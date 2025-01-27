@echo off & setlocal
mode con cols=125 lines=57
set VERSION=0.65.3 beta
TITLE DDVT OPTIONS [QfG] v%VERSION%

rem --- Hardcoded settings. Can be changed manually ---
set "sfkpath=%~dp0tools\sfk.exe" rem Path to sfk.exe

rem --- Hardcoded settings. Cannot be changed ---
set "TMP_FOLDER=SAME AS SOURCE"
set "TARGET_FOLDER=SAME AS SOURCE"
set "MKVTOOLNIX_FOLDER=INCLUDED"
set "TOOLFOLDER=%~dp0"
set "AVISYNTH_FOLDER=%ProgramFiles(x86)%\AviSynth+"
set "LAVFILTERS_FOLDER=%ProgramFiles(x86)%\LAV Filters"
set "MEDIAINFO_LOGFILE=YES"
set "JSON_SUPPORT=YES"
set "JSON_PROCESS=FIRST"
set "FIX_SCENECUTS=YES"

setlocal EnableDelayedExpansion

set "NewLine=[System.Environment]::NewLine"
set "Line1=Start the script with ADMINISTRATOR permissions to activate/deactivate the Windows SHELL EXTENSIONS. Without ADMINISTRATOR permissions you have insufficent rights changing Windows registry^!"
START /MIN PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('!Line1!', 'DDVT OPTIONS [QfG] %VERSION%', 'Ok','Info')"

set "WAIT="!sfkpath!" sleep"
set "GREEN="!sfkpath!" color green"
set "RED="!sfkpath!" color red"
set "YELLOW="!sfkpath!" color yellow"
set "WHITE="!sfkpath!" color white"
set "CYAN="!sfkpath!" color cyan"
set "MAGENTA="!sfkpath!" color magenta"
set "GREY="!sfkpath!" color grey"

::Check for INI and Load Settings
IF EXIST "!TOOLFOLDER!DDVT_OPTIONS.ini" (
	FOR /F "delims=" %%A IN ('findstr /C:"TEMP Folder=" "%~dp0DDVT_OPTIONS.ini"') DO (
		set "TMP_FOLDER=%%A"
		set "TMP_FOLDER=!TMP_FOLDER:~12!"
	)
	FOR /F "delims=" %%A IN ('findstr /C:"TARGET Folder=" "%~dp0DDVT_OPTIONS.ini"') DO (
		set "TARGET_FOLDER=%%A"
		set "TARGET_FOLDER=!TARGET_FOLDER:~14!"
	)
	FOR /F "delims=" %%A IN ('findstr /C:"MKVTOOLNIX Folder=" "%~dp0DDVT_OPTIONS.ini"') DO (
		set "MKVTOOLNIX_FOLDER=%%A"
		set "MKVTOOLNIX_FOLDER=!MKVTOOLNIX_FOLDER:~18!"
	)
	FOR /F "delims=" %%A IN ('findstr /C:"AVISYNTH+ Folder=" "%~dp0DDVT_OPTIONS.ini"') DO (
		set "AVISYNTH_FOLDER=%%A"
		set "AVISYNTH_FOLDER=!AVISYNTH_FOLDER:~17!"
	)
	FOR /F "delims=" %%A IN ('findstr /C:"LAVFILTERS Folder=" "%~dp0DDVT_OPTIONS.ini"') DO (
		set "LAVFILTERS_FOLDER=%%A"
		set "LAVFILTERS_FOLDER=!LAVFILTERS_FOLDER:~18!"
	)
	FOR /F "delims=" %%A IN ('findstr /C:"MEDIAINFO_LOGFILE=" "%~dp0DDVT_OPTIONS.ini"') DO (
		set "MEDIAINFO_LOGFILE=%%A"
		set "MEDIAINFO_LOGFILE=!MEDIAINFO_LOGFILE:~18!"
	)
	FOR /F "delims=" %%A IN ('findstr /C:"JSON_SUPPORT=" "%~dp0DDVT_OPTIONS.ini"') DO (
		set "JSON_SUPPORT=%%A"
		echo "!JSON_SUPPORT!"
		set "JSON_SUPPORT=!JSON_SUPPORT:~13!"
	)
	FOR /F "delims=" %%A IN ('findstr /C:"JSON_PROCESS=" "%~dp0DDVT_OPTIONS.ini"') DO (
		set "JSON_PROCESS=%%A"
		set "JSON_PROCESS=!JSON_PROCESS:~13!"
	)
	FOR /F "delims=" %%A IN ('findstr /C:"FIX_SCENECUTS=" "%~dp0DDVT_OPTIONS.ini"') DO (
		set "FIX_SCENECUTS=%%A"
		set "FIX_SCENECUTS=!FIX_SCENECUTS:~14!"
	)
)

