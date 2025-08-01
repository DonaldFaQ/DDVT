::written by DonaldFaQ, THX to Jamal for the great idea!
@echo off & setlocal
set "VERSION=--N.A.-- INCORRECTLY INSTALLED"
set "HEADER1=File "%~dp0DDVT_OPTIONS.cmd" missing! Script works not correctly!"
FOR /F "tokens=2 delims==" %%A IN ('findstr /C:"VERSION=" "%~dp0DDVT_OPTIONS.cmd"') DO set "VERSION=%%A"
FOR /F "tokens=2 delims==" %%A IN ('findstr /C:"HEADER1=" "%~dp0DDVT_OPTIONS.cmd"') DO set "HEADER1=%%A"
TITLE DDVT MediaInfo v%VERSION%
set DESIGN=STANDARD
set "TOOLTYPE=TEXT"
if /i "%~2"=="-MSGBOX" set "TOOLTYPE=MSGBOX"
if "%TOOLTYPE%"=="TEXT" (
	mode con cols=125 lines=30
) else (
	mode con cols=122 lines=20
)

set PasswordChars=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890
set PasswordLength=5
call :CreatePassword Password

set "Cecho=%~dp0tools\cecho_x64.exe" rem Path to cecho_x64.exe
set "sfkpath=%~dp0tools\sfk.exe" rem Path to sfk.exe
set "FFMPEGpath=%~dp0tools\ffmpeg.exe" rem Path to ffmpeg.exe
set "FFPROBEpath=%~dp0tools\ffprobe.exe" rem Path to ffprobe.exe
set "MEDIAINFOpath=%~dp0tools\mediainfo.exe" rem Path to mediainfo.exe
set "DO_VI_TOOLpath=%~dp0tools\dovi_tool.exe" rem Path to dovi_tool.exe

rem --- Hardcoded settings. Cannot be changed ---
set "LOGFILE=YES"
set "RAWFILE=TRUE"
set "EL_INPUT=FALSE"
set "RPU_EXIST=FALSE"
set "RPU_STRING="
set "TMP_FOLDER=SAME AS SOURCE"
set "MKVTOOLNIX_FOLDER=INCLUDED"
set "LAYERTYPE="
set "Format=HEVC"
set "DVinput=NO"
set "DVBIN=NO"
set "DVP7=NO"
set "RPU="

setlocal EnableDelayedExpansion

