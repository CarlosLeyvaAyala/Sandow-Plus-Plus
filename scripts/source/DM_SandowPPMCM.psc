; https://github.com/schlangster/skyui/wiki/MCM-State-Options
Scriptname DM_SandowPPMCM extends SKI_ConfigBase

Import DM_Utils
Import JsonUtil
Import DM_SandowPP_Globals
Import DM_SandowPP_SkeletonNodes

DM_SandowPPMain property SandowPP auto
DM_SandowPPMain SPP
DM_SandowPP_Config Cfg


; #########################################################
; ###               PRIVATE VARIABLES                   ###
; #########################################################

int sDecimals = 1                       ; To give format to floats

; Slider fomats declared like this so they can be changed once this mod was published
string Property slFmt
    string Function get()
        Return "{2}%"
    EndFunction
EndProperty
string Property xslFmt
    string Function get()
        Return "{0}x"
    EndFunction
EndProperty
string Property slFmt4
    string Function get()
        Return "{4}%"
    EndFunction
EndProperty
string Property slFmt0
    string Function get()
        Return "{0}%"
    EndFunction
EndProperty
string Property slFmt0r
    string Function get()
        Return "{0}"
    EndFunction
EndProperty

string Property slFmt2r = "{2}" AutoReadOnly

string _ppMain = "$Main"
string _ppSkills = "$Skills"
string _ppRipped = "$Ripped"
string _ppWidget = "$Widget"
; string _ppProfiles = "$Presets"
string _ppCompat = "$Compat"

string[] _reports
string[] _behaviors
; string[] _presetManagers
string[] _vAlign
string[] _hAlign
string[] _rippedPlayerMethods
string[] _rippedPlayerBulkBhv


; #########################################################
; ###                   MAINTENANCE                     ###
; #########################################################

int function GetVersion()
    {Mod 2.1+ needs to update version}
    ; 3 = added Paused behavior
    ; 4 = added Bruce Lee behavior. FISS dropped. Added Compatibility tab. Deleted presets tab. Dropped reports.
    return 4
endFunction

Event OnConfigInit()
    Cfg = SandowPP.Config

    Pages = new string[5]
    Pages[0] = _ppMain
    Pages[1] = _ppSkills
    Pages[2] = _ppRipped
    Pages[3] = _ppWidget
    Pages[4] = _ppCompat

    _hAlign = new string[3]
    _hAlign[0] = "left"
    _hAlign[1] = "center"
    _hAlign[2] = "right"

    _vAlign = new string[3]
    _vAlign[0] = "top"
    _vAlign[1] = "center"
    _vAlign[2] = "bottom"

    _reports = new string[3]
    _reports[Cfg.rtDebug] = "$Simple message"
    _reports[Cfg.rtSkyUiLib] = "$Color notifications"
    _reports[Cfg.rtWidget] = "$Widget"

    _behaviors = new string[4]
    _behaviors[Cfg.bhPause] = "$MCM_PausedBehavior"
    _behaviors[Cfg.bhSandowPP] = "Sandow Plus Plus"
    _behaviors[Cfg.bhPumpingIron] = "Pumping Iron"
    _behaviors[Cfg.bhBruce] = "Bruce Lee"

    ; _presetManagers = new string[3]
    ; _presetManagers[Cfg.pmNone] = "$None"
    ; _presetManagers[Cfg.pmPapyrusUtil] = "Papyrus Util"
    ; _presetManagers[Cfg.pmFISS] = "FISS -deprecated-"

    _rippedPlayerMethods = new string[6]
    _rippedPlayerMethods[Cfg.rpmNone] = "$None"
    _rippedPlayerMethods[Cfg.rpmConst] = "$Constant"
    _rippedPlayerMethods[Cfg.rpmWeight] = "$By weight"
    _rippedPlayerMethods[Cfg.rpmWInv] = "$By weight inv"
    _rippedPlayerMethods[Cfg.rpmSkill] = "$By skills"
    _rippedPlayerMethods[Cfg.rpmBhv] = "$By behavior"

    _rippedPlayerBulkBhv = new string[2]
    _rippedPlayerBulkBhv[Cfg.bulkSPP] = "Sandow Plus Plus"
    _rippedPlayerBulkBhv[Cfg.bulkPI] = "Pumping Iron"
EndEvent

event OnVersionUpdate(int aVersion)
    if (aVersion > 1)
        Trace("MCM.OnVersionUpdate(" + aVersion + ")")
        OnConfigInit()
    endIf
endEvent

event OnPageReset(string aPage)
    ; if aPage == _ppProfiles
    ;     PageProfiles()
    If aPage == _ppWidget
        PageWidget()
    ElseIf aPage == _ppRipped
        PageRipped()
    ElseIf aPage == _ppSkills
        PageSkills()
    ElseIf aPage == _ppCompat
        PageCompat()
    Else
        PageMain()
    EndIf
endEvent

Event OnGameReload()
    DM_SandowPP_Globals.Trace("MCM.OnGameReload()")
    parent.OnGameReload()
    SandowPP.OnGameReload()
    Cfg = SandowPP.Config
    SPP = SandowPP
EndEvent


; #########################################################
; ###                       MAIN                        ###
; #########################################################

Function PageMain()
    SetCursorFillMode(TOP_TO_BOTTOM)
    ; Row 1
    int presets = PageMainPresets(0)
    int stats = PageMainStats(1)
    ; Row 2
    int row2 = MaxI(stats - 1, presets)
    int pos2 = PageMainConfiguration(row2)
    PageMainOtherOptions(row2 + 1)
    ;Row 3
    PageMainItems(pos2)
EndFunction


; #########################################################
; ###                   MAIN - PRESETS                  ###
; #########################################################

int Function PageMainPresets(int pos)
    SetCursorPosition(pos)
    AddHeaderOption(Header("$Presets"))
    ; AddHeaderOption("$MCM_Header{" + " $Presets" + "}")
    int count = 1
    If PapyrusUtilExists()
        AddMenuOptionST("MN_PresetLoad", "$Load", "")
        AddInputOptionST("IN_PresetSave", "$Save as...", "")
        count += 2
    Else
        TagPapyrusUtil()
        count += 1
    EndIf
    ; AddKeyMapOptionST("KM_STATUS", "$Hotkey", Cfg.HkShowStatus)
    ; AddToggleOptionST("TG_VERBOSE", "$More status info", Cfg.VerboseMod)
    Return pos + ToNewPos(count)
