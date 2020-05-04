Scriptname DM_SandowPP_TrainingWeightCreate extends ObjectReference  
{Create and place a new activator for the player to train}

Import Math

Activator Property TrainingWeight Auto  
{Activator to spawn}

MiscObject Property Spawner Auto  
{Misc item that spawned the activator}


Event OnEquipped(Actor akActor)
    ObjectReference droppedActivator  
    Actor player = Game.GetPlayer()
    droppedActivator = player.PlaceAtMe(TrainingWeight)
    float theta = player.GetAngleZ()
    float r = 30
    If (droppedActivator)
        droppedActivator.MoveTo(player, r * Sin(theta), r * Cos(theta), 7.0)
        droppedActivator.SetAngle(0.0, 0.0, theta)
        player.RemoveItem(Spawner, 1, True)
    EndIf
EndEvent
