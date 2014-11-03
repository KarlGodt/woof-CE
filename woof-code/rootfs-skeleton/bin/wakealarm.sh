#!/bin/ash


. /etc/rc.d/f4puppy5

#GLOBAL variables:
TITLE='-title ''Wakealarm'' ''GUI'

_info_gui(){
 test "$*" || set - "$0:_info_gui: No MESSAGE given!"

test "$DISPLAY" && {
xmessage "$*"
 true
 } || {
echo "$*"
 false
 }

 return $?
}

_do_exit_missing_prerequisite(){
_info_gui "$*"
exit
}

_test_fr /sys/class/rtc/rtc0/since_epoch || _do_exit_missing_prerequisite

read SINCE_EPOCH_CURRENT_KERNEL </sys/class/rtc/rtc0/since_epoch

SINCE_EPOCH_CURRENT_DATE=`LC_TIME=C date +%s`

if test "$SINCE_EPOCH_CURRENT_KERNEL" = "$TIME_CURRENT_DATE"; then
:
elif test "$SINCE_EPOCH_CURRENT_KERNEL" = "$((SINCE_EPOCH_CURRENT_DATE+1))"; then
:
elif test "$SINCE_EPOCH_CURRENT_KERNEL" = "$((SINCE_EPOCH_CURRENT_DATE-1))"; then
:
else

SINCE_EPOCH_CURRENT_DIFFERENCE=$((SINCE_EPOCH_CURRENT_DATE-SINCE_EPOCH_CURRENT_KERNEL))

fi

read KERNEL_DATE </sys/class/rtc/rtc0/date
read KERNEL_TIME </sys/class/rtc/rtc0/time

KERNEL_YEAR=${KERNEL_DATE%%-*}
KERNEL_MONTH=`echo $KERNEL_DATE | cut -f2 -d'-'`
KERNEL_DAY=${KERNEL_DATE##*-}

KERNEL_HOUR=${KERNEL_TIME%%:*}
KERNEL_MINUTE=`echo $KERNEL_TIME | cut -f2 -d':'`
KERNEL_SECOND=${KERNEL_TIME##*:}

echo $KERNEL_DATE $KERNEL_YEAR $KERNEL_MONTH $KERNEL_DAY
echo $KERNEL_TIME $KERNEL_HOUR $KERNEL_MINUTE $KERNEL_SECOND

if test -f /proc/driver/rtc; then
echo
cat /proc/driver/rtc
echo
fi

if [ "$SINCE_EPOCH_CURRENT_DIFFERENCE" ];
then


DATE_DATE=`date +%F`
DATE_TIME=`date +%T`

TIME_DIFF_MSG="OK, I have no explanaition for now,
but the time that interests us here is the time,
that the kernel maintains in it's
/sys/class/rtc/rtc0/ directory .

And your current system time differs from the time,
that the kernel works with .

The kernel thinks, that it is
$KERNEL_DATE $KERNEL_TIME

and GLIBC thinks, that it is
$DATE_DATE $DATE_TIME

and the differece in seconds since epoch is computed as
$SINCE_EPOCH_CURRENT_DIFFERENCE

( Likely some differences in the GLIBC library ..? )
"
Xdialog $TITLE -backtitle "Notice:" -msgbox "$TIME_DIFF_MSG" 0 0
fi


c=0
(
until [ $c = 31 ]
do
echo XXX
cat /sys/class/rtc/rtc0/since_epoch
echo -e '\n/\n'
date +%s
echo XXX
sleep 1
c=$((c+1))
done
) | Xdialog \
 -no-cr-wrap \
 -beep -beep-after \
 $TITLE \
 -cancel-label "GO ON"  \
 -backtitle "Current kernel / system time in seconds since epoch:" \
 -infobox TIME 0 0 0


Xdialog -yesno "OK, \n
if you still dare to go on .. \n
\n
Press Yes button:\n" 0 0

case $? in
0) :;;
*) exit;;
esac

echo "OK"

Xdialog \
 -stdout \
 $TITLE  \
 -backtitle "Calendar" \
 -calendar \
 "Enter Date:" \
 0 0 $KERNEL_DAY $KERNEL_MONTH $KERNEL_YEAR \
 >/tmp/user_selected_date \

# \
#

