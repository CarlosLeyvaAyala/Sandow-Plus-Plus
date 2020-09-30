;  ===========================================
;  Overview
;  ===========================================
; This is the main script that changes an Actor appeareance.
; It basically decides how and which texture to apply to the player.
; This script adds two layers:
;       * The least ripped the actor can be.
;       * The most ripped the actor can be.

; To simulate muscle definiton it alpha blends the most ripped layer.

;@Overview:
;       * Gets which textures match a given actor's race.
;       * Applies an alpha based on MCM options.

;@Info:
; To add a new race based on the ones that already exist:
;       * Add its name to the corresponding Race Support function.

; To add more races (like avian races and shit):
;       * Do the same steps as adding support for already existing races.
;       * Create two new texture sets in the CK, one pointing to the most ripped texture
;         and the other for the least one.
          ; WARNING:
;         As long as NiOverride fails to work for NPCs, a "least ripped" texture set is needed
;         for using it on the player, so this mod can be compatible with Ripped Bodies.
;         This mod changes the player while ripped bodies changes NPCs.
;       * Add new properties to this script, those properties will point at those new texture sets.


Scriptname DM_SandowPP_TextureMngr Extends Quest
{Decides which texture set an actor should use. Used to make them ripped.}

Import DM_SandowPP_Globals
Import DM_Utils
Import JValue
Import NiOverride

DM_SandowPPMain Property SPP Auto
Actor property Player auto

int property IsInvalid = -2 AutoReadOnly
; int property NeedsRecalc = -1 AutoReadOnly

string _bodN0 = "Body [Ovl0]"
string _bodN1 = "Body [Ovl1]"
int _bodM = 0x04

; https://www.creationkit.com/index.php?title=Slot_Masks_-_Armor

;TODO: Delete
Function Debug(Actor aAct)
    Trace("Test")
EndFunction

;>========================================================
;>===                     PUBLIC                     ===<;
;>========================================================

;> Use these functions when you want to enable muscle definition.

Function InitData()
    int r = readFromFile("data/SKSE/Plugins/Sandow Plus Plus/config/ripped-races.json")
    JMap.setObj(SPP.GetDataTree(), "rippedRaces", r)
EndFunction

Function MakePlayerRipped()
    MakeRipped(Player, -1)
EndFunction

Function Clear(Actor aAct)
    TraceA(aAct, "Clear textures")
    bool isFem = _IsFemale(aAct)
    RemoveNodeOverride(aAct, isFem, _bodN0, 6, -1)
    RemoveNodeOverride(aAct, isFem, _bodN1, 6, -1)
EndFunction

; Sets ripped level for an actor
float Function MakeRipped(Actor aAct, float knownAlpha = -1.0)
    string r = _GetRacePrefix(aAct)
    If r
        return _ProcessActor(aAct, knownAlpha, r)
    Else
        return IsInvalid
    EndIf
EndFunction

;>========================================================
;>===                CORE - TEXTURES                 ===<;
;>========================================================

; `knownAlpha`is left to easily plug in NPCs when the time comes.
float Function _ProcessActor(Actor aAct, float knownAlpha, string aRace)
    TraceA(aAct, "Set ripped textures to valid actor.")
    string mode = _GetRippedMode(aAct)
    If mode == "$None"
        Clear(aAct)
        return 0    ; Tell the mode is constant to avoid spamming polls. Apply when NPCs are supported.
    EndIf
    bool isFemale = _IsFemale(aAct)
    float alpha = _CalcAlpha(aAct, mode, aRace, isFemale)
    _SetTextures(aAct, _bodN0, 1.0, aRace, isFemale, "W000")
    _SetTextures(aAct, _bodN1, alpha, aRace, isFemale, "W100")
    return alpha
EndFunction

Function _SetTextures(Actor aAct, string node, float alpha, string aRace, bool isFemale, string txSuffix)
    _TransferOverrides(aAct, node, isFemale, true)
    ; Sets alpha
    AddNodeOverrideFloat(aAct, isFemale, node, 8, -1, alpha, true)
    ; Sets body normal
    _SetBodyOverride(aAct, node, aRace, isFemale, txSuffix)
EndFunction

string Function _GetRacePrefix(Actor aAct)
    int r = JMap.getObj(SPP.GetDataTree(), "rippedRaces")
    return  JMap.getStr(r, _GetRace(aAct))
EndFunction

Function _SetBodyOverride(Actor aAct, string node, string aRace, bool isFemale, string txSuffix)
    ; generate filename
    string raceTex = aRace + _SexToTexName(isFemale) + txSuffix
    string tx = "data/textures/actors/character/SandowPP/" + raceTex + ".dds"
    AddNodeOverrideString(aAct, isFemale, node, 9, 1, tx, true)
EndFunction

string Function _SexToTexName(bool isFemale)
    If isFemale
        return "Fem"
    Else
        return "Mal"
    EndIf
EndFunction

;>========================================================
;>===                  CORE - ALPHA                  ===<;
;>========================================================
string _cfg = ".addons.ripped."
string Function _GetRippedMode(Actor aAct)
    If aAct == Player
        return JValue.solveStr(SPP.GetMCMConfig(), _cfg + "mode", "$None")
    Else
        return "Coolio"
    EndIf
    return "$None"
EndFunction

; Leave somewhat open to deal with NPCs
Float Function _CalcAlpha(Actor aAct, string mode, string aRace, bool isFemale)
    return _GetPlayerAlpha(mode)
EndFunction

