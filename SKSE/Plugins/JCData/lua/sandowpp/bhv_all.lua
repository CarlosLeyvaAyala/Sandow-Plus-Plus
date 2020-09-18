local dml = jrequire 'dmlib'
-- local l = jrequire 'sandowpp.shared'
local reportWidget = jrequire 'sandowpp.reportWidget'
local c = jrequire 'sandowpp.const'

local bhv_all = {}

--- Sets access to a ***non-MCM*** configurable property.
---@param bhvName string
---@param key string
function bhv_all.internalProp(bhvName, key)
    return function (data, value)
        if value ~= nil then data.bhv[bhvName][key] = value
        else return data.bhv[bhvName][key]
        end
    end
end

--- Sets access to a ***MCM*** configurable property shared by many behaviors.
---@param key string
function bhv_all.mcmGralProp(key)
    return function (data, value)
        if value ~= nil then data.preset.bhv[key] = value
        else return data.preset.bhv[key]
        end
    end
end

-- ;>========================================================
-- ;>===                     SHARED                     ===<;
-- ;>========================================================

bhv_all.canLose = bhv_all.mcmGralProp("canLose")

function bhv_all.flashByDanger(dangerLvl)
    return dml.case(dangerLvl, {
        [c.dangerLevels.Critical] = reportWidget.flashCol.critical,
        [c.dangerLevels.Danger] = reportWidget.flashCol.danger,
        [c.dangerLevels.Warning] = reportWidget.flashCol.warning
    },
    -1
)
end

function bhv_all.flashByInactivity(inactivePercent)
    local danger
    if inactivePercent >= 1 then danger = c.dangerLevels.Critical
    elseif inactivePercent >= 0.7 then danger = c.dangerLevels.Warning
    else danger = c.dangerLevels.Normal
    end
    return bhv_all.flashByDanger(danger)
end

return bhv_all
