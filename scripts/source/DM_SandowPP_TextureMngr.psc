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

DM_SandowPPMain Property SPP Auto
Actor property Player auto
; Racial textures
TextureSet Property HumFemW0 Auto
TextureSet Property HumFemW100 Auto
TextureSet Property HumMalW0 Auto
TextureSet Property HumMalW100 Auto
TextureSet Property CatFemW0 Auto
TextureSet Property CatFemW100 Auto
TextureSet Property CatMalW0 Auto
TextureSet Property CatMalW100 Auto
TextureSet Property LizFemW0 Auto
TextureSet Property LizFemW100 Auto
TextureSet Property LizMalW0 Auto
TextureSet Property LizMalW100 Auto

bool _textureWasSet = false

;TODO: Delete
Function Debug(Actor akTarget)
EndFunction

;>========================================================
;>===                     PUBLIC                     ===<;
;>========================================================

;> Use these functions when you want to enable muscle definition.

; `forceSet = false` is used to avoid flickering when a texture was already set.
Function MakePlayerRipped(bool forceSet = false)
    MakeRipped(Player, forceSet)
EndFunction

; Method is left somewhat generalized in the unlikely case NiOverride works for NPCs.
Function MakeRipped(Actor akTarget, bool forceSet = false)
    string m = _GetAlphaOptions(akTarget)
    If m == "$None"
        Clear(akTarget)
        return
    EndIf
    float alpha = _GetAlpha(akTarget, m)
    ; Avoid flickering  when a texture was already set.
    If forceSet || !_textureWasSet
        _textureWasSet = _ForceTextureSet(akTarget, alpha)
    Else
        _SetTexAlpha(akTarget, 1.0, "Body [Ovl0]")
        _SetTexAlpha(akTarget, alpha)
    EndIf
EndFunction

Function Clear(Actor akTarget)
    Trace("---------- Clearing textures")
    ; Ripped texture
    _SetTextureSetAndAlpha(akTarget, None, 0.0, "Body [Ovl0]")
    ; Most ripped texture
    _SetTextureSetAndAlpha(akTarget, None, 0.0)
    _textureWasSet = false
EndFunction

;>========================================================
;>===                      CORE                      ===<;
;>========================================================

; Tries to force a texture set on an actor. Returns wether it could do it.
bool Function _ForceTextureSet(Actor akTarget, float alpha)
    int tx = _GetTextures(akTarget)
    If tx == 0
        ; Race not supported
        return false
    EndIf
    ; Set least ripped texture to always visible
    _SetTextureSetAndAlpha(akTarget, JArray.getForm(tx, 0) as TextureSet, 1.0, "Body [Ovl0]")
    ; Sets most ripped texture as a blend.
    _SetTextureSetAndAlpha(akTarget, JArray.getForm(tx, 1) as TextureSet, alpha)
    return true
EndFunction

Function _SetTextureSetAndAlpha(Actor akTarget, TextureSet tx, float alpha, string node = "Body [Ovl1]")
    _SetTextureSet(akTarget, tx, node)
    _SetTexAlpha(akTarget, alpha, node)
EndFunction

;>========================================================
;>===                  CORE - ALPHA                  ===<;
;>========================================================
string _cfg = ".addons.ripped."
string Function _GetAlphaOptions(Actor akTarget)
    If akTarget == Player
        return JValue.solveStr(SPP.GetMCMConfig(), _cfg + "mode", "$None")
    EndIf
    return "$None"
EndFunction

float function _GetAlpha(Actor akTarget, string mode)
    If akTarget == Player
        return _GetPlayerAlpha(mode)
    EndIf
    return 0
EndFunction

