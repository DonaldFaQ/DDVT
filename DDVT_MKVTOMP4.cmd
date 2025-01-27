@echo off & setlocal
mode con cols=125 lines=57
FOR /F "tokens=2 delims==" %%A IN ('findstr /C:"VERSION=" "%~dp0DDVT_OPTIONS.cmd"') DO set "VERSION=%%A"
TITLE DDVT MKVtoMP4 [QfG] v%VERSION%

set PasswordChars=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890
set PasswordLength=5
call :CreatePassword Password

set "sfkpath=%~dp0tools\sfk.exe" rem Path to sfk.exe
set "FFMPEGpath=%~dp0tools\ffmpeg.exe" rem Path to ffmpeg.exe
set "FFPROBEpath=%~dp0tools\ffprobe.exe" rem Path to ffprobe.exe
set "MP4FPSMODpath=%~dp0tools\mp4fpsmod.exe" rem Path to mp4fpsmod.exe
set "MP4BOXpath=%~dp0tools\mp4box.exe" rem Path to mp4box.exe
set "MP4MUXERpath=%~dp0tools\mp4muxer.exe" rem Path to mp4muxer.exe
set "MEDIAINFOpath=%~dp0tools\mediainfo.exe" rem Path to mediainfo.exe
set "DO_VI_TOOLpath=%~dp0tools\dovi_tool.exe" rem Path to dovi_tool.exe
set "HDR10P_TOOLpath=%~dp0tools\hdr10plus_tool.exe" rem Path to hdr10plus_tool.exe

rem --- Hardcoded settings. Can be changed manually ---
set "AUDIOCODEC=Untouched"
:: Untouched / eAC-3 @640k / AC-3 @640k / AAC @High Quality - Set default Audiocodec

rem --- Hardcoded settings. Cannot be changed ---
set "INPUTFILE=%~dpnx1"
set "INPUTFILEPATH=%~dp1"
set "INPUTFILENAME=%~n1"
set "INPUTFILEEXT=%~x1"
set "DIRFOUND=FALSE"
set "FAKEP5ALLOWED=FALSE"
set "FAKEP5=NO"
set "TMP_FOLDER=SAME AS SOURCE"
set "TARGET_FOLDER=SAME AS SOURCE"
set "MKVTOOLNIX_FOLDER=INCLUDED"
set "HDR_Info=No HDR Infos found"
set "RESOLUTION=N/A"
set "HDR=N/A"
set "CODEC_NAME=N/A"
set "FRAMERATE=N/A"
set "FRAMES=N/A"
set "DIR=FALSE"
set /a "ERRORCOUNT=0"

setlocal EnableDelayedExpansion
set "WAIT="!sfkpath!" sleep"
set "GREEN="!sfkpath!" color green"
set "RED="!sfkpath!" color red"
set "YELLOW="!sfkpath!" color yellow"
set "WHITE="!sfkpath!" color white"
set "CYAN="!sfkpath!" color cyan"
set "MAGENTA="!sfkpath!" color magenta"
set "GREY="!sfkpath!" color grey"

