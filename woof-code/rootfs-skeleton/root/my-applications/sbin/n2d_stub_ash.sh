#!/bin/ash

###
#
# new2dir stub
#
###

echo "$0:'$*'"
$*

RUN_FLAG=$((RUN_FLAG+1))
export RUN_FLAG

if [ $RUN_FLAG = 1 ];then
echo "$0:'$*'"
$0 $*
fi

n2d_stub_ash_2.sh $*
