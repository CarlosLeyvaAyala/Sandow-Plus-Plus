Scriptname DM_SandowPP_RippedAlphaCalcNPC extends DM_SandowPP_RippedAlphaCalc
{Calculates an alpha for the player based on some settings.}


;>=========================================================
;>===                      PUBLIC                       ===
;>=========================================================


;@override:
float Function GetAlpha(Actor akTarget)
    {Gets an alpha based on settings.}
    If body.method <= cfg.rpmSkill
        return GetAlphaFromOptions(aktarget)
    ElseIf MethodIsRandom()
        ; TODO: Finish this
    ElseIf MethodIsThinnerLeanner()
    ElseIf MethodIsMuscleLeanner()
    EndIf
    return 0.0
EndFunction


;@Private:
;>Building blocks. These aren't designed for interacting with other scripts.

;>=========================================================
;>===                     COMPARE                       ===
;>=========================================================

bool Function MethodIsRandom()
    return body.method == cfg.rpmRand
EndFunction

bool Function MethodIsThinnerLeanner()
    return body.method == cfg.rpmThin
EndFunction

bool Function MethodIsMuscleLeanner()
    return body.method == cfg.rpmMuscle
EndFunction
