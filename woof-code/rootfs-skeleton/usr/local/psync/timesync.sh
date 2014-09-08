#!/bin/bash
#Psync Time Synchroniser Autorun 
#Synchronises system and hardware clock to a public time server
#Robert Lane 2010 (tasmod)

TIMEPLACE=`cat /usr/local/psync/setcountry | tail -n 1`

 exec /usr/local/psync/psyncfunc $TIMEPLACE