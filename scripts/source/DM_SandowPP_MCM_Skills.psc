Scriptname DM_SandowPP_MCM_Skills extends DM_SandowPP_MCM_Bhv Hidden

Import DM_Utils
Import DM_SandowPP_Globals

Function PageSkills()
    SetCursorFillMode(TOP_TO_BOTTOM)
    int flag = DisableSkills()
    ;================================
    SetCursorPosition(0)
    Header("$MCM_WGPHeader")
    Slider("SL_AR", "$Archery", Cfg.skillRatioAr, slFmt, flag)
    Slider("SL_BL", "$Block", Cfg.skillRatioBl, slFmt, flag)
    Slider("SL_HA", "$Heavy Armor", Cfg.skillRatioHa, slFmt, flag)
    Slider("SL_LA", "$Light Armor", Cfg.skillRatioLa, slFmt, flag)
    Slider("SL_1H", "$One Handed", Cfg.skillRatio1H, slFmt, flag)
    Slider("SL_SM", "$Smithing", Cfg.skillRatioSm, slFmt, flag)
    Slider("SL_SN", "$Sneak", Cfg.skillRatioSn, slFmt, flag)
    Slider("SL_2H", "$Two Handed", Cfg.skillRatio2H, slFmt, flag)

    SetCursorPosition(1)
    AddHeaderOption("")
    Slider("SL_AL", "$Alteration", Cfg.skillRatioAl, slFmt, flag)
    Slider("SL_CO", "$Conjuration", Cfg.skillRatioCo, slFmt, flag)
    Slider("SL_DE", "$Destruction", Cfg.skillRatioDe, slFmt, flag)
    Slider("SL_IL", "$Illusion", Cfg.skillRatioIl, slFmt, flag)
    Slider("SL_RE", "$Restoration", Cfg.skillRatioRe, slFmt, flag)

    ;================================
    If !Cfg.IsSandow()
        Return
    EndIf
    SetCursorPosition(20)
    AddHeaderOption("<font color='#daa520'>$Other options</font>")
    Slider("SL_FP", "$MCM_SlFatiguePhys", ToPercent(Cfg.physFatigueRate), xslFmt)

    SetCursorPosition(21)
    AddHeaderOption("")
EndFunction

int Function DisableSkills()
    If Cfg.skillsLocked
        Return OPTION_FLAG_DISABLED
    Else
        Return OPTION_FLAG_NONE
    EndIf
EndFunction

State SL_AR
    Event OnSliderOpenST()
        CreateSkillSliderPhys(Cfg.skillRatioAr)
    EndEvent

    event OnSliderAcceptST(float val)
        Cfg.skillRatioAr =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        Cfg.skillRatioAr = Cfg.skillDefaultAr
        SetSliderOptionValueST(Cfg.skillRatioAr, slFmt)
    endEvent
EndState

State SL_BL
    Event OnSliderOpenST()
        CreateSkillSliderPhys(Cfg.skillRatioBl)
    EndEvent

    event OnSliderAcceptST(float val)
        Cfg.skillRatioBl =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        Cfg.skillRatioBl = Cfg.skillDefaultBl
        SetSliderOptionValueST(Cfg.skillRatioBl, slFmt)
    endEvent
EndState

State SL_HA
    Event OnSliderOpenST()
        CreateSkillSliderPhys(Cfg.skillRatioHa)
    EndEvent

    event OnSliderAcceptST(float val)
        Cfg.skillRatioHa =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        Cfg.skillRatioHa = Cfg.skillDefaultHa
        SetSliderOptionValueST(Cfg.skillRatioHa, slFmt)
    endEvent
EndState

State SL_LA
    Event OnSliderOpenST()
        CreateSkillSliderPhys(Cfg.skillRatioLa)
    EndEvent

    event OnSliderAcceptST(float val)
        Cfg.skillRatioLa =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        Cfg.skillRatioLa = Cfg.skillDefaultLa
        SetSliderOptionValueST(Cfg.skillRatioLa, slFmt)
    endEvent
EndState

State SL_1H
    Event OnSliderOpenST()
        CreateSkillSliderPhys(Cfg.skillRatio1H)
    EndEvent

    event OnSliderAcceptST(float val)
        Cfg.skillRatio1H =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        Cfg.skillRatio1H = Cfg.skillDefault1H
        SetSliderOptionValueST(Cfg.skillRatio1H, slFmt)
    endEvent
