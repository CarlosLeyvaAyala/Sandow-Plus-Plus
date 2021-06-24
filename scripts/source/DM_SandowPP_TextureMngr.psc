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
Spell Property rippedSpell Auto
{Spell to make the player ripped}

int property IsInvalid = -1 AutoReadOnly
; int property NeedsRecalc = -1 AutoReadOnly
Armor Property Weight000 Auto
Armor Property Weight100 Auto
TextureSet Property HumFemBod0 Auto
TextureSet Property HumMalBod0 Auto
TextureSet Property KhaFemBod0 Auto
TextureSet Property KhaMalBod0 Auto
TextureSet Property SaxFemBod0 Auto
TextureSet Property SaxMalBod0 Auto
TextureSet Property HumFemBod1 Auto
TextureSet Property HumMalBod1 Auto
TextureSet Property KhaFemBod1 Auto
TextureSet Property KhaMalBod1 Auto
TextureSet Property SaxFemBod1 Auto
TextureSet Property SaxMalBod1 Auto

TextureSet Property HumFemHands Auto
TextureSet Property HumMalHands Auto
TextureSet Property KhaFemHands Auto
TextureSet Property KhaMalHands Auto
TextureSet Property SaxFemHands Auto
TextureSet Property SaxMalHands Auto
; TextureSet Property FemHands Auto
; TextureSet Property MalHands Auto

string _bodN0 = "Body [Ovl0]"
string _bodN1 = "Body [Ovl1]"
string _handN0 = "Hands [Ovl0]"
; int _bodM = 0x04
int _handM = 0x08
; int _skinCol = 0xffffff

; https://www.creationkit.com/index.php?title=Slot_Masks_-_Armor

;TODO: Delete
Function Debug(Actor aAct)
    ; ApplyToNPCs()
    ; return
    float a = Utility.RandomFloat()
    TraceV("Alpha", a)
    _SetBodyOverride(aAct, "Hum", true, a)
    _SetHandsOverride(aAct, "Hum", true)
EndFunction

Function ApplyToNPCs()
    Trace("ApplyToNPCs()")
    Actor[] npcs = MiscUtil.ScanCellNPCs(Player, 4096.0, None, false)
    int i = npcs.length
    Trace("NPCs found: " + i)
    While i > 0
        i -= 1
        Actor npc = npcs[i]
        If npc != Player
            TraceA(npc, "Applying texture set")
            float a = Utility.RandomFloat()
            TraceV("Alpha", a)
            if !HasOverlays(npc)
                AddOverlays(npc)
            endif
            _SetBodyOverride(npc, "Hum", true, a)
            _SetHandsOverride(npc, "Hum", true)
                    ; If forceUpdate
            ;     InitializeActor(npcs[i])
            ; Else
            ;     ApplyToNPC(npcs[i])
            ; EndIf
        EndIf
     EndWhile
EndFunction

;>========================================================
;>===                     PUBLIC                     ===<;
;>========================================================

;> Use these functions to enable muscle definition.

; Initialize data needed for this system to work.
Function InitData()
    int r = readFromFile("data/SKSE/Plugins/Sandow Plus Plus/config/ripped-races.json")
    JMap.setObj(SPP.GetDataTree(), "rippedRaces", r)
    _InitTexSets()
EndFunction

; Enable muscle definition for the player.
Function MakePlayerRipped()
    MakeRipped(Player)
EndFunction

; Clear muscle definition for an actor.
Function Clear(Actor aAct)
    TraceA(aAct, "Clear muscle definition")
    aAct.RemoveSpell(rippedSpell)
    bool isFem = _IsFemale(aAct)
    RemoveNodeOverride(aAct, isFem, _handN0, 6, -1)
    ; RemoveNodeOverride(aAct, isFem, _bodN1, 6, -1)
    ApplyNodeOverrides(aAct)
EndFunction

; Enable muscle definition for an actor.
float Function MakeRipped(Actor aAct)
    aAct.AddSpell(rippedSpell, false)
EndFunction

; Set muscle definition for an actor.
bool Function CalcMuscleDefinition(Actor aAct)
    TraceA(aAct, "Calculate muscle definition")
    string r = _GetRacePrefix(aAct)
    If r
        _ProcessActor(aAct, r)
        return true
    Else
        TraceA(aAct, "Is not from a race that can get ripped. " + _GetRace(aAct))
        return false
    EndIf
EndFunction

;>========================================================
;>===                CORE - TEXTURES                 ===<;
;>========================================================

; Returns the number of the texture set corresponding to an alpha.
; `[000, 010, 020, ..., 090, 100]`
string function _AlphaToBin(float a)
    return JValue.evalLuaStr(0, "return string.format('%.3d', math.floor(" + a + " * 10) * 10)")
