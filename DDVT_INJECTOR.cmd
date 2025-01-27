@echo off & setlocal
mode con cols=125 lines=57
FOR /F "tokens=2 delims==" %%A IN ('findstr /C:"VERSION=" "%~dp0DDVT_OPTIONS.cmd"') DO set "VERSION=%%A"
TITLE DDVT Injector [QfG] v%VERSION%

set PasswordChars=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890
set PasswordLength=5
call :CreatePassword Password

set "sfkpath=%~dp0tools\sfk.exe" rem Path to sfk.exe
set "FFMPEGpath=%~dp0tools\ffmpeg.exe" rem Path to ffmpeg.exe
set "MP4BOXpath=%~dp0tools\mp4box.exe" rem Path to mp4box.exe
set "MEDIAINFOpath=%~dp0tools\mediainfo.exe" rem Path to mediainfo.exe
set "DO_VI_TOOLpath=%~dp0tools\dovi_tool.exe" rem Path to dovi_tool.exe
set "HDR10Plus_TOOLpath=%~dp0tools\hdr10plus_tool.exe" rem Path to hdr10plus_tool.exe
set "PYTHONpath=%~dp0tools\Python\Python.exe" rem Path to PYTHON exe
set "HDR10PDELAYSCRIPTpath=%~dp0tools\Python\Scripts\hdr10plus_delay.py" rem Path to SCRIPT

rem --- Hardcoded settings. Can be changed manually ---
set "MUXINMKV=YES"
:: YES / NO - Muxing video stream into MKV container if source was MKV container.
set "MUXINMP4=YES"
:: YES / NO - Muxing video stream into MP4 container if source was MP4 container.
set "MUXP7SETTING=STANDARD"
:: STANDARD / makeMKV / Disable AUD NALUs - Method for muxing EL into BL.
set "CUSTOMEDIT=FIRST"
:: FIRST / LAST - Position how the custom.json file will be processed. FIRST=Processing BEFORE tool operations, LAST=Processing AFTER tool operations.
:: Also can be set via OPTIONS script.
set "FIX_SCENECUTS=YES"
:: Set frame 0 scenecut flag in RPU to true. Also can be set in OPTIONS and overwrite this settings.
:: YES / NO

