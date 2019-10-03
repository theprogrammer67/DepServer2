unit uCommonSvrTypes;

interface

uses System.Classes, System.SysUtils, Web.HTTPApp, uCommonTypes, XSuperObject;

type
  EUnprocessableEntity = class(Exception);
  EInternalServerError = class(Exception);

  TCustomCmd = class
  public
    constructor Create;
    destructor Destroy; override;
  public
    Method: TRequestMethod;
    Path: TArray<string>;
    Params: TStrings;
    Request: ISuperObject;
    Response: ISuperObject;
  end;

  ICustomCmd = interface(IObjWrapper<TCustomCmd>)
    ['{7D8EB6F4-7FC6-4A0E-B699-F9378DC13B0E}']
    function GetMethod: TRequestMethod;
    procedure SetMethod(AValue: TRequestMethod);
    function GetPath: TArray<string>;
    procedure SetPath(AValue: TArray<string>);
    function GetParams: TStrings;
    procedure SetParams(AValue: TStrings);
    function GetRequest: ISuperObject;
    procedure SetRequest(AValue: ISuperObject);
    function GetResponse: ISuperObject;
    procedure SetResponse(AValue: ISuperObject);
    property Method: TRequestMethod read GetMethod write SetMethod;
    property Path: TArray<string> read GetPath write SetPath;
    property Params: TStrings read GetParams write SetParams;
    property Request: ISuperObject read GetRequest write SetRequest;
    property Response: ISuperObject read GetResponse write SetResponse;
  end;

  TCustomCmdIntf = class(TObjWrapper<TCustomCmd>, ICustomCmd)
  public
    constructor Create(AMethod: TRequestMethod; APAth: TArray<string>;
      const AParams, ARequest: string);
  public
    function GetMethod: TRequestMethod;
    procedure SetMethod(AValue: TRequestMethod);
    function GetPath: TArray<string>;
    procedure SetPath(AValue: TArray<string>);
    function GetParams: TStrings;
    procedure SetParams(AValue: TStrings);
    function GetRequest: ISuperObject;
    procedure SetRequest(AValue: ISuperObject);
    function GetResponse: ISuperObject;
    procedure SetResponse(AValue: ISuperObject);
  end;

  IDepServer = interface
    ['{5A1111DC-EDAA-420F-AEEB-032BB7970A20}']
    procedure DoHandleDataRequest();
  end;

implementation

resourcestring
  RsErrWrongJSONString = 'Некорректная строка JSON';

  { TDataCmdIntf }

constructor TCustomCmdIntf.Create(AMethod: TRequestMethod;
  APAth: TArray<string>; const AParams, ARequest: string);
begin
  inherited Create(True);

  FObj.Method := AMethod;
  FObj.Path := APAth;
  ExtractHTTPFields(['&'], [], AParams, FObj.Params);
  try
    FObj.Request := TSuperObject.Create(ARequest);
  except
    raise EUnprocessableEntity.Create(RsErrWrongJSONString);
  end;
  FObj.Response := TSuperObject.Create;
end;

function TCustomCmdIntf.GetMethod: TRequestMethod;
begin
  Result := FObj.Method;
end;

function TCustomCmdIntf.GetParams: TStrings;
begin
  Result := FObj.Params;
end;

function TCustomCmdIntf.GetPath: TArray<string>;
begin
  Result := FObj.Path;
end;

function TCustomCmdIntf.GetRequest: ISuperObject;
begin
  Result := FObj.Request;
end;

function TCustomCmdIntf.GetResponse: ISuperObject;
begin
  Result := FObj.Response;
end;

procedure TCustomCmdIntf.SetMethod(AValue: TRequestMethod);
begin
  FObj.Method := AValue;
end;

procedure TCustomCmdIntf.SetParams(AValue: TStrings);
begin
  FObj.Params.Assign(AValue);
end;

procedure TCustomCmdIntf.SetPath(AValue: TArray<string>);
begin
  FObj.Path := AValue;
end;

procedure TCustomCmdIntf.SetRequest(AValue: ISuperObject);
begin
  FObj.Request := AValue;
end;

procedure TCustomCmdIntf.SetResponse(AValue: ISuperObject);
begin
  FObj.Response := AValue;
end;

{ TCustomCmd }

constructor TCustomCmd.Create;
begin
  Params := TStringList.Create;
end;

destructor TCustomCmd.Destroy;
begin
  FreeAndNil(Params);
  inherited;
end;

end.
