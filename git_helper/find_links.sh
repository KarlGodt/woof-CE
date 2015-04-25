#!/bin/ash

_exit(){
retVAL=$1
shift
echo "$*"
exit $retVAL
}

cd /root/GitHub.d/KarlGodt_ForkWoof.Push.D || _exit 1 "No directory /root/GitHub.d/KarlGodt_ForkWoof.Push.D"

test -d woof-code || _exit 1 "Directory woof-code missing"
test -d woof-code/rootfs-skeleton || _exit 1 "Directory woof-code/rootfs-skeleton mising"

while read oneLINK

do

test "$oneLINK" || continue

oneLINKonOS=`echo "${oneLINK}" | sed 's!woof-code/rootfs-skeleton!!'`

echo "$oneLINK"
echo "realpath:`realpath $oneLINK`"
echo "readlink:`readlink $oneLINK`"
echo -en '\e[1;31m'
file "$oneLINK" | grep broken
echo -e '\e[0;39m'

#if test -f "$oneFILEonOS";
#then

# oneFILE_MOD=`stat -c %Y "$oneFILE"`
# oneFILEonOS_MOD=`stat -c %Y "$oneFILEonOS"`

# if test $oneFILEonOS_MOD -gt $oneFILE_MOD; then
# echo "$oneFILEonOS is newly modificated"
# cp -a "$oneFILEonOS" "$oneFILE" || break
# git add "$oneFILE" || break
# git commit -m "${oneFILE}:Bulk update." || break
# fi

#fi


sleep 1s
done<<EoI
`find woof-code/rootfs-skeleton/ \( -type l \)`
EoI
