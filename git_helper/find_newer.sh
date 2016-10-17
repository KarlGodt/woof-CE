#!/bin/ash

# this script runs find in
# /root/Github.d/KarlGodt_ForkWoof.Push.D woof-code/rootfs-skeleton
# and then stat and then diff and if different
# appends to /tmp/find_newer.diff
# it does not add and commit to git
# but if directory missing on OS, copies into OS

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
git branch | grep '^\*' | grep "$BRANCH" || _exit 1 "Wrong branch '$BRANCH'"

rm $VERB -f /tmp/find_newer.diff
while read oneFILE

do

test "$oneFILE" || continue

oneFILEonOS=`echo "${oneFILE}" | sed 's!woof-code/rootfs-skeleton!!'`

if test -f "$oneFILEonOS";
then

 echo "$oneFILE" >&2
 oneFILE_MOD=`stat -c %Y "$oneFILE"`
 oneFILEonOS_MOD=`stat -c %Y "$oneFILEonOS"`

 if test $oneFILEonOS_MOD -gt $oneFILE_MOD; then

 echo "$oneFILEonOS is newly modificated"
 diff -qs "$oneFILE" "$oneFILEonOS" && continue
 diff -up "$oneFILE" "$oneFILEonOS" >>/tmp/find_newer.diff
 fi

elif test -d "$oneFILEonOS"; then :
else
        DIR="${oneFILEonOS%/*}"
     test "$DIR" || DIR='/'
 test -d "$DIR" || mkdir $VERB -p "$DIR"
 /bin/cp -x --verbose -a --remove-destination -T "$oneFILE" "$oneFILEonOS"
fi


sleep 0.1s
done<<EoI
`find woof-code/rootfs-skeleton/ \( -type f -o -type l \)`
EoI

test -s /tmp/find_newer.diff && exec geany /tmp/find_newer.diff &
