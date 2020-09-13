-- Diminishing returns means to have "noob gains". The more advanced you are, the
-- more hard is to keep advancing.

    -- ;WARNING: This doesn't use true inheritance.
    --  The main idea of this mod is series of functions that accept a global configuration
    -- and make calculations based on it.

local l = jrequire 'dmlib'
local addon = jrequire 'sandowpp.addon_all'
local const = jrequire 'sandowpp.const'

local name = const.addon.name.diminish      -- This plugin name
local addonDiminish = {}

-- ;>========================================================
-- ;>===                   PROPERTIES                   ===<;
-- ;>========================================================

addonDiminish.showInMCM = addon.internalProp(name, addon.names.showInMCM)
addonDiminish.enabled = addon.MCMProp(name, addon.names.enabled)


-- ;>========================================================
-- ;>===                      CORE                      ===<;
-- ;>========================================================

--- Ratio for diminishing returns.
--- x ∈ [0.0, 1.0] (will be forced to that, anyway)
local ratio = l.pipe(l.ensurePercent, l.expCurve(-2.3, {x=0, y=3}, {x=1, y=0.5}) )

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
    -- addon.val(data, name, "enabled", true)
    addonDiminish.enabled(data, true)
    addonDiminish.showInMCM(data, true)
end

return addonDiminish
