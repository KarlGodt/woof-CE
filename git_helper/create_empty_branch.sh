#!/bin/ash
#git checkout -b branch-without-rootfs-skeleton

MY_SELF=`realpath "$0"`

MY_DIR=${MY_SELF%/*}

cd "$MY_DIR" || exit 3

test "$*" && RM_DIR="$*" || \
             RM_DIR=woof-code/rootfs-skeleton/

test -e "$RM_DIR" || exit 4

git checkout -b branch-without-${RM_DIR##*/} || exit 5

git rm -r "$RM_DIR" || exit 6

ADD_DIR=${RM_DIR%/*}
test "$ADD_DIR" || exit 7

git add "$ADD_DIR" || exit 8

git commit -m "$RM_DIR : Removed." || exit 9

# Now re adding stub dir structure
(
mkdir -p "$RM_DIR"
for d in bin sbin lib etc root usr var
do
mkdir "$RM_DIR"/$d
touch "$RM_DIR"/$d/.gitignore
done
) || exit 20

git add "$RM_DIR" || exit 21

git commit -m "$RM_DIR : Directory Stub Added:
bin/
etc/
lib/
root/
sbin/
usr/
var/
"
