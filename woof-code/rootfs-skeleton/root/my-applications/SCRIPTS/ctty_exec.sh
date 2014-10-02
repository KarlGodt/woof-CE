#!/bin/bash








exec 1>>/tmp/ctty.log 2>&1

#busybox cttyhack $0
tty
echo
echo "`df`"
echo

if [ "`tty`" = 'not a tty' ];then
exec busybox cttyhack /root/my-applications/SCRIPTS/ctty.sh
fi
