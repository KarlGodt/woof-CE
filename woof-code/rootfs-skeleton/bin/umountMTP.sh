#!/bin/ash

. /etc/rc.d/f4puppy5

MOUNT_POINT=/mntf/MTPdev

mountpoint "$MOUNT_POINT" || _exit 4 "'$MOUNT_POINT' not mounted"

rox -D "$MOUNT_POINT"

sleep 1

fusermount -uz "$MOUNT_POINT"
