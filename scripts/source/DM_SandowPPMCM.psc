; https://github.com/schlangster/skyui/wiki/MCM-State-Options
Scriptname DM_SandowPPMCM extends SKI_ConfigBase

Import DM_Utils
Import JsonUtil
Import DM_SandowPP_Globals
Import DM_SandowPP_SkeletonNodes

DM_SandowPPMain property SandowPP auto
DM_SandowPP_Config Config


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
string _ppProfiles = "$Presets"
string _ppWidget = "$Widget"

string[] _reports
string[] _behaviors
string[] _presetManagers
string[] _vAlign
string[] _hAlign


; #########################################################
; ###                   MAINTENANCE                     ###
; #########################################################

int function GetVersion()
    {Mod 2.1+ needs to update version}
    ; 3 = added Paused behavior
    ; 4 = added Bruce Lee behavior
    return 3
endFunction

Event OnConfigInit()
    Config = SandowPP.Config

    Pages = new string[4]
    Pages[0] = _ppMain
    Pages[1] = _ppSkills
    Pages[2] = _ppWidget
    Pages[3] = _ppProfiles

    _hAlign = new string[3]
    _hAlign[0] = "left"
    _hAlign[1] = "center"
    _hAlign[2] = "right"

    _vAlign = new string[3]
    _vAlign[0] = "top"
    _vAlign[1] = "center"
    _vAlign[2] = "bottom"

    _reports = new string[3]
    _reports[Config.rtDebug] = "$Simple message"
    _reports[Config.rtSkyUiLib] = "$Color notifications"
    _reports[Config.rtWidget] = "$Widget"

    _behaviors = new string[3]
    _behaviors[Config.bhPause] = "$MCM_PausedBehavior"
    _behaviors[Config.bhSandowPP] = "Sandow Plus Plus"
    _behaviors[Config.bhPumpingIron] = "Pumping Iron"

    _presetManagers = new string[3]
    _presetManagers[Config.pmNone] = "$None"
    _presetManagers[Config.pmPapyrusUtil] = "Papyrus Util"
    _presetManagers[Config.pmFISS] = "FISS"
EndEvent

event OnVersionUpdate(int aVersion)
    if (aVersion > 1)
        Trace("MCM.OnVersionUpdate(" + aVersion + ")")
        OnConfigInit()
    endIf
endEvent

event OnPageReset(string aPage)
    if aPage == _ppProfiles
        PageProfiles()
    ElseIf aPage == _ppWidget
        PageWidget()
    ElseIf aPage == _ppSkills
        PageSkills()
    Else
        PageMain()
    EndIf
endEvent

Event OnGameReload()
    DM_SandowPP_Globals.Trace("MCM.OnGameReload()")
    parent.OnGameReload()
    SandowPP.OnGameReload()
    Config = SandowPP.Config
EndEvent


; #########################################################
; ###                       MAIN                        ###
; #########################################################

Function PageMain()
    SetCursorFillMode(TOP_TO_BOTTOM)

    int pos = PageMainReports(0)
    int pos2 = PageMainConfiguration(pos)
    PageMainItems(pos2)
    
    PageMainStats(1)
    PageMainOtherOptions(pos + 1)
EndFunction


; #########################################################
; ###                   MAIN - REPORTS                  ###
; #########################################################

int Function PageMainReports(int pos)
    SetCursorPosition(pos)
    AddHeaderOption("<font color='#daa520'>$Status report</font>")
    AddKeyMapOptionST("KM_STATUS", "$Hotkey", Config.HkShowStatus)
    AddToggleOptionST("TG_VERBOSE", "$More status info", Config.VerboseMod)
    AddMenuOptionST("MN_REPORT", "$Report type", _reports[Config.ReportType])
    Return pos + ToNewPos(5)
EndFunction

State KM_STATUS
    Event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
        If ( ConfirmHotkeyChange(conflictControl, conflictName) )
            Config.HkShowStatus = newKeyCode
            SetKeyMapOptionValueST(newKeyCode)
        EndIf
    EndEvent

    Event OnDefaultST()
        SetKeyMapOptionValueST(Config.hotkeyInvalid)
        Config.HkShowStatus = Config.hotkeyInvalid
    EndEvent

    Event OnHighlightST()
        SetInfoText(SandowPP.Report.MCMHotkeyInfo())
    EndEvent
