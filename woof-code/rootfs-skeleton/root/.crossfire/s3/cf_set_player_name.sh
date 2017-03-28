#!/bin/sh

test "$*" || {
	echo draw 3 "Need Player Name as parameter."
	exit 1
}


# *** PARAMETERS *** #

MY_SELF=`realpath "$0"`
MY_BASE=${MY_SELF##*/}
test -f "${MY_SELF%/*}"/cf_functions.sh   && . "${MY_SELF%/*}"/cf_functions.sh
_set_global_variables "$@"
# *** Override any VARIABLES in cf_functions.sh *** #
test -f "${MY_SELF%/*}"/"${MY_BASE}".conf && . "${MY_SELF%/*}"/"${MY_BASE}".conf

#_get_player_name && {
#test -f "${MY_SELF%/*}"/"${MY_NAME}".conf && . "${MY_SELF%/*}"/"${MY_NAME}".conf
#}

# *** Here begins program *** #
_say_start_msg "$@"

MY_NAME="$*"
test -f "${MY_SELF%/*}"/"${MY_NAME}".conf || echo '#' "${MY_NAME}'s config file" >"${MY_SELF%/*}"/"${MY_NAME}".conf

#test -s "${MY_SELF%/*}"/player_name.$PPID || echo "$MY_NAME" >"${MY_SELF%/*}"/player_name.$PPID

# In case the client stays online and player changes by play again and choose another player
#rm -f "${MY_SELF%/*}"/player_name.$PPID
#echo "$MY_NAME" >"${MY_SELF%/*}"/player_name.$PPID

rm -f "$TMP_DIR"/player_name.$PPID
echo "$MY_NAME" >"$TMP_DIR"/player_name.$PPID

# *** Here ends program *** #
_say_end_msg
