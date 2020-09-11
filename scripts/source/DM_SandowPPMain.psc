; Some comments are in english because I'm sure as hell you'll see this script.
; If you want to change something, try to change only the things that are marked as
; safe to change. Otherwise, you are bound to break this mod balance.
Scriptname DM_SandowPPMain extends DM_SandowPPMain_Interface
{Sandow Plus Plus main script. This controls everything.}

Import DM_Utils
Import DM_SandowPP_Globals
Import DM_SandowPP_SkeletonNodes

; ########################################################################
; Variables needed for this system to work. ***DON'T CHANGE AT RUN TIME***
; ########################################################################
DM_SandowPP_WeightTraining Property WeightTraining Auto
DM_SandowPP_Items Property Items Auto

Spell Property rippedSpell Auto
{Spell to make the player ripped}
DM_SandowPP_TextureMngr Property texMngr Auto
{Texture manager that applies ripped textures to actors}

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
{Paused Behavior}
DM_SandowPP_AlgoWCSandow Property AlgoWCSandow Auto
{Sandow++ Behavior}
DM_SandowPP_AlgoWCPumping Property AlgoWCPumping Auto
{Pumping Iron Behavior}
DM_SandowPP_AlgorithmBodyfatBruce Property AlgoBFBruce Auto
{Bruce Lee Behavior}

DM_SandowPP_Algorithm Property Algorithm
    {Current Behavior}
    DM_SandowPP_Algorithm Function get()
        Return _algorithm
    EndFunction
EndProperty

DM_SandowPP_AlgorithmData Property AlgorithmData Auto
{Composite object that carries all data needed for this mod to work}


; ########################################################################
; Internal variables used to keep track of this mod state
float _goneToSleepAt

DM_SandowPP_PresetManager _presetManager
DM_SandowPP_Report _report
DM_SandowPP_Algorithm _algorithm

; ########################################################################
; Events
; ########################################################################
Function ChangeHeadSize()
    DM_SandowPP_Config c = Config
    If c.CanResizeHead && SkelNodeExists(Player, NINODE_HEAD())
        float size = Lerp(c.HeadSizeMin, c.HeadSizeMax, PercentToFloat(Player.GetActorBase().GetWeight()))
        NetImmerse.SetNodeScale(Player, NINODE_HEAD(), size, False)
        Player.QueueNiNodeUpdate()
        Trace("Changed head size = " + size)
    EndIf
EndFunction

function txset()
    ; You should use a property to get this texture set. This is just for testing.
    TextureSet tx = Game.GetFormFromFile(0x01000800, "SandowPP - Ripped Bodies.esp") as TextureSet
    ; Index is irrelevant for all these specific operations. It's **somewhat** documented in the NiOverride source code.
    int irrelevant = -1
    ; It NEEDS to be this override layer (is that called like that? No info anywhere). Don't ask me why it doesn't work with other nodes, like "Body [Ovl0]" et al.
    string node = "Body [Ovl5]"
    ; Get the skin tint color of the Actor to reapply it soon
    int skinColor = NiOverride.GetSkinPropertyInt(player, false, 4, 7, -1)
    ; Add the texture set we want to show
    NiOverride.AddNodeOverrideTextureSet(Player, true, node, 6, irrelevant, tx, true)
    NiOverride.AddNodeOverrideFloat(Player, true,  node, 8, irrelevant, _ta, true)
    ; Last operation resets the skin tint color to white, making the character's body pale. Restore the color we got earlier.
    NiOverride.AddNodeOverrideInt(Player, true,  node, 7, irrelevant, skinColor, true)
    ; Profit! Have a nice day.
EndFunction

float _ta = 0.0
function la()
    int t = Math.floor(_ta * 100)
    t = (t + 5) % 100
    _ta = t / 100.0
    Trace("@@@@@@@@@@@@@@@@ a = " + _ta)
    NiOverride.AddNodeOverrideFloat(Player, true,  "Body [Ovl5]", 8, -1, _ta, true)
    int sx = Player.GetLeveledActorBase().GetSex()
    int sx2 = Player.GetActorBase().GetSex()
    trace("sex " + sx)
    trace("AlgoWCSandow " + AlgoWCSandow.GetPlayerWeight())
    ; trace("isFemale " + DM_Utils.GetActorSex(Player) + " " + DM_Utils.isFemale(Player))
    ; trace("isMale " + DM_Utils.GetActorSex(Player) + " " + DM_Utils.isMale(Player) + (GetActorSex(Player) == 0))
    Debug.Notification(_ta)
EndFunction

Event OnKeyDown(Int KeyCode)
    If KeyCode == Config.HkShowStatus
        Algorithm.ReportOnHotkey(AlgorithmData)
    EndIf
    ; If KeyCode == 200
    ;     la()
    ; EndIf
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
    CalcPlayerRippedness()
    If Config.VerboseMod
        Algorithm.ReportSleep(AlgorithmData)
    EndIf
endEvent

int _bulkCutDays = 0
DM_SandowPP_RippedPlayer _rippedPlayer
DM_SandowPP_RippedAlphaCalcPlayer _rippedPlayerAlpha
Function CalcPlayerRippedness()
    {Calculate muscular definition settings for player.}
    If _rippedPlayer.bulkCut
            ; SwapBulkCut()
    Else
        ;  Simple muscle def. options
        Trace("Simple muscle def")
        If !(_rippedPlayerAlpha.MethodIsNone() || _rippedPlayerAlpha.MethodIsBehavior())
            ; Reapply texture because some actions can clean it
            texMngr.InitializeActor(Player)
        EndIf
    EndIf
