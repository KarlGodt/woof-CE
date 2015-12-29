#!/bin/ash
# $Xorg: xinitrc.cpp,v 1.3 2000/08/17 19:54:30 cpqbld Exp $

PROG='/root/.xinitrc'
DEFAULTWM=jwm
DISP=${DISPLAY%.*}

. /etc/rc.d/f4puppy5
_notice "HOME='$HOME'"
_debug "LD_LIBRARY_PATH='$LD_LIBRARY_PATH'"
. /etc/rc.d/PUPSTATE

if [ -f /root/.jwm/jwm_colors ];then #v3.96
. /root/.jwm/jwm_colors
fi

#w482 reshape background image if widescreen...
[ $PUPMODE -eq 5 ] && /usr/sbin/background_reshape

# merge in defaults and keymaps ..
sysresources=/usr/X11/lib/X11/xinit/Xresources
[ -f "$sysresources" ] && xrdb -merge -nocpp "$sysresources"
userresources=$HOME/.Xresources
[ -f "$userresources" ] && xrdb -merge -nocpp "$userresources"

sysmodmap=/usr/X11/lib/X11/xinit/.Xmodmap
[ -f "$sysmodmap" ] && xmodmap "$sysmodmap"
usermodmap=$HOME/.Xmodmap
[ -f "$usermodmap" ] && xmodmap "$usermodmap"

#CURRENTWM="`cat /etc/windowmanager`"
read CURRENTWM </etc/windowmanager  #|| CURRENTWM=jwm #CURRENTWM=none
#DISP=${DISPLAY%.*} #get rid of ':1.0' .0
test -s "/etc/windowmanager.$DISP" && read CURRENTWM <"/etc/windowmanager.$DISP"
[ "$CURRENTWM" ] || CURRENTWM=$DEFAULTWM
_info "CURRENTWM='$CURRENTWM'"

if [ "$CURRENTWM" = "startkde" ];then
 exec startkde
fi

_debug "LD_LIBRARY_PATH='$LD_LIBRARY_PATH'"
#0.9.8 sync selection-buffer and clipboard. only useful for older apps
#such as rxvt that use the selection-buffer...
[ -f /usr/bin/autocutsel ] && /usr/bin/autocutsel &
#...disadvantage of this is it creates a little square bottom-right of screen.

if [ -e /tmp/videomode ];then #xvesa only: testing a video mode
 video-wizard &
fi

[ -f /usr/local/bin/agenda_chk ] && agenda_chk &

#v1.0.7 set by xrandrshell, part of xorg wizard... v3.99...
if [ -f /etc/xrandrindex ];then
  #v3.99 workround for dual monitors, 'head -n 1'....
  XYDEFAULT=`xrandr | grep '\*' | tr -s " " | grep '^ [0-9]' | cut -f 2 -d " " | head -n 1`
  XRANDRINDEX=`cat /etc/xrandrindex` #v3.99 XRANDRINDEX now is XxY resolution.
  #but do not switch if default is already this resolution....
  if [ "$XRANDRINDEX" = "$XYDEFAULT" ];then
   rm $VERB -f /etc/xrandrindex
  else
   xrandr -s $XRANDRINDEX
  fi
fi

_info "/root/.xset.sh ..."
if [ -f /root/.xset.sh ];then
 #this is created by /usr/bin/pupx...
 _notice "Evaluating /root/.xset.sh"
 eval "/root/.xset.sh"
else
 ##Xorg has it's own fontpath settings in /etc/X11/xorg.conf...
 #if [ "`readlink /usr/bin/X`" != "Xorg" ];then
 # #xset fp+ /usr/lib/X11/fonts/Type1/
 # #xset fp+ /usr/lib/X11/fonts/TTF/
 # xset fp+ /usr/share/fonts/default/Type1/
 # xset fp+ /usr/share/fonts/default/TTF/
 #fi
 _notice "Setting xset s 600 600 s blank"
 xset s 600 600 s blank
fi

#v1.0.7 also see /etc/rc.d/rc.local0
echo "$0:/root/.fonts/fonts.dir .."
if [ -f /root/.fonts/fonts.dir ];then
 _info "xset fp+ /root/.fonts/"
 xset fp+ /root/.fonts/
fi

_debug "LD_LIBRARY_PATH='$LD_LIBRARY_PATH'"
[ -f /usr/bin/xsetroot ] && xsetroot -cursor_name top_left_arrow

if [ "$CURRENTWM" != 'enlightenment_start' ]; then
#v555 w003
#[ -f /usr/bin/xfce-mcs-manager ] && xfce-mcs-manager
#[ "$CURRENTWM" = "xfwm4" ] && xfce-mcs-manager
#...no need to start it here, fvwm4 below will start it automatically.

