Scriptname DM_SandowPP_MCM_Stats extends DM_SandowPP_MCM_Skills Hidden

; Import DM_Utils
Import DM_SandowPP_Globals
Import JValue

string _mainStatInf
string _trainingInf
string _otherInf

int Function PageMainStats(int pos)
    SPP.UpdateMcmData()
    int d = SPP.GetDataTree()
    string p = ".bhv."
    _PageMainSetInfo(d, p)

    SetCursorPosition(pos)
    int count = 1
    Header("$Stats")
    count += _PageMainOptLbl(d, p, "LblMain_Stat", "mainStatLbl", "mainStatVal")
    count += _PageMainOptLbl(d, p, "LblMain_Training", "trainingLbl", "trainingVal")
    count += _PageMainOptLbl(d, p, "LblMain_Other", "otherLbl", "otherVal")
    ; If SPP.GetMCMStatus()
    ;     Label("LblMain_Status", "", "You need to sleep")
    ;     count += 1
    ; EndIf
    ; count += _PageMainShowWidget()
    Return pos + ToNewPos(count)
EndFunction

int Function _PageMainShowWidget()
    If SPP.ReportWidget.Visible
        Button("BtnMain_ToggleWidget", "", "$Hide widget")
    else
        Button("BtnMain_ToggleWidget", "", "$Show widget")
    EndIf
    return 1
EndFunction

; Shows a label if said label exists
int Function _PageMainOptLbl(int d, string p, string aState, string lbl, string val)
    string mainLbl = solveStr(d, p + lbl)
    string mainVal = solveStr(d, p + val)
    If mainLbl
        Label(aState, mainLbl, mainVal)
        return 1
    EndIf
    return 0
EndFunction

; Sets info text for all labels
Function _PageMainSetInfo(int d, string p)
    _mainStatInf = solveStr(d, p + "mainStatInf")
    _trainingInf = solveStr(d, p + "trainingInf")
    _otherInf = solveStr(d, p + "otherInf")
EndFunction

;>===                     EVENTS                     ===<;
    State LblMain_Stat
        Event OnHighlightST()
            SetInfoText(_mainStatInf)
        EndEvent
    EndState

    State LblMain_Training
        Event OnHighlightST()
            SetInfoText(_trainingInf)
        EndEvent
    EndState

    State LblMain_Other
        Event OnHighlightST()
            SetInfoText(_otherInf)
        EndEvent
    EndState

    State LblMain_Status
        Event OnHighlightST()
            SetInfoText(SPP.GetMCMStatus())
        EndEvent
    EndState

    ; State BtnMain_ToggleWidget
    ;     Event OnSelectST()
    ;         SPP.ReportWidget.Visible = !SPP.ReportWidget.Visible
    ;         Trace("BF ForcePageReset")
    ;         Parent.ForcePageReset()
    ;         Trace("AF ForcePageReset")
    ;     EndEvent
    ; EndState
