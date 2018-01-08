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

_set_global_variables(){
LOGGING=${LOGGING:-''}  #bool, set to ANYTHING ie "1" to enable, empty to disable
#DEBUG=${DEBUG:-''}      #bool, set to ANYTHING ie "1" to enable, empty to disable
MSGLEVEL=${MSGLEVEL:-7} #integer 1 emergency - 7 debug
#case $MSGLEVEL in
#7) DEBUG=${DEBUG:-1};; 6) INFO=${INFO:-1};; 5) NOTICE=${NOTICE:-1};; 4) WARN=${WARN:-1};;
#3) ERROR=${ERROR:-1};; 2) ALERT=${ALERT:-1};; 1) EMERG=${EMERG:-1};;
#esac
DEBUG=1; INFO=1; NOTICE=1; WARN=1; ERROR=1; ALERT=1; EMERG=1
case $MSGLEVEL in
7) :;; 6) unset DEBUG;; 5) unset DEBUG INFO;; 4) unset DEBUG INFO NOTICE;;
3) unset DEBUG INFO NOTICE WARN;; 2) unset DEBUG INFO NOTICE WARN ERROR;;
1) unset DEBUG INFO NOTICE WARN ERROR ALERT;;
*) _error "MSGLEVEL variable not set from 1 - 7";;
esac

TMOUT=${TMOUT:-1}      # read -t timeout, integer, seconds
SLEEP=${SLEEP:-1}      #default sleep value, float, seconds, refined in _get_player_speed()

DELAY_DRAWINFO=${DELAY_DRAWINFO:-2}  #default pause to sync, float, seconds, refined in _get_player_speed()
DRAWINFO=${DRAWINFO:-drawinfo} #older clients <= 1.12.0 use drawextinfo , newer clients drawinfo
FUNCTION_CHECK_FOR_SPACE=_check_for_space # request map pos works
case $* in
*-version" "*) CLIENT_VERSION="$2"
case $CLIENT_VERSION in 0.*|1.[0-9].*|1.1[0-2].*)
DRAWINFO=drawextinfo #older clients <= 1.12.0 use drawextinfo , newer clients drawinfo
                     #     except use_skill alchemy :watch drawinfo 0 The cauldron emits sparks.
                     # and except apply             :watch drawinfo 0 You open cauldron.
                     #
                     # and probably more ...? TODO!
FUNCTION_CHECK_FOR_SPACE=_check_for_space_old_client # needs request map near
;;
esac
;;
esac

COUNT_CHECK_FOOD=${COUNT_CHECK_FOOD:-10} # number between attempts to check foodlevel.
                    #  1 would mean check every single time, which is too much
EAT_FOOD=${EAT_FOOD:-waybread}   # set to desired food to eat ie food, mushroom, booze, .. etc.
FOOD_DEF=$EAT_FOOD     # default
MIN_FOOD_LEVEL_DEF=${MIN_FOOD_LEVEL_DEF:-200} # default minimum. 200 starts to beep.
                       # waybread has foodvalue of 500
                       # 999 is max foodlevel

HP_MIN_DEF=${HP_MIN_DEF:-20}          # minimum HP to return home. Lowlevel charakters probably need this set.

DIRB=${DIRB:-west}  # direction back to go
case $DIRB in
west)  DIRF=east;;
east)  DIRF=west;;
north) DIRF=south;;
south) DIRF=north;;
esac

SOUND_DIR="$HOME"/.crossfire/sounds

# Log file path in /tmp
#MY_SELF=`realpath "$0"` ## needs to be in main script
#MY_BASE=${MY_SELF##*/}  ## needs to be in main script
TMP_DIR=/tmp/crossfire
mkdir -p "$TMP_DIR"
LOGFILE=${LOGFILE:-"$TMP_DIR"/"$MY_BASE".$$.log}
REPLY_LOG="$TMP_DIR"/"$MY_BASE".$$.rpl
REQUEST_LOG="$TMP_DIR"/"$MY_BASE".$$.req
ON_LOG="$TMP_DIR"/"$MY_BASE".$$.ion
ERROR_LOG="$TMP_DIR"/"$MY_BASE".$$.err
exec 2>>"$ERROR_LOG"
}

_is(){
    echo issue "$@"
    sleep 0.2
}

_draw(){
    local COLOUR="$1"
    test "$COLOUR" || COLOUR=1 #set default
    shift
    local MSG="$@"
    echo draw $COLOUR "$MSG"
}

_msg(){
local LVL=$1; shift
case $LVL in
7|debug) test "$DEBUG"  && _debug  "$*";;
6|info)  test "$INFO"   && _info   "$*";;
5|note)  test "$NOTICE" && _notice "$*";;
4|warn)  test "$WARN"   && _warn   "$*";;
3|err)   test "$ERROR"  && _error  "$*";;
2|alert) test "$ALERT"  && _alert  "$*";;
1|emerg) test "$EMERG"  && _emerg  "$*";;
*) _debug "$*";;
esac
}

_debug(){
#test "$DEBUG" || return 0
    echo draw 10 "DEBUG:$@"
}

__debug(){  ##+++2018-01-06
test "$DEBUG" || return 0
cnt=0
echo "$*" | while read line
do
cnt=$((cnt+1))
    echo draw 3 "__DEBUG:$cnt:$line"
done
unset cnt line
}

_info(){
#test "$INFO" || return 0
    echo draw 7 "INFO:$@"
}

_notice(){
#test "$NOTICE" || return 0
    echo draw 2 "NOTICE:$@"
}

_warn(){
#test "$WARN" || return 0
    echo draw 6 "WARNING:$@"
}

_error(){
#test "$ERROR" || return 0
    echo draw 4 "ERROR:$@"
}

_alert(){
#test "$ALERT" || return 0
    echo draw 3 "ALERT:$@"
}

_ermerg(){
#test "$EMERG" || return 0
    echo draw 3 "EMERGENCY:$@"
}

_log(){
    test "$LOGGING" || return 0
    local lFILE
    test "$2" && {
    lFILE="$1"; shift; } || lFILE="$LOGFILE"
   echo "$*" >>"$lFILE"
}

_sound(){
    local DUR
test "$2" && { DUR="$1"; shift; }
test "$DUR" || DUR=0
test -e "$SOUND_DIR"/${1}.raw && \
           aplay $Q $VERB -d $DUR "$SOUND_DIR"/${1}.raw
}

_say_start_msg(){
# *** Here begins program *** #
_draw 2 "$0 has started.."
_draw 2 "PID is $$ - parentPID is $PPID"

# *** Check for parameters *** #
_draw 5 "Checking the parameters ($*)..."
}

