#!/bin/sh
#(c) Copyright Barry Kauler 2009, puppylinux.com
#2009 Lesser GPL licence v2 (http://www.fsf.org/licensing/licenses/lgpl.html).
#called from /usr/local/petget/downloadpkgs.sh.
#passed param is the path and name of the downloaded package.
#100116 add support for .tar.bz2 T2 pkgs.
#100616 add support for .txz slackware pkgs.
#101225 bug fix, .pet was converted to .tar.gz, restore to .pet.



#************
#KRG


OUT=/dev/null;ERR=$OUT
[ "$DEBUG" ] && { OUT=/dev/stdout;ERR=/dev/stderr; }
[ "$DEBUG" = 2 ] && set -x


Version=1.1-KRG-MacPup_O2

usage(){
MSG="
$0 [ help | version ]
"
echo "$MSG
$2"
exit $1
}
[ "`echo "$1" | grep -Ei "help|\-h"`" ] && usage 0
[ "`echo "$1" | grep -Ei "version|\-V"`" ] && { echo "$0: $Version";exit 0; }


trap "exit" HUP INT QUIT ABRT KILL TERM


#KRG
#************


echo "$0: START" >&2

OUT=/dev/null;ERR=$OUT
[ "$DEBUG" ] && { OUT=/dev/stdout;ERR=/dev/stderr; }

error_1(){
MSG="$0
ERROR
$1
returned other than 0
.
"
echo "$MSG" >/dev/stdout
[ "$DISPLAY" ] && xmessage -bg red1 "$MSG"
exit 1
}

export LANG=C
. /etc/rc.d/PUPSTATE  #this has PUPMODE and SAVE_LAYER.
. /etc/DISTRO_SPECS #has DISTRO_BINARY_COMPAT, DISTRO_COMPAT_VERSION
mkdir -p /tmp/petget #101225

DLPKG="$1"
DLPKG_BASE=`basename $DLPKG` #ex: scite-1.77-i686-2as.tgz
DLPKG_PATH=`dirname $DLPKG`  #ex: /root

FLAG="ok"
cd $DLPKG_PATH

