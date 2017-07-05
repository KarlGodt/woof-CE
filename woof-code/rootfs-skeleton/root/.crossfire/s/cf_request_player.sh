#!/bin/ash

ME_PROG=`readlink -f "$0"`
ME_DIR=${ME_PROG%/*}
cd "$ME_DIR"

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
exit $RV
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

# *** Here begins program *** #

# *** VARIABLES *** #

MY_SELF=`realpath "$0"`
MY_BASE=${MY_SELF##*/}
test -f "${MY_SELF%/*}"/cf_functions.sh   && . "${MY_SELF%/*}"/cf_functions.sh
_set_global_variables "$@"
# *** Override any VARIABLES in cf_functions.sh *** #
test -f "${MY_SELF%/*}"/"${MY_BASE}".conf && . "${MY_SELF%/*}"/"${MY_BASE}".conf


# *** Here begins program *** #
_say_start_msg "$@"

# *** PARAMETERS *** #

echo request player
while :;
do
read -t 1
echo draw 10 "REQUEST PLAYER:'$REPLY'"
c=$((c+1))
test "$c" = 9 && break
test "$REPLY" || break
MY_NAME_ALL="$REPLY"
unset REPLY
sleep 0.1
done

read r p N P MY_NAME_W_TITLE <<EoI
`echo "$MY_NAME_ALL"`
EoI

#MY_NAME=`echo "$MY_NAME_W_TITLE" | sed 's% the .*%%'`  #MIKE the Mechanic
MY_NAME=`echo "$MY_NAME_W_TITLE" | awk '{print $1}'`    #Nico a wonderful terrible
echo draw 7 "Player:'$MY_NAME'"
test "$MY_NAME"

# *** Here ends program *** #
_say_end_msg
