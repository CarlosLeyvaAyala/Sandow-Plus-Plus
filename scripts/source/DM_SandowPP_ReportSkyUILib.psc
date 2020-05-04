Scriptname DM_SandowPP_ReportSkyUILib extends DM_SandowPP_Report
{Report colored things using SkyUILib}

Import DM_SandowPP_Globals

Function Notification(DM_SandowPP_ReportArgs args)
    Trace("ReportSkyUILib.Notification = " + args.aText)
    If args.aText == ""
        Return
    EndIf
    ((Self as Form) as UILIB_1).ShowNotification(args.aText, SelectColor(args.aType))
EndFunction

string Function SelectColor(int aType)
    If aType == mtDown
        Return "#cc0000"
    ElseIf aType == mtUp
        Return "#4f8a35"
    ElseIf aType == mtWarning
        Return "#ffd966"
    ElseIf aType == mtDanger
        Return "#ff6d01"
    ElseIf aType == mtCritical
        Return "#ff0000"
    Else    
        Return "#ffffff"
    EndIf
EndFunction

Function OnEnter()
    Trace(Self + ".OnEnter()")
EndFunction

Function OnExit()
    Trace(Self + ".OnExit()")
EndFunction

string Function MCMInfo()
    Return "$MCM_ReportTypeColorInfo"
EndFunction