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
Spell Property RippedSpell Auto

int property IsInvalid = -2 AutoReadOnly
int property NeedsRecalc = -1 AutoReadOnly

TextureSet Property HumFemHands Auto
TextureSet Property HumMalHands Auto
TextureSet Property KhaFemHands Auto
TextureSet Property KhaMalHands Auto
TextureSet Property SaxFemHands Auto
TextureSet Property SaxMalHands Auto
; TextureSet Property FemHands Auto
; TextureSet Property MalHands Auto
TextureSet Property HumFemBod Auto
TextureSet Property HumMalBod Auto
TextureSet Property KhaFemBod Auto
TextureSet Property KhaMalBod Auto
TextureSet Property SaxFemBod Auto
TextureSet Property SaxMalBod Auto
; TextureSet Property FemBod Auto
; TextureSet Property MalBod Auto
Armor Property HackRing Auto
Armor Property HackNecklace Auto
Armor Property HackRobe Auto
Armor Property HackBoots Auto

string _handsN = "Hands [Ovl0]"
string _bodN = "Body [Ovl0]"
int _bodM = 0x04

int _KeyTexSet = 6
int _KeyTexture = 9
; int _SlotBody = 0x04
int _IdxNormal = 1
; https://www.creationkit.com/index.php?title=Slot_Masks_-_Armor

;TODO: Delete
Function Debug(Actor akTarget)
    Trace("Test")
        ApplyToNPCs()

    ; Trace(GetNodeOverrideString(player, _isFemale(player), "Body [Ovl0]", 9, 1))
    ; bool isFem = _isFemale(player)

    ; _TransferOverrides(player, isFem, true)
    ; AddNodeOverrideString(player, isFem, _bodN, 9, 1, "data/textures/actors/character/SandowPP/HumFemW100.dds", true)
    ; AddNodeOverrideFloat(player, isFem, _bodN, 8, -1, 0.5, true)
EndFunction

Function _TransferPlayerOverrides(Actor akTarget, bool isFem, bool persist)
    ; _TransferOvIdx(akTarget, isFem, 0, persist)       ; Diffuse map
    ; Index 1 is normal map. We don't want to transfer that, because that's the on this mod sets.
    ; _TransferOvIdx(akTarget, isFem, 2, persist)       ; Environment mask / subsurface tint map
    ; _TransferOvIdx(akTarget, isFem, 3, persist)       ; Glow / detail map
    ; _TransferOvIdx(akTarget, isFem, 4, persist)       ; Height map
    ; _TransferOvIdx(akTarget, isFem, 5, persist)       ; Environment map
    ; _TransferOvIdx(akTarget, isFem, 6, persist)       ; Multilayer map
    _TransferOvIdx(akTarget, isFem, 7, persist)       ; Backlight mask / specular map
    ; _TransferOvIdx(akTarget, isFem, 8, persist)       ; ???
    ; _TransferOvFloat(akTarget, isFem, 1, persist)     ; Emissive power
    _TransferOvFloat(akTarget, isFem, 2, persist)     ; Glossiness power
    _TransferOvFloat(akTarget, isFem, 3, persist)     ; Specular power
    ; _TransferOvFloat(akTarget, isFem, 4, persist)     ; Light fx 1
    ; _TransferOvFloat(akTarget, isFem, 5, persist)     ; Light fx 2
    ; _TransferOvInt(akTarget, isFem, 0, persist)       ; Emissive color
    _TransferOvInt(akTarget, isFem, 7, persist)       ; Skin color
EndFunction