_tell_script_time(){
test "$TIMEA" || return 1

 TIMEE=`date +%s`
 TIME=$((TIMEE-TIMEA))
 TIMEM=$((TIME/60))
 TIMES=$(( TIME - (TIMEM*60) ))
 _draw 4 "Loop of script had run a total of $TIMEM minutes and $TIMES seconds."
}

_say_script_time(){
TIME_ELAPSED=`ps -o pid,etime,args | grep -w "$$" | grep -vwE 'grep|ps'`
__debug "$TIME_ELAPSED"
TIME_ELAPSED=`echo "$TIME_ELAPSED" | awk '{print $2}'`
__debug "$TIME_ELAPSED"
case $TIME_ELAPSED in
*:*:*) _draw 5 "Script had run a time of $TIME_ELAPSED h:m:s .";;
*:*)   _draw 5 "Script had run a time of $TIME_ELAPSED m:s .";;
*)     _draw 5 "Script had run a time of $TIME_ELAPSED s .";;
esac
}

_say_end_msg(){
# *** Here ends program *** #
_is 1 1 fire_stop
test -f "$HOME"/.crossfire/sounds/su-fanf.raw && aplay $Q "$HOME"/.crossfire/sounds/su-fanf.raw & aPID=$!

#if test "$TIMEA"; then
# TIMEE=`date +%s`
# TIME=$((TIMEE-TIMEA))
# TIMEM=$((TIME/60))
# TIMES=$(( TIME - (TIMEM*60) ))
# _draw 4 "Loop of script had run a total of $TIMEM minutes and $TIMES seconds."
#fi

_tell_script_time || _say_script_time

test "$DEBUG" || { test -s "$ERROR_LOG" || rm -f "$ERROR_LOG"; }
test "$DEBUG" -o "$INFO" || rm -f "$TMP_DIR"/*.$$*

test "$aPID" && wait $aPID
_draw 2  "$0 has finished."
}

_loop_counter(){
test "$TIMEA" -a "$TIMEB" -a "$NUMBER" -a "$one" || return 0
TRIES_STILL=$((NUMBER-one))
TIMEE=`date +%s`
TIME=$((TIMEE-TIMEB))
TIMEZ=$((TIMEE-TIMEA))
TIMEAV=$((TIMEZ/one))
TIMEEST=$(( (TRIES_STILL*TIMEAV) / 60 ))
_draw 4 "Elapsed $TIME s, $success of $one successfull, still $TRIES_STILL ($TIMEEST m) to go..."
}

# *** EXIT FUNCTIONS *** #
_exit(){
case $1 in
[0-9]|[0-9][0-9]|[0-9][0-9][0-9]) RV=$1; shift;;
esac
#_is 1 1 $DIRB
#_is 1 1 $DIRB
#_is 1 1 $DIRF
#_is 1 1 $DIRF
_move_back_and_forth 2
sleep ${SLEEP}s
_draw 3 "Exiting $0. $@"
echo unwatch
echo unwatch $DRAWINFO
beep -l 1000 -f 700
test ${RV//[0-9]/} && RV=3
exit ${RV:-0}
}

_just_exit(){
echo draw 3 "Exiting $0."
echo unwatch
#echo unwatch $DRAWINFO
exit ${1:-0}
}

_emergency_exit(){
_is 1 1 apply -u rod of word of recall
_is 1 1 apply -a rod of word of recall
_is 1 1 fire center
_draw 3 "Emergency Exit $0 !"
echo unwatch $DRAWINFO
_is 1 1 fire_stop
beep -l 1000 -f 700
exit ${1:-0}
}

_exit_no_space(){
_draw 3 "On position $nr $DIRB there is Something ($IS_WALL)!"
_draw 3 "Remove that Item and try again."
_draw 3 "If this is a Wall, try another place."
beep -l 1000 -f 700
exit ${1:-0}
}

_move_back(){
for i in `seq 1 1 ${1:-1}`
do
_is 1 1 $DIRB
_sleep
done
}

_move_forth(){
for i in `seq 1 1 ${1:-1}`
do
_is 1 1 $DIRF
_sleep
done
}

_move_back_and_forth(){
STEPS=${1:-1}
for i in `seq 1 1 $STEPS`
do
_is 1 1 $DIRB
_sleep
done

if test "$2"; then shift
 while test "$1";
 do
 #oIFS=$IFS
 #IFS=';'
 COMMANDS=`echo "$1" | tr ';' '\n'`
 test "$COMMANDS" || break 1
  echo "$COMMANDS" | while read line
  do
  $line
  sleep 0.1
  done

 #IFS=$oIFS
 shift
 sleep 0.1
 done
fi

for i in `seq 1 1 $STEPS`
do
_is 1 1 $DIRF
_sleep
done
}

_round_up_and_down(){
echo "_round_up_and_down:$1" >&2
               #123
STELLEN=${#1}  #3
echo "STELLE=$STELLEN" >&2

LETZTSTELLE=${1:$((STELLEN-1))} #123:2
echo "LETZTSTELLE=$LETZTSTELLE" >&2

VORLETZTSTELLE=${1:$((STELLEN-2)):1} #123:1:1
echo "VORLETZTSTELLE=$VORLETZTSTELLE" >&2

GERUNDET_BASIS=${1:0:$((STELLEN-1))} #123:0:2
echo "GERUNDET_BASIS=$GERUNDET_BASIS" >&2

case $LETZTSTELLE in
0)     GERUNDET="${GERUNDET_BASIS}0";;
[5-9]) GERUNDET="$((GERUNDET_BASIS+1))0";;
[1-4]) GERUNDET="${GERUNDET_BASIS}0";;
*) :;;
esac

echo $GERUNDET
}

_set_sync_sleep(){
PL_SPEED1=${1:-$PL_SPEED1}
PL_SPEED1=${PL_SPEED1:-50}

  if test "$PL_SPEED1" -gt 60; then
SLEEP=0.4; DELAY_DRAWINFO=1.0; TMOUT=1
elif test "$PL_SPEED1" -gt 55; then
SLEEP=0.5; DELAY_DRAWINFO=1.1; TMOUT=1
elif test "$PL_SPEED1" -gt 50; then
SLEEP=0.6; DELAY_DRAWINFO=1.2; TMOUT=1
elif test "$PL_SPEED1" -gt 45; then
SLEEP=0.7; DELAY_DRAWINFO=1.4; TMOUT=1
elif test "$PL_SPEED1" -gt 40; then
SLEEP=0.8; DELAY_DRAWINFO=1.6; TMOUT=1
elif test "$PL_SPEED1" -gt 35; then
SLEEP=1.0; DELAY_DRAWINFO=2.0; TMOUT=2
elif test "$PL_SPEED1" -gt 30; then
SLEEP=1.5; DELAY_DRAWINFO=3.0; TMOUT=2
elif test "$PL_SPEED1" -gt 25; then
SlEEP=2.0; DELAY_DRAWINFO=4.0; TMOUT=2
elif test "$PL_SPEED1" -gt 20; then
SlEEP=2.5; DELAY_DRAWINFO=5.0; TMOUT=2
elif test "$PL_SPEED1" -gt 15; then
SLEEP=3.0; DELAY_DRAWINFO=6.0; TMOUT=2
elif test "$PL_SPEED1" -gt 10; then
SLEEP=4.0; DELAY_DRAWINFO=8.0; TMOUT=2
elif test "$PL_SPEED1" -ge 0;  then
SLEEP=5.0; DELAY_DRAWINFO=10.0; TMOUT=2
elif test "$PL_SPEED1" = "";   then
_draw 3 "WARNING: Could not set player speed. Using defaults."
else
_exit 1 "ERROR while processing player speed."
fi

_info "Setting SLEEP=$SLEEP ,TMOUT=$TMOUT ,DELAY_DRAWINFO=$DELAY_DRAWINFO"
}

_get_player_speed(){

if test "$1" = '-l'; then
 spc=$((spc+1))
 test "$spc" -ge ${COUNT_CHECK_FOOD:-200} || return 1
 spc=0
fi

_draw 5 "Processing Player's speed..."

local ANSWER OLD_ANSWER PL_SPEED
ANSWER=
OLD_ANSWER=

echo request stat cmbt # only one line

while :; do
read -t $TMOUT ANSWER
_log "$REQUEST_LOG" "request stat cmbt:$ANSWER"
_msg 7 "$ANSWER"
test "$ANSWER" || break
test "$ANSWER" = "$OLD_ANSWER" && break
OLD_ANSWER="$ANSWER"
sleep 0.1
done

#PL_SPEED=`awk '{print $7}' <<<"$ANSWER"`    # *** bash
test "$ANSWER" && PL_SPEED0=`echo "$ANSWER" | awk '{print $7}'` # *** ash + bash
PL_SPEED=${PL_SPEED0:-$PL_SPEED}
PL_SPEED=${PL_SPEED:-50000} # 0.50

case ${#PL_SPEED} in
6) PL_SPEED1="${PL_SPEED:0:4}"; PL_SPEED1=`dc $PL_SPEED1 1000 \/ p`;;
5) PL_SPEED1="0.${PL_SPEED:0:3}";;
4) PL_SPEED1="0.0.${PL_SPEED:0:2}";;
*) :;;
esac

_msg 7 "Player speed is '$PL_SPEED1'"

PL_SPEED_PRE="${PL_SPEED1%.*}."
PL_SPEED_POST="${PL_SPEED1##*.}"
PL_SPEED_POST=`_round_up_and_down $PL_SPEED_POST`
_msg 7 "Rounded Player speed is '$PL_SPEED_POST'"
PL_SPEED_POST=${PL_SPEED_POST:0:2}
_msg 7 "Rounded Player speed is '$PL_SPEED_POST'"

PL_SPEED1="${PL_SPEED_PRE}${PL_SPEED_POST}"
_msg 7 "Rounded Player speed is '$PL_SPEED1'"

PL_SPEED1=`echo "$PL_SPEED1" | sed 's!\.!!g;s!^0*!!'`
_msg 6 "Using player speed '$PL_SPEED1'"

_draw 6 "Done."
return 0
}

_sleep(){
sleep ${SLEEP:-1}
}

### ALCHEMY

_drop_in_cauldron(){

if test "$DRAWINFO" = drawextinfo; then
echo watch drawinfo
echo watch $DRAWINFO
else
echo watch $DRAWINFO
fi

_drop "$@"

_check_drop_or_exit

if test "$DRAWINFO" = drawextinfo; then
echo unwatch drawinfo
echo unwatch $DRAWINFO
else
echo unwatch $DRAWINFO
fi
}

_drop(){
 _sound 0 drip &
 echo issue 1 1 drop "$@"
}

_success(){
 _sound 0 bugle_charge
}

_failure(){
 _sound 0 ouch1
}

_disaster(){
 _sound 0 Missed
}

_unknown(){
 _sound 0 TowerClock
}


# *** Check if standing on a cauldron *** #
_check_if_on_cauldron(){
_draw 5 "Checking if on a cauldron..."

UNDER_ME='';
UNDER_ME_LIST='';
echo request items on

while :; do
read -t $TMOUT UNDER_ME
#echo "$UNDER_ME" >>"$ON_LOG"
_log "$ON_LOG" "_check_if_on_cauldron:$UNDER_ME"
UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"
case $UNDER_ME in
*request*items*on*end*) break;;
*scripttell*break*)     break;;
*scripttell*exit*)    _exit 1;;
esac

unset UNDER_ME
sleep 0.1s
done

test "`echo "$UNDER_ME_LIST" | grep 'cauldron.*cursed'`" && {
_draw 3 "You stand upon a cursed cauldron!"
beep -l 1000 -f 700
exit 1
}

test "`echo "$UNDER_ME_LIST" | grep 'cauldron$'`" || {
_draw 3 "Need to stand upon cauldron!"
beep -l 1000 -f 700
exit 1
}

_draw 7 "OK."
return 0
}

_check_for_space(){
# *** Check for 4 empty space to DIRB ***#

local REPLY_MAP OLD_REPLY NUMBERT
test "$1" && NUMBERT="$1"
test "$NUMBERT" || NUMBERT=4
test "${NUMBERT//[[:digit:]]/}" && _exit 2 "_check_for_space: Need a digit. Invalid parameter passed:$*"

_draw 5 "Checking for space to move..."


#         if ( strncmp(c,"pos",3)==0 ) { // v.1.10.0
#            char buf[1024];
#
#            sprintf(buf,"request map pos %d %d\n",pl_pos.x,pl_pos.y);
#            write(scripts[i].out_fd,buf,strlen(buf));
#         }

#         if ( strncmp(c,"pos",3)==0 ) { // v.1.12.0
#            char buf[1024];
#
#            snprintf(buf, sizeof(buf), "request map pos %d %d\n",pl_pos.x,pl_pos.y);
#            write(scripts[i].out_fd,buf,strlen(buf));
#         }

#         if (strncmp(c, "pos", 3) == 0) { // v.1.70.0
#            char buf[1024];
#
#            snprintf(buf, sizeof(buf), "request map pos %d %d\n", pl_pos.x+use_config[CONFIG_MAPWIDTH]/2, pl_pos.y+use_config[CONFIG_MAPHEIGHT]/2);
#            write(scripts[i].out_fd, buf, strlen(buf));

#        if ( strncmp(c,"near",4)==0 ) { // v.1.10.0
#            for(y=0;y<3;++y)
#               for(x=0;x<3;++x)
#                  send_map(i,
#                           x+pl_pos.x+use_config[CONFIG_MAPWIDTH]/2-1,
#                           y+pl_pos.y+use_config[CONFIG_MAPHEIGHT]/2-1
#                     );
#         }

#        if ( strncmp(c,"near",4)==0 ) { // v.1.12.0
#            for(y=0;y<3;++y)
#               for(x=0;x<3;++x)
#                  send_map(i,
#                           x+pl_pos.x+use_config[CONFIG_MAPWIDTH]/2-1,
#                           y+pl_pos.y+use_config[CONFIG_MAPHEIGHT]/2-1
#                     );
#        }


#         if (strncmp(c, "near", 4) == 0) { // v.1.70.0
#                for (y = 0; y < 3; ++y)
#                    for (x = 0; x < 3; ++x)
#                        send_map(i,
#                            x+pl_pos.x+use_config[CONFIG_MAPWIDTH]/2-1,
#                            y+pl_pos.y+use_config[CONFIG_MAPHEIGHT]/2-1
#                        );
#         }

echo request map pos

echo watch request

# client v.1.70.0 request map pos:request map pos 280 231 ##cauldron adventurers guild stoneville
# client v.1.10.0                 request map pos 272 225 ##cauldron adventurers guild stoneville

while :; do
read -t $TMOUT REPLY_MAP
#echo "request map pos:$REPLY_MAP" >>"$REPLY_LOG"
_log "$REPLY_LOG" "request map pos:$REPLY_MAP"
test "$REPLY_MAP" || break
test "$REPLY_MAP" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY_MAP"
sleep 0.1s
done

echo unwatch request


PL_POS_X=`echo "$REPLY_MAP" | awk '{print $4}'` #request map pos:request map pos 280 231
PL_POS_Y=`echo "$REPLY_MAP" | awk '{print $5}'`

if test "$PL_POS_X" -a "$PL_POS_Y"; then

if test ! "${PL_POS_X//[[:digit:]]/}" -a ! "${PL_POS_Y//[[:digit:]]/}"; then

for nr in `seq 1 1 $NUMBERT`; do

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

    _say_map_pos_1_10_0(){
    cat >&2 <<EoI
    // client v.1.10.0 common/script.c
    static void send_map(int i,int x,int y)
    {
    char buf[1024];

    if (x<0 || y<0 || the_map.x<=x || the_map.y<=y)
    {
        sprintf(buf,"request map %d %d unknown\n",x,y);
        write(scripts[i].out_fd,buf,strlen(buf));
    }
    /*** FIXME *** send more relevant data ***/
    sprintf(buf,"request map %d %d  %d %c %c %c %c"
            " smooth %d %d %d heads %d %d %d tails %d %d %d\n",
            x,y,the_map.cells[x][y].darkness,
            'n'+('y'-'n')*the_map.cells[x][y].need_update,
            'n'+('y'-'n')*the_map.cells[x][y].have_darkness,
            'n'+('y'-'n')*the_map.cells[x][y].need_resmooth,
            'n'+('y'-'n')*the_map.cells[x][y].cleared,
            the_map.cells[x][y].smooth[0],the_map.cells[x][y].smooth[1],the_map.cells[x][y].smooth[2],
            the_map.cells[x][y].heads[0].face,the_map.cells[x][y].heads[1].face,the_map.cells[x][y].heads[2].face,
            the_map.cells[x][y].tails[0].face,the_map.cells[x][y].tails[1].face,the_map.cells[x][y].tails[2].face
        );
        write(scripts[i].out_fd,buf,strlen(buf));
    }
