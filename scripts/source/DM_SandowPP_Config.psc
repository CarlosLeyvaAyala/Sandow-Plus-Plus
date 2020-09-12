Scriptname DM_SandowPP_Config extends Quest
{ This object stores config info }
Import DM_SandowPP_Globals

DM_SandowPPMain Property Owner auto

bool property BatchLoading = False auto

bool _canLoseWeight = True

bool property DiminishingReturns auto
bool property CanLoseWeight
    bool Function get()
        Return _canLoseWeight
    EndFunction
    Function set(bool v)
        _canLoseWeight = v
        Configure()
    EndFunction
EndProperty
bool property CanReboundWeight auto
bool property VerboseMod auto

bool property HungerAffectsGains
    bool Function get()
        Return _hungerAffectsGains
    EndFunction
    Function set(bool v)
        _hungerAffectsGains = v
        Configure()
    EndFunction
EndProperty

bool property CanGetDisease auto
bool property CanGainHeight auto

int property HkShowStatus
    int Function get()
        return _hkShowStatus
    EndFunction
    Function set(int newKey)
        RegisterHotkey(_hkShowStatus, newKey)
        _hkShowStatus = newKey
    EndFunction
EndProperty

int Property HeightDaysToGrow = 120 Auto
float Property HeightMax = 0.06 Auto

float Property skillRatio2H auto
float Property skillRatio1H auto
float Property skillRatioBl auto
float Property skillRatioAr auto
float Property skillRatioHa auto
float Property skillRatioLa auto
float Property skillRatioSn auto
float Property skillRatioSm auto
float Property skillRatioAl auto
float Property skillRatioCo auto
float Property skillRatioDe auto
float Property skillRatioIl auto
float Property skillRatioRe auto

float property skillDefault2H = 0.5 AutoReadOnly
float property skillDefault1H = 0.25 AutoReadOnly
float property skillDefaultBl = 0.25 AutoReadOnly
float property skillDefaultAr = 0.2 AutoReadOnly
float property skillDefaultHa = 0.33 AutoReadOnly
float property skillDefaultLa = 0.2 AutoReadOnly
float property skillDefaultSn = 0.25 AutoReadOnly
float property skillDefaultSm = 0.25 AutoReadOnly
float property skillDefaultAl = 0.2 AutoReadOnly
float property skillDefaultCo = 0.0 AutoReadOnly
float property skillDefaultDe = 0.0 AutoReadOnly
float property skillDefaultIl = 0.0 AutoReadOnly
float property skillDefaultRe = 0.15 AutoReadOnly
float property weightGainRate = 1.0 Auto Hidden
{Multiplier to weight gains. Configurable by player. Expected range: [0.1, 2.0], ie. [10, 200]%}

float property physFatigueRate auto
float property magFatigueRate
    float function get()
        return physFatigueRate * magFatigueRateMultiplier
    endFunction
endProperty
float property magFatigueRateMultiplier = 2.0 AutoReadOnly

float property trainFatigueRate
    {Fatigue rate for training with weights.}
    float function get()
    return physFatigueRate * 4.0
    endFunction
endProperty
; ==============================
int property Behavior
    int Function get()
        Return _behavior
    EndFunction
    Function set(int v)
        _behavior = v
        Configure()
    EndFunction
EndProperty

int Property bhPause = 0 AutoReadOnly
int Property bhSandowPP = 1 AutoreadOnly
int Property bhPumpingIron = 2 AutoreadOnly
int Property bhBruce = 3 AutoReadOnly

bool Function IsPaused()
    Return Behavior == bhPause
EndFunction

bool Function IsSandow()
    Return Behavior == bhSandowPP
EndFunction

bool Function IsPumpingIron()
    Return Behavior == bhPumpingIron
EndFunction

bool Function IsBruce()
    Return Behavior == bhBruce
EndFunction


; ==============================
string Property operationResult Auto        ; Used to get file manipulation information
bool Property skillsLocked = False Auto     ; Can player change skill rates in the MCM?

; ==============================
int property PresetManager
    int Function get()
        Return _presetManager
    EndFunction
    Function set(int v)
        _presetManager = v
        Configure()
    EndFunction
EndProperty
int Property pmNone = 0 AutoReadOnly
int Property pmPapyrusUtil = 1 AutoReadOnly
int Property pmFISS = 2 AutoReadOnly

; ==============================
int property ReportType
    int Function get()
        Return _reportType
    EndFunction
    Function set(int v)
        _reportType = v
        Configure()
    EndFunction
EndProperty
int Property rtDebug = 0 AutoReadOnly
int Property rtSkyUiLib = 1 AutoReadOnly
int Property rtWidget = 2 AutoReadOnly


;>=========================================================
;>===                       RIPPED                      ===
;>=========================================================

int Property rpmNone = 0 AutoReadOnly
int Property rpmConst = 1 AutoReadOnly
int Property rpmWeight = 2 AutoReadOnly
int Property rpmWInv = 3 AutoReadOnly
int Property rpmSkill = 4 AutoReadOnly

;> ============== Player options ==============
int Property rpmBhv = 5 AutoReadOnly

int Property bulkSPP = 0 AutoReadOnly
int Property bulkPI = 1 AutoReadOnly

;> ============== NPC options ==============
int Property rpmRand = 5 AutoReadOnly
int Property rpmThin = 6 AutoReadOnly
int Property rpmMuscle = 7 AutoReadOnly

;>=========================================================
;>===                       WIDGET                      ===
;>=========================================================

float Property rwUpdateTime
    Function set(float val)
        If val == 0.0
            val = 5.0
        EndIf
        _RWupdateTime = val
        Configure()
    EndFunction
    float Function get()
        Return _RWupdateTime
    EndFunction
