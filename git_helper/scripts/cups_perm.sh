#!/bin/ash

. /etc/rc.d/f4puppy5

DEBUG=
[ "$WHERE" ] || WHERE=/

_create_db(){

#WHERE="$1"

_entry

rm -f /tmp/cups_perm.db

find $WHERE/etc -xdev -name "cups" |
while read oneCUPS
do
stat $oneCUPS
 [ -d "$oneCUPS" ] && {
  for aCUPS in `ls -A "$oneCUPS"`
  do
  stat $oneCUPS/$aCUPS
  done
 }
done >>/tmp/cups_perm.db

find $WHERE/usr -xdev -name "cups*" |
while read oneCUPS
do
stat $oneCUPS
 [ -d "$oneCUPS" ] && {
  for aCUPS in `ls -A "$oneCUPS"`
  do
  stat $oneCUPS/$aCUPS
  done
  }
done >>/tmp/cups_perm.db

find $WHERE/var -xdev -name "cups" |
while read oneCUPS
do
stat $oneCUPS
 [ -d "$oneCUPS" ] && {
  for aCUPS in `ls -A "$oneCUPS"`
  do
  stat $oneCUPS/$aCUPS
  done
  }
done >>/tmp/cups_perm.db

}

__compare__(){

test -f /tmp/cups_perm.db || {
echo "Creating data-base file ..."
_create_db "$WHERE"
}

for d in etc usr var
do
[ -d "$d" ] && { WHERE=`pwd`; break; }
cd .. || _exit 1 "No etc usr var directory"
done

pwd
sleep 5

unset FN PERM US GR
find $WHERE/etc -xdev -name "cups" |
while read oneCUPS
do
stat $oneCUPS |
   while read oneLINE
    do
    [ "$DEBUG" ] && echo "oneLINE='$oneLINE'"
     case "$oneLINE" in
      '') continue;;
      File:*) FN="`echo "$oneLINE" | awk '{print $2}'`"
      echo "FN='$FN'";;
      Access:*) [ "$PERM" ] || {
      PERM="`echo "$oneLINE" | awk '{print $2}'`"
      US="`echo "$oneLINE" | awk -F '[()]' '{print $4}'`"
      GR="`echo "$oneLINE" | awk -F '[()]' '{print $6}'`"
      echo "PERM='$PERM' US='$US' GR='$GR'"
        }
        ;;
      *) continue;;
      esac
    done

[ "$DEBUG" ] && echo "FN='$FN'"
unset FNDB PERMDB USDB GRDB
 grep $QUIET -w "$FN" /tmp/cups_perm.db && {
 grep -A3 -w "$FN" /tmp/cups_perm.db |
 while read aLINE
 do
[ "$DEBUG" ] && echo "aLINE='$aLINE'"
     case "$aLINE" in
      '') continue;;
      File:*) FNDB="`echo "$aLINE" | awk '{print $2}'`"
      echo "FNDB='$FNDB'";;
      Access:*) [ "$PERMDB" ] || {
      PERMDB="`echo "$aLINE" | awk '{print $2}'`"
      USDB="`echo "$aLINE" | awk -F '[()]' '{print $4}'`"
      GRDB="`echo "$aLINE" | awk -F '[()]' '{print $6}'`"
      echo "PERMDB='$PERMDB' USDB='$USDB' GRDB='$GRDB'"
        }
        ;;
      *) continue;;
      esac
 done
 }

 [ -d "$oneCUPS" ] && {
  for aCUPS in `ls -A "$oneCUPS"`
  do
  unset FN PERM US GR
  stat $oneCUPS/$aCUPS |
   while read oneLINE
    do
    [ "$DEBUG" ] && echo "oneLINE='$oneLINE'"
     case "$oneLINE" in
      '') continue;;
      File:*) FN="`echo "$oneLINE" | awk '{print $2}'`"
      echo "FN='$FN'";;
      Access:*) [ "$PERM" ] || {
      PERM="`echo "$oneLINE" | awk '{print $2}'`"
      US="`echo "$oneLINE" | awk -F '[()]' '{print $4}'`"
      GR="`echo "$oneLINE" | awk -F '[()]' '{print $6}'`"
      echo "PERM='$PERM' US='$US' GR='$GR'"
        }
        ;;
      *) continue;;
      esac
    done

