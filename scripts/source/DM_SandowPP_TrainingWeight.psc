Scriptname DM_SandowPP_TrainingWeight extends ObjectReference
{This item adds WGP for simulating training}

Import DM_SandowPP_Globals

DM_SandowPPMain Property SPP Auto
{Link to the core of the mod}

Message Property Menu Auto
{What does the player want to do with this item?}

Message Property SoreMsg Auto
{Tell the player they're sore}

Message Property HeavyMsg Auto
{Tell the player they're too scrawny}

float Property WGP = 0.0 Auto
{How much WGP should this item add?}

float Property MinWeightRequired = 0.0 Auto
{What's the minimun Weight requisite for the player to use this? [0, 100]}

int Property HoursToRest = 72 Auto
{Used to limit the use Weights for training. Real hours.}

MiscObject Property Spawner Auto
{Item that originally spawned this Activator}



Event OnActivate(ObjectReference akActionRef)
    {Let the player decide what to do}
    Trace(akActionRef +".OnActivate()")
    int selection = Menu.Show()
    If selection == 0
        Train()
    ElseIf selection == 1
        Pickup(akActionRef)
    Else
        Return
    EndIf
EndEvent

Function Train()
    Trace("TrainingWeight.Train()")
    SPP.WeightTraining.TraceAll()
    
    If Game.GetPlayer().GetActorBase().GetWeight() < MinWeightRequired
        HeavyMsg.Show(MinWeightRequired)
        Return
    EndIf
    If !SPP.WeightTraining.CanTrainAgain()
        SoreMsg.Show(SPP.WeightTraining.HoursLeftToTrain())
        Return
    EndIf
    FadeOut()
    SPP.WeightTraining.Train(WGP, HoursToRest)
    FadeIn()
EndFunction

Function FadeOut()
    Game.DisablePlayerControls()
    Game.FadeOutGame(True, True, 0.5, 1.0)
    Utility.Wait(0.5)
EndFunction

Function FadeIn()
    Utility.Wait(0.5)
    Game.FadeOutGame(False, True, 0.5, 1.0)
    Game.EnablePlayerControls()
EndFunction

Function Pickup(ObjectReference akActionRef)
    {Pick up training weight to inventory}
    Game.GetPlayer().AddItem(Spawner, 1, True)
    DisableNoWait(True)
    Delete()
EndFunction