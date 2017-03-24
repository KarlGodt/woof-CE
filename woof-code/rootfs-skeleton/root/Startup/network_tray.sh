#!/bin/ash

. /etc/rc.d/f4puppy5
. /etc/rc.d/PUPSTATE
. /etc/DISTRO_SPECS

#[ "`which network_tray`" ] || exit 0
test -e "$HOME"/Startup/bin/network_tray || { echo "$HOME/Startup/bin/network_tray does not exist" >&2; exit 0; }
test -x "$HOME"/Startup/bin/network_tray || { echo "$HOME/Startup/bin/network_tray not executable" >&2; exit 0; }

DISP=${DISPLAY%.*}
tTTY=${DISP#*:}
tTTY=$((tTTY+1))

(
echo DISP=$DISP
echo tTTY=$tTTY
) >&2

CHK_RUN=`busybox ps -o tty,args | grep network_tray | grep -E "^4|^136" | grep "^[0-9]\+,$tTTY[[:blank:]]\+" | grep -vE 'grep|\.sh'`
test "$CHK_RUN" && { echo "network_tray already running on display '$DISP' : '$CHK_RUN'" >&2; exit 0; }
exec "$HOME"/Startup/bin/network_tray &