EndState

State TG_VERBOSE
    Event OnSelectST()
        Config.VerboseMod = !Config.VerboseMod
        SetToggleOptionValueST(Config.VerboseMod)
    EndEvent

    Event OnDefaultST()
        Config.VerboseMod = True
        SetToggleOptionValueST(True)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_VerboseInfo")
    EndEvent
EndState

State MN_REPORT
    Event OnMenuOpenST()
        OpenMenu(Config.ReportType, Config.ReportType, _reports)
    EndEvent

    Event OnMenuAcceptST(int index)
        If Config.ReportType == index
            Return
        EndIf
        Config.ReportType = index
        SetMenuOptionValueST(_reports[Config.ReportType])
        ForcePageReset()
    EndEvent

    Event OnDefaultST()
        Config.ReportType = 0
        SetMenuOptionValueST(_reports[Config.ReportType])
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
    AddHeaderOption("<font color='#daa520'>$Configuration</font>")
    AddMenuOptionST("MN_BEHAVIOR", "$Behavior", _behaviors[Config.Behavior])
    AddToggleOptionST("TG_LOSEW", "$Can lose Weight", Config.CanLoseWeight)
    If !Config.IsPumpingIron()
        AddToggleOptionST("TG_DR", "$Diminishing returns", Config.DiminishingReturns)
        AddToggleOptionST("TG_REBOUNDW", "$Weight rebound", Config.CanReboundWeight)
        count += 2
    EndIf
    ;AddToggleOptionST("TG_DISEASE", "$Disease affects Weight", false)
    ;AddToggleOptionST("TG_FOOD", "$Needs food to grow", false)
    Return pos + ToNewPos(count)
EndFunction

State MN_BEHAVIOR
    Event OnMenuOpenST()
        OpenMenu(Config.Behavior, Config.bhSandowPP, _behaviors)
    EndEvent

    Event OnMenuAcceptST(int index)
        If Config.Behavior == index
            Return
        EndIf
        Config.Behavior = index
        SetMenuOptionValueST(_behaviors[Config.Behavior])
        If Config.IsPumpingIron()
            ShowMessage("$MCM_PIResetSkills")
        EndIf
        ForcePageReset()
    EndEvent

    Event OnDefaultST()
        If Config.Behavior == Config.bhSandowPP
            Return
        EndIf
        Config.Behavior = Config.bhSandowPP
        SetMenuOptionValueST(_behaviors[Config.Behavior])
        ForcePageReset()
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_BehaviorInfo{" + SandowPP.Algorithm.MCMInfo() + "}")
    EndEvent
EndState

State TG_LOSEW
    Event OnSelectST()
        Config.CanLoseWeight = !Config.CanLoseWeight
        SetToggleOptionValueST(Config.CanLoseWeight)
        Trace("Toggled CanLoseWeight. Now " + Config.CanLoseWeight)
    EndEvent

    Event OnDefaultST()
        Config.CanLoseWeight = True
        SetToggleOptionValueST(True)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_LoseWeightInfo")
    EndEvent
EndState

State TG_DR
    Event OnSelectST()
        SandowPP.Config.DiminishingReturns = !SandowPP.Config.DiminishingReturns
        SetToggleOptionValueST(SandowPP.Config.DiminishingReturns)
    EndEvent

    Event OnDefaultST()
        SandowPP.Config.DiminishingReturns = True
        SetToggleOptionValueST(True)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_DiminishingInfo")
    EndEvent
EndState

State TG_REBOUNDW
    Event OnSelectST()
        SandowPP.Config.CanReboundWeight = !SandowPP.Config.CanReboundWeight
        SetToggleOptionValueST(SandowPP.Config.CanReboundWeight)
    EndEvent

    Event OnDefaultST()
        SandowPP.Config.CanReboundWeight = True
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
    AddHeaderOption("<font color='#daa520'>$Other options</font>")
    AddMenuOptionST("MN_PRESET", "$Preset manager", _presetManagers[Config.PresetManager])
    
    AddSliderOptionST("SL_WEIGHTMULT", "$Weight gain rate", FloatToPercent(Config.weightGainRate), slFmt0)

    AddToggleOptionST("TG_HEIGHT", "$Can gain Height", Config.CanGainHeight)
    AddSliderOptionST("SL_HEIGHTMAX", "$Max Height", FloatToPercent(Config.HeightMax), slFmt0)
    AddSliderOptionST("SL_HEIGHTDAYS", "$Days to max Height", Config.HeightDaysToGrow, slFmt0r)

    int flags = GetSkelFlags(NINODE_HEAD())
    AddToggleOptionST("TG_HEADSZ", "$MCM_HeadSz_Bool", Config.CanResizeHead, flags)
    AddSliderOptionST("SL_HEADSZ_MN", "$MCM_HeadSz_Mn", Config.HeadSizeMin, slFmt2r, flags)
    AddSliderOptionST("SL_HEADSZ_MX", "$MCM_HeadSz_Mx", Config.HeadSizeMax, slFmt2r, flags)
    
    Return pos + ToNewPos(8)
