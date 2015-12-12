#!/bin/sh
# $Xorg: xinitrc.cpp,v 1.3 2000/08/17 19:54:30 cpqbld Exp $

echo "$PPID:$$:$0:'$LINENO' `date`"
PROG='/root/.xinitrc'
DEFAULTWM=jwm

. /etc/rc.d/PUPSTATE

if [ -f /root/.jwm/jwm_colors ];then #v3.96
. /root/.jwm/jwm_colors
fi

#w482 reshape background image if widescreen...
[ $PUPMODE -eq 5 ] && /usr/sbin/background_reshape

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/usr/lib/X11/xinit/Xresources
sysmodmap=/usr/lib/X11/xinit/.Xmodmap

# merge in defaults and keymaps

[ -f "$sysresources" ]  && xrdb -merge -nocpp $sysresources
[ -f "$userresources" ] && xrdb -merge -nocpp $userresources
[ -f "$sysmodmap" ]     && xmodmap $sysmodmap
[ -f "$usermodmap" ]    && xmodmap $usermodmap

read CURRENTWM </etc/windowmanager
test "$CURRENTWM" || CURRENTWM=$DEFAULTWM
which $CURRENTWM  || CURRENTWM=jwm
case "$CURRENTWM" in "startkde")
 exec startkde;;
esac


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
  XYDEFAULT="`xrandr | grep '\*' | tr -s " " | grep '^ [0-9]' | cut -f 2 -d " " | head -n 1`"
  XRANDRINDEX="`cat /etc/xrandrindex`" #v3.99 XRANDRINDEX now is XxY resolution.
  #but do not switch if default is already this resolution....
  if [ "$XRANDRINDEX" = "$XYDEFAULT" ];then
   rm -f /etc/xrandrindex
  else
   xrandr -s $XRANDRINDEX
  fi
fi


if [ -f /root/.xset.sh ];then
 #this is created by /usr/bin/pupx...
 eval "/root/.xset.sh"
else
 ##Xorg has it's own fontpath settings in /etc/X11/xorg.conf...
 #if [ "`readlink /usr/bin/X`" != "Xorg" ];then
 # #xset fp+ /usr/lib/X11/fonts/Type1/
 # #xset fp+ /usr/lib/X11/fonts/TTF/
 # xset fp+ /usr/share/fonts/default/Type1/
 # xset fp+ /usr/share/fonts/default/TTF/
 #fi
 xset s 600 600 s blank
fi

#v1.0.7 also see /etc/rc.d/rc.local0
if [ -f /root/.fonts/fonts.dir ];then
 xset fp+ /root/.fonts/
fi

[ -f /usr/bin/xsetroot ] && xsetroot -cursor_name top_left_arrow

#v555 w003
#[ -f /usr/bin/xfce-mcs-manager ] && xfce-mcs-manager
#[ "$CURRENTWM" = "xfwm4" ] && xfce-mcs-manager
#...no need to start it here, fvwm4 below will start it automatically.

echo "CURRENTWM='$CURRENTWM'"
case "$CURRENTWM" in "enlightenment_start")
echo 'E17'
#pup_event_frontend_d stop &
exec pup_event_frontend_d restart &
pidof tempget && killall tempget
;;
*)
echo 'NOT E17'
/sbin/clean_desk_icons #v4.02 tidy up drive icons first.
#relocates right-side icons to actual right-side of screen...
/usr/sbin/fixPuppyPin $HOME/Choices/ROX-Filer/PuppyPin #v1.0.7
rox -p /root/Choices/ROX-Filer/PuppyPin

#v4.01 BK daemon to handle kernel uevents...
# daemon to manage drive icons on desktop
# (USB,Floppy,CD hotplug/insert events),
# also performs remaining free space checks on installation,
# :
exec /sbin/pup_event_frontend_d restart & #v403
;;
esac

#relocates right-side icons to actual right-side of screen...
#/usr/sbin/fixPuppyPin $HOME/Choices/ROX-Filer/PuppyPin #v1.0.7

#case $CURRENTWM in *enlightenment*) :;;
#*)
##w468 on old PCs this sometimes does not start, see further down...
#rox -p /root/Choices/ROX-Filer/PuppyPin
##rox -p=
#;;
#esac

#v2.0.0

#v2.01 hide cursor when not moving... (setup in /usr/sbin/input-wizard)
if [ -f /etc/mousehide ];then
 IDLETIME="`cat /etc/mousehide | cut -f 1 -d ','`"
 [ "$IDLETIME" = 0 ] || unclutter -idle $IDLETIME &