EoI
    }

    _say_map_pos_1_12_0(){
    cat >&2 <<EoI
    // client v.1.12.0 common/script.c
    static void send_map(int i,int x,int y)
    {
    char buf[1024];

    if (x<0 || y<0 || the_map.x<=x || the_map.y<=y)
    {
      snprintf(buf, sizeof(buf), "request map %d %d unknown\n",x,y);
      write(scripts[i].out_fd,buf,strlen(buf));
    }
    /*** FIXME *** send more relevant data ***/
    snprintf(buf, sizeof(buf), "request map %d %d  %d %c %c %c %c"
           " smooth %d %d %d heads %d %d %d tails %d %d %d\n",
           x,y,the_map.cells[x][y].darkness,
           'n'+('y'-'n')*the_map.cells[x][y].need_update,
           'n'+('y'-'n')*the_map.cells[x][y].have_darkness,
           'n'+('y'-'n')*the_map.cells[x][y].need_resmooth,
           'n'+('y'-'n')*the_map.cells[x][y].cleared,
           the_map.cells[x][y].smooth[0],the_map.cells[x][y].smooth[1],the_map.cells[x][y].smooth[2],
           the_map.cells[x][y].heads[0].face,the_map.cells[x][y].heads[1].face,the_map.cells[x][y].heads[2].face,
           the_map.cells[x][y].tails[0].face,the_map.cells[x][y].tails[1].face,the_map.cells[x][y].tails[2].face
      );
      write(scripts[i].out_fd,buf,strlen(buf));
    }
EoI
    }

    _say_map_pos_1_70_0(){
    cat >&2 <<EoI
    // client v.1.70.0 common/script.c
    static void send_map(int i, int x, int y) {
    char buf[1024];

    if (x < 0 || y < 0 || the_map.x <= x || the_map.y <= y) {
        snprintf(buf, sizeof(buf), "request map %d %d unknown\n", x, y);
        write(scripts[i].out_fd, buf, strlen(buf));
    }
    /*** FIXME *** send more relevant data ***/
    snprintf(buf, sizeof(buf), "request map %d %d  %d %c %c %c %c"
        " smooth %d %d %d heads %d %d %d tails %d %d %d\n",
        x, y, the_map.cells[x][y].darkness,
        the_map.cells[x][y].need_update ? 'y' : 'n',
        the_map.cells[x][y].have_darkness ? 'y' : 'n',
        the_map.cells[x][y].need_resmooth ? 'y' : 'n',
        the_map.cells[x][y].cleared ? 'y' : 'n',
        the_map.cells[x][y].smooth[0], the_map.cells[x][y].smooth[1], the_map.cells[x][y].smooth[2],
        the_map.cells[x][y].heads[0].face, the_map.cells[x][y].heads[1].face, the_map.cells[x][y].heads[2].face,
        the_map.cells[x][y].tails[0].face, the_map.cells[x][y].tails[1].face, the_map.cells[x][y].tails[2].face
    );
    write(scripts[i].out_fd, buf, strlen(buf));
    }
EoI
    }


