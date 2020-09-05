; https://github.com/schlangster/skyui/wiki/MCM-State-Options
Scriptname DM_SandowPPMCM extends SKI_ConfigBase

Import DM_Utils
Import JsonUtil
Import DM_SandowPP_Globals
Import DM_SandowPP_SkeletonNodes

DM_SandowPPMain property SandowPP auto
DM_SandowPPMain SPP
DM_SandowPP_Config Cfg


;>=========================================================
;>===               PRIVATE VARIABLES                   ===
;>=========================================================

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
; string _ppRipped = "$Ripped"
string _ppWidget = "$Widget"
; string _ppProfiles = "$Presets"
string _ppCompat = "$Compat"

string[] _reports
string[] _behaviors
; string[] _presetManagers
string[] _vAlign
string[] _hAlign
string[] _rippedPlayerMethods
string[] _rippedPlayerBulkBhvMenu


;>=========================================================
;>===                   MAINTENANCE                     ===
;>=========================================================

int function GetVersion()
    {Mod 2.1+ needs to update version}
    ; 3 = added Paused behavior
    ; 4 = added Bruce Lee behavior. FISS dropped. Added Compatibility tab. Deleted presets tab. Dropped reports.
    return 4
endFunction

Event OnConfigInit()
    Cfg = SandowPP.Config

    Pages = new string[4]
    Pages[0] = _ppMain
    Pages[1] = _ppSkills
    Pages[2] = _ppWidget
    Pages[3] = _ppCompat

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
    _rippedPlayerMethods[Cfg.rpmBhv] = "$By behavior"   ;FIXME: Delete this

    _rippedPlayerBulkBhvMenu = new string[2]
    _rippedPlayerBulkBhvMenu[Cfg.bulkSPP] = "Sandow Plus Plus"
    _rippedPlayerBulkBhvMenu[Cfg.bulkPI] = "Pumping Iron"
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
    InitVars()
EndEvent

Function InitVars()
    {Initializes variables needed for this to work.}
    Cfg = SandowPP.Config
    SPP = SandowPP
    _rippedPlayer = SPP.texMngr.PlayerSettings
    _rippedPlayerA = (_rippedPlayer as Form) as DM_SandowPP_RippedAlphaCalcPlayer
EndFunction

;>=========================================================
;>===                       MAIN                        ===
;>=========================================================

Function PageMain()
    SetCursorFillMode(TOP_TO_BOTTOM)
    ; Row 1
    int presets = PageMainPresets(0)
    int stats = PageMainStats(1)
    ; Row 2
    ; int row2 = MaxI(stats - 1, presets)
    int mainCfg = PageMainConfiguration(presets)
    int ripped = PageRippedPlayer(stats)
    ;Row 3
    PageMainOtherOptions(mainCfg)
    PageMainItems(ripped)
EndFunction


;>=========================================================
;>===                   MAIN - PRESETS                  ===
;>=========================================================

int Function PageMainPresets(int pos)
    SetCursorPosition(pos)
    Header("$Presets")
    int count = 1
    If PapyrusUtilExists()
        Menu("MN_PresetLoad", "$Load", "")
        AddInputOptionST("IN_PresetSave", "$Save as...", "")
        count += 2
    Else
        TagPapyrusUtil()
        count += 1
    EndIf
    Return pos + ToNewPos(count)
EndFunction



;>=========================================================
;>===               MAIN - CONFIGURATION                ===
;>=========================================================

int Function PageMainConfiguration(int pos)
    int count = 3
    SetCursorPosition(pos)
    ;AddEmptyOption()
    Header("$Configuration")
    If !_rippedPlayer.bulkCut
        Menu("MN_BEHAVIOR", "$Behavior", _behaviors[Cfg.Behavior])
    Else
        Label("TX_BulkCutCantShowBhv", "", "$MCM_BulkCutCantShowBhv")
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

;>=========================================================
;>===                   MAIN - OTHER                    ===
;>=========================================================

