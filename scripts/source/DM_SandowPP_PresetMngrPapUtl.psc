Scriptname DM_SandowPP_PresetMngrPapUtl extends DM_SandowPP_PresetManager
{ Preset manager for PapyrusUtils }

import JsonUtil

string Function FProfileFilePre()
    Return "PU"
EndFunction

string Function FProfileFileExt() 
    Return ".json"
EndFunction

; ########################################################################
; Override public functions
; ########################################################################
bool Function Exists()
    Return PapyrusUtil.GetVersion() > 1
EndFunction

bool Function ProfileExists(int profileNum) 
    Return JsonExists( GenerateFileName(profileNum) )
EndFunction

; ########################################################################
; Override private functions
; ########################################################################
Function VirtualSave(int presetNum, DM_SandowPP_Config config)
    string f = GenerateFileName(presetNum)
    SaveReports(f, config)
    SaveMainConfig(f, config)
    SaveOtherConfig(f, config)
    SaveSkills(f, config)
    SaveWidget(f, config)
    Save(f)    
EndFunction

DM_SandowPP_Config Function VirtualLoad(int presetNum)
    string f = GenerateFileName(presetNum)
    LoadMainConfig(f)
    LoadOtherConfig(f)
    LoadReports(f)
    LoadSkills(f)
    LoadWidget(f)
    Return ConfigResults
EndFunction

; ########################################################################
Function SaveSkills(string f, DM_SandowPP_Config config)
    SetFloatValue(f, "skillRatioAr", config.skillRatioAr)
    SetFloatValue(f, "skillRatioBl", config.skillRatioBl)
    SetFloatValue(f, "skillRatioHa", config.skillRatioHa)
    SetFloatValue(f, "skillRatioLa", config.skillRatioLa)
    SetFloatValue(f, "skillRatio1H", config.skillRatio1H)
    SetFloatValue(f, "skillRatioSm", config.skillRatioSm)
    SetFloatValue(f, "skillRatioSn", config.skillRatioSn)
    SetFloatValue(f, "skillRatio2H", config.skillRatio2H)
    
    SetFloatValue(f, "skillRatioAl", config.skillRatioAl)
    SetFloatValue(f, "skillRatioCo", config.skillRatioCo)
    SetFloatValue(f, "skillRatioDe", config.skillRatioDe)
    SetFloatValue(f, "skillRatioIl", config.skillRatioIl)
    SetFloatValue(f, "skillRatioRe", config.skillRatioRe)

    SetFloatValue(f, "physFatigueRate", config.physFatigueRate)
EndFunction

Function LoadSkills(string f)
    ConfigResults.skillRatioAr = GetFloatValue(f, "skillRatioAr")
    ConfigResults.skillRatioBl = GetFloatValue(f, "skillRatioBl")
    ConfigResults.skillRatioHa = GetFloatValue(f, "skillRatioHa")
    ConfigResults.skillRatioLa = GetFloatValue(f, "skillRatioLa")
    ConfigResults.skillRatio1H = GetFloatValue(f, "skillRatio1H")
    ConfigResults.skillRatioSm = GetFloatValue(f, "skillRatioSm")
    ConfigResults.skillRatioSn = GetFloatValue(f, "skillRatioSn")
    ConfigResults.skillRatio2H = GetFloatValue(f, "skillRatio2H")
    
    ConfigResults.skillRatioAl = GetFloatValue(f, "skillRatioAl")
    ConfigResults.skillRatioCo = GetFloatValue(f, "skillRatioCo")
    ConfigResults.skillRatioDe = GetFloatValue(f, "skillRatioDe")
    ConfigResults.skillRatioIl = GetFloatValue(f, "skillRatioIl")
    ConfigResults.skillRatioRe = GetFloatValue(f, "skillRatioRe")
    ConfigResults.physFatigueRate = GetFloatValue(f, "physFatigueRate")
EndFunction

Function SaveReports(string f, DM_SandowPP_Config config)
    SetIntValue(f, "HkShowStatus", config.HkShowStatus)
    SetIntValue(f, "VerboseMod", config.VerboseMod as int)
    SetIntValue(f, "ReportType", config.ReportType)
