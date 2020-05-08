; Some comments are in english because I'm sure as hell you'll see this script.
; If you want to change something, try to change only the things that are marked as 
; safe to change. Otherwise, you are bound to break this mod balance.
Scriptname DM_SandowPPMain extends DM_SandowPPMain_Interface
{Sandow Plus Plus main script}

Import DM_Utils
Import DM_SandowPP_Globals
Import DM_SandowPP_SkeletonNodes

; ########################################################################
; Variables needed for this system to work. ***DON'T CHANGE AT RUN TIME***
; ########################################################################
DM_SandowPP_WeightTraining Property WeightTraining Auto
DM_SandowPP_Items Property Items Auto

DM_SandowPP_Config Property Config auto
DM_SandowPP_State Property CurrentState Auto
DM_SandowPP_HeightChanger Property HeightChanger Auto

; Design patterns
DM_SandowPP_PresetMngrNone Property PresetMngrNone Auto
DM_SandowPP_PresetMngrPapUtl Property PresetMngrPapUtl Auto
DM_SandowPP_PresetMngrFISSES Property PresetMngrFISSES Auto
DM_SandowPP_PresetManager property PresetManager
    DM_SandowPP_PresetManager Function get()
        return _presetManager
    EndFunction
EndProperty

DM_SandowPP_ReportDebug Property ReportDebug Auto
DM_SandowPP_ReportSkyUILib Property ReportSkyUILib Auto
DM_SandowPP_ReportWidget Property ReportWidget Auto
DM_SandowPP_Report Property Report
    DM_SandowPP_Report Function get()
        Return _report
    EndFunction
EndProperty

DM_SandowPP_AlgorithmPause Property AlgoPause Auto
DM_SandowPP_AlgoWCSandow Property AlgoWCSandow Auto
DM_SandowPP_AlgoWCPumping Property AlgoWCPumping Auto

DM_SandowPP_Algorithm Property Algorithm
    DM_SandowPP_Algorithm Function get()
        Return _algorithm
    EndFunction
EndProperty

DM_SandowPP_AlgorithmData Property AlgorithmData Auto

; ########################################################################
; Internal variables used to keep track of this mod state
float _goneToSleepAt

DM_SandowPP_PresetManager _presetManager
DM_SandowPP_Report _report
DM_SandowPP_Algorithm _algorithm

; ########################################################################
; Events
; ########################################################################
;string Property NINODE_HEAD = "NPC Head [Head]" AutoReadOnly
Function ChangeHeadSize()
    DM_SandowPP_Config c = Config
    If c.CanResizeHead && SkelNodeExists(Player, NINODE_HEAD())
        float size = Lerp(c.HeadSizeMin, c.HeadSizeMax, PercentToFloat(Player.GetActorBase().GetWeight()))
        NetImmerse.SetNodeScale(Player, NINODE_HEAD(), size, False)
        Player.QueueNiNodeUpdate() 
        Trace("Changed head size = " + size)
    EndIf
EndFunction

function t(int index, string area)
    int i = NiOverride.GetNumBodyOverlays()
    While i > 0
    i -= 1
    Trace("Overlay" + i + " " + NiOverride.GetNodeOverrideString(Player, true, Area + " [ovl" + i + "]", 9, index))
    EndWhile
EndFunction

