-- Main script for Sandow++ mod.
-- This serves as a hub for executing all code, since it seems JContainers can't access
-- other files than init.lua inside a module dir and I don't feel like creating dozens
-- of folders for accessing mod functions.

-- ;@ignore: this data is only for testing and developing
local data = {
    -- Addon internal data
    addons = {
    }
}

package.path = package.path..";E:/Skyrim SE/MO2/mods/DM-SkyrimSE-Library/SKSE/Plugins/JCData/lua/?/init.lua"
package.path = package.path..";E:/Skyrim SE/MO2/mods/JContainers SE/SKSE/Plugins/JCData/lua/?/init.lua"

-- local dmlib = require 'dmlib'
-- local bhv_all = require 'bhv_all'
local addon_mgr = require 'addon_mgr'

local sandowpp = {}

sandowpp.installAddons = addon_mgr.installAll
--  sandowpp.installAddons(data)
--  print(addon_mgr.onGainMult(data, 1, 1.00))
--  print(addon_mgr.onGainMult(data, 1, 0.00))
return sandowpp
