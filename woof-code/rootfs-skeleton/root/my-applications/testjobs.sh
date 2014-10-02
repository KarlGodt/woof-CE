#!/bin/bash

func_tion(){
while :
do
xmessage -timeout 2 "HELLO" &
echo $0 running.
pidof ${0##*/}
sleep 1s
echo

jobs
jobs -r
jobs -s
echo
done
}

func_tion
