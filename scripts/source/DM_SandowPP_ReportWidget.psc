Scriptname DM_SandowPP_ReportWidget extends Quest
{Widget controller. Controls meters as a group and dispatches messages to relevant meters}

Import DM_SandowPP_Globals

DM_SandowPPMain Property Owner Auto
DM_SandowPP_ReportMeter01 Property Meter01 Auto
DM_SandowPP_ReportMeter02 Property Meter02 Auto
DM_SandowPP_ReportMeter03 Property Meter03 Auto
DM_SandowPP_ReportMeter04 Property Meter04 Auto

bool _visible = false

bool Property Visible
    Function set(bool val)
        If val
            _Show()
        else
            _Hide()
        EndIf
        _visible = val
    EndFunction
    bool Function get()
        return _visible
    EndFunction
EndProperty

DM_SandowPP_ReportMeterBase[] _meters

;>========================================================
;>===                     SETUP                      ===<;
;>========================================================

    Event OnInit()
        _InitMeters()
        Visible = False
    EndEvent

    Function Clear()
    EndFunction

    Function _InitMeters()
        _meters = New DM_SandowPP_ReportMeterBase[4]
        _meters[0] = Meter01
        _meters[1] = Meter02
        _meters[2] = Meter03
        _meters[3] = Meter04
    EndFunction

;>========================================================
;>===                      CORE                      ===<;
;>========================================================

    Function _ForceReport(int data)
        _Cache(data)
        _WillTween(data)
        _ApplyData()
    EndFunction

    Function Report(int data)
        If Visible
            _ForceReport(data)
        EndIf
    EndFunction

    ; Caches data to apply it as synchronically as possible.
    Function _Cache(int data)
        int i = 0
        While IterateMeters(i)
            _meters[i].Cache(data)
            i += 1
        EndWhile
    EndFunction

    ; Applies cached data.
    Function _ApplyData()
        int i = 0
        While IterateMeters(i)
            _meters[i].Apply()
            i += 1
        EndWhile
    EndFunction

    ; The Behavior Manager (Lua) has detected meters should tween to their pos.
    Function _WillTween(int data)
        string p = ".widget.tweenToPos"
        bool t = JValue.solveInt(data, p)
        int i = 0
        While IterateMeters(i)
            _meters[i].tween = false
            i += 1
        EndWhile
        JValue.solveIntSetter(data, p, 0, true)
    EndFunction

;>========================================================
;>===                 UPDATING CICLE                 ===<;
;>========================================================
    Function _Kickstart()
        Owner.ReportPlayer()
        RegisterForSingleUpdate(\
            JValue.solveFlt(Owner.GetDataTree(),\
            "preset.widget.refreshRate",\
            2)\
        )
    EndFunction

    State Running
        Event OnUpdate()
            _Kickstart()
        EndEvent
    EndState

    Event OnUpdate()
        UnregisterForUpdate()
    EndEvent


    ;>========================================================
    ;>===                   APPEARANCE                   ===<;
    ;>========================================================
    Function _Hide()
        Trace("Hide widget")
        GotoState("Paused")
        int i = 0
        While IterateMeters(i)
            _meters[i].FadeTo(0, 0.35)
            i += 1
        EndWhile
        Utility.Wait(0.4)
    EndFunction

    Function _Show()
        Trace("Show widget")
        int i = 0
        int d = Owner.GetDataTree()
        float a = JValue.solveFlt(d, ".preset.widget.opacity", 100.0)
        ; float t = JValue.solveFlt(d, ".preset.widget.transT", 1.0)
        While IterateMeters(i)
            If _meters[i].IsVisible()
                _meters[i].FadeTo(a, 0.35)
            EndIf
            i += 1
        EndWhile
        Utility.Wait(0.4)
        GotoState("Running")
        _Kickstart()
    EndFunction


;>========================================================
;>===                     OTHER                      ===<;
;>========================================================
    ; The meter exists and we are inside the array boundaries.
    bool Function IterateMeters(int i)
        ; Return _meters[i] && i < _meters.length
        Return i < _meters.length
    EndFunction
