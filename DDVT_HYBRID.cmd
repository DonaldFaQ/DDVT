@echo off & setlocal
mode con cols=125 lines=35
FOR /F "delims=" %%A IN ('findstr /C:"VERSION=" "%~dp0DDVT_OPTIONS.cmd"') DO set "VERSION=%%A"
set "VERSION=%VERSION:~13,-1%"
TITLE DDVT P8 Hybrid Script [QfG] v%VERSION%

set PasswordChars=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890
set PasswordLength=5
call :CreatePassword Password

set "sfkpath=%~dp0tools\sfk.exe" rem Path to sfk.exe
set "FFMPEGpath=%~dp0tools\ffmpeg.exe" rem Path to ffmpeg.exe
set "MP4BOXpath=%~dp0tools\mp4box.exe" rem Path to mp4box.exe
set "MEDIAINFOpath=%~dp0tools\mediainfo.exe" rem Path to mediainfo.exe
set "DO_VI_TOOLpath=%~dp0tools\dovi_tool.exe" rem Path to dovi_tool.exe
set "HDR10P_TOOLpath=%~dp0tools\HDR10Plus_tool.exe" rem Path to HDR_HDR10Plus_tool.exe
set "PYTHONpath=%~dp0tools\Python\Python.exe" rem Path to PYTHON exe
set "HDR10PDELAYSCRIPTpath=%~dp0tools\Python\Scripts\HDR10Plus_delay.py" rem Path to SCRIPT

rem --- Hardcoded settings. Can be changed manually ---
set "MUXINMKV=YES"
:: YES / NO - Muxing video stream into MKV container if source was MKV container.
set "MUXINMP4=YES"
:: YES / NO - Muxing video stream into MP4 container if source was MP4 container.
set "FIX_SCENECUTS=YES"
:: Set frame 0 scenecut flag in RPU to true. Also can be set in OPTIONS and overwrite this settings.
:: YES / NO

rem --- Hardcoded settings. Cannot be changed ---
set "TMP_FOLDER=SAME AS SOURCE"
set "TARGET_FOLDER=SAME AS SOURCE"
set "MKVTOOLNIX_FOLDER=INCLUDED"
set "HDR_File="
set "DV_File="
set "CM_VERSION=V29"
set "DELAY=0"
set "CHGFPS=NO"
set "CHGHDR_HDR10P=NO"
set "REMHDR_HDR10P=NO"
set "INJRPU=YES"
set "INJ_HDR10P=NO"
set "HDR_File_support=FALSE"
set "DV_File_support=FALSE"
set "RAW_FILE_HDR=FALSE"
set "RAW_FILE_DV=FALSE"
set "MP4Extract_HDR=FALSE"
set "MKVExtract_HDR=FALSE"
set "MP4Extract_DV=FALSE"
set "MKVExtract_DV=FALSE"
set "HDR_Info=No HDR Infos found"
set "HDR_DV=FALSE"
set "HDR_HDR=FALSE"
set "DV_DV=FALSE"
set "HDR_HDR10P=FALSE"
set "DV_HDR10P=FALSE"
set "HDR_INPUT_OK=NO"
set "DV_INPUT_OK=NO"
set "REM_HDR10PString="
set "EXTSTRING="
set "RESOLUTION_HDR=N/A"
set "RESOLUTION_DV=N/A"
set "HDR_Info=N/A"
set "HDR_DV_Profile=N/A"
set "DV_Info=No DV Infos found"
set "DV_DV_Profile=N/A"
set "HDR_ELFILE=FALSE"
set "DV_ELFILE=FALSE"
set "OUTPUT_Info=N/A"
set "CODEC_NAME_HDR=N/A"
set "CODEC_NAME_DV=N/A"
set "FRAMERATE_HDR=N/A"
set "FRAMERATE_DV=N/A"
set "FRAMES_HDR=N/A"
set "FRAMES_DV=N/A"
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
	FOR /F "delims=" %%A IN ('findstr /C:"FIX_SCENECUTS=" "%~dp0DDVT_OPTIONS.ini"') DO (
		set "FIX_SCENECUTS=%%A"
		set "FIX_SCENECUTS=!FIX_SCENECUTS:~14!"
	)
)

if "!MKVTOOLNIX_FOLDER!"=="INCLUDED" set "MKVTOOLNIX_FOLDER=%~dp0tools"
set "MKVMERGEpath=!MKVTOOLNIX_FOLDER!\mkvmerge.exe"

if not exist "%sfkpath%" set "MISSINGFILE=%sfkpath%" & goto :CORRUPTFILE
if not exist "%FFMPEGpath%" set "MISSINGFILE=%FFMPEGpath%" & goto :CORRUPTFILE
if not exist "%MKVMERGEpath%" set "MISSINGFILE=%MKVMERGEpath%" & goto :CORRUPTFILE
if not exist "%MP4BOXpath%" set "MISSINGFILE=%MP4BOXpath%" & goto :CORRUPTFILE
if not exist "%MEDIAINFOpath%" set "MISSINGFILE=%MEDIAINFOpath%" & goto :CORRUPTFILE
if not exist "%DO_VI_TOOLpath%" set "MISSINGFILE=%DO_VI_TOOLpath%" & goto :CORRUPTFILE
if not exist "%HDR10P_TOOLpath%" set "MISSINGFILE=%HDR10P_TOOLpath%" & goto :CORRUPTFILE
if not exist "%PYTHONpath%" set "MISSINGFILE=%PYTHONpath%" & goto :CORRUPTFILE
if not exist "%HDR10PDELAYSCRIPTpath%" set "MISSINGFILE=%HDR10PDELAYSCRIPTpath%" & goto :CORRUPTFILE

:PREPARE_HDR
cls
%GREEN%
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                          Dolby Vision Tool P8 Hybrid Script
%WHITE%
echo                                         ====================================
%WHITE%
echo.
echo.
echo  == INSERT HDR / HDR10+ FILE ============================================================================================
%GREEN%
echo.
echo [Info] If you will convert only HDR10+ Metadata to DV P8, drag 'n' drop here your HDR10+ file and skip the next section 
echo        with ENTER. Also you can remove HDR10+ Metadata from stream.
echo.
%YELLOW%
call :colortxt 0E "Drag 'n' Drop" & call :colortxt 0A " HDR / HDR10+ " & call :colortxt 0E "file here and press ENTER:" /n
%WHITE%
set /p "HDR_File=%~1"
for %%f in (!HDR_File!) do set "HDR_Filefolder=%%~dpf"
for %%f in (!HDR_File!) do set "HDR_Filename=%%~nf"
for %%f in (!HDR_File!) do set "HDR_Fileext=%%~xf"
for %%f in (!HDR_File!) do set "HDR_File=%%~dpnxf"
rem if "%HDR_Fileext%"==".hevc" set "RAW_FILE_HDR=TRUE" & set "HDR_File_support=TRUE"
rem if "%HDR_Fileext%"==".h265" set "RAW_FILE_HDR=TRUE" & set "HDR_File_support=TRUE"
if "%HDR_Fileext%"==".mkv" set "MKVExtract_HDR=TRUE" & set "HDR_File_support=TRUE"
if "%HDR_Fileext%"==".mp4" set "MP4Extract_HDR=TRUE" & set "HDR_File_support=TRUE"

::SET HDR FORMAT
set "HDR_HDR_info=Unknown HDR Format"
"!MEDIAINFOpath!" --output=Video;%%HDR_Format_String%% "!HDR_File!">"%TMP%\Info.txt"
FOR /F "delims=" %%A IN ('findstr /C:"Dolby Vision" "%TMP%\Info.txt"') DO set "HDR_INPUT_OK=YES" & set "HDR_HDR_info=Dolby Vision"
FOR /F "delims=" %%A IN ('findstr /C:"HDR10" "%TMP%\Info.txt"') DO set "HDR_INPUT_OK=YES" & set "HDR_HDR_info=HDR10"
FOR /F "delims=" %%A IN ('findstr /C:"HDR10+" "%TMP%\Info.txt"') DO set "HDR_INPUT_OK=YES" & set "HDR_HDR_info=HDR10+"
FOR /F "delims=" %%A IN ('findstr /C:"dvhe.05" "%TMP%\Info.txt"') DO set "HDR_INPUT_OK=NO" & set "HDR_HDR_info=Dolby Vision"
FOR /F "delims=" %%A IN ('findstr /C:"HLG" "%TMP%\Info.txt"') DO set "HDR_INPUT_OK=YES" & set "HDR_HDR_info=HLG"

::SET DV FORMAT
set "HDR_DV_profile="
"!MEDIAINFOpath!" --output=Video;%%HDR_Format_Profile%% "!HDR_File!">"%TMP%\Info.txt"
FOR /F "delims=" %%A IN ('findstr /C:".08" "%TMP%\Info.txt"') DO set "HDR_INPUT_OK=YES" & set "HDR_DV_profile= Profile 8"
FOR /F "delims=" %%A IN ('findstr /C:".07" "%TMP%\Info.txt"') DO set "HDR_INPUT_OK=YES" & set "HDR_DV_profile= Profile 7"
FOR /F "delims=" %%A IN ('findstr /C:".06" "%TMP%\Info.txt"') DO set "HDR_INPUT_OK=YES" & set "HDR_DV_profile= Profile 6"
FOR /F "delims=" %%A IN ('findstr /C:".05" "%TMP%\Info.txt"') DO set "HDR_INPUT_OK=NO" & set "HDR_DV_profile= Profile 5"
FOR /F "delims=" %%A IN ('findstr /C:".04" "%TMP%\Info.txt"') DO set "HDR_INPUT_OK=YES" & set "HDR_DV_profile= Profile 4"
FOR /F "delims=" %%A IN ('findstr /C:".03" "%TMP%\Info.txt"') DO set "HDR_INPUT_OK=YES" & set "HDR_DV_profile= Profile 3"

FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=General;%%VideoCount%% "!HDR_File!""') do set "VIDEO_COUNT=%%A"

if exist "%TMP%\Info.txt" del "%TMP%\Info.txt">nul

if "!HDR_File_support!"=="FALSE" (
	%YELLOW%
	if "!HDR_File!"=="" (
		echo No HDR10 / HDR10+ file choosen. HDR10 file must be set.
		TIMEOUT 3 /NOBREAK >nul
		goto :PREPARE_HDR
	) else (
		echo.
		echo File not Supported^^! Only MP4^/MKV files supported.
		TIMEOUT 3 /NOBREAK >nul
		goto :PREPARE_HDR
	)
)

if "!VIDEO_COUNT!" NEQ "1" (
	%YELLOW%
	echo.
	echo Only Single Layer files supported.
	TIMEOUT 3 /NOBREAK >nul
	goto :PREPARE_HDR
)

if "!HDR_INPUT_OK!"=="NO" (
	%YELLOW%
	echo.
	echo !HDR_HDR_info!!HDR_DV_profile! file choosen. Not supported as HDR / HDR10+ FILE.
	TIMEOUT 3 /NOBREAK >nul
	goto :PREPARE_HDR
)

if "!TMP_FOLDER!"=="SAME AS SOURCE" (
	set "TMP_FOLDER=!HDR_Filefolder!DDVT_%Password%_TMP"
) else (
	set "TMP_FOLDER=!TMP_FOLDER!\DDVT_%Password%_TMP"
)
if "!TARGET_FOLDER!"=="SAME AS SOURCE" (
	set "TARGET_FOLDER=!HDR_Filefolder!"
	set "TARGET_FOLDER=!TARGET_FOLDER:~0,-1!"
) else (
	set "TARGET_FOLDER=!TARGET_FOLDER!"
)
set "logfile=!TMP_FOLDER!\!HDR_Filename!.log"