EndFunction


; #########################################################
; ###                   MAIN - REPORTS                  ###
; #########################################################

int Function PageMainReports(int pos)
    SetCursorPosition(pos)
    AddHeaderOption("<font color='#daa520'>$Status report</font>")
    AddKeyMapOptionST("KM_STATUS", "$Hotkey", Cfg.HkShowStatus)
    AddToggleOptionST("TG_VERBOSE", "$More status info", Cfg.VerboseMod)
    AddMenuOptionST("MN_REPORT", "$Report type", _reports[Cfg.ReportType])
    Return pos + ToNewPos(5)
EndFunction

State KM_STATUS
    Event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
        If ( ConfirmHotkeyChange(conflictControl, conflictName) )
            Cfg.HkShowStatus = newKeyCode
            SetKeyMapOptionValueST(newKeyCode)
        EndIf
    EndEvent

    Event OnDefaultST()
        SetKeyMapOptionValueST(Cfg.hotkeyInvalid)
        Cfg.HkShowStatus = Cfg.hotkeyInvalid
    EndEvent

    Event OnHighlightST()
        SetInfoText(SandowPP.Report.MCMHotkeyInfo())
    EndEvent
EndState

State TG_VERBOSE
    Event OnSelectST()
        Cfg.VerboseMod = !Cfg.VerboseMod
        SetToggleOptionValueST(Cfg.VerboseMod)
    EndEvent

    Event OnDefaultST()
        Cfg.VerboseMod = True
        SetToggleOptionValueST(True)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_VerboseInfo")
    EndEvent
EndState

State MN_REPORT
    Event OnMenuOpenST()
        OpenMenu(Cfg.ReportType, Cfg.ReportType, _reports)
    EndEvent

    Event OnMenuAcceptST(int index)
        If Cfg.ReportType == index
            Return
        EndIf
        Cfg.ReportType = index
        SetMenuOptionValueST(_reports[Cfg.ReportType])
        ForcePageReset()
    EndEvent

    Event OnDefaultST()
        Cfg.ReportType = 0
        SetMenuOptionValueST(_reports[Cfg.ReportType])
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_ReportTypeInfo{" + SandowPP.Report.MCMInfo() + "}")
    EndEvent
EndState


; #########################################################
; ###               MAIN - CONFIGURATION                ###
; #########################################################

int Function PageMainConfiguration(int pos)
    int count = 3
    SetCursorPosition(pos)
    ;AddEmptyOption()
    AddHeaderOption(Header("$Configuration"))
    If !Cfg.RippedPlayerBulkCut
        AddMenuOptionST("MN_BEHAVIOR", "$Behavior", _behaviors[Cfg.Behavior])
    Else
        AddTextOptionST("TX_BulkCutCantShowBhv", "", "$MCM_BulkCutCantShowBhv")
    EndIf
    AddToggleOptionST("TG_LOSEW", "$Can lose gains", Cfg.CanLoseWeight)
    If !Cfg.IsPumpingIron()
        AddToggleOptionST("TG_DR", "$Diminishing returns", Cfg.DiminishingReturns)
        count += 1
        If Cfg.IsSandow()
            AddToggleOptionST("TG_REBOUNDW", "$Weight rebound", Cfg.CanReboundWeight)
            count += 1
        EndIf
    EndIf
    ;AddToggleOptionST("TG_DISEASE", "$Disease affects Weight", false)
    ;AddToggleOptionST("TG_FOOD", "$Needs food to grow", false)
    Return pos + ToNewPos(count)
EndFunction

State TX_BulkCutCantShowBhv
    Event OnHighlightST()
        SetInfoText("$MCM_BulkCutCantShowBhvInfo")
    EndEvent
EndState

State MN_BEHAVIOR
    Event OnMenuOpenST()
        OpenMenu(Cfg.Behavior, Cfg.bhSandowPP, _behaviors)
    EndEvent

    Event OnMenuAcceptST(int index)
        If Cfg.Behavior == index
            Return
        EndIf
        Cfg.Behavior = index
        SetMenuOptionValueST(_behaviors[Cfg.Behavior])
        If Cfg.IsPumpingIron()
            ShowMessage("$MCM_PIResetSkills")
        EndIf
        ForcePageReset()
    EndEvent

    Event OnDefaultST()
        If Cfg.Behavior == Cfg.bhSandowPP
            Return
        EndIf
        Cfg.Behavior = Cfg.bhSandowPP
        SetMenuOptionValueST(_behaviors[Cfg.Behavior])
        ForcePageReset()
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_BehaviorInfo{" + SandowPP.Algorithm.MCMInfo() + "}")
    EndEvent
EndState

State TG_LOSEW
    Event OnSelectST()
        Cfg.CanLoseWeight = !Cfg.CanLoseWeight
        SetToggleOptionValueST(Cfg.CanLoseWeight)
        Trace("Toggled CanLoseWeight. Now " + Cfg.CanLoseWeight)
    EndEvent

    Event OnDefaultST()
        Cfg.CanLoseWeight = True
        SetToggleOptionValueST(True)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_LoseWeightInfo")
    EndEvent
EndState

State TG_DR
    Event OnSelectST()
        Cfg.DiminishingReturns = !Cfg.DiminishingReturns
        SetToggleOptionValueST(Cfg.DiminishingReturns)
    EndEvent

    Event OnDefaultST()
        Cfg.DiminishingReturns = True
        SetToggleOptionValueST(True)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_DiminishingInfo")
    EndEvent
EndState

State TG_REBOUNDW
    Event OnSelectST()
        Cfg.CanReboundWeight = !Cfg.CanReboundWeight
        SetToggleOptionValueST(Cfg.CanReboundWeight)
    EndEvent

    Event OnDefaultST()
        Cfg.CanReboundWeight = True
        SetToggleOptionValueST(True)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_ReboundInfo")
    EndEvent
EndState

; #########################################################
; ###                   MAIN - OTHER                    ###
; #########################################################