int Function PageMainOtherOptions(int pos)
    SetCursorPosition(pos)
    Header("$Other options")
    Slider("SL_WEIGHTMULT", "$Weight gain rate", FloatToPercent(Cfg.weightGainRate), slFmt0)
    ; Change head size
    int flags = GetSkelFlags(NINODE_HEAD())
    AddToggleOptionST("TG_HEADSZ", "$MCM_HeadSz_Bool", Cfg.CanResizeHead, flags)
    If Cfg.CanResizeHead
        Slider("SL_HEADSZ_MN", "$MCM_HeadSz_Mn", Cfg.HeadSizeMin, slFmt2r, flags)
        Slider("SL_HEADSZ_MX", "$MCM_HeadSz_Mx", Cfg.HeadSizeMax, slFmt2r, flags)
    EndIf
    ; Change height
    AddToggleOptionST("TG_HEIGHT", "$Can gain Height", Cfg.CanGainHeight)
    If Cfg.CanGainHeight
        Slider("SL_HEIGHTMAX", "$Max Height", FloatToPercent(Cfg.HeightMax), slFmt0)
        Slider("SL_HEIGHTDAYS", "$Days to max Height", Cfg.HeightDaysToGrow, slFmt0r)
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

;>=========================================================
;>===                   MAIN - STATS                    ===
;>=========================================================

int Function PageMainStats(int pos)
    SandowPP.PrepareAlgorithmData()
    SetCursorPosition(pos)

    Header("$Stats")
    Label("TX_BW", SPP.Algorithm.GetMCMMainStatLabel(), SPP.Algorithm.GetMcmMainStat() + "%" )
    Label("TX_TRAINING", "$Weight Gain Potential:", SPP.GetMCMWGP() + "%")
    int count = 3
    ; Posibly won't exist
    If SPP.GetMCMCustomLabel1() && SPP.GetMCMCustomData1()
        Label("TX_CUSTOM1", SPP.GetMCMCustomLabel1(), SPP.GetMCMCustomData1() )
        count += 1
    EndIf
    If SPP.GetMCMStatus()
        Label("TX_STATUS", "", SandowPP.GetMCMStatus())
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

;>=========================================================
;>===                   MAIN - ITEMS                    ===
;>=========================================================
int Function PageMainItems(int pos)
    SetCursorPosition(pos)
    Header("$Items")
    Button("TX_IT_SACKS", "$Weight sacks", "$Distribute", FlagByBool(!SPP.Items.WeightSacksDistributed) )
    Button("TX_IT_ANABOL", "$Weight gainers", "$Distribute", FlagByBool(!SPP.Items.SillyDistributed) )
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


;>=========================================================
;>===                   REPORT WIDGET                   ===
;>=========================================================

Function PageWidget()
    SetCursorFillMode(TOP_TO_BOTTOM)
    Header("$Configuration")
    ; AddHeaderOption("<font color='#daa520'>$Configuration</font>")
    AddKeyMapOptionST("KM_WIDGET", "$MCM_HideShowWidget", Cfg.HkShowStatus)
    Slider("SL_RWUPDTIME", "$Update time", Cfg.rwUpdateTime, slFmt0r + " s")
    Slider("SL_RWALPHA", "$Opacity", Cfg.rwOpacity, slFmt0)
    Slider("SL_RWSCALE", "$Scale", FloatToPercent(Cfg.rwScale), slFmt0)

    SetCursorPosition(1)
    Header("$Other options")
    ; AddHeaderOption("<font color='#daa520'>$Other options</font>")
    Menu("MN_RWHAL", "$Horizontal Align", Cfg.rwHAlign)
    Menu("MN_RWVAL", "$Vertical Align", Cfg.rwVAlign)
    Slider("SL_RWX", "$X Offset", Cfg.rwX, slFmt0r)
    Slider("SL_RWY", "$Y Offset", Cfg.rwY, slFmt0r)
EndFunction

State KM_WIDGET
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
        SetInfoText("$MCM_HKStatusRWInfo")
    EndEvent
EndState

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


;>=========================================================
;>===                       SKILLS                      ===
;>=========================================================

