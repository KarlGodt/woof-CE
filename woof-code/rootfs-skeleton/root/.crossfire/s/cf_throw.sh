#!/bin/ash

ME_PROG=`realpath "$0"`
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

use_busybox_applets(){

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


exec 2>/tmp/cf_script.err

DRAW_INFO=drawinfo # drawextinfo

# FOREVER mode
INF_THRESH=30 # threshold to cast dexterity and probe
INF_TOGGLE=4  # threshold to cast restoration (INF_THRESH * INF_TOGGLE)
BAD_THRESH=3  # threshold to attack in DIR

THROW_OBJ='throwing dagger'
MAX_THROW=9
CHECK_ITEM_THRESH=34 # use_skill throwing would throw other items
                     # than marked ones without msg in the pane.
                     # check _mark_item if still possible after CHECK_ITEM_THRESH throws

LOG_REPLY_FILE=/tmp/cf_script.rpl

rm -f "$LOG_REPLY_FILE"

# ** ping if bad connection ** #
PING_DO=1
URL=crossfire.metalforge.net


# *** Here begins program *** #
echo draw 2 "$0 is started.."

# *** Check for parameters *** #

# *** implementing 'help' option *** #
_usage() {

echo draw 5 "Script to use_skill oratory."
echo draw 5 "Syntax:"
echo draw 5 "script $0 <direction> [number]"
echo draw 5 "For example: 'script $0 5 west'"
echo draw 5 "will issue 5 use_skill throwing in west."
echo draw 6 "Abbr. for north:n, northeast:ne .."
echo draw 6 "Use -I --infinite to run forever."
        exit 0
}

echo draw 3 "'$#' Parameters: '$*'"

until test $# = 0;
do

PARAM_1="$1"
case $PARAM_1 in
[0-9]*) NUMBER=$PARAM_1; test "${NUMBER//[[:digit:]]/}" && {
       echo draw 3 "Only :digit: numbers as first option allowed."; exit 1; }
       readonly NUMBER
       #echo draw 2 "NUMBER=$NUMBER"
       ;;
 n|north)       DIR=north;     DIRN=1;; #readonly DIR DIRN;;
ne|norteast)    DIR=northeast; DIRN=2;; #readonly DIR DIRN;;
 e|east)        DIR=east;      DIRN=3;; #readonly DIR DIRN;;
se|southeast)   DIR=southeast; DIRN=4;; #readonly DIR DIRN;;
 s|south)       DIR=south;     DIRN=5;; #readonly DIR DIRN;;
sw|southwest)   DIR=southwest; DIRN=6;; #readonly DIR DIRN;;
 w|west)        DIR=west;      DIRN=7;; #readonly DIR DIRN;;
nw|northwest)   DIR=northwest; DIRN=8;; #readonly DIR DIRN;;
-h|*help)       _usage;;
-I|*infinite)   FOREVER=1;;
'')     :;;
*)      echo draw 3 "Incorrect parameter '$PARAM_1' ."; exit 1;;
esac
sleep 1
shift
#echo draw "'$#'"

done

readonly NUMBER DIR DIRN
echo draw 3 "NUMBER='$NUMBER' DIR='$DIR' DIRN='$DIRN'"


# TODO: check for near doors and direct to them

if test "$DIR"; then
 :
else
 echo draw 3 "Need direction as parameter."
 exit 1
fi

_ping(){
test "$PING_DO" || return 0
while :;
do
ping -c1 -w10 -W10 "$URL" && break
sleep 1
done >/dev/null
}



_cast_dexterity(){
# ** cast DEXTERITY ** #

local REPLY c

echo watch $DRAW_INFO

echo issue 1 1 cast dexterity # don't mind if mana too low, not capable or bungles for now
sleep 0.5
echo issue 1 1 fire ${DIRN:-0}
sleep 0.5
echo issue 1 1 fire_stop
sleep 0.5

while :;
do
unset REPLY
sleep 0.1
 read -t 1
 [ "$LOGGING" ] && echo "_cast_dexterity:$REPLY" >>"$LOG_REPLY_FILE"
 [ "$DEBUG" ] && echo draw ${COL_GREEN:-7} "REPLY='$REPLY'" #debug

 case $REPLY in  # server/spell_util.c
 '*Something blocks the magic of your item.'*)   unset CAST_DEX CAST_PROBE;;
 '*Something blocks the magic of your scroll.'*) unset CAST_DEX CAST_PROBE;;
 *'Something blocks your spellcasting.'*)        unset CAST_DEX CAST_PROBE;;
 *'This ground is unholy!'*)                     unset CAST_REST;;
 *'You grow no more agile.'*)                    unset CAST_DEX;;
 *'You lack the skill '*)                        unset CAST_DEX;;
 *'You lack the proper attunement to cast '*)    unset CAST_DEX;;
 *'That spell path is denied to you.'*)          unset CAST_DEX;;
 *'You recast the spell while in effect.'*) INF_THRESH=$((INF_THRESH+1));;
 *) c=$((c+1)); test "$c" = 9 && break;; # 9 is just chosen as threshold for spam in msg pane
 esac

done

#You grow no more agile.

echo unwatch $DRAW_INFO

}
CAST_REST=_cast_restoration
CAST_PROBE=_cast_probe
CAST_DEX=_cast_dexterity
$CAST_DEX
#_cast_dexterity

