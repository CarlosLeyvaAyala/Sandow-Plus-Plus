; This script is a common interface to add races so they can get ripped.
; Each descendant means a new pair of *.dds textures needed for this to work.

;@Example:
; Men and Mer both use the same kind of texture sets. Since men and women use different textures, to fully implement humanoids we need at least two descendants. Fully implementing vanilla races needs 6 descendants; humanoids, khajiit and argonians x (men and women). 

;@Hint:
; Each time we talk about what the player wants, we are talking about things configurable at the MCM.

Scriptname DM_SandowPP_RippedActor extends Quest Hidden
{Script used to store muscle definition configurations.}

int Property method = 0 Auto
{Method used to set this actor muscle definition.}
float Property constAlpha = 1.0 Auto
{Value of the alpha if the player want it to be a constant.}
float Property LB = 0.0 Auto
{Min. muscle def. the player wants to have.}
float Property UB = 1.0 Auto
{Max. muscle def. the player wants to have.}
TextureSet Property texSet Auto
{Which ripped texture set needs to be applied.}

string Function Name()
    {This is used to save it's data and such.}
    ; WARNING: This needs to be implemented by all its descendants.
    return "***ERRROR***"
EndFunction

bool Function IsMe(Actor akTarget)
    {Determines if akTarget is the same kind as this class.}
    ; WARNING: This needs to be implemented by all its descendants.
EndFunction

Function SaveToFile()
    {Saves this }
EndFunction

Function LoadFromFile()
    {Saves this }
EndFunction