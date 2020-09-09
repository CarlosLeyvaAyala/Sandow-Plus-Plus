-- package.path = package.path .. ";E:/Skyrim SE/MO2/mods/DM-SkyrimSE-Library/SKSE/Plugins/JCData/lua/?/init.lua"

local dmlib = jrequire 'dmlib'
local bhv_all = jrequire 'sandowpp.bhv_all'
local sandowpp = {}

sandowpp.diminishingRatio = bhv_all.diminishingRatio
print("sandowpp.diminishingRatio(0)")
print(sandowpp.diminishingRatio(0))
return sandowpp
