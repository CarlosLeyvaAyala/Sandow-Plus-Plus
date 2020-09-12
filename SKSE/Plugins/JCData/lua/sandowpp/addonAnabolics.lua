-- No better anabolics than hard work, good diet, dedication, and training 32 hours
-- a day, bitches!

    -- ;WARNING: This doesn't use true inheritance.
    --  The main idea of this mod is series of functions that accept a global configuration
    -- and make calculations based on it.

local l = require 'dmlib'
local addon = require 'addon_all'
local const = require 'const'

local addonAnabolics = {}
local name = const.addon.name.anabolics      -- This plugin name

addonAnabolics.showInMCM = addon.internalProp(name, addon.names.showInMCM)

-- function addonAnabolics.onGainMult(x)
--     x.val = x.val * 10
--     return x
-- end

function addonAnabolics.install(data)
    addonAnabolics.showInMCM(data, true)
end

return addonAnabolics