::Check for INI and Load Settings
if exist "%~dp0DDVT_OPTIONS.ini" (
	FOR /F "delims=" %%A IN ('findstr /C:"TEMP Folder=" "%~dp0DDVT_OPTIONS.ini"') DO (
		set "TMP_FOLDER=%%A"
		set "TMP_FOLDER=!TMP_FOLDER:~12!"
	)
	FOR /F "delims=" %%A IN ('findstr /C:"MKVTOOLNIX Folder=" "%~dp0DDVT_OPTIONS.ini"') DO (
		set "MKVTOOLNIX_FOLDER=%%A"
		set "MKVTOOLNIX_FOLDER=!MKVTOOLNIX_FOLDER:~18!"
	)
	FOR /F "delims=" %%A IN ('findstr /C:"MEDIAINFO_LOGFILE=" "%~dp0DDVT_OPTIONS.ini"') DO (
		set "LOGFILE=%%A"
		set "LOGFILE=!LOGFILE:~18!"
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

if not exist "%Cecho%" set "MISSINGFILE=%~dp0tools\cecho_x64.exe" & goto :CORRUPTFILE
if not exist "%sfkpath%" set "MISSINGFILE=%sfkpath%" & goto :CORRUPTFILE
if not exist "%FFMPEGpath%" set "MISSINGFILE=%FFMPEGpath%" & goto :CORRUPTFILE
if not exist "%FFPROBEpath%" set "MISSINGFILE=%FFPROBEpath%" & goto :CORRUPTFILE
if not exist "%MEDIAINFOpath%" set "MISSINGFILE=%MEDIAINFOpath%" & goto :CORRUPTFILE
if not exist "%DO_VI_TOOLpath%" set "MISSINGFILE=%DO_VI_TOOLpath%" & goto :CORRUPTFILE
if not exist "%MKVMERGEpath%" set "MISSINGFILE=%MKVMERGEpath%" & goto :CORRUPTFILE

::PREPARE FOR OPTIONS
set "FILE=%~dpnx1"
set "FILEPATH=%~dp1"
set "FILENAME=%~n1"
set "FILEEXT=%~x1"

if /i "!FILEEXT!"=="" CALL :INSERT_INPUT

set "LOGFILEpath=!FILEPATH!!FILENAME!!FILEEXT!_DDVT_MediaInfo.txt" rem Path where your logfile will be saved
if "%TMP_FOLDER%"=="SAME AS SOURCE" (
	set "TMP_FOLDER=%tmp%\DDVT_%Password%_TMP"
) else (
	set "TMP_FOLDER=!TMP_FOLDER!\DDVT_%Password%_TMP"
)

if /i "!FILEEXT!"==".mkv" set "RAWFILE=FALSE" & goto :PREPARE
if /i "!FILEEXT!"==".ts"  goto :PREPARE
if /i "!FILEEXT!"==".m2ts" goto :PREPARE
if /i "!FILEEXT!"==".mp4" goto :PREPARE
if /i "!FILEEXT!"==".bin" set "RAWFILE=FALSE" & goto :PREPARE
if /i "!FILEEXT!"==".xml" set "RAWFILE=FALSE" & goto :PREPARE
if /i "!FILEEXT!"==".h265" goto :PREPARE
if /i "!FILEEXT!"==".hevc" goto :PREPARE
if /i "!FILEEXT!"==".iso" set "ISOFILE=TRUE" & goto :PREPARE
call :FALSEINPUT

:INSERT_INPUT
cls
%GREEN%
echo  !HEADER1!
%WHITE%
echo.
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool MEDIAINFO
%WHITE%
echo                                         ====================================
echo.
echo.
echo  == INSERT FILE HERE ====================================================================================================
%HCYELLOW%
echo.
echo [Info] Insert one file with following extensions:
echo        .iso ^(Blu-ray^) ^| .hevc ^| .h265 ^| .xml ^| .bin ^| .mp4 ^| .m2ts ^| .ts ^| .mkv
echo.
%WHITE%
"!Cecho!" {%_WHITE%}Drag 'n' Drop {%_GREEN%}FILE {%_WHITE%}here and press ENTER:{#}{\n}
%GREEN%
set /p "FILE=%~1" || if "!FILE!"=="" goto :INSERT_INPUT

for %%f in (!FILE!) do set "FILENAME=%%~nf"
for %%f in (!FILE!) do set "FILEEXT=%%~xf"
for %%f in (!FILE!) do set "FILEPATH=%%~dpf"
for %%f in (!FILE!) do set "FILE=%%~dpnxf"

goto :eof

:PREPARE
cls
%GREEN%
echo  %HEADER1%
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool MEDIAINFO
%WHITE%
echo                                         ====================================
echo.
echo.
echo  == OPERATION ===========================================================================================================
echo.
%CYAN%
if not exist "!TMP_FOLDER!" MD "!TMP_FOLDER!">nul
echo Processing. Please wait...
if /i "!FILEEXT!"==".bin" set "DVBIN=YES"& set "RPU=!FILEPATH!!FILENAME!.bin"& set "DVinput=YES"& set "RPU_EXIST=TRUE"& goto :SKIP
if /i "!FILEEXT!"==".xml" (
     "!DO_VI_TOOLpath!" generate --xml "!FILE!" --canvas-width 3840 --canvas-height 2160 --rpu-out "!TMP_FOLDER!\RPU.bin">nul 2>&1
	 if exist "!TMP_FOLDER!\RPU.bin" (
		 set "RPU=!TMP_FOLDER!\RPU.bin"
		 set "RPU_EXIST=TRUE"
		 set "DVBIN=YES
		 set "DVinput=YES"
		 goto :SKIP
	) else (
		GOTO :CORRUPTRPU
	)
)

if "!ISOFILE!"=="TRUE" (
	for %%a in (Z Y X W V U T S R Q P O N M L K J I H G F E D C B A) do (if not exist "%%a:\" set "MountDrive=%%a")
	if "!MountDrive!"=="" (
		"!Cecho!" {%_CYAN%}[{%HC_RED%}No Free Drive letter found^^!{%_CYAN%}]{#}{\n}
		goto :NOMOUNTDRIVE
	) else (
		CALL :MOUNT
	)
)	

::SET BL EL STREAMINDEX
call :ANALYSESTREAMS

::WRITE MEDIAINFO
set "MI_INFOVIDEO=!FILE!"
if "!RAWFILE!"=="TRUE" (
	"!MKVMERGEpath!" --ui-language en --priority higher --output ^"!TMP_FOLDER!\Info.mkv^" --language 0:und --compression 0:none ^"^(^" ^"!FILE!^" ^"^)^" --split parts:00:00:00-00:00:01 -q
	if exist "!TMP_FOLDER!\Info.mkv" set "MI_INFOVIDEO=!TMP_FOLDER!\Info.mkv"
)
if "!VIDEO_COUNT!" NEQ "1" (
	"!MKVMERGEpath!" --ui-language en --priority higher --output ^"!TMP_FOLDER!\Info.mkv^" --language 0:und --compression 0:none ^"^(^" ^"!FILE!^" ^"^)^" --split parts:00:00:00-00:00:01 -q
	if exist "!TMP_FOLDER!\Info.mkv" set "MI_INFOVIDEO=!TMP_FOLDER!\Info.mkv"
)

::SET HDR FORMAT
if exist "!TMP_FOLDER!\Info.mkv" (
	"!MEDIAINFOpath!" --output=Video;%%HDR_Format_String%% "!MI_INFOVIDEO!">"!TMP_FOLDER!\Info.txt"
	FOR /F "delims=" %%A IN ('findstr /C:"Dolby Vision" "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES"
	FOR /F "delims=" %%A IN ('findstr /C:"HDR10" "!TMP_FOLDER!\Info.txt"') DO set "HDRFormat=HDR10"
	FOR /F "delims=" %%A IN ('findstr /C:"HDR10+" "!TMP_FOLDER!\Info.txt"') DO set "HDRFormat=HDR10+"
	FOR /F "delims=" %%A IN ('findstr /C:"dvhe.05" "!TMP_FOLDER!\Info.txt"') DO set "HDRFormat=IPT-PQ-C2"
	FOR /F "delims=" %%A IN ('findstr /C:"HLG" "!TMP_FOLDER!\Info.txt"') DO set "HDRFormat=HLG"
)
if not defined HDRFormat (
	"!MEDIAINFOpath!" --output=Video;%%HDR_Format_String%% "!FILE!">"!TMP_FOLDER!\Info.txt"
	FOR /F "delims=" %%A IN ('findstr /C:"Dolby Vision" "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES"
	FOR /F "delims=" %%A IN ('findstr /C:"HDR10" "!TMP_FOLDER!\Info.txt"') DO set "HDRFormat=HDR10"
	FOR /F "delims=" %%A IN ('findstr /C:"HDR10+" "!TMP_FOLDER!\Info.txt"') DO set "HDRFormat=HDR10+"
	FOR /F "delims=" %%A IN ('findstr /C:"dvhe.05" "!TMP_FOLDER!\Info.txt"') DO set "HDRFormat=IPT-PQ-C2"
	FOR /F "delims=" %%A IN ('findstr /C:"HLG" "!TMP_FOLDER!\Info.txt"') DO set "HDRFormat=HLG"
)
if not defined HDRFormat set "HDRFormat=SDR"

::SET DV FORMAT
if exist "!TMP_FOLDER!\Info.mkv" (
	"!MEDIAINFOpath!" --output=Video;%%HDR_Format_Profile%% "!MI_INFOVIDEO!">"!TMP_FOLDER!\Info.txt">nul
	FOR /F "delims=" %%A IN ('findstr /C:".08." "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES" & set "DVprofile=8"
	FOR /F "delims=" %%A IN ('findstr /C:".07." "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES" & set "DVprofile=7"
	FOR /F "delims=" %%A IN ('findstr /C:".06." "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES" & set "DVprofile=6"
	FOR /F "delims=" %%A IN ('findstr /C:".05." "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES" & set "DVprofile=5"
	FOR /F "delims=" %%A IN ('findstr /C:".04." "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES" & set "DVprofile=4"
	FOR /F "delims=" %%A IN ('findstr /C:".03." "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES" & set "DVprofile=3"
)
if not defined DVprofile (
	"!MEDIAINFOpath!" --output=Video;%%HDR_Format_Profile%% "!FILE!">"!TMP_FOLDER!\Info.txt">nul
	FOR /F "delims=" %%A IN ('findstr /C:".08." "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES" & set "DVprofile=8"
	FOR /F "delims=" %%A IN ('findstr /C:".07." "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES" & set "DVprofile=7"
	FOR /F "delims=" %%A IN ('findstr /C:".06." "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES" & set "DVprofile=6"
	FOR /F "delims=" %%A IN ('findstr /C:".05." "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES" & set "DVprofile=5"
	FOR /F "delims=" %%A IN ('findstr /C:".04." "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES" & set "DVprofile=4"
	FOR /F "delims=" %%A IN ('findstr /C:".03." "!TMP_FOLDER!\Info.txt"') DO set "DVinput=YES" & set "DVprofile=3"
)

::DEMUX RPU SAMPLE
if "!DVinput!"=="YES" (
	"!FFMPEGpath!" -loglevel panic -i "!FILE!" -map 0:!EL_INDEX! -c:v copy -to 1 -bsf:v hevc_mp4toannexb -f hevc - | "!DO_VI_TOOLpath!" extract-rpu -o "!TMP_FOLDER!\RPU.bin" - >nul 2>&1
	if exist "!TMP_FOLDER!\RPU.bin" (
		FOR /F "usebackq" %%A IN ('"!TMP_FOLDER!\RPU.bin"') DO set "RPUSIZE=%%~zA"
		if "!RPUSIZE!" NEQ "0" (
			set "RPU=!TMP_FOLDER!\RPU.bin"
			set "RPU_EXIST=TRUE"
			set "RPU_STRING="
		)
	) else (
		"!FFMPEGpath!" -loglevel panic -i "!MI_INFOVIDEO!" -c:v copy -bsf:v hevc_mp4toannexb -f hevc - | "!DO_VI_TOOLpath!" extract-rpu -o "!TMP_FOLDER!\RPU.bin" - >nul 2>&1
	)
	if exist "!TMP_FOLDER!\RPU.bin" (
		FOR /F "usebackq" %%A IN ('"!TMP_FOLDER!\RPU.bin"') DO set "RPUSIZE=%%~zA"
		if "!RPUSIZE!" NEQ "0" (
			set "RPU=!TMP_FOLDER!\RPU.bin"
			set "RPU_EXIST=TRUE"
			set "RPU_STRING="
		) else (
			if exist "!TMP_FOLDER!\RPU.bin" del "!TMP_FOLDER!\RPU.bin" >nul
			set "RPU_STRING=RPU FOUND BUT CANNOT DEMUXED FROM VIDEO"
			set "RPU_EXIST=FALSE"
		)
	) else (
		set "RPU_STRING=RPU ERROR DURING DEMUXING. DOLBY VISION INFOS DISABLED"
		set "RPU_EXIST=FALSE"
	)
)

:: CHECK FOR EL INPUT
if "!DVprofile!!RESOLUTION!"=="71920 px x 1080 px" set "EL_INPUT=TRUE"

::GENERAL MEDIAINFO
FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=General;%%Duration/String%% "!FILE!""') do set "DURATION=%%A"
FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=General;%%FileSize_String4%% "!FILE!""') do set "FILESIZE=%%A"
::AUDIO COUNT
FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=General;%%AudioCount%% "!FILE!""') do set "AUDIO_COUNT=%%A"
if defined AUDIO_COUNT (
	set "AUDIO_COUNT=!AUDIO_COUNT! Audio track(s)"
)
::TEXT COUNT
FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=General;%%TextCount%% "!FILE!""') do set "TEXT_COUNT=%%A"
if defined TEXT_COUNT (
	set "TEXT_COUNT=!TEXT_COUNT! Subtitle(s)"
)

::BL MEDIAINFO

::CODEC NAME
FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%Format%%^-%%BitDepth%%Bit^-%%ColorSpace%%^-%%ChromaSubsampling%% "!MI_INFOVIDEO!""') do set "CODEC_NAME=%%A"
if not defined CODEC_NAME set "CODEC_NAME=N/A"
::MAXCll and MAXFall
FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%MaxCLL%% "!MI_INFOVIDEO!""') do set "MaxCLL=%%A"
if not defined MaxCLL set "MaxCLL=N/A"
FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%MaxFALL%% "!MI_INFOVIDEO!""') do set "MaxFALL=%%A"
if not defined MaxFALL set "MaxFALL=N/A"
::HDR METADATA
FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%MasteringDisplay_ColorPrimaries%% "!MI_INFOVIDEO!""') do set "MDCP=%%A"
if not defined MDCP set "MDCP=N/A"
FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%MasteringDisplay_Luminance%% "!MI_INFOVIDEO!""') do set "Luminance=%%A"
if not defined Luminance (
	set "MinDML=N/A"
	set "MaxDML=N/A"
	set "Luminance=N/A"
) else (
	for /F "tokens=2" %%A in ("!Luminance!") do set MinDML=%%A
	for /F "tokens=* delims=0." %%A in ("!MinDML!") do set "MinDML=%%A"
	for /F "tokens=5" %%A in ("!Luminance!") do set MaxDML=%%A
)

::VIDEO MEDIAINFO

::FRAMERATE
FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%FrameRate/String%% "!FILE!""') do set "FRAMERATE=%%A"
for /F "tokens=1-2 delims=FPS" %%A in ("!FRAMERATE!") do (
	set "FRAMERATE=%%AFPS"
	if "%%B" NEQ "" set "FRAMERATE=BL = %%AFPS | EL = %%BFPS"
)
::BITRATE
FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%BitRate/String%% "!FILE!""') do set "BITRATE=%%A"
for /F "tokens=1-2 delims=/s" %%A in ("!BITRATE!") do (
	set "BITRATE=%%A/s"
	if "%%B" NEQ "" set "BITRATE=BL = %%A/s | EL = %%B/s"
)
::RESOLUTION
FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;"%%Width%%x x %%Height%%x" "!FILE!""') do set "RESOLUTION=%%A"
for /F "tokens=1-4 delims=x " %%A in ("!RESOLUTION!") do (
	if "!DVprofile!%%A%%B"=="719201080" set "EL_INPUT=TRUE"
	set "RESOLUTION=%%A px x %%B px"
	if "%%C" NEQ "" set "RESOLUTION=BL = %%A px x %%B px | EL = %%C px x %%D px"
)
::STREAMSIZE
FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%StreamSize_String4%% "!FILE!""') do set "STREAMSIZE=%%A"
for /F "tokens=1-10 delims=iB" %%A in ("!STREAMSIZE!") do (
	set "STREAMSIZE=%%AiB"
	if "%%B" NEQ "" set "STREAMSIZE=BL = %%AiB | EL = %%BiB"
)

:SKIP
::RPU OPERATIONS

if "!RPU_EXIST!"=="TRUE" (
	"!DO_VI_TOOLpath!" info --input "!RPU!" -f 1 > "!TMP_FOLDER!\temp.rpu.json"
	"!DO_VI_TOOLpath!" info -s "!RPU!" > "!TMP_FOLDER!\RPUINFO.txt"

	::FIND DM VERSION
	FOR /F "delims=" %%A IN ('findstr /C:"DM version" "!TMP_FOLDER!\RPUINFO.txt"') DO set "DM_STRING=%%A"
	if defined DM_STRING (
		for /F "tokens=3 delims=:/()" %%A in ("!DM_STRING!") do set "DM=, %%A"
		for /F "tokens=2 delims=:" %%A in ("!DM_STRING!") do set "DM_FULL=%%A"
		set "DM_FULL=!DM_FULL:~1!"
	) else (
		set "DM=, DM NOT FOUND. CORRUPT RPU^?"
		set "DM_FULL=DM NOT FOUND. CORRUPT RPU^?"
	)

	::FIND DV PROFILE
	FOR /F "delims=" %%A IN ('findstr /C:"dovi_profile" "!TMP_FOLDER!\temp.rpu.json"') DO set "DVprofile=%%A"
	if defined DVprofile (
		set "DVprofile=!DVprofile:*:=!"
		set "DVprofile=!DVprofile:~1,-1!"
	) else (
		set "DVprofile=N/A"
		if "!DVBIN!"=="YES" set "DVinput=CORRUPT"
	)
	if "!DVprofile!"=="7" set "DVP7=YES"
	if "!DVinput!"=="CORRUPT" GOTO :CORRUPTRPU

	::FIND MEL FEL
	FOR /F "delims=" %%A IN ('findstr /C:"el_type" "!TMP_FOLDER!\temp.rpu.json"') DO set "subprofile=%%A"
	if defined subprofile (
		set "subprofile=!subprofile:*:=!"
		set "subprofile=!subprofile:~2,-2!"
	) else (
		set "subprofile=N/A ^(Corrupt^?^)"
	)

	::L1
	FOR /F "delims=" %%A IN ('findstr /C:"RPU mastering display:" "!TMP_FOLDER!\RPUINFO.txt"') DO set "RPUMDL_L1=%%A"
	if defined RPUMDL_L1 (
		for /F "tokens=4 delims=:/ " %%A in ("!RPUMDL_L1!") do set RPUMinDML_L1=%%A
		for /F "tokens=5 delims=:/ " %%A in ("!RPUMDL_L1!") do set RPUMaxDML_L1=%%A
		set "RPULuminanceL1=min: !RPUMinDML_L1! cd/m2, max: !RPUMaxDML_L1! cd/m2"
	) else (
		set "RPULuminanceL1=N/A"
	)
	FOR /F "delims=" %%A IN ('findstr /C:"RPU content light level" "!TMP_FOLDER!\RPUINFO.txt"') DO set "L1_STRING=%%A"
	if defined L1_STRING (
		for /F "tokens=7 delims=:/ " %%A in ("!L1_STRING!") do set "RPUCLL_L1=%%A cd/m2"
		for /F "tokens=10 delims=:/ " %%A in ("!L1_STRING!") do set "RPUFALL_L1=%%A cd/m2"
	) else (
		set "RPUCLL_L1=N/A"
		set "RPUFALL_L1=N/A"
	)

	::L2
	FOR /F "delims=" %%A IN ('findstr /C:"L2 trims" "!TMP_FOLDER!\RPUINFO.txt"') DO set "L2_TRIMS=%%A"
	if defined L2_TRIMS (
		set "L2_TRIMS=!L2_TRIMS:~12!"
	) else (
		set "L2_TRIMS=N/A"
	)

	::L5
	FOR /F "delims=" %%A IN ('findstr /C:"Level5" "!TMP_FOLDER!\temp.rpu.json"') DO set "L5_FOUND=%%A"
	if defined L5_FOUND (
		FOR /F "tokens=2 delims=:, " %%A IN ('findstr /C:"active_area_left_offset" "!TMP_FOLDER!\temp.rpu.json"') DO set "RPU_INPUT_AA_LC=%%A"
		FOR /F "tokens=2 delims=:, " %%A IN ('findstr /C:"active_area_right_offset" "!TMP_FOLDER!\temp.rpu.json"') DO set "RPU_INPUT_AA_RC=%%A"
		FOR /F "tokens=2 delims=:, " %%A IN ('findstr /C:"active_area_top_offset" "!TMP_FOLDER!\temp.rpu.json"') DO set "RPU_INPUT_AA_TC=%%A"
		FOR /F "tokens=2 delims=:, " %%A IN ('findstr /C:"active_area_bottom_offset" "!TMP_FOLDER!\temp.rpu.json"') DO set "RPU_INPUT_AA_BC=%%A"
	) else (
		if "!DVprofile!" NEQ "5" (
			set "L5_STRING_TXT=L5 Metadata not found. L5 Fix recommended"
		) else (
			set "L5_STRING_TXT=N/A"
		)
	)

	::L6
	FOR /F "delims=" %%A IN ('findstr /C:"L6 metadata:" "!TMP_FOLDER!\RPUINFO.txt"') DO set "L6METADATA=%%A"
	if defined L6METADATA (
		for /F "tokens=5 delims=:/ " %%A in ("!L6METADATA!") do set "RPUMinDML_L6=%%A"
		for /F "tokens=6 delims=:/ " %%A in ("!L6METADATA!") do set "RPUMaxDML_L6=%%A"
		for /F "tokens=9 delims=:/ " %%A in ("!L6METADATA!") do set "RPUCLL_L6=%%A cd/m2"
		for /F "tokens=12 delims=:/ " %%A in ("!L6METADATA!") do set "RPUFALL_L6=%%A cd/m2"
		set "RPULuminanceL6=min: !RPUMinDML_L6! cd/m2, max: !RPUMaxDML_L6! cd/m2"
	) else (
		set "RPULuminanceL6=N/A"
		set "RPUCLL_L6=N/A"
		set "RPUFALL_L6=N/A"
	)

	::L9
	FOR /F "delims=" %%A IN ('findstr /C:"source_primary_index" "!TMP_FOLDER!\temp.rpu.json"') DO set "L9_FOUND=%%A"
	if defined L9_FOUND (
		for /F "tokens=2 delims=:/ " %%A in ("!L9_FOUND!") do set "L9MDP=%%A"
		if "!L9MDP!"=="0" set "L9MDP=Display P3"
		if "!L9MDP!"=="2" set "L9MDP=BT.2020"
	)
)

if "!ISOFILE!"=="TRUE" powershell.exe -ExecutionPolicy Bypass -File "!TMP_FOLDER!\dismount.ps1"

::BEGIN DISPLAYING
if "!TOOLTYPE!"=="MSGBOX" (
	if exist "!TMP_FOLDER!" rmdir /Q /S "!TMP_FOLDER!">nul
	CALL :OUTPUT_msgBOX
)
if "!LOGFILE!"=="YES" CALL :OUTPUT_LOGFILE
if "!TOOLTYPE!"=="TEXT" CALL :OUTPUT_TEXT
if "!LOGFILE!"=="YES" (
	if exist "!TMP_FOLDER!\logfile.txt" copy "!TMP_FOLDER!\logfile.txt" "!LOGFILEpath!">nul
)
	
if exist "!TMP_FOLDER!" rmdir /Q /S "!TMP_FOLDER!">nul
setlocal DisableDelayedExpansion
endlocal
pause>nul
exit

:OUTPUT_TEXT
mode con cols=125 lines=57
if "!subprofile!"=="FEL" set "subprofile={%HC_GREEN%}FEL"
if "!subprofile!"=="MEL" set "subprofile={%HC_YELLOW%}MEL"
if defined L5_FOUND (
set "L5_STRING=Left: !RPU_INPUT_AA_LC! px, Top: !RPU_INPUT_AA_TC! px, Right: !RPU_INPUT_AA_RC! px, Bottom: !RPU_INPUT_AA_BC! px"
) else (
	if "!DVprofile!"=="8" (
	set "L5_STRING={%HC_YELLOW%}No L5 Metadata in RPU. L5 Fix recommended [DDVT SyncCheck]."
	) else (
		set "L5_STRING=N/A"
	)
)
cls
%GREEN%
echo  %HEADER1%
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool MEDIAINFO
%WHITE%
echo                                         ====================================
echo.
echo.
echo  == SUMMARY =============================================================================================================
echo.
"!Cecho!" {%_YELLOW%}Filename          {%HC_WHITE%}: !FILENAME!!FILEEXT!{#}{\n}
if defined FILESIZE (
	echo.
	"!Cecho!" {%_YELLOW%}Filesize          {%HC_WHITE%}: !FILESIZE!{#}{\n}
)
if defined DURATION (
	echo.
	"!Cecho!" {%_YELLOW%}Duration          {%HC_WHITE%}: !DURATION!{#}{\n}
)
echo.
::DV P7 INFOLINE
if "!EL_INPUT!!DVinput!!DVP7!!DVBIN!"=="FALSEYESYESNO" "!Cecho!" {%_YELLOW%}Video             {%HC_WHITE%}: Base Layer ({%HC_GREEN%}!HDRFormat!{%HC_WHITE%}) + Enhanced Layer ({%HC_GREEN%}Dolby Vision Profile 7!LAYERTYPE! !subprofile!{%HC_WHITE%}) + RPU ({%HC_GREEN%}!DM:~2!{%HC_WHITE%}){#}{\n}
::DV P5/P8 INFOLINE
if "!EL_INPUT!!DVinput!!DVP7!!DVBIN!"=="FALSEYESNONO" "!Cecho!" {%_YELLOW%}Video             {%HC_WHITE%}: Base Layer ({%HC_GREEN%}!HDRFormat!{%HC_WHITE%}) + RPU ({%HC_GREEN%}Dolby Vision Profile !DVprofile!!DM!{%HC_WHITE%}){#}{\n}
::EL INFOLINE
if "!EL_INPUT!!DVinput!"=="TRUEYES" "!Cecho!" {%_YELLOW%}Video             {%HC_WHITE%}: Enhanced Layer ({%HC_GREEN%}Dolby Vision Profile 7{%HC_WHITE%}) [!subprofile!{%HC_WHITE%}] + RPU ({%HC_GREEN%}!DM:~2!{%HC_WHITE%}){#}{\n}
::DV RPU/XML INFOLINE
if "!DVinput!!DVBIN!"=="YESYES" "!Cecho!" {%_YELLOW%}RPU               {%HC_WHITE%}: Reference Processing Unit Binary ({%HC_GREEN%}}Dolby Vision Profile !DVprofile!!DM!{%HC_WHITE%}){#}{\n}
::NO_DV
if "!DVinput!!DVBIN!"=="NONO" "!Cecho!" {%_YELLOW%}Video             {%HC_WHITE%}: !CODEC_NAME! ({%HC_GREEN%}!HDRFormat!{%HC_WHITE%}){#}{\n}

::RPU STATUS MESSAGE
if "!RPU_STRING!" NEQ "" "!Cecho!" {%HC_YELLOW%}                    !RPU_STRING!{#}{\n}

::EL LAYER STATUS MESSAGE
if "!EL_INPUT!!DVinput!"=="TRUEYES" "!Cecho!" {%HC_YELLOW%}                    Enhanced Layer needs muxing into HDR10 Base Layer to work correctly.{#}{\n}

::ISO BB STATUS MESSAGE
if "!ISOFILE!"=="TRUE" "!Cecho!" {%HC_YELLOW%}                    When the Blu-ray is mastered with seamless branching, Filesize and Duration{#}{\n}
if "!ISOFILE!"=="TRUE" "!Cecho!" {%HC_YELLOW%}                    of the main movie are not displayed correctly.{#}{\n}

::DV5 NO FALLBACK INFO
if "!DVprofile!"=="5" "!Cecho!" {%HC_YELLOW%}                    No HDR10 Fallback with Dolby Vision Profile 5.{#}{\n}
::BASE LAYER INFO
if "!DVBIN!"=="NO" (
	if "!DVinput!"=="YES" (
		echo.
		%YELLOW%
		echo Base Layer
		%HCWHITE%
		echo Codec             : !CODEC_NAME!
		echo Mastering DCP     : !MDCP!
		echo Mastering DL      : !Luminance!
		echo MaxCLL            : !MaxCLL!
		echo MaxFALL           : !MaxFALL!
	)
)
::RPU INFO

if "!DVinput!!RPU_EXIST!"=="YESTRUE" (
	echo.
	%YELLOW%
	if "!DVBIN!"=="NO" echo RPU
	%HCWHITE%
	echo DM Version        : !DM_FULL!
    echo L1-Mastering DL   : !RPULuminanceL1!
    echo L1-MaxCLL         : !RPUCLL_L1!
    echo L1-MaxFALL        : !RPUFALL_L1!
    echo L2-Trims          : !L2_TRIMS!
	"!Cecho!" {%HC_WHITE%}L5-Active Area    : !L5_STRING!{#}{\n}
    echo L6-Mastering DL   : !RPULuminanceL6!
    echo L6-MaxCLL         : !RPUCLL_L6!
	echo L6-MaxFALL        : !RPUFALL_L6!
	if defined L9_FOUND echo L9-Mastering DCP  : !L9MDP!
)
::MEDIAINFO
if "!DVBIN!"=="NO" (
	if defined RESOLUTION (
		echo.
		"!Cecho!" {%_YELLOW%}Resolution        {%HC_WHITE%}: !RESOLUTION!{#}{\n}
	)
	if defined BITRATE (
		echo.
		"!Cecho!" {%_YELLOW%}Video Bitrate     {%HC_WHITE%}: !BITRATE!{#}{\n}
	)
	if defined STREAMSIZE (
		echo.
		"!Cecho!" {%_YELLOW%}Video Size        {%HC_WHITE%}: !STREAMSIZE!{#}{\n}
	)
	if defined FRAMERATE (
		echo.
		"!Cecho!" {%_YELLOW%}Framerate         {%HC_WHITE%}: !FRAMERATE!{#}{\n}
	)
	if defined AUDIO_COUNT (
		echo.
		"!Cecho!" {%_YELLOW%}Audio             {%HC_WHITE%}: !AUDIO_COUNT!{#}{\n}
	)
	if defined TEXT_COUNT (
		echo.
		"!Cecho!" {%_YELLOW%}Subtitles         {%HC_WHITE%}: !TEXT_COUNT!{#}{\n}
	)
)
echo.
%WHITE%
echo  ========================================================================================================================
%HCGREEN%
echo.
echo Finished^^!
goto :eof

:OUTPUT_msgBOX
if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
set "NewLine=[System.Environment]::NewLine"
if "!EL_INPUT!!DVinput!!DVP7!!DVBIN!"=="FALSEYESYESNO" set "Line1=BL ^(!HDRFormat!^) ^+ EL ^(Dolby Vision Profile 7!LAYERTYPE!^ !subprofile!^) ^+ RPU ^(!DM:~2!^)"
if "!EL_INPUT!!DVinput!!DVP7!!DVBIN!"=="FALSEYESNONO" set "Line1=BL ^(!HDRFormat!^) ^+ RPU ^(Dolby Vision Profile !DVprofile!!DM!^)"
if "!EL_INPUT!!DVinput!"=="TRUEYES" set "Line1=EL ^(Dolby Vision Profile 7 ^[!subprofile!^]^) ^+ RPU ^(!DM:~2!^)                              EL NEEDS MUXING INTO HDR10 BL TO WORK CORRECTLY"
if "!DVinput!!DVBIN!"=="YESYES" set "Line1=RPU ^(Dolby Vision Profile !DVprofile!!DM!^)"
if "!DVinput!!DVBIN!"=="NONO" set "Line1=!CODEC_NAME! ^(!HDRFormat!^)"
if "!DVinput!"=="YES" set "Line2=DOLBY VISION RPU^^!"
if "!DVBIN!!DVinput!"=="YESNO" call :CORRUPTRPU
if "!DVinput!!DVBIN!"=="YESNO" set "Line2=DOLBY VISION=[ YES ]   |   HDR FALLBACK=[ YES ]"
if "!DVinput!!DVprofile!!DVBIN!"=="YES5NO" set "Line2=DOLBY VISION [ YES ]   |   HDR FALLBACK=[ NO ]"
if "!DVinput!!DVBIN!"=="NONO" set "Line2=DOLBY VISION=[ NO ]"
setlocal DisableDelayedExpansion
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('%FILENAME%%FILEEXT%' + %NewLine% + %NewLine% + '%Line1%' + %NewLine% + %NewLine% + '%Line2%', 'DDVT QuickInfo v%VERSION%', 'Ok','Info')"
exit

:OUTPUT_LOGFILE
if defined L5_FOUND (
	set "L5_STRING=Left: !RPU_INPUT_AA_LC! px, Top: !RPU_INPUT_AA_TC! px, Right: !RPU_INPUT_AA_RC! px, Bottom: !RPU_INPUT_AA_BC! px"
) else (
	if "!DVprofile!"=="8" (
		set "L5_STRING=L5 Metadata not found. L5 Fix recommended [DDVT SyncCheck]."
	) else (
		set "L5_STRING=N/A"
	)
)
echo  DDVT MediaInfo v%VERSION%%>"!TMP_FOLDER!\logfile.txt"
echo.>>"!TMP_FOLDER!\logfile.txt"
echo                                         ====================================>>"!TMP_FOLDER!\logfile.txt"
echo                                              Dolby Vision Tool MEDIAINFO>>"!TMP_FOLDER!\logfile.txt"
echo                                         ====================================>>"!TMP_FOLDER!\logfile.txt"
echo.>>"!TMP_FOLDER!\logfile.txt"
echo.>>"!TMP_FOLDER!\logfile.txt"
echo  == LOGFILE START =======================================================================================================>>"!TMP_FOLDER!\logfile.txt"
echo.>>"!TMP_FOLDER!\logfile.txt"
echo Filename          : !FILENAME!!FILEEXT!>>"!TMP_FOLDER!\logfile.txt"
if defined FILESIZE (
	echo.>>"!TMP_FOLDER!\logfile.txt"
	echo Filesize          : !FILESIZE!>>"!TMP_FOLDER!\logfile.txt"
)
if defined DURATION (
	echo.>>"!TMP_FOLDER!\logfile.txt"
	echo Duration          : !DURATION!>>"!TMP_FOLDER!\logfile.txt"
)
echo.>>"!TMP_FOLDER!\logfile.txt"
::DV P7 INFOLINE
if "!DVinput!!DVP7!!DVBIN!"=="YESYESNO" echo Video             ^: Base Layer ^(!HDRFormat!^) ^+ Enhanced Layer ^(Dolby Vision Profile 7!LAYERTYPE! ^[!subprofile!^]^) ^+ RPU ^(!DM:~2!^)>>"!TMP_FOLDER!\logfile.txt"
::DV P5/P8 INFOLINE
if "!DVinput!!DVP7!!DVBIN!"=="YESNONO" echo Video             ^: Base Layer ^(!HDRFormat!^) ^+ RPU ^(Dolby Vision Profile !DVprofile!!DM!^)>>"!TMP_FOLDER!\logfile.txt"
::EL INFOLINE
if "!EL_INPUT!!DVinput!"=="TRUEYES" echo Video             ^: Enhanced Layer ^(Dolby Vision Profile 7 ^[!subprofile!^]^) ^+ RPU ^(!DM:~2!^)>>"!TMP_FOLDER!\logfile.txt"
::DV P7 RPU/XML INFOLINE
if "!DVinput!!DVBIN!"=="YESYES" echo RPU               ^: Reference Processing Unit Binary ^(Dolby Vision Profile !DVprofile!!DM!^)>>"!TMP_FOLDER!\logfile.txt"
::NO_DV
if "!DVinput!!DVBIN!"=="NONO" echo Video             ^: !CODEC_NAME! ^(!HDRFormat!^)>>"!TMP_FOLDER!\logfile.txt"

::RPU STATUS MESSAGE
if "!RPU_STRING!" NEQ "" echo                     !RPU_STRING!>>"!TMP_FOLDER!\logfile.txt"

::EL LAYER STATUS MESSAGE
if "!EL_INPUT!!DVinput!"=="TRUEYES" echo                     Enhanced Layer needs muxing into HDR10 Base Layer to work correctly>>"!TMP_FOLDER!\logfile.txt"

::DV5 NO FALLBACK INFO
if "!DVprofile!"=="5" echo                     ^No ^HDR10 ^Fallback ^with ^Dolby ^Vision ^Profile ^5>>"!TMP_FOLDER!\logfile.txt"

::BASE LAYER INFO
if "!DVBIN!"=="NO" (
	if "!DVinput!"=="YES" (
		echo.>>"!TMP_FOLDER!\logfile.txt"
		echo Base Layer>>"!TMP_FOLDER!\logfile.txt"
		echo Codec             : !CODEC_NAME!>>"!TMP_FOLDER!\logfile.txt"
		echo Mastering DCP     : !MDCP!>>"!TMP_FOLDER!\logfile.txt"
		echo Mastering DL      : !Luminance!>>"!TMP_FOLDER!\logfile.txt"
		echo MaxCLL            : !MaxCLL!>>"!TMP_FOLDER!\logfile.txt"
		echo MaxFALL           : !MaxFALL!>>"!TMP_FOLDER!\logfile.txt"
	)
)

::RPU INFO
if "!DVinput!!RPU_EXIST!"=="YESTRUE" (
	echo.>>"!TMP_FOLDER!\logfile.txt"
	echo RPU>>"!TMP_FOLDER!\logfile.txt"
	echo DM Version        : !DM_FULL!>>"!TMP_FOLDER!\logfile.txt"
    echo L1-Mastering DL   : !RPULuminanceL1!>>"!TMP_FOLDER!\logfile.txt"
    echo L1-MaxCLL         : !RPUCLL_L1!>>"!TMP_FOLDER!\logfile.txt"
    echo L1-MaxFALL        : !RPUFALL_L1!>>"!TMP_FOLDER!\logfile.txt"
    echo L2-Trims          : !L2_TRIMS!>>"!TMP_FOLDER!\logfile.txt"
	echo L5-Active Area    : !L5_STRING!>>"!TMP_FOLDER!\logfile.txt"
    echo L6-Mastering DL   : !RPULuminanceL6!>>"!TMP_FOLDER!\logfile.txt"
    echo L6-MaxCLL         : !RPUCLL_L6!>>"!TMP_FOLDER!\logfile.txt"
	echo L6-MaxFALL        : !RPUFALL_L6!>>"!TMP_FOLDER!\logfile.txt"
	if defined L9_FOUND echo L9-Mastering DCP  : !L9MDP!>>"!TMP_FOLDER!\logfile.txt"
)
::MEDIAINFO
if "!DVBIN!"=="NO" (
	if defined RESOLUTION (
		echo.>>"!TMP_FOLDER!\logfile.txt"
		echo Resolution        : !RESOLUTION!>>"!TMP_FOLDER!\logfile.txt"
	)
	if defined BITRATE (
		echo.>>"!TMP_FOLDER!\logfile.txt"
		echo Video Bitrate     : !BITRATE!>>"!TMP_FOLDER!\logfile.txt"
	)
	if defined STREAMSIZE (
		echo.>>"!TMP_FOLDER!\logfile.txt"
		echo Video Size        : !STREAMSIZE!>>"!TMP_FOLDER!\logfile.txt"
	)
	if defined FRAMERATE (
		echo.>>"!TMP_FOLDER!\logfile.txt"
		echo Framerate         : !FRAMERATE!>>"!TMP_FOLDER!\logfile.txt"
	)
	if "!RAWFILE!!EL_INPUT!!DVBIN!"=="FALSEFALSENO" (
		if defined AUDIO_COUNT (
			echo.>>"!TMP_FOLDER!\logfile.txt"
			echo Audio             : !AUDIO_COUNT!>>"!TMP_FOLDER!\logfile.txt"
		)
		if defined TEXT_COUNT (
			echo.>>"!TMP_FOLDER!\logfile.txt"
			echo Subtitles         : !TEXT_COUNT!>>"!TMP_FOLDER!\logfile.txt"
		)
	)
)
echo.>>"!TMP_FOLDER!\logfile.txt"
echo  == LOGFILE END =========================================================================================================>>"!TMP_FOLDER!\logfile.txt"
goto :eof

:ANALYSESTREAMS
FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=General;%%VideoCount%% "!FILE!""') do set "VIDEO_COUNT=%%A"
if "!VIDEO_COUNT!" NEQ "1" set "LAYERTYPE= DL"
"!FFPROBEpath!" "!FILE!" -show_streams -v 0 -of compact=p=0:nk=1 >"!TMP_FOLDER!\STREAMS.txt"
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

:MOUNT
(
echo $isoImg = "!FILE!"
echo $driveLetter = "!MountDrive!:\"
echo.
echo #Check if elevated
echo ^[Security.Principal.WindowsPrincipal]$user = ^[Security.Principal.WindowsIdentity^]::GetCurrent^(^);
echo $Admin = $user.IsInRole^(^[Security.Principal.WindowsBuiltinRole^]::Administrator^);
echo.
echo if ^($Admin^) 
echo {
echo     Write-Host "Administrator rights granted.";
echo.
echo     Write-Host "Mount ISO file to !MountDrive!:\...";
echo     $diskImg = Mount-DiskImage -ImagePath $isoImg  -NoDriveLetter -PassThru;
echo.
echo     #Write-Host "Get mounted ISO volume";
echo     $volInfo = $diskImg ^| Get-Volume
echo.
echo     #Write-Host "Mount volume with specified drive letter";
echo     mountvol $driveLetter $volInfo.UniqueId
echo.
echo     #Write-Host "Ready";
echo     exit 0;
echo }
echo else
echo {
echo     Write-Error "This script must be executed as Administrator.";
echo     exit 1;
echo }
)>"!TMP_FOLDER!\mount.ps1"
(
echo $isoImg = "!FILE!"
echo $driveLetter = "!MountDrive!:\"
echo.
echo #Check if elevated
echo ^[Security.Principal.WindowsPrincipal]$user = ^[Security.Principal.WindowsIdentity^]::GetCurrent^(^);
echo $Admin = $user.IsInRole^(^[Security.Principal.WindowsBuiltinRole^]::Administrator^);
echo.
echo if ^($Admin^) 
echo {
echo     Write-Host "Dismount ISO file from !MountDrive!:\..."; 
echo     DisMount-DiskImage -ImagePath $isoImg ^| Out-Null
echo.    
echo     #Write-Host "Ready";
echo     exit 0;
echo }
echo else
echo {
echo     Write-Error "This script must be executed as Administrator.";
echo     exit 1;
echo }
)>"!TMP_FOLDER!\dismount.ps1"
powershell.exe -ExecutionPolicy Bypass -File "!TMP_FOLDER!\mount.ps1"
if exist "!MountDrive!:\BDMV\STREAM\*.m2ts" (
	"!Cecho!" {%_CYAN%}[{%HC_GREEN%}Blu-ray structure found^^!{%_CYAN%}]{#}{\n}
	for /f "tokens=*" %%A in ('dir /B /O:S /A:-D "!MountDrive!:\BDMV\STREAM\*.m2ts"') do set "FILE=!MountDrive!:\BDMV\STREAM\%%A"
) else (
	"!Cecho!" {%_CYAN%}[{%HC_RED%}Blu-ray structure not found^^!{%_CYAN%}]{#}{\n}
	powershell.exe -ExecutionPolicy Bypass -File "!TMP_FOLDER!\dismount.ps1"
	goto :FALSEINPUT
)
goto :eof

:CORRUPTVIDEO
if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
set "NewLine=[System.Environment]::NewLine"
set "Line1=NO VIDEO INFORMATIONS FOUND OR CORRUPT INPUT FILE^!"
rmdir /Q /S "!TMP_FOLDER!">nul
setlocal DisableDelayedExpansion
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('%FILENAME%%FILEEXT%' + %NewLine% + %NewLine% + '%Line1%', 'DDVT MediaInfo v%VERSION%', 'Ok','Warning')"
exit

:CORRUPTRPU
if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
set "NewLine=[System.Environment]::NewLine"
set "Line1=CORRUPT DOLBY VISION XML / RPU BINARY FILE^!"
rmdir /Q /S "!TMP_FOLDER!">nul
setlocal DisableDelayedExpansion
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('%FILENAME%%FILEEXT%' + %NewLine% + %NewLine% + '%Line1%', 'DDVT MediaInfo v%VERSION%', 'Ok','Warning')"
exit

:NOMOUNTDRIVE
if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
set "NewLine=[System.Environment]::NewLine"
set "Line1=NO FREE DRIVE LETTER FOR MOUNTING^!"
rmdir /Q /S "!TMP_FOLDER!">nul
setlocal DisableDelayedExpansion
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('%FILENAME%%FILEEXT%' + %NewLine% + %NewLine% + '%Line1%', 'DDVT MediaInfo v%VERSION%', 'Ok','Warning')"
exit

:FALSEINPUT
if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
set "NewLine=[System.Environment]::NewLine"
set "Line1=Unsupported Input File. Supported Files are:"
set "Line2=*.iso (Blu-ray) | *.mkv | *.ts | *.m2ts | *.mp4 | *.bin | *.xml | *.h265 | *.hevc"
setlocal DisableDelayedExpansion
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('%FILENAME%%FILEEXT%' + %NewLine% + %NewLine% + '%Line1%' + %NewLine% + %NewLine% + '%Line2%', 'DDVT MediaInfo v%VERSION%', 'Ok','Info')"
exit

:CORRUPTFILE
if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
START /B https://mega.nz/folder/x9FHlbbK#YQz_XsqcAXfZP2ciLeyyDg
set "NewLine=[System.Environment]::NewLine"
set "Line1=""%MISSINGFILE%""""
set "Line2=Copy the file to the directory or download and extract DDVT_tools.rar"
setlocal DisableDelayedExpansion
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('NEEDED FILE NOT FOUND!' + %NewLine% + %NewLine% + '%Line1%' + %NewLine% + %NewLine% + '%Line2%', 'DDVT MediaInfo v%VERSION%', 'Ok','Error')"
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