unit uRequestHandler;

interface

uses uCommonTypes;

type
  TRequestHandler = class
  public
    procedure HandleRequest(ARequestType: TRequestMethod;
      const APath, ARequestData: string; out AResponseData: string);
  end;

implementation

{ TRequestHandler }

procedure TRequestHandler.HandleRequest(ARequestType: TRequestMethod; const APath,
  ARequestData: string; out AResponseData: string);
begin

end;

end.
