unit uRequestHandler;

interface

uses System.Generics.Collections, ArrayHelper, System.SysUtils, uCommonTypes,
  uCommonSvrTypes, XSuperObject;

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
  RsErrInvalidPath = 'Неверное значение path';

function NormalizePath(const APath: string): string;
begin
  Result := APath;
  if APath = '' then
    Exit('');

  if Result[1] = '/' then
    Result := Result.Remove(0, 1);
  if Result = '' then
    Exit('');
  if Result[Length(Result)] = '/' then
    Result := Result.Remove(Length(Result), 1);
end;

function GetPathArray(const APath: string): TArray<string>;
var
  LPath: string;
begin
  SetLength(Result, 0);
  LPath := NormalizePath(APath);
  if LPath = '' then
    Exit;

  Result := LPath.Split(['/']);
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
  LPath: TArray<string>;
  LResponse: ISuperObject;
  LBasePath: string;
begin
  if Pos('favicon.ico', APath) > 0 then
    Exit(HTTP_OK);

  try
    LPath := GetPathArray(APath);
    if Length(LPath) = 0 then
      raise EUnprocessableEntity.Create(RsErrInvalidPath);

    LBasePath := LPath[0];
    TArray.Delete<string>(LPath, 0);

    LCmd := TCustomCmdIntf.Create(ARequestMethod, LPath, AParams, ARequestData);

    if SameText(LBasePath, PATH_CONTROL) then
      FExecCtrlCmd(LCmd)
    else if SameText(LBasePath, PATH_DATA) then
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
