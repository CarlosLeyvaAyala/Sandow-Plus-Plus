-- local dmlib = require 'dmlib'
local l = require 'shared'
local const = require 'const'
-- local l = require 'sandowpp.shared'
-- local const = require 'sandowpp.const'

local reportWidget = {}

local nMeters = 4

reportWidget.VAlign = {top = "top", center = "center", bottom = "bottom"}
reportWidget.HAlign = {left = "left", center = "center", right = "right"}


-- ;>========================================================
-- ;>===             WIDGET MCM PROPERTIES              ===<;
-- ;>========================================================

--- Creates a general property. These are shown in the MCM and apply to all meters.
local function gralProp(name)
    return function(data, x)
        if x ~= nil then data.preset.widget[name] = x
        else return data.preset.widget[name]
        end
    end
end

--- Vertical anchor point of the widget. Default: `"top"`.
reportWidget.vAlign = gralProp("vAlign")
--- Horizontal anchor point of the widget. Default: `"left"`.
reportWidget.hAlign = gralProp("hAlign")
--- Horizontal position of the widget in pixels at a resolution of 1280x720. `x ∈ [0.0, 1280.0]`. Default: `0.0`
reportWidget.x = gralProp("x")
--- Vertical position of the widget in pixels at a resolution of 1280x720. `x ∈ [0.0, 720.0]`. Default: `0.0`
reportWidget.y = gralProp("y")
--- Opacity of the widget. `x ∈ [0.0, 100.0]`. Default: `100.0`
reportWidget.opacity = gralProp("opacity")
--- Individual meter height. Default `17.5`
reportWidget.meterH = gralProp("meterH")
--- Individual meter width. Default `150`
reportWidget.meterW = gralProp("meterW")
--- Vertical gap between meters. It's a percentaje of meter height. x ∈ [0.0, 1.0]`. Default `0.025`
reportWidget.vGap = gralProp("vGap")


-- ;>========================================================
-- ;>===                METER PROPERTIES                ===<;
-- ;>========================================================

local function mProp(name)
    --- @param meterName string
    return function(data, meterName, x)
        if x ~= nil then data.widget[meterName][name] = x
        else return data.widget[meterName][name]
        end
    end
end

reportWidget.mVisible = mProp("visible")
reportWidget.mX = mProp("x")
reportWidget.mY = mProp("y")

-- ;>========================================================
-- ;>===                     METERS                     ===<;
-- ;>========================================================

local function mIterateAll(func, data) for i = 1, nMeters do func(data,  "meter"..i) end end

-- Makes all meters visible.
function reportWidget.mShowAll(data)
    mIterateAll(
        function (data, meterName) reportWidget.mVisible(data, meterName, true) end,
        data
    )
end

local mShown
--- Adds a widget to the visible list if it is visible.
local function mFilterShown(data, meterName)
    if reportWidget.mVisible(data, meterName) then
        table.insert(mShown, meterName)
    end
end

--- Sets the position (x,y) for a single meter based on its relative position in the widget.
local function mCalcPosition(data, meterName, relPos)
    -- Setting x is easy
    reportWidget.mX(data, meterName, reportWidget.x(data))

    -- Total vertical space per meter
    local h = reportWidget.meterH(data)
    local y = (h + (h * reportWidget.vGap(data)))
    -- Relative position
    y = (y * relPos) + reportWidget.y(data)
    reportWidget.mY(data, meterName, y)
end

--- Calculates the positions of all ***visible*** meters in the widget.
function reportWidget.mCalcPositions(data)
    mShown = {}
    mIterateAll(mFilterShown, data)
    local i = 0
    for _,v in pairs(mShown) do
        mCalcPosition(data, v, i)
        i = i + 1
    end
end

-- ;>========================================================
-- ;>===                     SETUP                      ===<;
-- ;>========================================================

--- Generates default settings for the widget.
function reportWidget.default(data)
    reportWidget.vAlign(data, reportWidget.VAlign.top)
    reportWidget.hAlign(data, reportWidget.HAlign.left)
    reportWidget.x(data, 0)
    reportWidget.y(data, 0)
    reportWidget.opacity(data, 100)
    reportWidget.meterH(data, 17.5)
    reportWidget.meterW(data, 150)
    reportWidget.vGap(data, 0.025)
    -- Meters
    reportWidget.mShowAll(data)
    reportWidget.mCalcPositions(data)
    return data
end


-- ;>========================================================
-- ;>===                TREE GENERATION                 ===<;
-- ;>========================================================

local function genColors(data)
    data.widget.colors = {}
    data.widget.colors.flash = {
        normal = 0xffffff, warning = 0xffd966,  danger = 0xff6d01, critical = 0xff0000,
        down = 0xcc0000, up = 0x4f8a35
    }
    data.preset.widget.colors = {}
    data.preset.widget.colors.meter = {
        meter1 = 0xc0c0c0,
        meter2 = 0x6b17cc,
        meter3 = 0xa6c942,
        meter4 = 0xf2e988
    }
end

function reportWidget.generateDataTree(data)
    print("Generating widget\n=================")
    data.preset.widget = {}
    mIterateAll(
        function (data, meterName)
            print("Generating '"..meterName.."'")
            data.widget[meterName] = {}
        end,
        data
    )
    genColors(data)
    print("Finished generating widget\n")
    return data
end

return reportWidget
