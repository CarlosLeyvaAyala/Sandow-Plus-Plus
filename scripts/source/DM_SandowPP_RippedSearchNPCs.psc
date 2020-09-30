Scriptname DM_SandowPP_RippedSearchNPCs extends ReferenceAlias
{Updates texture set when (un)equiping armor.}

Import DM_SandowPP_Globals

Spell Property rippedSpell Auto
Actor property Player auto
DM_SandowPP_TextureMngr property texMgr Auto

Event OnUpdate()
    _ScanNPCs()
EndEvent

Event OnInit()
    _ScanNPCs()
EndEvent

Function _ScanNPCs(bool force = false)
    ; TraceA(Player, "Searching for NPCs to get ripped")
    float d = 2048
    If force
        d = 4096
    EndIf
    Actor[] npcs = MiscUtil.ScanCellNPCs(Player, d, None, false)
    int i = npcs.length
    ; Trace("NPCs found: " + i)
    While i > 0
        i -= 1
        If npcs[i] != Player
            ; TraceA(npcs[i], "Making ripped")
            If force
                texMgr.MakeRipped(npcs[i], -1)
            Else
                npcs[i].AddSpell(rippedSpell)
            EndIf
        EndIf
     EndWhile
    RegisterForSingleUpdate(6)
EndFunction

; Event OnPlayerLoadGame()
;     Trace("force setting ripped")
;     _ScanNPCs(true)
; EndEvent
