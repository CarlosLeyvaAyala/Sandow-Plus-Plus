-- local dmlib = require 'dmlib'
local l = require 'shared'
local const = require 'const'

local reportWidget = {}

--;>=========================================================
--;>===                   REGISTERING                     ===
--;>=========================================================
-- local bhvTbl = {
--     [const.bhv.name.paused] = "nil",
--     [const.bhv.name.sandow] = "nil",
--     [const.bhv.name.pump] = "nil",
--     [const.bhv.name.bruce] = "nil",
--     [const.bhv.name.bulk] = "nil"
-- }
-- local traverse = l.traverse(bhvTbl)

--;>=========================================================
--;>===                 TREE GENERATION                   ===
--;>=========================================================
-- local function genBhvTrees(_, bhvName, data)
--     print("Generating '"..bhvName.."'")
--     data.bhv[bhvName] = {}
--     data.preset.bhv[bhvName] = {}
-- end

function reportWidget.generateDataTree(data)
    print("Generating widget\n=================")
    data.preset.widget = {}
    print("Finished generating widget\n")
    return data
end

return reportWidget
