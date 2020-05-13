:: This script was made to automatically include library files needed
:: by this mod.
:: Download library https://github.com/CarlosLeyvaAyala/DM-SkyrimSE-Library.git

ECHO OFF

:: Setting up needed variables
SET zipExe="C:\Program Files\7-Zip\7z"
SET modName="Sandow Plus Plus"
SET ModVersion=3.2
SET lib="D:\Skyrim SE\MO2\mods\DM-SkyrimSE-Library\scripts"
SET backupDir="_ignore\_backups"
SET modEsp="SandowPP.esp"

:: External libraries required by this mod
SET req1="DM_Utils.pex"
SET req2="DM_MeterWidgetScript.pex"

:: Files needed to compile, but not distributable
SET exc1="SKI_WidgetManager.pex"
SET exc2="SKI_WidgetBase.pex"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Create file
%zipExe% d %modName%.7z
%zipExe% a -t7z %modName%.7z interface scripts %modEsp% %lib%\%req1% %lib%\%req2%

:: Put libraries in the correct folder
%zipExe% rn %modName%.7z %req1% scripts\%req1% %req2% scripts\%req2%

:: Delete uneeded files
%zipExe% d %modName%.7z scripts\source %exc1% %exc2% -r

:::::::::::::::::::::::::::::::::::::::::::::::::::
:: Copy backup
copy %modName%.7z %backupDir%\%modName%" "%ModVersion%.7z
PAUSE