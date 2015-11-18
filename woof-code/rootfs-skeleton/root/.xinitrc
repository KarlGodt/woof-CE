#!/bin/ash
# $Xorg: xinitrc.cpp,v 1.3 2000/08/17 19:54:30 cpqbld Exp $

. /etc/rc.d/PUPSTATE
. /etc/rc.d/f4puppy5

DEBUGT=1
_debugt 00

DEFAULTWM=jwm
_test_frs /etc/windowmanager && read CURRENTWM </etc/windowmanager
test "$CURRENTWM" || CURRENTWM="$DEFAULTWM"

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/usr/lib/X11/xinit/Xresources
sysmodmap=/usr/lib/X11/xinit/.Xmodmap

if [ -f /root/.jwm/jwm_colors ];then #v3.96
. /root/.jwm/jwm_colors
fi
_debugt 10
#if [ "$CURRENTWM" != 'enlightenment_start' ];then
#v4.01 BK daemon to handle kernel uevents...
#/sbin/clean_desk_icons #v4.02 tidy up drive icons first. Now done by pup_event_frontend_d
_pidof $Q pup_event_frontend_d && {
exec /sbin/pup_event_frontend_d restart &
} || {
exec /sbin/pup_event_frontend_d start &  #v403
}
#fi
_debugt 20
#source /root/Choices/XINIT/bb_acpi start &  #MARKER
for file in /root/Choices/XINIT/*; do
[ "`head -n1 $file|grep '^#\!'`" ] && {
    [ -x "$file" ] && {
    _info "Starting '$file'"
    source "$file" start &
    }
}
done
_debugt 30
# merge in defaults and keymaps

if [ -f "$sysresources" ]; then
    xrdb -merge -nocpp "$sysresources"
fi

if [ -f "$sysmodmap" ]; then
    xmodmap "$sysmodmap"
fi

if [ -f "$userresources" ]; then
    xrdb -merge -nocpp "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi
_debugt 40
#w482 reshape background image if widescreen...
/usr/sbin/background_reshape
#relocates right-side icons to actual right-side of screen...
/usr/sbin/fixPuppyPin /root/Choices/ROX-Filer/PuppyPin #v1.0.7
_debugt 50
#v2.0.0
exec /usr/sbin/delayedrun &

if [ "$CURRENTWM" = "startkde" ];then
 exec startkde
fi

#0.9.8 sync selection-buffer and clipboard. only useful for older apps
#such as rxvt that use the selection-buffer...
[ -f /usr/bin/autocutsel ] && /usr/bin/autocutsel &
#...disadvantage of this is it creates a little square bottom-right of screen.

if [ -e /tmp/videomode ];then #xvesa only: testing a video mode
 video-wizard &
fi

[ -f /usr/local/bin/agenda_chk ] && /usr/local/bin/agenda_chk &

#v1.0.7 set by xrandrshell, part of xorg wizard... v3.99...
if [ -f /etc/xrandrindex ];then
  #v3.99 workround for dual monitors, 'head -n 1'....
  XYDEFAULT="`xrandr | grep '\*' | tr -s " " | grep '^ [0-9]' | cut -f 2 -d " " | head -n 1`"
  read XRANDRINDEX </etc/xrandrindex #v3.99 XRANDRINDEX now is XxY resolution.
  #but do not switch if default is already this resolution....
  if [ "$XRANDRINDEX" = "$XYDEFAULT" ];then
   rm $VERB -f /etc/xrandrindex
  else
   xrandr -s $XRANDRINDEX
  fi
fi
_debugt 60

if [ -f /root/.xset.sh ];then
 #this is created by /usr/bin/pupx...
 eval "/root/.xset.sh"
else
 __set_fontpath__(){
 #Xorg has it's own fontpath settings in /etc/X11/xorg.conf...
 if [ "`readlink /usr/bin/X`" != "Xorg" ];then
  #xset fp+ /usr/lib/X11/fonts/Type1/
  #xset fp+ /usr/lib/X11/fonts/TTF/
  xset fp+ /usr/share/fonts/default/Type1/
  xset fp+ /usr/share/fonts/default/TTF/
 fi
 }
 xset s 600 600 s blank
fi

#v1.0.7 also see /etc/rc.d/rc.local0
if [ -f /root/.fonts/fonts.dir ];then
 xset fp+ /root/.fonts/
fi
_debugt 70
__run_xsetroot__(){
#[ -f /usr/bin/xsetroot ] && xsetroot -cursor_name top_left_arrow
which xsetroot >>$OUT && xsetroot -cursor_name top_left_arrow
}

__xfce_manager__(){
#v555 w003
[ -f /usr/bin/xfce-mcs-manager ] && xfce-mcs-manager
[ "$CURRENTWM" = "xfwm4" ] && xfce-mcs-manager
#...no need to start it here, fvwm4 below will start it automatically.
}

__first_launch_rox__(){
#w468 on old PCs this sometimes does not start here, try again further down...
case $CURRENTWM in *enlightenment*)
   /usr/local/bin/rox -p= ;;
*)                rox -p /root/Choices/ROX-Filer/PuppyPin;;
esac
}



#v2.01 hide cursor when not moving... (setup in /usr/sbin/input-wizard)
if [ -f /etc/mousehide ];then
 IDLETIME="`cut -f 1 -d ',' /etc/mousehide`"
 [ "$IDLETIME" = "0" ] || unclutter -idle $IDLETIME &
fi
_debugt 80

__refresh_menu__(){
#v2.14 rarsa: update xdg menu for w.m. that do not allow includes...
which ${CURRENTWM}_menu_refresh && ${CURRENTWM}_menu_refresh
#...no, now doing it differently, see /usr/sbin/fixmenus
}

_launch_glipper(){
#v2.17 removed, interferes with clipboard in Composer....
##v2.15 disovered by GuestToo...
#[ "`which glipper`" != "" ] && glipper &
#v2.17 made it optional...
[ -f /root/.glipper_on ] && /usr/local/bin/glipper &
}
_launch_glipper

if [ "$CURRENTWM" = "xfwm4" ];then
 if [ "`which xfce4-panel`" != "" ];then
  xfwm4 --daemon #note, starts xfce-mcs-manager daemon also.
  exec xfce4-panel
 fi
fi

#v3.91 volume tray applet, thanks to hairywill... v3.96 MENU_BG variable...
if [ -f /usr/bin/absvolume ];then
 if [ "$MENU_BG" = "" ];then
  absvolume &
 else
  absvolume -bg $MENU_BG &
 fi
fi
_debugt 90
#v3.95 support fbpanel tray/taskbar...
#only launch tray for w.m. without inbuilt tray...
#if [ "$CURRENTWM" != "jwm" -a "$CURRENTWM" != "icewm" ];then
case $CURRENTWM in *enlightenment*|jwm*|icewm*) :;;
*)
 which fbpanel >>$OUT && fbpanel &
 which lxpanel >>$OUT && lxpanel &
;;
esac
#fi

_start_rox_again(){
if [ "$CURRENTWM" != 'enlightenment_start' ];then
##w468 rox may not start old hardware, try again...
PS="`ps`" #reanimated krg Mar2011
if [ "`echo "$PS" | grep -e 'ROX-Filer'`" = "" ];then
 touch /tmp/roxfilerstartupproblem #see /sbin/pup_event_frontend_d
 sleep 0.2
 /usr/local/bin/rox -p /root/Choices/ROX-Filer/PuppyPin
fi #reanimated krg Mar2011
fi
}

__start_rox(){
/usr/local/bin/rox -p /root/Choices/ROX-Filer/PuppyPin
sleep 1
_start_rox_again
}

_start_rox(){
    while :
    do
    /usr/local/bin/rox -p "$HOME"/Choices/ROX-Filer/PuppyPin
    sleep 1
    ps -o args | grep -e 'ROX-Filer' | grep -v grep | grep $Q "$HOME"'/Choices/ROX-Filer/PuppyPin' && break
    done
}

case $CURRENTWM in
*enlightenment*) :;;
*) _start_rox &
;;
esac
_debugt A0

setxkbmap -rules xorg -model pc102 -layout us,de -variant "" -option grp:rwin_toggle,lv3:ralt_switch
#exec $CURRENTWM
#v2.11 GuestToo suggested this improvement...
which "$CURRENTWM" >>$OUT && { echo "$CURRENTWM" >/etc/windowmanager; exec $CURRENTWM; }
[ -x "$CURRENTWM" ] && { echo "$CURRENTWM" >/etc/windowmanager; exec $CURRENTWM; }
echo jwm >/etc/windowmanager
exec jwm

###END###
