Scriptname DM_SandowPP_AlgoWCPumping extends DM_SandowPP_AlgorithmWeightChange
{ The Pumping Iron algorithm. It's all about timed sleep sessions }

Import DM_Utils
Import DM_SandowPP_Globals

int _sleepHoursDelay = 12
float _WGPDailyDecayRate = 0.1
float _WGPToMuscleBySleptHour = 0.1
float _WeightLossRatio = -0.01
float _lastTimeWGPQuery

string Function Signature()
    return "Pumping Iron"
EndFunction

DM_SandowPP_State Function OnSleep(DM_SandowPP_AlgorithmData aData)
    {Core calculation}
    Result.Assign(aData.CurrentState)

    Trace("===== Pumping.OnSleep() =====")
    Result.TraceAll()

    If Result.HoursAwaken < _sleepHoursDelay
        Trace("===== Ending Pumping.OnSleep() =====")
        Return Result
    EndIf
    WGPDecay(Result)
    GrowOrShrink(aData)
    Result.LastSlept = Now()

    Result.TraceAll()
    Trace("===== Ending Pumping.OnSleep() =====")
    Return Result      ;Always return this Property
EndFunction

Function GrowOrShrink(DM_SandowPP_AlgorithmData aData)
    {In 2.0, the only way to lose weight is by inactivity}
    If aData.Config.CanLoseWeight
        float inactivityTime = HoursInactive(Result.LastSkillGainTime) - aData.CurrentState.HoursSlept
        If inactivityTime >= InactivityHoursToLoses()
            Shrink(inactivityTime, aData)
            Return
        EndIf
    EndIf
    If GetPlayerWeight() < 100.0 && Result.WGP > 0.0
        Grow(aData)
    EndIf
EndFunction

Function Shrink(float inactivityTime, DM_SandowPP_AlgorithmData aData)
    {Once you enter in inactivity state, you lose weight for each pasing hour without training}
    float ratio = ToGameHours(inactivityTime) * _WeightLossRatio

    Trace("Pumping.Shrink(" + inactivityTime + ")")
    Trace("Ratio = " + ratio)

    ChangeWeight(GetPlayerWeight() * _WeightLossRatio, aData)
EndFunction

Function Grow(DM_SandowPP_AlgorithmData aData)
    {Weight gain is a straight forward WGP conversion}
    float weightGain = GetGains()
    Result.WGP -= weightGain
    weightGain = CalculateHunger(weightGain, aData.Config.HungerAffectsGains)
    weightGain = DiminishingReturns(weightGain, aData)
    ChangeWeight(weightGain, aData)
EndFunction

float Function DiminishingReturns(float gain, DM_SandowPP_AlgorithmData aData)
    If aData.Config.DiminishingReturns
        return DiminishingRatio(GetPlayerWeight()) * gain
    EndIf
    return gain
EndFunction

float Function GetGains()
    {Gains are based on hours slept}
    float h = MinF(Result.HoursSlept, SleepFullRestHours())
    Return MinF(h * _WGPToMuscleBySleptHour, Result.WGP)
EndFunction

Function WGPDecay(DM_SandowPP_State aState)
    {WGP is always decaying}
    Trace("Pumping.WGPDecay()")

    float decayVal
    if _lastTimeWGPQuery > 0.0
        float time = Now() - _lastTimeWGPQuery
        decayVal = aState.WGP * _WGPDailyDecayRate * time
        aState.WGP -= decayVal
    EndIf
    _lastTimeWGPQuery = Now()

    Trace("decayVal = " + decayVal)
EndFunction

; ########################################################################
; Report functions.
; ########################################################################
Function ReportEssentials(DM_SandowPP_AlgorithmData aData)
    {Bare minimum data useful for the player. Used for widgets and such.}
    ; To be compatible, a Report.Notification() must send whole data.
    ReportWeight(aData)
    ReportWGP(aData)
    ReportNextSleep(aData)
    ReportInactivity(aData)
EndFunction

Function ReportOnHotkey(DM_SandowPP_AlgorithmData aData)
    {What to report on demand}
    Parent.ReportOnHotkey(aData)
    ReportWGP(aData)
    ReportWeight(aData)
    ReportInactivity(aData)
    If aData.Config.VerboseMod
        ReportNextSleep(aData)
    EndIf
EndFunction

Function ReportSleep(DM_SandowPP_AlgorithmData aData)
    {What to report after sleeping}
    ReportWGP(aData)
    ReportWeight(aData)
EndFunction

Function ReportSkillLvlUp(DM_SandowPP_AlgorithmData aData)
    {What to report on level up}
    ReportWGP(aData)
    ReportNextSleep(aData)
EndFunction

Function ReportWGP(DM_SandowPP_AlgorithmData aData)
    {Reporting WGP should be adjusted because you are always losing it}
    WGPDecay(aData.CurrentState)
    Parent.ReportWGP(aData)
EndFunction

; Report how many hours left before you can sleep again.
Function ReportNextSleep(DM_SandowPP_AlgorithmData aData)
    string status = GetNextSleepStatus(aData)
    int msgType
    If status == "$ReportPICanSleep"
        msgType = aData.Report.mtWarning
    Else
        msgType = aData.Report.mtDefault
    EndIf
    RArg.Set(status, msgType)
    RArg.CatVal(aData.Report.mcSleepHours, aData.CurrentState.HoursAwakenRT() / _sleepHoursDelay)
    aData.Report.Notification(RArg)
EndFunction

; ########################################################################
; Public MCM functions
; ########################################################################
string Function GetMCMStatus(DM_SandowPP_AlgorithmData aData)
    Return GetInactivityStatus(aData)
EndFunction

string Function GetMCMCustomData1(DM_SandowPP_AlgorithmData aData)
    Return GetNextSleepStatus(aData)
EndFunction

string Function GetNextSleepStatus(DM_SandowPP_AlgorithmData aData)
    float sleepIn = _sleepHoursDelay - aData.CurrentState.HoursAwakenRT()
    string s
    If sleepIn > 0
        s = "$ReportPINextSleep{" + FloatToHour(sleepIn) + "}"
    Else
        s = "$ReportPICanSleep"
    EndIf
    Return s
EndFunction

string Function MCMInfo()
    Return "$MCM_BehaviorInfoPumping"
EndFunction

; ########################################################################
; Protected overridable functions.
; ########################################################################
Function OnEnterAlgorithm(DM_SandowPP_AlgorithmData aData)
    {Need to calculate this so your WGP decays correctly when switching to Pumping Iron}
    Trace("*** Player switched to Pumping Iron ***")

    Parent.OnEnterAlgorithm(aData)
    aData.CurrentState.WGPGainType = aData.Report.mtDefault     ; No need to flash WGP loss, since you are always losing it
    _lastTimeWGPQuery = MaxF(aData.CurrentState.LastSlept, _lastTimeWGPQuery)
    Trace( "_lastTimeWGPQuery delta = " + (Now() - _lastTimeWGPQuery) )

    ; Reset to default and lock WGP gains because freely changing them in this Behavior would be free estate.
    aData.Config.DefaultSkills()
    aData.Config.skillsLocked = True
EndFunction

; ########################################################################
; Protected overridable functions. NEEDED to be implemented by descendants
; ########################################################################
float Function InactivityHoursToLoseMuscle()
    Return 42.0
EndFunction

Function SetupWidget(DM_SandowPP_AlgorithmData aData)
    {Needed to be overrided by descendants if they want to support widget reporting}
    Trace("Pumping.SetupWidget()")
    SetupCommonWidget(aData, aData.Report.mcSleepHours)
EndFunction
