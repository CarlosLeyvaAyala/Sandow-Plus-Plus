; https://github.com/schlangster/skyui/wiki/MCM-State-Options
Scriptname DM_SandowPPMCM extends DM_SandowPP_MCM_Presets

Import DM_Utils
Import JsonUtil
Import DM_SandowPP_Globals
Import DM_SandowPP_SkeletonNodes
Import JValue

; DM_SandowPP_Config Cfg
; DM_SandowPPMain property SPP auto

;>=========================================================
;>===               PRIVATE VARIABLES                   ===
;>=========================================================

int sDecimals = 1                       ; To give format to floats

string _ppMain = "$Main"
string _ppSkills = "$Skills"
string _ppWidget = "$Widget"
string _ppCompat = "$Compat"

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
    Cfg = SPP.Config

    Pages = new string[4]
    Pages[0] = _ppMain
    Pages[1] = _ppSkills
    Pages[2] = _ppWidget
    Pages[3] = _ppCompat

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
    SPP.OnGameReload()
    InitVars()
EndEvent

Function InitVars()
    {Initializes variables needed for this to work.}
    Cfg = SPP.Config
    ; _rippedPlayer = SPP.texMngr.PlayerSettings
    ; _rippedPlayerA = (_rippedPlayer as Form) as DM_SandowPP_RippedAlphaCalcPlayer
EndFunction

;>=========================================================
;>===                       MAIN                        ===
;>=========================================================

Function PageMain()
    SetCursorFillMode(TOP_TO_BOTTOM)
    ; Col 1
    SetCursorPosition(0)
    ; If !JContainersExists()
    ;     return
    ; EndIf

    PageMainPresets()
    PageMainConfiguration()
    ; PageMainOtherOptions(mainCfg)

    ; Col 2
    SetCursorPosition(1)
    PageMainStats()
    ; PageRippedPlayer()
    PageMainItems()
EndFunction

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
    If !SkelNodeExists(SPP.Player, aNodeName)
        Return OPTION_FLAG_DISABLED
    Else
        Return OPTION_FLAG_NONE
    EndIf
EndFunction

Function EnsurePresetManager(string mgr)
    If SPP.PresetManager.Exists() || Cfg.PresetManager == Cfg.pmNone
        Return
    EndIf
    ShowMessage("$MCM_PresetMgrInexistent{" + mgr + "}")
    ; Cfg.PresetManager = SPP.DefaultPresetManager()
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
;>===                       RIPPED                      ===
;>=========================================================

string _sl_DaysFmt = "$sl_DaysFmt"
; DM_SandowPP_RippedPlayer _rippedPlayer
; DM_SandowPP_RippedAlphaCalcPlayer _rippedPlayerA

int Function PageRippedPlayer(int pos)
    SetCursorPosition(pos)
    int count = 1
    Header("$Getting ripped")
    ; If (SPP.texMngr.IsValidRace(SPP.Player))
    ;     ; Hide menu when the player wants to bulk & cut or get ripped by behavior, because it doesn't make sense in those cases
    ;     If !(_rippedPlayer.bulkCut || Cfg.IsBruce())
    ;         Menu("MN_RippedPlayerOpt", "$MCM_RippedApply", _rippedPlayerMethods[_rippedPlayer.Method])
    ;         count += 1
    ;     Else
    ;         Label("TX_RippedPlayerHiddenMethod", "$Behavior", SPP.Algorithm.Signature(), FlagByBool(false))
    ;         count += 1
    ;     EndIf
    ;     ; Hide bulk & cut when it doesn't make sense
    ;     If _rippedPlayerA.MethodIsBehavior() || Cfg.IsBruce()
    ;         AddToggleOptionST("TG_RippedPlayerBulkCut", "$MCM_BulkCut", _rippedPlayer.bulkCut)
    ;         count += 1
    ;         If _rippedPlayer.bulkCut
    ;             Slider("SL_RippedBulkDaysSwap", "$MCM_SwapBulkCutDays", _rippedPlayer.bulkCutDays, _sl_DaysFmt)
    ;             Menu("MN_RippedBulkBhv", "$MCM_BulkBhv", _rippedPlayerBulkBhvMenu[_rippedPlayer.bulkCutBhv])
    ;             count += 2
    ;         EndIf
    ;     EndIf

    ;     ; Show constant config only when it's required.
    ;     If _rippedPlayerA.MethodIsConst()
    ;         Slider("SL_RippedPlayerConstAlpha", "$MCM_RippedConst", FloatToPercent(_rippedPlayer.constAlpha), slFmt0)
    ;         count += 1
    ;     EndIf

    ;     ; Texture bounds for player
    ;     If !_rippedPlayerA.MethodIsNone() && !_rippedPlayerA.MethodIsConst()
    ;         Slider("SL_RippedPlayerLB", "$MCM_RippedLowerBound", FloatToPercent(_rippedPlayer.LB), slFmt0)
    ;         Slider("SL_RippedPlayerUB", "$MCM_RippedUpperBound", FloatToPercent(_rippedPlayer.UB), slFmt0)
    ;         count += 2
    ;     EndIf
    ; Else
    ;     AddTextOptionST("TX_RippedInvalidRace", "", "$MCM_RippedInvalidRace{" + MiscUtil.GetActorRaceEditorID(SPP.Player) + "}" )
    ;     count += 1
    ; EndIf
    return pos + ToNewPos(count)
EndFunction

State TX_RippedPlayerHiddenMethod
    Event OnHighlightST()
        SetInfoText("$MCM_RippedPlayerHiddenMethod")
    EndEvent
EndState

