@echo off & setlocal
mode con cols=125 lines=55
set "VERSION=--N.A.-- INCORRECTLY INSTALLED"
set "HEADER1=File "%~dp0DDVT_OPTIONS.cmd" missing! Script works not correctly!"
FOR /F "tokens=2 delims==" %%A IN ('findstr /C:"VERSION=" "%~dp0DDVT_OPTIONS.cmd"') DO set "VERSION=%%A"
FOR /F "tokens=2 delims==" %%A IN ('findstr /C:"HEADER1=" "%~dp0DDVT_OPTIONS.cmd"') DO set "HEADER1=%%A"
TITLE DDVT Demuxer v%VERSION%
set DESIGN=STANDARD

set PasswordChars=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890
set PasswordLength=5
call :CreatePassword Password

set "Cecho=%~dp0tools\cecho_x64.exe" rem Path to cecho_x64.exe
set "sfkpath=%~dp0tools\sfk.exe" rem Path to sfk.exe
set "jqpath=%~dp0tools\jq-win64.exe" rem Path to jq.exe
set "FFMPEGpath=%~dp0tools\ffmpeg.exe" rem Path to ffmpeg.exe
set "FFPROBEpath=%~dp0tools\ffprobe.exe" rem Path to ffprobe.exe
set "MP4BOXpath=%~dp0tools\mp4box.exe" rem Path to mp4box.exe
set "MEDIAINFOpath=%~dp0tools\mediainfo.exe" rem Path to mediainfo.exe
set "DO_VI_TOOLpath=%~dp0tools\dovi_tool.exe" rem Path to dovi_tool.exe
set "DOVI_METApath=%~dp0tools\dovi_meta.exe" rem Path to dovi_meta.exe
set "HDR10P_TOOLpath=%~dp0tools\hdr10plus_tool.exe" rem Path to hdr10plus_tool.exe

rem --- Hardcoded settings. Can be changed manually ---
set "CONVERT=PROFILE 8.1 HDR10"
:: PROFILE 8.1 HDR10 / PROFILE 7 MEL / PROFILE 8.4 HLG / NO --> Predefined convert profiles for RPU extraction.
set "CHGHDR10P=YES"
:: YES / NO --> Convert HDR10+ SEI to DV RPU.
set "REMHDR10P=NO"
:: YES / NO --> Remove HDR10+ SEI from BL.
set "SAVHDR10P=YES"
:: YES / NO --> Save HDR10+ SEI as JSON.
set "SKIPHDR10P=NO"
:: YES / NO --> Skip validation test for HDR10+ SEI.
set "CM_VERSION=V40"
:: V40 / V29 --> Set CMv for converting HDR10+ SEI to RPU.
set "CROP=NO"
:: YES / NO --> If yes the Active Area from the RPU will set to 0,0,0,0. Helpful for cropped videos.
set "BL=NO"
:: YES / NO --> Save BL in target folder.
set "EL=NO"
:: YES / NO --> Save EL in target folder.
set "RPU=YES"
:: YES / NO --> Save RPUin target folder.
set "FORCE_FFMPEG_DEMUXING=NO"
:: Use FFMPEG as default demuxing engine instead of MKVExtract/Mp4Box.
:: YES / NO

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
set "HDR=FALSE"
set "HDR10P=FALSE"
set "DV=FALSE"
set "HDR10P=FALSE"
set "ELFILE=FALSE"
set "DV=FALSE"
set "REMHDR10PString="
set "SKIPHDR10PString="
set "EXTSTRING="
set "RESOLUTION=N/A"
set "HDR=N/A"
set "CODEC_NAME=N/A"
set "FRAMERATE=N/A"
set "FRAMES=N/A"
set "RAW_FILE=FALSE"
set "RPU_FILE=FALSE"
set "DEMUX_RPU=FALSE"
set /a "ERRORCOUNT=0"

setlocal EnableDelayedExpansion

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
	FOR /F "delims=" %%A IN ('findstr /C:"DESIGN=" "%~dp0DDVT_OPTIONS.ini"') DO (
		set "DESIGN=%%A"
		set "DESIGN=!DESIGN:~7!"
	)
)

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

if "!DESIGN!" NEQ "STANDARD" call "!DESIGN!"

if "!MKVTOOLNIX_FOLDER!"=="INCLUDED" set "MKVTOOLNIX_FOLDER=%~dp0tools"
set "MKVMERGEpath=!MKVTOOLNIX_FOLDER!\mkvmerge.exe"
set "MKVEXTRACTpath=!MKVTOOLNIX_FOLDER!\mkvextract.exe"

if not exist "%Cecho%" set "MISSINGFILE=%~dp0tools\cecho_x64.exe" & goto :CORRUPTFILE
if not exist "%sfkpath%" set "MISSINGFILE=%sfkpath%" & goto :CORRUPTFILE
if not exist "%FFMPEGpath%" set "MISSINGFILE=%FFMPEGpath%" & goto :CORRUPTFILE
if not exist "%FFPROBEpath%" set "MISSINGFILE=%FFPROBEpath%" & goto :CORRUPTFILE
if not exist "%JQpath%" set "MISSINGFILE=%JQpath%" & goto :CORRUPTFILE
if not exist "%MP4BOXpath%" set "MISSINGFILE=%MP4BOXpath%" & goto :CORRUPTFILE
if not exist "%MEDIAINFOpath%" set "MISSINGFILE=%MEDIAINFOpath%" & goto :CORRUPTFILE
if not exist "%DO_VI_TOOLpath%" set "MISSINGFILE=%DO_VI_TOOLpath%" & goto :CORRUPTFILE
if not exist "%HDR10P_TOOLpath%" set "MISSINGFILE=%HDR10P_TOOLpath%" & goto :CORRUPTFILE
if not exist "%DOVI_METApath%" set "MISSINGFILE=%DOVI_METApath%" & goto :CORRUPTFILE
if not exist "%MKVMERGEpath%" set "MISSINGFILE=%MKVMERGEpath%" & goto :CORRUPTFILE
if not exist "%MKVEXTRACTpath%" set "MISSINGFILE=%MKVEXTRACTpath%" & goto :CORRUPTFILE

if /i "!INPUTFILEEXT!"=="" CALL :INSERT_INPUT

if "%TMP_FOLDER%"=="SAME AS SOURCE" (
	set "TMP_FOLDER=!INPUTFILEPATH!DDVT_%Password%_TMP"
) else (
	set "TMP_FOLDER=!TMP_FOLDER!\DDVT_%Password%_TMP"
)
set "logfile=%TMP_FOLDER%\!INPUTFILENAME!.log"
if "!TARGET_FOLDER!"=="SAME AS SOURCE" (
	set "TARGET_FOLDER=!INPUTFILEPATH!"
	set "TARGET_FOLDER=!TARGET_FOLDER:~0,-1!"
)

if /i "!INPUTFILEEXT!"==".hevc" set "RAW_FILE=TRUE" & goto CHECK
if /i "!INPUTFILEEXT!"==".h265" set "RAW_FILE=TRUE" & goto CHECK
if /i "!INPUTFILEEXT!"==".m2ts" set "M2TS_FILE=TRUE" & goto CHECK
if /i "!INPUTFILEEXT!"==".mkv" set "MKVExtract=TRUE" & goto CHECK
if /i "!INPUTFILEEXT!"==".mp4" set "MP4Extract=TRUE" & goto CHECK
if /i "!INPUTFILEEXT!"==".bin" set "RPU_FILE=TRUE" & set "RPU=!INPUTFILE!" & goto CHECK
goto :FALSEINPUT