int Function PageMainOtherOptions(int pos)
    SetCursorPosition(pos)
    ;AddEmptyOption()
    AddHeaderOption(Header("$Other options"))
    ; AddMenuOptionST("MN_PRESET", "$Preset manager", _presetManagers[Cfg.PresetManager])

    AddSliderOptionST("SL_WEIGHTMULT", "$Weight gain rate", FloatToPercent(Cfg.weightGainRate), slFmt0)

    AddToggleOptionST("TG_HEIGHT", "$Can gain Height", Cfg.CanGainHeight)
    If Cfg.CanGainHeight
        AddSliderOptionST("SL_HEIGHTMAX", "$Max Height", FloatToPercent(Cfg.HeightMax), slFmt0)
        AddSliderOptionST("SL_HEIGHTDAYS", "$Days to max Height", Cfg.HeightDaysToGrow, slFmt0r)
    EndIf

    int flags = GetSkelFlags(NINODE_HEAD())
    AddToggleOptionST("TG_HEADSZ", "$MCM_HeadSz_Bool", Cfg.CanResizeHead, flags)
    If Cfg.CanResizeHead
        AddSliderOptionST("SL_HEADSZ_MN", "$MCM_HeadSz_Mn", Cfg.HeadSizeMin, slFmt2r, flags)
        AddSliderOptionST("SL_HEADSZ_MX", "$MCM_HeadSz_Mx", Cfg.HeadSizeMax, slFmt2r, flags)
    EndIf

    Return pos + ToNewPos(8)
EndFunction

int Function GetSkelFlags(string aNodeName)
    If !SkelNodeExists(SandowPP.Player, aNodeName)
        Return OPTION_FLAG_DISABLED
    Else
        Return OPTION_FLAG_NONE
    EndIf
EndFunction

; State MN_PRESET
;     Event OnMenuOpenST()
;         OpenMenu(Cfg.PresetManager, SandowPP.DefaultPresetManager(), _presetManagers)
;     EndEvent

;     Event OnMenuAcceptST(int index)
;         Cfg.PresetManager = index
;         EnsurePresetManager(_presetManagers[index])
;         SetMenuOptionValueST(_presetManagers[Cfg.PresetManager])
;     EndEvent

;     Event OnDefaultST()
;         Cfg.PresetManager = SandowPP.DefaultPresetManager()
;         SetMenuOptionValueST(_presetManagers[Cfg.PresetManager])
;     EndEvent

;     Event OnHighlightST()
;         SetInfoText("$MCM_PresetManagerInfo")
;     EndEvent
; EndState

Function EnsurePresetManager(string mgr)
    If SandowPP.PresetManager.Exists() || Cfg.PresetManager == Cfg.pmNone
        Return
    EndIf
    ShowMessage("$MCM_PresetMgrInexistent{" + mgr + "}")
    Cfg.PresetManager = SandowPP.DefaultPresetManager()
EndFunction

State SL_WEIGHTMULT
    Event OnSliderOpenST()
        float val = FloatToPercent(Cfg.weightGainRate)
        CreateSlider(val, 10, 300, 10)
    EndEvent

    Event OnSliderAcceptST(float val)
        Cfg.weightGainRate =  PercentToFloat(val)
        SetSliderOptionValueST(val, slFmt0)
    EndEvent

    Event OnDefaultST()
        Cfg.weightGainRate = 1.0
        SetSliderOptionValueST(FloatToPercent(Cfg.weightGainRate), slFmt0)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_WeightMultInfo")
    EndEvent
EndState

State TG_HEIGHT
    Event OnSelectST()
        Cfg.CanGainHeight = !Cfg.CanGainHeight
        SetToggleOptionValueST(Cfg.CanGainHeight)
        ForcePageReset()
    EndEvent

    Event OnDefaultST()
        Cfg.CanGainHeight = False
        SetToggleOptionValueST(False)
        ForcePageReset()
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_GainHeightInfo")
    EndEvent
EndState

State SL_HEIGHTMAX
    Event OnSliderOpenST()
        float val = FloatToPercent(Cfg.HeightMax)
        SetSliderDialogStartValue(val)
        SetSliderDialogDefaultValue(val)
        SetSliderDialogRange(FloatToPercent(0.01), FloatToPercent(0.2))
        SetSliderDialogInterval(FloatToPercent(0.01))
    EndEvent

    Event OnSliderAcceptST(float val)
        Cfg.HeightMax =  PercentToFloat(val)
        SetSliderOptionValueST(val, slFmt0)
    EndEvent

    Event OnDefaultST()
        Cfg.HeightMax = 0.06
        SetSliderOptionValueST(FloatToPercent(Cfg.HeightMax), slFmt0)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_MaxHeightInfo")
    EndEvent
EndState

State SL_HEIGHTDAYS
    Event OnSliderOpenST()
        float val = Cfg.HeightDaysToGrow
        SetSliderDialogStartValue(val)
        SetSliderDialogDefaultValue(val)
        SetSliderDialogRange(30, 150)
        SetSliderDialogInterval(10)
    EndEvent

    Event OnSliderAcceptST(float val)
        Cfg.HeightDaysToGrow =  val as int
        SetSliderOptionValueST(val, slFmt0r)
    EndEvent

    Event OnDefaultST()
        Cfg.HeightDaysToGrow = 120
        SetSliderOptionValueST(Cfg.HeightDaysToGrow, slFmt0r)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_HeightDaysToGrowInfo")
    EndEvent
EndState

float Property SCALE_MIN = 0.10 AutoReadOnly
float Property SCALE_MAX = 3.00 AutoReadOnly
float Property SCALE_STEP = 0.01 AutoReadOnly

State TG_HEADSZ
    Event OnSelectST()
        Cfg.CanResizeHead = !Cfg.CanResizeHead
        SetToggleOptionValueST(Cfg.CanResizeHead)
        ForcePageReset()
    EndEvent

    Event OnDefaultST()
        Cfg.CanResizeHead = False
        SetToggleOptionValueST(False)
        ForcePageReset()
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_HeadSz_Info")
    EndEvent
EndState

State SL_HEADSZ_MN
    Event OnSliderOpenST()
        CreateSlider(Cfg.HeadSizeMin, SCALE_MIN, SCALE_MAX, SCALE_STEP)
    EndEvent

    Event OnSliderAcceptST(float val)
        Cfg.HeadSizeMin = val
        SetSliderOptionValueST(val, slFmt2r)
    EndEvent

    Event OnDefaultST()
        Cfg.HeadSizeMin = 1.0
        SetSliderOptionValueST(Cfg.HeadSizeMin, slFmt2r)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_BoneSz_Info")
    EndEvent
EndState