#relocates right-side icons to actual right-side of screen...
/usr/sbin/fixPuppyPin $HOME/Choices/ROX-Filer/PuppyPin #v1.0.7

#w468 on old PCs this sometimes does not start, see further down...
 rox -p /root/Choices/ROX-Filer/PuppyPin

#rox -p=

#v2.0.0
else
 exec dbus-uuidgen --ensure &
fi


#v2.01 hide cursor when not moving... (setup in /usr/sbin/input-wizard)
_info "/etc/mousehide ..."
if [ -f /etc/mousehide ];then
 IDLETIME=`cat /etc/mousehide | cut -f 1 -d ','`
  _notice "IDLETIME='$IDLETIME' OR unclutter .."
 [ "$IDLETIME" = "0" ] || unclutter -idle $IDLETIME &
fi
_debug "LD_LIBRARY_PATH='$LD_LIBRARY_PATH'"
##v2.14 rarsa: update xdg menu for w.m. that do not allow includes...
#which ${CURRENTWM}_menu_refresh && ${CURRENTWM}_menu_refresh
#...no, now doing it differently, see /usr/sbin/fixmenus

#v2.17 removed, interferes with clipboard in Composer....
##v2.15 disovered by GuestToo...
#[ "`which glipper`" != "" ] && glipper &
#v2.17 made it optional...
[ -f /root/.glipper_on ] && glipper &

#v3.91 volume tray applet, thanks to hairywill... v3.96 MENU_BG variable...
if [ -f /usr/bin/absvolume ];then
 if [ "$MENU_BG" = "" ];then
  absvolume &
 else
  absvolume -bg $MENU_BG &
 fi
fi

__restart_rox__(){
#w468 rox may not start old hardware, try again...
PS="`ps`"
if [ "`echo "$PS" | grep 'ROX\-Filer'`" = "" ];then
 touch /tmp/roxfilerstartupproblem #see /sbin/pup_event_frontend_d
 sleep 0.2
 rox -p /root/Choices/ROX-Filer/PuppyPin
fi
}

case $CURRENTWM in enlightenment_start) :;; *)
( while :;do pidof ROX-Filer >>$OUT && break; rox -p /root/Choices/ROX-Filer/PuppyPin; sleep 1; done ) &
;; esac


#v4.01 BK daemon to handle kernel uevents...
#( /sbin/clean_desk_icons #v4.02 tidy up drive icons first.
( /sbin/pup_event_frontend_d ) & #v403

_debug "LD_LIBRARY_PATH='$LD_LIBRARY_PATH'"
(
if test ! -f $HOME/Startup/fbxkb*; then
setxkbmap -rules xorg -model pc102 -layout us,de -variant "" -option grp:rwin_toggle,lv3:ralt_switch
sleep 2s
which fbxkb >>$OUT && exec fbxkb &
fi
) &

_info "/usr/sbin/delayedrun &"
/usr/sbin/delayedrun &

if [ "$CURRENTWM" = "xfwm4" ];then
 if [ "`which xfce4-panel`" ];then
  xfwm4 --daemon #note, starts xfce-mcs-manager daemon also.
  exec xfce4-panel
 fi
fi

#v3.95 support fbpanel tray/taskbar...
#only launch tray for w.m. without inbuilt tray...
if [ "$CURRENTWM" != "jwm" -a "$CURRENTWM" != "icewm" ];then
 [ -f /usr/bin/fbpanel ] && fbpanel &
 [ -f /usr/bin/lxpanel ] && lxpanel &
fi

setxkbmap -rules xorg -model pc102 -layout us,de -variant "" -option grp:rwin_toggle,lv3:ralt_switch

_notice "LD_LIBRARY_PATH='$LD_LIBRARY_PATH'"

__old_exec_currentwm__(){
_notice "exec '$CURRENTWM'"
exec $CURRENTWM
#v2.11 GuestToo suggested this improvement...
which "$CURRENTWM" >>$OUT && exec $CURRENTWM
[ -x "$CURRENTWM" ] && exec $CURRENTWM
exec awesome
#sleep 180
#killall delayedrun
}

_start_currentwm(){
CURRENTWM="$*"
echo "$CURRENTWM" >/etc/windowmanager."$DISP"
$CURRENTWM & wmPID=$!
wait $wmPID
exit
}

if which "$CURRENTWM" >>$OUT; then
 _start_currentwm "$CURRENTWM"
elif [ -x "$CURRENTWM" ] ; then
 _start_currentwm "$CURRENTWM"
else
 _start_currentwm "$DEFAULTWM"
fi

###END###