[ "$DEBUG" ] && echo "FN='$FN'"
unset FNDB PERMDB USDB GRDB
 grep $QUIET -w "$FN" /tmp/cups_perm.db && {
 grep -A3 -w "$FN" /tmp/cups_perm.db |
 while read aLINE
 do
[ "$DEBUG" ] && echo "aLINE='$aLINE'"
     case "$aLINE" in
      '') continue;;
      File:*) FNDB="`echo "$aLINE" | awk '{print $2}'`"
      echo "FNDB='$FNDB'";;
      Access:*) [ "$PERMDB" ] || {
      PERMDB="`echo "$aLINE" | awk '{print $2}'`"
      USDB="`echo "$aLINE" | awk -F '[()]' '{print $4}'`"
      GRDB="`echo "$aLINE" | awk -F '[()]' '{print $6}'`"
      echo "PERMDB='$PERMDB' USDB='$USDB' GRDB='$GRDB'"
        }
        ;;
      *) continue;;
      esac
 done
 }

  done
 }
done

unset FN PERM US GR
find $WHERE/usr -xdev -name "cups*" |
while read oneCUPS
do
stat $oneCUPS |
   while read oneLINE
    do
    [ "$DEBUG" ] && echo "oneLINE='$oneLINE'"
     case "$oneLINE" in
      '') continue;;
      File:*) FN="`echo "$oneLINE" | awk '{print $2}'`"
      echo "FN='$FN'";;
      Access:*) [ "$PERM" ] || {
      PERM="`echo "$oneLINE" | awk '{print $2}'`"
      US="`echo "$oneLINE" | awk -F '[()]' '{print $4}'`"
      GR="`echo "$oneLINE" | awk -F '[()]' '{print $6}'`"
      echo "PERM='$PERM' US='$US' GR='$GR'"
        }
        ;;
      *) continue;;
      esac
    done

[ "$DEBUG" ] && echo "FN='$FN'"
unset FNDB PERMDB USDB GRDB
 grep $QUIET -w "$FN" /tmp/cups_perm.db && {
 grep -A3 -w "$FN" /tmp/cups_perm.db |
 while read aLINE
 do
[ "$DEBUG" ] && echo "aLINE='$aLINE'"
     case "$aLINE" in
      '') continue;;
      File:*) FNDB="`echo "$aLINE" | awk '{print $2}'`"
      echo "FNDB='$FNDB'";;
      Access:*) [ "$PERMDB" ] || {
      PERMDB="`echo "$aLINE" | awk '{print $2}'`"
      USDB="`echo "$aLINE" | awk -F '[()]' '{print $4}'`"
      GRDB="`echo "$aLINE" | awk -F '[()]' '{print $6}'`"
      echo "PERMDB='$PERMDB' USDB='$USDB' GRDB='$GRDB'"
        }
        ;;
      *) continue;;
      esac
 done
 }

 [ -d "$oneCUPS" ] && {
  for aCUPS in `ls -A "$oneCUPS"`
  do
  unset FN PERM US GR
  stat $oneCUPS/$aCUPS |
   while read oneLINE
    do
    [ "$DEBUG" ] && echo "oneLINE='$oneLINE'"
     case "$oneLINE" in
      '') continue;;
      File:*) FN="`echo "$oneLINE" | awk '{print $2}'`"
      echo "FN=$FN";;
      Access:*) [ "$PERM" ] || {
      PERM="`echo "$oneLINE" | awk '{print $2}'`"
      US="`echo "$oneLINE" | awk -F '[()]' '{print $4}'`"
      GR="`echo "$oneLINE" | awk -F '[()]' '{print $6}'`"
      echo "PERM='$PERM' US='$US' GR='$GR'"
        }
        ;;
      *) continue;;
      esac
    done

