#!/bin/ash

cd "$*" || exit 1

GITROOT=/mnt/sda9/WOOF/krgPULL.d
CODEROOT=woof-code/rootfs-skeleton
RELDIR=`pwd | sed "s@$GITROOT@@;s@$CODEROOT@@" | tr -s '/'`
RELBACKTOP=`echo "$RELDIR" | grep -o '/' | sed 's@^@\.\.@' | tr -d '\n' | tr -s '/'`
for i in *; do
[ -L "$i" ]  || continue
LINK_TO=`readlink "$i"`
LINK_TO=`echo "$LINK_TO" | sed 's@\(\.\./\)@@g' | tr -s '/'`
ln -v -sf ${RELBACKTOP}$LINK_TO $i
done