Function PageSkills()
    SetCursorFillMode(TOP_TO_BOTTOM)
    int flag = DisableSkills()
    ;================================
    SetCursorPosition(0)
    AddHeaderOption("<font color='#daa520'>$MCM_WGPHeader</font>")
    Slider("SL_AR", "$Archery", Cfg.skillRatioAr, slFmt, flag)
    Slider("SL_BL", "$Block", Cfg.skillRatioBl, slFmt, flag)
    Slider("SL_HA", "$Heavy Armor", Cfg.skillRatioHa, slFmt, flag)
    Slider("SL_LA", "$Light Armor", Cfg.skillRatioLa, slFmt, flag)
    Slider("SL_1H", "$One Handed", Cfg.skillRatio1H, slFmt, flag)
    Slider("SL_SM", "$Smithing", Cfg.skillRatioSm, slFmt, flag)
    Slider("SL_SN", "$Sneak", Cfg.skillRatioSn, slFmt, flag)
    Slider("SL_2H", "$Two Handed", Cfg.skillRatio2H, slFmt, flag)

    SetCursorPosition(1)
    AddHeaderOption("")
    Slider("SL_AL", "$Alteration", Cfg.skillRatioAl, slFmt, flag)
    Slider("SL_CO", "$Conjuration", Cfg.skillRatioCo, slFmt, flag)
    Slider("SL_DE", "$Destruction", Cfg.skillRatioDe, slFmt, flag)
    Slider("SL_IL", "$Illusion", Cfg.skillRatioIl, slFmt, flag)
    Slider("SL_RE", "$Restoration", Cfg.skillRatioRe, slFmt, flag)

    ;================================
    If !Cfg.IsSandow()
        Return
    EndIf
    SetCursorPosition(20)
    AddHeaderOption("<font color='#daa520'>$Other options</font>")
    Slider("SL_FP", "$MCM_SlFatiguePhys", ToPercent(Cfg.physFatigueRate), xslFmt)

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


;>=========================================================
;>===                       RIPPED                      ===
;>=========================================================

string _sl_DaysFmt = "$sl_DaysFmt"
DM_SandowPP_RippedPlayer _rippedPlayer
DM_SandowPP_RippedAlphaCalcPlayer _rippedPlayerA

int Function PageRippedPlayer(int pos)
    SetCursorPosition(pos)
    int count = 1
    Header("$Getting ripped")
    If (SPP.texMngr.IsValidRace(SPP.Player))
        ; Hide menu when the player wants to bulk & cut or get ripped by behavior, because it doesn't make sense in those cases
        If !(_rippedPlayer.bulkCut || Cfg.IsBruce())
            Menu("MN_RippedPlayerOpt", "$MCM_RippedApply", _rippedPlayerMethods[_rippedPlayer.Method])
            count += 1
        Else
            Label("TX_RippedPlayerHiddenMethod", "$Behavior", SPP.Algorithm.Signature(), FlagByBool(false))
            count += 1
        EndIf
        ; Hide bulk & cut when it doesn't make sense
        If _rippedPlayerA.MethodIsBehavior() || Cfg.IsBruce()
            AddToggleOptionST("TG_RippedPlayerBulkCut", "$MCM_BulkCut", _rippedPlayer.bulkCut)
            count += 1
            If _rippedPlayer.bulkCut
                Slider("SL_RippedBulkDaysSwap", "$MCM_SwapBulkCutDays", _rippedPlayer.bulkCutDays, _sl_DaysFmt)
                Menu("MN_RippedBulkBhv", "$MCM_BulkBhv", _rippedPlayerBulkBhvMenu[_rippedPlayer.bulkCutBhv])
                count += 2
            EndIf
        EndIf

        ; Show constant config only when it's required.
        If _rippedPlayerA.MethodIsConst()
            Slider("SL_RippedPlayerConstAlpha", "$MCM_RippedConst", FloatToPercent(_rippedPlayer.constAlpha), slFmt0)
            count += 1
        EndIf

        ; Texture bounds for player
        If !_rippedPlayerA.MethodIsNone() && !_rippedPlayerA.MethodIsConst()
            Slider("SL_RippedPlayerLB", "$MCM_RippedLowerBound", FloatToPercent(_rippedPlayer.LB), slFmt0)
            Slider("SL_RippedPlayerUB", "$MCM_RippedUpperBound", FloatToPercent(_rippedPlayer.UB), slFmt0)
            count += 2
        EndIf
    Else
        AddTextOptionST("TX_RippedInvalidRace", "", "$MCM_RippedInvalidRace{" + MiscUtil.GetActorRaceEditorID(SPP.Player) + "}" )
        count += 1
    EndIf
    return pos + ToNewPos(count)
