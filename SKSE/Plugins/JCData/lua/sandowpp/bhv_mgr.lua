local dml = jrequire 'dmlib'
local l = jrequire 'sandowpp.shared'
local const = jrequire 'sandowpp.const'
local bhv_all = jrequire 'sandowpp.bhv_all'
local reportWidget = jrequire 'sandowpp.reportWidget'

local bhv_mgr = {}

-- ;>========================================================
-- ;>===                  REGISTERING                   ===<;
-- ;>========================================================
local bhvBruce = jrequire 'sandowpp.bhvBruce'

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
    bhv_all.canLose(data, true)
    bhv_mgr.changeBhv(data, const.bhv.name.bruce)
    return data
end


-- ;>========================================================
-- ;>===                      CORE                      ===<;
-- ;>========================================================
local function currBhv(data) return bhvTbl[data.preset.bhv.current] end

--- Determines if meters should be visible if max/min.
local function meterVisibility(data)
    --- returns if a meter should be visible and if its visibility changed.
    local function mVisible(data, meterName)
        local oldVisible = reportWidget.mVisible(data, meterName)
        local function shouldHide(condition)
            if condition then return false, oldVisible
            else return true, oldVisible ~= true
            end
        end

        if reportWidget.hideAtMin(data) then
            return shouldHide(reportWidget.mPercent(data, meterName) <= 0)
        elseif reportWidget.hideAtMax(data) then
            return shouldHide(reportWidget.mPercent(data, meterName) >= 1)
        end
        return oldVisible, false
    end

    local function testM(data, meterName)
        local visible, changed = mVisible(data, meterName)
        reportWidget.mVisible(data, meterName, visible)
        reportWidget.tweenToPos(data, changed or reportWidget.tweenToPos(data))
    end

    -- Meters 1 and 2 are the only ones that change visibility based on fullness
    for i = 1, 2 do testM(data, "meter"..i) end

    return data
end

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
    local flash
    data, flash = currBhv(data).onSleep(data)
    reportWidget.mFlash(data, "meter1", flash)
    return bhv_mgr.onReport(data)
end

function bhv_mgr.onReport(data)
    data = currBhv(data).report(data) or data
    data = meterVisibility(data)
    data = reportWidget.mCalcPositions(data)
    return data
end

function bhv_mgr.getMcmData(data)
    return currBhv(data).getMcmData(data) or data
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

-- ;>========================================================
-- ;>===                   INTERFACE                    ===<;
-- ;>========================================================

function bhv_mgr.canGainWGP(data)
    return (currBhv(data).canGainWGP ~= nil) or true
end

return bhv_mgr
