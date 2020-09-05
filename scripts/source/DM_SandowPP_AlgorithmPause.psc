Scriptname DM_SandowPP_AlgorithmPause extends DM_SandowPP_Algorithm
{ Pauses the whole system }
Import DM_SandowPP_Globals
Import DM_Utils

float _restoredInactivity
float _restoredSleeptime
float _anabolics

string Function Signature()
    return "$MCM_PausedBehavior"
EndFunction

Function OnEnterAlgorithm(DM_SandowPP_AlgorithmData aData)
    {Initial setup when switching to this algorithm}
    SetupWidget(aData)
    Trace("*** Player switched to Paused ***")
    ; Store current lack of training and last slept time, so it can be restored later
    _restoredInactivity = Now() - aData.CurrentState.LastSkillGainTime
    _restoredSleeptime = Now() - aData.CurrentState.LastSlept
    _anabolics = aData.CurrentState.WeightGainMultiplier

    ; TODO: Store hunger state
EndFunction

Function OnExitAlgorithm(DM_SandowPP_AlgorithmData aData)
    {Do things when getting out from this}
    Trace("*** Exiting Paused algorithm ***")
    ; Restore things
    aData.CurrentState.LastSkillGainTime = Now() - _restoredInactivity
    aData.CurrentState.LastSlept = Now() - _restoredSleeptime
    aData.CurrentState.WeightGainMultiplier = _anabolics
EndFunction

bool Function CanGainWGP()
    return false
EndFunction

Function SetupWidget(DM_SandowPP_AlgorithmData aData)
    {Needed to be overrided by descendants if they want to support widget reporting}
    SetupCommonWidget(aData, aData.Report.mcFatigue)
EndFunction

Function ReportEssentials(DM_SandowPP_AlgorithmData aData)
    {Bare minimum data useful for the player. Used for widgets and such.}
    ; To be compatible, a Report.Notification() must send whole data.
    DM_SandowPP_Report r = aData.Report
    ReportBlank(r.mcWeight, aData)
    ReportBlank(r.mcWGP, aData)
    ReportBlank(r.mcFatigue, aData)
    ReportBlank(r.mcInactivity, aData)
EndFunction

Function ReportBlank(int msgCat, DM_SandowPP_AlgorithmData aData)
    RArg.Set("$AlgoPausedMessage", aData.Report.mtDefault)
    RArg.CatVal(msgCat, 0.0)
    aData.Report.Notification(RArg)
EndFunction

DM_SandowPP_State Function OnSleep(DM_SandowPP_AlgorithmData aData)
    {Does something on the player when they go to sleep.}
    Result.Assign(aData.CurrentState)
    return Result      ; Always return this Property
EndFunction

Function ReportOnHotkey(DM_SandowPP_AlgorithmData aData)
    {Reports things on demand}
    aData.Report.OnHotkeyReport(Self)
    ReportEssentials(aData)
EndFunction

Function ReportSleep(DM_SandowPP_AlgorithmData aData)
    {Reports things after done sleeping}
    ReportBlank(aData.Report.mcWeight, aData)
EndFunction

Function ReportSkillLvlUp(DM_SandowPP_AlgorithmData aData)
    {Reports things at skill level up}
    ReportBlank(aData.Report.mcWGP, aData)
EndFunction

string Function GetMCMCustomData1(DM_SandowPP_AlgorithmData aData)
    Return "$AlgoPausedMessage"
EndFunction

string Function GetMCMCustomInfo1(DM_SandowPP_AlgorithmData aData)
    Return "$MCM_AlgoPauseInfo"
EndFunction

string Function MCMInfo()
    Return "$MCM_BehaviorInfoPaused"
EndFunction

string Function GetMcmMainStatLabel()
    return "$Weight:"
EndFunction

string Function GetMcmMainStat()
    return FloatToStr(GetPlayerWeight())
EndFunction
