@echo off & setlocal
mode con cols=125 lines=35
set "VERSION=--N.A.-- INCORRECTLY INSTALLED"
set "HEADER1=File "%~dp0DDVT_OPTIONS.cmd" missing! Script works not correctly!"
FOR /F "tokens=2 delims==" %%A IN ('findstr /C:"VERSION=" "%~dp0DDVT_OPTIONS.cmd"') DO set "VERSION=%%A"
FOR /F "tokens=2 delims==" %%A IN ('findstr /C:"HEADER1=" "%~dp0DDVT_OPTIONS.cmd"') DO set "HEADER1=%%A"
TITLE DDVT Remover [QfG] v%VERSION%

set PasswordChars=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890
set PasswordLength=5
call :CreatePassword Password

set "sfkpath=%~dp0tools\sfk.exe" rem Path to sfk.exe
set "MP4BOXpath=%~dp0tools\mp4box.exe" rem Path to mp4box.exe
set "MEDIAINFOpath=%~dp0tools\mediainfo.exe" rem Path to mediainfo.exe
set "FFMPEGpath=%~dp0tools\ffmpeg.exe" rem Path to ffmpeg.exe
set "DO_VI_TOOLpath=%~dp0tools\dovi_tool.exe" rem Path to dovi_tool.exe
set "HDR10Plus_TOOLpath=%~dp0tools\hdr10plus_tool.exe" rem Path to hdr10plus_tool.exe

rem --- Hardcoded settings. Can be changed manually ---
set "REM_HDR10P=YES
:: YES / NO - Remove HDR10+ Metadata from file.
set "REM_DV=NO
:: YES / NO - Remove DV Metadata from file.

rem --- Hardcoded settings. Cannot be changed ---
set "INPUTFILE=%~dpnx1"
set "INPUTFILEPATH=%~dp1"
set "INPUTFILENAME=%~n1"
set "INPUTFILEEXT=%~x1"
set "TMP_FOLDER=SAME AS SOURCE"
set "TARGET_FOLDER=SAME AS SOURCE"
set "MKVTOOLNIX_FOLDER=INCLUDED"
set "MP4Extract=FALSE"
set "MKVExtract=FALSE"
set "HDR_Info=No HDR Infos found"
set "RAW_FILE=FALSE"
set "ELFILE=FALSE"
set "HDR=FALSE"
set "HDR10P=FALSE"
set "DV=FALSE"
set "HDR=No HDR Infos found"
set "RESOLUTION=N/A"
set "CODEC_NAME=N/A"
set "FRAMERATE=N/A"
set "FRAMES=N/A"
set "MSTATUS=call :colortxt 08 "WAITING"
set "DIRFOUND=FALSE"
set /a ERRORCOUNT=0"

setlocal EnableDelayedExpansion
set "WAIT="!sfkpath!" sleep"
set "GREEN="!sfkpath!" color green"
set "RED="!sfkpath!" color red"
set "YELLOW="!sfkpath!" color yellow"
set "WHITE="!sfkpath!" color white"
set "CYAN="!sfkpath!" color cyan"
set "MAGENTA="!sfkpath!" color magenta"
set "GREY="!sfkpath!" color grey"

::Check for INI and Load Settings
if exist "%~dp0DDVT_OPTIONS.ini" (
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
)
if "%TMP_FOLDER%"=="SAME AS SOURCE" (
	set "TMP_FOLDER=%~dp1DDVT_%Password%_TMP"
) else (
	set "TMP_FOLDER=!TMP_FOLDER!\DDVT_%Password%_TMP"
)
if "!TARGET_FOLDER!"=="SAME AS SOURCE" (
	set "TARGET_FOLDER=%~dp1"
	set "TARGET_FOLDER=!TARGET_FOLDER:~0,-1!"
	set "TARGET_FOLDER_TYPE=SOURCE"
)
if "!MKVTOOLNIX_FOLDER!"=="INCLUDED" set "MKVTOOLNIX_FOLDER=%~dp0tools"
set "MKVMERGEpath=!MKVTOOLNIX_FOLDER!\mkvmerge.exe"
set "logfile=%TMP_FOLDER%\!INPUTFILENAME!.log"

if not exist "%sfkpath%" set "MISSINGFILE=%sfkpath%" & goto :CORRUPTFILE
if not exist "%FFMPEGpath%" set "MISSINGFILE=%FFMPEGpath%" & goto :CORRUPTFILE
if not exist "%MKVMERGEpath%" set "MISSINGFILE=%MKVMERGEpath%" & goto :CORRUPTFILE
if not exist "%MP4BOXpath%" set "MISSINGFILE=%MP4BOXpath%" & goto :CORRUPTFILE
if not exist "%MEDIAINFOpath%" set "MISSINGFILE=%MEDIAINFOpath%" & goto :CORRUPTFILE
if not exist "%HDR10Plus_TOOLpath%" set "MISSINGFILE=%HDR10Plus_TOOLpath%" & goto :CORRUPTFILE
if not exist "%DO_VI_TOOLpath%" set "MISSINGFILE=%DO_VI_TOOLpath%" & goto :CORRUPTFILE

cls
%GREEN%
echo  %HEADER1%
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool MKVtoMP4
%WHITE%
echo                                         ====================================
%WHITE%
echo.
echo.
echo  == CHECK INPUT FILE ====================================================================================================
if "%~1"=="" (
	%YELLOW%
	echo.
	echo No Input File. Use %~nx0 "YourFilename.mkv"
	echo.
	goto EXIT
)

dir /b/ad "%~1" >nul 2>nul && set DIRFOUND=TRUE
if "!DIRFOUND!"=="TRUE" goto :MPREPARE