fi

##v2.14 rarsa: update xdg menu for w.m. that do not allow includes...
#which ${CURRENTWM}_menu_refresh && ${CURRENTWM}_menu_refresh
#...no, now doing it differently, see /usr/sbin/fixmenus

#v2.17 removed, interferes with clipboard in Composer....
##v2.15 disovered by GuestToo...
#[ "`which glipper`" != "" ] && glipper &
#v2.17 made it optional...
[ -f /root/.glipper_on ] && glipper &

if [ "$CURRENTWM" = "xfwm4" ];then
 if [ "`which xfce4-panel`" ];then
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

which retrovol && exec retrovol &

#v3.95 support fbpanel tray/taskbar...
#only launch tray for w.m. without inbuilt tray...
case "$CURRENTWM" in "jwm"|"icewm") :;;
*)
 [ -f /usr/bin/fbpanel ] && fbpanel &
 [ -f /usr/bin/lxpanel ] && lxpanel &
;;
esac

case $CURRENTWM in *enlightenment*) :;;
*)
##w468 rox may not start old hardware, try again...
PS="`ps`"
if [ "`echo "$PS" | grep 'ROX\-Filer'`" = "" ];then
 touch /tmp/roxfilerstartupproblem #see /sbin/pup_event_frontend_d
 sleep 0.2
 rox -p /root/Choices/ROX-Filer/PuppyPin
fi
;;
esac

#while [ this ] ; do
#setxkbmap -rules xorg -model pc102 -layout us,de -variant "" -option grp:rwin_toggle,lv3:ralt_switch
#[ $? = 0 ] && break || c=$((c+1))
#[ $c = 5 ] && break
#sleep 1
#done
#which fbxkb && (sleep 4s;fbxkb &)&

if [ -f $HOME/.xinitrc.private ]
then
$HOME/.xinitrc.private &
else
echo "using default: /usr/sbin/delayedrun"
/usr/sbin/delayedrun &
fi

dbus-uuidgen --ensure &
echo "$PPID:$$:$0:'$LINENO' `date`"
#strace setxkbmap -rules xorg -model pc102 -layout us,de -variant "" -option grp:rwin_toggle,lv3:ralt_switch 2>>setxkbmap.strace
#which fbxkb && (sleep 4s;fbxkb &)&
#(sleep 11s;setxkbmap -rules xorg -model pc102 -layout us,de -variant "" -option grp:rwin_toggle,lv3:ralt_switch;which fbxkb && fbxkb &)&

#******************************************************************************
# REM: JWM could have a wrong taskbar width set
#      if the monitor changes

# REM : sub functions first :
 _say_root_screen_width(){
    # dont know, use grep -m1 (head -n1) - I could be wrong som3e day...
  rootX=`xdpyinfo | grep -m1 'dimensions:' | awk '{print $2}' | cut -f 1 -d'x'`
    echo $rootX
 }

_say_jwm_taskbar_tray_line(){
    JWM_TRAY_=`grep '<Tray .* width="[0-9]*" .*>' "$HOME"/.jwmrc-tray | \
                 grep -vE '^#|^[[:blank:]]*#' | tail -n1`
echo "$JWM_TRAY_"
}

_say_jwm_taskbar_autohide(){
    JWM_TRAY_LINE=`_say_jwm_taskbar_tray_line`
    autohideJWMTASKB=`echo "$JWM_TRAY_LINE" | grep -o 'autohide="[^"]"' | cut -f2 -d'"'`
    echo "$autohideJWMTASKB"
}

_say_jwm_taskbar_border(){
    JWM_TRAY_LINE=`_say_jwm_taskbar_tray_line`
    borderJWMTASKB=`echo "$JWM_TRAY_LINE" | grep -o 'border="[0-9-]*"' | cut -f2 -d'"'`
    echo "$borderJWMTASKB"
}

_say_jwm_taskbar_height(){
    JWM_TRAY_LINE=`_say_jwm_taskbar_tray_line`
    heightJWMTASKB=`echo "$JWM_TRAY_LINE" | grep -o 'height="[0-9-]*"' | cut -f2 -d'"'`
    echo "$heightJWMTASKB"
}

