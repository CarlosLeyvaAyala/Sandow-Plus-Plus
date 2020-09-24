-- Makes a variable delaration for values that can only be initialized once,
-- but said delaration may be called many times once initialized.
-- Use this when writing Lua code.

-- This is used to easily create new variables on running games while leaving
-- alone values that have been already in use.

-- ;@example:
--
-- Copy this from your Lua source
--          s.WGP = 0
--          s.hoursSlept = 0
--          s.weight = 0
--
-- This script will copy this to your clipboard:
--          s.WGP = s.WGP or 0
--          s.hoursSlept = s.hoursSlept or 0
--          s.weight = s.weight or 0

local clipboard = require'clipboard'
local s = clipboard.gettext()

local function makeDefaultDeclaration(str)
    local function processLine(st)
        local i = st:find("=")
        if not i then return st end
        local v = "= "..st:sub(1, i - 1):match( "^%s*(.-)%s*$" ).." or"
        return st:gsub("=", v)
    end

    local r = ""
    for line in str:gmatch("([^\n]*)\n?") do
        r = r..processLine(line).."\n"
    end
    return r
end

print(makeDefaultDeclaration(s))
clipboard.settext(makeDefaultDeclaration(s):match( "(.-)%s*$" ))
