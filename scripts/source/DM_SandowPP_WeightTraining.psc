Scriptname DM_SandowPP_WeightTraining extends Quest
{Controls how player trains with weights}

Import DM_SandowPP_Globals
Import DM_Utils

DM_SandowPPMain Property Owner Auto
{Link to the core of the mod}

float Property LastTrainingTime = 0.0 Auto         
{Used to limit the use Weights for training. Game hours.}

int Property HoursToRest = 0 Auto
{Used to limit the use Weights for training. Real hours.}

GlobalVariable Property GameHour Auto
{Points to GameHour global. Used to advance time after training.}


Function Train(float WGP, int aHoursToRest)
    {Script core}
    If CanTrainAgain()
        Owner.TrainAndFatigue(WGP, Owner.Config.trainFatigueRate)
        LastTrainingTime = Now()
        HoursToRest = aHoursToRest
        AdvanceHours(1.0)
    EndIf
EndFunction

Function AdvanceHours(float aHours)
    {How many hours the player spent training}
    GameHour.Mod(aHours)
EndFunction

bool Function CanTrainAgain()
    {Determine if the player can use weights to train again.}
    Return HoursLeftToTrain() <= 0
EndFunction

string Function HoursLeftToTrainStr()
    {Format as string}
    Return FloatToHour(HoursLeftToTrain())
EndFunction

float Function HoursLeftToTrain()
    {How many hours left before you can train again}
    Return HoursToRest - HoursSinceLastTraining()
EndFunction

float Function HoursSinceLastTraining()
    {How many hours have passed since last training}
    Return ToRealHours(Now() - LastTrainingTime)
EndFunction

Function TraceAll()
    Trace("WeightTraining.TraceAll()")
    Trace("LastTrainingTime = " + LastTrainingTime)
    Trace("HoursToRest = " + HoursToRest)
    Trace("HoursSinceLastTraining() = " + HoursSinceLastTraining())
    Trace("HoursLeftToTrain() = " + HoursLeftToTrain())
    ;Trace(" = " + )
EndFunction