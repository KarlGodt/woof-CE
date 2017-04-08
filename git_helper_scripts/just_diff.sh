#!/bin/ash

ME_PROG=`realpath "$0"`
ME_DIR=${ME_PROG%/*}

VERSION=0.0.1

_check_if_already_running()
{
pidof -o $$ -o %PPID "${0##*/}" && {
        echo "Already running."
        exit 1
 }
return $?
}
_check_if_already_running

_check_for_terminal()
{
local MSG
MSG="Need a contolling terminal"
tty >/dev/null || {
echo -n "Pid of X server:"
pidof X && xmessage -br red "$MSG"; exit 2; } || {
echo "$MSG"; exit 2; }
return $?
}
#_check_for_terminal

_exit()
{
RV=$1
shift
echo "$*"
exit $1
}

trap "_exit 99 \"Caught Signal\"" INT KILL TERM

_version()
{
echo "$0:Version:$VERSION"
exit 0
}

_usage()
{
local USAGE_MSG RV
RV=$1
shift
USAGE_MSG="
$0 [ PARAMETERS ]

PARAMETERS :

NONE YET

--
$*
"
echo "$USAGE_MSG"

if test "$RV" != 0; then
_exit $RV "Try again. Good Luck!"
else
exit $RV
fi
return $?
}

__getopt()
{

#POSIXLY_CORRECT=    ##
#GETOPT_COMPATIBLE=  ##

GET_OPT=`busybox getopt \
      -a -l help,version \
      -o h,V \
      -s sh \
      "$*"`
test $? = 0 || _usage 2 "Wrong option."

set - "`echo "$GET_OPT" | sed "s^' '^'\n'^g"`"

while read oneOPTION
do
test "$oneOPTION" || continue
case $oneOPTION
in
*) :;;
esac
done<<EoI
`set`
EoI
set -
return $?
}

_getopts()
{
local oneOPTION
while getopts hV oneOPTION
do
case $oneOPTION
in
h) _usage 0;;
V) _version;;
*) :;;
esac
done
return $?
}

_test()
{
#test "$*"
test $*
case $? in
0)
echo "'$*'" OK
return 0
;;
1)
echo "! '$*'"
return 1
;;
2)
echo "'$*'" wrong input
return 1
;;
esac
return $?
}

_get_argv()
{
local oneARG
for oneARG in $*
do
case $oneARG
in
-*help|help) _usage 0;;
-*version|version) _version;;
*) :;;
esac
done
return $?
}

_get_argv $*
_getopts $*


_logger()
{
local MESSAGE PRIORITY TAG
case $# in
1) MESSAGE="$*";;
2) PRIORITY=$1
   shift
   MESSAGE="$*";;
''|0) echo "$0:_logger [ PRRIORITY ] [[ TAG ]]:Need at least MESSAGE." >&2
      return 1;;
*)
PRIORITY=$1
shift
TAG="$1"
shift
MESSAGE="$*"
;;
esac

#_test "\"$PRIORITY\"" != '""' || PRIORITY=7
#_test "\"$TAG\"" != '""'      || TAG=${0##*/}

_check_content "$PRIORITY" || PRIORITY=7
_check_content "$TAG"      || TAG=${0##*/}

logger -p $PRIORITY -t "$TAG" "$MESSAGE"
return $?

#May 29 09:21:57 puppypc user.debug  /bin/sh: TESTING logger 7
#May 29 09:22:13 puppypc user.info   /bin/sh: TESTING logger 6
#May 29 09:22:19 puppypc user.notice /bin/sh: TESTING logger 5
#May 29 09:22:26 puppypc user.warn   /bin/sh: TESTING logger 4
#May 29 09:22:32 puppypc user.err    /bin/sh: TESTING logger 3
#May 29 09:22:37 puppypc user.crit   /bin/sh: TESTING logger 2
#May 29 09:22:43 puppypc user.alert  /bin/sh: TESTING logger 1
#May 29 09:22:48 puppypc user.emerg  /bin/sh: TESTING logger 0
#May 29 09:22:06 puppypc user.emerg  /bin/sh: TESTING logger 8

}

