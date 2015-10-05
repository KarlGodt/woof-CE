#!/bin/ash

export PATH=/bin:/usr/bin

# *** Here begins program *** #
echo draw 2 "$0 is started.."
echo draw 2 "PID is $$ - parentPID is $PPID"

# *** PARAMETERS *** #

TMOUT=1    # read -t timeout

DIRB=east  # direction back to go

case $DIRB in
west)  DIRF=east;;
east)  DIRF=west;;
north) DIRF=south;;
south) DIRF=north;;
esac

# Log file path in /tmp
MY_SELF=`realpath "$0"`
MY_BASE=${MY_SELF##*/}
TMP_DIR=/tmp/crossfire
mkdir -p "$TMP_DIR"
REPLY_LOG="$TMP_DIR"/"$MY_BASE".$$.rpl
REQUEST_LOG="$TMP_DIR"/"$MY_BASE".$$.req
ON_LOG="$TMP_DIR"/"$MY_BASE".$$.ion

exec 2>>"$TMP_DIR"/"$MY_BASE".$$.err

# *** Check for parameters *** #
echo drawnifo 5 "Checking the parameters ($*)..."

[ "$*" ] && {
PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in *"help"*)

echo draw 5 "Script to produce water of the wise."
echo draw 7 "Syntax:"
echo draw 7 "$0 NUMBER"
echo draw 5 "Allowed NUMBER will loop for"
echo draw 5 "NUMBER times to produce NUMBER of"
echo draw 5 "Balm of First Aid ."

        exit 0
;; esac

PARAM_1test="${PARAM_1//[[:digit:]]/}"
test "$PARAM_1test" && {
echo draw 3 "Only :digit: numbers as option allowed."
        exit 1 #exit if other input than numbers
        }

NUMBER=$PARAM_1

} || {
echo draw 3 "Script needs number of alchemy attempts as argument."
        exit 1
}

test "$1" || {
echo draw 3 "Need <number> ie: script $0 4 ."
        exit 1
}

echo drawinfo 7 "OK."


test -f "${MY_SELF%/*}"/cf_functions.sh && . "${MY_SELF%/*}"/cf_functions.sh

# *** Check if standing on a cauldron *** #
__check_if_on_cauldron(){
echo drawinfo 5 "Checking if on a cauldron..."

UNDER_ME='';
echo request items on

while :; do
#unset UNDER_ME
read -t $TMOUT UNDER_ME
#echo "$UNDER_ME" >>"$ON_LOG"
UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"
test "$UNDER_ME" = "request items on end" && break
test "$UNDER_ME" = "scripttell break" && break
test "$UNDER_ME" = "scripttell exit" && exit 1
unset UNDER_ME
sleep 0.1s
done

test "`echo "$UNDER_ME_LIST" | grep 'cauldron$'`" || {
echo draw 3 "Need to stand upon cauldron!"
beep -l 1000 -f 700
exit 1
}

echo drawinfo 7 "OK."
}

_check_if_on_cauldron

_issue(){
    echo issue "$@"
    sleep 0.2
}

# *** EXIT FUNCTIONS *** #
_f_exit(){
issue 1 1 $DIRB
issue 1 1 $DIRB
issue 1 1 $DIRF
issue 1 1 $DIRF
sleep ${SLEEP}s
echo draw 3 "Exiting $0."
#echo unmonitor
#echo unwatch monitor
#echo unwatch monitor issue
echo unwatch
echo unwatch drawinfo
beep -l 1000 -f 700
exit $1
}

_f_emergency_exit(){
issue 1 1 apply rod of word of recall
issue 1 1 fire center
echo draw 3 "Emergency Exit $0 !"
echo unwatch drawinfo
issue 1 1 fire_stop
beep -l 1000 -f 700
exit $1
}

_f_exit_no_space(){
echo draw 3 "On position $nr $DIRB there is Something ($IS_WALL)!"
echo draw 3 "Remove that Item and try again."
echo draw 3 "If this is a Wall, try another place."
beep -l 1000 -f 700
exit $1
}

rm -f "$REPLY_LOG"    # empty old log files
rm -f "$REQUEST_LOG"
rm -f "$ON_LOG"

