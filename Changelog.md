V4.0
========================
***MAJOR VERSION MEANS NEW GAME***. Sorry.

This may be the biggest release yet.\
Not only it adds too much new functionality, but I also basically rewrote all what I could in Lua.

## New requirements (NON OPTIONAL)
* ***JContainers***.\
This mod was rewritten in Lua and **NEEDS JContainers to work**.

* ***PapyrusUtil***\
It's required for all the new features related to being ripped.

* ***Racemenu*** (or at least, `NiOverride`)\
**IT'S REQUIRED** for all the new features related to being ripped. __No need to have it if you don't want to use my *"getting ripped"* features__, though.

* You will need ***some textures to look ripped***.\
May I suggest, *cough*, the ones I got permission to distribute/modify?

## Features dropped
* ***All report methods***, except Widget.

* ***FISS and PapyrusUtil support for saving presets***. Please re-save all your presets.\
    Since JContainers became a hard requirement, there's no need to develop and mantain all those options to save/load files.

## New features
* `Bruce Lee behavior`.\
You can now get ripped without gaining weight.

* `Bulk & Cut Behavior`.\
For each number of **SLEEPING SESSIONS** passed (MCM configurable), this mod will automatically swap behaviors; from gaining weight (bulking) to gaining muscle definition (cutting).\
Now you can start thin and flaccid and become muscular and ripped by training... or being muscular and flaccid, whatever floats your boat.

