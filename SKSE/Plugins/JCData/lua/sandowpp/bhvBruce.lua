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

--- The more you weight, the less harsh the penalty is (because muscles give
--- you some room to caloric expenditure IRL).
---      weight ∈ [0..100]
local weightPenaltyMult = l.expCurve(0.02, {x=0, y=1}, {x=100, y=0.2})

--- Penalty for inactivity. This number is an addition.
---      hoursInactive:      Real hours, not game hours
local inactivityPenaltyBase

--- Avoids perpetually gaining leanness.
--- @param training number
local capLeanness

-- ;>========================================================
-- ;>===                     LOSSES                     ===<;
-- ;>========================================================

--- Calculates how much training (WGP) will decay for inactivity.
---     `trainDecay(Hours inactive)`
---     `Hours inactive ∈ [allowedInactivity, 72]`
local trainDecay = l.pipe(
    l.expCurve(0.028881132523326, {x=allowedInactivity, y=0.2}, {x=72, y=0.8}),
    l.forceMax(0.4)
)

local function canPunishInactivity(hoursInactive) return hoursInactive >= allowedInactivity end

--- Rate of decay for muscle definiton. Base number, not multiplier.
---
---      `hoursInactive`:      Real hours, not game hours
---
--- This formula punishes up to 96 hours (4 in game days).
local inactivityPenaltyCurve = l.pipe(
    l.expCurve(0.04, {x=allowedInactivity, y=0.5}, {x=96, y=12}),
    l.forceMax(12)
)

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
            [c.dangerLevels.Critical] = l.forceMax(1.2)(hoursAwaken / 100),
            [c.dangerLevels.Danger] = hoursAwaken / 120,
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
    if not canPunishInactivity(inactive) then return false end

    local oldWGP = s.WGP
    local v = s.WGP * s.decay * trainDecay(inactive)
    s.WGP = l.forcePositve(s.WGP - v)
    return oldWGP ~= s.WGP
end

local function decayAndReportTrain(data)
    if decayTraining(data) then
        reportWidget.mFlash(data, "meter2", reportWidget.flashCol.down)
    end
end

-- ;>========================================================
-- ;>===                      CORE                      ===<;
-- ;>========================================================

-- Defines functions based on current values.
local function closeFuncs(data)
    daysToMaxLeanness = l.expCurve(0.02, {x=0, y=rip.daysForMin(data)}, {x=100, y=rip.daysForMax(data)})
    -- weightPenaltyMult = l.expCurve(0.02, {x=0, y=1}, {x=100, y=0.2})
    inactivityPenaltyBase = l.boolBase(inactivityPenaltyCurve, canPunishInactivity(data.state.hoursInactive))
    capLeanness = function (training) return l.forceMax(daysToMaxLeanness(data.state.weight) * 1.03)(training) end
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
    local state, wgp = data.state, data.state.WGP
    local inactive = inactivityPenaltyBase(state.hoursInactive)
    local sleep = sleepPenaltyBase(state.hoursAwaken)
    local lo = inactive + sleep
    -- ; ;TODO: not eating properly
    lo = lo * weightPenaltyMult(state.weight)
    return l.forcePositve(training(data) - lo), l.forcePositve(wgp)
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

local function gainOrLose(data, train)
    local flash = -1
    if canLose(data) then
        flash, train, data.state.WGP = reportWidget.flashCol.down, losses(data)
    else
        flash, train, data.state.WGP = reportWidget.flashCol.up, gains(data)
    end
    training(data, capLeanness(train))
    data.state.lastSlept = -1
    rip.currDef(data, bhvBruce.currLeanness(data))
    decayAndReportTrain(data)
    return data, flash
end

local function prepareBeforeSleep(data)
    -- data.preset.addons.diminishingReturns.enabled= false
    closeFuncs(data)

    -- Cap before processing
    local train = capLeanness(training(data))
    training(data, train)
    return train
end

--- Returns processed data and which color should the main bar flash.
function bhvBruce.onSleep(data)
    local train, flash = prepareBeforeSleep(data), -1
    print("start ", training(data), bhvBruce.currLeanness(data), data.state.WGP)
    -- Core calculations
    data, flash = gainOrLose(data, train)
    print("result ", training(data), bhvBruce.currLeanness(data), data.state.WGP)
    return data, flash
end

function bhvBruce.init(data)
    sh.defVal(data, training, 0)
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
    decayAndReportTrain(data)
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
    b.trainingVal = l.floatToPercentStr(data.state.WGP)
    b.trainingInf = "$MCM_RippedTrainingInfo"
    return data
end

return bhvBruce
