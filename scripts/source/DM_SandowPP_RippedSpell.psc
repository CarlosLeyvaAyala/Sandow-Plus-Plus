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
    TraceA(_self, "Gotten alpha = " + _alpha)
    RegisterForSingleUpdate(_GetWaitTime())
EndFunction

Event OnUpdate()
    _Poll()
EndEvent

; Gets time before next polling based on alpha mode.
float Function _GetWaitTime()
    ; Don't want to update NPCs so fast to avoid too much flickering.
    If _self != texMgr.Player
        return _NPCWait()
    Else
        return _PlayerWait()
    EndIf
EndFunction

float Function _PlayerWait()
    If _alpha >= 0
        ; Mode is constant alpha. No need to update too fast.
        ; Fixme: set 10
        return 1
    ElseIf _alpha <= texMgr.IsInvalid
        ; Wait a lot before next inquiry because it's possible (but unlikely)
        ; a patch for that race may exist in the future.
        return 60
    ElseIf _alpha <= texMgr.NeedsRecalc
        ; Alpha is calculated in real time. Wait less than other modes.
        return 3
    EndIf
EndFunction

float Function _NPCWait()
    If _alpha <= texMgr.IsInvalid
        return  3 * 60
    Else
        return 5
    EndIf
EndFunction
