#!/bin/ash
# Simple apply a Backup File
# November 2010
# KRG

PRO="restore.sh"
echo $$
SCRIPT_DIR="/usr/local/jwmconfig3"
test -f "$SCRIPT_DIR/variables" && . "$SCRIPT_DIR/variables"
. /etc/rc.d/f4puppy5

echo $DBG 12

##---backup--->
cp $VERB -f "$colorFILEbak" "$colorFILEbak.0"
cp $VERB -f "$themeFILEbak" "$themeFILEbak.0"

cp $VERB -f "$colorFILEbak" "$colorFILE"
cp $VERB -f "$themeFILEbak" "$themeFILE"

# Patriot Sep 2009
  # Attempting some robustness
  # Update only for known -bg option applets: blinky and xload

  . "$colorFILE" #Get MENU_BG, PAGER_BG

  . "$SCRIPT_DIR/func" -trayapply2

  pidof sync >$OUT || sync

  pidof jwm >$OUT  && jwm -restart

###END###
