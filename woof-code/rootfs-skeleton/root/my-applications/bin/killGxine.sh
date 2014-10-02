#!/bin/sh
###
####So 16. Okt 10:48:14 GMT-1 2011
###

programName='killGxine.sh'

psCommand='ps' ; psFlag='simple'
[ "`readlink -e $(which ps) | grep 'busybox'`" != "" ] && psCommand='busybox ps' && psFlag='busybox'
[ -x `which ps-FULL` ] && psCommand='ps-FULL' && psFlag='full'

debug(){
echo "$0 mark='$1' $msg"
}

command(){
if [ "$psFlag" == 'simple' ] ; then

gxinePidsPs=`ps | grep 'gxine' | grep -v 'grep'`

:
elif [ "$psFlag" == 'busybox' ] ; then

gxinePidsPs=`busybox ps | grep 'gxine' | grep -v 'grep'`

:
elif [ "$psFlag" == 'full' ] ; then

gxinePidsPs=`ps-FULL | grep 'gxine' | grep -v 'grep'`

:
else

echo " error "
exit 9
:
fi
msg="$gxinePidsPs"
[ $dbg ] && debug 39
}

pidofGxines=`pidof gxine`
msg="$pidofGxines"
[ $dbg ] && debug 44


for n in `seq 0 66` ; do  #64 kill signals until now
echo $n ; sleep 1
for p in $pidofGxines ; do
echo $p
kill -$n $p
pidof gxine
done;done









