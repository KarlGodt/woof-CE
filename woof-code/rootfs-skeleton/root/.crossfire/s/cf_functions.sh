#!/bin/ash


_use_skill(){

echo watch $DRAW_INFO

local c=0
local NUM=$NUMBER

while :;
do
:

echo issue 1 1 use_skill "$*"

test "$NUMBER" && { NUM=$((NUM-1)); test "$NUM" -le 0 && break; } || { c=$((c+1)); test "$c" = 99 && break; }

sleep 1

done

echo unwatch $DRAW_INFO

sleep 1

}