State SL_HEADSZ_MX
    Event OnSliderOpenST()
        CreateSlider(Cfg.HeadSizeMax, SCALE_MIN, SCALE_MAX, SCALE_STEP)
    EndEvent

    Event OnSliderAcceptST(float val)
        Cfg.HeadSizeMax = val
        SetSliderOptionValueST(val, slFmt2r)
    EndEvent

    Event OnDefaultST()
        Cfg.HeadSizeMax = 1.0
        SetSliderOptionValueST(Cfg.HeadSizeMax, slFmt2r)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_BoneSz_Info")
    EndEvent
EndState

; #########################################################
; ###                   MAIN - STATS                    ###
; #########################################################

int Function PageMainStats(int pos)
    SandowPP.PrepareAlgorithmData()
    SetCursorPosition(pos)

    AddHeaderOption(Header("$Stats"))
    AddTextOptionST("TX_BW", "$Weight:", SPP.GetMCMWeight() + "%" )
    AddTextOptionST( "TX_TRAINING", "$Weight Gain Potential:", SPP.GetMCMWGP() + "%" )
    int count = 3
    ; Posibly won't exist
    If SPP.GetMCMCustomLabel1() && SPP.GetMCMCustomData1()
        AddTextOptionST("TX_CUSTOM1", SPP.GetMCMCustomLabel1(), SPP.GetMCMCustomData1() )
        count += 1
    EndIf
    If SPP.GetMCMStatus()
        AddTextOptionST("TX_STATUS", "", SandowPP.GetMCMStatus())
        count += 1
    EndIf
    Return pos + ToNewPos(count)
EndFunction

State TX_BW
    Event OnHighlightST()
        SetInfoText("$Your current body Weight.")
    EndEvent
EndState

State TX_TRAINING
    Event OnHighlightST()
        SetInfoText("$MCM_WGPInfo")
    EndEvent
EndState

State TX_CUSTOM1
    Event OnHighlightST()
        SetInfoText(SandowPP.GetMCMCustomInfo1())
    EndEvent
EndState

State TX_STATUS
    Event OnHighlightST()
        SetInfoText(SandowPP.GetMCMStatus())
    EndEvent
EndState

; #########################################################
; ###                   MAIN - ITEMS                    ###
; #########################################################
int Function PageMainItems(int pos)
    SetCursorPosition(pos)
    AddHeaderOption("<font color='#daa520'>$Items</font>")
    AddTextOptionST("TX_IT_SACKS", "$Weight sacks", "$Distribute", FlagByBool(!SandowPP.Items.WeightSacksDistributed) )
    AddTextOptionST("TX_IT_ANABOL", "$Weight gainers", "$Distribute", FlagByBool(!SandowPP.Items.SillyDistributed) )
    Return pos + ToNewPos(3)
EndFunction

State TX_IT_SACKS
    Event OnSelectST()
        SandowPP.Items.DistributeWeightSacks()
        ShowMessage("$MCM_ItemsSacks", False)
        SetOptionFlagsST(OPTION_FLAG_DISABLED, False, "TX_IT_SACKS")
    EndEvent
EndState

State TX_IT_ANABOL
    Event OnSelectST()
        SandowPP.Items.DistributeSilly()
        ShowMessage("$MCM_ItemsAnabolics", False)
        SetOptionFlagsST(OPTION_FLAG_DISABLED, False, "TX_IT_ANABOL")
    EndEvent
EndState


; #########################################################
; ###                   REPORT WIDGET                   ###
; #########################################################

Function PageWidget()
    SetCursorFillMode(TOP_TO_BOTTOM)
    AddHeaderOption("<font color='#daa520'>$Configuration</font>")
    AddSliderOptionST("SL_RWUPDTIME", "$Update time", Cfg.rwUpdateTime, slFmt0r + " s")
    AddSliderOptionST("SL_RWALPHA", "$Opacity", Cfg.rwOpacity, slFmt0)
    AddSliderOptionST("SL_RWSCALE", "$Scale", FloatToPercent(Cfg.rwScale), slFmt0)

    SetCursorPosition(1)
    AddHeaderOption("<font color='#daa520'>$Other options</font>")
    AddMenuOptionST("MN_RWHAL", "$Horizontal Align", Cfg.rwHAlign)
    AddMenuOptionST("MN_RWVAL", "$Vertical Align", Cfg.rwVAlign)
    AddSliderOptionST("SL_RWX", "$X Offset", Cfg.rwX, slFmt0r)
    AddSliderOptionST("SL_RWY", "$Y Offset", Cfg.rwY, slFmt0r)
EndFunction

State SL_RWUPDTIME
    Event OnSliderOpenST()
        CreateSlider(Cfg.rwUpdateTime, 1.0, 20.0, 1.0)
    EndEvent

    Event OnSliderAcceptST(float val)
        Cfg.rwUpdateTime =  val
        SetSliderOptionValueST(Cfg.rwUpdateTime, slFmt0r + " s")
    EndEvent

    Event OnDefaultST()
        Cfg.rwUpdateTime = 3.0
        SetSliderOptionValueST(Cfg.rwUpdateTime, slFmt0r + " s")
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_RWUpdateTimeInfo")
    EndEvent
EndState

State SL_RWALPHA
    Event OnSliderOpenST()
        CreateSlider(Cfg.rwOpacity, 10, 100, 5)
    EndEvent

    Event OnSliderAcceptST(float val)
        Cfg.rwOpacity =  val
        SetSliderOptionValueST(Cfg.rwOpacity, slFmt0)
    EndEvent

    Event OnDefaultST()
        Cfg.rwOpacity = 100
        SetSliderOptionValueST(Cfg.rwOpacity, slFmt0)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_RWAlphaInfo")
    EndEvent
EndState

State SL_RWSCALE
    Event OnSliderOpenST()
        CreateSlider(FloatToPercent(Cfg.rwScale), 10, 200, 1)
    EndEvent

    Event OnSliderAcceptST(float val)
        Cfg.rwScale = PercentToFloat(val)
        SetSliderOptionValueST(val, slFmt0)
    EndEvent

    Event OnDefaultST()
        Cfg.rwScale = 1.0
        SetSliderOptionValueST(FloatToPercent(Cfg.rwScale), slFmt0)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_RWScaleInfo")
    EndEvent
EndState

State MN_RWHAL
    Event OnMenuOpenST()
        int p = IndexOfS(_hAlign, Cfg.rwHAlign)
        OpenMenu(p, p, _hAlign)
    EndEvent

    Event OnMenuAcceptST(int index)
        Cfg.rwHAlign = _hAlign[index]
        SetMenuOptionValueST(Cfg.rwHAlign)
    EndEvent

    Event OnDefaultST()
        Cfg.rwHAlign = _hAlign[0]
        SetMenuOptionValueST(Cfg.rwHAlign)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_RWhAlignInfo")
    EndEvent
