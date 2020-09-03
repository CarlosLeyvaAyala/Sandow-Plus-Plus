;  ===========================================
;  Overview
;  ===========================================
; This is the main script that changes an Actor appeareance.
; It basically decides how and which texture to apply to any given actor and automates the
; MCM options for NPCs.

;@Overview:
;       * Initializes everything needed to get actors ripped.
;       * Scans the environment every <x> seconds to apply the spell that keeps track of whom NPCs
;         have been set their muscle definition.
;         This spell expires after 30 min, so it can be reapplied to NPCs.

;@Info:
; To add a new race based on the ones that already exist:
;       * Add its name to  "__Ripped Races.json" under whichever texture is right.

; To add more races (like avian races and shit):
;       * Do the same steps as adding support for already existing races.
;       * Create a new texture set in the CK, pointing to the most ripped texture.
;       * Create new "DM_SandowPP_RippedActor" descendants and add them to new quests.
;         Don't forget to set all their needed properties.
;       * Add those new quests to the "DM_SPP_RippedRaces" formlist in the CK.

Scriptname DM_SandowPP_TextureMngr Extends Quest
{Decides which texture set an actor should use. Used to make them ripped}

Import DM_SandowPP_Globals
Import DM_Utils

Actor property Player auto
; DM_SandowPP_Config Property Cfg Auto
Formlist Property racesSettings Auto
{List of all quests that contain racial settings.}
DM_SandowPP_RippedPlayer Property PlayerSettings Auto
{Quest that contain settings for the player.}
Spell Property NPCRippedSpell Auto
{Add this to an NPC to mark it as ripped.}
MagicEffect Property NPCRippedFx Auto
{Add this to an NPC to mark it as ripped.}
Keyword Property ActorTypeNPC Auto
{Keyword to scan only for NPCs.}
DM_SandowPP_RippedActor Property AllNPCs Auto
{Global config helper. Used for the MCM.}
; string _node = "Body [Ovl5]"


;TODO: Delete
Function Debug(Actor akTarget)
    ; Debug.MessageBox(GetRacialSettings(Player).Name())
    AllNPCs.method = 1
    AllNPCs.constAlpha = 1.0
    ApplyGlobalSettings()
    ApplyToNPCs(true)

    InitializeActor(Player)
    TestOverride(Player)
    ; string actorRace = MiscUtil.GetActorRaceEditorID(akTarget)
    ; Debug.Notification("Target Sex " + IsFemale(akTarget))
    ; int skinColor = NiOverride.GetSkinPropertyInt(akTarget, false, 4, 7, -1)
    ; NetImmerse.SetNodeTextureSet(Player, "Body [Ovl0]", femaleTexSet, false)
    ; NiOverride.AddNodeOverrideInt(akTarget, true,  "Body [Ovl0]", 7, -1, skinColor, true)
EndFunction

;>=========================================================
;>===                      PUBLIC                       ===
;>=========================================================

;> Use these functions when you want to enable muscle definition.
Function InitData()
    {Initializes this script. Call this on game reload.}
    InitRacialSettings()
    InitPlayerTexture()
EndFunction

bool Function InitializeActor(Actor akTarget)
    {Sets a suitable texture set and a suitable alpha.}
    Trace("DM_SandowPP_TextureMngr.InitializeActor " + akTarget.getLeveledActorBase().getName())
    DM_SandowPP_RippedActor settings = SelectSettings(akTarget)
    If settings != None
        Trace("Found settings " + settings.Name())
        Trace("Texture set applied " + settings.texSet)
        Trace("Method " + settings.method)
        SetTextureSet(akTarget, settings.texSet)
        SetTexAlpha(akTarget, settings.GetAlpha(akTarget))
        ; int i = 1
        ; While (i <= 5)
        ;     SetTextureSet(akTarget, settings.texSet, "Body [Ovl" + i + "]")
        ;     SetTexAlpha(akTarget, settings.GetAlpha(akTarget), "Body [Ovl" + i + "]")
        ;     i += 1
        ; EndWhile
        return true
    EndIf
    return false
EndFunction

Function Clear(Actor akTarget)
    SetTexAlpha(akTarget, 0.0)
    SetTextureSet(akTarget, None)
EndFunction

