#!/bin/ash
. /etc/rc.d/f4puppy5

MOUNT_POINT=/mntf/MTPdev
mountpoint "$MOUNT_POINT" && _exit 4 "'$MOUNT_POINT' already mounted"
test -d "$MOUNT_POINT" || mkdir -p "$MOUNT_POINT"

trap "fusermount -uz $MOUNT_POINT; exit 0" KILL TERM ABRT

GO_MTPFS_OPS=

test -L /bin/mount || _exit 5 "Needs /bin/mount being symbolic link"

OLD_TARG=`realpath /bin/mount`
test -e "$OLD_TARG" || _exit 55 "'$OLD_TARG' does not exist"

ln -sf mountMTP /bin/mount
test $? = 0 || _exit 6 "Failed to link /bin/mount -> mountMTP"

go-mtpfs $GO_MTPFS_OPS /mntf/MTPdev &

sleep 5
ln -sf "$OLD_TARG" /bin/mount
