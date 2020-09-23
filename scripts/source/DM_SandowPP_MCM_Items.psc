Scriptname DM_SandowPP_MCM_Items extends DM_SandowPP_MCM_Widget Hidden

; Import DM_Utils
; Import DM_SandowPP_Globals
int Function PageMainItems()
    Header("$Items")
    Button("btnMain_Sacks", "$Weight sacks", "$Distribute", FlagByBool(!SPP.Items.WeightSacksDistributed) )
    Button("btnMain_Anabol", "$Weight gainers", "$Distribute", FlagByBool(!SPP.Items.SillyDistributed) )
EndFunction

State btnMain_Sacks
    Event OnSelectST()
        SPP.Items.DistributeWeightSacks()
        ShowMessage("$MCM_ItemsSacks", False)
        SetOptionFlagsST(OPTION_FLAG_DISABLED, False, "btnMain_Sacks")
    EndEvent
EndState

State btnMain_Anabol
    Event OnSelectST()
        SPP.Items.DistributeSilly()
        ShowMessage("$MCM_ItemsAnabolics", False)
        SetOptionFlagsST(OPTION_FLAG_DISABLED, False, "btnMain_Anabol")
    EndEvent
EndState
