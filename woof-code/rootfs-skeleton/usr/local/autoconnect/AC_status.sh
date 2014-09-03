#!/bin/sh

# give feedback about connection quality etc.
INTERFACE=`cat /tmp/AC_IF`
if  ping -c 1 google.com | grep -q "bytes from" ; 
 	then while [ 0 ] ; do 
		 clear
		 NAME=`iwconfig $INTERFACE | grep 'ESSID' | cut -d\" -f2` 
		 	if [ "$NAME" -eq ""]; then #fix for buggy NIC drivers, eg rt73, orinoco ... etc.
		 	exec /tmp/wag-profiles_iwconfig.sh
		 	else
		 	echo "connected to $NAME "
		 	echo "Link Quality: `iwconfig $INTERFACE | grep 'Quality' | cut -d= -f2 | tr -d 'Signal level'`" 
		 	echo "IP: `ifconfig $INTERFACE | grep 'inet addr' | cut -d: -f2 | tr -d Bcast`"
		 	echo "closing this window will disconnect you."
		 	sleep 8
		 	fi
		 done	
 	else 
 	echo
 	echo "---> Not connected ! <---"
 	sleep 5 
 	exit 0 
fi

