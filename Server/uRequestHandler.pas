unit uRequestHandler;

interface

uses uCommonTypes, uCommonSvrTypes;

type
  TExecuteCmd = procedure(ACmd: ICustomCmd) of object;

  TRequestHandler = class
  private
    FExecDataCmd: TExecuteCmd;
    FExecCtrlCmd: TExecuteCmd;
  public
    constructor Create(AExecDataCmd, AExecCtrlCmd: TExecuteCmd);
  public
    procedure HandleRequest(ARequestType: TRequestMethod;
      const APath, ARequestData: string; out AResponseData: string);
  end;

implementation

{ TRequestHandler }

constructor TRequestHandler.Create(AExecDataCmd, AExecCtrlCmd: TExecuteCmd);
begin
  FExecDataCmd := AExecDataCmd;
  FExecCtrlCmd := AExecCtrlCmd;
end;

procedure TRequestHandler.HandleRequest(ARequestType: TRequestMethod;
  const APath, ARequestData: string; out AResponseData: string);
begin

end;

end.
