#!/bin/sh

  _TITLE_=usb_modeswitch.sh
_VERSION_=1.0omega
_COMMENT_="Wrapper for usb_modeswitch ."

MY_SELF="$0"
MY_PID=$$

DEBUG=1

test -f /etc/rc.d/f4puppy5 && {
[ "$HAVE_F4PUPPY5" ] || source /etc/rc.d/f4puppy5

ADD_PARAMETER_LIST="ARGUMENTS"
ADD_PARAMETERS=""
_provide_basic_parameters

TWO_HELP='1'; TWO_VERSION='1'; TWO_VERBOSE='1'; TWO_DEBUG='1'; ## Set to anything if code requires further down (ie. custom usage or version message)
ADD_HELP_MSG="$_COMMENT_"
_parse_basic_parameters "$@"
[ "$DO_SHIFT" ] && [ ! "${DO_SHIFT//[[:digit:]]/}" ] && {
  for oneSHIFT in `seq 1 1 $DO_SHIFT`; do shift; done; }

_trap
}

# Passed Variables :
ARGUMENTS="$@"
[ "$DEBUG" ] && echo "$0:$ARGUMENTS"
# Modeswitch Variables :
modeswitchBIN=/usr/sbin/usb_modeswitch
confFILE=/etc/usb_modeswitch.conf
[ -f "$confFILE" ] || confFILE='""'
tmpDIR=/tmp/usb_modeswitch
mkdir -p "$tmpDIR"
logFILE="$tmpDIR"/usb_modeswitch-"`date +%F-%T`".log
# Driver Variables :
DRIVER=option #kernel/drivers/usb/serial/option.ko
modprobeBIN=/sbin/modprobe
modprobeCONF=/etc/modprobe.conf
USBSTORAGEDELAY="`grep 'options usb\-storage ' $modprobeCONF | grep -w -o 'delay_use=[0-9]*' | cut -f 2- -d '='`"
[ "$USBSTORAGEDELAY" = "" ] && USBSTORAGEDELAY="5" #default value

_invoke_method_conf(){
$modeswitchBIN -W -c "$confFILE" &> "$logFILE" #log both output and errors
 retVAL=$?
 sync
 cat "$logFILE" #show output to user
}

_invoke_method_udev_normal(){
sleep $USBSTORAGEDELAY;
sleep 5;
$modeswitchBIN $ARGUMENTS -s 9 -W >> "$logFILE" 2>&1
return $?;
}

_invoke_method_udev_reload_driver(){
sleep $USBSTORAGEDELAY;
sleep 5;
$modeswitchBIN $ARGUMENTS -s 10 -W >> "$logFILE" 2>&1;
sleep 2;
$modprobeBIN $VERB $DRIVER >> "$logFILE" 2>&1;
return $?
}

#config-file method of invocation :
if [ "$ARGUMENTS" = "" -o "$ARGUMENTS" = "-W" ];then
 #$modeswitchBIN -W -c "$confFILE" &> "$logFILE" #log both output and errors
 #retVAL=$?
 #sync
 #cat "$logFILE" #show output to user
 _invoke_method_conf

else #udev-rule -style invocation :

 if [ "`uname -r`" != "2.6.25.16" ] || [ "`echo "$ARGUMENTS" | grep ' -H'`" = "" ];then
  #sh -c "sleep $USBSTORAGEDELAY; sleep 5; $modeswitchBIN $ARGUMENTS -s 9 -W >> $logFILE 2>&1" &
  #retVAL=$?
  _invoke_method_udev_normal &
 else
  #Re-modprobe option driver for Huawei modems in kernel 2.6.25.16, after allowing time for it to switch.
  #sh -c "sleep $USBSTORAGEDELAY; sleep 5; $modeswitchBIN $ARGUMENTS -s 10 -W >> $logFILE 2>&1; $modprobeBIN $VERB $DRIVER" >> "$logFILE" 2>&1 &
  #retVAL=$?
  _invoke_method_udev_reload_driver &
 fi
 retVAL=$?

fi

sleep $USBSTORAGEDELAY
sleep 5s
sleep 2s # modeswitch
sleep 2s
sleep 2s # modprobe
[ "$DEBUG" ] && { [ -s "$logFILE" ] && { cat "$logFILE" || true; } || rm -f "$logFILE"; }

[ "$retVAL" ] || retVAL=0
exit $retVAL
# Very End of this file 'usr/sbin/usb_modeswitch.sh' #
###END###
