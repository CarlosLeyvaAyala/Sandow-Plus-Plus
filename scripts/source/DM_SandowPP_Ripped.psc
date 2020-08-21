Scriptname DM_SandowPP_Ripped extends activemagiceffect
{Effect to make an actor ripped}

Import DM_SandowPP_Globals

Actor Property Player  Auto
{The player has special processing}
DM_SandowPP_TextureMngr Property textureManager Auto
{Object that makes the actual changes to the actor.}

Event OnEffectStart(Actor akTarget, Actor akCaster)
    {Asks the texture manager to apply the overlay texture set over the target}
    Trace("DM_SandowPP_Ripped.OnEffectStart(" + akTarget + ")")
    Trace("textureManager = " + textureManager)
    textureManager.Debug(akTarget)
    ; Si es NPC, establecer texture overlay con alpha = random
    ; Si es el jugador, alpha = 0
EndEvent
