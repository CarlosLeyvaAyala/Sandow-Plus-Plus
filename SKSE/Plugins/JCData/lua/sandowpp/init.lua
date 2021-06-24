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

-- package.path = package.path..";E:/Skyrim SE/MO2/mods/DM-SkyrimSE-Library/SKSE/Plugins/JCData/lua/?/init.lua"
-- package.path = package.path..";E:/Skyrim SE/MO2/mods/JContainers SE/SKSE/Plugins/JCData/lua/?/init.lua"

local l = jrequire 'dmlib'
local addon_mgr = jrequire 'sandowpp.addon_mgr'
local bhv_mgr = jrequire 'sandowpp.bhv_mgr'
local reportWidget = jrequire 'sandowpp.reportWidget'
local skills = jrequire 'sandowpp.skills'

local sandowpp = {}

-- ;@ignore: this data is only for testing and developing
local data = {
    addons={}, bhv={}, preset={}, widget={}, state={}
}

-- ;>========================================================
-- ;>===                   INTERFACES                   ===<;
-- ;>========================================================
sandowpp.installAddons = addon_mgr.installAll
sandowpp.repositionWidget = reportWidget.mCalcPositions
sandowpp.onSleep = bhv_mgr.onSleep
sandowpp.onReport = bhv_mgr.onReport
sandowpp.realTimeCalc = bhv_mgr.realTimeCalc
sandowpp.getMcmData = bhv_mgr.getMcmData
sandowpp.changeHAlign = reportWidget.changeHAlign
sandowpp.changeVAlign = reportWidget.changeVAlign

function sandowpp.getDefaults(aData)
    local p = l.pipe(
        reportWidget.default,
        bhv_mgr.default,
        skills.default
    )
    aData = p(aData)
    aData.defaultsInit = true
    return aData
end

--- Registers a training point gained by the player.
function sandowpp.train(aData, skName)
    local train, fatigue = skills.trainingAndFatigue(aData, skName)
    if train and train > 0 and bhv_mgr.canGainWGP(aData) then
        sandowpp.trainAndFatigue(aData, train, fatigue)
    end
    return aData
end

--- Registers training and fatigue gained by the player.
--- This needs to be accessible to Papyrus because weight sacks directly call this.
function sandowpp.trainAndFatigue(aData, train, fatigue)
    aData.state.skillFatigue = (aData.state.skillFatigue or 0) + (train * fatigue)
    aData.state.WGP = aData.state.WGP + train
    aData.state.lastActive = -1
    return aData
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

local function genPlayerData(aData)
    local s = aData.state
    s.WGP = 0
    s.hoursSlept = 10
    s.hoursInactive = 5000
    s.hoursAwaken = 02000
    s.weight = 050

    return aData
end

local function testTrain(aData)
    sandowpp.train(aData, "TwoHanded")
    sandowpp.train(aData, "TwoHanded")
    sandowpp.train(aData, "TwoHanded")
    sandowpp.train(aData, "TwoHanded")
    sandowpp.train(aData, "TwoHanded")
    sandowpp.train(aData, "TwoHanded")
    sandowpp.train(aData, "TwoHanded")
    sandowpp.train(aData, "TwoHanded")
    sandowpp.train(aData, "TwoHanded")
    sandowpp.train(aData, "Enchanting")
    sandowpp.train(aData, "OneHanded")
    sandowpp.train(aData, "Sneak")
    sandowpp.train(aData, "Sneak")
    sandowpp.train(aData, "Alteration")
    sandowpp.train(aData, "Alteration")
    return aData
end

local function simulateDays(aData)
    print("Simulating training days")
    print("==================================")
    local days = 1
    for i = 1, days do
        print("Day ".. i)
        print("===============")
        aData = testTrain(aData)
        aData = sandowpp.onSleep(aData)
        print("")
    end

    return aData
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
    return data
end


return sandowpp
