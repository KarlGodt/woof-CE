#!/bin/ash

exec 2>/tmp/cf_script.$$.err


# *** PARAMETERS *** #

DIRB=west  # direction back to go

case $DIRB in
west)  DIRF=east;;
east)  DIRF=west;;
north) DIRF=south;;
south) DIRF=north;;
esac

PRINT=draw         # print command to msg pane - was using drawextinfo which worked too
DRAW_INFO=drawinfo # drawextinfo


# *** Here begins program *** #
echo $PRINT 2 "$0 is started.."


# *** Check for parameters *** #
echo $PRINT 5 "Checking the parameters ($*)..."

[ "$*" ] && {
PARAM_1="$1"

# *** implementing 'help' option *** #
test "$PARAM_1" = "help" && {

echo $PRINT 5 "Script to produce water of the wise."
echo $PRINT 7 "Syntax:"
echo $PRINT 7 "$0 NUMBER"
echo $PRINT 5 "Allowed NUMBER will loop for"
echo $PRINT 5 "NUMBER times to produce NUMBER of"
echo $PRINT 5 "Balm of First Aid ."

        exit 0
        }

PARAM_1test="${PARAM_1//[[:digit:]]/}"
test "$PARAM_1test" && {
echo $PRINT 3 "Only :digit: numbers as option allowed."
        exit 1 #exit if other input than numbers
        }

NUMBER=$PARAM_1

} || {
echo $PRINT 3 "Script needs number of alchemy attempts as argument."
        exit 1
}

test "$1" || {
echo $PRINT 3 "Need <number> ie: script $0 4 ."
        exit 1
}

echo $PRINT 7 "OK."

_scripttell_check(){
local STRING="$*"
STRING=${STRING:-"$REPLY"}
case $STRING in
"scripttell break") return 1;;
"scripttell exit")  beep; exit 1;;
esac
return 0
}

# *** EXIT FUNCTIONS *** #
f_exit(){
RV=${1:-0}
shift
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
sleep ${SLEEP}s
echo $PRINT 3 "Exiting $0."
echo $PRINT 4 "$*"
#echo unmonitor
#echo unwatch monitor
#echo unwatch monitor issue
echo unwatch
echo unwatch drawinfo
beep
exit $RV
}

f_emergency_exit(){
echo "issue 1 1 apply rod of word of recall"
echo "issue 1 1 fire center"
echo $PRINT 3 "Emergency Exit $0 !"
echo unwatch drawinfo
echo "issue 1 1 fire_stop"
beep
exit $1
}

f_exit_no_space(){
echo $PRINT 3 "On position $nr $DIRB there is Something ($IS_WALL)!"
echo $PRINT 3 "Remove that Item and try again."
echo $PRINT 3 "If this is a Wall, try another place."
beep
exit $1
}

# *** Check if standing on a cauldron *** #

echo $PRINT 5 "Checking if on a cauldron..."

UNDER_ME='';
echo request items on

while :; do
read -t 1 UNDER_ME
#echo "$UNDER_ME" >>/tmp/cf_script.ion
UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"
case "$UNDER_ME" in
"request items on end") break;;
#"scripttell break")     break;;
#"scripttell exit")     exit 1;;
esac
_scripttell_check "$UNDER_ME"
sleep 0.1s
done

test "`echo "$UNDER_ME_LIST" | grep 'cauldron$'`" || {
echo $PRINT 3 "Need to stand upon cauldron!"
beep
exit 1
}

echo $PRINT 7 "OK."


_drop_item(){  #AMOUNT "STRING"
test "$*" || return 4 # TODO error message for wrong usages
test "$1" || return 5
test "$2" || return 6

AMOUNT=$1
shift
ITEM="$*"

echo "issue 1 1 drop $AMOUNT $ITEM"

echo watch drawinfo

OLD_REPLY="";
REPLY="";

while :; do
read -t 1 REPLY
echo "$REPLY" >>/tmp/cf_script.rpl
case "$REPLY" in
*"Nothing to drop.") f_exit 1;;
*"There are only"*)  f_exit 1;;
*"There is only"*)   f_exit 1;;
'') break;;
"$OLD_REPLY") break;;
esac
_scripttell_check || break
OLD_REPLY="$REPLY"
sleep 0.1s
done

echo unwatch drawinfo
}

rm -f /tmp/cf_script.rpl   # empty old log file

# *** Check for 4 empty space to DIRB ***#

echo $PRINT 5 "Checking for space to move..."

