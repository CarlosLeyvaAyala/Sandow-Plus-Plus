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
bool _visible = false
bool _visibleOld = false
bool _willFade = false
bool Property tween = false Auto

;@abstract:
; Used to update individual meters
int Function Id()
    return 0
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
        CacheVisibility(data, p + "visible")
        CachePos(data, p)
        CacheFlash(data, p + "flash")
        CacheMCM(data, ".preset.widget.", mName)
    EndFunction

    Function CacheVisibility(int data, string p)
        _visibleOld = _visible
        _visible = solveInt(data, p)
        _willFade = _visibleOld != _visible
    EndFunction

    Function CachePos(int data, string p)
        _x = solveFlt(data, p + "x")
        _y = solveFlt(data, p + "y")
    EndFunction

    Function CacheFlash(int data, string p)
        FlashColor = solveInt(data, p, -1)
        solveIntSetter(data, p, -1, true)
    EndFunction

    Function CacheMCM(int data, string p, string mName)
        _w = solveFlt(data, p + "meterW")
        _h = solveFlt(data, p + "meterH")
        _hAlign = solveStr(data, p + "hAlign")
        _vAlign = solveStr(data, p + "vAlign")
        _opacity = solveFlt(data, p + "opacity", 100.0)
        _transT = solveFlt(data, p + "transT", 1)
        _col1 = solveInt(data, p + "colors." + mName, 0x1c1c1c)
        _col2 = LighterCol(_col1)
    EndFunction

;>========================================================
;>===                     UPDATE                     ===<;
;>========================================================

    ; Applies cached data.
    Function Apply()
        PrimaryColor = _col1
        SecondaryColor = _col2
        Percent = _percent
        SetPos()
        ; From MCM
        Width = _w
        Height = _h
        HAnchor = _hAlign
        VAnchor = _vAlign
        TryFlash()
        TryFade()
    EndFunction

    Function SetPos()
        If tween
            TweenTo(_x, _y, _transT)
        Else
            X = _x
            Y = _y
        EndIf
    EndFunction

    Function TryFlash()
        If FlashColor >= 0
            Flash()
        EndIf
    EndFunction

    Function TryFade()
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

    int Function LighterCol(int c)
        int r = Math.RightShift(Math.LogicalAnd(c, 0xFF0000), 16)
        int g = Math.RightShift(Math.LogicalAnd(c, 0xFF00), 8)
        int b = Math.LogicalAnd(c, 0xFF)
        r = LightenChannel(r) * 0x010000
        g = LightenChannel(g) * 0x0100
        b = LightenChannel(b)
        return r + g + b
    EndFunction

    int Function LightenChannel(int c)
        return Math.Floor(c + (0xFF - c) * 0.4)
    EndFunction

; TODO: Delete
Event OnUpdateDisplay(DM_SandowPP_Report sender, float aPercent,  int aType)
EndEvent
