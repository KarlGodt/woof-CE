#!/bin/bash


echo "$0 START"

F=`cat /proc/partitions`
F=`echo "$F" | sed 's/^major.*//g'`
F=`echo "$F" | sed "/^$/d"`
#F=`echo "$F" | sed "s/^/'/;s/$/'/"`

#for i in $F; do

#MAJ=`echo $i | cut -f 1 -d ' '`
#Min=`echo $i | cut -f 2 -d ' '`
#DEV=`echo $i | cut -f 4 -d ' '`

#rm -f /dev/$DEV
#mknod /dev/$DEV b $MAJ $Min

#done

rescue(){
echo "$F" | while read maj min siz dev ; do
echo "maj=$maj min=$min siz=$siz dev=$dev"
[ -z "$dev" ] && continue
rm /dev/$dev
mknod /dev/$dev b $maj $min
done
}

hitachi_500_16(){
mknod /dev/hda   b 259       0 #first
mknod /dev/hda16 b 259   32768 # 1/1 last

mknod /dev/hda8  b 259   65536 # 2/1 last  2|8  hda1/hda8
mknod /dev/hda4  b 259  131072 # 4/1 last  4|4  hda1/hda4 1/25 1/4
mknod /dev/hda2  b 259  262144 # 8/1 last  8|2  hda1/hda2 1/50 1/2
mknod /dev/hda12 b 259  196608 # 6/1 last  6|12 hda1-hda10
mknod /dev/hda10 b 259  327680 #10/1 last 10|10 hda1-hda6
mknod /dev/hda6  b 258  393216 #12/1 last 12|6  hda1-hda4
mknod /dev/hda14 b 259  458752 #14/1 last 14|14 hda1-hda8
mknod /dev/hda1  b 259  524288 #16/1 last 16|1  hda1=$(( $last * $partitionNrMax[16] }}
mknod /dev/hda9  b 259  589824 #18/1 last 18|9  hda1+hda8
mknod /dev/hda5  b 259  655360 #20/1 last 20|5  hda1+hda4 1/20 1/5
mknod /dev/hda3  b 259  786432 #24/1 last 24|3  hda1+hda2
mknod /dev/hda11 b 259  851968 #26/1 last 26|11 hda10+hda1
mknod /dev/hda7  b 259  917504 #28/1 last 28|7  hda1+hda6 hda4*7
mknod /dev/hda15 b 259  983040 #30/1 last 30|15 hda1+hda14 hda5+hda10 1/30  5+10


mknod /dev/sda  b 259  557056 #teak        hda9-32768
mknod /dev/sda1 b 259  294912 #teak 1part  hda2+32768
mknod /dev/sdb  b 259  819200 #teak cardr  hda11-32768
mknod /dev/sdc  b 259  425984 #EMtec cadr  hda14-32768
mknod /dev/sdc1 b 259  950272 #EMtec 1par  hda15-32768
mknod /dev/sdd  b 259  163840 #voda mmcsr  hda4+32768
mknod /dev/sdd1 b 259  688128 #voda 1part  hda5+32768
mknod /dev/sde  b 259   98304 #odys        1/10 hda15
mknod /dev/sde1 b 259  622592 #odys 1part  hda5-32768
mknod /dev/sdf  b 259  360448 #odys cardr  hda10+32768

}

echo "$0 END"