EndFunction

int Function GetSkelFlags(string aNodeName)
    If !SkelNodeExists(SandowPP.Player, aNodeName)
        Return OPTION_FLAG_DISABLED
    Else
        Return OPTION_FLAG_NONE
    EndIf
EndFunction

State MN_PRESET
    Event OnMenuOpenST()
        OpenMenu(Config.PresetManager, SandowPP.DefaultPresetManager(), _presetManagers)
    EndEvent

    Event OnMenuAcceptST(int index)
        Config.PresetManager = index
        EnsurePresetManager(_presetManagers[index])
        SetMenuOptionValueST(_presetManagers[Config.PresetManager])
    EndEvent

    Event OnDefaultST()
        Config.PresetManager = SandowPP.DefaultPresetManager()
        SetMenuOptionValueST(_presetManagers[Config.PresetManager])
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_PresetManagerInfo")
    EndEvent
EndState

Function EnsurePresetManager(string mgr)
    If SandowPP.PresetManager.Exists() || Config.PresetManager == Config.pmNone
        Return
    EndIf
    ShowMessage("$MCM_PresetMgrInexistent{" + mgr + "}")
    Config.PresetManager = SandowPP.DefaultPresetManager()
EndFunction

State SL_WEIGHTMULT
    Event OnSliderOpenST()
        float val = FloatToPercent(SandowPP.Config.weightGainRate)
        CreateSlider(val, 10, 200, 10)
    EndEvent

    Event OnSliderAcceptST(float val)
        SandowPP.Config.weightGainRate =  PercentToFloat(val)
        SetSliderOptionValueST(val, slFmt0)
    EndEvent

    Event OnDefaultST()
        SandowPP.Config.weightGainRate = 1.0
        SetSliderOptionValueST(FloatToPercent(SandowPP.Config.weightGainRate), slFmt0)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_WeightMultInfo")
    EndEvent
EndState

State TG_HEIGHT
    Event OnSelectST()
        Config.CanGainHeight = !Config.CanGainHeight
        SetToggleOptionValueST(Config.CanGainHeight)
    EndEvent

    Event OnDefaultST()
        Config.CanGainHeight = False
        SetToggleOptionValueST(False)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_GainHeightInfo")
    EndEvent
EndState

State SL_HEIGHTMAX
    Event OnSliderOpenST()
        float val = FloatToPercent(SandowPP.Config.HeightMax)
        SetSliderDialogStartValue(val)
        SetSliderDialogDefaultValue(val)
        SetSliderDialogRange(FloatToPercent(0.01), FloatToPercent(0.2))
        SetSliderDialogInterval(FloatToPercent(0.01))
    EndEvent    

    Event OnSliderAcceptST(float val)
        SandowPP.Config.HeightMax =  PercentToFloat(val)
        SetSliderOptionValueST(val, slFmt0)
    EndEvent    

    Event OnDefaultST()
        SandowPP.Config.HeightMax = 0.06
        SetSliderOptionValueST(FloatToPercent(SandowPP.Config.HeightMax), slFmt0)
    EndEvent    

    Event OnHighlightST()
        SetInfoText("$MCM_MaxHeightInfo")
    EndEvent    
EndState    

