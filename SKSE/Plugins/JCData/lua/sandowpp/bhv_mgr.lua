-- local dmlib = jrequire 'dmlib'
local l = jrequire 'sandowpp.shared'
local const = jrequire 'sandowpp.const'

local bhv_mgr = {}

--;>=========================================================
--;>===                   REGISTERING                     ===
--;>=========================================================
local bhvTbl = {
    [const.bhv.name.paused] = "nil",
    [const.bhv.name.sandow] = "nil",
    [const.bhv.name.pump] = "nil",
    [const.bhv.name.bruce] = "nil",
    [const.bhv.name.bulk] = "nil"
}
local traverse = l.traverse(bhvTbl)

--;>=========================================================
--;>===                 TREE GENERATION                   ===
--;>=========================================================
local function genBhvTrees(_, bhvName, data)
    print("Generating '"..bhvName.."'")
    data.bhv[bhvName] = {}
    data.preset.bhv[bhvName] = {}
end

function bhv_mgr.generateDataTree(data)
    print("Generating behaviors\n=================")
    data.preset.bhv = {}
    data.preset.bhv.all = {}
    traverse(genBhvTrees, {data = data})
    print("Finished generating behaviors\n")
    return data
end

return bhv_mgr
