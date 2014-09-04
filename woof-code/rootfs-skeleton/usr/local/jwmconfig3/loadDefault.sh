#!/bin/bash

PRO="loadDefault.sh"
SCRIPT_DIR="/usr/local/jwmconfig3"
. "$SCRIPT_DIR/path"
. /etc/rc.d/f4puppy5

. $colorFILEdef

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

sync
pidof jwm >$OUT && jwm -restart
