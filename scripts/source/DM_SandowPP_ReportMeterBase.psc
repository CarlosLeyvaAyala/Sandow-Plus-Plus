Scriptname DM_SandowPP_ReportMeterBase extends DM_MeterWidgetScript Hidden
Import DM_SandowPP_Globals
Import JValue

float _h = 17.5
float _w = 150.0
string _hAlign
string _vAlign
float _opacity = 100.0
float _transT = 1.0
int _col1 = 0x1c1c1c
int _col2
float _x = 0.0
float _y = 0.0
float _percent = 0.0
bool _willFade = false
bool Property tween = false Auto
; Must be visible, otherwise the player must wait for a reporting event before
; this shows for the first time.
bool _visible = true
bool _visibleOld = true

;@abstract:
; Used to update individual meters
int Function Id()
    return 0
EndFunction

bool Function IsVisible()
    return _visible
EndFunction

;>========================================================
;>===                     CACHE                      ===<;
;>========================================================

    ; Caches data to apply it as synchronically as possible.
    Function Cache(int data)
        string mName = "meter" + Id()
        string baseP = ".widget."
        string p = baseP + mName + "."

        _percent = solveFlt(data, p + "percent")
        _CacheVisibility(data, p + "visible")
        _CachePos(data, p)
        _CacheFlash(data, p + "flash")
        _CacheMCM(data, ".preset.widget.", mName)
    EndFunction

    Function _CacheVisibility(int data, string p)
        _visibleOld = _visible
        _visible = solveInt(data, p)
        _willFade = _visibleOld != _visible
    EndFunction

    Function _CachePos(int data, string p)
        _x = solveFlt(data, p + "x")
        _y = solveFlt(data, p + "y")
    EndFunction

    Function _CacheFlash(int data, string p)
        FlashColor = solveInt(data, p, -1)
        solveIntSetter(data, p, -1, true)
    EndFunction

    Function _CacheMCM(int data, string p, string mName)
        _w = solveFlt(data, p + "meterW")
        _h = solveFlt(data, p + "meterH")
        _hAlign = solveStr(data, p + "hAlign")
        _vAlign = solveStr(data, p + "vAlign")
        _opacity = solveFlt(data, p + "opacity", 100.0)
        _transT = solveFlt(data, p + "transT", 1)
        _col1 = solveInt(data, p + "colors." + mName, 0x1c1c1c)
        _col2 = _LighterCol(_col1)
    EndFunction

;>========================================================
;>===                     UPDATE                     ===<;
;>========================================================

    ; Applies cached data.
    Function Apply()
        PrimaryColor = _col1
        SecondaryColor = _col2
        Percent = _percent
        _SetPos()
        ; From MCM
        Width = _w
        Height = _h
        HAnchor = _hAlign
        VAnchor = _vAlign
        _TryFlash()
        _TryFade()
    EndFunction

    Function _SetPos()
        If tween
            TweenTo(_x, _y, _transT)
        Else
            X = _x
            Y = _y
        EndIf
    EndFunction

    Function _TryFlash()
        If FlashColor >= 0
            FlashColor = _CorrectFlash()
            Flash()
        EndIf
    EndFunction

    Function _TryFade()
        ; Alpha = _opacity
        If _willFade
            If _visible
                FadeTo(_opacity, _transT)
            Else
                FadeTo(0.0, _transT)
            EndIf
            _willFade = false
        EndIf
    EndFunction

;>========================================================
;>===                  CALCULATIONS                  ===<;
;>========================================================

    ; For some reason we need to do this, otherwise the bar flashes
    ; the primary color and not the intended color.
    int Function _CorrectFlash()
        return FlashColor
    EndFunction

    int Function _LighterCol(int c)
        int r = Math.RightShift(Math.LogicalAnd(c, 0xFF0000), 16)
        int g = Math.RightShift(Math.LogicalAnd(c, 0xFF00), 8)
        int b = Math.LogicalAnd(c, 0xFF)
        r = _LightenChannel(r) * 0x010000
        g = _LightenChannel(g) * 0x0100
        b = _LightenChannel(b)
        return r + g + b
    EndFunction

    int Function _LightenChannel(int c)
        return Math.Floor(c + (0xFF - c) * 0.4)
    EndFunction
