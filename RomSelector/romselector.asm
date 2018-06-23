; ==============================================================================
; Rom Selector for EasyKernal - I.R.on
; 09/04/2018 - Istanbul
; 
; Rom Selector GUI Version by emarti, Murat Ozdemir
; 17/06/2018 - Eskisehir
; ==============================================================================

; 2018 SYS2063

*=$0801

        BYTE    $0B, $08, $E2, $07, $9E, $32, $30, $36, $33, $00, $00, $00

;-------------------------------------------------------------------------------

RESET_HANDLER                   = $FCE2
CHROUT                          = $FFD2

;Zero page addresses used to address screen
COLLOW                          = $FB
COLHIGH                         = $FC

;Zero page addresses used to access file names
NAMELOW                         = $FD
NAMEHIGH                        = $FE

MODULATION_ADDRESS              = $F000

;-- Complex Interface Adapter --------------------------------------------------

CIA_1_BASE                      = $DC00
CIA_2_BASE                      = $DD00

PORT_A                          = $00
PORT_B                          = $01

TIMER_A_TOGGLE_BIT              = 64
TIMER_A_LO                      = $04
TIMER_A_HI                      = $05

;-- CIA Registers --------------------------------------------------------------
CIA_INT_MASK                    = $0D
CIA_TIMER_A_CTRL                = $0E
CIA_TIMER_B_CTRL                = $0F

;-- CIA Enums ------------------------------------------------------------------
CRA_TOD_IN_50HZ                 = 128
CRA_SP_MODE_OUTPUT              = 64
CRA_IN_MODE_CNT                 = 32
CRA_FORCE_LOAD                  = 16
CRA_RUN_MODE_ONE_SHOT           = 8
CRA_OUT_MODE_TOGGLE             = 4
CRA_PB6_ON                      = 2
CRA_START                       = 1

;-- Video Interface Chip -------------------------------------------------------
VIC_CONTROL_1                   = $D011
VIC_INT_CONTROL                 = $D01A
VIC_INT_ACK                     = $D019
VIC_BORDER_COLOR                = $D020
VIC_SCREEN_COLOR                = $D021

;-- VIC Enums
VIC_DEN                         = 16    

;------------------------------------------------------------------------------- 
PROCESSOR_PORT                  = $01
PP_CONFIG_ALL_RAM               = $34           ; RAM visible in $A000-$BFFF, $E000-$FFFF, $D000-$DFFF
PP_CONFIG_RAM_ON_ROM            = $35           ; RAM visible in $A000-$BFFF, $E000-$FFFF
PP_CONFIG_RAM_ON_BASIC          = $36           ; RAM visible in $A000-$BFFF
PP_CONFIG_DEFAULT               = $37           ; $A000-$BFFF, $E000-$FFFF is ROM, default config.

;-- Music ----------------------------------------------------------------------
MUSIC                           = $1000         ; init music
PLAY                            = $1003         ; play music
;-------------------------------------------------------------------------------
        *=$080F         
        
        SEI        
        JSR INIT                 
        JSR PRINTPAGE
        LDX #$00                                ;Puts the selector 
        JSR SETCURRENTROWHEAD                   ;to the first entry in the
        JSR SETARROW                            ;list
        
        LDA #$00
        JSR MUSIC                               ; init music
        
        SEI
        LDA #$7F
        STA $DC0D
        LDA #$00
        STA $DC0E
  
        LDX #$00
        STX $D012

        JSR IRQ_EnableDisplay
        JSR IRQ_EnableRasterInterrupts
;        LDA #$1B
;        STA $D011
;        LDA #$01
;        STA $D01A        

        LDA #$18
        STA $D018

        LDA #<KESINTI                           ; IRQ
        STA $0314
        LDA #>KESINTI
        STA $0315  
        CLI
        
INITIAL_PRESS
        JSR MINIKEY
        BNE INITIAL_PRESS
        
