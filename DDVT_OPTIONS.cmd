@echo off & setlocal
mode con cols=125 lines=57
set VERSION=0.71.1 "The Emperor protects"
set HEADER1=powered by quietvoids tools                                                                  GNU License (GPL) 2021-2025
TITLE DDVT OPTIONS v%VERSION%
set DESIGN=STANDARD

rem --- Hardcoded settings. Can be changed manually ---
set "Cecho=%~dp0tools\cecho_x64.exe" rem Path to cecho_x64.exe
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
	FOR /F "delims=" %%A IN ('findstr /C:"DESIGN=" "%~dp0DDVT_OPTIONS.ini"') DO (
		set "DESIGN=%%A"
		set "DESIGN=!DESIGN:~7!"
	)
)

:MAINMENU
set "HCWHITE="!sfkpath!" color white"
set "HCRED="!sfkpath!" color red"
set "HCGREEN="!sfkpath!" color green"
set "HCYELLOW="!sfkpath!" color yellow"
set "HC_WHITE=0F"
set "HC_RED=0C"
set "HC_GREEN=0A"
set "HC_YELLOW=0E"
set "GREY="!sfkpath!" color grey"
set "RED="!sfkpath!" color red"
set "GREEN="!sfkpath!" color green"
set "YELLOW="!sfkpath!" color yellow"
set "BLUE="!sfkpath!" color blue"
set "MAGENTA="!sfkpath!" color magenta"
set "CYAN="!sfkpath!" color cyan"
set "WHITE="!sfkpath!" color white"
set "_GREY=08"
set "_RED=0C"
set "_GREEN=0A"
set "_YELLOW=0E"
set "_BLUE=09"
set "_MAGENTA=0D"
set "_CYAN=0B"
set "_WHITE=0F"