:PREPARE_DV
cls
%GREEN%
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                          Dolby Vision Tool P8 Hybrid Script
%WHITE%
echo                                         ====================================
%WHITE%
echo.
echo.
echo  == INSERT DV / HDR10+ FILE =============================================================================================
%GREEN%
echo.
echo [Info] If you choose a HDR10+ file, you can make DV P8 RPU with this Metadata. Also you can mux the HDR10+ Metadata
echo        into HDR file or remove existing HDR10+ Metadata from HDR file.
echo.
%YELLOW%
call :colortxt 0E "Drag 'n' Drop" & call :colortxt 0A " DV / HDR10+ " & call :colortxt 0E "file here and press ENTER:" /n
%WHITE%
set /p "DV_File=%~1"
for %%f in (!DV_File!) do set "DV_Filename=%%~nf"
for %%f in (!DV_File!) do set "DV_Fileext=%%~xf"
for %%f in (!DV_File!) do set "DV_File=%%~dpnxf"
rem if "%DV_Fileext%"==".hevc" set "RAW_FILE_DV=TRUE" & set "DV_File_support=TRUE"
rem if "%DV_Fileext%"==".h265" set "RAW_FILE_DV=TRUE" & set "DV_File_support=TRUE"
if "%DV_Fileext%"==".mkv" set "MKVExtract_DV=TRUE" & set "DV_File_support=TRUE"
if "%DV_Fileext%"==".mp4" set "MP4Extract_DV=TRUE" & set "DV_File_support=TRUE"

::SET HDR FORMAT
set "DV_HDR_info=Unknown HDR Format"
"!MEDIAINFOpath!" --output=Video;%%HDR_Format_String%% "!DV_File!">"%TMP%\Info.txt"
FOR /F "delims=" %%A IN ('findstr /C:"HLG" "%TMP%\Info.txt"') DO set "DV_INPUT_OK=NO" & set "DV_HDR_info=HLG"
FOR /F "delims=" %%A IN ('findstr /C:"HDR10" "%TMP%\Info.txt"') DO set "DV_INPUT_OK=NO" & set "DV_HDR_info=HDR10"
FOR /F "delims=" %%A IN ('findstr /C:"HDR10+" "%TMP%\Info.txt"') DO set "DV_INPUT_OK=YES" & set "DV_HDR_info=HDR10+"
FOR /F "delims=" %%A IN ('findstr /C:"Dolby Vision" "%TMP%\Info.txt"') DO set "DV_INPUT_OK=YES" & set "DV_HDR_info=Dolby Vision"

::SET DV FORMAT
set "DV_DV_profile="
"!MEDIAINFOpath!" --output=Video;%%HDR_Format_Profile%% "!DV_File!">"%TMP%\Info.txt"
FOR /F "delims=" %%A IN ('findstr /C:".08" "%TMP%\Info.txt"') DO set "DV_INPUT_OK=YES" & set "DV_DV_profile= Profile 8"
FOR /F "delims=" %%A IN ('findstr /C:".07" "%TMP%\Info.txt"') DO set "DV_INPUT_OK=YES" & set "DV_DV_profile= Profile 7"
FOR /F "delims=" %%A IN ('findstr /C:".06" "%TMP%\Info.txt"') DO set "DV_INPUT_OK=YES" & set "DV_DV_profile= Profile 6"
FOR /F "delims=" %%A IN ('findstr /C:".05" "%TMP%\Info.txt"') DO set "DV_INPUT_OK=YES" & set "DV_DV_profile= Profile 5"
FOR /F "delims=" %%A IN ('findstr /C:".04" "%TMP%\Info.txt"') DO set "DV_INPUT_OK=YES" & set "DV_DV_profile= Profile 4"
FOR /F "delims=" %%A IN ('findstr /C:".03" "%TMP%\Info.txt"') DO set "DV_INPUT_OK=YES" & set "DV_DV_profile= Profile 3"

FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=General;%%VideoCount%% "!DV_File!""') do set "VIDEO_COUNT=%%A"

if exist "%TMP%\Info.txt" del "%TMP%\Info.txt">nul

if "!DV_File_support!"=="FALSE" (
	%YELLOW%
	if "!DV_File!"=="" (
		echo No DV / HDR10+ file choosen. Disable some functions and continue.
		set "DV_INPUT_OK=YES"
		TIMEOUT 2 /NOBREAK >nul
	) else (
		echo.
		echo File not Supported^^! Only MP4^/MKV files supported.
		TIMEOUT 3 /NOBREAK >nul
		goto :PREPARE_DV
	)
)

if "!VIDEO_COUNT!" NEQ "1" (
	%YELLOW%
	echo.
	echo Only Single Layer files supported.
	TIMEOUT 3 /NOBREAK >nul
	goto :PREPARE_DV
)

if "!DV_INPUT_OK!"=="NO" (
	%YELLOW%
	echo.
	echo !DV_HDR_info!!DV_DV_profile! file choosen. Not supported as DV / HDR10+ FILE.
	TIMEOUT 3 /NOBREAK >nul
	goto :PREPARE_DV
)

if "!HDR_File_support!"=="TRUE" call :HDR_CHECK
if "!DV_File_support!"=="TRUE" call :DV_CHECK

if "%AA_INPUT_LC%%AA_INPUT_TC%%AA_INPUT_RC%%AA_INPUT_BC%"=="%RPU_INPUT_AA_LC%%RPU_INPUT_AA_TC%%RPU_INPUT_AA_RC%%RPU_INPUT_AA_BC%" set "RPU_AA_String=[LEAVE UNTOUCHED]"
if "%AA_INPUT_LC%%AA_INPUT_TC%%AA_INPUT_RC%%AA_INPUT_BC%"=="" set "RPU_AA_String=[LEAVE UNTOUCHED]"

if exist "!TMP_FOLDER!"	RD /S /Q "!TMP_FOLDER!">nul
goto :START

:HDR_CHECK
if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
if not exist "!TMP_FOLDER!" MD "!TMP_FOLDER!">nul
if not exist "!TARGET_FOLDER!" MD "!TARGET_FOLDER!">nul
cls
%GREEN%
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                          Dolby Vision Tool P8 Hybrid Script
%WHITE%
echo                                         ====================================
echo.
echo.
%CYAN%
echo Analysing HDR / HDR10+ File. Please wait...
echo.
set "INPUTSTREAM=!HDR_File!"
set "INFOSTREAM=!HDR_File!"

if "!RAW_FILE_HDR!"=="TRUE" (
	"!MKVMERGEpath!" --ui-language en --priority higher --output ^"!TMP_FOLDER!\Info.mkv^" --language 0:und --compression 0:none ^"^(^" ^"!INPUTFILE!^" ^"^)^" --split parts:00:00:00-00:00:01 -q
	if exist "!TMP_FOLDER!\Info.mkv" set "INFOSTREAM=!TMP_FOLDER!\Info.mkv"
)

::SET HDR FORMAT
"!MEDIAINFOpath!" --output=Video;%%HDR_Format_String%% "!INFOSTREAM!">"!TMP_FOLDER!\Info.txt"
FOR /F "delims=" %%A IN ('findstr /C:"Dolby Vision" "!TMP_FOLDER!\Info.txt"') DO set "HDR_DVInput=YES"
FOR /F "delims=" %%A IN ('findstr /C:"HDR10" "!TMP_FOLDER!\Info.txt"') DO set "HDR_HDRFormat=HDR10"
FOR /F "delims=" %%A IN ('findstr /C:"HDR10+" "!TMP_FOLDER!\Info.txt"') DO set "HDR_HDRFormat=HDR10+"
FOR /F "delims=" %%A IN ('findstr /C:"dvhe.05" "!TMP_FOLDER!\Info.txt"') DO set "HDR_HDRFormat=IPT-PQ-C2"
FOR /F "delims=" %%A IN ('findstr /C:"HLG" "!TMP_FOLDER!\Info.txt"') DO set "HDR_HDRFormat=HLG"

::SET DV FORMAT
"!MEDIAINFOpath!" --output=Video;%%HDR_Format_Profile%% "!INFOSTREAM!">"!TMP_FOLDER!\Info.txt"
FOR /F "delims=" %%A IN ('findstr /C:".08" "!TMP_FOLDER!\Info.txt"') DO set "HDR_DVInput=YES" & set "HDR_DVprofile=8"
FOR /F "delims=" %%A IN ('findstr /C:".07" "!TMP_FOLDER!\Info.txt"') DO set "HDR_DVInput=YES" & set "HDR_DVprofile=7"
FOR /F "delims=" %%A IN ('findstr /C:".06" "!TMP_FOLDER!\Info.txt"') DO set "HDR_DVInput=YES" & set "HDR_DVprofile=6"
FOR /F "delims=" %%A IN ('findstr /C:".05" "!TMP_FOLDER!\Info.txt"') DO set "HDR_DVInput=YES" & set "HDR_DVprofile=5"
FOR /F "delims=" %%A IN ('findstr /C:".04" "!TMP_FOLDER!\Info.txt"') DO set "HDR_DVInput=YES" & set "HDR_DVprofile=4"
FOR /F "delims=" %%A IN ('findstr /C:".03" "!TMP_FOLDER!\Info.txt"') DO set "HDR_DVInput=YES" & set "HDR_DVprofile=3"

if "!HDR_DVInput!"=="YES" "!FFMPEGpath!" -loglevel panic -i "!INFOSTREAM!" -c:v copy -to 1 -bsf:v hevc_metadata -f hevc - | "!DO_VI_TOOLpath!" extract-rpu -o "!TMP_FOLDER!\RPU.bin" - >nul 2>&1
if exist "!TMP_FOLDER!\RPU.bin" set "RPUFILE=!TMP_FOLDER!\RPU.bin"

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
FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%Width%%x%%Height%% "!INFOSTREAM!""') do set "RESOLUTION_HDR=%%A"
FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%Format%%^-%%BitDepth%%Bit^-%%ColorSpace%%^-%%ChromaSubsampling%% "!INFOSTREAM!""') do set "CODEC_NAME_HDR=%%A"
FOR /F "tokens=1,2 delims= " %%A in ('""!MEDIAINFOpath!" --output=Video;%%FrameRate_String%% "!INPUTSTREAM!""') do (
	set "FRAMERATE_HDR=%%A"
	set "FRAMERATE_ORIG_HDR=%%A"
)
FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%FrameCount%% "!INPUTSTREAM!""') do set "FRAMES_HDR=%%A"
FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%MasteringDisplay_ColorPrimaries%% "!INFOSTREAM!""') do set "HDR_MDCP= [MDCP = %%A]"
if "!VIDEO_COUNT!"=="2" set "FRAMES_HDR=N/A DL"
if "!HDR_HDRFormat!"=="HDR10" (
	set "HDR_HDR=TRUE"
	%GREEN%
	echo HDR10 found.
)
if "!HDR_HDRFormat!"=="HLG" (
	set "HDR_HDR=TRUE"
	%GREEN%
	echo HLG found.
)
if "!HDR_HDRFormat!"=="HDR10+" (
	set "HDR_HDR=TRUE"
	set "HDR_HDR10P=TRUE"
	%GREEN%
	echo HDR10+ SEI found.
)
if "!HDR_DVprofile!"=="8" (
	set "HDR_HDR=TRUE"
	set "HDR_DV=TRUE"
	set "HDR_DV_Profile=8"
	%GREEN%
	echo Dolby Vision Profile 8 found.
)
if "!HDR_DVprofile!"=="7" (
	set "HDR_HDR=TRUE"
	set "HDR_DV=TRUE"
	set "HDR_DV_Profile=7"
	if "!RESOLUTION_HDR!"=="1920x1080" set "HDR_ELFILE=TRUE"
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
	if "!HDR_ELFILE!"=="TRUE" set "LAYERTYPE= EL"
	echo Dolby Vision Profile 7!subprofile!!LAYERTYPE! found.
	set "HDR_DV_Profile=7!subprofile!!LAYERTYPE!"
)
if "!HDR_DVprofile!"=="5" (
	set "HDR_HDR=FALSE"
	set "HDR_DV=TRUE"
	set "HDR_DV_Profile=5"
	%GREEN%
	echo Dolby Vision Profile 5 found.
)
if "!HDR_DVprofile!"=="4" (
	set "HDR_HDR=TRUE"
	set "HDR_DV=TRUE"
	set "HDR_DV_Profile=4"
	%GREEN%
	echo Dolby Vision Profile 4 found.
)
	