INPUT_GET 
        JSR MINIKEY
        BEQ INPUT_GET                           ; If zero then no key is pressed so repeat
        CMP LAST_KEY_PRESSED
        BEQ INPUT_GET
        STA LAST_KEY_PRESSED
        
        CMP #$20                                ; IF it's a DOWN character
        BEQ UP                                  ; Then continue iterate up in the menu
        CMP #$70                                ; IF it's a RIGHT character
        BEQ DOWN                                ; Then continue iterate down in the menu
        CMP #$10                                ; IF it's ENTER character
        BEQ ENTER                               ; Then launch the selected item
        CMP #$44                                ; music on/off M character
        BEQ MUSICONFF
        CMP #$50
        BEQ CHANGEBORDERCOLOR                   ; F3: Change border color
        CMP #$60
        BEQ CHANGECHARCOLOR                     ; F5: Change char color
        CMP #$40
        BEQ HELPSCREEN                          ; F1: Open & Close the help screen
        JMP INPUT_GET                           ; If other key then leave control to the main loop
                        
UP      
        LDA HELPSHOW
        BNE INPUT_GET
        JSR GETCURRENTROW
        JSR CLEARARROW
        TXA
        BNE NORMALUP
        LDX CURPAGEITEMS
NORMALUP        
        DEX
        JSR SETCURRENTROWHEAD   
        JSR SETARROW
        JMP INPUT_GET
DOWN    
        LDA HELPSHOW
        BNE INPUT_GET
        JSR GETCURRENTROW       
        JSR CLEARARROW
        INX
        CPX CURPAGEITEMS
        BNE ROLLINGDOWN
        LDX #$00
ROLLINGDOWN     
        JSR SETCURRENTROWHEAD 
        JSR SETARROW
        JMP INPUT_GET 

MUSICONFF
        JSR LMUSICONOFF
        JMP INPUT_GET

HELPSCREEN
        JSR LHELPSCREEN
        JMP INPUT_GET
ENTER   
        LDA HELPSHOW
        BNE INPUT_GET
        
        SEI
        JSR IRQ_DisableInterrupts
        JSR IRQ_DisableDisplay
        CLI

        JSR WasteTooMuchTime
        
        LDA #$00
        STA $D418
        
        JSR GETCURRENTROW
        JSR SwitchRom  
LOOP
        INC VIC_BORDER_COLOR
        JMP LOOP

CHANGEBORDERCOLOR
        JSR LCHANGEBORDERCOLOR
        JMP INPUT_GET

CHANGECHARCOLOR
        JSR LCHANGECHARCOLOR
        JMP INPUT_GET

;----------- Utility routines --------------------------------------------------
INIT            ; Input : None, Changed : A
        CLD
        LDA #$93                                ; CLEAR SCREEN
        JSR CHROUT
        LDA #$00                                ; SET COLOR
        STA VIC_BORDER_COLOR
        STA CSTART+1
        JSR CSTART
        LDA #$01
        STA VIC_SCREEN_COLOR
        JSR MAINSCREEN
        JSR IRQ_DisableInterrupts
        LDA #$00
        STA CIA_1_BASE + TIMER_A_LO
        RTS

SwitchRom
        INX
        TXA
        PHA
        JSR IRQ_DisableDisplay
        

        LDA MODULATION_ADDRESS
        JSR WasteTooMuchTime
        LDA MODULATION_ADDRESS  
        
        LDY #$FF
L1       
        DEY
        BNE L1

        LDA #$64
        JSR IRQ_Send
        
        LDA #$46
        JSR IRQ_Send    
        
        LDA #$17
        JSR IRQ_Send    
        
        PLA
        JSR IRQ_Send

        LDY #$FF
L2       
        DEY
        BNE L2
        JMP RESET_HANDLER     
        RTS
        
;-------------------------------------------------------------------------------
; Registers In : None
; Registers Used : A
;-------------------------------------------------------------------------------      
IRQ_DisableDisplay
        LDA VIC_CONTROL_1
        AND #$EF
        STA VIC_CONTROL_1       
        RTS
        
;-------------------------------------------------------------------------------
; Registers In : None
; Registers Used : A
;-------------------------------------------------------------------------------      
IRQ_EnableDisplay
        LDA VIC_CONTROL_1
        ORA #VIC_DEN
        STA VIC_CONTROL_1       
        RTS     

;-------------------------------------------------------------------------------
; Registers In : None
; Registers Used : A
;-------------------------------------------------------------------------------      
IRQ_EnableRasterInterrupts
        LDA #$01
        STA VIC_INT_CONTROL             ;Enable raster interrupts
        RTS

;-------------------------------------------------------------------------------
; Registers In : None
; Registers Used : A
;-------------------------------------------------------------------------------      
IRQ_DisableVICInterrupts
        ASL VIC_INT_ACK
        LDA #$00
        STA VIC_INT_CONTROL     
        RTS

