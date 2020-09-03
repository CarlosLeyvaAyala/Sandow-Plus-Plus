; Interface to make alpha calculations on a "DM_SandowPP_RippedActor".
; DM_SandowPP_RippedActor only stores configuration settings, while this 
; script make makes the actual calculations.

; Warning: both this and DM_SandowPP_RippedActor need to be added to a quest 
; for a race to be enabled.

Scriptname DM_SandowPP_RippedAlphaCalc extends Quest Hidden
{Calculates an alpha based on some settings.}

Import DM_SandowPP_Globals

DM_SandowPP_Config Property Cfg Auto
{Pointer to the Config object. We need to get constants from here.}
DM_SandowPP_RippedActor Property body Auto
{The ripped body abstraction from which we want to get the settings.}


;>=========================================================
;>===                      PUBLIC                       ===
;>=========================================================


;@abstract:
float Function GetAlpha(Actor akTarget)
    {Gets an alpha based on settings.}
    DM_SandowPP_Globals.Trace("DM_SandowPP_RippedAlphaCalc.GetAlpha() should never be called.")
    return 0.0
EndFunction

float Function LerpAlpha(float alpha)
    {Linearly interpolates an alpha based on this body settings.}
    return DM_Utils.Lerp(body.LB, body.UB, alpha)
EndFunction

;@Private:
;>Building blocks. These aren't designed for interacting with other scripts.

;>=========================================================
;>===                     COMPARE                       ===
;>=========================================================

bool Function MethodIsNone()
    return body.method == cfg.rpmNone
EndFunction

bool Function MethodIsConst()
    return body.method == cfg.rpmConst
EndFunction

bool Function MethodIsWeight()
    return body.method == cfg.rpmWeight
EndFunction

bool Function MethodIsWeightInv()
    return body.method == cfg.rpmWInv
EndFunction

bool Function MethodIsSkill()
    return body.method == cfg.rpmSkill
EndFunction


;>=========================================================
;>===                   CALCULATIONS                    ===
;>=========================================================

float Function GetAlphaFromOptions(Actor akTarget)
    {Gets an alpha for this actor based on its MCM settings.}
    If MethodIsConst()
        return body.constAlpha
    ELseIf MethodIsWeight()
        return AlphaFromWeight(akTarget)
    ELseIf MethodIsWeightInv()
        return AlphaFromWeightInv(akTarget)
    ELseIf MethodIsSkill()
        return AlphaFromSkills(akTarget)
    EndIf
    return 0.0
EndFunction

float Function AlphaFromWeight(Actor akTarget)
    return LerpAlpha(GetActorWeight(akTarget))
EndFunction

float Function AlphaFromWeightInv(Actor akTarget)
    return LerpAlpha(1.0 - GetActorWeight(akTarget))
EndFunction

float Function AlphaFromSkills(Actor akTarget)
    float hi = 1.25
    float md = 0.75
    float lo = 0.50
    float hv = aktarget.GetBaseActorValue("HeavyArmor") * hi
    float sn = aktarget.GetBaseActorValue("Sneak") * hi
    float th = aktarget.GetBaseActorValue("TwoHanded") * hi
    float bl = aktarget.GetBaseActorValue("Block") * hi
    float lt = aktarget.GetBaseActorValue("LightArmor") * md
    float oh = aktarget.GetBaseActorValue("OneHanded") * md
    float at = aktarget.GetBaseActorValue("Alteration") * md
    float ar = aktarget.GetBaseActorValue("Marksman") * lo
    float sm = aktarget.GetBaseActorValue("Smithing") * 2.0
    ; trace("Skills")
    ; trace(hv)
    ; trace(sn)
    ; trace(th)
    ; trace(bl)
    ; trace(lt)
    ; trace(oh)
    ; trace(at)
    ; trace(ar)
    ; trace(sm)
    float alpha = (hv + sn + th + bl + lt + oh + at + ar + sm) / 500.0
    return LerpAlpha(alpha)
EndFunction

float Function GetActorWeight(Actor akTarget)
    {Returns actor weight as percent.}
    return akTarget.GetActorBase().GetWeight() / 100.0
EndFunction