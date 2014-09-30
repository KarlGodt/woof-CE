#!/bin/sh
KEYBOARDVOL=$1
KEYBOARDAUTO=$2
KEYBOARDDELAY=$3
KEYBOARDRATE=$4
KEYBOARDDELAY=`echo -n $KEYBOARDDELAY | cut -f 1 -d '.'`
KEYBOARDRATE=`echo -n $KEYBOARDRATE | cut -f 1 -d '.'`
[ $KEYBOARDVOL -eq 0 ] && KEYBOARDVOL=off
if [ "$KEYBOARDAUTO" = "false" ];then
 KEYBOARDPARAMS="off"
else
 KEYBOARDPARAMS="rate $KEYBOARDDELAY $KEYBOARDRATE"
fi
xset c $KEYBOARDVOL r $KEYBOARDPARAMS
echo -n " c $KEYBOARDVOL r $KEYBOARDPARAMS"  >> /tmp/pupx/pupx_finalparams
[ $5 ] && exit
Xdialog --title "Keyboard settings" --msgbox "Keyclick volume set to ${KEYBOARDVOL}\nAuto-repeat set to ${KEYBOARDPARAMS}\n(for this session only)" 0 0

###END###
