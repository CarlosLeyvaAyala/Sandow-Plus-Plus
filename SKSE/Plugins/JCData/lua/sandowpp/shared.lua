-- Library for things exclusive to this mod.

-- local dmlib = jrequire 'dmlib'

local shared = {}

---Creates a default value for some *"property"* if such property is `nil`.
---@param data table
---@param property function
---@param val any
function shared.defVal(data, property, val)
    if property(data) == nil then property(data, val) end
end

-- ;>========================================================
-- ;>===                    MANAGERS                    ===<;
-- ;>========================================================

--- Returns a function that traverses a table and executes a function on each member.
---
--- This function is meant to be used by managers to easily traverse whatever they are
--- managing.
--- @param tbl table
function shared.traverse(tbl)
    --- @param func function(x) end
    ---@param x table
    return function (func, x)
        for name, member in pairs(tbl) do
            func(member, name, x.data, x.extra)
        end
    end
end
return shared