EndFunction

State TX_RippedPlayerHiddenMethod
    Event OnHighlightST()
        SetInfoText("$MCM_RippedPlayerHiddenMethod")
    EndEvent
EndState

State SL_RippedPlayerLB
    Event OnSliderOpenST()
        CreateSlider(FloatToPercent(_rippedPlayer.LB), 0.0, FloatToPercent(_rippedPlayer.UB) - 1.0, 1.0)
    EndEvent

    Event OnSliderAcceptST(float val)
        _rippedPlayer.LB = PercentToFloat(val)
        SPP.texMngr.InitializeActor(SPP.Player)
        SetSliderOptionValueST(val, slFmt0)
    EndEvent

    Event OnDefaultST()
        _rippedPlayer.LB = 0.0
        SPP.texMngr.InitializeActor(SPP.Player)
        SetSliderOptionValueST(0.0, slFmt0)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_RippedLowerBoundInfo{" + "$you" + "}")
    EndEvent
EndState

State SL_RippedPlayerUB
    Event OnSliderOpenST()
        CreateSlider(FloatToPercent(_rippedPlayer.UB), FloatToPercent(_rippedPlayer.LB) + 1.0, 100.0, 1.0)
    EndEvent

    Event OnSliderAcceptST(float val)
        _rippedPlayer.UB = PercentToFloat(val)
        SPP.texMngr.InitializeActor(SPP.Player)
        SetSliderOptionValueST(val, slFmt0)
    EndEvent

    Event OnDefaultST()
        _rippedPlayer.UB = 1.0
        SPP.texMngr.InitializeActor(SPP.Player)
        SetSliderOptionValueST(100, slFmt0)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_RippedUpperBoundInfo{" + "$you" + "}")
    EndEvent
EndState

State SL_RippedPlayerConstAlpha
    Event OnSliderOpenST()
        CreatePercentSlider(_rippedPlayer.constAlpha)
    EndEvent

    Event OnSliderAcceptST(float val)
        _rippedPlayer.constAlpha =  PercentToFloat(val)
        SPP.texMngr.InitializeActor(SPP.Player)
        SetSliderOptionValueST(val, slFmt0)
    EndEvent

    Event OnDefaultST()
        _rippedPlayer.constAlpha = 1.0
        ; RippedPlayerSetCnstAlpha()
        SPP.texMngr.InitializeActor(SPP.Player)
        SetSliderOptionValueST(FloatToPercent(_rippedPlayer.constAlpha), slFmt0)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_RippedConstInfo")
    EndEvent
EndState

