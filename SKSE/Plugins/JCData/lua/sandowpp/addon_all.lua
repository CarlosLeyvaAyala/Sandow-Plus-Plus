-- Functions and structures shared by all addons.
-- Notice this isn't true inheritance. No need for that.

local addon_all = {}

-- ;>========================================================
-- ;>===                     ACCESS                     ===<;
-- ;>========================================================

addon_all.names = {
    showInMCM = "showInMCM",
    enabled = "enabled"
}

--- Sets access to a MCM configurable property.
---@param addon string
---@param key string
function addon_all.MCMProp(addon, key)
    return function (data, value)
        if value ~= nil then data.preset.addons[addon][key] = value
        else return data.preset.addons[addon][key]
        end
    end
end

--- Sets access to a ***non-MCM*** configurable property.
---@param addon string
---@param key string
function addon_all.internalProp(addon, key)
    return function (data, value)
        if value ~= nil then data.addons[addon][key] = value
        else return data.addons[addon][key]
        end
    end
end

return addon_all