float Function _GetPlayerAlpha(string m)
    float min = JValue.solveFlt(SPP.GetMCMConfig(), _cfg + "minAlpha")
    float max = JValue.solveFlt(SPP.GetMCMConfig(), _cfg + "maxAlpha", 1) / 100.0

    If m == "$Constant"
        return JValue.solveFlt(SPP.GetMCMConfig(), _cfg + "currDef")
    ElseIf m == "$By weight"
        return Lerp(min, max, _PlayerWeight())
    ElseIf m == "$By weight inv"
        return Lerp(min, max, 1.0 - _PlayerWeight())
    ElseIf m == "$By skills"
        return Lerp(min, max, _AlphaFromSkills(Player))
    Else
        ; When nothing else matches, let's assume we are using a behavior.
        ; So we'll take the value directly from the addon settings.
        float val = JValue.solveFlt(SPP.GetMCMConfig(), _cfg + "currDef")
        ; Trace("Training " + val)
        ; Trace("Lerp " + Lerp(min, max, val))
        ; Trace("Min, max " + min + ", " + max)
        return Lerp(min, max, val)
    EndIf
EndFunction

float Function _AlphaFromSkills(Actor akTarget)
    float hi = 1.25
    float md = 0.75
    float lo = 0.50
    float hv = aktarget.GetBaseActorValue("HeavyArmor") * hi
    float sn = aktarget.GetBaseActorValue("Sneak") * hi
    float th = aktarget.GetBaseActorValue("TwoHanded") * hi
    float bl = aktarget.GetBaseActorValue("Block") * hi
    float lt = aktarget.GetBaseActorValue("LightArmor") * md
    float oh = aktarget.GetBaseActorValue("OneHanded") * md
    float at = aktarget.GetBaseActorValue("Alteration") * md
    float ar = aktarget.GetBaseActorValue("Marksman") * lo
    float sm = aktarget.GetBaseActorValue("Smithing") * 2.0
    float alpha = (hv + sn + th + bl + lt + oh + at + ar + sm) / 500.0
    return alpha
EndFunction

; Sets how much ripped an actor will look.
;
; "Node" can go from "Body [Ovl0]" to "Body [Ovl5]. Higher layers get applied over lower ones."
bool Function _SetTexAlpha(Actor akTarget, float alpha, string node = "Body [Ovl1]")
    ; trace("SetAlpha " + akTarget.getLeveledActorBase().getName() + " " + alpha)
    If !NiOverrideExists()
        return false
    EndIf
    alpha = ConstrainF(alpha, 0.0, 1.0)
    bool isFemale = _IsFemale(akTarget)

    ; This call needs some explanation.
    ; ref, isFemale, value and persist are self-explanatory.

    ; Node is which "layer?" we want to change. The only way to
    ; change normal maps is using whole texture sets, and the only
    ; node in which texture sets are shown is "Body [Ovl5]" if using
    ; NiOverride.AddNodeOverrideTextureSet.
    ; Using NetImmerse.SetNodeTextureSet seems to work for all layers.
    ; This limitation makes this mod incompatible with mods that use body
    ; overlay layers 0 and 1 (body tatoos and such).

    ; Key = 8 is used to tell NiOverride to change the alpha channel value.
    ; Index is irrelevant to this operation, so -1 it is.
    NiOverride.AddNodeOverrideFloat(akTarget, isFemale,  node, 8, -1, alpha, true)
    return true
EndFunction

;>========================================================
;>===                CORE - TEXTURES                 ===<;
;>========================================================

; Blindly sets a texture set to a target.
;
; "Node" can go from "Body [Ovl0]" to "Body [Ovl5]. Higher layers get applied over lower ones."
bool Function _SetTextureSet(Actor akTarget, TextureSet tx, string node = "Body [Ovl1]")
    If !NiOverrideExists()
        return false
    EndIf
    ; This function is so heavily commented because there's no documentation on NiOverride
    bool isFemale = _IsFemale(akTarget)

    ; Index is irrelevant for all these specific operations. It's **somewhat** documented in the NiOverride source code.
    int irrelevant = -1
    ; Get the skin tint color of the Actor to reapply it soon
    int skinColor = NiOverride.GetSkinPropertyInt(akTarget, false, 4, 7, -1)
    ; Add the texture set we want to show and make it invisible
    ; WARNING: NiOverride.AddNodeOverrideTextureSet only works for [Body Ovl5].
    ; WARNING: NetImmerse.SetNodeTextureSet works for [Body Ovl0..5],
    ; WARNING: but it needs to be reapplied at game reload.
    ;~~NiOverride.AddNodeOverrideTextureSet(akTarget, isFemale, node, 6, irrelevant, tx, true)~~
    NetImmerse.SetNodeTextureSet(akTarget, node, tx, false)
    NiOverride.AddNodeOverrideFloat(akTarget, isFemale, node, 8, irrelevant, 0.0, true)
    ; Last operation resets the skin tint color to white, making the character's body pale. Restore the color we got earlier.
    NiOverride.AddNodeOverrideInt(akTarget, isFemale, node, 7, irrelevant, skinColor, true)
    ; Profit! Have a nice day.
    return true
