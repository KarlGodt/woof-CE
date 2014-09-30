#!/bin/bash

mkdir -p /root/YouTube/

#find /root/.mozilla -wholename "*/Cache/*" -mmin -1 -exec file {} \;
#VIDFILE=`find /root/.mozilla -wholename "*/Cache/*" -amin -1 -exec file {} \; | grep -i video`
VIDFILE=`find /root/.mozilla -type f -wholename "*/Cache/*" -mmin -1 -exec file {} \; |grep -E -i -w 'video|mpeg|iso media' |grep -vE 'compressed'`
echo "$VIDFILE"
TMP_VIDFILE=`find /tmp/ -type f -mmin -1 -exec file {} \; |grep -E -i -w 'video|mpeg|iso media' |grep -vE 'compressed' |grep -vE 'compressed'`
echo "$TMP_VIDFILE"
# example /root/.mozilla/firefox/47p0emkb.default/Cache/7B340547d01: Macromedia Flash Video
videofile=`echo "$VIDFILE" |cut -f 1 -d ':'`
tmp_videofile=`echo "$TMP_VIDFILE" |cut -f 1 -d ':'`
echo '--'

save_loop(){

basef=`basename "$1"`
if [ -e /root/YouTube/"$basef" ];then
mv /root/YouTube/"$basef" /root/YouTube/"$basef"-"`date +%F-%T`"
fi

SIZE0='';SIZE=''
while [ -e "$1" ];do

if [ "$SIZE" ];then
SIZE0=`ls -s "$1"`
if [ "$SIZE" = "$SIZE0" ]; then
echo "finished downloading of
'$1'
at SIZE of
'$SIZE'"
break
fi;fi

cp -a "$1" /root/YouTube/
#sleep 0.1s
sleep 2s
#sleep 12s
sync
SIZE=`ls -s "$1"`
echo "$SIZE"
sleep 4s
done
sync

}

if [ "$videofile" -o "$tmp_videofile" ];then
echo "found
$videofile

$tmp_videofile"

CNT=`echo $videofile $tmp_videofile |wc -w`
CNT_FORK=$((CNT-1))
c=0
for i in $videofile $tmp_videofile;do
c=$((c+1))
if [ "$c" -lt $CNT ];then
save_loop "$i" &
fpid=$!;echo function_pid=$fpid
FPIDS="$FPIDS $fpid"
else
save_loop "$i"
fi

done

#while [ "`pidof save_loop`" ];do
#sleep 5s
#done

else
echo "ERROR , could not determine a video file for the last minute"
fi

sleep 55s
exec $0