State SL_HEIGHTDAYS
    Event OnSliderOpenST()
        float val = SandowPP.Config.HeightDaysToGrow
        SetSliderDialogStartValue(val)
        SetSliderDialogDefaultValue(val)
        SetSliderDialogRange(30, 150)
        SetSliderDialogInterval(10)
    EndEvent

    Event OnSliderAcceptST(float val)
        SandowPP.Config.HeightDaysToGrow =  val as int
        SetSliderOptionValueST(val, slFmt0r)
    EndEvent

    Event OnDefaultST()
        SandowPP.Config.HeightDaysToGrow = 120
        SetSliderOptionValueST(SandowPP.Config.HeightDaysToGrow, slFmt0r)
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
        Config.CanResizeHead = !Config.CanResizeHead
        SetToggleOptionValueST(Config.CanResizeHead)
    EndEvent

    Event OnDefaultST()
        Config.CanResizeHead = False
        SetToggleOptionValueST(False)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_HeadSz_Info")
    EndEvent
EndState

State SL_HEADSZ_MN
    Event OnSliderOpenST()
        CreateSlider(Config.HeadSizeMin, SCALE_MIN, SCALE_MAX, SCALE_STEP)
    EndEvent

    Event OnSliderAcceptST(float val)
        Config.HeadSizeMin = val
        SetSliderOptionValueST(val, slFmt2r)
    EndEvent

    Event OnDefaultST()
        Config.HeadSizeMin = 1.0
        SetSliderOptionValueST(Config.HeadSizeMin, slFmt2r)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_BoneSz_Info")
    EndEvent
EndState

State SL_HEADSZ_MX
    Event OnSliderOpenST()
        CreateSlider(Config.HeadSizeMax, SCALE_MIN, SCALE_MAX, SCALE_STEP)
    EndEvent

    Event OnSliderAcceptST(float val)
        Config.HeadSizeMax = val
        SetSliderOptionValueST(val, slFmt2r)
    EndEvent

    Event OnDefaultST()
        Config.HeadSizeMax = 1.0
        SetSliderOptionValueST(Config.HeadSizeMax, slFmt2r)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_BoneSz_Info")
    EndEvent
EndState

; #########################################################
; ###                   MAIN - STATS                    ###
; #########################################################

int Function PageMainStats(int pos)
    SetCursorPosition(pos)
    AddHeaderOption("<font color='#daa520'>$Stats</font>")

    SandowPP.PrepareAlgorithmData()
    AddTextOptionST("TX_BW", "$Weight:", SandowPP.GetMCMWeight() + "%" )
    AddTextOptionST( "TX_TRAINING", "$Weight Gain Potential:", SandowPP.GetMCMWGP() + "%" )
    AddTextOptionST( "TX_CUSTOM1", SandowPP.GetMCMCustomLabel1(), SandowPP.GetMCMCustomData1() )
    AddTextOptionST( "TX_STATUS", "", SandowPP.GetMCMStatus() )
    Return pos + ToNewPos(5)
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
    AddSliderOptionST("SL_RWUPDTIME", "$Update time", Config.rwUpdateTime, slFmt0r + " s")
    AddSliderOptionST("SL_RWALPHA", "$Opacity", Config.rwOpacity, slFmt0)
    AddSliderOptionST("SL_RWSCALE", "$Scale", FloatToPercent(Config.rwScale), slFmt0)

    SetCursorPosition(1)
    AddHeaderOption("<font color='#daa520'>$Other options</font>")
    AddMenuOptionST("MN_RWHAL", "$Horizontal Align", Config.rwHAlign)
    AddMenuOptionST("MN_RWVAL", "$Vertical Align", Config.rwVAlign)
    AddSliderOptionST("SL_RWX", "$X Offset", Config.rwX, slFmt0r)
    AddSliderOptionST("SL_RWY", "$Y Offset", Config.rwY, slFmt0r)
EndFunction

State SL_RWUPDTIME
    Event OnSliderOpenST()
        CreateSlider(Config.rwUpdateTime, 1.0, 20.0, 1.0)
    EndEvent

    Event OnSliderAcceptST(float val)
        Config.rwUpdateTime =  val
        SetSliderOptionValueST(Config.rwUpdateTime, slFmt0r + " s")
    EndEvent

    Event OnDefaultST()
        Config.rwUpdateTime = 3.0
        SetSliderOptionValueST(Config.rwUpdateTime, slFmt0r + " s")
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_RWUpdateTimeInfo")
    EndEvent
EndState