echo request map $R_X $R_Y

echo watch request

while :; do
read -t $TMOUT
#echo "request map '$R_X' '$R_Y':$REPLY" >>"$REPLY_LOG"
_log "$REPLY_LOG" "request map '$R_X' '$R_Y':$REPLY"
test "$REPLY" && IS_WALL=`echo "$REPLY" | awk '{print $16}'`
#echo "IS_WALL=$IS_WALL" >>"$REPLY_LOG"
_log "$REPLY_LOG" "IS_WALL=$IS_WALL"
test "$IS_WALL" = 0 || _exit_no_space 1

test "$REPLY" || break
unset REPLY
sleep 0.1s
done

echo unwatch request

done

else

_draw 3 "Received Incorrect X Y parameters from server"
exit 1

fi

else

_draw 3 "Could not get X and Y position of player."
exit 1

fi

_draw 7 "OK."
}

 _check_for_space_old_client(){
# *** Check for 4 empty space to DIRB ***#

local REPLY_MAP OLD_REPLY NUMBERT cm
test "$1" && NUMBERT="$1"
test "$NUMBERT" || NUMBERT=4
test "${NUMBERT//[[:digit:]]/}" && _exit 2 "_check_for_space_old_client: Need a digit. Invalid parameter passed:$*"

_draw 5 "Checking for space to move..."


#         if ( strncmp(c,"pos",3)==0 ) { // v.1.10.0
#            char buf[1024];
#
#            sprintf(buf,"request map pos %d %d\n",pl_pos.x,pl_pos.y);
#            write(scripts[i].out_fd,buf,strlen(buf));
#         }

#         if ( strncmp(c,"pos",3)==0 ) { // v.1.12.0
#            char buf[1024];
#
#            snprintf(buf, sizeof(buf), "request map pos %d %d\n",pl_pos.x,pl_pos.y);
#            write(scripts[i].out_fd,buf,strlen(buf));
#         }

#         if (strncmp(c, "pos", 3) == 0) { // v.1.70.0
#            char buf[1024];
#
#            snprintf(buf, sizeof(buf), "request map pos %d %d\n", pl_pos.x+use_config[CONFIG_MAPWIDTH]/2, pl_pos.y+use_config[CONFIG_MAPHEIGHT]/2);
#            write(scripts[i].out_fd, buf, strlen(buf));

#        if ( strncmp(c,"near",4)==0 ) { // v.1.10.0
#            for(y=0;y<3;++y)
#               for(x=0;x<3;++x)
#                  send_map(i,
#                           x+pl_pos.x+use_config[CONFIG_MAPWIDTH]/2-1,
#                           y+pl_pos.y+use_config[CONFIG_MAPHEIGHT]/2-1
#                     );
#         }

#        if ( strncmp(c,"near",4)==0 ) { // v.1.12.0
#            for(y=0;y<3;++y)
#               for(x=0;x<3;++x)
#                  send_map(i,
#                           x+pl_pos.x+use_config[CONFIG_MAPWIDTH]/2-1,
#                           y+pl_pos.y+use_config[CONFIG_MAPHEIGHT]/2-1
#                     );
#        }


#         if (strncmp(c, "near", 4) == 0) { // v.1.70.0
#                for (y = 0; y < 3; ++y)
#                    for (x = 0; x < 3; ++x)
#                        send_map(i,
#                            x+pl_pos.x+use_config[CONFIG_MAPWIDTH]/2-1,
#                            y+pl_pos.y+use_config[CONFIG_MAPHEIGHT]/2-1
#                        );
#         }

echo watch request

sleep 0.5

echo request map near

#echo watch request

# client v.1.70.0 request map pos:request map pos 280 231 ##cauldron adventurers guild stoneville
# client v.1.10.0                 request map pos 272 225 ##cauldron adventurers guild stoneville
#                request map near:request map     279 231  0 n n n n smooth 30 0 0 heads 4854 825 0 tails 0 0 0
cm=0
while :; do
cm=$((cm+1))
read -t $TMOUT REPLY_MAP
#echo "request map pos:$REPLY_MAP" >>"$REPLY_LOG"
_log "$REPLY_LOG" "request map near:$REPLY_MAP"
test "$cm" = 5 && break
test "$REPLY_MAP" || break
test "$REPLY_MAP" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY_MAP"
sleep 0.1s
done

echo unwatch request

_empty_message_stream

PL_POS_X=`echo "$REPLY_MAP" | awk '{print $3}'` #request map near:request map 278 230  0 n n n n smooth 30 0 0 heads 4854 0 0 tails 0 0 0
PL_POS_Y=`echo "$REPLY_MAP" | awk '{print $4}'`

if test "$PL_POS_X" -a "$PL_POS_Y"; then

if test ! "${PL_POS_X//[[:digit:]]/}" -a ! "${PL_POS_Y//[[:digit:]]/}"; then

for nr in `seq 1 1 $NUMBERT`; do

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

    _say_map_pos_1_10_0(){
    cat >&2 <<EoI
    // client v.1.10.0 common/script.c
    static void send_map(int i,int x,int y)
    {
    char buf[1024];

    if (x<0 || y<0 || the_map.x<=x || the_map.y<=y)
    {
        sprintf(buf,"request map %d %d unknown\n",x,y);
        write(scripts[i].out_fd,buf,strlen(buf));
    }
    /*** FIXME *** send more relevant data ***/
    sprintf(buf,"request map %d %d  %d %c %c %c %c"
            " smooth %d %d %d heads %d %d %d tails %d %d %d\n",
            x,y,the_map.cells[x][y].darkness,
            'n'+('y'-'n')*the_map.cells[x][y].need_update,
            'n'+('y'-'n')*the_map.cells[x][y].have_darkness,
            'n'+('y'-'n')*the_map.cells[x][y].need_resmooth,
            'n'+('y'-'n')*the_map.cells[x][y].cleared,
            the_map.cells[x][y].smooth[0],the_map.cells[x][y].smooth[1],the_map.cells[x][y].smooth[2],
            the_map.cells[x][y].heads[0].face,the_map.cells[x][y].heads[1].face,the_map.cells[x][y].heads[2].face,
            the_map.cells[x][y].tails[0].face,the_map.cells[x][y].tails[1].face,the_map.cells[x][y].tails[2].face
        );
        write(scripts[i].out_fd,buf,strlen(buf));
    }
EoI
    }

    _say_map_pos_1_12_0(){
    cat >&2 <<EoI
    // client v.1.12.0 common/script.c
    static void send_map(int i,int x,int y)
    {
    char buf[1024];

    if (x<0 || y<0 || the_map.x<=x || the_map.y<=y)
    {
      snprintf(buf, sizeof(buf), "request map %d %d unknown\n",x,y);
      write(scripts[i].out_fd,buf,strlen(buf));
    }
    /*** FIXME *** send more relevant data ***/
    snprintf(buf, sizeof(buf), "request map %d %d  %d %c %c %c %c"
           " smooth %d %d %d heads %d %d %d tails %d %d %d\n",
           x,y,the_map.cells[x][y].darkness,
           'n'+('y'-'n')*the_map.cells[x][y].need_update,
           'n'+('y'-'n')*the_map.cells[x][y].have_darkness,
           'n'+('y'-'n')*the_map.cells[x][y].need_resmooth,
           'n'+('y'-'n')*the_map.cells[x][y].cleared,
           the_map.cells[x][y].smooth[0],the_map.cells[x][y].smooth[1],the_map.cells[x][y].smooth[2],
           the_map.cells[x][y].heads[0].face,the_map.cells[x][y].heads[1].face,the_map.cells[x][y].heads[2].face,
           the_map.cells[x][y].tails[0].face,the_map.cells[x][y].tails[1].face,the_map.cells[x][y].tails[2].face
      );
      write(scripts[i].out_fd,buf,strlen(buf));
    }
EoI
    }

    _say_map_pos_1_70_0(){
    cat >&2 <<EoI
    // client v.1.70.0 common/script.c
    static void send_map(int i, int x, int y) {
    char buf[1024];

    if (x < 0 || y < 0 || the_map.x <= x || the_map.y <= y) {
        snprintf(buf, sizeof(buf), "request map %d %d unknown\n", x, y);
        write(scripts[i].out_fd, buf, strlen(buf));
    }
    /*** FIXME *** send more relevant data ***/
    snprintf(buf, sizeof(buf), "request map %d %d  %d %c %c %c %c"
        " smooth %d %d %d heads %d %d %d tails %d %d %d\n",
        x, y, the_map.cells[x][y].darkness,
        the_map.cells[x][y].need_update ? 'y' : 'n',
        the_map.cells[x][y].have_darkness ? 'y' : 'n',
        the_map.cells[x][y].need_resmooth ? 'y' : 'n',
        the_map.cells[x][y].cleared ? 'y' : 'n',
        the_map.cells[x][y].smooth[0], the_map.cells[x][y].smooth[1], the_map.cells[x][y].smooth[2],
        the_map.cells[x][y].heads[0].face, the_map.cells[x][y].heads[1].face, the_map.cells[x][y].heads[2].face,
        the_map.cells[x][y].tails[0].face, the_map.cells[x][y].tails[1].face, the_map.cells[x][y].tails[2].face
    );
    write(scripts[i].out_fd, buf, strlen(buf));
    }
EoI
    }


echo request map $R_X $R_Y

echo watch request

while :; do
read -t $TMOUT
#echo "request map '$R_X' '$R_Y':$REPLY" >>"$REPLY_LOG"
_log "$REPLY_LOG" "request map '$R_X' '$R_Y':$REPLY"
test "$REPLY" && IS_WALL=`echo "$REPLY" | awk '{print $16}'`
#echo "IS_WALL=$IS_WALL" >>"$REPLY_LOG"
_log "$REPLY_LOG" "IS_WALL=$IS_WALL"
test "$IS_WALL" = 0 || _exit_no_space 1

test "$REPLY" || break
unset REPLY
sleep 0.1s
done

echo unwatch request

done

else

_draw 3 "Received Incorrect X Y parameters from server"
exit 1

fi

else

_draw 3 "Could not get X and Y position of player."
exit 1

fi

_draw 7 "OK."
}