EndFunction

; Gets textures associated to some race.
int Function _GetTextures(Actor akTarget)
    int map
    If _IsFemale(akTarget)
        map = _GenFemTex()
    Else
        map = _GenMalTex()
    EndIf
    return JMap.getInt(map, _GetRace(akTarget))
EndFunction


;>========================================================
;>===                    HELPERS                     ===<;
;>========================================================

; It seems GetSex won't work if used inside a Global function; it can't be added to a library.
bool Function _IsFemale(Actor akTarget)
    return akTarget.GetLeveledActorBase().GetSex() == 1
EndFunction

; Gets the race for an actor as a string.
string Function _GetRace(Actor akTarget)
    return MiscUtil.GetActorRaceEditorID(akTarget)
EndFunction

float Function _PlayerWeight()
    return SPP.GetPlayerWeight() / 100
EndFunction


;>========================================================
;>===                  RACE SUPPORT                  ===<;
;>========================================================

;> Add more races here if needed

int Function _GenMalTex()
    int m = JMap.object()
    _GenHumanoids(m, HumMalW0, HumMalW100)
    _GenKhajiit(m, CatMalW0, CatMalW100)
    _GenArgonian(m, LizMalW0, LizMalW100)
    return m
EndFunction

int Function _GenFemTex()
    int m = JMap.object()
    _GenHumanoids(m, HumFemW0, HumFemW100)
    _GenKhajiit(m, CatFemW0, CatFemW100)
    _GenArgonian(m, LizFemW0, LizFemW100)
    return m
EndFunction

Function _GenHumanoids(int m, TextureSet tex0, TextureSet tex100)
    int hum = JArray.object()
    JArray.addForm(hum, tex0)
    JArray.addForm(hum, tex100)
    JMap.setInt(m, "BretonRace", hum)
    JMap.setInt(m, "BretonRaceVampire", hum)
    JMap.setInt(m, "DarkElfRace", hum)
    JMap.setInt(m, "DarkElfRaceVampire", hum)
    JMap.setInt(m, "HighElfRace", hum)
    JMap.setInt(m, "HighElfRaceVampire", hum)
    JMap.setInt(m, "ImperialRace", hum)
    JMap.setInt(m, "ImperialRaceVampire", hum)
    JMap.setInt(m, "NordRace", hum)
    JMap.setInt(m, "NordRaceVampire", hum)
    JMap.setInt(m, "OrcRace", hum)
    JMap.setInt(m, "OrcRaceVampire", hum)
    JMap.setInt(m, "RedguardRace", hum)
    JMap.setInt(m, "RedguardRaceVampire", hum)
    JMap.setInt(m, "WoodElfRace", hum)
    JMap.setInt(m, "WoodElfRaceVampire", hum)
EndFunction

Function _GenKhajiit(int m, TextureSet tex0, TextureSet tex100)
    int cat = JArray.object()
    JArray.addForm(cat, tex0)
    JArray.addForm(cat, tex100)
    JMap.setInt(m, "KhajiitRace", cat)
    JMap.setInt(m, "KhajiitRaceVampire", cat)
EndFunction

Function _GenArgonian(int m, TextureSet tex0, TextureSet tex100)
    int liz = JArray.object()
    JArray.addForm(liz, tex0)
    JArray.addForm(liz, tex100)
    JMap.setInt(m, "ArgonianRace", liz)
    JMap.setInt(m, "ArgonianRaceVampire", liz)
EndFunction
