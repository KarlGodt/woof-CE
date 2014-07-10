#!/bin/sh
# /etc/acpi/powerbtn.sh
# Initiates a shutdown when the power putton has been
# pressed.

# getXuser gets the X user belonging to the display in $displaynum.
# If you want the foreground X user, use getXconsole!
getXuser() {
        user=`pinky -fw | awk '{ if ($2 == ":'$displaynum'" || $(NF) == ":'$displaynum'" ) { print $1; exit; } }'`
        if [ x"$user" = x"" ]; then
                startx=`pgrep -n startx`
                if [ x"$startx" != x"" ]; then
                        user=`ps -o user --no-headers $startx`
                fi
        fi
        if [ x"$user" != x"" ]; then
                userhome=`getent passwd $user | cut -d: -f6`
                export XAUTHORITY=$userhome/.Xauthority
        else
                export XAUTHORITY=""
        fi
        export XUSER=$user
}

# Skip if we just in the middle of resuming.
test -f /var/lock/acpisleep && exit 0

# If the current X console user is running a power management daemon that
# handles suspend/resume requests, let them handle policy This is effectively
# the same as 'acpi-support's '/usr/share/acpi-support/policy-funcs' file.

getXconsole
PMS="gnome-power-manager kpowersave xfce4-power-manager"
PMS="$PMS guidance-power-manager.py dalston-power-applet"

if pidof x $PMS > /dev/null ||
	( test "$XUSER" != "" && pidof dcopserver > /dev/null && test -x /usr/bin/dcop && /usr/bin/dcop --user $XUSER kded kded loadedModules | grep -q klaptopdaemon) ||
	( test "$XUSER" != "" && test -x /usr/bin/qdbus && test -r /proc/$(pidof kded4)/environ && su - $XUSER -c "eval $(echo -n 'export '; cat /proc/$(pidof kded4)/environ |tr '\0' '\n'|grep DBUS_SESSION_BUS_ADDRESS); qdbus org.kde.kded" | grep -q powerdevil) ; then
    exit
fi

# If all else failed, just initiate a plain shutdown.
/sbin/shutdown -h now "Power button pressed"
