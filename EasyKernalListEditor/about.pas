//
// Coded by emarti, Murat Ozdemir June 2018
//
unit about;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls;

type

  { TFAbout }

  TFAbout = class(TForm)
    bOk: TButton;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lWebSite: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    procedure bOkClick(Sender: TObject);
    procedure lWebSiteClick(Sender: TObject);
  private

  public

  end;

var
  FAbout: TFAbout;

implementation

{$R *.lfm}

{ TFAbout }

uses lclintf;

procedure TFAbout.bOkClick(Sender: TObject);
begin
  Close;
end;

procedure TFAbout.lWebSiteClick(Sender: TObject);
begin
  OpenURL(lWebSite.Caption);
end;

end.

