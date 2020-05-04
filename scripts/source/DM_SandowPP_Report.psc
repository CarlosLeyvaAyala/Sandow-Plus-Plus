Scriptname DM_SandowPP_Report extends Quest Hidden
{ Abstract class to report things }

; Message types
int Property mtDefault = 0 AutoReadOnly
int Property mtDown = 100 AutoReadOnly
int Property mtUp = 200 AutoReadOnly
int Property mtWarning = 400 AutoReadOnly
int Property mtDanger = 500 AutoReadOnly
int Property mtCritical = 600 AutoReadOnly

; Message categories
int Property mcNone = 0 AutoReadOnly

; TODO: Change to constants for v3.0
int Property mcWeight
    int Function get()
        Return 1
    EndFunction
EndProperty
int Property mcWGP
    int Function get()
        Return 2
    EndFunction
EndProperty
int Property mcFatigue
    int Function get()
        Return 3
    EndFunction
EndProperty
int Property mcSleepHours
    int Function get()
    Return 4
    EndFunction
EndProperty
int Property mcInactivity
    int Function get()
        Return 5
    EndFunction
EndProperty
int Property mcHeight
    int Function get()
        Return 6
    EndFunction
EndProperty

string Property evWeight = "DM_SPP_evWeight" AutoReadOnly
string Property evWGP = "DM_SPP_evWGP" AutoReadOnly
string Property evFatigue = "DM_SPP_evFatigue" AutoReadOnly
string Property evSleepHours = "DM_SPP_evSleepHours" AutoReadOnly
string Property evInactivity = "DM_SPP_evInactivity" AutoReadOnly
string Property evHeight = "DM_SPP_evHeight" AutoReadOnly

string Function MCMInfo()
    Return "***ERROR***"
EndFunction

Function Notification(DM_SandowPP_ReportArgs args)
    {Notify what happened}
EndFunction

string Function MCMHotkeyInfo()
    Return "$MCM_HKStatusInfo"
EndFunction

Function OnHotkeyReport(DM_SandowPP_Algorithm aSender)
    {Special handling when player presses the report hotkey}
EndFunction

Function OnEnter()
EndFunction

Function OnExit()
EndFunction

Function RegisterMessageCategory(int aCat, int id = -1)
EndFunction

Function Clear()
EndFunction

Function Refresh()
EndFunction

Function HidePermanently(int id, bool aHide)
EndFunction

Function HideNow(int id, bool aHide)
EndFunction

Function UpdateConfig()
    {Updates appearance according to current configuration}
EndFunction
