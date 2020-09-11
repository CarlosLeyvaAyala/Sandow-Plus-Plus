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
-- for this.
-- Fortunately, tables seem to be properly allocating inside Lua structrues themselves.

-- ;@ignore: this data is only for testing and developing
local data = {
    addons={}, bhv={}, preset={}, widget={}, state={}
}

package.path = package.path..";E:/Skyrim SE/MO2/mods/DM-SkyrimSE-Library/SKSE/Plugins/JCData/lua/?/init.lua"
package.path = package.path..";E:/Skyrim SE/MO2/mods/JContainers SE/SKSE/Plugins/JCData/lua/?/init.lua"

local l = require 'dmlib'
-- local bhv_all = require 'bhv_all'
local addon_mgr = require 'addon_mgr'
local bhv_mgr = require 'bhv_mgr'
local reportWidget = require 'reportWidget'

local sandowpp = {}

--- Pre-generate the data tree used by this mod. Since the embedded Lua
--- interpreter can't allocate tables from these scripts, we generate
--- `bare tree.json` using this function.
local function generateDataTree()
    local p = l.pipe(
        addon_mgr.generateDataTree,
        bhv_mgr.generateDataTree,
        reportWidget.generateDataTree
    )
    p(data)
end

--- Comment this for release.
generateDataTree()


sandowpp.installAddons = addon_mgr.installAll
sandowpp.installAddons(data)
print(addon_mgr.onGainMult(data, 1, 1.00))
print(addon_mgr.onGainMult(data, 1, 0.00))
local luna = require 'lunajson'
print( luna.encode(data) )

return sandowpp