EndFunction

Function SwapBulkCut()
    {Swap bulkin and cutting behaviors.}
    _bulkCutDays += 1
    If _bulkCutDays >= _rippedPlayer.bulkCutDays
        _bulkCutDays = 0
        Debug.Notification("$RippedNotiBulk")
        Debug.Notification("$RippedNotiCut")
    EndIf
EndFunction

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
    InitVars()
    RegisterAgainHotkeys()
    RegisterEvents()
    PrepareAlgorithmData()
    HeightChanger.ReapplyHeight()
    ;RegisterForKey(200)
    texMngr.InitData()
    texMngr.Debug(Player)
    ; ; Trace("diminish SPP 0 = " + JValue.evalLuaFlt(0, "return sandowpp.diminishingRatio(0)"))
    ; Trace("diminish SPP 1 = " + JValue.evalLuaFlt(0, "return sandowpp.diminishingRatio(1)"))
    ; JValue.writeToFile(array, JContainers.userDirectory() + "playerInfo.txt")
    InitVars40()
    InitDataTree()
    LoadAddons()
EndFunction

;>=========================================================
;>===                       v4.0                        ===
;>=========================================================

    string Property mainDir =   "Data/SKSE/Plugins/Sandow Plus Plus/" AutoReadOnly Hidden
    string Property cfgDir  =   "config/" Auto
    string Property jDBRoot =   "sandow++" AutoReadOnly Hidden

    ;region: Initialization

        Function InitVars40()
            ; Init paths
            cfgDir = mainDir + cfgDir
        EndFunction

        ; Loads a premade data tree so it's easier to fill it in Lua.
            ; The file is "Data/SKSE/Plugins/Sandow Plus Plus/config/bare tree.json".
            ;
            ; That premade file contains the overall data structure for this mod.
        Function InitDataTree()
            JDB.setObj(jDBRoot, JValue.readFromFile(cfgDir + "bare tree.json"))
            ; int data = JValue.readFromFile(cfgDir + "bare tree.json")
            ; JDB.setObj(jDBRoot, data)
        EndFunction

        ; Creates the addon data tree in memory, so this mod can be used.
        Function LoadAddons()
            int tree = JValue.evalLuaObj(GetDataTree(), "return sandowpp.installAddons(jobject)")
            JValue.writeToFile(tree, JContainers.userDirectory() + "installAddons.json")

        EndFunction

    ; Gets the handle for the whole data tree.
        ; Look at "bare tree.json" to see which structure this function will return.
        ;
        ; This data tree is passed around by this scipt to make the mod work.
        ; Whenever you see a variable named "data" in Lua, it refers to this tree.
    int Function GetDataTree()
        return JDB.solveObj("." + jDBRoot)
    EndFunction

;>=========================================================
;>===                       END                         ===
;>=========================================================

Function InitVars()
    Config.Owner = Self         ; For some reason, Config.Owner refuses to stay as configured in the CK
    _rippedPlayer = texMngr.PlayerSettings
    _rippedPlayerAlpha = (_rippedPlayer as Form) as DM_SandowPP_RippedAlphaCalcPlayer
EndFunction

Event SexLabEnter(string eventName, string argString, float argNum, form sender)
    {Sexlab integration}
    ; sslThreadController c = sender as sslThreadController
    ; If !c || !c.HasPlayer
    ;   return
    ; EndIf

    CurrentState.LastSkillGainTime = Now()
EndEvent

Function RegisterEvents()
    { Register all events needed for this to work }
    HeightChanger.RegisterEvents()
    ; If Game.GetModByName("SexLab.esm") != 255
    If SexLabExists()
        ; SexLab = Game.GetFormFromFile(0x00D62, "SexLab.esm") as Quest
        ; RegisterForModEvent("AnimationStart", "SexLabEnter")
    EndIf
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

; TODO: Delete
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
    Trace("Current: " + Algorithm.Signature())
    DM_SandowPP_Algorithm newAlgo
    If Config.IsPumpingIron()
        newAlgo = AlgoWCPumping
    ElseIf Config.IsPaused()
        newAlgo = AlgoPause
    ElseIf Config.IsBruce()
        Trace("Is Bruce " + Config.bhBruce)
        newAlgo = AlgoBFBruce
    Else
        newAlgo = AlgoWCSandow
    EndIf
    Trace("Expected: " + newAlgo.Signature())

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
    ; Trace("Main.SelectPresetManager(" + Config.PresetManager + ")")

    If Config.PresetManager == Config.pmPapyrusUtil
        _presetManager = PresetMngrPapUtl
    ElseIf Config.PresetManager == Config.pmFISS
        _presetManager = PresetMngrFISSES
    Else
        _presetManager = PresetMngrNone
    EndIf
EndFunction

; Decides how much WGP and fatigue will be added.
Function Train(string aSkill)
    ; Trace("Main.Train(" + aSkill + ")")

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

; Apply fatigue, WGP and inactivity related things.
Function TrainAndFatigue(float aSkillTraining, float aSkillFatigueRate)
    ; Trace("Old SkillFatigue = " + CurrentState.SkillFatigue)
    ; Trace("Old WGP = " + CurrentState.WGP)
    If !Algorithm.CanGainWGP()
        ; Trace("Can't gain WGP. Returning.")
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

; Used by the MCM only.
string Function GetMCMStatus()
    Return Algorithm.GetMCMStatus(AlgorithmData)
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
