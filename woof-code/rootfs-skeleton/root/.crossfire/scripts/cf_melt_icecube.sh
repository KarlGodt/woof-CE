#!/bin/bash

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

export PATH=/bin:/usr/bin

# *** Here begins program *** #
echo draw 2 "$0 is started with pid $$ $PPID"

# *** Check for parameters *** #
[ "$*" ] && {
PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in *"help"*)

echo draw 5 "Script to melt icecube."
echo draw 5 "Syntax:"
echo draw 5 "script $0 [number]"
echo draw 5 "For example: 'script $0 5'"
echo draw 5 "will issue 5 times mark icecube and apply filint and steel."

        exit 0
;; esac

# *** testing parameters for validity *** #
PARAM_1test="${PARAM_1//[[:digit:]]/}"
test "$PARAM_1test" && {
echo draw 3 "Only :digit: numbers as first option allowed."
        exit 1 #exit if other input than letters
        }

NUMBER=$PARAM_1

}


f_exit(){
echo draw 3 "Exiting $0."
echo unwatch
#echo unwatch drawinfo
exit $1
}

rm -f /tmp/cf_script.rpl
#echo >>/tmp/cf_script.rpl

# *** Actual script to pray multiple times *** #
test "$NUMBER" && { test $NUMBER -ge 1 || NUMBER=1; } #paranoid precaution
echo draw 3 DEBUG:NUMBER=$NUMBER

echo watch drawinfo     # newer clients just use drawinfo
echo watch drawextinfo  #older clients up to v.1.12.0 use a mix of drawextinfo and drawinfo

  if test "$NUMBER"; then

for one in `seq 1 1 $NUMBER`
do

REPLY=
OLD_REPLY=

#echo watch drawinfo
#echo watch drawextinfo
#sleep 0.5
echo "issue 1 1 mark icecube"

 while :; do
 read -t 1 REPLY
 echo "mark:$REPLY" >>/tmp/cf_script.rpl
 test "`echo "$REPLY" | grep 'Could not find an object that matches'`" && f_exit 1
 test "`echo "$REPLY" | grep 'Could not find' | grep 'icecube'`" && f_exit 1
 #test "`echo "$REPLY" | grep '.*There are only.*'`"  && f_exit 1
 #test "`echo "$REPLY" | grep '.*There is only.*'`"   && f_exit 1
 test "$REPLY" || break
 #test "$REPLY" = "$OLD_REPLY" && break
 #OLD_REPLY="$REPLY"
 unset REPLY
 sleep 0.1s
 done

#echo unwatch drawextinfo
#echo unwatch drawinfo
#sleep 1s

  #NO_FAIL=
  until false
  do

  REPLY=
  OLD_REPLY=

  #echo watch drawinfo
  #echo watch drawextinfo
  #sleep 0.5
  echo "issue 1 1 apply flint and steel"

  while [ 1 ]; do
  read -t 3 REPLY
  echo "flint:$REPLY" >>/tmp/cf_script.rpl
  test "$REPLY" || break
  test "`echo "$REPLY" | grep 'fail'`" || break 2 #|| NO_FAIL=1
  test "`echo "$REPLY" | grep 'fail' | grep 'used up'`" && break 3
  #test "`echo "$REPLY" | grep '.*There are only.*'`"  && f_exit 1
  #test "`echo "$REPLY" | grep '.*There is only.*'`"   && f_exit 1
  #test "$REPLY" || break
  #test "$REPLY" = "$OLD_REPLY" && break
  #OLD_REPLY="$REPLY"
  unset REPLY
  sleep 0.1s
  done

  #echo unwatch drawextinfo
  #echo unwatch drawinfo
  #sleep 1s

  done #NO_FAIL

done #NUMBER

    else #PARAM_1


NO_ICECUBE=
false
until false; #[ "$NO_ICECUBE" ];
do

 REPLY=
 OLD_REPLY=

 #echo watch drawinfo
 #echo watch drawextinfo
 #sleep 1.5
 echo "issue 1 1 mark icecube"
 #sleep 1
 while [ 1 ]; do
 read -t 3 REPLY
 echo "mark:$REPLY" >>/tmp/cf_script.rpl
 case $REPLY in
 *Could*not*find*an*object*that*matches*) break 2;;
 '') break 1;;
 esac
 #test "`echo "$REPLY" | grep 'Could not find an object that matches'`" && break 2 #NO_ICECUBE=Y
 #test "`echo "$REPLY" | grep 'Could not find an object that matches'`" && f_exit 1
 #test "`echo "$REPLY" | grep '.*There are only.*'`"  && f_exit 1
 #test "`echo "$REPLY" | grep '.*There is only.*'`"   && f_exit 1
 #test "$REPLY" || break
 #test "$REPLY" = "$OLD_REPLY" && break
 #OLD_REPLY="$REPLY"
 unset REPLY
 sleep 0.1s
 done

 #echo unwatch drawextinfo
 #echo unwatch drawinfo
 sleep 1s

  NO_FAIL=
  #until [ "$NO_FAIL" ]
  until false
  do

  REPLY=
  OLD_REPLY=

  #echo watch drawinfo
  #echo watch drawextinfo
  #sleep 1.5
  echo "issue 1 1 apply flint and steel"
  #sleep 1
  while :; do
  read -t 3 REPLY
  echo "flint:$REPLY" >>/tmp/cf_script.rpl
  #test "$REPLY" || break

  case $REPLY in
  *You*light*the*icecube*with*the*flint*and*steel.*) break 2;;
  *used*up*fail*)         break 3;;
  *need*lightable*object*) break 3;;
  '') break 1;;
  esac

  #test "`echo "$REPLY" | grep 'fail'`" || break 2 #|| NO_FAIL=1
  #test "`echo "$REPLY" | grep 'fail' | grep 'used up'`" && break 3
  #test "`echo "$REPLY" | grep 'need' | grep 'lightable object'`" && break 3
  #test "`echo "$REPLY" | grep '.*There are only.*'`"  && f_exit 1
  #test "`echo "$REPLY" | grep '.*There is only.*'`"   && f_exit 1
  #test "$REPLY" || break
  #test "$REPLY" = "$OLD_REPLY" && break
  #OLD_REPLY="$REPLY"

  unset REPLY
  sleep 0.1s
  done
  RV=$?
  echo draw 3 "DEBUG:flint:returnvalue=$RV"

  #echo unwatch drawextinfo
  #echo unwatch drawinfo
  #sleep 1s

  done #NO_FAIL
  RV=$?
  echo draw 3 "DEBUG:until light:returnvalue=$RV"
done #true
RV=$?
echo draw 3 "DEBUG:false:returnvalue=$RV"

    fi #^!PARAM_1


# *** Here ends program *** #
echo draw 2 "$0 is finished."