:MAINMENU
if "!JSON_SUPPORT!"=="NO" set "JSON_PROCESS=DISABLED"
if "!FIX_SCENECUTS!" NEQ "YES" (
	set "COL_FIX_SCENECUTS=08"
) else (
	set "COL_FIX_SCENECUTS=0A"
)
if "!MEDIAINFO_LOGFILE!" NEQ "YES" (
	set "COL_MEDIAINFO_LOGFILE=08"
) else (
	set "COL_MEDIAINFO_LOGFILE=0A"
)
if "!JSON_SUPPORT!" NEQ "YES" (
	set "COL_JSON_SUPPORT=08"
) else (
	set "COL_JSON_SUPPORT=0A"
)
if "!JSON_PROCESS!"=="DISABLED" (
	set "COL_JSON_PROCESS=08"
) else (
	set "COL_JSON_PROCESS=0A"
)
if "!TMP_FOLDER!"=="" set "TMP_FOLDER=SAME AS SOURCE"
if "!TARGET_FOLDER!"=="" set "TARGET_FOLDER=SAME AS SOURCE"
set "TMP_FOLDER_STRING=!TMP_FOLDER!\DDVT_<CODE>_TMP"
set "TARGET_FOLDER_STRING=!TARGET_FOLDER!\<FILENAME>_[<SCRIPTNAME>]"
set "MKVTOOLNIX_FOLDER_STRING=!MKVTOOLNIX_FOLDER!"
if "!TMP_FOLDER!"=="SAME AS SOURCE" set "TMP_FOLDER_STRING=<SOURCEDIR>\DDVT_<CODE>_TMP"
if "!TARGET_FOLDER!"=="SAME AS SOURCE" set "TARGET_FOLDER_STRING=<SOURCEDIR>\<FILENAME>_[<SCRIPTNAME>]"
if "!MKVTOOLNIX_FOLDER!"=="INCLUDED" (
	set "MKVTOOLNIX_FOLDER_STRING=<TOOLDIR>\tools"
	set "MKVTOOLNIX_REAL_FOLDER=!TOOLFOLDER!tools"
) else (
	set "MKVTOOLNIX_REAL_FOLDER=!MKVTOOLNIX_FOLDER!"
)
if exist "!MKVTOOLNIX_REAL_FOLDER!\mkvextract.exe" (
	set "MKVTOOLNIX_STAT=call :colortxt 0A "OK""
) else (
	set "MKVTOOLNIX_STAT=call :colortxt 0C "FAILED""
)
if exist "!AVISYNTH_FOLDER!\plugins+\DirectShowSource.dll" (
	set "AVISYNTH_STAT=call :colortxt 0A "OK""
) else (
	set "AVISYNTH_STAT=call :colortxt 0C "FAILED""
)
if exist "!LAVFILTERS_FOLDER!\x64\LAVSplitter.ax" (
	set "LAVFILTER_STAT=call :colortxt 0A "OK""
) else (
	set "LAVFILTER_STAT=call :colortxt 0C "FAILED""
)
cls
%GREEN%
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool OPTIONS
%WHITE%
echo                                         ====================================
echo.
%WHITE%
echo.
echo.
echo  == FOLDERS =============================================================================================================
echo.
%CYAN%
echo TEMP FOLDER        = !TMP_FOLDER_STRING!
echo OUTPUT FOLDER      = !TARGET_FOLDER_STRING!
call :colortxt 0B "MKVTOOLNIX FOLDER  = !MKVTOOLNIX_FOLDER_STRING! [" & !MKVTOOLNIX_STAT! & call :colortxt 0B "]" /n
call :colortxt 0B "AVISYNTH+ FOLDER   = !AVISYNTH_FOLDER! [" & !AVISYNTH_STAT! & call :colortxt 0B "]" /n
call :colortxt 0B "LAV Filters FOLDER = !LAVFILTERS_FOLDER! [" & !LAVFILTER_STAT! & call :colortxt 0B "]" /n
echo.
%WHITE%
echo  == OPTIONS MENU ========================================================================================================
echo.
%GREEN%
echo 1. Set TEMP Directory
echo 2. Set OUTPUT Directory
echo 3. Set MKVTOOLNIX Directory 
echo 4. Set AVISYNTH+ Directory    [Also you can install AVISYNTH+ via this switch]
echo 5. Set LAV Filters Directory  [Also you can install LAV Filters via this switch]
%WHITE%
echo.
call :colortxt 0F "M. MediaInfo Logfile [" & call :colortxt !COL_MEDIAINFO_LOGFILE! "!MEDIAINFO_LOGFILE!" & call :colortxt 0F "]" /n
call :colortxt 0F "C. Injector Custom Edit Support [" & call :colortxt !COL_JSON_SUPPORT! "!JSON_SUPPORT!" & call :colortxt 0F "]" /n
call :colortxt 0F "P. Injector Custom Edit Processing [" & call :colortxt !COL_JSON_PROCESS! "!JSON_PROCESS!" & call :colortxt 0F "]" /n
call :colortxt 0F "F. Fix Scenecut Flags [" & call :colortxt !COL_FIX_SCENECUTS! "!FIX_SCENECUTS!" & call :colortxt 0F "]" /n
echo.
echo 6. Create Shell Extensions
echo 7. Delete Shell Extensions
echo.
%GREEN%
echo S. SAVE SETTINGS
%WHITE%
echo E. Exit
echo.
%GREEN%
echo Change Settings or press [E] to Exit^^!
CHOICE /C 12345MCPF67SE /N /M "Select a Letter 1,2,3,4,5,M,C,P,F,6,7,[S]ave,[E]xit"

