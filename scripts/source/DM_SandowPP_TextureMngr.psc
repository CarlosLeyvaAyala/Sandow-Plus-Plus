;  ===========================================
;  Overview
;  ===========================================
; This is the main script that changes an Actor appeareance.
; It basically decides how and which texture to apply to the player. ~~any given actor and automates the MCM options for NPCs.
; This script adds two layers:
;       * The least ripped the actor can be.
;       * The most ripped the actor can be.

; To simulate muscle definiton it alpha blends the most ripped layer.

;@Overview:
;       * Initializes everything needed to get actors ripped.
;       * Applies texture sets on other scripts' demands.
;       ~~* Scans the environment every <x> seconds to apply the spell that keeps track of whom NPCs
;        ~~ have been set their muscle definition.
;        ~~ This spell expires after 30 min, so it can be reapplied to NPCs.

;@Info:
; To add a new race based on the ones that already exist:
;       * Add its name to  "__Ripped Races.json" under whichever texture is right.

; To add more races (like avian races and shit):
;       * Do the same steps as adding support for already existing races.
;       * Create a new texture set in the CK, pointing to the most ripped texture.
          ;WARNING:
;         As long as NiOverride fails to work for NPCs, a "least ripped" texture set is needed
;         for using it on the player, so this mod can be compatible with Ripped Bodies.
;         This mods changes player while ripped bodies changes NPCs.
;       * Create new "DM_SandowPP_RippedActor" descendants and add them to new quests.
;         Don't forget to set all their needed properties.
;       * Add those new quests to the "DM_SPP_RippedRaces" formlist in the CK.

Scriptname DM_SandowPP_TextureMngr Extends Quest
{Decides which texture set an actor should use. Used to make them ripped.}

Import DM_SandowPP_Globals
Import DM_Utils

Actor property Player auto
; DM_SandowPP_Config Property Cfg Auto
Formlist Property racesSettings Auto
{List of all quests that contain racial settings.}
DM_SandowPP_RippedPlayer Property PlayerSettings Auto
{Quest that contain settings for the player.}

; Spell Property NPCRippedSpell Auto
; {Add this to an NPC to mark it as ripped.}
; MagicEffect Property NPCRippedFx Auto
; {Add this to an NPC to mark it as ripped.}
; Keyword Property ActorTypeNPC Auto
; {Keyword to scan only for NPCs.}
; DM_SandowPP_RippedActor Property AllNPCs Auto
; {Global config helper. Used for the MCM.}


;TODO: Delete
Function Debug(Actor akTarget)
    PlayerSettings.method = 1
    PlayerSettings.constAlpha = 0.4
    ; AllNPCs.method = 1
    ; AllNPCs.constAlpha = 1.0
    ; ApplyGlobalSettings()
    ; ApplyToNPCs(true)

    ; InitializeActor(Player)
    ; string actorRace = MiscUtil.GetActorRaceEditorID(akTarget)
    ; Debug.Notification("Target Sex " + IsFemale(akTarget))
EndFunction

;>=========================================================
;>===                      PUBLIC                       ===
;>=========================================================

;> Use these functions when you want to enable muscle definition.

; Initializes this script. Call this on game reload.
Function InitData()
    InitRacialSettings()
    InitPlayerTexture()
    ; Ripped textures need to be reapplied each game reload.
    InitializeActor(Player)
EndFunction