:: Check for INI and Load Settings
IF EXIST "%~dp0DDVT_OPTIONS.ini" (
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

if "!TARGET_FOLDER!"=="SAME AS SOURCE" (
	set "TARGET_FOLDER=%~dp1"
	set "TARGET_FOLDER=!TARGET_FOLDER:~0,-1!"
	set "TARGET_FOLDER_TYPE=SOURCE"
)
if "%TMP_FOLDER%"=="SAME AS SOURCE" (
	set "TMP_FOLDER=%~dp1DDVT_%Password%_TMP"
) else (
	set "TMP_FOLDER=!TMP_FOLDER!\DDVT_%Password%_TMP"
)
if "!MKVTOOLNIX_FOLDER!"=="INCLUDED" set "MKVTOOLNIX_FOLDER=%~dp0tools"
set "MKVMERGEpath=!MKVTOOLNIX_FOLDER!\mkvmerge.exe"
set "logfile=%TMP_FOLDER%\!INPUTFILENAME!.log"

if not exist "%sfkpath%" set "MISSINGFILE=%sfkpath%" & goto :CORRUPTFILE
if not exist "%FFMPEGpath%" set "MISSINGFILE=%FFMPEGpath%" & goto :CORRUPTFILE
if not exist "%MKVMERGEpath%" set "MISSINGFILE=%MKVMERGEpath%" & goto :CORRUPTFILE
if not exist "%FFPROBEpath%" set "MISSINGFILE=%FFPROBEpath%" & goto :CORRUPTFILE
if not exist "%MP4BOXpath%" set "MISSINGFILE=%MP4BOXpath%" & goto :CORRUPTFILE
if not exist "%MEDIAINFOpath%" set "MISSINGFILE=%MEDIAINFOpath%" & goto :CORRUPTFILE
if not exist "%MP4FPSMODpath%" set "MISSINGFILE=%MP4FPSMODpath%" & goto :CORRUPTFILE
if not exist "%DO_VI_TOOLpath%" set "MISSINGFILE=%DO_VI_TOOLpath%" & goto :CORRUPTFILE
if not exist "%MP4MUXERpath%" set "MISSINGFILE=%MP4MUXERpath%" & goto :CORRUPTFILE
if not exist "%HDR10P_TOOLpath%" set "MISSINGFILE=%HDR10P_TOOLpath%" & goto :CORRUPTFILE

cls
%GREEN%
echo  powered by quietvoids tools                                                                  Copyright ^(c^) 2021-2025 QfG
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool MKVtoMP4
%WHITE%
echo                                         ====================================
echo.
%WHITE%
echo.
echo.
echo  == CHECK INPUT FILE ====================================================================================================
if "%~1"=="" (
	%YELLOW%
	echo.
	echo No Input File. Use DDVT_MKVTOMP4.cmd "YourFilename.mkv"
	echo.
	goto EXIT
)

dir /b/ad "%~1" >nul 2>nul && set DIRFOUND=TRUE
if "!DIRFOUND!"=="TRUE" goto :MPREPARE
if /i "%~x1"==".mkv" set "MKVExtract=TRUE" & goto CHECK

goto :FALSEINPUT

:CHECK
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
FOR /F "delims=" %%A IN ('findstr /C:"dvhe.05" "!TMP_FOLDER!\Info.txt"') DO set "HDRFormat=IPT-PQ-C2"
FOR /F "delims=" %%A IN ('findstr /C:"HLG" "!TMP_FOLDER!\Info.txt"') DO set "HDRFormat=HLG"

::SET DV FORMAT
"!MEDIAINFOpath!" --output=Video;%%HDR_Format_Profile%% "!INFOSTREAM!">"!TMP_FOLDER!\Info.txt"
FOR /F "delims=" %%A IN ('findstr /C:".08" "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES" & set "DVprofile=8"
FOR /F "delims=" %%A IN ('findstr /C:".07" "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES" & set "DVprofile=7"
FOR /F "delims=" %%A IN ('findstr /C:".06" "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES" & set "DVprofile=6"
FOR /F "delims=" %%A IN ('findstr /C:".05" "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES" & set "DVprofile=5"
FOR /F "delims=" %%A IN ('findstr /C:".04" "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES" & set "DVprofile=4"
FOR /F "delims=" %%A IN ('findstr /C:".03" "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES" & set "DVprofile=3"

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

:MPREPARE
set "SOURCE_FOLDER=%~1"
set /A "FERRORCOUNT=0" & set "FERRORCOUNTC=08"
set /A "DONECOUNT=0" & set "DONECOUNTC=08"
set /A "SKIPCOUNT=0" & set "SKIPCOUNTC=08"
set /A "PFILECOUNT=0" & set "PFILECOUNTC=08"
for /F %%i in ('dir "!SOURCE_FOLDER!\*.mkv" /B /A-d') do set /A SOURCEFILES=!SOURCEFILES!+1>nul
goto :START

:START
if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
set "LOG_FILENAME=DDVT MKVtoMP4 (%~nx1)"
if "!DV_Profile!"=="8" set "FAKEP5ALLOWED=TRUE"
if "!DIRFOUND!"=="TRUE" set "FAKEP5ALLOWED=TRUE"
cls
%GREEN%
echo  powered by quietvoids tools                                                                  Copyright ^(c^) 2021-2025 QfG
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool MKVtoMP4
%WHITE%
echo                                         ====================================
echo.
echo.
if "!DIRFOUND!"=="FALSE" (
	echo  == VIDEO INPUT =========================================================================================================
	echo.
	%CYAN%
	echo Filename   = [!INPUTFILENAME!!INPUTFILEEXT!]
	echo Video Info = [Resolution = !RESOLUTION!] [Codec = !CODEC_NAME!] [Frames = !FRAMES!] [FPS = !FRAMERATE!]
	echo HDR Info   = [!HDR_Info!]
) else (
	echo  == MASS CONVERTER SETTINGS =============================================================================================
	echo.
	call :colortxt 0B "Info       = [MKV FILES PROCESS/SUM: " & call :colortxt !PFILECOUNTC! "!PFILECOUNT!" & call :colortxt 0B "/!SOURCEFILES!" & call :colortxt 0B "] [DONE: " & call :colortxt !DONECOUNTC! "!DONECOUNT!" & call :colortxt 0B "] [ERROR(S): " & call :colortxt !FERRORCOUNTC! "!FERRORCOUNT!" & call :colortxt 0B "] [SKIPPED: " & call :colortxt !SKIPCOUNTC! "!SKIPCOUNT!" & call :colortxt 0B "]" /n
)
echo.
%YELLOW%
echo Be sure that there no picture based subtitles in your MKV file (PGS or VobSub)^^!
echo Only textbased subtitles supported.
echo.
echo Please check your Audio Codec and the MP4 specifications. You can switch the 
echo Audio Codec if the source is not compatible with MP4 container.
echo.
%WHITE%
echo  == MENU ================================================================================================================
echo.
echo 1. Audio Codec                    : [!AUDIOCODEC!]
if "%FAKEP5ALLOWED%"=="TRUE" call :colortxt 0F "2. Fake Profile 5                 : [%FAKEP5%]" & call :colortxt 0E "* *Set Option to [YES] for watching video on old [LG] or [SAMSUNG] TVs." /n
echo.
echo S. START
echo.
%GREEN%
echo Change Settings and press [S] to start Converting^^!
if "%FAKEP5ALLOWED%"=="TRUE" (
	CHOICE /C 12S /N /M "Select a Letter 1,2,[S]tart"
) else (
	CHOICE /C 1S /N /M "Select a Letter 1,[S]tart"
)
if "%FAKEP5ALLOWED%"=="TRUE" (
	if "%ERRORLEVEL%"=="3" (
		if "%DIRFOUND%"=="TRUE" goto :MBEGIN
		if "%DIRFOUND%"=="FALSE" goto :BEGIN
	)
	if "%ERRORLEVEL%"=="2" (
		if "%FAKEP5%"=="YES" set "FAKEP5=NO"
		if "%FAKEP5%"=="NO" set "FAKEP5=YES"
	)
	if "%ERRORLEVEL%"=="1" (
		if "%AUDIOCODEC%"=="Untouched" set "AUDIOCODEC=eAC-3 @640k"
		if "%AUDIOCODEC%"=="eAC-3 @640k" set "AUDIOCODEC=AC-3 @640k"
		if "%AUDIOCODEC%"=="AC-3 @640k" set "AUDIOCODEC=AAC @High Quality"
		if "%AUDIOCODEC%"=="AAC @High Quality" set "AUDIOCODEC=Untouched"
	)	
) else (
	if "%ERRORLEVEL%"=="2" goto BEGIN
	if "%ERRORLEVEL%"=="1" (
		if "%AUDIOCODEC%"=="Untouched" set "AUDIOCODEC=eAC-3 @640k"
		if "%AUDIOCODEC%"=="eAC-3 @640k" set "AUDIOCODEC=AC-3 @640k"
		if "%AUDIOCODEC%"=="AC-3 @640k" set "AUDIOCODEC=AAC @High Quality"
		if "%AUDIOCODEC%"=="AAC @High Quality" set "AUDIOCODEC=Untouched"
	)
)
goto START

:MBEGIN
set "FAKEP5O=%FAKEP5%"
if "!TARGET_FOLDER_TYPE!"=="SOURCE" set "TARGET_FOLDER=!TARGET_FOLDER!\%~n1"
if not exist "!TMP_FOLDER!" MD "!TMP_FOLDER!">nul
if not exist "!TARGET_FOLDER!" MD "!TARGET_FOLDER!">nul
set "LOG_FILENAME=DDVT MKVtoMP4 (Folder=%~n1)"
rem -------- LOGFILE ------------
echo  powered by quietvoids tools                                                                  Copyright ^(c^) 2021-2025 QfG>"!logfile!"
echo.>>"!logfile!"
echo                                         ====================================>>"!logfile!"
echo                                              Dolby Vision Tool MKVtoMP4>>"!logfile!"
echo                                         ====================================>>"!logfile!"
echo.>>"!logfile!"
echo.>>"!logfile!"
echo.>>"!logfile!"
echo  == LOGFILE START =======================================================================================================>>"!logfile!"
echo.>>"!logfile!"
echo %date%  %time%>>"!logfile!"
echo.>>"!logfile!"
for %%A in ("!SOURCE_FOLDER!\*.mkv") do (
	set /A "PFILECOUNT=!PFILECOUNT!+1"
	if "!FERRORCOUNT!" NEQ "0" (
		set "FERRORCOUNTC=0C"
	) else (
		set "FERRORCOUNTC=0A"
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
	if "!PFILECOUNT!" NEQ "0" set "PFILECOUNTC=0F"
	set "INPUTFILE=%%~dpnxA"
	set "INPUTFILEPATH=%%~dpA"
	set "INPUTFILENAME=%%~nA"
	set "INPUTFILEEXT=%%~xA"
	call :CHECK
	cls
	%GREEN%
	echo  powered by quietvoids tools                                                                  Copyright ^(c^) 2021-2025 QfG
	echo.
	%WHITE%
	echo                                         ====================================
	%GREEN%
	echo                                              Dolby Vision Tool MKVtoMP4
	%WHITE%
	echo                                         ====================================
	echo.	
	echo.
	echo  == MASS CONVERTER OPERATION ============================================================================================
	echo.
	%CYAN%
	call :colortxt 0B "Info       = [MKV FILES PROCESS/SUM: " & call :colortxt !PFILECOUNTC! "!PFILECOUNT!" & call :colortxt 0B "/!SOURCEFILES!" & call :colortxt 0B "] [DONE: " & call :colortxt !DONECOUNTC! "!DONECOUNT!" & call :colortxt 0B "] [ERROR(S): " & call :colortxt !FERRORCOUNTC! "!FERRORCOUNT!" & call :colortxt 0B "] [SKIPPED: " & call :colortxt !SKIPCOUNTC! "!SKIPCOUNT!" & call :colortxt 0B "]" /n
	echo Filename   = [!INPUTFILENAME!!INPUTFILEEXT!]
	echo Video Info = [Resolution = !RESOLUTION!] [Codec = !CODEC_NAME!] [Frames = !FRAMES!] [FPS = !FRAMERATE!]
	echo HDR Info   = [!HDR_Info!]
	set "FAKEP5=%FAKEP5O%"
	if  "!DV_Profile!" NEQ "8" set "FAKEP5=NO"
	call :BEGIN
)
cls
%GREEN%
echo  powered by quietvoids tools                                                                  Copyright ^(c^) 2021-2025 QfG
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool MKVtoMP4
%WHITE%
echo                                         ====================================
echo.	
echo.
echo  == MASS CONVERTER OPERATION ============================================================================================
echo.
%CYAN%
call :colortxt 0B "Info       = [MKV FILES PROCESS/SUM: " & call :colortxt !PFILECOUNTC! "!PFILECOUNT!" & call :colortxt 0B "/!SOURCEFILES!" & call :colortxt 0B "] [DONE: " & call :colortxt !DONECOUNTC! "!DONECOUNT!" & call :colortxt 0B "] [ERROR(S): " & call :colortxt !FERRORCOUNTC! "!FERRORCOUNT!" & call :colortxt 0B "] [SKIPPED: " & call :colortxt !SKIPCOUNTC! "!SKIPCOUNT!" & call :colortxt 0B "]" /n
echo Filename   = [!INPUTFILENAME!!INPUTFILEEXT!]
echo Video Info = [Resolution = !RESOLUTION!] [Codec = !CODEC_NAME!] [Frames = !FRAMES!] [FPS = !FRAMERATE!]
echo HDR Info   = [!HDR_Info!]
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
echo [PROCESSED FILES^: !PFILECOUNT!] [DONE^: !DONECOUNT!/!PFILECOUNT!] [SKIPPED^: !SKIPCOUNT!/!PFILECOUNT!] [ERROR^(S^)^: !FERRORCOUNT!/!PFILECOUNT!]>>"!logfile!"
echo.>>"!logfile!"
echo  == LOGFILE END =========================================================================================================>>"!logfile!"
echo.>>"!logfile!"
echo %date%  %time%>>"!logfile!"
goto :EXIT

:BEGIN
if not exist "!TMP_FOLDER!" MD "!TMP_FOLDER!">nul
if not exist "!TARGET_FOLDER!" MD "!TARGET_FOLDER!">nul
set "WORKFILE=!INPUTFILE!"
if "!DIRFOUND!"=="FALSE" (
	rem -------- LOGFILE ------------
	echo  powered by quietvoids tools                                                                  Copyright ^(c^) 2021-2025 QfG>"!logfile!"
	echo.>>"!logfile!"
	echo                                         ====================================>>"!logfile!"
	echo                                              Dolby Vision Tool MKVtoMP4>>"!logfile!"
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
	echo  powered by quietvoids tools                                                                  Copyright ^(c^) 2021-2025 QfG
	echo.
	%WHITE%
	echo                                         ====================================
	%GREEN%
	echo                                              Dolby Vision Tool MKVtoMP4
	%WHITE%
	echo                                         ====================================
	echo.
	echo.
	echo  == VIDEO INPUT =========================================================================================================
	echo.
	%CYAN%
	echo Filename   = [!INPUTFILENAME!]
	echo Video Info = [Resolution = !RESOLUTION!] [Codec = !CODEC_NAME!] [Frames = !FRAMES!] [FPS = !FRAMERATE!]
	echo HDR Info   = [!HDR_Info!]
)
echo.
%WHITE%
echo  == CONVERTING ==========================================================================================================
echo.
set "duration="
if "%FRAMERATE%"=="23.976" set "duration=--fps 0:24000/1001"
if "%FRAMERATE%"=="24.000" set "duration=--fps 0:24"
if "%FRAMERATE%"=="25.000" set "duration=--fps 0:25"
if "%FRAMERATE%"=="30.000" set "duration=--fps 0:30"
if "%FRAMERATE%"=="48.000" set "duration=--fps 0:48"
if "%FRAMERATE%"=="50.000" set "duration=--fps 0:35"
if "%FRAMERATE%"=="60.000" set "duration=--fps 0:60"

IF "%AUDIOCODEC%"=="Untouched" set "AUDIOCODECC=-c:a copy" & set "DRC="
IF "%AUDIOCODEC%"=="eAC-3 @640k" set "AUDIOCODECC=-c:a eac3 -b:a 640k" & set "DRC=-drc_scale 0"
IF "%AUDIOCODEC%"=="AC-3 @640k" set "AUDIOCODECC=-c:a ac3 -b:a 640k" & set "DRC=-drc_scale 0"
IF "%AUDIOCODEC%"=="AAC @High Quality" set "AUDIOCODECC=-c:a aac -vbr 5" & set "DRC=-drc_scale 0"

if "!FAKEP5!"=="YES" (
	%CYAN%
	echo Converting DV Profile 8 to fake Profile 5. Please wait...
	%WHITE%
	"!FFMPEGpath!" -loglevel panic -stats -y -i "!INPUTFILE!" -c:v copy -bsf:v hevc_metadata -f hevc "!TMP_FOLDER!\temp.hevc"
	if exist "!TMP_FOLDER!\temp.hevc" (
		%CYAN%
		echo.
		echo Processing.Please wait...
		%WHITE%
		"!MP4MUXERpath!" --dv-profile 5 --input-file "!TMP_FOLDER!\temp.hevc" --output-file "!TMP_FOLDER!\temp.mp4">nul
	) else (
		%RED%
		echo Error.
		echo.
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	)
	if exist "!TMP_FOLDER!\temp.mp4" (
		"!FFMPEGpath!" %DRC% -y -i "!INPUTFILE!" -i "!TMP_FOLDER!\temp.mp4" -strict experimental -loglevel panic -stats -map 1:v? -map 0:a? -map 0:s? -dn -map_chapters -1 -movflags +faststart -c:v copy !AUDIOCODECC! -c:s mov_text -strict -2 "!TARGET_FOLDER!\!INPUTFILENAME!.mp4"
	) else (
		%RED%
		echo Error.
		echo.
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	)	
) else (
	%CYAN%
	echo Converting MKV to MP4. Please wait...
	%WHITE%
	"!FFMPEGpath!" %DRC% -y -i "!INPUTFILE!" -strict experimental -loglevel panic -stats -map 0:v? -map 0:a? -map 0:s? -dn -map_chapters -1 -movflags +faststart -c:v copy !AUDIOCODECC! -c:s mov_text -strict -2 "!TARGET_FOLDER!\!INPUTFILENAME!.mp4"
)
if exist "!TARGET_FOLDER!\!INPUTFILENAME!.mp4" (
	%GREEN%
	"!MP4FPSMODpath!" -i !duration! "!TARGET_FOLDER!\!INPUTFILENAME!.mp4"
	set /A DONECOUNT=!DONECOUNT!+1
	echo ^[!INPUTFILENAME!!INPUTFILEEXT!^] ^[AUDIO=!AUDIOCODEC!^] ^[FAKEP5=!FAKEP5!^] ^[CONVERT=DONE^] -^> ^[!INPUTFILENAME!.mp4^] >>"!logfile!"
	echo.
) else (
	%RED%
	echo Error.
	echo ^[!INPUTFILENAME!!INPUTFILEEXT!^] ^[AUDIO=!AUDIOCODEC!^] ^[FAKEP5=!FAKEP5!^] ^[CONVERT=ERROR^^!^] >>"!logfile!"
	echo.
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	set /A "FERRORCOUNT=!FERRORCOUNT!+1"
)
if "!DIRFOUND!"=="TRUE" goto :eof
echo.>>"!logfile!"
echo  == LOGFILE END =========================================================================================================>>"!logfile!"
echo.>>"!logfile!"
echo %date%  %time%>>"!logfile!"
goto :EXIT

:EXIT
if exist "!logfile!" move "!logfile!" "!TARGET_FOLDER!\!LOG_FILENAME!.log" >nul
%WHITE%
echo  == CLEANING ============================================================================================================
echo.
%CYAN%
echo Please wait. Cleaning Temp Folder...
if exist "!TMP_FOLDER!" (
	RD /S /Q "!TMP_FOLDER!">nul
	if "%ERRORLEVEL%"=="0" (
		%GREEN%
		echo Deleting Temp Folder - Done.
	) else (
		%RED%
		echo Deleting Temp Folder - Error.
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
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
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('NEEDED FILE NOT FOUND!' + %NewLine% + %NewLine% + '%Line1%' + %NewLine% + %NewLine% + '%Line2%', 'DDVT MKVtoMP4 [QfG] v%version%', 'Ok','Error')"
exit

:FALSEINPUT
if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
set "NewLine=[System.Environment]::NewLine"
set "Line1=Unsupported Input File. Supported Files are:"
set "Line2=*.mkv"
setlocal DisableDelayedExpansion
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('%INPUTFILENAME%%INPUTFILEEXT%' + %NewLine% + %NewLine% + '%Line1%' + %NewLine% + %NewLine% + '%Line2%', 'DDVT MKVtoMP4 [QfG] v%version%', 'Ok','Info')"
exit

:ERROR
if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
set "NewLine=[System.Environment]::NewLine"
set "Line1=%ERRORCOUNT% Error(s) during processing^!
set "Line2=Target file don''t exist or corrupt.
setlocal DisableDelayedExpansion
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('%INPUTFILENAME%%INPUTFILEEXT%' + %NewLine% + %NewLine% + '%Line1%' + %NewLine% + %NewLine% + '%Line2%', 'DDVT MKVtoMP4 [QfG] v%VERSION%', 'Ok','Error')"
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