_prepare_rod_of_recall(){
# *** Unreadying rod of word of recall - just in case *** #

local RECALL OLD_REPLY REPLY

_draw 5 "Preparing for recall if monsters come forth..."

RECALL=0
OLD_REPLY="";
REPLY="";

echo request items actv

echo watch request

while :; do
read -t $TMOUT
#echo "request items actv:$REPLY" >>"$REPLY_LOG"
_log "$REPLY_LOG" "request items actv:$REPLY"
case $REPLY in
*rod*of*word*of*recall*) RECALL=1;;
'') break;;
esac

unset REPLY
sleep 0.1s
done

if test "$RECALL" = 1; then # unapply it now , _emergency_exit applies again
_is 1 1 apply rod of word of recall
fi

echo unwatch request

_draw 6 "Done."

}


_check_empty_cauldron(){
# *** Check if cauldron is empty *** #

local REPLY OLD_REPLY REPLY_ALL

_is 1 1 pickup 0  # precaution otherwise might pick up cauldron
sleep 0.5
sleep ${SLEEP}s

_draw 5 "Checking for empty cauldron..."

_is 1 1 apply
sleep 0.5
sleep ${SLEEP}s

OLD_REPLY="";
REPLY_ALL='';
REPLY="";

echo watch $DRAWINFO
#sleep 0.5

#issue <repeat> <must_send> <command>
#- send <command> to server on behalf of client.
#<repeat> is the number of times to execute command
#<must_send> tells whether or not the command must sent at all cost (1 or 0).
#<repeat> and <must_send> are optional parameters.
#See The Issue Command for more details.
#issue 1 0 get nugget (works as 'get 1 nugget')
#issue 2 0 get nugget (works as 'get 2 nugget')
#issue 1 1 get nugget (works as 'get 1 nugget')
#issue 2 1 get nugget (works as 'get 2 nugget')
#issue 0 0 get nugget (works as 'get nugget')

#_is 1 1 get  ##gets 1 of topmost item
#_is 0 1 take
#_is 0 1 get all
#_is 0 1 get
_is 99 1 get

# Note : the commandline of the client handles take and get differently:
# 'get  4 water' would get 4 water of every item containing water
# 'take 4 water' ignores the number and would get all water from the topmost item containing water

#cr=0
while :; do
#cr=$((cr+1))
read -t $TMOUT
#echo "take:$REPLY" >>"$REPLY_LOG"
_log "$REPLY_LOG" "take:$cr:$REPLY"
REPLY_ALL="$REPLY
$REPLY_ALL"
#if test "$cr" -ge 50; then
test "$REPLY" || break
#break
#fi
unset REPLY
sleep 0.1s
done

case $REPLY_ALL in
*You*pick*up*the*cauldron*) _exit 1 "pickup 0 seems not to work in script..?";;
*Nothing*to*take*) :;;
*) _exit 1 "Cauldron NOT empty !!";;
esac
#test "`echo "$REPLY_ALL" | grep '.*Nothing to take!'`" || {
#_draw 3 "Cauldron NOT empty !!"
#_draw 3 "Please empty the cauldron and try again."
#_exit 1
#}

