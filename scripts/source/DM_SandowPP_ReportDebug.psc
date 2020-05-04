Scriptname DM_SandowPP_ReportDebug extends DM_SandowPP_Report
Import DM_SandowPP_Globals

Function Notification(DM_SandowPP_ReportArgs args)
    Trace("ReportDebug.Notification = " + args.aText)
    If args.aText == ""
        Return
    EndIf
    Debug.Notification(args.aText)
EndFunction

Function OnEnter()
    Trace(Self + ".OnEnter()")
EndFunction

Function OnExit()
    Trace(Self + ".OnExit()")
EndFunction

string Function MCMInfo()
    Return "$MCM_ReportTypeDebugInfo"
EndFunction