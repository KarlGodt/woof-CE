#!/bin/bash

Version=1.0-simple

usage(){
MSG="
$0 PARAMETERS

Script to configure programs from source.
Supports adjustable parameters.
Changes inside this script.

Special predefined programs are
ffmpeg,mesa,glut
"
echo "$MSG"
exit $1
}

[[ "$@" =~ 'help' ]] && usage 0

PARAMS="$@"
BUILD='--build=i486-pc-linux-gnu' # --host=i486-pc-linux-gnu --target=i486-pc-linux-gnu'

#PREFIXS='--prefix=/usr'
#  --bindir=DIR           [EPREFIX/bin]    user executables
#  --sbindir=DIR          [EPREFIX/sbin]   system admin executables
#  --libexecdir=DIR       [EPREFIX/libexec]program executables
#  --datadir=DIR          [PREFIX/share]   read-only architecture-independent data
#  --sysconfdir=DIR       [PREFIX/etc]     read-only single-machine data
#  --sharedstatedir=DIR   [PREFIX/com]     modifiable architecture-independent data
#  --localstatedir=DIR    [PREFIX/var]     modifiable single-machine data
#  --libdir=DIR           [EPREFIX/lib]    object code libraries
#  --includedir=DIR       [PREFIX/include] C header files
#  --oldincludedir=DIR    [/usr/include]   C header files for non-gcc
#  --infodir=DIR          [PREFIX/info]    info documentation
#  --mandir=DIR           [PREFIX/man]     man documentation

NO="'garage'"
CUSTOMNO="'garbage'"

###*************
##MESA Xorg server
#CUSTOMNO='static' #MESA
#NO="'Deprecated|icu|minimum|\-\-disable|\-\-without|=|selinux|ansi|kqueue|maintainer|strict|static'"

###*************


###*************
##FFmpeg
##--enable-shared --enable-gpl --enable-version3 --enable-nonfree --enable-w32threads
##--enable-x11grab --enable-gray --enable-small --enable-vaapi --enable-vdpau
##--enable-runtime-cpudetect --enable-hardcoded-tables --enable-memalign-hack
##--enable-avisynth --enable-bzlib --enable-libcelt --enable-frei0r --enable-libaacplus
##--enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libopencv
##--enable-libdc1394 --enable-libdirac --enable-libfaac --enable-libfreetype
##--enable-libgsm --enable-libmp3lame --enable-libnut --enable-libopenjpeg
##--enable-librtmp --enable-libschroedinger --enable-libspeex --enable-libtheora
##--enable-libvo-aacenc --enable-libvo-amrwbenc --enable-libvorbis --enable-libvpx
##--enable-libx264 --enable-libxavs --enable-libxvid --enable-mlib --enable-zlib
##--enable-cross-compile --enable-pic --enable-sram --enable-extra-warnings

NO='w32|frei0r|cross\-compile'

NO="${NO}|vaapi"
#NO="${NO}|vdpau"
#NO="${NO}|runtime\\-cpudetect"
NO="${NO}|avisynt" #for vfw32
NO="${NO}|libcelt"
NO="${NO}|libaacplus" #libaacplus >= 2.0.0 not found
NO="${NO}|libdc1394" #libdc1394-2
NO="${NO}|libdirac"
NO="${NO}|libgsm"
NO="${NO}|libmp3lame" # >= 3.98.3
NO="${NO}|libnut"
NO="${NO}|libopencore\\-amrnb"
NO="${NO}|libopencore\\-amrwb"
NO="${NO}|opencv"
NO="${NO}|libopenjpeg"
NO="${NO}|librtmp"
NO="${NO}|schroedinger" #schroedinger-1.0
NO="${NO}|libtheora"
NO="${NO}|libvo\\-aacenc"
NO="${NO}|libvo\\-amrwbenc"
NO="${NO}|libvpx" # libvpx decoder version must be >=0.9.1
NO="${NO}|libx264"
NO="${NO}|libxavs"
NO="${NO}|libxvid"
NO="${NO}|mlib" #mediaLib not found
NO="${NO}|gnutls" #ffmpeg-v9.1
NO="${NO}|libass" #ffmpeg-v9.1
NO="${NO}|libmodplug" #ffmpeg-v9.1
NO="${NO}|libpulse" #libpulse-simple
NO="${NO}|libstagefright\\-h264"
NO="${NO}|libutvideo"
NO="${NO}|libv4l2"
NO="${NO}|openal"


