#!/bin/bash

mkdir -p /root/YouTube/

find /root/.mozilla -wholename "*/Cache/*" -mmin -1 -exec file {} \;
#VIDFILE=`find /root/.mozilla -wholename "*/Cache/*" -amin -1 -exec file {} \; | grep -i video`
VIDFILE=`find /root/.mozilla -wholename "*/Cache/*" -mmin -1 -exec file {} \; | grep -E -i 'video|mpeg|iso media'`
echo "$VIDFILE"
# example /root/.mozilla/firefox/47p0emkb.default/Cache/7B340547d01: Macromedia Flash Video
videofile=`echo "$VIDFILE" |cut -f 1 -d ':'`
echo '--'

save_loop(){

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

if [ "$videofile" ];then
echo "found '$videofile'"

for i in $videofile;do
save_loop "$i" &
done

#while [ "`pidof save_loop`" ];do
#sleep 5s
#done

else
echo "ERROR , could not determine a video file for the last minute"
fi
