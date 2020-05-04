Scriptname DM_SandowPP_Anabolic extends ActiveMagicEffect  
{Multiplies the total weight gained.}

Import DM_SandowPP_Globals

DM_SandowPPMain Property SPP  Auto  
{Pointer to the mod core}

Spell Property ExtraEffect Auto  
{Extra effect the anabolic causes, if any}

float Property Magnitude = 1.0 Auto

Message Property Msg Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
    {Add weight multiplier and possible spell}
    Trace("Anabolic.OnEffectStart()")
    Trace("GetMagnitude() = " + Magnitude)
    
    SPP.PrepareAlgorithmData()
    SPP.CurrentState.WeightGainMultiplier = DM_Utils.MaxF(Magnitude, SPP.CurrentState.WeightGainMultiplier)
    If Msg
        Msg.Show()
    EndIf
    If ExtraEffect
        Actor player = Game.GetPlayer()
        ExtraEffect.Cast(player, player)
    EndIf
EndEvent