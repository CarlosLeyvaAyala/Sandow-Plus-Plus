-- This module serves as an interface to comunicate with the addons.
    -- ;@Actions:
        -- Loads addons.
        -- Dispatches events to addons.
        -- ;TODO: Sets and gets values for the addons.

    -- ;@About events:
        -- Each addon has "events", which are functions that will be executed by each addon
        -- when an event comes.

        -- All events recieve a an argument supplied by the client. These argument is a table
        -- which contents will vary depending on the event.
        -- Some events will pipe that argument.

        -- "Pipe" means that the argument will be transformed by an addon, then that result
        -- will be transformed by the next adonn and so on...

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
local serpent = require("serpent")

local jc = require 'jc'
local l = require 'dmlib'
local const = require 'const'
-- local addonAll = require 'addon_all'

--;Region: Addon registering

    -- ;@readme:
        -- Add new addons here. Then register them below.
    local diminish = require 'addonDiminish'
    local anabolics = require 'addonAnabolics'

    -- ;@readme:
        -- You NEED to register addons here.
        -- The names you use here will be used for the rest of the mod to access them.
    local addOnTable = {
        [const.addon.name.diminish] = diminish,
        [const.addon.name.anabolics] = anabolics
    }

--;Region: Functionality
    local addon_mgr = {}

    local function traverse(x, func)
        for name, addon in pairs(addOnTable) do
            func(x.data, name, addon, x.extra)
        end
    end

    --;Region: Setup
        local function installAddon(data, addonName, addon)
            if(not data.addons[addonName]) then
                print("Installing '"..addonName.."'")
                data.addons[addonName] = {}
                addon.install(data)
            else
                print("'".. addonName .."' was already installed")
            end
        end

        function addon_mgr.installAll(data)
            print("Installing addons\n=================")
            traverse({data = data}, installAddon)
            print("Finished installing addons\n")
            return data
        end

    --;Region: Events
        local eventTbl

        -- If an addon has an event, adds the event to a function table.
            -- Said table may be piped, executed sequentially... whatever.
        local function gatherEvents(_, __, addon, eventName)
            local evt = addon[eventName]
            if evt then table.insert(eventTbl, evt) end
        end

        -- Executes an event pipe
        function eventPipe(eventName, x)
            eventTbl = {}
            traverse({data = data, extra = eventName}, gatherEvents)
            local p = l.pipeTbl(eventTbl)
            return p(x).val
        end

        -- Starts the pipe that calculates gain multipliers
        function addon_mgr.onGainMult(data, val, diminishBy)
            return eventPipe("onGainMult", {data = data, val = val, diminishBy = diminishBy})
        end

-- ;TODO: Delete this
addon_mgr.installAll(data)
-- print(serpent.block(data))
-- print(addon_mgr.onGainMult(data, 1, 1.00))


return addon_mgr
