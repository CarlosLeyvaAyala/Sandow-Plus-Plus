local dml = require 'dmlib'
local l = require 'shared'
local const = require 'const'

local bhv_mgr = {}

-- ;>========================================================
-- ;>===                  REGISTERING                   ===<;
-- ;>========================================================
local bhvBruce = require 'bhvBruce'

local bhvTbl = {
    [const.bhv.name.paused] = "nil",
    [const.bhv.name.sandow] = "nil",
    [const.bhv.name.pump] = "nil",
    [const.bhv.name.bruce] = bhvBruce,
    [const.bhv.name.bulk] = "nil"
}
local traverse = l.traverse(bhvTbl)

-- ;>========================================================
-- ;>===                     SETUP                      ===<;
-- ;>========================================================

--- Initializes one specific behavior.
local function initBhv(bhv, _, data)
    if bhv.init then bhv.init(data) end
end

--- Generates default values for behaviors.
function bhv_mgr.default(data)
    traverse(initBhv, {data = data})
    bhv_mgr.changeBhv(data, const.bhv.name.bruce)
    return data
end

-- ;>========================================================
-- ;>===                      CORE                      ===<;
-- ;>========================================================
local function currBhv(data) return bhvTbl[data.preset.bhv.current] end

function bhv_mgr.changeBhv(data, newBhv)
    if newBhv == data.preset.bhv.current then return end

    print("New behavior: "..newBhv)
    local _currBhv = currBhv(data)
    if _currBhv then _currBhv.onExit(data) end
    data.preset.bhv.current = newBhv
    _currBhv = bhvTbl[data.preset.bhv.current]
    _currBhv.onEnter(data)
end

function bhv_mgr.onSleep(data)
    currBhv(data).onSleep(data)
end

-- ;>========================================================
-- ;>===                TREE GENERATION                 ===<;
-- ;>========================================================

local function genBhvTrees(_, bhvName, data)
    print("Generating '"..bhvName.."'")
    data.bhv[bhvName] = {}
    data.preset.bhv[bhvName] = {}
end

function bhv_mgr.generateDataTree(data)
    print("Generating behaviors\n=================")
    data.preset.bhv = {}
    traverse(genBhvTrees, {data = data})

    print("Finished generating behaviors\n")
    return data
end

return bhv_mgr
