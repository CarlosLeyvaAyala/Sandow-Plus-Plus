Scriptname DM_SandowPPMain extends DM_SandowPPMain_Interface
{Sandow Plus Plus main script. This controls everything.}

Import DM_Utils
Import DM_SandowPP_Globals
Import DM_SandowPP_SkeletonNodes
Import JValue

; ########################################################################
; Variables needed for this system to work. ***DON'T CHANGE AT RUN TIME***
; ########################################################################
DM_SandowPP_WeightTraining Property WeightTraining Auto
DM_SandowPP_Items Property Items Auto

DM_SandowPP_TextureMngr Property texMngr Auto
{Texture manager that applies ripped textures to actors}

DM_SandowPP_HeightChanger Property HeightChanger Auto
DM_SandowPP_ReportWidget Property ReportWidget Auto

; TODO: Delete
DM_SandowPP_Config Property Config auto
DM_SandowPP_State Property CurrentState Auto

; Design patterns
DM_SandowPP_PresetMngrNone Property PresetMngrNone Auto
DM_SandowPP_PresetMngrPapUtl Property PresetMngrPapUtl Auto
DM_SandowPP_PresetMngrFISSES Property PresetMngrFISSES Auto
DM_SandowPP_PresetManager property PresetManager
    DM_SandowPP_PresetManager Function get()
        return _presetManager
    EndFunction
EndProperty


DM_SandowPP_AlgorithmPause Property AlgoPause Auto
{Paused Behavior}
DM_SandowPP_AlgoWCSandow Property AlgoWCSandow Auto
{Sandow++ Behavior}
DM_SandowPP_AlgoWCPumping Property AlgoWCPumping Auto
{Pumping Iron Behavior}

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

; TODO: Delete
DM_SandowPP_PresetManager _presetManager
; DM_SandowPP_Report _report
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

bool _t = false

Event OnKeyDown(Int KeyCode)
    If KeyCode == solveInt(GetMCMConfig(), ".widget.hotkey", -1)
        ReportWidget.Visible = !ReportWidget.Visible
    EndIf
    If KeyCode == 200
        ; texMngr.Debug(Player)
        ; TestSave(38)
        ; ReportWidget.Visible = !ReportWidget.Visible
    EndIf
EndEvent

Event OnInit()
    OpenLog()
    Trace("$Gen_Init")
    ResetVariables()
    RegisterForSleep()
    RegisterEvents()
    _InitSequence()

    ; Config.PresetManager = DefaultPresetManager()
    ; ; Load preset #1 if it exists. This was done to save the player time.
    ; If PresetManager.ProfileExists(1)
    ;     Config.Assign( PresetManager.LoadFile(1) )
    ;     RegisterAgainHotkeys()
    ; EndIf
EndEvent


int _bulkCutDays = 0
; DM_SandowPP_RippedPlayer _rippedPlayer
; DM_SandowPP_RippedAlphaCalcPlayer _rippedPlayerAlpha
Function CalcPlayerRippedness()
    {Calculate muscular definition settings for player.}
    ; If _rippedPlayer.bulkCut
    ;         ; SwapBulkCut()
    ; Else
    ;     ;  Simple muscle def. options
    ;     Trace("Simple muscle def")
    ;     If !(_rippedPlayerAlpha.MethodIsNone() || _rippedPlayerAlpha.MethodIsBehavior())
    ;         ; Reapply texture because some actions can clean it
    ;         texMngr.InitializeActor(Player)
    ;     EndIf
    ; EndIf
EndFunction

Function SwapBulkCut()
    {Swap bulkin and cutting behaviors.}
    ; _bulkCutDays += 1
    ; If _bulkCutDays >= _rippedPlayer.bulkCutDays
    ;     _bulkCutDays = 0
    ;     Debug.Notification("$RippedNotiBulk")
    ;     Debug.Notification("$RippedNotiCut")
    ; EndIf
EndFunction

Function PrepareAlgorithmData()
    { Algorithms need data to function properly. This method properly points to that data. }
    ; AlgorithmData.CurrentState = CurrentState
    ; AlgorithmData.Config = Config
    ; AlgorithmData.Report = Report
EndFunction

; Setup things again after reloading a save. Mostly registering events again.
Function OnGameReload()
    If !Initialized
        Trace("Trying to reload without having initialized")
        return
    EndIf
    OpenLog()
    Trace("Reloading a saved game")
    InitVars()
    RegisterAgainHotkeys()
    RegisterEvents()
    HeightChanger.ReapplyHeight()
    RegisterForKey(200)
    _LoadAddons()
    _LoadDefaults()
    ; Since switching to Lua, we need to do this. Don't know why.
    ReportWidget.EnsureVisibility()
    ; texMngr.Debug(Player)
