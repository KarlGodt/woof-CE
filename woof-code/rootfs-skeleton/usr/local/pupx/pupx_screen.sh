#!/bin/sh

# REM: Pos Parameters passed : up to 6
#      Please double quote vars passed to this script
#      Otherwise bogus empty vars would confuse the order

. /etc/rc.d/f4puppy5
_debug "$@: '$1' '$2' '$3' '$4' '$5' '$6'"
[ "$7" ] && _warn "Ignoring \$7='$7'"

SCREENSAVERFLAG=$1
SCREENSAVERDELAY=$2
SCREENSAVERCYCLE=$3
SCREENSAVERBLANKING=$4
SCREENSAVEREXPOSURES=$5

# REM: Make sure they have content ..
[ "$SCREENSAVERFLAG" ]  || SCREENSAVERFLAG=false
[ "$SCREENSAVERDELAY" ] || SCREENSAVERDELAY=0
[ "$SCREENSAVERCYCLE" ] || SCREENSAVERCYCLE=0
[ "$SCREENSAVERBLANKING" ] || SCREENSAVERBLANKING=false
[ "$SCREENSAVEREXPOSURES" ] || SCREENSAVEREXPOSURES=false

# REM: any tenths??
SCREENSAVERDELAY=`echo -n $SCREENSAVERDELAY | cut -f 1 -d '.'`
SCREENSAVERCYCLE=`echo -n $SCREENSAVERCYCLE | cut -f 1 -d '.'`

# REM : dpms
if [ "$SCREENSAVERFLAG" = "false" ];then
 SCREENSAVERPARAMS="s off -dpms"
else
 [ "$SCREENSAVERBLANKING" = "false" ] && SCREENSAVERBLANKING=noblank
 [ "$SCREENSAVERBLANKING" = "true" ] && SCREENSAVERBLANKING=blank
 [ "$SCREENSAVEREXPOSURES" = "false" ] && SCREENSAVEREXPOSURES=noexpose
 [ "$SCREENSAVEREXPOSURES" = "true" ] && SCREENSAVEREXPOSURES=expose
 # REM: added +dpms
 SCREENSAVERPARAMS="s $SCREENSAVERDELAY $SCREENSAVERCYCLE s $SCREENSAVERBLANKING s $SCREENSAVEREXPOSURES +dpms"
fi

xset $SCREENSAVERPARAMS
[ "$?" = 0 ] || false ##TODO: error message to user and further handling
echo -n " $SCREENSAVERPARAMS"  >> /usr/local//pupx/pupx_finalparams

[ $6 ] && exit
Xdialog --title "Screensaver settings" --msgbox "Screensaver parameters set to:\n${SCREENSAVERDELAY} ${SCREENSAVERCYCLE} ${SCREENSAVERBLANKING} ${SCREENSAVEREXPOSURES}\n(for this session only)" 0 0

###END###
