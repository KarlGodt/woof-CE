#!/bin/ash

source /etc/rc.d/PUPSTATE

RDEV_FUNC(){
while [ -z "$PDEV1flag" ] ; do  ##+++2011_10_28
DEVPDEV1=`busybox rdev | cut -f 1 -d ' '`  ##+2011_10_28 changed position to top
DEVROOTDRIVE="$DEVPDEV1" ##+2011_10_28 changed position to second
DEV1FS=`mount | grep ^[\ \"\'\/]*dev/root | cut -f 5 -d ' ' |tr -d \'\"`  ##+2011_10_28 changed position to third
#PDEV1=`basename "$DEVPDEV1"`
PDEV1="${DEVPDEV1##*/}"
ROOTDRIVE="$PDEV1"
if [ -z "`echo "$PDEV1" | grep '^[shmf]'`" ] ; then  ##+++2011_10_28
PDEV1flag=''
head -n 5 /proc/partitions
UPDATINGDEV_FUNC
else
echo -e "\\033[1;32m""Root device is /dev/$PDEV1""\\033[0;39m"
PDEV1flag='yes'
fi  ##+++2011_10_28
PDEV1flagCount=$((PDEV1flagCount+1))
[ "$PDEV1flagCount" -gt "10" ] && break  ##precaution to prevent neverending loop
sleep 1s
done  ##+++2011_10_28
}

