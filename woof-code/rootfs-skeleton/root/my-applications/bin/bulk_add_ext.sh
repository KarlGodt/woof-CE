#!/bin/bash

files=`ls -1`

rm -f files_wo_ext.lst
echo "$files" |grep -v '\.[a-z0-9][a-z0-9][a-z0-9]$' >files_wo_ext.lst

N=`wc -l files_wo_ext.lst|cut -f 1 -d ' '`

for i in `seq 1 1 $N`;do
FILE=`sed -n "$i p" files_wo_ext.lst`;
echo "$FILE"; file "$FILE";

FLASH=`file "$FILE" | grep -E -i 'flash'`;
[ "$FLASH" ] && mv "$FILE" "$FILE".flv;FLASH='';

MP4=`file "$FILE" | grep -E -i 'mpeg|mp4'`;
[ "$MP4" ] && mv "$FILE" "$FILE".mp4;MP4='';

done


