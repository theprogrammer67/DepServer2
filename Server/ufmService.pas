unit ufmService;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes,
  Vcl.SvcMgr;

type
  TDepServer2Service = class(TService)
    procedure ServiceAfterInstall(Sender: TService);
    procedure ServiceAfterUninstall(Sender: TService);
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServicePause(Sender: TService; var Paused: Boolean);
    procedure ServiceContinue(Sender: TService; var Continued: Boolean);
    procedure ServiceShutdown(Sender: TService);
    procedure ServiceDestroy(Sender: TObject);
  public
    function GetServiceController: TServiceController; override;
    procedure Enable;
  end;

var
  DepServer2Service: TDepServer2Service;

implementation

uses System.Win.Registry;

resourcestring
  SERVICE_DESCRIPTION = '1С-Рарус: Депозитно-дисконтный сервер ред. 2';

{$R *.dfm}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  DepServer2Service.Controller(CtrlCode);
end;

procedure TDepServer2Service.Enable;
begin
//  try
//    ReplicationServer.Enable;
//    LogMessage('Start service successfully', EVENTLOG_INFORMATION_TYPE, 0, 1);
//  except
//    LogMessage(Exception(ExceptObject).Message, EVENTLOG_ERROR_TYPE, 0, 1);
//  end;
end;

function TDepServer2Service.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TDepServer2Service.ServiceAfterInstall(Sender: TService);
var
  Reg: TRegIniFile;
begin
  Reg := TRegIniFile.Create(KEY_ALL_ACCESS);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    // Создаём системный лог для себя
    Reg.OpenKey('\SYSTEM\CurrentControlSet\Services\Eventlog\Application\' +
      DisplayName, True);
    Reg.WriteString('\SYSTEM\CurrentControlSet\Services\Eventlog\Application\' +
      DisplayName, 'EventMessageFile', ParamStr(0));
    TRegistry(Reg).WriteInteger('TypesSupported', 7);
    // Прописываем себе описание
    Reg.WriteString('\SYSTEM\CurrentControlSet\Services\' + Name, 'Description',
      SERVICE_DESCRIPTION);
  finally
    FreeAndNil(Reg);
  end;
end;

procedure TDepServer2Service.ServiceAfterUninstall(Sender: TService);
var
  Reg: TRegIniFile;
begin
  Reg := TRegIniFile.Create(KEY_ALL_ACCESS);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    // Удалим свой системный лог
    Reg.EraseSection
      ('\SYSTEM\CurrentControlSet\Services\Eventlog\Application\' + Name);
  finally
    FreeAndNil(Reg);
  end;
end;

procedure TDepServer2Service.ServiceContinue(Sender: TService;
  var Continued: Boolean);
begin
  Enable;
  Continued := True;
end;

procedure TDepServer2Service.ServiceDestroy(Sender: TObject);
begin
//  ReplicationServer.Disable;
end;

procedure TDepServer2Service.ServicePause(Sender: TService;
  var Paused: Boolean);
begin
//  ReplicationServer.Disable;
  Paused := True;
end;

procedure TDepServer2Service.ServiceShutdown(Sender: TService);
begin
//  ReplicationServer.Disable;
end;

procedure TDepServer2Service.ServiceStart(Sender: TService;
  var Started: Boolean);
begin
//  LogMessage('Start service', EVENTLOG_INFORMATION_TYPE, 0, 1);
//  Enable;
  Started := True;
end;

procedure TDepServer2Service.ServiceStop(Sender: TService;
  var Stopped: Boolean);
begin
//  LogMessage('Stop service', EVENTLOG_INFORMATION_TYPE, 0, 1);
//  ReplicationServer.Disable;
  Stopped := True;
end;

end.