echo unwatch $DRAWINFO

sleep ${SLEEP}s

#_is 1 1 $DIRB
#_is 1 1 $DIRB
#_is 1 1 $DIRF
#_is 1 1 $DIRF
_move_back_and_forth 2

sleep ${SLEEP}s

_draw 7 "OK ! Cauldron IS empty."
}

_alch_and_get(){

_check_if_on_cauldron

local REPLY OLD_REPLY
local HAVE_CAULDRON=1
_unknown &

if test "$DRAWINFO" = drawextinfo; then
echo watch drawinfo
echo watch $DRAWINFO
else
echo watch $DRAWINFO
fi

sleep 0.5
_is 1 1 use_skill alchemy

# *** TODO: The cauldron burps and then pours forth monsters!
OLD_REPLY="";
REPLY="";
while :; do
read -t 1
#echo "$REPLY" >>"$REPLY_LOG"
_log "$REPLY_LOG" "alchemy:$REPLY"
case $REPLY in
                                                       #(level < 25)  /* INGREDIENTS USED/SLAGGED */
                                                       #(level < 40)  /* MAKE TAINTED ITEM */
                                                       #(level == 40) /* MAKE RANDOM RECIPE */ if 0
                                                       #(level < 45)  /* INFURIATE NPC's */
*The*cauldron*creates*a*bomb*) _emergency_exit 1;;     #(level < 50)  /* MINOR EXPLOSION/FIREBALL */
                                                       #(level < 60)  /* CREATE MONSTER */
