#!/bin/ash

. /etc/rc.d/f4puppy5

_install(){
(
MY_SELF=`realpath "$0"`
for x in jwm
do
test -x "$x" || continue
URXVT=`which "$x"`

case `file "$URXVT"` in
*shell*script*|*script*text*) :;;

*ELF*LSB*GNU/Linux*)
BNBIN=`basename "$URXVT"`
DNBIN=`dirname "$URXVT"`
cp -af "$URXVT" /tmp/"$BNBIN".bin
BNWRP=`basename "$MY_SELF"`
DNWRP=`dirname "$MY_SELF"`
cp -af "$MY_SELF" /tmp/"$BNWRP"

cp -af /tmp/"$BNBIN".bin "$DNBIN"/
cp -af /tmp/"$BNWRP" "$DNBIN"/jwm

;;

*)
: echo TODO
;;
esac
done
)
}

_install

which jwm.bin >>$OUT || exit 3

case $1 in

-restart)

 _pidof $Q glipper  >>$OUT && { HAVE_GLIPPER=Y;  killall glipper; }
 _pidof $Q fbxkb    >>$OUT && { HAVE_FBXKB=Y;    killall fbxkb; }
 _pidof $Q retrovol >>$OUT && { HAVE_RETROVOL=Y; killall retrovol; }
 which freememapplet_tray >>$OUT && { HAVE_FREEMEMAPP_TRAY=Y; killall freememapplet; }

 jwm.bin -restart
  sleep 1
 if test "$HAVE_RETROVOL" = Y; then
 #TODO
 RETVOL_VERS=`retrovol --version 2>/dev/null | awk '{print $2}'`
  case $RETVOL_VERS in
  0.1[0-9]*)
  exec retrovol -hide &
  ;;
  *)
  exec retrovol &
  ;;
  esac
 sleep 1
fi
if test "$HAVE_FBXKB" = Y; then
 exec fbxkb &
fi
if test "$HAVE_GLIPPER" = Y; then
 exec glipper &
fi
;;

'') #jwm seems to call jwm -exit if already running (now? JWM vgit-976)
if test "$DISPLAY"; then
_pidof $Q jwm.bin || exec jwm.bin
else
exec jwm.bin
fi
;;

*)
exec jwm.bin "$@";;
esac
