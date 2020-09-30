Scriptname DM_SandowPP_RippedSpell extends ActiveMagicEffect
{Makes actor ripped by asking the texture manager to set level every x seconds.}

Import DM_SandowPP_Globals
; Import DM_Utils
DM_SandowPP_TextureMngr property texMgr Auto

float _alpha = -1.0
Actor _self

Event OnEffectStart(Actor akTarget, Actor akCaster)
    TraceA(akTarget, "Now can get ripped")
    _self = akTarget
    _Poll()
EndEvent

Function _Poll()
    TraceA(_self, "Polling ripped spell")
    _alpha = texMgr.MakeRipped(_self, _alpha)
    RegisterForSingleUpdate(_GetWaitTime())
EndFunction

Event OnUpdate()
    _Poll()
EndEvent

; Gets time before next polling based on alpha mode.
float Function _GetWaitTime()
    If _alpha <= texMgr.IsInvalid
        ; Wait a lot before next inquiry because it's possible (but unlikely)
        ; a patch for that race may exist in the future.
        ; Player shouldn't be allowed to get hedre, anyway.
        return 2 * 60
    Else
        ; TODO: Make MCM configurable
        return 2
    EndIf
EndFunction
