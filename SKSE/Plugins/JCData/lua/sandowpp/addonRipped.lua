-- No better anabolics than hard work, good diet, dedication, and training 32 hours
-- a day, bitches!

    -- ;WARNING: This doesn't use true inheritance.
    --  The main idea of this mod is series of functions that accept a global configuration
    -- and make calculations based on it.

local addon = require 'addon_all'
local const = require 'const'

local addonRipped = {}
local name = const.addon.name.ripped      -- This plugin name

addonRipped.showInMCM = addon.internalProp(name, addon.names.showInMCM)
addonRipped.daysForMin = addon.MCMProp(name, "daysForMin")
addonRipped.daysForMax = addon.MCMProp(name, "daysForMax")
addonRipped.currentRipped = addon.MCMProp(name, "currentRipped")

-- function addonAnabolics.onGainMult(x)
--     x.val = x.val * 10
--     return x
-- end

function addonRipped.install(data)
    addonRipped.showInMCM(data, true)
    addonRipped.daysForMin(data, 30)
    addonRipped.daysForMax(data, 120)
    addonRipped.currentRipped(data, 0)
end

return addonRipped
