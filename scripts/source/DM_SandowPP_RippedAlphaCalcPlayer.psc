Scriptname DM_SandowPP_RippedAlphaCalcPlayer extends DM_SandowPP_RippedAlphaCalc
{Calculates an alpha for the player based on some settings.}

Import DM_SandowPP_Globals

DM_SandowPP_AlgorithmBodyfatChange _bhv

;>=========================================================
;>===                      PUBLIC                       ===
;>=========================================================


;@override:
; Gets an alpha based on settings.
float Function GetAlpha(Actor akTarget)
    If _bhv != None
        return LerpAlpha(_bhv.GetBodyFat())
    Else
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
;>===                     SETTINGS                      ===
;>=========================================================

;@Public:
; Sets the behavior that controls player muscle definiton
Function SetBehavior(DM_SandowPP_AlgorithmBodyfatChange bhv)
    If bhv != None
        MethodIsNowBehavior()
    Else
        MethodIsNoLongerBehavior()
    EndIf
    _bhv = bhv
EndFunction

int _oldBhv
Function MethodIsNowBehavior()
    _oldBhv = body.method
    body.method = cfg.rpmBhv
EndFunction

Function MethodIsNoLongerBehavior()
    body.method = _oldBhv
EndFunction

;>=========================================================
;>===                     COMPARE                       ===
;>=========================================================

bool Function MethodIsBehavior()
    return body.method == cfg.rpmBhv
EndFunction