if "%ERRORLEVEL%"=="13" goto EXIT
if "%ERRORLEVEL%"=="12" (
	(
	echo :: INI File for DDVT. Do not modify, using DDVT_OPTIONS.cmd.
	echo.
	echo --------------------------
	echo TEMP Folder=!TMP_FOLDER!
	echo TARGET Folder=!TARGET_FOLDER!
	echo MKVTOOLNIX Folder=!MKVTOOLNIX_FOLDER!
	echo AVISYNTH+ Folder=!AVISYNTH_FOLDER!
	echo LAVFILTERS Folder=!LAVFILTERS_FOLDER!
	echo MEDIAINFO_LOGFILE=!MEDIAINFO_LOGFILE!
	echo JSON_SUPPORT=!JSON_SUPPORT!
	echo JSON_PROCESS=!JSON_PROCESS!
	echo FIX_SCENECUTS=!FIX_SCENECUTS!
	echo --------------------------
	)>"!TOOLFOLDER!DDVT_OPTIONS.ini"
	echo.
	%GREEN%
	echo Settings Saved.
	%WAIT% 1000
)
if "%ERRORLEVEL%"=="11" (
	reg delete "HKCR\*\Shell\DDVT Demuxer" /f>nul 2>&1
	reg delete "HKCR\*\Shell\DDVT Injector" /f>nul 2>&1
	reg delete "HKCR\*\Shell\MenuDDVT" /f>nul 2>&1
	reg delete "HKLM\Software\Classes\Directory\Background\Shell\MenuDDVT" /f>nul 2>&1
	reg delete "HKCU\Software\Classes\*\Shell\QFG_DVFINDER" /f>nul 2>&1
	reg delete "HKCU\Software\Classes\*\Shell\DDVT QUICKINFO" /f>nul 2>&1
	reg delete "HKCU\Software\Classes\*\Shell\DDVT MEDIAINFO" /f>nul 2>&1
	reg delete "HKCU\Software\Classes\Directory\shell\05MKVTOMP4" /f>nul 2>&1
	echo.
	%GREEN%
	echo Registry strings deleted.
	%WAIT% 1000
)
if "%ERRORLEVEL%"=="10" (
	reg delete "HKCR\*\Shell\DDVT Demuxer" /f>nul 2>&1
	reg delete "HKCR\*\Shell\DDVT Injector" /f>nul 2>&1
	reg delete "HKCR\*\Shell\MenuDDVT" /f>nul 2>&1
	reg delete "HKLM\Software\Classes\Directory\Background\Shell\MenuDDVT" /f>nul 2>&1
	reg delete "HKCU\Software\Classes\*\Shell\QFG_DVFINDER" /f>nul 2>&1
	reg delete "HKCU\Software\Classes\*\Shell\DDVT QUICKINFO" /f>nul 2>&1
	reg delete "HKCU\Software\Classes\*\Shell\DDVT MEDIAINFO" /f>nul 2>&1
	reg delete "HKCU\Software\Classes\Directory\shell\05MKVTOMP4" /f>nul 2>&1
	reg add "HKCU\Software\Classes\Directory\shell\05MKVTOMP4" /ve /d "Convert MKVs to MP4 in Folder" /f>nul 2>&1
	reg add "HKCU\Software\Classes\Directory\shell\05MKVTOMP4" /v "Icon" /t REG_SZ /d "\"!TOOLFOLDER!tools\ICONS\MKVTOMP4.ico\",0" /f>nul 2>&1
	reg add "HKCU\Software\Classes\Directory\shell\05MKVTOMP4" /v "Position" /t REG_SZ /d "Top" /f>nul 2>&1
	reg add "HKCU\Software\Classes\Directory\shell\05MKVTOMP4\command" /ve /d "\"!TOOLFOLDER!DDVT_MKVTOMP4.cmd\" ""%%1""" /f>nul 2>&1
	reg add "HKCU\Software\Classes\*\Shell\DDVT MEDIAINFO" /ve /d "DDVT MediaInfo" /f>nul 2>&1
	reg add "HKCU\Software\Classes\*\Shell\DDVT MEDIAINFO" /v "Icon" /t REG_SZ /d "\"!TOOLFOLDER!tools\ICONS\MEDIAINFO.ico\",0" /f>nul 2>&1
	reg add "HKCU\Software\Classes\*\Shell\DDVT MEDIAINFO" /v "Position" /t REG_SZ /d "Top" /f>nul 2>&1
	reg add "HKCU\Software\Classes\*\Shell\DDVT MEDIAINFO\command" /ve /d "\"!TOOLFOLDER!DDVT_MEDIAINFO.cmd\" ""%%1""" /f>nul 2>&1
	reg add "HKCU\Software\Classes\*\Shell\DDVT QUICKINFO" /ve /d "DDVT QuickInfo" /f>nul 2>&1
	reg add "HKCU\Software\Classes\*\Shell\DDVT QUICKINFO" /v "Icon" /t REG_SZ /d "\"!TOOLFOLDER!tools\ICONS\QUICKINFO.ico\",0" /f>nul 2>&1
	reg add "HKCU\Software\Classes\*\Shell\DDVT QUICKINFO" /v "Position" /t REG_SZ /d "Top" /f>nul 2>&1
	reg add "HKCU\Software\Classes\*\Shell\DDVT QUICKINFO\command" /ve /d "\"!TOOLFOLDER!DDVT_MEDIAINFO.cmd\" ""%%1\"" -MSGBOX" /f>nul 2>&1
	if "!ERRORLEVEL!"=="1" reg add "HKCU\Software\Classes\*\Shell\DDVT QUICKINFO\command" /ve /d "\"!TOOLFOLDER!DDVT_MEDIAINFO.cmd\" ""%%1"" -MSGBOX" /f>nul 2>&1
	reg add "HKLM\Software\Classes\Directory\Background\Shell\MenuDDVT" /ve /d "DDVT" /f>nul 2>&1
	reg add "HKLM\Software\Classes\Directory\Background\Shell\MenuDDVT" /v "Icon" /t REG_SZ /d "\"!TOOLFOLDER!tools\ICONS\DDVT.ico\",0" /f>nul 2>&1
	reg add "HKLM\Software\Classes\Directory\Background\Shell\MenuDDVT" /v "ExtendedSubCommandsKey" /t REG_SZ /d "\"!TOOLFOLDER!tools\ICONS\DDVT.ico\",0" /f>nul 2>&1
	reg add "HKLM\Software\Classes\Directory\Background\Shell\MenuDDVT" /v "ExtendedSubCommandsKey" /t REG_SZ /d "Directory\Background\Shell\MenuDDVT\ContextMenu" /f>nul 2>&1
	reg add "HKLM\Software\Classes\Directory\Background\Shell\MenuDDVT" /v "Position" /t REG_SZ /d "Top" /f>nul 2>&1
	reg add "HKLM\Software\Classes\Directory\Background\Shell\MenuDDVT\ContextMenu\shell\01HYBRID" /ve /d "Profile 8 Hybrid" /f>nul 2>&1
	reg add "HKLM\Software\Classes\Directory\Background\Shell\MenuDDVT\ContextMenu\shell\01HYBRID" /v "Icon" /t REG_SZ /d "\"!TOOLFOLDER!tools\ICONS\HYBRID.ico\",0" /f>nul 2>&1
	reg add "HKLM\Software\Classes\Directory\Background\Shell\MenuDDVT\ContextMenu\shell\01HYBRID\command" /ve /d "\"!TOOLFOLDER!DDVT_HYBRID.cmd\" " /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT" /ve /d "DDVT" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT" /v "Icon" /t REG_SZ /d "\"!TOOLFOLDER!tools\ICONS\DDVT.ico\",0" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT" /v "ExtendedSubCommandsKey" /t REG_SZ /d "\"!TOOLFOLDER!tools\ICONS\DDVT.ico\",0" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT" /v "ExtendedSubCommandsKey" /t REG_SZ /d "*\Shell\MenuDDVT\ContextMenu" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT" /v "Position" /t REG_SZ /d "Top" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\01DEMUXER" /ve /d "Demuxer" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\01DEMUXER" /v "Icon" /t REG_SZ /d "\"!TOOLFOLDER!tools\ICONS\DEMUXER.ico\",0" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\01DEMUXER\command" /ve /d "\"!TOOLFOLDER!DDVT_DEMUXER.cmd\" ""%%1""" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\02INJECTOR" /ve /d "Injector" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\02INJECTOR" /v "Icon" /t REG_SZ /d "\"!TOOLFOLDER!tools\ICONS\INJECTOR.ico\",0" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\02INJECTOR\command" /ve /d "\"!TOOLFOLDER!DDVT_INJECTOR.cmd\" ""%%1""" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\03HYBRID" /ve /d "Profile 8 Hybrid" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\03HYBRID" /v "Icon" /t REG_SZ /d "\"!TOOLFOLDER!tools\ICONS\HYBRID.ico\",0" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\03HYBRID\command" /ve /d "\"!TOOLFOLDER!DDVT_HYBRID.cmd\" ""%%1""" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\04REMOVER" /ve /d "Remover" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\04REMOVER" /v "Icon" /t REG_SZ /d "\"!TOOLFOLDER!tools\ICONS\REMOVER.ico\",0" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\04REMOVER\command" /ve /d "\"!TOOLFOLDER!DDVT_REMOVER.cmd\" ""%%1""" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\05FILEINFO" /ve /d "FileInfo" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\05FILEINFO" /v "Icon" /t REG_SZ /d "\"!TOOLFOLDER!tools\ICONS\QUICKINFO.ico\",0" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\05FILEINFO\command" /ve /d "\"!TOOLFOLDER!DDVT_FILEINFO.cmd\" ""%%1""" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\06FILECHECK" /ve /d "SyncCheck" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\06FILECHECK" /v "Icon" /t REG_SZ /d "\"!TOOLFOLDER!tools\ICONS\SYNCCHECK.ico\",0" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\06FILECHECK\command" /ve /d "\"!TOOLFOLDER!DDVT_FILEINFO.cmd\" ""%%1\"" -CHECK" /f>nul 2>&1
	if "!ERRORLEVEL!"=="1" reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\06FILECHECK\command" /ve /d "\"!TOOLFOLDER!DDVT_FILEINFO.cmd\" ""%%1"" -CHECK" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\07MKVTOMP4" /ve /d "MKV to MP4" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\07MKVTOMP4" /v "Icon" /t REG_SZ /d "\"!TOOLFOLDER!tools\ICONS\MKVTOMP4.ico\",0" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\07MKVTOMP4\command" /ve /d "\"!TOOLFOLDER!DDVT_MKVTOMP4.cmd\" ""%%1""" /f>nul 2>&1
	if exist "!TOOLFOLDER!DDVT_GENERATOR.cmd" reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\08GENERATE" /ve /d "RPU Generator" /f>nul 2>&1
	if exist "!TOOLFOLDER!DDVT_GENERATOR.cmd" reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\08GENERATE" /v "Icon" /t REG_SZ /d "\"!TOOLFOLDER!tools\ICONS\GENERATOR.ico\",0" /f>nul 2>&1
	if exist "!TOOLFOLDER!DDVT_GENERATOR.cmd" reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\08GENERATE\command" /ve /d "\"!TOOLFOLDER!DDVT_GENERATOR.cmd\" ""%%1""" /f>nul 2>&1
	echo.
	%GREEN%	
	echo Registry strings set.
	%WAIT% 1000
)
if "%ERRORLEVEL%"=="9" (
	if "%FIX_SCENECUTS%"=="YES" set "FIX_SCENECUTS=NO"
	if "%FIX_SCENECUTS%"=="NO" set "FIX_SCENECUTS=YES"
)
if "%ERRORLEVEL%"=="8" (
	if "%JSON_PROCESS%"=="FIRST" set "JSON_PROCESS=LAST"
	if "%JSON_PROCESS%"=="LAST" set "JSON_PROCESS=FIRST"
)
if "%ERRORLEVEL%"=="7" (
	if "%JSON_SUPPORT%"=="YES" set "JSON_SUPPORT=NO" & set "JSON_PROCESS=DISABLED"
	if "%JSON_SUPPORT%"=="NO" set "JSON_SUPPORT=YES" & set "JSON_PROCESS=FIRST"
)
if "%ERRORLEVEL%"=="6" (
	if "%MEDIAINFO_LOGFILE%"=="YES" set "MEDIAINFO_LOGFILE=NO"
	if "%MEDIAINFO_LOGFILE%"=="NO" set "MEDIAINFO_LOGFILE=YES"
)
if "%ERRORLEVEL%"=="5" (
	%YELLOW%
	echo.
	echo If you must install LAV Filters leave blank and hit [ENTER]^ for installing^^!
	echo Don't forget to [S]AVE your settings after editing^^!
	%WHITE%
	set /p "LAVFILTERS_FOLDER=:>" || "!TOOLFOLDER!tools\Install\LAVFilters-0.79.2-Installer.exe"
	goto MAINMENU
)
if "%ERRORLEVEL%"=="4" (
	%YELLOW%
	echo.
	echo If you must install AVISYNTH+ leave blank and hit [ENTER]^ for installing^^!
	echo Don't forget to [S]AVE your settings after editing^^!
	%WHITE%
	set /p "AVISYNTH_FOLDER=:>" || "!TOOLFOLDER!tools\Install\AviSynthPlus_3.7.3_20230715.exe"
	goto MAINMENU
)
if "%ERRORLEVEL%"=="3" (
	%YELLOW%
	echo.
	echo If you will use the INCLUDED MKVTOOLNIX SET leave blank an press [ENTER]^^!
	echo Don't forget to [S]AVE your settings after editing^^!
	%WHITE%
	set /p "MKVTOOLNIX_FOLDER=:>" || SET "MKVTOOLNIX_FOLDER=INCLUDED"
)
if "%ERRORLEVEL%"=="2" (
	%YELLOW%
	echo.
	echo If you will use the STANDARD SOURCE folder leave blank an press [ENTER]^^!
	echo Don't forget to [S]AVE your settings after editing^^!
	%WHITE%
	set /p "TARGET_FOLDER=Type in your OUTPUT Folder and press [ENTER]:" || SET "TARGET_FOLDER=SAME AS SOURCE"
)
if "%ERRORLEVEL%"=="1" (
	%YELLOW%
	echo.
	echo If you will use the STANDARD TEMP folder leave blank an press [ENTER]^^!
	echo Don't forget to [S]AVE your settings after editing^^!
	%WHITE%
	set /p "TMP_FOLDER=Type in your TEMP Folder and press [ENTER]:" || SET "TMP_FOLDER=SAME AS SOURCE"
)
goto MAINMENU