EndFunction

;>=========================================================
;>===                       v4.0                        ===
;>=========================================================

    string Property mainDir =   "Data/SKSE/Plugins/Sandow Plus Plus/" AutoReadOnly Hidden
    string Property cfgDir  =   "config/" Auto
    string Property jDBRoot =   "sandow++" AutoReadOnly Hidden

    ;region: Initialization
        bool property Initialized = false Auto
        Function _InitSequence()
            ; If Initialized
            ;     return
            ; EndIf
            _Pause()
            _InitVars40()
            _InitDataTree()
            _LoadAddons()
            _LoadDefaults()
            ; FIXME: Delete this ------------------------------------------------
            Utility.Wait(1)
            ; FIXME: ------------------------------------------------------------
            _Resume()
            ; ReportWidget.Visible = false
            ; FIXME: Delete this ------------------------------------------------
            ReportWidget.Visible = true
            ; FIXME: ------------------------------------------------------------
            Initialized = true
            Trace("Finished initializing")
            MiscUtil.PrintConsole("[Sandow Plus Plus]: Finished initializing")
            ; FIXME: Delete this ------------------------------------------------
            texMngr.MakePlayerRipped()
        EndFunction

        Function _InitVars40()
            ; Init paths
            cfgDir = mainDir + "config/"
        EndFunction

        ; Loads a premade data tree so it's easier to fill it in Lua.
            ; The file is "Data/SKSE/Plugins/Sandow Plus Plus/config/bare tree.json".
            ;
            ; That premade file contains the overall data structure for this mod.
        Function _InitDataTree()
            UpdateDataTree(JValue.readFromFile(cfgDir + "bare tree.json"))
        EndFunction

        Function _LoadDefaults()
            ExecuteLua("return sandowpp.getDefaults(jobject)")
            texMngr.InitData()
        EndFunction

        ; Creates the addon data tree in memory, so this mod can be used.
        Function _LoadAddons()
            UpdateDataTree(JValue.evalLuaObj(GetDataTree(), "return sandowpp.installAddons(jobject)"))
        EndFunction

    ; Gets the handle for the whole data tree.
        ; Look at "bare tree.json" to see which structure this function will return.
        ;
        ; This data tree is passed around by this scipt to make the mod work.
        ; Whenever you see a variable named "data" in Lua, it refers to this tree.
    int Function GetDataTree()
        return JDB.solveObj("." + jDBRoot)
    EndFunction

    int Function GetMCMConfig()
        return JValue.solveObj(GetDataTree(), ".preset")
    EndFunction

    Function SavePreset(string fname)
        JValue.writeToFile(GetMCMConfig(), JContainers.userDirectory() + fname + ".json")
    EndFunction

    Function UpdateDataTree(int data)
        JDB.setObj(jDBRoot, data)
    EndFunction

    Function TestSave(int f = 1)
        JValue.writeToFile(GetDataTree(), JContainers.userDirectory() + "spp" + f + ".json")
    EndFunction

; Adds WGP/training and fatigue.
Function TrainSkill(string aSkill)
    ExecuteLua("return sandowpp.train(jobject, '" + aSkill + "')")
    RealTimeCalculations()
EndFunction

; Trains bypassing skill checks. Use it for things that directly set
; training/fatigue, like weight sacks or SexLab.
Function Train(float training, float fatigue)
    ExecuteLua("return sandowpp.trainAndFatigue(jobject, " + \
        training + ", " + \
        fatigue + ")"\
    )
    RealTimeCalculations()
EndFunction

Function RealTimeCalculations()
    _PapyrusToLuaState()
    ExecuteLua("return sandowpp.realTimeCalc(jobject)")
    ExecuteLua("return sandowpp.onReport(jobject)")
    ReportWidget.Report(GetDataTree())
EndFunction

Function UpdateMcmData()
    _PapyrusToLuaState()
    ExecuteLua("return sandowpp.getMcmData(jobject)")
EndFunction

; Gets the data tree and sends it to some Lua function, then updates data tree.
Function ExecuteLua(string str)
    ;@Hint: It's QUITE important to not let a function accidentally clear the data tree.
    int t = JValue.evalLuaObj(GetDataTree(), str)
    If t == 0 || JValue.empty(t)
        _LogAndShowLuaExecErrors(str)
        return
    EndIf
    UpdateDataTree(t)