[ "$DEBUG" ] && echo "FN='$FN'"
unset FNDB PERMDB USDB GRDB
 grep $QUIET -w "$FN" /tmp/cups_perm.db && {
 grep -A3 -w "$FN" /tmp/cups_perm.db |
 while read aLINE
 do
[ "$DEBUG" ] && echo "aLINE='$aLINE'"
     case "$aLINE" in
      '') continue;;
      File:*) FNDB="`echo "$aLINE" | awk '{print $2}'`"
      echo "FNDB='$FNDB'";;
      Access:*) [ "$PERMDB" ] || {
      PERMDB="`echo "$aLINE" | awk '{print $2}'`"
      USDB="`echo "$aLINE" | awk -F '[()]' '{print $4}'`"
      GRDB="`echo "$aLINE" | awk -F '[()]' '{print $6}'`"
      echo "PERMDB='$PERMDB' USDB='$USDB' GRDB='$GRDB'"
        }
        ;;
      *) continue;;
      esac
 done
 }
  done
  }
done

unset FN PERM US GR
find $WHERE/var -xdev -name "cups" |
while read oneCUPS
do
stat $oneCUPS |
   while read oneLINE
    do
    [ "$DEBUG" ] && echo "oneLINE='$oneLINE'"
     case "$oneLINE" in
      '') continue;;
      File:*) FN="`echo "$oneLINE" | awk '{print $2}'`"
      echo "FN='$FN'";;
      Access:*) [ "$PERM" ] || {
      PERM="`echo "$oneLINE" | awk '{print $2}'`"
      US="`echo "$oneLINE" | awk -F '[()]' '{print $4}'`"
      GR="`echo "$oneLINE" | awk -F '[()]' '{print $6}'`"
      echo "PERM='$PERM' US='$US' GR='$GR'"
        }
        ;;
      *) continue;;
      esac
    done

[ "$DEBUG" ] && echo "FN='$FN'"
unset FNDB PERMDB USDB GRDB
 grep $QUIET -w "$FN" /tmp/cups_perm.db && {
 grep -A3 -w "$FN" /tmp/cups_perm.db |
 while read aLINE
 do
[ "$DEBUG" ] && echo "aLINE='$aLINE'"
     case "$aLINE" in
      '') continue;;
      File:*) FNDB="`echo "$aLINE" | awk '{print $2}'`"
      echo "FNDB='$FNDB'";;
      Access:*) [ "$PERMDB" ] || {
      PERMDB="`echo "$aLINE" | awk '{print $2}'`"
      USDB="`echo "$aLINE" | awk -F '[()]' '{print $4}'`"
      GRDB="`echo "$aLINE" | awk -F '[()]' '{print $6}'`"
      echo "PERMDB='$PERMDB' USDB='$USDB' GRDB='$GRDB'"
        }
        ;;
      *) continue;;
      esac
 done
}

 [ -d "$oneCUPS" ] && {
  for aCUPS in `ls -A "$oneCUPS"`
  do
  unset FN PERM US GR
  stat $oneCUPS/$aCUPS |
   while read oneLINE
    do
    [ "$DEBUG" ] && echo "oneLINE='$oneLINE'"
     case "$oneLINE" in
      '') continue;;
      File:*) FN="`echo "$oneLINE" | awk '{print $2}'`"
      echo "FN=$FN";;
      Access:*) [ "$PERM" ] || {
      PERM="`echo "$oneLINE" | awk '{print $2}'`"
      US="`echo "$oneLINE" | awk -F '[()]' '{print $4}'`"
      GR="`echo "$oneLINE" | awk -F '[()]' '{print $6}'`"
      echo "PERM='$PERM' US='$US' GR='$GR'"
        }
        ;;
      *) continue;;
      esac
    done

[ "$DEBUG" ] && echo "FN='$FN'"
unset FNDB PERMDB USDB GRDB
 grep $QUIET -w "$FN" /tmp/cups_perm.db && {
 grep -A3 -w "$FN" /tmp/cups_perm.db |
 while read aLINE
 do
[ "$DEBUG" ] && echo "aLINE='$aLINE'"
     case "$aLINE" in
      '') continue;;
      File:*) FNDB="`echo "$aLINE" | awk '{print $2}'`"
      echo "FNDB='$FNDB'";;
      Access:*) [ "$PERMDB" ] || {
      PERMDB="`echo "$aLINE" | awk '{print $2}'`"
      USDB="`echo "$aLINE" | awk -F '[()]' '{print $4}'`"
      GRDB="`echo "$aLINE" | awk -F '[()]' '{print $6}'`"
      echo "PERMDB='$PERMDB' USDB='$USDB' GRDB='$GRDB'"
        }
        ;;
      *) continue;;
      esac
 done
 }

  done
  }
