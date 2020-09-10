-- Functions and structures shared by all addons.
-- Notice this isn't true inheritance. No need for that.

package.path = package.path .. ";E:/Skyrim SE/MO2/mods/DM-SkyrimSE-Library/SKSE/Plugins/JCData/lua/?/init.lua"

local l = require 'dmlib'

local addon_all = {}

--;>=========================================================
--;> Access
    function addon_all.modVal(data, addon, name, value)
        data.addons[addonName][name] = value
    end

    function addon_all.showInMCM(data, addon, show)
        addon_all.modVal(data, addon, "showInMCM", value)
    end

--;>=========================================================
--;> Generic event handlers
    function onGainMult(x)

--;>=========================================================
--;> Event setting
    -- Sets an event so an addon can respond to it.
    function addon_all.setEvent(data, addon, event, callback)
        data.addons[addonName].events.[event] = callback
    end

    -- Creates an event so an addon can respond to it.
    function addon_all.installEvent(data, addon, event, callback)
        if not data.addons[addonName].events then data.addons[addonName].events = {} end
        addon_all.setEvent(data, addon, event, callback)
    end

return addon_all