_cast_probe(){
# ** cast PROBE ** #

local REPLY c

echo watch $DRAW_INFO

echo issue 1 1 cast probe # don't mind if mana too low, not capable or bungles for now
sleep 0.5
echo issue 1 1 fire ${DIRN:-0}
sleep 0.5
echo issue 1 1 fire_stop
sleep 0.5

while :;
do
unset REPLY
sleep 0.1
 read -t 1
 echo "_cast_charisma:$REPLY" >>"$LOG_REPLY_FILE"
 echo draw 3 "REPLY='$REPLY'"

 case $REPLY in  # server/spell_util.c
 '*Something blocks the magic of your item.'*)   unset CAST_DEX CAST_PROBE;;
 '*Something blocks the magic of your scroll.'*) unset CAST_DEX CAST_PROBE;;
 *'Something blocks your spellcasting.'*)        unset CAST_DEX CAST_PROBE;;
 *'This ground is unholy!'*)                  unset CAST_REST;;
 #*'You are no easier to look at.'*)           unset CAST_CHA;;
 *'You lack the skill '*)                     unset CAST_DEX;;
 *'You lack the proper attunement to cast '*) unset CAST_DEX;;
 *'That spell path is denied to you.'*)       unset CAST_DEX;;
 *'You recast the spell while in effect.'*) INF_THRESH=$((INF_THRESH+1));;
 *) c=$((c+1)); test "$c" = 9 && break;; # 9 is just chosen as threshold for spam in msg pane
 esac

done

echo unwatch $DRAW_INFO

}

$CAST_PROBE

_cast_restoration(){
# ** if infinite loop, needs food ** #

local REPLY c

echo watch $DRAW_INFO

echo issue 1 1 cast restoration # don't mind if mana too low, not capable or bungles for now
sleep 0.5
echo issue 1 1 fire ${DIRN:-0}
sleep 0.5
echo issue 1 1 fire_stop
sleep 0.5

while :;
do
unset REPLY
sleep 0.1
 read -t 1
 echo "_cast_charisma:$REPLY" >>"$LOG_REPLY_FILE"
 echo draw 3 "REPLY='$REPLY'"

 case $REPLY in  # server/spell_util.c
 '*Something blocks the magic of your item.'*)   unset CAST_DEX CAST_PROBE;;
 '*Something blocks the magic of your scroll.'*) unset CAST_DEX CAST_PROBE;;
 *'Something blocks your spellcasting.'*)        unset CAST_DEX CAST_PROBE;;
 *'This ground is unholy!'*)                  unset CAST_REST;;
 #*'You are no easier to look at.'*)           unset CAST_CHA;;
 *'You lack the skill '*)                     unset CAST_REST;;
 *'You lack the proper attunement to cast '*) unset CAST_REST;;
 *'That spell path is denied to you.'*)       unset CAST_REST;;
 *'You recast the spell while in effect.'*) INF_THRESH=$((INF_THRESH+1));;
 *) c=$((c+1)); test "$c" = 9 && break;; # 9 is just chosen as threshold for spam in msg pane
 esac

done

echo unwatch $DRAW_INFO

}

$CAST_REST

___check_have(){
local REPLY=''

while :;
do
unset REPLY
sleep 0.1
read -t 1
case $REPLY in

*) echo draw 3 "DEBUG:$REPLY"; break;;
esac
done
return 1
}

#echo watch $DRAW_INFO

_mark_item(){
echo watch $DRAW_INFO

echo issue 1 1 mark "$THROW_OBJ"
#sleep 0.5

c=0
while :; do
unset REPLY
sleep 0.1
 read -t 1
 echo "_mark_item:$REPLY" >>"$LOG_REPLY_FILE"
 echo draw 3 "REPLY='$REPLY'"
 case $REPLY in
 *'Could not find an object that matches '*) return 3;;
 *'Marked item '*) break;;
 *) c=$((c+1)); test "$c" = 9 && break;; # 9 is just chosen as threshold for spam in msg pane
 esac
done

echo unwatch $DRAW_INFO
return 0
}
_mark_item || exit 1

NUM=$NUMBER
c=0; cc=0; C=0

TIMEB=`/bin/date +%s`

while :;
do

C=$((C+1))
echo draw 7 "throwing $C .."
echo issue 1 1 use_skill throwing
c=$((c+1))
#test "$c" -ge $CHECK_ITEM_THRESH && _check_have && break
test "$c" -ge $CHECK_ITEM_THRESH && { _mark_item || break; c=0; }

if test "$FOREVER"; then
 cc=$((cc+1))
 test "$cc" = $INF_THRESH && {
  if test "$TOGGLE" = $INF_TOGGLE; then
   $CAST_REST
       TOGGLE=0
  else TOGGLE=$((TOGGLE+1));
  fi
  #_cast_dexterity
  $CAST_DEX
  $CAST_PROBE
  echo draw 3 "Infinite loop. Use 'scriptkill $0' to abort."; cc=0;
  }

elif test "$NUMBER"; then
 NUM=$((NUM-1)); test "$NUM" -gt 0 || break;
else
 #c=$((c+1));
 test "$c" -lt $MAX_THROW || break;
fi


sleep 0.6  # 0.2 had been too fast for catching correct replys, 0.5 almost
#echo draw 7 "end of throwing loop"
done

TIMEE=`/bin/date +%s`
TIMEX=$((TIMEE-TIMEB))
TIMEM=$((TIMEX/60))
TIMES=$(( TIMEX - (TIMEM*60) ))

case $TIMES in [0-9]) TIMES="0$TIMES";; esac

echo draw 4 "You threw '$C' times."
echo draw 5 "Loop took $TIMEM:$TIMES minutes."
echo draw 2 "$0 is finished."
beep -f 700 -l 1000