EndFunction

; Set the ripped body normal.
Function _SetBodyOverride(Actor akTarget, string aRace, bool isFemale, float alpha)
    ; generate filename
    string raceTex = _GetTextureName(aRace, isFemale, "W" + _AlphaToBin(alpha))
    string tx = "data/textures/actors/character/SandowPP/" + raceTex + ".dds"
    AddSkinOverrideString(akTarget, isFemale, false, 0x04, 9, 1, tx, true)
    TraceA(akTarget, tx)
EndFunction

; Set the hands override to hide the bug that applies body normal maps to hands.
Function _SetHandsOverride(Actor akTarget, string aRace, bool isFemale)
    TextureSet tx = _GetHandsTextures(aRace, isFemale)
    AddNodeOverrideTextureSet(akTarget, isFemale, _handN0, 6, -1, tx, true)
    _TransferOverrides(akTarget, _handN0, isFemale, true)
EndFunction

; Get the hand texture set that will be used to hide an SKSE/NiOverride? bug.
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
    Debug.Notification("Sandow++: I forgot to add hands for " + aRace)
EndFunction

; TODO: Delete
; Initializes textures used to create override layers.
; Keys must use the normal map file name convention used by this mod.
Function _InitTexSets()
    int t = JMap.object()
    JMap.setForm(t, "HumFemW000", HumFemBod0)
    JMap.setForm(t, "HumFemW100", HumFemBod1)
    JMap.setForm(t, "HumMalW000", HumMalBod0)
    JMap.setForm(t, "HumMalW100", HumMalBod1)
    JMap.setForm(t, "KhaFemW000", KhaFemBod0)
    JMap.setForm(t, "KhaFemW100", KhaFemBod1)
    JMap.setForm(t, "KhaMalW000", KhaMalBod0)
    JMap.setForm(t, "KhaMalW100", KhaMalBod1)
    JMap.setForm(t, "SaxFemW000", SaxFemBod0)
    JMap.setForm(t, "SaxFemW100", SaxFemBod1)
    JMap.setForm(t, "SaxMalW000", SaxMalBod0)
    JMap.setForm(t, "SaxMalW100", SaxMalBod1)
    JMap.setObj(SPP.GetDataTree(), "rippedTexSets", t)
EndFunction

; Generates the filename of the normal texture that will be used.
string Function _GetTextureName(string aRace, bool isFemale, string txSuffix)
    return aRace + _SexToTexName(isFemale) + txSuffix
EndFunction

; Set ripped textures to valid actor.
float Function _ProcessActor(Actor aAct, string aRace)
    string mode = _GetRippedMode(aAct)
    If mode == "$None"
        TraceA(aAct, "Ripped mode = None")
        Clear(aAct)
        return IsInvalid
    Else
        return _ApplyTextures(aAct, aRace, mode)
    EndIf
EndFunction

; Make ripped a valid actor that the player wants to be ripped.
float Function _ApplyTextures(Actor aAct, string aRace, string mode)
    bool isFemale = _IsFemale(aAct)
    float alpha = _CalcAlpha(aAct, mode, aRace, isFemale)
    ; _SetTextures(aAct, _bodN0, 1.0, aRace, isFemale, "W000")
    ; _SetTextures(aAct, _bodN1, alpha, aRace, isFemale, "W100")
    if !HasOverlays(aAct)
        AddOverlays(aAct)
    endif
    _SetBodyOverride(aAct, aRace, isFemale, alpha)
    _SetHandsOverride(aAct, aRace, isFemale)

    return alpha
EndFunction

TextureSet Function _TxRaces(string aRace, bool isFemale, string txSuffix)
    string tx = _GetTextureName(aRace, isFemale, txSuffix)
    int t = JMap.getObj(SPP.GetDataTree(), "rippedTexSets")
    return  JMap.getForm(t, tx) as TextureSet
EndFunction

Function _SetTextures(Actor aAct, string node, float alpha, string aRace, bool isFemale, string txSuffix)
    _SetTextureSet(aAct, node, aRace, isFemale, txSuffix)
    _TransferOverrides(aAct, node, isFemale, true)
    ; Sets alpha
    AddNodeOverrideFloat(aAct, isFemale, node, 8, -1, alpha, true)
    ; Sets body normal
    _SetNormalOverride(aAct, node, aRace, isFemale, txSuffix)
EndFunction

string Function _GetRacePrefix(Actor aAct)
    int r = JMap.getObj(SPP.GetDataTree(), "rippedRaces")
    return  JMap.getStr(r, _GetRace(aAct))
EndFunction

