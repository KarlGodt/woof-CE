#!/bin/ash
. /etc/DISTRO_SPECS
. /etc/rc.d/PUPSTATE
. /etc/rc.d/f4puppy5

DEBUG=1

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


_debug  "rtc_time='$rtc_time'"
_debug "alrm_time='$alrm_time'"
_debug  "rtc_date='$rtc_date'"
_debug "alrm_date='$alrm_date'"

#cat /proc/driver/rtc
#rtc_time	: 16:36:59
#rtc_date	: 2015-11-09
#alrm_time	: 10:44:36
#alrm_date	: ****-**-**

case $rtc_time  in *[0-9]*):;; *) unset  rtc_time;;esac
case $rtc_date  in *[0-9]*):;; *) unset  rtc_date;;esac
case $alrm_time in *[0-9]*):;; *) unset alrm_time;;esac
case $alrm_date in *[0-9]*):;; *) unset alrm_date;;esac

_debug  "rtc_time='$rtc_time'"
_debug "alrm_time='$alrm_time'"
_debug  "rtc_date='$rtc_date'"
_debug "alrm_date='$alrm_date'"


if test "$alrm_date" -a "$alrm_time"
then
:
 _notice "$0:$*:$@: Wakealarm is set"
else
 _info "$0:$*:$@: Wakealarm is not set"
 exit 0
fi



curr_h=${rtc_time%%:*}
curr_h=${curr_h#*0}
test "$curr_h" || curr_h=24

_debug "curr_h='$curr_h'"

curr_m=${rtc_time%:*}
curr_m=${curr_m#*:}
curr_m=${curr_m#*0}
test "$curr_m" || curr_m=60

_debug  "curr_m='$curr_m'"

alrm_h=${alrm_time%%:*}
alrm_h=${alrm_h#*0}
test "$alrm_h" || alrm_h=24

_debug "alrm_h='$alrm_h'"

alrm_m=${alrm_time%:*}
 _debug "alrm_m='$alrm_m'"
alrm_m=${alrm_m#*:}
 _debug "alrm_m='$alrm_m'"
alrm_m=${alrm_m#*0}
 _debug "alrm_m='$alrm_m'"
test "$alrm_m" || alrm_m=60

_debug "alrm_m='$alrm_m'"

if test "$rtc_date" = "$alrm_date"
then
 :
 _info "$0:$*:$@: date is same"
elif test "$rtc_date" = $((alrm_date + 1)) && test "$alrm_m" = 59 -o "$alrm_h" = 23
then
 :

else
 _info "$0:$*:$@: date differs"
 exit 0
fi

if test "$curr_h" = "$alrm_h" || test "$curr_h" = $((alrm_h+1)) -a "$alrm_m" = 59
then
 m_diff=$(( curr_m - alrm_m ))
 _debug "m_diff='$m_diff'"

   case $m_diff in
   -*) _notice "$0:$*:$@: Apparently less than one minute ago"; exit 2;;
   0|1) test -x /etc/acpi/wakealarm/wakealarm_cmd && exec /etc/acpi/wakealarm/wakealarm_cmd;;
   *)  _notice "$0:$*:$@: Apparently more than one minute ago"; exit 1;;
   esac
fi