rem --- Hardcoded settings. Cannot be changed ---
set "INPUTFILE=%~dpnx1"
set "INPUTFILEPATH=%~dp1"
set "INPUTFILENAME=%~n1"
set "INPUTFILEEXT=%~x1"
set "TMP_FOLDER=SAME AS SOURCE"
set "TARGET_FOLDER=SAME AS SOURCE"
set "MKVTOOLNIX_FOLDER=INCLUDED"
set "JSON_SUPPORT=YES"
set "CUSTOM_ONLY=FALSE"
set "MP4Extract=FALSE"
set "MKVExtract=FALSE"
set "RAW_FILE=FALSE"
set "RPU_FILE=FALSE"
set "CROP_RPU=FALSE"
set "DELAY=0"
set "L6EDITING=NO"
set "VEDITING=NO"
set "HDR10P=FALSE"
set "DV=FALSE"
set "DV5=FALSE"
set "REMHDR10P=NO"
set "CHGFPS=NO"
set "DV_OK=FALSE"
set "HDR10P_OK=FALSE"
set "CJ_OK=FALSE"
set "RPU_exist=NO"
set "EL_INPUT=FALSE"
set "EL_exist=NO"
set "XML_exist=NO"
set "ELFILE=FALSE"
set "HDR10P_exist=NO"
set "REMHDR10PString="
set "MUXP7String="
set "DV_INJ=FALSE"
set "HDR10P_INJ=FALSE"
set "CJ_INJ=FALSE"
set "HDR_Info=No HDR Infos found"
set "RESOLUTION=N/A"
set "HDR=N/A"
set "CODEC_NAME=N/A"
set "FRAMERATE=N/A"
set "FRAMES=N/A"
set "RPU_FRAMES=N/A"
set "RPU_CMV=N/A"
set "RPU_DVP=N/A"
set "RPU_DVSP="
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
	FOR /F "delims=" %%A IN ('findstr /C:"JSON_SUPPORT=" "%~dp0DDVT_OPTIONS.ini"') DO (
		set "JSON_SUPPORT=%%A"
		set "JSON_SUPPORT=!JSON_SUPPORT:~13!"
	)
	FOR /F "delims=" %%A IN ('findstr /C:"JSON_PROCESS=" "%~dp0DDVT_OPTIONS.ini"') DO (
		set "CUSTOMEDIT=%%A"
		echo "!CUSTOMEDIT!"
		set "CUSTOMEDIT=!CUSTOMEDIT:~13!"
	)
	FOR /F "delims=" %%A IN ('findstr /C:"FIX_SCENECUTS=" "%~dp0DDVT_OPTIONS.ini"') DO (
		set "FIX_SCENECUTS=%%A"
		set "FIX_SCENECUTS=!FIX_SCENECUTS:~14!"
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
set "logfile=%TMP_FOLDER%\!INPUTFILENAME!.log"

if not exist "%sfkpath%" set "MISSINGFILE=%sfkpath%" & goto :CORRUPTFILE
if not exist "%FFMPEGpath%" set "MISSINGFILE=%FFMPEGpath%" & goto :CORRUPTFILE
if not exist "%MKVMERGEpath%" set "MISSINGFILE=%MKVMERGEpath%" & goto :CORRUPTFILE
if not exist "%MP4BOXpath%" set "MISSINGFILE=%MP4BOXpath%" & goto :CORRUPTFILE
if not exist "%MEDIAINFOpath%" set "MISSINGFILE=%MEDIAINFOpath%" & goto :CORRUPTFILE
if not exist "%DO_VI_TOOLpath%" set "MISSINGFILE=%DO_VI_TOOLpath%" & goto :CORRUPTFILE
if not exist "%HDR10Plus_TOOLpath%" set "MISSINGFILE=%HDR10Plus_TOOLpath%" & goto :CORRUPTFILE
if not exist "%PYTHONpath%" set "MISSINGFILE=%PYTHONpath%" & goto :CORRUPTFILE
if not exist "%HDR10PDELAYSCRIPTpath%" set "MISSINGFILE=%HDR10PDELAYSCRIPTpath%" & goto :CORRUPTFILE

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
%WHITE%
echo.
echo.
echo  == CHECK INPUT FILE ====================================================================================================

if "%~1" NEQ "" set "VIDEOSTREAM=%~1"
if /i "%~x1"==".mkv" set "MKVExtract=TRUE" & goto :PREPARE_DV
if /i "%~x1"==".mp4" set "MP4Extract=TRUE" & goto :PREPARE_DV
if /i "%~x1"==".hevc" set "RAW_FILE=TRUE" & goto :PREPARE_DV
if /i "%~x1"==".h265" set "RAW_FILE=TRUE" & goto :PREPARE_DV
if /i "%~x1"==".bin" set "RPU_FILE=TRUE" & goto :PREPARE_CJ

if not "!INPUTFILE!"=="" goto :FALSEINPUT

if "%~1"=="" (
	%YELLOW%
	echo.
	echo No Input File. Use DDVT_INJECTOR.cmd "YourFilename.mkv/mp4/hevc/h265"
	%WHITE%
	echo.
	goto :EXIT
)

:PREPARE_DV
FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=General;%%VideoCount%% "!INPUTFILE!""') do set "VIDEO_COUNT=%%A"
if "!VIDEO_COUNT!" NEQ "1" (
	%YELLOW%
	echo.
	echo No Support for Dual Layer Container^^!
	%WHITE%
	echo.
	goto :EXIT
)
cls
%GREEN%
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool INJECTOR
%WHITE%
echo                                         ====================================
echo.
echo.
echo  == INSERT RPU FILE / ENHANCED LAYER ====================================================================================
echo.
%GREEN%
echo [Info] For injecting DV Metadata, drag 'n' drop here your RPU [*.bin] or your ENHANCED LAYER [*.hevc, *.h265] and hit ENTER. 
echo        To skip DV injection leave blank and hit ENTER.
echo.
call :colortxt 0E "Drag 'n' Drop" & call :colortxt 0A " RPU FILE / ENHANCED LAYER " & call :colortxt 0E "file here and press ENTER:" /n
%WHITE%
set /p "DV_File=" || set "DV_File=NONE"
if "!DV_File!" NEQ "NONE" for %%f in (!DV_File!) do set "DV_Filename=%%~nf"
if "!DV_File!" NEQ "NONE" for %%f in (!DV_File!) do set "DV_Fileext=%%~xf"
if "!DV_File!" NEQ "NONE" for %%f in (!DV_File!) do set "DV_File=%%~dpnxf"

if /I "%DV_Fileext%"==".hevc" set "DV_OK=TRUE" & set "EL_exist=YES" & set "DV_INJ=TRUE" & set "ELSTREAM=!DV_File!"
if /I "%DV_Fileext%"==".h265" set "DV_OK=TRUE" & set "EL_exist=YES" & set "DV_INJ=TRUE" & set "ELSTREAM=!DV_File!"
if /I "%DV_Fileext%"==".bin" set "DV_OK=TRUE" & set "RPU_exist=YES" & set "DV_INJ=TRUE" & set "RPUFILE=!DV_File!"
if /I "%DV_Fileext%"==".xml" set "DV_OK=TRUE" & set "XML_exist=YES" & set "DV_INJ=TRUE" & set "XMLFILE=!DV_File!"

if "!DV_OK!"=="FALSE" (
	if "!DV_File!"=="NONE" (
		%YELLOW%
		echo No Dolby Vision file choosen. Skip Dolby Vision injection...
		TIMEOUT 2 /NOBREAK >nul
		goto :PREPARE_HDR10P
	) else (
		%RED%
		echo.
		echo File not Supported^^! Only .xml^/.bin^/.hevc^/.h265 files supported.
		TIMEOUT 3 /NOBREAK >nul
		goto :PREPARE_DV
	)
)

:PREPARE_HDR10P
cls
%GREEN%
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool INJECTOR
%WHITE%
echo                                         ====================================
echo.
echo.
echo  == HDR10 PLUS FILE =====================================================================================================
echo.
%GREEN%
echo [Info] For injecting HDR10+ SEI, drag 'n' drop here your HDR10+ JSON file [*.json] and hit ENTER. 
echo        To skip HDR10+ injection leave blank and hit ENTER.
echo.
call :colortxt 0E "Drag 'n' Drop" & call :colortxt 0A " HDR10+ JSON " & call :colortxt 0E "file here and press ENTER:" /n
%WHITE%
set /p "HDR10P_file=" || set "HDR10P_file=NONE"
if "!HDR10P_file!" NEQ "NONE" for %%f in (!HDR10P_file!) do set "HDR10P_Filename=%%~nf"
if "!HDR10P_file!" NEQ "NONE" for %%f in (!HDR10P_file!) do set "HDR10P_Fileext=%%~xf"
if "!HDR10P_file!" NEQ "NONE" for %%f in (!HDR10P_file!) do set "HDR10P_file=%%~dpnxf"

if /I "%HDR10P_Fileext%"==".json" set "HDR10P_OK=TRUE" & set "HDR10P_exist=YES" & set "HDR10P_INJ=TRUE" & set "HDR10PFILE=!HDR10P_file!"

if "!HDR10P_OK!"=="FALSE" (
	if "!HDR10P_file!"=="NONE" (
		%YELLOW%
		echo No HDR10+ file choosen. Skip HDR10+ injection...
		TIMEOUT 2 /NOBREAK >nul
		goto :PREPARE_CJ
	) else (
		%RED%
		echo.
		echo File not Supported^^! Only .json files supported.
		TIMEOUT 3 /NOBREAK >nul
		goto :PREPARE_HDR10P
	)
)

:PREPARE_CJ
if "!JSON_SUPPORT!"=="NO" goto :CHECK
cls
%GREEN%
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool INJECTOR
%WHITE%
echo                                         ====================================
echo.
echo.
echo  == CUSTOM EDIT FILE ====================================================================================================
echo.
%GREEN%
echo [Info] For operation with a custom json file, drag 'n' drop here your CUSTOM EDIT FILE [*.json] and hit ENTER. 
echo        Attention^^! The CUSTOM EDIT FILE will be processed BEFORE the tool functions processed.
if "!RPU_FILE!"=="FALSE" echo        To skip this operation leave blank and hit ENTER.
echo.
call :colortxt 0E "Drag 'n' Drop" & call :colortxt 0A " CUSTOM EDIT FILE " & call :colortxt 0E "file here and press ENTER:" /n
%WHITE%
set /p "CJ_File=" || set "CJ_File=NONE"
if "!CJ_File!" NEQ "NONE" for %%f in (!CJ_File!) do set "CJ_Filename=%%~nf"
if "!CJ_File!" NEQ "NONE" for %%f in (!CJ_File!) do set "CJ_Fileext=%%~xf"
if "!CJ_File!" NEQ "NONE" for %%f in (!CJ_File!) do set "CJ_File=%%~dpnxf"

if /I "%CJ_Fileext%"==".json" set "CJ_OK=TRUE" & set "CJ_INJ=TRUE"

if "!RPU_FILE!"=="FALSE" (
	if "!CJ_OK!"=="FALSE" (
		if "!CJ_File!"=="NONE" (
			%YELLOW%
			echo No EDIT file choosen. Skip CUSTOM EDIT operation...
			TIMEOUT 2 /NOBREAK >nul
			goto :CHECK
		) else (
			%RED%
			echo.
			echo File not Supported^^! Only .json files supported.
			TIMEOUT 3 /NOBREAK >nul
			goto :PREPARE_CJ
		)
	)
)
if "!RPU_FILE!"=="TRUE" (
	if "!CJ_OK!"=="FALSE" (
		if "!CJ_File!"=="NONE" (
			%YELLOW%
			echo No EDIT file choosen. Nothing to do...
			TIMEOUT 2 /NOBREAK >nul
			echo.
			goto :CHECK
		) else (
			%RED%
			echo.
			echo File not Supported^^! Only .json files supported.
			TIMEOUT 2 /NOBREAK >nul
			goto :PREPARE_CJ
		)
	)
)
	
:CHECK
cls
%GREEN%
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool INJECTOR
%WHITE%
echo                                         ====================================
echo.
echo.
if "!RPU_FILE!"=="TRUE" (
	echo  == CHECK RPU ===========================================================================================================
	goto :PREPARE
) else (
	echo  == CHECK INPUT FILE^(S^) =================================================================================================
	if "%XML_Exist%%RPU_exist%%EL_exist%"=="NONONO" (
		%YELLOW%
		set "DV_INJ=FALSE"
		echo.
		echo Dolby Vision Input File not set^^!
		echo Dolby Vision Functions disabled.
	)

	if "%HDR10P_exist%"=="NO" (
		%YELLOW%
		set "HDR10P_INJ=FALSE"
		echo.
		echo HDR10+ Input File not set^^!
		echo HDR10+ Functions disabled.
	)
		
	if "%JSON_SUPPORT%!CJ_File!"=="YESNONE" (
		%YELLOW%
		set "CJ_INJ=FALSE"
		echo.
		echo Custom Edit Input File not set^^!
		echo Custom Edit Processing disabled.
	)

	if "%JSON_SUPPORT%%XML_Exist%%RPU_exist%%EL_exist%%HDR10P_exist%"=="NONONONONO" (
		%RED%
		echo.
		echo Dolby Vision and HDR10+ Files not set^^!
		%YELLOW%
		echo.
		echo Abort Operation now.
		echo.
		goto :EXIT
	)
	if "!CJ_File!%XML_Exist%%RPU_exist%%EL_exist%%HDR10P_exist%"=="NONENONONONO" (
		%RED%
		echo.
		echo No Input Files set^^!
		%YELLOW%
		echo.
		echo Abort Operation now.
		echo.
		goto :EXIT
	)
)

:PREPARE
if not exist "!TMP_FOLDER!" MD "!TMP_FOLDER!">nul
if "!RPU_FILE!"=="FALSE" (
	%CYAN%
	echo.
	echo Analysing File. Please wait...
	echo.
	set "INPUTSTREAM=!INPUTFILE!"
	set "INFOSTREAM=!INPUTFILE!"
	if "!RAW_FILE!!VIDEO_COUNT!"=="TRUE1" (
		"!MKVMERGEpath!" --ui-language en --priority higher --output ^"!TMP_FOLDER!\Info.mkv^" --language 0:und --compression 0:none ^"^(^" ^"!INPUTFILE!^" ^"^)^" --split parts:00:00:00-00:00:01 -q
		if exist "!TMP_FOLDER!\Info.mkv" set "INFOSTREAM=!TMP_FOLDER!\Info.mkv"
	)
	::SET HDR FORMAT
	"!MEDIAINFOpath!" --output=Video;%%HDR_Format_String%% "!INFOSTREAM!">"!TMP_FOLDER!\Info.txt"
	FOR /F "delims=" %%A IN ('findstr /C:"Dolby Vision" "!TMP_FOLDER!\Info.txt"') DO set "HDR_DVinput=YES"
	FOR /F "delims=" %%A IN ('findstr /C:"HDR10" "!TMP_FOLDER!\Info.txt"') DO set "HDR_HDRFormat=HDR10"
	FOR /F "delims=" %%A IN ('findstr /C:"HDR10+" "!TMP_FOLDER!\Info.txt"') DO set "HDR_HDRFormat=HDR10+"
	FOR /F "delims=" %%A IN ('findstr /C:"dvhe.05" "!TMP_FOLDER!\Info.txt"') DO set "HDR_HDRFormat=IPT-PQ-C2"
	FOR /F "delims=" %%A IN ('findstr /C:"HLG" "!TMP_FOLDER!\Info.txt"') DO set "HDR_HDRFormat=HLG"

	::SET DV FORMAT
	"!MEDIAINFOpath!" --output=Video;%%HDR_Format_Profile%% "!INFOSTREAM!">"!TMP_FOLDER!\Info.txt"
	FOR /F "delims=" %%A IN ('findstr /C:".08" "!TMP_FOLDER!\Info.txt"') DO set "HDR_DVinput=YES" & set "DVprofile=8"
	FOR /F "delims=" %%A IN ('findstr /C:".07" "!TMP_FOLDER!\Info.txt"') DO set "HDR_DVinput=YES" & set "DVprofile=7"
	FOR /F "delims=" %%A IN ('findstr /C:".06" "!TMP_FOLDER!\Info.txt"') DO set "HDR_DVinput=YES" & set "DVprofile=6"
	FOR /F "delims=" %%A IN ('findstr /C:".05" "!TMP_FOLDER!\Info.txt"') DO set "HDR_DVinput=YES" & set "DVprofile=5"
	FOR /F "delims=" %%A IN ('findstr /C:".04" "!TMP_FOLDER!\Info.txt"') DO set "HDR_DVinput=YES" & set "DVprofile=4"
	FOR /F "delims=" %%A IN ('findstr /C:".03" "!TMP_FOLDER!\Info.txt"') DO set "HDR_DVinput=YES" & set "DVprofile=3"
	
	::DEMUX RPU SAMPLE
	if "!HDR_DVinput!"=="YES" (
		if exist "!INFOSTREAM!" (
			"!FFMPEGpath!" -loglevel panic -i "!INFOSTREAM!" -c:v copy -to 1 -bsf:v hevc_metadata -f hevc - | "!DO_VI_TOOLpath!" extract-rpu -o "!TMP_FOLDER!\RPU.bin" - >nul 2>&1
			if exist "!TMP_FOLDER!\RPU.bin" (
				FOR /F "usebackq" %%A IN ('"!TMP_FOLDER!\RPU.bin"') DO set "RPUSIZE=%%~zA"
				if "!RPUSIZE!" NEQ "0" (
					set "RPU_SAMPLE_EXIST=TRUE"
				) else (
					if exist "!TMP_FOLDER!\RPU.bin" del "!TMP_FOLDER!\RPU.bin" >nul
					set "RPU_SAMPLE_EXIST=FALSE"
				)
			) else (
				set "RPU_SAMPLE_EXIST=FALSE"
			)
		)
		if "!RPU_SAMPLE_EXIST!"=="FALSE" (
			"!FFMPEGpath!" -loglevel panic -i "!INPUTFILE!" !DT! -c:v copy -to 1 -bsf:v hevc_metadata -f hevc - | "!DO_VI_TOOLpath!" extract-rpu -o "!TMP_FOLDER!\RPU.bin" - >nul 2>&1
			if exist "!TMP_FOLDER!\RPU.bin" (
				FOR /F "usebackq" %%A IN ('"!TMP_FOLDER!\RPU.bin"') DO set "RPUSIZE=%%~zA"
				if "!RPUSIZE!" NEQ "0" (
					set "RPU_SAMPLE_EXIST=TRUE"
				) else (
					set "RPU_SAMPLE_EXIST=FALSE"
				)
			) else (
				set "RPU_SAMPLE_EXIST=FALSE"
			)
		)
	)

	::BEGIN MEDIAINFO
	FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%Width%% "!INFOSTREAM!""') do set "WIDTH=%%A"
	FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%Height%% "!INFOSTREAM!""') do set "HEIGHT=%%A"
	set "RESOLUTION=!WIDTH!x!HEIGHT!"
	FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%Format%%^-%%BitDepth%%Bit^-%%ColorSpace%%^-%%ChromaSubsampling%% "!INFOSTREAM!""') do set "CODEC_NAME=%%A"
	FOR /F "tokens=1,2 delims= " %%A in ('""!MEDIAINFOpath!" --output=Video;%%FrameRate_String%% "!INPUTSTREAM!""') do (
		set "FRAMERATE=%%A"
		set "FRAMERATE_ORIG=%%A"
	)
	FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%FrameCount%% "!INPUTSTREAM!""') do set "FRAMES=%%A"
	::MAXCll and MAXFall
	FOR /F "tokens=1 delims= " %%A in ('""!MEDIAINFOpath!" --output=Video;%%MaxCLL%% "!INFOSTREAM!""') do set "MaxCLL=%%A"
	if not defined MaxCLL set "L6_EDITING=FALSE"
	FOR /F "tokens=1 delims= " %%A in ('""!MEDIAINFOpath!" --output=Video;%%MaxFALL%% "!INFOSTREAM!""') do set "MaxFALL=%%A"
	if not defined MaxFALL set "L6_EDITING=FALSE"
	::HDR METADATA
	FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%MasteringDisplay_ColorPrimaries%% "!INFOSTREAM!""') do set "MDCP=%%A"
	if not defined MDCP set "MDCP=N/A"
	FOR /F "delims=" %%A in ('""!MEDIAINFOpath!" --output=Video;%%MasteringDisplay_Luminance%% "!INFOSTREAM!""') do set "Luminance=%%A"
	if not defined Luminance (
		set "L6_EDITING=FALSE"
	) else (
		for /F "tokens=2" %%A in ("!Luminance!") do set MinDML=%%A
		for /F "tokens=* delims=0." %%A in ("!MinDML!") do set "MinDML=%%A"
		for /F "tokens=5" %%A in ("!Luminance!") do set MaxDML=%%A
	)

	if "!VIDEO_COUNT!"=="2" set "FRAMES=N/A DL"
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
	if "!HDR_HDR!"=="TRUE" set "HDR_Info=!HDR_HDRFormat!"
	if "!HDR_HDR10P!"=="TRUE" set "HDR_Info=HDR10, !HDR_HDRFormat!"
	if "!HDR_DV!"=="TRUE" set "HDR_Info=Dolby Vision Profile !HDR_DV_Profile!"
	if "!HDR_HDR!!HDR_DV!"=="TRUETRUE" set "HDR_Info=!HDR_HDRFormat!, Dolby Vision Profile !HDR_DV_Profile!"
	if "!HDR_HDR10P!!HDR_DV!"=="TRUETRUE" set "HDR_Info=HDR10, !HDR_HDRFormat!, Dolby Vision Profile !HDR_DV_Profile!"
	if "!ELFILE!"=="TRUE" set "HDR_Info=Dolby Vision Profile !HDR_DV_Profile! Enhanced Layer [EL]"

	if "%JSON_SUPPORT%!CJ_OK!"=="YESTRUE" (
		if "!HDR_DVinput!!XML_Exist!!RPU_exist!!EL_exist!!HDR10P_exist!"=="YESNONONONO" (
			%GREEN%
			echo Custom Edit Processing enabled.
			set "CUSTOM_ONLY=TRUE"
		) else (
			if "!XML_Exist!!RPU_exist!!EL_exist!" NEQ "NONONO" (
				%GREEN%
				echo Custom Edit Processing enabled.
			) else (
				%RED%
				echo.
				echo Custom Edit Processing enabled but video input file contains no Dolby Vision^^!
				%YELLOW%
				echo Use a video input file with Dolby Vision or insert RPU file / Enhanced Layer.
				echo.
				goto :EXIT
			)
		)
	)


	if "!DVprofile!!CUSTOM_ONLY!"=="7TRUE" (
		%RED%
		echo Custom Edit Files alone cannot processed with Dolby Vision Profile !HDR_DV_Profile!^^!
		%YELLOW%
		echo.
		echo Abort Operation now.
		echo.
		goto :EXIT
	)

	echo.	
	echo Analysing complete.
	echo.

	if exist "!TMP_FOLDER!\Info.txt" del "!TMP_FOLDER!\Info.txt">nul
	if exist "!TMP_FOLDER!\Info.mkv" del "!TMP_FOLDER!\Info.mkv">nul

	if "!RAW_FILE!"=="FALSE" (
		%CYAN%
		echo Analysing Video Borders. Please wait...
		"%~dp0tools\DetectBorders.exe" --ffmpeg-path="!FFMPEGpath!" --input-file="!INPUTFILE!" --log-file="!TMP_FOLDER!\Crop.txt"
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
		echo.
	)

	if exist "!ELSTREAM!" (
		%CYAN%
		echo Analysing DV EL Stream. Please wait...
		"!FFMPEGpath!" -loglevel panic -i "!ELSTREAM!" -c:v copy -bsf:v hevc_metadata -f hevc - | "!DO_VI_TOOLpath!" extract-rpu -o "!TMP_FOLDER!\RPU_EL.bin" - >nul 2>&1
		if exist "!TMP_FOLDER!\RPU_EL.bin" (
			%GREEN%
			set "RPUFILE=!TMP_FOLDER!\RPU_EL.bin"
			echo Done.
		) else (
			%YELLOW%
			echo Analysing failed.
		)
		echo.
	)
	if "!XML_exist!"=="YES" (
		if "!WIDTH!!HEIGHT!" NEQ "" set "CANVASSTRING= --canvas-width !WIDTH! --canvas-height !HEIGHT!"
		%CYAN%
		echo Analysing XML. Please wait...
		%WHITE%
		"!DO_VI_TOOLpath!" generate --xml "!XMLFILE!"!CANVASSTRING! --rpu-out "!TMP_FOLDER!\RPU_XML.bin" >nul 2>&1
		if exist "!TMP_FOLDER!\RPU_XML.bin" (
			%GREEN%
			set "RPUFILE=!TMP_FOLDER!\RPU_XML.bin"
			echo Done.
		) else (
			%RED%
			echo Analysing failed.
		)
		echo.
	)
) else (
	set "RPUFILE=!INPUTFILE!"
	echo.
)
if exist "!RPUFILE!" (
	%CYAN%
	echo Analysing DV RPU.bin. Please wait...
	"!DO_VI_TOOLpath!" info -i "!RPUFILE!" -f 01>"!TMP_FOLDER!\Info.json"
	"!DO_VI_TOOLpath!" info -s "!RPUFILE!">"!TMP_FOLDER!\RPUINFO.txt"
	if exist "!TMP_FOLDER!\Info.json" (
		%GREEN%
		echo Done.
		echo.
	) else (
		%YELLOW%
		echo Analysing failed.
		echo.
	)
)
if exist "!TMP_FOLDER!\RPUINFO.txt" (
	::FIND DV PROFILE
	FOR /F "delims=" %%A IN ('findstr /C:"Profile" "!TMP_FOLDER!\RPUINFO.txt"') DO set "RPU_DVP=%%A"
	if defined RPU_DVP (
		for /F "tokens=2 delims=:/() " %%A in ("!RPU_DVP!") do set "RPU_DVP=%%A"
	) else (
		set "RPU_DVP=N/A"
	)
	if "!RPU_DVP!"=="7" (
		FOR /F "delims=" %%A IN ('findstr /C:"Profile" "!TMP_FOLDER!\RPUINFO.txt"') DO set "RPU_DVSP=%%A"
		if defined RPU_DVSP (
			for /F "tokens=3 delims=:/ " %%A in ("!RPU_DVSP!") do set "RPU_DVSP= %%A"
		)
	)
	::FIND DM VERSION
	FOR /F "delims=" %%A IN ('findstr /C:"DM version" "!TMP_FOLDER!\RPUINFO.txt"') DO set "RPU_CMV=%%A"
	if defined RPU_CMV (
		for /F "tokens=3 delims=:/()" %%A in ("!RPU_CMV!") do set "RPU_CMV=%%A"
	) else (
		set "RPU_CMV=N/A"
	)
	::FIND DM FRAMES
	FOR /F "delims=" %%A IN ('findstr /C:"Frames" "!TMP_FOLDER!\RPUINFO.txt"') DO set "RPU_FRAMES=%%A"
	if defined RPU_FRAMES (
		for /F "tokens=2 delims=:/() " %%A in ("!RPU_FRAMES!") do set "RPU_FRAMES=%%A"
	) else (
		set "RPU_FRAMES=N/A"
	)
	FOR /F "delims=" %%A IN ('findstr /C:"L6 metadata:" "!TMP_FOLDER!\RPUINFO.txt"') DO set "L6METADATA=%%A"
	if defined L6METADATA (
		for /F "tokens=5 delims=:/ " %%A in ("!L6METADATA!") do set "RPUMinDML_L6=%%A"
		for /F "tokens=* delims=0." %%A in ("!RPUMinDML_L6!") do set "RPUMinDML_L6=%%A"
		if not defined RPUMinDML_L6 set "RPUMinDML_L6=!MinDML!"
		if not defined RPUMinDML_L6 set "V_EDITING=FALSE"
		for /F "tokens=6 delims=:/ " %%A in ("!L6METADATA!") do set "RPUMaxDML_L6=%%A"
		if not defined RPUMaxDML_L6 set "RPUMaxDML_L6=!MaxDML!"
		if not defined RPUMaxDML_L6 set "V_EDITING=FALSE"
		for /F "tokens=9 delims=:/ " %%A in ("!L6METADATA!") do set "RPUCLL_L6=%%A"
		if not defined RPUCLL_L6 set "RPUCLL_L6=!MaxCLL!"
		if not defined RPUCLL_L6 set "V_EDITING=FALSE"
		for /F "tokens=12 delims=:/ " %%A in ("!L6METADATA!") do set "RPUFALL_L6=%%A"
		if not defined RPUFALL_L6 set "RPUFALL_L6=!MaxFALL!"
		if not defined RPUFALL_L6 set "V_EDITING=FALSE"
	)
)

if exist "!TMP_FOLDER!\Info.json" (
	:: FIND CROPPING VALUES RPU
	FOR /F "tokens=2 delims=:, " %%A IN ('findstr /C:"active_area_left_offset" "!TMP_FOLDER!\Info.json"') DO set "RPU_INPUT_AA_LC=%%A"
	FOR /F "tokens=2 delims=:, " %%A IN ('findstr /C:"active_area_right_offset" "!TMP_FOLDER!\Info.json"') DO set "RPU_INPUT_AA_RC=%%A"
	FOR /F "tokens=2 delims=:, " %%A IN ('findstr /C:"active_area_top_offset" "!TMP_FOLDER!\Info.json"') DO set "RPU_INPUT_AA_TC=%%A"
	FOR /F "tokens=2 delims=:, " %%A IN ('findstr /C:"active_area_bottom_offset" "!TMP_FOLDER!\Info.json"') DO set "RPU_INPUT_AA_BC=%%A"
	FOR /F "delims=" %%A IN ('findstr /C:"source_primary_index" "!TMP_FOLDER!\Info.json"') DO set "L9_FOUND=%%A"
	if defined L9_FOUND (
		for /F "tokens=2 delims=:/ " %%A in ("!L9_FOUND!") do set "L9MDP=%%A"
		if "!L9MDP!"=="0" set "L9MDP=Display P3"
		if "!L9MDP!"=="2" set "L9MDP=BT.2020"
	)
	if not defined L9MDP set "L9MDP=!MDCP!"
	if not defined L9MDP set "V_EDITING=FALSE"
)

if "!AA_INPUT_LC!!AA_INPUT_TC!!AA_INPUT_RC!!AA_INPUT_BC!"=="" (
	set "RPU_AA_LC=!RPU_INPUT_AA_LC!"
	set "RPU_AA_TC=!RPU_INPUT_AA_TC!"
	set "RPU_AA_RC=!RPU_INPUT_AA_RC!"
	set "RPU_AA_BC=!RPU_INPUT_AA_BC!"
)

if "!AA_INPUT_LC!!AA_INPUT_TC!!AA_INPUT_RC!!AA_INPUT_BC!"=="!RPU_INPUT_AA_LC!!RPU_INPUT_AA_TC!!RPU_INPUT_AA_RC!!RPU_INPUT_AA_BC!" set "RPU_AA_String=[LEAVE UNTOUCHED]"
if "!AA_INPUT_LC!!AA_INPUT_TC!!AA_INPUT_RC!!AA_INPUT_BC!"=="" set "RPU_AA_String=[LEAVE UNTOUCHED]"

if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul

TIMEOUT 3 /NOBREAK>nul

if "!DV_INJ!!HDR10P_INJ!"=="TRUEFALSE" goto :DV_MENU
if "!DV_INJ!!HDR10P_INJ!"=="FALSETRUE" goto :HDR10P_MENU
if "!DV_INJ!!HDR10P_INJ!"=="TRUETRUE" goto :DV_MENU
if "!RPU_FILE!"=="TRUE" goto :RPU_MENU
if "!JSON_SUPPORT!!CJ_OK!!CUSTOM_ONLY!"=="YESTRUETRUE" goto :CUSTOM_ONLY_MENU

goto :EXIT

:CUSTOM_ONLY_MENU
if "!RAW_FILE!"=="TRUE" set "MUXINMKV=NO" & set "MUXINMP4=NO"
set "HEADER_FILENAME=!INPUTFILENAME!_[Custom_Edited]"
set "HEADER_EXT=.hevc"
if "%MUXINMKV%%MKVExtract%"=="YESTRUE" set "%MUXINMP4%"=="NO" & set "HEADER_EXT=.mkv"
if "%MUXINMP4%%MP4Extract%"=="YESTRUE" set "%MUXINMKV%"=="NO" & set "HEADER_EXT=.mp4"
set "RPU_AA_String=[LEAVE UNTOUCHED]"
cls
%GREEN%
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool INJECTOR
echo                                               - CUSTOM EDIT INJECTOR -
%WHITE%
echo                                         ====================================
echo.
echo.
if "!CJ_OK!"=="TRUE" (
	echo  == JSON INPUT ==========================================================================================================
	echo.
	%CYAN%
	echo JSON File  = [!CJ_Filename!!CJ_Fileext!]
	echo.
)
%WHITE%
echo  == VIDEO INPUT =========================================================================================================
echo.
%CYAN%
echo Filename   = [!INPUTFILENAME!!INPUTFILEEXT!]
echo Video Info = [Resolution = %RESOLUTION%] [Codec = %CODEC_NAME%] [Frames = %FRAMES%] [FPS = !FRAMERATE_ORIG!]
echo HDR Info   = [!HDR_INFO!]
echo.
%WHITE%
echo  == VIDEO OUTPUT ========================================================================================================
echo.
%YELLOW%
echo Filename   = [!HEADER_FILENAME!!HEADER_EXT!]
%WHITE%
echo.
echo  == MENU ================================================================================================================
echo.
echo 1. Change FPS          : [!CHGFPS!]
if "!MKVExtract!"=="TRUE" echo 2. Mux Stream in MKV   : [!MUXINMKV!]
if "!MP4Extract!"=="TRUE" echo 2. Mux Stream in MP4   : [!MUXINMP4!]
echo.
echo.
echo S. START
echo.
%GREEN%
echo Change Settings and press [S] to start Injecting^^!
if "!RAW_FILE!"=="FALSE" (
	CHOICE /C 12S /N /M "Select a Letter 1,2,[S]tart"
) else (
	CHOICE /C 1S /N /M "Select a Letter 1,[S]tart"
)
if "!RAW_FILE!"=="FALSE" (
	if "%ERRORLEVEL%"=="3" goto :DV_BEGIN
	if "%ERRORLEVEL%"=="2" (
		if "!RAW_FILE!"=="TRUE" (
			goto :HDR10P_BEGIN
		) else (
			if "%MUXINMP4%"=="NO" set "MUXINMP4=YES"
			if "%MUXINMP4%"=="YES" set "MUXINMP4=NO"
			if "%MUXINMKV%"=="NO" set "MUXINMKV=YES"
			if "%MUXINMKV%"=="YES" set "MUXINMKV=NO"
		)
	)
	if "%ERRORLEVEL%"=="1" (
		if "%CHGFPS%"=="NO" set "CHGFPS=23.976" & set "FRAMERATE=23.976"
		if "%CHGFPS%"=="23.976" set "CHGFPS=24.000" & set "FRAMERATE=24.000"
		if "%CHGFPS%"=="24.000" set "CHGFPS=25.000" & set "FRAMERATE=25.000"
		if "%CHGFPS%"=="25.000" set "CHGFPS=NO" & set "FRAMERATE=!FRAMERATE_ORIG!"
	)		
) else (
	if "%ERRORLEVEL%"=="1" goto :HDR10P_BEGIN
	if "%ERRORLEVEL%"=="1" (
	if "%CHGFPS%"=="NO" set "CHGFPS=23.976" & set "FRAMERATE=23.976"
	if "%CHGFPS%"=="23.976" set "CHGFPS=24.000" & set "FRAMERATE=24.000"
	if "%CHGFPS%"=="24.000" set "CHGFPS=25.000" & set "FRAMERATE=25.000"
	if "%CHGFPS%"=="25.000" set "CHGFPS=NO" & set "FRAMERATE=!FRAMERATE_ORIG!"
	)
)
goto :CUSTOM_ONLY_MENU

:RPU_MENU
set "HEADER_FILENAME=!INPUTFILENAME!_[EDITED]"
set "HEADER_EXT=.bin"
set "HEADER_RPU_AA_String=call :colortxt 0B "Borders    = [LEFT=%RPU_INPUT_AA_LC% px], [TOP=%RPU_INPUT_AA_TC% px], [RIGHT=%RPU_INPUT_AA_RC% px], [BOTTOM=%RPU_INPUT_AA_BC% px]" /n"
if "%RPU_INPUT_AA_LC%%RPU_INPUT_AA_TC%%RPU_INPUT_AA_RC%%RPU_INPUT_AA_BC%"=="" set "HEADER_RPU_AA_String=call :colortxt 0B "Borders    = [" & call :colortxt 06 "BORDERS NOT SET IN RPU" & call :colortxt 0B "]" /n"
set "HEADER_RPU_OUTPUT_String=call :colortxt 0E "Borders    = [LEFT=!RPU_AA_LC! px], [TOP=!RPU_AA_TC! px], [RIGHT=!RPU_AA_RC! px], [BOTTOM=!RPU_AA_BC! px]" /n"
if "!RPU_AA_String!"=="[LEAVE UNTOUCHED]" set "HEADER_RPU_OUTPUT_String=call :colortxt 0E "Borders    = [" & call :colortxt 0F "LEAVE UNTOUCHED" & call :colortxt 0E "]" /n"

cls
%GREEN%
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool INJECTOR
echo                                                 - RPU JSON INJECTOR -
%WHITE%
echo                                         ====================================
echo.
echo.
if "!CJ_OK!"=="TRUE" (
	echo  == JSON INPUT ==========================================================================================================
	echo.
	%CYAN%
	echo JSON File  = [!CJ_Filename!!CJ_Fileext!]
	echo.
)
%WHITE%
echo  == RPU INPUT ===========================================================================================================
echo.
%CYAN%
echo Filename   = [!INPUTFILENAME!!INPUTFILEEXT!]
echo RPU Info   = [Dolby Vision Profile !RPU_DVP!!RPU_DVSP!] [DM = !RPU_CMV!] [Frames = !RPU_FRAMES!]
%HEADER_RPU_AA_String%
echo.
%WHITE%
echo  == FILE OUTPUT =========================================================================================================
echo.
%YELLOW%
echo Filename   = [!HEADER_FILENAME!!HEADER_EXT!]
echo RPU Info   = [Dolby Vision Profile !RPU_DVP!!RPU_DVSP!] [DM = !RPU_CMV!] [Frames = !RPU_FRAMES!]	
%HEADER_RPU_OUTPUT_String%
echo Delay      = [!DELAY! FRAMES]
echo.
%WHITE%
echo  == MENU ================================================================================================================
echo.
echo 1. DELAY               : [!DELAY! FRAMES]
echo.
call :colortxt 0F "E. EDIT ACTIVE AREA" & call :colortxt 0E "*" & call :colortxt 0E "   *Setting Crop Values. DISCARD set Borders to [" & call :colortxt 0F "LEAVE UNTOUCHED" & call :colortxt 0E "]." /n
%WHITE%
echo.
echo S. START
echo.
%GREEN%
echo Change Settings and press [S] to start Injecting^^!
CHOICE /C 1ES /N /M "Select a Letter 1,[E]dit,[S]tart"

if "%ERRORLEVEL%"=="3" goto :RPU_BEGIN
if "%ERRORLEVEL%"=="2" call :AA_AREA
if "%ERRORLEVEL%"=="1" (
	echo.
	%WHITE%
	echo Type in the RPU DELAY, which will be added.
	echo Importend^^! Set "-" for negative Delay.
	echo Example: For cutting 3 Frames type "-3" and press Enter^^!
	echo.
	set /p "DELAY=Type in the Frames and press [ENTER]: "
)
goto :RPU_MENU

:HDR10P_MENU
if "!RAW_FILE!"=="TRUE" set "MUXINMKV=NO" & set "MUXINMP4=NO"
set "HEADER_FILENAME=!INPUTFILENAME!_[HDR10+]"
set "HEADER_EXT=.hevc"
if "%MUXINMKV%%MKVExtract%"=="YESTRUE" set "%MUXINMP4%"=="NO" & set "HEADER_EXT=.mkv"
if "%MUXINMP4%%MP4Extract%"=="YESTRUE" set "%MUXINMKV%"=="NO" & set "HEADER_EXT=.mp4"
cls
%GREEN%
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool INJECTOR
echo                                                 - HDR10+ INJECTOR -
%WHITE%
echo                                         ====================================
echo.
echo.
if "!CJ_OK!"=="TRUE" (
	echo  == JSON INPUT ==========================================================================================================
	echo.
	%CYAN%
	echo JSON File  = [!CJ_Filename!!CJ_Fileext!]
	echo.
)
%WHITE%
echo  == VIDEO INPUT =========================================================================================================
echo.
%CYAN%
echo Filename   = [!INPUTFILENAME!!INPUTFILEEXT!]
echo Video Info = [Resolution = %RESOLUTION%] [Codec = %CODEC_NAME%] [Frames = %FRAMES%] [FPS = !FRAMERATE_ORIG!]
echo HDR Info   = [!HDR_INFO!]
echo.
%WHITE%
echo  == VIDEO OUTPUT ========================================================================================================
echo.
%YELLOW%
echo Filename   = [!HEADER_FILENAME!!HEADER_EXT!]
%WHITE%
echo.
echo  == MENU ================================================================================================================
echo.
echo 1. DELAY               : [!DELAY! FRAMES]
echo 2. Change FPS          : [!CHGFPS!]
if "!MKVExtract!"=="TRUE" echo 3. Mux Stream in MKV   : [!MUXINMKV!]
if "!MP4Extract!"=="TRUE" echo 3. Mux Stream in MP4   : [!MUXINMP4!]
echo.
echo.
echo S. START
echo.
%GREEN%
echo Change Settings and press [S] to start Injecting^^!
if "!RAW_FILE!"=="FALSE" (
	CHOICE /C 123S /N /M "Select a Letter 1,2,3,[S]tart"
) else (
	CHOICE /C 12S /N /M "Select a Letter 1,2,[S]tart"
)
if "!RAW_FILE!"=="FALSE" (
	if "%ERRORLEVEL%"=="4" goto :HDR10P_BEGIN
	if "%ERRORLEVEL%"=="3" (
		if "!RAW_FILE!"=="TRUE" (
			goto :HDR10P_BEGIN
		) else (
			if "%MUXINMP4%"=="NO" set "MUXINMP4=YES"
			if "%MUXINMP4%"=="YES" set "MUXINMP4=NO"
			if "%MUXINMKV%"=="NO" set "MUXINMKV=YES"
			if "%MUXINMKV%"=="YES" set "MUXINMKV=NO"
		)
	)
	if "%ERRORLEVEL%"=="2" (
		if "%CHGFPS%"=="NO" set "CHGFPS=23.976" & set "FRAMERATE=23.976"
		if "%CHGFPS%"=="23.976" set "CHGFPS=24.000" & set "FRAMERATE=24.000"
		if "%CHGFPS%"=="24.000" set "CHGFPS=25.000" & set "FRAMERATE=25.000"
		if "%CHGFPS%"=="25.000" set "CHGFPS=NO" & set "FRAMERATE=!FRAMERATE_ORIG!"
	)		
	if "%ERRORLEVEL%"=="1" (
		echo.
		%WHITE%
		echo Type in the JSON HDR10+ DELAY, which will be added.
		echo Importend^^! Set "-" for negative Delay.
		echo Example: For cutting 3 Frames type "-3" and press Enter^^!
		echo.
		set /p "DELAY=Type in the Frames and press [ENTER]: "
	)
) else (
	if "%ERRORLEVEL%"=="3" goto :HDR10P_BEGIN
	if "%ERRORLEVEL%"=="2" (
	if "%CHGFPS%"=="NO" set "CHGFPS=23.976" & set "FRAMERATE=23.976"
	if "%CHGFPS%"=="23.976" set "CHGFPS=24.000" & set "FRAMERATE=24.000"
	if "%CHGFPS%"=="24.000" set "CHGFPS=25.000" & set "FRAMERATE=25.000"
	if "%CHGFPS%"=="25.000" set "CHGFPS=NO" & set "FRAMERATE=!FRAMERATE_ORIG!"
	)
	if "%ERRORLEVEL%"=="1" (
		echo.
		%WHITE%
		echo Type in the JSON HDR10+ DELAY, which will be added.
		echo Importend^^! Set "-" for negative Delay.
		echo Example: For cutting 3 Frames type "-3" and press Enter^^!
		echo.
		set /p "DELAY=Type in the Frames and press [ENTER]: "
	)
)
goto :HDR10P_MENU

:DV_MENU
if "!RAW_FILE!"=="TRUE" set "MUXINMKV=NO" & set "MUXINMP4=NO"
if "!HDR10P_File!" NEQ "NONE" set "REMHDR10P=NO"
if "%RPU_exist%"=="YES" (
	set "HEADER_FILENAME=!INPUTFILENAME!_[BL+RPU]"
	if "!HDR10P_File!" NEQ "NONE" set "HEADER_FILENAME=!INPUTFILENAME!_[BL+RPU+HDR10+]"
	if "!HDR_HDR10P!!REMHDR10P!"=="TRUENO" set "HEADER_FILENAME=!INPUTFILENAME!_[BL+RPU+HDR10+]"
)
if "%XML_exist%"=="YES" (
	set "HEADER_FILENAME=!INPUTFILENAME!_[BL+RPU]"
	if "!HDR10P_File!" NEQ "NONE" set "HEADER_FILENAME=!INPUTFILENAME!_[BL+RPU+HDR10+]"
	if "!HDR_HDR10P!!REMHDR10P!"=="TRUENO" set "HEADER_FILENAME=!INPUTFILENAME!_[BL+RPU+HDR10+]"
)
if "!EL_exist!"=="YES" (
	if "!EL_INPUT!"=="TRUE" (
		set "HEADER_FILENAME=!INPUTFILENAME!_[EL+RPU]"
		if "!HDR10P_File!" NEQ "NONE" set "HEADER_FILENAME=!INPUTFILENAME!_[EL+RPU+HDR10+]"
		if "!HDR_HDR10P!!REMHDR10P!"=="TRUENO" set "HEADER_FILENAME=!INPUTFILENAME!_[EL+RPU+HDR10+]"
	) else (
		set "HEADER_FILENAME=!INPUTFILENAME!_[BL+EL+RPU]"
		if "!HDR10P_File!" NEQ "NONE" set "HEADER_FILENAME=!INPUTFILENAME!_[BL+EL+RPU+HDR10+]"
		if "!HDR_HDR10P!!REMHDR10P!"=="TRUENO" set "HEADER_FILENAME=!INPUTFILENAME!_[BL+EL+RPU+HDR10+]"	
	)
)
set "HEADER_EXT=.hevc"
if "!MUXINMKV!!MKVExtract!"=="YESTRUE" set "!MUXINMP4!"=="NO" & set "HEADER_EXT=.mkv"
if "!MUXINMP4!!MP4Extract!"=="YESTRUE" set "!MUXINMKV!"=="NO" & set "HEADER_EXT=.mp4"

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
echo                                              Dolby Vision Tool INJECTOR
if "!HDR10P_OK!"=="TRUE" (
	echo                                          - DOLBY VISION / HDR10 +INJECTOR -
) else (
	echo                                              - DOLBY VISION INJECTOR -
)
%WHITE%
echo                                         ====================================
echo.
echo.
if "!CJ_OK!"=="TRUE" (
	echo  == JSON INPUT ==========================================================================================================
	echo.
	%CYAN%
	echo JSON File  = [!CJ_Filename!!CJ_Fileext!]
	echo.
)
if "!EL_INPUT!"=="FALSE" (
	%WHITE%
	echo  == VIDEO INPUT =========================================================================================================
	echo.
	%CYAN%
	echo Filename   = [!INPUTFILENAME!!INPUTFILEEXT!]
	echo Video Info = [Resolution = !RESOLUTION!] [Codec = !CODEC_NAME!] [Frames = !FRAMES!] [FPS = !FRAMERATE_ORIG!]
	echo HDR Info   = [!HDR_INFO!]
	%AA_String%
	echo.
)
if "!XML_exist!!EL_exist!"=="YESNO" (
	%WHITE%
	echo  == XML INPUT ===========================================================================================================
	echo.
	%CYAN%
	echo Filename   = [!DV_Filename!!DV_Fileext!]
	echo RPU Info   = [Dolby Vision Profile !RPU_DVP!!RPU_DVSP!] [DM = !RPU_CMV!] [Frames = !RPU_FRAMES!]
	%HEADER_RPU_AA_String%
	echo.
)
if "!RPU_exist!!EL_exist!"=="YESNO" (
	%WHITE%
	echo  == RPU INPUT ===========================================================================================================
	echo.
	%CYAN%
	echo Filename   = [!DV_Filename!!DV_Fileext!]
	echo RPU Info   = [Dolby Vision Profile !RPU_DVP!!RPU_DVSP!] [DM = !RPU_CMV!] [Frames = !RPU_FRAMES!]
	%HEADER_RPU_AA_String%
	echo.
) 
if "!XML_exist!!RPU_exist!!EL_exist!"=="NONOYES" (
	%WHITE%
	echo  == EL INPUT ============================================================================================================
	echo.
	%CYAN%
	echo Filename   = [!DV_Filename!!DV_Fileext!]
	echo EL Info    = [Dolby Vision Profile !RPU_DVP!!RPU_DVSP!] [DM = !RPU_CMV!] [Frames = !RPU_FRAMES!]
	%HEADER_RPU_AA_String%
	echo.
)
if "!XML_exist!!EL_exist!"=="YESNO" (
	%WHITE%
	echo  == FILE OUTPUT =========================================================================================================
	echo.
	%YELLOW%
	echo Filename   = [!HEADER_FILENAME!!HEADER_EXT!]
	echo RPU Info   = [Dolby Vision Profile !RPU_DVP!!RPU_DVSP!] [DM = !RPU_CMV!] [Frames = !FRAMES!]	
	%HEADER_RPU_OUTPUT_String%
	echo Delay      = [!DELAY! FRAMES]
	echo.
)
if "!RPU_exist!!EL_exist!"=="YESNO" (
	echo.
	%WHITE%
	echo  == FILE OUTPUT =========================================================================================================
	echo.
	%YELLOW%
	echo Filename   = [!HEADER_FILENAME!!HEADER_EXT!]
	echo RPU Info   = [Dolby Vision Profile !RPU_DVP!!RPU_DVSP!] [DM = !RPU_CMV!] [Frames = !FRAMES!]	
	%HEADER_RPU_OUTPUT_String%
	echo Delay      = [!DELAY! FRAMES]
	echo.
)
if "!XML_exist!!RPU_exist!!EL_exist!"=="NONOYES" (
	echo.
	%WHITE%
	echo  == FILE OUTPUT =========================================================================================================
	echo.
	%YELLOW%
	echo Filename   = [!HEADER_FILENAME!!HEADER_EXT!]
	echo EL Info    = [Dolby Vision Profile !RPU_DVP!!RPU_DVSP!] [DM = !RPU_CMV!] [Frames = !FRAMES!] [FPS = !FRAMERATE!]
	%HEADER_RPU_OUTPUT_String%
	echo.
)
if "!DV5!"=="TRUE" (
	if not "!RPU_DVP!"=="5" (
		echo  == ERROR ===============================================================================================================
		echo.
		%RED%
		echo Found DV Profile 5 VIDEO STREAM, but the RPU has Profile !RPU_DVP!!RPU_DVSP!.
		echo.
		goto :EXIT
	)
)
if "!DV5!"=="FALSE" (
	if "!RPU_DVP!"=="5" (
		echo  == ERROR ===============================================================================================================
		echo.
		%RED%
		echo Found !HDR_INFO! VIDEO STREAM, 
		echo but the RPU has Profile 5.
		echo.
		goto :EXIT
	)
)
%WHITE%
echo  == MENU ================================================================================================================
echo.
if not exist "!ELSTREAM!" echo 1. DELAY               : [!DELAY! FRAMES]
echo 2. Change FPS          : [!CHGFPS!]
call :colortxt 0F "3. Video HDR to RPU L6 : [!L6EDITING!]" & call :colortxt 0E "*" & call :colortxt 0E "   *Change L6 Metadata in RPU." /n
call :colortxt 0F "4. RPU L6 to Video HDR : [!VEDITING!]" & call :colortxt 0E "*" & call :colortxt 0E "   *Change HDR Metadata in Video." /n
if "!HDR10P!"=="TRUE" echo 5. Remove HDR10+       : [!REMHDR10P!]
if "!MKVExtract!"=="TRUE" echo 6. MUX STREAM IN MKV   : [!MUXINMKV!]
if "!MP4Extract!"=="TRUE" echo 6. MUX STREAM IN MP4   : [!MUXINMP4!]
if exist "!ELSTREAM!" call :colortxt 0F "7. MUX EL IN BL        : [!MUXP7SETTING!]" & call :colortxt 0E "*" & call :colortxt 0E " *Create Profile 7 Single Layer File." /n
echo.
call :colortxt 0F "E. EDIT ACTIVE AREA" & call :colortxt 0E "*" & call :colortxt 0E "   *Setting Crop Values. DISCARD set Borders to [" & call :colortxt 0F "LEAVE UNTOUCHED" & call :colortxt 0E "]." /n
%WHITE%
echo.
echo S. START
echo.
%GREEN%
if exist "!ELSTREAM!" (
	if "%HDR10P%"=="TRUE" (
		if "!RAW_FILE!"=="FALSE" (
			echo Change Settings and press [S] to start Injecting^^!
			CHOICE /C 234567ES /N /M "Select a Letter 2,3,4,5,6,7,[E]dit,[S]tart"
		) else (
			echo Change Settings and press [S] to start Injecting^^!
			CHOICE /C 23457ES /N /M "Select a Letter 2,3,4,5,7,[E]dit,[S]tart"
		)
	) else (
		if "!RAW_FILE!"=="FALSE" (
			echo Change Settings and press [S] to start Injecting^^!
			CHOICE /C 23467ES /N /M "Select a Letter 2,3,4,6,7,[E]dit,[S]tart"
		) else (
			echo Change Settings and press [S] to start Injecting^^!
			CHOICE /C 2347ES /N /M "Select a Letter 2,3,4,7,[E]dit,[S]tart"
		)
	)
) else (
	if "%HDR10P%"=="TRUE" (
		if "!RAW_FILE!"=="FALSE" (
			echo Change Settings and press [S] to start Injecting^^!
			CHOICE /C 123456ES /N /M "Select a Letter 1,2,3,4,5,6,[E]dit,[S]tart"
		) else (
			echo Change Settings and press [S] to start Injecting^^!
			CHOICE /C 12345ES /N /M "Select a Letter 1,2,3,4,5,[E]dit,[S]tart"
		)
	) else (
		if "!RAW_FILE!"=="FALSE" (
			echo Change Settings and press [S] to start Injecting^^!
			CHOICE /C 12346ES /N /M "Select a Letter 1,2,3,4,6,[E]dit,[S]tart"
		) else (
			echo Change Settings and press [S] to start Injecting^^!
			CHOICE /C 1234ES /N /M "Select a Letter 1,2,3,4,[E]dit,[S]tart"
		)
	)
)

if exist "!ELSTREAM!" (
	if "%HDR10P%"=="TRUE" (
		if "!RAW_FILE!"=="FALSE" (
			if "%ERRORLEVEL%"=="8" goto :DV_BEGIN
			if "%ERRORLEVEL%"=="7" call :AA_AREA
			if "%ERRORLEVEL%"=="6" (
				if "%MUXP7SETTING%"=="STANDARD" set "MUXP7SETTING=makeMKV"			
				if "%MUXP7SETTING%"=="makeMKV" set "MUXP7SETTING=Disable AUD NALUs"
				if "%MUXP7SETTING%"=="Disable AUD NALUs" set "MUXP7SETTING=STANDARD"
			)
			if "%ERRORLEVEL%"=="5" (
				if "%MUXINMKV%"=="NO" set "MUXINMKV=YES"
				if "%MUXINMKV%"=="YES" set "MUXINMKV=NO"
				if "%MUXINMP4%"=="NO" set "MUXINMP4=YES"
				if "%MUXINMP4%"=="YES" set "MUXINMP4=NO"
			)
			if "%ERRORLEVEL%"=="4" (
				if "%REMHDR10P%"=="NO" (
					set "REMHDR10P=YES"
				)
				if "%REMHDR10P%"=="YES" (
					set "REMHDR10P=NO"
				)
			)
			if "%ERRORLEVEL%"=="3" (
				if "%VEDITING%"=="NO" (
					set "VEDITING=YES"
					set "L6EDITING=NO"
				)
				if "%VEDITING%"=="YES" (
					set "VEDITING=NO"
				)
			)
			if "%ERRORLEVEL%"=="2" (
				if "%L6EDITING%"=="NO" (
					set "L6EDITING=YES"
					set "VEDITING=NO"
				)
				if "%L6EDITING%"=="YES" (
					set "L6EDITING=NO"
				)
			)
			if "%ERRORLEVEL%"=="1" (
				if "%CHGFPS%"=="NO" set "CHGFPS=23.976" & set "FRAMERATE=23.976"
				if "%CHGFPS%"=="23.976" set "CHGFPS=24.000" & set "FRAMERATE=24.000"
				if "%CHGFPS%"=="24.000" set "CHGFPS=25.000" & set "FRAMERATE=25.000"
				if "%CHGFPS%"=="25.000" set "CHGFPS=NO" & set "FRAMERATE=!FRAMERATE_ORIG!"
			)				
		) else (
			if "%ERRORLEVEL%"=="7" goto :DV_BEGIN
			if "%ERRORLEVEL%"=="6" call :AA_AREA
			if "%ERRORLEVEL%"=="5" (
				if "%MUXP7SETTING%"=="STANDARD" set "MUXP7SETTING=makeMKV"			
				if "%MUXP7SETTING%"=="makeMKV" set "MUXP7SETTING=Disable AUD NALUs"
				if "%MUXP7SETTING%"=="Disable AUD NALUs" set "MUXP7SETTING=STANDARD"
			)
			if "%ERRORLEVEL%"=="4" (
				if "%REMHDR10P%"=="NO" (
					set "REMHDR10P=YES"
				)		
				if "%REMHDR10P%"=="YES" (
					set "REMHDR10P=NO"
				)
			)
			if "%ERRORLEVEL%"=="3" (
				if "%VEDITING%"=="NO" (
					set "VEDITING=YES"
					set "L6EDITING=NO"
				)
				if "%VEDITING%"=="YES" (
					set "VEDITING=NO"
				)
			)
			if "%ERRORLEVEL%"=="2" (
				if "%L6EDITING%"=="NO" (
					set "L6EDITING=YES"
					set "VEDITING=NO"
				)
				if "%L6EDITING%"=="YES" (
					set "L6EDITING=NO"
				)
			)
			if "%ERRORLEVEL%"=="1" (
				if "%CHGFPS%"=="NO" set "CHGFPS=23.976" & set "FRAMERATE=23.976"
				if "%CHGFPS%"=="23.976" set "CHGFPS=24.000" & set "FRAMERATE=24.000"
				if "%CHGFPS%"=="24.000" set "CHGFPS=25.000" & set "FRAMERATE=25.000"
				if "%CHGFPS%"=="25.000" set "CHGFPS=NO" & set "FRAMERATE=!FRAMERATE_ORIG!"
			)
		)
	) else (
		if "!RAW_FILE!"=="FALSE" (
			if "%ERRORLEVEL%"=="7" goto :DV_BEGIN
			if "%ERRORLEVEL%"=="6" call :AA_AREA
			if "%ERRORLEVEL%"=="5" (
				if "%MUXP7SETTING%"=="STANDARD" set "MUXP7SETTING=makeMKV"			
				if "%MUXP7SETTING%"=="makeMKV" set "MUXP7SETTING=Disable AUD NALUs"
				if "%MUXP7SETTING%"=="Disable AUD NALUs" set "MUXP7SETTING=STANDARD"
			)
			if "%ERRORLEVEL%"=="4" (
				if "%MUXINMKV%"=="NO" set "MUXINMKV=YES"
				if "%MUXINMKV%"=="YES" set "MUXINMKV=NO"
				if "%MUXINMP4%"=="NO" set "MUXINMP4=YES"
				if "%MUXINMP4%"=="YES" set "MUXINMP4=NO"
			)
			if "%ERRORLEVEL%"=="3" (
				if "%VEDITING%"=="NO" (
					set "VEDITING=YES"
					set "L6EDITING=NO"
				)
				if "%VEDITING%"=="YES" (
					set "VEDITING=NO"
				)
			)
			if "%ERRORLEVEL%"=="2" (
				if "%L6EDITING%"=="NO" (
					set "L6EDITING=YES"
					set "VEDITING=NO"
				)
				if "%L6EDITING%"=="YES" (
					set "L6EDITING=NO"
				)
			)
			if "%ERRORLEVEL%"=="1" (
				if "%CHGFPS%"=="NO" set "CHGFPS=23.976" & set "FRAMERATE=23.976"
				if "%CHGFPS%"=="23.976" set "CHGFPS=24.000" & set "FRAMERATE=24.000"
				if "%CHGFPS%"=="24.000" set "CHGFPS=25.000" & set "FRAMERATE=25.000"
				if "%CHGFPS%"=="25.000" set "CHGFPS=NO" & set "FRAMERATE=!FRAMERATE_ORIG!"
			)
		) else (
			if "%ERRORLEVEL%"=="6" goto :DV_BEGIN
			if "%ERRORLEVEL%"=="5" call :AA_AREA	
			if "%ERRORLEVEL%"=="4" (
				if "%MUXP7SETTING%"=="STANDARD" set "MUXP7SETTING=makeMKV"			
				if "%MUXP7SETTING%"=="makeMKV" set "MUXP7SETTING=Disable AUD NALUs"
				if "%MUXP7SETTING%"=="Disable AUD NALUs" set "MUXP7SETTING=STANDARD"
			)
			if "%ERRORLEVEL%"=="3" (
				if "%VEDITING%"=="NO" (
					set "VEDITING=YES"
					set "L6EDITING=NO"
				)
				if "%VEDITING%"=="YES" (
					set "VEDITING=NO"
				)
			)
			if "%ERRORLEVEL%"=="2" (
				if "%L6EDITING%"=="NO" (
					set "L6EDITING=YES"
					set "VEDITING=NO"
				)
				if "%L6EDITING%"=="YES" (
					set "L6EDITING=NO"
				)
			)
			if "%ERRORLEVEL%"=="1" (
				if "%CHGFPS%"=="NO" set "CHGFPS=23.976" & set "FRAMERATE=23.976"
				if "%CHGFPS%"=="23.976" set "CHGFPS=24.000" & set "FRAMERATE=24.000"
				if "%CHGFPS%"=="24.000" set "CHGFPS=25.000" & set "FRAMERATE=25.000"
				if "%CHGFPS%"=="25.000" set "CHGFPS=NO" & set "FRAMERATE=!FRAMERATE_ORIG!"
			)
		)
	)
) else (
	if "%HDR10P%"=="TRUE" (
		if "!RAW_FILE!"=="FALSE" (
			if "%ERRORLEVEL%"=="8" goto :DV_BEGIN
			if "%ERRORLEVEL%"=="7" call :AA_AREA
			if "%ERRORLEVEL%"=="6" (
				if "%MUXINMKV%"=="NO" set "MUXINMKV=YES"
				if "%MUXINMKV%"=="YES" set "MUXINMKV=NO"
				if "%MUXINMP4%"=="NO" set "MUXINMP4=YES"
				if "%MUXINMP4%"=="YES" set "MUXINMP4=NO"
			)	
			if "%ERRORLEVEL%"=="5" (
				if "%REMHDR10P%"=="NO" (
					set "REMHDR10P=YES"
				)		
				if "%REMHDR10P%"=="YES" (
					set "REMHDR10P=NO"
				)
			)
			if "%ERRORLEVEL%"=="4" (
				if "%VEDITING%"=="NO" (
					set "VEDITING=YES"
					set "L6EDITING=NO"
				)
				if "%VEDITING%"=="YES" (
					set "VEDITING=NO"
				)
			)
			if "%ERRORLEVEL%"=="3" (
				if "%L6EDITING%"=="NO" (
					set "L6EDITING=YES"
					set "VEDITING=NO"
				)
				if "%L6EDITING%"=="YES" (
					set "L6EDITING=NO"
				)
			)
			if "%ERRORLEVEL%"=="2" (
				if "%CHGFPS%"=="NO" set "CHGFPS=23.976" & set "FRAMERATE=23.976"
				if "%CHGFPS%"=="23.976" set "CHGFPS=24.000" & set "FRAMERATE=24.000"
				if "%CHGFPS%"=="24.000" set "CHGFPS=25.000" & set "FRAMERATE=25.000"
				if "%CHGFPS%"=="25.000" set "CHGFPS=NO" & set "FRAMERATE=!FRAMERATE_ORIG!"
			)
			if "%ERRORLEVEL%"=="1" (
				echo.
				%WHITE%
				echo Type in the RPU DELAY, which will be added.
				echo Importend^^! Set "-" for negative Delay.
				echo Example: For cutting 3 Frames type "-3" and press Enter^^!
				echo.
				set /p "DELAY=Type in the Frames and press [ENTER]: "
			)
		) else (
			if "%ERRORLEVEL%"=="7" goto :DV_BEGIN
			if "%ERRORLEVEL%"=="6" call :AA_AREA
			if "%ERRORLEVEL%"=="5" (
				if "%REMHDR10P%"=="NO" (
					set "REMHDR10P=YES"
				)		
				if "%REMHDR10P%"=="YES" (
					set "REMHDR10P=NO"
				)
			)
			if "%ERRORLEVEL%"=="4" (
				if "%VEDITING%"=="NO" (
					set "VEDITING=YES"
					set "L6EDITING=NO"
				)
				if "%VEDITING%"=="YES" (
					set "VEDITING=NO"
				)
			)
			if "%ERRORLEVEL%"=="3" (
				if "%L6EDITING%"=="NO" (
					set "L6EDITING=YES"
					set "VEDITING=NO"
				)
				if "%L6EDITING%"=="YES" (
					set "L6EDITING=NO"
				)
			)
			if "%ERRORLEVEL%"=="2" (
				if "%CHGFPS%"=="NO" set "CHGFPS=23.976" & set "FRAMERATE=23.976"
				if "%CHGFPS%"=="23.976" set "CHGFPS=24.000" & set "FRAMERATE=24.000"
				if "%CHGFPS%"=="24.000" set "CHGFPS=25.000" & set "FRAMERATE=25.000"
				if "%CHGFPS%"=="25.000" set "CHGFPS=NO" & set "FRAMERATE=!FRAMERATE_ORIG!"
			)
			if "%ERRORLEVEL%"=="1" (
				echo.
				%WHITE%
				echo Type in the RPU DELAY, which will be added.
				echo Importend^^! Set "-" for negative Delay.
				echo Example: For cutting 3 Frames type "-3" and press Enter^^!
				echo.
				set /p "DELAY=Type in the Frames and press [ENTER]: "
			)
		)
	) else (
		if "!RAW_FILE!"=="FALSE" (
			if "%ERRORLEVEL%"=="7" goto :DV_BEGIN
			if "%ERRORLEVEL%"=="6" call :AA_AREA
			if "%ERRORLEVEL%"=="5" (
				if "%MUXINMKV%"=="NO" set "MUXINMKV=YES"
				if "%MUXINMKV%"=="YES" set "MUXINMKV=NO"
				if "%MUXINMP4%"=="NO" set "MUXINMP4=YES"
				if "%MUXINMP4%"=="YES" set "MUXINMP4=NO"
			)
			if "%ERRORLEVEL%"=="4" (
				if "%VEDITING%"=="NO" (
					set "VEDITING=YES"
					set "L6EDITING=NO"
				)
				if "%VEDITING%"=="YES" (
					set "VEDITING=NO"
				)
			)
			if "%ERRORLEVEL%"=="3" (
				if "%L6EDITING%"=="NO" (
					set "L6EDITING=YES"
					set "VEDITING=NO"
				)
				if "%L6EDITING%"=="YES" (
					set "L6EDITING=NO"
				)
			)
			if "%ERRORLEVEL%"=="2" (
				if "%CHGFPS%"=="NO" set "CHGFPS=23.976" & set "FRAMERATE=23.976"
				if "%CHGFPS%"=="23.976" set "CHGFPS=24.000" & set "FRAMERATE=24.000"
				if "%CHGFPS%"=="24.000" set "CHGFPS=25.000" & set "FRAMERATE=25.000"
				if "%CHGFPS%"=="25.000" set "CHGFPS=NO" & set "FRAMERATE=!FRAMERATE_ORIG!"
			)
			if "%ERRORLEVEL%"=="1" (
				echo.
				%WHITE%
				echo Type in the RPU DELAY, which will be added.
				echo Importend^^! Set "-" for negative Delay.
				echo Example: For cutting 3 Frames type "-3" and press Enter^^!
				echo.
				set /p "DELAY=Type in the Frames and press [ENTER]: "
			)
		) else (
			if "%ERRORLEVEL%"=="6" goto :DV_BEGIN
			if "%ERRORLEVEL%"=="5" call :AA_AREA
			if "%ERRORLEVEL%"=="4" (
				if "%VEDITING%"=="NO" (
					set "VEDITING=YES"
					set "L6EDITING=NO"
				)
				if "%VEDITING%"=="YES" (
					set "VEDITING=NO"
				)
			)
			if "%ERRORLEVEL%"=="3" (
				if "%L6EDITING%"=="NO" (
					set "L6EDITING=YES"
					set "VEDITING=NO"
				)
				if "%L6EDITING%"=="YES" (
					set "L6EDITING=NO"
				)
			)
			if "%ERRORLEVEL%"=="2" (
				if "%CHGFPS%"=="NO" set "CHGFPS=23.976" & set "FRAMERATE=23.976"
				if "%CHGFPS%"=="23.976" set "CHGFPS=24.000" & set "FRAMERATE=24.000"
				if "%CHGFPS%"=="24.000" set "CHGFPS=25.000" & set "FRAMERATE=25.000"
				if "%CHGFPS%"=="25.000" set "CHGFPS=NO" & set "FRAMERATE=!FRAMERATE_ORIG!"
			)
			if "%ERRORLEVEL%"=="1" (
				echo.
				%WHITE%
				echo Type in the RPU DELAY, which will be added.
				echo Importend^^! Set "-" for negative Delay.
				echo Example: For cutting 3 Frames type "-3" and press Enter^^!
				echo.
				set /p "DELAY=Type in the Frames and press [ENTER]: "
			)
		)
	)
)

goto :DV_MENU

:RPU_BEGIN
if not exist "!TMP_FOLDER!" MD "!TMP_FOLDER!">nul
if not exist "!TARGET_FOLDER!" MD "!TARGET_FOLDER!">nul
set "HDR10P_File=NONE"
rem -------- LOGFILE ------------
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG>"!logfile!"
echo.>>"!logfile!"
echo                                         ====================================>>"!logfile!"
echo                                              Dolby Vision Tool INJECTOR>>"!logfile!"
echo                                         ====================================>>"!logfile!"
echo.>>"!logfile!"
echo.>>"!logfile!"
echo  == LOGFILE START =======================================================================================================>>"!logfile!"
echo.>>"!logfile!"
echo %date%  %time%>>"!logfile!"
echo.>>"!logfile!"
cls
%GREEN%
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool INJECTOR
echo                                                 - RPU JSON INJECTOR -
%WHITE%
echo                                         ====================================
echo.
echo.
echo  == INJECTING ===========================================================================================================
echo.
%CYAN%
call :DV_OPERATION
goto :EXIT

:HDR10P_BEGIN
if not exist "!TMP_FOLDER!" MD "!TMP_FOLDER!">nul
if not exist "!TARGET_FOLDER!" MD "!TARGET_FOLDER!">nul
rem -------- LOGFILE ------------
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG>"!logfile!"
echo.>>"!logfile!"
echo                                         ====================================>>"!logfile!"
echo                                              Dolby Vision Tool INJECTOR>>"!logfile!"
echo                                         ====================================>>"!logfile!"
echo.>>"!logfile!"
echo.>>"!logfile!"
echo  == LOGFILE START =======================================================================================================>>"!logfile!"
echo.>>"!logfile!"
echo %date%  %time%>>"!logfile!"
echo.>>"!logfile!"
cls
%GREEN%
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool INJECTOR
echo                                                 - HDR10+ INJECTOR -
%WHITE%
echo                                        ====================================
echo.
echo.
echo  == INJECTING ===========================================================================================================
echo.
%YELLOW%
echo ATTENTION^^! You need a lot of HDD Space for this operation.
echo.
%CYAN%
if "!RAW_FILE!"=="FALSE" (
	echo [Extracting Video Layer]>>"!logfile!"
	echo Please wait. Extracting Video Layer...
	%WHITE%
	"!FFMPEGpath!" -loglevel panic -stats -i "!INPUTFILE!" -c:v copy -bsf:v hevc_metadata -f hevc "!TMP_FOLDER!\temp.hevc"
	set "VIDEOSTREAM=!TMP_FOLDER!\temp.hevc"
	if "!ERRORLEVEL!"=="0" (
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
)

call :HDR10P_OPERATION
goto :EXIT

:HDR10P_OPERATION
if /I "!INPUTFILEEXT!"==".mp4" set "MKVExtract=FALSE" & set "MUXINMKV=NO"
if /I "!INPUTFILEEXT!"==".mkv" set "MP4Extract=FALSE" & set "MUXINMP4=NO"
if "!DELAY!" NEQ "0" call :HDR10P_DELAY
if "!DV_File!"=="NONE" (
	if "!CHGFPS!" NEQ "NO" call :FPS_CHANGE
)
call :HDR10PINJECT
if "!DV_File!"=="NONE" call :MUXINCONT
call :LOGFILEEND
goto :eof

:HDR10PINJECT
%CYAN%
echo Please wait. Injecting HDR10+ Metadata into stream...
echo [Injecting HDR10+ Metadata into stream]>>"!logfile!"
%WHITE%
"!HDR10Plus_TOOLpath!" inject -i "!VIDEOSTREAM!" -j "!HDR10PFILE!" -o "!TMP_FOLDER!\hdr10p_temp.hevc"
if exist "!TMP_FOLDER!\hdr10p_temp.hevc" (
	%GREEN%
	if "!RAW_FILE!"=="FALSE" del "!VIDEOSTREAM!"
	set "VIDEOSTREAM=!TMP_FOLDER!\hdr10p_temp.hevc"
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
goto :eof

:DV_BEGIN
if not exist "!TMP_FOLDER!" MD "!TMP_FOLDER!">nul
if not exist "!TARGET_FOLDER!" MD "!TARGET_FOLDER!">nul
cls
%GREEN%
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG
echo.
%WHITE%
echo                                         ====================================
%GREEN%
echo                                              Dolby Vision Tool INJECTOR
if "!HDR10P_OK!"=="TRUE" (
	echo                                          - DOLBY VISION / HDR10+ INJECTOR -
) else (
	echo                                              - DOLBY VISION INJECTOR -
)
%WHITE%
echo                                         ====================================
echo.
echo.
echo  == INJECTING ===========================================================================================================
echo.
%YELLOW%
echo ATTENTION^^! You need a lot of HDD Space for this operation.
echo.
%CYAN%

rem -------- LOGFILE ------------
echo  powered by quietvoids tools                                                                  Copyright (c) 2021-2025 QfG>"!logfile!"
echo.>>"!logfile!"
echo                                         ====================================>>"!logfile!"
echo                                              Dolby Vision Tool INJECTOR>>"!logfile!"
echo                                         ====================================>>"!logfile!"
echo.>>"!logfile!"
echo.>>"!logfile!"
echo  == LOGFILE START =======================================================================================================>>"!logfile!"
echo.>>"!logfile!"
echo %date%  %time%>>"!logfile!"
echo.>>"!logfile!"

if "!RAW_FILE!"=="FALSE" (
	%CYAN%
	echo Please wait. Extracting Video Layer...
	echo [Extracting Video Layer]>>"!logfile!"
	%WHITE%
	"!FFMPEGpath!" -loglevel panic -stats -i "!INPUTFILE!" -c:v copy -bsf:v hevc_metadata -f hevc "!TMP_FOLDER!\temp.hevc"
	set "VIDEOSTREAM=!TMP_FOLDER!\temp.hevc"
	if "%ERRORLEVEL%"=="0" (
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
)

if "!CUSTOM_ONLY!"=="TRUE" (
	if exist "!VIDEOSTREAM!" (
		%CYAN%
		echo Please wait. Extracting RPU...
		%WHITE%
		echo [Extracting RPU]>>"!logfile!"
		"!DO_VI_TOOLpath!" extract-rpu "!VIDEOSTREAM!" -o "!TMP_FOLDER!\RPU_CE.bin"
		if exist "!TMP_FOLDER!\RPU_CE.bin" (
			set "RPUFILE=!TMP_FOLDER!\RPU_CE.bin"
			%GREEN%
			echo Done.
			echo.
			echo Done.>>"!logfile!"
			echo.>>"!logfile!"
		) else (
			%YELLOW%
			echo Error.
			echo.
			set /a "ERRORCOUNT=!ERRORCOUNT!+1"
			echo Error.>>"!logfile!"
			echo.>>"!logfile!"
		)
	)	
)

if exist "!ELSTREAM!" (
	if "!DELAY!!RPU_AA_String!!L6EDITING!!CJ_INJ!" NEQ "0[LEAVE UNTOUCHED]NOFALSE" (
		%CYAN%
		echo Please wait. Extracting RPU from EL...
		%WHITE%
		echo [Extracting RPU from EL]>>"!logfile!"
		"!DO_VI_TOOLpath!" extract-rpu "!ELSTREAM!" -o "!TMP_FOLDER!\RPU_EL.bin"
		if exist "!TMP_FOLDER!\RPU_EL.bin" (
			set "RPUFILE=!TMP_FOLDER!\RPU_EL.bin"
			%GREEN%
			echo Done.
			echo.
			echo Done.>>"!logfile!"
			echo.>>"!logfile!"
		) else (
			%YELLOW%
			echo Error.
			echo.
			set /a "ERRORCOUNT=!ERRORCOUNT!+1"
			echo Error.>>"!logfile!"
			echo.>>"!logfile!"
		)
	)	
)
call :DV_OPERATION
call :EXIT

:DV_OPERATION
if "!XML_exist!"=="YES" call :CREATERPU
if /I "%INPUTFILEEXT%"==".mp4" set "MKVExtract=FALSE" & set "MUXINMKV=NO"
if /I "%INPUTFILEEXT%"==".mkv" set "MP4Extract=FALSE" & set "MUXINMP4=NO"
if "!CHGFPS!" NEQ "NO" call :FPS_CHANGE
if "!HDR10P_File!" NEQ "NONE" call :HDR10P_OPERATION
if /i "!CUSTOMEDIT!!CJ_INJ!"=="FIRSTTRUE" call :CUSTOM
if "!DELAY!" NEQ "0" call :DV_DELAY
if "!RPU_AA_String!" NEQ "[LEAVE UNTOUCHED]" call :CROPRPU
if "!L6EDITING!"=="YES" call :RPUL6EDITING
if /i "!CUSTOMEDIT!!CJ_INJ!"=="LASTTRUE" call :CUSTOM
if "!VEDITING!"=="YES" call :HDRMETADATAEDIT
if "!FIX_SCENECUTS!"=="YES" call :FIX_SHOTS
call :DV_INJECT
call :MUXINCONT
call :LOGFILEEND
goto :eof

:CREATERPU
if "!WIDTH!!HEIGHT!" NEQ "" set "CANVASSTRING= --canvas-width !WIDTH! --canvas-height !HEIGHT!"
%CYAN%
echo Please wait. Creating RPU Binary...
echo [Creating RPU Binary]>>"!logfile!"
%WHITE%
"!DO_VI_TOOLpath!" generate --xml "!XMLFILE!"!CANVASSTRING! --rpu-out "!TMP_FOLDER!\RPU-CREATED.bin">>"!logfile!"
if exist "!TMP_FOLDER!\RPU-CREATED.bin" (
	%GREEN%
	set "RPUFILE=!TMP_FOLDER!\RPU-CREATED.bin"
	echo Done.
	echo.
	echo Done.>>"!logfile!"
	echo.>>"!logfile!"
	goto :eof
) else (
	%RED%
	set /a "ERRORCOUNT=!ERRORCOUNT!+1"
	echo Error.
	echo.
	echo Error.>>"!logfile!"
	echo .>>"!logfile!"
)
goto :EXIT

:CUSTOM
%CYAN%
echo Please wait. Applying Custom Edit script...
echo [Applying Custom Edit script]>>"!logfile!"
%WHITE%
"!DO_VI_TOOLpath!" editor -i "!RPUFILE!" -j "!CJ_File!" -o "!TMP_FOLDER!\RPU-CUSTOM.bin">>"!logfile!"
if exist "!TMP_FOLDER!\RPU-CUSTOM.bin" (
	%GREEN%
	set "RPUFILE=!TMP_FOLDER!\RPU-CUSTOM.bin"
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

:CROPRPU
if "!RPU_AA_String!"=="[LEAVE UNTOUCHED]" goto :eof
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

:RPUL6EDITING
echo [Editing RPU L6 Metadata]>>"!logfile!"
if "!L6_EDITING!"=="FALSE" (
	%YELLOW%
	echo SKIPPED. NEEDED ENTRIES FOR L6 EDITING NOT FOUND IN VIDEO STREAM^^!
	echo SKIPPED. NEEDED ENTRIES FOR L6 EDITING NOT FOUND IN VIDEO STREAM^^!>>"!logfile!"
	echo.>>"!logfile!"
	echo.
	goto :eof
) else (
	%CYAN%
	echo Please wait. Editing RPU L6 Metadata...
	%WHITE%
	(
	echo {
	echo 	"level6": {
	echo	 	"max_display_mastering_luminance": !MaxDML!,
	echo	 	"min_display_mastering_luminance": !MinDML!,
	echo	 	"max_content_light_level": !MaxCLL!,
	echo	 	"max_frame_average_light_level": !MaxFall!
	echo 	}
	echo }
	)>"!TMP_FOLDER!\EDIT.json"
	"!DO_VI_TOOLpath!" editor -i "!RPUFILE!" -j "!TMP_FOLDER!\EDIT.json" -o "!TMP_FOLDER!\RPU-L6EDIT.bin">>"!logfile!"
	if exist "!TMP_FOLDER!\RPU-L6EDIT.bin" (
		%GREEN%
		del "!TMP_FOLDER!\EDIT.json"
		set "RPUFILE=!TMP_FOLDER!\RPU-L6EDIT.bin"
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

:HDRMETADATAEDIT
for %%f in (!VIDEOSTREAM!) do set "VS_DIR=%%~dpf"
for %%f in (!VIDEOSTREAM!) do set "VS_NAME=%%~nf"
for %%f in (!VIDEOSTREAM!) do set "VS_EXT=%%~xf"
%CYAN%
echo [Editing Video HDR Metadata]>>"!logfile!"
if "!V_EDITING!"=="FALSE" (
	%YELLOW%
	echo.>>"!logfile!"
	echo SKIPPED. NEEDED ENTRIES FOR HDR EDITING NOT FOUND IN VIDEO STREAM^^!
	echo SKIPPED. NEEDED ENTRIES FOR HDR EDITING NOT FOUND IN VIDEO STREAM^^!>>"!logfile!"
	echo.>>"!logfile!"
	echo.
	goto :eof
)
copy "%~dp0tools\HDRMetadataEditor.exe" "!VS_DIR!" >nul
attrib +h "!VS_DIR!\HDRMetadataEditor.exe" >nul
copy "%~dp0tools\nvcuda.dll" "!VS_DIR!" >nul
attrib +h "!VS_DIR!\nvcuda.dll" >nul
copy "%~dp0tools\nvcuvid.dll" "!VS_DIR!" >nul
attrib +h "!VS_DIR!\nvcuvid.dll" >nul
if "!L9MDP!"=="Display P3" (
	set "HDR_MDCP=displayp3"
) else (
	set "HDR_MDCP=bt2020"
)
if "!L9MDP!"=="" set "HDR_MDCP=bt2020"
%CYAN%
echo Please wait. Editing Video HDR Metadata...
%WHITE%
"!VS_DIR!\HDRMetadataEditor.exe" !HDR_MDCP! !RPUMinDML_L6!,!RPUMaxDML_L6! !RPUCLL_L6!,!RPUFALL_L6! "!VS_DIR!\!VS_NAME!!VS_EXT!">>"!logfile!"
if exist "!VS_DIR!\!VS_NAME! ^(HDR10-Edited^)!VS_EXT!"  (
	%GREEN%
	move "!VS_DIR!\!VS_NAME! ^(HDR10-Edited^)!VS_EXT!" "!TMP_FOLDER!\HDREDIT.hevc">nul
	set "VIDEOSTREAM=!TMP_FOLDER!\HDREDIT.hevc"
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
if exist "!VS_DIR!\HDRMetadataEditor.exe" (
	attrib -h "!VS_DIR!\HDRMetadataEditor.exe" >nul
	del "!VS_DIR!\HDRMetadataEditor.exe">nul
)
if exist "!VS_DIR!\nvcuda.dll" (
	attrib -h "!VS_DIR!\nvcuda.dll" >nul
	del "!VS_DIR!\nvcuda.dll">nul
)
if exist "!VS_DIR!\nvcuvid.dll" (
	attrib -h "!VS_DIR!\nvcuvid.dll" >nul
	del "!VS_DIR!\nvcuvid.dll">nul
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

:HDR10P_DELAY
%CYAN%
echo "!DELAY!" | find "-">nul 2>&1
if "%ERRORLEVEL%"=="0" (
	echo Please wait. Applying HDR10+ !DELAY! Frames negative Delay...
	echo [Applying HDR10+ !DELAY! Frames negative Delay]>>"!logfile!"
	%WHITE%
	"!PYTHONpath!" "!HDR10PDELAYSCRIPTpath!" -i "!HDR10PFILE!" -d !DELAY! -o "!TMP_FOLDER!\HDR10PlusDELAYED.json"
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

:FPS_CHANGE
if "!CHGFPS!"=="23.976" set "FPS=24/1001"
if "!CHGFPS!"=="24.000" set "FPS=24"
if "!CHGFPS!"=="25.000" set "FPS=25"
%CYAN%
echo Please wait. Changing HDR Stream FPS to !CHGFPS!...
echo [Changing HDR Stream FPS to !CHGFPS!]>>"!logfile!"
%WHITE%
"!FFMPEGpath!" -y -i "!VIDEOSTREAM!" -loglevel panic -stats -an -sn -dn -c copy -bsf:v hevc_metadata=tick_rate=!FPS!:num_ticks_poc_diff_one=1 "!TMP_FOLDER!\HDR_FPSCHANGED.hevc"
if exist "!TMP_FOLDER!\HDR_FPSCHANGED.hevc" (
	%GREEN%
	del "!VIDEOSTREAM!"
	set "VIDEOSTREAM=!TMP_FOLDER!\HDR_FPSCHANGED.hevc"
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
if "!EL_exist!"=="YES" (
	%CYAN%
	echo Please wait. Changing EL Stream FPS to !CHGFPS!...
	echo [Changing EL Stream FPS to !CHGFPS!]>>"!logfile!"
	%WHITE%
	"!FFMPEGpath!" -y -i "!ELSTREAM!" -loglevel panic -stats -an -sn -dn -c copy -bsf:v hevc_metadata=tick_rate=!FPS!:num_ticks_poc_diff_one=1 "!TMP_FOLDER!\EL_FPSCHANGED.hevc"
	if exist "!TMP_FOLDER!\EL_FPSCHANGED.hevc" (
		%GREEN%
		set "ELSTREAM=!TMP_FOLDER!\EL_FPSCHANGED.hevc"
		echo Done.
		echo.
		echo Done.>>"!logfile!"
		echo.>>"!logfile!"
	) else (
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
		%RED%
		echo Error.
		echo.
		echo Error.>>"!logfile!"
		echo.>>"!logfile!"
	)
)
goto :eof

:DV_INJECT
if "!RPU_FILE!"=="TRUE" (
	%CYAN%
	echo Please wait. Move RPU to Target Folder...
	echo [Move RPU to Target Folder]>>"!logfile!"
	move "!RPUFILE!" "!TARGET_FOLDER!\!HEADER_FILENAME!.bin">nul
	if exist "!TARGET_FOLDER!\!HEADER_FILENAME!.bin" (
		%GREEN%
		echo Done.
		echo.
		echo Done.>>"!logfile!"
		echo.>>"!logfile!"
	) else (
		set /a "ERRORCOUNT=!ERRORCOUNT!+1"
		%RED%
		echo Error.
		echo.
		echo Error.>>"!logfile!"
		echo.>>"!logfile!"
	)
	goto :eof
)
if "%REMHDR10P%"=="YES" set "REMHDR10PString=--drop-hdr10plus "
if "%MUXP7SETTING%"=="makeMKV" set "MUXP7String=--eos-before-el "
if "%MUXP7SETTING%"=="Disable AUD NALUs" set "MUXP7String=--no-add-aud "

if "%EL_exist%"=="YES" (
	if "!CROP_RPU!!CJ_INJ!!L6EDITING!!DELAY!" NEQ "FALSEFALSENO0" (
		%CYAN%
		echo Please wait. Injecting RPU in DV EL...
		echo [Injecting RPU in DV EL]>>"!logfile!"
		%WHITE%
		"!DO_VI_TOOLpath!" inject-rpu "!ELSTREAM!" --rpu-in "!RPUFILE!" -o "!TMP_FOLDER!\ELtemp.hevc"
		if "!ERRORLEVEL!"=="0" (
			%GREEN%
			set "ELSTREAM=!TMP_FOLDER!\ELtemp.hevc"
			echo Done.
			echo.
			echo Done.>>"!logfile!"
			echo.>>"!logfile!"
			echo.
		) else (
			%RED%
			set /a "ERRORCOUNT=!ERRORCOUNT!+1"
			echo Error.
			echo.
			echo Error.>>"!logfile!"
			echo.>>"!logfile!"
		)
	)
	%CYAN%
	echo Please wait. Injecting DV EL into stream...
	echo [Injecting  DV EL into stream]>>"!logfile!"
	%WHITE%
	"!DO_VI_TOOLpath!" !REMHDR10PString!mux !MUXP7String!--bl "!VIDEOSTREAM!" --el "!ELSTREAM!" -o "!TMP_FOLDER!\BL+EL.hevc"
	if exist "!TMP_FOLDER!\BL+EL.hevc" (
		%GREEN%
		if exist "!TMP_FOLDER!\temp.hevc" DEL "!TMP_FOLDER!\temp.hevc"
		set "VIDEOSTREAM=!TMP_FOLDER!\BL+EL.hevc"
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
) else (
	%CYAN%
	echo Please wait. Injecting RPU into stream...
	echo [Injecting RPU into stream]>>"!logfile!"
	%WHITE%
	"!DO_VI_TOOLpath!" !REMHDR10PString!inject-rpu "!VIDEOSTREAM!" --rpu-in "!RPUFILE!" -o "!TMP_FOLDER!\BL+RPU.hevc"
	if "!ERRORLEVEL!"=="0" (
		%GREEN%
		if exist "!TMP_FOLDER!\temp.hevc" DEL "!TMP_FOLDER!\temp.hevc"
		set "VIDEOSTREAM=!TMP_FOLDER!\BL+RPU.hevc"
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

:MUXINCONT
if "!RPU_FILE!"=="TRUE" goto :eof
if "!MUXINMKV!!MUXINMP4!"=="NONO" (
	%CYAN%
	echo Please wait. Moving RAW Stream to Target Folder...
	echo [Moving RAW Stream to Target Folder]>>"!logfile!"
	move "!VIDEOSTREAM!" "!TARGET_FOLDER!\!HEADER_FILENAME!.hevc">nul
	if exist "!TARGET_FOLDER!\!HEADER_FILENAME!.hevc" (
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
if "!MUXINMKV!"=="YES" (
	set "duration="
	if "!FRAMERATE!"=="23.976" set "duration=--default-duration 0:24000/1001p --fix-bitstream-timing-information 0:1"
	if "!FRAMERATE!"=="24.000" set "duration=--default-duration 0:24p --fix-bitstream-timing-information 0:1"
	if "!FRAMERATE!"=="25.000" set "duration=--default-duration 0:25p --fix-bitstream-timing-information 0:1"
	if "!FRAMERATE!"=="30.000" set "duration=--default-duration 0:30p --fix-bitstream-timing-information 0:1"
	if "!FRAMERATE!"=="48.000" set "duration=--default-duration 0:48p --fix-bitstream-timing-information 0:1"
	if "!FRAMERATE!"=="50.000" set "duration=--default-duration 0:50p --fix-bitstream-timing-information 0:1"
	if "!FRAMERATE!"=="60.000" set "duration=--default-duration 0:60p --fix-bitstream-timing-information 0:1"
	%CYAN%
	echo Please wait. Muxing !INPUTFILENAME! into MKV Container...
	echo [Muxing !INPUTFILENAME! into MKV Container]>>"!logfile!"
	%YELLOW%
	echo Don't close the "Muxing !INPUTFILENAME! into MKV" cmd window.
	start /WAIT /MIN "Muxing !INPUTFILENAME! into MKV" "!MKVMERGEpath!" --ui-language en --priority higher --output ^"!TARGET_FOLDER!\!HEADER_FILENAME!.mkv^" --stop-after-video-ends --no-video ^"^(^" ^"!INPUTFILE!^" ^"^)^" --language 0:und --compression 0:none !duration! ^"^(^" ^"!VIDEOSTREAM!^" ^"^)^" --track-order 1:0
	if exist "!TARGET_FOLDER!\!HEADER_FILENAME!.mkv" (
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
if "%MUXINMP4%"=="YES" (
	%CYAN%
	echo Please wait. Muxing !INPUTFILENAME! into MP4...
	echo [Muxing !INPUTFILENAME! into MP4]>>"!logfile!"
	%WHITE%
	"!MP4BOXpath!" -rem 1 "!INPUTFILE!" -out "!TMP_FOLDER!\temp.mp4"
	"!MP4BOXpath!" -add "!VIDEOSTREAM!:ID=1:fps=!FRAMERATE!:name=" "!TMP_FOLDER!\temp.mp4" -out "!TARGET_FOLDER!\!HEADER_FILENAME!.mp4"
	if exist "!TMP_FOLDER!\temp.mp4" del "!TMP_FOLDER!\temp.mp4"
	if exist "!TARGET_FOLDER!\!HEADER_FILENAME!.mp4" (
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
if "%AA_INPUT_LC%%AA_INPUT_TC%%AA_INPUT_RC%%AA_INPUT_BC%" NEQ "" (
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
if "!RPU_FILE!"=="FALSE" ( 
	echo  == VIDEO INPUT =========================================================================================================
	echo.
	%CYAN%
	%AA_String%
	if "!RPU_exist!!EL_exist!"=="YESNO" (
		echo.
		%WHITE%
		echo  == RPU INPUT ===========================================================================================================
		%CYAN%
		echo.
		%HEADER_RPU_AA_String%
	) else (
		echo.
		%WHITE%
		echo  == EL INPUT ============================================================================================================
		%CYAN%
		echo.
		%HEADER_RPU_AA_String%
	)
) else (
	echo  == RPU INPUT ===========================================================================================================
	%CYAN%
	echo.
	%HEADER_RPU_AA_String_RPU%
)
if "!EL_exist!"=="NO" (
	if "!RPU_FILE!"=="FALSE" (
		echo.
		%WHITE%
		echo  == RPU OUTPUT ==========================================================================================================
		%YELLOW%
		echo.
		%HEADER_RPU_OUTPUT_String%
	) else (
		echo.
		%WHITE%
		echo  == RPU OUTPUT ==========================================================================================================
		%YELLOW%
		echo.
		%HEADER_RPU_OUTPUT_String_RPU%
	)
) else (
	echo.
	%WHITE%
	echo  == EL OUTPUT ===========================================================================================================
	%YELLOW%
	echo.
	%HEADER_RPU_OUTPUT_String%
)
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
	if exist "!logfile!" move "!logfile!" "!TARGET_FOLDER!\DDVT Injector ^(!HEADER_FILENAME!!HEADER_EXT!^).log" >nul
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
	)
)
setlocal DisableDelayedExpansion
ENDLOCAL
%WHITE%
echo.
echo  == EXIT ================================================================================================================
echo.
if "!ERRORCOUNT!"=="0" (
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
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('NEEDED FILE NOT FOUND!' + %NewLine% + %NewLine% + '%Line1%' + %NewLine% + %NewLine% + '%Line2%', 'DDVT Injector [QfG] v%VERSION%', 'Ok','Error')"
exit

:FALSEINPUT
if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
set "NewLine=[System.Environment]::NewLine"
set "Line1=Unsupported Input File. Supported Files are:"
set "Line2=*.mkv | *.mp4 | *.h265 | *.hevc | *.bin"
setlocal DisableDelayedExpansion
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('%INPUTFILENAME%%INPUTFILEEXT%' + %NewLine% + %NewLine% + '%Line1%' + %NewLine% + %NewLine% + '%Line2%', 'DDVT Injector [QfG] v%VERSION%', 'Ok','Info')"
exit

:ERROR
if exist "!TMP_FOLDER!" RD /S /Q "!TMP_FOLDER!">nul
set "NewLine=[System.Environment]::NewLine"
set "Line1=%ERRORCOUNT% Error(s) during processing^!
set "Line2=Target file don''t exist or corrupt.
setlocal DisableDelayedExpansion
START /B PowerShell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('%INPUTFILENAME%%INPUTFILEEXT%' + %NewLine% + %NewLine% + '%Line1%' + %NewLine% + %NewLine% + '%Line2%', 'DDVT Injector [QfG] v%VERSION%', 'Ok','Error')"
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