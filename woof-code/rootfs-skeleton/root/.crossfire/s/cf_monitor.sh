#!/bin/ash


mv -f /tmp/cf_watch_monitor.txt /tmp/cf_watch_monitor.txt.0

#  echo watch

## echo monitor issue ## monitor does not notice additional parameter like watch

# * monitor
# *   send the script a copy of every command that is sent to the server.
# *
# * unmonitor
# *   turn off monitoring.

# void script_monitor(const char *command, int repeat, int must_send)
#  snprintf(buf, sizeof(buf), "monitor %d %d %s\n",repeat,must_send,command);
#
# void script_monitor_str(const char *command)
#  snprintf(buf, sizeof(buf), "monitor %s\n",command);

# else if ( strncmp(cmd,"monitor",7)==0 )   scripts[i].monitor=1;
# else if ( strncmp(cmd,"unmonitor",9)==0 ) scripts[i].monitor=0;

# *** Here begins program *** #
echo draw 2 "$0 is started.."

 echo monitor

while [ 1 ]; do
read -t 1 REPLY
echo "$REPLY" >>/tmp/cf_watch_monitor.txt
case $REPLY in
*scripttell*)
 case $REPLY in *exit*|*quit*|*break*) break;;
 esac
 ;;
esac
sleep 0.1
done

# unreached: scriptkill to terminate
# *** Here ends program *** #
echo draw 2 "$0 is finished."
beep -l 500 -f 700
