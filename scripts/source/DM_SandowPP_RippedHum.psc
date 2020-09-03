Scriptname DM_SandowPP_RippedHum extends DM_SandowPP_RippedActor Hidden
{Script used to store muscle definition configurations for humanoids.}

string[] _races

;@override:
Function InitRacesArray()
    _races = LoadValidRaces("humanoids")
EndFunction

;@override:
bool Function ActorIsThisRace(Actor akTarget)
    {This uses a binary search because it has more races than other arrays.}
    return DM_Utils.IndexOfSBin(_races, MiscUtil.GetActorRaceEditorID(akTarget)) != -1
EndFunction

