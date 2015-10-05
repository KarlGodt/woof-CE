#!/bin/ash

export PATH=/bin:/usr/bin

# *** Here begins program *** #
echo draw 2 "$0 is started.."
echo draw 2 "PID is $$ - parentPID is $PPID"

# *** PARAMETERS *** #

__set_global_variables(){
TMOUT=1    # read -t timeout

DIRB=east  # direction back to go

case $DIRB in
west)  DIRF=east;;
east)  DIRF=west;;
north) DIRF=south;;
south) DIRF=north;;
esac

# Log file path in /tmp
#MY_SELF=`realpath "$0"`
#MY_BASE=${MY_SELF##*/}
TMP_DIR=/tmp/crossfire
mkdir -p "$TMP_DIR"
REPLY_LOG="$TMP_DIR"/"$MY_BASE".$$.rpl
REQUEST_LOG="$TMP_DIR"/"$MY_BASE".$$.req
ON_LOG="$TMP_DIR"/"$MY_BASE".$$.ion

exec 2>>"$TMP_DIR"/"$MY_BASE".$$.err
}

MY_SELF=`realpath "$0"`
MY_BASE=${MY_SELF##*/}
test -f "${MY_SELF%/*}"/"${MY_BASE}".conf && . "${MY_SELF%/*}"/"${MY_BASE}".conf
test -f "${MY_SELF%/*}"/cf_functions.sh   && . "${MY_SELF%/*}"/cf_functions.sh

_set_global_variables

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


#test -f "${MY_SELF%/*}"/cf_functions.sh && . "${MY_SELF%/*}"/cf_functions.sh

rm -f "$REPLY_LOG"    # empty old log files
rm -f "$REQUEST_LOG"
rm -f "$ON_LOG"


# *** Check if standing on a cauldron *** #
_check_if_on_cauldron

_check_for_space

# *** Monitoring function *** #
# *** Todo ...            *** #
_monitor_malfunction(){

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


_prepare_rod_of_recall

_check_empty_cauldron

_is 1 1 $DIRB
_is 1 1 $DIRB
_is 1 1 $DIRF
_is 1 1 $DIRF


# *** Getting Player's Speed *** #
_get_player_speed

success=0
# *** Now LOOPING *** #

for one in `seq 1 1 $NUMBER`
do

TIMEB=`date +%s`

_is 1 1 apply
sleep ${SLEEP}s

echo watch drawinfo

_is 1 1 drop 1 water of the wise

#echo watch drawinfo

OLD_REPLY="";
REPLY="";

while :; do
#unset REPLY
read -t $TMOUT REPLY
echo "Water of the Wise:$REPLY" >>"$REPLY_LOG"
test "`echo "$REPLY" | grep '.*Nothing to drop\.'`" && _exit 1
test "`echo "$REPLY" | grep '.*There are only.*'`"  && _exit 1
test "`echo "$REPLY" | grep '.*There is only.*'`"   && _exit 1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
unset REPLY
sleep 0.1s
done

sleep ${SLEEP}s

_is 1 1 drop 1 mandrake root

OLD_REPLY="";
REPLY="";

while :; do
#unset REPLY
read -t $TMOUT REPLY
echo "mandrake root:$REPLY" >>"$REPLY_LOG"
test "`echo "$REPLY" | grep '.*Nothing to drop\.'`" && _exit 1
test "`echo "$REPLY" | grep '.*There are only.*'`"  && _exit 1
test "`echo "$REPLY" | grep '.*There is only.*'`"   && _exit 1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
unset REPLY
sleep 0.1s
done

echo unwatch drawinfo

sleep ${SLEEP}s

_is 1 1 $DIRB
_is 1 1 $DIRB
_is 1 1 $DIRF
_is 1 1 $DIRF
sleep ${SLEEP}s

#echo watch drawinfo

_is 1 1 use_skill alchemy

echo watch drawinfo

OLD_REPLY="";
REPLY="";

while :; do
#unset REPLY
read -t $TMOUT REPLY
echo "alchemy:$REPLY" >>"$REPLY_LOG"
test "`echo "$REPLY" | grep '.*pours forth monsters\!'`" && _emergency_exit 1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
unset REPLY
sleep 0.1s
done

#echo unwatch drawinfo

_is 1 1 apply
sleep ${SLEEP}s


#echo watch drawinfo

_is 1 1 get

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

_is 1 1 $DIRB
_is 1 1 $DIRB
_is 1 1 $DIRB
_is 1 1 $DIRB
sleep ${SLEEP}s

if test "$NOTHING" = 0; then
        if test "$SLAG" = 0; then
        _is 1 1 use_skill sense curse
        _is 1 1 use_skill sense magic
        _is 1 1 use_skill alchemy
        sleep ${SLEEP}s

        _is 0 1 drop balm
        success=$((success+1))
        else
        _is 0 1 drop slag
        fi
elif test "$NOTHING" = "-1"; then
      :   # emergency drop to prevent new created items droped in cauldron

fi

sleep ${DELAY_DRAWINFO}s

_is 1 1 $DIRF
_is 1 1 $DIRF
_is 1 1 $DIRF
_is 1 1 $DIRF
sleep ${SLEEP}s

__check_if_on_cauldron_two(){
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
_exit 1
 }

echo unwatch request
}

_check_if_on_cauldron

TRIES_SILL=$((NUMBER-one))
TIMEE=`date +%s`
TIME=$((TIMEE-TIMEB))
echo drawinfo 4 "Elapsed $TIME s, $success of $one successfull, still $TRIES_SILL to go..."


done  # *** MAINLOOP *** #


# *** Here ends program *** #
test -f /root/.crossfire/sounds/su-fanf.raw && aplay /root/.crossfire/sounds/su-fanf.raw
echo draw 2 "$0 is finished."
