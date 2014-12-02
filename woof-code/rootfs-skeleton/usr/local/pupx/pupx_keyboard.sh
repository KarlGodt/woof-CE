#!/bin/sh

# REM: Pos Parameters passed : up to 5
#      Please double quote vars passed to this script
#      Otherwise bogus empty vars would confuse the order

. /etc/rc.d/f4puppy5
_debug "$@: '$1' '$2' '$3' '$4' '$5'"
[ "$6" ] && _warn "Ignoring \$6='$6'"

KEYBOARDVOL=$1
KEYBOARDAUTO=$2
KEYBOARDDELAY=$3
KEYBOARDRATE=$4

# REM: Make sure they have content ..
[ "$KEYBOARDVOL" ]   || KEYBOARDVOL=0
[ "$KEYBOARDAUTO" ]  || KEYBOARDAUTO=false
[ "$KEYBOARDDELAY" ] || KEYBOARDDELAY=330
[ "$KEYBOARDRATE" ]  || KEYBOARDRATE=40

KEYBOARDDELAY=`echo -n $KEYBOARDDELAY | cut -f 1 -d '.'`
KEYBOARDRATE=`echo -n $KEYBOARDRATE | cut -f 1 -d '.'`
[ $KEYBOARDVOL -eq 0 ] && KEYBOARDVOL=off

if [ "$KEYBOARDAUTO" = "false" ];then
 KEYBOARDPARAMS="off"
else
 KEYBOARDPARAMS="rate $KEYBOARDDELAY $KEYBOARDRATE"
fi

xset c $KEYBOARDVOL r $KEYBOARDPARAMS
[ "$?" = 0 ] || false ##TODO: error message to user and further handling
echo -n " c $KEYBOARDVOL r $KEYBOARDPARAMS"  >> /usr/local/pupx/pupx_finalparams

[ $5 ] && exit
Xdialog --title "Keyboard settings" --msgbox "Keyclick volume set to ${KEYBOARDVOL}\nAuto-repeat set to ${KEYBOARDPARAMS}\n(for this session only)" 0 0

###END###