_basic_error_check()
{
local USAGE RV
USAGE="Usage: _basic_error_check \$? \"MESSAGE\""
RV=$1
test "$RV" || { RV=127; set - $USAGE $*; echo "$USAGE -- got '$*'" >&2; }
test "${RV//[0-9]/}" && { RV=127; set - $USAGE $*; echo "$USAGE -- got '$*'" >&2; }
shift
if test "$RV" != "0"; then
__ERRORS__="$__ERRORS__
'$*' returned '$RV'"
fi
return $RV
}

_check_content()
{
test "$*" || { _err "Usage: _check_content VARIABLE -- got '$*'"; return 0; }
ENOCONTENT=28
#test "$*" && return 0 || { _err "NO content."; return $ENOCONTENT; }
#echo "'`eval echo \\$$*`'"
test "`eval echo \\$$*`" && return 0 || { _err "$*:NO content."; return $ENOCONTENT; }
}

_check_content2()
{
test "$2" || { _err "Usage: _check_content2 PATTERN VARIABLE -- got '$*'"; return 0; }
EWRONGCONTENT=29
case $1 in
digit) gPATTERN="[[:digit:]]";;
alpha) gPATTERN="[[:alpha:]]";;
alnum) gPATTERN="[[:alnum:]]";;
punct) gPATTERN="[[:punct:]]";;
space) gPATTERN="[[:space:]]";;
blank) gPATTERN="[[:blank:]]";;
'') :;;
*) gPATTERN="$*";;
esac
shift
#test "`echo "$*" | grep -E "$gPATTERN"`" && return 0 || return $EWRONGCONTENT
#echo "$*" | grep -q -E "$gPATTERN" && return 0 || return $EWRONGCONTENT
#echo "`eval echo \\$$*`"
echo "`eval echo \\$$*`" | grep -q -E "$gPATTERN" && return 0 || { _warn "$*:No '$gPATTERN' content."; return $EWRONGCONTENT; }
}

_emerg(){
echo "EMERGENGY:$*"
}

_alert(){
echo "$0:ALERT:$*"
}

_crit(){
echo "$0:CRITICAL:$*"
}

_err(){
echo "$0:ERROR:$*"
}

_warn(){
echo "$0:WARNING:$*"
}

_notice(){
echo "$0:NOTICE:$*"
}

_info(){
echo "$0:INFO:$*"
}

_debug(){
echo "$0:DEBUG:$*"
}

_show_log()
{
test -e "$*" || { _err "'$*' does not exist."; return 1; }
test -f "$*" || { _err "'$*' is not a file."; return 2; }
Xdialog -f "$*" 0 0
}

_use_busybox_applets(){

[ "`which busybox`" ] && BBEXE=`which busybox`
[ "$BBEXE" ] || { [ -s /bin/busybox -a -x /bin/busybox ] && BBEXE='/bin/busybox'; }
[ "$BBEXE" ] || return 2  ##errno.h:define ENOENT 2 /* No such file or directory */

BBAPPLETS=`$BBEXE --list`

test "$BBAPPLETS" || BBAPPLETS='basename cat chmod chown clear cut
date dc dd dirname dmesg du ed expr false find free
head kill ln login ls lsmod mkdir mknod more mv nice pidof
readlink rev rm rmdir sleep sort stat su sync tail tar touch tr true
uname usleep waitmax wc which xargs'

for applet in $BBAPPLETS
do
#echo $applet
#file "`which $applet`" | grep 'link' | grep busybox || continue
eval "alias ${applet}=\"$BBEXE $applet\"";

done
}

_return()
{
RV=$1
 test "$RV" && shift || {
 false
 }
test "${RV//[0-9]/}" && RV=123
echo "$*"
return $RV
}


