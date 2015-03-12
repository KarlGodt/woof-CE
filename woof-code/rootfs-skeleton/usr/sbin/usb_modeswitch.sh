#!/bin/ash
#
# New header by Karl Reimer Godt, September 2014
  _TITLE_="Puppy_usb_modeswitch.sh"
_VERSION_=1.0omega
_COMMENT_="$_TITLE_:Puppy Linux shell script [to TODO here]"

MY_SELF="/usr/sbin/usb_modeswitch.sh"
MY_PID=$$

test -f /etc/rc.d/f4puppy5 && {
[ "$HAVE_F4PUPPY5" ] || source /etc/rc.d/f4puppy5

ADD_PARAMETER_LIST=""
ADD_PARAMETERS=""
_provide_basic_parameters

TWO_HELP='1'; TWO_VERSION='1'; TWO_VERBOSE='1'; TWO_DEBUG='1'; ## Set to anything if code requires further down (ie. custom usage or version message)
ADD_HELP_MSG="$_COMMENT_"
_parse_basic_parameters "$@"
[ "$DO_SHIFT" ] && [ ! "${DO_SHIFT//[[:digit:]]/}" ] && {
  for oneSHIFT in `seq 1 1 $DO_SHIFT`; do shift; done; }

_trap

}
# End new header
#

# ZTE MF628+ (tested version from Telia / Sweden)
# ZTE MF626
# ZTE MF636 (aka "Telstra / BigPond 7.2 Mobile Card")

#SUBSYSTEM=="usb", ATTRS{idProduct}=="2000", ATTRS{idVendor}=="19d2", ACTION=="add", RUN+="/usr/sbin/usb_modeswitch.sh -v 0x%s{idVendor} -p 0x%s{idProduct} -V 0x19d2 -P 0x0031 -M '55534243123456782000000080000c85010101180101010101000000000000'"

#/usr/sbin/usb_modeswitch.sh -v 0x19d2 -p 0x2000 -V 0x19d2 -P 0x0031 -M '55534243123456782000000080000c85010101180101010101000000000000'

ARGUMENTS="$@"
echo "$ARGUMENTS"

tmpDIR=/tmp/usb_modeswitch
mkdir -p "$tmpDIR"
logFILE="$tmpDIR"/usb_modeswitch-"`date +%F-%T`".log
modeswitchCONF=/etc/usb_modeswitch.conf
[ -f "$modeswitchCONF" ] || modeswitchCONF='""'
modeswitchBIN=/usr/sbin/usb_modeswitch
modprobeBIN=/sbin/modprobe
modprobeCONF=/etc/modprobe.conf
DRIVER=option
grep ^$DRIVER /proc/modules || modprobe $VERB $DRIVER
if test -f $modprobeCONF; then
USBSTORAGEDELAY="`grep 'options usb\-storage ' $modprobeCONF | grep -w -o 'delay_use=[0-9]*' | cut -f 2 -d '='`"
fi
[ "$USBSTORAGEDELAY" = "" ] && USBSTORAGEDELAY="5" #default value

if [ "$ARGUMENTS" = "" -o "$ARGUMENTS" = "-W" ];then #config-file method of invocation
 echo "configfile invocation"
 $modeswitchBIN -W -c $modeswitchCONF &> $logFILE #log both output and errors
 retval=$?
 sync
 cat $logFILE #show output to user

else #udev-rule invocation
 echo "udev invocation"
 #USBSTORAGEDELAY="`grep 'options usb-storage ' /etc/modprobe.conf | grep -w --only-matching 'delay_use=[0-9]*' | cut -f 2 -d '='`"
 #[ "$USBSTORAGEDELAY" = "" ] && USBSTORAGEDELAY="5" #default value
 if [ "`uname -r`" != "2.6.25.16" ] || [ "`echo "$ARGUMENTS" | grep ' \-H'`" = "" ];then
  echo "default invocation"
  sh -c "sleep $USBSTORAGEDELAY; sleep 5; $modeswitchBIN $ARGUMENTS -s 9 -W >> $logFILE 2>&1" &
 else
  echo "kernel 2.6.25.16 invocation , or not -H option"
  #Re-modprobe option driver for Huawei modems in kernel 2.6.25.16, after allowing time for it to switch.
  sh -c "sleep $USBSTORAGEDELAY; sleep 5; $modeswitchBIN $ARGUMENTS -s 10 -W >> $logFILE 2>&1; $modprobeBIN $VERB $DRIVER" >> $logFILE 2>&1 &
 fi
 retVAL=$?
 test "$retVAL" = 0 || cat $logFILE
fi

[ "$retVAL" ] || retVAL=0
exit $retVAL
