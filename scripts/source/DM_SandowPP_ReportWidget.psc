Scriptname DM_SandowPP_ReportWidget extends DM_SandowPP_Report
{Widget controller. Controls meters as a group and dispatches messages to relevant meters}

Import DM_SandowPP_Globals

DM_SandowPPMain Property Owner Auto
DM_SandowPP_ReportMeter01 Property Meter01 Auto
DM_SandowPP_ReportMeter02 Property Meter02 Auto
DM_SandowPP_ReportMeter03 Property Meter03 Auto
DM_SandowPP_ReportMeter04 Property Meter04 Auto

bool Property Visible
    Function set(bool val)
        _visible = val
        If val
            Show()
        Else
            Hide()
        EndIf
    EndFunction
    bool Function get()
        Return _visible
    EndFunction
EndProperty

float Property UpdateTime = 3.0 Auto
float Property Opacity = 100.0 Auto
{Opacity of the widget [0.0, 100.0]. Default: 100.0}
float Property Scale = 1.0 Auto
float Property X = 0.0 Auto
{Horizontal position of the widget in pixels at a resolution of 1280x720 [0.0, 1280.0]. Default: 0.0}
float Property Y = 0.0 Auto
{Vertical position of the widget in pixels at a resolution of 1280x720 [0.0, 720.0]. Default: 0.0}
string Property VAlign = "top" Auto 
{Vertical anchor point of the widget ["top", "center", "bottom"]. Default: "top"}
string Property HAlign = "left" Auto
{Horizontal anchor point of the widget ["left", "center", "right"]. Default: "left"}

bool _visible = False
int invalid = -1
int[] _messageDispatcher        ; Dispatches messages to the correct meter
bool[] _permaHide               ; Tells which meters are always hidden
float _baseMeterH = 17.5
float _baseMeterW = 150.0
DM_SandowPP_ReportMeterBase[] _meters


;##########################################################################
;###                        SETUP FUNCTIONS                             ###
;##########################################################################

Function OnEnter()
    {Code executed when selecting this report type}
    Trace(Self + ".OnEnter()")

    Owner.PrepareAlgorithmData()
    Owner.ConfigureWidget()
    Visible = True
EndFunction

Function OnExit()
    {Code executed when selecting any other report type}
    Trace(Self + ".OnExit()")
    
    Visible = False
    Clear()
EndFunction

Event OnInit()
    InitMeters()
    UpdateConfig()
    Visible = False
EndEvent

Function Clear()
    ResetDispatcher()
    ResetPermaHide()
EndFunction

Function InitMeters()
    ResetDispatcher()
    ResetPermaHide()
    _meters = New DM_SandowPP_ReportMeterBase[4]
    _meters[0] = Meter01
    _meters[1] = Meter02
    _meters[2] = Meter03
    _meters[3] = Meter04
EndFunction

Function ResetPermaHide()
    _permaHide = New bool[4] 
EndFunction

Function ResetDispatcher()
    _messageDispatcher = New int[10] 
EndFunction

;##########################################################################
;###                        REPORTING FUNCTIONS                         ###
;##########################################################################

; Visible and running
State Active
    Event OnUpdate()
        Refresh()
    EndEvent

    Function OnHotkeyReport(DM_SandowPP_Algorithm aSender)
        {Special handling when the player presses the report hotkey}
        FadeOut()
    EndFunction
EndState

; Invisible and not running
State Hidden
    Function OnHotkeyReport(DM_SandowPP_Algorithm aSender)
        {Special handling when the player presses the report hotkey}
        FadeIn()
        Refresh()
    EndFunction
EndState

Function Refresh()
    {Data polling}
    Owner.Algorithm.ReportEssentials(Owner.AlgorithmData)
    RegisterForSingleUpdate(UpdateTime)
EndFunction

Event OnUpdate()
    {Unregister if not active}
EndEvent

Function Notification(DM_SandowPP_ReportArgs args)
    {Notify what happened}
    Trace("ReportWidget.Notification()")

    NotifyWithText(args)
    Dispatch(args)
EndFunction

Function Dispatch(DM_SandowPP_ReportArgs args)
    {Forward the message to the proper meter}
    Trace("ReportWidget.Dispatch()")
    Trace("Category = " + args.aCategory)
    Trace("Type = " + args.aType)
    Trace("Float value = " + args.aFVal)
    
    If args.aCategory == 0
        Return
    EndIf
    int meterId = _messageDispatcher[args.aCategory]
    DM_SandowPP_ReportMeterBase m = _meters[meterId]
    m.OnUpdateDisplay(Self, args.aFVal, args.aType)
    HideIfMax(m, meterId, args.aCategory, args.aFVal)
EndFunction

Function HideIfMax(DM_SandowPP_ReportMeterBase m, int mId, int aCat, float aPercent)
    {Meters that can be hidden when reaching max value are hardcoded to weight and WGP meters}
    Trace("ReportWidget.HideIfMax()")
    Trace(m)
    
    If !(aCat == mcWeight || aCat == mcWGP)
        Return
    EndIf
    If HideMeterIfMax(m, mId, aPercent)
        TweenAllToNewPos()
    EndIf
EndFunction

