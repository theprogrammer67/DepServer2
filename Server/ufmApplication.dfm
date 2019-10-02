object frmApplication: TfrmApplication
  Left = 0
  Top = 0
  Caption = #1044#1077#1087#1086#1079#1080#1090#1085#1086'-'#1076#1080#1089#1082#1086#1085#1090#1085#1099#1081' '#1089#1077#1088#1074#1077#1088
  ClientHeight = 293
  ClientWidth = 633
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 120
  TextHeight = 16
  object btnEnable: TButton
    Left = 32
    Top = 32
    Width = 75
    Height = 25
    Caption = 'Enable'
    TabOrder = 0
    OnClick = btnEnableClick
  end
  object btnDisable: TButton
    Left = 128
    Top = 32
    Width = 75
    Height = 25
    Caption = 'Disable'
    TabOrder = 1
    OnClick = btnDisableClick
  end
end
