#!/bin/sh

mkdir -p /var/local/sns/ppp0

for ONECOUNT in \
 sns/r sns/t pupdial/isp1/r pupdial/isp1/t pupdial/isp2/r pupdial/isp2/t ppp0/r ppp0/t sns/ppp0/r sns/ppp0/t
do mkdir -p /var/local/${ONECOUNT%/*}
touch /var/local/${ONECOUNT}x_bytes_month
done

LANG=C UPDATE_MONTH=`date +%b`
read CURRENT_MONTH </var/local/sns/current_month
[ "$CURRENT_MONTH" ] || CURRENT_MONTH=0
if [ "$UPDATE_MONTH" != "$CURRENT_MONTH" ];then
 echo "$UPDATE_MONTH" > /var/local/sns/current_month
 for ONECOUNT in sns/r sns/t pupdial/isp1/r pupdial/isp1/t pupdial/isp2/r pupdial/isp2/t ppp0/r ppp0/t sns/ppp0/r sns/ppp0/t;do
  mkdir -p /var/local/${ONECOUNT%/*}
  cp --backup=numbered /var/local/${ONECOUNT}x_bytes_month /var/local/${ONECOUNT}x_bytes_month-`date +%Y`-$CURRENT_MONTH
  echo -n 0 > /var/local/${ONECOUNT}x_bytes_month
 done
fi

ACTIVE_INTERFACE="ppp0"
#mkdir -p /var/local/sns
[ -f /tmp/sns_interface_success ] && read ACTIVE_INTERFACE </tmp/sns_interface_success #SNS
[ "$ACTIVE_INTERFACE" ] || ACTIVE_INTERFACE="`ifconfig | grep '^[a-z]' | grep -v '^lo' | grep 'Link encap:Ethernet' | cut -f 1 -d ' ' | head -n 1`"
if [ "$ACTIVE_INTERFACE" ];then
 mkdir -p /var/local/$ACTIVE_INTERFACE
 if [ -d /sys/class/net/${ACTIVE_INTERFACE}/statistics ];then
  read RX_BYTES </sys/class/net/${ACTIVE_INTERFACE}/statistics/rx_bytes
  read TX_BYTES </sys/class/net/${ACTIVE_INTERFACE}/statistics/tx_bytes
  #echo -n "$RX_BYTES" > /var/local/$ACTIVE_INTERFACE/rx_bytes_session
  #echo -n "$TX_BYTES" > /var/local/$ACTIVE_INTERFACE/tx_bytes_session
  #RX_BYTES_MONTH=`cat /var/local/$ACTIVE_INTERFACE/rx_bytes_month`
  #[ ! "$RX_BYTES_MONTH" ] && RX_BYTES_MONTH=0
  #RX_BYTES_MONTH=`expr $RX_BYTES_MONTH + $RX_BYTES`
  #echo -n "$RX_BYTES_MONTH" > /var/local/$ACTIVE_INTERFACE/rx_bytes_month
  #TX_BYTES_MONTH=`cat /var/local/$ACTIVE_INTERFACE/tx_bytes_month`
  #[ ! "$TX_BYTES_MONTH" ] && TX_BYTES_MONTH=0
  #TX_BYTES_MONTH=`expr $TX_BYTES_MONTH + $TX_BYTES`
  #echo -n "$TX_BYTES_MONTH" > /var/local/$ACTIVE_INTERFACE/tx_bytes_month
 fi
fi
#TOTALSESSION=$(((RX_BYTES+TX_BYTES)/1024));echo SESSION:"$TOTALSESSION"
kill -1 `pidof pppd`

while [ "`pidof pppd`" ] ; do sleep 1s; done

if [ "$RX_BYTES" -a "$TX_BYTES" ] ; then
  SESS_END=`date +%s`

  echo -n "$RX_BYTES" > /var/local/$ACTIVE_INTERFACE/rx_bytes_session
  echo -n "$RX_BYTES" > /var/local/$ACTIVE_INTERFACE/rx_bytes_session-$SESS_END

  echo -n "$TX_BYTES" > /var/local/$ACTIVE_INTERFACE/tx_bytes_session
  echo -n "$TX_BYTES" > /var/local/$ACTIVE_INTERFACE/tx_bytes_session-$SESS_END

  read RX_BYTES_MONTH_la </var/local/$ACTIVE_INTERFACE/rx_bytes_month
  [ "$RX_BYTES_MONTH_la" ] || RX_BYTES_MONTH_la=0
  read RX_BYTES_MONTH_ls </var/local/sns/rx_bytes_month
  [ "$RX_BYTES_MONTH_ls" ] || RX_BYTES_MONTH_ls=0
  read RX_BYTES_MONTH_lsa </var/local/sns/$ACTIVE_INTERFACE/rx_bytes_month
  [ "$RX_BYTES_MONTH_lsa" ] || RX_BYTES_MONTH_lsa=0

  RX_BYTES_MONTH=$(((RX_BYTES_MONTH_la+RX_BYTES_MONTH_ls+RX_BYTES_MONTH_lsa)/3))

  [ "$RX_BYTES_MONTH" ] || RX_BYTES_MONTH=0

  RX_BYTES_MONTH=`expr $RX_BYTES_MONTH + $RX_BYTES`
  echo -n "$RX_BYTES_MONTH" > /var/local/$ACTIVE_INTERFACE/rx_bytes_month
  echo -n "$RX_BYTES_MONTH" > /var/local/sns/$ACTIVE_INTERFACE/rx_bytes_month
  echo -n "$RX_BYTES_MONTH" > /var/local/sns/rx_bytes_month

  read TX_BYTES_MONTH_la </var/local/$ACTIVE_INTERFACE/tx_bytes_month
  [ "$TX_BYTES_MONTH_la" ] || TX_BYTES_MONTH_la=0
  read TX_BYTES_MONTH_ls </var/local/sns/tx_bytes_month
  [ "$TX_BYTES_MONTH_ls" ] || TX_BYTES_MONTH_ls=0
  read TX_BYTES_MONTH_lsa </var/local/sns/$ACTIVE_INTERFACE/tx_bytes_month
  [ "$TX_BYTES_MONTH_lsa" ] || TX_BYTES_MONTH_lsa=0

  TX_BYTES_MONTH=$(((TX_BYTES_MONTH_la+TX_BYTES_MONTH_ls+TX_BYTES_MONTH_lsa)/3))

  [ "$TX_BYTES_MONTH" ] || TX_BYTES_MONTH=0
  TX_BYTES_MONTH=`expr $TX_BYTES_MONTH + $TX_BYTES`
  echo -n "$TX_BYTES_MONTH" > /var/local/$ACTIVE_INTERFACE/tx_bytes_month
  echo -n "$TX_BYTES_MONTH" > /var/local/sns/$ACTIVE_INTERFACE/tx_bytes_month
  echo -n "$TX_BYTES_MONTH" > /var/local/sns/tx_bytes_month


echo ""
TOTALSESSION=$(((RX_BYTES+TX_BYTES)/1024));          echo "SESSION:$TOTALSESSION KiB"
TOTALMONTH=$(((RX_BYTES_MONTH+TX_BYTES_MONTH)/1024));echo "  MONTH:$TOTALMONTH KiB"
TOTALSESSION=$((TOTALSESSION/1024)); echo "SESSION:$TOTALSESSION MiB"
TOTALMONTH=$((TOTALMONTH/1024));     echo "  MONTH:$TOTALMONTH MiB"
TOTALSESSION=$((TOTALSESSION/1024)); echo "SESSION:$TOTALSESSION GiB"
TOTALMONTH=$((TOTALMONTH/1024));     echo "  MONTH:$TOTALMONTH GiB"
echo ""
TOTALSESSION=$( dc $(($RX_BYTES+$TX_BYTES)) 1024 \/ p );          echo "SESSION:$TOTALSESSION KiB"
TOTALMONTH=$( dc $(($RX_BYTES_MONTH+$TX_BYTES_MONTH)) 1024 \/ p );echo "  MONTH:$TOTALMONTH KiB"
TOTALSESSION=$( dc $TOTALSESSION 1024 \/ p ); echo "SESSION:$TOTALSESSION MiB"
TOTALMONTH=$( dc $TOTALMONTH 1024 \/ p );     echo "  MONTH:$TOTALMONTH MiB"
TOTALSESSION=$( dc $TOTALSESSION 1024 \/ p ); echo "SESSION:$TOTALSESSION GiB"
TOTALMONTH=$( dc $TOTALMONTH 1024 \/ p );     echo "  MONTH:$TOTALMONTH GiB"
echo ""

else
echo -e "\e[1;31m""Err .. could not read /sys/class/net/${ACTIVE_INTERFACE}/statistics/""\e[0;39m"
fi

sleep 1s
exit 0
