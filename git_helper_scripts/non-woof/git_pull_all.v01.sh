#!/bin/bash

ME_PROG=`realpath "$0"`
ME_DIR=${ME_PROG%/*}
cd "$ME_DIR"

CONFL_FILE="$ME_DIR"/conflicts.lst
rm -f $CONFL_FILE

for i in `pwd`/*;
do echo $i;
test -d $i || continue
test -d $i/.git || continue

 case "$i"
 in
 *libusb|*libusb1) continue;;
 esac

cd $i;
pwd;

git remote -v
REPO=`git remote`
git remote prune $REPO

git branch;
BRANCHES=`git branch | sed 's!^\*! !'`

if test "`echo "$BRANCHES" | wc -l`" -le 9; then

while read oneBRANCH
do
test "$oneBRANCH" || continue
sleep 1
git checkout "$oneBRANCH" || continue
git status || { echo "$oneBRANCH: Needs manually merge" >>$CONFL_FILE; break; }

git pull $REPO $oneBRANCH  #2>>$CONFL_FILE  #2>&1 | tee -a $CONFL_FILE
# stderr:
#fatal: Couldn't find remote ref mergeback
#Unexpected end of command stream

# goes to stdout:
#Your configuration specifies to merge with the ref 'master'
#from the remote, but no such ref was fetched.

# to stderr:
#fatal: repository 'https://git.kernel.org/cgit/linux/kernel/git/gregkh/usbutils.git/' not found

git status || { echo "$oneBRANCH: Needs manually merge" >>$CONFL_FILE; break; }

done<<EoI
`echo "$BRANCHES"`
EoI

fi

git checkout master && git status && git pull

done