; Applies ripped settings to nearby NPCs.
; If forceUpdate, it outright sets values bypassing the spell check.
Function ApplyToNPCs(bool forceUpdate = false)
    Trace("ApplyToNPCs()")
    Actor[] npcs = MiscUtil.ScanCellNPCs(Player, 2048.0, None, false)
    int i = npcs.length
    Trace("NPCs found: " + i)
    While i > 0
        i -= 1
        Trace("Applying to: " + npcs[i] + npcs[i].getLeveledActorBase().getName())
        If npcs[i] != Player
    ; return  ; FIXME: Delete this
            TestOverride(npcs[i])
            ; If forceUpdate
            ;     InitializeActor(npcs[i])
            ; Else
            ;     ApplyToNPC(npcs[i])
            ; EndIf
        EndIf
     EndWhile
EndFunction

Event OnUpdate()
    ; TestOverride(Player)
    UnregisterForUpdate()
    Trace("OnUpdate()")
    ApplyToNPCs(true)
    RegisterForSingleUpdate(5.0)
EndEvent

;>=========================================================
;>===                       MCM                         ===
;>=========================================================

Function ApplyGlobalSettings()
    {Applies the global settings to all races.}
    int i = racesSettings.GetSize()
    While i > 0
        i -= 1
        RippedActor(i).AssignSettings(AllNPCs)
    EndWhile
EndFunction

;@Private:
;>Building blocks. These aren't designed for interacting with other scripts.

;>=========================================================
;>===                       SETUP                       ===
;>=========================================================

Function InitRacialSettings()
    {Initialize racial settings.}
    int n = racesSettings.GetSize()
    DM_SandowPP_RippedActor raceS
    While n > 0
        n -= 1
        raceS = racesSettings.GetAt(n) as DM_SandowPP_RippedActor
        raceS.Init()
    EndWhile
EndFunction

DM_SandowPP_RippedActor Function GetRacialSettings(Actor akTarget)
    {Gets racial settings for an Actor.}
    ; We iterate from 0 to max because most likely races (humanoids) are first in the list
    int i = 0
    int n = racesSettings.GetSize()
    DM_SandowPP_RippedActor raceS
    While i < n
        raceS = RippedActor(i)
        ; raceS = racesSettings.GetAt(i) as DM_SandowPP_RippedActor
        If raceS.IsMe(akTarget)
            return raceS
        EndIf
        i += 1
    EndWhile
    return None
EndFunction

DM_SandowPP_RippedActor Function RippedActor(int idx)
    {Returns the ripped actor at <idx> from the supported races Formlist.}
    return racesSettings.GetAt(idx) as DM_SandowPP_RippedActor
EndFunction

Function InitPlayerTexture()
    {Gets the texture of the player based on their race and sex.}
    PlayerSettings.texSet = GetRacialSettings(Player).texSet
EndFunction

Function ApplyToNPC(Actor akTarget)
    {Applies ripped settings to one NPC only if its lacks a mark or it has expired.}
    Trace("ApplyToNPC() " + akTarget)
    If !akTarget.HasMagicEffect(NPCRippedFx)
        InitializeActor(akTarget)
        ResetNPCSpell(akTarget)
    EndIf
EndFunction

Function ResetNPCSpell(Actor akTarget)
    {Resets the spell telling the NPC has already been processed.}
    If akTarget.HasSpell(NPCRippedSpell)
        akTarget.RemoveSpell(NPCRippedSpell)
    EndIf
    akTarget.AddSpell(NPCRippedSpell)
EndFunction

DM_SandowPP_RippedActor Function SelectSettings(Actor akTarget)
    {Selects suitable settings for akTarget.}
    DM_SandowPP_RippedActor settings = GetRacialSettings(akTarget)
    If akTarget == Player
        settings = PlayerSettings
    Else
        settings = GetRacialSettings(akTarget)
    EndIf
    return settings
EndFunction

bool Function SetTextureSet(Actor akTarget, TextureSet tx, string node = "Body [Ovl5]")
    {Blindly sets a texture set to a target.}
    Trace("SetTextureSet() On node " + node)
    ; This function is so heavily commented because there's no documentation on NiOverride
    bool isFemale = IsFemale(akTarget)

    ; Index is irrelevant for all these specific operations. It's **somewhat** documented in the NiOverride source code.
    int irrelevant = -1
    ; It NEEDS to be this override layer (is that called like that? No info anywhere). Don't ask me why it doesn't work with other nodes, like "Body [Ovl0]" et al.
    ; string node = "Body [Ovl5]"
    ; Get the skin tint color of the Actor to reapply it soon
    int skinColor = NiOverride.GetSkinPropertyInt(akTarget, false, 4, 7, -1)
    ; Add the texture set we want to show
    NiOverride.AddNodeOverrideTextureSet(akTarget, isFemale, node, 6, irrelevant, tx, true)
    NiOverride.AddNodeOverrideFloat(akTarget, isFemale,  node, 8, irrelevant, 0.0, true)
    ; Last operation resets the skin tint color to white, making the character's body pale. Restore the color we got earlier.
    NiOverride.AddNodeOverrideInt(akTarget, isFemale,  node, 7, irrelevant, skinColor, true)
    ; Profit! Have a nice day.
