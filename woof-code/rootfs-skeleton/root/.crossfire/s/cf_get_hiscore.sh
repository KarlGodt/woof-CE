#!/bin/bash

# 2018-03-07
# cf_get_hiscore.sh :
# script to get hiscores from server
# and save to a file in /tmp

VERSION=0.0 # Initial version,

# Log file path in /tmp
MY_SELF=`realpath "$0"` ## needs to be in main script
MY_BASE=${MY_SELF##*/}  ## needs to be in main script
MY_DIR=${MY_SELF%/*}

DEBUG=1
MSGLEVEL=7
LOGGING=1

. $MY_DIR/cf_funcs_common.sh   ||  { echo draw 3 "$MY_DIR/cf_funcs_common.sh failed to load."; exit 4; }

_set_global_variables "$@"

_check_if_already_running_ps || _exit 1 "Already running."

test "$*" && PARM="$*" || PARM=$$

rm -f /tmp/cf_hiscore_list_"$PARM".lst


_watch drawinfo

_is 1 1 hiscore "$@"
_sleep
#_watch ${DRAWINFO:-drawextinfo}
#echo watch

while :; do
unset REPLY
read -t ${TMOUT:-1}
echo "$REPLY" >> /tmp/cf_hiscore_list_"$PARM".lst

test "$REPLY" || break

#cnt=$((cnt+1))
#test $cnt -gt 100 && break

sleep 0.001
done
#_unwatch ${DRAWINFO:-drawinfo}
echo unwatch