__check_for_space(){
# *** Check for 4 empty space to DIRB ***#

echo drawinfo 5 "Checking for space to move..."

echo request map pos

echo watch request

while :; do
read -t $TMOUT REPLY_MAP
echo "request map pos:$REPLY_MAP" >>"$REPLY_LOG"
test "$REPLY_MAP" || break
test "$REPLY_MAP" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY_MAP"
sleep 0.1s
done

echo unwatch request


PL_POS_X=`echo "$REPLY_MAP" | awk '{print $4}'`
PL_POS_Y=`echo "$REPLY_MAP" | awk '{print $5}'`

if test "$PL_POS_X" -a "$PL_POS_Y"; then

if test ! "${PL_POS_X//[[:digit:]]/}" -a ! "${PL_POS_Y//[[:digit:]]/}"; then

for nr in `seq 1 1 4`; do

case $DIRB in
west)
R_X=$((PL_POS_X-nr))
R_Y=$PL_POS_Y
;;
east)
R_X=$((PL_POS_X+nr))
R_Y=$PL_POS_Y
;;
north)
R_X=$PL_POS_X
R_Y=$((PL_POS_Y-nr))
;;
south)
R_X=$PL_POS_X
R_Y=$((PL_POS_Y+nr))
;;
esac

echo request map $R_X $R_Y

echo watch request

while :; do
read -t $TMOUT REPLY
echo "request map '$R_X' '$R_Y':$REPLY" >>"$REPLY_LOG"

test "$REPLY" && IS_WALL=`echo "$REPLY" | awk '{print $16}'`
echo "IS_WALL=$IS_WALL" >>"$REPLY_LOG"
test "$IS_WALL" = 0 || f_exit_no_space 1

test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
unset REPLY
sleep 0.1s
done

echo unwatch request

done

else

echo drawinfo 3 "Received Incorrect X Y parameters from server"
exit 1

fi

else

echo drawinfo 3 "Could not get X and Y position of player."
exit 1

fi

echo drawinfo 7 "OK."
}

_check_for_space

# *** Monitoring function *** #
# *** Todo ...            *** #
f_monitor_malfunction(){

while :; do
read -t $TMOUT ERRORMSGS

sleep 0.1s
done
}





# *** Actual script to alch the desired balm of first aid *** #
test $NUMBER -ge 1 || NUMBER=1 #paranoid precaution

# *** Lets loop - hope you have the needed amount of ingredients    *** #
# *** in the inventory of the character and unlocked !              *** #
# *** Make sure similar items are not in the inventory --           *** #
# *** eg. staff of summon water elemental and such ...              *** #
# *** So do a 'drop water' and                                      *** #
# *** drop mandrake root   before beginning to alch.                *** #

# *** Then if some items are locked, unlock these and drop again.   *** #
# *** Now get the number of desired water and mandrake root --      *** #
# *** only one inventory line with water(s) and                     *** #
# *** mandrake root are allowed !!                                  *** #

# *** Now get the number of desired water of the wise and           *** #
# *** same times the number of mandrake root .                      *** #

# *** Now walk onto the cauldron and make sure there are 4 tiles    *** #
# *** west of the cauldron.                                         *** #
# *** Do not open the cauldron - this script does it.               *** #
# *** HAPPY ALCHING !!!                                             *** #


__prepare_ro_of_recall(){
# *** Readying rod of word of recall - just in case *** #

echo drawinfo 5 "Preparing for recall if monsters come forth..."

RECALL=0
OLD_REPLY="";
REPLY="";

echo request items actv

echo watch request

while :; do
#unset REPLY
read -t $TMOUT REPLY
echo "request items actv:$REPLY" >>"$REPLY_LOG"
test "`echo "$REPLY" | grep '.* rod of word of recall'`" && RECALL=1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
unset REPLY
sleep 0.1s
done

if test "$RECALL" = 1; then # unapply it now , f_emergency_exit applies again
issue 1 1 apply rod of word of recall
fi

echo unwatch request

echo drawinfo 6 "Done."

}

_prepare_rod_of_recall

