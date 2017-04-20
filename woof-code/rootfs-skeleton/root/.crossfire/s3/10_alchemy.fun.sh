#!/bin/ash


### ALCHEMY
_drop(){
 _sound 0 drip &
 _is 1 1 drop "$@"
}

_drop_in_cauldron(){

if test "$DRAWINFO" = drawextinfo; then
echo watch drawinfo
_watch
else
_watch
fi

_drop "$@"

#echo sync
_sleep

_check_drop_or_exit "$@"

if test "$DRAWINFO" = drawextinfo; then
echo unwatch drawinfo
_unwatch
else
_unwatch
fi
}


# *** Check if standing on a cauldron *** #
_check_if_on_cauldron(){  # called by _alch_and_get(), _return_to_cauldron()
_sleep
_draw 5 "Checking if on a cauldron..."

local UNDER_ME='';
local UNDER_ME_LIST='';
_debugx A
_debugx "UNDER_ME_LIST='$UNDER_ME_LIST'"

echo request items on

while :; do
read -t $TMOUT UNDER_ME
_debugx C
_debugx "UNDER_ME='$UNDER_ME'"
_debugx "UNDER_ME_LIST='$UNDER_ME_LIST'"

_log "$ON_LOG" "_check_if_on_cauldron:$UNDER_ME"

_debugx L
_debugx "UNDER_ME='$UNDER_ME'"
_debugx "UNDER_ME_LIST='$UNDER_ME_LIST'"

_debugx X
 UNDER_ME_LIST="${UNDER_ME}
${UNDER_ME_LIST}"
#UNDER_ME_LIST=`echo -e "${UNDER_ME}"\\n"${UNDER_ME_LIST}"`
#UNDER_ME_LIST=`echo -e "${UNDER_ME}\\n${UNDER_ME_LIST}"`
_debug "UNDER_ME_LIST='$UNDER_ME_LIST'"

case $UNDER_ME in
*request*items*on*end*) break;;
*scripttell*break*)     break;;
*scripttell*exit*)    _exit 1 "$UNDER_ME";;
esac

unset UNDER_ME
sleep 0.1s
done

_debugx B
UNDER_ME_LIST=`echo "$UNDER_ME_LIST" | grep -v 'malfunction'`
_debugx "UNDER_ME_LIST='$UNDER_ME_LIST'"

_debugx C
UNDER_ME_LIST=`echo "$UNDER_ME_LIST" | sed '/^$/d'`
_debug "UNDER_ME_LIST='$UNDER_ME_LIST'"

test "`echo "$UNDER_ME_LIST" | grep 'cauldron.*cursed'`" && {
_draw 3 "You stand upon a cursed cauldron!"
_beep
_exit 1
}

_debugx "UNDER_ME_LIST='$UNDER_ME_LIST'"
test "`echo "$UNDER_ME_LIST" | grep 'cauldron$'`" || {
_draw 3 "Need to stand upon cauldron!"
_beep
_exit 1
}

#+++2017-03-20 make sure cauldron is on top
_debugx "UNDER_ME_LIST='$UNDER_ME_LIST'"
#test "`echo "$UNDER_ME_LIST" | head -n1 | grep 'cauldron$'`" || {
test "`echo "$UNDER_ME_LIST" | tail -n1 | grep 'cauldron$'`" || {
_draw 3 "Cauldron is not topmost!"
_beep
_exit 1
}

_draw 7 "OK."
return 0
}

_check_empty_cauldron(){
# *** Check if cauldron is empty *** #

local REPLY OLD_REPLY REPLY_ALL

_is 1 1 pickup 0  # precaution otherwise might pick up cauldron
#sleep 0.5
_sleep

_draw 5 "Checking for empty cauldron..."

_is 1 1 apply
#sleep 0.5
_sleep

OLD_REPLY="";
REPLY_ALL='';
REPLY="";

_watch
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
_log "$REPLY_LOG" "take:$cr:$REPLY"
_debug "$REPLY"
#REPLY_ALL="$REPLY
#$REPLY_ALL"
#REPLY_ALL=`echo -e "$REPLY"\\n"$REPLY_ALL"`

REPLY_ALL=`echo -e "$REPLY\\n$REPLY_ALL"`

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
# _draw 3 "Cauldron NOT empty !!"
# _draw 3 "Please empty the cauldron and try again."
# _exit 1
# }

_unwatch

_sleep

#_is 2 1 $DIRB
_is 1 1 $DIRB
_is 1 1 $DIRB

#_is 2 1 $DIRF
_is 1 1 $DIRF
_is 1 1 $DIRF

_sleep

_draw 7 "OK ! Cauldron SEEMS empty."
}

_alch_and_get(){

_check_if_on_cauldron

local REPLY OLD_REPLY
local HAVE_CAULDRON=1
_unknown &

if test "$DRAWINFO" = drawextinfo; then
echo watch drawinfo
_watch
else
_watch
fi

sleep 0.5
_is 1 1 use_skill alchemy

# *** TODO: The cauldron burps and then pours forth monsters!
OLD_REPLY="";
REPLY="";
while :; do
read -t $TMOUT
_log "$REPLY_LOG" "alchemy:$REPLY"
_debug "$REPLY"
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
read -t $TMOUT

_log "$REPLY_LOG" "get/take:$REPLY"
_debug "$REPLY"
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
_unwatch
else
_unwatch
fi

_sleep
}

_check_drop_or_exit(){
local HAVE_PUT=0
local OLD_REPLY="";
local REPLY="";

while :; do
read -t $TMOUT
_log "$REPLY_LOG" "_check_drop_or_exit:$REPLY"
_debug "_check_drop_or_exit:'$REPLY'"

case $REPLY in
*Nothing*to*drop*)                _exit 1 "Missing '$@' in inventory";;
*There*are*only*|*There*is*only*) _exit 1 "Not enough '$@' to drop." ;;
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
[2-9]*|1[0-9]*) _exit 1 "More than one stack of '$@' put.";;
esac
_sleep
}

_close_cauldron(){

#_is 2 1 $DIRB
_is 1 1 $DIRB
_is 1 1 $DIRB
_sleep

#_is 2 1 $DIRF
_is 1 1 $DIRF
_is 1 1 $DIRF
_sleep
}

_go_cauldron_drop_alch_yeld(){
#_is 4 1 $DIRB
_is 1 1 $DIRB
_is 1 1 $DIRB
_is 1 1 $DIRB
_is 1 1 $DIRB
_sleep
}

_go_drop_alch_yeld_cauldron(){
#_is 4 1 $DIRF
_is 1 1 $DIRF
_is 1 1 $DIRF
_is 1 1 $DIRF
_is 1 1 $DIRF
_sleep
#sleep ${DELAY_DRAWINFO}s
}

_check_cauldron_cursed(){  #TODO
#_is 1 1 sense curse
_is 1 1 cast detect curse
_is 1 1 fire 0 # 0 is center
_is 1 1 fire_stop
}

_return_to_cauldron(){

_go_drop_alch_yeld_cauldron  ## sleeps at the end

_check_food_level   ## early return or long code with sleep

_get_player_speed -l || sleep ${DELAY_DRAWINFO}s

_check_if_on_cauldron  ## sleeps at the beginning

}

### ALCHEMY
