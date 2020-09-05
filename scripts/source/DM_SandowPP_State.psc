Scriptname DM_SandowPP_State extends Quest
{ Stores the state of the main script, DM_SandowPPMain }

Import DM_Utils
Import DM_SandowPP_Globals

float Property HoursAwaken Auto         ; Real hours, not game hours.
float Property HoursSlept Auto          ; Real hours, not game hours.
float Property SkillFatigue             ; Fatigue accumulated due to skill level gains
    float Function get()
        Return _skillFatigue
    EndFunction
    Function set(float x)
        _skillFatigue = EnsurePositiveF(x)
    EndFunction
EndProperty
float Property WGP                      ; Weight Gain Potential
    float Function get()
        Return _WGP
    EndFunction
    Function set(float x)
        ; Never allow this to be less than 0
        _WGP = EnsurePositiveF(x)
    EndFunction
EndProperty
float Property LastSlept                ; Game hours. Initialize to -1 to avoid a New Game bug.
    float Function get()
        if _lastSlept < 0
            ; Avoid a bug when creating a new game when this mod seems to be initialized way before the current date.
            ; If not for this check, player would get they haven't slept for 3000 hours or so the first time they
            ; play the game.
            _lastSlept = Now()
        EndIf
        Return _lastSlept
    EndFunction
    Function set(float x)
        _lastSlept = x
    EndFunction
EndProperty
float Property LastSkillGainTime        ; Game hours.
    float Function get()
        if _lastSkillGainTime < 0.0
            Return Now()
        Else
            Return _lastSkillGainTime
        EndIf
    EndFunction
    Function set(float x)
        _lastSkillGainTime = x
    EndFunction
EndProperty
int Property WGPGainType = 0 Auto
{This is used to track if the player gained or lost WGP. Used for the reporting system}

float Property WeightGainBase = 0.0 Auto
{Used by anabolics to get the last extra pump. Used to simulate the fact that steroid
users gain muscles even if they don't train.}
float Property WeightGainMultiplier = 1.0 Auto
{Used by anabolics to get the last extra pump.}

float _WGP
float _skillFatigue
float _lastSkillGainTime
float _lastSlept

Function Assign(DM_SandowPP_State other)
    HoursAwaken = other.HoursAwaken
    HoursSlept = other.HoursSlept
    SkillFatigue = other.SkillFatigue
    WGP = other.WGP
    LastSlept = other.LastSlept
    LastSkillGainTime = other.LastSkillGainTime
    WGPGainType = other.WGPGainType
    WeightGainMultiplier = other.WeightGainMultiplier
EndFunction

float Function HoursAwakenRT()
    {Report hours awaken in real time. Used to report real time status.}
    Return ToRealHours(Now() - LastSlept)
EndFunction

Function TraceAll()
    Trace("DM_SandowPP_State")
    Trace("WGP = " + WGP)
    Trace("SkillFatigue = " + SkillFatigue)
    Trace("LastSkillGainTime = " + LastSkillGainTime)
    Trace("LastSlept = " + LastSlept)
    Trace("HoursAwaken = " + HoursAwaken)
    Trace("LastSlept = " + HoursSlept)
    Trace("WeightGainMultiplier = " + WeightGainMultiplier)
EndFunction
