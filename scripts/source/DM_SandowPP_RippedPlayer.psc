Scriptname DM_SandowPP_RippedPlayer extends DM_SandowPP_RippedActor
{Script used to store muscle definition configurations for the Player.}

Actor property Player auto

bool Property bulkCut = false Auto
{Does the player want to bulk&cut?}
int Property bulkCutDays = 4 Auto
{Automatically switch behaviors after this many sleeping sessions.}
int Property bulkCutBhv = 0 Auto
{Switch to which bulking behavior?}
int Property minDaysToMax = 30 Auto
{How many days does it takes the player to get max definition at 0% weight. [20,60]. Default = 30.}
int Property maxDaysToMax = 120 Auto
{How many days does it takes the player to get max definition at 100% weight. [90,420]. Default = 120.}

;@Public:
Function SetBulkBhv(int bhv)
    ; TODO: Finish
EndFunction

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

; Sets the behavior that controls player muscle definiton
Function SetBehavior(DM_SandowPP_AlgorithmBodyfatChange bhv)
    ((self as Form) as DM_SandowPP_RippedAlphaCalcPlayer).SetBehavior(bhv)
EndFunction
