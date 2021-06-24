local l = jrequire 'dmlib'
local c = jrequire 'sandowpp.const'
local rip = jrequire 'sandowpp.addonRipped'
local bhv_all = jrequire 'sandowpp.bhv_all'
local reportWidget = jrequire 'sandowpp.reportWidget'
local sh = jrequire 'sandowpp.shared'

local bhvSandow = {}

-- ;>========================================================
-- ;>===               BEHAVIOR CONSTANTS               ===<;
-- ;>========================================================


-- ;>========================================================
-- ;> Modify these constants to tweak this behavior.

--- Any operation involving this constant expects a real hour, not a game hour.
local _fatigueHourlyRate = 0.1
--- Rate of training loss. This is a percentage of current fatigue.
local _trainingLossRate = 0.15
--- Allowed inactivity hours.
local _inactivityHoursToLoses = 72
--- Rate of losses by inactivity.
local _lossesRateByInactivity = 0.025
--- Max weight lost for inactivity.
local _maxInactivityPunishment = 25
--- How much weight lost for the fatigue percentage.
local _weightLossMagnitude = 2

-- ;> All these hours assume fatigue by training is 0.
-- ;> Fatigue by training makes these thresholds to be reached faster.
--- Hours needed to get full sleep growth benefits.
local _fatigueNeedSleepHours = 14
--- Hours needed to start losing training, but not weight.
local _fatigueTrainLossHours = 18
--- Hours to reach the catabolic threshold. You lose weight and training at this stage.
local _fatigueCatabolicHours = 20
--- Hours to reach max fatigue. Fatigue is capped to avoid ridiculous values.
local _maxFatigueHours = 72

-- ;>========================================================
-- ;> Calculated constants. DON'T CHANGE THESE.
local _bhvName = c.bhv.name.sandow

--- Once reaching this number you enter catabolic state.
local _catabolicThreshold = _fatigueCatabolicHours * _fatigueHourlyRate
--- Max allowed fatigue is 1000%.
local _maxFatigue = _catabolicThreshold * 10
--- Ensure fatigue never goes over `_maxFatigue`.
local _capFatigue = l.forceMax(_maxFatigue)
--- Above this number, you start to lose training because of fatigue
local _trainLossThreshold = _fatigueTrainLossHours / _fatigueCatabolicHours

--- Fatigue progression once the catabolic threshold has been reached.
--- Result goes from 100% to `_maxFatigue` (1000%).
---
---      fatigue ∈ [2.0, 7.2]
local _catabolicCurve = l.expCurve(0.5, {x=_catabolicThreshold, y=_catabolicThreshold}, {x=_maxFatigueHours * _fatigueHourlyRate, y=_maxFatigue})

-- local training = bhv_all.internalProp(_bhvName, "training")

-- ;>========================================================
-- ;>===                                                ===<;
-- ;>========================================================
-- ;> These functions will be closed later, when <data> is available

--- Flashes some meter for down color
local flashDown

-- ;>========================================================
-- ;>===                     LOSSES                     ===<;
-- ;>========================================================

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

--- Checks for losses (if too fatigued or doing too little).
local function canLose(data)
    return false
    -- if not bhv_all.canLose(data) then return false end
    -- local byInactivity = canPunishInactivity(state.hoursInactive)
    -- -- ;TODO: Lose for bad eating
    -- return byInactivity or bySleep
end

-- local function decayTraining(data) return false end

-- local function decayAndReportT(data) if decayTraining(data) then flashDown("meter2") end end

--- Reduce training and return the new value and meter flashing.
local function _loseTrainingByFatigue(aTraining, aFatigue)
    if aFatigue < _trainLossThreshold then return aTraining end
    local rate = l.forcePositve(1 - (aFatigue * _trainingLossRate))
    return rate * aTraining, reportWidget.flashCol.down
end

--- Calculate losses by inactivity.
local function _lossesByInactivity(aWeight, aTraining, aHoursInactive)
    if aHoursInactive < _inactivityHoursToLoses then return aWeight, aTraining end
    print("Too inactive")
    local rate = l.forceMax(_maxInactivityPunishment)(aHoursInactive * _lossesRateByInactivity)
    print("rate", rate)
    aWeight = aWeight - rate
    aTraining = aTraining - (rate / 2)
    return l.forcePositve(aWeight), l.forcePositve(aTraining)
end

--- Calculate losses by catabolism.
local function _lossesByCatabolism(aWeight, aFatigue)
    -- Catabolic state is at least 100% fatigue
    if aFatigue < 1 then return aWeight end
    return l.forcePositve(aWeight - (aFatigue * _weightLossMagnitude))
end

--- Loss sequence. Returns new weight, training and tells if there was weight loss.
local function _lossSeq(aData, aFatigue, aTraining)
    -- When losses are deactivated, the player always gains.
    if not bhv_all.canLose(aData) then return aData.state.weight, aTraining, false end

    print("Lose seq")
    local weight, training = aData.state.weight, aTraining
    print("weight", weight)
    print("training", training)
    -- By inactivity
    weight, training = _lossesByInactivity(weight, training, aData.state.hoursInactive)
    -- By catabolism
    weight = _lossesByCatabolism(weight, aFatigue)

    return weight, training, weight ~= aData.state.weight
end

-- ;>========================================================
-- ;>===                    FATIGUE                     ===<;
-- ;>========================================================

--- Adjust fatigue if catabolic threshold has been reached.
---@param aFatigue number
local function _adjustIfCatabolic(aFatigue)
    -- We cap the fatigue to avoid overflow errors with too big values.
    if aFatigue > _catabolicThreshold then return _catabolicCurve(_capFatigue(aFatigue)) end
    return aFatigue
end

