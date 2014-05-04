#!/bin/ash


MY_SELF="$0"
MY_REAL=`readlink -f "$0"`  # BB readlink does not know the -e option

BN_SELF="${MY_SELF##*/}"    #basename ie poweroff, reboot
BN_REAL="${MY_REAL##*/}"    #basename ie shutdown

which_shutdown(){

  if [ "`which hard-reboot`" ]; then
     SHUTDOWN_EXE=minit
elif [ "`which busybox`" ]; then
     SHUTDOWN_EXE=busybox
elif [ "`which shutdown.bin`" ]; then
     SHUTDOWN_EXE=shutdown.bin
else
     echo "Apparently no shutdown program found in known PATH '$PATH' ."
     echo "Exiting ."
     exit 1
  fi

}

all_which_shutdown(){

for BIN in hard-reboot busybox shutdown.bin; do
[ "`which $BIN`" ] && BINS="$BINS $BIN";    done

}
all_which_shutdown

probe_first_option(){
case $1 in
  reboot) :;;
poweroff) :;;
shutdown)                      [ "`which shutdown.bin`" ] && SHUTDOWN_EXE=shutdown.bin;;
-a|-c|-f|-F|-h|-H|-k|-n|-P|-t) [ "`which shutdown.bin`" ] && SHUTDOWN_EXE=shutdown.bin;; # shutdown
-n) [ "`which shutdown.bin`" ] && SHUTDOWN_EXE=shutdown.bin;;  # shutdown
*) :;;
esac
}
probe_first_option $*


assign_options(){

for opt in $*
do
shift
case $opt in
-d|-n|-f)
       if test "$SHUTDOWN_EXE" = busybox; then
          case $opt in -d) DELAY_SEC=$1; opt="-d $DELAY_SEC"; shift;;
          *) :;; esac
          SHUTOWN_OPTS="$SHUTOWN_OPTS $opt"
     elif test "$SHUTDOWN_EXE" = shutdown.bin; then
          case $opt in -d) echo "Unhandled option '$opt' for '$SHUTDOWN_EXE' .";;
          -f) echo "Unhandled option '$1' 'omit fsck' for '$SHUTDOWN_EXE' .";;
          -n) SHUTOWN_OPTS="$SHUTOWN_OPTS $opt";; esac
     else
          :
       fi
;;
-a|-c|-f|-F|-h|-H|-k|-n|-P|-t)
        if test "$SHUTDOWN_EXE" = shutdown.bin; then
           case $opt in -t) DELAY_SEC=$1; opt="-t $DELAY_SEC"; shift;;
           *) :;; esac
           SHUTOWN_OPTS="$SHUTOWN_OPTS $opt"
      else
           :
       fi
;;
*) RC_SHUTDOWN_OPTS="$RC_SHUTDOWN_OPTS $opt";;
esac
done

}

which_switch(){

if test ! "$SHUTDOWN_EXE"; then
which_shutdown
fi
if test ! "$SHUTDOWN_EXE"; then
SHUTDOWN_EXE=`echo "$BINS" | tr ' ' '\n' | grep -w "$1"`
 if test  ! "$SHUTDOWN_EXE"; then
 echo "'$1' apparently not installed in PATH '$PATH' ."
 echo "Exiting."
 exit 2
 fi
fi

case $SHUTDOWN_EXE in
 hard-reboot)
            if test "$1" = "poweroff";     then SHUTDOWN_DO='hard-reboot POWER_OFF'
          elif test "$1" = "reboot";       then SHUTDOWN_DO='hard-reboot RESTART'
          elif test "$1" = "halt";         then SHUTDOWN_DO='hard-reboot HALT'
          elif test "$1" = "shutdown.bin"; then :
          else echo "Unhandled parameter '$1' .Exiting ."; exit 3; fi
          ;;
     busybox)
            if test "$1" = "poweroff";     then SHUTDOWN_DO='busybox poweroff'
          elif test "$1" = "reboot";       then SHUTDOWN_DO='busybox reboot'
          elif test "$1" = "shutdown.bin"; then :
          else echo "Unhandled parameter '$1' .Exiting ."; exit 3; fi
          ;;
shutdown.bin)
            if test "$1" = "poweroff";     then SHUTDOWN_DO='shutdown.bin -hP'
          elif test "$1" = "reboot";       then SHUTDOWN_DO='shutdown.bin -r'
          elif test "$1" = "shutdown.bin"; then :
          else echo "Unhandled parameter '$1' .Exiting ."; exit 3; fi
          ;;
esac

}

case $BN_SELF in
poweroff|poweroff.sh) which_switch poweroff    ;;
  reboot|reboot.sh  ) which_switch reboot      ;;
shutdown|shutdown.sh) ##which_switch shutdown.bin;;

;;
*) echo "Unhandled '$MY_SELF' .Exiting '$MY_REAL' ."; exit 4;;
esac

assign_options $*

/etc/rc.d/rc.shutdown $RC_SHUTDOWN_OPTS
case $? in
0) :;;
*) :;;
esac

$SHUTDOWN_DO $SHUTOWN_OPTS
