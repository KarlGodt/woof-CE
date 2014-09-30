#!/bin/sh
###
####So 16. Okt 10:48:14 GMT-1 2011
###

programName='killGxine.sh'

dgb=;
for i in $@ ;do
case $i in
d)dbg=1;;
esac
shift
done

if [ ! "`pidof gxine`" ];then
echo "gxine not running";exit 0;fi

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
[ $dbg ] && debug 47
}

pidofGxines=`pidof gxine`
msg="$pidofGxines"
[ $dbg ] && debug 52

for i in `seq 1 1 99`;do
echo -ne "\r$i "
kill -$i $pidofGxines
if [ "$?" != '0' ]; then break;fi
sleep 2s
if [ ! "`pidof gxine`" ]; then break;fi
done

if [ ! "`pidof gxine`" ]; then
echo "killed gxine with $i"
exit 0
else
echo "Could not stop gxine"
exit 1
fi