echo request map pos

echo watch request

while [ 1 ]; do
read -t 1 REPLY
echo "$REPLY" >>/tmp/cf_script.rpl
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
_scripttell_check
OLD_REPLY="$REPLY"
sleep 0.1s
done

echo unwatch request


PL_POS_X=`echo "$REPLY" | awk '{print $4}'`
PL_POS_Y=`echo "$REPLY" | awk '{print $5}'`

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

while [ 1 ]; do
read -t 1 REPLY
echo "$REPLY" >>/tmp/cf_script.rpl

IS_WALL=`echo "$REPLY" | awk '{print $16}'`
echo "$IS_WALL" >>/tmp/cf_script.rpl
test "$IS_WALL" = 0 || f_exit_no_space 1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
_scripttell_check
OLD_REPLY="$REPLY"
sleep 0.1s
done

echo unwatch request

done

else

echo $PRINT 3 "Received Incorrect X Y parameters from server"
beep
exit 1

fi

else

echo $PRINT 3 "Could not get X and Y position of player."
beep
exit 1

fi

echo $PRINT 7 "OK."


# *** Monitoring function *** #
# *** Todo ...            *** #
f_monitor_malfunction(){

while [ 1 ]; do
read -t 1 ERRORMSGS

sleep 0.1s
done
}


# *** Getting Player's Speed *** #

echo $PRINT 5 "Processing Player's speed..."

SLEEP=3           # setting defaults
DELAY_DRAWINFO=6

ANSWER=
OLD_ANSWER=

echo request stat cmbt

echo watch request

while [ 1 ]; do
read -t 1 ANSWER
echo "$ANSWER" >>/tmp/cf_request.log
test "$ANSWER" || break
test "$ANSWER" = "$OLD_ANSWER" && break
_scripttell_check
OLD_ANSWER="$ANSWER"
sleep 0.1
done

echo unwatch request

#PL_SPEED=`awk '{print $7}' <<<"$ANSWER"`    # *** bash
PL_SPEED=`echo "$ANSWER" | awk '{print $7}'` # *** ash + bash
#PL_SPEED="0.${PL_SPEED:0:2}"
PL_SPEED=`echo "scale=2; $PL_SPEED / 100000" | bc -l`

echo $PRINT 7 "Player speed is $PL_SPEED"

#PL_SPEED="${PL_SPEED:2:2}"
PL_SPEED=`echo "$PL_SPEED" | sed 's/\.//g;s/^0*//'`
test "${PL_SPEED//[0-9]/}" && PL_SPEED=50
PL_SPEED=${PL_SPEED:-50}

echo $PRINT 7 "Player speed is $PL_SPEED"



if test $PL_SPEED -gt 35; then
SLEEP=1.0; DELAY_DRAWINFO=2.0
elif test $PL_SPEED -gt 25; then
SLEEP=2.0; DELAY_DRAWINFO=4.0
fi

echo $PRINT 6 "Done."

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


# *** Readying rod of word of recall - just in case *** #

echo $PRINT 5 "Preparing for recall if monsters come forth..."

RECALL=0
OLD_REPLY="";
REPLY="";

echo request items actv

echo watch request

while [ 1 ]; do
read -t 1 REPLY
echo "$REPLY" >>/tmp/cf_script.rpl
test "`echo "$REPLY" | grep '.* rod of word of recall'`" && RECALL=1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
_scripttell_check
OLD_REPLY="$REPLY"
sleep 0.1s
done

if test "$RECALL" = 1; then # unapply it now , f_emergency_exit applies again
echo "issue 1 1 apply rod of word of recall"
fi

echo unwatch request

echo $PRINT 6 "Done."


# *** Check if cauldron is empty *** #

echo "issue 0 1 pickup 0"  # precaution otherwise might pick up cauldron
sleep ${SLEEP}s


echo $PRINT 5 "Checking for empty cauldron..."

echo "issue 1 1 apply"
sleep ${SLEEP}s

OLD_REPLY="";
REPLY_ALL='';
REPLY="";

echo "issue 1 1 get"

echo watch drawinfo

while [ 1 ]; do
read -t 1 REPLY
echo "$REPLY" >>/tmp/cf_script.rpl
REPLY_ALL="$REPLY
$REPLY_ALL"
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
_scripttell_check
OLD_REPLY="$REPLY"
sleep 0.1s
done

