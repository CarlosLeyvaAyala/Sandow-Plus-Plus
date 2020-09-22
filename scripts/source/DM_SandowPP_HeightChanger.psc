Scriptname DM_SandowPP_HeightChanger extends Quest
{Script to change player height}

Import DM_Utils

DM_SandowPPMain Property SPP Auto
; DM_SandowPP_ReportArgs property RArg auto

float Property Height = 1.0 Auto

Function RegisterEvents()
    {This script can only run from an event call}
    RegisterForModEvent("GainWeight", "OnGainWeight")
EndFunction

Function ReapplyHeight()
    {Height must be reapplied everytime you load a save}
    If Game.GetPlayer().GetActorBase().GetHeight() != Height
        ApplyHeight()
    EndIf
EndFunction

Event OnGainWeight(string eventName, string strArg, float aHoursSlept, Form sender)
    ; {Event call}
    ; float max = SPP.Config.HeightMax + 1.0
    ; If !SPP.Config.CanGainHeight || Height >= max
    ;     Return
    ; EndIf
    ; float gain = Gain(aHoursSlept, max)
    ; RArg.Set("$Height gained{" + FloatToStr(FloatToPercent(gain), 3) + "}", SPP.Report.mtUp)
    ; SPP.Report.Notification(RArg)
EndEvent

float Function Gain(float aHoursSlept, float max)
    {Actual calculation}
    float ratio = MinF(aHoursSlept, SPP.Algorithm.SleepFullRestHours()) / SPP.Algorithm.SleepFullRestHours()
    float gain = (SPP.Config.HeightMax / SPP.Config.HeightDaysToGrow) * ratio
    Height += gain
    Height = MinF(Height, max)
    ApplyHeight()
    Return gain
EndFunction

Function ApplyHeight()
    Game.GetPlayer().GetActorBase().SetHeight(Height)
    Game.GetPlayer().QueueNiNodeUpdate()
EndFunction
