Scriptname DM_SandowPP_ReportArgs extends Quest 

string Property aText Auto
int Property aType Auto
int Property aCategory Auto
float Property aFVal Auto

Function Set(string aTxt, int aTyp)
    Clear()
    aText = aTxt
    aType = aTyp
EndFunction

Function CatVal(int aCat, float aVal)
    aCategory = aCat
    aFVal = aVal
EndFunction

Function Clear()
    aText = ""
    aType = 0
    aCategory = 0
    aFVal = 0.0
EndFunction