if /i "%~x1"==".hevc" set "RAW_FILE=TRUE" & goto CHECK
if /i "%~x1"==".h265" set "RAW_FILE=TRUE" & goto CHECK
if /i "%~x1"==".mkv" set "MKVExtract=TRUE" & goto CHECK
if /i "%~x1"==".mp4" set "MP4Extract=TRUE" & goto CHECK

if not "!INPUTFILE!"=="" goto :FALSEINPUT

:MPREPARE
set "SOURCE_FOLDER=%~1"
set /A "ERRORCOUNT=0" & set "ERRORCOUNTC=08"
set /A "DONECOUNT=0" & set "DONECOUNTC=08"
set /A "SKIPCOUNT=0" & set "SKIPCOUNTC=08"
set /A "PFILECOUNT=0" & set "PFILECOUNTC=08"
for /F %%i in ('dir "!SOURCE_FOLDER!\*.*" /B /A-d') do set /A SOURCEFILES=!SOURCEFILES!+1>nul
goto :MSTART

:CHECK
set "DVinput=NO"
set "HDR10Pinput=NO"
set "MSKIP=TRUE"
if not exist "!TMP_FOLDER!" MD "!TMP_FOLDER!">nul
echo.
%CYAN%
if "!DIRFOUND!"=="FALSE" echo Analysing File. Please wait...
if "!DIRFOUND!"=="FALSE" echo.
set "INPUTSTREAM=!INPUTFILE!"
set "INFOSTREAM=!INPUTFILE!"

set "VIDEO_COUNT="
FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=General;%%VideoCount%% "!INFOSTREAM!""') do set "VIDEO_COUNT=%%A"

