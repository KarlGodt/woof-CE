#!/bin/sh

me_call="$0"
me_link=`readlink -e "$0"`
me_base_name_call="${me_call##*/}"
me_base_name_link="${me_link##*/}"

usage(){
MSG="
$me_base_name_link [help] [start|stop]
daemon script to keep autoconnection for hidd running
if bt mouse disconnects out of the blue.
"
[ "$2" ] && MSG="$MSG
$2"
exit $1
}
[[ "$1" =~ 'help' ]] && usage 0
[[ "$1" =~ '-h' ]] && usage 0

[ "`lsmod | grep bluetooth`" ] || { echo "Bluetooth driver probably not loaded.";exit 900; }

hciconfig -a | grep 'UP RUNNING' || hciconfig hci0 up
[ $? = 0 ] || exit 899

function exit_function(){
exit $?
}
TRAP_SIGNALS=`trap -l|sed 's|\([0-9]*)\)||g;s|SIG||g;s|\t||g' |tr -s ' '`
TRAP_SIGNALS=`echo $TRAP_SIGNALS`
#trap "exit $?" HUP INT QUIT ILL TRAP ABRT BUS FPEKILL USR1 SEGV USR2 PIPE ALRM TERM STKFLT CHLD CONT STOP TSTP TTIN TTOU URG XCPU XFSZ VTALRM PROF WINCH IO PWR SYS RTMIN .. .. RTMIN+1 RTMIN+2 RTMIN+3 RTMIN+4 RTMIN+5 RTMIN+6 RTMIN+7 RTMIN+8 RTMIN+9 RTMIN+10 RTMIN+11 RTMIN+12 RTMIN+13 RTMIN+14 RTMIN+15 RTMAX-14 RTMAX-13 RTMAX-12 RTMAX-11 RTMAX-10 RTMAX-9 RTMAX-8 RTMAX-7 RTMAX-6 RTMAX-5 RTMAX-4 RTMAX-3 RTMAX-2 RTMAX-1 RTMAX
trap "exit_function" $TRAP_SIGNALS

function connect_bt(){
hidd -i hci0 --search
}

case $1 in
stop)
ps -C hidd && kill -1 `pidof hidd`
;;
start|*|'')
while [ running ];do
hcitool con |sed '1 d' |cut -f2- -d:
if test "`hcitool con |sed '1 d' |cut -f2- -d:`" = "" ;then
#aplay /usr/share/audio/2barks.au
aplay /usr/share/audio/leave.wav #same as /usr/share/audio/logout.wav
connect_bt
sleep 2s
 if test "`hcitool con |sed '1 d' |cut -f2- -d:`" != "" ;then
  #/usr/share/audio/join.wav sounding like cat's "Meeow"
  aplay /usr/share/audio/bark.au
 fi
fi
sleep 3s
done
;;
esac

