--- Finds a curve shape `b` that passes by certain 3 points.
---
--- Use this to ensure exponential curves pass by a certain milestone.
local shapeFinder = {}

local p1 = {x=36, y=0.05}
local p2 = {x=72, y=0.4}
local desired = {x=48, y=0.1}
local t, iter = 0.00000000000001, 0

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

local function findShape(e1, e2, d)
    iter = iter + 1
    local v1 = expCurve(e1)(d.x)
    local v2 = expCurve(e2)(d.x)
    local em = (e2 + e1) /  2.0
    local vm = expCurve(em)(d.x)

    print("===========================")
    print("iteration", iter)
    print("e1, v1", e1, v1)
    print("e2, v2", e2, v2)
    print("em, vm", em, vm)
    print("")

    if iter > 100 then print ("Couldn't find") return em end
    if (vm == d.y) or ((e2 - e1) /2 < t) then return em end

    if(vm - d.y) > 0 then return findShape(em, e2, d)
    else return findShape(e1, em, d) end
end

-----------------------------------------------------------------
local b = findShape(0.0001, 1, desired)
print("b = ", b)

local clipboard = require'clipboard'
clipboard.settext(b)
print("***b was copied to clipboard***")

return shapeFinder
