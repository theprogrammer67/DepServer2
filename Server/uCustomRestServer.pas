unit uCustomRestServer;

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
  public
    constructor Create;
    destructor Destroy; override;
  public
    procedure Enable;
    procedure Disable;
  public
    property Enabled: Boolean read FEnabled write SetEnabled;
    property RequestHandler: TRequestHandler read FRequestHandler;
  end;


implementation


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
