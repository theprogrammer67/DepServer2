unit uDepServer;

interface

uses System.SysUtils, IdHTTPWebBrokerBridge, IdSocketHandle, uCommonSvrTypes,
  uRequestHandler, uConsts;

type
  TCustomRestServer = class
  private
    FWebServer: TIdHTTPWebBrokerBridge;
    FRequestHandler: TRequestHandler;
    FEnabled: Boolean;
  private // Вeб-сервер
    procedure EnableWebServer;
    procedure DisableWebServer;
  private
    procedure ExecuteDataCmd(ACmd: ICustomCmd);
    procedure ExecuteControlCmd(ACmd: ICustomCmd);
    procedure SetEnabled(const Value: Boolean);
  protected
{$HINTS OFF}
    constructor Create; virtual;
    destructor Destroy; reintroduce; virtual;
{$HINTS ON}
  public
    procedure Enable;
    procedure Disable;
  public
    property Enabled: Boolean read FEnabled write SetEnabled;
    property RequestHandler: TRequestHandler read FRequestHandler;
  end;

  // Singleton
  TDepServer = class(TCustomRestServer)
  strict private
    class var FInstance: TDepServer;
{$HINTS OFF}
    constructor Create; override;
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
  end;

function DepServer: TDepServer;

implementation

resourcestring
  RsErrServerStopped = 'Сервер остановлен';
  RsErrServerNotSarted = 'Сервер не запущен';

function DepServer: TDepServer;
begin
  Result := TDepServer.GetInstance;
end;

{ TDepServer }

class procedure TDepServer.CheckInstance;
begin
  if not Assigned(FInstance) then
    raise Exception.Create(RsErrServerNotSarted);
end;

constructor TDepServer.Create;
begin
  inherited;

end;

class destructor TDepServer.Destroy;
begin
  FreeAndNil(FInstance);
end;

destructor TDepServer.Destroy;
begin
  Disable;

  inherited;
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

{ TCustomRestServer }

constructor TCustomRestServer.Create;
begin
  FWebServer := TIdHTTPWebBrokerBridge.Create(nil);
  FRequestHandler := TRequestHandler.Create(ExecuteDataCmd, ExecuteControlCmd);
end;

destructor TCustomRestServer.Destroy;
begin
  Disable;

  FreeAndNil(FRequestHandler);
  FreeAndNil(FWebServer);
  inherited;
end;

procedure TCustomRestServer.Disable;
begin
  FEnabled := False;
  DisableWebServer;
end;

procedure TCustomRestServer.DisableWebServer;
begin
  if Assigned(FWebServer) and (FWebServer.Active) then
  begin
    FWebServer.Active := False;
    FWebServer.Bindings.Clear;
  end;
end;

procedure TCustomRestServer.Enable;
begin
  Disable;
  EnableWebServer;
  FEnabled := True;
end;

procedure TCustomRestServer.EnableWebServer;
var
  Socket: TIdSocketHandle;
begin
  DisableWebServer;

  FWebServer.Bindings.Clear;

  Socket := FWebServer.Bindings.Add;
  Socket.Port := DEF_PORT;

  FWebServer.DefaultPort := DEF_PORT;
  FWebServer.Active := True;
end;

procedure TCustomRestServer.ExecuteControlCmd(ACmd: ICustomCmd);
begin
  raise Exception.Create('Under construction');
end;

procedure TCustomRestServer.ExecuteDataCmd(ACmd: ICustomCmd);
begin
  raise Exception.Create('Under construction');
end;

procedure TCustomRestServer.SetEnabled(const Value: Boolean);
begin
  if Value then
    Enable
  else
    Disable;
end;

end.
