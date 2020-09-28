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

TextureSet Property HumFemHands Auto
TextureSet Property HumMalHands Auto
TextureSet Property KhaFemHands Auto
TextureSet Property KhaMalHands Auto
TextureSet Property SaxFemHands Auto
TextureSet Property SaxMalHands Auto
; TextureSet Property FemHands Auto
; TextureSet Property MalHands Auto


; TODO: Delete
bool _textureWasSet = false

;TODO: Delete
Function Debug(Actor akTarget)
    ApplyToNPCs()
EndFunction

;>========================================================
;>===                     PUBLIC                     ===<;
;>========================================================

;> Use these functions when you want to enable muscle definition.
Function InitData()
    int r = JValue.readFromFile("data/SKSE/Plugins/Sandow Plus Plus/config/ripped-races.json")
    JMap.setObj(SPP.GetDataTree(), "rippedRaces", r)
    ; SPP.TestSave(344545)
EndFunction

; `forceSet = false` is used to avoid flickering when a texture was already set.
Function MakePlayerRipped(bool forceSet = false)
    MakeRipped(Player, forceSet)
EndFunction

; Method is left somewhat generalized in the unlikely case NiOverride works for NPCs.
Function MakeRipped(Actor akTarget, bool forceSet = false)
    string m = _GetAlphaOptions(akTarget)
    If m == "$None"
        Clear(akTarget)
    Else
        If akTarget != Player
            NiOverride.AddOverlays(akTarget)
        EndIf
        _MakeRippedByMode(akTarget, m)
    EndIf
EndFunction

Function _MakeRippedByMode(Actor akTarget, string mode)
    ; Get race
    int r = JMap.getObj(SPP.GetDataTree(), "rippedRaces")
    string aRace = JMap.getStr(r, _GetRace(akTarget))
    Trace("====" +  akTarget.getLeveledActorBase().getName() + "====")
    ; Check if race is supported
    If aRace
        bool isFemale = _IsFemale(akTarget)
        _SetHandsOverride(akTarget, aRace, isFemale)
        _SetBodyOverride(akTarget, aRace, isFemale, mode)
        If akTarget != Player
            akTarget.QueueNiNodeUpdate()
        EndIf
    EndIf
EndFunction

Function _SetBodyOverride(Actor akTarget, string aRace, bool isFemale, string mode)
    string alpha = _GetAlpha(akTarget, mode)
    string sex
    If isFemale
        sex = "Fem"
    Else
        sex = "Mal"
    EndIf
    ; generate filename
    string raceTex = aRace + sex + "W" + alpha
    string tx = "data/textures/actors/character/SandowPP/" + raceTex + ".dds"
    NiOverride.AddSkinOverrideString(akTarget, isFemale, false, 0x04, 9, 1, tx, true)
EndFunction

Function _SetHandsOverride(Actor akTarget, string aRace, bool isFemale)
    TextureSet tx = _GetHandsTextures(aRace, isFemale)
    string node = "Hands [Ovl0]"
    int skinColor = NiOverride.GetSkinPropertyInt(akTarget, false, 0x04, 7, -1)
    NiOverride.AddNodeOverrideTextureSet(akTarget, isFemale, node, 6, -1, tx, true)
    NiOverride.AddNodeOverrideInt(akTarget, isFemale, node, 7, -1, skinColor, true)
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

Function T(Actor akTarget, string node)
    ;@Hint: THIS WORKS
    string raceTex = "HumFemW100"
    string tx = "data/textures/actors/character/SandowPP/" + raceTex + ".dds"
    NiOverride.AddSkinOverrideString(Player, true, false, 0x04, 9, 1, tx, true)

    int skinColor = NiOverride.GetSkinPropertyInt(akTarget, false, 4, 7, -1)
    NiOverride.AddNodeOverrideTextureSet(Player, true, "Hands [Ovl0]", 6, -1, HumFemHands, true)
    NiOverride.AddNodeOverrideInt(Player, true, "Hands [Ovl0]", 7, -1, skinColor, true)
EndFunction

; TODO : Fix
Function Clear(Actor akTarget)
    Trace("---------- Clearing textures")
    _textureWasSet = false
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
            MakeRipped(npcs[i])
    ; return  ; FIXME: Delete this
            ; TestOverride(npcs[i])
            ; If forceUpdate
            ;     InitializeActor(npcs[i])
            ; Else
            ;     ApplyToNPC(npcs[i])
            ; EndIf
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
string Function _GetAlphaOptions(Actor akTarget)
    If akTarget == Player
        return JValue.solveStr(SPP.GetMCMConfig(), _cfg + "mode", "$None")
    Else
        return "Coolio"
    EndIf
    return "$None"
EndFunction

; Returns the number of the texture set corresponding to an alpha.
; `[000, 010, 020, ..., 090, 100]`
string function _GetAlpha(Actor akTarget, string mode)
    float a = 99           ; Return an unexistent texture set to make to failure obvious
    If akTarget == Player
        a = _GetPlayerAlpha(mode)
    Else
        a = 1
    EndIf
    return JValue.evalLuaStr(0, "return string.format('%.3d', math.floor(" + a + " * 10) * 10)")
EndFunction

float Function _GetPlayerAlpha(string m)
    float min = JValue.solveFlt(SPP.GetMCMConfig(), _cfg + "minAlpha")
    float max = JValue.solveFlt(SPP.GetMCMConfig(), _cfg + "maxAlpha", 1)

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
; bool Function _SetTexAlpha(Actor akTarget, float alpha, string node = "Body [Ovl1]")
;     ; trace("SetAlpha " + akTarget.getLeveledActorBase().getName() + " " + alpha)
;     If !NiOverrideExists()
;         return false
;     EndIf
;     alpha = ConstrainF(alpha, 0.0, 1.0)
;     bool isFemale = _IsFemale(akTarget)

;     ; This call needs some explanation.
;     ; ref, isFemale, value and persist are self-explanatory.

;     ; Node is which "layer?" we want to change. The only way to
;     ; change normal maps is using whole texture sets, and the only
;     ; node in which texture sets are shown is "Body [Ovl5]" if using
;     ; NiOverride.AddNodeOverrideTextureSet.
;     ; Using NetImmerse.SetNodeTextureSet seems to work for all layers.
;     ; This limitation makes this mod incompatible with mods that use body
;     ; overlay layers 0 and 1 (body tatoos and such).

;     ; Key = 8 is used to tell NiOverride to change the alpha channel value.
;     ; Index is irrelevant to this operation, so -1 it is.
;     NiOverride.AddNodeOverrideFloat(akTarget, isFemale,  node, 8, -1, alpha, true)
;     return true
; EndFunction

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
    int skinColor = NiOverride.GetSkinPropertyInt(akTarget, false, 0x04, 7, -1)
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