State SL_RWALPHA
    Event OnSliderOpenST()
        CreateSlider(Config.rwOpacity, 10, 100, 5)
    EndEvent

    Event OnSliderAcceptST(float val)
        Config.rwOpacity =  val
        SetSliderOptionValueST(Config.rwOpacity, slFmt0)
    EndEvent

    Event OnDefaultST()
        Config.rwOpacity = 100
        SetSliderOptionValueST(Config.rwOpacity, slFmt0)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_RWAlphaInfo")
    EndEvent
EndState

State SL_RWSCALE
    Event OnSliderOpenST()
        CreateSlider(FloatToPercent(Config.rwScale), 10, 200, 10)
    EndEvent

    Event OnSliderAcceptST(float val)
        Config.rwScale = PercentToFloat(val)
        SetSliderOptionValueST(val, slFmt0)
    EndEvent

    Event OnDefaultST()
        Config.rwScale = 1.0
        SetSliderOptionValueST(FloatToPercent(Config.rwScale), slFmt0)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_RWScaleInfo")
    EndEvent
EndState

State MN_RWHAL
    Event OnMenuOpenST()
        int p = IndexOfS(_hAlign, Config.rwHAlign)
        OpenMenu(p, p, _hAlign)
    EndEvent

    Event OnMenuAcceptST(int index)
        Config.rwHAlign = _hAlign[index]
        SetMenuOptionValueST(Config.rwHAlign)
    EndEvent

    Event OnDefaultST()
        Config.rwHAlign = _hAlign[0]
        SetMenuOptionValueST(Config.rwHAlign)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_RWhAlignInfo")
    EndEvent
EndState

State MN_RWVAL
    Event OnMenuOpenST()
        int p = IndexOfS(_vAlign, Config.rwVAlign)
        OpenMenu(p, p, _vAlign)
    EndEvent

    Event OnMenuAcceptST(int index)
        Config.rwVAlign = _vAlign[index]
        SetMenuOptionValueST(Config.rwVAlign)
    EndEvent

    Event OnDefaultST()
        Config.rwVAlign = _vAlign[0]
        SetMenuOptionValueST(Config.rwVAlign)
    EndEvent

    Event OnHighlightST()
        SetInfoText("MCM_RWvAlignInfo")
    EndEvent
EndState

State SL_RWX
    Event OnSliderOpenST()
        CreateSlider(Config.rwX, -425, 425, 1)
    EndEvent

    Event OnSliderAcceptST(float val)
        Config.rwX = val
        SetSliderOptionValueST(val, slFmt0r)
    EndEvent

    Event OnDefaultST()
        Config.rwX = 0
        SetSliderOptionValueST(0, slFmt0r)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_RWXInfo")
    EndEvent
EndState

State SL_RWY
    Event OnSliderOpenST()
        CreateSlider(Config.rwY, -240, 240, 1)
    EndEvent

    Event OnSliderAcceptST(float val)
        Config.rwY = val
        SetSliderOptionValueST(val, slFmt0r)
    EndEvent

    Event OnDefaultST()
        Config.rwY = 0
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
    AddSliderOptionST("SL_AR", "$Archery", SandowPP.Config.skillRatioAr, slFmt, flag)
    AddSliderOptionST("SL_BL", "$Block", SandowPP.Config.skillRatioBl, slFmt, flag)
    AddSliderOptionST("SL_HA", "$Heavy Armor", SandowPP.Config.skillRatioHa, slFmt, flag)
    AddSliderOptionST("SL_LA", "$Light Armor", SandowPP.Config.skillRatioLa, slFmt, flag)
    AddSliderOptionST("SL_1H", "$One Handed", SandowPP.Config.skillRatio1H, slFmt, flag)
    AddSliderOptionST("SL_SM", "$Smithing", SandowPP.Config.skillRatioSm, slFmt, flag)
    AddSliderOptionST("SL_SN", "$Sneak", SandowPP.Config.skillRatioSn, slFmt, flag)
    AddSliderOptionST("SL_2H", "$Two Handed", SandowPP.Config.skillRatio2H, slFmt, flag)

    SetCursorPosition(1)
    AddHeaderOption("")
    AddSliderOptionST("SL_AL", "$Alteration", SandowPP.Config.skillRatioAl, slFmt, flag)
    AddSliderOptionST("SL_CO", "$Conjuration", SandowPP.Config.skillRatioCo, slFmt, flag)
    AddSliderOptionST("SL_DE", "$Destruction", SandowPP.Config.skillRatioDe, slFmt, flag)
    AddSliderOptionST("SL_IL", "$Illusion", SandowPP.Config.skillRatioIl, slFmt, flag)
    AddSliderOptionST("SL_RE", "$Restoration", SandowPP.Config.skillRatioRe, slFmt, flag)

    ;================================
    If !SandowPP.Config.IsSandow()
        Return
    EndIf
    SetCursorPosition(20)
    AddHeaderOption("<font color='#daa520'>$Other options</font>")
    AddSliderOptionST("SL_FP", "$MCM_SlFatiguePhys", ToPercent(SandowPP.Config.physFatigueRate), xslFmt)

    SetCursorPosition(21)
    AddHeaderOption("")
