@echo off & setlocal
mode con cols=125 lines=57
FOR /F "tokens=2 delims==" %%A IN ('findstr /C:"VERSION=" "%~dp0DDVT_OPTIONS.cmd"') DO set "VERSION=%%A"
TITLE DDVT Demuxer [QfG] v%VERSION%

set PasswordChars=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890
set PasswordLength=5
call :CreatePassword Password

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
:: PROFILE 8.1 HDR10 / PROFILE 7 MEL / PROFILE 8.4 HLG / NO - Predefined convert profiles for RPU extraction.
set "CHGHDR10P=YES"
:: YES / NO - Convert HDR10+ Metadata to DV RPU.
set "REMHDR10P=NO"
:: YES / NO - Remove HDR10+ Metadata from BL.
set "SAVHDR10P=NO"
:: YES / NO - Save HDR10+ Metadata as JSON.
set "SKIPHDR10P=NO"
:: YES / NO - Skip validation test for HDR10+ Metadata.
set "CM_VERSION=V40"
:: V40 / V29 - Set CMv for converting HDR10+ Metadata to RPU.
set "CROP=NO"
:: YES / NO - If yes the Active Area from the RPU will set to 0,0,0,0. Helpful for cropped videos.
set "BL=NO"
:: YES / NO - Save BL in target folder.
set "EL=NO"
:: YES / NO - Save EL in target folder.
set "RPU=YES"
:: YES / NO - Save RPU in target folder.

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
)
if "!MKVTOOLNIX_FOLDER!"=="INCLUDED" set "MKVTOOLNIX_FOLDER=%~dp0tools"
set "MKVMERGEpath=!MKVTOOLNIX_FOLDER!\mkvmerge.exe"

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

if /i "%~x1"==".hevc" set "RAW_FILE=TRUE" & goto CHECK
if /i "%~x1"==".h265" set "RAW_FILE=TRUE" & goto CHECK
if /i "%~x1"==".m2ts" set "RAW_FILE=TRUE" & goto CHECK
if /i "%~x1"==".mkv" set "MKVExtract=TRUE" & goto CHECK
if /i "%~x1"==".mp4" set "MP4Extract=TRUE" & goto CHECK
if /i "%~x1"==".bin" set "RPU_FILE=TRUE" & set "RPU=%~1" & goto CHECK

if not "!INPUTFILE!"=="" goto :FALSEINPUT

:CHECK
CLS
%GREEN%
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                               Dolby Vision Tool DEMUXER
%WHITE%
echo                                         ====================================
%WHITE%
echo.
echo.
echo  == CHECK INPUT FILE ====================================================================================================

