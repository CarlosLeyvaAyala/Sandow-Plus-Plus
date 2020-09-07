Scriptname DM_SandowPP_TextureOnEquip Extends ReferenceAlias
{Corrects messed up ripped textures for player when (un)enquiping weapons.}

Import DM_SandowPP_Globals
Import DM_Utils

DM_SandowPP_TextureMngr Property texMgr Auto
{texture manager that applies textures.}
Keyword Property ArmorBoots Auto
Keyword Property ArmorGauntlets Auto
Keyword Property ArmorHelmet Auto
Keyword Property ArmorJewelry Auto

bool Function WontCare(Form ob)
  return ob.HasKeyword(ArmorBoots) || ob.HasKeyword(ArmorGauntlets) || ob.HasKeyword(ArmorHelmet) || ob.HasKeyword(ArmorJewelry)
EndFunction

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
  ; Trace("This actor just equipped a weapon! " + GetActorRef().GetLeveledActorBase().GetName())
  If !WontCare(akBaseObject)
    texMgr.InitPlayer()
    return
  EndIf
  ; Trace("... but I don't care")
EndEvent

Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
  If !WontCare(akBaseObject)
    texMgr.InitPlayer()
    return
  EndIf
endEvent
