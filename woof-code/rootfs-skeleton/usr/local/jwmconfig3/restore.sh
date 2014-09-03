#!/bin/bash
# Simple apply a Backup File
# November 2010
# KRG

PRO="restore.sh"
echo $$
SCRIPT_DIR="/usr/local/jwmconfig3"
. "$SCRIPT_DIR/path"
. /etc/rc.d/f4puppy5

echo $DBG 12

##---backup--->
cp -f "$colorFILEbak" "$colorFILEbak.0"
cp -f "$themeFILEbak" "$themeFILEbak.0"

cp -f "$colorFILEbak" "$colorFILE"
cp -f "$themeFILEbak" "$themeFILE"

# Patriot Sep 2009
  # Attempting some robustness
  # Update only for known -bg option applets: blinky and xload

  . "$colorFILE" #Get MENU_BG, PAGER_BG

  . "$SCRIPT_DIR/func" -trayapply2

  sync

  pidof jwm >$OUT && jwm -restart

###END###