done


}

_entry(){

read -p "Enter /path/to/rootfs
i.e. /mnt/sda2
( default '/' ) :" PTR

[ "$PTR" ] && WHERE="$PTR" || WHERE='/'

test -d "$WHERE" || _exit 1 "'$WHERE' not a valid directory."

}

_compare(){

if _test_fr /tmp/cups_perm.db; then

__entry__(){
read -p "Enter /path/to/rootfs
i.e. /mnt/sda2
( default '/' ) :" PTR

[ "$PTR" ] && WHERE="$PTR" || WHERE='/'

test -d "$WHERE" || _exit 1 "'$WHERE' not a valid directory."
}

_entry

while read aLINE
do

[ "$DEBUG" ] && echo "aLINE='$aLINE'"

case "$aLINE" in
'') continue;;
File:*)      FN=`echo "$aLINE" | awk '{print $2}' | sed "s,^',, ; s,'$,,"`;;
Access:*\(*) #[ "$PERM" ] || {
PERM=`echo "$aLINE" | awk -F'[\(\)]' '{print $2}'`
US=`echo "$aLINE" | awk -F'[\(\)]' '{print $4}'`
GR=`echo "$aLINE" | awk -F'[\(\)]' '{print $6}'`
#break
#}
;;
*) continue;;
esac

[ "$DEBUG" ] && echo "FN='$FN' PERM='$PERM' US='$US' GR='$GR'"

test "$FN" -a "$PERM" -a "$US" -a "$GR" || continue
test "$FN" -a "$PERM" -a "$US" -a "$GR" && {
#
 test -e "$WHERE"/"$FN" && {

  unset FNW PERMW USW GRW

  while read oLINE
  do

  [ "$DEBUG" ] && echo "oLINE='$oLINE'"

   case "$oLINE" in
    '') continue;;
    File:*)      FNW=`echo "$oLINE" | awk '{print $2}' | sed "s,^',, ; s,'$,,"`;;
    Access:*\(*) #[ "$PERMW" ] || {
    PERMW=`echo "$oLINE" | awk -F'[\(\)]' '{print $2}'`
    USW=`echo "$oLINE" | awk -F'[\(\)]' '{print $4}'`
    GRW=`echo "$oLINE" | awk -F'[\(\)]' '{print $6}'`
    #}
    break
;;
*) continue;;
esac

  done << EoI
`stat "$WHERE"/"$FN"`
EoI
#

[ "$DEBUG" ] && echo "FNW='$FNW' PERMW='$PERMW' USW='$USW' GRW='$GRW'"

test "$PERM" = "$PERMW" || echo -e "\\033[1;31m$FN:PERMISSIONS not same: '$PERM' '$PERMW'\\033[0;39m"
test "$US" = "$USW" || echo -e "\\033[1;31m$FN:USER not same: '$US' '$USW'\\033[0;39m"
test "$GR" = "$GRW" || echo -e "\\033[1;31m$FN:GROUP not same: '$GR' '$GRW'\\033[0;39m"

unset FN PERM US GR FNW PERMW USW GRW
 } || { echo -e "\033[0;31m$WHERE/$FN does not exists\\033[0;39m"; }

}  || {
#echo -e "\033[0;31mFN PERM US GR unset\\033[0;39m";
continue
true
}


unset FN PERM US GR FNW PERMW USW GRW
done </tmp/cups_perm.db # read aLINE

else echo "/tmp/cups_perm.db not a read-able file"
fi # _test_fr /tmp/cups_perm.db

}

case $1 in
-c|*create-db)
_create_db "$WHERE"
;;
-C|*compare)
_compare "$WHERE"
;;
-h|*help|*usage|'')
 cat <<EoI >&2
$0:
-c|*create-db) Create data-base file /tmp/cups_perm.db .
-C|*compare)   Compare against data-base file /tmp/cups_perm.db .
EoI

;;
*)
echo "Unknown option '$1'"
;;
esac
