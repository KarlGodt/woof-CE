#!/bin/bash

DEVICE=/dev/ttyUSB0
[ $1 ] && DEVICE=$1
#become text mode
modem-stats -c AT+CMGF=1 $DEVICE

#get all messages
modem-stats -c AT+CMGL='"ALL"' $DEVICE
