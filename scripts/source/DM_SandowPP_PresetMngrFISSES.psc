Scriptname DM_SandowPP_PresetMngrFISSES extends DM_SandowPP_PresetManager
{ Preset manager for FISSES }
import FISSFactory

string Function FProfileFilePre()
    Return "FISS"
EndFunction

string Function FProfileFileExt() 
    Return ".xml"
EndFunction

string Property ModName = "Sandow Plus Plus" AutoReadOnly

; ########################################################################
; Override public functions
; ########################################################################
bool Function Exists()
    Return getFISS() != None
EndFunction

bool Function ProfileExists(int profileNum) 
    FISSInterface fiss = getFISS()
    fiss.beginLoad(GenerateFileName(profileNum))
    string loadResult = fiss.endLoad()
    Return loadResult == ""
EndFunction

; ########################################################################
; Override private functions
; ########################################################################
Function VirtualSave(int presetNum, DM_SandowPP_Config config)
    FISSInterface fiss = getFISS()
    string f = GenerateFileName(presetNum)
    fiss.beginSave(f, ModName)
    SaveReports(fiss, config)
    SaveMainConfig(fiss, config)
    SaveOtherConfig(fiss, config)
    SaveSkills(fiss, config)
    SaveWidget(fiss, config)
    fiss.endSave()    
EndFunction

DM_SandowPP_Config Function VirtualLoad(int presetNum)
    FISSInterface fiss = getFISS()
    string f = GenerateFileName(presetNum)
    fiss.beginLoad(f)
    LoadReports(fiss)
    LoadMainConfig(fiss)
    LoadOtherConfig(fiss)
    LoadSkills(fiss)
    LoadWidget(fiss)
    fiss.endLoad()
    Return ConfigResults
EndFunction

; ########################################################################
Function SaveSkills(FISSInterface fiss, DM_SandowPP_Config config)
    fiss.saveFloat("skillRatioAr", config.skillRatioAr)
    fiss.saveFloat("skillRatioBl", config.skillRatioBl)
    fiss.saveFloat("skillRatioHa", config.skillRatioHa)
    fiss.saveFloat("skillRatioLa", config.skillRatioLa)
    fiss.saveFloat("skillRatio1H", config.skillRatio1H)
    fiss.saveFloat("skillRatioSm", config.skillRatioSm)
    fiss.saveFloat("skillRatioSn", config.skillRatioSn)
    fiss.saveFloat("skillRatio2H", config.skillRatio2H)
    
    fiss.saveFloat("skillRatioAl", config.skillRatioAl)
    fiss.saveFloat("skillRatioCo", config.skillRatioCo)
    fiss.saveFloat("skillRatioDe", config.skillRatioDe)
    fiss.saveFloat("skillRatioIl", config.skillRatioIl)
    fiss.saveFloat("skillRatioRe", config.skillRatioRe)

    fiss.saveFloat("physFatigueRate", config.physFatigueRate)
EndFunction

Function LoadSkills(FISSInterface fiss)
    ConfigResults.skillRatioAr = fiss.loadFloat("skillRatioAr")
    ConfigResults.skillRatioBl = fiss.loadFloat("skillRatioBl")
    ConfigResults.skillRatioHa = fiss.loadFloat("skillRatioHa")
    ConfigResults.skillRatioLa = fiss.loadFloat("skillRatioLa")
    ConfigResults.skillRatio1H = fiss.loadFloat("skillRatio1H")
    ConfigResults.skillRatioSm = fiss.loadFloat("skillRatioSm")
    ConfigResults.skillRatioSn = fiss.loadFloat("skillRatioSn")
    ConfigResults.skillRatio2H = fiss.loadFloat("skillRatio2H")
    
    ConfigResults.skillRatioAl = fiss.loadFloat("skillRatioAl")
    ConfigResults.skillRatioCo = fiss.loadFloat("skillRatioCo")
    ConfigResults.skillRatioDe = fiss.loadFloat("skillRatioDe")
    ConfigResults.skillRatioIl = fiss.loadFloat("skillRatioIl")
    ConfigResults.skillRatioRe = fiss.loadFloat("skillRatioRe")

    ConfigResults.physFatigueRate = fiss.loadFloat("physFatigueRate")
