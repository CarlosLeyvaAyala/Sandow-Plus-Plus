-- Main script for Sandow++ mod.
--===================================================
-- This serves as a hub for executing all code, since it seems JContainers can't access
-- other files than init.lua inside a module dir and I don't feel like creating dozens
-- of folders for accessing mod functions.

-- As usual, some hacks and workarounds are expected when programming for Skyrim.
-- In this case, the whole Lua code loads and unloads each time we want to run it
-- and we exchange data with Skyrim using tables, so instead of thinking about
-- classes, inhertitance and such, we think about functions that transform data.

-- ;WARNING: READ THIS
-- Another caveat is that it seems like JC objects can't insert new tables on the
-- fly directly from Lua, so many design choices and workarounds were made in account
-- for this (maybe we need to create a JObject instead of a table?).
-- Fortunately, tables seem to be properly allocating inside Lua structrues themselves.

package.path = package.path..";E:/Skyrim SE/MO2/mods/DM-SkyrimSE-Library/SKSE/Plugins/JCData/lua/?/init.lua"
package.path = package.path..";E:/Skyrim SE/MO2/mods/JContainers SE/SKSE/Plugins/JCData/lua/?/init.lua"

local l = require 'dmlib'
local addon_mgr = require 'addon_mgr'
local bhv_mgr = require 'bhv_mgr'
local reportWidget = require 'reportWidget'
local skills = require 'skills'

local sandowpp = {}

-- ;@ignore: this data is only for testing and developing
local data = {
    addons={}, bhv={}, preset={}, widget={}, state={}
}

-- ;>========================================================
-- ;>===                   INTERFACES                   ===<;
-- ;>========================================================
sandowpp.installAddons = addon_mgr.installAll
sandowpp.widgetChangeVAlign = reportWidget.changeVAlign
sandowpp.onSleep = bhv_mgr.onSleep

function sandowpp.getDefaults(data)
    local p = l.pipe(
        reportWidget.default,
        bhv_mgr.default,
        skills.default
    )
    return p(data)
end

--- Registers a training point gained by the player.
function sandowpp.train(data, skName, now)
    local train, fatigue = skills.trainingAndFatigue(data, skName)
    if train and bhv_mgr.canGainWGP(data) then
        data.state.skillFatigue = (data.state.skillFatigue or 0) + (train * fatigue)
        data.state.WGP = data.state.WGP + train
        data.state.lastActive = now
    end
    return data
end

-- ;>========================================================
-- ;>===                TREE GENERATION                 ===<;
-- ;>========================================================

--- See `_treeGen.lua` at:
--- https://github.com/CarlosLeyvaAyala/Sandow-Plus-Plus
function sandowpp.generateDataTree()
    local p = l.pipe(
        addon_mgr.generateDataTree,
        bhv_mgr.generateDataTree,
        reportWidget.generateDataTree,
        skills.generateDataTree
    )
    return p(data)
end


-- ;>========================================================
-- ;>===                    TESTING                     ===<;
-- ;>========================================================

local function genPlayerData(data)
    local s = data.state
    s.WGP = 0
    s.hoursSlept = 10
    s.hoursInactive = 14
    s.hoursAwaken = 20
    s.weight = 100

    return data
end

local function testTrain(data)
    sandowpp.train(data, "TwoHanded", 1)
    sandowpp.train(data, "Enchanting", 1)
    sandowpp.train(data, "OneHanded", 1)
    sandowpp.train(data, "Sneak", 1)
    sandowpp.train(data, "Alteration", 1)
    return data
end

local function simulateDays(data)
    print("Simulating training days")
    print("==================================")
    for i = 1, 15 do
        print("Day ".. i)
        print("===============")
        data = testTrain(data)
        data = sandowpp.onSleep(data)
        print("")
    end

    return data
end
--- See `_test.lua` at:
--- https://github.com/CarlosLeyvaAyala/Sandow-Plus-Plus
function sandowpp.runTest()
    local p = l.pipe(
        sandowpp.generateDataTree,
        sandowpp.installAddons,
        genPlayerData,
        sandowpp.getDefaults,
        simulateDays
    )
    data = p(data)
    -- print(addon_mgr.onGainMult(data, 1, 0))
    -- print(addon_mgr.onGainMult(data, 1, 1))
    return data
end


return sandowpp
