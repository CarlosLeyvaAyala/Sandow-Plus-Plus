; This script is a common interface to add races so they can get ripped.
; Each descendant means a new pair of *.dds textures needed for this to work.
; This script and its descendants are meant to be archetypes, not concrete objects;
; that's why many functions ask for an Actor on who to work on.

;@Example:
; Men and Mer both use the same kind of texture sets. Since men and women use different textures, to fully implement humanoids we need at least two descendants. Fully implementing vanilla races needs 6 descendants; humanoids, khajiit and argonians x (men and women).

;@Hint:
; Each time we talk about what the player wants, we are talking about things configurable at the MCM.

Scriptname DM_SandowPP_RippedActor extends Quest Hidden
{Script used to store muscle definition configurations. This is mostly a throwback for when
I thought it was possible to change NPCs textures. Might get used as intended when NiOverride
gets finished.}
Import DM_SandowPP_Globals

int Property method = 0 Auto
{Method used to set this actor muscle definition.}
float Property constAlpha = 1.0 Auto
{Value of the alpha if the player want it to be a constant.}
float Property LB = 0.0 Auto
{Min. muscle def. the player wants to have.}
float Property UB = 1.0 Auto
{Max. muscle def. the player wants to have.}
TextureSet Property texSet Auto
{The most ripped texture set which needs to be applied.}
TextureSet Property texSetLo Auto
{The least ripped texture set which needs to be applied.}

;>=========================================================
;>===                      PUBLIC                       ===
;>=========================================================

Function Init()
    InitRacesArray()
EndFunction

float Function GetAlpha(Actor akTarget)
    {Get the alpha calculation part from this form.}
    return ((Self as Form) as DM_SandowPP_RippedAlphaCalc).GetAlpha(akTarget)
EndFunction

Function AssignSettings(DM_SandowPP_RippedActor src)
    {Gets settings from another ripped actor temlpate. Texture sets aren¡t assigned because
    that would break all actor looks.}
    method = src.method
    constAlpha = src.constAlpha
    LB = src.LB
    UB = src.UB
EndFunction

;@virtual:
bool Function IsMe(Actor akTarget)
    {Determines if akTarget is the same kind as this class.}
    If ActorIsFemale(akTarget) != IsFemale()
        ; Different sex. Can't be from this type.
        return false
    Else
        return ActorIsThisRace(akTarget)
    EndIf
EndFunction

;@abstract:
string Function Name()
    {This is used to save it's data and such.}
    return "***ERRROR***"
EndFunction

;@virtual:
; TODO: Do it.
Function SaveToFile()
    {Saves this }
EndFunction

;@virtual:
; TODO: Do it.
Function LoadFromFile()
    {Saves this }
EndFunction


;@Private:
;>Building blocks. These aren't designed for interacting with other scripts.

;>=========================================================
;>===                       SETUP                       ===
;>=========================================================

;@abstract:
Function InitRacesArray()
    {Initializes the array of valid races for this configuration.}
    Trace("DM_SandowPP_RippedActor.InitRacesArray() shouldn't be called")
EndFunction

string[] Function LoadValidRaces(string aKey)
    {Loads an array of races with the <aKey> name. Used by this script descendants.}
    ; Read this from an external *.json to easily patch.
    string f = JsonFileName("__Ripped Races.json")
    string[] result = ReadStrArray(f, aKey)
    return result
EndFunction

;>=========================================================
;>===                     COMPARE                       ===
;>=========================================================


;@abstract:
bool Function ActorIsThisRace(Actor akTarget)
    return false
EndFunction

bool Function ActorIsFemale(Actor akTarget)
    return akTarget.GetLeveledActorBase().GetSex() == 1
EndFunction

;@abstract:
bool Function IsFemale()
    {Determines if this script represents females.}
    return false
EndFunction
