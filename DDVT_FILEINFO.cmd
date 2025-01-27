@echo off & setlocal
mode con cols=125 lines=40
FOR /F "tokens=2 delims==" %%A IN ('findstr /C:"VERSION=" "%~dp0DDVT_OPTIONS.cmd"') DO set "VERSION=%%A"
TITLE DDVT FileInfo [QfG] v%VERSION%

set PasswordChars=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890
set PasswordLength=5
call :CreatePassword Password

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
set "HDR10PFILE=%~dp1HDR10Plus.json"

rem --- Hardcoded settings. Can be changed manually ---
set "DVPLOT=YES"
:: YES / NO - Plot L1 Metadata from RPU to PNG file.
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
set "HDR_HDR=FALSE"
set "HDR_HDR10P=FALSE"
set "HDR_DV=FALSE"
set "RAW_FILE=FALSE"
set "RPU_FILE=FALSE"
set "ELFILE=FALSE"
set "HDR_Info=No HDR Infos found"
set "RESOLUTION=n.A."
set "HDR=n.A."
set "CODEC_NAME=n.A."
set "FRAMERATE=n.A."
set "FRAMES=n.A."
set "BORDERCHECK=FALSE"
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
)

if not exist "!LAVFILTERS_FOLDER!\x64\LAVSplitter.ax" set HDR10PLOT=NO
if "%TMP_FOLDER%"=="SAME AS SOURCE" (
	set "TMP_FOLDER=%~dp1DDVT_%Password%_TMP"
) else (
	set "TMP_FOLDER=!TMP_FOLDER!\DDVT_%Password%_TMP"
)
if "!MKVTOOLNIX_FOLDER!"=="INCLUDED" set "MKVTOOLNIX_FOLDER=%~dp0tools"
set "MKVMERGEpath=!MKVTOOLNIX_FOLDER!\mkvmerge.exe"

if not exist "%sfkpath%" set "MISSINGFILE=%sfkpath%" & goto :CORRUPTFILE
if not exist "%FFMPEGpath%" set "MISSINGFILE=%FFMPEGpath%" & goto :CORRUPTFILE
if not exist "%FFPROBEpath%" set "MISSINGFILE=%FFPROBEpath%" & goto :CORRUPTFILE
if not exist "%MKVMERGEpath%" set "MISSINGFILE=%MKVMERGEpath%" & goto :CORRUPTFILE
if not exist "%MADVRpath%" set "MISSINGFILE=%MADVRpath%" & goto :CORRUPTFILE
if not exist "%JQpath%" set "MISSINGFILE=%JQpath%" & goto :CORRUPTFILE
if not exist "%IMAGEMAGICKpath%" set "MISSINGFILE=%IMAGEMAGICKpath%" & goto :CORRUPTFILE
if not exist "%MP4BOXpath%" set "MISSINGFILE=%MP4BOXpath%" & goto :CORRUPTFILE
if not exist "%MEDIAINFOpath%" set "MISSINGFILE=%MEDIAINFOpath%" & goto :CORRUPTFILE
if not exist "%PYTHONpath%" set "MISSINGFILE=%PYTHONpath%" & goto :CORRUPTFILE
if not exist "%DO_VI_TOOLpath%" set "MISSINGFILE=%DO_VI_TOOLpath%" & goto :CORRUPTFILE
if not exist "%DO_VI_TOOLNFpath%" set "MISSINGFILE=%DO_VI_TOOLNFpath%" & goto :CORRUPTFILE
if not exist "%HDR10P_TOOLpath%" set "MISSINGFILE=%HDR10P_TOOLpath%" & goto :CORRUPTFILE

if /i "%~x1"==".mkv" set "MKVExtract=TRUE" & goto :CHECK
if /i "%~x1"==".mp4" set "MP4Extract=TRUE" & goto :CHECK
if /i "%~x1"==".h265" set "RAW_FILE=TRUE" & goto :CHECK
if /i "%~x1"==".hevc" set "RAW_FILE=TRUE" & goto :CHECK
if /i "%~x1"==".bin" set "RPU_FILE=TRUE" & set "RPUFILE=%~1" & goto :CHECK

if not "!INPUTFILE!"=="" goto :FALSEINPUT

