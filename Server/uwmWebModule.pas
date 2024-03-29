﻿unit uwmWebModule;

interface

uses System.Classes, Web.HTTPApp;

type
  TwmWebModule = class(TWebModule)
    procedure WebModule1DefaultHandlerAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure wmWebModuleWebActionDataAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure wmWebModuleWebActionControlAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
  private
    // procedure HandleRequest(Request: TWebRequest; Response: TWebResponse;
    // var Handled: Boolean);
  public
    { Public declarations }
  end;

var
  WebModuleClass: TComponentClass = TwmWebModule;

implementation

uses uDepServer, uCommonTypes;

{ %CLASSGROUP 'Vcl.Controls.TControl' }

{$R *.dfm}
// procedure TwmWebModule.HandleRequest(Request: TWebRequest;
// Response: TWebResponse; var Handled: Boolean);
// var
// LReply: string;
// begin
// ReplicationServer.RequestHandler.HandleRequest(Request.Content, LReply,
// tpHttp, Request.RemoteAddr);
// Response.Content := LReply;
// Handled := True;
// end;

procedure TwmWebModule.WebModule1DefaultHandlerAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  LMethod: TRequestMethod;
  LResponse, RequestData: string;
begin
  case Request.MethodType of
    mtPut, mtPost:
      LMethod := rmPut;
    mtDelete:
      LMethod := rmDelete;
  else
    LMethod := rmGet;
  end;

  if LMethod = rmPut then
    RequestData := Request.Content
  else
    RequestData := '';

  Response.StatusCode := DepServer.RequestHandler.HandleRequest(LMethod,
    Request.PathInfo, Request.Query, RequestData, LResponse);

  Response.Content := LResponse;
  Handled := True;
end;

procedure TwmWebModule.wmWebModuleWebActionControlAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  // HandleRequest(Request, Response, Handled);
end;

procedure TwmWebModule.wmWebModuleWebActionDataAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  // HandleRequest(Request, Response, Handled);
end;

end.
