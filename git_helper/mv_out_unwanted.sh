#!/bin/ash
_say_help_msg(){
	cat >&1 <<EoI
# simple script to move '??' marked files
# by git commit --short
# into MV_DIR
EoI
}

case $* in -h|*help) _say_help_msg; exit 0;; esac


. /etc/rc.d/f4puppy5
. /etc/rc.d/PUPSTATE
. /etc/DISTRO_SPECS

VERB=-v
MV_DIR=../moved_out


_cd_program_dir || _exit $? "Could not change into working directory"

mkdir $VERB -p "$MV_DIR"
cd ..

#git commit --short | while read Q f
while read Q f
do
test -f "$f" -o -d "$f" || continue
case $Q in '??') :;; *) continue;; esac

mvdir=${f%/*}
test "$mvdir" || mvdir=/
echo "f='$f'"
echo "mvdir='$mvdir'"

mkdir $VERB -p "$MV_DIR"/"$mvdir"  || break
mv $VERB "$f" "$MV_DIR"/"$mvdir"/  || break

done <<EoI
`git commit --short`
EoI
