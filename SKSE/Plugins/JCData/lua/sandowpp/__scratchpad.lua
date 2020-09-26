local maxT, b = 2 * 24, 0.1
local hInactive = 24
local p1 = {x=hInactive, y=2}
local p2 = {x=96, y=7}

local function linCurve(p1, p2)
    return function (x)
        local m = (p2.y - p1.y) / (p2.x - p1.x)
        return (m * (x - p1.x)) + p1.y
    end
end
-- local x = 0
-- print("f("..x..")", linCurve(p1, p2)(x))
local function calc(mT)
    local function expCurve(shape)
        return function(x)
            local e = math.exp
            local b = shape
            local ebx1 = e(b * p1.x)
            local a = (p2.y - p1.y) / (e(b * p2.x) - ebx1)
            local c = p1.y - a * ebx1
            return a * e(b * x) + c
        end
    end
    local f, decayT, ratio, r = expCurve(b), 0.00124073028564453, 1 / 24, 0
    --f = linCurve(p1, p2)
    f = function(x) return 1 end
    local decayPlayerT = decayT / ratio
    while hInactive <= mT do
        r = r + f(hInactive) * decayT
        hInactive = hInactive + decayPlayerT
    end
    return r
end
--print(calc(maxT))
