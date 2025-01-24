::written by DonaldFaQ, THX to Jamal for the great idea!
@echo off & setlocal
set "TOOLTYPE=TEXT"
if /i "%~2"=="-MSGBOX" set "TOOLTYPE=MSGBOX"
if "%TOOLTYPE%"=="TEXT" (
	mode con cols=125 lines=30
) else (
	mode con cols=122 lines=15
)
FOR /F "delims=" %%A IN ('findstr /C:"VERSION=" "%~dp0DDVT_OPTIONS.cmd"') DO set "VERSION=%%A"
set "VERSION=%VERSION:~13,-1%"

TITLE DDVT MediaInfo [QfG] v%VERSION%

set "TOOLTYPE=TEXT"
if /i "%~2"=="-MSGBOX" set "TOOLTYPE=MSGBOX"

set PasswordChars=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890
set PasswordLength=5
call :CreatePassword Password

for /F "tokens=2,*" %%i IN ('REG QUERY "HKCU\Software\DDVT DETECTOR" /v "LOGFILE"') do set "LOGFILE=%%j">nul 2>&1
cls

set "sfkpath=%~dp0tools\sfk.exe" rem Path to sfk.exe
set "FFMPEGpath=%~dp0tools\ffmpeg.exe" rem Path to ffmpeg.exe
set "FFPROBEpath=%~dp0tools\ffprobe.exe" rem Path to ffprobe.exe
set "MEDIAINFOpath=%~dp0tools\mediainfo.exe" rem Path to mediainfo.exe
set "DO_VI_TOOLpath=%~dp0tools\dovi_tool.exe" rem Path to dovi_tool.exe
set "LOGFILEpath=%~1_DDVT_MediaInfo.txt" rem Path where your logfile will be saved

rem --- Hardcoded settings. Cannot be changed ---
set "LOGFILE=YES"
set "RAWFILE=TRUE"
set "EL_INPUT=FALSE"
set "RPU_EXIST=FALSE"
set "RPU_STRING="
set "TMP_FOLDER=SAME AS SOURCE"
set "MKVTOOLNIX_FOLDER=INCLUDED"
set "LAYERTYPE=SL"
set "Format=HEVC"
set "DVinput=NO"
set "DVBIN=NO"
set "DVP7=NO"
set "RPU="

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
	FOR /F "delims=" %%A IN ('findstr /C:"MKVTOOLNIX Folder=" "%~dp0DDVT_OPTIONS.ini"') DO (
		set "MKVTOOLNIX_FOLDER=%%A"
		set "MKVTOOLNIX_FOLDER=!MKVTOOLNIX_FOLDER:~18!"
	)
	FOR /F "delims=" %%A IN ('findstr /C:"MEDIAINFO_LOGFILE=" "%~dp0DDVT_OPTIONS.ini"') DO (
		set "LOGFILE=%%A"
		set "LOGFILE=!LOGFILE:~18!"
	)
)

if "%TMP_FOLDER%"=="SAME AS SOURCE" (
	set "TMP_FOLDER=%tmp%\DDVT_%Password%_TMP"
) else (
	set "TMP_FOLDER=!TMP_FOLDER!\DDVT_%Password%_TMP"
)
if "!MKVTOOLNIX_FOLDER!"=="INCLUDED" set "MKVTOOLNIX_FOLDER=%~dp0tools"
set "MKVMERGEpath=!MKVTOOLNIX_FOLDER!\mkvmerge.exe"

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

::CHECK FILETYPE
if "!FILEEXT!"=="" goto :NOINPUT
if "!FILEEXT!"==".mkv" set "RAWFILE=FALSE" & goto :PREPARE
if "!FILEEXT!"==".ts"  goto :PREPARE
if "!FILEEXT!"==".m2ts" goto :PREPARE
if "!FILEEXT!"==".mp4" goto :PREPARE
if "!FILEEXT!"==".bin" set "RAWFILE=FALSE" & goto :PREPARE
if "!FILEEXT!"==".xml" set "RAWFILE=FALSE" & goto :PREPARE
if "!FILEEXT!"==".h265" goto :PREPARE
if "!FILEEXT!"==".hevc" goto :PREPARE
call :FALSEINPUT

:PREPARE
cls
%GREEN%
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG
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

