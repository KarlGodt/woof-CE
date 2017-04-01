#!/bin/ash

# *** Color numbers found in common/shared/newclient.h : *** #
#define NDI_BLACK       0
#define NDI_WHITE       1
#define NDI_NAVY        2
#define NDI_RED         3
#define NDI_ORANGE      4
#define NDI_BLUE        5       /**< Actually, it is Dodger Blue */
#define NDI_DK_ORANGE   6       /**< DarkOrange2 */
#define NDI_GREEN       7       /**< SeaGreen */
#define NDI_LT_GREEN    8       /**< DarkSeaGreen, which is actually paler
#                                 *   than seagreen - also background color. */
#define NDI_GREY        9
#define NDI_BROWN       10      /**< Sienna. */
#define NDI_GOLD        11
#define NDI_TAN         12      /**< Khaki. */
#define NDI_MAX_COLOR   12      /**< Last value in. */
#
#define NDI_COLOR_MASK  0xff    /**< Gives lots of room for expansion - we are
#                                 *   using an int anyways, so we have the
#                                 *   space to still do all the flags.
#                                 */
#define NDI_UNIQUE      0x100   /**< Print immediately, don't buffer. */
#define NDI_ALL         0x200   /**< Inform all players of this message. */
#define NDI_ALL_DMS     0x400   /**< Inform all logged in DMs. Used in case of
#                                 *   errors. Overrides NDI_ALL. */



LOG_REPLY_FILE=/tmp/cf_script.rpl

rm -f "$LOG_REPLY_FILE"

# *** Here begins program *** #
echo draw 2 "$0 is started.."

# *** Check for parameters *** #
[ "$*" ] && {
PARAM_1="$1"

# *** implementing 'help' option *** #
test "$PARAM_1" = "help" && {

echo draw 5 "Script to melt icecube."
echo draw 5 "Syntax:"
echo draw 5 "script $0 [number]"
echo draw 5 "For example: 'script $0 5'"
echo draw 5 "will issue 5 times mark icecube and apply filint and steel."

        exit 0
        }

# *** testing parameters for validity *** #
PARAM_1test="${PARAM_1//[[:digit:]]/}"
test "$PARAM_1test" && {
echo draw 3 "Only :digit: numbers as first option allowed."
        exit 1 #exit if other input than letters
        }

NUMBER=$PARAM_1

}
#|| {
#echo draw 3 "Script needs number of praying attempts as argument."
#        exit 1
#}

#test "$1" || {
#echo draw 3 "Need <number> ie: script $0 50 ."
#        exit 1
#}


f_exit(){
echo draw 3 "Exiting $0."
echo unwatch
#echo unwatch drawinfo
beep
exit $1
}

_mark_icecube(){

local REPLY=
local OLD_REPLY=

echo watch drawinfo
echo "issue 1 1 mark icecube"

 while :; do
 read -t 1 REPLY
 echo "$REPLY" >>/tmp/cf_script.rpl
 test "`echo "$REPLY" | grep 'Could not find an object that matches'`" && f_exit 1
 #test "`echo "$REPLY" | grep '.*There are only.*'`"  && f_exit 1
 #test "`echo "$REPLY" | grep '.*There is only.*'`"   && f_exit 1
 test "$REPLY" || break
 test "$REPLY" = "$OLD_REPLY" && break
 OLD_REPLY="$REPLY"
 sleep 0.1s
 done

echo unwatch drawinfo
}

_light_icecube(){

local REPLY=
local OLD_REPLY=

echo watch drawinfo

#NO_FAIL=
while :;
do

#local REPLY=
#local OLD_REPLY=

#echo watch drawinfo
echo "issue 1 1 apply flint and steel"

 #while :; do
 read -t 1 REPLY
 echo "$REPLY" >>/tmp/cf_script.rpl
 case $REPLY in
 *"You light "*) break;;  # NO_FAIL=1;
 *"You need to mark a lightable object."*) break;;
 *"You fail "*"used up"*) f_exit 1;;
 '') break;;
 #$OLD_REPLY) break;;
 esac
 #test  "`echo "$REPLY" | grep 'You light .*'`" && { NO_FAIL=1; break; }
 #test "`echo "$REPLY" | grep 'fail'`" || NO_FAIL=1
 #test "`echo "$REPLY" | grep '.*There are only.*'`"  && f_exit 1
 #test "`echo "$REPLY" | grep '.*There is only.*'`"   && f_exit 1
 #test "$REPLY" || break
 #test "$REPLY" = "$OLD_REPLY" && break
 #OLD_REPLY="$REPLY"
 sleep 0.1s
 #break
 #done
 unset REPLY