; Sets a suitable texture set and a suitable alpha.
bool Function InitializeActor(Actor akTarget)
    ; Trace("DM_SandowPP_TextureMngr.InitializeActor " + akTarget.getLeveledActorBase().getName())
    DM_SandowPP_RippedActor settings = SelectSettings(akTarget)
    If settings != None
        ; Set least ripped texture to always visible
        SetTextureSetAndAlpha(akTarget, settings.texSetLo, 1.0, "Body [Ovl0]")
        ; Sets most ripped texture as a blend.
        SetTextureSetAndAlpha(akTarget, settings.texSet, settings.GetAlpha(akTarget))
        ; SetTextureSet(akTarget, settings.texSet)
        ; SetTexAlpha(akTarget, settings.GetAlpha(akTarget))
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
;@Info: Not supported as long as NiOverride doesn't work for NPCs
; Function ApplyToNPCs(bool forceUpdate = false)
;     Trace("ApplyToNPCs()")
;     Actor[] npcs = MiscUtil.ScanCellNPCs(Player, 2048.0, None, false)
;     int i = npcs.length
;     Trace("NPCs found: " + i)
;     While i > 0
;         i -= 1
;         Trace("Applying to: " + npcs[i] + npcs[i].getLeveledActorBase().getName())
;         If npcs[i] != Player
;             If forceUpdate
;                 InitializeActor(npcs[i])
;             Else
;                 ApplyToNPC(npcs[i])
;             EndIf
;         EndIf
;      EndWhile
; EndFunction

; Event OnUpdate()
;     ; TestOverride(Player)
;     UnregisterForUpdate()
;     Trace("OnUpdate()")
;     ApplyToNPCs(true)
;     RegisterForSingleUpdate(5.0)
; EndEvent

;>=========================================================
;>===                       MCM                         ===
;>=========================================================

;@Info: Not supported as long as NiOverride doesn't work for NPCs
; Function ApplyGlobalSettings()
;     {Applies the global settings to all races.}
;     int i = racesSettings.GetSize()
;     While i > 0
;         i -= 1
;         RippedActor(i).AssignSettings(AllNPCs)
;     EndWhile
; EndFunction

;@Private:
;>Building blocks. These aren't designed for interacting with other scripts.

;>=========================================================
;>===                       SETUP                       ===
;>=========================================================

; Initialize racial settings.
;
; Loads configurations for all known races.
Function InitRacialSettings()
    int n = racesSettings.GetSize()
    DM_SandowPP_RippedActor raceS
    While n > 0
        n -= 1
        raceS = racesSettings.GetAt(n) as DM_SandowPP_RippedActor
        raceS.Init()
    EndWhile
EndFunction

; Gets racial settings for an Actor.
;
; This checks if an actor is member of one of the known races. If it is,
; it returns their racial settings. If not from known race, returns None.
DM_SandowPP_RippedActor Function GetRacialSettings(Actor akTarget)
    ; We iterate from 0 to max because most likely races (humanoids) are first in the list
    int i = 0
    int n = racesSettings.GetSize()
    DM_SandowPP_RippedActor raceS
    While i < n
        raceS = RippedActor(i)
        If raceS.IsMe(akTarget)
            return raceS
        EndIf
        i += 1
    EndWhile
    return None
EndFunction

; Returns the ripped actor at idx from the supported races Formlist.
DM_SandowPP_RippedActor Function RippedActor(int idx)
    return racesSettings.GetAt(idx) as DM_SandowPP_RippedActor
EndFunction

; Gets the texture of the player based on their race and sex.
Function InitPlayerTexture()
    DM_SandowPP_RippedActor pl = GetRacialSettings(Player)
    PlayerSettings.texSet = pl.texSet
    PlayerSettings.texSetLo = pl.texSetLo
EndFunction


; Selects suitable racial settings for akTarget.
; Fully usable when textures can be aplplied to NPCs.
DM_SandowPP_RippedActor Function SelectSettings(Actor akTarget)
    DM_SandowPP_RippedActor settings = GetRacialSettings(akTarget)
    If akTarget == Player
        settings = PlayerSettings
    Else
        settings = GetRacialSettings(akTarget)
    EndIf
    return settings
EndFunction


; Applies ripped settings to one NPC only if its lacks a mark or it has expired.
; Function ApplyToNPC(Actor akTarget)
;     Trace("ApplyToNPC() " + akTarget)
;     If !akTarget.HasMagicEffect(NPCRippedFx)
;         InitializeActor(akTarget)
;         ResetNPCSpell(akTarget)
;     EndIf
; EndFunction

