Scriptname DM_SandowPP_SkeletonNodes Hidden
{Names of the skeleton nodes. These were taken from RaceMenuPlugin}

;string Property NINODE_NPC = "NPC" AutoReadOnly
string Function NINODE_HEAD() Global
    Return "NPC Head [Head]" 
EndFunction

;string Property NINODE_LEFT_BREAST = "NPC L Breast" AutoReadOnly
;string Property NINODE_RIGHT_BREAST = "NPC R Breast" AutoReadOnly
;string Property NINODE_LEFT_BUTT = "NPC L Butt" AutoReadOnly
;string Property NINODE_RIGHT_BUTT = "NPC R Butt" AutoReadOnly
;string Property NINODE_LEFT_BREAST_FORWARD = "NPC L Breast01" AutoReadOnly
;string Property NINODE_RIGHT_BREAST_FORWARD = "NPC R Breast01" AutoReadOnly
;string Property NINODE_LEFT_BICEP = "NPC L UpperarmTwist1 [LUt1]" AutoReadOnly
;string Property NINODE_RIGHT_BICEP = "NPC R UpperarmTwist1 [RUt1]" AutoReadOnly
;string Property NINODE_LEFT_BICEP_2 = "NPC L UpperarmTwist2 [LUt2]" AutoReadOnly
;string Property NINODE_RIGHT_BICEP_2 = "NPC R UpperarmTwist2 [RUt2]" AutoReadOnly
;
;string Property NINODE_QUIVER = "QUIVER" AutoReadOnly
;string Property NINODE_BOW = "WeaponBow" AutoReadOnly
;string Property NINODE_AXE = "WeaponAxe" AutoReadOnly
;string Property NINODE_SWORD = "WeaponSword" AutoReadOnly
;string Property NINODE_MACE = "WeaponMace" AutoReadOnly
;string Property NINODE_SHIELD = "SHIELD" AutoReadOnly
;string Property NINODE_WEAPON_BACK = "WeaponBack" AutoReadOnly
;string Property NINODE_WEAPON = "WEAPON" AutoReadOnly

bool Function SkelNodeExists(Actor aActor, string aNode) Global
    Return NetImmerse.HasNode(aActor, aNode, False)
EndFunction