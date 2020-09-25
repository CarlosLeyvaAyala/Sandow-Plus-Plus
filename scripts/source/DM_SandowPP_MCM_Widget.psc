Scriptname DM_SandowPP_MCM_Widget extends DM_SandowPP_MCM_Stats Hidden

Import DM_Utils
Import DM_SandowPP_Globals
Import JValue

string[] _vAlign
string[] _hAlign

string _p = ".widget."
float _gap = -0.3

; Import DM_SandowPP_Globals
Function PageWidget()
    _wInitArrays()
    SetCursorFillMode(TOP_TO_BOTTOM)

    SetCursorPosition(0)
    Header("$Whole widget")
    Slider("slW_alpha", "$Opacity", _mwgf("opacity"), f0c)
    Menu("mnW_hAl", "$Horizontal Align", "$" + _mwgs("hAlign"))
    Menu("mnW_vAl", "$Vertical Align", "$" + _mwgs("vAlign"))
    Slider("slW_x", "$X Offset", _mwgf("x"), f0)
    Slider("slW_y", "$Y Offset", _mwgf("y"), f0)
    AddEmptyOption()

    Header("$Meter dimensions")
    Slider("slW_mH", "$Height", _mwgf("meterH"), f1c)
    Slider("slW_mW", "$Width", _mwgf("meterW"), f1c)
    Slider("slW_mvGap", "$Vertical gap", _wGaptoSl(), f0c)

    SetCursorPosition(1)
    Header("$Other options")
    Hotkey("hkW_toggle", "$Hide/show hotkey", _mwgi("hotkey"))
    Slider("slW_refRate", "$Update time", _mwgf("refreshRate"), f0s)
    ; s.defVal(data, reportWidget.maxMTrainPercent, 10)
    ; reportWidget.hideAtMin = mcmProp("hideAtMin")
    ; reportWidget.hideAtMax = mcmProp("hideAtMax")
EndFunction

;>========================================================
;>===                    HELPERS                     ===<;
;>========================================================

Function _wInitArrays()
    _hAlign = new string[3]
    _hAlign[0] = "$left"
    _hAlign[1] = "$center"
    _hAlign[2] = "$right"

    _vAlign = new string[3]
    _vAlign[0] = "$top"
    _vAlign[1] = "$center"
    _vAlign[2] = "$bottom"
EndFunction

Function _wRefreshByHiding()
    SPP.ReportWidget.Visible = !SPP.ReportWidget.Visible
    Utility.Wait(0.5)
    SPP.ReportWidget.Visible = !SPP.ReportWidget.Visible
EndFunction

; Repositions widget.
Function _wReposition()
    SPP.ExecuteLua("return sandowpp.repositionWidget(jobject)")
    SPP.RealTimeCalculations()
EndFunction

; Gap to silder.
float Function _wGaptoSl()
    return (_mwgf("vGap") - _gap) * 100
EndFunction

; Slider to gap.
Function _wSltoGap(float val)
    _mwsf("vGap", val/100 + _gap)
EndFunction

; Array position for some alignment.
int Function _wAlPos(string align, string[] opt)
    return IndexOfS(opt, "$" + _mwgs(align))
EndFunction


;>========================================================
;>===                GETTERS/SETTERS                 ===<;
;>========================================================

    ; MCM Widget Set Int
    Function _mwsi(string aKey, int val)
        solveIntSetter(SPP.GetMCMConfig(), _p + aKey, val)
    EndFunction

    ; MCM Widget Get Int
    int Function _mwgi(string aKey)
        return solveInt(SPP.GetMCMConfig(), _p + aKey)
    EndFunction

    ; MCM Widget Set Float
    Function _mwsf(string aKey, float val)
        solveFltSetter(SPP.GetMCMConfig(), _p + aKey, val)
    EndFunction

    ; MCM Widget Get Float
    float Function _mwgf(string aKey)
        return solveFlt(SPP.GetMCMConfig(), _p + aKey)
    EndFunction

    ; MCM Widget Set String
    Function _mwss(string aKey, string val)
        solveStrSetter(SPP.GetMCMConfig(), _p + aKey, val)
    EndFunction

    ; MCM Widget Get String
    string Function _mwgs(string aKey)
        return solveStr(SPP.GetMCMConfig(), _p + aKey)
    EndFunction

