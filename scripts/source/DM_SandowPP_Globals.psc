Scriptname DM_SandowPP_Globals Hidden

string Function JsonFileName(string fname) Global
    {Gets a filename that points to this Mod's folder.}
    return "../Sandow Plus Plus/" + fname
EndFunction

string Function CfgConst() Global
    {Returns the filename of the constants file.}
    return JsonFileName("__const.json")
EndFunction

string[] Function ReadStrArray(string FileName, string KeyName) Global
    {Instantiates and creates an array. The array needs a varable telling its size provided by the same file; if that doesn't exist, it creates a default sized array of 255.}
    string[] result
    result = Utility.CreateStringArray(JsonUtil.GetIntValue(FileName, KeyName + "Size",255))
    result = JsonUtil.StringListToArray(FileName, KeyName)
    return result
EndFunction

; Message colors
int Function clDefault() Global
    Return 0xFFFFFF
EndFunction
int Function clDown() Global
    Return 0xcc0000
EndFunction
int Function clUp() Global
    Return 0x4f8a35
EndFunction
int Function clWarning() Global
    Return 0xffd966
EndFunction
int Function clDanger() Global
    Return 0xff6d01
EndFunction
int Function clCritical() Global
    Return 0xff0000
EndFunction

int Function ModMajorVersion() Global
    Return 4
EndFunction

int Function ModMinorVersion() Global
    Return 0
EndFunction

int Function ModPatchVersion() Global
    Return 0
EndFunction

string Function ModVersion() Global
    Return ModMajorVersion() + "." + ModMinorVersion() + "." + ModPatchVersion()
EndFunction

Function OpenLog() Global
    Debug.OpenUserLog("Sandow Plus Plus")
    Trace("Sandow++ v" + ModVersion())
    Trace("=====================")
    If Skse.GetVersionRelease() == 0
        Trace("$TraceNotFound{" + "SKSE64" + "}", 3)
    EndIf
    ; If game.GetModByName("SkyUI_SE.esp") == 255
    If !game.IsPluginInstalled("SkyUI_SE.esp")
        Trace("$TraceNotFound{" + "SkyUI" + "}", 3)
    EndIf
EndFunction

Function Trace(string aMsg, int aSeverity = 0) Global
    Debug.TraceUser("Sandow Plus Plus", aMsg, aSeverity)
EndFunction

bool Function PapyrusUtilExists() Global
    Return PapyrusUtil.GetVersion() > 1
EndFunction

bool Function SexLabExists() Global
    Return game.IsPluginInstalled("SexLab.esm")
EndFunction

bool Function NiOverrideExists() Global
    Return NiOverride.GetScriptVersion() > 0 && SKSE.GetPluginVersion("skee") >= 1
EndFunction

bool Function JContainersExists() Global
    Return JContainers.isInstalled()
EndFunction
