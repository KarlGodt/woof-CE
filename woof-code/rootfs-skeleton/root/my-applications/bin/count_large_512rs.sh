#!/bin/sh


[ "$C" ] || C=0

for i in {1..4};do
echo $((i*512+C));
mount -o loop,offset=$((i*512+C)) /mnt/sda9/tmp-1/raspi-sd-4gb-sap6-5.91.img /mnt/raspi-0
[ $? = 0 ] && { echo "Mounted with '$i*512+$C'";exit 0; }
done

read -t 2 -p "More ? [y|ALL=n] " mk
[ "$mk" ] || mk=y
echo
[ "$mk" = y ] && { C=$((C+2048)); C=$C $0; }
