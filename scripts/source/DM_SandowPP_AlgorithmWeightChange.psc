Scriptname DM_SandowPP_AlgorithmWeightChange extends DM_SandowPP_Algorithm Hidden
{Family of all algorithms that change the player's weight in some way.}

Import DM_Utils
Import Math
Import DM_SandowPP_Globals

int property minW = 0 AutoReadOnly
int property maxW = 100 AutoReadOnly

; float Function GetPlayerWeight()
;     return Player.GetActorBase().GetWeight()
; EndFunction

; ########################################################################
; Protected functions. These are designed to be used only within
; this script and descendants. Never call them from the outside.
; ########################################################################

float Function CalculateHunger(float weightGain, bool aCanHunger)
    Return weightGain
EndFunction

Function ChangeWeight(float aIncrement, DM_SandowPP_AlgorithmData aData)
    Trace("AlgorithmWeightChange.ChangeWeight(" + aIncrement + ")")
    aData.CurrentState.TraceAll()

    aIncrement *= aData.Config.weightGainRate
    aIncrement = UseSteroids(aIncrement, aData)
    ; aIncrement *= aData.CurrentState.WeightGainMultiplier
    float w = GetPlayerWeight()
    float newW = ConstrainF(w + aIncrement, minW, maxW)
    Player.GetActorBase().SetWeight(newW)
    Player.QueueNiNodeUpdate()
    SendModEvent("ChangeWeight", "", aIncrement)
    ReportWeightChange(aData, w, newW)
    ; aData.CurrentState.WeightGainMultiplier = 1.0
EndFunction


; ########################################################################
; Report functions.
; ########################################################################

Function ReportWeight(DM_SandowPP_AlgorithmData aData)
    float w = GetPlayerWeight()
    RArg.Set("$ReportWeight{" + FloatToStr(w, 2) + "}", aData.Report.mtDefault)
    RArg.CatVal(aData.Report.mcWeight, PercentToFloat(w))
    aData.Report.Notification(RArg)
EndFunction

Function ReportWGP(DM_SandowPP_AlgorithmData aData)
    RArg.Set("$ReportWGP{" + FloatToStr(aData.CurrentState.WGP, 2) + "}", aData.CurrentState.WGPGainType)
    RArg.CatVal(aData.Report.mcWGP, PercentToFloat(aData.CurrentState.WGP))
    aData.Report.Notification(RArg)
    aData.CurrentState.WGPGainType = aData.Report.mtDefault     ; Done reporting. Stop flashing
EndFunction

Function ReportWeightChange(DM_SandowPP_AlgorithmData aData, float oldW, float newW)
    {Tells the player weight has changed}
    float dw = newW - oldW
    if dw > 0
        SendModEvent("GainWeight", "", aData.CurrentState.HoursSlept)
        DoReportWC(aData, "$ReportWeightGained{" + FloatToStr(dw)  + "}", aData.Report.mtUp, aData.Report.mcWeight, dw)
    ElseIf dw < 0
        DoReportWC(aData, "$ReportWeightLost{" + FloatToStr(abs(dw)) + "}", aData.Report.mtDown, aData.Report.mcWeight, dw)
    EndIf
    if aData.Config.VerboseMod
        ReportWeight(aData)
    EndIf

    ; Trace("AlgorithmWeightChange.ReportWeightChange()")
    ; Trace("Old weight = " + oldW)
    ; Trace("New weight = " + newW)
EndFunction

Function DoReportWC(DM_SandowPP_AlgorithmData aData, string aTxt, int aType, int aCat, float aWc)
    {Shortcut to report weight changes}
    RArg.Set(aTxt, aType)
    RArg.CatVal(aCat, PercentToFloat( GetPlayerWeight() ))
    aData.Report.Notification(RArg)
EndFunction

; ========================
Function ReportInactivity(DM_SandowPP_AlgorithmData aData)
    RArg.Set(GetInactivityStatus(aData), GetInactivityMsgLvl(aData))
    RArg.CatVal(aData.Report.mcInactivity, InactivityAsPercent(aData))
    aData.Report.Notification(RArg)
EndFunction

string Function GetInactivityStatus(DM_SandowPP_AlgorithmData aData)
    {Determines what message to show}
    If !aData.Config.CanLoseWeight
        Return ""
    EndIf

    int msgLvl = GetInactivityMsgLvl(aData)
    If msgLvl == aData.Report.mtWarning
        float hoursLeft = InactivityHoursLeft(aData)
        Return "$ReportTrainNotLoseWeight{" + FloatToStr(hoursLeft, 1) + "}"
    ElseIf msgLvl == aData.Report.mtCritical
        Return "$ReportTrainLoseWeight"
    EndIf
    Return ""
EndFunction

int Function GetInactivityMsgLvl(DM_SandowPP_AlgorithmData aData)
    {Determines how critical is the inactivity status}
    float inactivityTimeLeft = InactivityHoursLeft(aData)
    If inactivityTimeLeft <= 0.0
        Return aData.Report.mtCritical
    ElseIf inactivityTimeLeft < ReportInactivityPercentThreshold()
        Return aData.Report.mtWarning
    EndIf
    Return aData.Report.mtDefault
EndFunction

; Gets the label for the name of the stat this algorithm changes.
string Function GetMcmMainStatLabel()
    return "$Weight:"
EndFunction

; Gets the value of the stat this algorithm changes.
string Function GetMcmMainStat()
    return FloatToStr(GetPlayerWeight())
EndFunction
