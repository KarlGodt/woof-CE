#!/bin/sh
luvcview >/tmp/luvcview 2>&1
ERROR=`grep -iE 'error|exit fatal' /tmp/luvcview`
if [[ "$ERROR" != "" ]];then
 Xdialog  --msgbox "Luvcview has encountered an error. \n please ensure your webcam is connected \n and configured correctly" 0 0 0
 exit 1
fi

