unit uCustomRestServer;

interface

uses System.SysUtils, System.Classes, IdHTTPWebBrokerBridge, IdSocketHandle,
  uCommonSvrTypes,
  uRequestHandler, uConsts, System.Rtti, XSuperObject, uCommonTypes;

type
  CtrlMethAttribute = class(TCustomAttribute)
  private
    FCmdName: string;
  public
    constructor Create(const ACmdName: string);
  public
    property CmdName: string read FCmdName;
  end;

  DataMethAttribute = class(TCustomAttribute)
  private
    FPath: string;
    FMethod: TRequestMethod;
  public
    constructor Create(const APath: string; AMethod: TRequestMethod);
  public
    property Path: string read FPath;
    property Method: TRequestMethod read FMethod;
  end;

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
  public
    [CtrlMethAttribute('Test')]
    function Test(Param1, Param2: string): string;
    [CtrlMethAttribute('TestInt')]
    function TestInt(Param1, Param2: Integer): Integer;
  public
    [DataMethAttribute('cards/{CardId}', rmGet)]
    function getCardById(ACardId: string): ISuperObject;
    [DataMethAttribute('cards', rmPost)]
    procedure addCards(AData: ISuperObject);
  end;

resourcestring
  RsErrUnknownCommand = 'Неизвестная команда';

implementation

uses System.Variants;

resourcestring
  RsErrInvalidPath = 'Invalid path';

function VarToFloatDef(AValue: OleVariant; const ADefault: Extended = 0)
  : Extended;
var
  LValueStr: string;
begin
  if (not VarIsNull(AValue)) and (not VarIsEmpty(AValue)) then
    if VarIsStr(AValue) then
    begin
      LValueStr := Trim(VarToStr(AValue));
      LValueStr := StringReplace(LValueStr, ',',
        FormatSettings.DecimalSeparator, [rfReplaceAll]);
      LValueStr := StringReplace(LValueStr, '.',
        FormatSettings.DecimalSeparator, [rfReplaceAll]);
      Result := StrToFloatDef(LValueStr, ADefault);
    end
    else
      Result := AValue
  else
    Result := ADefault;
end;

function VarToIntDef(AValue: OleVariant; const ADefault: Integer = 0): Integer;
var
  LValueStr: string;
begin
  if (not VarIsNull(AValue)) and (not VarIsEmpty(AValue)) then
    if VarIsStr(AValue) then
    begin
      LValueStr := Trim(VarToStr(AValue));
      Result := StrToIntDef(AValue, ADefault);
    end
    else
      Result := AValue
  else
    Result := ADefault;
end;

function VarToStrDef(AValue: OleVariant; const ADefault: string = ''): string;
begin
  if (not VarIsNull(AValue)) and (not VarIsEmpty(AValue)) then
    Result := VarToStr(AValue)
  else
    Result := ADefault;
end;

function VarToValue(AValue: OleVariant; AKind: TTypeKind): TValue;
begin
  case AKind of
    tkInteger, tkInt64:
      Result := VarToIntDef(AValue);
    tkFloat:
      Result := VarToFloatDef(AValue);
    tkWChar, tkLString, tkWString, tkString, tkChar, tkUString:
      Result := VarToStrDef(AValue);
    tkVariant:
      Result := TValue.FromVariant(AValue);
  else
    raise EConvertError.Create('Cannot convert OleVariant to TValue');
  end;
end;

{ TCustomRestServer }

procedure TCustomRestServer.addCards(AData: ISuperObject);
begin

end;

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
var
  LCtx: TRttiContext;
  LType: TRttiType;
  LMethod: TRttiMethod;
  LAttribute: TCustomAttribute;
  LFound: Boolean;
  LArgs: TArray<TValue>;
  LCmdName: string;
  I: Integer;
  LParams: TArray<TRttiParameter>;
  LResult: TValue;
begin
  if Length(ACmd.Path) = 0 then
    raise EUnprocessableEntity.Create(RsErrInvalidPath);
  // Сначала ищем среди методов
  LFound := False;
  LCmdName := ACmd.Path[0];

  LCtx := TRttiContext.Create;
  try
    LType := LCtx.GetType(Self.ClassType);
    for LMethod in LType.GetMethods do
      for LAttribute in LMethod.GetAttributes do
        if LAttribute is CtrlMethAttribute then
          with CtrlMethAttribute(LAttribute) do
            if SameText(LCmdName, CmdName) then
            begin
              LFound := True;

              LParams := LMethod.GetParameters;
              SetLength(LArgs, Length(LParams));

              for I := 0 to High(LParams) do
                LArgs[I] := VarToValue(ACmd.Params.Values[LParams[I].Name],
                  LParams[I].ParamType.TypeKind);

              LResult := LMethod.Invoke(Self, LArgs);

              ACmd.Response.V['Result'] := LResult.AsVariant;
              for I := 0 to High(LParams) do
                ACmd.Response.V[LParams[I].Name] := LArgs[I].AsVariant;

              Break;
            end;
  finally
    LCtx.Free;
  end;

  if not LFound then
    raise Exception.Create(RsErrUnknownCommand);
