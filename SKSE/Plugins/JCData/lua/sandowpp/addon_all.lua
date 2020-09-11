-- Functions and structures shared by all addons.
-- Notice this isn't true inheritance. No need for that.

local l = require 'dmlib'

local addon_all = {}

--;Region: Access
local function getVal(data, addon, key)
    return data.addons[addon][key]
end

local function modVal(data, addon, key, value)
    data.addons[addon][key] = value
end

--- @param data table
---@param addon string
---@param key string
---@param value any
function addon_all.val(data, addon, key, value)
    if value ~= nil then modVal(data, addon, key, value)
    else return getVal(data, addon, key)
    end
end

function addon_all.showInMCM(data, addon, show)
    if show ~= nil then modVal(data, addon, "showInMCM", show)
    else return getVal(data, addon, "showInMCM")
    end
end

return addon_all