Function _TransferNPCOverrides(Actor akTarget, bool isFem, bool persist)
    _TransferOvIdx(akTarget, isFem, 0, persist)       ; Diffuse map
    ; Index 1 is normal map. We don't want to transfer that, because that's the on this mod sets.
    _TransferOvIdx(akTarget, isFem, 2, persist)       ; Environment mask / subsurface tint map
    ; _TransferOvIdx(akTarget, isFem, 3, persist)       ; Glow / detail map
    ; _TransferOvIdx(akTarget, isFem, 4, persist)       ; Height map
    ; _TransferOvIdx(akTarget, isFem, 5, persist)       ; Environment map
    ; _TransferOvIdx(akTarget, isFem, 6, persist)       ; Multilayer map
    _TransferOvIdx(akTarget, isFem, 7, persist)       ; Backlight mask / specular map
    ; _TransferOvIdx(akTarget, isFem, 8, persist)       ; ???
    _TransferOvFloat(akTarget, isFem, 1, persist)     ; Emissive power
    _TransferOvFloat(akTarget, isFem, 2, persist)     ; Glossiness power
    _TransferOvFloat(akTarget, isFem, 3, persist)     ; Specular power
    ; _TransferOvFloat(akTarget, isFem, 4, persist)     ; Light fx 1
    ; _TransferOvFloat(akTarget, isFem, 5, persist)     ; Light fx 2
    ; _TransferOvInt(akTarget, isFem, 0, persist)       ; Emissive color
    _TransferOvInt(akTarget, isFem, 7, persist)       ; Skin color
EndFunction

; Transfers to [Body Ovl0] overrides applied to skin
Function _TransferOverrides(Actor akTarget, bool isFem, bool persist)
    _TransferPlayerOverrides(akTarget, isFem, persist)
    ; If akTarget == Player
    ; Else
    ;     ; _TransferNPCOverrides(akTarget, isFem, persist)
    ; EndIf
EndFunction

; Transfers one int property from the body to [Body Ovl0]
Function _TransferOvInt(Actor akTarget, bool isFem, int k, bool persist)
    int v = GetSkinPropertyInt(akTarget, false, _bodM, k, -1)
    AddNodeOverrideInt(akTarget, isFem, _bodN, k, -1, v, persist)
EndFunction

; Transfers one float property from the body to [Body Ovl0]
Function _TransferOvFloat(Actor akTarget, bool isFem, int k, bool persist)
    float v = GetSkinPropertyFloat(akTarget, false, _bodM, k, -1)
    AddNodeOverrideFloat(akTarget, isFem, _bodN, k, -1, v, persist)
EndFunction

; Transfers one indexed property from the body to [Body Ovl0]
Function _TransferOvIdx(Actor akTarget, bool isFemale, int idx, bool persist)
    string tx = GetSkinPropertyString(akTarget, false, _bodM, 9, idx)
    float v = GetSkinPropertyFloat(akTarget, false, _bodM, 9, idx)
    TraceA(akTarget, "Transfer " + idx + " tx = " + tx)
    If tx
        string arg = "[[" + tx + "]]"
        If evalLuaInt(0, "return string.find(dmlib.getFileName(" + arg + "), 'hands')")
            TraceA(akTarget, "Found hands. Skipping")
            return
        EndIf
    EndIf
    AddNodeOverrideString(akTarget, isFemale, _bodN, 9, idx, tx, persist)
    AddNodeOverrideFloat(akTarget, isFemale, _bodN, 9, idx, v, persist)
EndFunction


;>========================================================
;>===                     PUBLIC                     ===<;
;>========================================================

;> Use these functions when you want to enable muscle definition.


Function InitData()
    int r = readFromFile("data/SKSE/Plugins/Sandow Plus Plus/config/ripped-races.json")
    JMap.setObj(SPP.GetDataTree(), "rippedRaces", r)
EndFunction

Function MakePlayerRipped(bool forceSet = false)
    MakeRipped(Player, -1)
EndFunction

; Sets ripped level for an actor
float Function MakeRipped(Actor akTarget, float knownAlpha)
    ; If !SPP.Initialized
    ;     return -1
    ; EndIf

    string r = _GetRacePrefix(akTarget)
    If r
        return _ProcessActor(akTarget, knownAlpha, r)
    Else
        return IsInvalid
    EndIf
EndFunction

float Function _ProcessActor(Actor akTarget, float knownAlpha, string aRace)
    string mode = _GetRippedMode(akTarget)
    If mode == "$None"
        Clear(akTarget)
        return 0    ; Tell the mode is constant to avoid spamming polls
    EndIf
    return _CalcAndSetTextures(akTarget, knownAlpha, mode, aRace)
EndFunction