EndFunction

Function TestOverride(Actor akTarget)

    string tx = "\\textures\\actors\\character\\Sandow PP\\female\\w100.dds"
    ; AddSkinOverrideString(ObjectReference ref, bool isFemale, bool firstPerson, int slotMask, int key, int index, string value, bool persist)
    int idx = 1     ; Normal maps
    int ky = 9
    ; While idx <= 8
    ;     Trace("*********** " + NiOverride.GetSkinPropertyString(akTarget, false, 0x04, ky, idx) + " idx = " + idx)
    ;     idx += 1
    ; EndWhile
    int i = 0
    string node = "Body [Ovl5]"

    ; While (i <= 5)
    ;     node = "Body [Ovl" + i + "]"
    ;     Trace("*********** " + NiOverride.GetNodeOverrideString(akTarget, IsFemale(akTarget), node, ky, idx) + " " + node)
    ;     NiOverride.AddNodeOverrideString(akTarget, IsFemale(akTarget), node, ky, idx, tx, false)
    ;     NiOverride.AddNodeOverrideFloat(akTarget, IsFemale(akTarget), node, ky, idx, 1.0, false)
    ;     Trace("*********** " + NiOverride.GetNodeOverrideString(akTarget, IsFemale(akTarget), node, ky, idx) + " " + node)
    ;     i += 1
    ; EndWhile
    ; string hands = NiOverride.GetSkinPropertyString(akTarget, false, 0x08, ky, idx)
    ; Trace("*********** " + hands + " idx = " + idx)
    ; Trace("*********** " + NiOverride.GetSkinPropertyString(akTarget, false, 0x04, ky, idx) + " idx = " + idx)
    ; NiOverride.AddSkinOverrideString(akTarget, IsFemale(akTarget), false, 0x04, ky, idx, tx, false)
    ; NiOverride.AddSkinOverrideFloat(akTarget, IsFemale(akTarget), false, 0x04, ky, idx, 0.50, false)
    ; NiOverride.AddSkinOverrideString(akTarget, IsFemale(akTarget), false, 0x08, ky, idx, hands, false)
    ; Trace("*********** " + NiOverride.GetSkinPropertyString(akTarget, false, 0x04, ky, idx) + " idx = " + idx)
    TextureSet ts = RippedActor(1).texSet
    ; NiOverride.AddSkinOverrideTextureSet(akTarget, IsFemale(akTarget), false, 0x05, 6, -1, ts, false)
    NiOverride.AddNodeOverrideTextureSet(akTarget, IsFemale(akTarget), node, 6, -1, ts, true)
EndFunction

Function SetTexAlpha(Actor akTarget, float alpha, string node = "Body [Ovl5]")
    {Sets how ripped the player will look.}
    trace("SetAlpha " + akTarget.getLeveledActorBase().getName() + " " + alpha)
    Trace("On node " + node)
    alpha = ConstrainF(alpha, 0.0, 1.0)
    bool isFemale = IsFemale(akTarget)

    ; This call needs some explanation.
    ; AddNodeOverrideFloat(ObjectReference ref, bool isFemale, string node, int key, int index, float value, bool persist)

    ; ref, isFemale, value and persist are self-explanatory.

    ; Node is which "layer?" we want to change. The only way to
    ; change normal maps is using whole texture sets, and the only
    ; node in which texture sets are shown is "Body [Ovl5]". This
    ; limitation makes this mod probably incompatible with those that
    ; also **had to use** this node.

    ; Key = 8 is used to tell NiOverride to change the alpha channel value.
    ; Index is irrelevant to this operation, so -1 it is.
    NiOverride.AddNodeOverrideFloat(akTarget, isFemale,  node, 8, -1, alpha, true)
    trace(akTarget + " " + alpha)
EndFunction


;>=========================================================
;>===                 RACE VALIDATORS                   ===
;>=========================================================

bool Function IsValidRace(Actor akTarget)
    {Checks if an actor has a compatible race.}
    return GetRacialSettings(akTarget) != None
EndFunction

bool Function IsFemale(Actor akTarget)
    {It seems GetSex won't work if used inside a Global function; it can't be added to a library.}
    return akTarget.GetLeveledActorBase().GetSex() == 1
EndFunction
