//
// Coded by emarti, Murat Ozdemir June 2018
//
program EasyKernalListEditor;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, main, about;

{$R *.res}

begin
  Application.Title:='EasyKernal List Editor';
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TFMain, FMain);
  Application.CreateForm(TFAbout, FAbout);
  Application.Run;
end.

