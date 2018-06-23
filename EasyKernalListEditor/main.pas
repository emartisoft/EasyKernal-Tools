//
// Coded by emarti, Murat Ozdemir June 2018
//
unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons;

type
  { TFMain }

  TFMain = class(TForm)
    bPreview: TButton;
    bSelect: TButton;
    bSave: TButton;
    bAbout: TButton;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Image1: TImage;
    Image2: TImage;
    Label2: TLabel;
    OpenDialog: TOpenDialog;
    gRoms: TGroupBox;
    Label1: TLabel;
    lRom1: TLabeledEdit;
    lRom2: TLabeledEdit;
    lRom3: TLabeledEdit;
    lRom4: TLabeledEdit;
    lRom5: TLabeledEdit;
    lRom6: TLabeledEdit;
    lRom7: TLabeledEdit;
    Panel1: TPanel;
    SaveDialog: TSaveDialog;
    bClear1: TSpeedButton;
    bClear2: TSpeedButton;
    bClear3: TSpeedButton;
    bClear4: TSpeedButton;
    bClear5: TSpeedButton;
    bClear6: TSpeedButton;
    bClear7: TSpeedButton;
    procedure bAboutClick(Sender: TObject);
    procedure bClear1Click(Sender: TObject);
    procedure bClear2Click(Sender: TObject);
    procedure bClear3Click(Sender: TObject);
    procedure bClear4Click(Sender: TObject);
    procedure bClear5Click(Sender: TObject);
    procedure bClear6Click(Sender: TObject);
    procedure bClear7Click(Sender: TObject);
    procedure bPreviewClick(Sender: TObject);
    procedure bSaveClick(Sender: TObject);
    procedure bSelectClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure ClearList;
    procedure FillList;
    procedure Preview;
    procedure ListToBuff(lRomX: TLabeledEdit; satir: integer);
  public

  end;

var
  FMain: TFMain;
  AFileName, SaveAFileName: string;
  karakter: string;
  liste: array [1..7] of string =
        ('','','','','','','');
  BuffEmarti: array [1..6] of byte = ( 05, 13, 01, 18, 20, 09);
  BuffEmartiC: array [1..6] of byte;
  Buff: array [1..196] of byte =
        (
            32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,0,
            32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,0,
            32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,0,
            32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,0,
            32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,0,
            32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,0,
            32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,0
        );

implementation

{$R *.lfm}

{ TFMain }

uses about;

procedure TFMain.FormCreate(Sender: TObject);
begin
  karakter:= '@abcdefghijklmnopqrstuvwxyz[@]@@ !"#$%&@()@+,-./0123456789:;<=>';
end;

procedure TFMain.FormShow(Sender: TObject);
begin

end;

procedure TFMain.ClearList;
var
 i: integer;
begin
  lRom1.Text:= '';
  lRom2.Text:= '';
  lRom3.Text:= '';
  lRom4.Text:= '';
  lRom5.Text:= '';
  lRom6.Text:= '';
  lRom7.Text:= '';
  for i:=1 to 7 do
  begin
    liste[i]:='';
  end;
end;

procedure TFMain.FillList;
var
   i:integer;
begin
  for i:= 1 to length(Buff) do
  begin
  if ((i mod 28)=0) then continue;
    case (i div 28) of
    0:
       lRom1.Text:= lRom1.Text + karakter.Substring(Buff[i],1) ;
    1:
       lRom2.Text:= lRom2.Text + karakter.Substring(Buff[i],1) ;
    2:
       lRom3.Text:= lRom3.Text + karakter.Substring(Buff[i],1) ;
    3:
       lRom4.Text:= lRom4.Text + karakter.Substring(Buff[i],1) ;
    4:
       lRom5.Text:= lRom5.Text + karakter.Substring(Buff[i],1) ;
    5:
       lRom6.Text:= lRom6.Text + karakter.Substring(Buff[i],1) ;
    6:
       lRom7.Text:= lRom7.Text + karakter.Substring(Buff[i],1) ;
    end;
  end;

end;

procedure TFMain.Preview;
var
   i,b,bx,by,y,x: integer;
