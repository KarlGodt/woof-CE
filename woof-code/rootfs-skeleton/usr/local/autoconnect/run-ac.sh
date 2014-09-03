#!/bin/sh
cd /usr/local/autoconnect
#run standalone is supported.
rxvt -bg blue -geometry 50X8 -e ./autoconnect.sh scan_open_networks=yes ##use this argument to autoconnect to open networks also 
INTERFACE=`cat /tmp/AC_IF`
rxvt -bg green -geometry 43X5 -e ./AC_status.sh 
ifconfig $INTERFACE down



