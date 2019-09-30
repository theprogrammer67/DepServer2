program DepServer2;

uses
  Vcl.Forms,
  Vcl.SvcMgr,
  System.SysUtils,
  Winapi.Windows,
  Web.WebReq,
  ufmApplication in 'ufmApplication.pas' {frmApplication} ,
  uConsts in 'uConsts.pas',
  ufmService in 'ufmService.pas' {DepServer2Service: TService};

{$R *.res}

var
  IsGuiApp: Boolean;

begin
{$IFDEF DEBUG}
  // Для отображения утечек памяти, если они есть
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF}
  FindCmdLineSwitch('InstanceID', InstancePostfix);
  IsGuiApp := FindCmdLineSwitch('GUI');

  if IsGuiApp then
  begin
    FreeAndNil(Vcl.SvcMgr.Application);

    Vcl.Forms.Application.Initialize;
    Vcl.Forms.Application.CreateForm(TfrmApplication, frmApplication);
    Vcl.Forms.Application.Run;
  end
  else
  begin
    if not Vcl.SvcMgr.Application.DelayInitialize or Vcl.SvcMgr.Application.Installing
    then
      Vcl.SvcMgr.Application.Initialize;
    Vcl.SvcMgr.Application.CreateForm(TDepServer2Service, DepServer2Service);
    Vcl.SvcMgr.Application.Run;
  end;

end.