bool Function HideMeterIfMax(DM_SandowPP_ReportMeterBase m, int mId, float aPercent)
    {Hides a single meter if reached max percent. Returns <True> if changes were made.}
    Trace("ReportWidget.HideMeterIfMax()")
    bool hideThis = aPercent >= 1.0
    If MeterIsHidden(mId) == hideThis
        Trace("No changes made.")
        Return False
    EndIf
    HidePermanently(mId, hideThis)
    float a
    If hideThis
        a = 0.0
    Else
        a = Opacity
    EndIf
    m.FadeTo(a, 1.0)
    Return True
EndFunction

Function TweenAllToNewPos()
    {Tween all meters to their new position}
    Trace("ReportWidget.TweenAllToNewPos()")
    int i = 0
    int pos = 0
    While IterateMeters(i)
        If !_permaHide[i]
            _meters[i].TweenToY(MeterPosY(pos), 1.0)
            pos += 1
        EndIf
        i += 1
    EndWhile
EndFunction


Function NotifyWithText(DM_SandowPP_ReportArgs args)
    {Player may want to know how much his stats have changed}
    If args.aType == mtDown || args.aType == mtUp
        Debug.Notification(args.aText)
    EndIf
EndFunction

Function RegisterMessageCategory(int aCat, int id = -1)
    {Enables a meter to catch report messages}
    Trace("ReportWidget.RegisterMessageCategory()")
    Trace("aCat = " + aCat)
    Trace("id = " + id)
    
    If id >= 0 && aCat > 0
        _messageDispatcher[aCat] = id
    EndIf
EndFunction

Function HidePermanently(int id, bool aHide)
    {Avoid a meter from ever showing}
    Trace("ReportWidget.HidePermanently(" + id + ", " + aHide + ")")
    _permaHide[id] = aHide
EndFunction

Function HideNow(int id, bool aHide)
    Trace("ReportWidget.HideNow(" + id + ", " + aHide + ")")
    If _meters[id].IsHidden()
        Return
    EndIf
    If aHide
        _meters[id].Hide()
    Else
        _meters[id].Show()
    EndIf
EndFunction

bool Function MeterIsHidden(int id)
    bool r = _permaHide[id]
    Trace("ReportWidget.MeterIsHidden(" + id + ")")
    Trace("IsHidden = " + r)
    Return r
EndFunction

;##########################################################################
;###                        APPEARANCE FUNCTIONS                        ###
;##########################################################################

Function Hide()
    Trace("ReportWidget.Hide()")
    int i = 0
    While IterateMeters(i)
        _meters[i].Hide()
        i += 1
    EndWhile
    GotoState("Hidden")
    UnregisterForUpdate()
EndFunction

Function Show()
    Trace("ReportWidget.Show()")
    int i = 0
    While IterateMeters(i)
        If !_permaHide[i]
            _meters[i].Show()
        EndIf
        i += 1
    EndWhile
    GotoState("Active")
    Refresh()
EndFunction

Function FadeOut()
    Fade(0.0, "Hidden")
EndFunction

Function FadeIn()
    Fade(Opacity, "Active")
    Refresh()
EndFunction

Function Fade(float aAlpha, string aState)
    GotoState("Fade")
    int i = 0
    While IterateMeters(i)
        If !_permaHide[i]
            _meters[i].FadeTo(aAlpha, 0.35)
        EndIf
        i += 1
    EndWhile
    Utility.Wait(0.4)
    GotoState(aState)
EndFunction

float Function GetXOffset()
    {Used to calculate H anchors}
    If HAlign == "center"
        Return 1280.0 / 2.0
    ElseIf HAlign == "right"
        Return 1280.0
    Else
        Return 0.0
    EndIf
EndFunction

float Function GetYOffset()
    {Used to calculate V anchors}
    If VAlign == "center"
        Return 720.0 / 2.0
    ElseIf VAlign == "bottom"
        Return 720.0
    Else
        Return 0.0
    EndIf
EndFunction

Function UpdateConfig()
    {Updates appearance according to current configuration}
    Trace("ReportWidget.UpdateConfig()")
    If !Visible
        Return
    EndIf
    int i = 0
    int pos = 0
    While IterateMeters(i)
        If !_permaHide[i]
            SetMeterAppearance(i, pos)
            pos += 1
        Else    
            _meters[i].Hide()
        EndIf
        i += 1
    EndWhile
EndFunction

Function SetMeterAppearance(int i, int pos)
    _meters[i].Alpha = Opacity
    _meters[i].Height = _baseMeterH * Scale
    _meters[i].Width = _baseMeterW * Scale
    _meters[i].Y = MeterPosY(pos)
    _meters[i].X = MeterPosX()
    _meters[i].HAnchor = HAlign
    _meters[i].VAnchor = VAlign
EndFunction

float Function MeterPosY(int pos)
    {Calculate Y for meter at position <pos>}
    float vSeparation = 0.025
    ; Asuming all meters are the same size
    Return (pos * _meters[0].Height) + (_meters[0].Height * vSeparation) + Y + GetYOffset()
EndFunction

float Function MeterPosX()
    Return X + GetXOffset()
EndFunction


;##########################################################################
;###                            OTHER FUNCTIONS                         ###
;##########################################################################

bool Function IterateMeters(int i)
    {The meter exists and we are inside the array boundaries}
    Return _meters[i] && i < _meters.length
EndFunction

string Function MCMInfo()
    {Show this report type info in the MCM}
    Return "$MCM_ReportTypeWidgetInfo"
EndFunction

string Function MCMHotkeyInfo()
    {Tell the player he can use the hotkey to hide the widget}
    Return "$MCM_HKStatusRWInfo"
EndFunction