EndFunction

Function LoadReports(string f)
    ConfigResults.HkShowStatus = GetIntValue(f, "HkShowStatus", -1)
    ConfigResults.VerboseMod = GetIntValue(f, "VerboseMod")
    ConfigResults.ReportType = GetIntValue(f, "ReportType")
EndFunction

Function SaveOtherConfig(string f, DM_SandowPP_Config config)
    SetIntValue(f, "PresetManager", config.PresetManager)
    SetFloatValue(f, "weightGainRate", config.weightGainRate)
    SetIntValue(f, "CanGainHeight", config.CanGainHeight as int)
    SetFloatValue(f, "HeightMax", config.HeightMax)
    SetIntValue(f, "HeightDaysToGrow", config.HeightDaysToGrow)
    SetIntValue(f, "CanResizeHead", config.CanResizeHead as int)
    SetFloatValue(f, "HeadSizeMin", config.HeadSizeMin)
    SetFloatValue(f, "HeadSizeMax", config.HeadSizeMax)
EndFunction

Function LoadOtherConfig(string f)
    ConfigResults.PresetManager = GetIntValue(f, "PresetManager")
    ConfigResults.weightGainRate = GetFloatValue(f, "weightGainRate", 1.0)
    ConfigResults.CanGainHeight = GetIntValue(f, "CanGainHeight")
    ConfigResults.HeightMax = GetFloatValue(f, "HeightMax", 0.06)
    ConfigResults.HeightDaysToGrow = GetIntValue(f, "HeightDaysToGrow", 120)
    ConfigResults.CanResizeHead = GetIntValue(f, "CanResizeHead")
    ConfigResults.HeadSizeMin = GetFloatValue(f, "HeadSizeMin", 1.0)
    ConfigResults.HeadSizeMax = GetFloatValue(f, "HeadSizeMax", 1.0)
EndFunction

Function SaveMainConfig(string f, DM_SandowPP_Config config)
    SetIntValue(f, "Behavior", config.Behavior)
    SetIntValue(f, "CanLoseWeight", config.CanLoseWeight as int)
    SetIntValue(f, "DiminishingReturns", config.DiminishingReturns as int)
    SetIntValue(f, "CanReboundWeight", config.CanReboundWeight as int)
    SetIntValue(f, "HungerAffectsGains", config.HungerAffectsGains as int)
EndFunction

Function LoadMainConfig(string f)
    ConfigResults.Behavior = GetIntValue(f, "Behavior")
    ConfigResults.CanLoseWeight = GetIntValue(f, "CanLoseWeight")
    ConfigResults.DiminishingReturns = GetIntValue(f, "DiminishingReturns")
    ConfigResults.CanReboundWeight = GetIntValue(f, "CanReboundWeight")
    ConfigResults.HungerAffectsGains = GetIntValue(f, "HungerAffectsGains")
EndFunction

Function SaveWidget(string f, DM_SandowPP_Config config)
    SetFloatValue(f, "rwUpdateTime", config.rwUpdateTime)
    SetFloatValue(f, "rwOpacity", config.rwOpacity)
    SetFloatValue(f, "rwScale", config.rwScale)
    SetStringValue(f, "rwHAlign", config.rwHAlign)
    SetStringValue(f, "rwVAlign", config.rwVAlign)
    SetFloatValue(f, "rwX", config.rwX)
    SetFloatValue(f, "rwY", config.rwY)
EndFunction

Function LoadWidget(string f)
    ConfigResults.rwUpdateTime  = GetFloatValue(f, "rwUpdateTime")
    ConfigResults.rwOpacity     = GetFloatValue(f, "rwOpacity")
    ConfigResults.rwScale       = GetFloatValue(f, "rwScale")
    ConfigResults.rwHAlign      = GetStringValue(f, "rwHAlign")
    ConfigResults.rwVAlign      = GetStringValue(f, "rwVAlign")
    ConfigResults.rwX           = GetFloatValue(f, "rwX")
    ConfigResults.rwY           = GetFloatValue(f, "rwY")
EndFunction