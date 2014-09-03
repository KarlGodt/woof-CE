#!/bin/bash
# Simple applying a Backup FiLe
# November 2010
# KRG
PRO="/restore.sh"
echo $$
SCRIPT_DIR="/usr/local/jwmconfig3"
. $SCRIPT_DIR/path
echo $DBG 8

##---backup--->
cp -f $ColorFileBak "$ColorFileBak.0"
cp -f $ThemeFileBak "$ThemeFileBak.0"

cp -f $ColorFileBak $ColorFile
cp -f $ThemeFileBak $ThemeFile

# Patriot Sep 2009
  # Attempting some robustness
  # Update only for known -bg option applets: blinky and xload

  . $ColorFile #Get MENU_BG, PAGER_BG
  
  . $SCRIPT_DIR/func -trayapply2
  

  sync
  
  pidof jwm >/dev/null && jwm -restart



###END###
