#!/bin/sh

ACTIVE_INTERFACE=ppp0
tmpDIR=/tmp/net
logFILE="$tmpDIR"/ips.txt
ipDETECT_ADDRESS=icanhazip.com

sleep 5s

while test "`pidof pppd`"; do
sleep 1s
[ -e /sys/class/net/$ACTIVE_INTERFACE/carrier ] && read carRIER </sys/class/net/$ACTIVE_INTERFACE/carrier 2>/dev/null
test "$carRIER" = 1 && break
#sleep 1s
done

rm -f "$tmpDIR"/wget.log
rm -f "$tmpDIR"/wget.out

mkdir -p "$tmpDIR"

date >> "$logFILE"
[ -s /var/log/messages ] && grep -i ip /var/log/messages >> "$logFILE"

wget -o "$tmpDIR"/wget.log -O "$tmpDIR"/wget.out $ipDETECT_ADDRESS
[ -s "$tmpDIR"/wget.log ] && read IP <"$tmpDIR"/wget.out
[ "$IP" ] && echo "$IP" >> "$logFILE" || echo "Could not get IP" >> "$logFILE"

echo >> "$logFILE"

exit
