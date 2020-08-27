Scriptname DM_SandowPP_Globals Hidden

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
    Return 3
EndFunction

int Function ModMinorVersion() Global
    Return 2
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