test "`echo "$REPLY_ALL" | grep '.*Nothing to take!'`" || {
echo $PRINT 3 "Cauldron seems NOT empty !!"
echo $PRINT 3 "Please empty the cauldron and try again."
beep
f_exit 1
}

echo unwatch drawinfo

echo $PRINT 7 "OK ! Seems cauldron IS empty."

echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"


# *** Now LOOPING *** #

for one in `seq 1 1 $NUMBER`
do

echo "issue 1 1 apply"
sleep ${SLEEP}s


__old_drop_item_wotw(){
#echo watch drawinfo

echo "issue 1 1 drop 1 water of the wise"

echo watch drawinfo

OLD_REPLY="";
REPLY="";

while :; do
read -t 1 REPLY
echo "$REPLY" >>/tmp/cf_script.rpl
case "$REPLY" in
*"Nothing to drop.") f_exit 1;;
*"There are only"*)  f_exit 1;;
*"There is only"*)   f_exit 1;;
'') break;;
"$OLD_REPLY") break;;
esac
OLD_REPLY="$REPLY"
sleep 0.1s
done
}

_drop_item 1 "water of the wise"

sleep ${SLEEP}s

__old_drop_item_mroot(){
echo "issue 1 1 drop 1 mandrake root"

OLD_REPLY="";
REPLY="";

while [ 1 ]; do
read -t 1 REPLY
echo "$REPLY" >>/tmp/cf_script.rpl
case "$REPLY" in
*"Nothing to drop".) f_exit 1;;
*"There are only"*)  f_exit 1;;
*"There is only"*)   f_exit 1;;
'') break;;
"$OLD_REPLY") break;;
esac
OLD_REPLY="$REPLY"
sleep 0.1s
done

echo unwatch drawinfo
}

_drop_item 1 "mandrake root"

sleep ${SLEEP}s

echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
sleep ${SLEEP}s

#echo watch drawinfo

echo "issue 1 1 use_skill alchemy"

echo watch drawinfo

OLD_REPLY="";
REPLY="";

while :; do
read -t 1 REPLY
echo "$REPLY" >>/tmp/cf_script.rpl
case "$REPLY" in
*"pours forth monsters!") f_emergency_exit 1;;
'') break;;
"$OLD_REPLY") break;;
esac
_scripttell_check
OLD_REPLY="$REPLY"
sleep 0.1s
done

echo unwatch drawinfo

echo "issue 1 1 apply"
sleep ${SLEEP}s

#echo watch drawinfo

echo "issue 1 1 get"

echo watch drawinfo

OLD_REPLY="";
REPLY="";
NOTHING=0
SLAG=0

while :; do
read -t 1 REPLY
echo "$REPLY" >>/tmp/cf_script.rpl
case "$REPLY" in
*"Nothing to take!") NOTHING=1; break;;
*'You pick up the slag.') SLAG=1; break;;
'') break;;
"$OLD_REPLY") break;;
esac
_scripttell_check
OLD_REPLY="$REPLY"
sleep 0.1s
done

echo unwatch drawinfo


sleep ${SLEEP}s

echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
sleep ${SLEEP}s

if test $NOTHING = 0; then
        if test $SLAG = 0; then
        echo "issue 1 1 use_skill sense curse"
        echo "issue 1 1 use_skill sense magic"
        echo "issue 1 1 use_skill alchemy"
        sleep ${SLEEP}s

        echo "issue 0 1 drop balm"
        else
        echo "issue 0 1 drop slag"
        fi
fi

sleep ${DELAY_DRAWINFO}s

echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
sleep ${SLEEP}s

sleep 5
#echo watch request

echo request items on

echo watch request

UNDER_ME='';
UNDER_ME_LIST='';

while :; do
read -t 1 UNDER_ME
echo "$UNDER_ME" >>/tmp/cf_script.ion
UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"
case "$UNDER_ME" in
"request items on end") break;;
#"scripttell break") break;;
#"scripttell exit") exit 1;;
#'') break;;
esac
_scripttell_check
sleep 0.1s
done

test "`echo "$UNDER_ME_LIST" | grep 'cauldron$'`" || {
echo $PRINT 3 "LOOP BOTTOM: SEEMS NOT ON CAULDRON!"
beep
f_exit 1
}

echo unwatch request

TRIES_SILL=$((NUMBER-one))
echo $PRINT 4 "Still $TRIES_SILL to go..."


done  # *** MAINLOOP *** #


# *** Here ends program *** #
echo $PRINT 2 "$0 is finished."
beep -l 400 -f 712
