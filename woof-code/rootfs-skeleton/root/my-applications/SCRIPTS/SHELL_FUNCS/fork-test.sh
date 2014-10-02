#!/bin/bash








echo "$0 START
TTY=`tty`
PS_PERSONALITY='$PS_PERSONALITY'"
unset PS_PERSONALITY
echo "PS_PERSONALITY='$PS_PERSONALITY'
ps -f:"
ps -f
sleep 3s
$0 &
sleep 3s
echo "$0 END"

