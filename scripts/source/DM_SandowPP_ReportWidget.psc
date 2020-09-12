Scriptname DM_SandowPP_ReportWidget extends DM_SandowPP_Report
{Widget controller. Controls meters as a group and dispatches messages to relevant meters}

Import DM_SandowPP_Globals

DM_SandowPPMain Property Owner Auto
DM_SandowPP_ReportMeter01 Property Meter01 Auto
DM_SandowPP_ReportMeter02 Property Meter02 Auto
DM_SandowPP_ReportMeter03 Property Meter03 Auto
DM_SandowPP_ReportMeter04 Property Meter04 Auto

bool Property Visible Auto

DM_SandowPP_ReportMeterBase[] _meters


;>========================================================
;>===                     SETUP                      ===<;
;>========================================================

    Event OnInit()
        InitMeters()
        Visible = False
    EndEvent

    Function InitMeters()
        _meters = New DM_SandowPP_ReportMeterBase[4]
        _meters[0] = Meter01
        _meters[1] = Meter02
        _meters[2] = Meter03
        _meters[3] = Meter04
    EndFunction


;>========================================================
;>===                   REPORTING                    ===<;
;>========================================================

    ; Updates all meters.
    Function Report(int data)
        CacheMeters(data)
        UpdateMeters(data)
    EndFunction

    ; Caches the data for all meters before updating them, so they all get updated as
    ; synchronically as possible.
    Function CacheMeters(int data)
        int i = 0
        While IterateMeters(i)
            _meters[i].CacheData(data)
            i += 1
        EndWhile
    EndFunction

    Function UpdateMeters(int data)
        int i = 0
        While IterateMeters(i)
            _meters[i].DoUpdate()
            i += 1
        EndWhile
    EndFunction



Function Refresh()
    UnregisterForUpdate()
EndFunction

Event OnUpdate()
    UnregisterForUpdate()
EndEvent

Function RegisterMessageCategory(int aCat, int id = -1)
EndFunction

;##########################################################################
;###                        APPEARANCE FUNCTIONS                        ###
;##########################################################################

Function Hide()
    ; Trace("ReportWidget.Hide()")
    ; int i = 0
    ; While IterateMeters(i)
    ;     _meters[i].Hide()
    ;     i += 1
    ; EndWhile
    ; GotoState("Hidden")
    ; UnregisterForUpdate()
EndFunction

Function Show()
    ; int i = 0
    ; While IterateMeters(i)
    ;     If !_permaHide[i]
    ;         _meters[i].Show()
    ;     EndIf
    ;     i += 1
    ; EndWhile
    ; GotoState("Active")
    ; Refresh()
EndFunction

Function FadeOut()
    ; Fade(0.0, "Hidden")
EndFunction

Function FadeIn()
    ; Fade(Opacity, "Active")
    ; Refresh()
EndFunction

Function Fade(float aAlpha, string aState)
    ; GotoState("Fade")
    ; int i = 0
    ; While IterateMeters(i)
    ;     If !_permaHide[i]
    ;         _meters[i].FadeTo(aAlpha, 0.35)
    ;     EndIf
    ;     i += 1
    ; EndWhile
    ; Utility.Wait(0.4)
    ; GotoState(aState)
EndFunction

;##########################################################################
;###                            OTHER FUNCTIONS                         ###
;##########################################################################

; The meter exists and we are inside the array boundaries.
bool Function IterateMeters(int i)
    Return _meters[i] && i < _meters.length
EndFunction

string Function MCMInfo()
    {Show this report type info in the MCM}
    Return "$MCM_ReportTypeWidgetInfo"
EndFunction

string Function MCMHotkeyInfo()
    {Tell the player he can use the hotkey to hide the widget}
    Return "$MCM_HKStatusRWInfo"
EndFunction
