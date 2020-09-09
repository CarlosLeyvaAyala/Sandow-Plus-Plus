package.path = package.path .. ";E:/Skyrim SE/MO2/mods/DM-SkyrimSE-Library/SKSE/Plugins/JCData/lua/?/init.lua"

local dmlib = require 'dmlib'
local bhv_all = {}

-- Ratio for diminishing returns.
--      x ∈ [0.0, 1.0]
bhv_all.diminishingRatio = dmlib.pipe(dmlib.ensurePercent, dmlib.expCurve(-2.3, {x=0, y=3}, {x=1, y=0.5}) )

return bhv_all
