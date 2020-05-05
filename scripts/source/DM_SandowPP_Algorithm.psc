Scriptname DM_SandowPP_Algorithm extends Quest Hidden 
{ Interface to implement algorithms that change the player in some way when they sleep }

Import DM_SandowPP_Globals

Actor property Player auto
DM_SandowPP_ReportArgs property RArg auto
DM_SandowPP_State property Result Auto

; Initial setup when switching to this algorithm
Function OnEnterAlgorithm(DM_SandowPP_AlgorithmData aData)
    SetupWidget(aData)
EndFunction    

float Function SleepFullRestHours()
    Return 10.0
EndFunction

Function SetupCommonWidget(DM_SandowPP_AlgorithmData aData, int a3rdMeterEvt)
    {Sets up the most common type of widget}
    DM_SandowPP_Report r = aData.Report
    r.Clear()
    r.RegisterMessageCategory(r.mcWeight, 0)
    r.RegisterMessageCategory(r.mcWGP, 1)
    r.RegisterMessageCategory(a3rdMeterEvt, 2)
    r.RegisterMessageCategory(r.mcInactivity, 3)
    r.HidePermanently(3, !aData.Config.CanLoseWeight)       ; Hide meter if <CanLoseWeight> is disabled
    r.HideNow(3, !aData.Config.CanLoseWeight)       
EndFunction    

Function SetupWidget(DM_SandowPP_AlgorithmData aData)
    {Needed to be overrided by descendants if they want to support widget reporting}
EndFunction    

Function ReportEssentials(DM_SandowPP_AlgorithmData aData)
    {Bare minimum data useful for the player. Used for widgets and such.}
    ; To be compatible, a Report.Notification() must send whole data.
EndFunction    

DM_SandowPP_State Function OnSleep(DM_SandowPP_AlgorithmData aData)
    {Does something on the player when they go to sleep.}
    return Result      ; Always return this Property
EndFunction    

Function ReportOnHotkey(DM_SandowPP_AlgorithmData aData)
    {Reports things on demand}
    aData.Report.OnHotkeyReport(Self)
EndFunction    

Function ReportSleep(DM_SandowPP_AlgorithmData aData)
    {Reports things after done sleeping}
EndFunction    

Function ReportSkillLvlUp(DM_SandowPP_AlgorithmData aData)
    {Reports things at skill level up}
EndFunction    

string Function GetMCMStatus(DM_SandowPP_AlgorithmData aData)
    {Shows your current state in the MCM}
    Return ""
EndFunction    

string Function GetMCMCustomData1(DM_SandowPP_AlgorithmData aData)
    {MCM Custom label functions}
    Return ""
EndFunction    

string Function GetMCMCustomLabel1(DM_SandowPP_AlgorithmData aData)
    Return ""
EndFunction    

string Function GetMCMCustomInfo1(DM_SandowPP_AlgorithmData aData)
    Return ""
EndFunction    

string Function MCMInfo()
    Return "***ERROR***"
EndFunction