if "%~1"=="" (
	%YELLOW%
	echo.
	echo No Input File. Use DDVT_DEMUXER.cmd "YourFilename.hevc/h265/mkv/mp4"
	echo.
	goto :EXIT
)
if not exist "!TMP_FOLDER!" MD "!TMP_FOLDER!">nul
echo.
%CYAN%
echo Analysing File. Please wait...
if "!RPU_FILE!"=="FALSE" (
	echo.
	set "INFOSTREAM=!INPUTFILE!"
	set "BL_INFOVIDEO=!INPUTFILE!"
	FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=General;%%VideoCount%% "!INFOSTREAM!""') do set "VIDEO_COUNT=%%A"
	if "!RAW_FILE!"=="TRUE" (
		"!MKVMERGEpath!" --ui-language en --priority higher --output ^"!TMP_FOLDER!\Info.mkv^" --language 0:und --compression 0:none ^"^(^" ^"!INPUTFILE!^" ^"^)^" --split parts:00:00:00-00:00:01 -q
		if exist "!TMP_FOLDER!\Info.mkv" set "INFOSTREAM=!TMP_FOLDER!\Info.mkv"
	)
	if "!VIDEO_COUNT!" NEQ "1" "!FFMPEGpath!" -loglevel panic -y -i "!INPUTFILE!" -map 0:0 -c:v copy -to 1 -bsf:v hevc_metadata -f hevc "!TMP_FOLDER!\BL_Info.mkv"
	if exist "!TMP_FOLDER!\BL_Info.mkv" (
		set "BL_INFOVIDEO=!TMP_FOLDER!\BL_Info.mkv"
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

	::DUAL LAYER OPERATION
	if "!VIDEO_COUNT!" NEQ "1" (
		set "LAYERTYPE= DL"
		"!FFPROBEpath!" "!INPUTFILE!" -show_streams -v 0 -of compact=p=0:nk=1 >"!TMP_FOLDER!\STREAMS.txt"
		FOR /F "delims=" %%A IN ('findstr /C:"1920|1080" "!TMP_FOLDER!\STREAMS.txt"') DO set "STREAMINFO=%%A"
		if exist "!TMP_FOLDER!\STREAMS.txt" del "!TMP_FOLDER!\STREAMS.txt"
		if defined STREAMINFO (
			for /F "tokens=1 delims=|" %%A in ("!STREAMINFO!") do set "STREAMINFO=%%A"
			set "DT=-map 0:!STREAMINFO!"
		) else (
			set "DT=-map 0:1"
		)
	)

	::DEMUX RPU SAMPLE
	if "!DVinput!"=="YES" (
		if exist "!INFOSTREAM!" (
			"!FFMPEGpath!" -loglevel panic -i "!INFOSTREAM!" -c:v copy -to 1 -bsf:v hevc_metadata -f hevc - | "!DO_VI_TOOLpath!" extract-rpu -o "!TMP_FOLDER!\RPU.bin" - >nul 2>&1
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
			"!FFMPEGpath!" -loglevel panic -i "!INPUTFILE!" !DT! -c:v copy -to 1 -bsf:v hevc_metadata -f hevc - | "!DO_VI_TOOLpath!" extract-rpu -o "!TMP_FOLDER!\RPU.bin" - >nul 2>&1
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
	FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%Format%%^-%%BitDepth%%Bit^-%%ColorSpace%%^-%%ChromaSubsampling%% "!BL_INFOVIDEO!""') do set "CODEC_NAME=%%A"
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
	FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%FrameCount%% "!BL_INFOVIDEO!""') do set "FRAMES=%%A"
	if "!HDRFormat!"=="HDR10" (
		set "HDR=TRUE"
		%GREEN%
		echo HDR10 found.
	)
	if "!HDRFormat!"=="HLG" (
		set "HDR=TRUE"
		%GREEN%
		echo HLG found.
	)
	if "!HDRFormat!"=="HDR10+" (
		set "HDR=TRUE"
		set "HDR10P=TRUE"
		%GREEN%
		echo HDR10+ SEI found.
	)
	if "!DVprofile!"=="8" (
		set "HDR=TRUE"
		set "DV=TRUE"
		set "DV_Profile=8"
		%GREEN%
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
		%GREEN%
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
		%GREEN%
		echo Dolby Vision Profile 5 found.
	)
	if "!DVprofile!"=="4" (
		set "HDR=TRUE"
		set "DV=TRUE"
		set "DV_Profile=4"
		%GREEN%
		echo Dolby Vision Profile 4 found.
	)
	%GREEN%
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
		%RED%
		echo.
		echo Corrupt RPU or not RPU File.
		echo.
		goto :EXIT
	)
	%GREEN%
	echo.
	echo Analysing complete.
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

TIMEOUT 3 /NOBREAK>nul

:START
if "!RPU!"=="NO" set "CONVERT=NO"
if "!RPU_FILE!"=="TRUE" goto :STARTRPU
cls
%GREEN%
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                               Dolby Vision Tool DEMUXER
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
%RED%
echo No HDR10^+ ^/ Dolby Vision found.
echo Abort Operation now.
echo.
goto :EXIT

:STARTRPU
cls
%GREEN%
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                               Dolby Vision Tool DEMUXER
%WHITE%
echo                                         ====================================
echo.
echo.
echo  == RPU INPUT ===========================================================================================================
echo.
%CYAN%
echo Filename   = [!INPUTFILENAME!!INPUTFILEEXT!]
echo RPU Info   = [Profile = %RPUProfile%] [DM = %DM%] [Frames = %FRAMES%]
echo.
%WHITE%
echo  == EXTRACTING ==========================================================================================================
echo.
call :RPU_EXTRACT
goto :EXIT

:HDR10Plus
if "!CM_VERSION!"=="V40" set "CM_VERSION_text=4.0"
if "!CM_VERSION!"=="V29" set "CM_VERSION_text=2.9"
echo  == MENU ================================================================================================================
echo.
echo 1. SAVE BL                        : [%BL%]
echo 2. SAVE HDR10+ Metadata           : [%SAVHDR10P%]
echo 3. Skip HDR10+ Validation         : [%SKIPHDR10P%]
echo 4. Remove HDR10+ Metadata from BL : [%REMHDR10P%]
echo 5. Convert HDR10+ Metadata to DV  : [%CHGHDR10P%]
if "%CHGHDR10P%"=="YES" echo 6. Content Mapping Version        : [%CM_VERSION_text%]
echo.
echo S. START
echo.
%GREEN%
echo Change Settings and press [S] to start Extracting^^!
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
		set "SAVHDR10P=YES"
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
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                               Dolby Vision Tool DEMUXER
%WHITE%
echo                                         ====================================
echo.
echo.
echo  == SETTINGS ============================================================================================================
%CYAN%
echo.
echo SAVE BL                        : [%BL%]
echo SAVE HDR10+ Metadata           : [%SAVHDR10P%]
echo Skip HDR10+ Validation         : [%SKIPHDR10P%]
echo Remove HDR10+ Metadata from BL : [%REMHDR10P%]
echo Convert HDR10+ Metadata to DV  : [%CHGHDR10P%]
echo Content Mapping Version        : [%CM_VERSION_text%]
echo.

call :SWITCHES
if "%RAW_FILE%"=="FALSE" call :DEMUX
if %BL%==YES call :DEMUX_BLEL
if "%SAVHDR10P%%CHGHDR10P%"=="YESNO" call :SAVE_HDR10P
if "%CHGHDR10P%"=="YES" call :CHG_HDR10P

echo.
goto :EXIT

:DV8
if "%HDR10P%"=="TRUE" goto DV8HDR10P
echo  == MENU ================================================================================================================
echo.
echo 1. SAVE BL             : [%BL%]
echo 2. SAVE RPU            : [%RPU%]
echo 3. CONVERT RPU         : [%CONVERT%]
call :colortxt 0F "4. CROP RPU" & call :colortxt 0E "*" & call :colortxt 0F "           : [%CROP%]" & call :colortxt 0E " *Whenever the final result doesn't have letterboxed bars set to [YES]." /n
%WHITE%
echo.
echo S. START
echo.
%GREEN%
echo Change Settings and press [S] to start Extracting^^!
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
	if "%CONVERT%"=="NO" set "CONVERT=PROFILE 7 MEL"
	if "%CONVERT%"=="PROFILE 7 MEL" set "CONVERT=PROFILE 8.1 HDR10"
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
echo  == MENU ================================================================================================================
echo.
echo 1. SAVE BL                        : [%BL%]
echo 2. SAVE RPU                       : [%RPU%]
echo 3. CONVERT RPU                    : [%CONVERT%]
call :colortxt 0F "4. CROP RPU" & call :colortxt 0E "*" & call :colortxt 0F "                      : [%CROP%]" & call :colortxt 0E " *Whenever the final result doesn't have letterboxed bars set to [YES]." /n
echo 5. Remove HDR10+ Metadata from BL : [%REMHDR10P%]
echo 6. SAVE HDR10+ Metadata           : [%SAVHDR10P%]
%WHITE%
echo.
echo S. START
echo.
%GREEN%
echo Change Settings and press [S] to start Extracting^^!
CHOICE /C 123456S /N /M "Select a Letter 1,2,3,4,5,6,[S]tart"

if "%ERRORLEVEL%"=="7" goto DV8EXT
if "%ERRORLEVEL%"=="6" (
	if "%SAVHDR10P%"=="NO" set "SAVHDR10P=YES"
	if "%SAVHDR10P%"=="YES" set "SAVHDR10P=NO"
)
if "%ERRORLEVEL%"=="5" (
	if "%REMHDR10P%"=="YES" set "REMHDR10P=NO"
	if "%REMHDR10P%"=="NO" (
		set "REMHDR10P=YES"
		set "BL=YES"
	)		
)
if "%ERRORLEVEL%"=="4" (
	if "%CROP%"=="YES" set "CROP=NO"
	if "%CROP%"=="NO" (
		set "CROP=YES"
		set "RPU=YES"
	)
)
if "%ERRORLEVEL%"=="3" (
	if "%CONVERT%"=="NO" set "CONVERT=PROFILE 7 MEL"
	if "%CONVERT%"=="PROFILE 7 MEL" set "CONVERT=PROFILE 8.1 HDR10"
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
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                               Dolby Vision Tool DEMUXER
%WHITE%
echo                                         ====================================
echo.
echo.
if "%HDR10P%"=="TRUE" (
	echo  == SETTINGS ============================================================================================================
	%CYAN%
	echo.
	echo SAVE BL                        : [%BL%]
	echo CROP RPU                       : [%CROP%]
	echo CONVERT RPU                    : [%CONVERT%]
	echo Remove HDR10+ Metadata from BL : [%REMHDR10P%]
	echo SAVE HDR10+ Metadata           : [%SAVHDR10P%]
	echo SAVE RPU                       : [%RPU%]
	%WHITE%
) else (
	echo  == SETTINGS ============================================================================================================
	%CYAN%	
	echo.
	echo SAVE BL                        : [%BL%]
	echo CROP RPU                       : [%CROP%]
	echo CONVERT RPU                    : [%CONVERT%]
	echo SAVE RPU                       : [%RPU%]
	%WHITE%
)
echo.

call :SWITCHES
if "%RAW_FILE%"=="FALSE" call :DEMUX
if "%HDR10P%%SAVHDR10P%"=="TRUEYES" call :SAVE_HDR10P
if "%BL%"=="YES" call :DEMUX_BLEL
if "%RPU%"=="YES" call :RPU_DEMUX

goto :EXIT

:DV7
if "!ELFILE!"=="TRUE" (
	set "BL=NO"
	set "EL=NO"
)
if "%HDR10P%"=="TRUE" goto DV7HDR10P
echo  == MENU ================================================================================================================
echo.
if "!ELFILE!"=="FALSE" call :colortxt 0F "1. SAVE BL" & call :colortxt 0E "*" & call :colortxt 0F "            : [%BL%]" & call :colortxt 0E " *For creating a Dual layer Profile 7 Disc set to [YES]." /n
if "!ELFILE!"=="FALSE" call :colortxt 0F "2. SAVE EL" & call :colortxt 0E "*" & call :colortxt 0F "            : [%EL%]" & call :colortxt 0E " *For creating a Dual layer Profile 7 Disc set to [YES]." /n
echo 3. SAVE RPU            : [%RPU%]
echo 4. CONVERT RPU         : [%CONVERT%]
call :colortxt 0F "5. CROP RPU" & call :colortxt 0E "*" & call :colortxt 0F "           : [%CROP%]" & call :colortxt 0E " *Whenever the final result doesn't have letterboxed bars set to [YES]." /n
echo.
echo S. START
echo.
%GREEN%
echo Change Settings and press [S] to start Extracting^^!
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
	if "%CONVERT%"=="NO" set "CONVERT=PROFILE 8.1 HDR10"
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
if "!ELFILE!"=="TRUE" (
	set "BL=NO"
	set "EL=NO"
)
echo  == MENU ================================================================================================================
echo.
if "!ELFILE!"=="FALSE" call :colortxt 0F "1. SAVE BL" & call :colortxt 0E "*" & call :colortxt 0F "                       : [%BL%]" & call :colortxt 0E " *For creating a Dual layer Profile 7 Disc set to [YES]." /n
echo 2. Remove HDR10+ Metadata from BL : [%REMHDR10P%]
echo 3. SAVE HDR10+ Metadata           : [%SAVHDR10P%]
echo 4. Skip HDR10+ Validation         : [%SKIPHDR10P%]
if "!ELFILE!"=="FALSE" call :colortxt 0F "5. SAVE EL" & call :colortxt 0E "*" & call :colortxt 0F "                       : [%EL%]" & call :colortxt 0E " *For creating a Dual layer Profile 7 Disc set to [YES]." /n
echo 6. SAVE RPU                       : [%RPU%]
echo 7. CONVERT RPU                    : [%CONVERT%]
call :colortxt 0F "8. CROP RPU" & call :colortxt 0E "*" & call :colortxt 0F "                      : [%CROP%]" & call :colortxt 0E " *Whenever the final result doesn't have letterboxed bars set to [YES]." /n
echo.
echo S. START
echo.
%GREEN%
echo Change Settings and press [S] to start Extracting^^!
CHOICE /C 12345678S /N /M "Select a Letter 1,2,3,4,5,6,7,8,[S]tart"

if "%ERRORLEVEL%"=="9" goto DV7EXT
if "%ERRORLEVEL%"=="8" (
	if "%CROP%"=="YES" set "CROP=NO"
	if "%CROP%"=="NO" (
		set "CROP=YES"
		set "RPU=YES"
	)
)
if "%ERRORLEVEL%"=="7" (
	if "%CONVERT%"=="NO" set "CONVERT=PROFILE 8.1 HDR10"
	if "%CONVERT%"=="PROFILE 8.1 HDR10" set "CONVERT=PROFILE 8.4 HLG"
	if "%CONVERT%"=="PROFILE 8.4 HLG" set "CONVERT=NO"
)
if "%ERRORLEVEL%"=="6" (
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
if "%ERRORLEVEL%"=="5" (
	if "%EL%"=="NO" set "EL=YES" & set "RPU=NO" & set "CONVERT=NO"
	if "%EL%"=="YES" set "EL=NO" & set "RPU=YES" & set "CONVERT=PROFILE 8.1 HDR10"
)
if "%ERRORLEVEL%"=="4" (
	if "%SKIPHDR10P%"=="NO" (
		set "SKIPHDR10P=YES"
		set "SAVHDR10P=YES"
	)
	if "%SKIPHDR10P%"=="YES" set "SKIPHDR10P=NO"
)
if "%ERRORLEVEL%"=="3" (
	if "%SAVHDR10P%"=="NO" set "SAVHDR10P=YES"
	if "%SAVHDR10P%"=="YES" (
		set "SAVHDR10P=NO"
		set "SKIPHDR10P=NO"
	)
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
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                               Dolby Vision Tool DEMUXER
%WHITE%
echo                                         ====================================
echo.
echo.
if "%HDR10P%"=="TRUE" (
	echo  == SETTINGS ============================================================================================================	
	%CYAN%
	echo.
	if "!ELFILE!"=="FALSE" echo SAVE BL                        : [%BL%]
	echo Remove HDR10+ Metadata from BL : [%REMHDR10P%]	
	echo SAVE HDR10+ Metadata           : [%SAVHDR10P%]
	echo Skip HDR10+ Validation         : [%SKIPHDR10P%]
	if "!ELFILE!"=="FALSE" echo SAVE EL                        : [%EL%]
	echo SAVE RPU                       : [%RPU%]
	echo CONVERT RPU                    : [%CONVERT%]
	echo CROP RPU                       : [%CROP%]
	%WHITE%
) else (
	echo  == SETTINGS ============================================================================================================
	%CYAN%
	echo.
	if "!ELFILE!"=="FALSE" echo SAVE BL             : [%BL%]
	if "!ELFILE!"=="FALSE" echo SAVE EL             : [%EL%]
	echo SAVE RPU            : [%RPU%]
	echo CONVERT RPU         : [%CONVERT%]
	echo CROP RPU            : [%CROP%]
	%WHITE%
)
echo.

call :SWITCHES
if "%RAW_FILE%"=="FALSE" call :DEMUX
if "%RAW_FILE%!VIDEO_COUNT!"=="TRUE2" call :DEMUX
if "%HDR10P%%SAVHDR10P%"=="TRUEYES" call :SAVE_HDR10P
if "%BL%%EL%" NEQ "NONO" call :DEMUX_BLEL
if "%RPU%"=="YES" call :RPU_DEMUX

goto :EXIT

:DV5
echo  == MENU ================================================================================================================
echo.
echo 1. CONVERT RPU         : [%CONVERT%]
call :colortxt 0F "2. CROP RPU" & call :colortxt 0E "*" & call :colortxt 0F "           : [%CROP%]" & call :colortxt 0E " *Whenever the final result doesn't have letterboxed bars set to [YES]." /n
echo.
echo S. START
echo.
%GREEN%
echo Change Settings and press [S] to start Extracting^^!
CHOICE /C 12S /N /M "Select a Letter 1,2,[S]tart"

if "%ERRORLEVEL%"=="3" goto DV5EXT
if "%ERRORLEVEL%"=="2" (
	if "%CROP%"=="NO" set "CROP=YES"
	if "%CROP%"=="YES" set "CROP=NO"
)
if "%ERRORLEVEL%"=="1" (
	if "%CONVERT%"=="NO" set "CONVERT=PROFILE 8.1 HDR10"
	if "%CONVERT%"=="PROFILE 8.1 HDR10" set "CONVERT=PROFILE 8.4 HLG"
	if "%CONVERT%"=="PROFILE 8.4 HLG" set "CONVERT=NO"
)
goto START

:DV5EXT
if not exist "!TMP_FOLDER!" MD "!TMP_FOLDER!">nul
if not exist "!TARGET_FOLDER!" MD "!TARGET_FOLDER!">nul
cls
%GREEN%
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                               Dolby Vision Tool DEMUXER
%WHITE%
echo                                         ====================================
echo.
echo.
echo  == SETTINGS ============================================================================================================
%CYAN%
echo.
echo CONVERT RPU         : [%CONVERT%]
echo CROP RPU            : [%CROP%]
echo.

call :SWITCHES
if "%RAW_FILE%"=="FALSE" call :DEMUX
call :RPU_DEMUX

goto :EXIT

:SWITCHES
if "!REMHDR10P!"=="YES" set "REMHDR10PString= --drop-hdr10plus"
if "!SKIPHDR10P!"=="YES" set "SKIPHDR10PString= --skip-validation"
if "!CONVERT!"=="NO" set "CONVERTSTRING="
if "!CONVERT!"=="PROFILE 8.1 HDR10" set "CONVERTSTRING=-m 2"
if "!DVprofile!!CONVERT!"=="5PROFILE 8.1 HDR10" set "CONVERTSTRING=-m 3"
if "!CONVERT!"=="PROFILE 8.4 HLG" set "CONVERTSTRING=-m 4"
if "!BL!"=="NO" set "EXTSTRING=--el-only"
if "!CROP!"=="YES" set "CROPSTRING=-c"
goto :eof

:DEMUX
if not exist "!TMP_FOLDER!" MD "!TMP_FOLDER!">nul
if not exist "!TARGET_FOLDER!" MD "!TARGET_FOLDER!">nul
%WHITE%
echo  == DEMUXING ============================================================================================================
echo.
%YELLOW%
echo ATTENTION^^! You need a lot of HDD Space for this operation.
PUSHD "!TMP_FOLDER!"
if "!VIDEO_COUNT!"=="1" (
	if "!DVProfile!"=="7" (
		if "%BL%%REMHDR10P%%SAVHDR10P%"=="NONONO" (
			%CYAN%
			echo.
			echo Please wait. Demuxing EL...
			%WHITE%
			"!FFMPEGpath!" -loglevel panic -stats -y -i "!INPUTFILE!" -c:v copy -bsf:v hevc_metadata -f hevc - | "!DO_VI_TOOLpath!" demux !EXTSTRING! -
			if exist "!TMP_FOLDER!\EL.hevc" (
				set "ELSTREAM=!TMP_FOLDER!\EL.hevc"
				%GREEN%
				echo EL Done.
			) else (
				%RED%
				echo EL Error.
				set /a "ERRORCOUNT=!ERRORCOUNT!+1"
			)
		) else (
			%CYAN%
			echo.
			echo Please wait. Demuxing BL and EL...
			%WHITE%
			"!FFMPEGpath!" -loglevel panic -stats -y -i "!INPUTFILE!" -c:v copy -bsf:v hevc_metadata -f hevc "!TMP_FOLDER!\temp.hevc"
			if exist "!TMP_FOLDER!\temp.hevc" (
				set "BLSTREAM=!TMP_FOLDER!\temp.hevc"
				set "ELSTREAM=!TMP_FOLDER!\temp.hevc"
				%GREEN%
				echo Done.
			) else (
				%RED%
				echo Error.
				set /a "ERRORCOUNT=!ERRORCOUNT!+1"
			)
		)
	) else (
		%CYAN%
		echo.
		echo Please wait. Demuxing BL...
		%WHITE%
		"!FFMPEGpath!" -loglevel panic -stats -y -i "!INPUTFILE!" -c:v copy -bsf:v hevc_metadata -f hevc "!TMP_FOLDER!\temp.hevc"
		if exist "!TMP_FOLDER!\temp.hevc" (
			set "BLSTREAM=!TMP_FOLDER!\temp.hevc"
			set "ELSTREAM=!TMP_FOLDER!\temp.hevc"
			%GREEN%
			echo Done.
		) else (
			%RED%
			echo Error.
			set /a "ERRORCOUNT=!ERRORCOUNT!+1"
		)
	)	
) else (
	if "%BL%%REMHDR10P%%SAVHDR10P%" NEQ "NONONO" (
		%CYAN%
		echo.
		echo Please wait. Demuxing BL...
		%WHITE%
		"!FFMPEGpath!" -loglevel panic -stats -y -i "!INPUTFILE!" -map 0:0 -c:v copy -bsf:v hevc_metadata -f hevc "!TMP_FOLDER!\BL.hevc"
		if exist "!TMP_FOLDER!\BL.hevc" (
			if "%BL%"=="NO" del "!TMP_FOLDER!\BL.hevc">nul
			if exist "!TMP_FOLDER!\BL.hevc" (
				set "BLSTREAM=!TMP_FOLDER!\BL.hevc"
				%GREEN%
				echo BL Done.
			) else (
				%RED%
				echo BL Error.
				set /a "ERRORCOUNT=!ERRORCOUNT!+1"
			)		
		)
	)
	if "%EL%%RPU%" NEQ "NONO" (
		%CYAN%
		echo.
		echo Please wait. Demuxing EL...
		%WHITE%
		"!FFMPEGpath!" -loglevel panic -stats -y -i "!INPUTFILE!" !DT! -c:v copy -bsf:v hevc_metadata -f hevc "!TMP_FOLDER!\EL.hevc"
		if exist "!TMP_FOLDER!\EL.hevc" (
			set "ELSTREAM=!TMP_FOLDER!\EL.hevc"
			%GREEN%
			echo EL Done.
		) else (
			%RED%
			echo EL Error.
			set /a "ERRORCOUNT=!ERRORCOUNT!+1"
		)	
	)
)

echo.
POPD
goto :eof

:DEMUX_BLEL
%CYAN%
if "%BL%%EL%%REMHDR10P%"=="YESNOYES" echo Please wait. Processing BL without HDR10+ Metadata...
if "%BL%%EL%%REMHDR10P%"=="YESYESYES" echo Please wait. Processing BL without HDR10+ Metadata and EL...
if "%BL%%EL%%REMHDR10P%"=="YESNONO" echo Please wait. Processing BL...
if "%BL%%EL%%REMHDR10P%"=="YESYESNO" echo Please wait. Processing BL and EL...
if "%BL%%EL%"=="NOYES" echo Please wait. Processing EL...
if "%REMHDR10P%"=="NO" (
	set "NAMESTRING=BL"
) else (
	set "NAMESTRING=BL no HDR10+"
)

PUSHD "!TARGET_FOLDER!"

if "%BL%"=="YES" (
	if exist "!TMP_FOLDER!\BL.hevc" (
		if "%REMHDR10P%"=="YES" (
			"!HDR10P_TOOLpath!" remove "!TMP_FOLDER!\BL.hevc" -o "!TARGET_FOLDER!\!INPUTFILENAME!_[!NAMESTRING!].hevc"
		) else ( 
			copy "!TMP_FOLDER!\BL.hevc" "!TARGET_FOLDER!\!INPUTFILENAME!_[!NAMESTRING!].hevc">nul
		)
	) else (
		if exist "!TMP_FOLDER!\temp.hevc" (
			"!DO_VI_TOOLpath!"%REMHDR10PString% demux !EXTSTRING! "!TMP_FOLDER!\temp.hevc"
			ren "!TARGET_FOLDER!\BL.hevc" "!INPUTFILENAME!_[!NAMESTRING!].hevc">nul
		)
	)		
	if exist "%TARGET_FOLDER%\!INPUTFILENAME!_[!NAMESTRING!].hevc" (
		%GREEN%
		echo BL Done.
	) else (
		%RED%
		echo BL Error.
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	)
)

if "%EL%"=="YES" (
	if exist "!TMP_FOLDER!\EL.hevc" (
		copy "!TMP_FOLDER!\EL.hevc" "!TARGET_FOLDER!\!INPUTFILENAME!_[EL].hevc">nul
	) else (
		if exist "!TMP_FOLDER!\temp.hevc" (
			"!DO_VI_TOOLpath!" demux !EXTSTRING! "!TMP_FOLDER!\temp.hevc"
			ren "!TARGET_FOLDER!\EL.hevc" "!INPUTFILENAME!_[EL].hevc"
		)
	)		
	if exist "%TARGET_FOLDER%\!INPUTFILENAME!_[EL].hevc" (
		%GREEN%
		echo EL Done.
	) else (
		%RED%
		echo EL Error.
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	)
)
if exist "!TARGET_FOLDER!\BL.hevc" del "!TARGET_FOLDER!\BL.hevc">nul
if exist "!TARGET_FOLDER!\EL.hevc" del "!TARGET_FOLDER!\EL.hevc">nul
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
if "!ELSTREAM!"=="" (
	set "ELSTREAM=!INPUTFILE!"
	%WHITE%
	echo  == DEMUXING ============================================================================================================
	echo.
)
%CYAN%
echo Please wait. Demuxing DV Reference Processing Unit...
%WHITE%
"!DO_VI_TOOLpath!" %CROPSTRING% %CONVERTSTRING% extract-rpu "!ELSTREAM!" -o "!TARGET_FOLDER!\!INPUTFILENAME!_[RPU!CSTRING!].bin"
if exist "!TARGET_FOLDER!\!INPUTFILENAME!_[RPU!CSTRING!].bin" (
	%GREEN%
	echo Done.
	echo.
) else (
	%RED%
	echo Error.
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	echo.
)
goto :eof

:RPU_EXTRACT
if not exist "!TMP_FOLDER!" MD "!TMP_FOLDER!">nul
if not exist "!TARGET_FOLDER!" MD "!TARGET_FOLDER!">nul
set "HEADERNAME=_[P!RPUProfile!]"
%CYAN%
echo Please wait. Extracting DV Reference Processing Unit...
%WHITE%
"!DOVI_METApath!" convert "!RPU!" "!TARGET_FOLDER!\!INPUTFILENAME!!HEADERNAME!.xml"
if exist "!TARGET_FOLDER!\!INPUTFILENAME!!HEADERNAME!.xml" (
	%GREEN%
	echo XML Done.
) else (
	%RED%
	echo XML Error.
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
)
echo.
%WHITE%
"!DO_VI_TOOLpath!" export -i "!RPU!" -d all="!TMP_FOLDER!\info.json"
"!jqpath!" . "!TMP_FOLDER!\info.json">"!TARGET_FOLDER!\!INPUTFILENAME!!HEADERNAME!.json"
if exist "!TARGET_FOLDER!\!INPUTFILENAME!!HEADERNAME!.json" (
	%GREEN%
	echo JSON Done.
	echo.
) else (
	%RED%
	echo JSON Error.
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	echo.
)
goto :eof

:CHG_HDR10P
%CYAN%
echo Please wait. Extracting HDR10+ SEI...
%WHITE%
"!HDR10P_TOOLpath!"%SKIPHDR10PString% extract "!BLSTREAM!" -o "!TMP_FOLDER!\HDR10Plus.json"
if exist "!TMP_FOLDER!\HDR10Plus.json" (
	if "%SAVHDR10P%"=="YES" copy "!TMP_FOLDER!\HDR10Plus.json" "!TARGET_FOLDER!\!INPUTFILENAME!_[HDR10+].json">nul
	%GREEN%
	echo Done.
	echo.
) else (
	%RED%
	echo Error.
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	echo.
)
%CYAN%
echo Please wait. Prefetching HDR10+ Metadata...
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
	%GREEN%
	echo Done.
	echo.
) else (
	%RED%
	echo Error.
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	echo.
)
%CYAN%
echo Please wait. Generate RPU.bin...
%WHITE%
"!DO_VI_TOOLpath!" generate -j "!TMP_FOLDER!\Extra.json" --hdr10plus-json "!TMP_FOLDER!\HDR10Plus.json" -o "!TARGET_FOLDER!\!INPUTFILENAME!_[HDR10+ RPU].bin"
if exist "!TARGET_FOLDER!\!INPUTFILENAME!_[HDR10+ RPU].bin" (
	%GREEN%
	echo Done.
	echo.
) else (
	%RED%
	echo Error during RPU.bin creating.
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	echo.
)
goto :eof

:SAVE_HDR10P
if not exist "!TARGET_FOLDER!\!INPUTFILENAME!_[HDR10+].json" (
	%CYAN%
	echo Please wait. Extracting HDR10+ SEI...
	%WHITE%
	"!HDR10P_TOOLpath!"%SKIPHDR10PString% extract "!BLSTREAM!" -o "!TARGET_FOLDER!\!INPUTFILENAME!_[HDR10+].json"
	if exist "!TARGET_FOLDER!\!INPUTFILENAME!_[HDR10+].json" (
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
goto :eof

:EXIT
%WHITE%
echo  == CLEANING ============================================================================================================
echo.
%CYAN%
echo Please wait. Cleaning Temp Folder...
if exist "!TARGET_FOLDER!\EL.hevc" if "%EL%"=="NO" (
	del "!TARGET_FOLDER!\EL.hevc">nul
	if "%ERRORLEVEL%"=="0" (
		%GREEN%
		echo Deleting EL.hevc - Done.
	) else (
		%RED%
		echo Deleting EL.hevc - Error.
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	)
)
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
%WHITE%
setlocal DisableDelayedExpansion
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
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('NEEDED FILE NOT FOUND!' + %NewLine% + %NewLine% + '%Line1%' + %NewLine% + %NewLine% + '%Line2%', 'DDVT Demuxer [QfG] v%VERSION%', 'Ok','Error')"
exit

:FALSEINPUT
if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
set "NewLine=[System.Environment]::NewLine"
set "Line1=Unsupported Input File. Supported Files are:"
set "Line2=*.mkv | *.mp4 | *.m2ts | *.h265 | *.hevc | *.bin"
setlocal DisableDelayedExpansion
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('%INPUTFILENAME%%INPUTFILEEXT%' + %NewLine% + %NewLine% + '%Line1%' + %NewLine% + %NewLine% + '%Line2%', 'DDVT Demuxer [QfG] v%VERSION%', 'Ok','Info')"
exit

:ERROR
if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
set "NewLine=[System.Environment]::NewLine"
set "Line1=%ERRORCOUNT% Error(s) during processing^!
set "Line2=Target file don''t exist or corrupt.
setlocal DisableDelayedExpansion
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('%INPUTFILENAME%%INPUTFILEEXT%' + %NewLine% + %NewLine% + '%Line1%' + %NewLine% + %NewLine% + '%Line2%', 'DDVT Demuxer [QfG] v%VERSION%', 'Ok','Error')"
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