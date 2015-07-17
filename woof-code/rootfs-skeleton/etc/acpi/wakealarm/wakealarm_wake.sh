#!/bin/ash
. /etc/DISTRO_SPECS
. /etc/rc.d/PUPSTATE
. /etc/rc.d/f4puppy5


#read KTIME </sys/class/rtc/rtc0/since_epoch

#sed -n '1p' /proc/driver/rtc | while read label col rtc_time; do :;done
#sed -n '2p' /proc/driver/rtc | while read label col rtc_date; do :;done
#sed -n '3p' /proc/driver/rtc | while read label col alrm_time; do :;done
#sed -n '4p' /proc/driver/rtc | while read label col alrm_date; do :;done

read label col rtc_time <<EoI
`sed -n '1p' /proc/driver/rtc`
EoI

read label col rtc_date <<EoI
`sed -n '2p' /proc/driver/rtc`
EoI

read label col alrm_time <<EoI
`sed -n '3p' /proc/driver/rtc`
EoI


read label col alrm_date <<EoI
`sed -n '4p' /proc/driver/rtc`
EoI


echo rtc_time=$rtc_time
echo alrm_time=$alrm_time
echo rtc_date=$rtc_date
echo alrm_date$alrm_date

if test $alrm_date -a $alrm_time
then
:
 echo "$0:$*:$@: Wakealarm is set"
else
 echo "$0:$*:$@: Wakealarm is not set"
 exit 0
fi



curr_h=${rtc_time%%:*}
curr_h=${curr_h#*0}
test $curr_h || curr_h=24

echo curr_h=$curr_h

curr_m=${rtc_time%:*}
curr_m=${curr_m#*:}
curr_m=${curr_m#*0}
test $curr_m || curr_m=60

echo  curr_m=$curr_m

alrm_h=${alrm_time%%:*}
alrm_h=${alrm_h#*0}
test $alrm_h || alrm_h=24

echo alrm_h=$alrm_h

alrm_m=${alrm_time%:*}
 echo alrm_m=$alrm_m
alrm_m=${alrm_m#*:}
 echo alrm_m=$alrm_m
alrm_m=${alrm_m#*0}
 echo alrm_m=$alrm_m
test $alrm_m || alrm_m=60

echo alrm_m=$alrm_m

if test $rtc_date = $alrm_date
then
 :
 echo "$0:$*:$@: date is same"
elif test $rtc_date = $((alrm_date + 1)) && test $alrm_m = 59 -o $alrm_h = 23
then
 :

else
 echo "$0:$*:$@: date differs"
 exit 0
fi

if test $curr_h = $alrm_h || test $curr_h = $((alrm_h+1)) -a $$alrm_m = 59
then
 m_diff=$(( curr_m - alrm_m ))
 echo m_diff=$m_diff

   case $m_diff in
   -*) echo "$0:$*:$@: Apparently less than one minute ago"; exit 2;;
   0|1) test -x /etc/acpi/wakealarm/wakealarm_cmd && exec /etc/acpi/wakealarm/wakealarm_cmd;;
   *)  echo "$0:$*:$@: Apparently more than one minute ago"; exit 1;;
   esac
fi











