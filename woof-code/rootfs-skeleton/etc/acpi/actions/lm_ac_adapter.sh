#! /bin/sh

/bin/logger -t "acpid:$0" -p 1 "Started"

test -f /usr/sbin/laptop_mode || exit 0

# ac on/offline event handler

/usr/sbin/laptop_mode auto

/bin/logger -t "acpid:$0" -p 1 "Ended"
