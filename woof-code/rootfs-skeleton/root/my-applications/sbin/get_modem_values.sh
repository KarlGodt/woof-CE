#!/bin/bash

usage(){
MSG="
$0 [help|version] [PIN=SIMPIN|/dev/MODEM]
"
if [ "$2" ];then
MSG="$MSG

$2
"
fi
echo "$MSG"
[ "$DISPLAY" ] && xmessage -bg cyan1 "$MSG"
exit $1
}

DEV_MODEM=/dev/ttyUSB2
CLAC_FILE=/modem-stats_AT+CLAC.sort_d.txt
VALUE_FILE=/get_modem_values.txt

while [ $1 ];do
case $1 in
-h|help|-help|--help) usage 0;;
-V|version|-version|--version)
. /etc/DISTRO_SPECS
usage 0 "$VERSION $DISTRO_NAME $DISTRO_VERSION"
;;
-f|force|-force|--force)
rm -f $CLAC_FILE;shift;;
/dev/*) DEV_MODEM=$1;shift;;
PIN=*)
modem-stats -c AT+C$1 $DEV_MODEM;shift;;
*|'')shift;;
esac;done



timeout -t 10 modem-stats ${DEV_MODEM} || { RV=$?;
echo ERROR
dmesg |grep `echo ${DEV_MODEM//\/dev\/} |tr -d '[[:digit:]]'`
echo ERROR
dmesg |grep ${DEV_MODEM//\/dev\//};
echo ERROR
ls -l /dev/modem;
ls -l ${DEV_MODEM//[[:digit:]]/}*;
echo ERROR
exit $RV;
 }

if ! [ -f ${CLAC_FILE} ];then
timeout -t 10 modem-stats -c AT+CLAC ${DEV_MODEM} |tr ',' '\n' |sort -d >${CLAC_FILE}
[ $? -ne 0 ] && { echo "Something wrong";exit 1; }
fi

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

[ -f ${VALUE_FILE} ] && cp --remove-destination ${VALUE_FILE} ${VALUE_FILE}.bak

date >${VALUE_FILE}
uname -a >>${VALUE_FILE}
. /etc/DISTRO_SPECS
echo "${DISTRO_NAME}*${DISTRO_VERSION}" >> ${VALUE_FILE}

timeout -t 10 modem-stats ${DEV_MODEM} >>${VALUE_FILE}
timeout -t 2 modem-stats -c ATZ ${DEV_MODEM}

while read line;do

echo "'$line'"
[ "$line" ] || continue
line=`echo "${line}" |awk '{print $1}'`

STATUS=0
echo '###########' >>${VALUE_FILE}
echo '#---------#' >>${VALUE_FILE}
echo "CMD=AT${line} [? & =? |'']" >>${VALUE_FILE}

echo '##CURRENT------#' >>${VALUE_FILE}
timeout -t 6 modem-stats -c "AT${line}?" ${DEV_MODEM} |sed 's|\(.\{72\}\)|\1\n|g' >>${VALUE_FILE} 2>&1
STATUS=$((STATUS+$?))
echo '##------#' >>${VALUE_FILE}

timeout -t 2 modem-stats -c ATZ ${DEV_MODEM}

echo '###POSSIBLE-----#' >>${VALUE_FILE}
timeout -t 6 modem-stats -c "AT${line}=?" ${DEV_MODEM} |sed 's|\(.\{72\}\)|\1\n|g' >>${VALUE_FILE} 2>&1
STATUS=$((STATUS+$?))
echo '###-----#' >>${VALUE_FILE}

timeout -t 2 modem-stats -c ATZ ${DEV_MODEM}

log_error_func(){
if [ "$STATUS" -ge 2 ];then
echo "'$line'" >>/at_commands_wo_output.txt
fi
}
log_error_func

display_func(){

if [ "$STATUS" -ge 2 ];then
 if [ "`echo "$line" |grep -Ew '\+GMR|\+GSN|\+CGMI|\+CGMM|\+CGMR|\+CGSN|\+CERR|&V|I|\+GCAP|\+GMI|\+GMM'`" ];then
 echo '####DISPLAY----#' >>${VALUE_FILE}
timeout -t 6 modem-stats -c "AT${line}" ${DEV_MODEM} |sed 's|\(.\{72\}\)|\1\n|g'  >>${VALUE_FILE} 2>&1
 echo '####-----' >>${VALUE_FILE}
 fi
fi
}
display_func

sys_possibles_func(){

if [ "$STATUS" -ge 2 ];then
 if [ "`echo "$line" |grep -Ew '\^SYSINFO|\+CLAC'`" ];then
 echo '####SYS----#' >>${VALUE_FILE}
timeout -t 6 modem-stats -c "AT${line}" ${DEV_MODEM}  |sed 's|\(.\{72\}\)|\1\n|g' >>${VALUE_FILE} 2>&1
 echo '####SYS----#' >>${VALUE_FILE}
 fi
fi
}
sys_possibles_func

sms_func(){

if [ "$STATUS" -ge 2 ];then
 if [ "`echo "$line" |grep -w '\+CMGL'`" ];then
 echo '####SMS----#' >>${VALUE_FILE}
timeout -t 6 modem-stats -c "AT${line}=\"ALL\"" ${DEV_MODEM}  |sed 's|\(.\{72\}\)|\1\n|g' >>${VALUE_FILE} 2>&1
 echo '####SMS----#' >>${VALUE_FILE}
 fi
fi
}
sms_func

dangerous_func(){  #enable it if you know what your doing
if [ "$STATUS" -ge 2 ];then ##coreutils timeout returns 124 when timeout occurs;still have to check busybox for this
echo '####SIMPLE----#' >>${VALUE_FILE}
 if [ "${line} " != '&F' ];then  #warn:loads factory profile
  if [ ! "`echo "$line" |grep -Ew '\+CSAS|\+CRES|A|D|;|H1|L0|M0|M1|M2|M3|\\G|\\G0|\\G1|&K|&K0|&K3|&K4|&K5|&K6|S'`" ];then  #TODO:make list more proof, or: grep only proofed commands
timeout -t 6 modem-stats -c "AT${line}" ${DEV_MODEM}  |sed 's|\(.\{72\}\)|\1\n|g' >>${VALUE_FILE} 2>&1
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

echo "#CMD=${line}--#" >>${VALUE_FILE}
echo '###########' >>${VALUE_FILE}

timeout -t 2 modem-stats -c ATZ ${DEV_MODEM}

done << EOF
$(cat ${CLAC_FILE})
EOF