if "!HDR_HDR!"=="TRUE" set "HDR_Info=!HDR_HDRFormat!"
if "!HDR_HDR10P!"=="TRUE" set "HDR_Info=HDR10, !HDR_HDRFormat!"
if "!HDR_DV!"=="TRUE" set "HDR_Info=Dolby Vision Profile !HDR_DV_Profile!"	
if "!HDR_HDR!!HDR_DV!"=="TRUETRUE" set "HDR_Info=!HDR_HDRFormat!, Dolby Vision Profile !HDR_DV_Profile!"
if "!HDR_HDR10P!!HDR_DV!"=="TRUETRUE" set "HDR_Info=HDR10, !HDR_HDRFormat!, Dolby Vision Profile !HDR_DV_Profile!"

if exist "!TMP_FOLDER!\Info.txt" del "!TMP_FOLDER!\Info.txt">nul
if exist "!TMP_FOLDER!\Info.mkv" del "!TMP_FOLDER!\Info.mkv">nul

if exist "!RPUFILE!" (
	"!DO_VI_TOOLpath!" info --input "!RPUFILE!" -f 1 >"!TMP_FOLDER!\Info.json"
	"!DO_VI_TOOLpath!" info -s "!RPUFILE!">"!TMP_FOLDER!\RPUINFO.txt"
	if exist "!TMP_FOLDER!\Info.json" (
		FOR /F "delims=" %%A IN ('findstr /C:"source_primary_index" "!TMP_FOLDER!\Info.json"') DO set "L9_FOUND=%%A"
		if defined L9_FOUND (
			for /F "tokens=2 delims=:/ " %%A in ("!L9_FOUND!") do set "L9MDP=%%A"
			if "!L9MDP!"=="0" set "HDR_L9MDP= [MDCP = Display P3]"
			if "!L9MDP!"=="2" set "HDR_L9MDP= [MDCP = BT.2020]"
		)
	)
	if exist "!TMP_FOLDER!\RPUINFO.txt" (
	::FIND DM VERSION
		FOR /F "delims=" %%A IN ('findstr /C:"DM version" "!TMP_FOLDER!\RPUINFO.txt"') DO set "HDR_RPU_CMV=%%A"
		if defined HDR_RPU_CMV (
			for /F "tokens=3 delims=:/()" %%A in ("!HDR_RPU_CMV!") do set "HDR_RPU_CMV=%%A"
		) else (
			set "HDR_RPU_CMV=N/A"
		)
	)
)

%GREEN%
echo.
echo Analysing complete.
echo.

if "!RAW_FILE_HDR!"=="FALSE" (
	%CYAN%
	echo Analysing Video Borders. Please wait...
	"%~dp0tools\DetectBorders.exe" --ffmpeg-path="!FFMPEGpath!" --input-file="!INPUTSTREAM!" --log-file="!TMP_FOLDER!\Crop.txt"
	FOR /F "tokens=2-5 delims=(,-)" %%A IN ('TYPE "!TMP_FOLDER!\Crop.txt"') DO (
		set "AA_INPUT_LC=%%A"
		set "AA_INPUT_TC=%%B"
		set "AA_INPUT_RC=%%C"
		set "AA_INPUT_BC=%%D"
		set "RPU_AA_LC=%%A"
		set "RPU_AA_TC=%%B"
		set "RPU_AA_RC=%%C"
		set "RPU_AA_BC=%%D"
	)
	if exist "!TMP_FOLDER!\Crop.txt" (
		del "!TMP_FOLDER!\Crop.txt"
		%GREEN%
		echo Done.
	) else (
		%YELLOW%
		echo Analysing failed.
		set "AA_INPUT_LC="
		set "AA_INPUT_TC="
		set "AA_INPUT_RC="
		set "AA_INPUT_BC="
	)
)

TIMEOUT 3 /NOBREAK>nul
goto :eof

:DV_CHECK
cls
%GREEN%
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                          Dolby Vision Tool P8 Hybrid Script
%WHITE%
echo                                         ====================================
echo.
echo.
%CYAN%
echo Analysing DV / HDR10+ File. Please wait...
echo.
set "INPUTSTREAM=!DV_File!"
set "INFOSTREAM=!DV_File!"

if "!RAW_FILE_DV!"=="TRUE" (
	"!MKVMERGEpath!" --ui-language en --priority higher --output ^"!TMP_FOLDER!\Info.mkv^" --language 0:und --compression 0:none ^"^(^" ^"!INPUTFILE!^" ^"^)^" --split parts:00:00:00-00:00:01 -q
	if exist "!TMP_FOLDER!\Info.mkv" set "INFOSTREAM=!TMP_FOLDER!\Info.mkv"
)

::SET HDR FORMAT
"!MEDIAINFOpath!" --output=Video;%%HDR_Format_String%% "!INFOSTREAM!">"!TMP_FOLDER!\Info.txt"
FOR /F "delims=" %%A IN ('findstr /C:"Dolby Vision" "!TMP_FOLDER!\Info.txt"') DO set "DV_DVInput=YES"
FOR /F "delims=" %%A IN ('findstr /C:"HDR10" "!TMP_FOLDER!\Info.txt"') DO set "DV_HDRFormat=HDR10"
FOR /F "delims=" %%A IN ('findstr /C:"HDR10+" "!TMP_FOLDER!\Info.txt"') DO set "DV_HDRFormat=HDR10+"
FOR /F "delims=" %%A IN ('findstr /C:"dvhe.05" "!TMP_FOLDER!\Info.txt"') DO set "DV_HDRFormat=IPT-PQ-C2"
FOR /F "delims=" %%A IN ('findstr /C:"HLG" "!TMP_FOLDER!\Info.txt"') DO set "DV_HDRFormat=HLG"

::SET DV FORMAT
"!MEDIAINFOpath!" --output=Video;%%HDR_Format_Profile%% "!INFOSTREAM!">"!TMP_FOLDER!\Info.txt"
FOR /F "delims=" %%A IN ('findstr /C:".08" "!TMP_FOLDER!\Info.txt"') DO set "DV_DVInput=YES" & set "DV_DVprofile=8"
FOR /F "delims=" %%A IN ('findstr /C:".07" "!TMP_FOLDER!\Info.txt"') DO set "DV_DVInput=YES" & set "DV_DVprofile=7"
FOR /F "delims=" %%A IN ('findstr /C:".06" "!TMP_FOLDER!\Info.txt"') DO set "DV_DVInput=YES" & set "DV_DVprofile=6"
FOR /F "delims=" %%A IN ('findstr /C:".05" "!TMP_FOLDER!\Info.txt"') DO set "DV_DVInput=YES" & set "DV_DVprofile=5"
FOR /F "delims=" %%A IN ('findstr /C:".04" "!TMP_FOLDER!\Info.txt"') DO set "DV_DVInput=YES" & set "DV_DVprofile=4"
FOR /F "delims=" %%A IN ('findstr /C:".03" "!TMP_FOLDER!\Info.txt"') DO set "DV_DVInput=YES" & set "DV_DVprofile=3"

if "!DV_DVInput!"=="YES" "!FFMPEGpath!" -loglevel panic -i "!INFOSTREAM!" -c:v copy -to 1 -bsf:v hevc_metadata -f hevc - | "!DO_VI_TOOLpath!" extract-rpu -o "!TMP_FOLDER!\RPU.bin" - >nul 2>&1
if exist "!TMP_FOLDER!\RPU.bin" set "RPUFILE=!TMP_FOLDER!\RPU.bin"

::BEGIN MEDIAINFO
FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%Width%%x%%Height%% "!INFOSTREAM!""') do set "RESOLUTION_DV=%%A"
FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%Format%%^-%%BitDepth%%Bit^-%%ColorSpace%%^-%%ChromaSubsampling%% "!INFOSTREAM!""') do set "CODEC_NAME_DV=%%A"
FOR /F "tokens=1,2 delims= " %%A in ('""!MEDIAINFOpath!" --output=Video;%%FrameRate_String%% "!INPUTSTREAM!""') do (
	set "FRAMERATE_DV=%%A"
	set "FRAMERATE_ORIG_DV=%%A"
)
	
FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%FrameCount%% "!INPUTSTREAM!""') do set "FRAMES_DV=%%A"
FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%MasteringDisplay_ColorPrimaries%% "!INFOSTREAM!""') do set "DV_MDCP= [MDCP = %%A]"
if "!DV_HDRFormat!"=="HDR10" (
	set "DV_HDR=TRUE"
	%GREEN%
	echo HDR10 found.
)
if "!DV_HDRFormat!"=="HLG" (
	set "DV_HDR=TRUE"
	%GREEN%
	echo HLG found.
)
if "!DV_HDRFormat!"=="HDR10+" (
	set "DV_HDR=TRUE"
	set "DV_HDR10P=TRUE"
	%GREEN%
	echo HDR10+ SEI found.
)
if "!DV_DVprofile!"=="8" (
	set "DV_HDR=TRUE"
	set "DV_DV=TRUE"
	set "DV_DV_Profile=8"
	%GREEN%
	echo Dolby Vision Profile 8 found.
)
if "!DV_DVprofile!"=="7" (
	set "DV_HDR=TRUE"
	set "DV_DV=TRUE"
	set "DV_DV_Profile=7"
	if "!RESOLUTION_DV!"=="1920x1080" set "DV_ELFILE=TRUE"
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
	if "!DV_ELFILE!"=="TRUE" set "LAYERTYPE= EL"
	echo Dolby Vision Profile 7!subprofile!!LAYERTYPE! found.
	set "DV_DV_Profile=7!subprofile!!LAYERTYPE!"
)
if "!DV_DVprofile!"=="5" (
	set "DV_HDR=FALSE"
	set "DV_DV=TRUE"
	set "DV_DV_Profile=5"
	%GREEN%
	echo Dolby Vision Profile 5 found.
)
if "!DV_DVprofile!"=="4" (
	set "DV_HDR=TRUE"
	set "DV_DV=TRUE"
	set "DV_DV_Profile=4"
	%GREEN%
	echo Dolby Vision Profile 4 found.
)