EndState

State MN_RWVAL
    Event OnMenuOpenST()
        int p = IndexOfS(_vAlign, Cfg.rwVAlign)
        OpenMenu(p, p, _vAlign)
    EndEvent

    Event OnMenuAcceptST(int index)
        Cfg.rwVAlign = _vAlign[index]
        SetMenuOptionValueST(Cfg.rwVAlign)
    EndEvent

    Event OnDefaultST()
        Cfg.rwVAlign = _vAlign[0]
        SetMenuOptionValueST(Cfg.rwVAlign)
    EndEvent

    Event OnHighlightST()
        SetInfoText("MCM_RWvAlignInfo")
    EndEvent
EndState

State SL_RWX
    Event OnSliderOpenST()
        CreateSlider(Cfg.rwX, -425, 425, 1)
    EndEvent

    Event OnSliderAcceptST(float val)
        Cfg.rwX = val
        SetSliderOptionValueST(val, slFmt0r)
    EndEvent

    Event OnDefaultST()
        Cfg.rwX = 0
        SetSliderOptionValueST(0, slFmt0r)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_RWXInfo")
    EndEvent
EndState

State SL_RWY
    Event OnSliderOpenST()
        CreateSlider(Cfg.rwY, -240, 240, 1)
    EndEvent

    Event OnSliderAcceptST(float val)
        Cfg.rwY = val
        SetSliderOptionValueST(val, slFmt0r)
    EndEvent

    Event OnDefaultST()
        Cfg.rwY = 0
        SetSliderOptionValueST(0, slFmt0r)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_RWYInfo")
    EndEvent
EndState


; #########################################################
; ###                       SKILLS                      ###
; #########################################################

Function PageSkills()
    SetCursorFillMode(TOP_TO_BOTTOM)
    int flag = DisableSkills()
    ;================================
    SetCursorPosition(0)
    AddHeaderOption("<font color='#daa520'>$MCM_WGPHeader</font>")
    AddSliderOptionST("SL_AR", "$Archery", Cfg.skillRatioAr, slFmt, flag)
    AddSliderOptionST("SL_BL", "$Block", Cfg.skillRatioBl, slFmt, flag)
    AddSliderOptionST("SL_HA", "$Heavy Armor", Cfg.skillRatioHa, slFmt, flag)
    AddSliderOptionST("SL_LA", "$Light Armor", Cfg.skillRatioLa, slFmt, flag)
    AddSliderOptionST("SL_1H", "$One Handed", Cfg.skillRatio1H, slFmt, flag)
    AddSliderOptionST("SL_SM", "$Smithing", Cfg.skillRatioSm, slFmt, flag)
    AddSliderOptionST("SL_SN", "$Sneak", Cfg.skillRatioSn, slFmt, flag)
    AddSliderOptionST("SL_2H", "$Two Handed", Cfg.skillRatio2H, slFmt, flag)

    SetCursorPosition(1)
    AddHeaderOption("")
    AddSliderOptionST("SL_AL", "$Alteration", Cfg.skillRatioAl, slFmt, flag)
    AddSliderOptionST("SL_CO", "$Conjuration", Cfg.skillRatioCo, slFmt, flag)
    AddSliderOptionST("SL_DE", "$Destruction", Cfg.skillRatioDe, slFmt, flag)
    AddSliderOptionST("SL_IL", "$Illusion", Cfg.skillRatioIl, slFmt, flag)
    AddSliderOptionST("SL_RE", "$Restoration", Cfg.skillRatioRe, slFmt, flag)

    ;================================
    If !Cfg.IsSandow()
        Return
    EndIf
    SetCursorPosition(20)
    AddHeaderOption("<font color='#daa520'>$Other options</font>")
    AddSliderOptionST("SL_FP", "$MCM_SlFatiguePhys", ToPercent(Cfg.physFatigueRate), xslFmt)

    SetCursorPosition(21)
    AddHeaderOption("")
EndFunction

int Function DisableSkills()
    If Cfg.skillsLocked
        Return OPTION_FLAG_DISABLED
    Else
        Return OPTION_FLAG_NONE
    EndIf
EndFunction

State SL_AR
    Event OnSliderOpenST()
        CreateSkillSliderPhys(Cfg.skillRatioAr)
    EndEvent

    event OnSliderAcceptST(float val)
        Cfg.skillRatioAr =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        Cfg.skillRatioAr = Cfg.skillDefaultAr
        SetSliderOptionValueST(Cfg.skillRatioAr, slFmt)
    endEvent
EndState

State SL_BL
    Event OnSliderOpenST()
        CreateSkillSliderPhys(Cfg.skillRatioBl)
    EndEvent

    event OnSliderAcceptST(float val)
        Cfg.skillRatioBl =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        Cfg.skillRatioBl = Cfg.skillDefaultBl
        SetSliderOptionValueST(Cfg.skillRatioBl, slFmt)
    endEvent
EndState

State SL_HA
    Event OnSliderOpenST()
        CreateSkillSliderPhys(Cfg.skillRatioHa)
    EndEvent

    event OnSliderAcceptST(float val)
        Cfg.skillRatioHa =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        Cfg.skillRatioHa = Cfg.skillDefaultHa
        SetSliderOptionValueST(Cfg.skillRatioHa, slFmt)
    endEvent
EndState

State SL_LA
    Event OnSliderOpenST()
        CreateSkillSliderPhys(Cfg.skillRatioLa)
    EndEvent

    event OnSliderAcceptST(float val)
        Cfg.skillRatioLa =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        Cfg.skillRatioLa = Cfg.skillDefaultLa
        SetSliderOptionValueST(Cfg.skillRatioLa, slFmt)
    endEvent
EndState

State SL_1H
    Event OnSliderOpenST()
        CreateSkillSliderPhys(Cfg.skillRatio1H)
    EndEvent

    event OnSliderAcceptST(float val)
        Cfg.skillRatio1H =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        Cfg.skillRatio1H = Cfg.skillDefault1H
        SetSliderOptionValueST(Cfg.skillRatio1H, slFmt)
    endEvent
EndState

