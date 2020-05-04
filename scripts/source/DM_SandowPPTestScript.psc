Scriptname DM_SandowPPTestScript extends ObjectReference  
{Increment some skill for testing purposes}
DM_SandowPPMain property SandowPP auto

Event OnActivate(ObjectReference akActionRef)
    Game.IncrementSkill("TwoHanded")
EndEvent
