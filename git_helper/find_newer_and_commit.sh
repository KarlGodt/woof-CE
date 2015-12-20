#!/bin/ash

_exit(){
retVAL=$1
shift
echo "$*"
exit $retVAL
}

cd /root/Github.d/KarlGodt_ForkWoof.Push.D || _exit 1 "No directory /root/Github.d/KarlGodt_ForkWoof.Push.D"

test -d woof-code || _exit 1 "Directory woof-code missing"
test -d woof-code/rootfs-skeleton || _exit 1 "Directory woof-code/rootfs-skeleton mising"

BRANCH="Opera2-GreatWallU310-KRGall-2013-11-23"
git branch | grep '^\*' | grep "$BRANCH" || _exit 1 "Wrong branch $BRANCH"

while read oneFILE

do

test "$oneFILE" || continue
test -L "$oneFILE" && continue

oneFILEonOS=`echo "${oneFILE}" | sed 's!woof-code/rootfs-skeleton!!'`
test -L "$oneFILEonOS" && continue

if test -f "$oneFILEonOS";
then

 echo "$oneFILE" >&2
 oneFILE_MOD=`stat -c %Y "$oneFILE"`
 oneFILEonOS_MOD=`stat -c %Y "$oneFILEonOS"`

 # REM: PERMISSIONS ..?
 if test $oneFILEonOS_MOD -gt $oneFILE_MOD; then

 echo "$oneFILEonOS is newly modificated"
 diff -qs "$oneFILE" "$oneFILEonOS" && continue

 cp -a "$oneFILEonOS" "$oneFILE" || break
 sleep 1
 git add "$oneFILE" || break
 sleep 1
 git commit -m "${oneFILE}:Bulk update." #|| break
 sleep 1

 fi

fi

sleep 0.1s
done<<EoI
`find woof-code/rootfs-skeleton/ \( -type f -o -type l \)`
EoI