if "!DESIGN!" NEQ "STANDARD" (
	call "!DESIGN!"
	for %%f in (!DESIGN!) do set "DESIGN_STRING=%%~nf">nul 2>&1
) else (
	set "DESIGN_STRING=STANDARD"
)

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
	set "MKVTOOLNIX_FOLDER_STRING=...\tools"
	set "MKVTOOLNIX_REAL_FOLDER=!TOOLFOLDER!tools"
) else (
	set "MKVTOOLNIX_REAL_FOLDER=!MKVTOOLNIX_FOLDER!"
)
if exist "!MKVTOOLNIX_REAL_FOLDER!\mkvextract.exe" (
	set "MKVTOOLNIX_STAT={%HC_GREEN%}OK"
) else (
	set "MKVTOOLNIX_STAT={%HC_RED%}FAILED"
)
if exist "!AVISYNTH_FOLDER!\plugins+\DirectShowSource.dll" (
	set "AVISYNTH_STAT={%HC_GREEN%}OK"
) else (
	set "AVISYNTH_STAT={%HC_RED%}FAILED"
)
if exist "!LAVFILTERS_FOLDER!\x64\LAVSplitter.ax" (
	set "LAVFILTER_STAT={%HC_GREEN%}OK"
) else (
	set "LAVFILTER_STAT={%HC_RED%}FAILED"
)
cls
%GREEN%
echo  %HEADER1%
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
"!Cecho!" {%_CYAN%}MKVTOOLNIX FOLDER  = !MKVTOOLNIX_FOLDER_STRING! [!MKVTOOLNIX_STAT!{%_CYAN%}]{#}{\n}
"!Cecho!" {%_CYAN%}AVISYNTH+ FOLDER   = !AVISYNTH_FOLDER! [!AVISYNTH_STAT!{%_CYAN%}]{#}{\n}
"!Cecho!" {%_CYAN%}LAV Filters FOLDER = !LAVFILTERS_FOLDER! [!LAVFILTER_STAT!{%_CYAN%}]{#}{\n}
echo.
%WHITE%
echo  == OPTIONS MENU ========================================================================================================
echo.
%CYAN%
echo 1. Set TEMP Directory
echo 2. Set OUTPUT Directory
echo 3. Set MKVTOOLNIX Directory
"!Cecho!" {%_CYAN%}4. Set AVISYNTH+ Directory    [{%HC_YELLOW%}Also you can install AVISYNTH+ via this switch{%_CYAN%}]{#}{\n}
"!Cecho!" {%_CYAN%}5. Set LAV Filters Directory  [{%HC_YELLOW%}Also you can install LAV Filters via this switch{%_CYAN%}]{#}{\n}
"!Cecho!" {%HC_WHITE%}M. MediaInfo Logfile [{%COL_MEDIAINFO_LOGFILE%}!MEDIAINFO_LOGFILE!{%HC_WHITE%}]{#}{\n}
"!Cecho!" {%HC_WHITE%}C. Injector Custom Edit Support [{%COL_JSON_SUPPORT%}!JSON_SUPPORT!{%HC_WHITE%}]{#}{\n}
"!Cecho!" {%HC_WHITE%}P. Injector Custom Edit Processing [{%COL_JSON_PROCESS%}!JSON_PROCESS!{%HC_WHITE%}]{#}{\n}
"!Cecho!" {%HC_WHITE%}F. Fix Scenecut Flags [{%COL_FIX_SCENECUTS%}!FIX_SCENECUTS!{%HC_WHITE%}]{#}{\n}
echo.
echo 6. Create Shell Extensions
echo 7. Delete Shell Extensions
echo.
"!Cecho!" {%HC_WHITE%}D. Design [{%HC_YELLOW%}!DESIGN_STRING!{%HC_WHITE%}]{#}{\n}
echo.
%GREEN%
echo S. SAVE SETTINGS
%HCWHITE%
echo E. Exit
echo.
echo Change Settings or press [E] to Exit^^!
CHOICE /C 12345MCPF67DSE /N /M "Select a Letter 1,2,3,4,5,M,C,P,F,6,7,D,[S]ave,[E]xit"

if "%ERRORLEVEL%"=="14" goto EXIT
if "%ERRORLEVEL%"=="13" (
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
	echo DESIGN=!DESIGN!
	echo --------------------------
	)>"!TOOLFOLDER!DDVT_OPTIONS.ini"
	echo.
	%HCGREEN%
	echo Settings Saved.
	TIMEOUT 2 /NOBREAK >nul
)
if "%ERRORLEVEL%"=="12" (
	echo.
	%HCYELLOW%
	echo [Info] Set own Design file here. Design sample files in ...\themes folder.
	echo        Leave blank and hit ENTER to use STANDARD Design.
	echo.
	echo        Design file MUST have one of the following extensions^:
	echo        bat^/cmd^ ^^!
	echo.
	%HCWHITE%
	echo.
	"!Cecho!" {%HC_WHITE%}Drag 'n' Drop {%_GREEN%}DESIGN File {%HC_WHITE%}here and press ENTER:{#}{\n}
	%GREEN%
	set /p "DESIGNINPUT=" || set "DESIGN=STANDARD"
	if "!DESIGNINPUT!" NEQ "STANDARD" for %%f in (!DESIGNINPUT!) do set "DESIGN=%%~dpnxf">nul 2>&1
)
if "%ERRORLEVEL%"=="11" (
	reg delete "HKCR\*\Shell\DDVT Demuxer" /f>nul 2>&1
	reg delete "HKCR\*\Shell\DDVT Injector" /f>nul 2>&1
	reg delete "HKCR\*\Shell\MenuDDVT" /f>nul 2>&1
	reg delete "HKCU\Software\Classes\Directory\shell\MenuDDVT" /f>nul 2>&1
	reg delete "HKCR\*\Shell\MenuDDVTDir" /f>nul 2>&1	
	reg delete "HKLM\Software\Classes\Directory\Background\Shell\MenuDDVT" /f>nul 2>&1
	reg delete "HKCU\Software\Classes\*\Shell\QFG_DVFINDER" /f>nul 2>&1
	reg delete "HKCU\Software\Classes\*\Shell\DDVT QUICKINFO" /f>nul 2>&1
	reg delete "HKCU\Software\Classes\*\Shell\DDVT MEDIAINFO" /f>nul 2>&1
	reg delete "HKCU\Software\Classes\Directory\shell\05MKVTOMP4" /f>nul 2>&1
	echo.
	reg query "HKCR\*\Shell\MenuDDVT" /v "Icon" >nul 2>&1
	if "!ERRORLEVEL!"=="1" (
		%HCGREEN%
		echo Registry strings deleted.
	) else (
		%HCRED%
		echo Registry strings not deleted. Permissions needed^^!
		set "NewLine=[System.Environment]::NewLine"
		set "Line1=REGISTRY STRINGS NOT DELETED^!"
		set "Line2=Start the script with ADMINISTRATOR permissions to activate/deactivate the Windows SHELL EXTENSIONS. Without ADMINISTRATOR permissions you have insufficent rights changing Windows registry^!"
		START /MIN PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('!Line1!' + !NewLine! + !NewLine! + '!Line2!', 'DDVT OPTIONS %VERSION%', 'Ok','Error')"	
	)
	TIMEOUT 2 /NOBREAK >nul
)
if "%ERRORLEVEL%"=="10" (
	reg delete "HKCR\*\Shell\DDVT Demuxer" /f>nul 2>&1
	reg delete "HKCR\*\Shell\DDVT Injector" /f>nul 2>&1
	reg delete "HKCR\*\Shell\MenuDDVT" /f>nul 2>&1
	reg delete "HKCU\Software\Classes\Directory\shell\MenuDDVT" /f>nul 2>&1
	reg delete "HKCR\*\Shell\MenuDDVTDir" /f>nul 2>&1	
	reg delete "HKLM\Software\Classes\Directory\Background\Shell\MenuDDVT" /f>nul 2>&1
	reg delete "HKCU\Software\Classes\*\Shell\QFG_DVFINDER" /f>nul 2>&1
	reg delete "HKCU\Software\Classes\*\Shell\DDVT QUICKINFO" /f>nul 2>&1
	reg delete "HKCU\Software\Classes\*\Shell\DDVT MEDIAINFO" /f>nul 2>&1
	reg delete "HKCU\Software\Classes\Directory\shell\05MKVTOMP4" /f>nul 2>&1
	
	reg add "HKCU\Software\Classes\Directory\shell\MenuDDVT" /ve /d "DDVT" /f>nul 2>&1
	reg add "HKCU\Software\Classes\Directory\shell\MenuDDVT" /v "Icon" /t REG_SZ /d "\"!TOOLFOLDER!tools\ICONS\DDVT.ico\",0" /f>nul 2>&1
	reg add "HKCU\Software\Classes\Directory\shell\MenuDDVT" /v "ExtendedSubCommandsKey" /t REG_SZ /d "Directory\shell\MenuDDVT\ContextMenu" /f>nul 2>&1
	reg add "HKCU\Software\Classes\Directory\shell\MenuDDVT" /v "Position" /t REG_SZ /d "Top" /f>nul 2>&1
	reg add "HKCU\Software\Classes\Directory\shell\MenuDDVT\ContextMenu\shell\04REMOVER" /ve /d "Mass-Remover" /f>nul 2>&1
	reg add "HKCU\Software\Classes\Directory\shell\MenuDDVT\ContextMenu\shell\04REMOVER" /v "Icon" /t REG_SZ /d "\"!TOOLFOLDER!tools\ICONS\REMOVER.ico\",0" /f>nul 2>&1
	reg add "HKCU\Software\Classes\Directory\shell\MenuDDVT\ContextMenu\shell\04REMOVER\command" /ve /d "\"!TOOLFOLDER!DDVT_REMOVER.cmd\" ""%%1""" /f>nul 2>&1
	reg add "HKCU\Software\Classes\Directory\shell\MenuDDVT\ContextMenu\shell\07MKVTOMP4" /ve /d "Mass-MKV to MP4" /f>nul 2>&1
	reg add "HKCU\Software\Classes\Directory\shell\MenuDDVT\ContextMenu\shell\07MKVTOMP4" /v "Icon" /t REG_SZ /d "\"!TOOLFOLDER!tools\ICONS\MKVTOMP4.ico\",0" /f>nul 2>&1
	reg add "HKCU\Software\Classes\Directory\shell\MenuDDVT\ContextMenu\shell\07MKVTOMP4\command" /ve /d "\"!TOOLFOLDER!DDVT_MKVTOMP4.cmd\" ""%%1""" /f>nul 2>&1	

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
	reg add "HKLM\Software\Classes\Directory\Background\Shell\MenuDDVT" /v "ExtendedSubCommandsKey" /t REG_SZ /d "Directory\Background\Shell\MenuDDVT\ContextMenu" /f>nul 2>&1
	reg add "HKLM\Software\Classes\Directory\Background\Shell\MenuDDVT" /v "Position" /t REG_SZ /d "Top" /f>nul 2>&1
	reg add "HKLM\Software\Classes\Directory\Background\Shell\MenuDDVT\ContextMenu\shell\01HYBRID" /ve /d "Profile 8 Hybrid" /f>nul 2>&1
	reg add "HKLM\Software\Classes\Directory\Background\Shell\MenuDDVT\ContextMenu\shell\01HYBRID" /v "Icon" /t REG_SZ /d "\"!TOOLFOLDER!tools\ICONS\HYBRID.ico\",0" /f>nul 2>&1
	reg add "HKLM\Software\Classes\Directory\Background\Shell\MenuDDVT\ContextMenu\shell\01HYBRID\command" /ve /d "\"!TOOLFOLDER!DDVT_HYBRID.cmd\" " /f>nul 2>&1

	reg add "HKCR\*\Shell\MenuDDVT" /ve /d "DDVT" /f>nul 2>&1
	reg add "HKCR\*\Shell\MenuDDVT" /v "Icon" /t REG_SZ /d "\"!TOOLFOLDER!tools\ICONS\DDVT.ico\",0" /f>nul 2>&1
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

	if exist "!TOOLFOLDER!DDVT_GENERATOR.cmd" reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\99GENERATE" /ve /d "RPU Generator" /f>nul 2>&1
	if exist "!TOOLFOLDER!DDVT_GENERATOR.cmd" reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\99GENERATE" /v "Icon" /t REG_SZ /d "\"!TOOLFOLDER!tools\ICONS\GENERATOR.ico\",0" /f>nul 2>&1
	if exist "!TOOLFOLDER!DDVT_GENERATOR.cmd" reg add "HKCR\*\Shell\MenuDDVT\ContextMenu\shell\99GENERATE\command" /ve /d "\"!TOOLFOLDER!DDVT_GENERATOR.cmd\" ""%%1""" /f>nul 2>&1
	echo.
	reg query "HKCR\*\Shell\MenuDDVT" /v "Icon" >nul 2>&1
	if "!ERRORLEVEL!"=="0" (
		%HCGREEN%
		echo Registry strings set.
	) else (
		%HCRED%
		echo Registry strings not set. Permissions needed^^!
		set "NewLine=[System.Environment]::NewLine"
		set "Line1=REGISTRY STRINGS NOT SET^!"
		set "Line2=Start the script with ADMINISTRATOR permissions to activate/deactivate the Windows SHELL EXTENSIONS. Without ADMINISTRATOR permissions you have insufficent rights changing Windows registry^!"
		START /MIN PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('!Line1!' + !NewLine! + !NewLine! + '!Line2!', 'DDVT OPTIONS %VERSION%', 'Ok','Error')"	
	)
	TIMEOUT 2 /NOBREAK >nul
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
	%HCYELLOW%
	echo.
	echo If you must install LAV Filters leave blank and hit [ENTER]^ for installing^^!
	echo Don't forget to [S]AVE your settings after editing^^!
	%HCWHITE%
	set /p "LAVFILTERS_FOLDER=:>" || "!TOOLFOLDER!tools\Install\LAVFilters-0.80-Installer.exe"
	goto MAINMENU
)
if "%ERRORLEVEL%"=="4" (
	%HCYELLOW%
	echo.
	echo If you must install AVISYNTH+ leave blank and hit [ENTER]^ for installing^^!
	echo Don't forget to [S]AVE your settings after editing^^!
	%HCWHITE%
	set /p "AVISYNTH_FOLDER=:>" || "!TOOLFOLDER!tools\Install\AviSynthPlus_3.7.5_20250420"
	goto MAINMENU
)
if "%ERRORLEVEL%"=="3" (
	%HCYELLOW%
	echo.
	echo If you will use the INCLUDED MKVTOOLNIX SET leave blank an press [ENTER]^^!
	echo Don't forget to [S]AVE your settings after editing^^!
	%HCWHITE%
	set /p "MKVTOOLNIX_FOLDER=:>" || SET "MKVTOOLNIX_FOLDER=INCLUDED"
)
if "%ERRORLEVEL%"=="2" (
	%HCYELLOW%
	echo.
	echo If you will use the STANDARD SOURCE folder leave blank an press [ENTER]^^!
	echo Don't forget to [S]AVE your settings after editing^^!
	%HCWHITE%
	set /p "TARGET_FOLDER=Type in your OUTPUT Folder and press [ENTER]:" || SET "TARGET_FOLDER=SAME AS SOURCE"
)
if "%ERRORLEVEL%"=="1" (
	%HCYELLOW%
	echo.
	echo If you will use the STANDARD TEMP folder leave blank an press [ENTER]^^!
	echo Don't forget to [S]AVE your settings after editing^^!
	%HCWHITE%
	set /p "TMP_FOLDER=Type in your TEMP Folder and press [ENTER]:" || SET "TMP_FOLDER=SAME AS SOURCE"
)
goto MAINMENU

:EXIT
%WHITE%
setlocal DisableDelayedExpansion
endlocal
echo.
echo  == EXIT ================================================================================================================
echo.
exit