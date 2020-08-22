Scriptname DM_SandowPP_TextureMngr Extends Quest
{Decides which texture set an actor should use. Used to make them ripped}

Import DM_SandowPP_Globals

; DM_SandowPPMain Property Owner Auto
Actor property Player auto
TextureSet Property femaleTexSet Auto
TextureSet Property maleTexSet Auto

string[] _validRaces

Function Debug(Actor akTarget)
    string actorRace = MiscUtil.GetActorRaceEditorID(akTarget)
    LoadValidRaces()
    debug.messagebox("Exito "+ DM_Utils.GetActorName(akTarget) + " " + actorRace + " " + _validRaces)
    trace(_validRaces)
    trace(DM_Utils.now())
EndFunction

Function LoadValidRaces()
    {Loads an array of races that can be ripped.}
    string f = "../Sandow Plus Plus/Ripped Races.json"
    ; Read this from an external *.json to easily patch.
    _validRaces = Utility.CreateStringArray(JsonUtil.GetIntValue(f, "dataSize"))
    _validRaces = JsonUtil.StringListToArray(f, "validRaces")
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
    {Applies the texture set only to adult humanoids.}
    string actorRace = MiscUtil.GetActorRaceEditorID(akTarget)
    ; Search in races array
EndFunction

Function SelectTextureSet()
    {This function is so heavily commented because there's no documentation on NiOverride}

    ; You should use a property to get this texture set. This is just for testing.
    TextureSet tx = femaleTexSet
    ; Index is irrelevant for all these specific operations. It's **somewhat** documented in the NiOverride source code.
    int irrelevant = -1
    ; It NEEDS to be this override layer (is that called like that? No info anywhere). Don't ask me why it doesn't work with other nodes, like "Body [Ovl0]" et al.
    string node = "Body [Ovl5]"
    ; Get the skin tint color of the Actor to reapply it soon
    int skinColor = NiOverride.GetSkinPropertyInt(player, false, 4, 7, -1)
    ; Add the texture set we want to show
    NiOverride.AddNodeOverrideTextureSet(Player, true, node, 6, irrelevant, tx, true)
    NiOverride.AddNodeOverrideFloat(Player, true,  node, 8, irrelevant, 0.0, true)
    ; Last operation resets the skin tint color to white, making the character's body pale. Restore the color we got earlier.
    NiOverride.AddNodeOverrideInt(Player, true,  node, 7, irrelevant, skinColor, true)
    ; Profit! Have a nice day.
EndFunction
