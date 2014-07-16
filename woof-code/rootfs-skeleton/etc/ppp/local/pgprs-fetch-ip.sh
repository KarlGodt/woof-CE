#!/bin/sh

ACTIVE_INTERFACE=ppp0
tmpDIR=/tmp/net
logFILE="$tmpDIR"/ips.txt
ipDETECT_ADDRESS=icanhazip.com

sleep 5s

while test "`pidof pppd`"; do
read carRIER </sys/class/net/$ACTIVE_INTERFACE/carrier
test "$carRIER" = 1 && break
sleep 1s
done

rm -f "$tmpDIR"/wget.log
rm -f "$tmpDIR"/wget.out

mkdir -p "$tmpDIR"

date >> "$logFILE"
grep -i ip /var/log/messages >> "$logFILE"

wget -o "$tmpDIR"/wget.log -O "$tmpDIR"/wget.out $ipDETECT_ADDRESS
read IP <"$tmpDIR"/wget.out
echo "$IP" >> "$logFILE"

echo >> "$logFILE"

exit
