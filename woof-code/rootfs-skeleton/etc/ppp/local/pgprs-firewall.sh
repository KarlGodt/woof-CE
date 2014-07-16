#!/bin/bash

#**********
#
#**********

exec 2>>/tmp/pgprs-firewall-err.log
#
#
#
#bash-3.2# help trap
#trap: trap [-lp] [arg signal_spec ...]
#    The command ARG is to be read and executed when the shell receives
#    signal(s) SIGNAL_SPEC.  If ARG is absent (and a single SIGNAL_SPEC
#    is supplied) or `-', each specified signal is reset to its original
#    value.  If ARG is the null string each SIGNAL_SPEC is ignored by the
#    shell and by the commands it invokes.  If a SIGNAL_SPEC is EXIT (0)
#    the command ARG is executed on exit from the shell.  If a SIGNAL_SPEC
#    is DEBUG, ARG is executed after every simple command.  If the`-p' option
#    is supplied then the trap commands associated with each SIGNAL_SPEC are
#    displayed.  If no arguments are supplied or if only `-p' is given, trap
#    prints the list of commands associated with each signal.  Each SIGNAL_SPEC
#    is either a signal name in <signal.h> or a signal number.  Signal names
#    are case insensitive and the SIG prefix is optional.  `trap -l' prints
#    a list of signal names and their corresponding numbers.  Note that a
#    signal can be sent to the shell with "kill -signal $$".

#bash-3.2# trap -l
# 1) SIGHUP  2) SIGINT   3) SIGQUIT  4) SIGILL
# 5) SIGTRAP     6) SIGABRT  7) SIGBUS   8) SIGFPE
# 9) SIGKILL    10) SIGUSR1 11) SIGSEGV 12) SIGUSR2
#13) SIGPIPE    14) SIGALRM 15) SIGTERM 16) SIGSTKFLT
#17) SIGCHLD    18) SIGCONT 19) SIGSTOP 20) SIGTSTP
#21) SIGTTIN    22) SIGTTOU 23) SIGURG  24) SIGXCPU
#25) SIGXFSZ    26) SIGVTALRM   27) SIGPROF 28) SIGWINCH
#29) SIGIO  30) SIGPWR  31) SIGSYS  34) SIGRTMIN
#35) SIGRTMIN+1 36) SIGRTMIN+2  37) SIGRTMIN+3  38) SIGRTMIN+4
#39) SIGRTMIN+5 40) SIGRTMIN+6  41) SIGRTMIN+7  42) SIGRTMIN+8
#43) SIGRTMIN+9 44) SIGRTMIN+10 45) SIGRTMIN+11 46) SIGRTMIN+12
#47) SIGRTMIN+13    48) SIGRTMIN+14 49) SIGRTMIN+15 50) SIGRTMAX-14
#51) SIGRTMAX-13    52) SIGRTMAX-12 53) SIGRTMAX-11 54) SIGRTMAX-10
#55) SIGRTMAX-9 56) SIGRTMAX-8  57) SIGRTMAX-7  58) SIGRTMAX-6
#59) SIGRTMAX-5 60) SIGRTMAX-4  61) SIGRTMAX-3  62) SIGRTMAX-2
#63) SIGRTMAX-1 64) SIGRTMAX

trap exit 0 SIGHUP

mkdir -p /tmp/net
logfile=`grep ^logfile /etc/ppp/peers/gprsmm`
[ "$logfile" ] && logfile=`echo "$logfile" |cut -f2- -d ' '` || NOLOG=y

runfirewall(){
/etc/rc.d/rc.firewall 1>/tmp/net/firewall.log 2>&1
xmessage -buttons "OK :140, Again:141" -file /tmp/net/firewall.log
if [ "$?" = '141' ];then
runfirewall
fi
}

sleep 2s

while [ "`pidof pppd`" ];do

sleep 2s

c=0
until [ -L /sys/class/net/ppp0 ];do
sleep 2s;c=$((c+1));[ "$c" = '5' ] && exit
done

if [ "$NOLOG" ] ; then
sleep 10s
else
until [ "`tail -n5 $logfile | grep '^remote IP address '`" ] ; do
sleep 1s
done
fi

#runfirewall(){
#/etc/rc.d/rc.firewall 1>/tmp/net/firewall.log 2>&1
#xmessage -buttons "OK :140, Again:141" -file /tmp/net/firewall.log
#if [ "$?" = '141' ];then
#runfirewall
#fi
#}

until [ -L /sys/class/net/ppp0 ];do
sleep 2s;c=$((c+1));[ "$c" = '5' ] && exit
done

if [ -x /etc/rc.d/rc.firewall ];then
runfirewall
else
firewall_install.sh || firewallinstallshell
fi
#exit $?
break
done
exit $?