ERRFLG_FUNC() {  ###KRG
echo -e "\\033[1;34m"'Checking for unpropper previous shutdown  ... '"\\033[0;39m"
echo -n -e "\\033[1;33m"'Searching for *fsckme* file 3 levels deep ... '"\\033[0;39m"
#ErrFlag=`busybox find / -maxdepth 3 -type f -iname '*fsckme*' | head -n1`  ###KRG 3 deep for fsckme.file@etc @boot @$HOME ..etc..
if [ -z "$ErrFlag" ] ; then  ##1
echo -e "\\033[56G\\033[1;5;32m"'Hurray , not found !'"\\033[0;39m"

LANG=C
todayY=`date +%Y`;[ "$todayY" ] || todayY='9999'
todayM=`date +%m | sed 's/^0//'`;[ "$todayM" ] || todayM=12
todayD=`date +%d | sed 's/^0//'`;[ "$todayD" ] || todayD='1'
#todayYDN=`date +%j`;[ "$todayYDN" ] || todayYDN=100
todayYDN=`date +%j |sed 's%^0*%%'`;[ "$todayYDN" ] || todayYDN=100

echo "
todayY='$todayY'
todayM='$todayM'
todayD='$todayD'
todayYDN='$todayYDN'
"

monthN=`for i in $(seq 1 12) ; do cal $i 1 | head -n 1 | grep -o '[[:alpha:]]*' | sed "s/^/$i /"; done`
monthT=`echo "$monthN" | grep -w "^$todayM"`
montTN=`echo "$monthT" | cut -f 1 -d ' '`
montTO=`echo "$monthT" | cut -f 2 -d ' '`

echo "monthN=$monthN"
echo "monthT='$monthT'"
echo "monthTN='$montTN'"
echo "montTO='$montTO'"

#funcs:

func_next_check(){
nextcY=`echo "$nextch" |awk '{print $1}'`;[ "$nextcY" ] || nextcY=2038
nextcM=`echo "$nextch" |awk '{print $2}'`;[ "$nextcM" ] || nextcM='Dec'
nextcD=`echo "$nextch" |awk '{print $3}'`;[ "$nextcD" ] || nextcD='31'
}
func_last_check(){
lastcY=`echo "$lastch" |awk '{print $1}'`;[ "$lastcY" ] || lastcY=1902
lastcM=`echo "$lastch" |awk '{print $2}'`;[ "$lastcM" ] || lastcM='Dec'
lastcD=`echo "$lastch" |awk '{print $3}'`;[ "$lastcD" ] || lastcD='31'
}


func_mount_count(){
    #echo "mntcnt=$mntcnt maxmnt=$maxmnt"
diffMC=$(( $maxmnt - $mntcnt ));
}

func_check_maxmnt(){
    #echo "mntcnt=$mntcnt maxmnt=$maxmnt"
if [ "$mntcnt" -ge "$maxmnt" ] ; then  ##1
echo -e "\\033[1;33m"'Maximum mount count reached'"\\033[0;39m"
FSCK='yes';fi
}

func_thirties(){
montCN=`echo "$monthC" | cut -f 1 -d ' '`
montCO=`echo "$monthC" | cut -f 2 -d ' '`
val30C=`cal $montCN 1 | grep '[[:digit:]]$' | sed '/^$/d' | tail -n 1 | grep -o '[[:digit:]]*$'`


##+++
val30B=0
for i in `seq $((montCN+1)) $((montTN-1))` ; do
val30i=`cal $i 1 | grep '[[:digit:]]$' | sed '/^$/d' | tail -n 1 | grep -o -e '[[:digit:]]*$'`
val30B=$((val30B+val30i))
done
###+++

val30T=`cal $montTN 1 | grep '[[:digit:]]$' | sed '/^$/d' | tail -n 1 | grep -o '[[:digit:]]*$'`
}

func_compare(){
echo -e "\\033[0;39m"
FSCK=''
echo "$mntcnt -ge $maxmnt"
if [ "$mntcnt" -ge "$maxmnt" ] ; then  ##1
echo -e "\\033[1;33m"'Maximum mount count reached'"\\033[0;39m"
FSCK='yes'
else ##1
  echo "$todayY -ge $nextcY"
  if [ "$todayY" -ge "$nextcY" ] ; then    #2
   echo  "$montTN = $montCN"
   if [ "$montTN" = "$montCN" ] ; then     #3
    echo "$todayD -ge $nextcD"
    if [ "$todayD" -ge "$nextcD" ] ; then  #4 ##+-2012-05-24 changed -gt to -ge
echo -e "\\033[1;33m"'Day interval reached'"\\033[0;39m"
FSCK='yes'
    fi #4
   else #3
    echo "$montTN -gt $montCN"
    if [ "$montTN" -gt "$montCN" ] ; then #5
     MinusTD=$todayD
     PlusCD=$(( $val30C - $nextcD ))
     SUM=$(( $MinusTD + $val30B + $PlusCD ))
      if [ "$SUM" -ge "$ckdays" ] ; then  #6 ##+-2012-05-24 changed -gt to -ge  ##+-2013-08-10 OLD BUG was interN instead ckdays
       echo -e "\\033[1;33m"'Day interval reached'"\\033[0;39m"
       FSCK='yes'
      fi #6
    fi #5 "$montTN" -gt "$montCN"
   fi #3 "$montTN" = "$montCN"
  fi #2 "$todayY" -ge "$nextcY"
fi #1 "$mntcnt" -ge "$maxmnt"
}

func_notify(){
if [ -z "$FSCK" ] ; then #8
  echo -e "\\033[1;32m"'OK , '"\\033[0;32m""next check '$nextcM $nextcD' or in '$diffMC' mounts""\\033[0;39m"
  echo -e "\\033[0;39m"
  BUSYBOX_INIT_FUNC
                    else #8
   if [ "$TIME_ELAPSED" ];then
  echo -e "\\033[1;33m"'Filesystem check interval reached :'"\\033[0;39m"
  echo -e "\\033[0;33m"'Today : '"\\033[0;33m""$montTO $todayD""\\033[0;33m"' , next check was or would be : '"\\033[0;33m""$nextcM  $nextcD""\\033[0;33m"
   elif [ "$MAX_MOUNT_COUNT" ];then
  echo -e "\\033[0;33m"'mount intervals : '"\\033[0;33m""$mntcnt""\\033[0;33m"' of '"\\033[0;33m""$maxmnt"
   else
  echo -e "\\033[0;33m"'File System Apparently marked unclean'
   fi
  echo -e "\\033[0;39m"
fi #8                    #8
}

                  if [ "`echo "$DEV1FS" |grep -Ei 'ext[234]'`" ];then #1.5
echo -e "\\033[1;33m"'Checking for filesystem check intervals using'"\\033[0;39m"
VARS=`dumpe2fs -h $DEVROOTDRIVE | grep -E 'Maximum mount count|Mount count|Next check after|Check interval'`  ##+2013-07-07 added -h option to dumpe2fs
nextch=`echo "$VARS" | grep 'Next check after:' |cut -f2- -d':' |awk '{print $5" "$2" "$3}'`;[ "$nextch" ] || nextch="Next check after:         Sun Dec 31 17:51:27 9999"
func_next_check

mntcnt=`echo "$VARS" | grep 'Mount count:' |cut -f 2 -d ':' |awk '{print $1}'`;[ "$mntcnt" ] || mntcnt='1'
maxmnt=`echo "$VARS" | grep 'Maximum mount count:' |grep -o '[[:digit:]]' |tr -d '\n'`;[ "$maxmnt" ] || maxmnt=999
#func_mount_count
func_check_maxmnt
func_mount_count

monthC=`echo "$monthN" | grep -e "^[0-9]* $nextcM.*"`
func_thirties
#func_compare

#NEW*
#ckday=`echo "$VARS" |grep 'Check interval:' |cut -f2 -d ':' |awk '{print $1}'`
#chdays=$((checkday/60/60/24))
#chdays=$((ckday/60/60/24))
nextckYDN=`date --d="$montCN"/"$nextcD"/"$nextcY" +%j |sed 's%^0*%%'`
echo "todayY=$todayY'"
if [ "$nextcY" -gt $((todayY+1)) ];then
  echo "$nextcY -gt $((todayY+1))"
  part_1=$nextckYDN
for i in `seq $nextcY -1 $todayY`;do
[ $i = $todayY ] && break
  part_2=$((part_2+365))
done
  part_3=$((365-todayYDN))
  time_elapsed=$((part_1+part_2+part_3))
elif [ "$nextcY" -eq $((todayY+1)) ];then
     echo "$nextcY -eq $((todayY+1))"
     part_1=$nextckYDN
     echo "part_1=$part_1' nextckYDN=$nextckYDN' todayYDN=$todayYDN'"
     part_3=$((365-todayYDN))
     echo "part_3=$part_3'"
     time_elapsed=$((part_1+part_3))
     echo "time_elapsed=$time_elapsed'"
elif [ "$nextcY" -eq $todayY ];then
  echo "$nextcY -eq $todayY"
  time_elapsed=$((nextckYDN-todayYDN))  ##+++2013-07-07 BUG was nextYDN , should have been nextckYDN
fi

###+++2013-07-07
ckdays=`echo "$VARS" | grep 'Check interval:' | awk '{print $3}'`
 ckdays=$(($ckdays/60/60/24))
###+++2013-07-07
 #if [ $time_elapsed -ge $ckdays ];then
  if [ $time_elapsed -gt $ckdays ];then ##+-2013-08-10 180er problematic
       FSCK=yes;TIME_ELAPSED=yes
   fi

func_notify

else

:

fi

fi ##1
}

RDEV_FUNC
ERRFLG_FUNC
