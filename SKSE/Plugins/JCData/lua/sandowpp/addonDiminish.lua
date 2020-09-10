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

    -- Ratio for diminishing returns.
        -- x ∈ [0.0, 1.0] (will be forced to that, anyway)
    local ratio = l.pipe(l.ensurePercent, l.expCurve(-2.3, {x=0, y=3}, {x=1, y=0.5}) )

    function addonDiminish.onGainMult(x)
        x.val = l.boolMult(
            addon.val(x.data, name, "enabled"),
            x.val,
            l.defaultMult(ratio(x.diminishBy))
        )
        return x
    end

    function addonDiminish.install(data)
        addon.val(data, name, "enabled", true)
        addon.showInMCM(data, name, true)
    end

return addonDiminish
