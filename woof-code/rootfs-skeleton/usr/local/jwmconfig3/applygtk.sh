#!/bin/bash
########################################################################
#
# Written or Changed by Karl Reimer Godt
#
#
#
# /dev/hda8:
# LABEL="MacPup431_O2"
# UUID="6d9a8e91-c301-4ff8-9875-97ec708cbee8"
# TYPE="ext3"
# DISTRO_NAME='Puppy'
# DISTRO_VERSION=431
# DISTRO_BINARY_COMPAT='puppy'
# DISTRO_FILE_PREFIX='pup'
# DISTRO_COMPAT_VERSION='4'
# PUPMODE=2
# KERNVER=2.6.37.4-KRG-i486-StagingDrivers-2
# PUP_HOME='/'
# SATADRIVES='·'
# USBDRIVES='·sda·'
# Linux·puppypc·2.6.37.4-KRG-i486-StagingDrivers-2·#4·SMP·Thu·Mar·17·06:05:58·GMT-8·2011·i686·GNU/Linux
# X·Window·System·Version·1.3.0
# Release·Date:·19·April·2007
# X·Protocol·Version·11,·Revision·0,·Release·1.3
# Build·Operating·System:·UNKNOWN·
# Current·Operating·System:·Linux·puppypc·2.6.37.4-KRG-i486-StagingDrivers-2·#4·SMP·Thu·Mar·17·06:05:58·GMT-8·2011·i686
# Build·Date:·28·November·2007
# $LANG=de_DE@euro
# today=So·30.·Okt·12:47:41·GMT+1·2011
#
#
#
#
#
########################################################################

PRO="/applygtk.sh"
SCRIPT_DIR="/usr/local/jwmconfig3"
. "$SCRIPT_DIR"/path


GTKTHEME=`fgrep 'include' "$hoMe"/.gtkrc-2.0 | fgrep '/usr/share/themes/' | grep -v '^#' | fgrep -m1 'gtkrc' | tr -d "'" | tr -d '"' | sed 's/include //' | tr -d '\t' | tr -d ' '`
# [ ! -e $GTKTHEME ] && exit 1 
GtkTheme="`echo "$GTKTHEME" | cut -f 5 -d /`"
THEME="$GTKTHEME"
Theme="$GtkTheme"
echo $DBG 12 GTKTHEME fgrep include $GTKTHEME
if [ -z "$GtkTheme" ]; then
XfceTheme=`grep 'gtk-theme-name=' "$hoMe"/.gtkrc-2.0 | cut -f 2 -d '"'`
echo $DBG 15 $XFCETHEME
XFCETHEME="/usr/share/themes/$XfceTheme/gtk-2.0/gtkrc"
THEME=$XFCETHEME
Theme=$XfceTheme
echo $DBG 19 $XFCETHEME
echo $THEME
echo $Theme
fi
##------get relevant gtk colours-------->>
MENU_BG=`grep -v "^#" "$THEME" | grep -m1 '\Wbg\[NORMAL\]' | cut -d'"' -f2`
ACTIVE_BG=`grep -v "^#" "$THEME" | grep -m1 '\Wbg\[SELECTED\]' | cut -d'"' -f2`
FOREGROUND=`grep -v "^#" "$THEME" | grep -m1 '\Wfg\[NORMAL\]' | cut -d'"' -f2`
PAGER_BG=`grep -v "^#" "$THEME" | grep -m1 '\Wbg\[ACTIVE\]' | cut -d'"' -f2`
FG_SELECTED=`grep -v "^#" "$THEME" | grep -m1 '\Wfg\[SELECTED\]' | cut -d'"' -f2`
if [ -z "$MENU_BG" ] || [ -z "$ACTIVE_BG" ] || [ -z "$FOREGROUND" ] || [ -z "$PAGER_BG" ] || [ -z "$FG_SELECTED" ] || [ -z "$THEME" ] || [ "$GtkTheme" = "Raleigh" ]; then 


#if [ -z "$MENU_BG" ]; then
#if [ -f $JWMCBAK ]; then
# cp -f $JWMCBAK $JWMCOLO ; fi
Xdialog --title "Err...." --msgbox "What the heck ?\n\n
something went wrong ... \n
Theme < $Theme > seems to be missing something. \n
The $DEFAULTTEXTEDITOR will show the following files : \n
please look into the $GtkrcFile , $ColorFile and \n
$THEME files ...\n
Or try to adjust the $HOME/.jwm/* files manually.\n" 0 0 
defaulttexteditor "$ColorFile" &
defaulttexteditor "$GtkrcFile" &
defaulttexteditor "$THEME" &
 exit 2
else 
#save them...
echo '#This is written to by /usr/local/jwmconfig3/applygt.sh script' > "$ColorFile"
echo "MENU_BG='${MENU_BG}'" >> "$ColorFile"
echo "ACTIVE_BG='${ACTIVE_BG}'" >> "$ColorFile"
echo "FOREGROUND='${FOREGROUND}'" >> "$ColorFile"
echo "PAGER_BG='${PAGER_BG}'" >> "$ColorFile"
echo "FG_SELECTED='${FG_SELECTED}'" >> "$ColorFile"
. "$SCRIPT_DIR"/func -gradientcolors
 
. "$SCRIPT_DIR"/func -themedef
  
echo "$DefTheme" > "$ThemeFile"

#########
#John Doe created code for the applet backgrounds, old jwmconfig, port here...
. "$SCRIPT_DIR"/func -trayapply 
#end John Doe's code.
########

sync
pidof jwm >/dev/null && jwm -restart
fi
exit 0