::WRITE MEDIAINFO
rem "!MEDIAINFOpath!" --full --Output=JSON "!FILE!">"!TMP_FOLDER!\mediainfo.json"
echo.
set "MI_INFOVIDEO=!FILE!"
set "BL_INFOVIDEO=!FILE!"
FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=General;%%VideoCount%% "!FILE!""') do set "VIDEO_COUNT=%%A"
if "!VIDEO_COUNT!" NEQ "1" set "RAWFILE=TRUE"
if "!RAWFILE!"=="TRUE" (
	"!MKVMERGEpath!" --ui-language en --priority higher --output ^"!TMP_FOLDER!\Info.mkv^" --language 0:und --compression 0:none ^"^(^" ^"!FILE!^" ^"^)^" --split parts:00:00:00-00:00:01 -q
	if exist "!TMP_FOLDER!\Info.mkv" (
		set "MI_INFOVIDEO=!TMP_FOLDER!\Info.mkv"
		set "BL_INFOVIDEO=!TMP_FOLDER!\Info.mkv"
	)
	if "!VIDEO_COUNT!" NEQ "1" "!FFMPEGpath!" -loglevel panic -y -i "!FILE!" -map 0:0 -c:v copy -to 1 -bsf:v hevc_metadata -f hevc "!TMP_FOLDER!\BL_Info.mkv"
	if exist "!TMP_FOLDER!\BL_Info.mkv" (
		set "BL_INFOVIDEO=!TMP_FOLDER!\BL_Info.mkv"
	)
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

::DUAL LAYER OPERATION
if "!VIDEO_COUNT!" NEQ "1" (
	set "LAYERTYPE=DL"
	"!FFPROBEpath!" "!FILE!" -show_streams -v 0 -of compact=p=0:nk=1 >"!TMP_FOLDER!\STREAMS.txt"
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
	if exist "!MI_INFOVIDEO!" (
		"!FFMPEGpath!" -loglevel panic -i "!MI_INFOVIDEO!" -c:v copy -to 1 -bsf:v hevc_metadata -f hevc - | "!DO_VI_TOOLpath!" extract-rpu -o "!TMP_FOLDER!\RPU.bin" - >nul 2>&1
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
	if "!RPU_EXIST!"=="FALSE" (
		"!FFMPEGpath!" -loglevel panic -i "!FILE!" !DT! -c:v copy -to 1 -bsf:v hevc_metadata -f hevc - | "!DO_VI_TOOLpath!" extract-rpu -o "!TMP_FOLDER!\RPU.bin" - >nul 2>&1
		if exist "!TMP_FOLDER!\RPU.bin" (
			FOR /F "usebackq" %%A IN ('"!TMP_FOLDER!\RPU.bin"') DO set "RPUSIZE=%%~zA"
			if "!RPUSIZE!" NEQ "0" (
				set "RPU=!TMP_FOLDER!\RPU.bin"
				set "RPU_EXIST=TRUE"
				set "RPU_STRING="
			) else (
				set "RPU_STRING=RPU FOUND BUT CANNOT DEMUXED FROM VIDEO"
				set "RPU_EXIST=FALSE"
			)
		) else (
			set "RPU_STRING=RPU ERROR DURING DEMUXING. DOLBY VISION INFOS DISABLED"
			set "RPU_EXIST=FALSE"
		)
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
FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%Format%%^-%%BitDepth%%Bit^-%%ColorSpace%%^-%%ChromaSubsampling%% "!BL_INFOVIDEO!""') do set "CODEC_NAME=%%A"
if not defined CODEC_NAME set "CODEC_NAME=N/A"
::MAXCll and MAXFall
FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%MaxCLL%% "!BL_INFOVIDEO!""') do set "MaxCLL=%%A"
if not defined MaxCLL set "MaxCLL=N/A"
FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%MaxFALL%% "!BL_INFOVIDEO!""') do set "MaxFALL=%%A"
if not defined MaxFALL set "MaxFALL=N/A"
::HDR METADATA
FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%MasteringDisplay_ColorPrimaries%% "!BL_INFOVIDEO!""') do set "MDCP=%%A"
if not defined MDCP set "MDCP=N/A"
FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%MasteringDisplay_Luminance%% "!BL_INFOVIDEO!""') do set "Luminance=%%A"
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
pause>nul
exit

:OUTPUT_TEXT
mode con cols=125 lines=57
if "!subprofile!"=="FEL" set "subprofile= :colortxt 0A "FEL"
if "!subprofile!"=="MEL" set "subprofile= :colortxt 06 "MEL"
if defined L5_FOUND (
	set "L5_STRING=call :colortxt 0F " Left: !RPU_INPUT_AA_LC! px, Top: !RPU_INPUT_AA_TC! px, Right: !RPU_INPUT_AA_RC! px, Bottom: !RPU_INPUT_AA_BC! px""
) else (
	if "!DVprofile!"=="8" (
		set "L5_STRING=call :colortxt 06 " L5 Metadata not found. L5 Fix recommended [DDVT SyncCheck].""
	) else (
		set "L5_STRING=call :colortxt 0F " N/A""
	)
)
cls
%GREEN%
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG
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
call :colortxt 0E "Filename          " & call :colortxt 0F ": !FILENAME!!FILEEXT!" /n
if defined FILESIZE (
	echo.
	call :colortxt 0E "Filesize          " & call :colortxt 0F ": !FILESIZE!" /n
)
if defined DURATION (
	echo.
	call :colortxt 0E "Duration          " & call :colortxt 0F ": !DURATION!" /n
)
echo.
::DV P7 INFOLINE
if "!EL_INPUT!!DVinput!!DVP7!!DVBIN!"=="FALSEYESYESNO" call :colortxt 0E "Video             " & call :colortxt 0F ": Base Layer (" & call :colortxt 0A "!HDRFormat!" & call :colortxt 0F ") + Enhanced Layer (" & call :colortxt 0A "Dolby Vision Profile 7 " & call :colortxt 0F "[" & call !subprofile! & call :colortxt 0F "]" & call :colortxt 0A " !LAYERTYPE!" & call :colortxt 0F ") + RPU (" & call :colortxt 0A "!DM:~2!" & call :colortxt 0F ")" /n
::DV P5/P8 INFOLINE
if "!EL_INPUT!!DVinput!!DVP7!!DVBIN!"=="FALSEYESNONO" call :colortxt 0E "Video             " & call :colortxt 0F ": Base Layer (" & call :colortxt 0A "!HDRFormat!" & call :colortxt 0F ") + RPU (" & call :colortxt 0A "Dolby Vision Profile !DVprofile!!DM!" & call :colortxt 0F ")" /n
::EL INFOLINE
if "!EL_INPUT!!DVinput!"=="TRUEYES" call :colortxt 0E "Video             " & call :colortxt 0F ": Enhanced Layer (" & call :colortxt 0A "Dolby Vision Profile 7 " & call :colortxt 0F "[" & call !subprofile! & call :colortxt 0F "]" & call :colortxt 0F ") + RPU (" & call :colortxt 0A "!DM:~2!" & call :colortxt 0F ")" /n
::DV RPU/XML INFOLINE
if "!DVinput!!DVBIN!"=="YESYES" call :colortxt 0E "RPU               " & call :colortxt 0F ": Reference Processing Unit Binary (" & call :colortxt 0A "Dolby Vision Profile !DVprofile!!DM!" & call :colortxt 0F ")" /n
::NO_DV
if "!DVinput!!DVBIN!"=="NONO" call :colortxt 0E "Video             " & call :colortxt 0F ": !CODEC_NAME!" & call :colortxt 0F " (" & call :colortxt 0A "!HDRFormat!" & call :colortxt 0F ")" /n

::RPU STATUS MESSAGE
if "!RPU_STRING!" NEQ "" call :colortxt 06 "                    !RPU_STRING!" /n

::EL LAYER STATUS MESSAGE
if "!EL_INPUT!!DVinput!"=="TRUEYES" call :colortxt 06 "                    Enhanced Layer needs muxing into HDR10 Base Layer to work correctly" /n

::DV5 NO FALLBACK INFO
if "!DVprofile!"=="5" (
	call :colortxt 06 "                    No HDR10 Fallback with Dolby Vision Profile 5" /n
)
::BASE LAYER INFO
if "!DVBIN!"=="NO" (
	if "!DVinput!"=="YES" (
		echo.
		%YELLOW%
		echo Base Layer
		%WHITE%
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
	%WHITE%
	echo DM Version        : !DM_FULL!
    echo L1-Mastering DL   : !RPULuminanceL1!
    echo L1-MaxCLL         : !RPUCLL_L1!
    echo L1-MaxFALL        : !RPUFALL_L1!
    echo L2-Trims          : !L2_TRIMS!
	call :colortxt 0F "L5-Active Area    :" & !L5_STRING! /n
    echo L6-Mastering DL   : !RPULuminanceL6!
    echo L6-MaxCLL         : !RPUCLL_L6!
	echo L6-MaxFALL        : !RPUFALL_L6!
	if defined L9_FOUND echo L9-Mastering DCP  : !L9MDP!
)
::MEDIAINFO
if "!DVBIN!"=="NO" (
	if defined RESOLUTION (
		echo.
		call :colortxt 0E "Resolution        " & call :colortxt 0F ": !RESOLUTION!" /n
	)
	if defined BITRATE (
		echo.
		call :colortxt 0E "Video Bitrate     " & call :colortxt 0F ": !BITRATE!" /n
	)
	if defined STREAMSIZE (
		echo.
		call :colortxt 0E "Video Size        " & call :colortxt 0F ": !STREAMSIZE!" /n
	)
	if defined FRAMERATE (
		echo.
		call :colortxt 0E "Framerate         " & call :colortxt 0F ": !FRAMERATE!" /n
	)
	if defined AUDIO_COUNT (
		echo.
		call :colortxt 0E "Audio             " & call :colortxt 0F ": !AUDIO_COUNT!" /n
	)
	if defined TEXT_COUNT (
		echo.
		call :colortxt 0E "Subtitles         " & call :colortxt 0F ": !TEXT_COUNT!" /n
	)
)

echo.
echo  ========================================================================================================================
%GREEN%
echo.
echo Finish^^!
goto :eof

:OUTPUT_msgBOX
if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
set "NewLine=[System.Environment]::NewLine"
if "!EL_INPUT!!DVinput!!DVP7!!DVBIN!"=="FALSEYESYESNO" set "Line1=BL ^(!HDRFormat!^) ^+ EL ^(Dolby Vision Profile 7 ^[!subprofile!^] !LAYERTYPE!^) ^+ RPU ^(!DM:~2!^)"
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
if "!DL!"=="TRUE" set "LAYERTYPE=DL"
if defined L5_FOUND (
	set "L5_STRING=Left: !RPU_INPUT_AA_LC! px, Top: !RPU_INPUT_AA_TC! px, Right: !RPU_INPUT_AA_RC! px, Bottom: !RPU_INPUT_AA_BC! px"
) else (
	if "!DVprofile!"=="8" (
		set "L5_STRING=L5 Metadata not found. L5 Fix recommended [DDVT SyncCheck]."
	) else (
		set "L5_STRING=N/A"
	)
)
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG>"!TMP_FOLDER!\logfile.txt"
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
if "!DVinput!!DVP7!!DVBIN!"=="YESYESNO" echo Video             ^: Base Layer ^(!HDRFormat!^) ^+ Enhanced Layer ^(Dolby Vision Profile 7 ^[!subprofile!^] !LAYERTYPE!^) ^+ RPU ^(!DM:~2!^)>>"!TMP_FOLDER!\logfile.txt"
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

:CORRUPTVIDEO
if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
set "NewLine=[System.Environment]::NewLine"
set "Line1=NO VIDEO INFORMATIONS FOUND OR CORRUPT INPUT FILE^!"
rmdir /Q /S "!TMP_FOLDER!">nul
setlocal DisableDelayedExpansion
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('%FILENAME%%FILEEXT%' + %NewLine% + %NewLine% + '%Line1%', 'DDVT MediaInfo [QfG] v%VERSION%', 'Ok','Warning')"
exit

:CORRUPTRPU
if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
set "NewLine=[System.Environment]::NewLine"
set "Line1=CORRUPT DOLBY VISION XML / RPU BINARY FILE^!"
rmdir /Q /S "!TMP_FOLDER!">nul
setlocal DisableDelayedExpansion
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('%FILENAME%%FILEEXT%' + %NewLine% + %NewLine% + '%Line1%', 'DDVT MediaInfo [QfG] v%VERSION%', 'Ok','Warning')"
exit

:FALSEINPUT
if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
set "NewLine=[System.Environment]::NewLine"
set "Line1=Unsupported Input File. Supported Files are:"
set "Line2=*.mkv | *.ts | *.m2ts | *.mp4 | *.bin | *.xml | *.h265 | *.hevc"
setlocal DisableDelayedExpansion
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('%FILENAME%%FILEEXT%' + %NewLine% + %NewLine% + '%Line1%' + %NewLine% + %NewLine% + '%Line2%', 'DDVT MediaInfo [QfG] v%VERSION%', 'Ok','Info')"
exit

:NOINPUT
cls
%GREEN%
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool MEDIAINFO
%WHITE%
echo                                         ====================================
echo.
echo.
echo  == CHECK INPUT FILE ====================================================================================================
%YELLOW%
echo.
echo No Input File. Use^:
echo.
echo DDVT_MEDIAINFO.cmd "YourFilename.mkv/ts/m2ts/mp4/bin/xml/hevc/h265"
echo.
echo or use for simple Dolby Vision check^:
echo.
echo DDVT_MEDIAINFO.cmd "YourFilename.mkv/ts/m2ts/mp4/bin/xml/hevc/h265" -MSGBOX
echo.
%WHITE%
echo  ========================================================================================================================
setlocal DisableDelayedExpansion
TIMEOUT 30
exit

:CORRUPTFILE
if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
set "NewLine=[System.Environment]::NewLine"
set "Line1=""%MISSINGFILE%""""
set "Line2=Copy the file to the directory or reinstall DDVT v%VERSION%."
setlocal DisableDelayedExpansion
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('NEEDED FILE NOT FOUND!' + %NewLine% + %NewLine% + '%Line1%' + %NewLine% + %NewLine% + '%Line2%', 'DDVT MediaInfo [QfG] v%VERSION%', 'Ok','Error')"
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
::The single blank line within the following IN() clause is critical - DO NOT REMOVE
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