pfix=`cat /proc/cmdline |grep -o 'pfix=.* |cut -f 1 -d ' '`
params=`echo "$pfix" |sed 's/pfix=//' |tr ',' ' '`
for param in $params;do
case $param in
nosound)echo "NOSOUND='yes'" >>/etc/rc.d/PUPSTATE ;;
novideo)echo "NOVIVEO='yes'" >>/etc/rc.d/PUPSTATE ;;
esac

[ "$NOSOUND" = 'yes' -a "`echo "$MODULE" |grep -E '^snd|^sound'`" ] && exit $BECAUSE_NOSOUND
videodrivers=` modprobe -l | grep 'drm'`
videodrivers=` echo "$videodrivers" |cut -f1 -d'.'|rev|cut -f1 -d'/'|rev`
[ "$NOVIDEO" = 'yes' -a "`echo "$videodrivers" |grep "$MODULE"`" ] && exit $BECAUSE_NOVIDEO


#!/bin/sh

#Personal Sound script
# ie to unload modules by the rmmod or modprobe -v commands
# or to load modules by the modprobe [-v] command
# see " [p]man modprobe " for more details .
#It is als advised to run /usr/sbin/bootmanager
# from the System Menu , to force the loading of modules .

#Don't forget to add a line with /etc/init.d/[##_]alsa [start|stop].
#In case on no sound modules loaded,
#the sound applet in the tray (/usr/[local/]bin/retrovol) tends to exit .
#Of course, you can run alsawizard ,too .

ALSACONFFILES="/etc/modprobe.d/alsa-base.conf /etc/modprobe.d/alsa.conf"
snd_order_func(){
if [ "`echo "$MODULE" |grep -E '^snd'`" ] ;then
listed_soundcards=`grep -e '^alias snd\-card\-[0-9]*' $ALSACONFFILES | awk '{print $2" "$3}' |sort -u`
[ "$listed_soundcards" ] || return 0
snd_card_nrs=`echo "$listed_soundcards" |awk '{print $1}' |cut -f3 -d'-'`
current_nr=`echo "$listed_soundcards" | grep "${MODULE//_/-}" |awk '{print $1}' |cut -f3 -d'-'`
already_loaded=`lsmod |grep '^snd_' |awk '{print $1}'`

#if [ ! "$already_loaded" -a "$current_nr" = '0' ];then
#return 0 #go on,load module
#else #wait for
#until [ "`lsmod | grep '^snd'`" ];do sleep 1s;done
#fi
#[ "$current_nr" = '1' ] && return

#c=0
for n in $snd_card_nrs;do
#c=$((c+1))
soundcard=`echo "$listed_soundcards" | grep -o "\-$n .*" |awk '{print $2}' |head -n 1`
if [ "${soundcard//-/_}" = "$MODULE" -a "$n" = '0' ];then return 0;fi #first module
#if [ "${soundcard//-/_}" = "$MODULE" -a ! "`lsmod | grep "${soundcard//-/_}"`" ];then
c=$((n-1));h=$((h+1))
#for zzz in {0..$c};do
for zzz in `seq 1 1 $n`;do
temp_soundcard=`echo "$listed_soundcards" | grep -o "\-$zzz .*" |awk '{print $2}' |head -n 1`
until [ "`lsmod | grep "${temp_soundcard//-/_}"`" ];do sleep 1s;done
pattern=`echo "$listed_soundcards" |head -n $h`
included=`echo "$pattern" | grep "$MODULE"`
#1 must be included
[ "$included" ] && return
done
done
fi
}








