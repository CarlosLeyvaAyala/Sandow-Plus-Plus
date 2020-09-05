; You need to see https://docs.google.com/spreadsheets/d/1r10g-b73KjagmzT5Rm1SrWUY7ROhxtawBxy-vV4Yyms/edit?usp=drivesdk
;  to understand all formulas.

Scriptname DM_SandowPP_AlgorithmBodyfatBruce extends DM_SandowPP_AlgorithmBodyfatChange
{Makes the player more ripped by training.}

Import DM_Utils
Import DM_SandowPP_Globals
; Import Math

float _muscleDef = 0.0  ; Current muscle definition. [0.0, 1.0]
float _OldWGP = 0.0     ; This algorithm uses it's own implementation of WGP, save old to restore it when exiting it.
float _todaysTraining = 0.0     ; How much has the player trained today
float _training = 0.0           ; Current total training. Used to calculate muscle definition.
float _sleepToTrainingRatio = 0.1   ; How much will sleeping hours get converted to training.
float _maxAwakenHours = 20.0    ; Max hours allowed before penalization.

string Function Signature()
    return "Bruce Lee"
EndFunction

;>=========================================================
;>===                       CORE                        ===
;>=========================================================

;> Core calculations that make this behavior to work. Most of them are private.

;@Public:
; Does something on the player when they go to sleep.
DM_SandowPP_State Function OnSleep(DM_SandowPP_AlgorithmData aData)
    Result.Assign(aData.CurrentState)       ; Always assign this property
    Trace("===== Bruce.OnSleep() =====")
    Result.TraceAll()

    CalculateGainsOrLosses(aData)
    txMgr.InitPlayer()

    Result.TraceAll()
    Trace("===== Ending Bruce.OnSleep() =====")
    return Result
EndFunction

Function CalculateGainsOrLosses(DM_SandowPP_AlgorithmData aData)
    If CanLose(aData)
        CalculateLosses(aData)
    Else
        CalculateGains(aData)
    EndIf
EndFunction

Function CalculateGains(DM_SandowPP_AlgorithmData aData)
    aData.CurrentState.WGP = MinF(1.0, aData.CurrentState.WGP)
    _todaysTraining = aData.CurrentState.WGP * CappedSleepingTime(aData) * _sleepToTrainingRatio
    If aData.Config.DiminishingReturns
        _todaysTraining *= DiminishingRatio(GetBodyFat())
    EndIf
    aData.CurrentState.WGP = aData.CurrentState.WGP - _todaysTraining
    ;TODO: Multiplier for eating well.
    _training += UseSteroids(_todaysTraining, aData)
    ; Cap training at the max days to get plus sowe leeway
    _training = MinF(_training, txMgr.PlayerSettings.maxDaysToMax * 1.02)
EndFunction

;>=========================================================
;> Losses

;@Virtual:
; How many hours without training before being penalized.
float Function InactivityHoursToLoses()
    Return 24.0
EndFunction

Function CalculateLosses(DM_SandowPP_AlgorithmData aData)
    float losses = LossesByInactivity(aData)
    losses += LossesBySleep(aData)
    ; ;TODO: not eating properly
    losses *= WeightPenaltyModifier()
    _training -= losses
    _training = EnsurePositiveF(_training)
EndFunction

; The more you weight, the less harsh the penalty is (because muscles give
; you some room to caloric expenditure IRL.)
float Function WeightPenaltyModifier()
    return -0.2 * Exp(0.0153 * GetPlayerWeight()) + 0.122
EndFunction

; Loses are capped at a max of 16 points of training.
float Function LossesByInactivity(DM_SandowPP_AlgorithmData aData)
    float inactivity  = HoursInactiveBeforeSleeping(aData)
    If inactivity >= InactivityHoursToLoses()
        float res = 0.108 * Exp(0.052 * inactivity) + 0.15
        return MinF(res, 16.0)
    EndIf
    return 0.0
EndFunction

; Loses are capped at a max of 16 points of training.
float Function LossesBySleep(DM_SandowPP_AlgorithmData aData)
    float h = aData.CurrentState.HoursAwaken
    If h >= _maxAwakenHours
        If (h < _maxAwakenHours + 8)
            return h / 120.0        ; Light penalty
        Else
            return MinF(h / 100, 1.2)
        EndIf
    EndIf
    return 0