__check_empty_cauldron(){
# *** Check if cauldron is empty *** #

SLEEP=3           # setting defaults
DELAY_DRAWINFO=6

issue 0 1 pickup 0  # precaution otherwise might pick up cauldron
sleep ${SLEEP}s


echo drawinfo 5 "Checking for empty cauldron..."

issue 1 1 apply
sleep ${SLEEP}s

OLD_REPLY="";
REPLY_ALL='';
REPLY="";

echo watch drawinfo

issue 1 1 get

#echo watch drawinfo

while :; do
#unset REPLY
read -t $TMOUT REPLY
echo "get:$REPLY" >>"$REPLY_LOG"
REPLY_ALL="$REPLY
$REPLY_ALL"
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
unset REPLY
sleep 0.1s
done

test "`echo "$REPLY_ALL" | grep '.*Nothing to take!'`" || {
echo drawinfo 3 "Cauldron NOT empty !!"
echo drawinfo 3 "Please empty the cauldron and try again."
f_exit 1
}

echo unwatch drawinfo

echo drawinfo 7 "OK ! Cauldron IS empty."
}

_check_empty_cauldron

issue 1 1 $DIRB
issue 1 1 $DIRB
issue 1 1 $DIRF
issue 1 1 $DIRF


# *** Getting Player's Speed *** #
__get_player_speed(){
echo drawinfo 5 "Processing Player's speed..."

ANSWER=
OLD_ANSWER=

echo request stat cmbt

echo watch request

while :; do
read -t $TMOUT ANSWER
echo "request stat cmbt:$ANSWER" >>"$REQUEST_LOG"
test "$ANSWER" || break
test "$ANSWER" = "$OLD_ANSWER" && break
OLD_ANSWER="$ANSWER"
sleep 0.1
done

echo unwatch request

#PL_SPEED=`awk '{print $7}' <<<"$ANSWER"`    # *** bash
PL_SPEED=`echo "$ANSWER" | awk '{print $7}'` # *** ash + bash
PL_SPEED="0.${PL_SPEED:0:2}"

echo drawinfo 7 "Player speed is '$PL_SPEED'"

#PL_SPEED="${PL_SPEED:2:2}"
PL_SPEED=`echo "$PL_SPEED" | sed 's!^0*!!;s!\.!!g'`
echo drawinfo 7 "Player speed is '$PL_SPEED'"

  if test "$PL_SPEED" -gt 60; then
SLEEP=0.4; DELAY_DRAWINFO=1.0; TMOUT=1
elif test "$PL_SPEED" -gt 50; then
SLEEP=0.6; DELAY_DRAWINFO=1.2; TMOUT=1
elif test "$PL_SPEED" -gt 40; then
SLEEP=0.8; DELAY_DRAWINFO=1.6; TMOUT=1
elif test "$PL_SPEED" -gt 35; then
SLEEP=1; DELAY_DRAWINFO=2; TMOUT=2
elif test "$PL_SPEED" -gt 25; then
SlEEP=2; DELAY_DRAWINFO=4; TMOUT=2
elif test "$PL_SPEED" -gt 15; then
SLEEP=3; DELAY_DRAWINFO=6; TMOUT=2
elif test "$PL_SPEED" -gt 10; then
SLEEP=4; DELAY_DRAWINFO=8; TMOUT=2
elif test "$PL_SPEED" -ge 0;  then
SLEEP=5; DELAY_DRAWINFO=10; TMOUT=2
fi

echo drawinfo 6 "Done."
}

_get_player_speed

success=0
# *** Now LOOPING *** #

for one in `seq 1 1 $NUMBER`
do

TIMEB=`date +%s`

issue 1 1 apply
sleep ${SLEEP}s

echo watch drawinfo

issue 1 1 drop 1 water of the wise

#echo watch drawinfo

OLD_REPLY="";
REPLY="";

while :; do
#unset REPLY
read -t $TMOUT REPLY
echo "Water of the Wise:$REPLY" >>"$REPLY_LOG"
test "`echo "$REPLY" | grep '.*Nothing to drop\.'`" && f_exit 1
test "`echo "$REPLY" | grep '.*There are only.*'`"  && f_exit 1
test "`echo "$REPLY" | grep '.*There is only.*'`"   && f_exit 1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
unset REPLY
sleep 0.1s
done