EndFunction

Function SaveReports(FISSInterface fiss, DM_SandowPP_Config config)
    fiss.saveInt("HkShowStatus", config.HkShowStatus)
    fiss.saveBool("VerboseMod", config.VerboseMod)
    fiss.saveInt("ReportType", config.ReportType)
EndFunction

Function LoadReports(FISSInterface fiss)
    ConfigResults.HkShowStatus = fiss.loadInt("HkShowStatus")
    ConfigResults.VerboseMod = fiss.loadBool("VerboseMod")
    ConfigResults.ReportType = fiss.loadInt("ReportType")
EndFunction

Function SaveOtherConfig(FISSInterface fiss, DM_SandowPP_Config config)
    fiss.saveInt("PresetManager", config.PresetManager)
    fiss.saveBool("CanGainHeight", config.CanGainHeight)
    fiss.saveFloat("HeightMax", config.HeightMax)
    fiss.saveInt("HeightDaysToGrow", config.HeightDaysToGrow)

    fiss.saveBool("CanResizeHead", config.CanResizeHead)
    fiss.saveFloat("HeadSizeMin", config.HeadSizeMin)
    fiss.saveFloat("HeadSizeMax", config.HeadSizeMax)
EndFunction

Function LoadOtherConfig(FISSInterface fiss)
    ConfigResults.PresetManager = fiss.loadInt("PresetManager")
    ConfigResults.CanGainHeight = fiss.loadBool("CanGainHeight")
    ConfigResults.HeightMax = fiss.loadFloat("HeightMax")
    ConfigResults.HeightDaysToGrow = fiss.loadInt("HeightDaysToGrow")

    ConfigResults.CanResizeHead = fiss.loadBool("CanResizeHead")
    ConfigResults.HeadSizeMin = fiss.loadFloat("HeadSizeMin")
    ConfigResults.HeadSizeMax = fiss.loadFloat("HeadSizeMax")
EndFunction

Function SaveMainConfig(FISSInterface fiss, DM_SandowPP_Config config)
    fiss.saveInt("Behavior", config.Behavior)
    fiss.saveBool("CanLoseWeight", config.CanLoseWeight)
    fiss.saveBool("DiminishingReturns", config.DiminishingReturns)
    fiss.saveBool("CanReboundWeight", config.CanReboundWeight)
    fiss.saveBool("HungerAffectsGains", config.HungerAffectsGains)
EndFunction

Function LoadMainConfig(FISSInterface fiss)
    ConfigResults.Behavior = fiss.loadInt("Behavior")
    ConfigResults.CanLoseWeight = fiss.loadBool("CanLoseWeight")
    ConfigResults.DiminishingReturns = fiss.loadBool("DiminishingReturns")
    ConfigResults.CanReboundWeight = fiss.loadBool("CanReboundWeight")
    ConfigResults.HungerAffectsGains = fiss.loadBool("HungerAffectsGains")
EndFunction

Function SaveWidget(FISSInterface fiss, DM_SandowPP_Config config)
    fiss.saveFloat("rwUpdateTime", config.rwUpdateTime)
    fiss.saveFloat("rwOpacity", config.rwOpacity)
    fiss.saveFloat("rwScale", config.rwScale)
    fiss.saveString("rwHAlign", config.rwHAlign)
    fiss.saveString("rwVAlign", config.rwVAlign)
    fiss.saveFloat("rwX", config.rwX)
    fiss.saveFloat("rwY", config.rwY)
EndFunction

Function LoadWidget(FISSInterface fiss)
    ConfigResults.rwUpdateTime = fiss.loadFloat("rwUpdateTime")
    ConfigResults.rwOpacity = fiss.loadFloat("rwOpacity")
    ConfigResults.rwScale = fiss.loadFloat("rwScale")
    ConfigResults.rwHAlign = fiss.loadString("rwHAlign")
    ConfigResults.rwVAlign = fiss.loadString("rwVAlign")
    ConfigResults.rwX = fiss.loadFloat("rwX")
    ConfigResults.rwY = fiss.loadFloat("rwY")
EndFunction