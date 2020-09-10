-- This module serves as an interface to comunicate with the addons.

-- ;@Responsibilities:
    -- Loads addons.
    -- Sets and gets values for the addons.
    -- Dispatches events to addons.

-- ;@About events:
    -- Each addon has "events", which are functions that will be executed by each addon
    -- when an event comes. "eventArgs", both from manager and plugin level will be
    -- supplied by the manager to each addon, so they can do their job.

    -- Each event has one entry at "eventArgs" at manager level, so that value will piped
    -- to each addon.
    -- A client (most likely a Behavior) needs to set these "eventArgs" at manager level.

    -- There's also "eventArgs" at plugin level. These arguments are not piped because they
    -- are exclusive to each plugin. That value needs to be supplied by a client, as well.

    -- "Pipe" means that the argument will be transformed by some function in an addon,
    -- then that result will be transformed by the next adonn and so on...

-- ;@Available events:
    -- onGainBase
        -- Expects a number that will be added in a pipe.
    -- onGainBMult
        -- Expects a number that will be multiplied in a pipe.
    -- onLossBase
        -- Expects a number that will be added in a pipe.
    -- onLossMult
        -- Expects a number that will be multiplied in a pipe.
    -- onBeforeSleep
        -- Won't be piped. Will most likely be a pre processing operation.
    -- onAfterSleep
        -- Won't be piped. Will most likely be a post rocessing operation.
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

--;>=========================================================
-- Addons
    -- ;@readme:
    -- Add new addons here. Then register them below.
local diminish = require 'addonDiminish'
local ripped = {}

-- ;@readme:
    -- You NEED to register addons here.
    -- The names you use here will be used for the rest of the mod to access them.
local addOnTable = {
    [const.addon.name.diminish] = diminish
    -- [const.addon.name.ripped] = ripped
}

--;>=========================================================
local addon_mgr = {}

local function installAddon(data, addonName)
    if(not data.addons[addonName]) then
        data.addons[addonName] = {}
        data.addons[addonName].events = {}
        data.addons[addonName].eventArgs = {}
    else
        print("================================")
        print("Addon '".. addonName .."' was already installed")
    end
end

function addon_mgr.installAll(data)
    for name, _ in pairs(addOnTable) do
        installAddon(data, name)
    end
    return data
end

print("================================")
print("Before")
print("================================")
print(serpent.block(data))
addon_mgr.installAll(data)
addon_mgr.installAll(data)
print("================================")
print("After")
print("================================")
print(serpent.block(data))
-- addon_mgr.installAll(data)

return addon_mgr
