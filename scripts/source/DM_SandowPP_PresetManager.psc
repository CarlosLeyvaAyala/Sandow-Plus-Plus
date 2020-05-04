Scriptname DM_SandowPP_PresetManager extends Quest Hidden 
{ Interface for open/loading presets }

DM_SandowPP_Config Property ConfigResults Auto
{ You can't actually instantiate new objects in real time in Skyrim. You must use an existing script to be able to return values }

; ########################################################################
; DON'T TOUCH THESE
; ########################################################################
string FProfileFilePath = "../Sandow Plus Plus/"
string FProfileFilename = "profile"

; ########################################################################
; Theses variables need to be reimplemented by descendants.
; ########################################################################
string Function FProfileFilePre()
    Return "DUMMY"
EndFunction

string Function FProfileFileExt() 
    Return ".txt"
EndFunction

; ########################################################################
; Abstract public functions. These need to be reimplemented by descendants.
; ########################################################################

; Does the external file system exist?
bool Function Exists()
    Return False
EndFunction

; Does this profile exist?
bool Function ProfileExists(int profileNum) 
    ; Should be used in conjunction with GenerateFileName()
    Return False
EndFunction

; ########################################################################
; Static public functions. These aren't intended to be redefined.
; ########################################################################
Function SaveFile(int presetNumber, DM_SandowPP_Config config)     
    {Export user config}
    if !Exists()
        Return
    EndIf
    VirtualSave(presetNumber, config)
EndFunction

DM_SandowPP_Config Function LoadFile(int presetNumber)
    {Import user config}
    if !Exists()
        ConfigResults.operationResult = "$PresetMngrNotExist"
        Return ConfigResults
    EndIf
    if !ProfileExists(presetNumber)
        ConfigResults.operationResult = "$PresetFileNotExist"
        Return ConfigResults
    EndIf    
    
    return VirtualLoad(presetNumber)
EndFunction

string Function GenerateFileNameOnly(int presetNumber)
    Return FProfileFilePre() + FProfileFilename + presetNumber + FProfileFileExt()
EndFunction

; ########################################################################
; Private abstract functions. These are designed to be used only within
; this script. Never call them from the outside.
; Override these.
; ########################################################################
Function VirtualSave(int presetNum, DM_SandowPP_Config config)
EndFunction

DM_SandowPP_Config Function VirtualLoad(int presetNum)
EndFunction

; ########################################################################
; Private static functions. These are designed to be used only within
; this script. Never call them from the outside.
; ########################################################################
string Function GenerateFileName(int presetNumber)
    {Generate filename with path}
    Return FProfileFilePath + GenerateFileNameOnly(presetNumber)
EndFunction