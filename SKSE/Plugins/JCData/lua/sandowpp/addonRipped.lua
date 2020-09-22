-- No better anabolics than hard work, good diet, dedication, and training 32 hours
-- a day, bitches!

    -- ;WARNING: This doesn't use true inheritance.
    --  The main idea of this mod is series of functions that accept a global configuration
    -- and make calculations based on it.

local addon = jrequire 'sandowpp.addon_all'
local const = jrequire 'sandowpp.const'

local addonRipped = {}
local name = const.addon.name.ripped      -- This plugin name

addonRipped.showInMCM = addon.internalProp(name, addon.names.showInMCM)

--- Current muscle def. Used for constant def or values set by behavior.
addonRipped.currDef = addon.MCMProp(name, "currDef")

--- x ∈ [0, 1]
addonRipped.minAlpha = addon.MCMProp(name, "minAlpha")

--- x ∈ [0, 1]
addonRipped.maxAlpha = addon.MCMProp(name, "maxAlpha")

addonRipped.daysForMin = addon.MCMProp(name, "daysForMin")
addonRipped.daysForMax = addon.MCMProp(name, "daysForMax")

addonRipped.mode = addon.MCMProp(name, "mode")
addonRipped.modes = {
    none = "$None",
    const = "$Constant",
    weight= "$By weight",
    wInv = "$By weight inv",
    skills = "$By skills"
}

function addonRipped.install(data)
    addonRipped.showInMCM(data, true)
    addonRipped.daysForMin(data, 30)
    addonRipped.daysForMax(data, 120)
    addonRipped.minAlpha(data, 0)
    addonRipped.maxAlpha(data, 100)
    addonRipped.mode(data, addonRipped.modes.none)
    addonRipped.currDef(data, 0)
    -- addonRipped.interpolate(data, false)
end

return addonRipped
