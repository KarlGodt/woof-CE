#!/bin/sh
#(c) Copyright Barry Kauler 2009, puppylinux.com
#2009 Lesser GPL licence v2 (http://www.fsf.org/licensing/licenses/lgpl.html).
#called from /usr/local/petget/downloadpkgs.sh.
#passed param is the path and name of the downloaded package.


###KRG Fr 31. Aug 23:34:58 GMT+1 2012



trap "exit 1" HUP INT QUIT KILL TERM


OUT=/dev/null;ERR=$OUT
[ "$DEBUG" ] && { OUT=/dev/stdout;ERR=/dev/stderr; }
[ "$DEBUG" = "2" ] && set -x


Version='1.1'


usage(){
USAGE_MSG="
$0 [ PARAMETERS ]

-V|--version : showing version information
-H|--help : show this usage information

*******  *******  *******  *******  *******  *******  *******  *******  *******
$2
"
exit $1
}

[ "`echo "$1" | grep -wiE "help|\-H"`" ] && usage 0
[ "`echo "$1" | grep -wiE "\-version|\-V"`" ] && { echo "$0 -version $Version";exit 0; }



###KRG Fr 31. Aug 23:34:58 GMT+1 2012



out=/dev/null;err=$out
case $2 in
debug) set -x;;
verbose) DEBUG=1;VERB=-v;L_VERB=--verbose;A_VERB=-verbose;out=/dev/stdout;err=/dev/stderr;;
esac

echo "$0:$*" >&2

export LANG=C
. /etc/rc.d/PUPSTATE  #this has PUPMODE and SAVE_LAYER.
. /etc/DISTRO_SPECS #has DISTRO_BINARY_COMPAT, DISTRO_COMPAT_VERSION

DLPKG="$1"
DLPKG_BASE=`basename $DLPKG` #ex: scite-1.77-i686-2as.tgz
DLPKG_PATH=`dirname $DLPKG`  #ex: /root

FLAG="ok"
cd $DLPKG_PATH

case $DLPKG_BASE in
*.tar.*) TAR_COMPRESS_EXT="${DLPKG_BASE##*\.}"
esac

case $DLPKG_BASE in
 *.pet)
  DLPKG_MAIN=`basename $DLPKG_BASE .pet`
  pet2tgz $DLPKG_BASE
  [ $? -ne 0 ] && FLAG="bad"
  tgz2pet ${DLPKG_BASE%.*}.tar.gz
  [ $? -ne 0 ] && FLAG="bad"
 ;;
 *.pup)
  DLPKG_MAIN=`basename $DLPKG_BASE .pup`
  unzip -t $DLPKG_BASE
  [ $? -ne 0 ] && FLAG="bad"
 ;;
 *.deb)
  DLPKG_MAIN=`basename $DLPKG_BASE .deb`
  dpkg-deb --contents $DLPKG_BASE
  [ $? -ne 0 ] && FLAG="bad"
 ;;
 *.tgz)
  DLPKG_MAIN=`basename $DLPKG_BASE .tgz` #ex: scite-1.77-i686-2as
  gzip --test $DLPKG_BASE >$out 2>&1
  [ $? -ne 0 ] && FLAG="bad"
 ;;
 *.tar.gz)
  DLPKG_MAIN=`basename $DLPKG_BASE .tar.gz` #ex: acl-2.2.47-1-i686.pkg
  gzip --test $DLPKG_BASE >$out 2>&1
  [ $? -ne 0 ] && FLAG="bad"
 ;;
 *.txz)
  DLPKG_MAIN=`basename $DLPKG_BASE .txz` #ex: scite-1.77-i686-2as
  xz --test $DLPKG_BASE >$out 2>&1
  [ $? -ne 0 ] && FLAG="bad"
 ;;
 *.tar.xz)
  DLPKG_MAIN=`basename $DLPKG_BASE .tar.xz` #ex: acl-2.2.47-1-i686.pkg
  gzip --test $DLPKG_BASE >$out 2>&1
  [ $? -ne 0 ] && FLAG="bad"
 ;;
 *.tar.bz2)
  DLPKG_MAIN=`basename $DLPKG_BASE .tar.bz2` #ex: acl-2.2.47-1-i686.pkg
  bzip2 --test $DLPKG_BASE >$out 2>&1
  [ $? -ne 0 ] && FLAG="bad"
 ;;
 *.tar.lzma|*.tar.lzm|*.tar.lza)
  DLPKG_MAIN=`basename $DLPKG_BASE .tar.$TAR_COMPRESS_EXT` #ex: acl-2.2.47-1-i686.pkg
  lzma --test $DLPKG_BASE >$out 2>&1
  [ $? -ne 0 ] && FLAG="bad"
 ;;
 *.tar.lzop|*.tar.lzo|*.tar.lzp)
  DLPKG_MAIN=`basename $DLPKG_BASE .tar.$TAR_COMPRESS_EXT` #ex: acl-2.2.47-1-i686.pkg
  lzop --test $DLPKG_BASE >$out 2>&1
  [ $? -ne 0 ] && FLAG="bad"
 ;;
esac

if [ "$FLAG" = "bad" ];then
 #rm -f $DLPKG_BASE > /dev/null 2>&1
 #rm -f ${DLPKG_MAIN}.tar.gz > /dev/null 2>&1
 xmessage -bg red "$0
    WARNING: Seems the
$DLPKG_BASE does not test ok
"
 exit 1
fi
exit 0
###END###
