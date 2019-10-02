unit uCommonSvrTypes;

interface

uses System.Classes, System.SysUtils, Web.HTTPApp, uCommonTypes, XSuperObject;

type
  TCustomCmd = class
  public
    constructor Create;
    destructor Destroy; override;
  public
    Method: TRequestMethod;
    Path: string;
    Params: TStrings;
    Request:ISuperObject;
    Response:ISuperObject;
  end;

  ICustomCmd = interface(IObjWrapper<TCustomCmd>)
    ['{7D8EB6F4-7FC6-4A0E-B699-F9378DC13B0E}']
    function GetMethod: TRequestMethod;
    procedure SetMethod(AValue: TRequestMethod);
    function GetPath: string;
    procedure SetPath(AValue: string);
    function GetParams: TStrings;
    procedure SetParams(AValue: TStrings);
    function GetRequest: ISuperObject;
    procedure SetRequest(AValue: ISuperObject);
    function GetResponse: ISuperObject;
    procedure SetResponse(AValue: ISuperObject);
    property Method : TRequestMethod read GetMethod write SetMethod;
    property Path : string read GetPath write SetPath;
    property Params : TStrings read GetParams write SetParams;
    property Request : ISuperObject read GetRequest write SetRequest;
    property Response : ISuperObject read GetResponse write SetResponse;
  end;

  TCustomCmdIntf = class(TObjWrapper<TCustomCmd>, ICustomCmd)
  public
    constructor Create(AMethod: TRequestMethod; const APath, AParams, ARequest: string);
  public
    function GetMethod: TRequestMethod;
    procedure SetMethod(AValue: TRequestMethod);
    function GetPath: string;
    procedure SetPath(AValue: string);
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

{ TDataCmdIntf }

constructor TCustomCmdIntf.Create(AMethod: TRequestMethod; const APath, AParams,
  ARequest: string);
begin
  inherited Create(True);

  FObj.Method := AMethod;
  FObj.Path := APath;
  ExtractHTTPFields(['&'], [], AParams, FObj.Params);
  FObj.Request := SO(ARequest);
  FObj.Response := SO;
end;

function TCustomCmdIntf.GetMethod: TRequestMethod;
begin
  Result := FObj.Method;
end;

function TCustomCmdIntf.GetParams: TStrings;
begin
  Result := FObj.Params;
end;

function TCustomCmdIntf.GetPath: string;
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

procedure TCustomCmdIntf.SetPath(AValue: string);
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
  FreeAndNil(PArams);
  inherited;
end;

end.
