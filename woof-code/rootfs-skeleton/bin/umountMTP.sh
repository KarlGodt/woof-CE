#!/bin/ash

MOUNT_POINT=/mntf/MTPdev

rox -D "$MOUNT_POINT"

sleep 1

fusermount -uz "$MOUNT_POINT"