*The*cauldron*erupts*in*flame*)     HAVE_CAULDRON=0;;  #(level < 80)  /* MAJOR FIRE */
*The*burning*item*erupts*in*flame*) HAVE_CAULDRON=0;;  #(level < 80)  /* MAJOR FIRE */
*turns*darker*then*makes*a*gulping*sound*) _exit 1 "Cauldron probably got cursed";;  #(level < 100) /* WHAMMY the CAULDRON */
*Your*cauldron*becomes*darker*) _exit 1 "Cauldron probably got cursed";;  #(level < 100) /* WHAMMY the CAULDRON */
*pours*forth*monsters*) _emergency_exit 1;;            #(level < 110) /* SUMMON EVIL MONSTERS */
                                                       #(level < 150) /* COMBO EFFECT */
                                                       #(level == 151) /* CREATE RANDOM ARTIFACT */
*You*unwisely*release*potent*forces*) _emergency_exit 1;;  #else /* MANA STORM - watch out!! */
'') break;;
esac

unset REPLY
sleep 0.1s
done

if test "$HAVE_CAULDRON" = 0; then
 _check_if_on_cauldron && HAVE_CAULDRON=1
 test "$HAVE_CAULDRON" = 0 && _exit 1 "Destroyed cauldron." # :D
fi

_is 1 1 apply

#issue <repeat> <must_send> <command>
#- send <command> to server on behalf of client.
#<repeat> is the number of times to execute command
#<must_send> tells whether or not the command must sent at all cost (1 or 0).
#<repeat> and <must_send> are optional parameters.
#See The Issue Command for more details.

#_is  1 1 get  # [AMOUNT] [ITEM]
#_is 99 1 take # [ITEM] ## take gets <repeat> of ITEM -> 99 should be enough to empty the cauldron

#issue 1 0 get nugget (works as 'get 1 nugget')
#issue 2 0 get nugget (works as 'get 2 nugget')
#issue 1 1 get nugget (works as 'get 1 nugget')
#issue 2 1 get nugget (works as 'get 2 nugget')
#issue 0 0 get nugget (works as 'get nugget')
#_is 0 1 take
#_is 0 1 get all
#_is 0 1 get
_is 99 1 get

# Note : the commandline of the client handles take and get differently:
# 'get  4 water' would get 4 water of every item containing water
# 'take 4 water' ignores the number and would get all water from the topmost item containing water

OLD_REPLY="";
REPLY="";
NOTHING=0
SLAG=0

while :; do
read -t 1
#echo "take:$REPLY" >>"$REPLY_LOG"
_log "$REPLY_LOG" "take:$REPLY"
case $REPLY in
*Nothing*to*take*)   NOTHING=1;;
*You*pick*up*the*slag*) SLAG=1;;
'') break;;
esac

unset REPLY
sleep 0.1s
done

if test "$DRAWINFO" = drawextinfo; then
echo unwatch drawinfo
echo unwatch $DRAWINFO
else
echo unwatch $DRAWINFO
fi

sleep ${SLEEP}s
}

_check_drop_or_exit(){
local HAVE_PUT=0
local OLD_REPLY="";
local REPLY="";
while :; do
read -t 1
#echo "drop:$REPLY" >>"$REPLY_LOG"
_log "$REPLY_LOG" "drop:$REPLY"
case $REPLY in
*Nothing*to*drop*)                _exit 1 "Missing in inventory";;
*There*are*only*|*There*is*only*) _exit 1 "Not enough to drop." ;;
*You*put*in*cauldron*) HAVE_PUT=$((HAVE_PUT+1));;
'') break;;
esac

unset REPLY
sleep 0.1s
done

case "$HAVE_PUT" in
0)   _exit 1 "Could not put.";;
1)   :;;
'')  _exit 2 "_check_drop_or_exit:ERROR:Got no content.";;
*[[:alpha:][:punct:]]*) _exit 2 "_check_drop_or_exit:ERROR:Got no number.";;
[2-9]*) _exit 1 "More than one stack put.";;
esac
sleep ${SLEEP}s
}

_close_cauldron(){

#_is 1 1 $DIRB
#_is 1 1 $DIRB
#sleep ${SLEEP}s

#_is 1 1 $DIRF
#_is 1 1 $DIRF
#sleep ${SLEEP}s
_move_back_and_forth 2
}

