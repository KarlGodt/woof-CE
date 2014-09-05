#!/bin/sh

  _TITLE_=
_COMMENT_=

MY_SELF="$0"

test -f /etc/rc.d/f4puppy5 && {
source /etc/rc.d/f4puppy5

ADD_PARAMETER_LIST=""
ADD_PARAMETERS=""
_provide_basic_parameters

ADD_HELP_MSG="$_COMMENT_"
_parse_basic_parameters "$@"
[ "$DO_SHIFT" ] && [ ! "${DO_SHIFT//[[:digit:]]/}" ] && {
  for oneSHIFT in `seq 1 1 $DO_SHIFT`; do shift; done; }

_trap
}

ARGUMENTS="$@"
if [ "$ARGUMENTS" = "" -o "$ARGUMENTS" = "-W" ];then #config-file method of invocation
 usb_modeswitch -W -c /etc/usb_modeswitch.conf &> /tmp/usb_modeswitch.log #log both output and errors
 sync
 cat /tmp/usb_modeswitch.log #show output to user

else #udev-rule invocation
 USBSTORAGEDELAY="`grep 'options usb-storage ' /etc/modprobe.conf | grep -w --only-matching 'delay_use=[0-9]*' | cut -f 2 -d '='`"
 [ "$USBSTORAGEDELAY" = "" ] && USBSTORAGEDELAY="5" #default value
 if [ "`uname -r`" != "2.6.25.16" ] || [ "`echo "$ARGUMENTS" | grep ' -H'`" = "" ];then
  sh -c "sleep $USBSTORAGEDELAY; sleep 5; /usr/sbin/usb_modeswitch $ARGUMENTS -s 9 -W >> /tmp/usb_modeswitch.log 2>&1" &
 else
  #Re-modprobe option driver for Huawei modems in kernel 2.6.25.16, after allowing time for it to switch.
  sh -c "sleep $USBSTORAGEDELAY; sleep 5; /usr/sbin/usb_modeswitch $ARGUMENTS -s 10 -W >> /tmp/usb_modeswitch.log 2>&1; /sbin/modprobe option" >> /tmp/usb_modeswitch.log 2>&1 &
 fi
fi
exit 0
