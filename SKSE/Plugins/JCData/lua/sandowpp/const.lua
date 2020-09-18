local l = jrequire 'dmlib'
local const = {}

const.addon = {
    name = {
        diminish = "diminishingReturns",
        anabolics = "anabolics",
        ripped = "ripped"
    }
}
const.bhv = {
    name = {
        paused = "$MCM_PausedBehavior",
        sandow = "Sandow Plus Plus",
        pump = "Pumping Iron",
        bruce = "Bruce Lee",
        bulk = "Bulk & Cut"
    }
}
const.skills ={
    physical = {
        TwoHanded = "TwoHanded",
        OneHanded = "OneHanded",
        Block = "Block",
        Marksman = "Marksman",
        HeavyArmor = "HeavyArmor",
        LightArmor = "LightArmor",
        Sneak = "Sneak",
        Smithing = "Smithing"
    },
    magical = {
        Alteration = "Alteration",
        Conjuration = "Conjuration",
        Destruction = "Destruction",
        Illusion = "Illusion",
        Restoration = "Restoration"
    }
}

const.dangerLevels = l.enum {
    "Normal",
    "Warning",
    "Danger",
    "Critical"
 }
return const
