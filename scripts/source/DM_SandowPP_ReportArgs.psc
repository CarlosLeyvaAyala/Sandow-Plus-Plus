Scriptname DM_SandowPP_ReportArgs extends Quest

string Property aText Auto
int Property aType Auto
int Property aCategory Auto
float Property aFVal Auto

; Sets the message associated with the value to be reported. Used for telling the player if they've gained/lost weight, etc. and how much.
; This function should always be called before reporting.
Function Set(string aTxt, int aTyp)
    Clear()
    aText = aTxt
    aType = aTyp
EndFunction

; Sets a reporting category and its value.
; This is the value displayed by the widget meters.
;
; aCat => See DM_SandowPP_Report for Message Categories values.
; aVal => [0.0..1.0]. Value displayed by the meter asociated to this category.
Function CatVal(int aCat, float aVal)
    aCategory = aCat
    aFVal = aVal
EndFunction

;@Private:
Function Clear()
    aText = ""
    aType = 0
    aCategory = 0
    aFVal = 0.0
EndFunction
