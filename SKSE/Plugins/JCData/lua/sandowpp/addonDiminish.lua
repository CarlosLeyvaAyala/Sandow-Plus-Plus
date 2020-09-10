-- Diminishing returns means to have "noob gains". The more advanced you are, the
-- more hard is to keep advancing.
--
-- ;WARNING: This doesn't use true inheritance.
-- The only way to call these functions is by the Addon Manager, who is the only
-- one who knows addons names. That way things can be kept more centralized.

package.path = package.path .. ";E:/Skyrim SE/MO2/mods/DM-SkyrimSE-Library/SKSE/Plugins/JCData/lua/?/init.lua"
package.path = package.path .. ";E:/Skyrim SE/MO2/mods/JContainers SE/SKSE/Plugins/JCData/lua/?/init.lua"

local l = require 'dmlib'
local addon = require 'addon_all'
local const = require 'const'

local addonDiminish = {}

-- Ratio for diminishing returns.
    -- x ∈ [0.0, 1.0] (will be forced to that, anyway)
    --
    -- ;@usage:
        -- ratio(x)
local ratio = l.pipe(l.ensurePercent, l.expCurve(-2.3, {x=0, y=3}, {x=1, y=0.5}) )

function addonDiminish.install(data, addonName)
    addon.showInMCM(data, addonName, true)
    addon.installEvent(data, addonName, const.addon.events.onGainMult, addon.onGainMult)
end

return addonDiminish