if "!DV_HDR!"=="TRUE" set "DV_Info=!DV_HDRFormat!"
if "!DV_HDR10P!"=="TRUE" set "DV_Info=HDR10, !DV_HDRFormat!"
if "!DV_DV!"=="TRUE" set "DV_Info=Dolby Vision Profile !DV_DV_Profile!"	
if "!DV_HDR!!DV_DV!"=="TRUETRUE" set "DV_Info=!DV_HDRFormat!, Dolby Vision Profile !DV_DV_Profile!"
if "!DV_HDR10P!!DV_DV!"=="TRUETRUE" set "DV_Info=HDR10, !DV_HDRFormat!, Dolby Vision Profile !DV_DV_Profile!"

if exist "!TMP_FOLDER!\Info.txt" del "!TMP_FOLDER!\Info.txt">nul
if exist "!TMP_FOLDER!\Info.mkv" del "!TMP_FOLDER!\Info.mkv">nul

%GREEN%
echo.
echo Analysing complete.
echo.

if exist "!RPUFILE!" (
	"!DO_VI_TOOLpath!" info --input "!RPUFILE!" -f 1 >"!TMP_FOLDER!\Info.json"
	"!DO_VI_TOOLpath!" info -s "!RPUFILE!">"!TMP_FOLDER!\RPUINFO.txt"
	if exist "!TMP_FOLDER!\Info.json" (
		:: FIND CROPPING VALUES RPU
		FOR /F "tokens=2 delims=:, " %%A IN ('findstr /C:"active_area_left_offset" "!TMP_FOLDER!\Info.json"') DO set "RPU_INPUT_AA_LC=%%A"
		FOR /F "tokens=2 delims=:, " %%A IN ('findstr /C:"active_area_right_offset" "!TMP_FOLDER!\Info.json"') DO set "RPU_INPUT_AA_RC=%%A"
		FOR /F "tokens=2 delims=:, " %%A IN ('findstr /C:"active_area_top_offset" "!TMP_FOLDER!\Info.json"') DO set "RPU_INPUT_AA_TC=%%A"
		FOR /F "tokens=2 delims=:, " %%A IN ('findstr /C:"active_area_bottom_offset" "!TMP_FOLDER!\Info.json"') DO set "RPU_INPUT_AA_BC=%%A"
		FOR /F "delims=" %%A IN ('findstr /C:"source_primary_index" "!TMP_FOLDER!\Info.json"') DO set "L9_FOUND=%%A"
		if defined L9_FOUND (
			for /F "tokens=2 delims=:/ " %%A in ("!L9_FOUND!") do set "L9MDP=%%A"
			if "!L9MDP!"=="0" set "DV_L9MDP= [MDCP = Display P3]"
			if "!L9MDP!"=="2" set "DV_L9MDP= [MDCP = BT.2020]"
		)
	)
	if exist "!TMP_FOLDER!\RPUINFO.txt" (
	::FIND DM VERSION
		FOR /F "delims=" %%A IN ('findstr /C:"DM version" "!TMP_FOLDER!\RPUINFO.txt"') DO set "DV_RPU_CMV=%%A"
		if defined DV_RPU_CMV (
			for /F "tokens=3 delims=:/()" %%A in ("!DV_RPU_CMV!") do set "DV_RPU_CMV=%%A"
		) else (
			set "DV_RPU_CMV=N/A"
		)
	)
)

if "%AA_INPUT_LC%%AA_INPUT_TC%%AA_INPUT_RC%%AA_INPUT_BC%"=="" (
	set "RPU_AA_LC=%RPU_INPUT_AA_LC%"
	set "RPU_AA_TC=%RPU_INPUT_AA_TC%"
	set "RPU_AA_RC=%RPU_INPUT_AA_RC%"
	set "RPU_AA_BC=%RPU_INPUT_AA_BC%"
)

TIMEOUT 3 /NOBREAK>nul
goto :eof

:START
mode con cols=125 lines=50
if "!HDR_HDR!"=="TRUE" set "OUTPUT_Info=HDR10, Dolby Vision Profile 8"
if "!HDR_HDR10P!"=="TRUE" set "OUTPUT_Info=HDR10, HDR10+, Dolby Vision Profile 8"
if "!HDR_HDR!!REMHDR_HDR10P!"=="TRUEYES" set "OUTPUT_Info=HDR10, Dolby Vision Profile 8"
if "!HDR_HDR!!REMHDR_HDR10P!!INJ_HDR10P!"=="TRUENOYES" set "OUTPUT_Info=HDR10, HDR10+, Dolby Vision Profile 8"
if "!HDR_File_support!!DV_File_support!"=="FALSEFALSE" goto :EXIT
if "!HDR_HDR!!HDR_HDR10P!!DV_DV!!DV_HDR10P!!"=="TRUEFALSEFALSEFALSE" (
	%YELLOW%
	echo HDR Stream found, but no HDR10+ Metadata included or a valid DV / HDR10+ File.
	set "HDR_File_support=FALSE"
	%GREEN%
	echo Analysing complete.
	echo.
	goto :EXIT
)
if "!HDR_HDR10P!"=="TRUE" set "INJ_HDR10P=NO"
if "!HDR_DV!!DV_DV!"=="FALSEFALSE" set "CHGHDR_HDR10P=YES" & set "INJRPU=NO"
if "!DV_File_support!!HDR_DV!!HDR_HDR10P!"=="FALSEFALSETRUE" set "CHGHDR_HDR10P=YES" & set "INJRPU=NO"
if "!DV_File_support!!DV_DV!!HDR_HDR10P!!DV_HDR10P!"=="TRUEFALSEFALSETRUE" set "CHGHDR_HDR10P=YES" & set "INJRPU=NO"
if exist "!HDR_RPU!" set "RPUFILE=!HDR_RPU!"
if exist "!DV_RPU!" set "RPUFILE=!DV_RPU!"
if "!HDR_HDR10P!"=="TRUE" set "HDR10PFILE=!HDR_HDR10PFILE!"
if "!HDR_HDR10P!!DV_HDR10P!"=="FALSETRUE" set "HDR10PFILE=!DV_HDR10PFILE!"
set "NAMESTRING=BL+RPU"
if "!INJ_HDR10P!!REMHDR_HDR10P!"=="YESNO" set "NAMESTRING=BL+RPU+HDR10+"
if "!HDR_HDR10P!!REMHDR_HDR10P!"=="TRUENO" set "NAMESTRING=BL+RPU+HDR10+"
::VIDEO LINE
:: VIDEO-INPUT = RPU-INPUT
if "%AA_INPUT_LC%%AA_INPUT_TC%%AA_INPUT_RC%%AA_INPUT_BC%"=="%RPU_INPUT_AA_LC%%RPU_INPUT_AA_TC%%RPU_INPUT_AA_RC%%RPU_INPUT_AA_BC%" (
	set "HEADER_RPU_AA_String=call :colortxt 0B "Borders    = [LEFT=%RPU_INPUT_AA_LC% px], [TOP=%RPU_INPUT_AA_TC% px], [RIGHT=%RPU_INPUT_AA_RC% px], [BOTTOM=%RPU_INPUT_AA_BC% px] [" & call :colortxt 0A "MATCH WITH VIDEO" & call :colortxt 0B "]" /n"
	set "AA_String=call :colortxt 0B "Borders    = [LEFT=%AA_INPUT_LC% px], [TOP=%AA_INPUT_TC% px], [RIGHT=%AA_INPUT_RC% px], [BOTTOM=%AA_INPUT_BC% px] [" & call :colortxt 0A "MATCH WITH INPUT RPU" & call :colortxt 0B "]" /n"
) else (
	set "HEADER_RPU_AA_String=call :colortxt 0B "Borders    = [LEFT=%RPU_INPUT_AA_LC% px], [TOP=%RPU_INPUT_AA_TC% px], [RIGHT=%RPU_INPUT_AA_RC% px], [BOTTOM=%RPU_INPUT_AA_BC% px] [" & call :colortxt 0C "NOT MATCH WITH VIDEO" & call :colortxt 0B "]" /n"
	set "AA_String=call :colortxt 0B "Borders    = [LEFT=%AA_INPUT_LC% px], [TOP=%AA_INPUT_TC% px], [RIGHT=%AA_INPUT_RC% px], [BOTTOM=%AA_INPUT_BC% px] [" & call :colortxt 0C "NOT MATCH WITH INPUT RPU" & call :colortxt 0B "]" /n"
)
::RPU LINE
:: RPU-INPUT = NONE
if "%RPU_INPUT_AA_LC%%RPU_INPUT_AA_TC%%RPU_INPUT_AA_RC%%RPU_INPUT_AA_BC%"=="" set "HEADER_RPU_AA_String=call :colortxt 0B "Borders    = [" & call :colortxt 06 "BORDERS NOT SET IN RPU" & call :colortxt 0B "]" /n"	
::OUTPUT_LINE
set "HEADER_RPU_OUTPUT_String=call :colortxt 0E "Borders    = [LEFT=!RPU_AA_LC! px], [TOP=!RPU_AA_TC! px], [RIGHT=!RPU_AA_RC! px], [BOTTOM=!RPU_AA_BC! px] [" & call :colortxt 0C "NOT MATCH WITH VIDEO" & call :colortxt 0E "]" /n"
:: RPU-OUTPUT = VIDEO-INPUT
if "%RPU_AA_LC%%RPU_AA_TC%%RPU_AA_RC%%RPU_AA_BC%"=="%AA_INPUT_LC%%AA_INPUT_TC%%AA_INPUT_RC%%AA_INPUT_BC%" (
	set "HEADER_RPU_OUTPUT_String=call :colortxt 0E "Borders    = [LEFT=!RPU_AA_LC! px], [TOP=!RPU_AA_TC! px], [RIGHT=!RPU_AA_RC! px], [BOTTOM=!RPU_AA_BC! px] [" & call :colortxt 0A "MATCH WITH VIDEO" & call :colortxt 0E "]" /n"
	set "AA_String=call :colortxt 0B "Borders    = [LEFT=%AA_INPUT_LC% px], [TOP=%AA_INPUT_TC% px], [RIGHT=%AA_INPUT_RC% px], [BOTTOM=%AA_INPUT_BC% px] [" & call :colortxt 0A "MATCH WITH OUTPUT" & call :colortxt 0B "]" /n"
) else (
	set "HEADER_RPU_OUTPUT_String=call :colortxt 0E "Borders    = [LEFT=!RPU_AA_LC! px], [TOP=!RPU_AA_TC! px], [RIGHT=!RPU_AA_RC! px], [BOTTOM=!RPU_AA_BC! px] [" & call :colortxt 0C "NOT MATCH WITH VIDEO" & call :colortxt 0E "]" /n"
	set "AA_String=call :colortxt 0B "Borders    = [LEFT=%AA_INPUT_LC% px], [TOP=%AA_INPUT_TC% px], [RIGHT=%AA_INPUT_RC% px], [BOTTOM=%AA_INPUT_BC% px] [" & call :colortxt 0C "NOT MATCH WITH OUTPUT" & call :colortxt 0B "]" /n"
)
::OUTPUT LINE
:: VIDEO-INPUT = NONE
if "%AA_INPUT_LC%%AA_INPUT_TC%%AA_INPUT_RC%%AA_INPUT_BC%"=="" (
	set "AA_String=call :colortxt 0B "Borders    = [" & call :colortxt 06 "NOT FOUND. MUX FILE IN CONTAINER OR SET CROPPING VALUES MANUALLY" & call :colortxt 0B "]" /n"
	if "%RPU_INPUT_AA_LC%%RPU_INPUT_AA_TC%%RPU_INPUT_AA_RC%%RPU_INPUT_AA_BC%"=="" (
		set "HEADER_RPU_AA_String=call :colortxt 0B "Borders    = [" & call :colortxt 06 "BORDERS NOT SET IN RPU" & call :colortxt 0B "]" /n"	
	) else (
		set "HEADER_RPU_AA_String=call :colortxt 0B "Borders    = [LEFT=%RPU_INPUT_AA_LC% px], [TOP=%RPU_INPUT_AA_TC% px], [RIGHT=%RPU_INPUT_AA_RC% px], [BOTTOM=%RPU_INPUT_AA_BC% px] [" & call :colortxt 06 "VIDEO BORDERS NOT FOUND" & call :colortxt 0B "]" /n"
	)
	set "HEADER_RPU_OUTPUT_String=call :colortxt 0E "Borders    = [LEFT=!RPU_AA_LC! px], [TOP=!RPU_AA_TC! px], [RIGHT=!RPU_AA_RC! px], [BOTTOM=!RPU_AA_BC! px] [" & call :colortxt 06 "VIDEO BORDERS NOT FOUND" & call :colortxt 0E "]" /n"
)
set "HEADER_RPU_AA_String_RPU=call :colortxt 0B "Borders    = [LEFT=%RPU_INPUT_AA_LC% px], [TOP=%RPU_INPUT_AA_TC% px], [RIGHT=%RPU_INPUT_AA_RC% px], [BOTTOM=%RPU_INPUT_AA_BC% px]" /n"	
set "HEADER_RPU_OUTPUT_String_RPU=call :colortxt 0E "Borders    = [LEFT=!RPU_AA_LC! px], [TOP=!RPU_AA_TC! px], [RIGHT=!RPU_AA_RC! px], [BOTTOM=!RPU_AA_BC! px]" /n"
if "!RPU_AA_String!"=="[LEAVE UNTOUCHED]" (
	if "%AA_INPUT_LC%%AA_INPUT_TC%%AA_INPUT_RC%%AA_INPUT_BC%"=="%RPU_INPUT_AA_LC%%RPU_INPUT_AA_TC%%RPU_INPUT_AA_RC%%RPU_INPUT_AA_BC%" (
		set "HEADER_RPU_OUTPUT_String=call :colortxt 0E "Borders    = [" & call :colortxt 0A "LEAVE UNTOUCHED" & call :colortxt 0E "]" /n"
	) else (
		set "HEADER_RPU_OUTPUT_String=call :colortxt 0E "Borders    = [" & call :colortxt 0C "LEAVE UNTOUCHED" & call :colortxt 0E "]" /n"
	)
	if "%RPU_INPUT_AA_LC%%RPU_INPUT_AA_TC%%RPU_INPUT_AA_RC%%RPU_INPUT_AA_BC%"=="" set "HEADER_RPU_OUTPUT_String=call :colortxt 0E "Borders    = [" & call :colortxt 06 "LEAVE UNTOUCHED" & call :colortxt 0E "]" /n"
	if "%AA_INPUT_LC%%AA_INPUT_TC%%AA_INPUT_RC%%AA_INPUT_BC%"=="" set "HEADER_RPU_OUTPUT_String=call :colortxt 0E "Borders    = [" & call :colortxt 06 "LEAVE UNTOUCHED" & call :colortxt 0E "]" /n"
)
cls
%GREEN%
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                          Dolby Vision Tool P8 Hybrid Script
%WHITE%
echo                                         ====================================
echo.
if "!HDR_File_support!"=="TRUE" (
	%WHITE%
	echo.
	echo  == HDR / HDR10+ INPUT ==================================================================================================
	echo.
	%CYAN%
	echo Filename   = [!HDR_Filename!!HDR_Fileext!]
	echo Video Info = [Resolution = !RESOLUTION_HDR!] [Codec = !CODEC_NAME_HDR!] [Frames = !FRAMES_HDR!] [FPS = !FRAMERATE_ORIG_HDR!]
	echo HDR Info   = [!HDR_Info!]!HDR_MDCP!
	if "!HDR_DV!"=="TRUE" echo RPU Info   = [Dolby Vision Profile !HDR_DV_Profile!] [DM = !HDR_RPU_CMV!]!HDR_L9MDP!
	%AA_String%
)
	
