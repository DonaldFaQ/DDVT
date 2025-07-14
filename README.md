# DDVT
[![GitHub version](https://img.shields.io/github/v/release/DonaldFaQ/DDVT)](https://github.com/DonaldFaQ/DDVT/)
![BeHappy number of downloads](https://img.shields.io/github/downloads/DonaldFaQ/DDVT/latest/total.svg)
[![download latest release](https://img.shields.io/badge/DDVT-download-green?style=flat)](https://github.com/DonaldFaQ/DDVT/releases/latest)

**DDVT** (_**D**onalds **D**olby **V**ision **C**onverter_) is a little toolbox that works with quietvoids dolby_vision and HDR10plus tool.
For every function exists an own script.

### Script list:

| Script                        | Switches                     | Description |
|------------------------------ |------------------------------|-------------|
| DDVT_OPTIONS.cmd              | `N.A.`                       | Setting Menu. You can set folders for Output und Temp Directories. Contains a function to set / delete shell extensions for the tool. ⚠️IF YOUR CHANGES TAKES NO EFFECT RUN AS ADMINISTRATOR❗|
| DDVT_MEDIAINFO.cmd            | `-MSGBOX`                    | Creates a list of MediaInfos from videos. Also DoVi levels and profiles. Logfile can be turned ON/OFF via DDVT_OPTIONS.cmd. With the Switch `-MSGBOX` a small MS MSG box shows the main values (Quickcheck).|
| DDVT_DEMUXER.cmd              | `N.A.`                       | Can demux EL/DL Layers, RPUs and HDR10+ metadata. Many subfunctions, like to convert RPUs and removing HDR10+ metadata.|
| DDVT_INJECTOR.cmd             | `N.A.`                       | Can mux EL Layers or RPUs (BIN/XML) into Base Layer. Also can mux HDR10+ Matadata into file. Contains a little Editor for cropping functions. You can set Delays for HDR10+ Metadata or RPUs and many other features.|
| DDVT_REMOVER.cmd              | `N.A.`                       | Simply does what it means. Removes DV and/or HDR10+ metadata from streams. Works with single files or folders.|
| DDVT_FILEINFO.cmd             | `-CHECK`                     | Creates DV / HDR10+ plots. The output is a PNG image. Also creates a JSON file next the sourcefile with RPU infos from the choosen frame. Usefull if you will check fast cropping values or CM Version. Use `ALL` for exporting all frames from an RPU to valid JSON file. Also a Json file with all scene cuts will be created. All files will be readable formatted. ⚠️Attention! first frame of a videofile is frame 0 NOT frame 1❗ Can fix bad cropped RPUs, too. Also can be used with switch `-CHECK` for jumping directly to the SyncCheck area.|
| DDVT_MKVTOMP4.cmd             | `N.A.`                       | A simple converter from mkv container to mk4 container. Containes an audio converter from not supported mp4 audio files to supported E-AC3, AC3, AAC. ⚠️Attention: Works not with graphic based subtitles how PGS or VOBSUB. You must demux graphic based subtitles first❗ Works with single files or folders.|
| DDVT_HYBRID.cmd               | `N.A.`                       | Simple quick script to create a DV Profile 8 Hybrid Release. Only add HDR and DV File (No RAW file Support, only MKV/MP4 Container) set the options and Go. Completely simplified and the fastest script to Build Profile 8.1 Files. Also you can Input only a HDR10+ file without DV Input file and you create a Profile 8.1 DV file based on the HDR10+ Metadata.|


### Examples:
----------------------------------------------------------------------------------------
### `DDVT_MEDIAINFO.cmd`
* DDVT_MEDIAINFO `<SOURCEFILE>`.`hevc`/`mkv`/`mp4`/`ts`/`m2ts`/`bin`/`avi`
* DDVT_MEDIAINFO `<SOURCEFILE>`.`hevc`/`mkv`/`mp4`/`ts`/`m2ts`/`bin`/`avi` `-MSGBOX`
----------------------------------------------------------------------------------------
### `DDVT_DEMUXER.cmd`
* DDVT_DEMUXER `<SOURCEFILE>`.`hevc`/`mkv`/`mp4`/`bin`/`m2ts`
#
* _Start Script with `RPU (BIN)` will automatically demux the RPU into `XML` and `JSON`._
#
----------------------------------------------------------------------------------------
### `DDVT_INJECTOR.cmd`
* DDVT_INJECTOR `<SOURCEFILE>`.`hevc`/`mkv`/`mp4`/`bin`

- FEATURES:
* _Start Script with sourcefile. Now you have following features:_
* Drag 'n' Drop "`EL.hevc`" into script will start `P7 build options`.
* Drag 'n' Drop "`RPU.bin`" into script will start `P8 build options`.
* Drag 'n' Drop "`RPU.xml`" into script will start `P8 build options`.
* Drag 'n' Drop "`HDR10Plus.json`" into script will start `HDR10+ build options`.
* Drag 'n' Drop "`EDIT.json`" into script allows `custom EDIT options`.
* You can add `DV`, `HDR10+` Metadata and `Custom` files to `inject all in one step`.
* _Custom JSON Support can be disabled via options._

Examples how to edit a JSON file can be found here:
* https://github.com/quietvoid/dovi_tool/tree/main/assets/editor_examples
----------------------------------------------------------------------------------------
### `DDVT_REMOVER.cmd`
* DDVT_REMOVER `<SOURCEFILE>`.`hevc`/`mkv`/`mp4`
* DDVT_REMOVER `<SOURCEDIR>`
----------------------------------------------------------------------------------------
### SCRIPT `DDVT_FILEINFO.cmd`
* DDVT_FILEINFO `<SOURCEFILE>`.`hevc`/`mkv`/`mp4`/`bin`/`json`
* DDVT_FILEINFO `<SOURCEFILE>`.`hevc`/`mkv`/`mp4` `-CHECK`
----------------------------------------------------------------------------------------
### `DDVT_MKVTOMP4.cmd`
* DDVT_MKVTOMP4 `<SOURCEFILE>`.`mkv`
* DDVT_MKVTOMP4 `<SOURCEDIR>`
----------------------------------------------------------------------------------------
### `DDVT_HYBRID.cmd`
* `DDVT_HYBRID`
----------------------------------------------------------------------------------------

### CREDITS to quietvoid, yuseope, Atak_Snajpera

❗REQUIRED 3RD PARTY TOOLS MUST BE DOWNLOAD HERE:❗  

[![Tools Download on MEGA](https://i.ibb.co/CzHqWx9/MEGA.png)](https://mega.nz/folder/x9FHlbbK#YQz_XsqcAXfZP2ciLeyyDg)

# USEFUL LINKS:

### DOOM9 Forum Thread:
https://forum.doom9.org/showthread.php?t=183479
