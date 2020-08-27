Scriptname DM_SandowPP_TextureMngr Extends Quest
{Decides which texture set an actor should use. Used to make them ripped}

Import DM_SandowPP_Globals
Import DM_Utils

; DM_SandowPPMain Property Owner Auto
Actor property Player auto
TextureSet Property femaleTexSet Auto
TextureSet Property maleTexSet Auto

string[] _validHumanoids
string[] _validCats
string[] _validLizards

Function Debug(Actor akTarget)
    string actorRace = MiscUtil.GetActorRaceEditorID(akTarget)
    Debug.Notification("Debug " + IsHumanoid(akTarget))
    ; debug.messagebox("Is valid " + IsValidRace(akTarget))
    ; debug.messagebox("Exito "+ DM_Utils.GetActorName(akTarget) + " " + actorRace + " " + _validCats + _validLizards + _validHumanoids)
    trace(_validHumanoids)
    trace(DM_Utils.now())
EndFunction

Function LoadValidRaces()
    {Loads an array of races that can be ripped.}
    ; Read this from an external *.json to easily patch.
    string f = "../Sandow Plus Plus/Ripped Races.json"

    ; Actors that use a humanoid skin
    _validHumanoids = Utility.CreateStringArray(JsonUtil.GetIntValue(f, "humanlistsize"))
    _validHumanoids = JsonUtil.StringListToArray(f, "humanoids")
    ; Actors that use a khajiit skin
    _validCats = Utility.CreateStringArray(JsonUtil.GetIntValue(f, "catlistsize"))
    _validCats = JsonUtil.StringListToArray(f, "cats")
    ; Actors that use an argonian skin
    _validLizards = Utility.CreateStringArray(JsonUtil.GetIntValue(f, "lizardlistsize"))
    _validLizards = JsonUtil.StringListToArray(f, "lizards")
EndFunction

Function  SaveRacesTest()
    ; ************************ DELETE THIS *****************************
    ; Saving an array with uninitialized indexes cause CTDs
    string[] races = new string[2]
    races[0] = "BretonRace"
    races[1] = "BretonRaceVampire"
    string f = "../Sandow Plus Plus/Ripped Races.json"
    JsonUtil.SetIntValue(f, "dataSize", races.length)
    JsonUtil.StringListCopy(f, "validRaces", races)
    JsonUtil.Save(f)
EndFunction

Function InitData()
    {Initializes this script. Call this on game reload.}
    LoadValidRaces()
EndFunction

bool Function IsValidRace(Actor akTarget)
    {Checks if an actor has a compatible race.}
    return IsHumanoid(akTarget) || IsCat(akTarget) || IsLizard(akTarget)
EndFunction

bool Function IsCat(Actor akTarget)
    {Checks if an actor is Khajiit or variant.}
    return IndexOfS(_validCats, MiscUtil.GetActorRaceEditorID(akTarget)) != -1
EndFunction

bool Function IsLizard(Actor akTarget)
    {Checks if an actor is Khajiit or variant.}
    return IndexOfS(_validLizards, MiscUtil.GetActorRaceEditorID(akTarget)) != -1
EndFunction

bool Function IsHumanoid(Actor akTarget)
    {Checks if an actor is humanoid.}
    return IndexOfSBin(_validHumanoids, MiscUtil.GetActorRaceEditorID(akTarget)) != -1
EndFunction

bool Function SetTextureSet(Actor akTarget)
    {This function is so heavily commented because there's no documentation on NiOverride}
    bool isFemale = IsFemale(akTarget)
    trace("isFemale " + GetActorSex(akTarget) + " " + isFemale)
    trace("isMale " + GetActorSex(akTarget) + " " + isMale(akTarget) + GetActorSex(akTarget) == 0)
    isFemale = true

    ; Get a suitable texture set or exit if we couldn't find it
    TextureSet tx = SelectTextureSet(akTarget)
    If !tx
        return false
    EndIf
    ; Index is irrelevant for all these specific operations. It's **somewhat** documented in the NiOverride source code.
    int irrelevant = -1
    ; It NEEDS to be this override layer (is that called like that? No info anywhere). Don't ask me why it doesn't work with other nodes, like "Body [Ovl0]" et al.
    string node = "Body [Ovl5]"
    ; Get the skin tint color of the Actor to reapply it soon
    int skinColor = NiOverride.GetSkinPropertyInt(akTarget, false, 4, 7, -1)
    ; Add the texture set we want to show
    NiOverride.AddNodeOverrideTextureSet(akTarget, isFemale, node, 6, irrelevant, tx, true)
    NiOverride.AddNodeOverrideFloat(akTarget, isFemale,  node, 8, irrelevant, 0.0, true)
    ; Last operation resets the skin tint color to white, making the character's body pale. Restore the color we got earlier.
    NiOverride.AddNodeOverrideInt(akTarget, isFemale,  node, 7, irrelevant, skinColor, true)
    ; Profit! Have a nice day.
    return true
EndFunction

Function SetAlpha(Actor akTarget, float alpha)
    bool isFemale = IsFemale(akTarget)
    isFemale = true
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
    NiOverride.AddNodeOverrideFloat(akTarget, isFemale,  "Body [Ovl5]", 8, -1, alpha, true)
    trace(akTarget + " " + alpha)
EndFunction

bool Function SetTextureSetAndAlpha(Actor akTarget, float alpha)
    {Sets a suitable texture set and a direct (ie. not LERPed) alpha.}
    trace(akTarget + " " + alpha)
    If SetTextureSet(akTarget)
        trace("texture can be set")
        SetAlpha(akTarget, alpha)
    EndIf
EndFunction

TextureSet Function SelectTextureSet(Actor akTarget)
    {Selects a texture set suitable for known races}
    If IsHumanoid(akTarget)
        If IsFemale(akTarget)
            return femaleTexSet
        Else
            return maleTexSet
        EndIf
    EndIf
    return None
EndFunction
