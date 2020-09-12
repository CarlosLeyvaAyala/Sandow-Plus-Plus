Scriptname DM_SandowPP_ReportMeterBase extends DM_MeterWidgetScript Hidden
Import DM_SandowPP_Globals
Import JValue

bool _willFade = false
int _flashColor = -1
float _percent
bool _visible = false
bool _visibleOld = false
float _alpha = 100.0
int _primaryCol = 0xc0c0c0
float _h = 1.75
float _w = 150.0
string _vAlign = "top"
string _hAlign = "left"
float _x = 0.0
float _y = 0.0


;@Abstract:
; This way, any individual meter can get its own data from the tree
int Function Id()
    return 0
EndFunction

; Caches the data before this gets updated, so all meters get updated as
; synchronically as possible.
Function CacheData(int data)
    string mName = "meter" + Id()
    string p = ".widget." + mName + "."
    string mcm = ".preset.widget."

    _x = solveFlt(data, p + "x")
    _y = solveFlt(data, p + "y")
    _percent = solveFlt(data, p + "percent")
    _visibleOld = _visible
    _visible = solveInt(data, p + "visible")
    If _visibleOld != _visible
        _willFade = true
    EndIf

    _alpha = solveFlt(data, mcm + "opacity")
    _primaryCol = solveInt(data, mcm + "colors.meter." + mName)
    _h = solveFlt(data, mcm + "meterH")
    _w = solveFlt(data, mcm + "meterW")
    _vAlign = solveStr(data, mcm + "vAlign")
    _hAlign = solveStr(data, mcm + "hAlign")
EndFunction

; Applies cached data
Function DoUpdate()
    Percent = _percent
    TweenTo(_x, _y, 1.0)
    TryFade()

    PrimaryColor = _primaryCol
    SecondaryColor = GetSecondaryCol(_primaryCol)
    Trace(SecondaryColor)
    Height = _h
    Width = _w
    HAnchor = _hAlign
    VAnchor = _vAlign
EndFunction

; Gets a slightly lighter color than primary.
int Function GetSecondaryCol(int color)
    int r = Math.RightShift(Math.LogicalAnd(color, 0xFF0000), 16)
    int g = Math.RightShift(Math.LogicalAnd(color, 0x00FF00), 8)
    int b = Math.LogicalAnd(color, 0x0000FF)
    r = LightenChannel(r)
    g = LightenChannel(g)
    b = LightenChannel(b)
    r = r * 0x010000
    g = g * 0x0100
    return r + g + b
EndFunction

int Function LightenChannel(int c)
    return c + (0xFF - c) / 2
EndFunction

Function TryFade()
    If _visible && _willFade
        FadeTo(_alpha, 1.0)
        _willFade = false
    EndIf
EndFunction

Event OnUpdateDisplay(DM_SandowPP_Report sender, float aPercent,  int aType)
EndEvent

; Flashes if there's a valid flash color in cache.
Function TryFlash()
    If _flashColor != -1
        FlashColor = _flashColor
        Flash()
        _flashColor = -1
    EndIf
EndFunction
