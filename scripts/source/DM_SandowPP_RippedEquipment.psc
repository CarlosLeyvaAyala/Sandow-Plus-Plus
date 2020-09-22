Scriptname DM_SandowPP_RippedEquipment extends ReferenceAlias
{Updates texture set when (un)equiping armor.}

Import DM_SandowPP_Globals

DM_SandowPP_TextureMngr Property texMgr Auto
Keyword Property ArmorBoots Auto
Keyword Property ArmorGauntlets Auto
Keyword Property ArmorJewelry Auto
Keyword Property ArmorShield Auto
Keyword Property ArmorHelmet Auto

bool Function IsInvalid(Form o)
    return o.HasKeyword(ArmorBoots) || o.HasKeyword(ArmorGauntlets) || o.HasKeyword(ArmorJewelry) ||\
        o.HasKeyword(ArmorShield) || o.HasKeyword(ArmorHelmet)
EndFunction

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
    ; Utility.Wait(0.2)
    If !IsInvalid(akBaseObject)
        texMgr.MakePlayerRipped()
    EndIf
EndEvent

Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
    If !IsInvalid(akBaseObject)
        texMgr.MakePlayerRipped()
    EndIf
EndEvent
