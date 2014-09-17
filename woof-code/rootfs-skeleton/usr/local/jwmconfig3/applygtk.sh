#!/bin/bash

PRO="applygtk.sh"
SCRIPT_DIR="/usr/local/jwmconfig3"
. "$SCRIPT_DIR/path"
. /etc/rc.d/f4puppy5

GTKTHEME=`fgrep 'include' $HOME/.gtkrc-2.0 | fgrep '/usr/share/themes/' | grep -v '^#' | fgrep -m1 'gtkrc' | tr -d "'" | tr -d '"' | sed 's/include //' | tr -d '\t' | tr -d ' '`
# [ ! -e $GTKTHEME ] && exit 1
GtkTheme="`echo $GTKTHEME | cut -f 5 -d /`"
echo $DBG 11 $GtkTheme
##------get relevant gtk colours-------->>
MENU_BG=`grep -v "^#" $GTKTHEME | grep -m1 '\Wbg\[NORMAL\]' | cut -d'"' -f2`
ACTIVE_BG=`grep -v "^#" $GTKTHEME | grep -m1 '\Wbg\[SELECTED\]' | cut -d'"' -f2`
FOREGROUND=`grep -v "^#" $GTKTHEME | grep -m1 '\Wfg\[NORMAL\]' | cut -d'"' -f2`
PAGER_BG=`grep -v "^#" $GTKTHEME | grep -m1 '\Wbg\[ACTIVE\]' | cut -d'"' -f2`
FG_SELECTED=`grep -v "^#" $GTKTHEME | grep -m1 '\Wfg\[SELECTED\]' | cut -d'"' -f2`
#if [ -z "$MENU_BG" ] || [ -z "$ACTIVE_BG" ] || [ -z "$FOREGROUND" ] || [ -z "$PAGER_BG" ] || [ -z "$FG_SELECTED" ] || [ ! -e $GTKTHEME ] || [ "$GtkTheme" = "Raleigh" ]; then
if [ "$GtkTheme" = "Raleigh" ]; then

#if [ -z "$MENU_BG" ]; then
#if [ -f $JWMCBAK ]; then
# cp -f $JWMCBAK $JWMCOLO ; fi
Xdialog --title "Err...." --msgbox "What the heck ?\n\n
something went wrong ... \n
Theme $GtkTheme seems to be missing something. \n
please look into ~/.gtkrc , ~/.jwm/ and \n
$GTKTHEME files ...\n
Or try to adjust $HOME/.jwm/jwmrc-color manually.\n" 0 0
# pidof jwm >/dev/null && jwm -restart
 exit 2
else
#save them...
echo '#This is written to by /usr/local/jwmconfig3/applygtk.sh script' > "$colorFILE"
echo "MENU_BG='${MENU_BG}'" >> "$colorFILE"
echo "ACTIVE_BG='${ACTIVE_BG}'" >> "$colorFILE"
echo "FOREGROUND='${FOREGROUND}'" >> "$colorFILE"
echo "PAGER_BG='${PAGER_BG}'" >> "$colorFILE"
echo "FG_SELECTED='${FG_SELECTED}'" >> "$colorFILE"
. "$SCRIPT_DIR/func" -gradientcolors

. "$SCRIPT_DIR/func" -themedef

echo "$ThemeDef" > "$themeFILE"

#########
#John Doe created code for the applet backgrounds, old jwmconfig, port here...
. "$SCRIPT_DIR/func" -trayapply
#end John Doe's code.
########

sync
pidof jwm >$OUT && jwm -restart
fi
exit 0
# Very End of this file 'usr/local/jwmconfig3/applygtk.sh' #
###END###
