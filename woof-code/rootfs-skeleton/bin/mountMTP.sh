#!/bin/ash
. /etc/rc.d/f4puppy5

# REM: Prevent multiple instances
_pidof $Q go-mtpfs && _exit 3 "go-mtpfs already running"

# REM: Use other dir than /mnt in case mount troubles,
#      fuse mounts in /mnt will render whole /mnt directory
#      inaccessible
MOUNT_POINT=/mntf/MTPdev
# REM: exit if already mounted
mountpoint "$MOUNT_POINT" && _exit 4 "'$MOUNT_POINT' already mounted"
# REM: create mount point if not already exists
test -d "$MOUNT_POINT"    || mkdir -p "$MOUNT_POINT"
# REM: unmount if script killed
trap "fusermount -uz $MOUNT_POINT; exit 0" KILL TERM ABRT

# REM: Handle /bin/mount
#      Puppy /bin/mount is a wrapper script that may return non-zero
#      or even stop while processing code
#     This is neccessary since fusermount calls mount -f and expects 0
#     as return value . NOTE: mount -f does not do anything (fake, not force)
test -L /bin/mount || _exit 5 "Needs /bin/mount being symbolic link"

OLD_TARG=`realpath /bin/mount`
test -e "$OLD_TARG" || _exit 55 "'$OLD_TARG' does not exist"
# make a backup of mount
test -e "$OLD_TARG".BAK || cp -a "$OLD_TARG" "$OLD_TARG".BAK
# REM: Create mountMTP wrapper if not exists
test -f /bin/mountMTP || {
    echo 'exit 0' >/bin/mountMTP || _exit 56 "Could not create /bin/mountMTP wrapper" ;
    chmod $VERB +x /bin/mountMTP || _exit 57 "Could not make /bin/mountMTP executable";
    }

# REM: If called from external program, needs returnvalues
#      Needs to be placed here, to prevent link creation
test "`which go-mtpfs`" || _exit 7 "go-mtpfs not installed in PATH"

ln $VERB -sf mountMTP /bin/mount
test $? = 0 || _exit 6 "Failed to link /bin/mount -> mountMTP"

# REM: Now start go-mtpfs
#     Needs forking to able to re-link original mount wrapper
#     Otherwise further mounts will fail :D
GO_MTPFS_OPS=
go-mtpfs $GO_MTPFS_OPS /mntf/MTPdev &

# Give it some time...?
sleep 5
ln $VERB -sf "$OLD_TARG" /bin/mount

# REM: If called from external program, needs returnvalues
_pidof $Q go-mtpfs && exit 0 || exit 1
