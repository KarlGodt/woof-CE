#!/bin/bash

mkdir -p /root/YouTube/

#find /root/.mozilla -wholename "*/Cache/*" -mmin -1 -exec file {} \;
#VIDFILE=`find /root/.mozilla -wholename "*/Cache/*" -amin -1 -exec file {} \; | grep -i video`
VIDFILE=`find /root/.mozilla -wholename "*/Cache/*" -mmin -5 -exec file {} \; | grep -E -i 'video|mpeg|iso media|Macromedia|Flash' | grep -viE 'sequence|compressed'`
DIRS=`find /root/.mozilla -wholename "*/Cache/*" -type d`
echo "$VIDFILE"
# example /root/.mozilla/firefox/47p0emkb.default/Cache/7B340547d01: Macromedia Flash Video
videofile=`echo "$VIDFILE" |cut -f 1 -d ':'`
echo '--'

save_loop(){

#[ -e /root/YouTube/"`basename $1`" ] && mv /root/YouTube/"${1##*/}" /root/YouTube/"${1##*/}"-"`date +%F+%T`"
[ -e /root/YouTube/"${1##*/}" ] && mv /root/YouTube/"${1##*/}" /root/YouTube/"${1##*/}"-"`date +%F+%T`"

SIZE0='';SIZE1=''
while [ -e "$1" ];do

if [ "$SIZE1" ];then
SIZE0=`ls -s "$1"`
if [ "$SIZE1" = "$SIZE0" ]; then
echo "finished downloading of
'$1'
at SIZE of
'$SIZE1'"
break
fi;fi

cp -a "$1" /root/YouTube/
sleep 2s
sync
SIZE1=`ls -s "$1"`
sleep 2s
done

sync
echo "'$1' renamed"
mv /root/YouTube/"${1##*/}" /root/YouTube/"${1##*/}"-"`date +%F-%T`"
[ "$?" =0 ] && echo "'${1##*/}' renamed with time apended"
return $?
}

if [ "$videofile" ];then
echo "found '$videofile'"

for i in $videofile;do
save_loop "$i" &
done

else
echo "Could not determine a video file for the last 5 minutes
in /root/.mozilla/*/Cache/*
"
#Trying /tmp directory ..."
fi

#OPERA
VIDFILE=`find /root/.opera -wholename "*/cache/*" -mmin -5 -exec file {} \; | grep -E -i 'video|mpeg|iso media|Macromedia|Flash' |grep -viE 'sequence|compressed'`
DIRS=`find /root/.opera -wholename "*/cache/*" -type d`
echo "$VIDFILE"
videofile=`echo "$VIDFILE" |cut -f 1 -d ':'`
echo '--'

if [ "$videofile" ];then
echo "found '$videofile'"

for i in $videofile;do
save_loop "$i" &
done

else
echo "Could not determine a video file for the last 5 minutes
in /root/.opera/*/cache/*
"
#Trying /tmp directory ..."
fi

#Trying /tmp directory ..."
#find /tmp -type f -mmin -1 -exec file {} \;
VIDFILE=`find /tmp -type f -mmin -1 -exec file {} \; | grep -E -i 'video|mpeg|iso media|Macromedia|Flash' | grep -vE 'sequence|compressed'`
echo "$VIDFILE"
# example /root/.mozilla/firefox/47p0emkb.default/Cache/7B340547d01: Macromedia Flash Video
videofile=`echo "$VIDFILE" |cut -f 1 -d ':'`
echo '--'

if [ "$videofile" ];then
echo "found '$videofile'"

for i in $videofile;do
save_loop "$i" &
done

else
echo "Could not determine a video file for the last minute
in /tmp directory ..."

fi

mkdir -p /root/FF_Cache
F=`find /root/.mozilla/firefox/b7ov9xpo.default/Cache -type f`
for i in $F;do cp -a $i /root/FF_Cache/;done

#find /root/FF_Cache -exec file {} \;
VIDFILE=`find /root/FF_Cache -exec file {} \; | grep -E -i 'video|mpeg|iso media|Macromedia|Flash' | grep -vE 'sequence|compressed'`

echo "$VIDFILE"
# example /root/.mozilla/firefox/47p0emkb.default/Cache/7B340547d01: Macromedia Flash Video
videofile=`echo "$VIDFILE" |cut -f 1 -d ':'`
echo '--'

if [ "$videofile" ];then
echo "found '$videofile'"

for i in $videofile;do
save_loop "$i" &
done

else
echo "Could not determine a video file
in /root/FF_Cache/"

fi

remove(){
#waiting ...
for i in {1..10};do echo -n '.';sleep 2s;done;echo
rm -rf /root/FF_Cache/*
for i in $DIRS;do rmdir $i 2>/dev/null;done
}
remove &