;-------------------------------------------------------------------------------
; Registers In : None
; Registers Used : A
;-------------------------------------------------------------------------------      
IRQ_DisableCIAInterrupts
        LDA #$7f                        ; $7f = %01111111 
        STA CIA_1_BASE + CIA_INT_MASK   ; Turn off CIA 1 interrupts 
        STA CIA_2_BASE + CIA_INT_MASK   ; Turn off CIA 2 interrupts     
        LDA CIA_1_BASE + CIA_INT_MASK   ; cancel all CIA-IRQs in queue/unprocessed 
        LDA CIA_2_BASE + CIA_INT_MASK   ; cancel all CIA-IRQs in queue/unprocessed 
        RTS
        
;-------------------------------------------------------------------------------
; Registers In : None
; Registers Used : A
;-------------------------------------------------------------------------------      
IRQ_DisableInterrupts
        JSR IRQ_DisableVICInterrupts
        JSR IRQ_DisableCIAInterrupts
        RTS
           
;-------------------------------------------------------------------------------
;Registers In : A (Byte to send)
;Registers Used : X
;-------------------------------------------------------------------------------
IRQ_SendBit
        JSR WasteTooMuchTime
        LSR
        BCC L3
        LDX #255
        BNE _continue                   ; Fake unconditional jump, to make code relocatable.
L3
        LDX #128
_continue
        
        LDY MODULATION_ADDRESS          ; Cause interrupt on Attiny85
        JSR WasteCertainTime            
        LDY MODULATION_ADDRESS              
        RTS
        
WasteCertainTime
L4       
        DEX
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        ;
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP

        BNE L4
        RTS

WasteTooMuchTime
        LDX #15
OUTERWASTE      
        LDY #$FF
L5       
        DEY
        NOP
        BNE L5
        DEX
        BNE OUTERWASTE
        RTS
        
ToggleCondition                                 
        BYTE   0

;--- API routines --------------------------------------------------------------
; We will send 
; long interval Kernal Accesses for transmitting 1
; short interval Kernal Accesses for transmitting 0
; The idea here is : Receiver will measure the signal on /OE line. 
; It will measure how long the signal is kept high between two low states. (L/H/L) __|''|__
; If its in the range say N-Epsilon, N+Epsilon than c64 is transmitting a ZERO
; If its in the range say N*2-Epsilon, N*2+Epsilon than c64 is transmitting a ONE
;-------------------------------------------------------------------------------
; Registers In : A (Byte to send)
; Registers Used : X
;-------------------------------------------------------------------------------
IRQ_Send
        JSR IRQ_SendBit
        JSR IRQ_SendBit
        JSR IRQ_SendBit
        JSR IRQ_SendBit 
        JSR IRQ_SendBit
        JSR IRQ_SendBit
        JSR IRQ_SendBit
        JSR IRQ_SendBit
        RTS

IRQ_Wait        
        LDX #$FF
        LDY #$00 
        STY VIC_SCREEN_COLOR
MLO     
        LDY #$FF
L6       
        NOP
        NOP
        NOP
        NOP
        DEY
        BNE L6
        
        DEX
        BNE MLO         
        RTS

SETARROW        ; Input : X (current row), Changed : A, Y 
        LDY #$00
        LDA #112        ; CHECKED sign
        STA (COLLOW),Y
        RTS

CLEARARROW      ; Input : X (current row), Changed : A, Y 
        LDY #$00
        LDA #111        ; NOT CHECKED
        STA (COLLOW),Y
        RTS
        
SETCURRENTROW   ; Input : X (current row), Changed : None
        PHA
        STX CURRENTROW
        TXA
        PHA
        ASL
        TAX
        LDA COLS+2,X
        STA COLLOW
        INX
        LDA COLS+2,X
        STA COLHIGH     
        PLA
        TAX
        PLA
        RTS
        
SETCURRENTROWHEAD ; Input : X (current row), Changed : None
        PHA
        STX CURRENTROW
        TXA
        PHA
        ASL
        TAX
        LDA COLS+2,X
        CLC
        SBC #01
        STA COLLOW
        INX
        LDA COLS+2,X
        STA COLHIGH     
        PLA
        TAX
        PLA
        RTS
                
