#!/bin/ash

exec 2>/tmp/cf_script.err

DRAW_INFO=drawinfo # drawextinfo



while :;
do

c=0
while :;
 do
  echo issue 0 0 pray
  sleep 1
  c=$((c+1)); test "$c" = 50 && break
 done

 echo issue 0 1 cast regeneration
 sleep 1
 echo issue 1 0 fire 0
 sleep 0.5
 echo issue 1 1 fire_stop

 sleep 1

 echo issue 0 0 apply -a horn of Plenty
 sleep 1
 echo issue 0 0 fire 0
 sleep 0.5
 echo issue 1 1 fire_stop

 sleep 1

 echo issue 1 1 cast restoration
 sleep 1
 echo issue 1 1 fire 0
 sleep 0.5
 echo issue 1 1 fire_stop


sleep 1
done
