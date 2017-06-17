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

 echo monitor

while [ 1 ]; do
read -t 1 REPLY
echo "$REPLY" >>/tmp/cf_watch_monitor.txt
sleep 0.1
done

