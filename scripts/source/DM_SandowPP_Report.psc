Scriptname DM_SandowPP_Report extends Quest Hidden
{ Abstract class to report things }

;> Message types
int Property mtDefault = 0 AutoReadOnly
int Property mtDown = 100 AutoReadOnly
int Property mtUp = 200 AutoReadOnly
int Property mtWarning = 400 AutoReadOnly
int Property mtDanger = 500 AutoReadOnly
int Property mtCritical = 600 AutoReadOnly

;> Message categories
int Property mcNone = 0 AutoReadOnly
int Property mcWeight = 1 AutoReadOnly
int Property mcWGP = 2 AutoReadOnly
int Property mcFatigue = 3 AutoReadOnly
int Property mcSleepHours = 4 AutoReadOnly
int Property mcInactivity = 5 AutoReadOnly
int Property mcHeight = 6 AutoReadOnly

;> Message events
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

; Enables a meter to catch report messages.
;
; aCat  => Category for the message.
; id    => Id of the widget meter that will catch this message.
Function RegisterMessageCategory(int aCat, int id = -1)
EndFunction

Function Clear()
EndFunction

Function Refresh()
EndFunction

Function HidePermanently(int id, bool aHide)
EndFunction

; Hides the widget meter #id.
Function HideNow(int id, bool aHide)
EndFunction

; Updates appearance according to current configuration.
Function UpdateConfig()
EndFunction
