#!/bin/ash

MY_SELF=`realpath "$0"`

MY_DIR=${MY_SELF%/*}

cd "$MY_DIR" || exit 3


sc=0 # count number of found scripts and links

for d in /bin /sbin /usr/bin /usr/sbin /usr/local/bin
do

echo "$d:"
while read f
do
test -f "$f" || continue

if test -L "$f"; then
:
else
:
fi

echo "$f"
relf=${f#*/}
echo "$relf"
reld=${relf%/*}
test "$reld" || reld=/
test -e ../woof-code/rootfs-skeleton/$reld || mkdir -p ../woof-code/rootfs-skeleton/$reld || break 2
cp -a "$f" ../woof-code/rootfs-skeleton/$reld/ || break 2

sc=$((sc +1))

done <<EoI
`grep -I -H -E -m1 '^[[:blank:]]*#.*B\.K\.|^[[:blank:]]*#.*Barry Kauler|^[[:blank:]]*#.*BK|^[[:blank:]]*#.*Puppy Linux' $d/* | cut -f1 -d':'`
EoI

echo

done
echo Found $sc scripts.
