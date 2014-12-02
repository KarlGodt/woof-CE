#!/bin/sh
SCREENSAVERFLAG=$1
SCREENSAVERDELAY=$2
SCREENSAVERCYCLE=$3
SCREENSAVERBLANKING=$4
SCREENSAVEREXPOSURES=$5
SCREENSAVERDELAY=`echo -n $SCREENSAVERDELAY | cut -f 1 -d '.'`
SCREENSAVERCYCLE=`echo -n $SCREENSAVERCYCLE | cut -f 1 -d '.'`
if [ "$SCREENSAVERFLAG" = "false" ];then
 SCREENSAVERPARAMS="s off -dpms"
else
 [ "$SCREENSAVERBLANKING" = "false" ] && SCREENSAVERBLANKING=noblank
 [ "$SCREENSAVERBLANKING" = "true" ] && SCREENSAVERBLANKING=blank
 [ "$SCREENSAVEREXPOSURES" = "false" ] && SCREENSAVEREXPOSURES=noexpose
 [ "$SCREENSAVEREXPOSURES" = "true" ] && SCREENSAVEREXPOSURES=expose
 SCREENSAVERPARAMS="s $SCREENSAVERDELAY $SCREENSAVERCYCLE s $SCREENSAVERBLANKING s $SCREENSAVEREXPOSURES"
fi
xset $SCREENSAVERPARAMS
echo -n " $SCREENSAVERPARAMS"  >> /tmp/pupx/pupx_finalparams
[ $6 ] && exit
Xdialog --title "Screensaver settings" --msgbox "Screensaver parameters set to:\n${SCREENSAVERDELAY} ${SCREENSAVERCYCLE} ${SCREENSAVERBLANKING} ${SCREENSAVEREXPOSURES}\n(for this session only)" 0 0

###END###