end;

procedure TCustomRestServer.ExecuteDataCmd(ACmd: ICustomCmd);

  function MatchPath(APattern, APath: TArray<string>): Boolean;
  var
    I: Integer;
  begin
    if Length(APattern) <> Length(APath) then
      Exit(False);

    for I := Low(APattern) to High(APattern) do
    begin
      if (Length(APattern[I]) = 0) or (Length(APath[I]) = 0) then
        raise Exception.Create(RsErrInvalidPath);

      if APattern[I][1] = '{' then
        Continue;

      if not SameText(APattern[I], APath[I]) then
        Exit(False);
    end;

    Result := True;
  end;

  function GetPathParams(APattern, APath: TArray<string>): TStrings;
  var
    I: Integer;
    LName: string;
  begin
    Result := TStringList.Create;
    try
      if Length(APattern) <> Length(APath) then
        raise Exception.Create(RsErrInvalidPath);

      for I := Low(APattern) to High(APattern) do
      begin
        if (Length(APattern[I]) = 0) or (Length(APath[I]) = 0) then
          raise Exception.Create(RsErrInvalidPath);

        if APattern[I][1] <> '{' then
          Continue;

        LName := Copy(APattern[I], 2, Length(APattern[I]) - 2);
        Result.Values[LName] := APath[I];
      end;
    except
      FreeAndNil(Result);
      raise;
    end;
  end;

var
//  LCtx: TRttiContext;
//  LType: TRttiType;
//  LMethod: TRttiMethod;
//  LAttribute: TCustomAttribute;
  LFound: Boolean;
//  LArgs: TArray<TValue>;
//  // LCmdName: string;
//  I: Integer;
//  LParams: TArray<TRttiParameter>;
//  LResult: TValue;
begin
  if Length(ACmd.Path) = 0 then
    raise EUnprocessableEntity.Create(RsErrInvalidPath);
  // Сначала ищем среди методов
  LFound := False;
  // LCmdName := ACmd.Path[0];
  //
  // LCtx := TRttiContext.Create;
  // try
  // LType := LCtx.GetType(Self.ClassType);
  // for LMethod in LType.GetMethods do
  // for LAttribute in LMethod.GetAttributes do
  // if LAttribute is CtrlMethAttribute then
  // with CtrlMethAttribute(LAttribute) do
  // if SameText(LCmdName, CmdName) then
  // begin
  // LFound := True;
  //
  // LParams := LMethod.GetParameters;
  // SetLength(LArgs, Length(LParams));
  //
  // for I := 0 to High(LParams) do
  // LArgs[I] := VarToValue(ACmd.Params.Values[LParams[I].Name],
  // LParams[I].ParamType.TypeKind);
  //
  // LResult := LMethod.Invoke(Self, LArgs);
  //
  // ACmd.Response.V['Result'] := LResult.AsVariant;
  // for I := 0 to High(LParams) do
  // ACmd.Response.V[LParams[I].Name] := LArgs[I].AsVariant;
  //
  // Break;
  // end;
  // finally
  // LCtx.Free;
  // end;

  if not LFound then
    raise Exception.Create(RsErrUnknownCommand);
end;

function TCustomRestServer.getCardById(ACardId: string): ISuperObject;
begin

end;

procedure TCustomRestServer.SetEnabled(const Value: Boolean);
begin
  if Value then
    Enable
  else
    Disable;
end;

function TCustomRestServer.TestInt(Param1, Param2: Integer): Integer;
begin
  Result := Param1 + Param2;
end;

function TCustomRestServer.Test(Param1, Param2: string): string;
begin
  Result := Param1 + '+' + Param2;
end;

{ CtrlMethAttribute }

constructor CtrlMethAttribute.Create(const ACmdName: string);
begin
  FCmdName := ACmdName;
end;

{ DataMethAttribute }

constructor DataMethAttribute.Create(const APath: string;
  AMethod: TRequestMethod);
begin
  FPath := APath;
  FMethod := AMethod;
end;

end.
