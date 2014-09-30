#!/bin/bash

modem-stats -c AT+CPBR=? /dev/ttyUSB0
HOW_MANY_ENTRIES=`modem-stats -c AT+CPBR=? /dev/ttyUSB0 |grep '^\+' |grep -oe '\([0-9]*\-[0-9]*\)'`
F_ENTRY=${HOW_MANY_ENTRIES%\-*}
L_ENTRY=${HOW_MANY_ENTRIES#*\-}

[ "$F_ENTRY" -a "$L_ENTRY" ] || { echo "Something wrong";exit 1; }

#for e in { ${F_ENTRY} .. ${L_ENTRY} };do
#for e in {${F_ENTRY}..${L_ENTRY}};do
#for e in {$F_ENTRY..$L_ENTRY};do
for e in `seq $F_ENTRY 1 $L_ENTRY`;do

echo $e
echo $e >>/my_sim_phonebook_entries.txt
timeout -t 6 modem-stats -c AT+CPBR=$e /dev/ttyUSB0  >>/my_sim_phonebook_entries.txt
echo '#-------#' >>/my_sim_phonebook_entries.txt

done
