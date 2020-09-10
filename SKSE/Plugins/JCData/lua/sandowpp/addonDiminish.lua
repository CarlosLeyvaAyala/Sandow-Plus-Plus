-- Diminishing returns means to have "noob gains". The more advanced you are, the
-- more hard is to keep advancing.

    -- ;WARNING: This doesn't use true inheritance.
    --  The main idea of this mod is series of functions that accept a global configuration
    -- and make calculations based on it.

local l = require 'dmlib'
local addon = require 'addon_all'
local const = require 'const'

local name = const.addon.name.diminish      -- This plugin name
local addonDiminish = {}

--- Ratio for diminishing returns.
--- x ∈ [0.0, 1.0] (will be forced to that, anyway)
local ratio = l.pipe(l.ensurePercent, l.expCurve(-2.3, {x=0, y=3}, {x=1, y=0.5}) )

--- Property.
--- @param data table
---@param x boolean
--- @return boolean
function addonDiminish.enabled(data, x)
    if x ~= nil then addon.val(data, name, "enabled", x)
    else return addon.val(data, name, "enabled")
    end
end

--- Event executed for getting a number multiplier for gains.
--- @param x table
function addonDiminish.onGainMult(x)
    x.val = l.boolMult(
        addonDiminish.enabled(x.data),
        x.val,
        l.defaultMult(ratio(x.diminishBy))
    )
    return x
end

--- Loads this addon data to the data table.
--- @param data table
function addonDiminish.install(data)
    addon.val(data, name, "enabled", true)
    addon.showInMCM(data, name, true)
end

return addonDiminish