#echo unwatch drawinfo
sleep 1
done

echo unwatch drawinfo
}

# *** Actual script to pray multiple times *** #
test "$NUMBER" && { test $NUMBER -ge 1 || NUMBER=1; } #paranoid precaution

    if test "$NUMBER"; then

for one in `seq 1 1 $NUMBER`
do

__old_mark_icecube(){
REPLY=
OLD_REPLY=

echo watch drawinfo
echo "issue 1 1 mark icecube"

 while [ 1 ]; do
 read -t 1 REPLY
 echo "$REPLY" >>/tmp/cf_script.rpl
 test "`echo "$REPLY" | grep 'Could not find an object that matches'`" && f_exit 1
 #test "`echo "$REPLY" | grep '.*There are only.*'`"  && f_exit 1
 #test "`echo "$REPLY" | grep '.*There is only.*'`"   && f_exit 1
 test "$REPLY" || break
 test "$REPLY" = "$OLD_REPLY" && break
 OLD_REPLY="$REPLY"
 sleep 0.1s
 done

echo unwatch drawinfo
}

_mark_icecube || f_exit 2
sleep 1s

__old_light_icecube(){
NO_FAIL=
until [ "$NO_FAIL" ]
do

REPLY=
OLD_REPLY=

echo watch drawinfo
echo "issue 1 1 apply flint and steel"

 while [ 1 ]; do
 read -t 1 REPLY
 echo "$REPLY" >>/tmp/cf_script.rpl
 case $REPLY in
 *"You light "*) NO_FAIL=1; break 2;;
 *"You need to mark a lightable object."*) break 2;;
 esac
 #test  "`echo "$REPLY" | grep 'You light .*'`" && { NO_FAIL=1; break; }
 #test "`echo "$REPLY" | grep 'fail'`" || NO_FAIL=1
 #test "`echo "$REPLY" | grep '.*There are only.*'`"  && f_exit 1
 #test "`echo "$REPLY" | grep '.*There is only.*'`"   && f_exit 1
 #test "$REPLY" || break
 #test "$REPLY" = "$OLD_REPLY" && break
 #OLD_REPLY="$REPLY"
 sleep 0.1s
 break
 done

echo unwatch drawinfo
sleep 1s

done #NO_FAIL
}

_light_icecube

done #NUMBER

    else #PARAM_1


until [ "$NO_ICECUBE" ];
do

__old_mark_icecube(){
REPLY=
OLD_REPLY=

echo watch drawinfo
echo "issue 1 1 mark icecube"
while [ 1 ]; do
 read -t 1 REPLY
 echo "$REPLY" >>/tmp/cf_script.rpl
 test "`echo "$REPLY" | grep 'Could not find an object that matches'`" && f_exit 1
 #test "`echo "$REPLY" | grep '.*There are only.*'`"  && f_exit 1
 #test "`echo "$REPLY" | grep '.*There is only.*'`"   && f_exit 1
 test "$REPLY" || break
 test "$REPLY" = "$OLD_REPLY" && break
 OLD_REPLY="$REPLY"
 sleep 0.1s
 done

echo unwatch drawinfo
}

_mark_icecube

sleep 1s

__old_melt_icecube(){
NO_FAIL=
until [ "$NO_FAIL" ]
do


REPLY=
OLD_REPLY=

echo watch drawinfo
echo "issue 1 1 apply flint and steel"
 while [ 1 ]; do
 read -t 1 REPLY
 echo "$REPLY" >>/tmp/cf_script.rpl
 case $REPLY in
 *"You light "*) NO_FAIL=1; break 2;;
 *"You need to mark a lightable object."*) break 2;;
 esac
 #test  "`echo "$REPLY" | grep 'You light .*'`" && { NO_FAIL=1; break; }
 #test "`echo "$REPLY" | grep 'fail'`" || NO_FAIL=1
 #test "`echo "$REPLY" | grep '.*There are only.*'`"  && f_exit 1
 #test "`echo "$REPLY" | grep '.*There is only.*'`"   && f_exit 1
 #test "$REPLY" || break
 #test "$REPLY" = "$OLD_REPLY" && break
 #OLD_REPLY="$REPLY"
 sleep 0.1s
 break
 done

echo unwatch drawinfo
sleep 1s

done #NO_FAIL
}

_light_icecube

done #true

    fi #^!PARAM_1


# *** Here ends program *** #
echo draw 2 "$0 is finished."
beep
