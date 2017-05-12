#!/bin/ash

_beep(){
[ "$BEEP_DO" ] || return 0
test "$1" && { BEEP_L=$1; shift; }
test "$1" && { BEEP_F=$1; shift; }
BEEP_LENGTH=${BEEP_L:-$BEEP_LENGTH}
BEEP_FREQ=${BEEP_F:-$BEEP_FREQ}
beep -l $BEEP_LENGTH -f $BEEP_FREQ "$@"
}

_verbose(){
test "$VERBOSE" || return 0
_draw ${COL_VERB:-12} "VERBOSE:$*"
}

__draw(){
    local COLOUR="$1"
    test "$COLOUR" || COLOUR=1 #set default
    shift
    local MSG="$@"
    echo $DRAWINFO $COLOUR "$MSG"
}

_draw(){
    local COLOUR="$1"
    COLOUR=${COLOUR:-1} #set default
    shift
    local MSG="$@"
    echo draw $COLOUR "$MSG"
}

_black()  { _draw 0  "$*"; }
_bold()   { _draw 1  "$*"; }
_blue()   { _draw 5  "$*"; }
_navy()   { _draw 2  "$*"; }
_lgreen() { _draw 8  "$*"; }
_green()  { _draw 7  "$*"; }
_red()    { _draw 3  "$*"; }
_dorange(){ _draw 6  "$*"; }
_orange() { _draw 4  "$*"; }
_gold()   { _draw 11 "$*"; }
_tan()    { _draw 12 "$*"; }
_brown()  { _draw 10 "$*"; }
_gray()   { _draw 9  "$*"; }
alias _grey=_gray

__debug(){
test "$DEBUG" || return 0
    _draw ${COL_DEB:-3} "DEBUG:$@"
}

_debug(){
test "$DEBUG" || return 0
while read -r line
do
test "$line" || continue
_draw ${COL_DEB:-3} "DEBUG:$line"
done <<EoI
`echo "$*"`
EoI
}

_debugx(){
test "$DEBUGX" || return 0
while read -r line
do
test "$line" || continue
_draw ${COL_DEB:-11} "DEBUG:$line"
done <<EoI
`echo "$*"`
EoI
}

__log(){
[ "$LOGGING" ] || return 0
echo "$*" >>"$LOGFILE"
}

_log(){
    test "$LOGGING" || return 0
    local lFILE
    test "$2" && {
    lFILE="$1"; shift; } || lFILE="$LOGFILE"
   echo "$*" >>"$lFILE"
}

_remove_err_log(){
#+++2017-03-20 Remove *.err file if empty
if test -s "$TMP_DIR"/"$MY_BASE".$$.err; then
_draw 3 "WARNING:Content reported in $TMP_DIR/$MY_BASE.$$.err ."
false
else
_draw 7 "No content reported in $TMP_DIR/$MY_BASE.$$.err ."
[ "$DEBUG" ] || rm -f "$TMP_DIR"/"$MY_BASE".$$.err
true
fi
}

