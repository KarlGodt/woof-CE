#!/bin/bash
##
# written by Karl Reimer Godt.
##

#
#
#



##FIRST MAIN VARS
PID="$$"
PROGRAM_NAME="${0##*/}"
#echo $PROGRAM_NAME

##took out of pidfile_func because the pidfile
#seems not to be removed sometimes prog finishes >
pidof pppd
echo
pidfile=/var/run/net/"$PROGRAM_NAME".pid
mkdir -p /var/run/net
rm -f $pidfile

trap "rm -f $pidfile" SIGHUP
trap exit 0 SIGHUP

##load driver
driver_func(){
OPTIONS=''
DRIVER='option'
[ ! "`lsmod | grep '$DRIVER'`" ] && modprobe -v $DRIVER $OPTIONS
}
driver_func

##wait for connection established
c=0
while [ ! -L /sys/class/net/ppp0 ] ; do
sleep 1s;c=$((c+1))
[ "$c" == "10" ] && break
done

##no connection && exit
[ -L /sys/class/net/ppp0 ] || exit 1

variables_func(){
IFS='·' #for spacebar to be recognized by read command
RX_BYTES_O=0;TX_BYTES_O=0
}
variables_func

config_func(){
mainconf='/etc/ppp/peers/gprsmm'
}
#config_func

logfile_func(){
#logfile /var/log/net/pppd
logfile=`grep 'logfile' "$mainconf" |awk '{print $2}'`
[ "$logfile" ] || logfile='/var/log/net/pppd'
#echo $logfile
mkdir -p `dirname "$logfile"`
touch "$logfile"
}
#logfile_func

month_change_func(){
LANG=C UPDATE_MONTH="`date +%b`"
touch /var/local/sns/current_month || mkdir -p /var/local/sns
CURRENT_MONTH="`cat /var/local/sns/current_month`" || CURRENT_MONTH='none'
#[ ! "$CURRENT_MONTH" ] && CURRENT_MONTH='none'
if [ "$UPDATE_MONTH" != "$CURRENT_MONTH" ];then
 echo "$UPDATE_MONTH" > /var/local/sns/current_month
 for ONECOUNT in sns pupdial/isp1 pupdial/isp2 ppp0;do
  [ -d /var/local/${ONECOUNT} ] || mkdir -p /var/local/${ONECOUNT}
  echo -n 0 > /var/local/${ONECOUNT}/rx_bytes_month
  echo -n 0 > /var/local/${ONECOUNT}/tx_bytes_month
 done
fi
}

get_transmission_func(){
ACTIVE_INTERFACE="ppp0"
mkdir -p /var/local/$ACTIVE_INTERFACE
[ -f /tmp/sns_interface_success ] && ACTIVE_INTERFACE="`cat /tmp/sns_interface_success`" #SNS
[ ! "$ACTIVE_INTERFACE" ] && ACTIVE_INTERFACE="`ifconfig | grep '^[a-z]' | grep -v '^lo' | grep 'Link encap:Ethernet' | cut -f 1 -d ' ' | head -n 1`"
if [ "$ACTIVE_INTERFACE" ];then
 if [ -d /sys/class/net/${ACTIVE_INTERFACE}/statistics ];then
  #RX_BYTES="`cat /sys/class/net/${ACTIVE_INTERFACE}/statistics/rx_bytes`"
  read RX_BYTES </sys/class/net/${ACTIVE_INTERFACE}/statistics/rx_bytes
  #TX_BYTES="`cat /sys/class/net/${ACTIVE_INTERFACE}/statistics/tx_bytes`"
  read TX_BYTES </sys/class/net/${ACTIVE_INTERFACE}/statistics/tx_bytes
  echo -n "$RX_BYTES" > /var/local/$ACTIVE_INTERFACE/rx_bytes_session
  echo -n "$TX_BYTES" > /var/local/$ACTIVE_INTERFACE/tx_bytes_session
  #RX_BYTES_MONTH=`cat /var/local/$ACTIVE_INTERFACE/rx_bytes_month`
  read RX_BYTES_MONTH </var/local/$ACTIVE_INTERFACE/rx_bytes_month
  [ "$RX_BYTES_MONTH" ] || RX_BYTES_MONTH=0
  #RX_BYTES_MONTH=`expr $RX_BYTES_MONTH + $RX_BYTES - $RX_BYTES_O`
  RX_BYTES_MONTH=$((RX_BYTES_MONTH + RX_BYTES - RX_BYTES_O))
  echo -n "$RX_BYTES_MONTH" > /var/local/$ACTIVE_INTERFACE/rx_bytes_month
  #TX_BYTES_MONTH=`cat /var/local/$ACTIVE_INTERFACE/tx_bytes_month`
  read TX_BYTES_MONTH </var/local/$ACTIVE_INTERFACE/tx_bytes_month
  [ "$TX_BYTES_MONTH" ] || TX_BYTES_MONTH=0
  #TX_BYTES_MONTH=`expr $TX_BYTES_MONTH + $TX_BYTES - $TX_BYTES_O`
  TX_BYTES_MONTH=$((TX_BYTES_MONTH + TX_BYTES - TX_BYTES_O))
  echo -n "$TX_BYTES_MONTH" > /var/local/$ACTIVE_INTERFACE/tx_bytes_month
  RX_BYTES_O=$RX_BYTES;TX_BYTES_O=$TX_BYTES
 fi
fi
}

present_transmission_func(){

MSG="SESSION out:$TX_BYTES Bytes
SESSION in :$RX_BYTES Bytes"
SK=`dc $((RX_BYTES+TX_BYTES)) 1024 \/ p`
SM=`dc $SK 1024 \/ p`
SG=`dc $SM 1024 \/ p`

MSG="$MSG
SESSION tot:$SK KiB
SESSION    :$SM MiB
SESSION    :$SG GiB

  MONTH out:$TX_BYTES_MONTH Bytes
  MONTH in :$RX_BYTES_MONTH Bytes"

MK=`dc $((RX_BYTES_MONTH+TX_BYTES_MONTH)) 1024 \/ p`
MM=`dc $MK 1024 \/ p`
MG=`dc $MM 1024 \/ p`

MSG="$MSG
  MONTH tot:$MK KiB
  MONTH    :$MM MiB
  MONTH    :$MG GiB
"

if [ "$DISPLAY" ] ; then
xmessage "$MSG" &
else
echo "$MSG"
fi
}

pidfile_func(){
#pidfile=/var/run/net/"$PROGRAM_NAME".pid
#mkdir -p /var/run/net
[ -f "$pidfile" ] && exit 2
echo $PID >> "$pidfile"
}
pidfile_func

while [ -L /sys/class/net/ppp0 ] ; do
month_change_func
get_transmission_func
sleep 2s
done

present_transmission_func
rm "$pidfile"
exit "$?"


