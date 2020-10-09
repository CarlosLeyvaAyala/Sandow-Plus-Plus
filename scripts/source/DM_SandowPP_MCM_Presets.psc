Scriptname DM_SandowPP_MCM_Presets extends DM_SandowPP_MCM_Items Hidden

; Import DM_Utils
; Import DM_SandowPP_Globals

Function PageMainPresets()
    ; SetCursorPosition(pos)

    Header("$Presets")
    Label("LblPre_Name", "$Current preset", "")
    Menu("MN_PresetLoad", "$Load", "")
    AddInputOptionST("IN_PresetSave", "$Save as...", "")
    AddEmptyOption()
EndFunction
