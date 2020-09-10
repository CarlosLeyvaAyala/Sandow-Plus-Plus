-- Main script for Sandow++ mod.
    -- This serves as a hub for executing all code, since it seems JContainers can't access
    -- other files than init.lua inside a module dir and I don't feel like creating dozens
    -- of folders for accessing mod functions.

package.path = package.path..";E:/Skyrim SE/MO2/mods/DM-SkyrimSE-Library/SKSE/Plugins/JCData/lua/?/init.lua"
package.path = package.path..";E:/Skyrim SE/MO2/mods/JContainers SE/SKSE/Plugins/JCData/lua/?/init.lua"

local dmlib = require 'dmlib'
-- local bhv_all = require 'bhv_all'
local addon_mgr = require 'addon_mgr'

local sandowpp = {}

sandowpp.installAddons = addon_mgr.installAll
return sandowpp
