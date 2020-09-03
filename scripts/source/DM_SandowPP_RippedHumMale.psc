Scriptname DM_SandowPP_RippedHumMale extends DM_SandowPP_RippedHum
{Script used to store muscle definition configurations for humanoid females.}

;@override:
bool Function IsFemale()
    return false
EndFunction

;@override:
string Function Name()
    return "HumMale"
EndFunction
