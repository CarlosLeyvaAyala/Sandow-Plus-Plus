data = {
    -- Calculations on player
    state = {
        -- supplied by payrus behavior
        training = 0,
        WGP = 1.7,
        -- supplied by global variables
        hoursSlept = 10,
        hoursInactive = 4,
        hoursAwaken = 4,
        weight = 0
    }
}

-- ;>=====================================================
dangerLevels = enum {
    "Normal",
    "Warning",
    "Danger",
    "Critical"
 }

-- ;>=====================================================
-- ;>Behavior constants
trainRatio = 0.1
capSleep = capValue(10)
allowedAwakenHrs = 24
allowedInactivity = 24

-- ;>=====================================================
-- ;> These functions will be closed later, when <data> is available
-- Ratio for calculating diminishing returns
local diminishTraining
local diminishingReturns        --;TODO: Delete

-- How many days to reach max leanness at this bodyweight?
--      weight ∈ [0..100]
local daysToMaxLeanness

-- The more you weight, the less harsh the penalty is (because muscles give
-- you some room to caloric expenditure IRL.)
--      weight ∈ [0..100]
local weightPenaltyMult

-- Penalty for inactivity. This number is an addition.
--      hoursInactive   =>      Real hours, not game hours
local inactivityPenaltyBase

-- ;>=====================================================
function canPunishInactivity(hoursInactive) return hoursInactive >= allowedInactivity end

-- Rate of decay for muscle definiton. Base number, not multiplier.
--      hoursInactive   =>      Real hours, not game hours
inactivityPenaltyCurve = pipe(expCurve(0.04, {x=24, y=0.5}, {x=96, y=12}), capValue(12))

-- Danger levels for not sleeping.
function sleepDanger(hoursAwaken)
    if hoursAwaken >= allowedAwakenHrs + 6 then return dangerLevels.Critical
    elseif hoursAwaken >= allowedAwakenHrs then return dangerLevels.Danger
    elseif hoursAwaken >= allowedAwakenHrs - 2 then return dangerLevels.Warning
    else return dangerLevels.Normal
    end
end

-- Not a multiplier, but a base number.
function sleepPenaltyBase(hoursAwaken)
    return case(sleepDanger(hoursAwaken), {
            [dangerLevels.Critical] = capValue(1.2)(hoursAwaken / 100),
            [dangerLevels.Danger] = hoursAwaken / 120,
        }, 0
    )
end

-- Punish only punishable sleeping levels.
function canPunishSleep(hoursAwaken)
    local p = sleepDanger(hoursAwaken)
    return (p == dangerLevels.Danger) or (p == dangerLevels.Critical)
end

-- Loses muscle definition if sleeping to few or doing too little.
function canLose(state)
    -- local byInactivity = state.hoursInactive >= allowedInactivity
    local byInactivity = canPunishInactivity(state.hoursInactive)
    local bySleep = canPunishSleep(state.hoursAwaken)
    -- ;TODO: Lose for bad eating
    -- ;TODO: Lose only if MCM enabled
    return byInactivity or bySleep
    -- return (HoursInactiveBeforeSleeping(aData) >= InactivityHoursToLoses()) || (aData.CurrentState.HoursAwaken >= _maxAwakenHours)
end

function addonEvent(addon, event, callback)
    print(data.cfg.addons[addon].execute[event])
    data.cfg.addons[addon].execute[event] = callback
    print(data.cfg.addons[addon].execute[event])
end

-- Defines functions based on current values.
function closeFuncs(state, cfg)
    daysToMaxLeanness = expCurve(0.02, {x=0, y=cfg.addons.ripped.player.daysFromMin}, {x=100, y=cfg.addons.ripped.player.daysFromMax})
    weightPenaltyMult = expCurve(0.02, {x=0, y=1}, {x=100, y=0.2})
    inactivityPenaltyBase = boolBase(inactivityPenaltyCurve, canPunishInactivity(state.hoursInactive))
    diminishTraining = calcDiminish(state.training / daysToMaxLeanness(state.weight))
    diminishingReturns = boolMultiplier(diminishTraining, cfg.addons.diminishingReturns.enabled)
    addonEvent("diminishingReturns", "onSleepGains", 2)
end

--;>=====================================================
--;> Behavior core
function losses(state)
    local l = inactivityPenaltyBase(state.hoursInactive)
    l = l + sleepPenaltyBase(state.hoursAwaken)
    l = l * weightPenaltyMult(state.weight)
    -- ; ;TODO: not eating properly
    return ensurePositve(state.training - l)
end

function gains(state)
    local wgp = ensurePercent(state.WGP)         -- Can't have more than 100% training a day
    local todayTrained = capValue(wgp)(capSleep(state.hoursSlept) * trainRatio)
    wgp = ensurePositve(wgp - todayTrained)
    todayTrained = diminishingReturns(todayTrained) --;@Addons:
    return state.training + todayTrained, wgp
end

function onSleep(data)
    closeFuncs(data.state, data.cfg)

    if canLose(data.state) then
        data.state.training = losses(data.state)
    else
        data.state.training, data.state.WGP = gains(data.state)
    end
    return data
end
-- print(table.concat(map(double, {1,2,3}),","))
onSleep(data)
-- addons = {
--     diminishingReturns = {
--         enabled = true,
--         execute = {
--             onSleepGains = 1
--         }
--     },