:CHECK
CLS
%GREEN%
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool FILEINFO
%WHITE%
echo                                         ====================================
echo.
%WHITE%
echo.
echo.
echo  == CHECK INPUT FILE ====================================================================================================
if "%~1"=="" (
	%yellow%
	echo.
	echo No Input File. Use DDVT_FRAMEINFO.cmd "YourFilename.mkv/mp4/hevc/h265/bin"
	%WHITE%
	echo.
	goto :EXIT
)
FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=General;%%VideoCount%% "!INPUTFILE!""') do set "VIDEO_COUNT=%%A"
if "!RPU_FILE!"=="FALSE" (
	if "!VIDEO_COUNT!" NEQ "1" (
		%YELLOW%
		echo.
		echo No Support for Dual Layer Container^^!
		%WHITE%
		echo.
		goto :EXIT
	)
)
if not exist "!TMP_FOLDER!" md "!TMP_FOLDER!"
echo.
%CYAN%
if "%RPU_FILE%"=="FALSE" (
	echo Analysing File. Please wait...
	echo.
	set "INPUTSTREAM=!INPUTFILE!"
	set "INFOSTREAM=!INPUTFILE!"
	FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=General;%%VideoCount%% "!INFOSTREAM!""') do set "VIDEO_COUNT=%%A"
	if "!RAW_FILE!!VIDEO_COUNT!"=="TRUE1" (
		"!MKVMERGEpath!" --ui-language en --priority higher --output ^"!TMP_FOLDER!\Info.mkv^" --language 0:und --compression 0:none ^"^(^" ^"!INPUTFILE!^" ^"^)^" --split parts:00:00:00-00:00:01 -q
		if exist "!TMP_FOLDER!\Info.mkv" set "INFOSTREAM=!TMP_FOLDER!\Info.mkv"
	)
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
	::MAXCll and MAXFall
	FOR /F "tokens=1 delims= " %%A in ('""!MEDIAINFOpath!" --output=Video;%%MaxCLL%% "!INFOSTREAM!""') do set "MaxCLL=%%A"
	if not defined MaxCLL set "MaxCLL=0"
	FOR /F "tokens=1 delims= " %%A in ('""!MEDIAINFOpath!" --output=Video;%%MaxFALL%% "!INFOSTREAM!""') do set "MaxFALL=%%A"
	if not defined MaxFALL set "MaxFALL=0"
	::HDR METADATA
	FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%MasteringDisplay_ColorPrimaries%% "!INFOSTREAM!""') do set "MDCP=%%A"
	if not defined MDCP set "MDCP=N/A"
	FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%MasteringDisplay_Luminance%% "!INFOSTREAM!""') do set "Luminance=%%A"
	if not defined Luminance (
		set "MinDML=50"
		set "MaxDML=1000"
	) else (
		for /F "tokens=2" %%A in ("!Luminance!") do set MinDML=%%A
		for /F "tokens=* delims=0." %%A in ("!MinDML!") do set "MinDML=%%A"
		for /F "tokens=5" %%A in ("!Luminance!") do set MaxDML=%%A
	)
	FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%FrameCount%% "!INPUTSTREAM!""') do set "FRAMES=%%A"
	if "!VIDEO_COUNT!"=="2" set "FRAMES=N/A DL"
	if "!HDRFormat!"=="HDR10" (
		set "HDR_HDR=TRUE"
		set "PHDR=HDR10"
		%GREEN%
		echo HDR10 found.
	)
	if "!HDRFormat!"=="HLG" (
		set "HDR_HDR=TRUE"
		set "PHDR=HLG"		
		%GREEN%
		echo HLG found.
	)
	if "!HDRFormat!"=="HDR10+" (
		set "HDR_HDR=TRUE"
		set "HDR_HDR10P=TRUE"
		set "PHDR=HDR10"
		%GREEN%
		echo HDR10+ SEI found.
	)
	if "!DVprofile!"=="8" (
		set "HDR_HDR=TRUE"
		set "HDR_DV=TRUE"
		set "HDR_DV_Profile=8"
		%GREEN%
		echo Dolby Vision Profile 8 found.
	)
	if "!DVprofile!"=="7" (
		set "HDR_HDR=TRUE"
		set "HDR_DV=TRUE"
		set "HDR_DV_Profile=7"
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
		set "HDR_DV_Profile=7!subprofile!!LAYERTYPE!"
	)
	if "!DVprofile!"=="5" (
		set "HDR_HDR=FALSE"
		set "HDR_DV=TRUE"
		set "HDR_DV_Profile=5"
		%GREEN%
		echo Dolby Vision Profile 5 found.
	)
	if "!DVprofile!"=="4" (
		set "HDR_HDR=TRUE"
		set "HDR_DV=TRUE"
		set "HDR_DV_Profile=4"
		%GREEN%
		echo Dolby Vision Profile 4 found.
	)
	%GREEN%
	if exist "!TMP_FOLDER!\Info.mkv" del "!TMP_FOLDER!\Info.mkv">nul
	if exist "!TMP_FOLDER!\BL.mkv" del "!TMP_FOLDER!\BL.mkv">nul
	if exist "!TMP_FOLDER!\RPU.bin" del "!TMP_FOLDER!\RPU.bin">nul
	if "!HDR_HDR!"=="TRUE" set "HDR_Info=!HDRFormat!"
	if "!HDR_HDR10P!"=="TRUE" set "HDR_Info=HDR10, !HDRFormat!"
	if "!HDR_DV!"=="TRUE" set "HDR_Info=Dolby Vision Profile !DV_Profile!"	
	if "!HDR_HDR!!HDR_DV!"=="TRUETRUE" set "HDR_Info=!HDRFormat!, Dolby Vision Profile !HDR_DV_Profile!"
	if "!HDR_HDR10P!!HDR_DV!"=="TRUETRUE" set "HDR_Info=HDR10, !HDRFormat!, Dolby Vision Profile !HDR_DV_Profile!"

	if exist "!TMP_FOLDER!\Info.txt" del "!TMP_FOLDER!\Info.txt">nul
	if exist "!TMP_FOLDER!\Info.mkv" del "!TMP_FOLDER!\Info.mkv">nul
) else (
	%CYAN%
	echo Analysing DV RPU. Please wait...
	echo.
	"!DO_VI_TOOLpath!" info -i "!RPUFILE!" -s>"!TMP_FOLDER!\RPUINFO.txt"
	if exist "!TMP_FOLDER!\RPUINFO.txt" (
		%GREEN%
		set "HDR_DV=TRUE"
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
		echo Done.
	) else (
		%YELLOW%
		echo Error.
		goto :EXIT
	)
)

