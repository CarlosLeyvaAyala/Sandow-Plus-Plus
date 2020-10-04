local c = 16777215
c = 410
print(string.format("%.6X", c))

local m = 20
local hard = {}
local function summa(n) return (n * (n + 1)) / 2 end
for i = 1, m do table.insert(hard, i) end       -- Días difíciles
local function diffTbl(t, v) local d = {}; for i = 1, m do table.insert(d, math.abs(summa(t[i]) - v)) end; return d end
local function fMin(t)
    local idx, val = 1, t[1]
    for i = 2, #t do if t[i] < val then idx, val = i, t[i] end end
    return idx
end
local function closestLadder(t, reps) return fMin(diffTbl(t, reps)) end
local function genDays(h, ratio)
    local r = {}
    for _, v in pairs(h) do table.insert(r, closestLadder(h, summa(v) * ratio)) end
    return r
end
local easy = genDays(hard, 0.3333333)
local medium = genDays(hard, 0.6666666)
-- for i = 1, #hard do
--     print(hard[i], easy[i], medium[i], summa(hard[i]), summa(easy[i]), summa(medium[i]))
-- end

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