Function Test()
    Trace("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
    string tx = "textures\\actors\\character\\female\\600 extreme.dds"
    txset()
    ; int idx = 0
    ; ts(idx)
    ; NiOverride.AddSkinOverrideString(Player, true, false, 0x04, 9, idx, tx, true)
    ; NiOverride.ApplySkinOverrides(Player)
    ; ts(idx)
    
    Trace("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
EndFunction

function txset()
    TextureSet tx = Game.GetFormFromFile(0x01000800, "SandowPP - Ripped Bodies.esp") as TextureSet
    RaceMenu r = Game.GetFormFromFile(0x01000800, "RaceMenu.esp") as RaceMenu
    ; TextureSet tx = Game.GetFormFromFile(0x01000802, "SandowPP - Ripped Bodies.esp") as TextureSet
    ; TextureSet tx = Game.GetFormFromFile(0x01000807, "SandowPP - Ripped Bodies.esp") as TextureSet
    Trace(r)
    Trace(tx)
    ; rgb = NiOverride.GetNodePropertyInt(_targetActor, false, nodeName, 7, -1)
    int idx = -1
    string node = "Body [Ovl5]"
    int skinColor = NiOverride.GetSkinPropertyInt(player, false, 4, 7, -1)
    Trace("Skin base? " + NiOverride.GetSkinPropertyInt(player, false, 4, 7, -1))
    Trace("Skin base? 1st " + NiOverride.GetSkinPropertyInt(player, true, 4, 7, -1))
    Trace("Skin override " + NiOverride.GetNodePropertyInt(player, false, node, 7, -1))
    Trace(node)
    NiOverride.AddNodeOverrideFloat(Player, true,  node, 8, idx, 0, true)
    NiOverride.AddNodeOverrideTextureSet(Player, true, node, 6, idx, tx, true)
    NiOverride.AddNodeOverrideFloat(Player, true,  node, 8, idx, 0.5, true)
    NiOverride.AddNodeOverrideInt(Player, true,  node, 7, idx, skinColor, true)
	r.Reinitialize()

    ; NiOverride.ApplyNodeOverrides(player)
    Player.QueueNiNodeUpdate()
EndFunction

function ts(int idx)
    Trace("GetSkinPropertyString " + NiOverride.GetSkinPropertyString(Player, false, 0x04, 9, idx))
    Trace("GetSkinOverrideString " + NiOverride.GetSkinOverrideString(Player, true, false, 0x04, 9, idx))
EndFunction

function ovDiffuse(string tx)
    String Area = "Body"
    String Node = Area + " [ovl" + 5 + "]"
    int index = 1
    
    Trace(NiOverride.GetNumBodyOverlays())
    Trace("Before")
    t(index, area)
    NiOverride.AddNodeOverrideString(Player, true, Node, 9, index, tx, true)
    NiOverride.AddNodeOverrideFloat(Player, true,  node, 9, index, 1.0, true)
    Player.QueueNiNodeUpdate()
    NiOverride.ApplyNodeOverrides(player)
    Trace("After")
    t(index, area)
EndFunction

Event OnKeyDown(Int KeyCode)
    If KeyCode == Config.HkShowStatus
        Test()
        ChangeHeadSize()
        Algorithm.ReportOnHotkey(AlgorithmData)
    EndIf
EndEvent

Event OnInit()
    OpenLog()
    Trace("$Gen_Init")
    ResetVariables()
    RegisterForSleep()
    RegisterEvents()
    
    Config.PresetManager = DefaultPresetManager()
    ; Load preset #1 if it exists. This was done to save the player time.
    If PresetManager.ProfileExists(1) 
        Config.Assign( PresetManager.LoadFile(1) )
        RegisterAgainHotkeys()
    EndIf
EndEvent 

Function PreparePlayerToSleep()
    {Being in animation (from Posers or something) while sleeping seems to freeze the game. Avoid it.}
    If Player.IsWeaponDrawn()
        Player.SheatheWeapon()
    EndIf
EndFunction

Event OnSleepStart(float aStartTime, float aEndTime)
    {Prepare player to sleep. Setup sleeping time and total hours awaken.}
    PreparePlayerToSleep()
    CurrentState.HoursAwaken = CurrentState.HoursAwakenRT() ; Freeze hours awaken because he just went to sleep. Duh!
    _goneToSleepAt           = Now()                        ; Just went to sleep
endEvent

Event OnSleepStop(bool aInterrupted)
    { Main calculation. This is the core of this mod. }
    CurrentState.HoursSlept = ToRealHours(Now() - _goneToSleepAt)       ; Hours actually slept. Player can cancel.
    If CurrentState.HoursSlept < 1 
        Return      ; Do nothing if didn't really slept
    EndIf
    CurrentState.Assign( Algorithm.OnSleep(AlgorithmData) )             ; Main calculation. Yep; that's all.
    CurrentState.WeightGainMultiplier = 1.0                             ; Weight gain from anabolics expires on sleep
    ChangeHeadSize()
    If Config.VerboseMod
        Algorithm.ReportSleep(AlgorithmData)
    EndIf
endEvent

Function PrepareAlgorithmData()
    { Algorithms need data to function properly. This method properly points to that data. }
    AlgorithmData.CurrentState = CurrentState
    AlgorithmData.Config = Config
    AlgorithmData.Report = Report
EndFunction

; ########################################################################
; Public functions. Call them from wherever you want.
; ########################################################################
Function OnGameReload()
    {Setup things again after reloading a save. Mostly registering events again}
    OpenLog()
    Trace("Reloading a saved game")
    Config.Owner = Self         ; For some reason, Config.Owner refuses to stay as configured in the CK
    RegisterAgainHotkeys()      
    RegisterEvents()
    PrepareAlgorithmData()    
    HeightChanger.ReapplyHeight()
EndFunction

Function RegisterEvents()
    { Register all events needed for this to work }
    HeightChanger.RegisterEvents()
EndFunction

Function Configure()
    { Configure data after using the MCM or reloading a preset. This method is called by the Config script/object belonging to this script }
    Trace("Main.Configure()")
    PrepareAlgorithmData()
    SelectReport()
    SelectPresetManager()
    ChangeAlgorithm()
    ConfigureWidget()
EndFunction

Function SelectReport()
    {Selects report system}
    Trace("Main.SelectReport(" + Config.ReportType + ")")
    
    _report.OnExit()
    If Config.IsSkyUiLib()
        _report = ReportSkyUILib
    ElseIf Config.IsWidget()
        _report = ReportWidget
    Else
        _report = ReportDebug
    EndIf
    _report.OnEnter()
EndFunction

Function ChangeAlgorithm()
    { Change mod Behavior }    
    Trace("Main.ChangeAlgorithm(" + Config.Behavior + ")")
    DM_SandowPP_Algorithm newAlgo
    If Config.IsPumpingIron()
        newAlgo = AlgoWCPumping
    ElseIf Config.IsPaused()
        newAlgo = AlgoPause
    Else
        newAlgo = AlgoWCSandow
    EndIf
    
    ; Change only if switched algorithms
    If _algorithm.Signature() != newAlgo.Signature()
        Trace("Switching algorithms")
        _algorithm.OnExitAlgorithm(AlgorithmData)
        _algorithm = newAlgo
        _algorithm.OnEnterAlgorithm(AlgorithmData)
    EndIf
    Trace("Ending Main.ChangeAlgorithm()")
EndFunction

Function ConfigureWidget()
    {}
    Trace("Main.ConfigureWidget()")
    ReportWidget.UpdateTime = Config.rwUpdateTime
    ReportWidget.Opacity = Config.rwOpacity
    ReportWidget.Scale = Config.rwScale
    ReportWidget.HAlign = Config.rwHAlign
    ReportWidget.VAlign = Config.rwVAlign
    ReportWidget.X = Config.rwX
    ReportWidget.Y = Config.rwY
    If Report == ReportWidget
        Algorithm.SetupWidget(AlgorithmData)
        ReportWidget.UpdateConfig()
        Algorithm.ReportEssentials(AlgorithmData)
    EndIf
EndFunction
    
Function RegisterAgainHotkeys()
    { Registers again events for hotkeys that have already been set up }
    Trace("Main.RegisterAgainHotkeys(HkShowStatus = " + Config.HkShowStatus + ")")
    RegisterAgainHotkey(Config.HkShowStatus)
EndFunction

Function RegisterHotkey(int aOldKey, int aNewKey)
    {Registers a new hotkey}
    Trace("Main.RegisterHotkey(" + aOldKey + ", " + aNewKey + ")")
    UnRegisterForKey(aOldKey)
    RegisterForKey(aNewKey)
EndFunction
    
Function RegisterAgainHotkey(int oldKey)
    { Registers again events for ONE hotkey that have already been set up }
    Trace("Main.RegisterAgainHotkey(oldKey = " + oldKey + ")")

    if oldKey != Config.hotkeyInvalid
        RegisterForKey(oldKey)
    EndIf
EndFunction

int Function DefaultPresetManager()
    {Returns a default preset manager}
    Trace("Main.DefaultPresetManager()")
    int i

    If PresetMngrPapUtl.Exists()        ; PapyrusUtils is the preferred file manager
        i = Config.pmPapyrusUtil
    ElseIf PresetMngrFISSES.Exists()
        i = Config.pmFISS
    Else
        i = Config.pmNone
    EndIf

    Trace("Return " + i)
    Return i
EndFunction

Function SelectPresetManager()
    {Selection of the Strategy Pattern}
    Trace("Main.SelectPresetManager(" + Config.PresetManager + ")")
    
    If Config.PresetManager == Config.pmPapyrusUtil
        _presetManager = PresetMngrPapUtl
    ElseIf Config.PresetManager == Config.pmFISS
        _presetManager = PresetMngrFISSES
    Else
        _presetManager = PresetMngrNone
    EndIf
EndFunction

Function Train(string aSkill)
    {Decides how much WGP and fatigue will be added}
    Trace("Main.Train(" + aSkill + ")")

    if aSkill == "TwoHanded"
        TrainAndFatigue(Config.skillRatio2H, Config.physFatigueRate)
    elseif aSkill == "OneHanded"
        TrainAndFatigue(Config.skillRatio1H, Config.physFatigueRate)
    elseif aSkill == "Block"
        TrainAndFatigue(Config.skillRatioBl, Config.physFatigueRate)
    elseif aSkill == "Marksman"
        TrainAndFatigue(Config.skillRatioAr, Config.physFatigueRate)
    elseif aSkill == "HeavyArmor" 
        TrainAndFatigue(Config.skillRatioHa, Config.physFatigueRate)
    elseif aSkill == "LightArmor" 
        TrainAndFatigue(Config.skillRatioLa, Config.physFatigueRate)
    elseif aSkill == "Sneak" 
        TrainAndFatigue(Config.skillRatioSn, Config.physFatigueRate)
    elseif aSkill == "Smithing" 
        TrainAndFatigue(Config.skillRatioSm, Config.physFatigueRate)
    elseif aSkill == "Alteration" 
        TrainAndFatigue(Config.skillRatioAl, Config.magFatigueRate)
    elseif aSkill == "Conjuration" 
        TrainAndFatigue(Config.skillRatioCo, Config.magFatigueRate)
    elseif aSkill == "Destruction" 
        TrainAndFatigue(Config.skillRatioDe, Config.magFatigueRate)
    elseif aSkill == "Illusion" 
        TrainAndFatigue(Config.skillRatioIl, Config.magFatigueRate)
    elseif aSkill == "Restoration" 
        TrainAndFatigue(Config.skillRatioRe, Config.magFatigueRate)
    EndIf
EndFunction

Function TrainAndFatigue(float aSkillTraining, float aSkillFatigueRate)
    {Apply fatigue, WGP and inactivity related things}
    Trace("Old SkillFatigue = " + CurrentState.SkillFatigue)
    Trace("Old WGP = " + CurrentState.WGP)
    
    If !Algorithm.CanGainWGP()
        Trace("Can't gain WGP. Returning.")
        return
    EndIf

    CurrentState.SkillFatigue += (aSkillFatigueRate * aSkillTraining)
    CurrentState.WGP += aSkillTraining
    CurrentState.WGPGainType = Report.mtUp
    If aSkillTraining > 0
        CurrentState.LastSkillGainTime = Now()          ; Used for Inactivity calculations
        if Config.VerboseMod
            Algorithm.ReportSkillLvlUp(AlgorithmData)
        EndIf
    EndIf
    
    Trace("New SkillFatigue = " + CurrentState.SkillFatigue)
    Trace("New WGP = " + CurrentState.WGP)
EndFunction

; ########################################################################
; Private functions. These are designed to be used only within   LeveledItem
; this script. Never call them from the outside.
; ########################################################################

Function ResetVariables()
    Config.HkShowStatus = Config.hotkeyInvalid
    _algorithm = AlgoWCSandow
    Config.Owner = Self
    _report = ReportDebug
    PrepareAlgorithmData()
    CurrentState.LastSlept = -1
EndFunction

string Function GetMCMStatus()  
    {Used by the MCM only}
    Return Algorithm.GetMCMStatus(AlgorithmData)
EndFunction

string Function GetMCMWeight()
    {Used by the MCM only}
    Return FloatToStr(Player.GetActorBase().GetWeight())
EndFunction

string Function GetMCMWGP()
    {Used by the MCM only}
    Return FloatToStr(CurrentState.WGP)
EndFunction

string Function GetMCMCustomLabel1()
    {Used by the MCM only}
    Return Algorithm.GetMCMCustomLabel1(AlgorithmData)
EndFunction

string Function GetMCMCustomData1()
    {Used by the MCM only}
    Return Algorithm.GetMCMCustomData1(AlgorithmData)
EndFunction

string Function GetMCMCustomInfo1()
    {Used by the MCM only}
    Return Algorithm.GetMCMCustomInfo1(AlgorithmData)
EndFunction