if "!RPU_FILE!!HDR_HDR!!HDR_DV!"=="FALSEFALSEFALSE" (
	echo.
	%YELLOW%
	echo No HDR / DV found in videostream.
	echo Script works only with HDR / DV Content.
	echo.
	%GREEN%
	echo Analysing complete.
	echo.
	goto :EXIT
) else (
	echo.
	%GREEN%
	echo Analysing complete.
	echo.
)

if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
TIMEOUT 3 /NOBREAK>nul
if /i "%~2"=="-CHECK" goto :DV8CHK

:START
if "!HDR_HDR!"=="FALSE" set "HDR10PLOT=NO"
if "!HDR_DV!"=="FALSE" set "DVPLOT=NO
if "!HDR_DV!"=="FALSE" set "FRAME=NONE
if "!HDR_HDR10P!"=="FALSE" set "HDR10PPLOT=NO
if "!RPU_FILE!"=="TRUE" set "MEDIAINFOFILE=NO
if "!RPU_FILE!"=="TRUE" set "HDR10PPLOT=NO
if "!RPU_FILE!"=="TRUE" set "VBITRATEPLOT=NO
if "!RAW_FILE!"=="TRUE" set "VBITRATEPLOT=NO
if "!BORDERCHECK!"=="FALSE" set "BC_INFO=& call :colortxt 06 "NOT CHECKED""
if "!BORDERCHECK!"=="TRUE" set "BC_INFO=& call :colortxt 0A "CHECKED""
if exist "!INPUTFILENAME!_[RPU BORDERS FIXED]!INPUTFILEEXT!" set "BC_INFO=& call :colortxt 0A "FIXED FILE FOUND IN DIR""
cls
%GREEN%
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG
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
if "!RPU_FILE!!RAW_FILE!"=="FALSEFALSE" echo 1. Video Bitrate Plotting         : [!VBITRATEPLOT!]
if "!HDR_DV!"=="TRUE" (
	echo 2. DV L1 PNG Plotting             : [!DVPLOT!]
	echo 3. DV Frameinfo                   : [Frame^(s^)^: !FRAME!]
)
if "!HDR_HDR!"=="TRUE" (
	echo 4. HDR10 PNG Plotting             : [!HDR10PLOT!]
)
if "!HDR_HDR10P!"=="TRUE" (
	echo 5. HDR10+ Metadata PNG Plotting   : [!HDR10PPLOT!]
)
if "!RPU_FILE!"=="FALSE" echo 6. Create MediaInfo File          : [!MEDIAINFOFILE!]
echo.
if "!HDR_DV_Profile!"=="8" call :colortxt 0F "C. CHECK RPU CROPPING VALUES" & call :colortxt 0E "*" & call :colortxt 0F "     : [" !BC_INFO! & call :colortxt 0F "]" & call :colortxt 0E " *Check and Fix wrong cropped Releases" /n
echo.
echo S. START
echo.
%GREEN%
echo Change Settings and press [S] to start^^!
CHOICE /C 123456CS /N /M "Select a Letter 1,2,3,4,5,6,C,[S]tart"

if "%ERRORLEVEL%"=="8" goto :OPERATION
if "!HDR_DV_Profile!%ERRORLEVEL%"=="87" call :DV8CHK
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
	if "%DVPLOT%"=="NO" set "DVPLOT=YES"
	if "%DVPLOT%"=="YES" set "DVPLOT=NO"
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
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool FILEINFO
%WHITE%
echo                                         ====================================
echo.
echo.
set "VIDEOSTREAM=!INPUTFILE!"
if "!RPU_FILE!!RAW_FILE!"=="FALSEFALSE" call :DEMUX
if "!VBITRATEPLOT!"=="YES" call :BITRATE_PLOTTING
if "!HDR10PLOT!"=="YES" call :HDR10_PLOTPNG
if "!RPU_FILE!!HDR_DV!"=="FALSETRUE" call :RPU_EXTRACT
if "!DVPLOT!"=="YES" call :DV_PLOTPNG
if "!FRAME!" NEQ "NONE" call :WRITE_DV_FRAMEINFO
if "!HDR_HDR10P!!HDR10PPLOT!"=="TRUEYES" call :HDR10P_EXTRACT
if "!HDR10PPLOT!"=="YES" call :HDR10Plus_PLOTPNG
if "!MEDIAINFOFILE!"=="YES" call :C_MEDIAINFO
goto :EXIT