_sound(){
    local DUR
test "$2" && { DUR="$1"; shift; }
DUR=${DUR:-0}
test -e "$SOUND_DIR"/${1}.raw && \
           aplay $Q $VERB -d $DUR "$SOUND_DIR"/${1}.raw
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


_say_start_msg(){
# *** Here begins program *** #
if test "$MY_SELF"; then
_draw 2 "$0 ->"
_draw 2 "$MY_SELF"
_draw 2 "has started.."
else
_draw 2 "$0 has started.."
fi
_draw 2 "PID is $$ - parentPID is $PPID" # logfiles

# *** Check for parameters *** #
_draw 5 "Checking the parameters ($*)..."
}

_say_end_msg(){
# *** Here ends program *** #
_is 1 1 fire_stop
if test -f "$HOME"/.crossfire/sounds/su-fanf.raw; then
aplay $Q "$HOME"/.crossfire/sounds/su-fanf.raw & aPID=$!
else
(
beep -l 300 -f 700
beep -l 300 -f 750
beep -l 300 -f 800
beep -l 300 -f 1000
) & aPID=$!
fi

_say_statistics_end

_remove_err_log

test "$aPID" && wait $aPID
_draw 2  "$0 has finished."
}

# times
_say_minutes_seconds(){
# syntax: _say_minutes_seconds "500" "600" "Loop run:"
test "$1" -a "$2" || return 3

local TIMEa TIMEz TIMEy TIMEm TIMEs

TIMEa="$1"
shift
TIMEz="$1"
shift

TIMEy=$((TIMEz-TIMEa))
TIMEm=$((TIMEy/60))
TIMEs=$(( TIMEy - (TIMEm*60) ))
case $TIMEs in [0-9]) TIMEs="0$TIMEs";; esac

_draw 5 "$* $TIMEm:$TIMEs minutes."
}

_say_success_fail(){  # melt icecube

NUMBER=${NUMBER:-$1}
success=${success:-$2}
FAIL=${FAIL:-$3}

if test "$NUMBER" -a "$success"; then
FAIL=${FAIL:-$((NUMBER-success))} # balm of first aid
fi

test "$NUMBER" -a "$FAIL" || return 3
test "${NUMBER//[0-9]/}"  && return 4
test "${FAIL//[0-9]/}"    && return 5

if test "$FAIL" -le 0; then
 SUCC=$((NUMBER-FAIL))
 PERCENT=$(( (SUCC*100) / NUMBER ))
 _draw 7 "You succeeded '$SUCC' times of '$NUMBER' (${PERCENT}%)." # green
elif test "$((NUMBER/FAIL))" -lt 2;
then
 PERCENT=$(( (FAIL*100) / NUMBER ))
 _draw 8 "You failed '$FAIL' times of '$NUMBER' (${PERCENT}%)."    # light green
 _draw 7 "PLEASE increase your INTELLIGENCE !!"
else
 SUCC=$((NUMBER-FAIL))
 PERCENT=$(( (SUCC*100) / NUMBER ))
 _draw 7 "You succeeded '$SUCC' times of '$NUMBER' (${PERCENT}%)." # green
fi
}

_say_statistics_end(){
# Now count the whole loop time
TIMELE=`/bin/date +%s`
TIMELB=${TIMELB:-$TIMEB}
_say_minutes_seconds "$TIMELB" "$TIMELE" "Whole  loop  time :"

_say_success_fail

# Now count the whole script time
TIMEZ=`/bin/date +%s`
_say_minutes_seconds "$TIMEA" "$TIMEZ" "Whole script time :"
}

___loop_counter(){
test "$TIMEA" -a "$TIMEB" -a "$NUMBER" -a "$one" || return 0
TRIES_STILL=$((NUMBER-one))
TIMEE=`/bin/date +%s`
TIME=$((TIMEE-TIMEB))
TIMEZ=$((TIMEE-TIMEA))
TIMEAV=$((TIMEZ/one))
TIMEEST=$(( (TRIES_STILL*TIMEAV) / 60 ))
_draw 4 "Elapsed $TIME s, $success of $one successfull, still $TRIES_STILL ($TIMEEST m) to go..."
}