* Added ***options for getting ripped*** in a more straight forward way.\
These options can be used with weight gaining behaviors. What makes these options different than the Bruce Lee behavior is that behavior has complex rules to getting ripped and you can also lose muscle definition.

    ### ***WARNING***
    The method I used for getting ripped with scripts may be incompatible with some mods that also change textures programatically on people. There's simply no way around that; trust me, I tried.

    For a non scripted way to getting ripped, please check out my [Ripped Bodies mod](https://www.nexusmods.com/skyrimspecialedition/mods/34632).

* ***Named presets***.\
    You can now have an arbitrary number of presets and name them as you wish.

* ***Sexlab integration***.\
    Nothing too fancy. It just considers sex scenes as physical activity, so you won't lose your gains by inactivity.\
    **Having sex won't make you muscular or ripped**, since it's not physical training.

    ... and before you ask me to count it as training because *"muh immersion"*, I'll give you a low blow by telling you that **you must be really unfit if sex is physically draining to you** (ouch).

* This mod has gotten so big (thank you all for your suggestions!) it now needs a proper ***User Manual***, so I made a PDF file just for that.


## Major changes
* `Weight Gain Potential` got renamed to `Training`, like good ole Pumping Iron.\
    It was a needed change, since `WGP` doesn't make sense for the new muscle definition behaviors.

## Minor changes
* Reworked and (hopefully) less cluttered MCM.

* `Weight gain rate` can now be set up to 300% (formerly 200%), because of the new `Bulk & Cut Behavior`.\
Without this new multiplier, getting muscular and ripped by training would take too much time.

* More options to adjust the Widget's appearance.

## Minor fixes
* Adjusted `Diminishing Returns` formula. It's mostly the same, but prettier.

* Did you know sedentary juicers gain more weight than hard training naturals? Weight gain multipliers were adjusted to show that fact.


V3.1
========================
## New features
* Added the `- Paused - Behavior`.\
When selected, there won't be changes in your Weight or `WGP`. Inactivity won't be tracked, as well.

* Added an ***option to change your head size based on Weight***. No more ill proportioned heads!

* Added an ***option to change your Weight gaining rate***. This means going from 0% to 100% could take you more or less time.

## Minor fixes
* Fixed (at last) a bug that made the inactivity bar permanent when switching Report managers.

V3.0
========================
## New features
* ***Weight sacks*** (Small, Medium and Large sizes) added under miscellaneous items, so non-warrior characters can get proper training too.

* ***Optional silly fun items*** like *Mammoth Whey*, *Troll creatine* and *Vitamin T*, because why the hell not?

* New items won't appear in vendors lists and chests ***until you add them from the MCM***.\
    They appear randomly, as many other items. Have patience.

## Major fixes
* Upgrading to 3.0 requires a new game.

    Turns out `V2.1.x` was corrupted and could lead to CTDs and other nasty things.
    I know: what a mess... I'm quite unhappy too.

    Let's pretend `V2.1` never happened, no? :)

## Minor fixes
* WGP gains and losses are now properly reported by the widget. Its bar now flashes to tell you what happened.

## Future development path
* Hunger affects your gains.

V2.1
========================
## New features
* Option to use an ***UI widget*** to know your status.

## Minor fixes
* In the Sandow Plus Plus Behavior you could lose Weight by inactivity and then gain Weight by training when sleeping. This was a baffling behavior, so now you won't gain Weight if you ever lose some in that particular sleeping sesion.\
        Beware: fatige and inactivity losses both apply for a single sleeping sesion.

* Fixed text errors and formatting in the MCM (yet again...).


V2.0.1
========================
## Fixes
* Height gained got lost when closing the game. Fixed that.
* Fixed some minor text errors in the MCM (does THIS ever end?).

V2.0
========================
## New features
* ***Support for "behaviors"***.\
    The new implementation lets me easily change the rules for gaining/losing weight on the fly, so you can now play like if you had installed a completely different mod just by selecting some option in the MCM.

* ***Translation support addded***.\
    I can't translate this mod to every supported language. Maybe you can help me? :)\
    Idioma español agregado por mí mismo. No juego Skyrim en español, así que tu ayuda para ajustar mi traducción es bienvenida.

* When running for the first time, this mod automatically loads Preset #1 (if it exists). Useful when you create a new character and don't want to go and setup everything once again.\
    Now you have even less reasons to use the MCM once you setup this mod to your liking.

* Can now show colored notifications thanks to SkyUILib.

* FISS added to preset managers, so you can now save/load presets if you don't have PapyrusUtil.

* You can now lose weight by inactivity.

# Major improvements
* ***Refactored and reimplemented code***.\
    Unfortunately, changes made by this new implementation makes previous version incompatible (sorry), but now this mod should be more compatible with future versions and new features should be easier to add in the future.

* Resources packed as BSA, since now there are too many of them.

* I included the source code in the BSA so you can learn from it if you want. Maybe some day you will inherit and take care of this mod?

## Minor improvements
* Added a little supercompensation after weight rebound, for better simulating how humans grow.

* Presets can now save and load hotkeys.

* Reworked MCM. Should be more intuitive to use.

* Logging and tracing, so it will be easier to find and fix problems.

## Minor fixes
* Fixed minor formating errors all around.

* Overall message formatting is now more consistent.

* Fixed a minor bug when calculating Fatigue once entering in Catabolic State. Now it should progress as it always should: reaaaaally low at first (expect to be at stuck at 100% fatigue for a few game hours), but alarmingly fast after a few hours.

* Fixed some minor calculation bugs.

* Fixed some MCM behavior.

## Experimental features
* Added a `Pumping Iron behavior`, so this mod will act exactly as Pumping Iron (timed sleeping sessions) whenever the player wants. Can go back to Sandow Plus Plus (fatigue management) whenever the player wants; no penalties, no downsides.\
    The Pumping Iron behavior benefits from all standard Sandow Plus Plus features (reports, hotkeys, weight gain for mages, losing weight...), so it effectively acts as a "Pumping Iron Remade" mod, or something.\
    This was added as a proof of concept to demonstrate the power of the new implementation. May be gone in the future if Gopher asks me to take it out (I asked him for permission, but got no answer).

* I can easily add more behaviors. If you have cool ideas on how weight should be gained/lost, I'd like to hear them.

* Option to gain height (requested by user *Loostreaks*), so you can now really go "from zero to hero".\
    I personally think this game wasn't really designed for changing Actor heights with scripts, but once again, I added this feature just to demonstrate the power of the new implementation.\
    Play with this at your own risk.

## Incompatibilities
* Completely incompatible with previous version.\
    Please make sure to delete all files starting with "DM_SandowPP" in your Data\Scripts\ folder.

* Old presets don't work with the new system. Please setup everything again.\
    Sorry for the inconvenience.