:DEMUX
if "!DVPLOT!!HDR10PPLOT!!MEDIAINFOFILE!!FRAME!"=="NONONONONE" goto :eof
%WHITE%
echo  == DEMUXING ============================================================================================================
echo.
%YELLOW%
echo ATTENTION^^! You need a lot of HDD Space for this operation.
echo.
%WHITE%
"!FFMPEGpath!" -loglevel panic -stats -i "!INPUTFILE!" -c:v copy -bsf:v hevc_metadata -f hevc "!TMP_FOLDER!\temp.hevc"
if exist "!TMP_FOLDER!\temp.hevc" (
	set "VIDEOSTREAM=!TMP_FOLDER!\temp.hevc"
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
if "!DVPLOT!!FRAME!"=="NONONE" goto :eof
%WHITE%
echo  == EXTRACTING RPU ======================================================================================================
echo.
"!DO_VI_TOOLpath!" extract-rpu "!VIDEOSTREAM!" -o "!TMP_FOLDER!\RPU.bin"
if exist "!TMP_FOLDER!\RPU.bin" (
	set "RPUFILE=!TMP_FOLDER!\RPU.bin"
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
	
:HDR10P_EXTRACT
%WHITE%
echo  == EXTRACTING HDR10+ SEI ===============================================================================================
echo.
"!HDR10P_TOOLpath!" extract "!VIDEOSTREAM!" -o "!TMP_FOLDER!\HDR10Plus.json"
if exist "!TMP_FOLDER!\HDR10Plus.json" (
	set "HDR10PFILE=!TMP_FOLDER!\HDR10Plus.json"
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

:BITRATE_PLOTTING
%WHITE%
echo  == PLOTTING VIDEO BITRATE ==============================================================================================
echo.
copy "!FFPROBEpath!" "!INPUTFILEPATH!" >nul
attrib +h "!INPUTFILEPATH!\ffprobe.exe" >nul
%CYAN%
echo Processing. Please wait...
%WHITE%
"!PYTHONpath!" "!PYTHONSCRIPTpath!\plotbitrate.py" -o "!TMP_FOLDER!\!INPUTFILENAME!.png" -f png "!INPUTFILEPATH!!INPUTFILENAME!!INPUTFILEEXT!"
if exist "!TMP_FOLDER!\!INPUTFILENAME!.png" "!IMAGEMAGICKpath!" convert "!TMP_FOLDER!\!INPUTFILENAME!.png" -quality 100 -fill white -stroke none -draw "rectangle 0,0 3000,100" -fill black -font Arial-Bold -pointsize 30 -gravity Center -annotate -0-532 "!INPUTFILENAME!!INPUTFILEEXT!" -font Arial -pointsize 25 -annotate -0-498 "(Video Bitrate Plot)" "!INPUTFILEPATH!!INPUTFILENAME!_[Video Bitrate Plot].png"
if exist "!INPUTFILEPATH!!INPUTFILENAME!_[Video Bitrate Plot].png" (
	%GREEN%
	echo Done.
	attrib -h "!INPUTFILEPATH!\ffprobe.exe" >nul
	del "!INPUTFILEPATH!\ffprobe.exe"
	echo.	
) else (
	%RED%
	echo Error.
	attrib -h "!INPUTFILEPATH!\ffprobe.exe" >nul
	del "!INPUTFILEPATH!\ffprobe.exe" >nul
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	echo.
)
goto :eof

:HDR10_PLOTPNG
:: Credits for this function goes to R3S3t9999. Original tool from R3S3t9999 here: https://github.com/R3S3t9999/DoVi_Scripts
%WHITE%
echo  == PLOTTING HDR10 ======================================================================================================
echo.
set "WORKFILE=!INPUTFILE!"
if "!RAW_FILE!"=="TRUE" (
	%CYAN%
	echo Please wait. Muxing Videostream into Container...
	echo.
	%YELLOW%
	echo Don't close the "Muxing !INPUTFILENAME! into MKV" cmd window.
	start /WAIT /MIN "Muxing !INPUTFILENAME! into MKV" "!MKVMERGEpath!" --ui-language en --priority higher --output ^"!TMP_FOLDER!\VIDEOSTREAM.mkv^" --language 0:und --compression 0:none ^"^(^" ^"!INPUTFILE!^" ^"^)^"
	if exist "!TMP_FOLDER!\VIDEOSTREAM.mkv" (
		set "WORKFILE=!TMP_FOLDER!\VIDEOSTREAM.mkv"
		%GREEN%
		echo Done.
		echo.
	)
)
%CYAN%
echo Processing. Please wait...
%WHITE%
if not exist "!WORKFILE!.measurements" "!MADVRpath!" "!WORKFILE!"
if exist "!WORKFILE!.measurements" (
	set "MFILE=!WORKFILE!.measurements"
) else (
	echo.
	%RED%
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
) > "%~dp0temp.json"

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
		set "RPULuminance=min^: !RPUMinDML! cd^/m2^, max^: !RPUMaxDML! cd^/m2"
	)
)

set "MDL=-annotate +120+130 "Mastering display luminance^: !RPULuminance! ^(!L9MDP!^)""
if "!HDR_HDR10P!"=="TRUE" set "HDR10PINFO= ^| HDR10^+"
if "!DVinput!"=="YES" set "DVINFO= ^| Dolby Vision Profile^: !HDR_DV_Profile!"
set "HDRINFO=-annotate +120+5 "Video: !PHDR!!HDR10PINFO!!DVINFO! ^(!RESOLUTION!^)""

if "!PLOTTYPE!"=="MAX" (
	set "titlepos=-135"
	call :ENHPLOTS
) else (
	set "titlepos=-0"
)

"!IMAGEMAGICKpath!" convert "!TMP_FOLDER!\!INPUTFILENAME!.png" -quality 100 -fill white -stroke none -draw "rectangle 0,0 3000,150" -gravity NorthWest -pointsize 20 -fill black -font Arial-Bold !HDRINFO! -font Arial -annotate +120+30 "Frames: !RPU_FRAMES!, Scenecuts: !RPU_SHOTCOUNT!" -font Arial-Bold -pointsize 25 -gravity Center -annotate !titlepos!-552 "!INPUTFILENAME!!INPUTFILEEXT!" -font Arial -pointsize 25 -annotate !titlepos!-518 "(!PHDR! Plot)" -pointsize 20 -gravity NorthWest !A1! !A2! !A3! !A4! !A5! !P1! !P2! !P3! !P4! !P5! !MDL! -font Arial-Bold !AM! !AA! "!INPUTFILEPATH!!INPUTFILENAME!_[!PHDR! Plot].png"
if exist "!INPUTFILEPATH!!INPUTFILENAME!_[!PHDR! Plot].png" (
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

:DV_PLOTPNG
%WHITE%
echo  == PLOTTING RPU L1 METADATA ============================================================================================
echo.
%CYAN%
echo Processing. Please wait...
%WHITE%
"!DO_VI_TOOLpath!" plot "!RPUFILE!" -t "" -o "!TMP_FOLDER!\!INPUTFILENAME!.png">nul
if "!PLOTTYPE!" NEQ "ORIGINAL" (
	"!DO_VI_TOOLpath!" info --input "!RPUFILE!" -f 1 > "!TMP_FOLDER!\temp.rpu.json"
	"!DO_VI_TOOLpath!" export -i "!RPUFILE!" -o "!TMP_FOLDER!\plot.json">nul
	"!DO_VI_TOOLpath!" info -s "!RPUFILE!" > "!TMP_FOLDER!\RPUINFO.txt"
	if exist "!TMP_FOLDER!\!INPUTFILENAME!.png" (
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
		FOR /F "tokens=2 delims=:" %%A IN ('findstr /C:"L2 trims" "!TMP_FOLDER!\RPUINFO.txt"') DO set "L2_TRIMS=%%A"
		if defined L2_TRIMS (
			set "L2_TRIMS=!L2_TRIMS:~1!"
		) else (
			set "L2_TRIMS=No L2 entries in RPU."
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

	set "RPUINFO=-annotate +120+5 "RPU: Dolby Vision Profile^: !HDR_DV_Profile!, DM Version^: !DM!""
	set "FRAMEINFO=-annotate +120+30 "Frames: !RPU_FRAMES!, Scenecuts: !RPU_SHOTCOUNT!""
	if defined RPUMD set L1=-annotate +120+55 "L1 !RPUMD!"
	if defined L2_TRIMS set "L2=-annotate +120+80 "L2 trims^: !L2_TRIMS!""
	set "L5=-annotate +120+105 "L5 Active area^: !L5_STRING_TXT!""
	if defined L6M set "L6=-annotate +120+130 "!L6M!!L9MDP!""

	if "!PLOTTYPE!"=="MAX" (
		set "titlepos=-135"
		call :ENHPLOTS
	) else (
		set "titlepos=-0"
	)
	if exist "!TMP_FOLDER!\!INPUTFILENAME!.png" "!IMAGEMAGICKpath!" convert "!TMP_FOLDER!\!INPUTFILENAME!.png" -quality 100 -fill white -stroke none -draw "rectangle 0,0 3000,150" -fill black -pointsize 25 -gravity Center -font Arial-Bold -annotate !titlepos!-552 "!INPUTFILENAME!!INPUTFILEEXT!" -pointsize 25 -font Arial -annotate !titlepos!-518 "(Dolby Vision L1 Plot)" -gravity NorthWest -pointsize 20 -font Arial-Bold !RPUINFO! -font Arial !FRAMEINFO! !L1! !L2! !L5! !L6! !A1! !A2! !A3! !A4! !A5! !P1! !P2! !P3! !P4! !P5! -font Arial-Bold !AM! !AA! "!INPUTFILEPATH!!INPUTFILENAME!_[DV L1 Plot].png"
) else (
	if exist "!TMP_FOLDER!\!INPUTFILENAME!.png" "!IMAGEMAGICKpath!" convert "!TMP_FOLDER!\!INPUTFILENAME!.png" -quality 100 -fill black -pointsize 25 -gravity Center -font Arial-Bold -annotate -0-552 "!INPUTFILENAME!!INPUTFILEEXT!" -pointsize 25 -font Arial -annotate -0-518 "(Dolby Vision L1 Plot)" "!INPUTFILEPATH!!INPUTFILENAME!_[DV L1 Plot].png"
)
if exist "!INPUTFILEPATH!!INPUTFILENAME!_[DV L1 Plot].png" (
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

:HDR10Plus_PLOTPNG
%WHITE%
echo  == PLOTTING HDR10+ METADATA ============================================================================================
echo.
pushd "%~dp1"
"!HDR10P_TOOLpath!" plot "!HDR10PFILE!" -t "" -o "!TMP_FOLDER!\!INPUTFILENAME!.png"
popd
if exist "!TMP_FOLDER!\!INPUTFILENAME!.png" "!IMAGEMAGICKpath!" convert "!TMP_FOLDER!\!INPUTFILENAME!.png" -quality 100 -fill black -font Arial-Bold -pointsize 25 -gravity Center -annotate -0-552 "!INPUTFILENAME!!INPUTFILEEXT!" -font Arial -pointsize 25 -annotate -0-518 "(HDR10+ SEI Plot)" "!INPUTFILEPATH!!INPUTFILENAME!_[HDR10+ Plot].png"
if exist "!INPUTFILEPATH!!INPUTFILENAME!_[HDR10+ Plot].png" (
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

:C_MEDIAINFO
%WHITE%
echo  == CREATE MEDIAINFO FILE ===============================================================================================
echo.
"!MEDIAINFOpath!" --output=TXT "!INPUTFILENAME!!INPUTFILEEXT!">"!INPUTFILEPATH!!INPUTFILENAME!_[MediaInfo].txt"
if exist "!INPUTFILEPATH!!INPUTFILENAME!_[MediaInfo].txt" (
	echo Creating txt File...
	%GREEN%
	echo Done.
	echo.
) else (
	echo Creating txt File...
	%RED%
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
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG
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
%YELLOW%
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
echo  == WRITE DV FRAME INFOS ================================================================================================
echo.
if "!Frame!"=="ALL" (
	%WHITE%
	"!DO_VI_TOOLpath!" export -i "!RPUFILE!" -o "!TMP_FOLDER!\info.json"
	"!JQpath!" . "!TMP_FOLDER!\info.json">"!INPUTFILEPATH!!INPUTFILENAME!_[All Frames Info].json"
	if exist "!INPUTFILEPATH!!INPUTFILENAME!_[All Frames Info].json" (
		%GREEN%
		echo !INPUTFILENAME!_[All Frames Info].json Done.
	) else (
		%RED%
		echo !INPUTFILENAME!_[All Frames Info].json Error.
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	)
	%WHITE%
	"!JQpath!" "to_entries | .[] | select(.value.vdr_dm_data.scene_refresh_flag == 1) | .key" "!TMP_FOLDER!\info.json">"!INPUTFILEPATH!!INPUTFILENAME!_[All Scene Cuts].txt"
	if exist "!INPUTFILEPATH!!INPUTFILENAME!_[All Scene Cuts].txt" (
		%GREEN%
		echo !INPUTFILENAME!_[All Scene Cuts].txt Done.
	) else (
		%RED%
		echo !INPUTFILENAME!_[All Scene Cuts].txt Error.
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	)
)
if "!Frame!"=="SCENECUTS" (
	%WHITE%
	"!DO_VI_TOOLpath!" export -i "!RPUFILE!" -d scenes="!INPUTFILEPATH!!INPUTFILENAME!_[All Scene Cuts].txt"
	if exist "!INPUTFILEPATH!!INPUTFILENAME!_[All Scene Cuts].txt" (
		%GREEN%
		echo !INPUTFILENAME!_[All Scene Cuts].txt Done.
	) else (
		%RED%
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
		%GREEN%
		echo !INPUTFILENAME!_[Frame !Frame! Info].json Done.
	) else (
		%RED%
		echo !INPUTFILENAME!_[Frame !Frame! Info].json Error.
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	)
)
if exist "!TMP_FOLDER!\info.json" del "!TMP_FOLDER!\info.json"
echo.
goto :eof

:DV8CHK
if /i "%~2!HDR_DV!"=="-CHECKFALSE" goto :SC_NODV
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
%WHITE%
if "%RAW_FILE%"=="FALSE" (
	echo  == DEMUXING ============================================================================================================
	echo.
	%YELLOW%
	echo ATTENTION^^! You need a lot of HDD Space for this operation.
	echo.
	%CYAN%
	echo Please wait. Extracting Video Layer...
	%WHITE%
	"!FFMPEGpath!" -loglevel panic -stats -i "!INPUTFILE!" -c:v copy -bsf:v hevc_metadata -f hevc "!TMP_FOLDER!\temp.hevc"
	set "VIDEOSTREAM=!TMP_FOLDER!\temp.hevc"
	if exist "!TMP_FOLDER!\temp.hevc" (
		%GREEN%
		echo Done.
		echo.
	) else (
		%RED%
		echo Error.
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
		echo.
	)
) else (
	echo  == MUXING ==============================================================================================================
	echo.
	%YELLOW%
	echo ATTENTION^^! You need a lot of HDD Space for this operation.
	echo.
	%CYAN%
	echo Please wait. Muxing Videostream into Container...
	%YELLOW% 
	echo Don't close the "Muxing into MKV Container" cmd window.
	start /WAIT /MIN "Muxing into MKV Container" "!MKVMERGEpath!" --ui-language en --output ^"!TMP_FOLDER!\temp.mkv^" ^"^(^" ^"!INPUTFILE!^" ^"^)^" --language 0:und --compression 0:none ^"^(^" ^"!CONTAINERSTREAM!^" ^"^)^"
	if exist "!TMP_FOLDER!\temp.mkv" (
		set "CONTAINERSTREAM=!TMP_FOLDER!\temp.mkv"
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
	%GREEN%
	echo Done.
	echo.
) else (
	%YELLOW%
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
	%GREEN%
	echo Done.
	echo.
) else (
	%RED%
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
IF "%AA_LC%%AA_TC%%AA_RC%%AA_BC%"=="%RPU_AA_LC%%RPU_AA_TC%%RPU_AA_RC%%RPU_AA_BC%" (
	set "RPU_AA_String=call :colortxt 0B "Borders = [LEFT=%RPU_AA_LC% px], [TOP=%RPU_AA_TC% px], [RIGHT=%RPU_AA_RC% px], [BOTTOM=%RPU_AA_BC% px] [" & call :colortxt 0A "MATCH WITH VIDEO" & call :colortxt 0B "]" /n"
	set "AA_String=call :colortxt 0B "Borders = [LEFT=%AA_LC% px], [TOP=%AA_TC% px], [RIGHT=%AA_RC% px], [BOTTOM=%AA_BC% px] [" & call :colortxt 0A "MATCH WITH RPU" & call :colortxt 0B "]" /n"
) else (
	set "RPU_AA_String=call :colortxt 0B "Borders = [LEFT=%RPU_AA_LC% px], [TOP=%RPU_AA_TC% px], [RIGHT=%RPU_AA_RC% px], [BOTTOM=%RPU_AA_BC% px] [" & call :colortxt 0C "NOT MATCH WITH VIDEO" & call :colortxt 0B "]" /n"
	set "AA_String=call :colortxt 0B "Borders = [LEFT=%AA_LC% px], [TOP=%AA_TC% px], [RIGHT=%AA_RC% px], [BOTTOM=%AA_BC% px] [" & call :colortxt 0C "NOT MATCH WITH RPU" & call :colortxt 0B "]" /n"
)
IF "%RPU_AA_LC%%RPU_AA_TC%%RPU_AA_RC%%RPU_AA_BC%"=="UndefinedUndefinedUndefinedUndefined" set "RPU_AA_String=call :colortxt 0B "Borders = [" & call :colortxt 0C "BORDERS NOT SET IN RPU" & call :colortxt 0B "]" /n"

IF "!V0_FRAMES!"=="!RPU_FRAMES!" (
	set "FRAMEINFO_VIDEO=call :colortxt 0B "Frames  = [!V0_FRAMES!] [" & call :colortxt 0A "MATCH WITH RPU" & call :colortxt 0B "]" /n"
	set "FRAMEINFO_RPU=call :colortxt 0B "Frames  = [!RPU_FRAMES!] [" & call :colortxt 0A "MATCH WITH VIDEO" & call :colortxt 0B "]" /n"
	set "FRAME_String=call :colortxt 0A "VIDEO AND RPU FRAMECOUNT EQUAL." /n"
) else (
	set "FRAMEINFO_VIDEO=call :colortxt 0B "Frames  = [!V0_FRAMES!] [" & call :colortxt 0C "NOT MATCH WITH RPU" & call :colortxt 0B "]" /n"
	set "FRAMEINFO_RPU=call :colortxt 0B "Frames  = [!RPU_FRAMES!] [" & call :colortxt 0C "NOT MATCH WITH VIDEO" & call :colortxt 0B "]" /n"
	set "FRAME_String=call :colortxt 0C "VIDEO AND RPU FRAMECOUNT NOT EQUAL." /n"
)
cls
%GREEN%
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG
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
	%GREEN%
	echo ALL CROPPING VALUES CORRECT. Press ^[E^] to Exit^^!
) else (
	%RED%
	echo CROPPING VALUES INCORRECT. Press ^[S^] to fix them^^!
)
%WHITE%
echo.
echo  ========================================================================================================================
echo.
echo L. Set LEFT Crop value [%AA_LC% px]
echo T. Set TOP Crop value [%AA_TC% px]
echo R. Set RIGHT Crop value [%AA_RC% px]
echo B. Set BOTTOM Crop value [%AA_BC% px]
echo.
IF "%AA_LC%%AA_TC%%AA_RC%%AA_BC%"=="%RPU_AA_LC%%RPU_AA_TC%%RPU_AA_RC%%RPU_AA_BC%" (
	echo S. SAVE and FIX Release
	%YELLOW%
	echo E. EXIT and do nothing [RECOMMENDED]
) else (
	%YELLOW%
	echo S. SAVE and FIX Release [RECOMMENDED]
	%WHITE%
	echo E. EXIT and do nothing
)
echo.
%GREEN%
echo Change Settings and press [S] to FIX or [E] to EXIT^^!
CHOICE /C LTRBSE /N /M "Select a Letter L,T,R,B,[S]ave,[E]xit"

if "%ERRORLEVEL%"=="6" goto DV8CHKEND
if "%ERRORLEVEL%"=="5" goto DV8CHKFIX
if "%ERRORLEVEL%"=="4" (
	echo.
	%WHITE%
	echo Type in the Pixels, which will be cropped on BOTTOM side.
	echo Example: For cropping 140px on BOTTOM side type "140" and press Enter^^!
	echo.
	set /p "AA_BC=Type in Pixels and press [ENTER]: "
)
if "%ERRORLEVEL%"=="3" (
	echo.
	%WHITE%
	echo Type in the Pixels, which will be cropped on RIGHT side.
	echo Example: For cropping 140px on RIGHT side type "140" and press Enter^^!
	echo.
	set /p "AA_RC=Type in Pixels and press [ENTER]: "
)
if "%ERRORLEVEL%"=="2" (
	echo.
	%WHITE%
	echo Type in the Pixels, which will be cropped on TOP side.
	echo Example: For cropping 140px on TOP side type "140" and press Enter^^!
	echo.
	set /p "AA_TC=Type in Pixels and press [ENTER]: "
)
if "%ERRORLEVEL%"=="1" (
	echo.
	%WHITE%
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
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG
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
	%GREEN%
	echo Done.
	echo.
) else (
	%RED%
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
	%GREEN%
	echo Done.
	echo.
) else (
	%RED%
	echo Error.
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	echo.
)
IF "%RAW_FILE%"=="FALSE" (
	if exist "!VIDEOSTREAM!" (
		del "!VIDEOSTREAM!">nul
		if "%ERRORLEVEL%"=="0" (
			%GREEN%
			echo Deleting Temp File - Done.
			echo.
		) else (
			%RED%
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
	%YELLOW%
	echo Don't close the "Muxing into MKV Container" cmd window.
	start /WAIT /MIN "Muxing into MKV Container" "!MKVMERGEpath!" --ui-language en --output ^"!TARGET_FOLDER!\!INPUTFILENAME!_[RPU BORDERS FIXED].mkv^" --no-video ^"^(^" ^"!INPUTFILE!^" ^"^)^" --language 0:und --compression 0:none !duration! ^"^(^" ^"!TMP_FOLDER!\!INPUTFILENAME!_[RPU BORDERS FIXED].hevc^" ^"^)^" --track-order 1:0
	if exist "!TARGET_FOLDER!\!INPUTFILENAME!_[RPU BORDERS FIXED].mkv" (
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
	echo Please wait. Muxing Videostream into Container...
	%WHITE%
	"!MP4BOXpath!" -rem 1 "!INPUTFILE!" -out "!TMP_FOLDER!\temp.mp4"
	if exist "!TMP_FOLDER!\temp.mp4" (
		%GREEN%
		echo Done.
	) else (
		%RED%
		echo Error.
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	)
	%WHITE%
	"!MP4BOXpath!" -add "!TMP_FOLDER!\!INPUTFILENAME!_[RPU BORDERS FIXED].hevc:ID=1:fps=!FRAMERATE!:name=" "!TMP_FOLDER!\temp.mp4" -out "!TARGET_FOLDER!\!INPUTFILENAME!_[RPU BORDERS FIXED].mp4"
	if exist "!TARGET_FOLDER!\!INPUTFILENAME!_[RPU BORDERS FIXED].mp4" (
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
		%GREEN%
		echo Deleting Temp Folder - Done.
	) else (
		%RED%
		echo Deleting Temp Folder - Error.
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	)
)
if "%ERRORCOUNT%"=="0" (
	%GREEN%
	echo.
	echo All Operations successful.
) else (
	echo.
	%RED%
	echo SOME Operations failed.
)
%WHITE%
TIMEOUT 10
goto :eof

:FIX_SHOTS
if exist "!RPUFILE!" (
	%CYAN%
	echo Fixing Scenecuts...
	(
	echo {
	echo	"scene_cuts": {
	echo		"0-0": true
	echo	}
	echo }
	)>"!TMP_FOLDER!\EDIT.json"
	"!DO_VI_TOOLpath!" editor -i "!RPUFILE!" -j "!TMP_FOLDER!\EDIT.json" -o "!TMP_FOLDER!\RPU-SCFIXED.bin">nul
	if exist "!TMP_FOLDER!\RPU-SCFIXED.bin" (
		%GREEN%
		del "!TMP_FOLDER!\EDIT.json"
		set "RPUFILE=!TMP_FOLDER!\RPU-SCFIXED.bin"
		echo Done.
		echo.
	) else (
		%RED%
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

:NOLAVFILTERS
set "NewLine=[System.Environment]::NewLine"
set "Line1=LAV Filters not set or installed."
set "Line2=Start <DDVT_OPTIONS.cmd> and set correct directory or install LAV Filters."
setlocal DisableDelayedExpansion
START /MIN /WAIT PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('%INPUTFILENAME%%INPUTFILEEXT%' + %NewLine% + %NewLine% + '%Line1%' + %NewLine% + %NewLine% + '%Line2%', 'DDVT FileInfo [QfG] v%VERSION%', 'Ok','Info')"
goto :eof

:FALSEINPUT
if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
set "NewLine=[System.Environment]::NewLine"
set "Line1=Unsupported Input File. Supported Files are:"
set "Line2=*.mkv | *.mp4 | *.h265 | *.hevc | *.bin"
setlocal DisableDelayedExpansion
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('%INPUTFILENAME%%INPUTFILEEXT%' + %NewLine% + %NewLine% + '%Line1%' + %NewLine% + %NewLine% + '%Line2%', 'DDVT FileInfo [QfG] v%VERSION%', 'Ok','Info')"
exit

:CORRUPTFILE
if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
START /B https://mega.nz/folder/x9FHlbbK#YQz_XsqcAXfZP2ciLeyyDg
set "NewLine=[System.Environment]::NewLine"
set "Line1=""%MISSINGFILE%""""
set "Line2=Copy the file to the directory or download and extract DDVT_tools.rar"
setlocal DisableDelayedExpansion
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('NEEDED FILE NOT FOUND!' + %NewLine% + %NewLine% + '%Line1%' + %NewLine% + %NewLine% + '%Line2%', 'DDVT FileInfo [QfG] v%VERSION%', 'Ok','Error')"
exit

:ERROR
if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
set "NewLine=[System.Environment]::NewLine"
set "Line1=%ERRORCOUNT% Error(s) during processing^!
set "Line2=Target file don''t exist or corrupt.
setlocal DisableDelayedExpansion
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('%INPUTFILENAME%%INPUTFILEEXT%' + %NewLine% + %NewLine% + '%Line1%' + %NewLine% + %NewLine% + '%Line2%', 'DDVT FileInfo [QfG] v%VERSION%', 'Ok','Error')"
exit

:SC_NODV
if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
set "NewLine=[System.Environment]::NewLine"
set "Line1=Unsupported Input File.
set "Line2=Only Files with Dolby Vision Content supported.
setlocal DisableDelayedExpansion
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('%INPUTFILENAME%%INPUTFILEEXT%' + %NewLine% + %NewLine% + '%Line1%' + %NewLine% + %NewLine% + '%Line2%', 'DDVT FileInfo [QfG] v%VERSION%', 'Ok','Info')"
exit

:FALSEINPUTCHECK
if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
set "NewLine=[System.Environment]::NewLine"
set "Line1=Unsupported Input File. Supported Files are:"
set "Line2=*.mkv | *.mp4 | *.h265 | *.hevc"
setlocal DisableDelayedExpansion
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('%INPUTFILENAME%%INPUTFILEEXT%' + %NewLine% + %NewLine% + '%Line1%' + %NewLine% + %NewLine% + '%Line2%', 'DDVT SyncCheck [QfG] v%VERSION%', 'Ok','Info')"
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