State SL_RippedPlayerLB
    Event OnSliderOpenST()
        ; CreateSlider(FloatToPercent(_rippedPlayer.LB), 0.0, FloatToPercent(_rippedPlayer.UB) - 1.0, 1.0)
    EndEvent

    Event OnSliderAcceptST(float val)
        ; _rippedPlayer.LB = PercentToFloat(val)
        ; SPP.texMngr.InitializeActor(SPP.Player)
        ; SetSliderOptionValueST(val, slFmt0)
    EndEvent

    Event OnDefaultST()
        ; _rippedPlayer.LB = 0.0
        ; SPP.texMngr.InitializeActor(SPP.Player)
        ; SetSliderOptionValueST(0.0, slFmt0)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_RippedLowerBoundInfo{" + "$you" + "}")
    EndEvent
EndState

State SL_RippedPlayerUB
    Event OnSliderOpenST()
        ; CreateSlider(FloatToPercent(_rippedPlayer.UB), FloatToPercent(_rippedPlayer.LB) + 1.0, 100.0, 1.0)
    EndEvent

    Event OnSliderAcceptST(float val)
        ; _rippedPlayer.UB = PercentToFloat(val)
        ; SPP.texMngr.InitializeActor(SPP.Player)
        ; SetSliderOptionValueST(val, slFmt0)
    EndEvent

    Event OnDefaultST()
        ; _rippedPlayer.UB = 1.0
        ; SPP.texMngr.InitializeActor(SPP.Player)
        ; SetSliderOptionValueST(100, slFmt0)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_RippedUpperBoundInfo{" + "$you" + "}")
    EndEvent
EndState

State SL_RippedPlayerConstAlpha
    Event OnSliderOpenST()
        ; CreatePercentSlider(_rippedPlayer.constAlpha)
    EndEvent

    Event OnSliderAcceptST(float val)
        ; _rippedPlayer.constAlpha =  PercentToFloat(val)
        ; SPP.texMngr.InitializeActor(SPP.Player)
        ; SetSliderOptionValueST(val, slFmt0)
    EndEvent

    Event OnDefaultST()
        ; _rippedPlayer.constAlpha = 1.0
        ; ; RippedPlayerSetCnstAlpha()
        ; SPP.texMngr.InitializeActor(SPP.Player)
        ; SetSliderOptionValueST(FloatToPercent(_rippedPlayer.constAlpha), slFmt0)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_RippedConstInfo")
    EndEvent
EndState

State SL_RippedBulkDaysSwap
    Event OnSliderOpenST()
        ; CreateSlider(_rippedPlayer.bulkCutDays, 1.0, 20.0, 1.0)
    EndEvent

    Event OnSliderAcceptST(float val)
        ; _rippedPlayer.bulkCutDays = val as int
        ; SetSliderOptionValueST(_rippedPlayer.bulkCutDays, _sl_DaysFmt)
    EndEvent

    Event OnDefaultST()
        ; _rippedPlayer.bulkCutDays = 4
        ; SetSliderOptionValueST(_rippedPlayer.bulkCutDays, _sl_DaysFmt)
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
        ; OpenMenu(_rippedPlayer.Method, 0, _rippedPlayerMethods)
    EndEvent

    Event OnMenuAcceptST(int index)
        ; IF _rippedPlayer.Method == index
        ;     return
        ; EndIf
        ; _rippedPlayer.Method = index
        ; SetMenuOptionValueST(_rippedPlayerMethods[_rippedPlayer.Method])

        ; If _rippedPlayerA.MethodIsBehavior()
        ;     ; Bruce Lee behavior was actually selected from here
        ;     ;FIXME: Delete this
        ;     Cfg.Behavior = Cfg.bhBruce
        ; Else
        ;     SPP.texMngr.InitializeActor(SPP.Player)
        ; EndIf
        ; ForcePageReset()
    EndEvent

    Event OnDefaultST()
        ; If _rippedPlayer.Method == Cfg.rpmNone
        ;     return
        ; EndIf
        ; _rippedPlayer.Method = Cfg.rpmNone
        ; SPP.texMngr.InitializeActor(SPP.Player)
        ; SetMenuOptionValueST(_rippedPlayerMethods[_rippedPlayer.Method])
        ; ForcePageReset()
    EndEvent

    Event OnHighlightST()
        ; SetInfoText("$MCM_RippedApplyInfo{" + _rippedPlayerA.MethodInfo() + "}")
    EndEvent
EndState

State MN_RippedBulkBhv
    Event OnMenuOpenST()
        ; OpenMenu(_rippedPlayer.bulkCutBhv, 0, _rippedPlayerBulkBhvMenu)
    EndEvent

    Event OnMenuAcceptST(int index)
        ; _rippedPlayer.bulkCutBhv = index
        ; SetMenuOptionValueST(_rippedPlayerBulkBhvMenu[_rippedPlayer.bulkCutBhv])
    EndEvent

    Event OnDefaultST()
        ; _rippedPlayer.bulkCutBhv = 0
        ; SetMenuOptionValueST(_rippedPlayerBulkBhvMenu[_rippedPlayer.bulkCutBhv])
        ; ForcePageReset()
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_SwitchBulkCutDaysInfo")
    EndEvent
EndState

State TG_RippedPlayerBulkCut
    Event OnSelectST()
        ; _rippedPlayer.bulkCut = !_rippedPlayer.bulkCut
        ; SetToggleOptionValueST(_rippedPlayer.bulkCut)
        ; ForcePageReset()
    EndEvent

    Event OnDefaultST()
        ; _rippedPlayer.bulkCut = False
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
