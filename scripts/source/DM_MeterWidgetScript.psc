Scriptname DM_MeterWidgetScript extends SKI_WidgetBase ;Hidden 

int Property PrimaryColor
    {Primary color of the meter gradient RRGGBB [0x000000, 0xFFFFFF]. Default: 0xFF0000. Convert to decimal when editing this in the CK}
    int Function get()
        Return _primaryColor
    EndFunction
    Function set(int a_val)
        _primaryColor = a_val
        If Ready
            SetColors(_primaryColor, _secondaryColor, _flashColor)
        EndIf
    EndFunction
EndProperty

int Property SecondaryColor
    {Secondary color of the meter gradient, -1 = automatic. RRGGBB [0x000000, 0xFFFFFF]. Default: -1. Convert to decimal when editing this in the CK}
    int Function get()
        Return _secondaryColor
    EndFunction
    Function set(int a_val)
        _secondaryColor = a_val
        SetColors(_primaryColor, _secondaryColor, _flashColor)
    EndFunction
EndProperty

int Property FlashColor
    {Color of the meter warning flash, -1 = automatic. RRGGBB [0x000000, 0xFFFFFF]. Default: -1. Convert to decimal when editing this in the CK}
    int Function get()
        Return _flashColor
    EndFunction
    Function set(int a_val)
        _flashColor = a_val
        If Ready
            ui.InvokeInt(HUD_MENU, WidgetRoot + ".setFlashColor", _flashColor)
        EndIf
    EndFunction
EndProperty

Float property Percent
    {Percent of the meter [0.0, 1.0]. Default: 0.0}
    float Function get()
        Return _percent
    EndFunction
    Function set(float a_val)
        _percent = a_val
        If Ready
            SetPercent(_percent, False)
        EndIf
    EndFunction
EndProperty

float Property Height
    {Height of the meter in pixels at a resolution of 1280x720. Default: 25.2}
    float Function get()
        Return _height
    EndFunction
    Function set(float a_val)
        _height = a_val
        If Ready
            ui.InvokeFloat(HUD_MENU, WidgetRoot + ".setHeight", _height)
        EndIf
    EndFunction
EndProperty

Float property Width
    {Width of the meter in pixels at a resolution of 1280x720. Default: 292.8}
    float Function get()
        Return _width
    EndFunction
    Function set(float a_val)
        _width = a_val
        If Ready
            ui.InvokeFloat(HUD_MENU, WidgetRoot + ".setWidth", _width)
        EndIf
    EndFunction
EndProperty

string Property FillDirection
    {The position at which the meter fills from, ["left", "center", "right"] . Default: center}
    string Function get()
        Return _fillDirection
    EndFunction
    Function set(string a_val)
        _fillDirection = a_val
        If Ready
            ui.InvokeString(HUD_MENU, WidgetRoot + ".setFillDirection", _fillDirection)
        EndIf
    EndFunction
EndProperty

float _width            = 292.8
int _primaryColor       = 0xc0c0c0
int _secondaryColor     = -1
float _percent          = 0.0
int _flashColor         = -1
string _fillDirection   = "both"
float _height           = 25.2
float _restoreAlpha     ; Used for hiding and showing


;##########################################################################
;###                        SETUP FUNCTIONS                             ###
;##########################################################################

Function OnWidgetReset()
    {This gets called at new game and reloading a save}
    Parent.OnWidgetReset()
    float[] numberArgs = new float[6]
    numberArgs[0] = _width
    numberArgs[1] = _height
    numberArgs[2] = _primaryColor as float
    numberArgs[3] = _secondaryColor as float
    numberArgs[4] = _flashColor as float
    numberArgs[5] = _percent
    UI.InvokefloatA(HUD_MENU, WidgetRoot + ".initNumbers", numberArgs)
    string[] stringArgs = new string[1]
    stringArgs[0] = _fillDirection
    UI.InvokeStringA(HUD_MENU, WidgetRoot + ".initStrings", stringArgs)
    UI.Invoke(HUD_MENU, WidgetRoot + ".initCommit")
EndFunction

string Function GetWidgetSource()
    {Flash file path}
    Return "SandowPP/meter.swf"
EndFunction

string Function GetWidgetType()
    {Must be the same name as this script}
    return "DM_MeterWidgetScript"
EndFunction


;##########################################################################
;###                        APPEARANCE FUNCTIONS                        ###
;##########################################################################

Function SetColors(int aPrimaryColor, int aSecondaryColor, int aFlashColor)
    {Sets all colors at once}
    _primaryColor = aPrimaryColor
    _secondaryColor = aSecondaryColor
    _flashColor = aFlashColor
    If Ready
        int[] args = new int[3]
        args[0] = aPrimaryColor
        args[1] = aSecondaryColor
        args[2] = aFlashColor
        UI.InvokeIntA(HUD_MENU, WidgetRoot + ".setColors", args)
    EndIf
EndFunction

Function SetPercent(float aPercent, Bool aForce)
    {Sets the meter percent, aForce sets the meter percent without animation}
    _percent = aPercent
    if Ready
        float[] args = new float[2]
        args[0] = aPercent
        args[1] = aForce as float
        UI.InvokefloatA(HUD_MENU, WidgetRoot + ".setPercent", args)
    endIf
EndFunction

Function ForcePercent(float aPercent)
    {Convenience Function} 
    SetPercent(aPercent, True)
EndFunction

Function Flash()
    {Convenience Function}
    StartFlash(False)
EndFunction

Function ForceFlash()
    {Convenience Function}
    StartFlash(True)
EndFunction

Function StartFlash(Bool aForce)
    {Starts meter flashing. aForce starts the meter flashing if it's already animating}
    if Ready
        UI.InvokeBool(HUD_MENU, WidgetRoot + ".startFlash", aForce)
    endIf
EndFunction

Function Hide()
    If Alpha > 0.0
        _restoreAlpha = Alpha
    EndIf
    Alpha = 0.0
EndFunction

Function Show()
    Alpha = _restoreAlpha
EndFunction

bool Function IsHidden()
    return Alpha == 0.0
EndFunction