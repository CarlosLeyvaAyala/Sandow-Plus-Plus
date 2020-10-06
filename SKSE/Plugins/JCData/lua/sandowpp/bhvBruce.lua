local l = jrequire 'dmlib'
local c = jrequire 'sandowpp.const'
local rip = jrequire 'sandowpp.addonRipped'
local bhv_all = jrequire 'sandowpp.bhv_all'
local reportWidget = jrequire 'sandowpp.reportWidget'
local sh = jrequire 'sandowpp.shared'

local bhvBruce = {}

-- ;>========================================================
-- ;>===               BEHAVIOR CONSTANTS               ===<;
-- ;>========================================================

local trainRatio = 0.1
local capSleep = l.forceMax(10)
local allowedAwakenHrs = 30
local allowedInactivity = 24
local name = c.bhv.name.bruce

local _storedWGP = bhv_all.internalProp(name, "_storedWGP")
local _oldRipped = bhv_all.internalProp(name, "_oldRipped")
local training = bhv_all.internalProp(name, "training")

-- ;>========================================================
-- ;>===                                                ===<;
-- ;>========================================================
-- ;> These functions will be closed later, when <data> is available

--- How many days to reach max leanness at this bodyweight?
---      weight ∈ [0..100]
local daysToMaxLeanness

--- Avoids perpetually gaining leanness.
--- @param training number
local capLeanness

--- Flashes some meter for down color
local flashDown

-- ;>========================================================
-- ;>===                     LOSSES                     ===<;
-- ;>========================================================

--- The more you weight, the less harsh the penalty is (because muscles give
--- you some room to caloric expenditure IRL).
---      weight ∈ [0..100]
local weightPenaltyMult = l.expCurve(0.02, {x=0, y=1}, {x=100, y=0.7})

local function canPunishInactivity(hoursInactive) return hoursInactive >= allowedInactivity end

--- Penalty for inactivity. This number is an addition.
---
---      `hoursInactive`:      Player hours, not game hours
local function inactivityPenaltyBase(hoursInactive)
    if canPunishInactivity(hoursInactive) then return 2
    else return 0
    end
end

--- Danger levels for not sleeping.
local function sleepDanger(hoursAwaken)
    if hoursAwaken >= allowedAwakenHrs then return c.dangerLevels.Critical
    elseif hoursAwaken >= allowedAwakenHrs - 6 then return c.dangerLevels.Danger
    elseif hoursAwaken >= allowedAwakenHrs - 10 then return c.dangerLevels.Warning
    else return c.dangerLevels.Normal
    end
end

--- Not a multiplier, but a base number.
local function sleepPenaltyBase(hoursAwaken)
    return l.case(sleepDanger(hoursAwaken), {
            [c.dangerLevels.Critical] = 0.25,
            [c.dangerLevels.Danger] = 0.1,
        }, 0
    )
end

--- Punish only punishable sleeping levels.
local function canPunishSleep(hoursAwaken)
    local p = sleepDanger(hoursAwaken)
    return (p == c.dangerLevels.Danger) or (p == c.dangerLevels.Critical)
end

--- Checks for losses (if sleeping too few or doing too little).
local function canLose(data)
    if not bhv_all.canLose(data) then return false end
    local state = data.state
    local byInactivity = canPunishInactivity(state.hoursInactive)
    local bySleep = canPunishSleep(state.hoursAwaken)
    -- ;TODO: Lose for bad eating
    return byInactivity or bySleep
end

--- Decays training and returns if there was decay.
local function decayTraining(data)
    local s, inactive = data.state, data.state.hoursInactive
    if not canPunishInactivity(inactive) or s.WGP <= 0 then return false end
    -- Each day without training drains 1 training day
    local v = s.decay -- * 1  <--- decay ratio
    s.WGP = l.forcePositve(s.WGP - v)
    return true
end

local function decayAndReportT(data) if decayTraining(data) then flashDown("meter2") end end

-- ;>========================================================
-- ;>===                      CORE                      ===<;
-- ;>========================================================

-- Defines functions based on current values.
local function closeFuncs(data)
    daysToMaxLeanness = l.expCurve(0.02, {x=0, y=rip.daysForMin(data)}, {x=100, y=rip.daysForMax(data)})
    capLeanness = function (training) return l.forceMax(daysToMaxLeanness(data.state.weight) * 1.03)(training) end
    flashDown = function (meterName) reportWidget.mFlash(data, meterName, reportWidget.flashCol.down) end
end

--- Calculates current leanness. This is what the player will actually see
--- in their bodies.
--- @return number
function bhvBruce.currLeanness(data)
    return l.forcePercent(training(data) / daysToMaxLeanness(data.state.weight))
end

local addons = jrequire 'sandowpp.addon_mgr'

--- Applies gains modifiers.
local function applyGainMod(data, gains)
    -- ;TODO: Adding modifiers
    return addons.onGainMult(data, gains, bhvBruce.currLeanness(data))
end

--- Calculates losses.
local function losses(data)
    local state = data.state
    local inactive = inactivityPenaltyBase(state.hoursInactive)
    local sleep = sleepPenaltyBase(state.hoursAwaken)
    local lo = inactive + sleep
    -- ;TODO: not eating properly
    lo = lo * state.decay * weightPenaltyMult(state.weight)
    return l.forcePositve(training(data) - lo)
