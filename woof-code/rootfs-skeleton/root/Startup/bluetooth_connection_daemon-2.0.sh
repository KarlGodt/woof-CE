#!/bin/ash

test -f /etc/rc.d/f4puppy5 && . /etc/rc.d/f4puppy5

me_call="$0"
me_real=`realpath "$0"`
me_base_name_call="${me_call##*/}"
me_base_name_real="${me_real##*/}"

# VARIABLES
test -f /etc/bluetooth/puppy/bt_connect_d.conf && . /etc/bluetooth/puppy/bt_connect_d.conf

DEBUG=1
 BT_ADDR_TO_CONNECT_TO='3C:DA:2A:39:7C:45' #ZTE Blade L3 Smartfone
#BT_ADDR_TO_CONNECT_TO='60:FE:1E:22:47:D7' #Archos 40 Neon
#BT_ADDR_TO_CONNECT_TO='F4:55:9C:71:91:37' #Huawei Ideos X3 U8510
#BT_ADDR_TO_CONNECT_TO='30:19:66:55:18:6B' #Samsung Gal Y Duo S GT-S6102
BT_ADDRS_TO_CONNECT_TO='
3C:DA:2A:39:7C:45
60:FE:1E:22:47:D7
F4:55:9C:71:91:37
30:19:66:55:18:6B'
USB_BT_DEV_VEND_ID=1131
USB_BT_DEV_PROD_ID=1004
BT_DEV_VEND=1131
BT_DEV_PROD=1004      #method csr gives error message and switches prodid from 1004 to 1002
BT_MODE=hci           # hci or hid
BT_MODE_METH=logitech #csr, logitech, dell
CPU_SLEEP=1 # seconds, set higher if slow cpu

echo A

for oneBT_DEV in $BT_ADDR_TO_CONNECT_TO; do
case $oneBT_DEV in '#'*) continue;; esac
test -f /etc/bluetooth/puppy/devices/"$oneBT_DEV".cfg && . /etc/bluetooth/puppy/devices/"$oneBT_DEV".cfg
done

for oneBT_DEV in $USB_BT_DEV_VEND_IDS; do
case $oneBT_DEV in '#'*) continue;; esac
test -f /etc/bluetooth/puppy/devices/${oneBT_DEV}.cfg && . /etc/bluetooth/puppy/devices/${oneBT_DEV}.cfg
done

for oneBT_DEV in `ls /etc/bluetooth/puppy/devices/`; do
test -r /etc/bluetooth/puppy/devices/"$oneBT_DEV".cfg && . /etc/bluetooth/puppy/devices/"$oneBT_DEV".cfg
done

_usage(){
MSG="
$me_base_name_link [help] [start|stop]
daemon script to keep autoconnection for hidd running
if bt mouse disconnects out of the blue.
"
[ "$2" ] && MSG="$MSG
$2"
echo "$MSG"
exit $1
}

case $1 in
*start|*stop|'') :;;
*help|-h) _usage 0;;
*)        _usage 1;;
esac

echo B

#_exit_function(){
#exit $?
#}  # ash does not like trap -l
#TRAP_SIGNALS=`trap -l|sed 's|\([0-9]*)\)||g;s|SIG||g;s|\t||g' |tr -s ' '`
#TRAP_SIGNALS=`echo $TRAP_SIGNALS`
#[ "$DEBUG" ] && echo "$TRAP_SIGNALS"
#trap "exit $?" HUP INT QUIT ILL TRAP ABRT BUS FPEKILL USR1 SEGV USR2 PIPE ALRM TERM STKFLT CHLD CONT STOP TSTP TTIN TTOU URG XCPU XFSZ VTALRM PROF WINCH IO PWR SYS RTMIN .. .. RTMIN+1 RTMIN+2 RTMIN+3 RTMIN+4 RTMIN+5 RTMIN+6 RTMIN+7 RTMIN+8 RTMIN+9 RTMIN+10 RTMIN+11 RTMIN+12 RTMIN+13 RTMIN+14 RTMIN+15 RTMAX-14 RTMAX-13 RTMAX-12 RTMAX-11 RTMAX-10 RTMAX-9 RTMAX-8 RTMAX-7 RTMAX-6 RTMAX-5 RTMAX-4 RTMAX-3 RTMAX-2 RTMAX-1 RTMAX
#trap "_exit_function" $TRAP_SIGNALS

