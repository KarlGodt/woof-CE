#!/bin/sh
#v3.99 fix from bde, was not remembering setup at next boot.
#v411 fix path.

INTERFACE=${1}
WEP_DRIVER=${2}
# Dougal: add support for WPA2
WPA_TYPE=$3

echo -e "\nAcquiring WPA$WPA_TYPE connection for ${INTERFACE}... (press Enter to cancel)" > /dev/console
echo -e "\nAcquiring WPA$WPA_TYPE connection for ${INTERFACE}... (press Enter to cancel)"


# If there are supplicant processes for the current interface, kill them
[ -e /var/run/wpa_supplicant/${INTERFACE} ] && rm /var/run/wpa_supplicant/${INTERFACE}
SUPPLICANT_PIDS=$( ps -e | grep -v "grep" | grep -E "wpa_supplicant.+${INTERFACE}" | grep -oE "^ *[0-9]+")
for SUPPLICANT_PID in ${SUPPLICANT_PIDS} ; do
	kill ${SUPPLICANT_PID}
done

sleep 5

#v3.99 fix path /usr/bin to /usr/sbin ...well, just remove it... v411...
wpa_supplicant -i ${INTERFACE} -D ${WEP_DRIVER} -c /usr/local/net_setup/etc/wpa_supplicant$WPA_TYPE.conf -B

COUNT=0
MAX_COUNT=12
DELAY=5

while [ "${COUNT}" != "${MAX_COUNT}" ] ; do  
	let COUNT=COUNT+1
	echo -n "." > /dev/console
	echo -n "."
	#v3.99 remove path...
	WPA_STATUS=`wpa_cli status | grep "wpa_state" | cut -d"=" -f2`
	if [ "${WPA_STATUS}" == "COMPLETED" ] ; then
		COUNT=${MAX_COUNT}
	else
		read -t ${DELAY} a
		[ $? -eq 0 ] &&	COUNT=${MAX_COUNT}
	fi
done

echo ""
