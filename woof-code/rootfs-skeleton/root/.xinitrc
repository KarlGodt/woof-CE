#!/bin/sh
# $Xorg: xinitrc.cpp,v 1.3 2000/08/17 19:54:30 cpqbld Exp $

PROG='/root/.xinitrc'

. /etc/rc.d/PUPSTATE
. /etc/rc.d/f4puppy5

DEFAULTWM=jwm
test -f /etc/windowmanager || echo "$DEFAULTWM" >/etc/windowmanager
read CURRENTWM  </etc/windowmanager

_info "CURRENTWM='$CURRENTWM'"


if [ -d /root/Choices/XINIT ]; then
for file in /root/Choices/XINIT/*; do
#source /root/Choices/XINIT/bb_acpi start &
[ -f "$file" -a -r "$file" ] && {
_info  "source ing '$file'"
. "$file" start &
sleep 0.1
}
done; fi

#v4.01 BK daemon to handle kernel uevents...
_pidof /sbin/pup_event_frontend_d && {
exec /sbin/pup_event_frontend_d restart &
    } || {
exec /sbin/pup_event_frontend_d start & #v403
}

if [ "$CURRENTWM" = "startkde" ]; then
 exec startkde
elif [ "$CURRENTWM" != "enlightenment_start" ] ; then
_info 'NOT E17'
#relocates right-side icons to actual right-side of screen...
/usr/sbin/fixPuppyPin $HOME/Choices/ROX-Filer/PuppyPin #v1.0.7
rox -p /root/Choices/ROX-Filer/PuppyPin
else
_info 'E17'
exec dbus-uuidgen --ensure &
fi

__keyboard__(){
setxkbmap -rules xorg -model pc102 -layout us,de -variant "" -option grp:lwin_toggle,lv3:ralt_switch
fbxkb &
}

# REM: Lupu Puppy 528 with openbox wm
case $CURRENTWM in
*openbox*) if which fbpanel >>$OUT; then
            #a bit of a hack: when 3builddistro runs fixmenus, which calls variconlinks,
            #which populates /var/local/icons with symlinks, /usr/local/lib/X11/pixmaps
            #is not yet populated (happens at first boot, from default icon theme)...
            [ -e /var/local/icons/home48.png ] || ln -fs /usr/local/lib/X11/pixmaps/* /var/local/icons/
            exec fbpanel &
           fi
           if which lxpanel >>$OUT; then
            exec lxpanel &
           fi
;;
jwm|icewm|startxfce4|startfluxbox) :
;;
esac



#v2.11 GuestToo suggested this improvement...
# test CURRENTWM in PATH:
which $CURRENTWM  && { echo "$CURRENTWM" >/etc/windowmanager; exec $CURRENTWM; }
# CURRENTWM not in PATH but executable:
[ -x $CURRENTWM ] && { echo "$CURRENTWM" >/etc/windowmanager; exec $CURRENTWM; }
# Fallback if both of the two above do not work ( typo in 'xwin icwm' for example )
#exec awesome
test "$DEFAULTWM" || DEFAULTWM=jwm
echo "$DEFAULTWM" >/etc/windowmanager
exec $DEFAULTWM
# If wm fails( not found ), then print error message
echo "$0:Could neither start CURRENTWM '$CURRENTWM' nor DEFAULTWM '$DEFAULTWM'" >/tmp/xinitrc.err

###END##