State SL_SN
    Event OnSliderOpenST()
        CreateSkillSliderPhys(Cfg.skillRatioSn)
    EndEvent

    event OnSliderAcceptST(float val)
        Cfg.skillRatioSn =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        Cfg.skillRatioSn = Cfg.skillDefaultSn
        SetSliderOptionValueST(Cfg.skillRatioSn, slFmt)
    endEvent
EndState

State SL_SM
    Event OnSliderOpenST()
        CreateSkillSliderPhys(Cfg.skillRatioSm)
    EndEvent

    event OnSliderAcceptST(float val)
        Cfg.skillRatioSm =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        Cfg.skillRatioSm = Cfg.skillDefaultSm
        SetSliderOptionValueST(Cfg.skillRatioSm, slFmt)
    endEvent
EndState

State SL_2H
    Event OnSliderOpenST()
        CreateSkillSliderPhys(Cfg.skillRatio2H)
    EndEvent

    event OnSliderAcceptST(float val)
        Cfg.skillRatio2H =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        Cfg.skillRatio2H = Cfg.skillDefault2H
        SetSliderOptionValueST(Cfg.skillRatio2H, slFmt)
    endEvent
EndState

State SL_AL
    Event OnSliderOpenST()
        CreateSkillSliderMag(Cfg.skillRatioAl)
    EndEvent

    event OnSliderAcceptST(float val)
        Cfg.skillRatioAl =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        Cfg.skillRatioAl = Cfg.skillDefaultAl
        SetSliderOptionValueST(Cfg.skillRatioAl, slFmt)
    endEvent
EndState

State SL_CO
    Event OnSliderOpenST()
        CreateSkillSliderMag(Cfg.skillRatioCo)
    EndEvent

    event OnSliderAcceptST(float val)
        Cfg.skillRatioCo =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        Cfg.skillRatioCo = Cfg.skillDefaultCo
        SetSliderOptionValueST(Cfg.skillRatioCo, slFmt)
    endEvent
EndState

State SL_DE
    Event OnSliderOpenST()
        CreateSkillSliderMag(Cfg.skillRatioDe)
    EndEvent

    event OnSliderAcceptST(float val)
        Cfg.skillRatioDe =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        Cfg.skillRatioDe = Cfg.skillDefaultDe
        SetSliderOptionValueST(Cfg.skillRatioDe, slFmt)
    endEvent
EndState

State SL_IL
    Event OnSliderOpenST()
        CreateSkillSliderMag(Cfg.skillRatioIl)
    EndEvent

    event OnSliderAcceptST(float val)
        Cfg.skillRatioIl =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        Cfg.skillRatioIl = Cfg.skillDefaultIl
        SetSliderOptionValueST(Cfg.skillRatioIl, slFmt)
    endEvent
EndState

State SL_RE
    Event OnSliderOpenST()
        CreateSkillSliderMag(Cfg.skillRatioRe)
    EndEvent

    event OnSliderAcceptST(float val)
        Cfg.skillRatioRe =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        Cfg.skillRatioRe = Cfg.skillDefaultRe
        SetSliderOptionValueST(Cfg.skillRatioRe, slFmt)
    endEvent
EndState

State SL_FP
    Event OnSliderOpenST()
        CreateFatigueSlider(Cfg.physFatigueRate)
    EndEvent

    Event OnSliderAcceptST(float val)
        Cfg.physFatigueRate =  PercentToFloat(val)
        SetSliderOptionValueST(val, xslFmt)
    EndEvent

    Event OnDefaultST()
        Cfg.physFatigueRate = PercentToFloat(10)
        SetSliderOptionValueST(10, xslFmt)
    EndEvent

    Event OnHighlightST()
        float sk = Cfg.skillRatioRe
        float mr = Cfg.magFatigueRateMultiplier
        float r = Cfg.physFatigueRate * mr
        float rr = FloatToPercent(sk * r)
        string s = "$MCM_SlWGPMultInfo{" + FloatToStr(mr, 1) + "}{" + FloatToStr(rr) + "}"
        SetInfoText(s)
    EndEvent
EndState


; #########################################################
; ###                       RIPPED                      ###
; #########################################################
Function PageRipped()
    SetCursorFillMode(TOP_TO_BOTTOM)
    int playr = PageRippedPlayer(0)
EndFunction

string _sl_DaysFmt = "$sl_DaysFmt"
int Function PageRippedPlayer(int pos)
    SetCursorPosition(pos)
    int result = 1
    AddHeaderOption("<font color='#daa520'>$Player</font>")
    If (SPP.texMngr.IsValidRace(SPP.Player))
        ; Hide menu when the player wants to bulk & cut or get ripped by behavior, because it doesn't make sense in those cases
        If !(Cfg.RippedPlayerBulkCut || Cfg.IsBruce())
            AddMenuOptionST("MN_RippedPlayerOpt", "$MCM_RippedApply", _rippedPlayerMethods[Cfg.RippedPlayerMethod])
            result += 1
        EndIf
        ; Hide bulk & cut when it doesn't make sense
        If Cfg.RippedPlayerMethodIsBehavior() || Cfg.IsBruce()
            AddToggleOptionST("TG_RippedPlayerBulkCut", "$MCM_BulkCut", Cfg.RippedPlayerBulkCut)
            result += 1
            If Cfg.RippedPlayerBulkCut
                AddSliderOptionST("SL_RippedBulkDaysSwap", "$MCM_SwapBulkCutDays", Cfg.RippedPlayerBulkCutDays, _sl_DaysFmt)
                AddMenuOptionST("MN_RippedBulkBhv", "$MCM_BulkBhv", _rippedPlayerBulkBhv[Cfg.RippedPlayerBulkCutBhv])
                result += 2
            EndIf
        EndIf

        ; Show constant config only when it's required.
        If Cfg.RippedPlayerMethodIsConst()
            AddSliderOptionST("SL_RippedPlayerConstAlpha", "$MCM_RippedConst", FloatToPercent(Cfg.RippedPlayerConstLvl), slFmt0)
        EndIf

        ; Texture bounds for player
        If !Cfg.RippedPlayerMethodIsNone() && !Cfg.RippedPlayerMethodIsConst()
            AddSliderOptionST("SL_RippedPlayerLB", "$MCM_RippedLowerBound", FloatToPercent(Cfg.RippedPlayerLB), slFmt0)
            AddSliderOptionST("SL_RippedPlayerUB", "$MCM_RippedUpperBound", FloatToPercent(Cfg.RippedPlayerUB), slFmt0)
        EndIf
    Else
        AddTextOptionST("TX_RippedInvalidRace", "", "$MCM_RippedInvalidRace{" + MiscUtil.GetActorRaceEditorID(SPP.Player) + "}" )
        result += 1
    EndIf
    return result
