Scriptname DM_SandowPP_ReportMeterBase extends DM_MeterWidgetScript Hidden
Import DM_SandowPP_Globals

Event OnUpdateDisplay(DM_SandowPP_Report sender, float aPercent,  int aType)
    {Update data. Core behavior.}
    ; Trace(Self + ".OnUpdateDisplay()")

    Percent = aPercent
    FlashColor(sender, aType)
EndEvent

Function FlashColor(DM_SandowPP_Report sender, int aType)
    {Decides if the meter has to flash}
    If aType == sender.mtDefault
        DoFlashColor(-1, False)
    ElseIf aType == sender.mtDown
        DoFlashColor(clDown(), True)
    ElseIf aType == sender.mtUp
        DoFlashColor(clUp(), True)
    ElseIf aType == sender.mtWarning
        DoFlashColor(clWarning(), True)
    ElseIf aType == sender.mtDanger
        DoFlashColor(clDanger(), True)
    ElseIf aType == sender.mtCritical
        DoFlashColor(clCritical(), True)
    EndIf
EndFunction

Function DoFlashColor(int aColor, bool aFlash)
    {Applies the flashing}
    FlashColor = aColor
    If aFlash
        Flash()
    EndIf
EndFunction