EndFunction

Function _LogAndShowLuaExecErrors(string cmd)
    string s = "ExecuteLua('" + cmd + "'): returns an empty data tree."
    string s2 = "***ERROR*** " + s
    Trace(s2, 2)
    Debug.TraceStack(s2, 2)
    Debug.MessageBox("Sandow Plus Plus\n" + s + "\nPlease contact this mod's author.")
EndFunction

; Saves current player variables so they can be processed by Lua.
Function _PapyrusToLuaState()
    string s = ".state."
    int data = GetDataTree()
    float ls = GetLastSlept(data)
    float la = GetLastActive(data)
    JValue.solveFltSetter(data, s + "weight", GetPlayerWeight())
    JValue.solveFltSetter(data, s + "hoursAwaken", HourSpan(ls))
    JValue.solveFltSetter(data, s + "hoursInactive", HourSpan(la))
    _SetDecay()
    UpdateDataTree(data)
EndFunction

; Sets a `decay` multiplier.
;
; @param ratio - Ratio for the decay multiplier. Use it to decay less when
; sleeping and shit.
;
; Decay multiplier is used for behaviors that constantly drain resources based
; on time, like Pumping Iron degrading WGP all the time or Bruce Lee degrading
; training after some inactivity time.
Function _SetDecay(float ratio = 1.0)
    int data = GetDataTree()
    float ld = GetLastDecay(data)
    string s = ".state."
    JValue.solveFltSetter(data, s + "decay", (Now() - ld) * ratio)
    JValue.solveFltSetter(data, s + "lastDecay", Now())
EndFunction

; Returns player weight. Weight ∈ [0, 100]
float Function GetPlayerWeight()
    return Player.GetActorBase().GetWeight()
EndFunction

; Avoids a bug when creating a new game when this mod seems to be initialized way
; before the current date.
; If not for this check, player would get they haven't slept for 3000 hours or so
; the first time they play the game.
float Function GetLastSlept(int data)
    ; Behaviors are the ones that change this value.
    return EnsureTime(data, ".state.lastSlept")
EndFunction

float Function GetLastActive(int data)
    ; This value is changed by anything that changes activity.
    return EnsureTime(data, ".state.lastActive")
EndFunction

float Function GetLastDecay(int data)
    return EnsureTime(data, ".state.lastDecay")
EndFunction

; If an expected time is -1, sets it to now.
float Function EnsureTime(int data, string path)
    float ls = JValue.solveFlt(data, path, -1)
    If ls < 0
        ls = Now()
        JValue.solveFltSetter(data, path, ls, true)
    EndIf
    return ls
EndFunction

; Retuns in real hours how much time has passed between two game hours.
float Function HourSpan(float then)
    Return ToRealHours(Now() - then)
EndFunction

    ;region: Sleeping
        ; Being in animation (from Posers or something) while sleeping seems to freeze the game. Avoid it.
        Function PreparePlayerToSleep()
            If Player.IsWeaponDrawn()
                Player.SheatheWeapon()
            EndIf
            _PapyrusToLuaState()
        EndFunction

        Function SetHoursSlept(float hoursSlept)
            int data = GetDataTree()
            JValue.solveFltSetter(data, ".state.hoursSlept", hoursSlept, true)
            UpdateDataTree(data)
        EndFunction

        ; Prepare player to sleep. Setup sleeping time and total hours awaken.
        Event OnSleepStart(float aStartTime, float aEndTime)
            _Pause()
            PreparePlayerToSleep()
            _goneToSleepAt = Now()                        ; Just went to sleep
        endEvent

        ; Main calculation. This is the core of this mod.
        Event OnSleepStop(bool aInterrupted)
            ; Hours actually slept, since player can cancel or Astrid can kidnap.
            float hoursSlept = HourSpan(_goneToSleepAt)
            If hoursSlept < 1
                Return      ; Do nothing if didn't really slept
            EndIf
            SetHoursSlept(hoursSlept)
            _SetDecay(0.6)
            ExecuteLua("return sandowpp.onSleep(jobject)")
            _SleepPostprocess()
            RealTimeCalculations()
            _Resume()
        endEvent

        Function _SleepPostprocess()
            texMngr.MakePlayerRipped()
            ChangeHeadSize()
        EndFunction

; Registers a new hotkey.
Function RegisterHotkey(int aOldKey, int aNewKey)
    ; Trace("Main.RegisterHotkey(" + aOldKey + ", " + aNewKey + ")")
    UnRegisterForKey(aOldKey)
    RegisterForKey(aNewKey)