; Function ResetNPCSpell(Actor akTarget)
;     {Resets the spell telling the NPC has already been processed.}
;     If akTarget.HasSpell(NPCRippedSpell)
;         akTarget.RemoveSpell(NPCRippedSpell)
;     EndIf
;     akTarget.AddSpell(NPCRippedSpell)
; EndFunction

;>=========================================================
;>===                 RACE VALIDATORS                   ===
;>=========================================================

; Checks if an actor has a compatible race.
bool Function IsValidRace(Actor akTarget)
    return GetRacialSettings(akTarget) != None
EndFunction

; It seems GetSex won't work if used inside a Global function; it can't be added to a library.
bool Function IsFemale(Actor akTarget)
    return akTarget.GetLeveledActorBase().GetSex() == 1
EndFunction


;>=========================================================
;>===            CORE - TEXTURE MANIPULATION            ===
;>=========================================================

; Blindly sets a texture set to a target.
bool Function SetTextureSet(Actor akTarget, TextureSet tx, string node = "Body [Ovl1]")
    ; This function is so heavily commented because there's no documentation on NiOverride
    bool isFemale = IsFemale(akTarget)

    ; Index is irrelevant for all these specific operations. It's **somewhat** documented in the NiOverride source code.
    int irrelevant = -1
    ; It NEEDS to be this override layer (is that called like that? No info anywhere). Don't ask me why it doesn't work with other nodes, like "Body [Ovl0]" et al.
    ; string node = "Body [Ovl5]"
    ; Get the skin tint color of the Actor to reapply it soon
    int skinColor = NiOverride.GetSkinPropertyInt(akTarget, false, 4, 7, -1)
    ; Add the texture set we want to show and make it invisible
    ; WARNING: NiOverride.AddNodeOverrideTextureSet only works for [Body Ovl5], but
    ; WARNING: NetImmerse.SetNodeTextureSet works for [Body Ovl0..5]. But it always needs to be reapplied at game reload.
    ;
    ;~~NiOverride.AddNodeOverrideTextureSet(akTarget, isFemale, node, 6, irrelevant, tx, true)
    NetImmerse.SetNodeTextureSet(akTarget, node, tx, false)
    NiOverride.AddNodeOverrideFloat(akTarget, isFemale, node, 8, irrelevant, 0.0, true)
    ; Last operation resets the skin tint color to white, making the character's body pale. Restore the color we got earlier.
    NiOverride.AddNodeOverrideInt(akTarget, isFemale, node, 7, irrelevant, skinColor, true)
    ; Profit! Have a nice day.
EndFunction

; Sets how much ripped an actor will look.
;
; "Node" can go from "Body [Ovl0]" to "Body [Ovl5]. Higher layers overwrite lower ones."
Function SetTexAlpha(Actor akTarget, float alpha, string node = "Body [Ovl1]")
    ; trace("SetAlpha " + akTarget.getLeveledActorBase().getName() + " " + alpha)
    alpha = ConstrainF(alpha, 0.0, 1.0)
    bool isFemale = IsFemale(akTarget)

    ; This call needs some explanation.
    ; ref, isFemale, value and persist are self-explanatory.

    ; Node is which "layer?" we want to change. The only way to
    ; change normal maps is using whole texture sets, and the only
    ; node in which texture sets are shown is "Body [Ovl5]" if using
    ; NiOverride.AddNodeOverrideTextureSet.
    ; Using NetImmerse.SetNodeTextureSet seems to work for all layers.
    ; This limitation makes this mod probably incompatible with those that
    ; also **had to use** this node.

    ; Key = 8 is used to tell NiOverride to change the alpha channel value.
    ; Index is irrelevant to this operation, so -1 it is.
    NiOverride.AddNodeOverrideFloat(akTarget, isFemale,  node, 8, -1, alpha, true)
EndFunction

Function SetTextureSetAndAlpha(Actor akTarget, TextureSet tx, float alpha, string node = "Body [Ovl1]")
    SetTextureSet(akTarget, tx, node)
    SetTexAlpha(akTarget, alpha, node)
EndFunction