EndState

State SL_SN
    Event OnSliderOpenST()
        CreateSkillSliderPhys(Cfg.skillRatioSn)
    EndEvent

    event OnSliderAcceptST(float val)
        Cfg.skillRatioSn =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        Cfg.skillRatioSn = Cfg.skillDefaultSn
        SetSliderOptionValueST(Cfg.skillRatioSn, slFmt)
    endEvent
EndState

State SL_SM
    Event OnSliderOpenST()
        CreateSkillSliderPhys(Cfg.skillRatioSm)
    EndEvent

    event OnSliderAcceptST(float val)
        Cfg.skillRatioSm =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        Cfg.skillRatioSm = Cfg.skillDefaultSm
        SetSliderOptionValueST(Cfg.skillRatioSm, slFmt)
    endEvent
EndState

State SL_2H
    Event OnSliderOpenST()
        CreateSkillSliderPhys(Cfg.skillRatio2H)
    EndEvent

    event OnSliderAcceptST(float val)
        Cfg.skillRatio2H =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        Cfg.skillRatio2H = Cfg.skillDefault2H
        SetSliderOptionValueST(Cfg.skillRatio2H, slFmt)
    endEvent
EndState

State SL_AL
    Event OnSliderOpenST()
        CreateSkillSliderMag(Cfg.skillRatioAl)
    EndEvent

    event OnSliderAcceptST(float val)
        Cfg.skillRatioAl =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        Cfg.skillRatioAl = Cfg.skillDefaultAl
        SetSliderOptionValueST(Cfg.skillRatioAl, slFmt)
    endEvent
EndState

State SL_CO
    Event OnSliderOpenST()
        CreateSkillSliderMag(Cfg.skillRatioCo)
    EndEvent

    event OnSliderAcceptST(float val)
        Cfg.skillRatioCo =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        Cfg.skillRatioCo = Cfg.skillDefaultCo
        SetSliderOptionValueST(Cfg.skillRatioCo, slFmt)
    endEvent
EndState

State SL_DE
    Event OnSliderOpenST()
        CreateSkillSliderMag(Cfg.skillRatioDe)
    EndEvent

    event OnSliderAcceptST(float val)
        Cfg.skillRatioDe =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        Cfg.skillRatioDe = Cfg.skillDefaultDe
        SetSliderOptionValueST(Cfg.skillRatioDe, slFmt)
    endEvent
EndState

State SL_IL
    Event OnSliderOpenST()
        CreateSkillSliderMag(Cfg.skillRatioIl)
    EndEvent

    event OnSliderAcceptST(float val)
        Cfg.skillRatioIl =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        Cfg.skillRatioIl = Cfg.skillDefaultIl
        SetSliderOptionValueST(Cfg.skillRatioIl, slFmt)
    endEvent
EndState

State SL_RE
    Event OnSliderOpenST()
        CreateSkillSliderMag(Cfg.skillRatioRe)
    EndEvent

    event OnSliderAcceptST(float val)
        Cfg.skillRatioRe =  val
        SetSliderOptionValueST(val, slFmt)
    endEvent

    event OnDefaultST()
        Cfg.skillRatioRe = Cfg.skillDefaultRe
        SetSliderOptionValueST(Cfg.skillRatioRe, slFmt)
    endEvent
EndState

State SL_FP
    Event OnSliderOpenST()
        CreateFatigueSlider(Cfg.physFatigueRate)
    EndEvent

    Event OnSliderAcceptST(float val)
        Cfg.physFatigueRate =  PercentToFloat(val)
        SetSliderOptionValueST(val, xslFmt)
    EndEvent

    Event OnDefaultST()
        Cfg.physFatigueRate = PercentToFloat(10)
        SetSliderOptionValueST(10, xslFmt)
    EndEvent

    Event OnHighlightST()
        float sk = Cfg.skillRatioRe
        float mr = Cfg.magFatigueRateMultiplier
        float r = Cfg.physFatigueRate * mr
        float rr = FloatToPercent(sk * r)
        string s = "$MCM_SlWGPMultInfo{" + FloatToStr(mr, 1) + "}{" + FloatToStr(rr) + "}"
        SetInfoText(s)
    EndEvent
EndState
