#!/bin/ash

exec 2>/tmp/cf_script.err

DRAW_INFO=drawinfo # drawextinfo

SET_SPELL_REGENERATION=1 # set empty if prayer not avail
SET_SPELL_RESTAURATION=1 # set empty if prayer not avail

_invoke_regeneration(){
 test "$SET_SPELL_REGENERATION" || return 0
 #echo issue 0 1 cast regeneration
 #sleep 1
 #echo issue 1 0 fire 0
 #sleep 0.5
 #echo issue 1 1 fire_stop
 echo issue 1 1 invoke regeneration
}

_invoke_restauration(){
 test "$SET_SPELL_RESTAURATION" || return 0
 #echo issue 1 1 cast restoration
 #sleep 1
 #echo issue 1 1 fire 0
 #sleep 0.5
 #echo issue 1 1 fire_stop
 echo issue 1 1 invoke restoration


}

_fire_item(){
 local lITEM=${*:-'horn of plenty'}
 echo issue 0 0 apply -u $lITEM
 echo issue 0 0 apply -a $lITEM
 sleep 1
 echo issue 0 0 fire 0
 sleep 0.5
 echo issue 1 1 fire_stop
}

while :;
do

 c=0; d=0; e=0
 while :;
 do
  echo issue 0 0 pray
  sleep 1
  d=$((d+1)); if test "$d" = 5;  then use_skill hiding;          d=0; fi
  e=$((e+1)); if test "$e" = 10; then _fire_item horn of Plenty; e=0; fi
  c=$((c+1)); test "$c" = 50 && break
 done


 _invoke_regeneration
 sleep 1

 _fire_item horn of Plenty
 sleep 1

 _invoke_restauration

sleep 1
done