#CUSTOMNO='yasm'
#CUSTOM='--disable-yasm'

#!--without=vfw32
#!--disable-feature=vfw32

#--enable-shared --enable-gpl --enable-version3 --enable-nonfree
#--enable-x11grab
#--enable-gray --enable-small --enable-vdpau --enable-runtime-cpudetect
#--enable-hardcoded-tables --enable-memalign-hack --enable-bzlib
#--enable-libfaac --enable-libfreetype --enable-libspeex --enable-libvorbis
#--enable-zlib --enable-pic --enable-sram --enable-extra-warnings
#===NO x11grab

##simply --enable-pic --enable-x11grab did not work either .... ?????

#8.10WARNING: Please upgrade to VA-API >= 0.32 if you would like full VA-API support
#9.1 WARNING: Please upgrade to VA-API >= 0.32 if you would like full VA-API support
###****************


###*************
#GLUT
#NO="${NO}|warnings" #warnings as errors = -pedantic
CUSTOM='--enable-warnings=no'

echo "$0
in
`pwd` ?"
read -n1 -t10 k
[ ! "$k" ] && k=Y
k=`echo $k | tr '[[:upper:]]' '[[:lower:]]'`
case "$k" in
y)echo;;
*)echo;exit 101;;
esac
HELP=`./configure --help |grep '\-\-'`
echo "$HELP"
echo
#W=`./configure --help | grep '\-\-with' | grep -v -E 'icu|minimum|\-\-disable|\-\-without|=|selinux|ansi|kqueue|maintainer|strict' | awk '{print $1}' | sed 's#^[[:blank:]]*##g' | tr '\n' ' '`
#W=`echo "$HELP" | awk '{print $1}' | grep '\-\-with' | grep -v -E 'Deprecated|icu|minimum|\-\-disable|\-\-without|=|selinux|ansi|kqueue|maintainer|strict|static' | sed 's#^[[:blank:]]*##g' | tr '\n' ' '`
W=`echo "$HELP" | awk '{print $1}' | grep '\-\-with' | grep -vE '=|without' | grep -v -E "$NO" | grep -v -E "$CUSTOMNO" | sed 's#^[[:blank:]]*##g' | tr '\n' ' '`

#E=`./configure --help | grep '\-\-enable' | grep -v -E 'icu|minimum|\-\-disable|=|selinux|ansi|kqueue|maintainer|strict' | awk '{print $1}' | sed 's#^[[:blank:]]*##g' | tr '\n' ' '`
#E=`echo "$HELP" | awk '{print $1}' | grep '\-\-enable' | grep -v -E 'Deprecated|icu|minimum|\-\-disable|=|selinux|ansi|kqueue|maintainer|strict|static' | sed 's#^[[:blank:]]*##g' | tr '\n' ' '`
E=`echo "$HELP" | awk '{print $1}' | grep '\-\-enable' |grep -v '=' |grep -v -E "$NO" | grep -v -E "$CUSTOMNO" | sed 's#^[[:blank:]]*##g' | tr '\n' ' '`

echo $W
echo
echo $E
echo
echo 'W E PARAMS CUSTOM PREFI'
echo "$W $E $PARAMS $CUSTOM $PREFI"
echo
echo "$0 in
`pwd` ?"
read -n1 -t10 k
[ ! "$k" ] && k=Y
k=`echo $k | tr '[[:upper:]]' '[[:lower:]]'`
case "$k" in
y)echo;;
*)echo;exit 1;;
esac

#logsave logsave.`basename $(pwd)`.`date +%d-%H:%M`.log ./configure $W $E $PARAMS $CUSTUM $PREFIXS
logsave logsave.log ./configure $W $E $PARAMS $CUSTOM $PREFI
