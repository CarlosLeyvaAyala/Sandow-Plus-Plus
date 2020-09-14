-- local dml = require 'dmlib'
-- local l = require 'shared'
-- local const = require 'const'

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
        else return data.bhv[key]
        end
    end
end

return bhv_all
