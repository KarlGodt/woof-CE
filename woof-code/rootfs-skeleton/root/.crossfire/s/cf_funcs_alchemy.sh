#!/bin/ash

[ "$HAVE_FUNCS_ALCHEMY" ] && return 0

# depends :
[ "$HAVE_FUNCS_COMMON"   ] || . cf_funcs_common.sh

### ALCHEMY

_drop_in_cauldron(){
_debug "_drop_in_cauldron:$*"

test "$*" || return 254

_watch $DRAWINFO
_drop "$@"
_check_drop_or_exit
_unwatch $DRAWINFO
}

_check_if_on_cauldron(){
# *** Check if standing on a cauldron *** #
_debug "_check_if_on_cauldron:$*"
_draw 5 "Checking if on a cauldron..."

UNDER_ME='';
UNDER_ME_LIST='';

_empty_message_stream
echo request items on

while :; do
read -t $TMOUT UNDER_ME
_log "$ON_LOG" "_check_if_on_cauldron:$UNDER_ME"
_debug "$UNDER_ME"

UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"

case $UNDER_ME in
*request*items*on*end*) break;;
*scripttell*break*)     break ${UNDER_ME##*?break};;
*scripttell*exit*)    _exit 1 $REPLY;;
*'YOU HAVE DIED.'*) _just_exit;;
*bed*to*reality*)   _just_exit;;
esac

unset UNDER_ME
sleep 0.1s
done

test "`echo "$UNDER_ME_LIST" | grep -E 'cauldron.*cursed|cauldron.*damned'`" && {
#_draw 3 "You stand upon a cursed cauldron!"
#_beep_std
_exit 1 "You stand upon a cursed cauldron!"
}

test "`echo "$UNDER_ME_LIST" | grep 'cauldron$'`" || {
#_draw 3 "Need to stand upon cauldron!"
#_beep_std
_exit 1 "Need to stand upon cauldron!"
}

_draw 7 "OK."
return 0
}


_check_empty_cauldron(){
# *** Check if cauldron is empty *** #
_debug "_check_empty_cauldron:$*"

local REPLY OLD_REPLY REPLY_ALL

#_is 1 1 pickup 0  # precaution otherwise might pick up cauldron
_set_pickup 0
sleep 0.5
_sleep

_draw 5 "Checking for empty cauldron..."

# opening the cauldron:
_is 1 1 apply
sleep 0.5
_sleep

OLD_REPLY="";
REPLY_ALL='';
REPLY="";

# getting items out of the cauldron
_watch $DRAWINFO
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

while :; do unset REPLY
read -t $TMOUT
_log "$REPLY_LOG" "take:$cr:$REPLY"
_debug "$REPLY"

REPLY_ALL="$REPLY
$REPLY_ALL"

test "$REPLY" || break
sleep 0.1s
done

case $REPLY_ALL in
*You*pick*up*the*cauldron*) _exit 1 "pickup 0 seems not to work in script..?";;
*Nothing*to*take*) :;;
*) _exit 1 "Cauldron seems to be NOT empty !!";;
esac

_unwatch $DRAWINFO

#_sleep
_move_back_and_forth 2
#_sleep

_draw 7 "OK ! Cauldron IS empty."
}

_alch_and_get(){
_debug "_alch_and_get:$*"

_check_if_on_cauldron || return 1

local REPLY OLD_REPLY
local HAVE_CAULDRON=1
_unknown &

_watch $DRAWINFO

sleep 0.5
_is 1 1 use_skill alchemy

# *** TODO: The cauldron burps and then pours forth monsters!
OLD_REPLY="";
REPLY="";
while :; do unset REPLY
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

sleep 0.1s
done

if test "$HAVE_CAULDRON" = 0; then
 _check_if_on_cauldron && HAVE_CAULDRON=1
 test "$HAVE_CAULDRON" = 0 && _exit 1 "Destroyed cauldron." # :D
fi

# Now opening the cauldron
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

while :; do unset REPLY
read -t $TMOUT
_log "$REPLY_LOG" "take:$REPLY"
_debug "$REPLY"
case $REPLY in
*Nothing*to*take*)   NOTHING=1;;
*You*pick*up*the*slag*) SLAG=1;;
'') break;;
esac

sleep 0.1s
done

_unwatch $DRAWINFO
_sleep
}

_check_drop_or_exit(){
_debug "_check_drop_or_exit:$*"

local HAVE_PUT=0
local OLD_REPLY="";
local REPLY="";

while :; do unset REPLY
read -t $TMOUT
_log "$REPLY_LOG" "_check_drop_or_exit:$REPLY"
_debug "$REPLY"
case $REPLY in
*Nothing*to*drop*)                _exit 1 "Missing in inventory";;
*There*are*only*|*There*is*only*) _exit 1 "Not enough to drop." ;;
*You*put*in*cauldron*) HAVE_PUT=$((HAVE_PUT+1));;
'') break;;
esac

sleep 0.1s
done

case "$HAVE_PUT" in
0)   _exit 1 "Could not put.";;
1)   :;;
'')  _exit 2 "_check_drop_or_exit:ERROR:Got no content.";;
*[[:alpha:][:punct:]]*) _exit 2 "_check_drop_or_exit:ERROR:Got no number.";;
[2-9]*) _exit 1 "More than one stack put.";;
esac
_sleep
}

_close_cauldron(){
_move_back_and_forth 2
}

_go_cauldron_drop_alch_yeld(){
_move_back 4
}

_go_drop_alch_yeld_cauldron(){
_move_forth 4
}

_check_cauldron_cursed_use_skill(){
_is 1 1 use_skill sense curse
}

_check_cauldron_cursed_ready_skill(){
_is 1 1 ready_skill sense curse
_is 1 1 fire 0 # 0 is center
_is 1 1 fire_stop
}

_check_cauldron_cursed_cast_detect_curse(){
_is 1 1 cast detect curse
_is 1 1 fire 0 # 0 is center
_is 1 1 fire_stop
}

_check_cauldron_cursed_invoke_detect_curse(){
_is 1 1 invoke detect curse
}

_check_cauldron_cursed(){
_debug "_check_cauldron_cursed:$*"
##_is 1 1 use_skill sense curse
#_is 1 1 cast detect curse
#_is 1 1 fire 0 # 0 is center
#_is 1 1 fire_stop

 _check_cauldron_cursed_use_skill
#_check_cauldron_cursed_ready_skill
#_check_cauldron_cursed_cast_detect_curse
#_check_cauldron_cursed_invoke_detect_curse
}

_return_to_cauldron(){
_debug "_return_to_cauldron:$*"

_go_drop_alch_yeld_cauldron

_check_food_level

_get_player_speed -l || sleep ${DELAY_DRAWINFO}s

_check_if_on_cauldron
}

### ALCHEMY

###END###
HAVE_FUNCS_ALCHEMY=1