_command() # This is for busybox with internals first .
{          # sed -i and grep -w may not work as the regular binaries ,
           # especially if compiled without REGEX or not with GLIBC
#echo "$0:_command:$1:$*"
COM="$1"
shift
#echo "$0:_command:$1:$*"

typeCOM=`type -p "$COM"`
test "$typeCOM" ||{  _return 1 "No such type \"$COM\"";return $?; }

whichCOM=`which "$COM"`
test "$whichCOM" ||{  _return 1 "No such which \"$COM\"";return $?; }

test "$typeCOM" = "$whichCOM" && {
 "$typeCOM" "$@"    # "$*" does not work, so needs "$@"
 return $?
 } || {
 "$whichCOM" "$@"
 return $?
 }
}

_mkdevices()
{
mountpoint -q /dev && return 0
test "`type mdev`" && { mdev -s && return 0; }
 while read maj min siz dev ; do
  [ "${maj//[[:digit:]]/}" ] && continue
  [ "$maj" -a "$min" -a "$dev" ] || continue
  test -b /dev/$dev || mknod /dev/$dev b $maj $min
 done</proc/partitions
}

_kernel_version()
{
SFSSTR='squashfs, version 4'
SFSMAJOR=4
squashXZ=YES
KERNELVER="`uname -r`"
KERNVER="$KERNELVER"

if vercmp $KERNELVER ge 3.0;then #111016
:    # if vercmp not installed would run else
else # assume 2.6
 test $? = 127 && { _warn "_kernel_version:Is vercomp installed in PATH? -- using _kernel_version2 instead..."; _kernel_version2; }
 #echo $?
 #which vercmp || _kernel_version2

 KERNELSUBVER=`echo -n "$KERNELVER" | cut -f 3 -d '.' | cut -f 1 -d '-' | cut -f 1 -d '_'` #100831
 KERNELSUBSUBVER=`echo -n "$KERNELVER" | cut -f 4 -d '.' | cut -f 1 -d '-'`

 test "$KERNELSUBVER" || KERNELSUBVER=0
 test "${KERNELSUBVER//[[:digit:]]/}" && KERNELSUBVER=0
 test "$KERNELSUBSUBVER" || KERNELSUBSUBVER=0
 test "${KERNELSUBSUBVER//[[:digit:]]/}" && KERNELSUBSUBVER=0

 if [ $KERNELSUBVER -eq 27 -a $KERNELSUBSUBVER -le 46 ] || [ $KERNELSUBVER -le 26 ] || [ $KERNELSUBVER -eq 28 ];then
   SFSSTR='squashfs, version 3'
   SFSMAJOR=3
 fi
 if test $KERNELSUBVER -le 37; then
 squashXZ=NOT
 fi
fi 2>/dev/null
}

