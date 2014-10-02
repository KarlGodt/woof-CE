#!/bin/bash

DEV_MODEM=/dev/ttyUSB0
CLAC_FILE=/modem-stats_AT+CLAC.sort_d.txt
VALUE_FILE=/get_modem_values.txt

Version=1.0-Puppy-4.3x
echo $LINENO
usage(){
MSG="
$0 [help|version] [force|/dev/MODEM|pin=3210]

"
if [ "$2" ];then
MSG="$MSG

$2
"
fi
echo "$MSG"
[ "$DISPLAY" ] && xmessage -bg cyan "$MSG"
exit $1
}

while [ "$1" ];do
case $1 in
help) usage 0;;
version) usage 0 "Version=$Version";;
force) rm $CLAC_FILE;shift;;
pin=*) PIN=${1##*=};modem-stats -c AT+CPIN=$PIN $DEV_MODEM;shift;;
/dev/*) DEV_MODEM=$1;shift;;
*|'') shift;;
esac;done
echo $LINENO
modem-stats ${DEV_MODEM}
echo $LINENO
if ! [ -f ${CLAC_FILE} ];then
modem-stats -c AT+CLAC ${DEV_MODEM} |tr ',' '\n' |sort -d >${CLAC_FILE}
fi
echo $LINENO
un_b_lock_function(){

PIN=3210      ##Change as needed/required to your PIN
PUK=76543210  ##Change as needed/required to your PUK

if [ "$1" = 'unlock' ];then
modem-stats -c "AT+CPIN=${PIN}" ${DEV_MODEM}
shift
fi

if [ "$1" = 'unblock' ];then
modem-stats -c AT+CPIN=${PUK},${PIN} ${DEV_MODEM}
shift
fi
}
#un_b_lock_function
echo $LINENO
[ -f ${VALUE_FILE} ] && cp --remove-destination ${VALUE_FILE} ${VALUE_FILE}.bak
echo $LINENO
date >${VALUE_FILE}
uname -a >>${VALUE_FILE}
. /etc/DISTRO_SPECS
echo "${DISTRO_NAME}*${DISTRO_VERSION}" >> ${VALUE_FILE}
echo $LINENO
modem-stats ${DEV_MODEM} >>${VALUE_FILE}
echo $LINENO
while read line;do
echo "'$line'"
[ "$line" ] || continue
line=`echo "${line}" |awk '{print $1}'`
STATUS=0
echo '#-------#' >>${VALUE_FILE}
echo "CMD=AT${line} [? & =? |'']" >>${VALUE_FILE}
echo '##CURRENT------#' >>${VALUE_FILE}
timeout -t 6 modem-stats -c "AT${line}?" ${DEV_MODEM} >>${VALUE_FILE} 2>&1
STATUS=$((STATUS+$?))
echo '##------#' >>${VALUE_FILE}
echo '###POSSIBLE-----#' >>${VALUE_FILE}
timeout -t 6 modem-stats -c "AT${line}=?" ${DEV_MODEM} >>${VALUE_FILE} 2>&1
STATUS=$((STATUS+$?))
echo '###-----#' >>${VALUE_FILE}

log_error_func(){
if [ "$STATUS" -ge 2 ];then
echo "'$line'" >>/at_commands_wo_output.txt
fi
}
log_error_func

display_func(){

if [ "$STATUS" -ge 2 ];then
 if [ "`echo "$line" |grep -Ew '\+GMR|\+GSN|\+CGMI|\+CGMM|\+CGMR|\+CGSN|\+CERR|&V|I|\+GCAP|\+GMI|\+GMM'`" ];then
 echo '####INFO --#'  >>${VALUE_FILE}
timeout -t 6 modem-stats -c "AT${line}" ${DEV_MODEM} >>${VALUE_FILE} 2>&1
 echo '####INFO --#'  >>${VALUE_FILE}
 fi
fi
}
display_func

own_possibles_func(){

if [ "$STATUS" -ge 2 ];then
 if [ "`echo "$line" |grep -Ew '\^SYSINFO|\+CLAC'`" ];then
  echo '####SYS ---#'  >>${VALUE_FILE}
 timeout -t 6 modem-stats -c "AT${line}" ${DEV_MODEM} >>${VALUE_FILE} 2>&1
  echo '####SYS ---#'  >>${VALUE_FILE}
 fi
fi
}
own_possibles_func

sms_func(){

if [ "$STATUS" -ge 2 ];then
 if [ "`echo "$line" |grep -w '\+CMGL'`" ];then
  echo '####SMS ---#'  >>${VALUE_FILE}
 timeout -t 6 modem-stats -c "AT${line}=\"ALL\"" ${DEV_MODEM} >>${VALUE_FILE} 2>&1
  echo '####SMS ---#'  >>${VALUE_FILE}
 fi
fi
}
sms_func

dangerous_func(){  #enable it if you know what your doing
if [ "$STATUS" -ge 2 ];then ##coreutils timeout returns 124 when timeout occurs;still have to check busybox for this
echo '####SIMPLE----#' >>${VALUE_FILE}
 if [ "${line} " != '&F' ];then  #warn:loads factory profile
  if [ ! "`echo "$line" |grep -Ew '\+CSAS|\+CRES|A|D|;|H1|L0|M0|M1|M2|M3|\\G|\\G0|\\G1|&K|&K0|&K3|&K4|&K5|&K6|S'`" ];then  #TODO:make list more proof, or: grep only proofed commands
timeout -t 6 modem-stats -c "AT${line}" ${DEV_MODEM} >>${VALUE_FILE} 2>&1
  else
  echo '####OMITTED----#'
  fi
 else
 echo '####NOT SETTING FACTORY DEFAULT----#'
 fi
echo '####----#' >>${VALUE_FILE}
fi
}
#dangerous_func #enable it if you know what your doing

echo "CMD=AT${line} [? & =? |'']" >>${VALUE_FILE}
echo '#-------#' >>${VALUE_FILE}

done << EOF
$(cat ${CLAC_FILE})
EOF

mkdir -p /etc/ppp/modem_info.d
cp -ai $CLAC_FILE /etc/ppp/modem_info.d/
cp -ai $VALUE_FILE /etc/ppp/modem_info.d/

exit 0