float Function _CalcAndSetTextures(Actor akTarget, float knownAlpha, string mode, string aRace)
    bool isFemale = _IsFemale(akTarget)
    float alpha = 0.0
    alpha = _CalcAlpha(akTarget, mode, aRace, isFemale)
    _SetTextures(akTarget, alpha, aRace, isFemale)
    If _NeedsRecalc(akTarget, mode)
        return NeedsRecalc
    Else
    ;     If knownAlpha >= 0
    ;         alpha = knownAlpha
    ;     Else
    ;         alpha = _CalcAlpha(akTarget, mode, aRace, isFemale)
    ;     EndIf
    ;     _SetTextures(akTarget, alpha, aRace, isFemale)
        return alpha
    EndIf
EndFunction

Function _SetTextures(Actor akTarget, float alpha, string aRace, bool isFemale)
    bool persist = true
    If akTarget == Player
        _TransferOverrides(akTarget, isFemale, persist)
        ; Sets alpha
        AddNodeOverrideFloat(akTarget, isFemale, _bodN, 8, -1, alpha, persist)
        ; Sets body normal
        _SetBodyOverride(akTarget, aRace, isFemale, persist)
        return
    EndIf

    TraceA(akTarget, "Alpha to set: " + alpha)
    TraceA(akTarget, "Has overlays: " + HasOverlays(akTarget))
    TraceA(akTarget, "Has node: " + NetImmerse.HasNode(akTarget, _bodN, false))

    _AddOverlays(akTarget, isFemale)
    _TransferOverrides(akTarget, isFemale, true)
    AddNodeOverrideFloat(akTarget, isFemale, _bodN, 8, -1, 0.9, true)
    _ForceRefresh(akTarget)
    ; TraceA(akTarget, GetNodeOverrideString(akTarget, isFemale, _bodN, 9, 1))
    ; ApplyNodeOverrides(akTarget)
EndFunction

Function _AddOverlays(Actor akTarget, bool isFemale)
    If akTarget != Player
        TraceA(akTarget, "Adding overlays")
        AddOverlays(akTarget)
    EndIf
    AddNodeOverrideTextureSet(akTarget, isFemale, _bodN, 6, -1, HumFemBod, true)
EndFunction

string Function _GetRacePrefix(Actor akTarget)
    int r = JMap.getObj(SPP.GetDataTree(), "rippedRaces")
    return  JMap.getStr(r, _GetRace(akTarget))
EndFunction

bool Function _NeedsRecalc(Actor akTarget, string mode)
    If akTarget == Player
        return mode != "$Constant"
    Else
        return mode == "$By skills"
    EndIf
EndFunction

Function _SetBodyOverride(Actor akTarget, string aRace, bool isFemale, bool persist)
    ; generate filename
    string raceTex = aRace + _SexToTexName(isFemale) + "W100"
    string tx = "data/textures/actors/character/SandowPP/" + raceTex + ".dds"
    ; AddSkinOverrideString(akTarget, isFemale, false, _bodM, _KeyTexture, _IdxNormal, tx, persist)
    AddNodeOverrideString(akTarget, isFemale, _bodN, 9, 1, tx, persist)
EndFunction

string Function _SexToTexName(bool isFemale)
    If isFemale
        return "Fem"
    Else
        return "Mal"
    EndIf
EndFunction

string Function _AlphaToTexName(float alpha)
    return JValue.evalLuaStr(0, "return string.format('%.3d', math.floor(" + alpha + " * 10) * 10)")
EndFunction

Function _SetHandsOverride(Actor akTarget, string aRace, bool isFemale)
    TextureSet tx = _GetHandsTextures(aRace, isFemale)
    int skinColor = GetSkinPropertyInt(akTarget, false, 0x04, 7, -1)
    AddNodeOverrideTextureSet(akTarget, isFemale, _handsN, _KeyTexSet, -1, tx, true)
    AddNodeOverrideInt(akTarget, isFemale, _handsN, 7, -1, skinColor, true)
EndFunction

TextureSet Function _GetHandsTextures(string aRace, bool isFemale)
    If isFemale
        If aRace == "Hum"
            return HumFemHands
        ElseIf aRace == "Kha"
            return KhaFemHands
        ElseIf aRace == "Sax"
            return SaxFemHands
        EndIf
    Else
        If aRace == "Hum"
            return HumMalHands
        ElseIf aRace == "Kha"
            return KhaMalHands
        ElseIf aRace == "Sax"
            return SaxMalHands
        EndIf
    EndIf
    return None