case $DLPKG_BASE in
 *.pet)
  #101225 bug fix, .pet was converted to .tar.gz, restore to .pet...
  DLPKG_MAIN=`basename $DLPKG_BASE .pet`
  FULLSIZE=`stat --format=%s "${DLPKG_BASE}"`
  ORIGSIZE=`expr $FULLSIZE - 32`
  dd if="${DLPKG_BASE}" of=/tmp/petget/petmd5sum bs=1 skip=${ORIGSIZE} 2>$OUT
  sync
  MD5SUM=`cat /tmp/petget/petmd5sum`
  pet2tgz $DLPKG_BASE
  [ $? -ne 0 ] && FLAG="bad"
  if [ -f ${DLPKG_PATH}/${DLPKG_MAIN}.tar.gz ];then
   mv -f ${DLPKG_PATH}/${DLPKG_MAIN}.tar.gz ${DLPKG_PATH}/${DLPKG_MAIN}.pet
   echo -n "$MD5SUM" >> ${DLPKG_PATH}/${DLPKG_MAIN}.pet
  fi
 ;;
 *.*pet)
   case $DLPKG_BASE in
   *.b2pet) OPT=-b;COMPRESS_EXT=bz2;CE=$COMPRESS_EXT;;
   *.lopet) OPT=-l;COMPRESS_EXT=lzo;CE=$COMPRESS_EXT;;
   *.lapet) OPT=-L;COMPRESS_EXT=lzma;CE=$COMPRESS_EXT;;
   *.xzpet) OPT=-x;COMPRESS_EXT=xz;CE=$COMPRESS_EXT;;
   *) OPT=-g;COMPRESS_EXT=gz;CE=$COMPRESS_EXT;;;;
   esac
  pet2tgz $OPT $DLPKG_BASE
   [ $? -ne 0 ] && error_1 "pet2tgz $OPT $DLPKG_BASE"
  tgz2pet $OPT ${DLPKG_BASE%\.*}.tar.$CE
   [ $? -ne 0 ] && error_1 "tgz2pet $OPT ${DLPKG_BASE%\.*}.tar.$CE"
 ;;

 *.lopet)
 pet2tgz -l $DLPKG_BASE
  [ $? -ne 0 ] && error_1 "pet2tgz -l $DLPKG_BASE"
 tgz2pet -l ${DLPKG_BASE%\.*}.tar.lzo
  [ $? -ne 0 ] && error_1 "tgz2pet -l ${DLPKG_BASE%\.*}.tar.lzo"
 ;;
 *.lapet)
 pet2tgz -L $DLPKG_BASE
  [ $? -ne 0 ] && error_1 "pet2tgz -L $DLPKG_BASE"
 tgz2pet -L ${DLPKG_BASE%\.*}.tar.lzma
  [ $? -ne 0 ] && error_1 "tgz2pet -L ${DLPKG_BASE%\.*}.tar.lzma"
 ;;
 *.xzpet)
 pet2tgz -x $DLPKG_BASE
  [ $? -ne 0 ] && error_1 "pet2tgz -x $DLPKG_BASE"
 tgz2pet -x ${DLPKG_BASE%\.*}.tar.xz
  [ $? -ne 0 ] && error_1 "tgz2pet -x ${DLPKG_BASE%\.*}.tar.xz"
 ;;

 *.pup)
 :
 ;;

 *.deb)
  DLPKG_MAIN=`basename $DLPKG_BASE .deb`
  dpkg-deb --contents $DLPKG_BASE
  [ $? -ne 0 ] && FLAG="bad"
 ;;
 *.tgz)
  DLPKG_MAIN=`basename $DLPKG_BASE .tgz` #ex: scite-1.77-i686-2as
  gzip --test $DLPKG_BASE > $OUT 2>$ERR
  [ $? -ne 0 ] && FLAG="bad"
 ;;
 *.txz)
  DLPKG_MAIN=`basename $DLPKG_BASE .txz` #ex: scite-1.77-i686-2as
  xz --test $DLPKG_BASE > $OUT 2>$ERR
  [ $? -ne 0 ] && FLAG="bad"
 ;;
 *.tar.gz)
  DLPKG_MAIN=`basename $DLPKG_BASE .tar.gz` #ex: acl-2.2.47-1-i686.pkg
  gzip --test $DLPKG_BASE > $OUT 2>$ERR
  [ $? -ne 0 ] && FLAG="bad"
 ;;
 *.tar.bz2) #100116
  DLPKG_MAIN=`basename $DLPKG_BASE .tar.bz2`
  bzip2 --test $DLPKG_BASE > $OUT 2>$ERR
  [ $? -ne 0 ] && FLAG="bad"
 ;;
 *.tar.*)
  TAR_COMPRESS_EXT="${DLPKG_BASE##*\.}";TCE=$TAR_COMPRESS_EXT
    case $TCE in
      gz)   COMPRESSBIN=gzip;TEST=--test;;
      bz2)  COMPRESSBIN=bzip2;TEST=--test;;
      lzo)  COMPRESSBIN=lzopTEST=--test;;;
      lzma) COMPRESSBIN=lzma;TEST=--test;;
      xz)   COMPRESSBIN=xz;TEST=--test;;
    esac
    [ "`which $COMPRESSBIN`" ] || error_1 "'$COMPRESSBIN' Not found ?"
   $COMPRESSBIN $TEST $DLPKG_BASE >$OUT 2>$ERR
    [ $? -ne 0 ] && FLAG="bad"
 ;;
esac

if [ "$FLAG" = "bad" ];then
 #rm -f $DLPKG_BASE >$OUT 2>$ERR
 #rm -f ${DLPKG_MAIN}.tar.gz >$OUT 2>$ERR
 xmessage -bg red "$0 :
WARNING some tests on $DLPKG_BASE
failed.
"
 exit 1
fi
echo "$0: END" >&2
exit $?
###END###
