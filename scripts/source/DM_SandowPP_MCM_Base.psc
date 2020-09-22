; https://github.com/schlangster/skyui/wiki/MCM-State-Options
Scriptname DM_SandowPP_MCM_Base extends SKI_ConfigBase Hidden

Import DM_Utils
Import DM_SandowPP_Globals
; Import DM_SandowPP_SkeletonNodes


DM_SandowPPMain property SPP auto
DM_SandowPP_Config property Cfg auto

Function Header(string text)
    AddHeaderOption("$MCM_Header{" + text + "}")
EndFunction

string Function Error(string text)
    return "$MCM_Error{" + text + "}"
EndFunction

; Renames AddTextOptionST() to declutter code
Function Button(string stateName, string ltext, string rtext, int flags = 0)
    AddTextOptionST(stateName, ltext, rtext, flags)
EndFunction

; Renames AddTextOptionST() to declutter code
Function Label(string stateName, string ltext, string rtext, int flags = 0)
    AddTextOptionST(stateName, ltext, rtext, flags)
EndFunction

; Renames AddSliderOptionST() to declutter code
Function Slider(string stateName, string text, float val, string fmt, int flags = 0)
    AddSliderOptionST(stateName, text, val, fmt, flags)
EndFunction

Function Menu(string stateName, string label, string options, int flags = 0)
    AddMenuOptionST(stateName, label, options, flags)
EndFunction

int Function ToNewPos(int aPos)
    Return (aPos * 2) + 2
EndFunction

int Function FlagByBool(bool aVal)
    {Enables control if aVal is True}
    If aVal
        Return OPTION_FLAG_NONE
    Else
        Return OPTION_FLAG_DISABLED
    EndIf
EndFunction



;>========================================================================#
; Generic tags functions
;>========================================================================#
string Function TagExists(bool condition)
    If condition
        return "$Found"
    Else
        return Error("$Not found")
    EndIf
EndFunction

Function TagPapyrusUtil()
    AddTextOptionST("TX_NfPapyrusU", "PapyrusUtil", TagExists(PapyrusUtilExists()))
EndFunction

Function TagNiOverride()
    AddTextOptionST("TX_NfNiOverride", "NiOverride", TagExists(NiOverrideExists()))
EndFunction

Function TagSexlab()
    AddTextOptionST("TX_NfSexlab", "Sexlab", TagExists(SexLabExists()))
EndFunction

State TX_NfPapyrusU
    Event OnHighlightST()
        SetInfoText("$MCM_CompatPapyrusUtilInfo")
    EndEvent
EndState

State TX_NfNiOverride
    Event OnHighlightST()
        SetInfoText("$MCM_CompatNiOverrideInfo")
    EndEvent
EndState

State TX_NfSexlab
    Event OnHighlightST()
        SetInfoText("$MCM_CompatSexlabInfo")
    EndEvent
EndState


;>========================================================================#
; Helper functions
;>========================================================================#

Function OpenMenu(int aStart, int aDefault, string[] aOptions)
    SetMenuDialogStartIndex(aStart)
    SetMenuDialogDefaultIndex(aDefault)
    SetMenuDialogOptions(aOptions)
EndFunction

Function CreateSkillSliderPhys(float startValue)
    CreateSkillSlider(startValue, 0.5)
EndFunction

Function CreateSkillSliderMag(float startValue)
    CreateSkillSlider(startValue, 0.20)
EndFunction

Function CreateSkillSlider(float startValue, float maxValue)
    CreateSlider(startValue, 0.0, maxValue, 0.01)
EndFunction

Function CreateSlider(float aStart, float aMin, float aMax, float aInterval)
    SetSliderDialogStartValue(aStart)
    SetSliderDialogDefaultValue(aStart)
    SetSliderDialogRange(aMin, aMax)
    SetSliderDialogInterval(aInterval)
EndFunction

Function CreateFatigueSlider(float startValue)
    float x = ToPercent(startValue)
    CreateSlider(x, 5, 50, 1)
EndFunction

Function CreatePercentSlider(float startValue)
    {Creates a slider from 0% to 100%. startValue goes from [0.0, 1.0].}
    CreateSlider(FloatToPercent(startValue), 0.0, 100.0, 1.0)
EndFunction

bool Function ConfirmHotkeyChange(string conflictControl, string conflictName)
    if (conflictControl != "")
        string msg
        if (conflictName != "")
            msg = "$MCM_HotkeyConflict2{" + conflictControl + "}{" + conflictName + "}"
        else
            msg = "$MCM_HotkeyConflict1{" + conflictControl + "}"
        endIf
        Return ShowMessage(msg, true, "$Yes", "$No")
    endIf
    Return True
EndFunction
