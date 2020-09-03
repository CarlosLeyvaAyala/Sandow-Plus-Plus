Scriptname DM_SandowPP_RippedAlphaCalcPlayer extends DM_SandowPP_RippedAlphaCalc
{Calculates an alpha for the player based on some settings.}

Import DM_SandowPP_Globals

;>=========================================================
;>===                      PUBLIC                       ===
;>=========================================================


;@override:
float Function GetAlpha(Actor akTarget)
    {Gets an alpha based on settings.}
    Trace("DM_SandowPP_RippedAlphaCalcPlayer.GetAlpha()")
    Trace("Method = " + body.method)
    If !MethodIsBehavior()
        return GetAlphaFromOptions(aktarget)
    EndIf
    return 0.0
EndFunction

string Function MethodInfo()
    If MethodIsConst()
        return "$MCM_RippedApplyInfoConstant"
    ElseIf MethodIsWeight()
        return "$MCM_RippedApplyInfoWeight"
    ElseIf MethodIsWeightInv()
        return "$MCM_RippedApplyInfoWeightInv"
    ElseIf MethodIsSkill()
        return "$MCM_RippedApplyInfoSkill"
    ElseIf MethodIsBehavior()
        return "$MCM_RippedApplyInfoBhv"
    Else
        return "$MCM_RippedApplyInfoNone"
    EndIf
EndFunction

;@Private:
;>Building blocks. These aren't designed for interacting with other scripts.

;>=========================================================
;>===                     COMPARE                       ===
;>=========================================================

bool Function MethodIsBehavior()
    return body.method == cfg.rpmBhv
EndFunction
