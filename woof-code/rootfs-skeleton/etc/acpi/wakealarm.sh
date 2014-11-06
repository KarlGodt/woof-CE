#!/bin/ash

#
. /etc/rc.d/f4puppy5

# GLOBAL variables:
Version='1.0.1-luci218-Dell755'

# Exit count
cEXIT=3

# Subdir in /tmp for scripts | choice files
_TMP_=/tmp
_FEAT_=acpi
tmpDIR=${_TMP_}/${_FEAT_}/${0##*/}
rm -r "$tmpDIR"
mkdir -p "$tmpDIR"

#oldIFS=$"$IFS"
#IFS=$'\n'

#TITLE='-title ''Wakealarm'' ''GUI'
#TITLE='-title "Wakealarm GUI"'
#TITLE="-title Wakealarm\ GUI"
#TITLE=-title\ Wakealarm\ GUI

#TITLE='-title \
#"Wakealarm GUI"'

TITLE='Wakealarm GUI' # for -title option Xdialog and xmessage

if test -f /etc/acpi/X11/app-defaults/Xmessage; then
export XAPPLRESDIR=/etc/acpi/X11/app-defaults/
fi

# Functions
_check_gui_return_value_if_canceled(){
# simple test 0 | * && exit $((cEXIT+1))
test "$1" || set - 0
case $1 in
0) return 0;;
*) exit $((cEXIT+1));;
esac
}

_info_gui(){
# called from _do_exit_missing_prerequisite
 test "$*" || set - `gettext "$0:_info_gui: No MESSAGE given!"`

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
#
test "$*" || set - `gettext "Missing Prerequsite"`
_info_gui "$*"
exit $((cEXIT+1))
}

_test_fr /sys/class/rtc/rtc0/since_epoch || _do_exit_missing_prerequisite `gettext "/sys/class/rtc/rtc0/since_epoch either not file or readable"`

# read kernel time
read SINCE_EPOCH_CURRENT_KERNEL </sys/class/rtc/rtc0/since_epoch
# read user-land time
SINCE_EPOCH_CURRENT_DATE=`LC_TIME=C date +%s`
# test difference between both
if test "$SINCE_EPOCH_CURRENT_KERNEL" = "$TIME_CURRENT_DATE"; then
:
elif test "$SINCE_EPOCH_CURRENT_KERNEL" = "$((SINCE_EPOCH_CURRENT_DATE+1))"; then
:
elif test "$SINCE_EPOCH_CURRENT_KERNEL" = "$((SINCE_EPOCH_CURRENT_DATE-1))"; then
:
else

SINCE_EPOCH_CURRENT_DIFFERENCE=$((SINCE_EPOCH_CURRENT_DATE-SINCE_EPOCH_CURRENT_KERNEL))
[ "$SINCE_EPOCH_CURRENT_DIFFERENCE" = 0 ] && unset SINCE_EPOCH_CURRENT_DIFFERENCE

fi

# Some more files to read and compute
read KERNEL_DATE </sys/class/rtc/rtc0/date
read KERNEL_TIME </sys/class/rtc/rtc0/time

