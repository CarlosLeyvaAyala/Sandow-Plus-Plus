Scriptname DM_SandowPP_RippedSpell extends ActiveMagicEffect
{Makes actor ripped by asking the texture manager to set level every x seconds.}

; Import DM_SandowPP_Globals
; Import DM_Utils


DM_SandowPPMain Property SPP Auto
Actor property Player auto
DM_SandowPP_TextureMngr property texMgr Auto

float _alpha = -1.0

Event OnEffectStart(Actor akTarget, Actor akCaster)

EndEvent

Function _Poll()
    ; code
EndFunction

float Function _GetWaitTime()
    If _alpha >= 0
        ; Mode is constant alpha. No need to update too fast.
        return 10
    ElseIf _alpha <= texMgr.IsInvalid
        ; Wait a lot before next inquiry because it's possible (but unlikely)
        ; a patch for that race may exist in the future.
        return 60
    ElseIf _alpha <= texMgr.NeedsRecalc
        ; Alpha is calculated in real time. Wait less than other modes.
        return 5
    EndIf
    return 1
EndFunction