EndFunction

int Function DisableSkills()
    If Config.skillsLocked
        Return OPTION_FLAG_DISABLED
    Else
        Return OPTION_FLAG_NONE
    EndIf
EndFunction

State SL_AR
    Event OnSliderOpenST()
        CreateSkillSliderPhys(SandowPP.Config.skillRatioAr)
    EndEvent

    event OnSliderAcceptST(float val)
        SandowPP.Config.skillRatioAr =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        SandowPP.Config.skillRatioAr = SandowPP.Config.skillDefaultAr
        SetSliderOptionValueST(SandowPP.Config.skillRatioAr, slFmt)
    endEvent
EndState

State SL_BL
    Event OnSliderOpenST()
        CreateSkillSliderPhys(SandowPP.Config.skillRatioBl)
    EndEvent

    event OnSliderAcceptST(float val)
        SandowPP.Config.skillRatioBl =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        SandowPP.Config.skillRatioBl = SandowPP.Config.skillDefaultBl
        SetSliderOptionValueST(SandowPP.Config.skillRatioBl, slFmt)
    endEvent
EndState

State SL_HA
    Event OnSliderOpenST()
        CreateSkillSliderPhys(SandowPP.Config.skillRatioHa)
    EndEvent

    event OnSliderAcceptST(float val)
        SandowPP.Config.skillRatioHa =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        SandowPP.Config.skillRatioHa = SandowPP.Config.skillDefaultHa
        SetSliderOptionValueST(SandowPP.Config.skillRatioHa, slFmt)
    endEvent
EndState

State SL_LA
    Event OnSliderOpenST()
        CreateSkillSliderPhys(SandowPP.Config.skillRatioLa)
    EndEvent

    event OnSliderAcceptST(float val)
        SandowPP.Config.skillRatioLa =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        SandowPP.Config.skillRatioLa = SandowPP.Config.skillDefaultLa
        SetSliderOptionValueST(SandowPP.Config.skillRatioLa, slFmt)
    endEvent
EndState

State SL_1H
    Event OnSliderOpenST()
        CreateSkillSliderPhys(SandowPP.Config.skillRatio1H)
    EndEvent

    event OnSliderAcceptST(float val)
        SandowPP.Config.skillRatio1H =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        SandowPP.Config.skillRatio1H = SandowPP.Config.skillDefault1H
        SetSliderOptionValueST(SandowPP.Config.skillRatio1H, slFmt)
    endEvent
EndState

State SL_SN
    Event OnSliderOpenST()
        CreateSkillSliderPhys(SandowPP.Config.skillRatioSn)
    EndEvent

    event OnSliderAcceptST(float val)
        SandowPP.Config.skillRatioSn =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        SandowPP.Config.skillRatioSn = SandowPP.Config.skillDefaultSn
        SetSliderOptionValueST(SandowPP.Config.skillRatioSn, slFmt)
    endEvent
EndState

State SL_SM
    Event OnSliderOpenST()
        CreateSkillSliderPhys(SandowPP.Config.skillRatioSm)
    EndEvent

    event OnSliderAcceptST(float val)
        SandowPP.Config.skillRatioSm =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        SandowPP.Config.skillRatioSm = SandowPP.Config.skillDefaultSm
        SetSliderOptionValueST(SandowPP.Config.skillRatioSm, slFmt)
    endEvent
EndState

