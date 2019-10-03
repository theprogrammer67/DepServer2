unit uDepServer;

interface

uses System.SysUtils, uCustomRestServer;

type
  // Singleton
  TDepServer = class(TCustomRestServer)
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

end.