__loop_counter(){  # balm of first aid
#test "$TIMEA" -a "$TIMEB" -a "$TIMEC" -a "$NUMBER" -a "$one" || return 0
test "$1" -o "$TIMEA" -o "$TIMEB" -o "$TIMEC" || return 0
test "$NUMBER" -a "$one" || return 0

TIMEC=${TIMEC:-$1}
TIMEC=${TIMEC:-$TIMEB}
TIMEC=${TIMEC:-$TIMEA}

test "$TIMEC"           || return 3
test "${TIMEC//[0-9]/}" && return 4

TIMEB=${TIMEB:-$2}
TIMEB=${TIMEB:-$TIMEA}

test "$TIMEB"           || return 5
test "${TIMEB//[0-9]/}" && return 6

TIMEE=`/bin/date +%s`

TIMEX=$((TIMEE-TIMEC))
TIMEY=$((TIMEE-TIMEB))

local MSG

if _test_integer "$NUMBER"; then
TRIES_STILL=$((NUMBER-one))
TIMEAV=$((TIMEY/one))
TIMEAV=$((TRIES_STILL*TIMEAV))
#TIMEESTM=$(( (TRIES_STILL*TIMEAV) / 60 ))
#TIMEESTS=$(( (TRIES_STILL*TIMEAV) - (TIMEESTM*60) ))
MSG="Still '$TRIES_STILL' attempts to go..."
else
TRIES_STILL=$one
TIMEAV=$((TIMEAV+TIMEX))
#TIMEESTM=$(( TIMEAV / 60 ))
#TIMEESTS=$(( TIMEAV - (TIMEESTM*60) ))
MSG="$TRIES_STILL attempts completed..."
fi

TIMEESTM=$(( TIMEAV / 60 ))
TIMEESTS=$(( TIMEAV - (TIMEESTM*60) ))
case $TIMEESTS in [0-9]) TIMEESTS="0$TIMEESTS";; esac

_draw 4 "Elapsed '$TIMEX' s, '$success' of '$one' successfull."
_draw 4 "$MSG ($TIMEESTM:$TIMEESTS m)"
}

_loop_counter_main(){
#test "$TIMEA" -a "$TIMEB" -a "$TIMEC" -a "$NUMBER" -a "$one" || return 0
test "$1" -o "$TIMEA" -o "$TIMEB" -o "$TIMEC" || return 0
test "$NUMBER" -a "$one" || return 4

TIMEC=${TIMEC:-$1}
TIMEC=${TIMEC:-$TIMEB}
TIMEC=${TIMEC:-$TIMEA}

test "$TIMEC"           || return 5
test "${TIMEC//[0-9]/}" && return 6

TIMEB=${TIMEB:-$2}
TIMEB=${TIMEB:-$TIMEA}

test "$TIMEB"           || return 7
test "${TIMEB//[0-9]/}" && return 8

TIMEE=`/bin/date +%s`

TIMEX=$((TIMEE-TIMEC))
TIMEY=$((TIMEE-TIMEB))
}

_loop_counter_ms(){
TIMEESTM=$(( TIMEAV / 60 ))
TIMEESTS=$(( TIMEAV - (TIMEESTM*60) ))
case $TIMEESTS in [0-9]) TIMEESTS="0$TIMEESTS";; esac

_draw 4 "Elapsed '$TIMEX' s, '$success' of '$one' successfull."
}

_loop_counter_number(){  # balm of first aid

_loop_counter_main || return 0

TRIES_STILL=$((NUMBER-one))
TIMEAV=$((TIMEY/one))
TIMEAV=$((TRIES_STILL*TIMEAV))

_loop_counter_ms
_draw 4 "Still '$TRIES_STILL' attempts to go... ($TIMEESTM:$TIMEESTS m)"
}


_loop_counter_infinite(){  # balm of first aid

_loop_counter_main || return 0

TRIES_STILL=$one
TIMEAV=$((TIMEAV+TIMEX))

_loop_counter_ms
_draw 4 "$TRIES_STILL attempts completed... ($TIMEESTM:$TIMEESTS m)"
}

# ** the messages in the msgpane may pollute ** #
# ** need to catch msg to discard them into an unused variable ** #
_empty_message_stream(){
local REPLY

while :;
do
read -t $TMOUT
_log "$REPLY_LOG" "_empty_message_stream:$REPLY"
#_debug "$REPLY"
test "$REPLY" || break
_debug "_empty_message_stream:$REPLY"
unset REPLY
sleep 0.1
done
}
