unit uDepServer;

interface

type
  // Singleton
  TDepServer = class
  strict private
    class var FInstance: TDepServer;
  public
    class procedure Init;
  end;

implementation

{ TDepServer }

class procedure TDepServer.Init;
begin
  if not Assigned(FInstance) then
    FInstance := TDepServer.Create;
end;

end.
