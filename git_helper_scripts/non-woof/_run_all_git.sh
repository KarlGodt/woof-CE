#!/bin/sh

ME_PROG=`realpath "$0"`
ME_DIR=${ME_PROG%/*}
cd "$ME_DIR"


FILES=`find -maxdepth 4 -type f -name "git_pull_all.sh" | sort`
echo
echo "$FILES"

for aPULL in $FILES
do

TRUEPATH=`realpath $aPULL`
echo $TRUEPATH
DIROF=${TRUEPATH%/*}
echo $DIROF

cd $DIROF || continue

./git_pull_all.sh

cd $ME_DIR

done