_go_cauldron_drop_alch_yeld(){
#_is 1 1 $DIRB
#_is 1 1 $DIRB
#_is 1 1 $DIRB
#_is 1 1 $DIRB
#sleep ${SLEEP}s
_move_back 4
}

_go_drop_alch_yeld_cauldron(){
#_is 1 1 $DIRF
#_is 1 1 $DIRF
#_is 1 1 $DIRF
#_is 1 1 $DIRF

#sleep ${SLEEP}s
#sleep ${DELAY_DRAWINFO}s
_move_forth 4
}

_check_cauldron_cursed(){
#_is 1 1 sense curse
_is 1 1 cast detect curse
_is 1 1 fire 0 # 0 is center
_is 1 1 fire_stop
}

_return_to_cauldron(){

_go_drop_alch_yeld_cauldron

_check_food_level

_get_player_speed -l || sleep ${DELAY_DRAWINFO}s

_check_if_on_cauldron

}

### ALCHEMY

#** the messages in the msgpane may pollute **#
#** need to catch msg to discard them into an unused variable **#
_empty_message_stream(){
local REPLY
while :;
do
read -t 1
_log "$REPLY_LOG" "_empty_message_stream:$REPLY"
test "$REPLY" || break
_msg 7 "_empty_message_stream:$REPLY"
unset REPLY
sleep 0.1
done
}

#** we may get attacked and die **#
_check_hp_and_return_home(){

hpc=$((hpc+1))
test "$hpc" -lt $COUNT_CHECK_FOOD && return
hpc=0

local REPLY

test "$1" && local currHP=$1
test "$2" && local currHPMin=$2

test "$currHP"     || local currHP=$HP
test "$HP_MIN_DEF" && local currHPMin=$HP_MIN_DEF
test "$currHPMin"  || local currHPMin=$((MHP/10))

_msg 7 currHP=$currHP currHPMin=$currHPMin
if test "$currHP" -le $currHPMin; then

_empty_message_stream
_is 1 1 apply -a rod of word of recall
_empty_message_stream

_is 1 1 fire center ## Todo check if already applied and in inventory
_is 1 1 fire_stop
_empty_message_stream

echo unwatch $DRAWINFO
exit
fi

unset HP
}

#Food

_check_mana_for_create_food(){

local REPLY
_is 1 0 cast create

while :;
do

read -t 1
_msg 7 "_check_mana_for_create_food:$REPLY"
case $REPLY in
*ready*the*spell*create*food*) return 0;;
*create*food*)
MANA_NEEDED=`echo "$REPLY" | awk '{print $NF}'`
test "$SP" -ge "$MANA_NEEDED" && return 0
;;
'') break;;
*) sleep 0.1; continue;;
esac

sleep 0.1
unset REPLY
done

return 1
}

_cast_create_food_and_eat(){

local lEAT_FOOD REPLY1 REPLY2 REPLY3 REPLY4 BUNGLE

test "$EAT_FOOD" && lEAT_FOOD="$EAT_FOOD"
test "$*" && lEAT_FOOD="$@"
test "$lEAT_FOOD" || lEAT_FOOD=$FOOD_DEF
test "$lEAT_FOOD" || lEAT_FOOD=food

#while :;
#do
#_check_mana_for_create_food && break || { sleep 10; continue; }
#done

_is 1 1 pickup 0
_empty_message_stream

# TODO : Check MANA
_is 1 1 cast create food $lEAT_FOOD
_empty_message_stream

while :;
do
_is 1 1 fire_stop
sleep 0.1

while :;
do
_check_mana_for_create_food && break || { sleep 10; continue; }
done

sleep 0.1
_is 1 1 fire center ## Todo handle bungling the spell

unset BUNGLE
sleep 0.1
read -t 1 BUNGLE
test "`echo "$BUNGLE" | grep -i 'bungle'`" || break
sleep 0.1
done

_is 1 1 fire_stop
sleep 1
_empty_message_stream


_is 1 1 apply ## Todo check if food is there on tile
_empty_message_stream

}

_apply_horn_of_plenty_and_eat(){
local REPLY

read -t 1
_is 1 1 apply -a Horn of Plenty
sleep 1
unset REPLY
read -t 1

_is 1 1 fire center ## Todo handle bungling
_is 1 1 fire_stop
sleep 1
unset REPLY
read -t 1

_is 1 1 apply ## Todo check if food is there on tile
unset REPLY
read -t 1
}


_eat_food(){

local REPLY

test "$*" && EAT_FOOD="$@"
test "$EAT_FOOD" || EAT_FOOD=waybread

#_check_food_inventory ## Todo: check if food is in INV

read -t 1
_is 1 1 apply $EAT_FOOD
unset REPLY
read -t 1
}

_check_food_level(){

fc=$((fc+1))
test "$fc" -lt $COUNT_CHECK_FOOD && return
fc=0

test "$*" && MIN_FOOD_LEVEL="$@"
test "$MIN_FOOD_LEVEL" || MIN_FOOD_LEVEL=200

local FOOD_LVL=''
local REPLY

read -t 1  # empty the stream of messages

echo watch $DRAWINFO
sleep 1
echo request stat hp   #hp,maxhp,sp,maxsp,grace,maxgrace,food
while :;
do
unset FOOD_LVL
read -t1 Re Stat Hp HP MHP SP MSP GR MGR FOOD_LVL
test "$Re" = request || continue

test "$FOOD_LVL" || break
test "${FOOD_LVL//[[:digit:]]/}" && break

_msg 7 HP=$HP $MHP $SP $MSP $GR $MGR FOOD_LVL=$FOOD_LVL #DEBUG

if test "$FOOD_LVL" -lt $MIN_FOOD_LEVEL; then
 #_eat_food
 _cast_create_food_and_eat $EAT_FOOD

 sleep 1
 _empty_message_stream
 sleep 1
 echo request stat hp   #hp,maxhp,sp,maxsp,grace,maxgrace,food
 #sleep 0.1
 sleep 1
 read -t1 Re2 Stat2 Hp2 HP2 MHP2 SP2 MSP2 GR2 MGR2 FOOD_LVL
 _msg 7 HP=$HP2 $MHP2 $SP2 $MSP2 $GR2 $MGR2 FOOD_LVL=$FOOD_LVL #DEBUG

 #return $?
 break
fi

test "${FOOD_LVL//[[:digit:]]/}" || break
test "$FOOD_LVL" && break
test "$oF" = "$FOOD_LVL" && break

oF="$FOOD_LVL"
sleep 0.1
done

echo unwatch $DRAWINFO
}

#Food