EndProperty

float Property rwScale
    Function set(float val)
        If val == 0.0
            val = 1.0
        EndIf
        _RWscale = val
        Configure()
    EndFunction
    float Function get()
        Return _RWscale
    EndFunction
EndProperty

float Property rwOpacity
    Function set(float val)
        If val == 0.0
            val = 100.0
        EndIf
        _RWalpha = val
        Configure()
    EndFunction
    float Function get()
        Return _RWalpha
    EndFunction
EndProperty

float Property rwX
    Function set(float val)
        _RWx = val
        Configure()
    EndFunction
    float Function get()
        Return _RWx
    EndFunction
EndProperty

float Property rwY
    Function set(float val)
        _RWy = val
        Configure()
    EndFunction
    float Function get()
        Return _RWy
    EndFunction
EndProperty

string Property rwVAlign
    Function set(string val)
        If val == ""
            val = "top"
        EndIf
        _RWvAlign = val
        Configure()
    EndFunction
    string Function get()
        Return _RWvAlign
    EndFunction
EndProperty

string Property rwHAlign
    Function set(string val)
        If val == ""
            val = "left"
        EndIf
        _RWhAlign = val
        Configure()
    EndFunction
    string Function get()
        Return _RWhAlign
    EndFunction
EndProperty

float _RWscale          = 1.0
float _RWalpha          = 100.0
float _RWupdateTime     = 3.0
float _RWx
float _RWy
string _RWvAlign         = "top"
string _RWhAlign         = "left"

; ==============================
bool property CanResizeHead = False Auto Hidden
float property HeadSizeMin = 1.0 Auto Hidden
float property HeadSizeMax = 1.0 Auto Hidden

;>=========================================================###############
; Public constants
int property hotkeyInvalid = -1 AutoReadOnly

;>=========================================================###############
; Private variables
bool _hungerAffectsGains
int _hkShowStatus
int _behavior
int _presetManager
int _reportType

;>=========================================================###############
; Public functions. Call them from wherever you want.
;>=========================================================###############

Function DefaultSkills()
    skillRatio2H = skillDefault2H
    skillRatio1H = skillDefault1H
    skillRatioBl = skillDefaultBl
    skillRatioAr = skillDefaultAr
    skillRatioHa = skillDefaultHa
    skillRatioLa = skillDefaultLa
    skillRatioSn = skillDefaultSn
    skillRatioSm = skillDefaultSm
    skillRatioAl = skillDefaultAl
    skillRatioCo = skillDefaultCo
    skillRatioDe = skillDefaultDe
    skillRatioIl = skillDefaultIl
    skillRatioRe = skillDefaultRe
EndFunction

Function Assign(DM_SandowPP_Config other)
    BatchLoading = True
    AssignReports(other)
    AssignMainConfig(other)
    AssignOtherConfig(other)
    AssignSkills(other)
    AssignWidget(other)
    AssignMisc(other)
    BatchLoading = False
    Configure()
EndFunction

bool Function IsSkyUiLib()
    Return ReportType == rtSkyUiLib
EndFunction

bool Function IsWidget()
    Return ReportType == rtWidget
EndFunction

;>=========================================================###############
; Private functions. These are designed to be used only within
; this script. Never call them from the outside.
;>=========================================================###############

Function Configure()
    If Owner != None && !BatchLoading
        Owner.Configure()
    EndIf
EndFunction

Function RegisterHotkey(int aOldKey, int aNewKey)
    If Owner != None
        Owner.RegisterHotkey(aOldKey, aNewKey)
    EndIf
EndFunction

Function AssignSkills(DM_SandowPP_Config other)
    skillRatio2H = other.skillRatio2H
    skillRatio1H = other.skillRatio1H
    skillRatioBl = other.skillRatioBl
    skillRatioAr = other.skillRatioAr
    skillRatioHa = other.skillRatioHa
    skillRatioLa = other.skillRatioLa
    skillRatioSn = other.skillRatioSn
    skillRatioSm = other.skillRatioSm
    skillRatioAl = other.skillRatioAl
    skillRatioCo = other.skillRatioCo
    skillRatioDe = other.skillRatioDe
    skillRatioIl = other.skillRatioIl
    skillRatioRe = other.skillRatioRe
    physFatigueRate = other.physFatigueRate
EndFunction

Function AssignReports(DM_SandowPP_Config other)
    HkShowStatus = other.HkShowStatus
    VerboseMod = other.VerboseMod
    ReportType = other.ReportType
EndFunction

Function AssignMainConfig(DM_SandowPP_Config other)
    Behavior = other.Behavior
    CanLoseWeight = other.CanLoseWeight
    DiminishingReturns = other.DiminishingReturns
    CanReboundWeight = other.CanReboundWeight
    HungerAffectsGains = other.HungerAffectsGains
EndFunction

Function AssignOtherConfig(DM_SandowPP_Config other)
    PresetManager = other.PresetManager
    CanGainHeight = other.CanGainHeight
    HeightMax = other.HeightMax
    HeightDaysToGrow = other.HeightDaysToGrow
    weightGainRate = other.weightGainRate
    CanResizeHead = other.CanResizeHead
    HeadSizeMin = other.HeadSizeMin
    HeadSizeMax = other.HeadSizeMax
EndFunction

Function AssignMisc(DM_SandowPP_Config other)
    operationResult = other.operationResult
EndFunction

Function AssignWidget(DM_SandowPP_Config other)
    rwScale = other.rwScale
    rwUpdateTime = other.rwUpdateTime
    rwOpacity = other.rwOpacity
    rwX = other.rwX
    rwY = other.rwY
    rwVAlign = other.rwVAlign
    rwHAlign = other.rwHAlign
EndFunction
