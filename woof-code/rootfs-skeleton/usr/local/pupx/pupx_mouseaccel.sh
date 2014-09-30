#!/bin/sh
MOUSEACCX10=`dc ${1} 10 mul p`
xset m ${MOUSEACCX10}/10 ${2}
echo -n "m ${MOUSEACCX10}/10 ${2}" >> /tmp/pupx/pupx_finalparams
[ $3 ] && exit
Xdialog --title "Mouse settings" --msgbox "Mouse acceleration set to ${1}\nMouse threshold set to ${2}\n(for this session only)" 0 0

###END###
