Scriptname DM_SandowPP_RippedSpell extends ActiveMagicEffect
{Makes actor ripped by asking the texture manager to set level every x seconds.}

Import DM_SandowPP_Globals
; Import DM_Utils
DM_SandowPP_TextureMngr property texMgr Auto

; float _alpha = -1.0
Actor _self

Event OnEffectStart(Actor akTarget, Actor akCaster)
    TraceA(akTarget, "Can now get ripped")
    _self = akTarget
    _Poll()
EndEvent

Function _Poll()
    TraceA(_self, "Ripped spell - Polling")
    _CheckValidRace( texMgr.CalcMuscleDefinition(_self) )
    ; TODO: Make MCM configurable
    RegisterForSingleUpdate(2)
EndFunction

Event OnUpdate()
    _Poll()
EndEvent

Function _CheckValidRace(bool isValid)
    If !isValid
        Dispel()
    EndIf
EndFunction
