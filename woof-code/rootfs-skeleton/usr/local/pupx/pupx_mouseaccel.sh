#!/bin/sh

# REM: Pos Parameters passed : up to 3
#      Please double quote vars passed to this script
#      Otherwise bogus empty vars would confuse the order

. /etc/rc.d/f4puppy5
_debug "$@: '$1' '$2' '$3'"
[ "$4" ] && _warn "Ignoring \$4='$4'"

__old_code__(){
MOUSEACCX10=`dc ${1} 10 mul p`
xset m ${MOUSEACCX10}/10 ${2}
echo -n "m ${MOUSEACCX10}/10 ${2}" >> /usr/local/pupx/pupx_finalparams
}

MAXXL="$1"
MTRSH="$2"

# REM: Make sure they have content ..
[ "$MAXXL" ] || MAXXL=2
[ "$MTRSH" ] || MTRSH=4

MOUSEACCX10=`dc ${MAXXL} 10 mul p`
xset m ${MOUSEACCX10}/10 ${MTRSH}
[ "$?" = 0 ] || false ##TODO: error message to user and further handling
echo -n "m ${MOUSEACCX10}/10 ${MTRSH}" >> /usr/local/pupx/pupx_finalparams

[ $3 ] && exit
Xdialog --title "Mouse settings" --msgbox "Mouse acceleration set to ${1}\nMouse threshold set to ${2}\n(for this session only)" 0 0

###END###