end

--- Calculates gains.
local function gains(data)
    local state = data.state
    local wgp = state.WGP
    local todayTrained = l.forceMax(wgp)(capSleep(state.hoursSlept) * trainRatio)
    wgp = l.forcePositve(wgp - todayTrained)
    todayTrained = applyGainMod(data, todayTrained)
    return training(data) + todayTrained, wgp
end

local function updateTrainAndLean(data, train)
    training(data, capLeanness(train))
    rip.currDef(data, bhvBruce.currLeanness(data))
end

local function gainSeq(data, train)
    local flash, oldT = -1, train
    train, data.state.WGP = gains(data)
    updateTrainAndLean(data, train)
    if training(data) ~= oldT then flash = reportWidget.flashCol.up end
    data.state.lastSlept = -1
    return data, flash
end

local function prepareBeforeProcess(data)
    -- data.preset.addons.diminishingReturns.enabled= false
    closeFuncs(data)
    -- Cap before processing
    local train = capLeanness(training(data))
    training(data, train)
    return train
end

--- Returns processed data and which color should the main bar flash.
function bhvBruce.onSleep(data)
    -- ;TODO:  transfer this check to behavior manager
    if (data.state.hoursAwaken <= 5) or (bhvBruce.currLeanness(data) >= 1) then return data, -1 end
    local train, flash = prepareBeforeProcess(data), -1
    print("start ", training(data), bhvBruce.currLeanness(data), data.state.WGP)
    -- Core calculations
    data, flash = gainSeq(data, train)
    print("result ", training(data), bhvBruce.currLeanness(data), data.state.WGP)
    return data, flash
end

function bhvBruce.init(data)
    sh.defVal(data, training, 0)
end

local function lossSeq(data)
    prepareBeforeProcess(data)
    if not canLose(data) or training(data) == 0 then return end
    updateTrainAndLean(data, losses(data))
    flashDown("meter1")
end

--- All loses are done in real time.
function bhvBruce.realTimeCalc(data)
    lossSeq(data)
    decayAndReportT(data)
    -- updateTrainAndLean(data, 4)
    return data
end

-- ;>========================================================
-- ;>===                     EVENTS                     ===<;
-- ;>========================================================

local function storeOtherWGP(data)
    local o = _storedWGP(data) or 0
    _storedWGP(data, data.state.WGP)
    data.state.WGP = o
end

local function restoreOtherWGP(data)
    local o = data.state.WGP
    data.state.WGP = _storedWGP(data)
    _storedWGP(data, o)
end

local function storeOldRipped(data)
    _oldRipped(data, rip.mode(data))
    rip.mode(data, "bruce lee")
end

function bhvBruce.onEnter(data)
    print("Entering behavior")
    storeOtherWGP(data)
    storeOldRipped(data)
    reportWidget.mName(data, "meter2", "$training")
end

function bhvBruce.onExit(data)
    print("Exit behavior")
    restoreOtherWGP(data)
    rip.mode(data, _oldRipped(data))
    -- ;TODO: reapply old muscle definition
end


-- ;>========================================================
-- ;>===                   REPORTING                    ===<;
-- ;>========================================================
local function log(msg, val)
    print(msg, val)
    return val
end

local function setMeter1(data)
    reportWidget.mPercent(data, "meter1", bhvBruce.currLeanness(data))
end

local function setMeter2(data)
    reportWidget.mPercent(data, "meter2", bhv_all.adjMeter2(data))
end

local function setMeter3(data)
    if not bhv_all.canLose(data) then
        reportWidget.mVisible(data, "meter3", false)
    else
        local sleepFlash = bhv_all.flashByDanger(sleepDanger(data.state.hoursAwaken))
        reportWidget.mVisible(data, "meter3", true)
        reportWidget.mPercent(data, "meter3", data.state.hoursAwaken / allowedAwakenHrs)
        reportWidget.mFlash(data, "meter3", sleepFlash)
    end
end

local function setMeter4(data)
    -- Inactivity is integral to this behavior, so this meter is always displayed.
    local inactive = data.state.hoursInactive / allowedInactivity
    reportWidget.mVisible(data, "meter4", true)
    reportWidget.mPercent(data, "meter4", inactive)
    reportWidget.mFlash(data, "meter4", bhv_all.flashByInactivity(inactive))
end

function bhvBruce.report(data)
    closeFuncs(data)
    setMeter1(data)
    setMeter2(data)
    setMeter3(data)
    setMeter4(data)
    return data
end

function bhvBruce.getMcmData(data)
    closeFuncs(data)
    local b = data.bhv
    b.mainStatLbl = "$Muscle definition:"
    b.mainStatVal = l.floatToPercentStr(bhvBruce.currLeanness(data))
    b.mainStatInf = "$MCM_RippedLblInfo"
    b.trainingLbl = "$Daily training:"
    b.trainingVal = l.floatToPercentStr(data.state.WGP / 100)
    b.trainingInf = "$MCM_RippedTrainingInfo"
    return data
end

return bhvBruce