_say_jwm_taskbar_tray_insert(){
    JWM_TRAY_LINE=`_say_jwm_taskbar_tray_line`
    trayinsertJWMTASKB=`echo "$JWM_TRAY_LINE" | grep -o 'insert="[^"]*"' | cut -f2 -d'"'`
    echo "$trayinsertJWMTASKB"
}

_say_jwm_taskbar_width(){
    JWM_TRAY_LINE=`_say_jwm_taskbar_tray_line`
    widthJWMTASKB=`echo "$JWM_TRAY_LINE" | grep -o 'width="[0-9-]*"' | cut -f2 -d'"'`
    echo "$widthJWMTASKB"
}

_say_jwm_taskbar_x(){
    JWM_TRAY_LINE=`_say_jwm_taskbar_tray_line`
    xJWMTASKB=`echo "$JWM_TRAY_LINE" | grep -o 'x="[0-9-]*"' | cut -f2 -d'"'`
    echo "$xJWMTASKB"
}

_say_jwm_taskbar_y(){
    JWM_TRAY_LINE=`_say_jwm_taskbar_tray_line`
    yJWMTASKB=`echo "$JWM_TRAY_LINE" | grep -o 'y="[0-9-]*"' | cut -f2 -d'"'`
    echo "$yJWMTASKB"
}

_manage_jwm_taskbar_width(){

    # REM: Get the current JWM taskbar (tray) width setting
      JWM_TRAY_=`grep '<Tray .* width="[0-9]*" .*>' "$HOME"/.jwmrc-tray | \
                 grep -vE '^#|^[[:blank:]]*#' | tail -n1`
   widthJWM_TRAY=`echo "$JWM_TRAY_" | grep -o 'width="[0-9]*"' | cut -f2 -d'"'`
    [ "$widthJWM_TRAY" ]                 || { echo "widthJWM_TRAY has no content ";return 4; }
    [ "${widthJWM_TRAY//[[:digit:]]/}" ] && { echo "widthJWM_TRAY has incorrect content ";return 4; }
    # "0" means fit to screen :
    [ "${widthJWM_TRAY}" == "0" ]        && { echo "widthJWM_TRAY is set 0 ";return 4; }

    # REM: get the current root screen width (max x)
    WIDTH_ROOT=`_say_root_screen_width`
    [ "$WIDTH_ROOT" ]                 || { echo "WIDTH_ROOT has no content ";return 5; }
    [ "${WIDTH_ROOT//[[:digit:]]/}" ] && { echo "WIDTH_ROOT has incorrect content ";return 5; }

    if test $WIDTH_ROOT -lt $widthJWM_TRAY; then

    # need to check x too
    jwmTRAYX=`_say_jwm_taskbar_x`
    test "$jwmTRAYX"                 || { echo "jwmTRAYX has no content ";return 6; }
    test "${jwmTRAYX//[[:digit:]]/}" && { echo "jwmTRAYX has incorrect content ";return 6; }


    test "$jwmTRAYX" -ge $WIDTH_ROOT && jwmTRAYX=0 # reset to be usefull
    test "$jwmTRAYX" -lt 0           && jwmTRAYX=0

    NEWwidthJWM_TRAY=$((WIDTH_ROOT-jwmTRAYX))

    sed -i".xinitrc-backup" \
  "s/\(<Tray .*\) width=\"$widthJWM_TRAY\"/\1 width=\"$NEWwidthJWM_TRAY\"/" \
           "$HOME"/.jwmrc-tray
    fi

}
#******************************************************************************

# REM:
# Monitor could have changed with different resolution ...
case "$CURRENTWM" in jwm)
    [ -e /etc/system.jwmrc ] || cp $VERB -a /root/.jwmrc /etc/system.jwmrc ;
    if test -f "$HOME"/.jwmrc-tray; then
    _manage_jwm_taskbar_width
    fi
   ;;
esac

if which ${CURRENTWM##*/}; then
# REM:
# Update /etc/windowmanager if CURRENTWM has changed until here ..
# Otherwise some /usr/bin/wm* scripts would probably not work ..
echo ${CURRENTWM##*/} >/etc/windowmanager
exec ${CURRENTWM##*/}
else
echo 'CURRENTWM unset or not in PATH'
echo '.xinitrc error' >/tmp/wmexitmode.txt
echo '.xinitrc error' >/tmp/xwin/wmexitmode.txt
exit 66
fi

#v2.11 GuestToo suggested this improvement...
#which $CURRENTWM && exec $CURRENTWM
#[ -x $CURRENTWM ] && exec $CURRENTWM
#exec awesome

###END##
