Scriptname DM_SandowPP_Anabolic extends ActiveMagicEffect
{Multiplies the total weight gained.}

Import DM_SandowPP_Globals

DM_SandowPPMain Property SPP  Auto
{Pointer to the mod core}

Spell Property ExtraEffect Auto
{Extra effect the anabolic causes, if any}

float Property Magnitude = 1.0 Auto
{Weight gain multiplier.}
float Property BaseValue = 0.0 Auto
{Used to simulate the fact that steroid users gain muscles even if they don't train.}

Message Property Msg Auto

; Adds a weight multiplier and possibly as extra spell.
Event OnEffectStart(Actor akTarget, Actor akCaster)
    ; Trace("Anabolic.OnEffectStart()")
    ; Trace("GetMagnitude() = " + Magnitude)
    SPP.PrepareAlgorithmData()
    SPP.CurrentState.WeightGainBase = DM_Utils.MaxF(BaseValue, SPP.CurrentState.WeightGainBase)
    SPP.CurrentState.WeightGainMultiplier = DM_Utils.MaxF(Magnitude, SPP.CurrentState.WeightGainMultiplier)
    If Msg
        Msg.Show()
    EndIf
    If ExtraEffect
        Actor player = Game.GetPlayer()
        ExtraEffect.Cast(player, player)
    EndIf
EndEvent