float Function _GetPlayerAlpha(string m)
    float min = solveFlt(SPP.GetMCMConfig(), _cfg + "minAlpha")
    float max = solveFlt(SPP.GetMCMConfig(), _cfg + "maxAlpha", 1)

    If m == "$Constant"
        return solveFlt(SPP.GetMCMConfig(), _cfg + "currDef")
    ElseIf m == "$By weight"
        return Lerp(min, max, _PlayerWeight())
    ElseIf m == "$By weight inv"
        return Lerp(min, max, 1.0 - _PlayerWeight())
    ElseIf m == "$By skills"
        return Lerp(min, max, _AlphaFromSkills(Player))
    Else
        ; When nothing else matches, let's assume we are using a behavior.
        ; So we'll take the value directly from the addon settings.
        float val = solveFlt(SPP.GetMCMConfig(), _cfg + "currDef")
        return Lerp(min, max, val)
    EndIf
EndFunction

float Function _AlphaFromSkills(Actor aAct)
    float hi = 1.25
    float md = 0.75
    float lo = 0.50
    float hv = aAct.GetBaseActorValue("HeavyArmor") * hi
    float sn = aAct.GetBaseActorValue("Sneak") * hi
    float th = aAct.GetBaseActorValue("TwoHanded") * hi
    float bl = aAct.GetBaseActorValue("Block") * hi
    float lt = aAct.GetBaseActorValue("LightArmor") * md
    float oh = aAct.GetBaseActorValue("OneHanded") * md
    float at = aAct.GetBaseActorValue("Alteration") * md
    float ar = aAct.GetBaseActorValue("Marksman") * lo
    float sm = aAct.GetBaseActorValue("Smithing") * 2.0
    float alpha = (hv + sn + th + bl + lt + oh + at + ar + sm) / 500.0
    return alpha
EndFunction

;>========================================================
;>===               TRANSFER OVERRIDES               ===<;
;>========================================================

; Transfers to [Body Ovl0] overrides applied to skin
Function _TransferOverrides(Actor aAct, string node, bool isFem, bool persist)
    _TransferOvIdx(aAct, node, isFem, 0, persist)       ; Diffuse map
    ; Index 1 is normal map. We don't want to transfer that, because that's the on this mod sets.
    _TransferOvIdx(aAct, node, isFem, 2, persist)       ; Environment mask / subsurface tint map
    _TransferOvIdx(aAct, node, isFem, 3, persist)       ; Glow / detail map
    _TransferOvIdx(aAct, node, isFem, 4, persist)       ; Height map
    _TransferOvIdx(aAct, node, isFem, 5, persist)       ; Environment map
    _TransferOvIdx(aAct, node, isFem, 6, persist)       ; Multilayer map
    _TransferOvIdx(aAct, node, isFem, 7, persist)       ; Backlight mask / specular map
    _TransferOvIdx(aAct, node, isFem, 8, persist)       ; ???
    _TransferOvFloat(aAct, node, isFem, 1, persist)     ; Emissive power
    _TransferOvFloat(aAct, node, isFem, 2, persist)     ; Glossiness power
    _TransferOvFloat(aAct, node, isFem, 3, persist)     ; Specular power
    _TransferOvFloat(aAct, node, isFem, 4, persist)     ; Light fx 1
    _TransferOvFloat(aAct, node, isFem, 5, persist)     ; Light fx 2
    _TransferOvInt(aAct, node, isFem, 0, persist)       ; Emissive color
    _TransferOvInt(aAct, node, isFem, 7, persist)       ; Skin color
EndFunction

; Transfers one int property from the body to [Body Ovl0]
Function _TransferOvInt(Actor aAct, string node, bool isFem, int k, bool persist)
    int v = GetSkinPropertyInt(aAct, false, _bodM, k, -1)
    AddNodeOverrideInt(aAct, isFem, node, k, -1, v, persist)
EndFunction

; Transfers one float property from the body to [Body Ovl0]
Function _TransferOvFloat(Actor aAct, string node, bool isFem, int k, bool persist)
    float v = GetSkinPropertyFloat(aAct, false, _bodM, k, -1)
    AddNodeOverrideFloat(aAct, isFem, node, k, -1, v, persist)
EndFunction

; Transfers one indexed property from the body to [Body Ovl0]
Function _TransferOvIdx(Actor aAct, string node, bool isFemale, int idx, bool persist)
    string tx = GetSkinPropertyString(aAct, false, _bodM, 9, idx)
    float v = GetSkinPropertyFloat(aAct, false, _bodM, 9, idx)
    AddNodeOverrideString(aAct, isFemale, node, 9, idx, tx, persist)
    AddNodeOverrideFloat(aAct, isFemale, node, 9, idx, v, persist)
    ; Used to prevent setting hands textures on NPCs, but seems it doesn't fail on PCs.
    ; TraceA(aAct, "Transfer " + idx + " tx = " + tx)
    ; If tx
    ;     string arg = "[[" + tx + "]]"
    ;     If evalLuaInt(0, "return string.find(dmlib.getFileName(" + arg + "), 'hands')")
    ;         TraceA(aAct, "Found hands. Skipping")
    ;         return
    ;     EndIf
    ; EndIf
EndFunction

;>========================================================
;>===                    HELPERS                     ===<;
;>========================================================

; It seems GetSex won't work if used inside a Global function; it can't be added to a library.
bool Function _IsFemale(Actor aAct)
    return aAct.GetLeveledActorBase().GetSex() == 1
EndFunction

; Gets the race for an actor as a string.
string Function _GetRace(Actor aAct)
    return MiscUtil.GetActorRaceEditorID(aAct)
EndFunction

float Function _PlayerWeight()
    return SPP.GetPlayerWeight() / 100
EndFunction
