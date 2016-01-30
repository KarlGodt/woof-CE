#!/bin/ash

. /etc/rc.d/f4puppy5
. /etc/rc.d/PUPSTATE
. /etc/eventmanager.cfg

_savepuppy(){
  yaf-splash -font "8x16" -outline 0 -margin 4 -bg orange -placement top -text "Saving RAM to 'pup_save' file..." &
  YAFPID=$!
  pidof sync >>$OUT || sync
  nice -n 19 /usr/sbin/snapmergepuppy
  kill $YAFPID
}
_do_ramsaveinterval(){

while :; do
 SAVECNT=$((SAVECNT + 60))
 if [ "$SAVECNT" -ge "$RAMSAVEINTERVAL" ];then
  _savepuppy
  SAVECNT=0
 fi
sleep 60
done
}


case $1 in
start)

case $PUPMODE in
3|7|13)
   _debug "RAMSAVEINTERVAL='$RAMSAVEINTERVAL'"
   [ "$RAMSAVEINTERVAL" -gt 0 ] && _do_ramsaveinterval &
;;
esac