if "!DV_File_support!"=="TRUE" (
	echo.
	%WHITE%
	echo  == DV / HDR10+ INPUT ===================================================================================================
	echo.
	%CYAN%
	echo Filename   = [!DV_Filename!!DV_Fileext!]
	echo Video Info = [Resolution = !RESOLUTION_DV!] [Codec = !CODEC_NAME_DV!] [Frames = !FRAMES_DV!] [FPS = !FRAMERATE_ORIG_DV!]
	echo HDR Info   = [!DV_Info!]!DV_MDCP!
	if "!DV_DV!"=="TRUE" (
		echo RPU Info   = [Dolby Vision Profile !DV_DV_Profile!] [DM = !DV_RPU_CMV!]!DV_L9MDP!
		%HEADER_RPU_AA_String%
	)
)
%WHITE%
echo.
echo  == OUTPUT ==============================================================================================================
echo.
%YELLOW%
if "!MUXINMKV!"=="YES" (
	echo Filename   = [!HDR_Filename!_[!NAMESTRING!]!HDR_Fileext!]
) else (
	echo Filename   = [!HDR_Filename!_[!NAMESTRING!].hevc]
)
echo Video Info = [Resolution = !RESOLUTION_HDR!] [Codec = !CODEC_NAME_HDR!] [Frames = !FRAMES_HDR!] [FPS = !FRAMERATE_HDR!]
echo HDR Info   = [!OUTPUT_Info!]
%HEADER_RPU_OUTPUT_String%
echo.
%WHITE%
echo  ========================================================================================================================
echo.
echo 1. Delay                : [!DELAY! FRAMES]
echo 2. Change FPS           : [!CHGFPS!]
if "!DV_HDR10P!!DV_DV!"=="TRUETRUE" call :colortxt 0F "3. Convert HDR10+ to DV : [!CHGHDR_HDR10P!]" & call :colortxt 0E "*" & call :colortxt 0E "   *Choose [YES] for injecting converted HDR10+ Metadata instead RPU." /n
if "!HDR_HDR10P!"=="TRUE" echo 4. Remove HDR10+        : [!REMHDR_HDR10P!]
if "!DV_HDR10P!!HDR_HDR10P!"=="TRUEFALSE" echo 4. Also inject HDR10+   : [!INJ_HDR10P!]
if "%MKVExtract_HDR%"=="TRUE" echo 5. MUX STREAM IN MKV    : [!MUXINMKV!]
if "%MP4Extract_HDR%"=="TRUE" echo 5. MUX STREAM IN MP4    : [!MUXINMP4!]
echo.
call :colortxt 0F "E. EDIT ACTIVE AREA" & call :colortxt 0E "*" & call :colortxt 0E "   *Setting Crop Values. DISCARD set Borders to [" & call :colortxt 0F "LEAVE UNTOUCHED" & call :colortxt 0E "]." /n
%WHITE%
echo.
echo S. START
echo.
%GREEN%
echo Change Settings and press [E] for exit or [S] to start processing^^!
CHOICE /C 12345ES /N /M "Select a Letter"

if "%ERRORLEVEL%"=="7" goto OPERATION
if "%ERRORLEVEL%"=="6" call :AA_AREA
if "%ERRORLEVEL%"=="5" (
	if "%MUXINMP4%"=="NO" set "MUXINMP4=YES"
	if "%MUXINMP4%"=="YES" set "MUXINMP4=NO"
	if "%MUXINMKV%"=="NO" set "MUXINMKV=YES"
	if "%MUXINMKV%"=="YES" set "MUXINMKV=NO"
)
if "%ERRORLEVEL%"=="4" (
	if "!HDR_HDR10P!"=="TRUE" (
		if "%REMHDR_HDR10P%"=="NO" set "REMHDR_HDR10P=YES"
		if "%REMHDR_HDR10P%"=="YES" set "REMHDR_HDR10P=NO"
	)
	if "!DV_HDR10P!!HDR_HDR10P!"=="TRUEFALSE" (
		if "%INJ_HDR10P%"=="NO" set "INJ_HDR10P=YES"
		if "%INJ_HDR10P%"=="YES" set "INJ_HDR10P=NO"
	)		
)
if "%ERRORLEVEL%"=="3" (
	if "!HDR_HDR10P!"=="TRUE" (
		if "%CHGHDR_HDR10P%"=="NO" set "CHGHDR_HDR10P=YES"
		if "%CHGHDR_HDR10P%"=="YES" set "CHGHDR_HDR10P=NO"
		if "%CHGHDR_HDR10P%"=="NO" set "INJRPU=YES"
		if "%CHGHDR_HDR10P%"=="YES" set "INJRPU=NO"
	)
	if "!DV_HDR10P!"=="TRUE" (
		if "%CHGHDR_HDR10P%"=="NO" set "CHGHDR_HDR10P=YES"
		if "%CHGHDR_HDR10P%"=="YES" set "CHGHDR_HDR10P=NO"
		if "%CHGHDR_HDR10P%"=="NO" set "INJRPU=YES"
		if "%CHGHDR_HDR10P%"=="YES" set "INJRPU=NO"
	)
)
if "%ERRORLEVEL%"=="2" (
	if "%CHGFPS%"=="NO" set "CHGFPS=23.976" & set "FRAMERATE_HDR=23.976"
	if "%CHGFPS%"=="23.976" set "CHGFPS=24.000" & set "FRAMERATE_HDR=24.000"
	if "%CHGFPS%"=="24.000" set "CHGFPS=25.000" & set "FRAMERATE_HDR=25.000"
	if "%CHGFPS%"=="25.000" set "CHGFPS=NO" & set "FRAMERATE_HDR=!FRAMERATE_ORIG_HDR!"
)
if "%ERRORLEVEL%"=="1" (
	echo.
	%WHITE%
	echo Type in the DELAY, which will be added.
	echo Importend^^! Set "-" for negative Delay.
	echo Example: For cutting 3 Frames type "-3" and press Enter^^!
	echo.
	set /p "DELAY=Type in the Frames and press [ENTER]: "
)
goto START

:OPERATION
if not exist "!TMP_FOLDER!" MD "!TMP_FOLDER!">nul
rem -------- LOGFILE ------------
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG>"!logfile!"
echo.>>"!logfile!"
echo                                         ====================================>>"!logfile!"
echo                                          Dolby Vision Tool P8 Hybrid Script>>"!logfile!"
echo                                         ====================================>>"!logfile!"
echo.>>"!logfile!"
echo.>>"!logfile!"
echo  == LOGFILE START =======================================================================================================>>"!logfile!"
echo.>>"!logfile!"
echo %date%  %time%>>"!logfile!"
echo.>>"!logfile!"
mode con cols=125 lines=65
cls
%GREEN%
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                          Dolby Vision Tool P8 Hybrid Script
echo                                              - DOLBY VISION INJECTOR -
%WHITE%
echo                                         ====================================
echo.
echo.
echo  == OPERATION ===========================================================================================================
call :HDR_EXTRACT
call :DV_EXTRACT
if exist "!HDR_HDR10PFILE!" set "HDR10PFILE=!HDR_HDR10PFILE!"
if exist "!DV_HDR10PFILE!" set "HDR10PFILE=!DV_HDR10PFILE!"
if "!CHGFPS!" NEQ "NO" call :FPS_CHANGE
if "!CHGHDR_HDR10P!"=="YES" call :CONVERT_HDR10P
if "!INJ_HDR10P!"=="YES" (
	call :HDR10P_DELAY
	call :HDR10PINJECT
)
if "!DELAY!" NEQ "0" call :DV_DELAY
if "!RPU_AA_String!" NEQ "[LEAVE UNTOUCHED]" call :CROPRPU
if "!FIX_SCENECUTS!"=="YES" call :FIX_SHOTS
call :DV_INJECT
call :MUXINCONT
call :LOGFILEEND
goto :EXIT

