unit uDepServer;

interface

uses System.SysUtils, IdHTTPWebBrokerBridge, IdSocketHandle, uCommonSvrTypes,
  uRequestHandler;

type
  TCustomRestServer = class
  private
    FWebServer: TIdHTTPWebBrokerBridge;
    FRequestHandler: TRequestHandler;
    FEnabled: Boolean;
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

end;

class destructor TDepServer.Destroy;
begin
  FreeAndNil(FInstance);
end;

destructor TDepServer.Destroy;
begin
  Disable;
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

end;

procedure TCustomRestServer.Enable;
begin
  Disable;

  FEnabled := True;
end;

procedure TCustomRestServer.ExecuteControlCmd(ACmd: ICustomCmd);
begin

end;

procedure TCustomRestServer.ExecuteDataCmd(ACmd: ICustomCmd);
begin

end;

procedure TCustomRestServer.SetEnabled(const Value: Boolean);
begin
  if Value then
    Enable
  else
    Disable;
end;

end.