EndFunction

;>========================================================
;>===                 UPDATING CICLE                 ===<;
;>========================================================

int _cycle = 0

; Advances cycle by one.
;       _cycle ∈ [0, 59]
; 60 is the upper limit so modulo calculations don't get too slow with larger numbers.
Function _AdvCycle()
    _cycle = (_cycle + 1) % 60
EndFunction

; Tells if current cycle is divisible by some number.
; Cycle is compared from [1, 60] because 60 it's divisible by many numbers.
bool Function _IsNthCycle(int num)
    return (_cycle + 1) % num == 0
EndFunction

Function _Loop()
    RegisterForSingleUpdate(solveFlt(GetMCMConfig(), ".widget.refreshRate", 5))
EndFunction

State Running
    Event OnUpdate()
        RealTimeCalculations()
        _AdvCycle()
        _Loop()
    EndEvent
EndState

Event OnUpdate()
    UnregisterForUpdate()
EndEvent

Function _Pause()
    UnregisterForUpdate()
    GotoState("Paused")
EndFunction

Function _Resume()
    GotoState("Running")
    _Loop()
EndFunction

;>=========================================================
;>===                       END                         ===
;>=========================================================

Function InitVars()
    Config.Owner = Self         ; For some reason, Config.Owner refuses to stay as configured in the CK
    ; _rippedPlayer = texMngr.PlayerSettings
    ; _rippedPlayerAlpha = (_rippedPlayer as Form) as DM_SandowPP_RippedAlphaCalcPlayer
EndFunction

; Sexlab integration.
Event SexLabEnter(string eventName, string argString, float argNum, form sender)
    sslThreadController c = sender as sslThreadController
    If c && c.HasPlayer
        Debug.MessageBox("Player is having sex")
        Train(0, 0)
    EndIf
EndEvent

; Register all events needed for this to work.
Function RegisterEvents()
    HeightChanger.RegisterEvents()
    If SexLabExists()
        RegisterForModEvent("AnimationStart", "SexLabEnter")
    EndIf
EndFunction

Function Configure()
    { Configure data after using the MCM or reloading a preset. This method is called by the Config script/object belonging to this script }
    ; Trace("Main.Configure()")
    ; PrepareAlgorithmData()
    ; ChangeAlgorithm()
EndFunction


Function ChangeAlgorithm()
    ; { Change mod Behavior }
    ; Trace("Main.ChangeAlgorithm(" + Config.Behavior + ")")
    ; Trace("Current: " + Algorithm.Signature())
    ; DM_SandowPP_Algorithm newAlgo
    ; If Config.IsPumpingIron()
    ;     newAlgo = AlgoWCPumping
    ; ElseIf Config.IsPaused()
    ;     newAlgo = AlgoPause
    ; ElseIf Config.IsBruce()
    ;     Trace("Is Bruce " + Config.bhBruce)
    ;     ; newAlgo = AlgoBFBruce
    ; Else
    ;     newAlgo = AlgoWCSandow
    ; EndIf
    ; Trace("Expected: " + newAlgo.Signature())

    ; ; Change only if switched algorithms
    ; If _algorithm.Signature() != newAlgo.Signature()
    ;     Trace("Switching algorithms")
    ;     _algorithm.OnExitAlgorithm(AlgorithmData)
    ;     _algorithm = newAlgo
    ;     _algorithm.OnEnterAlgorithm(AlgorithmData)
    ; EndIf
    ; Trace("Ending Main.ChangeAlgorithm()")
EndFunction

; Registers again events for hotkeys that have already been set up.
Function RegisterAgainHotkeys()
    RegisterAgainHotkey(JValue.solveInt(GetMCMConfig(), ".widget.hotkey", -1))
EndFunction

Function RegisterAgainHotkey(int oldKey)
    { Registers again events for ONE hotkey that have already been set up }
    ; Trace("Main.RegisterAgainHotkey(oldKey = " + oldKey + ")")

    if oldKey != -1
        RegisterForKey(oldKey)
    EndIf
EndFunction

; ########################################################################
; Private functions. These are designed to be used only within   LeveledItem
; this script. Never call them from the outside.
; ########################################################################

Function ResetVariables()
    Config.HkShowStatus = Config.hotkeyInvalid
    ; _algorithm = AlgoWCSandow
    ; Config.Owner = Self
    ; _report = ReportDebug
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