KERNEL_YEAR=${KERNEL_DATE%%-*}
KERNEL_MONTH=`echo $KERNEL_DATE | cut -f2 -d'-'`
KERNEL_DAY=${KERNEL_DATE##*-}

KERNEL_HOUR=${KERNEL_TIME%%:*}
KERNEL_MINUTE=`echo $KERNEL_TIME | cut -f2 -d':'`
KERNEL_SECOND=${KERNEL_TIME##*:}

echo $KERNEL_DATE $KERNEL_YEAR $KERNEL_MONTH $KERNEL_DAY     #DEBUG
echo $KERNEL_TIME $KERNEL_HOUR $KERNEL_MINUTE $KERNEL_SECOND #DEBUG

if test -f /proc/driver/rtc; then #DEBUG
echo
cat /proc/driver/rtc
echo
fi

# if block if user-land and kernel time differ
if [ "$SINCE_EPOCH_CURRENT_DIFFERENCE" ];
then

DATE_DATE=`date +%F`
DATE_TIME=`date +%T`

if grep $Q ^CONFIG_HPET /etc/modules/DOTconfig*; then
HPET_MSG="( and or the 'High Precision Event Timer HPET' feature of the kernel )"
fi

if grep $Q ^CONFIG_HIGH_RES_TIMERS /etc/modules/DOTconfig*; then
HIGHRES_MSG="( and or the 'High Resolution Timer HIGH_RES' feature of the kernel )"
fi

TIME_DIFF_MSG=`gettext "OK, I have no explanaition for now,
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
$HPET_MSG
$HIGHRES_MSG
"`

Xdialog -title "$TITLE" -backtitle "Notice:" -msgbox "$TIME_DIFF_MSG" 0 0
_check_gui_return_value_if_canceled $?

# Debug playaround with Xdialog possibilities
COMPARE_MSG=`gettext "Current kernel / system time in seconds since epoch:"`
CANCEL_LBL=`gettext "GO ON"`

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
 -title "$TITLE" \
 -cancel-label "$CANCEL_LBL"  \
 -backtitle "$COMPARE_MSG" \
 -infobox TIME 0 0 0

# confirm
DARE_MSG=`gettext "OK,
if you still dare to go on ..

Press Yes button:"`

Xdialog -title "$TITLE" -yesno "$DARE_MSG" 0 0
_check_gui_return_value_if_canceled $?
#case $? in
#0) :;;
#*) exit $((cEXIT+1));;
#esac

echo "OK"

fi

# Select date
CAL_BTITLE=`gettext "Calendar"`
CAL_TXT=`gettext "Enter date:"`

Xdialog \
 -stdout \
 -title "$TITLE"  \
 -backtitle "$CAL_BTITLE" \
 -calendar \
 "$CAL_TXT" \
 0 0 $KERNEL_DAY $KERNEL_MONTH $KERNEL_YEAR \
 >"$tmpDIR"/user_selected_date \

_check_gui_return_value_if_canceled $?

# \
#

# Select time
TBX_BTITLE=`gettext "Timebox"`
TBX_TXT=`gettext "Enter time to wake sleeping kernel up:"`

Xdialog \
 -stdout \
 -title "$TITLE" \
 -backtitle "$TBX_BTITLE" \
 -timebox \
 "$TBX_TXT" \
 0 0 $KERNEL_HOURS $KERNEL_MINUTES $KERNEL_SECONDS \
 >"$tmpDIR"/user_selected_time

_check_gui_return_value_if_canceled $?

cat  "$tmpDIR"/user_selected_date  #DEBUG
cat  "$tmpDIR"/user_selected_time  #DEBUG

IFS=$'/' read SELECTED_DAY SELECTED_MONTH SELECTED_YEAR <"$tmpDIR"/user_selected_date
IFS=$':' read SELECTED_HOUR SELECTED_MINUTE SELECTED_SECOND <"$tmpDIR"/user_selected_time

echo $SELECTED_DAY $SELECTED_MONTH $SELECTED_YEAR     #DEBUG
echo $SELECTED_HOUR $SELECTED_MINUTE $SELECTED_SECOND #DEBUG

# transform user time to kernel time
busybox date -d "${SELECTED_YEAR}-${SELECTED_MONTH}-${SELECTED_DAY} ${SELECTED_HOUR}:${SELECTED_MINUTE}:${SELECTED_SECOND}" +%s  #DEBUG

SELECTED_SINCE_EPOCH=`busybox date -d "${SELECTED_YEAR}-${SELECTED_MONTH}-${SELECTED_DAY} ${SELECTED_HOUR}:${SELECTED_MINUTE}:${SELECTED_SECOND}" +%s`

KERNEL_SELECTED_SINCE_EPOCH=$(( (SELECTED_SINCE_EPOCH) - (SINCE_EPOCH_CURRENT_DIFFERENCE) ))

# check if wake time is in future, otherwise re-run script
read SINCE_EPOCH_CURRENT_KERNEL2 </sys/class/rtc/rtc0/since_epoch

if test "$KERNEL_SELECTED_SINCE_EPOCH" -le $SINCE_EPOCH_CURRENT_KERNEL2; then

PAST_DATE_MSG="OOPS :
Your selected time and date is in the past ..

Click OK and this program will run again."

xmessage -bg red -title "$TITLE" "$PAST_DATE_MSG"
exec "$0"
fi

# transform seconds to other time measures for the confirm gui
USER_INFO_SECONDS=$(( ( KERNEL_SELECTED_SINCE_EPOCH ) - (SINCE_EPOCH_CURRENT_KERNEL) ))
USER_INFO_MINUTES=$((USER_INFO_SECONDS/60))
USER_INFO_HOURS=$((USER_INFO_SECONDS/60/60))
USER_INFO_DAYS=$((USER_INFO_SECONDS/60/60/24))
USER_INFO_YEARS=$((USER_INFO_SECONDS/6060/24/365))

echo $USER_INFO_YEARS $USER_INFO_DAYS $USER_INFO_HOURS $USER_INFO_MINUTES #DEBUG

# confirm
CFRM_BTITLE=`gettext "Confirm:"`
CFRM_TXT=`gettext "OK,
 You have chosen to wake up a sleeping kernel
 in
 YEARS:   $USER_INFO_YEARS
 DAYS:    $USER_INFO_DAYS
 HOURS:   $USER_INFO_HOURS
 MINUTES: $USER_INFO_MINUTES

 If that is OK to write
 '$KERNEL_SELECTED_SINCE_EPOCH'
 ( current time was
 '$SINCE_EPOCH_CURRENT_KERNEL'
  at the beginning)
 to
 /sys/class/rtc/rtc0/wakealarm ,
 then click Yes Button,
 otherwise No .
"`

Xdialog \
 -title "$TITLE" \
 -backtitle "$CFRM_BTITLE" \
 -yesno "$CFRM_TXT" 0 0

_check_gui_return_value_if_canceled $?
#case $? in
#0):;;
#*) exit $((cEXIT+1));;
#esac

# unset the current value in wakealarm ...
echo "" >/sys/class/rtc/rtc0/wakealarm
sleep 1
cat /sys/class/rtc/rtc0/wakealarm #DEBUG

if test -f /proc/driver/rtc; then #DEBUG
echo
cat /proc/driver/rtc
echo
fi

# actually write the choosen time to wakealarm ...
OK_MSG=`gettext "OK Have set wakealarm!`
ER_MSG=`getext "Something went wrong .. Dunno what .."`
echo $KERNEL_SELECTED_SINCE_EPOCH >/sys/class/rtc/rtc0/wakealarm
case $? in
0) xmessage -bg green -timeout 9 -title "$TITLE" "$OK_MSG" &
sleep 2
;;
*) xmessage -bg red -timeout 9 -title "$TITLE" "$ER_MSG"
exit $((cEXIT+1))
;;
esac

if test -f /proc/driver/rtc; then #DEBUG
echo
cat /proc/driver/rtc
echo
fi

###EXIT###
exit 0
###EXIT###