:INSERT_INPUT
cls
%GREEN%
echo  !HEADER1!
%WHITE%
echo.
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool DEMUXER
%WHITE%
echo                                         ====================================
echo.
echo.
echo  == INSERT FILE HERE ====================================================================================================
%HCYELLOW%
echo.
echo [Info] Insert one file with following extensions:
echo        .bin ^| .mp4 ^| .mkv ^| .m2ts ^| .h265 ^| .hevc
echo.
%WHITE%
"!Cecho!" {%_WHITE%}Drag 'n' Drop {%_GREEN%}FILE {%_WHITE%}here and press ENTER:{#}{\n}
%GREEN%
set /p "INPUTFILE=%~1" || if "!INPUTFILE!"=="" goto :INSERT_INPUT

for %%f in (!INPUTFILE!) do set "INPUTFILENAME=%%~nf"
for %%f in (!INPUTFILE!) do set "INPUTFILEEXT=%%~xf"
for %%f in (!INPUTFILE!) do set "INPUTFILEPATH=%%~dpf"
for %%f in (!INPUTFILE!) do set "INPUTFILE=%%~dpnxf"

goto :eof

:CHECK
CLS
%GREEN%
echo  !HEADER1!
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool DEMUXER
%WHITE%
echo                                         ====================================
%WHITE%
echo.
echo.
echo  == CHECK INPUT FILE ====================================================================================================
if not exist "!TMP_FOLDER!" MD "!TMP_FOLDER!">nul
echo.
%CYAN%
echo Analysing File. Please wait...
if "!RPU_FILE!"=="FALSE" (
	echo.
	::SET BL EL STREAMINDEX
	call :ANALYSESTREAMS
	set "INFOSTREAM=!INPUTFILE!"
	FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=General;%%VideoCount%% "!INFOSTREAM!""') do set "VIDEO_COUNT=%%A"
	if "!RAW_FILE!"=="TRUE" (
		"!MKVMERGEpath!" --ui-language en --priority higher --output ^"!TMP_FOLDER!\Info.mkv^" --language 0:und --compression 0:none ^"^(^" ^"!INPUTFILE!^" ^"^)^" --split parts:00:00:00-00:00:01 -q
		if exist "!TMP_FOLDER!\Info.mkv" set "INFOSTREAM=!TMP_FOLDER!\Info.mkv"
	)
	if "!M2TS_FILE!"=="TRUE" (
		"!MKVMERGEpath!" --ui-language en --priority higher --output ^"!TMP_FOLDER!\Info.mkv^" --language 0:und --compression 0:none ^"^(^" ^"!INPUTFILE!^" ^"^)^" --split parts:00:00:00-00:00:01 -q
		if exist "!TMP_FOLDER!\Info.mkv" set "INFOSTREAM=!TMP_FOLDER!\Info.mkv"
	)
	::SET HDR FORMAT
	if exist "!TMP_FOLDER!\Info.mkv" (
		"!MEDIAINFOpath!" --output=Video;%%HDR_Format_String%% "!INFOSTREAM!">"!TMP_FOLDER!\Info.txt"
		FOR /F "delims=" %%A IN ('findstr /C:"Dolby Vision" "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES"
		FOR /F "delims=" %%A IN ('findstr /C:"HDR10" "!TMP_FOLDER!\Info.txt"') DO set "HDRFormat=HDR10"
		FOR /F "delims=" %%A IN ('findstr /C:"HDR10+" "!TMP_FOLDER!\Info.txt"') DO set "HDRFormat=HDR10+"
		FOR /F "delims=" %%A IN ('findstr /C:"dvhe.05" "!TMP_FOLDER!\Info.txt"') DO set "HDRFormat=IPT-PQ-C2"
		FOR /F "delims=" %%A IN ('findstr /C:"HLG" "!TMP_FOLDER!\Info.txt"') DO set "HDRFormat=HLG"
	)
	if not defined HDRFormat (
		"!MEDIAINFOpath!" --output=Video;%%HDR_Format_String%% "!INPUTFILE!">"!TMP_FOLDER!\Info.txt"
		FOR /F "delims=" %%A IN ('findstr /C:"Dolby Vision" "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES"
		FOR /F "delims=" %%A IN ('findstr /C:"HDR10" "!TMP_FOLDER!\Info.txt"') DO set "HDRFormat=HDR10"
		FOR /F "delims=" %%A IN ('findstr /C:"HDR10+" "!TMP_FOLDER!\Info.txt"') DO set "HDRFormat=HDR10+"
		FOR /F "delims=" %%A IN ('findstr /C:"dvhe.05" "!TMP_FOLDER!\Info.txt"') DO set "HDRFormat=IPT-PQ-C2"
		FOR /F "delims=" %%A IN ('findstr /C:"HLG" "!TMP_FOLDER!\Info.txt"') DO set "HDRFormat=HLG"
	)
	if not defined HDRFormat set "HDRFormat=SDR"

	::SET DV FORMAT
	if exist "!TMP_FOLDER!\Info.mkv" (
		"!MEDIAINFOpath!" --output=Video;%%HDR_Format_Profile%% "!INFOSTREAM!">"!TMP_FOLDER!\Info.txt">nul
		FOR /F "delims=" %%A IN ('findstr /C:".08." "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES" & set "DVprofile=8"
		FOR /F "delims=" %%A IN ('findstr /C:".07." "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES" & set "DVprofile=7"
		FOR /F "delims=" %%A IN ('findstr /C:".06." "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES" & set "DVprofile=6"
		FOR /F "delims=" %%A IN ('findstr /C:".05." "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES" & set "DVprofile=5"
		FOR /F "delims=" %%A IN ('findstr /C:".04." "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES" & set "DVprofile=4"
		FOR /F "delims=" %%A IN ('findstr /C:".03." "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES" & set "DVprofile=3"
	)
	if not defined DVprofile (
		"!MEDIAINFOpath!" --output=Video;%%HDR_Format_Profile%% "!INPUTFILE!">"!TMP_FOLDER!\Info.txt">nul
		FOR /F "delims=" %%A IN ('findstr /C:".08." "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES" & set "DVprofile=8"
		FOR /F "delims=" %%A IN ('findstr /C:".07." "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES" & set "DVprofile=7"
		FOR /F "delims=" %%A IN ('findstr /C:".06." "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES" & set "DVprofile=6"
		FOR /F "delims=" %%A IN ('findstr /C:".05." "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES" & set "DVprofile=5"
		FOR /F "delims=" %%A IN ('findstr /C:".04." "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES" & set "DVprofile=4"
		FOR /F "delims=" %%A IN ('findstr /C:".03." "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES" & set "DVprofile=3"
	)

	::DEMUX RPU SAMPLE
	if "!DVinput!"=="YES" (
		if exist "!INFOSTREAM!" (
			"!FFMPEGpath!" -loglevel panic -i "!INFOSTREAM!" -c:v copy -to 1 -bsf:v hevc_mp4toannexb -f hevc - | "!DO_VI_TOOLpath!" extract-rpu -o "!TMP_FOLDER!\RPU.bin" - >nul 2>&1
			if exist "!TMP_FOLDER!\RPU.bin" (
				FOR /F "usebackq" %%A IN ('"!TMP_FOLDER!\RPU.bin"') DO set "RPUSIZE=%%~zA"
				if "!RPUSIZE!" NEQ "0" (
					set "RPU_EXIST=TRUE"
				) else (
					if exist "!TMP_FOLDER!\RPU.bin" del "!TMP_FOLDER!\RPU.bin" >nul
					set "RPU_EXIST=FALSE"
				)
			) else (
				set "RPU_EXIST=FALSE"
			)
		)
		if "!RPU_EXIST!"=="FALSE" (
			"!FFMPEGpath!" -loglevel panic -i "!INPUTFILE!" -map 0:!EL_INDEX! -c:v copy -to 1 -bsf:v hevc_mp4toannexb -f hevc - | "!DO_VI_TOOLpath!" extract-rpu -o "!TMP_FOLDER!\RPU.bin" - >nul 2>&1
			if exist "!TMP_FOLDER!\RPU.bin" (
				FOR /F "usebackq" %%A IN ('"!TMP_FOLDER!\RPU.bin"') DO set "RPUSIZE=%%~zA"
				if "!RPUSIZE!" NEQ "0" (
					set "RPU_EXIST=TRUE"
				)
			) else (
				"!FFMPEGpath!" -loglevel panic -i "!INFOSTREAM!" -c:v copy -to 1 -bsf:v hevc_mp4toannexb -f hevc - | "!DO_VI_TOOLpath!" extract-rpu -o "!TMP_FOLDER!\RPU.bin" - >nul 2>&1
				if exist "!TMP_FOLDER!\RPU.bin" (
					FOR /F "usebackq" %%A IN ('"!TMP_FOLDER!\RPU.bin"') DO set "RPUSIZE=%%~zA"
					if "!RPUSIZE!" NEQ "0" (
						set "RPU_EXIST=TRUE"
					) else (
						set "RPU_EXIST=FALSE"
					)
				) else (
					set "RPU_EXIST=FALSE"
				)
			)
		)
	)

	::BEGIN MEDIAINFO
	FOR /F "tokens=1 delims= " %%A in ('""!MEDIAINFOpath!" --output=Video;%%MaxCLL%% "!INFOSTREAM!""') do set "MaxCLL=%%A"
	if not defined MaxCLL set "MaxCLL=0"
	FOR /F "tokens=1 delims= " %%A in ('""!MEDIAINFOpath!" --output=Video;%%MaxFALL%% "!INFOSTREAM!""') do set "MaxFALL=%%A"
	if not defined MaxFALL set "MaxFALL=0"
	FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%MasteringDisplay_Luminance%% "!INFOSTREAM!""') do set "Luminance=%%A"
	if not defined Luminance (
		set "MinDML=1"
		set "MaxDML=1000"
		set "Luminance=N/A"
	) else (
		for /F "tokens=2" %%A in ("!Luminance!") do set "MinDML=%%A"
		for /F "tokens=* delims=0." %%A in ("!MinDML!") do set "MinDML=%%A"
		for /F "tokens=5" %%A in ("!Luminance!") do set "MaxDML=%%A"
	)

	::CODEC NAME
	FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%Format%%^-%%BitDepth%%Bit^-%%ColorSpace%%^-%%ChromaSubsampling%% "!INFOSTREAM!""') do set "CODEC_NAME=%%A"
	if not defined CODEC_NAME set "CODEC_NAME=N/A"
	::FRAMERATE
	FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%FrameRate/String%% "!INPUTFILE!""') do set "FRAMERATE=%%A"
	for /F "tokens=1-2 delims=FPS " %%A in ("!FRAMERATE!") do set "FRAMERATE=%%A"
	::RESOLUTION
	FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;"%%Width%%x x %%Height%%x" "!INPUTFILE!""') do set "RESOLUTION=%%A"
	for /F "tokens=1-4 delims=x " %%A in ("!RESOLUTION!") do (
		if "!DVprofile!%%A%%B"=="719201080" set "ELFILE=TRUE"
		set "RESOLUTION=%%Ax%%B"
	)
	::FRAMES
	FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%FrameCount%% "!INPUTFILE!""') do set "FRAMES=%%A"
	if "!HDRFormat!"=="HDR10" (
		set "HDR=TRUE"
		%HCGREEN%
		echo HDR10 found.
	)
	if "!HDRFormat!"=="HLG" (
		set "HDR=TRUE"
		%HCGREEN%
		echo HLG found.
	)
	if "!HDRFormat!"=="HDR10+" (
		set "HDR=TRUE"
		set "HDR10P=TRUE"
		%HCGREEN%
		echo HDR10+ SEI found.
	)
	if "!DVprofile!"=="8" (
		set "HDR=TRUE"
		set "DV=TRUE"
		set "DV_Profile=8"
		set "CONVERT=NO"
		%HCGREEN%
		echo Dolby Vision Profile 8 found.
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
		%HCGREEN%
		if "!ELFILE!"=="TRUE" (
			echo Dolby Vision Profile 7!subprofile!!LAYERTYPE! EL found.
		) else (
			echo Dolby Vision Profile 7!subprofile!!LAYERTYPE! found.
		)
		set "DV_Profile=7!subprofile!!LAYERTYPE!"
	)
	if "!DVprofile!"=="5" (
		set "HDR=FALSE"
		set "DV=TRUE"
		set "DV_Profile=5"
		%HCGREEN%
		echo Dolby Vision Profile 5 found.
	)
	if "!DVprofile!"=="4" (
		set "HDR=TRUE"
		set "DV=TRUE"
		set "DV_Profile=4"
		%HCGREEN%
		echo Dolby Vision Profile 4 found.
	)
	%HCGREEN%
	echo.
	if exist "!TMP_FOLDER!\Info.mkv" del "!TMP_FOLDER!\Info.mkv">nul
	if exist "!TMP_FOLDER!\BL.mkv" del "!TMP_FOLDER!\BL.mkv">nul
	if exist "!TMP_FOLDER!\RPU.bin" del "!TMP_FOLDER!\RPU.bin">nul
	if "!HDR!"=="TRUE" set "HDR_Info=!HDRFormat!"
	if "!HDR10P!"=="TRUE" set "HDR_Info=HDR10, !HDRFormat!"
	if "!DV!"=="TRUE" set "HDR_Info=Dolby Vision Profile !DV_Profile!"
	if "!HDR!!DV!"=="TRUETRUE" set "HDR_Info=!HDRFormat!, Dolby Vision Profile !DV_Profile!"
	if "!HDR10P!!DV!"=="TRUETRUE" set "HDR_Info=HDR10, !HDRFormat!, Dolby Vision Profile !DV_Profile!"
	if "!ELFILE!"=="TRUE" set "HDR_Info=Dolby Vision Profile !DV_Profile! Enhanced Layer [EL]"
	echo Analysing complete.
) else (
	"!DO_VI_TOOLpath!" info -s "!RPU!" >"!TMP_FOLDER!\RPUINFO.txt"
	if not exist "!TMP_FOLDER!\RPUINFO.txt" (
		%HCRED%
		echo.
		echo Corrupt RPU or not RPU File.
		echo.
		goto :EXIT
	) else (
		FOR /F "delims=" %%A IN ('findstr /C:"Frames" "!TMP_FOLDER!\RPUINFO.txt"') DO set "Frames=%%A"
		if defined Frames (
			for /F "tokens=2 delims=:/() " %%A in ("!Frames!") do set "Frames=%%A"
		) else (
			set "Frames=N/A"
		)
		%HCGREEN%
		echo.
		echo Analysing complete.
	)
)

::FIND DV PROFILE FOR RPU
if exist "!TMP_FOLDER!\RPUINFO.txt" (
	FOR /F "delims=" %%A IN ('findstr /C:"Profile" "!TMP_FOLDER!\RPUINFO.txt"') DO set "RPUProfile=%%A"
	if defined RPUProfile (
		for /F "tokens=2 delims=:/() " %%A in ("!RPUProfile!") do set "RPUProfile=%%A"
	) else (
		set "RPUProfile=N/A"
	)
	if "!RPUProfile!"=="7" (
		FOR /F "delims=" %%A IN ('findstr /C:"Profile" "!TMP_FOLDER!\RPUINFO.txt"') DO set "RPUSUBProfile=%%A"
		if defined RPUSUBProfile (
			for /F "tokens=3 delims=:/() " %%A in ("!RPUSUBProfile!") do set "RPUSUBProfile=%%A"
			set "RPUProfile=!RPUProfile! !RPUSUBProfile!"
		) else (
			set "RPUProfile=N/A"
		)
	)
	::FIND DM VERSION
	FOR /F "delims=" %%A IN ('findstr /C:"DM version" "!TMP_FOLDER!\RPUINFO.txt"') DO set "DM=%%A"
	if defined DM (
		for /F "tokens=3 delims=:/()" %%A in ("!DM!") do set "DM=%%A"
	) else (
		set "DM=N/A"
	)
)

if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul

if "!HDRFormat!"=="HLG" set "CONVERT=PROFILE 8.1 HDR10"

TIMEOUT 2 /NOBREAK>nul

:START
if "!RPU!"=="NO" set "CONVERT=NO"
if "!RPU_FILE!"=="TRUE" goto :STARTRPU
cls
%GREEN%
echo  !HEADER1!
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool DEMUXER
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
if "!DVprofile!"=="8" goto :DV8
if "!DVprofile!"=="7" goto :DV7
if "!DVprofile!"=="5" goto :DV5
if "!HDR10P!!DV!"=="TRUEFALSE" goto HDR10Plus
%HCYELLOW%
echo No HDR10^+ ^/ Dolby Vision found.
echo Abort Operation now.
echo.
goto :EXIT

:STARTRPU
if not exist "!TMP_FOLDER!" MD "!TMP_FOLDER!">nul
if not exist "!TARGET_FOLDER!" MD "!TARGET_FOLDER!">nul
cls
%GREEN%
echo  !HEADER1!
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool DEMUXER
%WHITE%
echo                                         ====================================
echo.
echo.
call :LOGFILESTART
echo  == INFORMATIONS ========================================================================================================>>"!logfile!"
echo.>>"!logfile!"
echo Filename : [!INPUTFILENAME!!INPUTFILEEXT!]>>"!logfile!"
echo RPU Info : [Profile = %RPUProfile%] [DM = %DM%] [Frames = %FRAMES%]>>"!logfile!"
echo.>>"!logfile!"
echo  == EXTRACTING ==========================================================================================================>>"!logfile!"
echo.>>"!logfile!"
echo  == RPU INPUT ===========================================================================================================
echo.
%CYAN%
echo Filename : [!INPUTFILENAME!!INPUTFILEEXT!]
echo RPU Info : [Profile = %RPUProfile%] [DM = %DM%] [Frames = %FRAMES%]
echo.
%WHITE%
echo  == EXTRACTING ==========================================================================================================
echo.
call :RPU_EXTRACT
goto :EXIT

:HDR10Plus
if "!CM_VERSION!"=="V40" set "CM_VERSION_text=4.0"
if "!CM_VERSION!"=="V29" set "CM_VERSION_text=2.9"
if "%SAVHDR10P%%CHGHDR10P%"=="NONO" set "SKIPHDR10P=NO"
echo  == MENU ================================================================================================================
%HCWHITE%
echo.
echo 1. Save BL                      : [%BL%]
echo 2. Save HDR10+ SEI              : [%SAVHDR10P%]
echo 3. Skip HDR10+ Validation       : [%SKIPHDR10P%]
echo 4. Remove HDR10+ SEI from BL    : [%REMHDR10P%]
echo 5. Convert HDR10+ SEI to DV RPU : [%CHGHDR10P%]
if "%CHGHDR10P%"=="YES" echo 6. Content Mapping Version      : [%CM_VERSION_text%]
echo.
%GREEN%
echo S. START
%HCWHITE%
echo.
"!Cecho!" {%HC_WHITE%}Change Settings and press [{%_GREEN%}S{%HC_WHITE%}] to start Extracting^^!{#}{\n}
if "%CHGHDR10P%"=="YES" (
	CHOICE /C 123456S /N /M "Select a Letter 1,2,3,4,5,6,[S]tart"
) else (
	CHOICE /C 12345S /N /M "Select a Letter 1,2,3,4,5,[S]tart"
)

if "%CHGHDR10P%"=="YES" (
	if "%ERRORLEVEL%"=="7" goto HDR10PlusEXT
) else (
	if "%ERRORLEVEL%"=="6" goto HDR10PlusEXT
)
if "%CHGHDR10P%"=="YES" (
	if "%ERRORLEVEL%"=="6" (
		if "%CM_VERSION%"=="V40" set "CM_VERSION=V29"
		if "%CM_VERSION%"=="V29" set "CM_VERSION=V40"
	)
)
if "%ERRORLEVEL%"=="5" (
	if "%CHGHDR10P%"=="NO" set "CHGHDR10P=YES"
	if "%CHGHDR10P%"=="YES" set "CHGHDR10P=NO"
)
if "%ERRORLEVEL%"=="4" (
	if "%REMHDR10P%"=="YES" set "REMHDR10P=NO"
	if "%REMHDR10P%"=="NO" (
		set "REMHDR10P=YES"
		set "BL=YES"
	)
)
if "%ERRORLEVEL%"=="3" (
	if "%SKIPHDR10P%"=="NO" (
		set "SKIPHDR10P=YES"
		if "%CHGHDR10P%"=="NO" set "SAVHDR10P=YES"
	)
	if "%SKIPHDR10P%"=="YES" set "SKIPHDR10P=NO"
)
if "%ERRORLEVEL%"=="2" (
	if "%SAVHDR10P%"=="NO" set "SAVHDR10P=YES"
	if "%SAVHDR10P%"=="YES" (
		set "SAVHDR10P=NO"
		set "SKIPHDR10P=NO"
	)
)	
if "%ERRORLEVEL%"=="1" (
	if "%BL%"=="NO" set "BL=YES"
	if "%BL%"=="YES" (
		set "BL=NO"
		set "REMHDR10P=NO"
	)
)
goto START

:HDR10PlusEXT
if not exist "!TMP_FOLDER!" MD "!TMP_FOLDER!">nul
if not exist "!TARGET_FOLDER!" MD "!TARGET_FOLDER!">nul
cls
%GREEN%
echo  !HEADER1!
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool DEMUXER
%WHITE%
echo                                         ====================================
echo.
echo.
if "!HDR10P!"=="TRUE" (set "HDR10PInfo_string=YES") else (set "HDR10PInfo_string=NO")
if "!DV!"=="TRUE" (set "DVInfo_string=YES - Profile !DV_Profile!") else (set "DVInfo_string=NO")

call :LOGFILESTART
echo  == INFORMATIONS ========================================================================================================>>"!logfile!"
echo.>>"!logfile!"
echo Filename : !INPUTFILENAME!>>"!logfile!"
echo Index    : Video Count [!VIDEO_COUNT!] ^| BL [!BL_INDEX!] ^| EL [!EL_INDEX!]>>"!logfile!"
echo HDR Info : HDR10+ [!HDR10PInfo_string!] ^| Dolby Vision [!DVInfo_string!]>>"!logfile!"
echo.>>"!logfile!"
echo  == SETTINGS ============================================================================================================>>"!logfile!"
echo.>>"!logfile!"
echo Save BL                      : [%BL%]>>"!logfile!"
echo Save HDR10+ SEI              : [%SAVHDR10P%]>>"!logfile!"
echo Skip HDR10+ Validation       : [%SKIPHDR10P%]>>"!logfile!"
echo Remove HDR10+ SEI from BL    : [%REMHDR10P%]>>"!logfile!"
echo Convert HDR10+ SEI to DV RPU : [%CHGHDR10P%]>>"!logfile!"
if "%CHGHDR10P%"=="YES" echo Content Mapping Version      : [%CM_VERSION_text%]>>"!logfile!"
echo.>>"!logfile!"
echo  == OPERATIONS ==========================================================================================================>>"!logfile!"
echo.>>"!logfile!"

call :SWITCHES

if "%RAW_FILE%"=="FALSE" call :DEMUX
if "%BL%"=="YES" call :DEMUX_BLEL
if "%SAVHDR10P%"=="YES" call :SAVE_HDR10P
if "%CHGHDR10P%"=="YES" call :CHG_HDR10P

goto :EXIT

:DV8
if "%HDR10P%"=="TRUE" goto DV8HDR10P
echo  == MENU ================================================================================================================
%HCWHITE%
echo.
echo 1. Save BL             : [%BL%]
echo 2. Save RPU            : [%RPU%]
echo 3. Convert RPU         : [%CONVERT%]
"!Cecho!" {%HC_WHITE%}4. Crop RPU{%HC_YELLOW%}*{%HC_WHITE%}           : [%CROP%]   {%HC_YELLOW%}*Whenever the final result doesn't have letterboxed bars set to {%HC_WHITE%}[YES]{%HC_YELLOW%}.{#}{\n}
echo.
%GREEN%
echo S. START
%HCWHITE%
echo.
"!Cecho!" {%HC_WHITE%}Change Settings and press [{%_GREEN%}S{%HC_WHITE%}] to start Extracting^^!{#}{\n}
CHOICE /C 1234S /N /M "Select a Letter 1,2,3,4,[S]tart"

if "%ERRORLEVEL%"=="5" goto DV8EXT
if "%ERRORLEVEL%"=="4" (
	if "%CROP%"=="YES" set "CROP=NO"
	if "%CROP%"=="NO" (
		set "CROP=YES"
		set "RPU=YES"
	)
)
if "%ERRORLEVEL%"=="3" (
	if "%CONVERT%"=="NO" (
		set "RPU=YES"
		set "CONVERT=PROFILE 8.1 HDR10"
	)
	if "%CONVERT%"=="PROFILE 8.1 HDR10" set "CONVERT=PROFILE 8.4 HLG"
	if "%CONVERT%"=="PROFILE 8.4 HLG" set "CONVERT=NO"
)
if "%ERRORLEVEL%"=="2" (
	if "%RPU%"=="NO" set "RPU=YES"
	if "%RPU%"=="YES" (
		set "RPU=NO"
		set "CROP=NO"
	)
)
if "%ERRORLEVEL%"=="1" (
	if "%BL%"=="NO" set "BL=YES"
	if "%BL%"=="YES" set "BL=NO"
)
goto START

:DV8HDR10P
if "%SAVHDR10P%%CHGHDR10P%"=="NONO" set "SKIPHDR10P=NO"
echo  == MENU ================================================================================================================
echo.
%HCWHITE%
echo 1. Save BL                      : [%BL%]
echo 2. Remove HDR10+ SEI from BL    : [%REMHDR10P%]
echo 3. Save HDR10+ SEI              : [%SAVHDR10P%]
echo 4. Convert HDR10+ SEI to DV RPU : [%CHGHDR10P%]
echo 5. Skip HDR10+ SEI Validation   : [%SKIPHDR10P%]
echo 6. Save RPU                     : [%RPU%]
echo 7. Convert RPU                  : [%CONVERT%]
"!Cecho!" {%HC_WHITE%}8. Crop RPU{%HC_YELLOW%}*                    {%HC_WHITE%}: [%CROP%]   {%HC_YELLOW%}*Whenever the final result doesn't have letterboxed bars set to {%HC_WHITE%}[YES]{%HC_YELLOW%}.{#}{\n}
echo.
%GREEN%
echo S. START
%HCWHITE%
echo.
"!Cecho!" {%HC_WHITE%}Change Settings and press [{%_GREEN%}S{%HC_WHITE%}] to start Extracting^^!{#}{\n}
CHOICE /C 12345678S /N /M "Select a Letter 1,2,3,4,5,6,7,8,[S]tart"

if "%ERRORLEVEL%"=="9" goto DV8EXT
if "%ERRORLEVEL%"=="8" (
	if "%CROP%"=="YES" set "CROP=NO"
	if "%CROP%"=="NO" (
		set "CROP=YES"
		set "RPU=YES"
	)
)
if "%ERRORLEVEL%"=="7" (
	if "%CONVERT%"=="NO" (
		set "RPU=YES"
		set "CONVERT=PROFILE 8.1 HDR10"
	)
	if "%CONVERT%"=="PROFILE 8.1 HDR10" set "CONVERT=PROFILE 8.4 HLG"
	if "%CONVERT%"=="PROFILE 8.4 HLG" set "CONVERT=NO"
)
if "%ERRORLEVEL%"=="6" (
	if "%RPU%"=="NO" set "RPU=YES"
	if "%RPU%"=="YES" (
		set "RPU=NO"
		set "CROP=NO"
	)
)
if "%ERRORLEVEL%"=="5" (
	if "%SKIPHDR10P%"=="NO" (
		if "%CHGHDR10P%"=="NO" set "SAVHDR10P=YES"
		set "SKIPHDR10P=YES"
	)
	if "%SKIPHDR10P%"=="YES" set "SKIPHDR10P=NO"
)	
if "%ERRORLEVEL%"=="4" (
	if "%CHGHDR10P%"=="NO" set "CHGHDR10P=YES"
	if "%CHGHDR10P%"=="YES" set "CHGHDR10P=NO"
)
if "%ERRORLEVEL%"=="3" (
	if "%SAVHDR10P%"=="NO" set "SAVHDR10P=YES"
	if "%SAVHDR10P%"=="YES" set "SAVHDR10P=NO"
)
if "%ERRORLEVEL%"=="2" (
	if "%REMHDR10P%"=="YES" set "REMHDR10P=NO"
	if "%REMHDR10P%"=="NO" (
		set "REMHDR10P=YES"
		set "BL=YES"
	)		
)
if "%ERRORLEVEL%"=="1" (
	if "%BL%"=="NO" set "BL=YES"
	if "%BL%"=="YES" (
		set "BL=NO"
		set "REMHDR10P=NO"
	)
)

goto START

:DV8EXT
if not exist "!TMP_FOLDER!" MD "!TMP_FOLDER!">nul
if not exist "!TARGET_FOLDER!" MD "!TARGET_FOLDER!">nul
cls
%GREEN%
echo  !HEADER1!
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool DEMUXER
%WHITE%
echo                                         ====================================
echo.
echo.
if "!HDR10P!"=="TRUE" (set "HDR10PInfo_string=YES") else (set "HDR10PInfo_string=NO")
if "!DV!"=="TRUE" (set "DVInfo_string=YES - Profile !DV_Profile!") else (set "DVInfo_string=NO")

call :LOGFILESTART
echo  == INFORMATIONS ========================================================================================================>>"!logfile!"
echo.>>"!logfile!"
echo Filename : !INPUTFILENAME!>>"!logfile!"
echo Index    : Video Count [!VIDEO_COUNT!] ^| BL [!BL_INDEX!] ^| EL [!EL_INDEX!]>>"!logfile!"
echo HDR Info : HDR10+ [!HDR10PInfo_string!] ^| Dolby Vision [!DVInfo_string!]>>"!logfile!"
echo.>>"!logfile!"
if "%HDR10P%"=="TRUE" (
	echo  == SETTINGS ============================================================================================================>>"!logfile!"
	echo.>>"!logfile!"
	echo Save BL                      : [%BL%]>>"!logfile!"
	echo Remove HDR10+ SEI from BL    : [%REMHDR10P%]>>"!logfile!"
	echo Save HDR10+ SEI              : [%SAVHDR10P%]>>"!logfile!"
	echo Convert HDR10+ SEI to DV RPU : [%CHGHDR10P%]>>"!logfile!"
	echo Skip HDR10+ SEI Validation   : [%SKIPHDR10P%]>>"!logfile!"
	echo Save RPU                     : [%RPU%]>>"!logfile!"
	echo Convert RPU                  : [%CONVERT%]>>"!logfile!"
	echo Crop RPU                     : [%CROP%]>>"!logfile!"
) else (
	echo  == SETTINGS ============================================================================================================>>"!logfile!"
	echo.>>"!logfile!"
	echo Save BL     : [%BL%]>>"!logfile!"
	echo Save RPU    : [%RPU%]>>"!logfile!"
	echo Convert RPU : [%CONVERT%]>>"!logfile!"
	echo Crop RPU    : [%CROP%]>>"!logfile!"
)
echo.>>"!logfile!"
echo  == OPERATIONS ==========================================================================================================>>"!logfile!"
echo.>>"!logfile!"

call :SWITCHES

if "%RAW_FILE%"=="FALSE" call :DEMUX
if "%SAVHDR10P%"=="YES" call :SAVE_HDR10P
if "%CHGHDR10P%"=="YES" call :CHG_HDR10P
if "%RPU%"=="YES" call :RPU_DEMUX
if "%BL%"=="YES" call :DEMUX_BLEL

goto :EXIT

:DV7
if "%ELFILE%"=="TRUE" (
	set "BL=NO"
	set "EL=NO"
)
if "%HDR10P%"=="TRUE" goto DV7HDR10P
echo  == MENU ================================================================================================================
echo.
%HCWHITE%
if "!ELFILE!"=="FALSE" "!Cecho!" {%HC_WHITE%}1. Save BL{%HC_YELLOW%}*    {%HC_WHITE%}: [%BL%]   {%HC_YELLOW%}*For creating a Dual layer Profile 7 Disc set to {%HC_WHITE%}[YES]{%HC_YELLOW%}.{#}{\n}
if "!ELFILE!"=="FALSE" "!Cecho!" {%HC_WHITE%}2. Save EL{%HC_YELLOW%}*    {%HC_WHITE%}: [%EL%]   {%HC_YELLOW%}*For creating a Dual layer Profile 7 Disc set to {%HC_WHITE%}[YES]{%HC_YELLOW%}.{#}{\n}
echo 3. Save RPU    : [%RPU%]
echo 4. Convert RPU : [%CONVERT%]
"!Cecho!" {%HC_WHITE%}5. Crop RPU{%HC_YELLOW%}*   {%HC_WHITE%}: [%CROP%]   {%HC_YELLOW%}*Whenever the final result doesn't have letterboxed bars set to {%HC_WHITE%}[YES]{%HC_YELLOW%}.{#}{\n}
echo.
%GREEN%
echo S. START
%HCWHITE%
echo.
"!Cecho!" {%HC_WHITE%}Change Settings and press [{%_GREEN%}S{%HC_WHITE%}] to start Extracting^^!{#}{\n}
CHOICE /C 12345S /N /M "Select a Letter 1,2,3,4,5,[S]tart"
if "%ERRORLEVEL%"=="6" goto DV7EXT
if "%ERRORLEVEL%"=="5" (
	if "%CROP%"=="YES" set "CROP=NO"
	if "%CROP%"=="NO" (
		set "CROP=YES"
		set "RPU=YES"
	)
)
if "%ERRORLEVEL%"=="4" (
	if "%CONVERT%"=="NO" (
		set "RPU=YES"
		set "CONVERT=PROFILE 8.1 HDR10"
	)
	if "%CONVERT%"=="PROFILE 8.1 HDR10" set "CONVERT=PROFILE 8.4 HLG"
	if "%CONVERT%"=="PROFILE 8.4 HLG" set "CONVERT=NO"
)
if "%ERRORLEVEL%"=="3" (
	if "%RPU%"=="NO" (
		set "RPU=YES"
		set "CONVERT=PROFILE 8.1 HDR10"
	)
	if "%RPU%"=="YES" (
		set "RPU=NO"
		set "CROP=NO"
		set "CONVERT=NO"
	)
)
if "%ERRORLEVEL%"=="2" (
	if "%EL%"=="NO" set "EL=YES" & set "RPU=NO" & set "CONVERT=NO"
	if "%EL%"=="YES" set "EL=NO" & set "RPU=YES" & set "CONVERT=PROFILE 8.1 HDR10"
)
if "%ERRORLEVEL%"=="1" (
	if "%BL%"=="NO" set "BL=YES"
	if "%BL%"=="YES" set "BL=NO"
)
goto START

:DV7HDR10P
if "%SAVHDR10P%%CHGHDR10P%"=="NONO" set "SKIPHDR10P=NO"
if "!ELFILE!"=="TRUE" (
	set "BL=NO"
	set "EL=NO"
)
echo  == MENU ================================================================================================================
echo.
%HCWHITE%
if "!ELFILE!"=="FALSE" "!Cecho!" {%HC_WHITE%}1. Save BL{%HC_YELLOW%}*                     {%HC_WHITE%}: [%BL%]   {%HC_YELLOW%}*For creating a Dual layer Profile 7 Disc set to {%HC_WHITE%}[YES]{%HC_YELLOW%}.{#}{\n}
echo 2. Remove HDR10+ SEI from BL    : [%REMHDR10P%]
echo 3. Save HDR10+ SEI              : [%SAVHDR10P%]
echo 4. Convert HDR10+ SEI to DV RPU : [%CHGHDR10P%]
echo 5. Skip HDR10+ Validation       : [%SKIPHDR10P%]
if "!ELFILE!"=="FALSE" "!Cecho!" {%HC_WHITE%}6. Save EL{%HC_YELLOW%}*                     {%HC_WHITE%}: [%EL%]   {%HC_YELLOW%}*For creating a Dual layer Profile 7 Disc set to {%HC_WHITE%}[YES]{%HC_YELLOW%}.{#}{\n}
echo 7. Save RPU                     : [%RPU%]
echo 8. Convert RPU                  : [%CONVERT%]
"!Cecho!" {%HC_WHITE%}9. Crop RPU{%HC_YELLOW%}*                    {%HC_WHITE%}: [%CROP%]   {%HC_YELLOW%}*Whenever the final result doesn't have letterboxed bars set to {%HC_WHITE%}[YES]{%HC_YELLOW%}.{#}{\n}
echo.
%GREEN%
echo S. START
%HCWHITE%
echo.
"!Cecho!" {%HC_WHITE%}Change Settings and press [{%_GREEN%}S{%HC_WHITE%}] to start Extracting^^!{#}{\n}
CHOICE /C 123456789S /N /M "Select a Letter 1,2,3,4,5,6,7,8,9,[S]tart"

if "%ERRORLEVEL%"=="10" goto DV7EXT
if "%ERRORLEVEL%"=="9" (
	if "%CROP%"=="YES" set "CROP=NO"
	if "%CROP%"=="NO" (
		set "CROP=YES"
		set "RPU=YES"
	)
)
if "%ERRORLEVEL%"=="8" (
	if "%CONVERT%"=="NO" (
		set "RPU=YES"
		set "CONVERT=PROFILE 8.1 HDR10"
	)
	if "%CONVERT%"=="PROFILE 8.1 HDR10" set "CONVERT=PROFILE 8.4 HLG"
	if "%CONVERT%"=="PROFILE 8.4 HLG" set "CONVERT=NO"
)
if "%ERRORLEVEL%"=="7" (
	if "%RPU%"=="NO" (
		set "RPU=YES"
		set "CONVERT=PROFILE 8.1 HDR10"
	)
	if "%RPU%"=="YES" (
		set "RPU=NO"
		set "CROP=NO"
		set "CONVERT=NO"
	)
)
if "%ERRORLEVEL%"=="6" (
	if "%EL%"=="NO" set "EL=YES" & set "RPU=NO" & set "CONVERT=NO"
	if "%EL%"=="YES" set "EL=NO" & set "RPU=YES" & set "CONVERT=PROFILE 8.1 HDR10"
)
if "%ERRORLEVEL%"=="5" (
	if "%SKIPHDR10P%"=="NO" (
		if "%SAVHDR10P%%CHGHDR10P%"=="NONO" set "SAVHDR10P=YES"
		set "SKIPHDR10P=YES"
	)
	if "%SKIPHDR10P%"=="YES" set "SKIPHDR10P=NO"
)
if "%ERRORLEVEL%"=="4" (
	if "%CHGHDR10P%"=="NO" set "CHGHDR10P=YES"
	if "%CHGHDR10P%"=="YES" set "CHGHDR10P=NO"
)
if "%ERRORLEVEL%"=="3" (
	if "%SAVHDR10P%"=="NO" set "SAVHDR10P=YES"
	if "%SAVHDR10P%"=="YES" set "SAVHDR10P=NO"
)
if "%ERRORLEVEL%"=="2" (
	if "%REMHDR10P%"=="YES" set "REMHDR10P=NO"
	if "%REMHDR10P%"=="NO" (
		set "REMHDR10P=YES"
		set "BL=YES"
	)
)
if "%ERRORLEVEL%"=="1" (
	if "%BL%"=="NO" set "BL=YES"
	if "%BL%"=="YES" (
		set "BL=NO"
		set "REMHDR10P=NO"
	)
)
goto START

:DV7EXT
if not exist "!TMP_FOLDER!" MD "!TMP_FOLDER!">nul
if not exist "!TARGET_FOLDER!" MD "!TARGET_FOLDER!">nul
cls
%GREEN%
echo  !HEADER1!
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool DEMUXER
%WHITE%
echo                                         ====================================
echo.
echo.
if "!HDR10P!"=="TRUE" (set "HDR10PInfo_string=YES") else (set "HDR10PInfo_string=NO")
if "!DV!"=="TRUE" (set "DVInfo_string=YES - Profile !DV_Profile!") else (set "DVInfo_string=NO")

call :LOGFILESTART
echo  == INFORMATIONS ========================================================================================================>>"!logfile!"
echo.>>"!logfile!"
echo Filename : !INPUTFILENAME!>>"!logfile!"
echo Index    : Video Count [!VIDEO_COUNT!] ^| BL [!BL_INDEX!] ^| EL [!EL_INDEX!]>>"!logfile!"
echo HDR Info : HDR10+ [!HDR10PInfo_string!] ^| Dolby Vision [!DVInfo_string!]>>"!logfile!"
echo.>>"!logfile!"
if "%HDR10P%"=="TRUE" (
	echo  == SETTINGS ============================================================================================================>>"!logfile!"
	echo.>>"!logfile!"
	if "!ELFILE!"=="FALSE" echo Save BL                        : [%BL%]>>"!logfile!"
	echo Remove HDR10+ SEI from BL      : [%REMHDR10P%]>>"!logfile!"
	echo Save HDR10+ SEI                : [%SAVHDR10P%]>>"!logfile!"
	echo Convert HDR10+ SEI to DV RPU   : [%CHGHDR10P%]>>"!logfile!"
	echo Skip HDR10+ Validation         : [%SKIPHDR10P%]>>"!logfile!"
	if "!ELFILE!"=="FALSE" echo Save EL                        : [%EL%]>>"!logfile!"
	echo Save RPU                       : [%RPU%]>>"!logfile!"
	echo Convert RPU                    : [%CONVERT%]>>"!logfile!"
	echo Crop RPU                       : [%CROP%]>>"!logfile!"
) else (
	echo  == SETTINGS ============================================================================================================>>"!logfile!"
	echo.>>"!logfile!"
	if "!ELFILE!"=="FALSE" echo Save BL     : [%BL%]>>"!logfile!"
	if "!ELFILE!"=="FALSE" echo Save EL     : [%EL%]>>"!logfile!"
	echo Save RPU    : [%RPU%]>>"!logfile!"
	echo Convert RPU : [%CONVERT%]>>"!logfile!"
	echo Crop RPU    : [%CROP%]>>"!logfile!"
)
echo.>>"!logfile!"
echo  == OPERATIONS ==========================================================================================================>>"!logfile!"
echo.>>"!logfile!"

call :SWITCHES

if "%RAW_FILE%"=="FALSE" call :DEMUX
if "%RAW_FILE%!VIDEO_COUNT!"=="TRUE2" call :DEMUX
if "%SAVHDR10P%"=="YES" call :SAVE_HDR10P
if "%CHGHDR10P%"=="YES" call :CHG_HDR10P
if "%BL%%EL%" NEQ "NONO" call :DEMUX_BLEL
if "%RPU%"=="YES" call :RPU_DEMUX

goto :EXIT

:DV5
echo  == MENU ================================================================================================================
echo.
%HCWHITE%
echo 1. Convert RPU : [%CONVERT%]
"!Cecho!" {%HC_WHITE%}2. Crop RPU{%HC_YELLOW%}*   {%HC_WHITE%}: [%CROP%]   {%HC_YELLOW%}*Whenever the final result doesn't have letterboxed bars set to {%HC_WHITE%}[YES]{%HC_YELLOW%}.{#}{\n}
echo.
%GREEN%
echo S. START
%HCWHITE%
echo.
"!Cecho!" {%HC_WHITE%}Change Settings and press [{%_GREEN%}S{%HC_WHITE%}] to start Extracting^^!{#}{\n}
CHOICE /C 12S /N /M "Select a Letter 1,2,[S]tart"

if "%ERRORLEVEL%"=="3" goto DV5EXT
if "%ERRORLEVEL%"=="2" (
	if "%CROP%"=="NO" set "CROP=YES"
	if "%CROP%"=="YES" set "CROP=NO"
)
if "%ERRORLEVEL%"=="1" (
	if "%CONVERT%"=="NO" (
		set "RPU=YES"
		set "CONVERT=PROFILE 8.1 HDR10"
	)
	if "%CONVERT%"=="PROFILE 8.1 HDR10" set "CONVERT=PROFILE 8.4 HLG"
	if "%CONVERT%"=="PROFILE 8.4 HLG" set "CONVERT=NO"
)
goto START

:DV5EXT
if not exist "!TMP_FOLDER!" MD "!TMP_FOLDER!">nul
if not exist "!TARGET_FOLDER!" MD "!TARGET_FOLDER!">nul
cls
%GREEN%
echo  !HEADER1!
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool DEMUXER
%WHITE%
echo                                         ====================================
echo.
echo.
if "!HDR10P!"=="TRUE" (set "HDR10PInfo_string=YES") else (set "HDR10PInfo_string=NO")
if "!DV!"=="TRUE" (set "DVInfo_string=YES - Profile !DV_Profile!") else (set "DVInfo_string=NO")

call :LOGFILESTART
echo  == INFORMATIONS ========================================================================================================>>"!logfile!"
echo.>>"!logfile!"
echo Filename : !INPUTFILENAME!>>"!logfile!"
echo Index    : Video Count [!VIDEO_COUNT!] ^| BL [!BL_INDEX!] ^| EL [!EL_INDEX!]>>"!logfile!"
echo HDR Info : HDR10+ [!HDR10PInfo_string!] ^| Dolby Vision [!DVInfo_string!]>>"!logfile!"
echo.>>"!logfile!"
echo  == SETTINGS ============================================================================================================>>"!logfile!"
echo.>>"!logfile!"
echo Convert RPU : [%CONVERT%]>>"!logfile!"
echo Crop RPU    : [%CROP%]>>"!logfile!"
echo.>>"!logfile!"
echo  == OPERATIONS ==========================================================================================================>>"!logfile!"
echo.>>"!logfile!"

call :SWITCHES

if "%RAW_FILE%"=="FALSE" call :DEMUX
call :RPU_DEMUX

goto :EXIT

:SWITCHES
if "!HDR10P!"=="FALSE" (
	set "REMHDR10P=NO"
	set "SAVHDR10P=NO"
	set "SKIPHDR10P=NO"
	set "CHGHDR10P=NO"
)
if "!DV!"=="FALSE" (
	set "CONVERT=NO"
	set "RPU=NO"
	set "CROP=NO"
	set "EL=NO"
)
if "!DVProfile!" NEQ "7" set "EL=NO"
if "!REMHDR10P!!SAVHDR10P!!CHGHDR10P!"=="NONONO" (set "HDR10P_OFF=TRUE") else (set "HDR10P_OFF=FALSE")
if "!RPU!"=="NO" (set "DV_OFF=TRUE") else (set "DV_OFF=FALSE")
if "!DVProfile!" NEQ "7" set "EL=NO" 
if "!REMHDR10P!"=="YES" set "REMHDR10PString= --drop-hdr10plus"
if "!SKIPHDR10P!"=="YES" set "SKIPHDR10PString= --skip-validation"
if "!CONVERT!"=="NO" set "CONVERTSTRING="
if "!CONVERT!"=="PROFILE 8.1 HDR10" set "CONVERTSTRING= -m 2"
if "!DVprofile!!CONVERT!"=="5PROFILE 8.1 HDR10" set "CONVERTSTRING= -m 3"
if "!CONVERT!"=="PROFILE 8.4 HLG" set "CONVERTSTRING= -m 4"
if "!BL!"=="NO" set "EXTSTRING= --el-only"
if "!CROP!"=="YES" set "CROPSTRING= -c"

%WHITE%
echo  == DEMUXING ============================================================================================================
echo.
goto :eof

:DEMUX
if not exist "!TMP_FOLDER!" MD "!TMP_FOLDER!">nul
if not exist "!TARGET_FOLDER!" MD "!TARGET_FOLDER!">nul
if "!BL!!EL!!SAVHDR10P!!DV_OFF!"=="NONOYESTRUE" goto :eof
if "!BL!!EL!!CHGHDR10P!!DV_OFF!"=="NONOYESTRUE" goto :eof
if "!BL!!EL!!HDR10P_OFF!!DV_OFF!"=="NONOTRUEFALSE" goto :eof
%HCYELLOW%
echo ATTENTION^^! You need a lot of HDD Space for this operation.
PUSHD "!TMP_FOLDER!"
:: BEGIN SINGLE LAYER
if "!VIDEO_COUNT!"=="1" (
	%CYAN%
	echo.
	if "!DVProfile!" NEQ "7" (
		echo Please wait. Demuxing BL...
		echo [Demuxing BL]>>"!logfile!"
	)
	if "!DVProfile!"=="7" (
		if "!FORCE_FFMPEG_DEMUXING!!BL!!EL!"=="YESNOYES" (
		echo Please wait. Demuxing EL...
		echo [Demuxing EL]>>"!logfile!"
		) else (
		echo Please wait. Demuxing BL and EL...
		echo [Demuxing BL and EL]>>"!logfile!"
		)
	)
	%CYAN%
	echo.
	%WHITE%
	if "!FORCE_FFMPEG_DEMUXING!!MKVExtract!"=="NOTRUE" "!MKVEXTRACTpath!" "!INPUTFILE!" tracks --ui-language en !BL_INDEX!:"!TMP_FOLDER!\temp.hevc"
	if "!FORCE_FFMPEG_DEMUXING!!MP4Extract!"=="NOTRUE" "!MP4BOXpath!" -raw 1 "!INPUTFILE!" -out "!TMP_FOLDER!\temp.hevc"
	if "!FORCE_FFMPEG_DEMUXING!!MKVExtract!"=="NOTRUE" echo Command^: "!MKVEXTRACTpath!" "!INPUTFILE!" tracks --ui-language en !BL_INDEX!:"!TMP_FOLDER!\temp.hevc">>"!logfile!"
	if "!FORCE_FFMPEG_DEMUXING!!MP4Extract!"=="NOTRUE" echo Command^: "!MP4BOXpath!" -raw 1 "!INPUTFILE!" -out "!TMP_FOLDER!\temp.hevc">>"!logfile!"	
	if not exist "!TMP_FOLDER!\temp.hevc" "!FFMPEGpath!" -loglevel panic -stats -y -i "!INPUTFILE!" -map 0:!BL_INDEX! -c:v copy -bsf:v hevc_mp4toannexb -f hevc - | "!DO_VI_TOOLpath!" demux -
	if not exist "!TMP_FOLDER!\temp.hevc" echo Command^: "!FFMPEGpath!" -loglevel panic -stats -y -i "!INPUTFILE!" -map 0:!BL_INDEX! -c:v copy -bsf:v hevc_mp4toannexb -f hevc - ^| "!DO_VI_TOOLpath!" demux ->>"!logfile!"
	if exist "!TMP_FOLDER!\temp.hevc" (
		for %%f in ("!TMP_FOLDER!\temp.hevc") do set "CHECKSIZE=%%~zf" >nul 2>&1
		if "!CHECKSIZE!" NEQ "0" (
			set "BLSTREAM=!TMP_FOLDER!\temp.hevc"
			set "ELSTREAM=!TMP_FOLDER!\temp.hevc"
			%HCGREEN%
			echo Done.
			echo Done.>>"!logfile!"
			echo.>>"!logfile!"
		)
	) else (
		if exist "!TMP_FOLDER!\BL.hevc" (
			for %%f in ("!TMP_FOLDER!\BL.hevc") do set "CHECKSIZE=%%~zf" >nul 2>&1
			if "!CHECKSIZE!" NEQ "0" (
				set "BLSTREAM=!TMP_FOLDER!\BL.hevc"
				set "ELSTREAM=!TMP_FOLDER!\BL.hevc"
				%HCGREEN%
				echo BL Done.
				echo BL Done.>>"!logfile!"
				echo.>>"!logfile!"
			) else (
				%HCRED%
				set /a "ERRORCOUNT=!ERRORCOUNT!+1"
				echo Error.
				echo Error.>>"!logfile!"
				echo.>>"!logfile!"
			)
		) else (
			%HCRED%
			set /a "ERRORCOUNT=!ERRORCOUNT!+1"
			echo Error.
			echo Error.>>"!logfile!"
			echo.>>"!logfile!"
		)
	)
) else (
	:: BEGIN DUAL LAYER
	if "!BL!"=="YES" (
		if "!HDR10P_OFF!"=="TRUE" (set "BL_Folder=!TARGET_FOLDER!\!INPUTFILENAME!_[BL].hevc") else (set "BL_Folder=!TMP_FOLDER!\BL.hevc")
		%CYAN%
		echo.
		echo Please wait. Demuxing BL...
		echo [Demuxing BL]>>"!logfile!"
		if exist "!BL_Folder!" del "!BL_Folder!"
		%WHITE%
		if "!FORCE_FFMPEG_DEMUXING!!MKVExtract!"=="NOTRUE" echo Command^: "!MKVEXTRACTpath!" "!INPUTFILE!" tracks --ui-language en  !BL_INDEX!:"!BL_Folder!">>"!logfile!"
		if "!FORCE_FFMPEG_DEMUXING!!MP4Extract!"=="NOTRUE" echo Command^: "!MP4BOXpath!" -raw !BL_INDEX! "!INPUTFILE!" -out "!BL_Folder!">>"!logfile!"
		if not exist "!BL_Folder!" echo Command^: "!FFMPEGpath!" -loglevel panic -stats -i "!INPUTFILE!" -map 0:!BL_INDEX! -c:v copy -bsf:v hevc_mp4toannexb -f hevc "!BL_Folder!">>"!logfile!"
		if "!FORCE_FFMPEG_DEMUXING!!MKVExtract!"=="NOTRUE" "!MKVEXTRACTpath!" "!INPUTFILE!" tracks --ui-language en  !BL_INDEX!:"!BL_Folder!"
		if "!FORCE_FFMPEG_DEMUXING!!MP4Extract!"=="NOTRUE" "!MP4BOXpath!" -raw !BL_INDEX! "!INPUTFILE!" -out "!BL_Folder!"
		if not exist "!BL_Folder!" "!FFMPEGpath!" -loglevel panic -stats -i "!INPUTFILE!" -map 0:!BL_INDEX! -c:v copy -bsf:v hevc_mp4toannexb -f hevc "!BL_Folder!"
		if exist "!BL_Folder!" (
			for %%f in ("!BL_Folder!") do set "CHECKSIZE=%%~zf" >nul 2>&1
			if "!CHECKSIZE!" NEQ "0" (
				%HCGREEN%
				echo Done.
				set "BLSTREAM=!BL_Folder!"
				echo Done.>>"!logfile!"
				echo.>>"!logfile!"
			) else (
				%HCRED%
				set /a "ERRORCOUNT=!ERRORCOUNT!+1"
				echo Error.
				echo Error.>>"!logfile!"
				echo.>>"!logfile!"
			)
		) else (
			%HCRED%
			echo Error.
			echo Error.>>"!logfile!"
			echo.>>"!logfile!"
			set /a "ERRORCOUNT=!ERRORCOUNT!+1"
		)
	)
	if "!EL!"=="YES" (
		if "!DV_OFF!"=="TRUE" (set "EL_Folder=!TARGET_FOLDER!\!INPUTFILENAME!_[EL].hevc") else (set "EL_Folder=!TMP_FOLDER!\EL.hevc")
		%CYAN%
		echo.
		echo Please wait. Demuxing EL...
		echo [Demuxing EL]>>"!logfile!"
		if exist "!EL_Folder!" del "!EL_Folder!"
		%WHITE%
		if "!FORCE_FFMPEG_DEMUXING!!MKVExtract!"=="NOTRUE" echo Command^: "!MKVEXTRACTpath!" "!INPUTFILE!" tracks --ui-language en  !EL_INDEX!:"!EL_Folder!">>"!logfile!"
		if "!FORCE_FFMPEG_DEMUXING!!MP4Extract!"=="NOTRUE" echo Command^: "!MP4BOXpath!" -raw !EL_INDEX! "!INPUTFILE!" -out "!EL_Folder!">>"!logfile!"
		if not exist "!EL_Folder!" echo Command^: "!FFMPEGpath!" -loglevel panic -stats -i "!INPUTFILE!" -map 0:!EL_INDEX! -c:v copy -bsf:v hevc_mp4toannexb -f hevc "!EL_Folder!">>"!logfile!"
		if "!FORCE_FFMPEG_DEMUXING!!MKVExtract!"=="NOTRUE" "!MKVEXTRACTpath!" "!INPUTFILE!" tracks --ui-language en  !EL_INDEX!:"!EL_Folder!"
		if "!FORCE_FFMPEG_DEMUXING!!MP4Extract!"=="NOTRUE" "!MP4BOXpath!" -raw !EL_INDEX! "!INPUTFILE!" -out "!EL_Folder!"
		if not exist "!EL_Folder!" "!FFMPEGpath!" -loglevel panic -stats -i "!INPUTFILE!" -map 0:!EL_INDEX! -c:v copy -bsf:v hevc_mp4toannexb -f hevc "!EL_Folder!"
		if exist "!EL_Folder!" (
			for %%f in ("!EL_Folder!") do set "CHECKSIZE=%%~zf" >nul 2>&1
			if "!CHECKSIZE!" NEQ "0" (
				%HCGREEN%
				echo Done.
				set "ELSTREAM=!EL_Folder!"
				echo Done.>>"!logfile!"
				echo.>>"!logfile!"
			) else (
				%HCRED%
				set /a "ERRORCOUNT=!ERRORCOUNT!+1"
				echo Error.
				echo Error.>>"!logfile!"
				echo.>>"!logfile!"
			)
		) else (
			%HCRED%
			echo Error.
			set /a "ERRORCOUNT=!ERRORCOUNT!+1"
			echo Error.>>"!logfile!"
		)
	)
)


POPD
echo.
goto :eof

:DEMUX_BLEL
%CYAN%
if "!BL!!EL!"=="NONO" goto :eof
if "!VIDEO_COUNT!" NEQ "1" (
	if "!HDR10P_OFF!"=="TRUE" goto :eof
)
if "!REMHDR10P!"=="NO" (
	set "NAMESTRING=BL"
) else (
	set "NAMESTRING=BL no HDR10+"
)
if "!BL!!EL!!REMHDR10P!"=="YESNOYES" echo [Processing BL without HDR10+ SEI]>>"!logfile!"
if "!BL!!EL!!REMHDR10P!"=="YESYESYES" echo [Processing BL without HDR10+ SEI and EL]>>"!logfile!"
if "!BL!!EL!!REMHDR10P!"=="YESNONO" echo [Processing BL]>>"!logfile!"
if "!BL!!EL!!REMHDR10P!"=="YESYESNO" echo [Processing BL and EL]>>"!logfile!"
if "!BL!!EL!"=="NOYES" echo [Processing EL]>>"!logfile!"

if "!BL!!EL!!REMHDR10P!"=="YESNOYES" echo Please wait. Processing BL without HDR10+ SEI...
if "!BL!!EL!!REMHDR10P!"=="YESYESYES" echo Please wait. Processing BL without HDR10+ SEI and EL...
if "!BL!!EL!!REMHDR10P!"=="YESNONO" echo Please wait. Processing BL...
if "!BL!!EL!!REMHDR10P!"=="YESYESNO" echo Please wait. Processing BL and EL...
if "!BL!!EL!"=="NOYES" echo Please wait. Processing EL...

::RAW FILE
if "!RAW_FILE!"=="TRUE" (
	PUSHD "!TMP_FOLDER!"
	echo Command^: "!DO_VI_TOOLpath!"!REMHDR10PString! demux!EXTSTRING! "!INPUTFILE!">>"!logfile!"
	"!DO_VI_TOOLpath!"!REMHDR10PString! demux!EXTSTRING! "!INPUTFILE!"
	POPD
)

PUSHD "!TARGET_FOLDER!"

::TEMP FOLDER HEVC
if exist "!TMP_FOLDER!\temp.hevc" (
	if exist "!TMP_FOLDER!\BL.hevc" del "!TMP_FOLDER!\BL.hevc"
	if exist "!TMP_FOLDER!\EL.hevc" del "!TMP_FOLDER!\EL.hevc"
	echo Command^: "!DO_VI_TOOLpath!"!REMHDR10PString! demux!EXTSTRING! "!TMP_FOLDER!\temp.hevc">>"!logfile!"
	"!DO_VI_TOOLpath!"!REMHDR10PString! demux!EXTSTRING! "!TMP_FOLDER!\temp.hevc"
	if "!BL!"=="NO" (
		if exist "!TARGET_FOLDER!\BL.hevc" del "!TARGET_FOLDER!\BL.hevc"
	) else (
		if exist "!INPUTFILENAME!_[!NAMESTRING!].hevc" del "!INPUTFILENAME!_[!NAMESTRING!].hevc"
		ren "!TARGET_FOLDER!\BL.hevc" "!INPUTFILENAME!_[!NAMESTRING!].hevc"
	)
	if "!EL!"=="NO" (
		if exist "!TARGET_FOLDER!\EL.hevc" del "!TARGET_FOLDER!\EL.hevc"
	) else (
		if exist "!INPUTFILENAME!_[EL].hevc" del "!INPUTFILENAME!_[EL].hevc"
		ren "!TARGET_FOLDER!\EL.hevc" "!INPUTFILENAME!_[EL].hevc"
	)
)

::TEMP FOLDER BL
if exist "!TMP_FOLDER!\BL.hevc" (
	if "!BL!"=="YES" (
		if "!VIDEO_COUNT!!REMHDR10P!" NEQ "1NO" (
			echo Command^: "!HDR10P_TOOLpath!" remove "!TMP_FOLDER!\BL.hevc" -o "!TARGET_FOLDER!\!INPUTFILENAME!_[!NAMESTRING!].hevc">>"!logfile!"
			"!HDR10P_TOOLpath!" remove "!TMP_FOLDER!\BL.hevc" -o "!TARGET_FOLDER!\!INPUTFILENAME!_[!NAMESTRING!].hevc"
		) else (
			echo Command^: copy /y "!TMP_FOLDER!\BL.hevc" "!TARGET_FOLDER!\!INPUTFILENAME!_[!NAMESTRING!].hevc">>"!logfile!"
			copy /y "!TMP_FOLDER!\BL.hevc" "!TARGET_FOLDER!\!INPUTFILENAME!_[!NAMESTRING!].hevc">nul
		)
	)
)

::TEMP FOLDER EL
if exist "!TMP_FOLDER!\EL.hevc" (
	if "!EL!"=="YES" echo Command^: copy /y "!TMP_FOLDER!\EL.hevc" "!TARGET_FOLDER!\!INPUTFILENAME!_[EL].hevc">>"!logfile!"
	if "!EL!"=="YES" copy /y "!TMP_FOLDER!\EL.hevc" "!TARGET_FOLDER!\!INPUTFILENAME!_[EL].hevc">nul
)

::CHECK FUNCTION
if "!BL!"=="YES" (
	if exist "!TARGET_FOLDER!\!INPUTFILENAME!_[!NAMESTRING!].hevc" (
		for %%f in ("!TARGET_FOLDER!\!INPUTFILENAME!_[!NAMESTRING!].hevc") do set "CHECKSIZE=%%~zf" >nul 2>&1
		if "!CHECKSIZE!" NEQ "0" (
			%HCGREEN%
			echo BL Done.
			echo BL Done.>>"!logfile!"
		) else (
			%HCRED%
			set /a "ERRORCOUNT=!ERRORCOUNT!+1"
			echo BL Error.
			echo BL Error.>>"!logfile!"
		)
	) else (
		%HCRED%
		echo BL Error.
		echo BL Error.>>"!logfile!"
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	)
)

if "!EL!"=="YES" (
	if exist "!TARGET_FOLDER!\!INPUTFILENAME!_[EL].hevc" (
		for %%f in ("!TARGET_FOLDER!\!INPUTFILENAME!_[EL].hevc") do set "CHECKSIZE=%%~zf" >nul 2>&1
		if "!CHECKSIZE!" NEQ "0" (
			%HCGREEN%
			echo EL Done.
			echo EL Done.>>"!logfile!"
		) else (
			%HCRED%
			set /a "ERRORCOUNT=!ERRORCOUNT!+1"
			echo EL Error.
			echo EL Error.>>"!logfile!"
		)
	) else (
		%HCRED%
		echo EL Error.
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
		
	)
)

echo.>>"!logfile!"
echo.
POPD
goto :eof

:RPU_DEMUX
if not exist "!TMP_FOLDER!" MD "!TMP_FOLDER!">nul
if not exist "!TARGET_FOLDER!" MD "!TARGET_FOLDER!">nul
if "%CONVERT%"=="NO" set "CSTRING=_P!DVProfile!"
if "%CONVERT%"=="PROFILE 8.1 HDR10" set "CSTRING=_CONVERTED-P8.1"
if "%CONVERT%"=="PROFILE 8.4 HLG" set "CSTRING=_CONVERTED-P8.4"
if "%CONVERT%"=="PROFILE 7 MEL" set "CSTRING=_CONVERTED-P7MEL"
if "!RAW_FILE!"=="TRUE" set "ELSTREAM=!INPUTFILE!"
%CYAN%
echo [Demuxing DV Reference Processing Unit]>>"!logfile!"
echo Please wait. Demuxing DV Reference Processing Unit...
%WHITE%
if exist "!ELSTREAM!" (
	echo Command^: "!DO_VI_TOOLpath!"%CROPSTRING%%CONVERTSTRING% extract-rpu "!ELSTREAM!" -o "!TARGET_FOLDER!\!INPUTFILENAME!_[RPU!CSTRING!].bin">>"!logfile!"
	"!DO_VI_TOOLpath!"%CROPSTRING%%CONVERTSTRING% extract-rpu "!ELSTREAM!" -o "!TARGET_FOLDER!\!INPUTFILENAME!_[RPU!CSTRING!].bin">>"!logfile!"
) else (
	echo Command^: "!FFMPEGpath!" -loglevel panic -stats -i "!INPUTFILE!" -map 0:!EL_INDEX! -c:v copy -bsf:v hevc_mp4toannexb -f hevc - ^| "!DO_VI_TOOLpath!"%CROPSTRING%%CONVERTSTRING% extract-rpu -o "!TARGET_FOLDER!\!INPUTFILENAME!_[RPU!CSTRING!].bin" ->>"!logfile!"
	"!FFMPEGpath!" -loglevel panic -stats -i "!INPUTFILE!" -map 0:!EL_INDEX! -c:v copy -bsf:v hevc_mp4toannexb -f hevc - | "!DO_VI_TOOLpath!"%CROPSTRING%%CONVERTSTRING% extract-rpu -o "!TARGET_FOLDER!\!INPUTFILENAME!_[RPU!CSTRING!].bin" ->>"!logfile!"
)
if exist "!TARGET_FOLDER!\!INPUTFILENAME!_[RPU!CSTRING!].bin" (
	for %%f in ("!TARGET_FOLDER!\!INPUTFILENAME!_[RPU!CSTRING!].bin") do set "CHECKSIZE=%%~zf" >nul 2>&1
	if "!CHECKSIZE!" NEQ "0" (
		%HCGREEN%
		echo Done.
		echo Done.>>"!logfile!"
		echo.>>"!logfile!"
	) else (
		%HCRED%
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
		echo Error.
		echo Error.>>"!logfile!"
		echo.>>"!logfile!"
	)
) else (
	%HCRED%
	echo Error.
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	echo Error.>>"!logfile!"
	echo.>>"!logfile!"
)
echo.
goto :eof

:RPU_EXTRACT
if not exist "!TMP_FOLDER!" MD "!TMP_FOLDER!">nul
if not exist "!TARGET_FOLDER!" MD "!TARGET_FOLDER!">nul
set "HEADERNAME=_[P!RPUProfile!]"
%CYAN%
echo [Extracting DV Reference Processing Unit]>>"!logfile!"
echo Please wait. Extracting DV Reference Processing Unit...
%WHITE%
echo Command^: "!DOVI_METApath!" convert "!RPU!" "!TARGET_FOLDER!\!INPUTFILENAME!!HEADERNAME!.xml">>"!logfile!"
"!DOVI_METApath!" convert "!RPU!" "!TARGET_FOLDER!\!INPUTFILENAME!!HEADERNAME!.xml"
if exist "!TARGET_FOLDER!\!INPUTFILENAME!!HEADERNAME!.xml" (
	for %%f in ("!TARGET_FOLDER!\!INPUTFILENAME!!HEADERNAME!.xml") do set "CHECKSIZE=%%~zf" >nul 2>&1
	if "!CHECKSIZE!" NEQ "0" (
		%HCGREEN%
		echo XML Done.
		echo XML Done.>>"!logfile!"
		echo.>>"!logfile!"
	) else (
		%HCRED%
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
		echo XML Error.
		echo XML Error.>>"!logfile!"
		echo.>>"!logfile!"
	)
) else (
	%HCRED%
	echo XML Error.
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	echo XML Error.>>"!logfile!"
	echo.>>"!logfile!"
)
echo.
%WHITE%
echo Command^: "!DO_VI_TOOLpath!" export -i "!RPU!" -d all="!TMP_FOLDER!\info.json">>"!logfile!"
"!DO_VI_TOOLpath!" export -i "!RPU!" -d all="!TMP_FOLDER!\info.json">>"!logfile!"
echo Command^: "!jqpath!" . "!TMP_FOLDER!\info.json"^>"!TARGET_FOLDER!\!INPUTFILENAME!!HEADERNAME!.json">>"!logfile!"
"!jqpath!" . "!TMP_FOLDER!\info.json">"!TARGET_FOLDER!\!INPUTFILENAME!!HEADERNAME!.json"
if exist "!TARGET_FOLDER!\!INPUTFILENAME!!HEADERNAME!.json" (
	for %%f in ("!TARGET_FOLDER!\!INPUTFILENAME!!HEADERNAME!.json") do set "CHECKSIZE=%%~zf" >nul 2>&1
	if "!CHECKSIZE!" NEQ "0" (
		%HCGREEN%
		echo JSON Done.
		echo JSON Done.>>"!logfile!"
		echo.>>"!logfile!"
	) else (
		%HCRED%
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
		echo JSON Error.
		echo JSON Error..>>"!logfile!"
		echo.>>"!logfile!"
	)
) else (
	%HCRED%
	echo JSON Error.
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	echo JSON Error.>>"!logfile!"
	echo.>>"!logfile!"
)
echo.
goto :eof

:SAVE_HDR10P
if "!SAVE_HDR10P_OPERATION_DONE!"=="YES" goto :eof
if "!RAW_FILE!"=="TRUE" set "BLSTREAM=!INPUTFILE!"
%CYAN%
echo [Demuxing HDR10+ SEI]>>"!logfile!"
echo Please wait. Demuxing HDR10+ SEI...
%WHITE%
if exist "!BLSTREAM!" (
	echo Command^: "!HDR10P_TOOLpath!"%SKIPHDR10PString% extract "!BLSTREAM!" -o "!TMP_FOLDER!\HDR10Plus.json">>"!logfile!"
	"!HDR10P_TOOLpath!"%SKIPHDR10PString% extract "!BLSTREAM!" -o "!TMP_FOLDER!\HDR10Plus.json">>"!logfile!"
) else (
	echo Command^: "!FFMPEGpath!" -loglevel panic -stats -i "!INPUTFILE!" -map 0:!BL_INDEX! -c:v copy -bsf:v hevc_mp4toannexb -f hevc - ^| "!HDR10P_TOOLpath!" extract -o "!TMP_FOLDER!\HDR10Plus.json" ->>"!logfile!"
	"!FFMPEGpath!" -loglevel panic -stats -i "!INPUTFILE!" -map 0:!BL_INDEX! -c:v copy -bsf:v hevc_mp4toannexb -f hevc - | "!HDR10P_TOOLpath!" extract -o "!TMP_FOLDER!\HDR10Plus.json" ->>"!logfile!"
)
if exist "!TMP_FOLDER!\HDR10Plus.json" (
	for %%f in ("!TMP_FOLDER!\HDR10Plus.json") do set "CHECKSIZE=%%~zf" >nul 2>&1
	if "!CHECKSIZE!" NEQ "0" (
		if "%SAVHDR10P%"=="YES" echo Command^: copy "!TMP_FOLDER!\HDR10Plus.json" "!TARGET_FOLDER!\!INPUTFILENAME!_[HDR10+].json">>"!logfile!"
		if "%SAVHDR10P%"=="YES" copy "!TMP_FOLDER!\HDR10Plus.json" "!TARGET_FOLDER!\!INPUTFILENAME!_[HDR10+].json">nul
		%HCGREEN%
		echo Done.
		echo Done.>>"!logfile!"
		echo.>>"!logfile!"
	) else (
		%HCRED%
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
		echo Error.
		echo Error.>>"!logfile!"
		echo.>>"!logfile!"
	)
) else (
	%HCRED%
	echo Error.
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	echo Error.>>"!logfile!"
	echo.>>"!logfile!"
)
set "SAVE_HDR10P_OPERATION_DONE=YES"
echo.
goto :eof
	
:CHG_HDR10P
CALL :SAVE_HDR10P
%CYAN%
echo Please wait. Prefetching HDR10+ SEI...
echo [Prefetching HDR10+ SEI]>>"!logfile!"
(
echo {
echo	"cm_version": "!CM_VERSION!",
echo 	"length": !FRAMES!,
echo 	"level6": {
echo	 	"max_display_mastering_luminance": !MaxDML!,
echo	 	"min_display_mastering_luminance": !MinDML!,
echo	 	"max_content_light_level": !MaxCLL!,
echo	 	"max_frame_average_light_level": !MaxFall! 
echo 	}
echo }
)>>"!logfile!"
(
echo {
echo	"cm_version": "!CM_VERSION!",
echo 	"length": !FRAMES!,
echo 	"level6": {
echo	 	"max_display_mastering_luminance": !MaxDML!,
echo	 	"min_display_mastering_luminance": !MinDML!,
echo	 	"max_content_light_level": !MaxCLL!,
echo	 	"max_frame_average_light_level": !MaxFall! 
echo 	}
echo }
)>"!TMP_FOLDER!\Extra.json"
if exist "!TMP_FOLDER!\Extra.json" (
	%HCGREEN%
	echo Done.
	echo Done.>>"!logfile!"
	echo.>>"!logfile!"
) else (
	%HCRED%
	echo Error.
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	echo Error.>>"!logfile!"
	echo.>>"!logfile!"
)
echo.
%CYAN%
echo [Generate DV Reference Processing Unit]>>"!logfile!"
echo Please wait. Generate DV Reference Processing Unit...
%WHITE%
"!DO_VI_TOOLpath!" generate -j "!TMP_FOLDER!\Extra.json" --hdr10plus-json "!TMP_FOLDER!\HDR10Plus.json" -o "!TARGET_FOLDER!\!INPUTFILENAME!_[HDR10+ RPU].bin">>"!logfile!"
if exist "!TARGET_FOLDER!\!INPUTFILENAME!_[HDR10+ RPU].bin" (
	for %%f in ("!TARGET_FOLDER!\!INPUTFILENAME!_[HDR10+ RPU].bin") do set "CHECKSIZE=%%~zf" >nul 2>&1
	if "!CHECKSIZE!" NEQ "0" (
		%HCGREEN%
		echo Done.
		echo.>>"!logfile!"
	) else (
		%HCRED%
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
		echo Error.
		echo.>>"!logfile!"
	)
) else (
	%HCRED%
	echo Error.
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	echo.>>"!logfile!"
)
echo.
goto :eof

:ANALYSESTREAMS
FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=General;%%VideoCount%% "!INPUTFILE!""') do set "VIDEO_COUNT=%%A"
if "!VIDEO_COUNT!" NEQ "1" set "LAYERTYPE= DL"
"!FFPROBEpath!" "!INPUTFILE!" -show_streams -v 0 -of compact=p=0:nk=1 >"!TMP_FOLDER!\STREAMS.txt"
FOR /F "delims=" %%A IN ('findstr /C:"hevc|H.265" "!TMP_FOLDER!\STREAMS.txt"') DO echo %%A>>"!TMP_FOLDER!\VSTREAMS.txt"
if exist "!TMP_FOLDER!\VSTREAMS.txt" (
	FOR /F "delims=" %%A IN ('findstr /C:"3840|2160" "!TMP_FOLDER!\VSTREAMS.txt"') DO set "BL_STREAMINFO=%%A"
	FOR /F "delims=" %%A IN ('findstr /C:"1920|1080" "!TMP_FOLDER!\VSTREAMS.txt"') DO set "EL_STREAMINFO=%%A"
)
if defined BL_STREAMINFO (
	for /F "tokens=1 delims=|" %%A in ("!BL_STREAMINFO!") do set "BL_INDEX=%%A"
) else (
	set "BL_INDEX=0"
)
if defined EL_STREAMINFO (
	for /F "tokens=1 delims=|" %%A in ("!EL_STREAMINFO!") do set "EL_INDEX=%%A"
) else (
	set "EL_INDEX=0"
)
if exist "!TMP_FOLDER!\STREAMS.txt" del "!TMP_FOLDER!\STREAMS.txt"
if exist "!TMP_FOLDER!\VSTREAMS.txt" del "!TMP_FOLDER!\VSTREAMS.txt"
goto :eof

:LOGFILESTART
if exist "!TMP_FOLDER!" (
	echo  DDVT Demuxer v%VERSION%>"!logfile!"
	echo.>>"!logfile!"
	echo.>>"!logfile!"
	echo                                         ====================================>>"!logfile!"
	echo                                              Dolby Vision Tool DEMUXER>>"!logfile!"
	echo                                         ====================================>>"!logfile!"
	echo.>>"!logfile!"
	echo.>>"!logfile!"
	echo  == LOGFILE START =======================================================================================================>>"!logfile!"
	echo.>>"!logfile!"
	echo %date%  %time%>>"!logfile!"
	echo.>>"!logfile!"
)
goto :eof

:LOGFILEEND
if exist "!TMP_FOLDER!" (
	echo  == ERROR^(S^) ============================================================================================================>>"!logfile!"
	echo.>>"!logfile!"
	echo !ERRORCOUNT! Error^(s^) during processing.>>"!logfile!"
	echo.>>"!logfile!"
	echo  == LOGFILE END =========================================================================================================>>"!logfile!"
	echo.>>"!logfile!"
	echo %date%  %time%>>"!logfile!"
	if exist "!logfile!" move "!logfile!" "!TARGET_FOLDER!\DDVT Demuxer ^(!INPUTFILENAME!!INPUTFILEEXT!^).log" >nul
)
goto :eof

:EXIT
call :LOGFILEEND
%WHITE%
echo  == CLEANING ============================================================================================================
echo.
%CYAN%
echo Please wait. Cleaning Temp Folder...
if exist "!TMP_FOLDER!" (
	RD /S /Q "!TMP_FOLDER!">nul
	if "%ERRORLEVEL%"=="0" (
		%HCGREEN%
		echo Deleting Temp Folder - Done.
	) else (
		%HCRED%
		echo Deleting Temp Folder - Error.
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	)
)
%WHITE%
setlocal DisableDelayedExpansion
endlocal
%WHITE%
echo.
echo  == EXIT ================================================================================================================
echo.
if "%ERRORCOUNT%"=="0" (
	%HCGREEN%
	echo All Operations successful.
	%HCWHITE%
	TIMEOUT 30
) else (
	%HCRED%
	echo SOME Operations failed.
	%HCWHITE%
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
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('NEEDED FILE NOT FOUND!' + %NewLine% + %NewLine% + '%Line1%' + %NewLine% + %NewLine% + '%Line2%', 'DDVT Demuxer v%VERSION%', 'Ok','Error')"
exit

:FALSEINPUT
if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
set "NewLine=[System.Environment]::NewLine"
set "Line1=Unsupported Input File. Supported Files are:"
set "Line2=*.mkv | *.mp4 | *.m2ts | *.h265 | *.hevc | *.bin"
setlocal DisableDelayedExpansion
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('%INPUTFILENAME%%INPUTFILEEXT%' + %NewLine% + %NewLine% + '%Line1%' + %NewLine% + %NewLine% + '%Line2%', 'DDVT Demuxer v%VERSION%', 'Ok','Info')"
exit

:ERROR
if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
set "NewLine=[System.Environment]::NewLine"
set "Line1=%ERRORCOUNT% Error(s) during processing^!
set "Line2=Target file don''t exist or corrupt.
setlocal DisableDelayedExpansion
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('%INPUTFILENAME%%INPUTFILEEXT%' + %NewLine% + %NewLine% + '%Line1%' + %NewLine% + %NewLine% + '%Line2%', 'DDVT Demuxer v%VERSION%', 'Ok','Error')"
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