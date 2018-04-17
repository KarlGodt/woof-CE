#!/bin/sh

ME_PROG=`realpath "$0"`
ME_DIR=${ME_PROG%/*}
cd "$ME_DIR"

CONFL_FILE="$ME_DIR"/conflicts.lst
rm -f "$CONFL_FILE"

YEAR=`date +%Y`
YEAR1=$((YEAR-1))

for i in `pwd`/*;
#for i in `pwd`/Grub `pwd`/GRUB-http;
#for i in `pwd`/binutils;
do echo $i;
test -d $i || continue
test -d $i/.git || continue
#case $i in
#*/a*|*/b*|*/c*|*/d*|*/e*|*/f*|*/g*|*/Git.d/G*|*/i*|*/k*) continue;;
#esac
cd $i || { echo "failed to change directory \"$i\""; exit; }
pwd;

git remote -v
REPO=`git remote | tail -n1`
git remote prune $REPO

git branch -r;
          git branch -r | sed 's!^\*! !' | sed 's!remotes/!!' | cut -f2- -d'/'
BRANCHES=`git branch -r | sed 's!^\*! !' | sed 's!remotes/!!' | cut -f2- -d'/'`
sleep 5
echo

if test "`echo "$BRANCHES" | wc -l`" -le 9; then

while read oneBRANCH
do
test "$oneBRANCH" || continue
sleep 1
git checkout "$oneBRANCH" || { git merge --abort && git checkout "$oneBRANCH"; } || continue
git status || { echo "$oneBRANCH: Needs manually merge" >>$CONFL_FILE; break; }

LASTCOMMITYEAR=`git log | head -n3 | tail -n1 | awk '{ print $(NF-1)}'`
echo "LASTCOMMITYEAR=$LASTCOMMITYEAR"
case $LASTCOMMITYEAR in
$YEAR|$YEAR1):;;*)continue;;
esac

git pull $REPO $oneBRANCH || git merge --abort
git status || { echo "$oneBRANCH: Needs manually merge" >>$CONFL_FILE; break; }
echo

done<<EoI
`echo "$BRANCHES"`
EoI

else
 echo
 echo "more than 9 branches.."
 echo
fi

( git checkout master && git status && git pull ) || { git merge --abort && git status && git checkout master && git status && git pull; }
sleep 5
done