sleep ${SLEEP}s

issue 1 1 drop 1 mandrake root

OLD_REPLY="";
REPLY="";

while :; do
#unset REPLY
read -t $TMOUT REPLY
echo "mandrake root:$REPLY" >>"$REPLY_LOG"
test "`echo "$REPLY" | grep '.*Nothing to drop\.'`" && f_exit 1
test "`echo "$REPLY" | grep '.*There are only.*'`"  && f_exit 1
test "`echo "$REPLY" | grep '.*There is only.*'`"   && f_exit 1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
unset REPLY
sleep 0.1s
done

echo unwatch drawinfo

sleep ${SLEEP}s

issue 1 1 $DIRB
issue 1 1 $DIRB
issue 1 1 $DIRF
issue 1 1 $DIRF
sleep ${SLEEP}s

#echo watch drawinfo

issue 1 1 use_skill alchemy

echo watch drawinfo

OLD_REPLY="";
REPLY="";

while :; do
#unset REPLY
read -t $TMOUT REPLY
echo "alchemy:$REPLY" >>"$REPLY_LOG"
test "`echo "$REPLY" | grep '.*pours forth monsters\!'`" && f_emergency_exit 1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
unset REPLY
sleep 0.1s
done

#echo unwatch drawinfo

issue 1 1 apply
sleep ${SLEEP}s


#echo watch drawinfo

issue 1 1 get

#echo watch drawinfo

OLD_REPLY="";
REPLY="";
NOTHING=1
SLAG=0

while :; do
#unset REPLY
read -t $TMOUT REPLY
echo "get:$REPLY" >>"$REPLY_LOG"
test "`echo "$REPLY" | grep '.*Nothing to take\!'`"      && { NOTHING=2; break; }
test "`echo "$REPLY" | grep '.*You pick up the slag\.'`" && { NOTHING=0;SLAG=1; break; }
test "`echo "$REPLY" | grep '.*You pick up the.*'`"      && { NOTHING=0; break; }
test "$REPLY" || { NOTHING='-1'; break; }
test "$REPLY" = "$OLD_REPLY" && { NOTHING='-1'; break; }
OLD_REPLY="$REPLY"
unset REPLY
sleep 0.1s
done

echo unwatch drawinfo


sleep ${SLEEP}s

issue 1 1 $DIRB
issue 1 1 $DIRB
issue 1 1 $DIRB
issue 1 1 $DIRB
sleep ${SLEEP}s

if test "$NOTHING" = 0; then
        if test "$SLAG" = 0; then
        issue 1 1 use_skill sense curse
        issue 1 1 use_skill sense magic
        issue 1 1 use_skill alchemy
        sleep ${SLEEP}s

        issue 0 1 drop balm
        success=$((success+1))
        else
        issue 0 1 drop slag
        fi
elif test "$NOTHING" = "-1"; then
      :   # emergency drop to prevent new created items droped in cauldron

fi

sleep ${DELAY_DRAWINFO}s

issue 1 1 $DIRF
issue 1 1 $DIRF
issue 1 1 $DIRF
issue 1 1 $DIRF
sleep ${SLEEP}s


#echo watch request

echo request items on

echo watch request

UNDER_ME='';
UNDER_ME_LIST='';

while :; do
read -t $TMOUT UNDER_ME
echo "$UNDER_ME" >>"$ON_LOG"
UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"
test "$UNDER_ME" = "request items on end" && break
test "$UNDER_ME" = "scripttell break"     && break
test "$UNDER_ME" = "scripttell exit"      && exit 1
test "$UNDER_ME" || break
unset UNDER_ME
sleep 0.1s
done

test "`echo "$UNDER_ME_LIST" | grep 'cauldron$'`" || {
echo drawinfo 3 "LOOP BOTTOM: NOT ON CAULDRON!"
f_exit 1
}

echo unwatch request

TRIES_SILL=$((NUMBER-one))
TIMEE=`date +%s`
TIME=$((TIMEE-TIMEB))
echo drawinfo 4 "Elapsed $TIME s, $success of $one successfull, still $TRIES_SILL to go..."


done  # *** MAINLOOP *** #


# *** Here ends program *** #
echo draw 2 "$0 is finished."
