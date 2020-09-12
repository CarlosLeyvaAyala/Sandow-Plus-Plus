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

function sandowpp.getDefaults(data)
    local p = l.pipe(
        reportWidget.default,
        bhv_mgr.default,
        skills.default
    )
    return p(data)
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

--- See `_test.lua` at:
--- https://github.com/CarlosLeyvaAyala/Sandow-Plus-Plus
function sandowpp.runTest()
    local p = l.pipe(
        sandowpp.generateDataTree,
        sandowpp.installAddons,
        sandowpp.getDefaults
    )
    data = p(data)
    print(addon_mgr.onGainMult(data, 1, 0))
    print(addon_mgr.onGainMult(data, 1, 1))
    return data
end

return sandowpp
