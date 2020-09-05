Scriptname DM_SandowPP_AlgorithmBodyfatChange extends DM_SandowPP_Algorithm Hidden
{Family of all algorithms that change the player's bodyfat in some way.}

; Import DM_Utils
; Import Math
; Import DM_SandowPP_Globals

DM_SandowPP_TextureMngr Property txMgr Auto

;@Public:
; Tells the body fat levels this algorithm carries.
float Function GetBodyFat()
    return -1.0
EndFunction

;@Override:
; Initial setup when switching to this algorithm.
Function OnEnterAlgorithm(DM_SandowPP_AlgorithmData aData)
    txMgr.SetPlayerBehavior(self)
    txMgr.InitPlayer()
    ;	Apply behavior texture set
    parent.OnEnterAlgorithm(aData)
EndFunction

;@Override:
; Do things when getting out from this.
Function OnExitAlgorithm(DM_SandowPP_AlgorithmData aData)
    If !txMgr.PlayerSettings.bulkCut
        ; We assume the player no longer wants to be ripped by behavior
        txMgr.SetPlayerBehavior(none)
    EndIf
    txMgr.InitPlayer()
EndFunction