:HDR_EXTRACT
echo.
%CYAN%
echo Please wait. Extracting Video Layer...
echo [Extracting Video Layer]>>"!logfile!"
%YELLOW%
echo ATTENTION^^! You need a lot of HDD Space for this operation.
echo.
%WHITE%
"!FFMPEGpath!" -loglevel panic -stats -i "!HDR_File!" -c:v copy -bsf:v hevc_metadata -f hevc "!TMP_FOLDER!\HDR.hevc"
if exist "!TMP_FOLDER!\HDR.hevc" (
	set "HDR_VIDEOSTREAM=!TMP_FOLDER!\HDR.hevc"
	%GREEN%
	echo Done.
	echo.
	echo Done.>>"!logfile!"
	echo.>>"!logfile!"
) else (
	%RED%
	echo Error.
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	echo.
	echo Error.>>"!logfile!"
	echo.>>"!logfile!"
)

if "!HDR_HDR10P!!CHGHDR_HDR10P!"=="TRUEYES" (
	%CYAN%
	echo Please wait. Extracting HDR10+ SEI...
	echo [Extracting HDR10+ SEI]>>"!logfile!"
	%WHITE%
	"!HDR10P_TOOLpath!" extract "!HDR_VIDEOSTREAM!" -o "!TMP_FOLDER!\HDR_HDR10Plus.json"
	if exist "!TMP_FOLDER!\HDR_HDR10Plus.json" (
		%GREEN%
		set "HDR_HDR10PFILE=!TMP_FOLDER!\HDR_HDR10Plus.json"
		echo Done.
		echo.
		echo Done.>>"!logfile!"
		echo.>>"!logfile!"	
	) else (
		%RED%
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"		
		echo Error.
		echo.
		echo Error.>>"!logfile!"
		echo.>>"!logfile!"
	)
)
goto :eof

:DV_EXTRACT
set "CONVERTswitch=2"
if "!DV_DVprofile!"=="5" set "CONVERTswitch=3"
if "!HDR_HDR_info!"=="HLG" set "CONVERTswitch=4"

if "!DV_DV!"=="TRUE" (
	%CYAN%
	echo Please wait. Extracting Dolby Vision Metadata...
	echo [Extracting Dolby Vision Metadata]>>"!logfile!"
	%WHITE%
	"!FFMPEGpath!" -loglevel panic -stats -i "!INFOSTREAM!" -c:v copy -bsf:v hevc_metadata -f hevc - | "!DO_VI_TOOLpath!" -m !CONVERTswitch! extract-rpu -o "!TMP_FOLDER!\RPU.bin" -
	if exist "!TMP_FOLDER!\RPU.bin" (
		%GREEN%
		set "RPUFILE=!TMP_FOLDER!\RPU.bin"
		echo Done.
		echo.
		echo Done.>>"!logfile!"
		echo.>>"!logfile!"
	) else (
		%RED%
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"		
		echo Error.
		echo.
		echo Error.>>"!logfile!"
		echo.>>"!logfile!"
	)
)

if "!DV_HDR10P!"=="TRUE" (
	if "!INJ_HDR10P!!CHGHDR_HDR10P!" NEQ "NONO" (
		%CYAN%
		echo Please wait. Extracting HDR10+ SEI...
		echo [Extracting HDR10+ SEI]>>"!logfile!"
		%WHITE%
		"!FFMPEGpath!" -loglevel panic -stats -i "!DV_File!" -c:v copy -bsf:v hevc_metadata -f hevc - | "!HDR10P_TOOLpath!" extract -o "!TMP_FOLDER!\DV_HDR10Plus.json" -
		if exist "!TMP_FOLDER!\DV_HDR10Plus.json" (
			%GREEN%
			set "DV_HDR10PFILE=!TMP_FOLDER!\DV_HDR10Plus.json"
			echo Done.
			echo.
			echo Done.>>"!logfile!"
			echo.>>"!logfile!"
		) else (
			%RED%
			echo Error.
			set /a "ERRORCOUNT=!ERRORCOUNT!+1"
			echo.
			echo Error.>>"!logfile!"
			echo.>>"!logfile!"
		)
	)
)
goto :eof

:HDR10P_DELAY
%CYAN%
echo "!DELAY!" | find "-">nul 2>&1
if "%ERRORLEVEL%"=="0" (
	echo Please wait. Applying HDR10+ !DELAY! Frames negative Delay...
	echo [Applying HDR10+ !DELAY! Frames negative Delay]>>"!logfile!"
	%WHITE%
	"!PYTHONpath!" "!HDR10PDELAYSCRIPTpath!" -i "!HDR10PFILE!" -d !DELAY! -o "!TMP_FOLDER!\HDR10PlusDELAYED.json">>"!logfile!"
) else (
	echo Please wait. Applying HDR10+ !DELAY! Frames positive Delay...
	echo [Applying HDR10+ !DELAY! Frames positive Delay]>>"!logfile!"
	%WHITE%
	"!PYTHONpath!" "!HDR10PDELAYSCRIPTpath!" -i "!HDR10PFILE!" -d !DELAY! -o "!TMP_FOLDER!\HDR10PlusDELAYED.json">>"!logfile!"
)
if exist "!TMP_FOLDER!\HDR10PlusDELAYED.json" (
	%GREEN%
	set "HDR10PFILE=!TMP_FOLDER!\HDR10PlusDELAYED.json"
	echo Done.
	echo.
	echo Done.>>"!logfile!"
	echo.>>"!logfile!"
) else (
	%RED%
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"	
	echo Error.
	echo.
	echo Error.>>"!logfile!"
	echo.>>"!logfile!"
)
goto :eof

:HDR10PINJECT
%CYAN%
if "!INJ_HDR10P!"=="NO" goto :eof
echo Please wait. Injecting the HDR10+ Metadata into stream...
echo [Injecting the HDR10+ Metadata into stream]>>"!logfile!"
%WHITE%
"!HDR10P_TOOLpath!" inject -i "!HDR_VIDEOSTREAM!" -j "!HDR10PFILE!" -o "!TMP_FOLDER!\HDR10P_INJ.hevc">>"!logfile!"
if exist "!TMP_FOLDER!\HDR10P_INJ.hevc" (
	%GREEN%
	echo Done.
	if exist "!HDR_VIDEOSTREAM!" del "!HDR_VIDEOSTREAM!">nul
	set "HDR_VIDEOSTREAM=!TMP_FOLDER!\HDR10P_INJ.hevc"
	echo.
	echo Done.>>"!logfile!"
	echo.>>"!logfile!"
) else (
	%RED%
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"	
	echo Error.
	echo.
	echo Error.>>"!logfile!"
	echo.>>"!logfile!"
)
goto :eof

