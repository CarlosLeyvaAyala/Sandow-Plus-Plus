local dmlib = jrequire 'dmlib'
local l = jrequire 'sandowpp.shared'
local const = jrequire 'sandowpp.const'
-- local l = jrequire 'sandowpp.sandowpp.shared'
-- local const = jrequire 'sandowpp.sandowpp.const'

local reportWidget = {}

local nMeters = 4

reportWidget.VAlign = {top = "top", center = "center", bottom = "bottom"}
reportWidget.HAlign = {left = "left", center = "center", right = "right"}


-- ;>========================================================
-- ;>===             WIDGET MCM PROPERTIES              ===<;
-- ;>========================================================

--- Creates a general property. These are shown in the MCM and apply to all meters.
local function mcmProp(name)
    return function(data, x)
        if x ~= nil then data.preset.widget[name] = x
        else return data.preset.widget[name]
        end
    end
end

--- Vertical anchor point of the widget. Default: `"top"`.
reportWidget.vAlign = mcmProp("vAlign")

--- Horizontal anchor point of the widget. Default: `"left"`.
reportWidget.hAlign = mcmProp("hAlign")

--- Horizontal position of the widget in pixels at a resolution of 1280x720.
--- `x ∈ [0.0, 1280.0]`. Default: `0.0`
reportWidget.x = mcmProp("x")

--- Vertical position of the widget in pixels at a resolution of 1280x720.
--- `x ∈ [0.0, 720.0]`. Default: `0.0`
reportWidget.y = mcmProp("y")

--- Opacity of the widget. `x ∈ [0.0, 100.0]`. Default: `100.0`
reportWidget.opacity = mcmProp("opacity")

--- Individual meter height. Default `17.5`
reportWidget.meterH = mcmProp("meterH")

--- Individual meter width. Default `150`
reportWidget.meterW = mcmProp("meterW")

--- Vertical gap between meters. It's a percentaje of meter height.
--- x ∈ [-0.3, 2.3]`. Default `-0.1`
reportWidget.vGap = mcmProp("vGap")

--- Transition time. How much seconds it takes to tween, fade...
reportWidget.transT = mcmProp("transT")

--- Hides the meter is it's at min.
reportWidget.hideAtMin = mcmProp("hideAtMin")

--- Hides the meter is it's at max.
reportWidget.hideAtMax = mcmProp("hideAtMax")

--- How fast will the widget update.
reportWidget.refreshRate = mcmProp("refreshRate")


-- ;>========================================================
-- ;>===                 GLOBAL HIDDEN                  ===<;
-- ;>========================================================

--- Creates a hidden general property. These are ***not shown in the MCM*** and apply to all meters.
local function hidGProp(name)
    return function(data, x)
        if x ~= nil then data.widget[name] = x
        else return data.widget[name]
        end
    end
end

--- Tweens all meters instead of just putting them in place.
reportWidget.tweenToPos = hidGProp("tweenToPos")


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

local mX = mProp("x")
local mY = mProp("y")
reportWidget.mVisible = mProp("visible")
reportWidget.mFlash = mProp("flash")
reportWidget.mPercent = mProp("percent")
reportWidget.mName = mProp("name")
reportWidget.mMsg = mProp("message")

-- ;>========================================================
-- ;>===                     METERS                     ===<;
-- ;>========================================================
reportWidget.flashCol = {
    normal = 0xffffff, warning = 0xffd966,  danger = 0xff6d01, critical = 0xff0000,
    down = 0xcc0000, up = 0x4f8a35
}

local function mIterateAll(func, data) for i = 1, nMeters do func(data,  "meter"..i) end end

local function mPercentAll(data, val)
    mIterateAll(
        function (data, meterName) reportWidget.mPercent(data, meterName, val) end,
        data
    )
end

-- Makes all meters visible.
function reportWidget.setVisibeAll(data, val)
    mIterateAll(
        function (data, meterName) reportWidget.mVisible(data, meterName, val) end,
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

local function mGetBaseX(data)
    local mx, align = 1280, reportWidget.hAlign(data)
    if align == reportWidget.HAlign.center then return mx / 2
    elseif align == reportWidget.HAlign.right then return mx
    else return 0
    end
end

--- Total vertical space per meter. Gap included.
local function mFullMeterH(data)
    local h = reportWidget.meterH(data)
    return h + h * reportWidget.vGap(data)
end

local function fullWidgetH(data)
    local h = mFullMeterH(data) * (#mShown - 1) + reportWidget.meterH(data)
    return dmlib.forcePositve(h)
end

local function mGetYDisplace(data, align)
    if (align ~= reportWidget.VAlign.top) and (#mShown > 1) then
        local wh = fullWidgetH(data)
        local mh = reportWidget.meterH(data)
        return mh - wh
    else return 0
    end
end

local function mGetBaseY(data)
    local my, align = 720, reportWidget.vAlign(data)
    if align ~= reportWidget.VAlign.top then
        local displace = my + mGetYDisplace(data, align)
        if align == reportWidget.VAlign.center then displace = displace / 2 end
        return displace
    end
    return 0
end

--- Sets the position (x,y) for a single meter based on its relative position in the widget.
local function mCalcPosition(data, meterName, relPos)
    mX(data, meterName, reportWidget.x(data) + mGetBaseX(data))

    local y = mFullMeterH(data)
    y = (y * relPos) + reportWidget.y(data) + mGetBaseY(data)
    mY(data, meterName, y)
end

local function mGetShown(data)
    mShown = {}
    mIterateAll(mFilterShown, data)
end

local function mCalcShownPos(data)
    local i = 0
    for _,v in pairs(mShown) do
        mCalcPosition(data, v, i)
        i = i + 1
    end
end

--- Calculates the positions of all ***visible*** meters in the widget.
function reportWidget.mCalcPositions(data)
    mGetShown(data)
    mCalcShownPos(data)
    return data
end

-- ;>========================================================
-- ;>===                     SETUP                      ===<;
-- ;>========================================================

--- Generates default settings for the widget.
function reportWidget.default(data)
    reportWidget.vAlign(data, reportWidget.VAlign.top)
    reportWidget.hAlign(data, reportWidget.HAlign.right)
    reportWidget.x(data, 0)
    reportWidget.y(data, 0)
    reportWidget.refreshRate(data, 5)
    reportWidget.opacity(data, 100)
    reportWidget.meterH(data, 17.5)
    reportWidget.meterW(data, 150)
    reportWidget.vGap(data, -0.31)
    reportWidget.transT(data, 1)
    reportWidget.hideAtMin(data, false)
    reportWidget.hideAtMax(data, true)
    reportWidget.tweenToPos(data, false)
    -- Meters
    reportWidget.setVisibeAll(data, true)
    reportWidget.mCalcPositions(data)
    mPercentAll(data, 0.0)
    -- reportWidget.mFlash(data, "meter1", reportWidget.flashCol.danger)
    -- reportWidget.mFlash(data, "meter2", reportWidget.flashCol.critical)
    return data
end

function reportWidget.changeVAlign(data, align)
    reportWidget.vAlign(data, align)
    return reportWidget.mCalcPositions(data)
end

-- ;>========================================================
-- ;>===                TREE GENERATION                 ===<;
-- ;>========================================================

local function genColors(data)
    data.widget.flash = reportWidget.flashCol
    data.preset.widget.colors = {
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
