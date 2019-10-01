unit uDepServer;

interface

uses System.SysUtils, IdHTTPWebBrokerBridge, IdSocketHandle;

type
  // Singleton
  TDepServer = class
  strict private
    class var FInstance: TDepServer;
{$HINTS OFF}
    constructor Create;
    destructor Destroy; override;
    class destructor Destroy;
    // class constructor Create;
{$HINTS ON}
  public
    class procedure Init;
    // Точка доступа к экземпляру
    class function GetInstance: TDepServer;
    class procedure CheckInstance;
  private
    // FServerParams: TServerParams;
    // FRequestHandler: TRequestHandler;
    FWebServer: TIdHTTPWebBrokerBridge;
    FEnabled: Boolean;
  public
    procedure Enable;
    procedure Disable;
  end;

implementation

resourcestring
  RsErrServerStopped = 'Сервер остановлен';
  RsErrServerNotSarted = 'Сервер не запущен';

  { TDepServer }

class procedure TDepServer.CheckInstance;
begin
  if not Assigned(FInstance) then
    raise Exception.Create(RsErrServerNotSarted);
end;

constructor TDepServer.Create;
begin
  inherited;

  FWebServer := TIdHTTPWebBrokerBridge.Create(nil);
end;

class destructor TDepServer.Destroy;
begin
  FreeAndNil(FInstance);
end;

destructor TDepServer.Destroy;
begin
  Disable;
  FreeAndNil(FWebServer);
end;

procedure TDepServer.Disable;
begin
  FEnabled := False;

end;

procedure TDepServer.Enable;
begin
  Disable;

  FEnabled := True;
end;

class function TDepServer.GetInstance: TDepServer;
begin
  CheckInstance;
  Result := FInstance;
end;

class procedure TDepServer.Init;
begin
  if not Assigned(FInstance) then
    FInstance := TDepServer.Create;
end;

end.