;>========================================================
;>===                     EVENTS                     ===<;
;>========================================================

    State hkW_toggle
        Event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
            If (ConfirmHotkeyChange(conflictControl, conflictName))
                SPP.RegisterHotkey(_mwgi("hotkey"), newKeyCode)
                _mwsi("hotkey", newKeyCode)
                SetKeyMapOptionValueST(newKeyCode)
            EndIf
        EndEvent

        Event OnDefaultST()
            SPP.UnRegisterForKey(_mwgi("hotkey"))
            _mwsi("hotkey", -1)
            SetKeyMapOptionValueST(-1)
        EndEvent

        Event OnHighlightST()
            SetInfoText("$MCM_HKStatusRWInfo")
        EndEvent
    EndState

    State slW_refRate
        Event OnSliderOpenST()
            CreateSlider(_mwgf("refreshRate"), 1.0, 20.0, 1.0)
        EndEvent

        Event OnSliderAcceptST(float val)
            _mwsf("refreshRate", val)
            SetSliderOptionValueST(val, f0s)
        EndEvent

        Event OnDefaultST()
            _mwsf("refreshRate", 3.0)
            SetSliderOptionValueST(3.0, f0s)
        EndEvent

        Event OnHighlightST()
            SetInfoText("$MCM_RWUpdateTimeInfo")
        EndEvent
    EndState

    State slW_alpha
        Event OnSliderOpenST()
            CreateSlider(_mwgf("opacity"), 10, 100, 5)
        EndEvent

        Event OnSliderAcceptST(float val)
            _mwsf("opacity", val)
            SetSliderOptionValueST(val, slFmt0)
            _wRefreshByHiding()
        EndEvent

        Event OnDefaultST()
            _mwsf("opacity", 100)
            SetSliderOptionValueST(100, slFmt0)
            _wRefreshByHiding()
        EndEvent

        Event OnHighlightST()
            SetInfoText("$MCM_RWAlphaInfo")
        EndEvent
    EndState

    State mnW_hAl
        Event OnMenuOpenST()
            int p = _wAlPos("hAlign", _hAlign)
            OpenMenu(p, 2, _hAlign)
        EndEvent

        Event OnMenuAcceptST(int index)
            SPP.ExecuteLua("return sandowpp.changeHAlign(jobject, " + index + ")")
            SetMenuOptionValueST(_hAlign[index])
            _wReposition()
        EndEvent

        Event OnDefaultST()
            SPP.ExecuteLua("return sandowpp.changeHAlign(jobject, 2)")
            SetMenuOptionValueST(_hAlign[2])
            _wReposition()
        EndEvent

        Event OnHighlightST()
            SetInfoText("$MCM_RWhAlignInfo")
        EndEvent
    EndState

    State mnW_vAl
        Event OnMenuOpenST()
            int p = _wAlPos("vAlign", _vAlign)
            OpenMenu(p, 0, _vAlign)
        EndEvent

        Event OnMenuAcceptST(int index)
            SPP.ExecuteLua("return sandowpp.changeVAlign(jobject, " + index + ")")
            SetMenuOptionValueST(_vAlign[index])
            _wReposition()
        EndEvent

        Event OnDefaultST()
            SPP.ExecuteLua("return sandowpp.changeVAlign(jobject, 2)")
            SetMenuOptionValueST(_vAlign[0])
            _wReposition()
        EndEvent

        Event OnHighlightST()
            SetInfoText("$MCM_RWvAlignInfo")
        EndEvent
    EndState

    State slW_x
        Event OnSliderOpenST()
            CreateSlider(_mwgf("x"), -425, 425, 1)
        EndEvent

        Event OnSliderAcceptST(float val)
            _mwsf("x", val)
            SetSliderOptionValueST(val, f0)
            _wReposition()
        EndEvent

        Event OnDefaultST()
            _mwsf("x", 0)
            SetSliderOptionValueST(0, f0)
            _wReposition()
        EndEvent

        Event OnHighlightST()
            SetInfoText("$MCM_RWXInfo")
        EndEvent
    EndState

    State slW_y
        Event OnSliderOpenST()
            CreateSlider(_mwgf("y"), -240, 240, 1)
        EndEvent

        Event OnSliderAcceptST(float val)
            _mwsf("y", val)
            SetSliderOptionValueST(val, f0)
            _wReposition()
        EndEvent

        Event OnDefaultST()
            _mwsf("y", 0)
            SetSliderOptionValueST(0, f0)
            _wReposition()
        EndEvent

        Event OnHighlightST()
            SetInfoText("$MCM_RWYInfo")
        EndEvent
    EndState

    State slW_mH
        Event OnSliderOpenST()
            CreateSlider(_mwgf("meterH"), 10, 50, 0.5)
        EndEvent

        Event OnSliderAcceptST(float val)
            _mwsf("meterH", val)
            SetSliderOptionValueST(val, f1c)
            _wReposition()
        EndEvent

        Event OnDefaultST()
            _mwsf("meterH", 17.5)
            SetSliderOptionValueST(17.5, f1c)
            _wReposition()
        EndEvent

        Event OnHighlightST()
            SetInfoText("$MCM_RWmHInfo")
        EndEvent
    EndState

    State slW_mW
        Event OnSliderOpenST()
            CreateSlider(_mwgf("meterW"), 20, 450, 10)
        EndEvent

        Event OnSliderAcceptST(float val)
            _mwsf("meterW", val)
            SetSliderOptionValueST(val, f1c)
            _wReposition()
        EndEvent

        Event OnDefaultST()
            _mwsf("meterW", 150)
            SetSliderOptionValueST(150, f1c)
            _wReposition()
        EndEvent

        Event OnHighlightST()
            SetInfoText("$MCM_RWmWInfo")
        EndEvent
    EndState

    State slW_mvGap
        Event OnSliderOpenST()
            CreateSlider(_wGaptoSl(), 0, 200, 10)
        EndEvent

        Event OnSliderAcceptST(float val)
            _wSltoGap(val)
            SetSliderOptionValueST(val, f0c)
            _wReposition()
        EndEvent

        Event OnDefaultST()
            _mwsf("vGap", -0.1)
            SetSliderOptionValueST(_wGaptoSl(), f0c)
            _wReposition()
        EndEvent

        Event OnHighlightST()
            SetInfoText("$MCM_RWmGapInfo")
        EndEvent
    EndState
