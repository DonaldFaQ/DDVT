@echo off & setlocal
mode con cols=125 lines=40
set "VERSION=--N.A.-- INCORRECTLY INSTALLED"
set "HEADER1=File "%~dp0DDVT_OPTIONS.cmd" missing! Script works not correctly!"
FOR /F "tokens=2 delims==" %%A IN ('findstr /C:"VERSION=" "%~dp0DDVT_OPTIONS.cmd"') DO set "VERSION=%%A"
FOR /F "tokens=2 delims==" %%A IN ('findstr /C:"HEADER1=" "%~dp0DDVT_OPTIONS.cmd"') DO set "HEADER1=%%A"
TITLE DDVT FileInfo v%VERSION%
set DESIGN=STANDARD

set PasswordChars=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890
set PasswordLength=5
call :CreatePassword Password

set "Cecho=%~dp0tools\cecho_x64.exe" rem Path to cecho_x64.exe
set "sfkpath=%~dp0tools\sfk.exe" rem Path to sfk.exe
set "FFMPEGpath=%~dp0tools\ffmpeg.exe" rem Path to ffmpeg.exe
set "FFPROBEpath=%~dp0tools\ffprobe.exe" rem Path to ffprobe.exe
set "MADVRpath=%~dp0tools\madVR\madMeasureHDR.exe"
set "JQpath=%~dp0tools\jq-win64.exe" rem Path to jq.exe
set "IMAGEMAGICKpath=%~dp0tools\ImageMagick\magick.exe" rem Path to magick.exe
set "MP4BOXpath=%~dp0tools\mp4box.exe" rem Path to mp4box.exe
set "MEDIAINFOpath=%~dp0tools\mediainfo.exe" rem Path to mediainfo.exe
set "PYTHONpath=%~dp0tools\Python\Python.exe" rem Path to PYTHON exe
set "PYTHONSCRIPTpath=%~dp0tools\Python\Scripts" rem Path to PYTHON SCRIPTS
set "DO_VI_TOOLpath=%~dp0tools\dovi_tool.exe" rem Path to dovi_tool.exe
set "DO_VI_TOOLNFpath=%~dp0tools\dovi_tool_no_floor.exe" rem Path to dovi_tool_no_floor.exe
set "HDR10P_TOOLpath=%~dp0tools\hdr10plus_tool.exe" rem Path to hdr10plus_tool.exe

set "AVISYNTH_FOLDER=%ProgramFiles(x86)%\AviSynth+"
set "LAVFILTERS_FOLDER=%ProgramFiles(x86)%\LAV Filters"

rem --- Hardcoded settings. Can be changed manually ---
set "DVPLOT=L1 ONLY"
:: L1 ONLY / ALL / NO - Plot Metadata from RPU to PNG file. "ALL" works only with dovi_tool v2.3.0 and higher!
set "HDR10PLOT=NO"
:: YES / NO - Plot HDR Metadata via madVR.
set "HDR10PPLOT=YES"
:: YES / NO - Plot HDR10+ Metadata from json to PNG file.
set "VBITRATEPLOT=NO"
:: YES / NO - Plot video bitrate to PNG file.
set "FRAME=SCENECUTS"
:: SCENECUTS / ALL / NONE - Frameinfos from RPU..
set "MEDIAINFOFILE=NO"
:: YES / NO - Create mediainfo file.
set "PLOTTYPE=MAX"
:: MIN / MAX / ORIGINAL - Details of plotting infos. ORIGINAL=Original plotting outputs from quietvoid.
set "FIX_SCENECUTS=YES"
:: Set frame 0 scenecut flag in RPU to true. Also can be set in OPTIONS and overwrite this settings.
:: YES / NO
set "FORCE_FFMPEG_DEMUXING=NO"
:: Use FFMPEG as default demuxing engine instead of MKVExtract/Mp4Box.
:: YES / NO

rem --- Hardcoded settings. Cannot be changed ---
set "TESTMODE=OFF"
set "INPUTFILE=%~dpnx1"
set "INPUTFILEPATH=%~dp1"
set "INPUTFILENAME=%~n1"
set "INPUTFILEEXT=%~x1"
set "TMP_FOLDER=SAME AS SOURCE"
set "MKVTOOLNIX_FOLDER=INCLUDED"
set "MP4Extract=FALSE"
set "MKVExtract=FALSE"
set "HDR=FALSE"
set "HDR10P=FALSE"
set "DV=FALSE"
set "RAW_FILE=FALSE"
set "RPU_FILE=FALSE"
set "HDR10P_FILE=FALSE"
set "ELFILE=FALSE"
set "HDR_Info=No HDR Infos found"
set "RESOLUTION=n.A."
set "HDR=n.A."
set "CODEC_NAME=n.A."
set "FRAMERATE=n.A."
set "FRAMES=n.A."
set "BORDERCHECK=FALSE"
set "L2100=FALSE"
set "L2300=FALSE"
set "L2600=FALSE"
set "L21000=FALSE"
set "L22000=FALSE"
set "L24000=FALSE"
set /a "ERRORCOUNT=0"

setlocal EnableDelayedExpansion