EndFunction

; Loses if sleeping to few or doing too little.
bool Function CanLose(DM_SandowPP_AlgorithmData aData)
    ; TODO: Lose for bad eating
    return (HoursInactiveBeforeSleeping(aData) >= InactivityHoursToLoses()) || (aData.CurrentState.HoursAwaken >= _maxAwakenHours)
EndFunction

;>=========================================================

;@Public Override:
; Tells the body fat levels this algorithm carries.
float Function GetBodyFat()
    Trace("Bruce.GetBodyFat()")
    float b = 0.02
    float a = (txMgr.PlayerSettings.maxDaysToMax - txMgr.PlayerSettings.minDaysToMax) / (Exp(100 * b) - 1)
    float c =  txMgr.PlayerSettings.minDaysToMax - a
    float trainingToGoal = a * Exp(b * GetPlayerWeight()) + c
    Trace("training = " + _training)
    Trace("trainingToGoal = " + trainingToGoal)
    return _training / trainingToGoal
EndFunction

;>=========================================================
;>===                      SETUP                        ===
;>=========================================================

; Backs up the old WGP because the one for this algorithm resets to 0 every day.
Function BackupOldWGP(DM_SandowPP_AlgorithmData aData)
    _OldWGP = aData.CurrentState.WGP
    aData.CurrentState.WGP = MinF(aData.CurrentState.WGP, 1.0)
    _todaysTraining = aData.CurrentState.WGP
EndFunction

; Restores the old WGP so other behaviors can continue as usual.
Function RestoreOldWGP(DM_SandowPP_AlgorithmData aData)
     aData.CurrentState.WGP = _OldWGP
EndFunction

;@Override:
; Initial setup when switching to this algorithm.
Function OnEnterAlgorithm(DM_SandowPP_AlgorithmData aData)
    parent.OnEnterAlgorithm(aData)
    BackupOldWGP(aData)
EndFunction

;@Override:
; Do things when getting out from this.
Function OnExitAlgorithm(DM_SandowPP_AlgorithmData aData)
    RestoreOldWGP(aData)
    parent.OnExitAlgorithm(aData)
EndFunction


;>=========================================================
;>===                     REPORTS                       ===
;>=========================================================
;@Override:
; Needed to be overrided by descendants if they want to support widget reporting.
Function SetupWidget(DM_SandowPP_AlgorithmData aData)
EndFunction

;@Override:
; Bare minimum data useful for the player. Used for widgets and such.
Function ReportEssentials(DM_SandowPP_AlgorithmData aData)
    ; To be compatible, a Report.Notification() must send whole data.
EndFunction

;@Override:
; Reports things on demand.
Function ReportOnHotkey(DM_SandowPP_AlgorithmData aData)
    aData.Report.OnHotkeyReport(Self)
EndFunction

;@Override:
; Reports things after done sleeping.
Function ReportSleep(DM_SandowPP_AlgorithmData aData)
EndFunction

;@Override:
; Reports things at skill level up.
Function ReportSkillLvlUp(DM_SandowPP_AlgorithmData aData)
EndFunction

;@Override:
; Gets the label for the name of the stat this algorithm changes.
string Function GetMcmMainStatLabel()
    return "$MCM_AlgoMuscleDef"
EndFunction

;@Override:
; Gets the value of the stat this algorithm changes.
string Function GetMcmMainStat()
    return FloatToStr(_muscleDef)
EndFunction

;@Override:
; Shows your current state in the MCM.
string Function GetMCMStatus(DM_SandowPP_AlgorithmData aData)
    Return ""
EndFunction

;@Override:
; MCM Custom label functions.
string Function GetMCMCustomData1(DM_SandowPP_AlgorithmData aData)
    Return ""
EndFunction

;@Override:
string Function GetMCMCustomLabel1(DM_SandowPP_AlgorithmData aData)
    Return ""
EndFunction

;@Override:
string Function GetMCMCustomInfo1(DM_SandowPP_AlgorithmData aData)
    Return ""
EndFunction

;@Override:
string Function MCMInfo()
    Return "***ERROR***"
EndFunction
