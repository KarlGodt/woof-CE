#!/bin/sh
######################
### Batch diff in directory
### Oct 08 2011
######################

Time=`date +%Y_%m_%d-%H:%M`
F1=`find . -maxdepth 1 -type f | sort -g`
F2=`echo "$F1" | sed '$ d'`
F3=`echo "$F1" | sed '1 d'`
echo "$F2"
echo 
echo $F3
count=0
for content in $F2 ; do
count=$((count+1))
diff1="$content"
diff2=`echo "$F3" | sed -n "$count p"`
echo $diff1
echo $diff2
diff -uaNd $diff1 $diff2 >> batch.$Time.diff
done


