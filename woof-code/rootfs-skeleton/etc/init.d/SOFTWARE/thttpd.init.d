#!/bin/sh

### BEGIN INIT INFO
# Provides:          thttpd
# Required-Start:    $network $remote_fs
# Required-Stop:     $network $remote_fs
# Should-Start:
# Should-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Starts tiny/turbo/throttling HTTP server
# Description:       thttpd is a small, fast secure webserver.
### END INIT INFO

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
#DAEMON=/usr/sbin/thttpd
DAEMON=/usr/local/sbin/thttpd
DESC="web server"
NAME=thttpd

DEFAULTS=/etc/default/thttpd
CONFFILE=/etc/thttpd/thttpd.conf
PIDFILE=/var/run/thttpd.pid
OPTIONS="-C $CONFFILE -i $PIDFILE"

test -x $DAEMON || exit 0
echo $LINENO
test -f $CONFFILE || exit 1
echo $LINENO

#
#  Read the defaults file if present
#
if [ -s $DEFAULTS ]; then
    echo $LINENO
    . $DEFAULTS

    if [ "x$ENABLED" != "xyes" ]; then
        echo $LINENO
        exit 0
    fi
fi


set -e

case "$1" in
	start)
		echo -n "Starting $DESC: "
		start-stop-daemon -S -q -p $PIDFILE -x $DAEMON --oknodo -- $OPTIONS
		if [ "$?" == '0' ]; then
		echo "$NAME ."
		else
		echo "failed to start $NAME"
		fi
		;;

	stop)
		echo -n "Stopping $DESC: "
		start-stop-daemon -K -q -p $PIDFILE -x $DAEMON --oknodo --signal 10
		RET_VAL=$?
		if [ "$RET_VAL" = '0' ];then
		echo "$NAME."
		else
		echo "start-stop-daemon -K -q -p $PIDFILE -x $DAEMON --oknodo --signal 10
		returned with '$RET_VAL'"
		fi
		;;

	force-stop)
		echo -n "Stopping $DESC: "
		start-stop-daemon -K -q -p $PIDFILE -x $DAEMON
		echo "$NAME."
		;;

	force-reload)
		if start-stop-daemon -K -q -p $PIDFILE -x $DAEMON --test
		then
			$0 restart
		fi
		;;

	restart)
		$0 stop
		sleep 1
		$0 start
		;;

	*)
		N=/etc/init.d/$NAME
		echo "Usage: $N {start|stop|force-stop|restart|force-reload}" >&2
		exit 1
		;;
esac

exit 0