begin
  ListToBuff(lRom1, 0);
  ListToBuff(lRom2, 1);
  ListToBuff(lRom3, 2);
  ListToBuff(lRom4, 3);
  ListToBuff(lRom5, 4);
  ListToBuff(lRom6, 5);
  ListToBuff(lRom7, 6);
  y:=12;
  x:=9*8;
  for i:= 1 to length(Buff) do
  begin
       if ((i mod 28)=0) then
       begin
         inc(y);
         x:=9*8;
         continue;
       end;
       b:= Buff[i];
       bx:= (b mod 8)*8;
       by:= (b div 8)*8;
       Image1.Canvas.CopyRect(
         Rect(x, y*8, x+8, y*8+8),
         Image2.Canvas,
         Rect(bx,by,bx+8,by+8)
         );
       inc(x,8);
  end;
end;

procedure TFMain.ListToBuff(lRomX: TLabeledEdit; satir:integer);
Var
  i,x, index: integer;
  kernalName: string;
  space: integer;
begin
  kernalName:= lRomX.Text;
  space:= 27 - length(lRomX.Text);
  kernalName:= kernalName + StringOfChar(' ', space);
  index:= satir*28+1;
  for i:= 1 to length(kernalName) do
  begin
    for x:= 0 to length(karakter)-1 do
        begin
          if (CompareStr(kernalName[i],UTF8EnCode(karakter.Substring(x,1)))=0) then
             begin
               Buff[index]:= x;
               inc(index);
               break;
             end;
       end;
  end;
end;

procedure TFMain.bAboutClick(Sender: TObject);
begin
  FAbout.ShowModal;
end;

procedure TFMain.bClear1Click(Sender: TObject);
begin
  lRom1.Text:=''; lRom1.SetFocus;
end;

procedure TFMain.bClear2Click(Sender: TObject);
begin
  lRom2.Text:=''; lRom2.SetFocus;
end;

procedure TFMain.bClear3Click(Sender: TObject);
begin
  lRom3.Text:=''; lRom3.SetFocus;
end;

procedure TFMain.bClear4Click(Sender: TObject);
begin
  lRom4.Text:=''; lRom4.SetFocus;
end;

procedure TFMain.bClear5Click(Sender: TObject);
begin
  lRom5.Text:=''; lRom5.SetFocus;
end;

procedure TFMain.bClear6Click(Sender: TObject);
begin
  lRom6.Text:=''; lRom6.SetFocus;
end;

procedure TFMain.bClear7Click(Sender: TObject);
begin
  lRom7.Text:=''; lRom7.SetFocus;
end;

procedure TFMain.bPreviewClick(Sender: TObject);
begin
  Preview;
end;

procedure TFMain.bSaveClick(Sender: TObject);
var
 sv, fs: TFileStream;
begin
  Preview;
  if SaveDialog.Execute then
  begin
    if (SaveDialog.FileName.Equals(AFileName)) then
    begin
      ShowMessage('Can not save file to destination file. Please enter different file name.');
      bSaveClick(self);
    end
    else
    begin
      fs := TFileStream.Create( AFileName, fmOpenRead );
      try
         sv := TFileStream.Create( SaveDialog.FileName, fmOpenWrite or fmCreate );
         try
               sv.CopyFrom(fs, fs.Size);
               sv.Position := $0000227;
               sv.Write(Buff, Length(Buff));
         finally
                sv.Free;
         end;
      finally
         fs.Free;
         ShowMessage('The file is saved successfully.');
      end;
    end;
  end;
end;

procedure TFMain.bSelectClick(Sender: TObject);
var
  fs: TFileStream;
  csize, x: integer;
  correctFile: boolean;
begin
  csize:= Length(BuffEmarti);
  correctFile:= true;
  if OpenDialog.Execute then
  begin
    AFileName:= OpenDialog.FileName;
    fs := TFileStream.Create(AFileName, fmOpenReadWrite);
    try
      fs.Position := $0002183;
      fs.Read(BuffEmartiC, csize);
      for x:= 1 to csize do
          begin
            if not (BuffEmarti[x] = BuffEmartiC[x]) then correctFile:= false;
          end;
      fs.Position := $0000227;
      fs.Read(Buff, Length(Buff));
    finally
      fs.Free;
    end;

    if correctFile then
    begin
      bSave.Enabled:= true;
      gRoms.Enabled:=true;
      bPreview.Enabled:= true;
      FillList;
      Preview;
    end
    else
    begin
      ShowMessage('File not patch to edit rom list. Please select romselector.prg.');
    end;
  end
  else
  begin
     bSave.Enabled:= false;
     gRoms.Enabled:=false;
     bPreview.Enabled:= false;
     ClearList;
  end;
end;

end.

