Scriptname DM_SandowPP_RippedHumFem extends DM_SandowPP_RippedHum
{Script used to store muscle definition configurations for humanoid females.}

;@override:
bool Function IsFemale()
    return true
EndFunction

;@override:
string Function Name()
    return "HumFem"
EndFunction