State SL_2H
    Event OnSliderOpenST()
        CreateSkillSliderPhys(SandowPP.Config.skillRatio2H)
    EndEvent

    event OnSliderAcceptST(float val)
        SandowPP.Config.skillRatio2H =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        SandowPP.Config.skillRatio2H = SandowPP.Config.skillDefault2H
        SetSliderOptionValueST(SandowPP.Config.skillRatio2H, slFmt)
    endEvent
EndState

State SL_AL
    Event OnSliderOpenST()
        CreateSkillSliderMag(SandowPP.Config.skillRatioAl)
    EndEvent

    event OnSliderAcceptST(float val)
        SandowPP.Config.skillRatioAl =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        SandowPP.Config.skillRatioAl = SandowPP.Config.skillDefaultAl
        SetSliderOptionValueST(SandowPP.Config.skillRatioAl, slFmt)
    endEvent
EndState

State SL_CO
    Event OnSliderOpenST()
        CreateSkillSliderMag(SandowPP.Config.skillRatioCo)
    EndEvent

    event OnSliderAcceptST(float val)
        SandowPP.Config.skillRatioCo =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        SandowPP.Config.skillRatioCo = SandowPP.Config.skillDefaultCo
        SetSliderOptionValueST(SandowPP.Config.skillRatioCo, slFmt)
    endEvent
EndState

State SL_DE
    Event OnSliderOpenST()
        CreateSkillSliderMag(SandowPP.Config.skillRatioDe)
    EndEvent

    event OnSliderAcceptST(float val)
        SandowPP.Config.skillRatioDe =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        SandowPP.Config.skillRatioDe = SandowPP.Config.skillDefaultDe
        SetSliderOptionValueST(SandowPP.Config.skillRatioDe, slFmt)
    endEvent
EndState

State SL_IL
    Event OnSliderOpenST()
        CreateSkillSliderMag(SandowPP.Config.skillRatioIl)
    EndEvent

    event OnSliderAcceptST(float val)
        SandowPP.Config.skillRatioIl =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        SandowPP.Config.skillRatioIl = SandowPP.Config.skillDefaultIl
        SetSliderOptionValueST(SandowPP.Config.skillRatioIl, slFmt)
    endEvent
EndState

State SL_RE
    Event OnSliderOpenST()
        CreateSkillSliderMag(SandowPP.Config.skillRatioRe)
    EndEvent

    event OnSliderAcceptST(float val)
        SandowPP.Config.skillRatioRe =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        SandowPP.Config.skillRatioRe = SandowPP.Config.skillDefaultRe
        SetSliderOptionValueST(SandowPP.Config.skillRatioRe, slFmt)
    endEvent
EndState

State SL_FP
    Event OnSliderOpenST()
        CreateFatigueSlider(SandowPP.Config.physFatigueRate)
    EndEvent

    Event OnSliderAcceptST(float val)
        SandowPP.Config.physFatigueRate =  PercentToFloat(val)
        SetSliderOptionValueST(val, xslFmt)
    EndEvent

    Event OnDefaultST()
        SandowPP.Config.physFatigueRate = PercentToFloat(10)
        SetSliderOptionValueST(10, xslFmt)
    EndEvent

    Event OnHighlightST()
        float sk = SandowPP.Config.skillRatioRe
        float mr = SandowPP.Config.magFatigueRateMultiplier
        float r = SandowPP.Config.physFatigueRate * mr
        float rr = FloatToPercent(sk * r)
        string s = "$MCM_SlWGPMultInfo{" + FloatToStr(mr, 1) + "}{" + FloatToStr(rr) + "}"
        SetInfoText(s)
    EndEvent
EndState


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
    ;If SandowPP.PresetManager.Exists()
    ;    Return OPTION_FLAG_NONE
    ;Else
    ;    Return OPTION_FLAG_DISABLED
    ;EndIf
EndFunction

int Function LoadFlag(int aPresetNum)
    Return FlagByBool(SandowPP.PresetManager.Exists() && SandowPP.PresetManager.ProfileExists(aPresetNum))
    ;If SandowPP.PresetManager.Exists() && SandowPP.PresetManager.ProfileExists(aPresetNum)
    ;    Return OPTION_FLAG_NONE
    ;Else
    ;    Return OPTION_FLAG_DISABLED
    ;EndIf
EndFunction

Function SavePreset(int aPresetNum)
    SandowPP.PresetManager.SaveFile(aPresetNum, SandowPP.Config)
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
    Config.Assign(pData)
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