GETCURRENTROW   ; Input : None, Output : X (current row)
        LDX CURRENTROW
        RTS     

; list name length = 27 chars
KERNALLIST         
        TEXT 'Standart C64C Kernal       '
        BYTE 0
        TEXT 'SD2IEC Kernal 2.2          '
        BYTE 0
        TEXT 'JiffyDOS V6.01             '
        BYTE 0                 
        TEXT 'JaffyDOS V1.2              '
        BYTE 0                                         
        TEXT 'SpeedDOS Plus              '
        BYTE 0
        TEXT 'EXOS V4.0 JOE              '
        BYTE 0
        TEXT 'CockRoach Turbo-ROM V1     '
        BYTE 0
        

PRINTFILENAME   ; Input : None, Changed: Y, A
        LDY #$00
FILENAMEPRINT   
        LDA (NAMELOW),Y
        BNE NOTEND
        LDA #$20
NOTEND  
        CMP #$3F
        BMI SYMBOL
        CLC
        SBC #$3f
SYMBOL  
        STA (COLLOW),Y
        INY
        CPY #$1B                        ; 27 CHARS MENU ITEM LENGTH
        BNE FILENAMEPRINT
        RTS

    ;    BYTES 00*2      ; added bytes to avoid page boundary

CLEARLINE       ; Input : None, Changed: Y, A
        LDY #$00
        LDA #$20        
ICLEARLINE              
        STA (COLLOW),Y
        INY
        CPY #$1B ;************************
        BNE ICLEARLINE
        RTS

LAST_KEY_PRESSED 
        BYTE 0

COMMANDBYTE     
        BYTE 0

COMMANDARG  
        BYTE 0, 0, 0, 0

CURRENTROW      
        BYTE 0

CURPAGENAMELOW  
        BYTE <KERNALLIST

CURPAGENAMEHIGH 
        BYTE >KERNALLIST

;NAMESLO   
;        BYTE <L7

;NAMESHI   
;        BYTE >L7
        
CURPAGEITEMS    
        BYTE 7

PAGECOUNT       
        BYTE 1

CURPAGEINDEX    
        BYTE 1  

;sil
        BYTE 0,0
        
PRINTPAGE       ; Input : None, Changed : A, X, Y
        LDA CURPAGENAMELOW
        STA NAMELOW
        LDA CURPAGENAMEHIGH
        STA NAMEHIGH

        LDX #$00
SETCOL  
        JSR SETCURRENTROW

        JSR PRINTFILENAME
        
        INX
        CPX CURPAGEITEMS
        BEQ FINISH      
        LDA NAMELOW
        CLC
        ADC #$1C ;***************
        STA NAMELOW
        BCC NEXTFILE
        INC NAMEHIGH
NEXTFILE
        JMP SETCOL      
FINISH
        CPX #$08; **** MADDE SAYISI
        BEQ ACTUALFINISH
        JSR SETCURRENTROW
        JSR CLEARLINE
        INX 
        CLV
        BVC FINISH
        
ACTUALFINISH    
        RTS


MINIKEY
        LDA #$0
        STA $DC03       ; PORT B DDR (INPUT)
        LDA #$FF
        STA $DC02       ; PORT A DDR (OUTPUT)
                        
        LDA #$00
        STA $DC00       ; PORT A
        LDA $DC01       ; PORT B
        CMP #$FF
        BEQ NOKEY
        ; GOT COLUMN
        TAY
                        
        LDA #$7F
        STA NOKEY2+1
        LDX #8
NOKEY2
        LDA #0
        STA $DC00       ; PORT A
        
        SEC
        ROR NOKEY2+1
        DEX
        BMI NOKEY
                        
        LDA $DC01       ; PORT B
        CMP #$FF
        BEQ NOKEY2
                        
        ; GOT ROW IN X
        TXA
        ORA COLUMNTAB,Y
        SEC
        RTS
                        
NOKEY
        CLC
        RTS

