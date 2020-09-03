Scriptname DM_SandowPP_RippedPlayer extends DM_SandowPP_RippedActor
{Script used to store muscle definition configurations for the Player.}

Actor property Player auto

bool Property bulkCut = false Auto
int Property bulkCutDays = 4 Auto
int Property bulkCutBhv = 0 Auto


;@override:
bool Function IsMe(Actor akTarget)
    return akTarget == Player
EndFunction

;@override:
string Function Name()
    return "Player"
EndFunction

;@override:
bool Function IsFemale()
    return ActorIsFemale(Player)
EndFunction

;@override:
; TODO: Do it.
Function SaveToFile()
    {Saves this }
EndFunction

;@override:
; TODO: Do it.
Function LoadFromFile()
    {Saves this }
EndFunction
