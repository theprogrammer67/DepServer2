unit ufmApplication;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uDepServer, Vcl.StdCtrls;

type
  TfrmApplication = class(TForm)
    btnEnable: TButton;
    btnDisable: TButton;
    procedure btnDisableClick(Sender: TObject);
    procedure btnEnableClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmApplication: TfrmApplication;

implementation

{$R *.dfm}

procedure TfrmApplication.btnDisableClick(Sender: TObject);
begin
  DepServer.Disable;
end;

procedure TfrmApplication.btnEnableClick(Sender: TObject);
begin
  DepServer.Enable;
end;

end.