_kernel_version2()
{
KERNELVER="`uname -r`"
KERNVER="$KERNELVER"
SFSSTR='squashfs, version 3'
SFSMAJOR=3
squashXZ=NOT

ifsv='.-_'
#ifsv='[[:punct:]]' # also [:punct:] does not work
ifsv='^°!"§$%&/()=?`¹²³¼½¬{[]}\ß´+*~#-_.:·,;'"'"  # '\' seems not to work , even as '\\' '\\\' '\\\\'

      K_VERSION=`echo "$KERNVER" | { IFS="$ifsv" read kversion localversion;echo $kversion; }` ##code from /usr/sbin/laptop_mode, Maintainer: Bart Samwel (bart@samwel.tk)
   K_PATCHLEVEL=`echo "$KERNVER" | { IFS="$ifsv" read kversion patchlevel localversion;echo $patchlevel; }`
     K_SUBLEVEL=`echo "$KERNVER" | { IFS="$ifsv" read kversion patchlevel sublevel localversion;echo $sublevel; }`
   KERNELSUBVER="$K_SUBLEVEL"

 #test "$K_VERSION" || _err "_kernel_version2:Could not get K_VERSION"
 _check_content K_VERSION
 #test "${K_VERSION//[[:digit:]]/}" && _warn "_kernel_version2:Got '$K_VERSION' with other than :digit:"
 _check_content2 onlydigit K_VERSION

 if test $K_VERSION = 3; then
  _info "Newer kernel 3 series"
  K_LOCALVERSION=`echo "$KERNVER" | { IFS="$ifsv" read kversion patchlevel sublevel localversion;echo $localversion; }`
 elif
 test $K_VERSION = 2; then
  _info "Older Kernel 2 series"
  K_EXTRAVERSION=`echo "$KERNVER" | { IFS="$ifsv" read kversion patchlevel sublevel extraversion localversion;echo $extraversion; }`
  K_LOCALVERSION=`echo "$KERNVER" | { IFS="$ifsv" read kversion patchlevel sublevel extraversion localversion;echo $localversion; }`
 else
  _err "Unhandled K_VERSION '$K_VERSION'"
 fi

[ "$K_EXTRAVERSION" ] || K_EXTRAVERSION=0
[ "${K_EXTRAVERSION//[[:digit:]]/}" ] && { K_LOCALVERSION="$K_EXTRAVERSION $K_LOCALVERSION";K_EXTRAVERSION=0; }
KERNELSUBSUBVER="$K_EXTRAVERSION"

case $K_VERSION in
3) SFSSTR='squashfs, version 4';SFSMAJOR=4;squashXZ=YES;;
2)
        case $K_PATCHLEVEL in
        6)
                case $K_SUBLEVEL in
                29|30|31|32|33|34|35|36|37) SFSSTR='squashfs, version 4';SFSMAJOR=4;;
                38|39) SFSSTR='squashfs, version 4';SFSMAJOR=4;squashXZ=YES;;
                28)
                    case $K_EXTRAVERSION in
                    46) SFSSTR='squashfs, version 4';;
                    esac
                ;;
                *) _notice "Old 2.6 kernel version '$K_VERSION' patchlevel '$K_PATCHLEVEL' sublevel '$K_SUBLEVEL' .";;
                esac;;
        0|1|2|3|4|5) _crit "Unhandled kernel version '$K_VERSION' patchlevel '$K_PATCHLEVEL' .";;
        *) _alert "Unhandled kernel version '$K_VERSION' patchlevel '$K_PATCHLEVEL' .";;
        esac;;
*) _emerg "Unhandled kernel version '$K_VERSION' .";;
esac
}

_kernel_version3()
{

test -f /proc/config.gz || modprobe -v configs
test -f /proc/config.gz && {

 VERSIONS=`zcat /proc/config.gz | grep -m1 -E '# Linux kernel version: .*|CONFIG_LOCALVERSION=".*"'`
 KERNELVER=`echo "$VERSIONS" | grep -m1 '# Linux kernel version: .*' | cut -f2 -d:`
 LOCALVERSION=`echo "$VERSIONS" -grep -m1 'CONFIG_LOCALVERSION=".*"' | cut -f2 -d=`

 SFSSTR='squashfs, version 4'
 SFSMAJOR=4
 squashXZ=YES
 KERNELVER="`uname -r`"
 KERNVER="$KERNELVER"

 if test "`echo "$KERNELVER" | grep '^3.0'`"; then #111016
 :

 elif echo "$KERNELVER" | grep -q '^2.6'; then

 KERNELSUBVER=`echo -n "$KERNELVER" | cut -f 3 -d '.' | cut -f 1 -d '-' | cut -f 1 -d '_'` #100831
 KERNELSUBSUBVER=`echo -n "$KERNELVER" | cut -f 4 -d '.' | cut -f 1 -d '-'`
 test "$KERNELSUBVER" || KERNELSUBVER=0
 test "${KERNELSUBVER//[[:digit:]]/}" && KERNELSUBVER=0
 test "$KERNELSUBSUBVER" || KERNELSUBSUBVER=0
 test "${KERNELSUBSUBVER//[[:digit:]]/}" && KERNELSUBSUBVER=0

 if [ $KERNELSUBVER -eq 27 -a $KERNELSUBSUBVER -le 46 ] || [ $KERNELSUBVER -le 26 ] || [ $KERNELSUBVER -eq 28 ];then
  SFSSTR='squashfs, version 3'
  SFSMAJOR=3
 fi
 if test $KERNELSUBVER -le 37; then
  squashXZ=NOT
 fi

 else # assume 2.6

 KERNELSUBVER=`echo -n "$KERNELVER" | cut -f 3 -d '.' | cut -f 1 -d '-' | cut -f 1 -d '_'` #100831
 KERNELSUBSUBVER=`echo -n "$KERNELVER" | cut -f 4 -d '.' | cut -f 1 -d '-'`
 test "$KERNELSUBVER" || KERNELSUBVER=0
 test "${KERNELSUBVER//[[:digit:]]/}" && KERNELSUBVER=0
 test "$KERNELSUBSUBVER" || KERNELSUBSUBVER=0
 test "${KERNELSUBSUBVER//[[:digit:]]/}" && KERNELSUBSUBVER=0

 if [ $KERNELSUBVER -eq 27 -a $KERNELSUBSUBVER -le 46 ] || [ $KERNELSUBVER -le 26 ] || [ $KERNELSUBVER -eq 28 ];then
  SFSSTR='squashfs, version 3'
  SFSMAJOR=3
 fi
 if test $KERNELSUBVER -le 37; then
  squashXZ=NOT
 fi
fi
 } || _kernel_version
}

