Scriptname DM_SandowPP_Algorithm extends Quest Hidden
{Interface to implement algorithms that change the player in some way when they sleep.}

Import DM_SandowPP_Globals
import DM_Utils

Actor property Player auto
; DM_SandowPP_ReportArgs property RArg auto
DM_SandowPP_State property Result Auto

;@abstract:
; WARNING: REQUIRED. Used to differentiate between algorithms.
string Function Signature()
    return ""
EndFunction

; Initial setup when switching to this algorithm.
Function OnEnterAlgorithm(DM_SandowPP_AlgorithmData aData)
    SetupWidget(aData)
EndFunction

; Do things when getting out from this.
Function OnExitAlgorithm(DM_SandowPP_AlgorithmData aData)
EndFunction

float Function SleepFullRestHours()
    Return 10.0
EndFunction

bool Function CanGainWGP()
    return true
EndFunction

; Sets up the most common type of widget.
Function SetupCommonWidget(DM_SandowPP_AlgorithmData aData, int a3rdMeterEvt)
    ; DM_SandowPP_Report r = aData.Report
    ; r.Clear()
    ; r.RegisterMessageCategory(r.mcWeight, 0)
    ; r.RegisterMessageCategory(r.mcWGP, 1)
    ; r.RegisterMessageCategory(a3rdMeterEvt, 2)
    ; r.RegisterMessageCategory(r.mcInactivity, 3)
    ; r.HidePermanently(3, !aData.Config.CanLoseWeight)       ; Hide meter if <CanLoseWeight> is disabled
    ; r.HideNow(3, !aData.Config.CanLoseWeight)
EndFunction

; Needed to be overrided by descendants if they want to support widget reporting.
Function SetupWidget(DM_SandowPP_AlgorithmData aData)
EndFunction

; Bare minimum data useful for the player. Used for widgets and such.
Function ReportEssentials(DM_SandowPP_AlgorithmData aData)
    ; To be compatible, a Report.Notification() must send whole data.
EndFunction

; Does something on the player when they go to sleep.
DM_SandowPP_State Function OnSleep(DM_SandowPP_AlgorithmData aData)
    ; WARNING: Always return this Property
    return Result
EndFunction

; Reports things on demand.
Function ReportOnHotkey(DM_SandowPP_AlgorithmData aData)
    ; aData.Report.OnHotkeyReport(Self)
EndFunction

; Reports things after done sleeping.
Function ReportSleep(DM_SandowPP_AlgorithmData aData)
EndFunction

; Reports things at skill level up.
Function ReportSkillLvlUp(DM_SandowPP_AlgorithmData aData)
EndFunction

; Gets the label for the name of the stat this algorithm changes.
;
; Example:
; Weight changing algorithm will return "Weight:".
; Bodyfat may return "Muscle definition:".
string Function GetMcmMainStatLabel()
    return ""
EndFunction

; Gets the value of the stat this algorithm changes.
string Function GetMcmMainStat()
    return ""
EndFunction

; Shows your current state in the MCM.
string Function GetMCMStatus(DM_SandowPP_AlgorithmData aData)
    Return ""
EndFunction

; MCM Custom label functions.
string Function GetMCMCustomData1(DM_SandowPP_AlgorithmData aData)
    Return ""
EndFunction

string Function GetMCMCustomLabel1(DM_SandowPP_AlgorithmData aData)
    Return ""
EndFunction

string Function GetMCMCustomInfo1(DM_SandowPP_AlgorithmData aData)
    Return ""
EndFunction

string Function MCMInfo()
    Return "***ERROR***"
EndFunction

;@Virtual:
; How many hours without training before being penalized.
float Function InactivityHoursToLoses()
    Return 12.0
EndFunction

float Function InactivityHoursLeft(DM_SandowPP_AlgorithmData aData)
;     ; float inactivityTime = HoursInactive(aData.CurrentState.LastSkillGainTime)
;     ; Return InactivityHoursToLoses() - inactivityTime
EndFunction

float Function ReportInactivityPercentThreshold()
    Return InactivityHoursToLoses() * 0.3
EndFunction

float Function InactivityAsPercent(DM_SandowPP_AlgorithmData aData)
    ; Return HoursInactive(aData.CurrentState.LastSkillGainTime) / InactivityHoursToLoses()
EndFunction


;>=========================================================
;>===                     UTILITY                       ===
;>=========================================================

;> Utiliy functions used by descendants.

; Formula to calculate Diminishing Returns. [0.0, 1.0]. <x> can be Weight or muscle definition.
float Function DiminishingRatio(float x)
    ; Trace("DiminishingRatio(" + x + ")")
    Return 2.7786 * DM_Utils.Exp(-2.3 * x) + 0.2214
EndFunction

; Calculates raw gains by steroids.
float Function UseSteroids(float baseGain, DM_SandowPP_AlgorithmData aData)
    ; baseGain += aData.CurrentState.WeightGainBase           ; Gains even if sedentary
    ; baseGain *= aData.CurrentState.WeightGainMultiplier     ; Gains are multiplied
    ; ; Drops effect after use
    ; aData.CurrentState.WeightGainBase = 0.0
    ; aData.CurrentState.WeightGainMultiplier = 1.0
    return baseGain
EndFunction

; Returns player bodyweight [0..100].
float Function GetPlayerWeight()
    return Player.GetActorBase().GetWeight()
EndFunction

; Max time used for sleeping calculations
float Function CappedSleepingTime(DM_SandowPP_AlgorithmData aData)
    ; return MinF(aData.CurrentState.HoursSlept, SleepFullRestHours())
EndFunction

; Returns how many hours of inactivity have passed at the time of going to bed.
float Function HoursInactiveBeforeSleeping(DM_SandowPP_AlgorithmData aData)
    ; return HoursInactive(aData.CurrentState.LastSkillGainTime) - aData.CurrentState.HoursSlept
EndFunction

; Returns how many hours of inactivity have passed at the time of calling this function.
float Function HoursInactive(float aLastActive)
    Return ToRealHours(Now() - aLastActive)
EndFunction
