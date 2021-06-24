Scriptname DM_SandowPP_AlgoWCSandow extends DM_SandowPP_AlgorithmWeightChange
{ The traditional Sandow Plus Plus algorithm. It's all about fatigue management }

import DM_Utils
import Math
Import DM_SandowPP_Globals

; ########################################################################
; DO NOT CHANGE. Calculated constants. Needed for this
; script to properly work.
; ########################################################################
float property CatabolicThreshold
    float function get()
        Return FatigueCatabolicHours * FatigueHourlyRate
    endFunction
endProperty
float property TrainLossThreshold
  float function get()
    return FatigueTrainLossHours * FatigueHourlyRate
  endFunction
endProperty

float property NeedSleepThreshold
    {From having been these hours awaken and on, you'll get the "You NEED TO SLEEP" kind of messages.}
    float function get()
        Return FatigueNeedSleepHours * FatigueHourlyRate
    endFunction
endProperty

float property FatigueClamp
    {Min hours needed to get full growing benefits}
    float function get()
        Return FatigueNeedSleepHours * FatigueHourlyRate
    endFunction
endProperty
; ########################################################################

; Don't change these constants, lest you want to break this mod's balance
float FatigueHourlyRate = 0.1       ; Any operation involvig this constant expects a real hour, not a game hour
int FatigueNeedSleepHours = 14
int FatigueTrainLossHours = 18
int FatigueCatabolicHours = 20
float FatigueCatabolicRate = 1.2
float SleepRestRatioHours = 1.5
float WeightLossRate = -0.01
float LossesRateByInactivity = 0.025
float TrainingLossRate = 0.01
float ReboundWeightRatio = 2.5
float SuperCompensationRatio = 1.5

float _maxWeight            ; Used for rebound

string Function Signature()
    return "Sandow Plus Plus"
EndFunction

DM_SandowPP_State Function OnSleep(DM_SandowPP_AlgorithmData aData)
    ; Result.WGP -= LoseWGPBecauseOfFatigue(currFatigue, aData)
    ; Result.WGP -= GrowOrShrink(currFatigue, aData)
    ; ChangeFatigue(Result)
    Return Result      ;Always return this Property
EndFunction

float Function LoseWGPBecauseOfFatigue(float aFatigue, DM_SandowPP_AlgorithmData aData)
    Return 0.0
EndFunction

float Function GrowOrShrink(float aFatigue, DM_SandowPP_AlgorithmData aData)
    {Returns how much WGP was lost}
    ; bool weightLost = LossesByInactivity(aData)
    
    ; if aFatigue >= CatabolicThreshold
    ;     If aData.Config.CanLoseWeight
    ;         ChangeWeight(aFatigue * WeightLossRate, aData)
    ;     EndIf
    ;     Return 0.0
    ; EndIf
    
    ; If GetPlayerWeight() >= 100.0 || weightLost      ; Already at max weight, don't substract WGP
    ;     Return 0.0
    ; EndIf
    ; If aData.CurrentState.WGP > 0.0
    ;     Return Grow(aFatigue, aData)
    ; EndIf
EndFunction

float Function Grow(float aFatigue, DM_SandowPP_AlgorithmData aData)
    {Grow based on hours slept and fatigue}
    ; float f = MinF(aFatigue, FatigueClamp) / FatigueClamp
    ; ; float t = MinF(aData.CurrentState.HoursSlept, SleepFullRestHours()) / SleepFullRestHours()
    ; float t = CappedSleepingTime(aData) / SleepFullRestHours()
    ; float takeWGP = MinF(f * t, Result.WGP)
    ; ChangeWeight( CalculateWeightGain(takeWGP, aData.Config), aData )
    ; _maxWeight = GetPlayerWeight()
    ; return takeWGP
EndFunction

float Function CalculateWeightGain(float takeWGP, DM_SandowPP_Config aConfig)
    {Main function to calculate how much weight the player will gain}
    float currW = GetPlayerWeight()
    float weightGain = takeWGP                  ; Normal weight gain
    weightGain = CalculateDiminishingReturns(weightGain, currW, aConfig.DiminishingReturns)
    weightGain = CalculateRebound(weightGain, currW, aConfig.CanReboundWeight)
    weightGain = CalculateHunger(weightGain, aConfig.HungerAffectsGains)
    Return weightGain
EndFunction

float Function CalculateDiminishingReturns(float weightGain, float currW, bool aDiminish)
    if aDiminish
        Return DiminishingRatio(currW / 100.0) * weightGain
    EndIf
    Return weightGain
EndFunction

float Function CalculateRebound(float weightGain, float currW, bool aRebound)
    {Calculate how much weight player will gain when rebound}
    If aRebound
        ; Gain more weight if expected weight is lower than historical max
        float hypotheticW = ConstrainF(currW + weightGain, minW, maxW)
        If hypotheticW <= _maxWeight
            ; Player already had this weight
            weightGain = weightGain * ReboundWeightRatio

            ; Adjust gains so new gains are as expected and not multiplied
            hypotheticW = ConstrainF(currW + weightGain, minW, maxW)
            if hypotheticW > _maxWeight
                float newGainz = hypotheticW - _maxWeight
                weightGain -= newGainz
                ; Simulate supercompensation
                newGainz = (newGainz / ReboundWeightRatio) * SuperCompensationRatio
                weightGain += newGainz
            EndIf
        EndIf
    EndIf
    Return weightGain
EndFunction

Function ChangeFatigue(DM_SandowPP_State aState)
    {Calculate how much Fatigue player will have after sleeping}
    if aState.HoursSlept >= SleepFullRestHours()
        FullRest(aState)
    Else
        PartialRest(aState)
    EndIf
EndFunction

Function FullRest(DM_SandowPP_State aState)
    {Reset fatigue because player did a full rest}
    aState.SkillFatigue = 0
    aState.LastSlept = Now()
EndFunction

Function PartialRest(DM_SandowPP_State aState)
    {Simulate partial rest by advancing the last time the player slept}

    ; We need to add HoursSlept because time has passed since the player wanted to sleep. DO NOT CHANGE THIS.
    float restHours = (aState.HoursSlept * SleepRestRatioHours) + aState.HoursSlept
    restHours = ToGameHours(restHours)
    aState.LastSlept = MinF(aState.LastSlept + restHours, Now())

    ; SkillFatigue is impervious to time because it never depends on it. No need to make complex calculations.
    restHours = aState.HoursSlept * FatigueHourlyRate * SleepRestRatioHours
    aState.SkillFatigue -= restHours
EndFunction


float Function FatigueFromState(DM_SandowPP_State aState)
    {Returns the Fatigue calculated from a state; mostly current state, but sometimes a former state}
    ; Return Fatigue(aState.HoursAwakenRT(), aState.SkillFatigue)
EndFunction

; ########################################################################
; Report functions.
; ########################################################################
Function ReportEssentials(DM_SandowPP_AlgorithmData aData)
    {Bare minimum data useful for the player. Used for widgets and such.}
    ; To be compatible, a Report.Notification() must send whole data.
    ReportWeight(aData)
    ReportWGP(aData)
    ReportFatigue(aData)
    ReportInactivity(aData)
EndFunction

Function ReportState(DM_SandowPP_AlgorithmData aData)
    {"YOU NEED TO SLEEP" kind of reports}
    ; float fatigue = FatigueFromState(aData.CurrentState)
    ; string s = GetSleepFatigueState(fatigue, aData.Config.CanLoseWeight)
    ; RArg.Set(s, GetFatigueMsgType(fatigue, aData.Report))
    ; aData.Report.Notification(RArg)
EndFunction

Function ReportFatigue(DM_SandowPP_AlgorithmData aData)
    ; float fatigue = FatigueFromState(aData.CurrentState)
    ; int msgType = GetFatigueMsgType(fatigue, aData.Report)
    ; string asPercent = FatigueAsPercent(fatigue)
    ; RArg.Set("$ReportFatigue{" + asPercent + "}", msgType)
    ; RArg.CatVal(aData.Report.mcFatigue, PercentToFloat( FatigueAsPercentF(fatigue) ))
    ; aData.Report.Notification(RArg)
EndFunction

Function ReportSleep(DM_SandowPP_AlgorithmData aData)
    {Report these things after sleeping}
    ReportFatigue(aData)
    ReportState(aData)
    ReportInactivity(aData)
EndFunction

Function ReportOnHotkey(DM_SandowPP_AlgorithmData aData)
    ; {Things to report on demand}
    ; Parent.ReportOnHotkey(aData)
    ; ReportWGP(aData)
    ; ReportWeight(aData)
    ; ReportFatigue(aData)
    ; if aData.Config.VerboseMod
    ;     ReportState(aData)
    ; EndIf
    ; ReportInactivity(aData)
EndFunction

Function ReportSkillLvlUp(DM_SandowPP_AlgorithmData aData)
    {What to report on skill level up}
    ReportFatigue(aData)
    ReportState(aData)
EndFunction

string Function GetSleepFatigueState(float aFatigue, bool aCanLoseWeight)
    {"YOU NEED TO SLEEP" kind of reports}
    if aFatigue < NeedSleepThreshold
        Return "$ReportFatigueStrNormal"
    elseif aFatigue < TrainLossThreshold
        Return "$ReportFatigueStrWarn"
    elseif aFatigue < CatabolicThreshold
        Return "$ReportFatigueStrDanger"
    else
        if aCanLoseWeight
            Return "$ReportFatigueStrCritLose"
        else
            Return  "$ReportFatigueStrCritNoLose"
        EndIf
    EndIf
EndFunction

; int Function GetFatigueMsgType(float aFatigue, DM_SandowPP_Report aReport)
;     {Urgency of the state report. Used for determine color of the message}
;     If aFatigue < NeedSleepThreshold
;         Return aReport.mtDefault
;     ElseIf aFatigue < TrainLossThreshold
;         Return aReport.mtWarning
;     ElseIf aFatigue < CatabolicThreshold
;         Return aReport.mtDanger
;     Else
;         Return aReport.mtCritical
;     EndIf
; EndFunction

string Function FatigueAsString(DM_SandowPP_State aState)
    {Used to directly get a string for a Fatigue calculation given some State}
    float fatigue = FatigueFromState(aState)
    Return FatigueAsPercent(fatigue)
EndFunction

float Function FatigueAsPercentF(float x)
    {Mostly used for reporting current fatigue in the MCM and UI reports}
    Return (x * 100) / CatabolicThreshold
EndFunction

string Function FatigueAsPercent(float x, int precision = 2)
    {Mostly used for reporting current fatigue in the MCM and UI reports}
    ;    float p = (x * 100) / CatabolicThreshold
    Return FloatToStr(FatigueAsPercentF(x), precision)
EndFunction

; ########################################################################
; Public MCM functions
; ########################################################################

string Function GetMCMCustomData1(DM_SandowPP_AlgorithmData aData)
    {Used for the MCM}
    ; Return FatigueAsString(aData.CurrentState) + "%"
EndFunction

string Function GetMCMCustomLabel1(DM_SandowPP_AlgorithmData aData)
    {Used for the MCM}
    Return "$Fatigue:"
EndFunction

string Function GetMCMCustomInfo1(DM_SandowPP_AlgorithmData aData)
    {Used for the MCM}
    Return "$MCM_FatigueInfo{" + FatigueAsPercent(TrainLossThreshold, -1) + "}{" + FatigueAsPercent(CatabolicThreshold, -1) + "}"
EndFunction

string Function GetMCMStatus(DM_SandowPP_AlgorithmData aData)
    ; {Used for the MCM}
    ; float fatigue = FatigueFromState(aData.CurrentState)
    ; Return GetSleepFatigueState(fatigue, aData.Config.CanLoseWeight)
EndFunction

string Function MCMInfo()
    Return "$MCM_BehaviorInfoSandow"
EndFunction

; ########################################################################
; Protected overridable functions.
; ########################################################################
Function OnEnterAlgorithm(DM_SandowPP_AlgorithmData aData)
    {Extra setup needed when switching to Sandow++}
    ; Trace("*** Player switched to Sandow++ ***")
    ; Parent.OnEnterAlgorithm(aData)
    ; aData.Config.skillsLocked = False        ; Player is free to change gains by skill
EndFunction

; ########################################################################
; Public overridable functions. NEEDED to be implemented by descendants
; ########################################################################

; ########################################################################
; Protected overridable functions. NEEDED to be implemented by descendants
; ########################################################################
;@Override:
; Hours allowed before considering being inactive and starting to lose muscle because of that.
float Function InactivityHoursToLoses()
    Return 72.0
EndFunction

Function SetupWidget(DM_SandowPP_AlgorithmData aData)
    {Needed to be overrided by descendants if they want to support widget reporting}
    ; Trace("Sandow.SetupWidget()")
    ; SetupCommonWidget(aData, aData.Report.mcFatigue)
EndFunction
