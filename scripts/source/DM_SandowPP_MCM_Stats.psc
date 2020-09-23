Scriptname DM_SandowPP_MCM_Stats extends DM_SandowPP_MCM_Skills Hidden

; Import DM_Utils
Import DM_SandowPP_Globals
Import JValue

string _mainStatInf
string _trainingInf
string _otherInf

Function PageMainStats()
    SPP.UpdateMcmData()
    int d = SPP.GetDataTree()
    string p = ".bhv."
    _PageMainSetInfo(d, p)

    Header("$Stats")
    _PageMainOptLbl(d, p, "LblMain_Stat", "mainStatLbl", "mainStatVal")
    _PageMainOptLbl(d, p, "LblMain_Training", "trainingLbl", "trainingVal")
    _PageMainOptLbl(d, p, "LblMain_Other", "otherLbl", "otherVal")
    ; If SPP.GetMCMStatus()
    ;     Label("LblMain_Status", "", "You need to sleep")
    ;     count += 1
    ; EndIf
    ; count += _PageMainShowWidget()
    Toggle("tgMain_ToggleWidget", "$Show widget", SPP.ReportWidget.Visible)
    AddEmptyOption()
EndFunction

; Shows a label if said label exists
Function _PageMainOptLbl(int d, string p, string aState, string lbl, string val)
    string mainLbl = solveStr(d, p + lbl)
    string mainVal = solveStr(d, p + val)
    If mainLbl
        Label(aState, mainLbl, mainVal)
    EndIf
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

    ; FIXME: Doesn't reload page
    State tgMain_ToggleWidget
        Event OnSelectST()
            SPP.ReportWidget.Visible = !SPP.ReportWidget.Visible
            SetToggleOptionValueST(SPP.ReportWidget.Visible)
            ForcePageReset()
        EndEvent

        Event OnDefaultST()
            SPP.ReportWidget.Visible = False
            SetToggleOptionValueST(False)
            ForcePageReset()
        EndEvent

        Event OnHighlightST()
            SetInfoText("$MCM_MainToggleWidgetInfo")
        EndEvent
    EndState
