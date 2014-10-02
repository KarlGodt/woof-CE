#!/bin/sh
#####
###
####






###RL=`readlink -f /sys/bus/usb/devices/*`
LSF=`ls -F /sys/bus/usb/devices/* | tr -d '@'`
echo $LSF

wak_a_cotl_func(){
for i in $LSF; do
RL=`readlink -f $i`
echo $RL
#done
WF=`find $RL -type f -name "wakeup"`
echo $WF
CF=`find $RL -type f -name "control"`
echo $CF
for j in $WF; do
echo $j
FWF=`cat $j`
[ "$FWF" = "disabled" ] && echo 'enabled' > $j
cat $j
done
for k in $CF; do
echo $k
FCF=`cat $k`
[ "$FCF" = "auto" ] && echo 'on' > $k
cat $k
done


other_func() {
OF=`find $RL -type f`
for l in $OF; do
echo $l
cat $l
done
}

done
}

rmmod_usbcore_func() {
	ruc_func_main(){
UF=`lsmod | grep 'usbcore' | tr -s ' ' | cut -f 4 -d ' ' | tr ',' ' '`
for i in $UF; do
rmmod -f $i
done
}
[ "`lsmod | grep 'usbcore' | tr -s ' ' | cut -f 4 -d ' '`" != "" ] && ruc_func_main
rmmod usbcore
}


modp_usb_func() {
	HCI=`elspci -l`
	[ -n"`echo $HCI | grep '0C0300'`" ] && modprobe uhci_hcd
	[ -n"`echo $HCI | grep '0C0310'`" ] && modprobe ohci_hcd
	[ -n"`echo $HCI | grep '0C0320'`" ] && modprobe ehci_hcd
	modprobe usb_storage
	modprobe usbcore autosuspend=-1
}

	