::Check for INI and Load Settings
IF EXIST "%~dp0DDVT_OPTIONS.ini" (
	FOR /F "delims=" %%A IN ('findstr /C:"TEMP Folder=" "%~dp0DDVT_OPTIONS.ini"') DO (
		set "TMP_FOLDER=%%A"
		set "TMP_FOLDER=!TMP_FOLDER:~12!"
	)
	FOR /F "delims=" %%A IN ('findstr /C:"MKVTOOLNIX Folder=" "%~dp0DDVT_OPTIONS.ini"') DO (
		set "MKVTOOLNIX_FOLDER=%%A"
		set "MKVTOOLNIX_FOLDER=!MKVTOOLNIX_FOLDER:~18!"
	)
	FOR /F "delims=" %%A IN ('findstr /C:"LAVFILTERS Folder=" "%~dp0DDVT_OPTIONS.ini"') DO (
		set "LAVFILTERS_FOLDER=%%A"
		set "LAVFILTERS_FOLDER=!LAVFILTERS_FOLDER:~18!"
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

if not exist "!LAVFILTERS_FOLDER!\x64\LAVSplitter.ax" set HDR10PLOT=NO

if "!MKVTOOLNIX_FOLDER!"=="INCLUDED" set "MKVTOOLNIX_FOLDER=%~dp0tools"
set "MKVMERGEpath=!MKVTOOLNIX_FOLDER!\mkvmerge.exe"
set "MKVEXTRACTpath=!MKVTOOLNIX_FOLDER!\mkvextract.exe"

if not exist "%Cecho%" set "MISSINGFILE=%~dp0tools\cecho_x64.exe" & goto :CORRUPTFILE
if not exist "%sfkpath%" set "MISSINGFILE=%sfkpath%" & goto :CORRUPTFILE
if not exist "%FFMPEGpath%" set "MISSINGFILE=%FFMPEGpath%" & goto :CORRUPTFILE
if not exist "%FFPROBEpath%" set "MISSINGFILE=%FFPROBEpath%" & goto :CORRUPTFILE
if not exist "%MKVMERGEpath%" set "MISSINGFILE=%MKVMERGEpath%" & goto :CORRUPTFILE
if not exist "%MKVEXTRACTpath%" set "MISSINGFILE=%MKVEXTRACTpath%" & goto :CORRUPTFILE
if not exist "%MADVRpath%" set "MISSINGFILE=%MADVRpath%" & goto :CORRUPTFILE
if not exist "%JQpath%" set "MISSINGFILE=%JQpath%" & goto :CORRUPTFILE
if not exist "%IMAGEMAGICKpath%" set "MISSINGFILE=%IMAGEMAGICKpath%" & goto :CORRUPTFILE
if not exist "%MP4BOXpath%" set "MISSINGFILE=%MP4BOXpath%" & goto :CORRUPTFILE
if not exist "%MEDIAINFOpath%" set "MISSINGFILE=%MEDIAINFOpath%" & goto :CORRUPTFILE
if not exist "%PYTHONpath%" set "MISSINGFILE=%PYTHONpath%" & goto :CORRUPTFILE
if not exist "%DO_VI_TOOLpath%" set "MISSINGFILE=%DO_VI_TOOLpath%" & goto :CORRUPTFILE
if not exist "%DO_VI_TOOLNFpath%" set "MISSINGFILE=%DO_VI_TOOLNFpath%" & goto :CORRUPTFILE
if not exist "%HDR10P_TOOLpath%" set "MISSINGFILE=%HDR10P_TOOLpath%" & goto :CORRUPTFILE

if /i "!INPUTFILEEXT!"=="" CALL :INSERT_INPUT

if "%TMP_FOLDER%"=="SAME AS SOURCE" (
	set "TMP_FOLDER=!INPUTFILEPATH!DDVT_%Password%_TMP"
) else (
	set "TMP_FOLDER=!TMP_FOLDER!\DDVT_%Password%_TMP"
)

if /i "!INPUTFILEEXT!"==".mkv" set "MKVExtract=TRUE" & goto :CHECK
if /i "!INPUTFILEEXT!"==".mp4" set "MP4Extract=TRUE" & goto :CHECK
if /i "!INPUTFILEEXT!"==".m2ts" set "M2TS_FILE=TRUE" & goto :CHECK
if /i "!INPUTFILEEXT!"==".h265" set "RAW_FILE=TRUE" & goto :CHECK
if /i "!INPUTFILEEXT!"==".hevc" set "RAW_FILE=TRUE" & goto :CHECK
if /i "!INPUTFILEEXT!"==".bin" set "RPU_FILE=TRUE" & set "RPUFILE=!INPUTFILE!" & goto :CHECK
if /i "!INPUTFILEEXT!"==".json" set "HDR10P_FILE=TRUE" & set "HDR10PFILE=!INPUTFILE!" & goto :CHECK
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
echo        .bin ^| .mp4 ^| .m2ts ^| .mkv ^| .json ^| .h265 ^| .hevc
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
echo                                              Dolby Vision Tool FILEINFO
%WHITE%
echo                                         ====================================
echo.
echo.
echo  == CHECK INPUT FILE ====================================================================================================
if not exist "!TMP_FOLDER!" md "!TMP_FOLDER!"
echo.
%CYAN%
if "!RPU_FILE!!HDR10P_FILE!"=="FALSEFALSE" (
	echo Analysing File. Please wait...
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
	set "PHDR=!HDRFormat!"
	if "!HDRFormat!"=="HDR10+" set "PHDR=HDR"

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
	if "!RPU_EXIST!"=="TRUE" (
		%HCGREEN%
		"!DO_VI_TOOLpath!" info -i "!TMP_FOLDER!\RPU.bin" -s>"!TMP_FOLDER!\RPUINFO.txt"
		FOR /F "delims=" %%A IN ('findstr /C:"Profile:" "!TMP_FOLDER!\RPUINFO.txt"') DO set "RPU_PROFILE=%%A"
		if defined RPU_PROFILE (
			for /F "tokens=2 delims=:/ " %%A in ("!RPU_PROFILE!") do set "RPU_DVP=%%A"
			if "!RPU_DVP!"=="7" for /F "tokens=3 delims=:/ " %%A in ("!RPU_PROFILE!") do set "RPU_DVSP= %%A"
		) else (
			set "RPU_DVP=N/A"
		)
		FOR /F "delims=" %%A IN ('findstr /C:"DM version" "!TMP_FOLDER!\RPUINFO.txt"') DO set "RPU_CMV=%%A"
		if defined RPU_CMV (
			for /F "tokens=3 delims=:/()" %%A in ("!RPU_CMV!") do set "RPU_CMV=%%A"
		) else (
			set "RPU_CMV=N/A"
		)
		FOR /F "delims=" %%A IN ('findstr /C:"Frames" "!TMP_FOLDER!\RPUINFO.txt"') DO set "RPU_FRAMES=%%A"
		if defined RPU_FRAMES (
			for /F "tokens=2 delims=:/() " %%A in ("!RPU_FRAMES!") do set "RPU_FRAMES=%%A"
		) else (
			set "RPU_FRAMES=N/A"
		)
		FOR /F "tokens=2 delims=:" %%A IN ('findstr /C:"L2 trims" "!TMP_FOLDER!\RPUINFO.txt"') DO set "L2_TRIMS=%%A"
		if defined L2_TRIMS (
			set "L2_TRIMS=!L2_TRIMS:~1!"
			echo "!L2_TRIMS!" | find "100 nits">nul 2>&1
			if "!ERRORLEVEL!"=="0" set "L2100=TRUE"
			echo "!L2_TRIMS!" | find "300 nits">nul 2>&1
			if "!ERRORLEVEL!"=="0" set "L2300=TRUE"
			echo "!L2_TRIMS!" | find "600 nits">nul 2>&1
			if "!ERRORLEVEL!"=="0" set "L2600=TRUE"
			echo "!L2_TRIMS!" | find "1000 nits">nul 2>&1
			if "!ERRORLEVEL!"=="0" set "L21000=TRUE"
			echo "!L2_TRIMS!" | find "2000 nits">nul 2>&1
			if "!ERRORLEVEL!"=="0" set "L22000=TRUE"
			echo "!L2_TRIMS!" | find "4000 nits">nul 2>&1
			if "!ERRORLEVEL!"=="0" set "L24000=TRUE"
		) else (
			set "L2_TRIMS=No L2 entries in RPU."
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
	FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%MasteringDisplay_ColorPrimaries%% "!INFOSTREAM!""') do set "MDCP=%%A"
	if not defined MDCP (set "MDCP=") else (set "MDCP= ^(!MDCP!^)")
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
	if exist "!TMP_FOLDER!\Info.mkv" del "!TMP_FOLDER!\Info.mkv">nul
	if exist "!TMP_FOLDER!\BL.mkv" del "!TMP_FOLDER!\BL.mkv">nul
	if exist "!TMP_FOLDER!\RPU.bin" del "!TMP_FOLDER!\RPU.bin">nul
	if "!HDR!"=="TRUE" set "HDR_Info=!HDRFormat!"
	if "!HDR10P!"=="TRUE" set "HDR_Info=HDR10, !HDRFormat!"
	if "!DV!"=="TRUE" set "HDR_Info=Dolby Vision Profile !DV_Profile!"	
	if "!HDR!!DV!"=="TRUETRUE" set "HDR_Info=!HDRFormat!, Dolby Vision Profile !DV_Profile!"
	if "!HDR10P!!DV!"=="TRUETRUE" set "HDR_Info=HDR10, !HDRFormat!, Dolby Vision Profile !DV_Profile!"

	if exist "!TMP_FOLDER!\Info.txt" del "!TMP_FOLDER!\Info.txt">nul
	if exist "!TMP_FOLDER!\Info.mkv" del "!TMP_FOLDER!\Info.mkv">nul
) else (
	if "!RPU_FILE!"=="TRUE" (
		%CYAN%
		echo Analysing DV RPU. Please wait...
		echo.
		"!DO_VI_TOOLpath!" info -i "!RPUFILE!" -s>"!TMP_FOLDER!\RPUINFO.txt"
		if exist "!TMP_FOLDER!\RPUINFO.txt" (
			%HCGREEN%
			set "DV=TRUE"
			FOR /F "delims=" %%A IN ('findstr /C:"Profile:" "!TMP_FOLDER!\RPUINFO.txt"') DO set "RPU_PROFILE=%%A"
			if defined RPU_PROFILE (
				for /F "tokens=2 delims=:/ " %%A in ("!RPU_PROFILE!") do set "RPU_DVP=%%A"
				if "!RPU_DVP!"=="7" for /F "tokens=3 delims=:/ " %%A in ("!RPU_PROFILE!") do set "RPU_DVSP= %%A"
			) else (
				set "RPU_DVP=N/A"
			)
			FOR /F "delims=" %%A IN ('findstr /C:"DM version" "!TMP_FOLDER!\RPUINFO.txt"') DO set "RPU_CMV=%%A"
			if defined RPU_CMV (
				for /F "tokens=3 delims=:/()" %%A in ("!RPU_CMV!") do set "RPU_CMV=%%A"
			) else (
				set "RPU_CMV=N/A"
			)
			FOR /F "delims=" %%A IN ('findstr /C:"Frames" "!TMP_FOLDER!\RPUINFO.txt"') DO set "RPU_FRAMES=%%A"
			if defined RPU_FRAMES (
				for /F "tokens=2 delims=:/() " %%A in ("!RPU_FRAMES!") do set "RPU_FRAMES=%%A"
			) else (
				set "RPU_FRAMES=N/A"
			)
			FOR /F "tokens=2 delims=:" %%A IN ('findstr /C:"L2 trims" "!TMP_FOLDER!\RPUINFO.txt"') DO set "L2_TRIMS=%%A"
			if defined L2_TRIMS (
				set "L2_TRIMS=!L2_TRIMS:~1!"
				echo "!L2_TRIMS!" | find "100 nits">nul 2>&1
				if "!ERRORLEVEL!"=="0" set "L2100=TRUE"
				echo "!L2_TRIMS!" | find "300 nits">nul 2>&1
				if "!ERRORLEVEL!"=="0" set "L2300=TRUE"
				echo "!L2_TRIMS!" | find "600 nits">nul 2>&1
				if "!ERRORLEVEL!"=="0" set "L2600=TRUE"
				echo "!L2_TRIMS!" | find "1000 nits">nul 2>&1
				if "!ERRORLEVEL!"=="0" set "L21000=TRUE"
				echo "!L2_TRIMS!" | find "2000 nits">nul 2>&1
				if "!ERRORLEVEL!"=="0" set "L22000=TRUE"
				echo "!L2_TRIMS!" | find "4000 nits">nul 2>&1
				if "!ERRORLEVEL!"=="0" set "L24000=TRUE"
			) else (
				set "L2_TRIMS=No L2 entries in RPU."
			)
			echo Done.
		) else (
			%HCRED%
			echo Error.
			goto :EXIT
		)
	)
	if "!HDR10P_FILE!"=="TRUE" (
		%CYAN%
		echo Analysing HDR10+ SEI. Please wait...
		%HCGREEN%
		echo Done.
		echo.
		call :HDR10Plus_PLOTPNG
		goto :EXIT
	)
)

if "!RPU_FILE!!HDR!!DV!"=="FALSEFALSEFALSE" (
	echo.
	%HCYELLOW%
	echo No HDR / DV found in videostream.
	echo Script works only with HDR / DV Content.
	echo.
	%HCGREEN%
	echo Analysing complete.
	echo.
	goto :EXIT
) else (
	echo.
	%HCGREEN%
	echo Analysing complete.
	echo.
)

if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
TIMEOUT 2 /NOBREAK>nul
if /i "%~2"=="-CHECK" goto :DV8CHK

:START
if "!HDR!"=="FALSE" set "HDR10PLOT=NO"
if "!DV!"=="FALSE" set "DVPLOT=NO
if "!DV!"=="FALSE" set "FRAME=NONE
if "!HDR10P!"=="FALSE" set "HDR10PPLOT=NO
if "!RPU_FILE!"=="TRUE" set "MEDIAINFOFILE=NO
if "!RPU_FILE!"=="TRUE" set "HDR10PPLOT=NO
if "!RPU_FILE!"=="TRUE" set "VBITRATEPLOT=NO
if "!RAW_FILE!"=="TRUE" set "VBITRATEPLOT=NO
if "!BORDERCHECK!"=="FALSE" set "BC_INFO={%HC_YELLOW%}NOT CHECKED"
if "!BORDERCHECK!"=="TRUE" set "BC_INFO={%HC_GREEN%}CHECKED"
if exist "!INPUTFILENAME!_[RPU BORDERS FIXED]!INPUTFILEEXT!" set "BC_INFO={%HC_GREEN%}FIXED FILE FOUND IN DIR"
cls
%GREEN%
echo  !HEADER1!
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool FILEINFO
%WHITE%
echo                                         ====================================
echo.
echo.
if "%RPU_FILE%"=="FALSE" (
	echo  == VIDEO INPUT =========================================================================================================
	echo.
	%CYAN%
	echo Filename   = [!INPUTFILENAME!!INPUTFILEEXT!]
	echo Video Info = [Resolution = !RESOLUTION!] [Codec = !CODEC_NAME!] [Frames = !FRAMES!] [FPS = !FRAMERATE!]
	echo HDR Info   = [!HDR_Info!]
	echo.
) else (
	echo.
	echo  == RPU INPUT ===========================================================================================================
	echo.
	%CYAN%
	echo Filename   = [!INPUTFILENAME!!INPUTFILEEXT!]
	echo RPU Info   = [DV Profile = !RPU_DVP!!RPU_DVSP!] [DM = !RPU_CMV!] [Frames = !RPU_FRAMES!]
	echo.
)
%WHITE%
echo  == MENU ================================================================================================================
echo.
%HCWHITE%
if "!RPU_FILE!!RAW_FILE!"=="FALSEFALSE" echo 1. Video Bitrate Plotting         : [!VBITRATEPLOT!]
if "!DV!"=="TRUE" (
	echo 2. DV L1 PNG Plotting             : [!DVPLOT!]
	echo 3. DV Frameinfo                   : [Frame^(s^)^: !FRAME!]
)
if "!HDR!"=="TRUE" (
	echo 4. HDR PNG Plotting               : [!HDR10PLOT!]
)
if "!HDR10P!"=="TRUE" (
	echo 5. HDR10+ Metadata PNG Plotting   : [!HDR10PPLOT!]
)
if "!RPU_FILE!"=="FALSE" echo 6. Create MediaInfo File          : [!MEDIAINFOFILE!]
echo.
if "!DV_Profile!"=="8" (
	"!Cecho!" {%HC_WHITE%}C. CHECK RPU CROPPING VALUES{%HC_YELLOW%}*{%HC_WHITE%}     : [!BC_INFO!{%HC_WHITE%}]   {%HC_YELLOW%}*Check and Fix wrong cropped Releases{#}{\n}
	echo.
)
%GREEN%
echo S. START
%HCWHITE%
echo.
"!Cecho!" {%HC_WHITE%}Change Settings and press [{%_GREEN%}S{%HC_WHITE%}] to Start^^!{#}{\n}
CHOICE /C 123456CS /N /M "Select a Letter 1,2,3,4,5,6,C,[S]tart"

if "%ERRORLEVEL%"=="8" goto :OPERATION
if "!DV_Profile!%ERRORLEVEL%"=="87" call :DV8CHK
if "%ERRORLEVEL%"=="6" (
	if "%MEDIAINFOFILE%"=="NO" set "MEDIAINFOFILE=YES"
	if "%MEDIAINFOFILE%"=="YES" set "MEDIAINFOFILE=NO"
)
if "%ERRORLEVEL%"=="5" (
	if "%HDR10PPLOT%"=="NO" set "HDR10PPLOT=YES"
	if "%HDR10PPLOT%"=="YES" set "HDR10PPLOT=NO"
)
if "%ERRORLEVEL%"=="4" (
	if not exist "!LAVFILTERS_FOLDER!\x64\LAVSplitter.ax" (
		call :NOLAVFILTERS
	) else (
		if "%HDR10PLOT%"=="NO" set "HDR10PLOT=YES"
		if "%HDR10PLOT%"=="YES" set "HDR10PLOT=NO"
	)
)
if "%ERRORLEVEL%"=="3" call :DV_FRAMEINFO

if "%ERRORLEVEL%"=="2" (
	if "%DVPLOT%"=="NO" set "DVPLOT=L1 ONLY"
	if "%DVPLOT%"=="L1 ONLY" set "DVPLOT=ALL"	
	if "%DVPLOT%"=="ALL" set "DVPLOT=NO"

)
if "%ERRORLEVEL%"=="1" (
	if "%VBITRATEPLOT%"=="NO" set "VBITRATEPLOT=YES"
	if "%VBITRATEPLOT%"=="YES" set "VBITRATEPLOT=NO"
)
goto :START

:OPERATION
if not exist "!TMP_FOLDER!" MD "!TMP_FOLDER!">nul
if not exist "!TARGET_FOLDER!" MD "!TARGET_FOLDER!">nul
mode con cols=125 lines=60
cls
%GREEN%
echo  !HEADER1!
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool FILEINFO
%WHITE%
echo                                         ====================================
echo.
echo.
%WHITE%
echo  == OPERATION ===========================================================================================================
echo.
set "VIDEOSTREAM=!INPUTFILE!"
if "!RPU_FILE!!RAW_FILE!"=="FALSEFALSE" call :DEMUX
if "!VBITRATEPLOT!"=="YES" call :BITRATE_PLOTTING
if "!HDR10PLOT!"=="YES" call :HDR10_PLOTPNG
if "!RPU_FILE!!DV!"=="FALSETRUE" call :RPU_EXTRACT
if "!DVPLOT!" NEQ "NO" call :DV_PLOTPNG
if "!FRAME!" NEQ "NONE" call :WRITE_DV_FRAMEINFO
if "!HDR10P!!HDR10PPLOT!"=="TRUEYES" call :HDR10P_EXTRACT
if "!HDR10PPLOT!"=="YES" call :HDR10Plus_PLOTPNG
if "!MEDIAINFOFILE!"=="YES" call :C_MEDIAINFO
goto :EXIT

:DEMUX
if "!DVPLOT!!VBITRATEPLOT!!HDR10PLOT!!HDR10PPLOT!!MEDIAINFOFILE!!FRAME!"=="NONONONONONONE" goto :eof
if "!VBITRATEPLOT!!HDR10PLOT!!HDR10PPLOT!"=="NONONO" goto :eof
%HCYELLOW%
echo ATTENTION^^! You need a lot of HDD Space for this operation.
echo.
if "!VIDEO_COUNT!" NEQ "1" (
	if "!VBITRATEPLOT!!HDR10PLOT!!HDR10PPLOT!" NEQ "NONONO" (
		%CYAN%
		echo Please wait. Extracting BL...
		%WHITE%
		if "!FORCE_FFMPEG_DEMUXING!!MKVExtract!"=="NOTRUE" "!MKVEXTRACTpath!" "!INPUTFILE!" tracks --ui-language en  !BL_INDEX!:"!TMP_FOLDER!\BL.hevc"
		if "!FORCE_FFMPEG_DEMUXING!!MP4Extract!"=="NOTRUE" "!MP4BOXpath!" -raw !BL_INDEX! "!INPUTFILE!" -out "!TMP_FOLDER!\BL.hevc"
		if not exist "!TMP_FOLDER!\temp.hevc" "!FFMPEGpath!" -loglevel panic -stats -i "!INPUTFILE!" -map 0:!BL_INDEX! -c:v copy -bsf:v hevc_mp4toannexb -f hevc "!TMP_FOLDER!\BL.hevc"
		if exist "!TMP_FOLDER!\BL.hevc" (
			for %%f in ("!TMP_FOLDER!\BL.hevc") do set "CHECKSIZE=%%~zf" >nul 2>&1
			if "!CHECKSIZE!" NEQ "0" (
				%HCGREEN%
				set "BLSTREAM=!TMP_FOLDER!\BL.hevc"
				echo Done.
				echo.
			) else (
				%HCRED%
				set /a "ERRORCOUNT=!ERRORCOUNT!+1"
				echo Error.
				echo.
			)
		) else (
			%HCRED%
			echo Error.
			set /a "ERRORCOUNT=!ERRORCOUNT!+1"
			echo.
		)
	)
	if "!DVPLOT!!FRAME!" NEQ "NONONE" (
		%CYAN%
		echo Please wait. Extracting EL...
		%WHITE%
		if "!FORCE_FFMPEG_DEMUXING!!MKVExtract!"=="NOTRUE" "!MKVEXTRACTpath!" "!INPUTFILE!" tracks --ui-language en  !EL_INDEX!:"!TMP_FOLDER!\EL.hevc"
		if "!FORCE_FFMPEG_DEMUXING!!MP4Extract!"=="NOTRUE" "!MP4BOXpath!" -raw !EL_INDEX! "!INPUTFILE!" -out "!TMP_FOLDER!\EL.hevc"
		if not exist "!TMP_FOLDER!\temp.hevc" "!FFMPEGpath!" -loglevel panic -stats -i "!INPUTFILE!" -map 0:!EL_INDEX! -c:v copy -bsf:v hevc_mp4toannexb -f hevc "!TMP_FOLDER!\EL.hevc"
		if exist "!TMP_FOLDER!\EL.hevc" (
			for %%f in ("!TMP_FOLDER!\EL.hevc") do set "CHECKSIZE=%%~zf" >nul 2>&1
			if "!CHECKSIZE!" NEQ "0" (
				%HCGREEN%
				set "ELSTREAM=!TMP_FOLDER!\EL.hevc"
				echo Done.
				echo.
			) else (
				%HCRED%
				set /a "ERRORCOUNT=!ERRORCOUNT!+1"
				echo Error.
				echo.
			)
		) else (
			%HCRED%
			echo Error.
			set /a "ERRORCOUNT=!ERRORCOUNT!+1"
			echo.
		)
	)
) else (
	%CYAN%
	echo Please wait. Extracting Video Layer...
	%WHITE%
	if "!FORCE_FFMPEG_DEMUXING!!MKVExtract!"=="NOTRUE" "!MKVEXTRACTpath!" "!INPUTFILE!" tracks --ui-language en  !BL_INDEX!:"!TMP_FOLDER!\temp.hevc"
	if "!FORCE_FFMPEG_DEMUXING!!MP4Extract!"=="NOTRUE" "!MP4BOXpath!" -raw !BL_INDEX! "!INPUTFILE!" -out "!TMP_FOLDER!\temp.hevc"
	if not exist "!TMP_FOLDER!\temp.hevc" "!FFMPEGpath!" -loglevel panic -stats -i "!INPUTFILE!" -map 0:!BL_INDEX! -c:v copy -bsf:v hevc_mp4toannexb -f hevc "!TMP_FOLDER!\temp.hevc"
	if exist "!TMP_FOLDER!\temp.hevc" (
		for %%f in ("!TMP_FOLDER!\temp.hevc") do set "CHECKSIZE=%%~zf" >nul 2>&1
		if "!CHECKSIZE!" NEQ "0" (
			%HCGREEN%
			set "BLSTREAM=!TMP_FOLDER!\temp.hevc"
			set "ELSTREAM=!TMP_FOLDER!\temp.hevc"
			echo Done.
			echo.
		) else (
			%HCRED%
			set /a "ERRORCOUNT=!ERRORCOUNT!+1"
			echo Error.
			echo.
		)
	) else (
		%HCRED%
		echo Error.
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
		echo.
	)
)
goto :eof

:RPU_EXTRACT
if "!DVPLOT!!FRAME!"=="NONONE" goto :eof
%CYAN%
echo Please wait. Demuxing DV RPU...
%WHITE%
if exist "!ELSTREAM!" (
	"!DO_VI_TOOLpath!" extract-rpu "!ELSTREAM!" -o "!TMP_FOLDER!\RPU.bin"
) else (
	"!FFMPEGpath!" -loglevel panic -stats -i "!INPUTFILE!" -map 0:!EL_INDEX! -c:v copy -bsf:v hevc_mp4toannexb -f hevc - | "!DO_VI_TOOLpath!" extract-rpu -o "!TMP_FOLDER!\RPU.bin" -
)
if exist "!TMP_FOLDER!\RPU.bin" (
	set "RPUFILE=!TMP_FOLDER!\RPU.bin"
	%HCGREEN%
	echo Done.
	echo.
) else (
	%HCRED%
	echo Error.
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	echo.
)
goto :eof

:HDR10P_EXTRACT
%CYAN%
echo Please wait. Demuxing HDR10+ SEI...
%WHITE%
if exist "!BLSTREAM!" (
	"!HDR10P_TOOLpath!" extract "!BLSTREAM!" -o "!TMP_FOLDER!\HDR10Plus.json"
) else (
	"!FFMPEGpath!" -loglevel panic -stats -i "!INPUTFILE!" -map 0:!BL_INDEX! -c:v copy -bsf:v hevc_mp4toannexb -f hevc - | "!HDR10P_TOOLpath!" extract "!BLSTREAM!" -o "!TMP_FOLDER!\HDR10Plus.json" -
)
if exist "!TMP_FOLDER!\HDR10Plus.json" (
	set "HDR10PFILE=!TMP_FOLDER!\HDR10Plus.json"
	%HCGREEN%
	echo Done.
	echo.
) else (
	%HCRED%
	echo Error.
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	echo.
)
goto :eof

:BITRATE_PLOTTING
%CYAN%
echo Please wait. Plotting Video Bitrate...
%WHITE%
copy "!FFPROBEpath!" "!INPUTFILEPATH!" >nul
attrib +h "!INPUTFILEPATH!\ffprobe.exe" >nul
%WHITE%
"!PYTHONpath!" "!PYTHONSCRIPTpath!\plotbitrate.py" -o "!TMP_FOLDER!\!INPUTFILENAME!.png" -f png "!INPUTFILEPATH!!INPUTFILENAME!!INPUTFILEEXT!"
if exist "!TMP_FOLDER!\!INPUTFILENAME!.png" "!IMAGEMAGICKpath!" convert "!TMP_FOLDER!\!INPUTFILENAME!.png" -quality 100 -fill white -stroke none -draw "rectangle 0,0 3000,100" -fill black -font Arial-Bold -pointsize 30 -gravity Center -annotate -0-532 "!INPUTFILENAME!!INPUTFILEEXT!" -font Arial -pointsize 25 -annotate -0-498 "(Video Bitrate Plot)" "!INPUTFILEPATH!!INPUTFILENAME!_[Video Bitrate Plot].png"
if exist "!INPUTFILEPATH!!INPUTFILENAME!_[Video Bitrate Plot].png" (
	%HCGREEN%
	echo Done.
	attrib -h "!INPUTFILEPATH!\ffprobe.exe" >nul
	del "!INPUTFILEPATH!\ffprobe.exe"
	echo.	
) else (
	%HCRED%
	echo Error.
	attrib -h "!INPUTFILEPATH!\ffprobe.exe" >nul
	del "!INPUTFILEPATH!\ffprobe.exe" >nul
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	echo.
)
goto :eof

:HDR10_PLOTPNG
:: Credits for this function goes to R3S3t9999. Original tool from R3S3t9999 here: https://github.com/R3S3t9999/DoVi_Scripts
%CYAN%
echo Please wait. Plotting !PHDR!...
%WHITE%
set "WORKFILE=!INPUTFILE!"
if "!RAW_FILE!"=="TRUE" (
	%CYAN%
	echo Please wait. Muxing Videostream into Container...
	echo.
	%HCYELLOW%
	echo Don't close the "Muxing !INPUTFILENAME! into MKV" cmd window.
	start /WAIT /MIN "Muxing !INPUTFILENAME! into MKV" "!MKVMERGEpath!" --ui-language en --priority higher --output ^"!TMP_FOLDER!\VIDEOSTREAM.mkv^" --language 0:und --compression 0:none ^"^(^" ^"!INPUTFILE!^" ^"^)^"
	if exist "!TMP_FOLDER!\VIDEOSTREAM.mkv" (
		set "WORKFILE=!TMP_FOLDER!\VIDEOSTREAM.mkv"
		%HCGREEN%
		echo Done.
		echo.
	)
)
if "!VIDEO_COUNT!" NEQ "1" (
	%CYAN%
	echo Please wait. Muxing Videostream into MKV Container...
	echo.
	%HCYELLOW%
	if exist "!BLSTREAM!" (
		echo Don't close the "Muxing !INPUTFILENAME! into MKV" cmd window.
		start /WAIT /MIN "Muxing !INPUTFILENAME! into MKV" "!MKVMERGEpath!" --ui-language en --priority higher --output ^"!TMP_FOLDER!\VIDEOSTREAM.mkv^" --language 0:und --compression 0:none ^"^(^" ^"!BLSTREAM!^" ^"^)^"
		if exist "!TMP_FOLDER!\VIDEOSTREAM.mkv" (
			set "WORKFILE=!TMP_FOLDER!\VIDEOSTREAM.mkv"
			%HCGREEN%
			echo Done.
			echo.
		)
	) else (
		%CYAN%
		echo Please wait. Muxing Videostream into MKV Container...
		echo.
		%HCYELLOW%
		"!FFMPEGpath!" -loglevel panic -stats -i "!INPUTFILE!" -map 0:!BL_INDEX! -c:v copy "!TMP_FOLDER!\VIDEOSTREAM.mkv"
		if exist "!TMP_FOLDER!\VIDEOSTREAM.mkv" (
			set "WORKFILE=!TMP_FOLDER!\VIDEOSTREAM.mkv"
			%HCGREEN%
			echo Done.
			echo.
		)		
	)
)
%WHITE%
if not exist "!WORKFILE!.measurements" "!MADVRpath!" "!WORKFILE!"
if exist "!WORKFILE!.measurements" (
	set "MFILE=!WORKFILE!.measurements"
) else (
	echo.
	%HCRED%
	echo. Error.
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
)

(
echo {
echo    "min_pq": 7,
echo    "max_pq": 3079,
echo	"remove_cmv4": true,
echo    "level6": {
echo        "max_display_mastering_luminance": !MaxDML!,
echo        "min_display_mastering_luminance": !MinDML!,
echo        "max_content_light_level": 0,
echo        "max_frame_average_light_level": 0
echo    }
echo }
)>"%~dp0temp.json"

%WHITE%
"!DO_VI_TOOLNFpath!" generate -j "%~dp0temp.json" --madvr-file "!MFILE!" -o "!TMP_FOLDER!\HDRRPU.bin" >nul
if exist "!TMP_FOLDER!\HDRRPU.bin" (
	if "!TESTMODE!"=="OFF" if exist "!WORKFILE!.measurements" del "!WORKFILE!.measurements">nul
	set "HDRRPU=!TMP_FOLDER!\HDRRPU.bin"
	set "HDRRPU_EXIST=TRUE"
) else (
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
)

if "!HDRRPU_EXIST!"=="TRUE" (
	"!DO_VI_TOOLpath!" plot "!HDRRPU!" -t "" -o "!TMP_FOLDER!\!INPUTFILENAME!.png">nul
	"!DO_VI_TOOLpath!" export -i "!HDRRPU!" -o "!TMP_FOLDER!\plot.json">nul
	"!DO_VI_TOOLpath!" info --input "!HDRRPU!" -f 1 > "!TMP_FOLDER!\temp.hdrrpu.json"
	"!DO_VI_TOOLpath!" info -s "!HDRRPU!" > "!TMP_FOLDER!\HDRRPUINFO.txt"
	FOR /F "tokens=2 delims=: " %%A IN ('findstr /C:"Frames" "!TMP_FOLDER!\HDRRPUINFO.txt"') DO set "RPU_FRAMES=%%A"
	FOR /F "tokens=3 delims=: " %%A IN ('findstr /C:"shot count" "!TMP_FOLDER!\HDRRPUINFO.txt"') DO set "RPU_SHOTCOUNT=%%A"
	FOR /F "delims=" %%A IN ('findstr /C:"source_primary_index" "!TMP_FOLDER!\temp.hdrrpu.json"') DO set "L9_FOUND=%%A"
	if defined L9_FOUND (
		for /F "tokens=2 delims=:/ " %%A in ("!L9_FOUND!") do set "L9MDP=%%A"
		if "!L9MDP!"=="0" set "L9MDP=Display P3"
		if "!L9MDP!"=="2" set "L9MDP=BT.2020"
	)	
	FOR /F "delims=" %%A IN ('findstr /C:"RPU mastering display:" "!TMP_FOLDER!\HDRRPUINFO.txt"') DO set "RPUMDL=%%A"
	if defined RPUMDL (
		FOR /F "tokens=4 delims=:/ " %%A in ("!RPUMDL!") do set "RPUMinDML=%%A"
		FOR /F "tokens=5 delims=:/ " %%A in ("!RPUMDL!") do set "RPUMaxDML=%%A"
		set "RPULuminance=min: !RPUMinDML! cd/m2, max: !RPUMaxDML! cd/m2"
	)
)

set "MDL=-annotate +120+130 "Mastering display luminance^: !RPULuminance! ^(!L9MDP!^)""
if "!HDR10P!"=="TRUE" set "HDR10PINFO= | HDR10+"
if "!DVinput!"=="YES" set "DVINFO= | Dolby Vision Profile^: !DV_Profile!"
set "HDRINFO=-annotate +120+5 "Video: !PHDR!!HDR10PINFO!!DVINFO! ^(!RESOLUTION!^)""

if "!PLOTTYPE!"=="MAX" (
	set "titlepos=-135"
	call :ENHPLOTS
) else (
	set "titlepos=-0"
)

"!IMAGEMAGICKpath!" convert "!TMP_FOLDER!\!INPUTFILENAME!.png" -quality 100 -fill white -stroke none -draw "rectangle 0,0 3000,150" -gravity NorthWest -pointsize 20 -fill black -font Arial-Bold !HDRINFO! -font Arial -annotate +120+30 "Frames: !RPU_FRAMES!, Scenecuts: !RPU_SHOTCOUNT!" -font Arial-Bold -pointsize 25 -gravity Center -annotate !titlepos!-552 "!INPUTFILENAME!!INPUTFILEEXT!" -font Arial -pointsize 25 -annotate !titlepos!-518 "(!PHDR! Plot)" -pointsize 20 -gravity NorthWest !A1! !A2! !A3! !A4! !A5! !P1! !P2! !P3! !P4! !P5! !MDL! -font Arial-Bold !AM! !AA! "!INPUTFILEPATH!!INPUTFILENAME!_[!PHDR! Plot].png"
if exist "!INPUTFILEPATH!!INPUTFILENAME!_[!PHDR! Plot].png" (
	%HCGREEN%
	echo Done.
	echo.
) else (
	%HCRED%
	echo Error.
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	echo.
)
goto :eof

:DV_PLOTPNG
set "PFilename="
if "!PLOTTYPE!"=="ORIGINAL" set "PFilename=!INPUTFILENAME!!INPUTFILEEXT!"
%CYAN%
If "!DVPlot!"=="L1 ONLY" echo Please wait. Plotting DV RPU L1 Metadata...
If "!DVPlot!!RPU_CMV!"=="ALLCM v2.9" echo Please wait. Plotting DV RPU L1, L2 Metadata...
if "!DVPlot!!RPU_CMV!"=="ALLCM v4.0" echo Please wait. Plotting DV RPU L1, L2, L8 Metadata...
%WHITE%
"!DO_VI_TOOLpath!" plot "!RPUFILE!" -t "!PFilename!" -o "!TMP_FOLDER!\!INPUTFILENAME!L1.png">nul

If "!DVPlot!"=="ALL" (
	if "!L2100!"=="TRUE" "!DO_VI_TOOLpath!" plot "!RPUFILE!" -p l2 --target-nits 100 -t "!PFilename!" -o "!TMP_FOLDER!\!INPUTFILENAME!L2100.png">nul
	if "!L2300!"=="TRUE" "!DO_VI_TOOLpath!" plot "!RPUFILE!" -p l2 --target-nits 300 -t "!PFilename!" -o "!TMP_FOLDER!\!INPUTFILENAME!L2300.png">nul
	if "!L2600!"=="TRUE" "!DO_VI_TOOLpath!" plot "!RPUFILE!" -p l2 --target-nits 600 -t "!PFilename!" -o "!TMP_FOLDER!\!INPUTFILENAME!L2600.png">nul
	if "!L21000!"=="TRUE" "!DO_VI_TOOLpath!" plot "!RPUFILE!" -p l2 --target-nits 1000 -t "!PFilename!" -o "!TMP_FOLDER!\!INPUTFILENAME!L21000.png">nul
	if "!L22000!"=="TRUE" "!DO_VI_TOOLpath!" plot "!RPUFILE!" -p l2 --target-nits 2000 -t "!PFilename!" -o "!TMP_FOLDER!\!INPUTFILENAME!L22000.png">nul
	if "!L24000!"=="TRUE" "!DO_VI_TOOLpath!" plot "!RPUFILE!" -p l2 --target-nits 4000 -t "!PFilename!" -o "!TMP_FOLDER!\!INPUTFILENAME!L24000.png">nul
)

if "!DVPlot!!RPU_CMV!"=="ALLCM v4.0" (
	if "!L2100!"=="TRUE" "!DO_VI_TOOLpath!" plot "!RPUFILE!" -p l8 --target-nits 100 -t "!PFilename!" -o "!TMP_FOLDER!\!INPUTFILENAME!L8100.png">nul
	if "!L2300!"=="TRUE" "!DO_VI_TOOLpath!" plot "!RPUFILE!" -p l8 --target-nits 300 -t "!PFilename!" -o "!TMP_FOLDER!\!INPUTFILENAME!L8300.png">nul
	if "!L2600!"=="TRUE" "!DO_VI_TOOLpath!" plot "!RPUFILE!" -p l8 --target-nits 600 -t "!PFilename!" -o "!TMP_FOLDER!\!INPUTFILENAME!L8600.png">nul
	if "!L21000!"=="TRUE" "!DO_VI_TOOLpath!" plot "!RPUFILE!" -p l8 --target-nits 1000 -t "!PFilename!" -o "!TMP_FOLDER!\!INPUTFILENAME!L81000.png">nul
	if "!L22000!"=="TRUE" "!DO_VI_TOOLpath!" plot "!RPUFILE!" -p l8 --target-nits 2000 -t "!PFilename!" -o "!TMP_FOLDER!\!INPUTFILENAME!L82000.png">nul
	if "!L24000!"=="TRUE" "!DO_VI_TOOLpath!" plot "!RPUFILE!" -p l8 --target-nits 4000 -t "!PFilename!" -o "!TMP_FOLDER!\!INPUTFILENAME!L84000.png">nul
)

if "!PLOTTYPE!" NEQ "ORIGINAL" (
	"!DO_VI_TOOLpath!" info --input "!RPUFILE!" -f 1 > "!TMP_FOLDER!\temp.rpu.json"
	"!DO_VI_TOOLpath!" export -i "!RPUFILE!" -o "!TMP_FOLDER!\plot.json">nul
	"!DO_VI_TOOLpath!" info -s "!RPUFILE!" > "!TMP_FOLDER!\RPUINFO.txt"
	if exist "!TMP_FOLDER!\!INPUTFILENAME!L1.png" (
		FOR /F "tokens=2 delims=: " %%A IN ('findstr /C:"Frames" "!TMP_FOLDER!\RPUINFO.txt"') DO set "RPU_FRAMES=%%A"
		FOR /F "tokens=3 delims=: " %%A IN ('findstr /C:"shot count" "!TMP_FOLDER!\RPUINFO.txt"') DO set "RPU_SHOTCOUNT=%%A"
		FOR /F "tokens=3-5 delims=: " %%A IN ('findstr /C:"DM version" "!TMP_FOLDER!\RPUINFO.txt"') DO set "DM=%%A %%B %%C"
		FOR /F "tokens=2 delims=:" %%A IN ('findstr /C:"RPU mastering display" "!TMP_FOLDER!\RPUINFO.txt"') DO set "RPUMD=%%A"
		if defined RPUMD set "RPUMD=Mastering display^:!RPUMD!"
		FOR /F "delims=" %%A IN ('findstr /C:"source_primary_index" "!TMP_FOLDER!\temp.rpu.json"') DO set "L9_FOUND=%%A"
		if defined L9_FOUND (
			for /F "tokens=2 delims=:/ " %%A in ("!L9_FOUND!") do set "L9MDP=%%A"
			if "!L9MDP!"=="0" set "L9MDP= (Display P3)"
			if "!L9MDP!"=="2" set "L9MDP= (BT.2020)"
		)
		FOR /F "tokens=2-5 delims=:" %%A IN ('findstr /C:"L6 metadata:" "!TMP_FOLDER!\RPUINFO.txt"') DO set "L6M=%%A: %%B: %%C: %%D"
		if "!L6M!"==":::" (
			set "L6M=No L6 entries in RPU."
		) else (
			set "L6M=L6!L6M!"
		)
		FOR /F "delims=" %%A IN ('findstr /C:"Level5" "!TMP_FOLDER!\temp.rpu.json"') DO set "L5_FOUND=%%A"
		if defined L5_FOUND (
			FOR /F "tokens=2 delims=:, " %%A IN ('findstr /C:"active_area_left_offset" "!TMP_FOLDER!\temp.rpu.json"') DO set "RPU_INPUT_AA_LC=%%A">nul
			FOR /F "tokens=2 delims=:, " %%A IN ('findstr /C:"active_area_right_offset" "!TMP_FOLDER!\temp.rpu.json"') DO set "RPU_INPUT_AA_RC=%%A">nul
			FOR /F "tokens=2 delims=:, " %%A IN ('findstr /C:"active_area_top_offset" "!TMP_FOLDER!\temp.rpu.json"') DO set "RPU_INPUT_AA_TC=%%A">nul
			FOR /F "tokens=2 delims=:, " %%A IN ('findstr /C:"active_area_bottom_offset" "!TMP_FOLDER!\temp.rpu.json"') DO set "RPU_INPUT_AA_BC=%%A">nul
			set "L5_STRING_TXT=Left !RPU_INPUT_AA_LC! px, Right !RPU_INPUT_AA_RC! px, Top !RPU_INPUT_AA_TC! px, Bottom !RPU_INPUT_AA_BC! px"
		) else (
			set "L5_STRING_TXT=No border entries in RPU."
		)
	)
	set "RPUINFO=-annotate +120+5 "RPU: Dolby Vision Profile: !DV_Profile!, DM Version: !DM!""
	set "FRAMEINFO=-annotate +120+30 "Frames: !RPU_FRAMES!, Scenecuts: !RPU_SHOTCOUNT!""
	if defined RPUMD set L1=-annotate +120+55 "L1 !RPUMD!"
	if defined L2_TRIMS set "L2=-annotate +120+80 "L2 trims: !L2_TRIMS!""
	set "L5=-annotate +120+105 "L5 Active area: !L5_STRING_TXT!""
	if defined L6M set "L6=-annotate +120+130 "!L6M!!L9MDP!""

	if "!PLOTTYPE!"=="MAX" (
		set "titlepos=-135"
		call :ENHPLOTS
	) else (
		set "titlepos=-0"
	)
	if exist "!TMP_FOLDER!\!INPUTFILENAME!L1.png" "!IMAGEMAGICKpath!" convert "!TMP_FOLDER!\!INPUTFILENAME!L1.png" -quality 100 -fill white -stroke none -draw "rectangle 0,0 3000,150" -fill black -pointsize 25 -gravity Center -font Arial-Bold -annotate !titlepos!-552 "!INPUTFILENAME!!INPUTFILEEXT!" -pointsize 25 -font Arial -annotate !titlepos!-518 "(Dolby Vision L1 Plot)" -gravity NorthWest -pointsize 20 -font Arial-Bold !RPUINFO! -font Arial !FRAMEINFO! !L1! !L2! !L5! !L6! !A1! !A2! !A3! !A4! !A5! !P1! !P2! !P3! !P4! !P5! -font Arial-Bold !AM! !AA! "!INPUTFILEPATH!!INPUTFILENAME!_[DV L1 Plot].png"
	if exist "!TMP_FOLDER!\!INPUTFILENAME!L2100.png" "!IMAGEMAGICKpath!" convert "!TMP_FOLDER!\!INPUTFILENAME!L2100.png" -quality 100 -fill white -stroke none -draw "rectangle 0,0 3000,150" -fill black -pointsize 25 -gravity Center -font Arial-Bold -annotate !titlepos!-552 "!INPUTFILENAME!!INPUTFILEEXT!" -pointsize 25 -font Arial -annotate !titlepos!-518 "(Dolby Vision L2 Plot 100 nits)" -gravity NorthWest -pointsize 20 -font Arial-Bold !RPUINFO! -font Arial !FRAMEINFO! !L1! !L2! !L5! !L6! !A1! !A2! !A3! !A4! !A5! !P1! !P2! !P3! !P4! !P5! -font Arial-Bold !AM! !AA! "!INPUTFILEPATH!!INPUTFILENAME!_[DV L2 100nits Plot].png"
	if exist "!TMP_FOLDER!\!INPUTFILENAME!L8100.png" "!IMAGEMAGICKpath!" convert "!TMP_FOLDER!\!INPUTFILENAME!L8100.png" -quality 100 -fill white -stroke none -draw "rectangle 0,0 3000,150" -fill black -pointsize 25 -gravity Center -font Arial-Bold -annotate !titlepos!-552 "!INPUTFILENAME!!INPUTFILEEXT!" -pointsize 25 -font Arial -annotate !titlepos!-518 "(Dolby Vision L8 Plot 100 nits)" -gravity NorthWest -pointsize 20 -font Arial-Bold !RPUINFO! -font Arial !FRAMEINFO! !L1! !L2! !L5! !L6! !A1! !A2! !A3! !A4! !A5! !P1! !P2! !P3! !P4! !P5! -font Arial-Bold !AM! !AA! "!INPUTFILEPATH!!INPUTFILENAME!_[DV L8 100nits Plot].png"
	if exist "!TMP_FOLDER!\!INPUTFILENAME!L2300.png" "!IMAGEMAGICKpath!" convert "!TMP_FOLDER!\!INPUTFILENAME!L2300.png" -quality 100 -fill white -stroke none -draw "rectangle 0,0 3000,150" -fill black -pointsize 25 -gravity Center -font Arial-Bold -annotate !titlepos!-552 "!INPUTFILENAME!!INPUTFILEEXT!" -pointsize 25 -font Arial -annotate !titlepos!-518 "(Dolby Vision L2 Plot 300 nits)" -gravity NorthWest -pointsize 20 -font Arial-Bold !RPUINFO! -font Arial !FRAMEINFO! !L1! !L2! !L5! !L6! !A1! !A2! !A3! !A4! !A5! !P1! !P2! !P3! !P4! !P5! -font Arial-Bold !AM! !AA! "!INPUTFILEPATH!!INPUTFILENAME!_[DV L2 300nits Plot].png"
	if exist "!TMP_FOLDER!\!INPUTFILENAME!L8300.png" "!IMAGEMAGICKpath!" convert "!TMP_FOLDER!\!INPUTFILENAME!L8300.png" -quality 100 -fill white -stroke none -draw "rectangle 0,0 3000,150" -fill black -pointsize 25 -gravity Center -font Arial-Bold -annotate !titlepos!-552 "!INPUTFILENAME!!INPUTFILEEXT!" -pointsize 25 -font Arial -annotate !titlepos!-518 "(Dolby Vision L8 Plot 300 nits)" -gravity NorthWest -pointsize 20 -font Arial-Bold !RPUINFO! -font Arial !FRAMEINFO! !L1! !L2! !L5! !L6! !A1! !A2! !A3! !A4! !A5! !P1! !P2! !P3! !P4! !P5! -font Arial-Bold !AM! !AA! "!INPUTFILEPATH!!INPUTFILENAME!_[DV L8 300nits Plot].png"
	if exist "!TMP_FOLDER!\!INPUTFILENAME!L2600.png" "!IMAGEMAGICKpath!" convert "!TMP_FOLDER!\!INPUTFILENAME!L2600.png" -quality 100 -fill white -stroke none -draw "rectangle 0,0 3000,150" -fill black -pointsize 25 -gravity Center -font Arial-Bold -annotate !titlepos!-552 "!INPUTFILENAME!!INPUTFILEEXT!" -pointsize 25 -font Arial -annotate !titlepos!-518 "(Dolby Vision L2 Plot 600 nits)" -gravity NorthWest -pointsize 20 -font Arial-Bold !RPUINFO! -font Arial !FRAMEINFO! !L1! !L2! !L5! !L6! !A1! !A2! !A3! !A4! !A5! !P1! !P2! !P3! !P4! !P5! -font Arial-Bold !AM! !AA! "!INPUTFILEPATH!!INPUTFILENAME!_[DV L2 600nits Plot].png"
	if exist "!TMP_FOLDER!\!INPUTFILENAME!L8600.png" "!IMAGEMAGICKpath!" convert "!TMP_FOLDER!\!INPUTFILENAME!L8600.png" -quality 100 -fill white -stroke none -draw "rectangle 0,0 3000,150" -fill black -pointsize 25 -gravity Center -font Arial-Bold -annotate !titlepos!-552 "!INPUTFILENAME!!INPUTFILEEXT!" -pointsize 25 -font Arial -annotate !titlepos!-518 "(Dolby Vision L8 Plot 600 nits)" -gravity NorthWest -pointsize 20 -font Arial-Bold !RPUINFO! -font Arial !FRAMEINFO! !L1! !L2! !L5! !L6! !A1! !A2! !A3! !A4! !A5! !P1! !P2! !P3! !P4! !P5! -font Arial-Bold !AM! !AA! "!INPUTFILEPATH!!INPUTFILENAME!_[DV L8 600nits Plot].png"
	if exist "!TMP_FOLDER!\!INPUTFILENAME!L21000.png" "!IMAGEMAGICKpath!" convert "!TMP_FOLDER!\!INPUTFILENAME!L21000.png" -quality 100 -fill white -stroke none -draw "rectangle 0,0 3000,150" -fill black -pointsize 25 -gravity Center -font Arial-Bold -annotate !titlepos!-552 "!INPUTFILENAME!!INPUTFILEEXT!" -pointsize 25 -font Arial -annotate !titlepos!-518 "(Dolby Vision L2 Plot 1000 nits)" -gravity NorthWest -pointsize 20 -font Arial-Bold !RPUINFO! -font Arial !FRAMEINFO! !L1! !L2! !L5! !L6! !A1! !A2! !A3! !A4! !A5! !P1! !P2! !P3! !P4! !P5! -font Arial-Bold !AM! !AA! "!INPUTFILEPATH!!INPUTFILENAME!_[DV L2 1000nits Plot].png"
	if exist "!TMP_FOLDER!\!INPUTFILENAME!L81000.png" "!IMAGEMAGICKpath!" convert "!TMP_FOLDER!\!INPUTFILENAME!L81000.png" -quality 100 -fill white -stroke none -draw "rectangle 0,0 3000,150" -fill black -pointsize 25 -gravity Center -font Arial-Bold -annotate !titlepos!-552 "!INPUTFILENAME!!INPUTFILEEXT!" -pointsize 25 -font Arial -annotate !titlepos!-518 "(Dolby Vision L8 Plot 1000 nits)" -gravity NorthWest -pointsize 20 -font Arial-Bold !RPUINFO! -font Arial !FRAMEINFO! !L1! !L2! !L5! !L6! !A1! !A2! !A3! !A4! !A5! !P1! !P2! !P3! !P4! !P5! -font Arial-Bold !AM! !AA! "!INPUTFILEPATH!!INPUTFILENAME!_[DV L8 1000nits Plot].png"
	if exist "!TMP_FOLDER!\!INPUTFILENAME!L22000.png" "!IMAGEMAGICKpath!" convert "!TMP_FOLDER!\!INPUTFILENAME!L22000.png" -quality 100 -fill white -stroke none -draw "rectangle 0,0 3000,150" -fill black -pointsize 25 -gravity Center -font Arial-Bold -annotate !titlepos!-552 "!INPUTFILENAME!!INPUTFILEEXT!" -pointsize 25 -font Arial -annotate !titlepos!-518 "(Dolby Vision L2 Plot 2000 nits)" -gravity NorthWest -pointsize 20 -font Arial-Bold !RPUINFO! -font Arial !FRAMEINFO! !L1! !L2! !L5! !L6! !A1! !A2! !A3! !A4! !A5! !P1! !P2! !P3! !P4! !P5! -font Arial-Bold !AM! !AA! "!INPUTFILEPATH!!INPUTFILENAME!_[DV L2 2000nits Plot].png"
	if exist "!TMP_FOLDER!\!INPUTFILENAME!L82000.png" "!IMAGEMAGICKpath!" convert "!TMP_FOLDER!\!INPUTFILENAME!L82000.png" -quality 100 -fill white -stroke none -draw "rectangle 0,0 3000,150" -fill black -pointsize 25 -gravity Center -font Arial-Bold -annotate !titlepos!-552 "!INPUTFILENAME!!INPUTFILEEXT!" -pointsize 25 -font Arial -annotate !titlepos!-518 "(Dolby Vision L8 Plot 2000 nits)" -gravity NorthWest -pointsize 20 -font Arial-Bold !RPUINFO! -font Arial !FRAMEINFO! !L1! !L2! !L5! !L6! !A1! !A2! !A3! !A4! !A5! !P1! !P2! !P3! !P4! !P5! -font Arial-Bold !AM! !AA! "!INPUTFILEPATH!!INPUTFILENAME!_[DV L8 2000nits Plot].png"
	if exist "!TMP_FOLDER!\!INPUTFILENAME!L24000.png" "!IMAGEMAGICKpath!" convert "!TMP_FOLDER!\!INPUTFILENAME!L24000.png" -quality 100 -fill white -stroke none -draw "rectangle 0,0 3000,150" -fill black -pointsize 25 -gravity Center -font Arial-Bold -annotate !titlepos!-552 "!INPUTFILENAME!!INPUTFILEEXT!" -pointsize 25 -font Arial -annotate !titlepos!-518 "(Dolby Vision L2 Plot 4000 nits)" -gravity NorthWest -pointsize 20 -font Arial-Bold !RPUINFO! -font Arial !FRAMEINFO! !L1! !L2! !L5! !L6! !A1! !A2! !A3! !A4! !A5! !P1! !P2! !P3! !P4! !P5! -font Arial-Bold !AM! !AA! "!INPUTFILEPATH!!INPUTFILENAME!_[DV L2 4000nits Plot].png"
	if exist "!TMP_FOLDER!\!INPUTFILENAME!L84000.png" "!IMAGEMAGICKpath!" convert "!TMP_FOLDER!\!INPUTFILENAME!L84000.png" -quality 100 -fill white -stroke none -draw "rectangle 0,0 3000,150" -fill black -pointsize 25 -gravity Center -font Arial-Bold -annotate !titlepos!-552 "!INPUTFILENAME!!INPUTFILEEXT!" -pointsize 25 -font Arial -annotate !titlepos!-518 "(Dolby Vision L8 Plot 4000 nits)" -gravity NorthWest -pointsize 20 -font Arial-Bold !RPUINFO! -font Arial !FRAMEINFO! !L1! !L2! !L5! !L6! !A1! !A2! !A3! !A4! !A5! !P1! !P2! !P3! !P4! !P5! -font Arial-Bold !AM! !AA! "!INPUTFILEPATH!!INPUTFILENAME!_[DV L8 4000nits Plot].png"
) else (
	if exist "!TMP_FOLDER!\!INPUTFILENAME!L1.png" copy "!TMP_FOLDER!\!INPUTFILENAME!L1.png" "!INPUTFILEPATH!!INPUTFILENAME!_[DV L1 Plot].png">nul
	if exist "!TMP_FOLDER!\!INPUTFILENAME!L2100.png" copy "!TMP_FOLDER!\!INPUTFILENAME!L2100.png" "!INPUTFILEPATH!!INPUTFILENAME!_[DV L2 100nits Plot].png">nul
	if exist "!TMP_FOLDER!\!INPUTFILENAME!L8100.png" copy "!TMP_FOLDER!\!INPUTFILENAME!L8100.png" "!INPUTFILEPATH!!INPUTFILENAME!_[DV L8 100nits Plot].png">nul
	if exist "!TMP_FOLDER!\!INPUTFILENAME!L2300.png" copy "!TMP_FOLDER!\!INPUTFILENAME!L2300.png" "!INPUTFILEPATH!!INPUTFILENAME!_[DV L2 300nits Plot].png">nul
	if exist "!TMP_FOLDER!\!INPUTFILENAME!L8300.png" copy "!TMP_FOLDER!\!INPUTFILENAME!L8300.png"  "!INPUTFILEPATH!!INPUTFILENAME!_[DV L8 300nits Plot].png">nul
	if exist "!TMP_FOLDER!\!INPUTFILENAME!L2600.png" copy "!TMP_FOLDER!\!INPUTFILENAME!L2600.png"  "!INPUTFILEPATH!!INPUTFILENAME!_[DV L2 600nits Plot].png">nul
	if exist "!TMP_FOLDER!\!INPUTFILENAME!L8600.png" copy "!TMP_FOLDER!\!INPUTFILENAME!L8600.png"  "!INPUTFILEPATH!!INPUTFILENAME!_[DV L8 600nits Plot].png">nul
	if exist "!TMP_FOLDER!\!INPUTFILENAME!L21000.png" copy "!TMP_FOLDER!\!INPUTFILENAME!L21000.png"  "!INPUTFILEPATH!!INPUTFILENAME!_[DV L2 1000nits Plot].png">nul
	if exist "!TMP_FOLDER!\!INPUTFILENAME!L81000.png" copy "!TMP_FOLDER!\!INPUTFILENAME!L81000.png"  "!INPUTFILEPATH!!INPUTFILENAME!_[DV L8 1000nits Plot].png">nul
	if exist "!TMP_FOLDER!\!INPUTFILENAME!L22000.png" copy "!TMP_FOLDER!\!INPUTFILENAME!L22000.png"  "!INPUTFILEPATH!!INPUTFILENAME!_[DV L2 2000nits Plot].png">nul
	if exist "!TMP_FOLDER!\!INPUTFILENAME!L82000.png" copy "!TMP_FOLDER!\!INPUTFILENAME!L82000.png"  "!INPUTFILEPATH!!INPUTFILENAME!_[DV L8 2000nits Plot].png">nul
	if exist "!TMP_FOLDER!\!INPUTFILENAME!L24000.png" copy "!TMP_FOLDER!\!INPUTFILENAME!L24000.png"  "!INPUTFILEPATH!!INPUTFILENAME!_[DV L2 4000nits Plot].png">nul
	if exist "!TMP_FOLDER!\!INPUTFILENAME!L84000.png" copy "!TMP_FOLDER!\!INPUTFILENAME!L84000.png"  "!INPUTFILEPATH!!INPUTFILENAME!_[DV L8 4000nits Plot].png">nul
)
if exist "!INPUTFILEPATH!!INPUTFILENAME!_[DV L1 Plot].png" (
	%HCGREEN%
	echo Done.
	echo.
) else (
	%HCRED%
	echo Error.
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	echo.
)
goto :eof

:HDR10Plus_PLOTPNG
%CYAN%
echo Please wait. Plotting HDR10+ SEI...
%WHITE%
pushd "!INPUTFILEPATH!"
if exist "!BLSTREAM!" (
	"!HDR10P_TOOLpath!" extract "!BLSTREAM!" -o "!TMP_FOLDER!\HDR10Plus.json"
) else (
	"!FFMPEGpath!" -loglevel panic -stats -i "!INPUTFILE!" -map 0:!BL_INDEX! -c:v copy -bsf:v hevc_mp4toannexb -f hevc - | "!HDR10P_TOOLpath!" extract "!BLSTREAM!" -o "!TMP_FOLDER!\HDR10Plus.json" -
)
if exist "!TMP_FOLDER!\HDR10Plus.json" (
	(
	echo {
	echo	"cm_version": "V29",
	echo 	"length": !FRAMES!,
	echo 	"level6": {
	echo	 	"max_display_mastering_luminance": !MaxDML!,
	echo	 	"min_display_mastering_luminance": !MinDML!,
	echo	 	"max_content_light_level": !MaxCLL!,
	echo	 	"max_frame_average_light_level": !MaxFall! 
	echo 	}
	echo }
	)>"!TMP_FOLDER!\Extra.json"
	"!DO_VI_TOOLpath!" generate -j "!TMP_FOLDER!\Extra.json" --hdr10plus-json "!TMP_FOLDER!\HDR10Plus.json" -o "!TMP_FOLDER!\HDR10Plus.bin">nul
	if exist "!TMP_FOLDER!\HDR10Plus.bin" (
		if "!TESTMODE!"=="OFF" if exist "!WORKFILE!.measurements" del "!WORKFILE!.measurements">nul
		set "HDRRPU=!TMP_FOLDER!\HDR10Plus.bin"
		set "HDRRPU_EXIST=TRUE"
	) else (
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	)
	set "L9MDP=!MDCP!"
	if "!HDRRPU_EXIST!"=="TRUE" (
		"!DO_VI_TOOLpath!" export -i "!HDRRPU!" -o "!TMP_FOLDER!\plot.json">nul
		"!DO_VI_TOOLpath!" info --input "!HDRRPU!" -f 1 > "!TMP_FOLDER!\temp.hdrrpu.json"
		"!DO_VI_TOOLpath!" info -s "!HDRRPU!" > "!TMP_FOLDER!\HDRRPUINFO.txt"
		FOR /F "tokens=2 delims=: " %%A IN ('findstr /C:"Frames" "!TMP_FOLDER!\HDRRPUINFO.txt"') DO set "RPU_FRAMES=%%A"
		FOR /F "tokens=3 delims=: " %%A IN ('findstr /C:"shot count" "!TMP_FOLDER!\HDRRPUINFO.txt"') DO set "RPU_SHOTCOUNT=%%A"
		FOR /F "delims=" %%A IN ('findstr /C:"RPU mastering display:" "!TMP_FOLDER!\HDRRPUINFO.txt"') DO set "RPUMDL=%%A"
		if defined RPUMDL (
			FOR /F "tokens=4 delims=:/ " %%A in ("!RPUMDL!") do set "RPUMinDML=%%A"
			FOR /F "tokens=5 delims=:/ " %%A in ("!RPUMDL!") do set "RPUMaxDML=%%A"
			set "RPULuminance=min: !RPUMinDML! cd/m2, max: !RPUMaxDML! cd/m2"
		)
	)
)

set "MDL=-annotate +120+130 "Mastering display luminance: !RPULuminance!!L9MDP!""
if "!HDR10P!"=="TRUE" set "HDR10PINFO= | HDR10+"
if "!DVinput!"=="YES" set "DVINFO= | Dolby Vision Profile: !DV_Profile!"
set "HDRINFO=-annotate +120+5 "Video: !PHDR!!HDR10PINFO!!DVINFO! ^(!RESOLUTION!^)""

if "!PLOTTYPE!"=="MAX" (
	set "titlepos=-135"
	call :ENHPLOTS
) else (
	set "titlepos=-0"
)

"!HDR10P_TOOLpath!" plot "!HDR10PFILE!" -t "" -o "!TMP_FOLDER!\!INPUTFILENAME!.png"
popd
if exist "!TMP_FOLDER!\!INPUTFILENAME!.png" "!IMAGEMAGICKpath!" convert "!TMP_FOLDER!\!INPUTFILENAME!.png" -quality 100 -fill white -stroke none -draw "rectangle 0,0 3000,150" -gravity NorthWest -pointsize 20 -fill black -font Arial-Bold !HDRINFO! -font Arial -annotate +120+30 "Frames: !RPU_FRAMES!, Scenecuts: !RPU_SHOTCOUNT!" -font Arial-Bold -pointsize 25 -gravity Center -annotate !titlepos!-552 "!INPUTFILENAME!!INPUTFILEEXT!" -font Arial -pointsize 25 -annotate !titlepos!-518 "(HDR10+ Plot)" -pointsize 20 -gravity NorthWest !A1! !A2! !A3! !A4! !A5! !P1! !P2! !P3! !P4! !P5! !MDL! -font Arial-Bold !AM! !AA! "!INPUTFILEPATH!!INPUTFILENAME!_[HDR10+ Plot].png"
if exist "!INPUTFILEPATH!!INPUTFILENAME!_[HDR10+ Plot].png" (
	%HCGREEN%
	echo Done.
	echo.
) else (
	%HCRED%
	echo Error.
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	echo.
)
goto :eof

:C_MEDIAINFO
%CYAN%
echo Please wait. Creating MediaInfo...
%WHITE%
"!MEDIAINFOpath!" --output=TXT "!INPUTFILENAME!!INPUTFILEEXT!">"!INPUTFILEPATH!!INPUTFILENAME!_[MediaInfo].txt"
if exist "!INPUTFILEPATH!!INPUTFILENAME!_[MediaInfo].txt" (
	echo Creating txt File...
	%HCGREEN%
	echo Done.
	echo.
) else (
	echo Creating txt File...
	%HCRED%
	echo Error.
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	echo.
)
goto :eof

:DV_FRAMEINFO
set "FRAME_ALL=FALSE"
set "FRAME_SC=FALSE"
set "FRAME_NONE=FALSE"
set "FRAME_NMB=TRUE"
cls
%GREEN%
echo  !HEADER1!
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool FILEINFO
%WHITE%
echo                                         ====================================
echo.
echo.
if "%RPU_FILE%"=="FALSE" (
	echo  == VIDEO INPUT =========================================================================================================
	echo.
	%CYAN%
	echo Filename   = [!INPUTFILENAME!!INPUTFILEEXT!]
	echo Video Info = [Resolution = !RESOLUTION!] [Codec = !CODEC_NAME!] [Frames = !FRAMES!] [FPS = !FRAMERATE!]
	echo HDR Info   = [!HDR_Info!]
	echo.
) else (
	echo.
	echo  == RPU INPUT ===========================================================================================================
	echo.
	%CYAN%
	echo Filename   = [!INPUTFILENAME!!INPUTFILEEXT!]
	echo RPU Info   = [DV Profile = !RPU_DVP!!RPU_DVSP!] [CM Version = !RPU_CMV!] [Frames = !RPU_FRAMES!]
	echo.
)
%WHITE%
echo  == FRAME INFO ==========================================================================================================
echo.
%HCYELLOW%
echo Type in the Frame.
echo.
echo Example: For Frame Info of Frame 1000 type in 1000^^!
echo          If you will extract info of all frames and
echo          info for all Scene Cuts in the RPU type ALL.
echo          For only Scenecuts type in SCENECUTS.
echo.
echo          For disabling Frame Info type NONE.
echo.
%WHITE%
set /p "FRAME=Type in FRAME NUMBER (0-%FRAMES%), SCENECUTS, ALL or NONE for no output and press [ENTER]: "

if /i "!Frame!"=="ALL" set "FRAME_ALL=TRUE"
if /i "!Frame!"=="SCENECUTS" set "FRAME_SC=TRUE"
if /i "!Frame!"=="NONE" set "FRAME_NONE=TRUE"

set /a "FRAME=!Frame!"
if !Frame! LSS 0 set /a "FRAME=0"
if !Frame! GTR %FRAMES% set /a "FRAME=%FRAMES%"

if "!FRAME_ALL!"=="TRUE" set "FRAME=ALL" & set "FRAME_NMB=FALSE"
if "!FRAME_SC!"=="TRUE" set "FRAME=SCENECUTS" & set "FRAME_NMB=FALSE"
if "!FRAME_NONE!"=="TRUE" set "FRAME=NONE" & set "FRAME_NMB=FALSE"
echo.
goto :eof

:WRITE_DV_FRAMEINFO
%WHITE%
if "!Frame!"=="0" set "Frame=00"
if "!Frame!"=="1" set "Frame=01"
if "!Frame!"=="2" set "Frame=02"
if "!Frame!"=="3" set "Frame=03"
if "!Frame!"=="4" set "Frame=04"
if "!Frame!"=="5" set "Frame=05"
if "!Frame!"=="6" set "Frame=06"
if "!Frame!"=="7" set "Frame=07"
if "!Frame!"=="8" set "Frame=08"
if "!Frame!"=="9" set "Frame=09"
%CYAN%
echo Please wait. Writing DV Frame Infos...
%WHITE%
if "!Frame!"=="ALL" (
	%WHITE%
	"!DO_VI_TOOLpath!" export -i "!RPUFILE!" -o "!TMP_FOLDER!\info.json"
	"!JQpath!" . "!TMP_FOLDER!\info.json">"!INPUTFILEPATH!!INPUTFILENAME!_[All Frames Info].json"
	if exist "!INPUTFILEPATH!!INPUTFILENAME!_[All Frames Info].json" (
		%HCGREEN%
		echo !INPUTFILENAME!_[All Frames Info].json Done.
	) else (
		%HCRED%
		echo !INPUTFILENAME!_[All Frames Info].json Error.
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	)
	%WHITE%
	"!JQpath!" "to_entries | .[] | select(.value.vdr_dm_data.scene_refresh_flag == 1) | .key" "!TMP_FOLDER!\info.json">"!INPUTFILEPATH!!INPUTFILENAME!_[All Scene Cuts].txt"
	if exist "!INPUTFILEPATH!!INPUTFILENAME!_[All Scene Cuts].txt" (
		%HCGREEN%
		echo !INPUTFILENAME!_[All Scene Cuts].txt Done.
	) else (
		%HCRED%
		echo !INPUTFILENAME!_[All Scene Cuts].txt Error.
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	)
)
if "!Frame!"=="SCENECUTS" (
	%WHITE%
	"!DO_VI_TOOLpath!" export -i "!RPUFILE!" -d scenes="!INPUTFILEPATH!!INPUTFILENAME!_[All Scene Cuts].txt"
	if exist "!INPUTFILEPATH!!INPUTFILENAME!_[All Scene Cuts].txt" (
		%HCGREEN%
		echo !INPUTFILENAME!_[All Scene Cuts].txt Done.
	) else (
		%HCRED%
		echo !INPUTFILENAME!_[All Scene Cuts].txt Error.
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	)
)
if "!Frame_NMB!"=="TRUE" (
	%WHITE%
	echo.
	"!DO_VI_TOOLpath!" info -i "!RPUFILE!" -s>"!INPUTFILEPATH!!INPUTFILENAME!_[Frame !Frame! Info].json"
	"!DO_VI_TOOLpath!" info -i "!RPUFILE!" -f !Frame!>>"!INPUTFILEPATH!!INPUTFILENAME!_[Frame !Frame! Info].json"
	if exist "!INPUTFILEPATH!!INPUTFILENAME!_[Frame !Frame! Info].json" (
		%HCGREEN%
		echo !INPUTFILENAME!_[Frame !Frame! Info].json Done.
	) else (
		%HCRED%
		echo !INPUTFILENAME!_[Frame !Frame! Info].json Error.
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	)
)
if exist "!TMP_FOLDER!\info.json" del "!TMP_FOLDER!\info.json"
echo.
goto :eof

:DV8CHK
if /i "%~2!DV!"=="-CHECKFALSE" goto :SC_NODV
if "!DV_Profile!" NEQ "8" goto :SC_NODV
if /i "!INPUTFILEEXT!"==".bin" goto :FALSEINPUTCHECK
mode con cols=125 lines=50
if exist "%~dp0DDVT_OPTIONS.ini" (
	FOR /F "delims=" %%A IN ('findstr /C:"TARGET Folder=" "%~dp0DDVT_OPTIONS.ini"') DO (
		set "TARGET_FOLDER=%%A"
		set "TARGET_FOLDER=!TARGET_FOLDER:~14!"
	)
)
if "!TARGET_FOLDER!"=="SAME AS SOURCE" set "TARGET_FOLDER=!INPUTFILEPATH!"
if not exist "!TMP_FOLDER!" MD "!TMP_FOLDER!">nul
set AA_LC=Undefined
set AA_TC=Undefined
set AA_RC=Undefined
set AA_BC=Undefined
set RPU_AA_LC=Undefined
set RPU_AA_TC=Undefined
set RPU_AA_RC=Undefined
set RPU_AA_BC=Undefined
set "CONTAINERSTREAM=!INPUTFILE!"
cls
echo.
cls
%GREEN%
echo  !HEADER1!
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                             Dolby Vision Tool SYNC CHECK
%WHITE%
echo                                         ====================================
echo.
echo.
%WHITE%
echo  == CHECKING RELEASE ====================================================================================================
echo.
%WHITE%
if "%RAW_FILE%"=="FALSE" (
	set "CONTAINERSTREAM=!INPUTFILE!"
	call :DEMUX
) else (
	%HCYELLOW%
	echo ATTENTION^^! You need a lot of HDD Space for this operation.
	echo.
	%CYAN%
	echo Please wait. Muxing Videostream into Container...
	%HCYELLOW% 
	echo Don't close the "Muxing into MKV Container" cmd window.
	start /WAIT /MIN "Muxing into MKV Container" "!MKVMERGEpath!" --ui-language de --priority higher --output ^"!TMP_FOLDER!\temp.mkv^" --language 0:und --compression 0:none ^"^(^" ^"!INPUTFILE!^" ^"^)^" --stop-after-video-ends
	if exist "!TMP_FOLDER!\temp.mkv" (
		set "CONTAINERSTREAM=!TMP_FOLDER!\temp.mkv"
		set "VIDEOSTREAM=!INPUTFILE!"
		%HCGREEN%
		echo Done.
		echo.
	) else (
		%HCRED%
		echo Error.
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
		echo.
	)
)
%CYAN%
echo Please wait. Analysing Videostream...
%WHITE%
::BL FRAMES
"!MEDIAINFOpath!" --output=Video;%%FrameCount%% "!CONTAINERSTREAM!">"!TMP_FOLDER!\Info.txt"
set /p V0_FRAMES=<"!TMP_FOLDER!\Info.txt">nul

::DETECT BORDERS
"%~dp0tools\DetectBorders.exe" --ffmpeg-path="!FFMPEGpath!" --input-file="!CONTAINERSTREAM!" --log-file="!TMP_FOLDER!\Crop.txt"
FOR /F "tokens=2-5 delims=(,-)" %%A IN ('TYPE "!TMP_FOLDER!\Crop.txt"') DO (
	set AA_LC=%%A
	set AA_TC=%%B
	set AA_RC=%%C
	set AA_BC=%%D
)
if exist "!TMP_FOLDER!\Crop.txt" (
	del "!TMP_FOLDER!\Crop.txt"
	%HCGREEN%
	echo Done.
	echo.
) else (
	%HCYELLOW%
	echo Analysing failed.
	set AA_LC=Failed
	set AA_TC=Failed
	set AA_RC=Failed
	set AA_BC=Failed
	echo.
)
	
set "AA_String=[LEFT=%AA_LC% px], [TOP=%AA_TC% px], [RIGHT=%AA_RC% px], [BOTTOM=%AA_BC% px]"
if "%AA_LC%%AA_TC%%AA_RC%%AA_BC%"=="UntouchedUntouchedUntouchedUntouched" set "RPU_AA_String=[ANALYSING FAILED^^!]"

%CYAN%
echo Please wait. Analysing RPU Binary...
%WHITE%
"!DO_VI_TOOLpath!" extract-rpu "!VIDEOSTREAM!" -o "!TMP_FOLDER!\RPU.bin">nul
set "RPUFILE=!TMP_FOLDER!\RPU.bin"
if exist "!TMP_FOLDER!\RPU.bin" (
	%HCGREEN%
	echo Done.
	echo.
) else (
	%HCRED%
	echo Error.
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	echo.
)


if exist "!RPUFILE!" (
	%WHITE%
	"!DO_VI_TOOLpath!" info --input "!RPUFILE!" -f 1 >"!TMP_FOLDER!\Info.json"
	"!DO_VI_TOOLpath!" info -s "!RPUFILE!">"!TMP_FOLDER!\RPUINFO.txt"
	if exist "!TMP_FOLDER!\Info.json" (
		:: FIND CROPPING VALUES RPU
		FOR /F "tokens=2 delims=:, " %%A IN ('findstr /C:"active_area_left_offset" "!TMP_FOLDER!\Info.json"') DO set "RPU_AA_LC=%%A"
		FOR /F "tokens=2 delims=:, " %%A IN ('findstr /C:"active_area_right_offset" "!TMP_FOLDER!\Info.json"') DO set "RPU_AA_RC=%%A"
		FOR /F "tokens=2 delims=:, " %%A IN ('findstr /C:"active_area_top_offset" "!TMP_FOLDER!\Info.json"') DO set "RPU_AA_TC=%%A"
		FOR /F "tokens=2 delims=:, " %%A IN ('findstr /C:"active_area_bottom_offset" "!TMP_FOLDER!\Info.json"') DO set "RPU_AA_BC=%%A"
	)
	if exist "!TMP_FOLDER!\RPUINFO.txt" (
		FOR /F "delims=" %%A IN ('findstr /C:"Frames" "!TMP_FOLDER!\RPUINFO.txt"') DO set "RPU_FRAMES=%%A"
		if defined RPU_FRAMES (
			for /F "tokens=2 delims=:/() " %%A in ("!RPU_FRAMES!") do set "RPU_FRAMES=%%A"
		)
	)
)

set "RPU_AA_String=[LEFT=%RPU_AA_LC% px], [TOP=%RPU_AA_TC% px], [RIGHT=%RPU_AA_RC% px], [BOTTOM=%RPU_AA_BC% px]"
if "%RPU_AA_LC%%RPU_AA_TC%%RPU_AA_RC%%RPU_AA_BC%"=="UndefinedUndefinedUndefinedUndefined" set "RPU_AA_String=[NOT SET IN RPU]"
IF "%RAW_FILE%"=="TRUE" if exist !CONTAINERSTREAM! DEL !CONTAINERSTREAM!

:DV8CHKMENU
:: VIDEO-INPUT = RPU-INPUT
if "%AA_LC%%AA_TC%%AA_RC%%AA_BC%"=="%RPU_AA_LC%%RPU_AA_TC%%RPU_AA_RC%%RPU_AA_BC%" (
	set "RPU_AA_String="!Cecho!" {%_CYAN%}Borders = [LEFT=%RPU_AA_LC% px], [TOP=%RPU_AA_TC% px], [RIGHT=%RPU_AA_RC% px], [BOTTOM=%RPU_AA_BC% px] [{%HC_GREEN%}MATCH WITH VIDEO{%_CYAN%}]{#}{\n}"
	set "AA_String="!Cecho!" {%_CYAN%}Borders = [LEFT=%AA_LC% px], [TOP=%AA_TC% px], [RIGHT=%AA_RC% px], [BOTTOM=%AA_BC% px] [{%HC_GREEN%}MATCH WITH RPU{%_CYAN%}]{#}{\n}"
) else (
	set "RPU_AA_String="!Cecho!" {%_CYAN%}Borders = [LEFT=%RPU_AA_LC% px], [TOP=%RPU_AA_TC% px], [RIGHT=%RPU_AA_RC% px], [BOTTOM=%RPU_AA_BC% px] [{%HC_RED%}NOT MATCH WITH VIDEO{%_CYAN%}]{#}{\n}"
	set "AA_String="!Cecho!" {%_CYAN%}Borders = [LEFT=%AA_LC% px], [TOP=%AA_TC% px], [RIGHT=%AA_RC% px], [BOTTOM=%AA_BC% px] [{%HC_RED%}NOT MATCH WITH RPU{%_CYAN%}]{#}{\n}"
)
IF "%RPU_AA_LC%%RPU_AA_TC%%RPU_AA_RC%%RPU_AA_BC%"=="UndefinedUndefinedUndefinedUndefined" set "RPU_AA_String="!Cecho!" {%_CYAN%}Borders    = [{%_GREY%}BORDERS NOT SET IN RPU{%_CYAN%}]{#}{\n}"

IF "!V0_FRAMES!"=="!RPU_FRAMES!" (
	set "FRAMEINFO_VIDEO="!Cecho!" {%_CYAN%}Frames  = [!V0_FRAMES!] [{%HC_GREEN%}MATCH WITH RPU{%_CYAN%}]{#}{\n}"
	set "FRAMEINFO_RPU="!Cecho!" {%_CYAN%}Frames  = [!RPU_FRAMES!] [{%HC_GREEN%}MATCH WITH VIDEO{%_CYAN%}]{#}{\n}"
	set "FRAME_String="!Cecho!" {%HC_GREEN%}VIDEO AND RPU FRAMECOUNT EQUAL!{#}{\n}"
) else (
	set "FRAMEINFO_VIDEO="!Cecho!" {%_CYAN%}Frames  = [!V0_FRAMES!] [{%HC_RED%}NOT MATCH WITH RPU{%_CYAN%}]{#}{\n}"
	set "FRAMEINFO_RPU="!Cecho!" {%_CYAN%}Frames  = [!RPU_FRAMES!] [{%HC_RED%}NOT MATCH WITH VIDEO{%_CYAN%}]{#}{\n}"
	set "FRAME_String="!Cecho!" {%HC_RED%}VIDEO AND RPU FRAMECOUNT NOT EQUAL!{#}{\n}"
)
cls
%GREEN%
echo  !HEADER1!
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                             Dolby Vision Tool SYNC CHECK
%WHITE%
echo                                         ====================================
echo.
echo.
%WHITE%
echo  == FILENAME ============================================================================================================
%CYAN%
echo.
echo !INPUTFILENAME!!INPUTFILEEXT!
echo.
%WHITE%
echo  == VIDEO INPUT =========================================================================================================
%YELLOW%
echo.
%FRAMEINFO_VIDEO%
%AA_String%
%WHITE%
echo.
echo  == RPU INPUT ===========================================================================================================
echo.
%YELLOW%
%FRAMEINFO_RPU%
%RPU_AA_String%
%WHITE%
echo.
echo  == INFORMATIONS ========================================================================================================
echo.
%FRAME_String%
IF "%AA_LC%%AA_TC%%AA_RC%%AA_BC%"=="%RPU_AA_LC%%RPU_AA_TC%%RPU_AA_RC%%RPU_AA_BC%" (
	"!Cecho!" {%HC_GREEN%}ALL CROPPING VALUES CORRECT. Press [{%HC_YELLOW%}E{%HC_GREEN%}] to Exit!{#}{\n}
) else (
	"!Cecho!" {%HC_RED%}CROPPING VALUES INCORRECT. Press [{%HC_YELLOW%}S{%HC_RED%}] to fix them!{#}{\n}
)
%WHITE%
echo.
echo  ========================================================================================================================
echo.
%HCWHITE%
"!Cecho!" {%HC_WHITE%}L. Set [{%HC_YELLOW%}LEFT{%HC_WHITE%}] Crop value: [{%HC_YELLOW%}!RPU_AA_LC! px{%HC_WHITE%}]{#}{\n}
"!Cecho!" {%HC_WHITE%}T. Set [{%HC_YELLOW%}TOP{%HC_WHITE%}] Crop value: [{%HC_YELLOW%}!RPU_AA_TC! px{%HC_WHITE%}]{#}{\n}
"!Cecho!" {%HC_WHITE%}R. Set [{%HC_YELLOW%}RIGHT{%HC_WHITE%}] Crop value: [{%HC_YELLOW%}!RPU_AA_RC! px{%HC_WHITE%}]{#}{\n}
"!Cecho!" {%HC_WHITE%}B. Set [{%HC_YELLOW%}BOTTOM{%HC_WHITE%}] Crop value: [{%HC_YELLOW%}!RPU_AA_BC! px{%HC_WHITE%}]{#}{\n}
echo.
IF "%AA_LC%%AA_TC%%AA_RC%%AA_BC%"=="%RPU_AA_LC%%RPU_AA_TC%%RPU_AA_RC%%RPU_AA_BC%" (
	%HCWHITE%
	echo S. SAVE and FIX Release
	%GREEN%
	echo E. EXIT and do nothing [RECOMMENDED]
	echo.
	"!Cecho!" {%HC_WHITE%}Change Settings and press [S] to FIX or [{%_GREEN%}E{%HC_WHITE%}] to {%_GREEN%}EXIT{%HC_WHITE%}!{#}{\n}
) else (
	%GREEN%
	echo S. SAVE and FIX Release [RECOMMENDED]
	%HCWHITE%
	echo E. EXIT and do nothing
	echo.
	"!Cecho!" {%HC_WHITE%}Change Settings and press [{%_GREEN%}S{%HC_WHITE%}] to {%_GREEN%}FIX{%HC_WHITE%} or [E] to EXIT!{#}{\n}
)
%HCWHITE%
CHOICE /C LTRBSE /N /M "Select a Letter L,T,R,B,[S]ave,[E]xit"

if "%ERRORLEVEL%"=="6" goto DV8CHKEND
if "%ERRORLEVEL%"=="5" goto DV8CHKFIX
if "%ERRORLEVEL%"=="4" (
	echo.
	%HCWHITE%
	echo Type in the Pixels, which will be cropped on BOTTOM side.
	echo Example: For cropping 140px on BOTTOM side type "140" and press Enter^^!
	echo.
	set /p "AA_BC=Type in Pixels and press [ENTER]: "
)
if "%ERRORLEVEL%"=="3" (
	echo.
	%HCWHITE%
	echo Type in the Pixels, which will be cropped on RIGHT side.
	echo Example: For cropping 140px on RIGHT side type "140" and press Enter^^!
	echo.
	set /p "AA_RC=Type in Pixels and press [ENTER]: "
)
if "%ERRORLEVEL%"=="2" (
	echo.
	%HCWHITE%
	echo Type in the Pixels, which will be cropped on TOP side.
	echo Example: For cropping 140px on TOP side type "140" and press Enter^^!
	echo.
	set /p "AA_TC=Type in Pixels and press [ENTER]: "
)
if "%ERRORLEVEL%"=="1" (
	echo.
	%HCWHITE%
	echo Type in the Pixels, which will be cropped on LEFT side.
	echo Example: For cropping 140px on LEFT side type "140" and press Enter^^!
	echo.
	set /p "AA_LC=Type in Pixels and press [ENTER]: "
)

goto :DV8CHKMENU

:DV8CHKFIX
if not exist "!TMP_FOLDER!" md "!TMP_FOLDER!"
if not exist "!TARGET_FOLDER!" MD "!TARGET_FOLDER!">nul
cls
%GREEN%
echo  !HEADER1!
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                             Dolby Vision Tool SYNC CHECK
%WHITE%
echo                                         ====================================
echo.
echo.
%WHITE%
echo  == FIXING RELEASE ======================================================================================================
%CYAN%
echo.
echo Please wait. Applying cropping values...
%WHITE%
(
echo ^{
echo   ^"active_area^"^: ^{
echo     ^"presets^"^: ^[
echo       ^{
echo       	 ^"id^"^: 0,
echo       	 ^"left^"^: %AA_LC%,
echo       	 ^"right^"^: %AA_RC%,
echo       	 ^"top^"^: %AA_TC%,
echo      	 ^"bottom^"^: %AA_BC%
echo       ^}
echo     ^],
echo      ^"edits^"^: {
echo      ^"all^"^: 0
echo     ^}
echo   ^}
echo ^}
)>"!TMP_FOLDER!\CROP.json"

"!DO_VI_TOOLpath!" editor -i "!RPUFILE!" -j "!TMP_FOLDER!\CROP.json" --rpu-out "!TMP_FOLDER!\RPU-cropped.bin">nul
if exist "!TMP_FOLDER!\RPU-cropped.bin" (
	set "RPUFILE=!TMP_FOLDER!\RPU-cropped.bin"
	%HCGREEN%
	echo Done.
	echo.
) else (
	%HCRED%
	echo Error.
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	echo.
)
del "!TMP_FOLDER!\CROP.json"

if "!FIX_SCENECUTS!"=="YES" call :FIX_SHOTS

%CYAN%
echo Please wait. Injecting RPU Metadata Binary into stream...
%WHITE%
"!DO_VI_TOOLpath!" inject-rpu -i "!VIDEOSTREAM!" --rpu-in "!RPUFILE!" -o "!TMP_FOLDER!\!INPUTFILENAME!_[RPU BORDERS FIXED].hevc"
if exist "!TMP_FOLDER!\!INPUTFILENAME!_[RPU BORDERS FIXED].hevc" (
	%HCGREEN%
	echo Done.
	echo.
) else (
	%HCRED%
	echo Error.
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	echo.
)
IF "%RAW_FILE%"=="FALSE" (
	if exist "!VIDEOSTREAM!" (
		del "!VIDEOSTREAM!">nul
		if "%ERRORLEVEL%"=="0" (
			%HCGREEN%
			echo Deleting Temp File - Done.
			echo.
		) else (
			%HCRED%
			echo Deleting Temp File - Error.
			set /a "ERRORCOUNT=!ERRORCOUNT!+1"
			echo.
		)
	)
) else (
	%CYAN%
	echo Please wait. Moving RAW Stream to Target Folder...
	%WHITE%
	move "!TMP_FOLDER!\!INPUTFILENAME!_[RPU BORDERS FIXED].hevc" "!TARGET_FOLDER!\!INPUTFILENAME!_[RPU BORDERS FIXED].hevc" >nul
	if exist "!TARGET_FOLDER!\!INPUTFILENAME!_[RPU BORDERS FIXED].hevc" (
		%HCGREEN%
		echo Done.
		echo.
	) else (
		%HCRED%
		echo Error.
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
		echo.
	)
)

if "!MKVExtract!"=="TRUE" (
	set "duration="
	if "!FRAMERATE!"=="23.976" set "duration=--default-duration 0:24000/1001p --fix-bitstream-timing-information 0:1"
	if "!FRAMERATE!"=="24.000" set "duration=--default-duration 0:24p --fix-bitstream-timing-information 0:1"
	if "!FRAMERATE!"=="25.000" set "duration=--default-duration 0:25p --fix-bitstream-timing-information 0:1"
	if "!FRAMERATE!"=="30.000" set "duration=--default-duration 0:30p --fix-bitstream-timing-information 0:1"
	if "!FRAMERATE!"=="48.000" set "duration=--default-duration 0:48p --fix-bitstream-timing-information 0:1"
	if "!FRAMERATE!"=="50.000" set "duration=--default-duration 0:50p --fix-bitstream-timing-information 0:1"
	if "!FRAMERATE!"=="60.000" set "duration=--default-duration 0:60p --fix-bitstream-timing-information 0:1"
	%CYAN%
	echo Please wait. Muxing Videostream into Container...
	%HCYELLOW%
	echo Don't close the "Muxing into MKV Container" cmd window.
	start /WAIT /MIN "Muxing into MKV Container" "!MKVMERGEpath!" --ui-language en --output ^"!TARGET_FOLDER!\!INPUTFILENAME!_[RPU BORDERS FIXED].mkv^" --no-video ^"^(^" ^"!INPUTFILE!^" ^"^)^" --language 0:und --compression 0:none !duration! ^"^(^" ^"!TMP_FOLDER!\!INPUTFILENAME!_[RPU BORDERS FIXED].hevc^" ^"^)^" --track-order 1:0
	if exist "!TARGET_FOLDER!\!INPUTFILENAME!_[RPU BORDERS FIXED].mkv" (
		%HCGREEN%
		echo Done.
		echo.
	) else (
		%HCRED%
		echo Error.
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
		echo.
	)
)	

if "!MP4Extract!"=="TRUE" (
	%CYAN%
	echo Please wait. Muxing Videostream into Container...
	%WHITE%
	"!MP4BOXpath!" -rem 1 "!INPUTFILE!" -out "!TMP_FOLDER!\temp.mp4"
	if exist "!TMP_FOLDER!\temp.mp4" (
		%HCGREEN%
		echo Done.
	) else (
		%HCRED%
		echo Error.
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	)
	%WHITE%
	"!MP4BOXpath!" -add "!TMP_FOLDER!\!INPUTFILENAME!_[RPU BORDERS FIXED].hevc:ID=1:fps=!FRAMERATE!:name=" "!TMP_FOLDER!\temp.mp4" -out "!TARGET_FOLDER!\!INPUTFILENAME!_[RPU BORDERS FIXED].mp4"
	if exist "!TARGET_FOLDER!\!INPUTFILENAME!_[RPU BORDERS FIXED].mp4" (
		%HCGREEN%
		echo Done.
		echo.
	) else (
		%HCRED%
		echo Error.
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
		echo.
	)	
)
	
:DV8CHKEND
%WHITE%
set BORDERCHECK=TRUE
echo.
echo  == CLEANING ============================================================================================================
echo.
%CYAN%
echo Please wait. Cleaning and Moving files...
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
if "%ERRORCOUNT%"=="0" (
	%HCGREEN%
	echo.
	echo All Operations successful.
) else (
	echo.
	%HCRED%
	echo SOME Operations failed.
)
%WHITE%
TIMEOUT 10
goto :eof

:FIX_SHOTS
if exist "!RPUFILE!" (
	%CYAN%
	echo Fixing Scenecuts...
	%WHITE%
	(
	echo {
	echo	"scene_cuts": {
	echo		"0-0": true
	echo	}
	echo }
	)>"!TMP_FOLDER!\EDIT.json"
	"!DO_VI_TOOLpath!" editor -i "!RPUFILE!" -j "!TMP_FOLDER!\EDIT.json" -o "!TMP_FOLDER!\RPU-SCFIXED.bin">nul
	if exist "!TMP_FOLDER!\RPU-SCFIXED.bin" (
		%HCGREEN%
		del "!TMP_FOLDER!\EDIT.json"
		set "RPUFILE=!TMP_FOLDER!\RPU-SCFIXED.bin"
		echo Done.
		echo.
	) else (
		%HCRED%
		echo Error.
		echo.
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	)
)
goto :eof

:ENHPLOTS
"!JQpath!" "to_entries[] | .value.vdr_dm_data.cmv29_metadata.ext_metadata_blocks[]?.Level1.avg_pq" "!TMP_FOLDER!\plot.json" | findstr /v "null" > "!TMP_FOLDER!\avg.pq.txt"
"!JQpath!" "to_entries[] | .value.vdr_dm_data.cmv29_metadata.ext_metadata_blocks[]?.Level1.max_pq" "!TMP_FOLDER!\plot.json" | findstr /v "null" > "!TMP_FOLDER!\max.pq.txt"

::---------------------------------maxfall stats----------------------------------------------------------------------

set percentage2.5avg=& set percentage10avg=& set percentage25avg=& set percentage50avg=& set percentage91avg=

::2.5nits
FOR /F "delims=" %%A in ('""!PYTHONpath!" "!PYTHONSCRIPTpath!\Percent.target.py" -i "!TMP_FOLDER!\avg.pq.txt" -t 819 -m over"') do set "percentage2.5avg=%%A"
if "!percentage2.5avg!"=="0.00" set percentage2.5avg=0
if "!percentage2.5avg!"=="00.00" set percentage2.5avg=0
if "!percentage2.5avg!"=="" set percentage2.5avg=0
set A1=-annotate +2640+130 "MaxFALL above 2.5 nits: !percentage2.5avg! %%"

::10nits
FOR /F "delims=" %%A in ('""!PYTHONpath!" "!PYTHONSCRIPTpath!\Percent.target.py" -i "!TMP_FOLDER!\avg.pq.txt" -t 1229 -m over"') do set "percentage10avg=%%A"
if "!percentage10avg!"=="0.00" set percentage10avg=0
if "!percentage10avg!"=="00.00" set percentage10avg=0
if "!percentage10avg!"=="" set percentage10avg=0
set A2=-annotate +2640+105 "MaxFALL above  10 nits: !percentage10avg! %%"

::25nits
FOR /F "delims=" %%A in ('""!PYTHONpath!" "!PYTHONSCRIPTpath!\Percent.target.py" -i "!TMP_FOLDER!\avg.pq.txt" -t 1542 -m over"') do set "percentage25avg=%%A"
if "!percentage25avg!"=="0.00" set percentage25avg=0
if "!percentage25avg!"=="00.00" set percentage25avg=0
if "!percentage25avg!"=="" set percentage25avg=0
set A3=-annotate +2640+80 "MaxFALL above  25 nits: !percentage25avg! %%"

::50nits
FOR /F "delims=" %%A in ('""!PYTHONpath!" "!PYTHONSCRIPTpath!\Percent.target.py" -i "!TMP_FOLDER!\avg.pq.txt" -t 1803 -m over"') do set "percentage50avg=%%A"
if "!percentage50avg!"=="0.00" set percentage50avg=0
if "!percentage50avg!"=="00.00" set percentage50avg=0
if "!percentage50avg!"=="" set percentage50avg=0
set A4=-annotate +2640+55 "MaxFALL above  50 nits: !percentage50avg! %%"

::91nits
FOR /F "delims=" %%A in ('""!PYTHONpath!" "!PYTHONSCRIPTpath!\Percent.target.py" -i "!TMP_FOLDER!\avg.pq.txt" -t 2042 -m over"') do set "percentage91avg=%%A"
if "!percentage91avg!"=="0.00" set percentage91avg=0
if "!percentage91avg!"=="00.00" set percentage91avg=0
if "!percentage91avg!"=="" set percentage91avg=0
set A5=-annotate +2640+30 "MaxFALL above  91 nits: !percentage91avg! %%"

::---------------------------------maxcll stats----------------------------------------------------------------------

set percentage150max=& set percentage500max=& set percentage1000max=& set percentage2000max=& set percentage4000max=
set THRE1=2249& set nit1=150& set THRE2=2771& set nit2=500& set THRE3=3079& set nit3=1000& set THRE4=3388& set nit4=2000& set THRE5=3696& set nit5=4000

::150nits
FOR /F "delims=" %%A in ('""!PYTHONpath!" "!PYTHONSCRIPTpath!\Percent.target.py" -i "!TMP_FOLDER!\max.pq.txt" -t %THRE1% -m over"') do set "percentage150max=%%A"
if "!percentage150max!"=="0.00" set percentage150max=0
if "!percentage150max!"=="00.00" set percentage150max=0
if "!percentage150max!"=="" set percentage150max=0
set P1=-annotate +2290+130 "MaxCLL above   !nit1! nits: !percentage150max! %%"

::500nits
FOR /F "delims=" %%A in ('""!PYTHONpath!" "!PYTHONSCRIPTpath!\Percent.target.py" -i "!TMP_FOLDER!\max.pq.txt" -t %THRE2% -m over"') do set "percentage500max=%%A"
if "!percentage500max!"=="0.00" set percentage500max=0
if "!percentage500max!"=="00.00" set percentage500max=0
if "!percentage500max!"=="" set percentage500max=0
set P2=-annotate +2290+105 "MaxCLL above   !nit2! nits: !percentage500max! %%"

::1000nits
FOR /F "delims=" %%A in ('""!PYTHONpath!" "!PYTHONSCRIPTpath!\Percent.target.py" -i "!TMP_FOLDER!\max.pq.txt" -t %THRE3% -m over"') do set "percentage1000max=%%A"
if "!percentage1000max!"=="0.00" set percentage1000max=0
if "!percentage1000max!"=="00.00" set percentage1000max=0
if "!percentage1000max!"=="" set percentage1000max=0
set P3=-annotate +2290+80 "MaxCLL above !nit3! nits: !percentage1000max! %%"

::2000nits
FOR /F "delims=" %%A in ('""!PYTHONpath!" "!PYTHONSCRIPTpath!\Percent.target.py" -i "!TMP_FOLDER!\max.pq.txt" -t %THRE4% -m over"') do set "percentage2000max=%%A"
if "!percentage2000max!"=="0.00" set percentage2000max=0
if "!percentage2000max!"=="00.00" set percentage2000max=0
if "!percentage2000max!"=="" set percentage2000max=0
set P4=-annotate +2290+55 "MaxCLL above !nit4! nits: !percentage2000max! %%"

::4000nits
FOR /F "delims=" %%A in ('""!PYTHONpath!" "!PYTHONSCRIPTpath!\Percent.target.py" -i "!TMP_FOLDER!\max.pq.txt" -t %THRE5% -m over"') do set "percentage4000max=%%A"
if "!percentage4000max!"=="0.00" set percentage4000max=0
if "!percentage4000max!"=="00.00" set percentage4000max=0
if "!percentage4000max!"=="" set percentage4000max=0
set P5=-annotate +2290+30 "MaxCLL above !nit5! nits: !percentage4000max! %%"

set actualmax=& set actualavg=

::find the actual maxcll/fall shot, display the first frame
FOR /F "delims=" %%A in ('""!PYTHONpath!" "!PYTHONSCRIPTpath!\maxcll.shot.finder.py" -i "!TMP_FOLDER!\max.pq.txt" -m max"') do set "actualmax=%%A"
set AM=-annotate +2290+5 "MaxCLL scene frame start: !actualmax!"

FOR /F "delims=" %%A in ('""!PYTHONpath!" "!PYTHONSCRIPTpath!\maxcll.shot.finder.py" -i "!TMP_FOLDER!\avg.pq.txt" -m max"') do set "actualavg=%%A"
set AA=-annotate +2640+5 "MaxFALL scene frame start: !actualavg!"
goto :eof

:EXIT
%WHITE%
echo  == CLEANING ============================================================================================================
echo.
%CYAN%
echo Please wait. Cleaning and Moving files...
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

:ANALYSESTREAMS
FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=General;%%VideoCount%% "!INPUTFILE!""') do set "VIDEO_COUNT=%%A"
if "!VIDEO_COUNT!" NEQ "1" set "LAYERTYPE= DL"
"!FFPROBEpath!" "!INPUTFILE!" -show_streams -v 0 -of compact=p=0:nk=1 >"!TMP_FOLDER!\STREAMS.txt"
FOR /F "delims=" %%A IN ('findstr /C:"hevc|H.265" "!TMP_FOLDER!\STREAMS.txt"') DO echo %%A>>"!TMP_FOLDER!\VSTREAMS.txt"
FOR /F "delims=" %%A IN ('findstr /C:"3840|2160" "!TMP_FOLDER!\VSTREAMS.txt"') DO set "BL_STREAMINFO=%%A"
FOR /F "delims=" %%A IN ('findstr /C:"1920|1080" "!TMP_FOLDER!\VSTREAMS.txt"') DO set "EL_STREAMINFO=%%A"
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

:NOLAVFILTERS
set "NewLine=[System.Environment]::NewLine"
set "Line1=LAV Filters not set or installed."
set "Line2=Start <DDVT_OPTIONS.cmd> and set correct directory or install LAV Filters."
setlocal DisableDelayedExpansion
START /MIN /WAIT PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('%INPUTFILENAME%%INPUTFILEEXT%' + %NewLine% + %NewLine% + '%Line1%' + %NewLine% + %NewLine% + '%Line2%', 'DDVT FileInfo v%VERSION%', 'Ok','Info')"
goto :eof

:FALSEINPUT
if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
set "NewLine=[System.Environment]::NewLine"
set "Line1=Unsupported Input File. Supported Files are:"
set "Line2=*.bin | *.mp4 | *.m2ts | *.mkv | *.json | *.h265 | *.hevc"
setlocal DisableDelayedExpansion
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('%INPUTFILENAME%%INPUTFILEEXT%' + %NewLine% + %NewLine% + '%Line1%' + %NewLine% + %NewLine% + '%Line2%', 'DDVT FileInfo v%VERSION%', 'Ok','Info')"
exit

:CORRUPTFILE
if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
START /B https://mega.nz/folder/x9FHlbbK#YQz_XsqcAXfZP2ciLeyyDg
set "NewLine=[System.Environment]::NewLine"
set "Line1=""%MISSINGFILE%""""
set "Line2=Copy the file to the directory or download and extract DDVT_tools.rar"
setlocal DisableDelayedExpansion
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('NEEDED FILE NOT FOUND!' + %NewLine% + %NewLine% + '%Line1%' + %NewLine% + %NewLine% + '%Line2%', 'DDVT FileInfo v%VERSION%', 'Ok','Error')"
exit

:ERROR
if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
set "NewLine=[System.Environment]::NewLine"
set "Line1=%ERRORCOUNT% Error(s) during processing^!
set "Line2=Target file don''t exist or corrupt.
setlocal DisableDelayedExpansion
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('%INPUTFILENAME%%INPUTFILEEXT%' + %NewLine% + %NewLine% + '%Line1%' + %NewLine% + %NewLine% + '%Line2%', 'DDVT FileInfo v%VERSION%', 'Ok','Error')"
exit

:SC_NODV
if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
set "NewLine=[System.Environment]::NewLine"
set "Line1=Unsupported Input File.
set "Line2=Only Files with Dolby Vision Profile 8 supported.
setlocal DisableDelayedExpansion
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('%INPUTFILENAME%%INPUTFILEEXT%' + %NewLine% + %NewLine% + '%Line1%' + %NewLine% + %NewLine% + '%Line2%', 'DDVT FileInfo v%VERSION%', 'Ok','Info')"
exit

:FALSEINPUTCHECK
if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
set "NewLine=[System.Environment]::NewLine"
set "Line1=Unsupported Input File. Supported Files are:"
set "Line2=*.mkv | *.mp4 | *.h265 | *.hevc | *.bin | *.json"
setlocal DisableDelayedExpansion
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('%INPUTFILENAME%%INPUTFILEEXT%' + %NewLine% + %NewLine% + '%Line1%' + %NewLine% + %NewLine% + '%Line2%', 'DDVT SyncCheck v%VERSION%', 'Ok','Info')"
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