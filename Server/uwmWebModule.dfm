object wmWebModule: TwmWebModule
  OldCreateOrder = False
  Actions = <
    item
      Default = True
      Name = 'DefaultHandler'
      PathInfo = '/'
      OnAction = WebModule1DefaultHandlerAction
    end
    item
      Name = 'WebActionData'
      PathInfo = '/data*'
      OnAction = wmWebModuleWebActionDataAction
    end
    item
      Name = 'WebActionControl'
      PathInfo = '/control*'
      OnAction = wmWebModuleWebActionControlAction
    end>
  Height = 230
  Width = 415
end