EndFunction

; FIXME: Change
Function Clear(Actor akTarget)
    Trace("---------- Clearing textures")
    If HasOverlays(akTarget)
        bool isFem = _IsFemale(akTarget)
        RemoveNodeOverride(akTarget, isFem, _handsN, _KeyTexSet, -1)
        _ForceRefresh(akTarget)
        RemoveOverlays(akTarget)
    EndIf
EndFunction

; This a hack that refreshes an NPC to avoid mismatched hand colors.
; It equips and promptly deletes a ring.
Function _ForceRefresh(Actor akTarget)
    If akTarget != Player
        ; https://www.creationkit.com/index.php?title=Slot_Masks_-_Armor
        Armor wornArmor = akTarget.GetWornForm(0x00000040) as Armor
        akTarget.EquipItem(HackRing, false, true)
        akTarget.EquipItem(wornArmor, false, true)
        akTarget.RemoveItem(HackRing, 1, true)
    EndIf
EndFunction

Function T(Actor akTarget, string node)
    ;@Hint: THIS WORKS
    string raceTex = "HumFemW100"
    string tx = "data/textures/actors/character/SandowPP/" + raceTex + ".dds"
    NiOverride.AddSkinOverrideString(Player, true, false, 0x04, 9, 1, tx, true)

    int skinColor = NiOverride.GetSkinPropertyInt(akTarget, false, 4, 7, -1)
    NiOverride.AddNodeOverrideTextureSet(Player, true, "Hands [Ovl0]", 6, -1, HumFemHands, true)
    NiOverride.AddNodeOverrideInt(Player, true, "Hands [Ovl0]", 7, -1, skinColor, true)
EndFunction


Function ApplyToNPCs(bool forceUpdate = false)
    Trace("ApplyToNPCs()")
    Actor[] npcs = MiscUtil.ScanCellNPCs(Player, 2048.0, None, false)
    int i = npcs.length
    Trace("NPCs found: " + i)
    While i > 0
        i -= 1
        If npcs[i] != Player
            Trace("Applying to: " + npcs[i] + npcs[i].getLeveledActorBase().getName())
            RemoveOverlays(npcs[i])
            MakeRipped(npcs[i], -1)
        EndIf
     EndWhile
EndFunction

; Function ApplyToNPC(Actor akTarget)
;     {Applies ripped settings to one NPC only if its lacks a mark or it has expired.}
;     Trace("ApplyToNPC() " + akTarget)
;     If !akTarget.HasMagicEffect(NPCRippedFx)
;         InitializeActor(akTarget)
;         ResetNPCSpell(akTarget)
;     EndIf
; EndFunction


; Function ResetNPCSpell(Actor akTarget)
;     {Blindly sets a texture set to a target.}
;     {Resets the spell telling the NPC has already been processed.}
;     If akTarget.HasSpell(NPCRippedSpell)
;         akTarget.RemoveSpell(NPCRippedSpell)
;     EndIf
;     akTarget.AddSpell(NPCRippedSpell)
; EndFunction

;>========================================================
;>===                      CORE                      ===<;
;>========================================================


;>========================================================
;>===                  CORE - ALPHA                  ===<;
;>========================================================
string _cfg = ".addons.ripped."
string Function _GetRippedMode(Actor akTarget)
    If akTarget == Player
        return JValue.solveStr(SPP.GetMCMConfig(), _cfg + "mode", "$None")
    Else
        return "Coolio"
    EndIf
    return "$None"
EndFunction

Float Function _CalcAlpha(Actor akTarget, string mode, string aRace, bool isFemale)
    If akTarget == Player
        return _GetPlayerAlpha(mode)
    Else
        ; TODO: DO
        return 1
    EndIf
EndFunction

; Returns the number of the texture set corresponding to an alpha.
; `[000, 010, 020, ..., 090, 100]`
string function _GetAlpha(Actor akTarget, string mode)
    ; float a = 99           ; Return an unexistent texture set to make to failure obvious
    ; If akTarget == Player
    ;     a = _GetPlayerAlpha(mode)
    ; Else
    ;     a = 1
    ; EndIf
    ; return JValue.evalLuaStr(0, "return string.format('%.3d', math.floor(" + a + " * 10) * 10)")
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
