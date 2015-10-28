#!/bin/ash

PRO="loadDefault.sh"
SCRIPT_DIR="/usr/local/jwmconfig3"
test -f "$SCRIPT_DIR/variables" && . "$SCRIPT_DIR/variables"
. /etc/rc.d/f4puppy5

. "$colorFILEdef"

if [ -z "$MENU_BG" ]; then
 pidof jwm >$OUT && jwm -restart
 exit 2
else

. "$SCRIPT_DIR/func" -gradientcolors

. "$SCRIPT_DIR/func" -themedef

fi

echo "$DefTheme" > "$themeFILE"

#########
#John Doe created code for the applet backgrounds, old jwmconfig, port here...
. "$SCRIPT_DIR/func" -trayapply
#end John Doe's code.
########

pidof sync >$OUT || sync
pidof jwm  >$OUT && jwm -restart
# Very End of this file 'usr/local/jwmconfig3/loadDefault.sh' #
###END###
