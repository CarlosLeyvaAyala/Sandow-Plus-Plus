Scriptname DM_SandowPP_TextureMngr Extends Quest
{Decides which texture set an actor should use. Used to make them ripped}

Import DM_SandowPP_Globals
Import DM_Utils

; DM_SandowPPMain Property Owner Auto
Actor property Player auto
TextureSet Property femaleTexSet Auto
TextureSet Property maleTexSet Auto
DM_SandowPP_Config Property Cfg Auto

string[] _validHumanoids
string[] _validCats
string[] _validLizards

Function Debug(Actor akTarget)
    string actorRace = MiscUtil.GetActorRaceEditorID(akTarget)
    Debug.Notification("Target Sex " + IsFemale(akTarget))
    ; debug.messagebox("Is valid " + IsValidRace(akTarget))
    ; debug.messagebox("Exito "+ DM_Utils.GetActorName(akTarget) + " " + actorRace + " " + _validCats + _validLizards + _validHumanoids)
    trace(_validHumanoids)
    trace(DM_Utils.now())
    SetTextureSetAndAlpha(akTarget, 1)
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
    ; bool isFemale = akTarget.GetLeveledActorBase().GetSex() == 1
    trace("isFemale " + isFemale(akTarget))

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
    trace("SetAlpha " + aktarget + " " + alpha)
    alpha = ConstrainF(alpha, 0.0, 1.0)
    bool isFemale = IsFemale(akTarget)
    ; bool isFemale = akTarget.GetLeveledActorBase().GetSex()
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
    If SetTextureSet(akTarget)
        SetAlpha(akTarget, alpha)
        return true
    EndIf
    return false
EndFunction

TextureSet Function SelectTextureSet(Actor akTarget)
    {Selects a texture set suitable for known races}
    bool isFemale = IsFemale(akTarget)
    If IsHumanoid(akTarget)
        If isFemale
            return femaleTexSet
        Else
            return maleTexSet
        EndIf
    EndIf
    return None
EndFunction

bool Function IsFemale(Actor akTarget)
    {It seems GetSex won't work if used inside a Global function; it can't be added to a library.}
    return akTarget.GetLeveledActorBase().GetSex() == 1
EndFunction

Function Clear(Actor akTarget)
    SetAlpha(akTarget, 0.0)
EndFunction

float Function GetActorWeight(Actor akTarget)
    {Returns actor weight as percent.}
    trace("GetActorWeight " + aktarget)
    return akTarget.GetActorBase().GetWeight() / 100.0
EndFunction

; bool Function SetTextureAndLerpA(Actor akTarget, float alpha)
;     {Sets a suitable texture set and a LERPed alpha.}
;     If SetTextureSet(akTarget)
;         SetAlpha(akTarget, LerpAlpha(akTarget, alpha))
;     EndIf
; EndFunction

float Function LerpAlpha(Actor akTarget, float alpha)
    {Linearly interpolates an alpha between player configured bounds. Automatically gets info for sex and race.}
    bool isFemale = IsFemale(akTarget)
    ; TODO: Arreglar
    If (akTarget == Player)
        return LerpPlayerAlpha(alpha)
    EndIf
    return alpha
EndFunction

Function SetLerpAlpha(Actor akTarget, float alpha)
    {Gets a linearly interpolated alpha and sets it to an actor.}
    SetAlpha(aktarget, LerpAlpha(aktarget, alpha))
EndFunction

float Function LerpPlayerAlpha(float alpha)
    {Lerps alpha from player MCM settings. You can use this for behavior set alpha, too.}
    trace("LerpPlayerAlpha ")
    return Lerp(Cfg.RippedPlayerLB, Cfg.RippedPlayerUB, alpha)
EndFunction

Function AlphaFromWeight(Actor akTarget)
    SetLerpAlpha(akTarget, GetActorWeight(akTarget))
EndFunction

Function AlphaFromWeightInv(Actor akTarget)
    SetLerpAlpha(akTarget, 1.0 - GetActorWeight(akTarget))
EndFunction

Function AlphaFromSkills(Actor akTarget)
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
    trace("Skills")
    trace(hv)
    trace(sn)
    trace(th)
    trace(bl)
    trace(lt)
    trace(oh)
    trace(at)
    trace(ar)
    trace(sm)
    float alpha = (hv + sn + th + bl + lt + oh + at + ar + sm) / 500.0
    SetLerpAlpha(akTarget, alpha)
EndFunction

Function SetAlphaFromOptions(Actor akTarget)
    {Sets an actor alpha based on MCM options. DO NOT USE FOR BEHAVIOR SET ALPHA.}
    If  aktarget == Player
        PlayerAlphaFromOptions()
    EndIf
EndFunction

Function PlayerAlphaFromOptions()
    {Sets the player alpha based on MCM options.}
    If Cfg.RippedPlayerMethodIsConst()
        trace("Set const")
        SetAlpha(Player, Cfg.RippedPlayerConstLvl)
    ElseIf Cfg.RippedPlayerMethodIsSkill()
        trace("Set skill")
        AlphaFromSkills(Player)
    ElseIf Cfg.RippedPlayerMethodIsWeight()
        trace("Set by weight")
        AlphaFromWeight(Player)
    ElseIf Cfg.RippedPlayerMethodIsWeInv()
        trace("Set by weight inv")
        AlphaFromWeightInv(Player)
    Else
        Clear(Player)
    EndIf
EndFunction

bool Function InitializeActor(Actor akTarget)
    {Sets a suitable texture set and a suitable alpha.}
    If SetTextureSet(akTarget)
        SetAlphaFromOptions(akTarget)
        return true
    EndIf
    return false
EndFunction
