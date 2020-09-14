local l = require 'dmlib'
local c = require 'const'
local rip = require 'addonRipped'
local bhv_all = require 'bhv_all'

local bhvBruce = {}

-- ;>========================================================
-- ;>===               BEHAVIOR CONSTANTS               ===<;
-- ;>========================================================

local trainRatio = 0.1
local capSleep = l.forceMax(10)
local allowedAwakenHrs = 24
local allowedInactivity = 24
local name = c.bhv.name.bruce


local _OldWGP = bhv_all.internalProp(name, "_oldWGP")
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
local weightPenaltyMult

--- Penalty for inactivity. This number is an addition.
---      hoursInactive:      Real hours, not game hours
local inactivityPenaltyBase

-- ;>========================================================
-- ;>===                     LOSSES                     ===<;
-- ;>========================================================

local function canPunishInactivity(hoursInactive) return hoursInactive >= allowedInactivity end

--- Rate of decay for muscle definiton. Base number, not multiplier.
---      hoursInactive:      Real hours, not game hours
--- This formula punishes up to 96 hours (4 in game days).
local inactivityPenaltyCurve = l.pipe(l.expCurve(0.04, {x=24, y=0.5}, {x=96, y=12}), l.forceMax(12))

-- Danger levels for not sleeping.
local function sleepDanger(hoursAwaken)
    if hoursAwaken >= allowedAwakenHrs + 6 then return c.dangerLevels.Critical
    elseif hoursAwaken >= allowedAwakenHrs then return c.dangerLevels.Danger
    elseif hoursAwaken >= allowedAwakenHrs - 2 then return c.dangerLevels.Warning
    else return c.dangerLevels.Normal
    end
end

-- Not a multiplier, but a base number.
local function sleepPenaltyBase(hoursAwaken)
    return l.case(sleepDanger(hoursAwaken), {
            [c.dangerLevels.Critical] = l.forceMax(1.2)(hoursAwaken / 100),
            [c.dangerLevels.Danger] = hoursAwaken / 120,
        }, 0
    )
end

-- Punish only punishable sleeping levels.
local function canPunishSleep(hoursAwaken)
    local p = sleepDanger(hoursAwaken)
    return (p == c.dangerLevels.Danger) or (p == c.dangerLevels.Critical)
end

-- Loses muscle definition if sleeping to few or doing too little.
local function canLose(data)
    local state = data.state
    local byInactivity = canPunishInactivity(state.hoursInactive)
    local bySleep = canPunishSleep(state.hoursAwaken)
    -- ;TODO: Lose for bad eating
    -- ;TODO: Lose only if MCM enabled
    return byInactivity or bySleep

    -- return (HoursInactiveBeforeSleeping(aData) >= InactivityHoursToLoses()) || (aData.CurrentState.HoursAwaken >= _maxAwakenHours)
end


-- ;>========================================================
-- ;>===                      CORE                      ===<;
-- ;>========================================================

-- Defines functions based on current values.
local function closeFuncs(data)
    daysToMaxLeanness = l.expCurve(0.02, {x=0, y=rip.daysForMin(data)}, {x=100, y=rip.daysForMax(data)})
    weightPenaltyMult = l.expCurve(0.02, {x=0, y=1}, {x=100, y=0.2})
    inactivityPenaltyBase = l.boolBase(inactivityPenaltyCurve, canPunishInactivity(data.state.hoursInactive))
end

--- Calculates current leanness. This is what the player will actually see
--- in their bodies.
--- @return number
function bhvBruce.currLeanness(data)
    return l.forcePercent(training(data) / daysToMaxLeanness(data.state.weight))
end

local function losses(data)
    local state = data.state
    local lo = inactivityPenaltyBase(state.hoursInactive)
    lo = lo + sleepPenaltyBase(state.hoursAwaken)
    lo = lo * weightPenaltyMult(state.weight)
    -- ; ;TODO: not eating properly
    return l.forcePositve(training(data) - lo)
end

local addons = require 'addon_mgr'

--- Applies gains modifiers.
local function applyGainMod(data, gains)
    -- ;TODO: Adding modifiers
    return addons.onGainMult(data, gains, bhvBruce.currLeanness(data))
end

--- Calculates gains.
local function gains(data)
    local state = data.state
    local wgp = l.forcePercent(state.WGP)       -- Can't have more than 100% training a day
    local todayTrained = l.forceMax(wgp)(capSleep(state.hoursSlept) * trainRatio)
    wgp = l.forcePositve(wgp - todayTrained)
    todayTrained = applyGainMod(data, todayTrained)
    return training(data) + todayTrained, wgp
end

function bhvBruce.onSleep(data)
    closeFuncs(data)
    local train
    print("start ", training(data), bhvBruce.currLeanness(data))

    if canLose(data) then
        train = losses(data)
        data.state.WGP = 0
    else
        train, data.state.WGP = gains(data)
        -- Avoid perpetually gaining leanness
        train = l.forceMax(daysToMaxLeanness(data.state.weight) * 1.03)(train)
    end
    training(data, train)
    print("result ", training(data), bhvBruce.currLeanness(data))
    return data
end

function bhvBruce.init(data)
    training(data, 10)
end

-- ;>========================================================
-- ;>===                     EVENTS                     ===<;
-- ;>========================================================

local function storeOldWGP(data)
    local s = data.state
    _OldWGP(data, s.WGP)
    s.WGP = l.forcePercent(s.WGP)
end

local function restoreOldWGP(data)
    data.state.WGP = _OldWGP(data)
end

function bhvBruce.onEnter(data)
    print("Entering behavior")
    storeOldWGP(data)
end

function bhvBruce.onExit(data)
    print("Exit behavior")
    restoreOldWGP(data)
    -- ;TODO: reapply old muscle definition
end

return bhvBruce
