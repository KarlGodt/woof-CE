#!/bin/sh

DEFAULT=xfishtank # xearth # xplanet # xsnow

while :;
do
case $1 in
*start|*stop|*restart|*status|*help|*usage) STARTSTOPPARAM="$1";;
*xfishtank|*xearth|*xplanet|*xsnow) X_BACK_GROUND_PROGRAM=$1;;
*) X_BACK_GROUND_PROGRAM_OPTS="$X_BACK_GROUND_PROGRAM_OPTS $1";;
esac

shift
[ "$1" ] || break
done

[ "$X_BACK_GROUND_PROGRAM" ] || {
    X_BACK_GROUND_PROGRAM=$DEFAULT
    echo "Defaulting to $X_BACK_GROUND_PROGRAM ."
}

[ "`which $X_BACK_GROUND_PROGRAM`" ] || {
echo "Sorry, $X_BACK_GROUND_PROGRAM seems not to be installed in PATH"
exit 2
}

set - $STARTSTOPPARAM

case $1 in

*restart)

 case $X_BACK_GROUND_PROGRAM in
 xsnow) killall xsnow;;
 *)
 for p in xfishtank xearth xplanet
 do
  pidof $p && { killall $p; sleep 1; }
 done
 ;;
 esac

pidof ROX-Filer && rox -p=
exec $X_BACK_GROUND_PROGRAM $X_BACK_GROUND_PROGRAM_OPTS &

;;
*start)

shift

pidof $X_BACK_GROUND_PROGRAM && { echo "$0: $X_BACK_GROUND_PROGRAM already running.";exit 1; }

case $X_BACK_GROUND_PROGRAM in xsnow) :;;
*)
 for p in xfishtank xearth xplanet
 do
  pidof $p && { echo "$0 : XBackground program '$p' still running.
Use '${0##*/}' stop '$p' first."; exit 2; }
 done
;;
esac

if [ "`ps -elF | grep -E 'ROX\-Filer|rox' | grep '\-p' | grep 'PuppyPin' |grep -v 'grep'`" ];then
PUPPYPIN=Running
fi

#rox -p
#/usr/local/apps/ROX-Filer/ROX-Filer: option requires an argument -- p
pidof ROX-Filer && rox -p=

exec $X_BACK_GROUND_PROGRAM $X_BACK_GROUND_PROGRAM_OPTS &
;;

*stop)

case $X_BACK_GROUND_PROGRAM in xsnow) :;;
*)
 for p in xfishtank xearth xplanet
 do
 [ "$X_BACK_GROUND_PROGRAM" = "$p" ] && continue
  pidof $p && { echo "$0 : XBackground program '$p' still running."; }
 done
;;
esac

if pidof $X_BACK_GROUND_PROGRAM; then
 killall $X_BACK_GROUND_PROGRAM
 sleep 1

 if pidof ROX-Filer; then
  if which fixitup;then
   fixitup
  else
   rox -p=$HOME/Choices/ROX-Filer/PuppyPin
  fi
 fi
fi

;;

*status)
 STATUS=0
 for p in xfishtank xearth xplanet xsnow
 do
  [ "$X_BACK_GROUND_PROGRAM" = "$p" ] && continue
  pidof $p && { echo "$0 : XBackground program '$p' running."; }
 done
 pidof $X_BACK_GROUND_PROGRAM && { echo "$X_BACK_GROUND_PROGRAM: Running."; STATUS=1; } || {
                                   echo "$X_BACK_GROUND_PROGRAM not running."; }
;;

*help|*usage|*) echo "$0: "'start|stop|restart|status <xbgprogram> [ options ] parameter needed.';;
esac

exit $STATUS