EndFunction


State SL_RippedPlayerLB
    Event OnSliderOpenST()
        CreateSlider(FloatToPercent(Cfg.RippedPlayerLB), 0.0, FloatToPercent(Cfg.RippedPlayerUB) - 1.0, 1.0)
    EndEvent

    Event OnSliderAcceptST(float val)
        Cfg.RippedPlayerLB = PercentToFloat(val)
        SPP.texMngr.PlayerAlphaFromOptions()
        SetSliderOptionValueST(val, slFmt0)
    EndEvent

    Event OnDefaultST()
        Cfg.RippedPlayerLB = 0.0
        SPP.texMngr.PlayerAlphaFromOptions()
        SetSliderOptionValueST(0.0, slFmt0)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_RippedLowerBoundInfo{" + "$you" + "}")
    EndEvent
EndState

State SL_RippedPlayerUB
    Event OnSliderOpenST()
        CreateSlider(FloatToPercent(Cfg.RippedPlayerUB), FloatToPercent(Cfg.RippedPlayerLB) + 1.0, 100.0, 1.0)
    EndEvent

    Event OnSliderAcceptST(float val)
        Cfg.RippedPlayerUB = PercentToFloat(val)
        SPP.texMngr.PlayerAlphaFromOptions()
        SetSliderOptionValueST(val, slFmt0)
    EndEvent

    Event OnDefaultST()
        Cfg.RippedPlayerUB = 1.0
        SPP.texMngr.PlayerAlphaFromOptions()
        SetSliderOptionValueST(100, slFmt0)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_RippedUpperBoundInfo{" + "$you" + "}")
    EndEvent
EndState

State SL_RippedPlayerConstAlpha
    Event OnSliderOpenST()
        CreatePercentSlider(Cfg.RippedPlayerConstLvl)
    EndEvent

    Event OnSliderAcceptST(float val)
        Cfg.RippedPlayerConstLvl =  PercentToFloat(val)
        ; RippedPlayerSetCnstAlpha()
        SPP.texMngr.PlayerAlphaFromOptions()
        SetSliderOptionValueST(val, slFmt0)
    EndEvent

    Event OnDefaultST()
        Cfg.RippedPlayerConstLvl = 1.0
        ; RippedPlayerSetCnstAlpha()
        SPP.texMngr.PlayerAlphaFromOptions()
        SetSliderOptionValueST(FloatToPercent(Cfg.RippedPlayerConstLvl), slFmt0)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_RippedConstInfo")
    EndEvent
EndState

State SL_RippedBulkDaysSwap
    Event OnSliderOpenST()
        CreateSlider(Cfg.RippedPlayerBulkCutDays, 1.0, 20.0, 1.0)
    EndEvent

    Event OnSliderAcceptST(float val)
        Cfg.RippedPlayerBulkCutDays = val as int
        SetSliderOptionValueST(Cfg.RippedPlayerBulkCutDays, _sl_DaysFmt)
    EndEvent

    Event OnDefaultST()
        Cfg.RippedPlayerBulkCutDays = 4
        SetSliderOptionValueST(Cfg.RippedPlayerBulkCutDays, _sl_DaysFmt)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_SwitchBulkCutDaysInfo")
    EndEvent
EndState

State TX_RippedInvalidRace
    Event OnHighlightST()
        SetInfoText("$MCM_RippedInvalidRaceInfo")
    EndEvent
EndState

State MN_RippedPlayerOpt
    Event OnMenuOpenST()
        ; Start, default, options
        OpenMenu(Cfg.RippedPlayerMethod, 0, _rippedPlayerMethods)
    EndEvent

    Event OnMenuAcceptST(int index)
        Cfg.RippedPlayerMethod = index
        SetMenuOptionValueST(_rippedPlayerMethods[Cfg.RippedPlayerMethod])

        If Cfg.RippedPlayerMethodIsBehavior()
            ; Bruce Lee behavior was actually selected from here
            Cfg.Behavior = Cfg.bhBruce
        Else
            SPP.texMngr.InitializeActor(SPP.Player)
        EndIf
        ForcePageReset()
    EndEvent

    Event OnDefaultST()
        Cfg.RippedPlayerMethod = Cfg.rpmNone
        SPP.texMngr.PlayerAlphaFromOptions()
        SetMenuOptionValueST(_rippedPlayerMethods[Cfg.RippedPlayerMethod])
        ForcePageReset()
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_RippedApplyInfo{" + Cfg.RippedPlayerMethodInfo() + "}")
    EndEvent
EndState

State MN_RippedBulkBhv
    Event OnMenuOpenST()
        OpenMenu(Cfg.RippedPlayerBulkCutBhv, 0, _rippedPlayerBulkBhv)
    EndEvent

    Event OnMenuAcceptST(int index)
        Cfg.RippedPlayerBulkCutBhv = index
        SetMenuOptionValueST(_rippedPlayerBulkBhv[Cfg.RippedPlayerBulkCutBhv])
    EndEvent

    Event OnDefaultST()
        Cfg.RippedPlayerBulkCutBhv = 0
        SetMenuOptionValueST(_rippedPlayerBulkBhv[Cfg.RippedPlayerBulkCutBhv])
        ForcePageReset()
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_SwitchBulkCutDaysInfo")
    EndEvent
EndState

State TG_RippedPlayerBulkCut
    Event OnSelectST()
        Cfg.RippedPlayerBulkCut = !Cfg.RippedPlayerBulkCut
        SetToggleOptionValueST(Cfg.RippedPlayerBulkCut)
        ForcePageReset()
    EndEvent

    Event OnDefaultST()
        Cfg.RippedPlayerBulkCut = False
        SetToggleOptionValueST(False)
        ForcePageReset()
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_BulkCutInfo")
    EndEvent
EndState


; #########################################################
; ###                       COMPAT                      ###
; #########################################################

Function PageCompat()
    SetCursorFillMode(TOP_TO_BOTTOM)
    TagPapyrusUtil()
    TagNiOverride()
    If SexLabExists()
        TagSexlab()
    EndIf
EndFunction

; #########################################################
; ###                       PRESETS                     ###
; #########################################################

