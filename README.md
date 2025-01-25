Donalds Dolby Vision Tool (DDVT)
==================================

NEEDED 3RD PARTY TOOLS CAN BE FOUND HERE:

[<img src="https://i.ibb.co/CzHqWx9/MEGA.png">](https://mega.nz/folder/x9FHlbbK#YQz_XsqcAXfZP2ciLeyyDg)

--------------------------------------------
CREDITS to quietvoid, yuseope, Atak_Snajpera
--------------------------------------------
DESCRIPTION:
------------
A little toolbox that works with quietvoids dolby_vision and HDR10plus tool. 
For every function exists an own script. Script list:
===========================================================================

- SCRIPT <DDVT_OPTIONS.cmd>

DESCRIPTION:
------------
Setting Menu. You can set folders for Output und Temp Directories. Contains a
function to set / delete shell extensions for the tool.
IF YOUR CHANGES TAKES NO EFFECT RUN AS ADMINISTRATOR!

USAGE:
------
DDVT_OPTIONS

===========================================================================

- SCRIPT <DDVT_MEDIAINFO.cmd>

DESCRIPTION:
------------
Creates a list of MediaInfos from videos. Also DoVi levels and profiles.
Logfile can be turned ON/OFF via DDVT_OPTIONS.cmd. With the Switch -MSGBOX
a small MS MSG box shows the main values (Quickcheck).

USAGE:
------
DDVT_MEDIAINFO <SOURCEFILE>.hevc/mkv/mp4/ts/m2ts/bin/avi

DDVT_MEDIAINFO <SOURCEFILE>.hevc/mkv/mp4/ts/m2ts/bin/avi -MSGBOX

===========================================================================

- SCRIPT <DDVT_DEMUXER.cmd>

DESCRIPTION:
------------
Can demux EL/DL Layers, RPUs and HDR10+ metadata. Many subfunctions, like to
convert RPUs and removing HDR10+ metadata.

USAGE:
------
DDVT_DEMUXER <SOURCEFILE>.hevc/mkv/mp4/bin/m2ts

===========================================================================

- SCRIPT <DDVT_INJECTOR.cmd>

DESCRIPTION:
------------
Can mux EL Layers or RPUs into Base Layer. Also can mux HDR10+ Matadata into
file. Contains a little Editor for cropping functions. You can set Delays for
HDR10+ Metadata or RPUs and many other features:

FEATURES:
---------
Start Script with sourcefile. Now you have following features:
Drag 'n' Drop "EL.hevc" into script will start P7 build options.
Drag 'n' Drop "RPU.bin" into script will start P8 build options.
Drag 'n' Drop "HDR10Plus.json" into script will start HDR10+ build options.
Drag 'n' Drop "EDIT.json" into script allows custom EDIT options.
You can add DV, HDR10+ Metadata and Custom files to inject all in one step.
Custom JSON Support can be disabled via options.

Examples how to edit a JSON 
file can be found here:
https://github.com/quietvoid/dovi_tool/tree/main/assets/editor_examples

USAGE:
------
DDVT_INJECTOR <SOURCEFILE>.hevc/mkv/mp4/bin

===========================================================================

- SCRIPT <DDVT_REMOVER.cmd>

DESCRIPTION:
------------
Simply does what it means. Removes DV and/or HDR10+ metadata from streams.

USAGE:
------
DDVT_REMOVER <SOURCEFILE>.hevc/mkv/mp4

===========================================================================

- SCRIPT <DDVT_FILEINFO.cmd>

DESCRIPTION:
------------
Creates DV / HDR10+brightness metadata into a graph. The output is a PNG image.
Also creates a JSON file next the sourcefile with RPU infos from the choosen frame.
Usefull if you will check fast cropping values or CM Version. Use ALL for exporting
all frames from an RPU to valid JSON file. Also a Json file with all scene cuts will
be created. All files will be readable formatted. Attention! first frame of a 
videofile is frame 0 NOT frame 1! Can fix bad cropped RPUs, too. Also can be used with
switch "-CHECK" for jumping directly to the SyncCheck area.

USAGE:
------
DDVT_FILEINFO <SOURCEFILE>.hevc/mkv/mp4/bin

DDVT_FILEINFO <SOURCEFILE>.hevc/mkv/mp4/bin -CHECK

===========================================================================

- SCRIPT <DDVT_MKVTOMP4.cmd>

DESCRIPTION:
------------
A simple converter from mkv container to mk4 container. Containes an audio 
converter from not supported mp4 audio files to supported E-AC3, AC3, AAC.
Attention: Works not with graphic based subtitles how PGS or VOBSUB. You must
demux graphic based subtitles first. Works with single files or folders.

USAGE:
------
DDVT_MKVTOMP4 <SOURCEFILE>.mkv
DDVT_MKVTOMP4 <SOURCEDIR>

===========================================================================

- SCRIPT <DDVT_HYBRID.cmd>

DESCRIPTION:
------------
Simple quick script to create a DV Profile 8 Hybrid Release. Only add HDR
and DV File (No RAW file Support, only MKV/MP4 Container) set the options
and Go. Completely simplified and the fastest script to Build Profile 8.1 Files.
Also you can Input only a HDR10+ file without DV Input file and you create
a Profile 8.1 DV file based on the HDR10+ Metadata.

USAGE:
------
DDVT_HYBRID

==========================================================================

Help and discussions on DOOM9 Forum. Thanks to the community for help and support.
If you paid for this tool, fuck off the guy who sold it. I don't need money, if
you will support this project, support the guys from the credits!

===========================================================================

USEFUL LINKS:
-------------
DOOM9 Forum Thread:
https://forum.doom9.org/showthread.php?t=183479