State SL_RippedBulkDaysSwap
    Event OnSliderOpenST()
        CreateSlider(_rippedPlayer.bulkCutDays, 1.0, 20.0, 1.0)
    EndEvent

    Event OnSliderAcceptST(float val)
        _rippedPlayer.bulkCutDays = val as int
        SetSliderOptionValueST(_rippedPlayer.bulkCutDays, _sl_DaysFmt)
    EndEvent

    Event OnDefaultST()
        _rippedPlayer.bulkCutDays = 4
        SetSliderOptionValueST(_rippedPlayer.bulkCutDays, _sl_DaysFmt)
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
        OpenMenu(_rippedPlayer.Method, 0, _rippedPlayerMethods)
    EndEvent

    Event OnMenuAcceptST(int index)
        IF _rippedPlayer.Method == index
            return
        EndIf
        _rippedPlayer.Method = index
        SetMenuOptionValueST(_rippedPlayerMethods[_rippedPlayer.Method])

        If _rippedPlayerA.MethodIsBehavior()
            ; Bruce Lee behavior was actually selected from here
            ;FIXME: Delete this
            Cfg.Behavior = Cfg.bhBruce
        Else
            SPP.texMngr.InitializeActor(SPP.Player)
        EndIf
        ForcePageReset()
    EndEvent

    Event OnDefaultST()
        If _rippedPlayer.Method == Cfg.rpmNone
            return
        EndIf
        _rippedPlayer.Method = Cfg.rpmNone
        SPP.texMngr.InitializeActor(SPP.Player)
        SetMenuOptionValueST(_rippedPlayerMethods[_rippedPlayer.Method])
        ForcePageReset()
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_RippedApplyInfo{" + _rippedPlayerA.MethodInfo() + "}")
    EndEvent
EndState

State MN_RippedBulkBhv
    Event OnMenuOpenST()
        OpenMenu(_rippedPlayer.bulkCutBhv, 0, _rippedPlayerBulkBhvMenu)
    EndEvent

    Event OnMenuAcceptST(int index)
        _rippedPlayer.bulkCutBhv = index
        SetMenuOptionValueST(_rippedPlayerBulkBhvMenu[_rippedPlayer.bulkCutBhv])
    EndEvent

    Event OnDefaultST()
        _rippedPlayer.bulkCutBhv = 0
        SetMenuOptionValueST(_rippedPlayerBulkBhvMenu[_rippedPlayer.bulkCutBhv])
        ForcePageReset()
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_SwitchBulkCutDaysInfo")
    EndEvent
EndState

State TG_RippedPlayerBulkCut
    Event OnSelectST()
        _rippedPlayer.bulkCut = !_rippedPlayer.bulkCut
        SetToggleOptionValueST(_rippedPlayer.bulkCut)
        ForcePageReset()
    EndEvent

    Event OnDefaultST()
        _rippedPlayer.bulkCut = False
        SetToggleOptionValueST(False)
        ForcePageReset()
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_BulkCutInfo")
    EndEvent
EndState

;>=========================================================
;> Ripped NPC
int Function PageRippedNPCAll(int pos)
    SetCursorPosition(pos)

    int count = 1
    Header("$MCM_RippedNPCGlobal")
    return pos + ToNewPos(count)
EndFunction

;>=========================================================
;>===                       COMPAT                      ===
;>=========================================================

Function PageCompat()
    SetCursorFillMode(TOP_TO_BOTTOM)
    Header("$MCM_CompatHeader")
    TagPapyrusUtil()
    TagNiOverride()
    If SexLabExists()
        TagSexlab()
    EndIf
EndFunction


;>========================================================================#
; Generic tags functions
;>========================================================================#
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


;>========================================================================#
; Helper functions
;>========================================================================#

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

; string Function Header(string text)
;     AddHeaderOption(Header("$Presets"))
;     return "$MCM_Header{" + text + "}"
; EndFunction
Function Header(string text)
    AddHeaderOption("$MCM_Header{" + text + "}")
EndFunction

string Function Error(string text)
    return "$MCM_Error{" + text + "}"
EndFunction

; Renames AddTextOptionST() to declutter code
Function Button(string stateName, string ltext, string rtext, int flags = 0)
    AddTextOptionST(stateName, ltext, rtext, flags)
EndFunction

; Renames AddTextOptionST() to declutter code
Function Label(string stateName, string ltext, string rtext, int flags = 0)
    AddTextOptionST(stateName, ltext, rtext, flags)
EndFunction

; Renames Slider() to declutter code
Function Slider(string stateName, string text, float val, string fmt, int flags = 0)
    AddSliderOptionST(stateName, text, val, fmt, flags)
EndFunction

Function Menu(string stateName, string label, string options, int flags = 0)
    AddMenuOptionST(stateName, label, options, flags)
EndFunction