COLUMNTAB
        BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,$FF, $FF, $FF, $FF,$FF, $FF, $FF, $FF,$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,$FF, $FF, $FF, $FF,$FF, $FF, $FF, $FF
        BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,$FF, $FF, $FF, $FF,$FF, $FF, $FF, $FF,$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,$FF, $FF, $FF, $FF,$FF, $FF, $FF, $FF
        BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,$FF, $FF, $FF, $FF,$FF, $FF, $FF, $FF,$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,$FF, $FF, $FF, $FF,$FF, $FF, $FF, $FF
        BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,$FF, $FF, $FF, $FF,$FF, $FF, $FF, $FF,$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,$FF, $FF, $FF, $FF,$FF, $FF, $FF, $70
        BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,$FF, $FF, $FF, $FF,$FF, $FF, $FF, $FF,$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,$FF, $FF, $FF, $FF,$FF, $FF, $FF, $FF
        BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,$FF, $FF, $FF, $FF,$FF, $FF, $FF, $FF,$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,$FF, $FF, $FF, $FF,$FF, $FF, $FF, $60
        BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,$FF, $FF, $FF, $FF,$FF, $FF, $FF, $FF,$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,$FF, $FF, $FF, $FF,$FF, $FF, $FF, $50
        BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,$FF, $FF, $FF, $FF,$FF, $FF, $FF, $40,$FF, $FF, $FF, $FF, $FF, $FF, $FF, $30,$FF, $FF, $FF, $20,$FF, $10, $00, $FF

COLS    
        WORD $05C1, $05E9, $0611, $0639, $0661, $0689, $06B1, $06D9

KESINTI        
        LDA #$30
k1      CMP $D012
        BNE k1
        LDA MONOFF
        AND #$01
        CMP #$00
        BEQ MUTE
        JSR PLAY
CINT    LSR VIC_INT_ACK
        JMP $EA81
MUTE    LDA #$00        
        STA $D418
        JMP CINT

HELPSHOW
        BYTE $00                                ; 1: OPEN 0: CLOSE
MONOFF  
        BYTE $01                                ; music on:1 off:0 

LHELPSCREEN
        INC HELPSHOW
        LDA HELPSHOW
        AND #$01
        STA HELPSHOW
        BNE HELPOPEN
        JSR MAINSCREEN
        JSR PRINTPAGE  
        LDX #$00                                ;Puts the selector 
        JSR SETCURRENTROWHEAD                   ;to the first entry in the
        JSR SETARROW
        RTS
HELPOPEN
        JSR HELPWINDOW
        RTS

LMUSICONOFF
        INC MONOFF      ; KARAKTER BASILACAK ON OFF
        LDA MONOFF
        AND #$01
        BEQ MUTES
        LDA #$40
        JMP MSIGN
MUTES   LDA #$6E
MSIGN   STA $0426
        RTS

LCHANGEBORDERCOLOR
        INC VIC_SCREEN_COLOR
        LDA VIC_SCREEN_COLOR
        AND #$0F
        CMP CSTART+1
        BNE NOTSAMECOLOR
        INC VIC_SCREEN_COLOR
NOTSAMECOLOR
        RTS

LCHANGECHARCOLOR
        INC CSTART+1
        LDA CSTART+1
        AND #$0F
        STA VIC_BORDER_COLOR
        STA CSTART+1
        LDA VIC_SCREEN_COLOR
        AND #$0F
        CMP CNGCOLOR-1
        BNE CSTART
        INC CSTART+1
        INC VIC_BORDER_COLOR
        LDX #$00
CSTART
        LDA #$00                                ; CHAR COLOR
CNGCOLOR
        STA $D800,X
        STA $D900,X
        STA $DA00,X
        STA $DB00,X
        INX
        BNE CNGCOLOR
        RTS
        
       

MAINSCREEN
        LDX #$00
LMS     LDA MAINSCREENMAP,X
        STA $0400,X
        LDA MAINSCREENMAP+$0100,X
        STA $0500,X
        LDA MAINSCREENMAP+$0200,X
        STA $0600,X
        LDA MAINSCREENMAP+$0300,X
        STA $0700,X
        INX
        BNE LMS
        JSR LMUSICONOFF+3
        RTS


HELPWINDOW
        LDX #$00
LHS     LDA HELPSCREENMAP,X
        STA $0400,X
        LDA HELPSCREENMAP+$0100,X
        STA $0500,X
        LDA HELPSCREENMAP+$0200,X
        STA $0600,X
        LDA HELPSCREENMAP+$0300,X
        STA $0700,X
        INX
        BNE LHS
        JSR LMUSICONOFF+3
        RTS



incasm "music.asm"
incasm "charset.asm"
incasm "helpscreen.asm"
incasm "mainscreen.asm"