_get_hci_devices(){
HCI_DEVICES=`hciconfig | grep '^[[:alnum:]]*:' | cut -f1 -d':'` # hci0, hci1, ..
}

_connect_bt_hci0_as_hid_search(){
hidd -i hci0 -t 5 --search
}

_connect_bt_all_as_hid_search(){
_get_hci_devices
for oneHCI_DEV in $HCI_DEVICES; do
hidd -i $oneHCI_DEV -t 5 --search
sleep $((1*CPU_SLEEP))
done
}

_connect_bt_static_hci0_as_hci(){
    for oneADDR in $BT_ADDRS_TO_CONNECT_TO; do
case $oneADDR in '#'*) continue;; esac
#hidd -i hci0 -t 5 --connect "$BT_ADDR_TO_CONNECT_TO"
echo -n "$oneADDR"' :'
#hidd -i hci0 -t 5 --connect "$oneADDR"
hcitool cc "$oneADDR"
sleep $((1*CPU_SLEEP))
    done
}
#       cc [--role=m|s] [--pkt-type=<ptype>] <bdaddr>
#              Create  baseband  connection  to  remote  device  with Bluetooth
#              address bdaddr.  Option --pkt-type specifies a list  of  allowed
#              packet  types.   <ptype>  is  a  comma-separated  list of packet
#              types, where the possible packet types are DM1, DM3,  DM5,  DH1,
#              DH3,  DH5, HV1, HV2, HV3.  Default is to allow all packet types.
#              Option --role can have value m (do not allow role  switch,  stay
#              master)  or  s (allow role switch, become slave if the peer asks
#              to become master). Default is m.

_connect_bt_static_all_as_hci(){
    _get_hci_devices
    for oneADDR in $BT_ADDRS_TO_CONNECT_TO; do
case $oneADDR in '#'*) continue;; esac
#hidd -i hci0 -t 5 --connect "$BT_ADDR_TO_CONNECT_TO"
for oneHCI_DEV in $HCI_DEVICES; do
echo -n "$oneHCI_DEV $oneADDR"' :'
#hidd -i $oneHCI_DEV -t 5 --connect "$oneADDR"
hcitool -i $oneHCI_DEV cc "$oneADDR"
sleep $((1*CPU_SLEEP))
done
    done
}

_connect_bt(){
    if test "$BT_ADDRS_TO_CONNECT_TO"; then
    case "$BT_MODE" in
    hid) _connect_bt_all_as_hid_search;;
    hci) _connect_bt_static_all_as_hci;;
    esac
    else
    case $BT_MODE in
    hid) _connect_bt_hci0_as_hid_search;;
    hci) _connect_bt_static_hci0_as_hci;;
    esac
    fi
}
echo C

_show_info_blue_devices(){
BT_WHO_IS_NEAR_SCAN=`hcitool scan`
if test "$BT_WHO_IS_NEAR_SCAN"; then
 echo "hcitool scan :
 $BT_WHO_IS_NEAR_SCAN
"
 BT_WHO_IS_NEAR_INQ=`hcitool inq`
 echo "hcitool ibq :
 $BT_WHO_IS_NEAR_INQ
"
 BT_ADDRESSES=`echo "$BT_WHO_IS_NEAR_SCAN" | awk '{print $1}'`
 BT_ADDRS_NEW="$BT_ADDRESSES"
  for oneBT_ADDR in $BT_ADDRESSES; do
 echo
 hcitool info "$oneBT_ADDR"
 if test "$BT_ADDRS_TO_CONNECT_TO"; then
  echo "$BT_ADDRS_TO_CONNECT_TO" | grep $Q "$oneBT_ADDR" || BT_ADDRS_NEW=`echo "$BT_ADDRS_NEW" | grep -v "$oneBT_ADDR"` #works only if one address per line
 fi
  done

else
echo "No BT devices detected in near area."
fi
BT_ADDRS_TO_CONNECT_TO=$BT_ADDRS_NEW
}

