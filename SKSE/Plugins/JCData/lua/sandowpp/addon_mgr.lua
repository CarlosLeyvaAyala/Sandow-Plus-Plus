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


-- local jc = require 'jc'
local l = require 'dmlib'
local const = require 'const'
-- local serpent = require("serpent")

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

    -- Iterates through all registered addons
    local function traverse(func, x)
        for name, addon in pairs(addOnTable) do
            func(addon, name, x.data, x.extra)
        end
    end

    --;Region: Setup
        local function installAddon(addon, addonName, data)
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
            traverse(installAddon, {data = data})
            print("Finished installing addons\n")
            return data
        end

    --;Region: Events
        local eventTbl

        -- If an addon has an event, adds the event to a function table.
            -- Said table may be piped, executed sequentially... whatever.
        local function gatherEvents(addon, _, __, eventName)
            local evt = addon[eventName]
            if evt then table.insert(eventTbl, evt) end
        end

        -- Fills the event table with the events found named <eventName>.
        local function fillEvtTbl(eventName)
            eventTbl = {}
            traverse(gatherEvents, {extra = eventName})
        end

        -- Creates and executes an event pipe.
            -- <x> will be sent as the parameter for the pipe.
        local function eventPipe(eventName, x)
            fillEvtTbl(eventName)
            local p = l.pipeTbl(eventTbl)
            return p(x).val
        end

        -- Starts the pipe that calculates gain multipliers
        function addon_mgr.onGainMult(data, val, diminishBy)
            return eventPipe("onGainMult", {data = data, val = val, diminishBy = diminishBy})
        end
-- print(serpent.block(data))

return addon_mgr
