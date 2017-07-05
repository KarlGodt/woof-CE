#!/bin/sh

# *** diff marker 1
# ***
# ***

TIMEA=`/bin/date +%s`

DIRB=west  # direction back to go

case $DIRB in
west)  DIRF=east;;   # direction forward
east)  DIRF=west;;
north) DIRF=south;;
south) DIRF=north;;

northwest) DIRF=southeast;;
northeast) DIRF=southwest;;
southwest) DIRF=northeast;;
southeast) DIRF=northwest;;
esac

DRAWINFO=drawinfo   # drawinfo (old servers or clients compiled by confused compiler)
                    # OR drawextinfo (new servers)
                    # used for catching msgs watch/unwatch $DRAW_INFO


LOG_FILE=/tmp/cf_script.log

_usage(){
echo draw 5 "Script to"
echo draw 5 "ready_skill hiding"
echo draw 5 "and run fire center"
echo draw 4 "and go one step $DIRB and $DIRF"
echo draw 4 "in a loop to gain 1 exp point each step."

        exit 0
}


_draw(){
    local COLOUR="$1"
    COLOUR=${COLOUR:-1} #set default
    shift
    local MSG="$@"
    echo draw $COLOUR "$MSG"
}

_log(){
    test "$LOGGING" || return 0
    local lFILE
    test "$2" && {
    lFILE="$1"; shift; } || lFILE="$LOG_FILE"
   echo "$*" >>"$lFILE"
}

_debug(){
test "$DEBUG" || return 0
    _draw ${COL_DEB:-3} "DEBUG:$@"
}
_debugx(){
test "$DEBUGX" || return 0
    _draw ${COL_DEB:-3} "DEBUGX:$@"
}

_is(){
    _verbose "$*"
    echo issue "$@"
    sleep 0.2
}

_verbose(){
test "$VERBOSE" || return 0
_draw ${COL_VERB:-12} "VERBOSE:$*"
}

_watch(){
echo unwatch $DRAWINFO
echo   watch $DRAWINFO
}

_parse_parameters(){

DEBUGX=1

until [ $# = 0 ];
do
_debugx "'$1' '$2'"
case $1 in

-h|*help|*usage) _usage;;

--*) case $1 in
      --help)   _usage;;
      --deb*)    DEBUG=$((DEBUG+1));;
      --fast)  SLEEP_MOD='/'; SLEEP_MOD_VAL=$((SLEEP_MOD_VAL+1));;
      --log*)  LOGGING=$((LOGGING+1));;
      --number=*) NUMBER=`echo "$1" | cut -f2 -d'='`;;
      --number)   NUMBER="$2"; shift;;
      --slow)  SLEEP_MOD='*'; SLEEP_MOD_VAL=$((SLEEP_MOD_VAL+1));;
      --verb*) VERBOSE=$((VERBOSE+1));;
      *) _draw 3 "Ignoring unhandled option '$PARAM_1'";;
     esac
;;
-*) OPTS=`printf '%s' "$1" | sed -r 's/^-*//; s/(.)/\1\n/g'`  # echo "$1" would echo -n if passed ...
    _debugx "OPTS='$OPTS'"
    for oneOP in $OPTS; do
    _debugx "oneOP='$oneOP'"
     case $oneOP in
      h)  _usage;;
      d)   DEBUG=$((DEBUG+1));;
      F) SLEEP_MOD='/'; SLEEP_MOD_VAL=$((SLEEP_MOD_VAL+1));;
      L) LOGGING=$((LOGGING+1));;
      n) NUMBER="$2"; _debugx "n:$*";shift;_debugx "n:$*";;
      S) SLEEP_MOD='*'; SLEEP_MOD_VAL=$((SLEEP_MOD_VAL+1));;
      v) VERBOSE=$((VERBOSE+1));;
      *) _draw 3 "Ignoring unhandled option '$oneOP'";;
     esac
    done
;;

esac
shift
sleep 0.1
done
}


# ***
# ***
# *** diff marker 2
# *** diff marker 3
# ***
# ***


# *** Here begins program *** #
echo draw 2 "$0 is started.."

_parse_parameters "$@"

_is 1 1 ready_skill hiding

while :
do

 while :; do
    _watch
    _is 1 1 fire 0
        while :; do
        unset REPLY
        read -t 1
        case $REPLY in
        *fail*conceal*) break 2;;  #You fail to conceal yourself.
        *hide*shadow*)  break 1;;  #You hide in the shadows.
        '') break;;
        esac
        done
    _is 1 1 fire_stop
 # after being able to conceal needs to walk around
 # for each next tile gives 1 exp.
 # we go back and forth here:
 for a in 1 2 3 4; do
 _is 1 1 $DIRB; done
 for a in 1 2 3 4; do
 _is 1 1 $DIRF; done

 break
 done

sleep 1
done


# ***
# ***
# *** diff marker 4
