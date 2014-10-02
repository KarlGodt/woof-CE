#!/bin/ash


exec 1>/tmp/ash.f.log

func_1(){

for i in `seq 1 10` ; do

export eval echo PARAM$i=$(( $i * 10 ))

done

}

func_1

echo

func_2(){

for i in `seq 1 10` ; do

eval echo PARAM$i = \$PARAM$i

done

}

func_2

echo

exec 1>/tmp/ash.s.log

echo

func_1

echo

func_2

echo

exec 1>>/tmp/ash.f.log

echo

func_1

echo

func_2

echo



