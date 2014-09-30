#!/bin/bash

#become text mode
modem-stats -c AT+CMGF=1 /dev/ttyUSB0

#modem-stats -c AT+CMGL=? /dev/ttyUSB0
#CMGL: ("REC UNREAD","REC READ","STO UNSENT","STO SENT","ALL")

#get all messages
modem-stats -c AT+CMGL='"ALL"' /dev/ttyUSB0
