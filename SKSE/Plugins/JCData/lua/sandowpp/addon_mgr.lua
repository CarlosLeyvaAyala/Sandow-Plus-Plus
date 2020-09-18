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

local l = jrequire 'dmlib'
local const = jrequire 'sandowpp.const'

-- ;>========================================================
-- ;>===               ADDON REGISTERING                ===<;
-- ;>========================================================

-- ;@readme:
-- Add new addons here. Then register them below.
local diminish = jrequire 'sandowpp.addonDiminish'
local anabolics = jrequire 'sandowpp.addonAnabolics'
local ripped = jrequire 'sandowpp.addonRipped'

-- ;@readme:
-- You NEED to register addons here.
-- The names you use here will be used for the rest of the mod to access them.

--- Table with all registered addons. You need to rigster them here before
--- you can use them.
local addOnTable = {
    [const.addon.name.diminish] = diminish,
    [const.addon.name.anabolics] = anabolics,
    [const.addon.name.ripped] = ripped
}

-- ;>========================================================
-- ;>===                 FUNCTIONALITY                  ===<;
-- ;>========================================================

local addon_mgr = {}

--- Iterates through all registered addons and executes `f(x)`.
---@param func function () end
---@param x any
local function traverse(func, x)
    for name, addon in pairs(addOnTable) do
        func(addon, name, x.data, x.extra)
    end
end

-- ;>========================================================
-- ;>===                     SETUP                      ===<;
-- ;>========================================================

--- Loads an individual addon to memory.
local function installAddon(addon, addonName, data)
    -- data.addons[addonName] = {}
    if not data.addons[addonName].installed then
        addon.install(data)
        data.addons[addonName].installed = true
    end
end

--- Loads addon basic data to the data tree.
--- @param data table
function addon_mgr.installAll(data)
    -- debug.getinfo(1)
    traverse(installAddon, {data = data})
    return data
end


-- ;>========================================================
-- ;>===                TREE GENERATION                 ===<;
-- ;>========================================================

local function genAddonTrees(_, addonName, data)
    print("Generating '"..addonName.."'")
    data.addons[addonName] = {}
    data.preset.addons[addonName] = {}
end

function addon_mgr.generateDataTree(data)
    print("Generating addons\n=================")
    data.preset.addons = {}
    traverse(genAddonTrees, {data = data})
    print("Finished generating addons\n")
    return data
end


-- ;>========================================================
-- ;>===                     EVENTS                     ===<;
-- ;>========================================================

local eventTbl = {}

--- If an addon has an event, adds the event to a function table that will be executed later.
--- Said table may be piped, executed sequentially... whatever.
local function gatherEvents(addon, _, __, eventName)
    local evt = addon[eventName]
    if evt then table.insert(eventTbl, evt) end
end

--- Fills the event table with the events found named `eventName`.
local function fillEvtTbl(eventName)
    eventTbl = {}
    traverse(gatherEvents, {extra = eventName})
end

--- Creates and executes an event pipe.
--- `x` will be sent as the parameter for the pipe.
---@return number
---@param eventName string
---@param x table
local function eventPipe(eventName, x)
    fillEvtTbl(eventName)
    if #eventTbl > 0 then
        local p = l.pipeTbl(eventTbl)
        return p(x).val
    else
        return x.val
    end
end

--- Starts the pipe that calculates gain multipliers.
---@param data table
---@param val number
---@param diminishBy number
function addon_mgr.onGainMult(data, val, diminishBy)
    -- local k = {x = {y=12}, 23}
    -- assert(k.x.y == 22, "22")
    -- return k.x.y
    return eventPipe("onGainMult", {data = data, val = val, diminishBy = diminishBy})
end

return addon_mgr