Xdialog \
 -stdout \
 $TITLE \
 -backtitle "Timebox" \
 -timebox \
 "Enter time to wake sleeping kernel up:" \
 0 0 $KERNEL_HOURS $KERNEL_MINUTES $KERNEL_SECONDS \
 >/tmp/user_selected_time


cat  /tmp/user_selected_date
cat  /tmp/user_selected_time

IFS=$'/' read SELECTED_DAY SELECTED_MONTH SELECTED_YEAR </tmp/user_selected_date
IFS=$':' read SELECTED_HOUR SELECTED_MINUTE SELECTED_SECOND </tmp/user_selected_time

echo $SELECTED_DAY $SELECTED_MONTH $SELECTED_YEAR
echo $SELECTED_HOUR $SELECTED_MINUTE $SELECTED_SECOND

busybox date -d "${SELECTED_YEAR}-${SELECTED_MONTH}-${SELECTED_DAY} ${SELECTED_HOUR}:${SELECTED_MINUTE}:${SELECTED_SECOND}" +%s

SELECTED_SINCE_EPOCH=`busybox date -d "${SELECTED_YEAR}-${SELECTED_MONTH}-${SELECTED_DAY} ${SELECTED_HOUR}:${SELECTED_MINUTE}:${SELECTED_SECOND}" +%s`

KERNEL_SELECTED_SINCE_EPOCH=$(( (SELECTED_SINCE_EPOCH) - (SINCE_EPOCH_CURRENT_DIFFERENCE) ))

read SINCE_EPOCH_CURRENT_KERNEL2 </sys/class/rtc/rtc0/since_epoch

if test "$KERNEL_SELECTED_SINCE_EPOCH" -le $SINCE_EPOCH_CURRENT_KERNEL2; then
xmessage -bg red $TITLE "OOPS :
Your selected time and date is in the past ..

Click OK and this program will run again."
exec "$0"
fi

#USER_INFO_MINUTES=$((KERNEL_SELECTED_SINCE_EPOCH
#USER_INFO_HOURS=$((KERNEL_SELECTED_SINCE_EPOCH
#USER_INFO_DAYS=
#USER_INFO_YEARS=

USER_INFO_SECONDS=$(( ( KERNEL_SELECTED_SINCE_EPOCH ) - (SINCE_EPOCH_CURRENT_KERNEL) ))
USER_INFO_MINUTES=$((USER_INFO_SECONDS/60))
USER_INFO_HOURS=$((USER_INFO_SECONDS/60/60))
USER_INFO_DAYS=$((USER_INFO_SECONDS/60/60/24))
USER_INFO_YEARS=$((USER_INFO_SECONDS/6060/24/365))

echo $USER_INFO_YEARS $USER_INFO_DAYS $USER_INFO_HOURS $USER_INFO_MINUTES

Xdialog \
 $TITLE \
 -backtitle "Confirm:" \
 -yesno "OK, \n
 You have chosen to wake up a sleeping kernel \n
 in \n
 YEARS:   $USER_INFO_YEARS \n
 DAYS:    $USER_INFO_DAYS  \n
 HOURS:   $USER_INFO_HOURS \n
 MINUTES: $USER_INFO_MINUTES \n
 \n
 If that is OK to write \n
 '$KERNEL_SELECTED_SINCE_EPOCH' \n
 ( current time was at the beginning \n
 '$SINCE_EPOCH_CURRENT_KERNEL' \n
 to \n
 /sys/class/rtc/rtc0/wakealarm ,\n
 then click Yes Button, \n
 otherwise No .\n
" 0 0

case $? in
0):;;
*) exit;;
esac

echo "" >/sys/class/rtc/rtc0/wakealarm
sleep 1
cat /sys/class/rtc/rtc0/wakealarm

if test -f /proc/driver/rtc; then
echo
cat /proc/driver/rtc
echo
fi


echo $KERNEL_SELECTED_SINCE_EPOCH >/sys/class/rtc/rtc0/wakealarm
case $? in 0) xmessage -bg green $TITLE "OK!";;
*) xmessage -bg red $TITLE "Something went wrong .. Dunno what .."
;;
esac

if test -f /proc/driver/rtc; then
echo
cat /proc/driver/rtc
echo
fi