:CONVERT_HDR10P
%CYAN%
echo Please wait. Prefetching HDR10+ file for RPU convertion...
echo [Prefetching HDR10+ file for RPU convertion]>>"!logfile!"
(
echo {
echo	"cm_version": "!CM_VERSION!",
echo 	"length": !FRAMES_HDR!,
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
	echo Done.>>"!logfile!"
	echo.>>"!logfile!"
) else (
	%RED%
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	echo Error.
	echo.
	echo Error.>>"!logfile!"
	echo.>>"!logfile!"
)

%CYAN%
echo Please wait. Generating RPU from HDR10+ file...
echo [Generating RPU from HDR10+ file]>>"!logfile!"
%WHITE%
"!DO_VI_TOOLpath!" generate -j "!TMP_FOLDER!\Extra.json" --hdr10plus-json "!HDR10PFILE!" -o "!TMP_FOLDER!\HDR10PCONVDV.bin">>"!logfile!"
if exist "!TMP_FOLDER!\HDR10PCONVDV.bin" (
	set "RPUFILE=!TMP_FOLDER!\HDR10PCONVDV.bin"
	%GREEN%
	echo.
	echo Done.>>"!logfile!"
	echo.>>"!logfile!"
) else (
	%RED%
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	echo Error.
	echo.
	echo Error.>>"!logfile!"
	echo.>>"!logfile!"
)
goto :eof

:CROPRPU
%CYAN%
echo Please wait. Applying cropping values...
echo [Applying cropping values]>>"!logfile!"
%WHITE%
(
echo {
echo   "active_area": {
echo     "presets": [
echo       {
echo       	 "id": 0,
echo       	 "left": !RPU_AA_LC!,
echo       	 "right": !RPU_AA_RC!,
echo       	 "top": !RPU_AA_TC!,
echo      	 "bottom": !RPU_AA_BC!
echo       }
echo     ],
echo      "edits": {
echo      "all": 0
echo     }
echo   }
echo }
)>"!TMP_FOLDER!\EDIT.json"
"!DO_VI_TOOLpath!" editor -i "!RPUFILE!" -j "!TMP_FOLDER!\EDIT.json" -o "!TMP_FOLDER!\RPU-CROPPED.bin">>"!logfile!"
if exist "!TMP_FOLDER!\RPU-CROPPED.bin" (
	%GREEN%
	set "RPUFILE=!TMP_FOLDER!\RPU-CROPPED.bin"
	set "CROP_RPU=TRUE"
	echo Done.
	echo.
	echo Done.>>"!logfile!"
	echo.>>"!logfile!"
) else (
	%RED%
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	echo Error.
	echo.	
	echo Error.>>"!logfile!"
	echo.>>"!logfile!"
)
goto :eof

:DV_DELAY
%CYAN%
echo "!DELAY!" | find "-">nul 2>&1
if "%ERRORLEVEL%"=="0" (
	echo Please wait. Applying RPU !DELAY! Frames negative Delay...
	echo [Applying RPU !DELAY! Frames negative Delay]>>"!logfile!"
	%WHITE%
	set /A DELAY=!DELAY!+1
	(
	echo {
	echo 	"remove": [
	echo 		"0!DELAY!"
	echo 	]
	echo }
	)>"!TMP_FOLDER!\EDIT.json"
) else (
	echo Please wait. Applying RPU !DELAY! Frames positive Delay...
	echo [Applying RPU !DELAY! Frames positive Delay]>>"!logfile!"
	set "DELAY_SC_FIX=TRUE"
	(
	%WHITE%
	echo {
	echo 	"duplicate": [
	echo 		{
	echo 			"source": 0,
	echo 			"offset": 0,
	echo 			"length": !DELAY!
	echo 		}
	echo 	]
	echo }
	)>"!TMP_FOLDER!\Edit.json"
)
"!DO_VI_TOOLpath!" editor -i "!RPUFILE!" -j "!TMP_FOLDER!\EDIT.json" -o "!TMP_FOLDER!\RPU-DELAYED.bin">>"!logfile!"
if exist "!TMP_FOLDER!\RPU-DELAYED.bin" (
	%GREEN%
	del "!TMP_FOLDER!\EDIT.json"
	set "RPUFILE=!TMP_FOLDER!\RPU-DELAYED.bin"
	echo Done.
	echo.
	echo Done.>>"!logfile!"
	echo.>>"!logfile!"
) else (
	%RED%
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	echo Error.
	echo.
	echo Error.>>"!logfile!"
	echo.>>"!logfile!"	
)
goto :eof

:FIX_SHOTS
if exist "!RPUFILE!" (
	%CYAN%
	echo Fixing Scenecuts...
	echo [Fix Scenecuts]>>"!logfile!"
	(
	echo {
	echo	"scene_cuts": {
	if "!DELAY_SC_FIX!"=="TRUE" echo		"1-!DELAY!": false,
	echo		"0-0": true
	echo	}
	echo }
	)>"!TMP_FOLDER!\Edit.json"
	"!DO_VI_TOOLpath!" editor -i "!RPUFILE!" -j "!TMP_FOLDER!\EDIT.json" -o "!TMP_FOLDER!\RPU-SCFIXED.bin">>"!logfile!"
	if exist "!TMP_FOLDER!\RPU-SCFIXED.bin" (
		%GREEN%
		del "!TMP_FOLDER!\EDIT.json"
		set "RPUFILE=!TMP_FOLDER!\RPU-SCFIXED.bin"
		echo Done.
		echo.
		echo Done.>>"!logfile!"
		echo.>>"!logfile!"
	) else (
		%RED%
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
		echo Error.
		echo.
		echo Error.>>"!logfile!"
		echo.>>"!logfile!"
	)
)
goto :eof

:FPS_CHANGE
if "!CHGFPS!"=="23.976" set "FPS=24/1.001"
if "!CHGFPS!"=="24.000" set "FPS=24"
if "!CHGFPS!"=="25.000" set "FPS=25"
set "CODEC=hevc"

%CYAN%
echo Please wait. Changing HDR Stream FPS to !CHGFPS!...
echo [Changing HDR Stream FPS to !CHGFPS!]>>"!logfile!"
%WHITE%
"!FFMPEGpath!" -y -i "!HDR_VIDEOSTREAM!" -loglevel panic -stats -an -sn -dn -c copy -bsf:v hevc_metadata=tick_rate=!FPS!:num_ticks_poc_diff_one=1 "!TMP_FOLDER!\HDR_FPSCHANGED.!CODEC!"
if exist "!TMP_FOLDER!\HDR_FPSCHANGED.!CODEC!" (
	%GREEN%
	del "!TMP_FOLDER!\HDR.!CODEC!"
	set "HDR_VIDEOSTREAM=!TMP_FOLDER!\HDR_FPSCHANGED.!CODEC!"
	echo Done.
	echo.
	echo Done.>>"!logfile!"
	echo.>>"!logfile!"
) else (
	%RED%
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	echo Error.
	echo.
	echo Error.>>"!logfile!"
	echo.>>"!logfile!"
)
goto :eof

:DV_INJECT
if "%REMHDR_HDR10P%"=="YES" set "REM_HDR10PString=--drop-hdr10plus "
%CYAN%
echo Please wait. Injecting DV Metadata Binary into stream...
echo [Injecting DV Metadata Binary into stream]>>"!logfile!"
%WHITE%
"!DO_VI_TOOLpath!" !REM_HDR10PString!inject-rpu "!HDR_VIDEOSTREAM!" --rpu-in "!RPUFILE!" -o "!TMP_FOLDER!\HDR_DV_INJ.hevc">>"!logfile!"
if exist "!TMP_FOLDER!\HDR_DV_INJ.hevc" (
	%GREEN%
	if exist "!HDR_VIDEOSTREAM!" del "!HDR_VIDEOSTREAM!">nul
	set "HDR_VIDEOSTREAM=!TMP_FOLDER!\HDR_DV_INJ.hevc"
	echo Done.	
	echo.
	echo Done.>>"!logfile!"
	echo.>>"!logfile!"
) else (
	%RED%
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	echo Error.
	echo.
	echo Error.>>"!logfile!"
	echo.>>"!logfile!"
)
goto :eof

:MUXINCONT
if "!MKVExtract_HDR!!MUXINMKV!"=="TRUEYES" (
	set "duration="
	if "%FRAMERATE_HDR%"=="23.976" set "duration=--default-duration 0:24000/1001p --fix-bitstream-timing-information 0:1"
	if "%FRAMERATE_HDR%"=="24.000" set "duration=--default-duration 0:24p --fix-bitstream-timing-information 0:1"
	if "%FRAMERATE_HDR%"=="25.000" set "duration=--default-duration 0:25p --fix-bitstream-timing-information 0:1"
	if "%FRAMERATE_HDR%"=="30.000" set "duration=--default-duration 0:30p --fix-bitstream-timing-information 0:1"
	if "%FRAMERATE_HDR%"=="48.000" set "duration=--default-duration 0:48p --fix-bitstream-timing-information 0:1"
	if "%FRAMERATE_HDR%"=="50.000" set "duration=--default-duration 0:50p --fix-bitstream-timing-information 0:1"
	if "%FRAMERATE_HDR%"=="60.000" set "duration=--default-duration 0:60p --fix-bitstream-timing-information 0:1"
	%CYAN%
	echo Please wait. Muxing Videostream into MKV Container...
	echo [Muxing Videostream into MKV Container]>>"!logfile!"
	%YELLOW%
	set "MUXEXT=.mkv"
	echo Don't close "Muxing !HDR_Filename!_[!NAMESTRING!] into MKV" cmd window.
	start /WAIT /MIN "Muxing !HDR_Filename! into MKV" "!MKVMERGEpath!" --ui-language en --priority higher --output ^"!TARGET_FOLDER!\!HDR_Filename!_[!NAMESTRING!].mkv^" --stop-after-video-ends --no-video ^"^(^" ^"!HDR_File!^" ^"^)^" --language 0:und --compression 0:none !duration! ^"^(^" ^"!HDR_VIDEOSTREAM!^" ^"^)^" --track-order 1:0
	if exist "!TARGET_FOLDER!\!HDR_Filename!_[!NAMESTRING!]!MUXEXT!" (
		%GREEN%
		echo Done.
		echo.
		echo Done.>>"!logfile!"
		echo.>>"!logfile!"
	) else (
		%RED%
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
		echo Error.
		echo.
		echo Error.>>"!logfile!"
		echo.>>"!logfile!"
	)
)

if "!MP4Extract_HDR!!MUXINMP4!"=="TRUEYES" (
	%CYAN%
	echo Please wait. Muxing !HDR_Filename! into MP4...
	echo [Muxing !HDR_Filename! into MP4]>>"!logfile!"
	%WHITE%
	"!MP4BOXpath!" -rem 1 "!HDR_File!" -out "!TMP_FOLDER!\temp.mp4"
	if exist "!TMP_FOLDER!\temp.mp4" (
		%GREEN%
		echo Done.
		echo.
		echo Done.>>"!logfile!"
		echo.>>"!logfile!"
	) else (
		%RED%
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
		echo Error.
		echo.
		echo Error.>>"!logfile!"
		echo.>>"!logfile!"
	)
	set "MUXEXT=.mp4"
	"!MP4BOXpath!" -add "!TMP_FOLDER!\HDR_DV_INJ.hevc:ID=1:fps=!FRAMERATE_HDR!:name=" "!TMP_FOLDER!\temp.mp4" -out "!TARGET_FOLDER!\!HDR_Filename!_[!NAMESTRING!]!MUXEXT!"
	echo [Finalising MP4 File]>>"!logfile!"
	if exist "!TARGET_FOLDER!\!HDR_Filename!_[!NAMESTRING!]!MUXEXT!" (
		%GREEN%
		echo.
		echo Done.>>"!logfile!"
		echo.>>"!logfile!"
	) else (
		%RED%
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
		echo Error.
		echo.
		echo Error.>>"!logfile!"
		echo.>>"!logfile!"
	)
)

if "!MUXINMKV!!MUXINMP4!"=="NONO" (
	%CYAN%
	set "MUXEXT=.hevc"
	echo Move Videostream into Target Folder...
	echo [Move Videostream into Target Folder]>>"!logfile!"
	move /Y "!HDR_VIDEOSTREAM!" "!TARGET_FOLDER!\!HDR_Filename!_[!NAMESTRING!]!MUXEXT!" >nul
	if exist "!TARGET_FOLDER!\!HDR_Filename!_[!NAMESTRING!]!MUXEXT!" (
		%GREEN%
		echo Done.
		echo.
		echo Done.>>"!logfile!"
		echo.>>"!logfile!"
	) else (
		%RED%
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
		echo Error.
		echo.
		echo Error.>>"!logfile!"
		echo.>>"!logfile!"
	)
)
goto :eof

:AA_AREA
mode con cols=125 lines=55
set "RPU_AA_String="
if "%RPU_INPUT_AA_LC%%RPU_INPUT_AA_TC%%RPU_INPUT_AA_RC%%RPU_INPUT_AA_BC%"=="" (
	if "%AA_INPUT_LC%%AA_INPUT_TC%%AA_INPUT_RC%%AA_INPUT_BC%" NEQ "" (
		set "RPU_AA_LC=%AA_INPUT_LC%"
		set "RPU_AA_TC=%AA_INPUT_TC%"
		set "RPU_AA_RC=%AA_INPUT_RC%"
		set "RPU_AA_BC=%AA_INPUT_BC%"
	) else (
		set "RPU_AA_LC=0"
		set "RPU_AA_TC=0"
		set "RPU_AA_RC=0"
		set "RPU_AA_BC=0"
	)
)

:AA_AREA_BASE
::VIDEO LINE
:: VIDEO-INPUT = RPU-INPUT
if "%AA_INPUT_LC%%AA_INPUT_TC%%AA_INPUT_RC%%AA_INPUT_BC%"=="%RPU_INPUT_AA_LC%%RPU_INPUT_AA_TC%%RPU_INPUT_AA_RC%%RPU_INPUT_AA_BC%" (
	set "HEADER_RPU_AA_String=call :colortxt 0B "Borders    = [LEFT=%RPU_INPUT_AA_LC% px], [TOP=%RPU_INPUT_AA_TC% px], [RIGHT=%RPU_INPUT_AA_RC% px], [BOTTOM=%RPU_INPUT_AA_BC% px] [" & call :colortxt 0A "MATCH WITH VIDEO" & call :colortxt 0B "]" /n"
	set "AA_String=call :colortxt 0B "Borders    = [LEFT=%AA_INPUT_LC% px], [TOP=%AA_INPUT_TC% px], [RIGHT=%AA_INPUT_RC% px], [BOTTOM=%AA_INPUT_BC% px] [" & call :colortxt 0A "MATCH WITH INPUT RPU" & call :colortxt 0B "]" /n"
) else (
	set "HEADER_RPU_AA_String=call :colortxt 0B "Borders    = [LEFT=%RPU_INPUT_AA_LC% px], [TOP=%RPU_INPUT_AA_TC% px], [RIGHT=%RPU_INPUT_AA_RC% px], [BOTTOM=%RPU_INPUT_AA_BC% px] [" & call :colortxt 0C "NOT MATCH WITH VIDEO" & call :colortxt 0B "]" /n"
	set "AA_String=call :colortxt 0B "Borders    = [LEFT=%AA_INPUT_LC% px], [TOP=%AA_INPUT_TC% px], [RIGHT=%AA_INPUT_RC% px], [BOTTOM=%AA_INPUT_BC% px] [" & call :colortxt 0C "NOT MATCH WITH INPUT RPU" & call :colortxt 0B "]" /n"
)
::RPU LINE
:: RPU-INPUT = NONE
if "%RPU_INPUT_AA_LC%%RPU_INPUT_AA_TC%%RPU_INPUT_AA_RC%%RPU_INPUT_AA_BC%"=="" set "HEADER_RPU_AA_String=call :colortxt 0B "Borders    = [" & call :colortxt 06 "BORDERS NOT SET IN RPU" & call :colortxt 0B "]" /n"	
::OUTPUT_LINE
set "HEADER_RPU_OUTPUT_String=call :colortxt 0E "Borders    = [LEFT=!RPU_AA_LC! px], [TOP=!RPU_AA_TC! px], [RIGHT=!RPU_AA_RC! px], [BOTTOM=!RPU_AA_BC! px] [" & call :colortxt 0C "NOT MATCH WITH VIDEO" & call :colortxt 0E "]" /n"
:: RPU-OUTPUT = VIDEO-INPUT
if "%RPU_AA_LC%%RPU_AA_TC%%RPU_AA_RC%%RPU_AA_BC%"=="%AA_INPUT_LC%%AA_INPUT_TC%%AA_INPUT_RC%%AA_INPUT_BC%" (
	set "HEADER_RPU_OUTPUT_String=call :colortxt 0E "Borders    = [LEFT=!RPU_AA_LC! px], [TOP=!RPU_AA_TC! px], [RIGHT=!RPU_AA_RC! px], [BOTTOM=!RPU_AA_BC! px] [" & call :colortxt 0A "MATCH WITH VIDEO" & call :colortxt 0E "]" /n"
	set "AA_String=call :colortxt 0B "Borders    = [LEFT=%AA_INPUT_LC% px], [TOP=%AA_INPUT_TC% px], [RIGHT=%AA_INPUT_RC% px], [BOTTOM=%AA_INPUT_BC% px] [" & call :colortxt 0A "MATCH WITH OUTPUT RPU" & call :colortxt 0B "]" /n"
) else (
	set "HEADER_RPU_OUTPUT_String=call :colortxt 0E "Borders    = [LEFT=!RPU_AA_LC! px], [TOP=!RPU_AA_TC! px], [RIGHT=!RPU_AA_RC! px], [BOTTOM=!RPU_AA_BC! px] [" & call :colortxt 0C "NOT MATCH WITH VIDEO" & call :colortxt 0E "]" /n"
	set "AA_String=call :colortxt 0B "Borders    = [LEFT=%AA_INPUT_LC% px], [TOP=%AA_INPUT_TC% px], [RIGHT=%AA_INPUT_RC% px], [BOTTOM=%AA_INPUT_BC% px] [" & call :colortxt 0C "NOT MATCH WITH OUTPUT RPU" & call :colortxt 0B "]" /n"
)
::OUTPUT LINE
:: VIDEO-INPUT = NONE
if "%AA_INPUT_LC%%AA_INPUT_TC%%AA_INPUT_RC%%AA_INPUT_BC%"=="" (
	set "AA_String=call :colortxt 0B "Borders    = [" & call :colortxt 06 "NOT FOUND. MUX FILE IN CONTAINER OR SET CROPPING VALUES MANUALLY" & call :colortxt 0B "]" /n"
	if "%RPU_INPUT_AA_LC%%RPU_INPUT_AA_TC%%RPU_INPUT_AA_RC%%RPU_INPUT_AA_BC%"=="" (
		set "HEADER_RPU_AA_String=call :colortxt 0B "Borders    = [" & call :colortxt 06 "BORDERS NOT SET IN RPU" & call :colortxt 0B "]" /n"	
	) else (
		set "HEADER_RPU_AA_String=call :colortxt 0B "Borders    = [LEFT=%RPU_INPUT_AA_LC% px], [TOP=%RPU_INPUT_AA_TC% px], [RIGHT=%RPU_INPUT_AA_RC% px], [BOTTOM=%RPU_INPUT_AA_BC% px] [" & call :colortxt 06 "VIDEO BORDERS NOT FOUND" & call :colortxt 0B "]" /n"
	)
	set "HEADER_RPU_OUTPUT_String=call :colortxt 0E "Borders    = [LEFT=!RPU_AA_LC! px], [TOP=!RPU_AA_TC! px], [RIGHT=!RPU_AA_RC! px], [BOTTOM=!RPU_AA_BC! px] [" & call :colortxt 06 "VIDEO BORDERS NOT FOUND" & call :colortxt 0E "]" /n"
)
set "HEADER_RPU_AA_String_RPU=call :colortxt 0B "Borders    = [LEFT=%RPU_INPUT_AA_LC% px], [TOP=%RPU_INPUT_AA_TC% px], [RIGHT=%RPU_INPUT_AA_RC% px], [BOTTOM=%RPU_INPUT_AA_BC% px]" /n"	
set "HEADER_RPU_OUTPUT_String_RPU=call :colortxt 0E "Borders    = [LEFT=!RPU_AA_LC! px], [TOP=!RPU_AA_TC! px], [RIGHT=!RPU_AA_RC! px], [BOTTOM=!RPU_AA_BC! px]" /n"
cls
%GREEN%
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool INJECTOR
echo                                                - ACTIVE AREA EDITOR -
%WHITE%
echo                                         ====================================
echo.
echo.
echo  == VIDEO INPUT =========================================================================================================
echo.
%CYAN%
%AA_String%
echo.
if "!DV_DV!"=="TRUE" (
	%WHITE%
	echo  == RPU INPUT ===========================================================================================================
	%CYAN%
	echo.
	%HEADER_RPU_AA_String%
	echo.
)
%WHITE%
echo  == RPU OUTPUT ==========================================================================================================
%YELLOW%
echo.
%HEADER_RPU_OUTPUT_String%
echo.
%WHITE%
echo  == EDIT ACTIVE AREA ====================================================================================================
%CYAN%
echo.
echo If you change the resolution of the target video you must edit the Active Area. For Example^:
echo Source^: 3840 px x 2160 px Letterboxed ^(Active Area 3840 px x 1600 px^) ^= 280 px at Top and Bottom.
echo Target^: 1920 px x 1080 px Letterboxed ^(Active Area 1920 px x 800 px^) ^= 140 px at Top and Bottom.
echo If your target File is cropped (1920 px x 800 px) set all values to 0 or simply use the "Crop RPU" Function in Demuxer.
echo.
%WHITE%
echo  ========================================================================================================================
echo.
%RED%
echo All Settings will be Lost if you closed the Tool^^!
%WHITE%
echo.
echo  ========================================================================================================================
echo.
call :colortxt 0F "L. Set " & call :colortxt 0E "LEFT" & call :colortxt 0F " Crop value [" & call :colortxt 0E "!RPU_AA_LC!" & call :colortxt 0F " px]" /n
call :colortxt 0F "T. Set " & call :colortxt 0E "TOP" & call :colortxt 0F " Crop value [" & call :colortxt 0E "!RPU_AA_TC!" & call :colortxt 0F " px]" /n
call :colortxt 0F "R. Set " & call :colortxt 0E "RIGHT" & call :colortxt 0F " Crop value [" & call :colortxt 0E "!RPU_AA_RC!" & call :colortxt 0F " px]" /n
call :colortxt 0F "B. Set " & call :colortxt 0E "BOTTOM" & call :colortxt 0F " Crop value [" & call :colortxt 0E "!RPU_AA_BC!" & call :colortxt 0F " px]" /n
echo.
%WHITE%
echo D. DISCARD Settings and Exit
echo S. SAVE Settings and Exit
echo.
%GREEN%
echo Change Settings and press [S] to SAVE or [D] to DISCARD^^!
CHOICE /C LTRBDS /N /M "Select a Letter L,T,R,B,[D]iscard,[S]ave"

if "%ERRORLEVEL%"=="6" goto :eof
if "%ERRORLEVEL%"=="5" (
	set "RPU_AA_String=[LEAVE UNTOUCHED]"
	set "RPU_AA_LC=%RPU_INPUT_AA_LC%"
	set "RPU_AA_TC=%RPU_INPUT_AA_TC%"
	set "RPU_AA_RC=%RPU_INPUT_AA_RC%"
	set "RPU_AA_BC=%RPU_INPUT_AA_BC%"
	goto :eof
)

if "%ERRORLEVEL%"=="4" (
	echo.
	%WHITE%
	echo Type in the Pixels, which will be cropped on BOTTOM side.
	echo Example: For cropping 140px on BOTTOM side type "140" and press Enter^^!
	echo.
	set /p "RPU_AA_BC=Type in the Pixels and press [ENTER]: "
)
if "%ERRORLEVEL%"=="3" (
	echo.
	%WHITE%
	echo Type in the Pixels, which will be cropped on RIGHT side.
	echo Example: For cropping 140px on RIGHT side type "140" and press Enter^^!
	echo.
	set /p "RPU_AA_RC=Type in the Pixels and press [ENTER]: "
)
if "%ERRORLEVEL%"=="2" (
	echo.
	%WHITE%
	echo Type in the Pixels, which will be cropped on TOP side.
	echo Example: For cropping 140px on TOP side type "140" and press Enter^^!
	echo.
	set /p "RPU_AA_TC=Type in the Pixels and press [ENTER]: "
)
if "%ERRORLEVEL%"=="1" (
	echo.
	%WHITE%
	echo Type in the Pixels, which will be cropped on LEFT side.
	echo Example: For cropping 140px on LEFT side type "140" and press Enter^^!
	echo.
	set /p "RPU_AA_LC=Type in the Pixels and press [ENTER]: "
)
goto :AA_AREA_BASE

:LOGFILEEND
if exist "!TMP_FOLDER!" (
	echo  == ERROR^(S^) ============================================================================================================>>"!logfile!"
	echo.>>"!logfile!"
	echo !ERRORCOUNT! Error^(s^) during processing.>>"!logfile!"
	echo.>>"!logfile!"
	echo  == LOGFILE END =========================================================================================================>>"!logfile!"
	echo.>>"!logfile!"
	echo %date%  %time%>>"!logfile!"
	if exist "!logfile!" move "!logfile!" "!TARGET_FOLDER!\DDVT Hybrid ^(!HDR_Filename!_[!NAMESTRING!]!MUXEXT!^).log" >nul
)
goto :eof

:EXIT
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
set "NewLine=[System.Environment]::NewLine"
set "Line1=""%MISSINGFILE%""""
set "Line2=Copy the file to the directory or reinstall DDVT v%VERSION%."
setlocal DisableDelayedExpansion
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('NEEDED FILE NOT FOUND!' + %NewLine% + %NewLine% + '%Line1%' + %NewLine% + %NewLine% + '%Line2%', 'DDVT P8 Hybrid Script [QfG] v%VERSION%', 'Ok','Error')"
exit

:ERROR
if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
set "NewLine=[System.Environment]::NewLine"
set "Line1=%ERRORCOUNT% Error(s) during processing^!
set "Line2=Target file don''t exist or corrupt.
setlocal DisableDelayedExpansion
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('%INPUTFILENAME%%INPUTFILEEXT%' + %NewLine% + %NewLine% + '%Line1%' + %NewLine% + %NewLine% + '%Line2%', 'DDVT P8 Hybrid Script [QfG] v%VERSION%', 'Ok','Error')"
exit

:DUALLAYERERROR
if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
set "NewLine=[System.Environment]::NewLine"
set "Line1=Unsupported Input File.
set "Line2=Only Dolby Vision Single Layer files supported.
setlocal DisableDelayedExpansion
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('%INPUTFILENAME%%INPUTFILEEXT%' + %NewLine% + %NewLine% + '%Line1%' + %NewLine% + %NewLine% + '%Line2%', 'DDVT P8 Hybrid Script [QfG] v%VERSION%', 'Ok','Info')"
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