::SET HDR FORMAT
"!MEDIAINFOpath!" --output=Video;%%HDR_Format_String%% "!INFOSTREAM!">"!TMP_FOLDER!\Info.txt"
FOR /F "delims=" %%A IN ('findstr /C:"Dolby Vision" "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES"
FOR /F "delims=" %%A IN ('findstr /C:"HDR10" "!TMP_FOLDER!\Info.txt"') DO set "HDRFormat=HDR10"
FOR /F "delims=" %%A IN ('findstr /C:"HDR10+" "!TMP_FOLDER!\Info.txt"') DO set "HDRFormat=HDR10+"
FOR /F "delims=" %%A IN ('findstr /C:"HDR10+" "!TMP_FOLDER!\Info.txt"') DO set "HDR10Pinput=YES"
FOR /F "delims=" %%A IN ('findstr /C:"dvhe.05" "!TMP_FOLDER!\Info.txt"') DO set "HDRFormat=IPT-PQ-C2"
FOR /F "delims=" %%A IN ('findstr /C:"HLG" "!TMP_FOLDER!\Info.txt"') DO set "HDRFormat=HLG"

if /i "!INPUTFILEEXT!"==".hevc" set "RAW_FILE=TRUE" & set "MSKIP=FALSE"
if /i "!INPUTFILEEXT!"==".h265" set "RAW_FILE=TRUE" & set "MSKIP=FALSE"
if /i "!INPUTFILEEXT!"==".mkv" set "MKVExtract=TRUE" & set "MSKIP=FALSE"
if /i "!INPUTFILEEXT!"==".mp4" set "MP4Extract=TRUE" & set "MSKIP=FALSE"
if "!DVinput!!HDR10Pinput!"=="NONO" set "MSKIP=TRUE"

::SET DV FORMAT
"!MEDIAINFOpath!" --output=Video;%%HDR_Format_Profile%% "!INFOSTREAM!">"!TMP_FOLDER!\Info.txt"
FOR /F "delims=" %%A IN ('findstr /C:".08" "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES" & set "DVprofile=8"
FOR /F "delims=" %%A IN ('findstr /C:".07" "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES" & set "DVprofile=7"
FOR /F "delims=" %%A IN ('findstr /C:".06" "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES" & set "DVprofile=6"
FOR /F "delims=" %%A IN ('findstr /C:".05" "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES" & set "DVprofile=5"
FOR /F "delims=" %%A IN ('findstr /C:".04" "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES" & set "DVprofile=4"
FOR /F "delims=" %%A IN ('findstr /C:".03" "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES" & set "DVprofile=3"
if "!DVprofile!"=="5" set "MSKIP=TRUE"

::DUAL LAYER OPERATION
if "!VIDEO_COUNT!"=="2" (
	set "LAYERTYPE= DL"
	set "DT=-map 0:1"
	"!FFMPEGpath!" -loglevel panic -i "!INFOSTREAM!" -map 0:0 -c:v copy -to 1 "!TMP_FOLDER!\BL.mkv">nul 2>&1
)
if "!DVinput!"=="YES" "!FFMPEGpath!" -loglevel panic -i "!INFOSTREAM!" !DT! -c:v copy -to 1 -bsf:v hevc_metadata -f hevc - | "!DO_VI_TOOLpath!" extract-rpu -o "!TMP_FOLDER!\RPU.bin" - >nul 2>&1
if exist "!TMP_FOLDER!\BL.mkv" set "INFOSTREAM=!TMP_FOLDER!\BL.mkv"

::BEGIN MEDIAINFO
FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%Width%%x%%Height%% "!INFOSTREAM!""') do set "RESOLUTION=%%A"
FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%Format%%^-%%BitDepth%%Bit^-%%ColorSpace%%^-%%ChromaSubsampling%% "!INFOSTREAM!""') do set "CODEC_NAME=%%A"
FOR /F "tokens=1,2 delims= " %%A in ('""!MEDIAINFOpath!" --output=Video;%%FrameRate_String%% "!INPUTSTREAM!""') do (
	set "FRAMERATE=%%A"
	set "FRAMERATE_ORIG=%%A"
)
FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%FrameCount%% "!INPUTSTREAM!""') do set "FRAMES=%%A"
if "!VIDEO_COUNT!"=="2" set "FRAMES=N/A DL"
if "!HDRFormat!"=="HDR10" (
	set "HDR=TRUE"
	%GREEN%
	if "!DIRFOUND!"=="FALSE" echo HDR10 found.
)
if "!HDRFormat!"=="HLG" (
	set "HDR=TRUE"
	%GREEN%
	if "!DIRFOUND!"=="FALSE" echo HLG found.
)
if "!HDRFormat!"=="HDR10+" (
	set "HDR=TRUE"
	set "HDR10P=TRUE"
	%GREEN%
	if "!DIRFOUND!"=="FALSE" echo HDR10+ SEI found.
)
if "!DVprofile!"=="8" (
	set "HDR=TRUE"
	set "DV=TRUE"
	set "DV_Profile=8"
	%GREEN%
	if "!DIRFOUND!"=="FALSE" echo Dolby Vision Profile 8 found.
)
if "!DVprofile!"=="7" (
	set "HDR=TRUE"
	set "DV=TRUE"
	set "DV_Profile=7"
	if "!RESOLUTION!"=="1920x1080" set "ELFILE=TRUE"
	if exist "!TMP_FOLDER!\RPU.bin" (
		FOR /F "usebackq" %%A IN ('!TMP_FOLDER!\RPU.bin') DO set "RPUSIZE=%%~zA">nul 2>&1
		if "!RPUSIZE!" NEQ "0" (
			"!DO_VI_TOOLpath!" info -s "!TMP_FOLDER!\RPU.bin">"!TMP_FOLDER!\RPUINFO.txt"
			if exist "!TMP_FOLDER!\RPUINFO.txt" (
				FOR /F "delims=" %%A IN ('findstr /C:"Profile:" "!TMP_FOLDER!\RPUINFO.txt"') DO set "subprofile=%%A"
				if defined subprofile (
					for /F "tokens=3 delims=:/ " %%A in ("!subprofile!") do set "subprofile= %%A"
				) else (
					set "subprofile="
				)
			)
		)
	)
	%GREEN%
	if "!ELFILE!"=="FALSE" (
		if "!DIRFOUND!"=="FALSE" echo Dolby Vision Profile 7!subprofile!!LAYERTYPE! found.
	) else (
		if "!DIRFOUND!"=="FALSE" echo Dolby Vision Profile 7!subprofile!!LAYERTYPE! EL Layer found.
	)
	set "DV_Profile=7!subprofile!!LAYERTYPE!"
)
if "!DVprofile!"=="5" (
	set "HDR=FALSE"
	set "DV=TRUE"
	set "DV_Profile=5"
	%GREEN%
	if "!DIRFOUND!"=="FALSE" echo Dolby Vision Profile 5 found.
)
if "!DVprofile!"=="4" (
	set "HDR=TRUE"
	set "DV=TRUE"
	set "DV_Profile=4"
	%GREEN%
	if "!DIRFOUND!"=="FALSE" echo Dolby Vision Profile 4 found.
)
%GREEN%
if "!HDR!"=="TRUE" set "HDR_Info=!HDRFormat!"
if "!HDR10P!"=="TRUE" set "HDR_Info=HDR10, !HDRFormat!"
if "!DV!"=="TRUE" set "HDR_Info=Dolby Vision Profile !DV_Profile!"
if "!HDR!!DV!"=="TRUETRUE" set "HDR_Info=!HDRFormat!, Dolby Vision Profile !DV_Profile!"
if "!HDR10P!!DV!"=="TRUETRUE" set "HDR_Info=HDR10, !HDRFormat!, Dolby Vision Profile !DV_Profile!"
echo.
if "!DIRFOUND!"=="FALSE" echo Analysing complete.
if "!DIRFOUND!"=="TRUE" goto :eof
TIMEOUT 3 /NOBREAK>nul
goto :START

:START
if "!DV!!HDR10P!"=="FALSEFALSE" goto :NOTHINGTODO
set "LOG_FILENAME=DDVT Remover ^(!INPUTFILENAME!!INPUTFILEEXT!^)"
set "NAMESTRING="
if "!HDRFormat!"=="HDR10+" set "HDRFormat=HDR10"
if "!DV_Profile!"=="5" goto :PROFILE5NS
set "HDR_InfoO=%HDR_Info%"
if "!HDR10P!!REM_HDR10P!"=="TRUEYES" set "HDR_InfoO=HDR10"
if "!HDR10P!!REM_HDR10P!!DV!"=="TRUEYESTRUE" set "HDR_InfoO=HDR10, Dolby Vision Profile !DV_Profile!"
if "!DV!!REM_DV!"=="TRUEYES" set "HDR_InfoO=!HDRFormat!"
if "!DV!!REM_DV!!HDR10P!"=="TRUEYESTRUE" set "HDR_InfoO=HDR10, HDR10+"
if "!HDR10P!!REM_HDR10P!!DV!!REM_DV!"=="TRUEYESTRUEYES" set "HDR_InfoO=!HDRFormat!"
if "!HDR10P!!REM_HDR10P!"=="TRUEYES" set "NAMESTRING=_[No HDR10+]"
if "!DV!!REM_DV!"=="TRUEYES" set "NAMESTRING=_[No DV]"
if "!HDR10P!!REM_HDR10P!!DV!!REM_DV!"=="TRUEYESTRUEYES" set "NAMESTRING=_[No HDR10+ No DV]"
cls
%GREEN%
echo  %HEADER1%
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool REMOVER
%WHITE%
echo                                         ====================================
echo.
echo.
echo  == VIDEO INPUT =========================================================================================================
echo.
%CYAN%
echo Filename   = [!INPUTFILENAME!!INPUTFILEEXT!]
echo Video Info = [Resolution = %RESOLUTION%] [Codec = %CODEC_NAME%] [Frames = %FRAMES%] [FPS = %FRAMERATE%]
echo HDR Info   = [%HDR_Info%]
echo.
%WHITE%
echo  == FILE OUTPUT =========================================================================================================
echo.
%YELLOW%
echo Filename   = [!INPUTFILENAME!!NAMESTRING!!INPUTFILEEXT!]
echo Video Info = [Resolution = %RESOLUTION%] [Codec = %CODEC_NAME%] [Frames = %FRAMES%] [FPS = %FRAMERATE%]
echo HDR Info   = [!HDR_InfoO!]
echo.
%WHITE%
echo  == MENU ================================================================================================================
echo.
if "%HDR10P%"=="TRUE" echo 1. Remove HDR10+               : [%REM_HDR10P%]
if "%DV%"=="TRUE" echo 2. Remove Dolby Vision         : [%REM_DV%]
echo.
%WHITE%
echo S. START
echo.
%GREEN%
echo Change Settings and press [S] to start Extracting^^!
if "%HDR10P%"=="TRUE" if "%DV%"=="TRUE" CHOICE /C 12S /N /M "Select a Letter 1,2,[S]tart"
if "%HDR10P%"=="TRUE" if "%DV%"=="FALSE" CHOICE /C 12S /N /M "Select a Letter 1,[S]tart"
if "%HDR10P%"=="FALSE" if "%DV%"=="TRUE" CHOICE /C 12S /N /M "Select a Letter 2,[S]tart"
if "%ERRORLEVEL%"=="3" goto :OPERATION
if "%ERRORLEVEL%"=="2" (
	if "%REM_DV%"=="NO" set "REM_DV=YES"
	if "%REM_DV%"=="YES" set "REM_DV=NO"
)
if "%ERRORLEVEL%"=="1" (
	if "%REM_HDR10P%"=="NO" set "REM_HDR10P=YES"
	if "%REM_HDR10P%"=="YES" set "REM_HDR10P=NO"
)
goto :START

:MSTART
cls
%GREEN%
echo  %HEADER1%
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool REMOVER
%WHITE%
echo                                         ====================================
echo.
echo.
echo  == MASS REMOVER ========================================================================================================
echo.
%CYAN%
call :colortxt 0B "Status     = [" & !MSTATUS! & call :colortxt 0B "]" /n
call :colortxt 0B "Folder     = [" & call :colortxt 0A "!SOURCE_FOLDER!" & call :colortxt 0B "]" /n
call :colortxt 0B "Info       = [FILES PROCESS/SUM: " & call :colortxt !PFILECOUNTC! "!PFILECOUNT!" & call :colortxt 0B "/!SOURCEFILES!" & call :colortxt 0B "] [DONE: " & call :colortxt !DONECOUNTC! "!DONECOUNT!" & call :colortxt 0B "] [ERROR(S): " & call :colortxt !ERRORCOUNTC! "!ERRORCOUNT!" & call :colortxt 0B "] [SKIPPED: " & call :colortxt !SKIPCOUNTC! "!SKIPCOUNT!" & call :colortxt 0B "]" /n
echo.
%WHITE%
echo  == MENU ================================================================================================================
echo.
echo 1. Remove HDR10+               : [%REM_HDR10P%]
echo 2. Remove Dolby Vision         : [%REM_DV%]
echo.
%WHITE%
echo S. START
echo.
%GREEN%
echo Change Settings and press [S] to start Extracting^^!
CHOICE /C 12S /N /M "Select a Letter 1,2,[S]tart"

if "%ERRORLEVEL%"=="3" goto :MBEGIN
if "%ERRORLEVEL%"=="2" (
	if "%REM_DV%"=="NO" set "REM_DV=YES"
	if "%REM_DV%"=="YES" set "REM_DV=NO"
)
if "%ERRORLEVEL%"=="1" (
	if "%REM_HDR10P%"=="NO" set "REM_HDR10P=YES"
	if "%REM_HDR10P%"=="YES" set "REM_HDR10P=NO"
)
goto :MSTART

:MBEGIN
mode con cols=125 lines=55
set "ERRORCOUNT_END=!ERRORCOUNT!"
if "!TARGET_FOLDER_TYPE!"=="SOURCE" set "TARGET_FOLDER=!TARGET_FOLDER!\%~n1"
if not exist "!TMP_FOLDER!" MD "!TMP_FOLDER!">nul
if not exist "!TARGET_FOLDER!" MD "!TARGET_FOLDER!">nul
set "LOG_FILENAME=DDVT Remover (Folder=%~n1)"
set "MSTATUS=call :colortxt 0F "WORKING"
rem -------- LOGFILE ------------
echo  %HEADER1%>"!logfile!"
echo.>>"!logfile!"
echo                                         ====================================>>"!logfile!"
echo                                              Dolby Vision Tool REMOVER>>"!logfile!"
echo                                         ====================================>>"!logfile!"
echo.>>"!logfile!"
echo.>>"!logfile!"
echo.>>"!logfile!"
echo  == LOGFILE START =======================================================================================================>>"!logfile!"
echo.>>"!logfile!"
echo %date%  %time%>>"!logfile!"
echo.>>"!logfile!"
for %%A in ("!SOURCE_FOLDER!\*.*") do (
	set /A "PFILECOUNT=!PFILECOUNT!+1"
	if "!ERRORCOUNT!" NEQ "0" (
		set "ERRORCOUNTC=0C"
	) else (
		set "ERRORCOUNTC=0A"
	)
	if "!DONECOUNT!" NEQ "0" (
		set "DONECOUNTC=0A"
	) else (
		set "DONECOUNTC=0E"
	)
	if "!SKIPCOUNT!" NEQ "0" (
		set "SKIPCOUNTC=0E"
	) else (
		set "SKIPCOUNTC=0A"
	)
	set "ERRORCOUNT_START=!ERRORCOUNT!"
	if "!PFILECOUNT!" NEQ "0" set "PFILECOUNTC=0F"
	set "INPUTFILE=%%~dpnxA"
	set "INPUTFILEPATH=%%~dpA"
	set "INPUTFILENAME=%%~nA"
	set "INPUTFILEEXT=%%~xA"
	set "RAW_FILE=FALSE"
	set "RAW_FILE=FALSE"
	set "MKVExtract=FALSE"
	set "MP4Extract=FALSE"
	call :CHECK
	set "NAMESTRING="
	if "!HDRFormat!"=="HDR10+" set "HDRFormat=HDR10"
	set "HDR_InfoO=%HDR_Info%"
	if "!HDR10P!!REM_HDR10P!"=="TRUEYES" set "HDR_InfoO=HDR10"
	if "!HDR10P!!REM_HDR10P!!DV!"=="TRUEYESTRUE" set "HDR_InfoO=HDR10, Dolby Vision Profile !DV_Profile!"
	if "!DV!!REM_DV!"=="TRUEYES" set "HDR_InfoO=!HDRFormat!"
	if "!DV!!REM_DV!!HDR10P!"=="TRUEYESTRUE" set "HDR_InfoO=HDR10, HDR10+"
	if "!HDR10P!!REM_HDR10P!!DV!!REM_DV!"=="TRUEYESTRUEYES" set "HDR_InfoO=!HDRFormat!"
	if "!HDR10P!!REM_HDR10P!"=="TRUEYES" set "NAMESTRING=_[No HDR10+]"
	if "!DV!!REM_DV!"=="TRUEYES" set "NAMESTRING=_[No DV]"
	if "!HDR10P!!REM_HDR10P!!DV!!REM_DV!"=="TRUEYESTRUEYES" set "NAMESTRING=_[No HDR10+ No DV]"
	cls
	%GREEN%
	echo  %HEADER1%
	echo.
	%WHITE%
	echo                                         ====================================
	%GREEN%
	echo                                               Dolby Vision Tool REMOVER
	%WHITE%
	echo                                         ====================================
	echo.	
	echo.
	echo  == MASS REMOVER ========================================================================================================
	echo.
	%CYAN%
	call :colortxt 0B "Status     = [" & !MSTATUS! & call :colortxt 0B "]" /n
	echo Filename   = [!INPUTFILENAME!!INPUTFILEEXT!]
	echo Video Info = [Resolution = !RESOLUTION!] [Codec = !CODEC_NAME!] [Frames = !FRAMES!] [FPS = !FRAMERATE!]
	echo HDR Info   = [!HDR_Info!]
	call :colortxt 0B "Info       = [FILES PROCESS/SUM: " & call :colortxt !PFILECOUNTC! "!PFILECOUNT!" & call :colortxt 0B "/!SOURCEFILES!" & call :colortxt 0B "] [DONE: " & call :colortxt !DONECOUNTC! "!DONECOUNT!" & call :colortxt 0B "] [ERROR(S): " & call :colortxt !ERRORCOUNTC! "!ERRORCOUNT!" & call :colortxt 0B "] [SKIPPED: " & call :colortxt !SKIPCOUNTC! "!SKIPCOUNT!" & call :colortxt 0B "]" /n
	if "!MSKIP!"=="FALSE" call :MOPERATION
	if "!MSKIP!"=="FALSE" (
		if "!ERRORCOUNT_START!"=="!ERRORCOUNT_END!" set /A DONECOUNT=!DONECOUNT!+1 & echo [DONE] [!INPUTFILENAME!!INPUTFILEEXT!] -^> [!INPUTFILENAME!!NAMESTRING!!INPUTFILEEXT!]>>"!logfile!"
		if "!ERRORCOUNT_START!" NEQ "!ERRORCOUNT_END!" echo [ERROR] [!INPUTFILENAME!!INPUTFILEEXT!]>>"!logfile!"
	)
	if "!MSKIP!"=="TRUE" set /A "SKIPCOUNT=!SKIPCOUNT!+1" & echo [SKIPPED] [!INPUTFILENAME!!NAMESTRING!!INPUTFILEEXT!]>>"!logfile!"
)
set "MSTATUS=call :colortxt 0F "DONE"
mode con cols=125 lines=35
cls
set "MSTATUS=call :colortxt 0A "DONE"
%GREEN%
echo  %HEADER1%
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool REMOVER
%WHITE%
echo                                         ====================================
echo.	
echo.
echo  == MASS REMOVER ========================================================================================================
echo.
%CYAN%
call :colortxt 0B "Status     = [" & !MSTATUS! & call :colortxt 0B "]" /n
call :colortxt 0B "Folder     = [" & call :colortxt 0A "!SOURCE_FOLDER!" & call :colortxt 0B "]" /n
call :colortxt 0B "Info       = [FILES PROCESS/SUM: " & call :colortxt !PFILECOUNTC! "!PFILECOUNT!" & call :colortxt 0B "/!SOURCEFILES!" & call :colortxt 0B "] [DONE: " & call :colortxt !DONECOUNTC! "!DONECOUNT!" & call :colortxt 0B "] [ERROR(S): " & call :colortxt !ERRORCOUNTC! "!ERRORCOUNT!" & call :colortxt 0B "] [SKIPPED: " & call :colortxt !SKIPCOUNTC! "!SKIPCOUNT!" & call :colortxt 0B "]" /n
echo.
%WHITE%
echo  ========================================================================================================================
echo.
%GREEN%
echo CONVERTING DONE^^!.
echo.
%YELLOW%
echo Open logfile for detailed Infos.
echo.
echo.>>"!logfile!"
echo  == INFO ================================================================================================================>>"!logfile!"
echo.>>"!logfile!"
echo Settings^:>>"!logfile!"
echo.>>"!logfile!"
echo Remove HDR10+               : [%REM_HDR10P%]>>"!logfile!"
echo Remove Dolby Vision         : [%REM_DV%]>>"!logfile!"
echo.>>"!logfile!"
echo [PROCESSED FILES^: !PFILECOUNT!] [DONE^: !DONECOUNT!/!PFILECOUNT!] [SKIPPED^: !SKIPCOUNT!/!PFILECOUNT!] [ERROR^(S^)^: !ERRORCOUNT!/!PFILECOUNT!]>>"!logfile!"
echo.>>"!logfile!"
echo %date%  %time%>>"!logfile!"
echo.>>"!logfile!"
echo  == LOGFILE END =========================================================================================================>>"!logfile!"
goto :EXIT

:MOPERATION
if exist "!TMP_FOLDER!\*.hevc" del "!TMP_FOLDER!\*.hevc">nul
if not exist "!TMP_FOLDER!" MD "!TMP_FOLDER!">nul
if not exist "!TARGET_FOLDER!" MD "!TARGET_FOLDER!">nul
echo.
%WHITE%
echo  == REMOVING ============================================================================================================
echo.
%CYAN%
if "!HDR10P!"=="TRUE" echo Remove HDR10+               : [!REM_HDR10P!]
if "!DV!"=="TRUE" echo Remove Dolby Vision         : [!REM_DV!]
if "!REM_HDR10P!!REM_DV!"=="NONO" echo All options set to [NO]. Exiting... & goto :EXIT
if "!RAW_FILE!"=="FALSE" (
	call :DEMUX
) else (
	call :NODEMUX
)
if "%HDR10P%%REM_HDR10P%"=="TRUEYES" call :REMOVE_HDR10+
if "%DV%%REM_DV%"=="TRUEYES" call :REMOVE_DV
if "%RAW_FILE%"=="FALSE" (
	call :MUX
) else (
	call :POSTRAW
)
if "!DIRFOUND!"=="TRUE" goto :eof
goto :EXIT

:OPERATION
mode con cols=125 lines=65
if not exist "!TMP_FOLDER!" MD "!TMP_FOLDER!">nul
if not exist "!TARGET_FOLDER!" MD "!TARGET_FOLDER!">nul
echo.>>"!logfile!"
echo                                         ====================================>>"!logfile!"
echo                                              Dolby Vision Tool REMOVER>>"!logfile!"
echo                                         ====================================>>"!logfile!"
echo.>>"!logfile!"
echo.>>"!logfile!"
echo.>>"!logfile!"
echo  == LOGFILE START =======================================================================================================>>"!logfile!"
echo.>>"!logfile!"
echo %date%  %time%>>"!logfile!"
echo.>>"!logfile!"
cls
%GREEN%
echo  %HEADER1%
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool REMOVER
%WHITE%
echo                                         ====================================
echo.
echo.
echo  == VIDEO INPUT =========================================================================================================
echo.
%CYAN%
echo Filename   = [!INPUTFILENAME!!INPUTFILEEXT!]
echo Video Info = [Resolution = !RESOLUTION!] [Codec = !CODEC_NAME!] [Frames = !FRAMES!] [FPS = !FRAMERATE!]
echo HDR Info   = [!HDR_Info!]
echo.
%WHITE%
echo  == FILE OUTPUT =========================================================================================================
echo.
%YELLOW%
echo Filename   = [!INPUTFILENAME!!NAMESTRING!!INPUTFILEEXT!]
echo Video Info = [Resolution = !RESOLUTION!] [Codec = !CODEC_NAME!] [Frames = !FRAMES!] [FPS = !FRAMERATE!]
echo HDR Info   = [!HDR_InfoO!]
echo.
%WHITE%
echo  == REMOVING ============================================================================================================
echo.
%CYAN%
if "!HDR10P!"=="TRUE" echo Remove HDR10+               : [!REM_HDR10P!]
if "!DV!"=="TRUE" echo Remove Dolby Vision         : [!REM_DV!]
if "!REM_HDR10P!!REM_DV!"=="NONO" echo All options set to [NO]. Exiting... & goto :EXIT
if "!RAW_FILE!"=="FALSE" (
	call :DEMUX
) else (
	call :NODEMUX
)
if "%HDR10P%%REM_HDR10P%"=="TRUEYES" call :REMOVE_HDR10+
if "%DV%%REM_DV%"=="TRUEYES" call :REMOVE_DV
if "%RAW_FILE%"=="FALSE" (
	call :MUX
) else (
	call :POSTRAW
)

if "!ERRORCOUNT!"=="0" echo [DONE] [!INPUTFILENAME!!INPUTFILEEXT!] -^> [!INPUTFILENAME!!NAMESTRING!!INPUTFILEEXT!]>>"!logfile!"
if "!ERRORCOUNT!" NEQ "0" echo [ERROR] [!INPUTFILENAME!!INPUTFILEEXT!]>>"!logfile!"


echo.>>"!logfile!"
echo  == INFO ================================================================================================================>>"!logfile!"
echo.>>"!logfile!"
echo Settings^:>>"!logfile!"
echo.>>"!logfile!"
echo Remove HDR10+               : [%REM_HDR10P%]>>"!logfile!"
echo Remove Dolby Vision         : [%REM_DV%]>>"!logfile!"
echo.>>"!logfile!"
echo %date%  %time%>>"!logfile!"
echo.>>"!logfile!"
echo  == LOGFILE END =========================================================================================================>>"!logfile!"
goto :EXIT

:NODEMUX
%WHITE%
echo.
echo  == COPYING =============================================================================================================
echo.
%CYAN%
echo Please wait. Copy Stream to Temp folder...
copy "!INPUTFILE!" "!TMP_FOLDER!\temp.hevc">nul
if exist "!TMP_FOLDER!\temp.hevc" (
	%GREEN%
	echo Done.
	set "VIDEOSTREAM=!TMP_FOLDER!\temp.hevc"
	echo.
) else (
	%RED%
	echo Error.
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	echo.
)
goto :eof

:DEMUX
%WHITE%
echo.
echo  == DEMUXING ============================================================================================================
echo.
%YELLOW%
echo ATTENTION^^! You need a lot of HDD Space for this operation.
echo.
%CYAN%
echo Please wait. Extracting Video Layer...
%WHITE%
"!FFMPEGpath!" -loglevel panic -stats -i "!INPUTFILE!" -c:v copy -bsf:v hevc_metadata -f hevc "!TMP_FOLDER!\temp.hevc"
if exist "!TMP_FOLDER!\temp.hevc" (
	%GREEN%
	echo Done.
	set "VIDEOSTREAM=!TMP_FOLDER!\temp.hevc"
	echo.
) else (
	%RED%
	echo Error.
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	echo.
)
goto :eof

:REMOVE_HDR10+
if "!HDR10Pinput!"=="NO" goto :eof
%WHITE%
echo  == REMOVING HDR10+ =====================================================================================================
echo.
if "%REM_HDR10P%"=="YES" if "%HDR10P%"=="TRUE" (
	%CYAN%
	echo Please wait. Removing HDR10+ SEI...
	%WHITE%
	PUSHD "!TMP_FOLDER!"
	"%HDR10Plus_TOOLpath%" remove "!VIDEOSTREAM!" -o "!TMP_FOLDER!\BL_NOHDR10P.hevc"
	POPD
	if "%ERRORLEVEL%"=="0" (
		%GREEN%
		echo Done.
		set "VIDEOSTREAM=!TMP_FOLDER!\BL_NOHDR10P.hevc"
		echo.
	) else (
		%RED%
		echo Error.
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
		echo.
	)
)
goto :eof

:REMOVE_DV
if "!DVinput!"=="NO" goto :eof
%WHITE%
echo  == REMOVING Dolby Vision ===============================================================================================
echo.
%CYAN%
echo Please wait. Removing Dolby Vision Metadata...
%WHITE%
PUSHD "!TMP_FOLDER!"
"%DO_VI_TOOLpath%" demux "!VIDEOSTREAM!"
POPD
if "%ERRORLEVEL%"=="0" (
	%GREEN%
	set "VIDEOSTREAM=!TMP_FOLDER!\BL.hevc"
	echo Done.
	echo.
) else (
	%RED%
	echo Error.
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	echo.
)
goto :eof

:POSTRAW
%CYAN%
echo Please wait. Moving RAW Stream to Target Folder...
move "!VIDEOSTREAM!" "!TARGET_FOLDER!\!INPUTFILEO!!NAMESTRING!.hevc">nul
if exist "!TARGET_FOLDER!\!INPUTFILEO!!NAMESTRING!.hevc (
	%GREEN%
	echo Done.
	echo.
) else (
	%RED%
	echo Error.
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	echo.
)
set "ERRORCOUNT_END=!ERRORCOUNT!"
goto :eof

:MUX
%WHITE%
echo  == MUXING ==============================================================================================================
echo.
if "!MKVExtract!"=="TRUE" (
	set "duration="
	SETLOCAL ENABLEDELAYEDEXPANSION
	if "!FRAMERATE!"=="23.976" set "duration=--default-duration 0:24000/1001p --fix-bitstream-timing-information 0:1"
	if "!FRAMERATE!"=="24.000" set "duration=--default-duration 0:24p --fix-bitstream-timing-information 0:1"
	if "!FRAMERATE!"=="25.000" set "duration=--default-duration 0:25p --fix-bitstream-timing-information 0:1"
	if "!FRAMERATE!"=="30.000" set "duration=--default-duration 0:30p --fix-bitstream-timing-information 0:1"
	if "!FRAMERATE!"=="48.000" set "duration=--default-duration 0:48p --fix-bitstream-timing-information 0:1"
	if "!FRAMERATE!"=="50.000" set "duration=--default-duration 0:50p --fix-bitstream-timing-information 0:1"
	if "!FRAMERATE!"=="60.000" set "duration=--default-duration 0:60p --fix-bitstream-timing-information 0:1"
	%CYAN%
	echo Please wait. Muxing Videostream into Container...
	%YELLOW%
	echo Don't close the "Muxing !INPUTFILENAME! into MKV" cmd window.
	start /WAIT /MIN "Muxing !INPUTFILENAME! into MKV" "!MKVMERGEpath!" --ui-language en --priority higher --output ^"!TARGET_FOLDER!\!INPUTFILENAME!!NAMESTRING!.mkv^" --stop-after-video-ends --no-video ^"^(^" ^"!INPUTFILE!^" ^"^)^" --language 0:und --compression 0:none !duration! ^"^(^" ^"!VIDEOSTREAM!^" ^"^)^" --track-order 1:0
	if exist "!TARGET_FOLDER!\!INPUTFILENAME!!NAMESTRING!.mkv" (
		%GREEN%
		echo Done.
		echo.
	) else (
		%RED%
		echo Error.
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
		echo.
	)
)

if "!MP4Extract!"=="TRUE" (
	%CYAN%
	echo Please wait. Muxing !INPUTFILENAME! into MP4...
	%WHITE%
	"!MP4BOXpath!" -rem 1 "!INPUTFILE!" -out "!TMP_FOLDER!\temp.mp4"
	"!MP4BOXpath!" -add "!VIDEOSTREAM!:ID=1:fps=!FRAMERATE!:name=" "!TMP_FOLDER!\temp.mp4" -out "!TARGET_FOLDER!\!INPUTFILENAME!!NAMESTRING!.mp4"
	if exist "!TMP_FOLDER!\temp.mp4" del "!TMP_FOLDER!\temp.mp4"
	if "%ERRORLEVEL%"=="0" (
		%GREEN%
		echo Done.
		echo.
	) else (
		%RED%
		echo Error.
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
		echo.
	)
)
set "ERRORCOUNT_END=!ERRORCOUNT!"
goto :eof

:EXIT
if exist "!logfile!" move "!logfile!" "!TARGET_FOLDER!\!LOG_FILENAME!.log" >nul
%WHITE%
echo  == CLEANING ============================================================================================================
echo.
%CYAN%
echo Please wait. Cleaning and Moving files...
if exist "!TMP_FOLDER!" (
	RD /S /Q "!TMP_FOLDER!">nul
	if "%ERRORLEVEL%"=="0" (
		%GREEN%
		echo Deleting Temp Folder - Done.
	) else (
		%RED%
		echo Deleting Temp Folder - Error.
	)
)
setlocal DisableDelayedExpansion
ENDLOCAL
%WHITE%
echo.
echo  == EXIT ================================================================================================================
echo.
if "%ERRORCOUNT%"=="0" (
	%GREEN%
	echo All Operations successful.
	%WHITE%
	TIMEOUT 30
) else (
	%RED%
	echo SOME Operations failed.
	%WHITE%
	TIMEOUT 30
	goto :ERROR
)
exit

:CORRUPTFILE
if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
START /B https://mega.nz/folder/x9FHlbbK#YQz_XsqcAXfZP2ciLeyyDg
set "NewLine=[System.Environment]::NewLine"
set "Line1=""%MISSINGFILE%""""
set "Line2=Copy the file to the directory or download and extract DDVT_tools.rar"
setlocal DisableDelayedExpansion
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('NEEDED FILE NOT FOUND!' + %NewLine% + %NewLine% + '%Line1%' + %NewLine% + %NewLine% + '%Line2%', 'DDVT Remover [QfG] v%VERSION%', 'Ok','Error')"
exit

:NOTHINGTODO
if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
set "NewLine=[System.Environment]::NewLine"
set "Line1=No HDR10+ SEI or DV Metadata in file."
set "Line2=The file has no Metadata for removing included."
setlocal DisableDelayedExpansion
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('%INPUTFILENAME%%INPUTFILEEXT%' + %NewLine% + %NewLine% + '%Line1%' + %NewLine% + %NewLine% + '%Line2%', 'DDVT Remover [QfG] v%VERSION%', 'Ok','Info')"
exit

:PROFILE5NS
if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
set "NewLine=[System.Environment]::NewLine"
set "Line1=Dolby Vision Profile 5 not supported."
set "Line2=The file has a RPU included, but the RPU cannot be removed."
setlocal DisableDelayedExpansion
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('%INPUTFILENAME%%INPUTFILEEXT%' + %NewLine% + %NewLine% + '%Line1%' + %NewLine% + %NewLine% + '%Line2%', 'DDVT Remover [QfG] v%VERSION%', 'Ok','Info')"
exit

:FALSEINPUT
if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
set "NewLine=[System.Environment]::NewLine"
set "Line1=Unsupported Input File. Supported Files are:"
set "Line2=*.mkv | *.mp4 | *.h265 | *.hevc"
setlocal DisableDelayedExpansion
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('%INPUTFILENAME%%INPUTFILEEXT%' + %NewLine% + %NewLine% + '%Line1%' + %NewLine% + %NewLine% + '%Line2%', 'DDVT Remover [QfG] v%VERSION%', 'Ok','Info')"
exit

:ERROR
if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
set "NewLine=[System.Environment]::NewLine"
set "Line1=%ERRORCOUNT% Error(s) during processing^!
set "Line2=Target file don''t exist or corrupt.
setlocal DisableDelayedExpansion
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('%INPUTFILENAME%%INPUTFILEEXT%' + %NewLine% + %NewLine% + '%Line1%' + %NewLine% + %NewLine% + '%Line2%', 'DDVT Remover [QfG] v%VERSION%', 'Ok','Error')"
exit

:CreatePassword
set TempVar=%PasswordChars%
set /a PWCharCount=0

:CountLoop
	set TempVar=%TempVar:~1%
	set /a PWCharCount+=1
if not "%TempVar%"=="" goto CountLoop
set TempVar=
set Length=0

:GenerateLoop
set /a i=%Random% %% PWCharCount
set /a Length+=1
set TempVar=%TempVar%!PasswordChars:~%i%,1!
if not "%Length%"=="%PasswordLength%" goto GenerateLoop
set %1=%TempVar%
goto :eof

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