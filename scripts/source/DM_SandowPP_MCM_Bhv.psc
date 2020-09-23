Scriptname DM_SandowPP_MCM_Bhv extends DM_SandowPP_MCM_Base Hidden

Import DM_Utils
Import DM_SandowPP_Globals

string[] _behaviors
Function PageMainConfiguration()
    _behaviors = new string[4]
    _behaviors[0] = "$MCM_PausedBehavior"
    _behaviors[1] = "Sandow Plus Plus"
    _behaviors[2] = "Pumping Iron"
    _behaviors[3] = "Bruce Lee"

    ; int count = 3
    ; SetCursorPosition(pos)
    ;AddEmptyOption()
    Header("$Configuration")
    ; If !_rippedPlayer.bulkCut
        Menu("MN_BEHAVIOR", "$Behavior", _behaviors[Cfg.Behavior])
    ; Else
        ; Label("TX_BulkCutCantShowBhv", "", "$MCM_BulkCutCantShowBhv")
    ; EndIf

    AddToggleOptionST("TG_LOSEW", "$Can lose gains", Cfg.CanLoseWeight)

    If !Cfg.IsPumpingIron()
        AddToggleOptionST("TG_DR", "$Diminishing returns", Cfg.DiminishingReturns)
        ; count += 1
        If Cfg.IsSandow()
            AddToggleOptionST("TG_REBOUNDW", "$Weight rebound", Cfg.CanReboundWeight)
            ; count += 1
        EndIf
    EndIf


    ;AddToggleOptionST("TG_DISEASE", "$Disease affects Weight", false)
    ;AddToggleOptionST("TG_FOOD", "$Needs food to grow", false)
    AddEmptyOption()
    ; Return pos + ToNewPos(count)
EndFunction

State TX_BulkCutCantShowBhv
    Event OnHighlightST()
        SetInfoText("$MCM_BulkCutCantShowBhvInfo")
    EndEvent
EndState

State MN_BEHAVIOR
    Event OnMenuOpenST()
        OpenMenu(Cfg.Behavior, Cfg.bhSandowPP, _behaviors)
    EndEvent

    Event OnMenuAcceptST(int index)
        If Cfg.Behavior == index
            Return
        EndIf
        Cfg.Behavior = index
        SetMenuOptionValueST(_behaviors[Cfg.Behavior])
        If Cfg.IsPumpingIron()
            ShowMessage("$MCM_PIResetSkills")
        EndIf
        ForcePageReset()
    EndEvent

    Event OnDefaultST()
        If Cfg.Behavior == Cfg.bhSandowPP
            Return
        EndIf
        Cfg.Behavior = Cfg.bhSandowPP
        SetMenuOptionValueST(_behaviors[Cfg.Behavior])
        ForcePageReset()
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_BehaviorInfo{" + SPP.Algorithm.MCMInfo() + "}")
    EndEvent
EndState

State TG_LOSEW
    Event OnSelectST()
        Cfg.CanLoseWeight = !Cfg.CanLoseWeight
        SetToggleOptionValueST(Cfg.CanLoseWeight)
        Trace("Toggled CanLoseWeight. Now " + Cfg.CanLoseWeight)
    EndEvent

    Event OnDefaultST()
        Cfg.CanLoseWeight = True
        SetToggleOptionValueST(True)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_LoseWeightInfo")
    EndEvent
EndState

State TG_DR
    Event OnSelectST()
        Cfg.DiminishingReturns = !Cfg.DiminishingReturns
        SetToggleOptionValueST(Cfg.DiminishingReturns)
    EndEvent

    Event OnDefaultST()
        Cfg.DiminishingReturns = True
        SetToggleOptionValueST(True)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_DiminishingInfo")
    EndEvent
EndState

State TG_REBOUNDW
    Event OnSelectST()
        Cfg.CanReboundWeight = !Cfg.CanReboundWeight
        SetToggleOptionValueST(Cfg.CanReboundWeight)
    EndEvent

    Event OnDefaultST()
        Cfg.CanReboundWeight = True
        SetToggleOptionValueST(True)
    EndEvent

    Event OnHighlightST()
        SetInfoText("$MCM_ReboundInfo")
    EndEvent
EndState