--- Calculate fatigue as a percent acording to hours awaken and fatigue accumulated by training.
---
--- This function only accepts real hours, not game hours.
--- Ie, using `0.08` (2 game hours) will get you wrong data,
--- but using `2`, will give you accurate data.
---@param aHoursAwaken number
---@param aTrainFatigue number
---@return number
local function _getFatigue(aHoursAwaken, aTrainFatigue)
    aHoursAwaken = l.forcePositve(aHoursAwaken)
    local fatigue = (aHoursAwaken * _fatigueHourlyRate) + aTrainFatigue
    fatigue = _adjustIfCatabolic(fatigue)
    return _capFatigue(fatigue) / _catabolicThreshold
end

-- ;>========================================================
-- ;>===                      CORE                      ===<;
-- ;>========================================================

-- Defines functions based on current values.
local function closeFuncs(data)
end

local addons = jrequire 'sandowpp.addon_mgr'

--- Calculates losses.
local function losses(data)
    -- local state = data.state
    -- local inactive = inactivityPenaltyBase(state.hoursInactive)
    -- local sleep = sleepPenaltyBase(state.hoursAwaken)
    -- local lo = inactive + sleep
    -- -- ;TODO: not eating properly
    -- lo = lo * state.decay * weightPenaltyMult(state.weight)
    -- return l.forcePositve(training(data) - lo)
end

--- Calculates gains.
local function gains(data)
    -- local state = data.state
    -- local wgp = state.WGP
    -- local todayTrained = l.forceMax(wgp)(capSleep(state.hoursSlept) * trainRatio)
    -- wgp = l.forcePositve(wgp - todayTrained)
    -- todayTrained = applyGainMod(data, todayTrained)
    -- return training(data) + todayTrained, wgp
end

local function prepareBeforeProcess(data)
    -- closeFuncs(data)
    -- -- Cap before processing
    -- local train = capLeanness(training(data))
    -- training(data, train)
    -- return train
end

local function _gainOrLose(aFatigue, aTraining, aData)
    local flash1, flash2
    -- Lose
    local weight, training, weightLost = _lossSeq(aData, aFatigue, aTraining)
    -- Can't gain weight. Exit.
    if weight >= 100 or weightLost then
        return weight, training
    end
    print("lose seq ended")
    print("weight", weight)
    print("training", training)
--
end

--- Returns processed data and which color should the main bar flash.
function bhvSandow.onSleep(data)
    local fatigue = _getFatigue(data.state.hoursAwaken, data.state.skillFatigue)
    local training, flash2 = _loseTrainingByFatigue(data.state.WGP, fatigue)
    local flash1
    flash1 = _gainOrLose(fatigue, training, data)

    print("hoursAwaken", data.state.hoursAwaken)
    -- print("skillFatigue", data.state.skillFatigue)
    print("fatigue", string.format("%.2f%%", fatigue * 100))
    -- local train, flash = prepareBeforeProcess(data), -1
    -- print("start ", training(data), bhvSandow.currLeanness(data), data.state.WGP)
    -- Core calculations
    -- data, flash = gainSeq(data, train)
    -- print("result ", training(data), bhvSandow.currLeanness(data), data.state.WGP)
    -- return data, flash
    return data, flash1, flash2
end

function bhvSandow.init(data)
    -- sh.defVal(data, training, 0)
end

--- All loses are done in real time.
function bhvSandow.realTimeCalc(data)
    -- _lossSeq(data)
    -- decayAndReportT(data)
    -- updateTrainAndLean(data, 1000)
    return data
end

-- ;>========================================================
-- ;>===                     EVENTS                     ===<;
-- ;>========================================================

function bhvSandow.onEnter(data)
    print("Entering ".._bhvName)
    -- storeOtherWGP(data)
    -- storeOldRipped(data)
    reportWidget.mName(data, "meter2", "$training")
end

function bhvSandow.onExit(data)
    print("Exit ".._bhvName)
    -- restoreOtherWGP(data)
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
    -- reportWidget.mPercent(data, "meter1", bhvSandow.currLeanness(data))
end

local function setMeter2(data)
    reportWidget.mPercent(data, "meter2", bhv_all.adjMeter2(data))
end

local function setMeter3(data)
    -- if not bhv_all.canLose(data) then
    --     reportWidget.mVisible(data, "meter3", false)
    -- else
    --     local sleepFlash = bhv_all.flashByDanger(sleepDanger(data.state.hoursAwaken))
    --     reportWidget.mVisible(data, "meter3", true)
    --     reportWidget.mPercent(data, "meter3", data.state.hoursAwaken / allowedAwakenHrs)
    --     reportWidget.mFlash(data, "meter3", sleepFlash)
    -- end
end

local function setMeter4(data)
    -- local inactive = data.state.hoursInactive / allowedInactivity
    -- reportWidget.mVisible(data, "meter4", true)
    -- reportWidget.mPercent(data, "meter4", inactive)
    -- reportWidget.mFlash(data, "meter4", bhv_all.flashByInactivity(inactive))
end

function bhvSandow.report(data)
    closeFuncs(data)
    setMeter1(data)
    setMeter2(data)
    setMeter3(data)
    setMeter4(data)
    return data
end

function bhvSandow.getMcmData(data)
    closeFuncs(data)
    local b = data.bhv
    b.mainStatLbl = "$Muscle definition:"
    -- b.mainStatVal = l.floatToPercentStr(bhvSandow.currLeanness(data))
    b.mainStatInf = "$MCM_RippedLblInfo"
    b.trainingLbl = "$Daily training:"
    b.trainingVal = l.floatToPercentStr(data.state.WGP / 100)
    b.trainingInf = "$MCM_RippedTrainingInfo"
    return data
end

return bhvSandow