; Sets a texture set on some override layer. This is used to ensure maximum compatibility
; with some armor mods and the 3BBB body.
Function _SetTextureSet(Actor aAct, string node, string aRace, bool isFemale, string txSuffix)
    TextureSet base = _TxRaces(aRace, isFemale, txSuffix)
    AddNodeOverrideTextureSet(aAct, isFemale, node, 6, -1, base, true)
EndFunction

Function _SetNormalOverride(Actor aAct, string node, string aRace, bool isFemale, string txSuffix)
    ; generate filename
    string raceTex = _GetTextureName(aRace, isFemale, txSuffix)
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

; Get player alpha from current options.
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

; Check if there's something to override.
; Some armors may completely delete skin geometry. In that case there's nothing to override.
; We check this by getting a skin color. If it's invalid, we don't proceed any further.
bool Function _OverrideExists(Actor aAct, bool isFem)
    int v = GetSkinPropertyInt(aAct, false, _handM, 7, -1)
    return  v != 0
EndFunction

; Transfers to [Body Ovl0] overrides applied to skin
Function _TransferOverrides(Actor aAct, string node, bool isFem, bool persist)
    If !_OverrideExists(aAct, isFem)
        TraceA(aAct, "Has no skin. Stopping override data transfering.")
        return
    EndIf
    ; _TransferOvIdx(aAct, node, isFem, 0, persist)       ; Diffuse map
    ; Index 1 is normal map. We don't want to transfer that, because that's the on this mod sets.
    ; _TransferOvIdx(aAct, node, isFem, 2, persist)       ; Environment mask / subsurface tint map
    ; _TransferOvIdx(aAct, node, isFem, 3, persist)       ; Glow / detail map
    ; _TransferOvIdx(aAct, node, isFem, 4, persist)       ; Height map
    ; _TransferOvIdx(aAct, node, isFem, 5, persist)       ; Environment map
    ; _TransferOvIdx(aAct, node, isFem, 6, persist)       ; Multilayer map
    _TransferOvIdx(aAct, node, isFem, 7, persist)       ; Backlight mask / specular map
    ; _TransferOvIdx(aAct, node, isFem, 8, persist)       ; ???
    ; _TransferOvFloat(aAct, node, isFem, 1, persist)     ; Emissive power
    _TransferOvFloat(aAct, node, isFem, 2, persist)     ; Glossiness power
    _TransferOvFloat(aAct, node, isFem, 3, persist)     ; Specular power
    ; _TransferOvFloat(aAct, node, isFem, 4, persist)     ; Light fx 1
    ; _TransferOvFloat(aAct, node, isFem, 5, persist)     ; Light fx 2
    ; _TransferOvInt(aAct, node, isFem, 0, persist)       ; Emissive color

    ; _TransferOvInt(aAct, node, isFem, 7, persist)       ; Skin color
    _TransferSkinColor(aAct, node, isFem, persist)       ; Skin color
EndFunction

; Transfers skin color from the body to some overlay layer.
; This function is mainly used to avoid the 3BBB bug that discolors NiOverride layers.
Function _TransferSkinColor(Actor aAct, string node, bool isFem, bool persist)
    int v = GetSkinPropertyInt(aAct, false, _handM, 7, -1)
    ; Avoid the skin color bug when using 3BBB
    If v != 0xFFFFFF
        ; TODO: Make this depend on a constant
        JFormDB.setInt(aAct, ".sandowppforms.skincolor", v)
        TraceA(aAct, "Set valid color: " + ColorToStr(v))
        ; _skinCol = v
    Else
        ; TODO: Make this depend on a constant
        TraceA(aAct, "Has invalid skin color: " + ColorToStr(v))
        v = JFormDB.getInt(aAct, ".sandowppforms.skincolor")
    EndIf
    TraceA(aAct, node + ". Last valid skin color: " + ColorToStr(v))
    AddNodeOverrideInt(aAct, isFem, node, 7, -1, v, persist)
EndFunction

; Transfers one int property from the body to some overlay layer.
Function _TransferOvInt(Actor aAct, string node, bool isFem, int k, bool persist)
    int v = GetSkinPropertyInt(aAct, false, _handM, k, -1)
    AddNodeOverrideInt(aAct, isFem, node, k, -1, v, persist)
EndFunction

; Transfers one float property from the body to some overlay layer.
Function _TransferOvFloat(Actor aAct, string node, bool isFem, int k, bool persist)
    float v = GetSkinPropertyFloat(aAct, false, _handM, k, -1)
    AddNodeOverrideFloat(aAct, isFem, node, k, -1, v, persist)
EndFunction

; Transfers one indexed property from the body to some overlay layer.
Function _TransferOvIdx(Actor aAct, string node, bool isFemale, int idx, bool persist)
    string tx = GetSkinPropertyString(aAct, false, _handM, 9, idx)
    float v = GetSkinPropertyFloat(aAct, false, _handM, 9, idx)
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
