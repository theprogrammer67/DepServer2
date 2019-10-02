unit uCommonTypes;

interface

uses XSuperObject, System.Rtti, System.SysUtils;

type
  TRequestMethod = (rmGet, rmPut, rmDelete);

  IObjWrapper<T: class> = interface
    ['{9FB289A5-5BCE-4A4E-BC78-8B37E5B4875B}']
    function AsJSON: string;
    function GetObj: T;
    property Obj: T read GetObj;
  end;

  TObjWrapper<T: class> = class(TInterfacedObject)
  protected
    FObj: T;
    function GetObj: T;
  public
    constructor Create(ACreateObject: Boolean); overload; virtual;
    constructor Create(AObject: T); overload;
    constructor FromJSON(const AJson: string);
    destructor Destroy; override;
  public
    function AsJSON: string;
  end;

implementation

{ TObjWrapper<T> }

constructor TObjWrapper<T>.Create(ACreateObject: Boolean);
var
  LCtx: TRttiContext;
  LType: TRttiType;
begin
  inherited Create;
  if not ACreateObject then
    Exit;

  LCtx := TRttiContext.Create;
  try
    LType := LCtx.GetType(TypeInfo(T));
    if not Assigned(LType) then
      raise Exception.Create('RTTI type not found');
    FObj := LType.GetMethod('Create').Invoke(LType.AsInstance.MetaclassType, [])
      .AsType<T>;
  finally
    LCtx.Free;
  end;
end;

function TObjWrapper<T>.AsJSON: string;
begin
  Result := TJSON.Stringify<T>(FObj);
end;

constructor TObjWrapper<T>.Create(AObject: T);
begin
  inherited Create;
  FObj := AObject;
end;

destructor TObjWrapper<T>.Destroy;
begin
  FreeAndNil(FObj);
  inherited;
end;

constructor TObjWrapper<T>.FromJSON(const AJson: string);
begin
  Create(TJSON.Parse<T>(AJson));
end;

function TObjWrapper<T>.GetObj: T;
begin
  Result := FObj;
end;

end.
