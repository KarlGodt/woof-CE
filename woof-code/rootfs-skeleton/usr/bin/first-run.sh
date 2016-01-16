#!/bin/sh
STARTUPSCRIPT=/root/Startup/fullstart
PS=$(ps)
echo "$PS" | grep -qw "sh[ ].*$STARTUPSCRIPT" && exit 
[ -s /tmp/firstrun ] && exit
sh "$STARTUPSCRIPT"
chmod -x "$STARTUPSCRIPT"