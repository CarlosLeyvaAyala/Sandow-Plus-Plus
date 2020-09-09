data = {
    -- Addon internal data
    addons = {
    }
}
package.path = package.path .. ";E:/Skyrim SE/MO2/mods/DM-SkyrimSE-Library/SKSE/Plugins/JCData/lua/?/init.lua"
package.path = package.path .. ";E:/Skyrim SE/MO2/mods/JContainers SE/SKSE/Plugins/JCData/lua/?/init.lua"
local serpent = require("serpent")

local jc = require 'jc'
local l = require 'dmlib'
local const = require 'const'
local addon_mgr = {}

-- Events and execute are the main thing the addon does.
--
-- When a client calls the addon manager with an event, the addon manager
--
local function loadAddon(data, addonName)
    data.addons[addonName] = {}
    data.addons[addonName].events = {}
    data.addons[addonName].execute = {}
end

-- Loads all addons into <memList>
-- memList is a submap from JDB that carries all addon info.
function addon_mgr.loadAll(data)
    print(serpent.block(data))
    -- Since Lua code can be modified on the fly, we don't need to load them from a file
    loadAddon(data, "diminishingReturns")
    loadAddon(data, "ripped")
    print(serpent.block(data))
    return data
end

addon_mgr.loadAll(data)
-- print(addons)

return addon_mgr
