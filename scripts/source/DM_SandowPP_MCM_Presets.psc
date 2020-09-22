Scriptname DM_SandowPP_MCM_Presets extends DM_SandowPP_MCM_Stats Hidden

; Import DM_Utils
; Import DM_SandowPP_Globals

int Function PageMainPresets(int pos)
    SetCursorPosition(pos)

    int count = 3
    Header("$Presets")
    Menu("MN_PresetLoad", "$Load", "")
    AddInputOptionST("IN_PresetSave", "$Save as...", "")
    Return pos + ToNewPos(count)
EndFunction
