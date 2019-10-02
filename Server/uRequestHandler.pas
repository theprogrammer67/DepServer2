unit uRequestHandler;

interface

uses System.SysUtils, uCommonTypes, uCommonSvrTypes, XSuperObject;

const
  ERR_UNPROCESSABLE_ENTITY = 422;
  ERR_INTERNAL_SERVERERROR = 500;
  HTTP_OK = 200;

type
  EUnprocessableEntity = class(Exception);
  EInternalServerError = class(Exception);

  TExecuteCmd = procedure(ACmd: ICustomCmd) of object;

  TRequestHandler = class
  private
    FExecDataCmd: TExecuteCmd;
    FExecCtrlCmd: TExecuteCmd;
  public
    constructor Create(AExecDataCmd, AExecCtrlCmd: TExecuteCmd);
  public
    function HandleRequest(ARequestMethod: TRequestMethod;
      const APath, AParams, ARequestData: string;
      out AResponseData: string): Integer;
  end;

implementation

uses System.StrUtils;

const
  PATH_CONTROL = 'control';
  PATH_DATA = 'data';

resourcestring
  RsErrInvalidPath = 'Invalid path';

function NormalizePath(const APath: string): string;
var
  LPath: string;
begin
  LPath := APath;
  if APath = '' then
    Exit('');
  if LPath[1] = '/' then
    LPath.Remove(0, 1);
  if APath = '' then
    Exit('');
  if LPath[Length(LPath)] = '/' then
    LPath.Remove(Length(LPath), 1);
end;

function DeletePathItem(const APath: string; AIndex: Integer): string;
var
  LPos: Integer;
begin
  if APath = '' then
    Exit(APath);

  LPos := APath.IndexOf('/');
  if LPos < 0 then
    Exit(APath);

  Result := APath.Substring(LPos + 1, Length(APath) - LPos - 1);
end;

function ComparePathItem(const APath, AText: string; AIndex: Integer): Boolean;
var
  LItems: TArray<string>;
begin
  if APath = '' then
    Exit(False);

  LItems := APath.Split(['/']);
  if (AIndex > High(LItems)) or (AIndex < Low(LItems)) then
    Exit(False);

  Result := SameText(LItems[AIndex], AText);
end;

{ TRequestHandler }

constructor TRequestHandler.Create(AExecDataCmd, AExecCtrlCmd: TExecuteCmd);
begin
  FExecDataCmd := AExecDataCmd;
  FExecCtrlCmd := AExecCtrlCmd;
end;

function TRequestHandler.HandleRequest(ARequestMethod: TRequestMethod;
  const APath, AParams, ARequestData: string;
  out AResponseData: string): Integer;
var
  LCmd: ICustomCmd;
  LPath: string;
  LResponse: ISuperObject;
begin
  try
    LPath := NormalizePath(APath);
    LCmd := TCustomCmdIntf.Create(ARequestMethod, DeletePathItem(LPath, 0),
      AParams, ARequestData);

    if ComparePathItem(APath, PATH_CONTROL, 0) then
      FExecCtrlCmd(LCmd)
    else if ComparePathItem(APath, PATH_DATA, 0) then
      FExecDataCmd(LCmd)
    else
      raise EUnprocessableEntity.Create(RsErrInvalidPath);

    Result := HTTP_OK;
    AResponseData := LCmd.Response.AsJSON;
  except
    if ExceptObject is EUnprocessableEntity then
      Result := ERR_UNPROCESSABLE_ENTITY
    else
      Result := ERR_INTERNAL_SERVERERROR;

    LResponse := SO;
    LResponse.S['message'] := Exception(ExceptObject).Message;
    AResponseData := LResponse.AsJSON;
  end;
end;

end.