_mk_free_loop()
{
  FREE_LOOP=`losetup -f`  # find free and create loop
  [ "$FREE_LOOP" ] || {   # for kernel 3.0 and earlier
  LOOPS_ALL=`ls -1v /dev/loop* |sed 's%[^[:digit:]]%%g'`
  LOOP_LAST=`echo "$LOOPS_ALL" | tail -n1`
  LOOP_NEW=$(( $LOOP_LAST + 1 ))
  mknod /dev/loop${LOOP_NEW} b 7 $LOOP_NEW
  }
}


#================ Check GETTEXT ==============================================
_check_gettext()
{
_G=`which gettext`
test "$_G" && {
 test "`which gettext.sh`" && {
export TEXTDOMAIN=remasterpup2x #NOTE: rename to avoid clash with 'remasterpup2.mo' used by previous i18n method.
export OUTPUT_CHARSET=UTF-8
. gettext.sh
test "`type -t eval_gettext`"   &&  _eG=eval_gettext
if test "`which ngettext`"; then
 test "`type -t eval_ngettext`" && _eNG=eval_ngettext
fi
  }
 }

test "$_G"   ||   _G=echo
test "$_eG"  ||  _eG=echo
test "$_eNG" || _eNG=echo
#echo "_G='$_G'"
#echo "_eG='$_eG'"
#echo "_eNG='$_eNG'"
}
_check_gettext

# testing this script

#outDDCPROBE=`ddcprobe`
#_check_content outDDCPROBE
#_check_content2 alnum outDDCPROBE

A="here is              tabtab

a

long
list somehow with 'ABC' ^°!\"§\$%&/()=?-_<>|
"

#_check_content A
#_check_content2 digit A

_logger_test(){
echo 0
_logger
_basic_error_check $? "First call to _logger"
echo 1
_logger "MESSAGE"
_basic_error_check $? "Second call to _logger"
echo 2
_logger 7 "MESSAGE"
_basic_error_check $? "Third call to _logger"
echo 3
_logger 7 TAG "$MESSAGE"
_basic_error_check $? "Fourth call to _logger"
echo "$__ERRORS__"
}


# ZHIS ZCRIPT ZOULD ZUST ZIFF -qs ZHE GIT ZILES
# zand zist /tmp/woof-diff-files.lst zin geany -i

cd "$ME_DIR" || exit 3

pwd # zebug

rm $VERB -f /tmp/woof-diff-files.lst

while :;
do
test -d ${BACK}woof-code/rootfs-skeleton && break

BACK=${BACK}../

END=`realpath "${BACK}"`
echo "$END" #zebug
if test "$END" = '/'; then exit 4; fi

sleep 0.1
done

echo "$BACK" #zebug

find "${BACK}"woof-code/rootfs-skeleton -type f | while read file
do

#echo "$file"
diff -qs "$file" "${file##*rootfs-skeleton}" && continue
echo  "$file" >>/tmp/woof-diff-files.lst

done

geany -i /tmp/woof-diff-files.lst &