_show_conneted_info_more(){
for oneADDR in $BT_ADDRS_TO_CONNECT_TO; do
echo $oneADDR
# A=`hcitool rssi "$BT_ADDR_TO_CONNECT_TO"`
# B=`hcitool lq   "$BT_ADDR_TO_CONNECT_TO"`
#AA=`hcitool tpl  "$BT_ADDR_TO_CONNECT_TO"`
#BB=`hcitool afh  "$BT_ADDR_TO_CONNECT_TO"`
test "$A" && \
echo -e "received signal strenght information :\n $A\n" || \
echo 'No info about received signal strenght rssi.'
test "$B" && \
echo -e "link quality :\n $B\n" || \
echo 'No info about link quality.'
test "$AA" && \
echo -e "transmit power level:\n $AA\n" || \
echo 'No info about transmit power level.'
test "$BB" && \
echo -e "AFH channel map :\n $BB\n" || \
echo 'No info about AFH channel map.'
done
}
_check_driver(){
if modprobe -l | grep $Q 'bluetooth\.ko'; then
test -f /proc/modules || { echo "CRIT:No /proc/modules file..";return 2; }
grep $Q 'bluetooth' /proc/modules || { echo "WARN:Bluetooth driver probably not loaded.";return 1; }
fi
return 0
}

_check_sys_hci(){
SYS_HCI_DIRS=`find /sys -type d -name "hci[0-9]*"`
test "$SYS_HCI_DIRS"
}

_bring_hci_devices_down(){
for oneADDR in $BT_ADDRS_TO_CONNECT_TO; do
hcitool dc $oneADDR 19 #Default is 19 for user ended connections
sleep 0.2
done
_get_hci_devices
for oneHCI_DEV in $HCI_DEVICES ; do
hciconfig $oneHCI_DEV down
sleep 0.2
done
hciconfig hci0 down
}

echo D
rm -f /tmp/bluetooth_stop.mrk
case $1 in
stop)
echo STOP
touch /tmp/bluetooth_stop.mrk
if _check_sys_hci; then
_bring_hci_devices_down
fi
ps -C hidd >$OUT && kill -1 `pidof hidd` #>/dev/null

;;
restart)
touch /tmp/bluetooth_stop.mrk
if _check_sys_hci; then
_bring_hci_devices_down
fi
ps -C hidd >$OUT && kill -1 `pidof hidd` #>/dev/null
if grep $Q bluetooth /proc/modules; then
modprobe $Q $VERB -r bluetooth
sleep $((2*CPU_SLEEP))
modprobe $Q $VERB bluetooth
fi
sleep $((9*CPU_SLEEP))
exec "$me_real" &
exit
;;

start|*|'')
echo starting

_check_driver || exit 3

#hid2hci -r $BT_MODE -v $BT_DEV_VEND -p $BT_DEV_PROD -m $BT_MODE_METH || :

if hciconfig -a | grep $Q 'UP RUNNING'; then : #piscan makes bt device visible to other bt devices
else { if hciconfig hci0 up; then sleep 2; hciconfig hci0 piscan; sleep 2; fi; }
fi
[ $? = 0 ] || { echo "ERROR:Unable to bring hci0 up."; exit 30; }

_show_info_blue_devices && echo 'OK. :)' || echo 'No info about bt devices obtained. :('

while :;do
#pidof hidd || break
test -e /tmp/bluetooth_stop.mrk && break
_check_driver  || { echo "Notice: bluetooth.ko driver not loaded";           sleep 3; continue; }
_check_sys_hci || { echo "Notice: No hciX found in sysfs. Is it unplugged?"; sleep 3; continue; }
hciconfig  || break #>/dev/null
hcitool con |sed '1 d' |cut -f2- -d: #DEBUG
if test "`hcitool con |sed '1 d' |cut -f2- -d:`" = "" ;then
#aplay /usr/share/audio/2barks.au
aplay /usr/share/audio/leave.wav #same as /usr/share/audio/logout.wav
_connect_bt
sleep 2s
 if test "`hcitool con |sed '1 d' |cut -f2- -d:`" != "" ;then
  #/usr/share/audio/join.wav #sounding like cat's "Meeow"
  aplay /usr/share/audio/bark.au
  _show_conneted_info_more
 fi
fi
sleep 3s
#_check_driver
#_check_sys_hci
done
;;
esac
echo ENDofSCRIPT