Function PageProfiles()
    SetCursorFillMode(LEFT_TO_RIGHT)
    AddHeaderOption("<font color='#daa520'>$Load</font>")
    AddHeaderOption("<font color='#daa520'>$Save</font>")

    AddTextOptionST("TX_PL1", "$Preset {" + 1 + "}", "$Load", LoadFlag(1) )
    AddTextOptionST("TX_PS1", "$Preset {" + 1 + "}", "$Save", SaveFlag() )
    AddTextOptionST("TX_PL2", "$Preset {" + 2 + "}", "$Load", LoadFlag(2) )
    AddTextOptionST("TX_PS2", "$Preset {" + 2 + "}", "$Save", SaveFlag() )
    AddTextOptionST("TX_PL3", "$Preset {" + 3 + "}", "$Load", LoadFlag(3) )
    AddTextOptionST("TX_PS3", "$Preset {" + 3 + "}", "$Save", SaveFlag() )
EndFunction

int Function SaveFlag()
    Return FlagByBool(SandowPP.PresetManager.Exists())
EndFunction

int Function LoadFlag(int aPresetNum)
    Return FlagByBool(SandowPP.PresetManager.Exists() && SandowPP.PresetManager.ProfileExists(aPresetNum))
EndFunction

Function SavePreset(int aPresetNum)
    SandowPP.PresetManager.SaveFile(aPresetNum, Cfg)
    ShowMessage("$Preset saved", False)
EndFunction

Function TryLoadPreset(int aPresetNum)
    DM_SandowPP_Config pData = SandowPP.PresetManager.LoadFile(aPresetNum)
    if pData.operationResult != ""
        ; Should never get this message, but it was added as a safety measure anyway.
        ShowMessage("$Can't open preset{" + pData.operationResult + "}", true)
        Return
    EndIf

    ; Assign new data
    Cfg.Assign(pData)
    ShowMessage("$Preset loaded succesfully", False)
EndFunction

State TX_PS1
    Event OnSelectST()
        SavePreset(1)
        SetOptionFlagsST(OPTION_FLAG_NONE, false, "TX_PL1")
    EndEvent
EndState

State TX_PL1
    Event OnSelectST()
        TryLoadPreset(1)
    EndEvent
EndState

State TX_PS2
    Event OnSelectST()
        SavePreset(2)
        SetOptionFlagsST(OPTION_FLAG_NONE, false, "TX_PL2")
    EndEvent
EndState

State TX_PL2
    Event OnSelectST()
        TryLoadPreset(2)
    EndEvent
EndState

State TX_PS3
    Event OnSelectST()
        SavePreset(3)
        SetOptionFlagsST(OPTION_FLAG_NONE, false, "TX_PL3")
    EndEvent
EndState

State TX_PL3
    Event OnSelectST()
        TryLoadPreset(3)
    EndEvent
EndState


; #########################################################################
; Generic tags functions
; #########################################################################
string Function TagExists(bool condition)
    If condition
        return "$Found"
    Else
        return Error("$Not found")
    EndIf
EndFunction

Function TagPapyrusUtil()
    ; AddTextOptionST("TX_NfPapyrusU", "PapyrusUtil", TagExists(PapyrusUtilExists()), OPTION_FLAG_DISABLED )
    AddTextOptionST("TX_NfPapyrusU", "PapyrusUtil", TagExists(PapyrusUtilExists()))
EndFunction

Function TagNiOverride()
    AddTextOptionST("TX_NfNiOverride", "NiOverride", TagExists(NiOverrideExists()))
EndFunction

Function TagSexlab()
    AddTextOptionST("TX_NfSexlab", "Sexlab", TagExists(SexLabExists()))
EndFunction

State TX_NfPapyrusU
    Event OnHighlightST()
        SetInfoText("$MCM_CompatPapyrusUtilInfo")
    EndEvent
EndState

State TX_NfNiOverride
    Event OnHighlightST()
        SetInfoText("$MCM_CompatNiOverrideInfo")
    EndEvent
EndState

State TX_NfSexlab
    Event OnHighlightST()
        SetInfoText("$MCM_CompatSexlabInfo")
    EndEvent
EndState


; #########################################################################
; Helper functions
; #########################################################################

Function OpenMenu(int aStart, int aDefault, string[] aOptions)
    SetMenuDialogStartIndex(aStart)
    SetMenuDialogDefaultIndex(aDefault)
    SetMenuDialogOptions(aOptions)
EndFunction

Function CreateSkillSliderPhys(float startValue)
    CreateSkillSlider(startValue, 0.5)
EndFunction

Function CreateSkillSliderMag(float startValue)
    CreateSkillSlider(startValue, 0.20)
EndFunction

Function CreateSkillSlider(float startValue, float maxValue)
    CreateSlider(startValue, 0.0, maxValue, 0.01)
EndFunction

Function CreateSlider(float aStart, float aMin, float aMax, float aInterval)
    SetSliderDialogStartValue(aStart)
    SetSliderDialogDefaultValue(aStart)
    SetSliderDialogRange(aMin, aMax)
    SetSliderDialogInterval(aInterval)
EndFunction

Function CreateFatigueSlider(float startValue)
    float x = ToPercent(startValue)
    CreateSlider(x, 5, 50, 1)
EndFunction

Function CreatePercentSlider(float startValue)
    {Creates a slider from 0% to 100%. startValue goes from [0.0, 1.0].}
    CreateSlider(FloatToPercent(startValue), 0.0, 100.0, 1.0)
EndFunction

bool Function ConfirmHotkeyChange(string conflictControl, string conflictName)
    if (conflictControl != "")
        string msg
        if (conflictName != "")
            msg = "$MCM_HotkeyConflict2{" + conflictControl + "}{" + conflictName + "}"
        else
            msg = "$MCM_HotkeyConflict1{" + conflictControl + "}"
        endIf
        Return ShowMessage(msg, true, "$Yes", "$No")
    endIf
    Return True
EndFunction

int Function ToNewPos(int aPos)
    Return (aPos * 2) + 2
EndFunction

int Function FlagByBool(bool aVal)
    {Enables control if aVal is True}
    If aVal
        Return OPTION_FLAG_NONE
    Else
        Return OPTION_FLAG_DISABLED
    EndIf
EndFunction

string Function Header(string text)
    return "$MCM_Header{" + text + "}"
EndFunction

string Function Error(string text)
    return "$MCM_Error{" + text + "}"
EndFunction