:colortxt
setlocal enableDelayedExpansion
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:colorPrint Color  Str  [/n]
setlocal
set "s=%~2"
call :colorPrintVar %1 s %3
exit /b

:colorPrintVar  Color  StrVar  [/n]
if not defined DEL call :initColorPrint
setlocal enableDelayedExpansion
pushd .
':
cd \
set "s=!%~2!"
:: The single blank line within the following IN() clause is critical - DO NOT REMOVE
for %%n in (^"^

^") do (
  set "s=!s:\=%%~n\%%~n!"
  set "s=!s:/=%%~n/%%~n!"
  set "s=!s::=%%~n:%%~n!"
)
for /f delims^=^ eol^= %%s in ("!s!") do (
  if "!" equ "" setlocal disableDelayedExpansion
  if %%s==\ (
    findstr /a:%~1 "." "\'" nul
    <nul set /p "=%DEL%%DEL%%DEL%"
  ) else if %%s==/ (
    findstr /a:%~1 "." "/.\'" nul
    <nul set /p "=%DEL%%DEL%%DEL%%DEL%%DEL%"
  ) else (
    >colorPrint.txt (echo %%s\..\')
    findstr /a:%~1 /f:colorPrint.txt "."
    <nul set /p "=%DEL%%DEL%%DEL%%DEL%%DEL%%DEL%%DEL%"
  )
)
if /i "%~3"=="/n" echo(
popd
exit /b


:initColorPrint
for /f %%A in ('"prompt $H&for %%B in (1) do rem"') do set "DEL=%%A %%A"
<nul >"%temp%\'" set /p "=."
subst ': "%temp%" >nul
exit /b


:cleanupColorPrint
2>nul del "%temp%\'"
2>nul del "%temp%\colorPrint.txt"
>nul subst ': /d
exit /b

:EXIT
%WHITE%
setlocal DisableDelayedExpansion
ENDLOCAL
echo.
echo  == EXIT ================================================================================================================
echo.
exit