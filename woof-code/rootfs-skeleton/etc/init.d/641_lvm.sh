#!/bin/bash
# needs bash for <<<

VERSION=0.5 #2016-08-30

ERR_LOG=/tmp/lvm_init_err.log
KERNEL_MODULES='dm-mod '   #kernel driver names
PWD_WORK=/mnt/sda9/LVM     #directory lv files are located
PV_DEVICES_BASE=rd         #usually sd hd mmc etc. ; i choosed rd for raiddevice
PV_DEVICES_DEVS='a b c d'  #device names suffix
PV_FILE_SIZE=128 #MB       #size of the files used to create lv
VG_NAME=vgrootgv           #desired name of the volume group
# lv partitions name:{size}K|M|G for kilo mega giga
LV_PARTS='share:180M backup:50M media:40M'

DBG=-d  #debug option
VERB=-v #verbose option
#FORCE_OP=-f # force option to lvm, since it asks for confirmation otherwise

TTY=`tty` || HAVE_NO_CONTROL=1 #TTY=/dev/console
HAVE_NO_CONTROL=1
echo HAVE_NO_CONTROL=$HAVE_NO_CONTROL

_print_lvm_scans(){
ORDER='pv vg lv'
test "$START_STOP_PARAM" = stop && ORDER='lv vg pv'
sleep 1
echo
for cmd in $ORDER; do
lvm ${cmd}scan
echo
done
losetup -a
echo
}

_exit(){
EVAL=$1;shift
echo "$*"
_print_lvm_scans
exit $EVAL
}

_umount_lvs(){
 MAYBE_ACTIVE=`lvm lvscan | grep -iE 'ACTIVE|inactive' | awk '{print $2}' | cut -f2 -d"'"`

 echo MAYBE_ACTIVE=$MAYBE_ACTIVE

 while read -r device
 do

 [ "$device" ] || continue

 MNTPT=`grep -w "^${device}" /proc/mounts | cut -f2 -d' '`
 MNTPT=`echo -e "$MNTPT"`
 test -d "$MNTPT" || continue

     [ "$DISPLAY" ]    && rox -D "$MNTPT"
     FsUsers=`fuser -m "$MNTPT"`
     for each in $FsUsers; do
         case $each in 1) continue;; esac
      kill -9 $each
     done
     echo unmounting $MNTPT ...
     /bin/umount ${VERB:+-v} -fl "$MNTPT"
 sleep 1

 done <<EoI
`echo "$MAYBE_ACTIVE"`
EoI

}

_activate_lvs(){

INACTIVE=`lvm lvscan | grep -i 'inactive' | awk '{print $2}' | cut -f2 -d"'"`

for dev in $INACTIVE
do

 [ "$dev" ] || continue

 echo activating $dev ...
 if test "$HAVE_NO_CONTROL"; then
 #yes $YES_STR | lvm lvchange $DBG $VERB -a y "$dev"
 lvm lvchange $DBG $VERB $@ -a y "$dev" <<<$YES_STR
 else
 lvm lvchange $DBG $VERB $@ -a y "$dev" <$TTY
 fi

done
}

_de_activate_lvs(){

 ACTIVE=`lvm lvscan | grep -i 'ACTIVE' | awk '{print $2}' | cut -f2 -d"'"`

for dev in $ACTIVE
do

 [ "$dev" ] || continue

 echo de-activating $dev ...
 if test "$HAVE_NO_CONTROL"; then
 #yes $YES_STR | lvm lvchange $DBG $VERB -a n "$dev"
 lvm lvchange $DBG $VERB $@ -a n "$dev" <<<$YES_STR
 else
 lvm lvchange $DBG $VERB $@ -a n "$dev" <$TTY
 fi

done
}

START_STOP_PARAM="$1"
shift
while :; do
echo $1
case $1 in
  -f|-force)  FORCE_OP='-f';;
 -ff|--force) FFORCE_OP='-ff';;
  -y|--yes)   YES_OP='-y';;
  -d|--debug) DBG='-d';;
-v|--verbose) VERB='-v';;
esac
shift
[ "$1" ] || break
done

YES_STR='n'
[ "$HAVE_NO_CONTROL" ] && { YES_OP='-y'; YES_STR='y'; }
test "$FFORCE_OP" && { FORCE_OP='-f'; YES_OP='-y'; YES_STR='y'; }
test "$FORCE_OP" && { test "$YES_STR" = 'y' && YES_OP='-y'; } || YES_OP=
echo $FORCE_OP $FFORCE_OP $YES_OP $DBG $VERB $YES_STR

set - "$START_STOP_PARAM"
echo $@

case $1 in

start)

which lvm || exit 0

_activate_lvs

#early exit in case already run and not stopped
PVSCAN_OUT=`lvm pvscan 2>&1`
[ "$PVSCAN_OUT" ] && { echo "$PVSCAN_OUT" | grep $Q -i 'no .* found' || exit 0; }

for m in $KERNEL_MODULES; do
modprobe $VERB $m
done

#mountpoint /mnt/sda9 || exit 0
PWD_START="$PWD"
cd "$PWD_WORK"     || exit 1

(
echo START >&2

_print_lvm_scans

for dev in $PV_DEVICES_DEVS
do
test -e ./${PV_DEVICES_BASE}$dev || {
    echo creating file ${PV_DEVICES_BASE}$dev of bs=1024 count=$((PV_FILE_SIZE*1024)) ..
    dd if=/dev/zero of=${PV_DEVICES_BASE}$dev bs=1024 count=$((PV_FILE_SIZE*1024)) && sleep 1; }
echo setting up loop for ${PV_DEVICES_BASE}$dev ..
losetup $VERB `losetup -f` ./${PV_DEVICES_BASE}$dev || break
done

sleep 1

for dev in $PV_DEVICES_DEVS
do
LOOP_DEV=`losetup -a | grep "/${PV_DEVICES_BASE}$dev" | cut -f1 -d':'` || exit 2
test -b "$LOOP_DEV" || exit 2
echo registering physical volume $LOOP_DEV ..
echo registering physical volume $LOOP_DEV .. >&2
if test "$HAVE_NO_CONTROL"; then
#yes $YES_STR | lvm pvcreate $DBG $VERB $FORCE_OP $FFORCE_OP $LOOP_DEV
lvm pvcreate $DBG $VERB $FORCE_OP $FFORCE_OP $LOOP_DEV <<< $YES_STR
else
lvm pvcreate $DBG $VERB $FORCE_OP $FFORCE_OP $LOOP_DEV <$TTY
fi
done

sleep 1

if [ "$FORCE_OP" ]; then
if test -e /dev/$VG_NAME; then
rm ${VERB} /dev/$VG_NAME/*
rmdir ${VERB:+} /dev/$VG_NAME
fi
fi

LOOP_DEVS=`lvm pvscan | grep '^[[:blank:]]*PV /dev/.*' | awk '{print $2}'`
for dev in $LOOP_DEVS
do
echo creating virtual group $VG_NAME with $dev ..
echo creating virtual group $VG_NAME with $dev .. >&2
if test "$HAVE_NO_CONTROL"; then
#yes $YES_STR | lvm vgcreate $DBG $VERB $VG_NAME $dev || yes $YES_STR | lvm vgextend $DBG $VERB $VG_NAME $dev
lvm vgcreate $DBG $VERB $VG_NAME $dev <<<$YES_STR || lvm vgextend $DBG $VERB $VG_NAME $dev <<<$YES_STR
else
lvm vgcreate $DBG $VERB $VG_NAME $dev <$TTY || lvm vgextend $DBG $VERB $VG_NAME $dev <$TTY || break
fi
done


sleep 1
for part in $LV_PARTS; do

name=${part%:*}
size=${part#*:}
#echo $name $size
test "$name" -a "$size" || continue
echo creating logical volume $name of $size size on virtual group $VG_NAME ..
echo creating logical volume $name of $size size on virtual group $VG_NAME .. >&2
if test "$HAVE_NO_CONTROL"; then
#yes $YES_STR | lvm lvcreate $DBG $VERB $VG_NAME --name  $name --size $size
lvm lvcreate $DBG $VERB $VG_NAME --name  $name --size $size <<<$YES_STR
else
lvm lvcreate $DBG $VERB $VG_NAME --name  $name --size $size <$TTY
fi
done

) 2>"$ERR_LOG"

_print_lvm_scans

cd "$PWD_START"

;;

activate-all)

_print_lvm_scans

(
echo ACTIVATE-ALL >&2

which lvm || exit 0

_activate_lvs

) 2>"$ERR_LOG"

_print_lvm_scans

;;

de-activate-all)

_print_lvm_scans

(
echo DE-ACTIVATE-ALL >&2

which lvm || exit 0

_de_activate_lvs

) 2>"$ERR_LOG"

_print_lvm_scans

;;

stop)

(
echo STOP >&2

which lvm || exit 0
_print_lvm_scans
_umount_lvs
_de_activate_lvs
_print_lvm_scans

) 2>>$ERR_LOG
;;

remove-all)

(
echo REMOVE-ALL >&2

which lvm || exit 0
_print_lvm_scans
_umount_lvs

 [ "$MAYBE_ACTIVE" ] && sleep 2
 DEVICES=`lvm lvdisplay | grep -E 'LV Path|LV Name' | awk '{print $3}'`

 echo DEVICES=$DEVICES

 while read -r device
 do
 echo 1 $device
 [ "$device" ] || continue
 echo 2 $device
 lvm lvchange $DBG $VERB -ay "$device" #force activation
 echo 3 $device
 [ -L "$device" ] || continue
 echo 4 $device

 #FS_TYPE=`guess_fstype $device`
 #test "$FS_TYPE" || continue
 #test "$FS_TYPE" = 'unknown' && continue

 echo setting readonly $device $DBG $VERB $FORCE_OP
 echo removing $device $DBG $VERB $FORCE_OP .. >&2
 if test "$HAVE_NO_CONTROL"; then
 #yes $YES_STR | lvm lvchange $DBG $VERB -p r "$device"
 lvm lvchange $DBG $VERB -p r "$device" <<<$YES_STR
 else
 lvm lvchange $DBG $VERB -p r "$device" <$TTY
 fi
 sleep 1

 echo removing $device $DBG $VERB $FORCE_OP ..
 echo removing $device $DBG $VERB $FORCE_OP .. >&2
 if test "$HAVE_NO_CONTROL"; then
 #yes $YES_STR | lvm lvremove $DBG $VERB $FORCE_OP "$device"
 lvm lvremove $DBG $VERB $FORCE_OP "$device" <<<$YES_STR
 else
 lvm lvremove $DBG $VERB $FORCE_OP "$device" <$TTY
 fi
 sleep 1
 rm $VERB -f "$device"

 done <<EoI
`echo "$DEVICES"`
EoI

 [ "$DEVICES" ] && sleep 2

if test "$FFORCE_OP"; then :; else
LVSCAN_OUT=`lvm lvscan 2>&1`
test "$LVSCAN_OUT" && { echo "$LVSCAN_OUT" | grep $Q -i 'no .* found' || _exit 1 "Still LV partitions found."; }
fi

 VGS=`lvm vgdisplay | grep 'VG Name' | awk '{print $3}'`

 echo VGS=$VGS

 while read -r name
 do

 [ "$name" ] || continue

 echo removing $name $DBG $VERB $FORCE_OP ...
 echo removing $name $DBG $VERB $FORCE_OP ... >&2
 if test "$HAVE_NO_CONTROL"; then
 #yes $YES_STR | lvm vgremove $DBG $VERB $FORCE_OP "$name"
 lvm vgremove $DBG $VERB $FORCE_OP "$name" <<<$YES_STR
 else
 lvm vgremove $DBG $VERB $FORCE_OP "$name" <$TTY
 fi
 sleep 1
 [ -d /dev/$name ] && rmdir ${VERB:+} /dev/$name

 done <<EoI
`echo "$VGS"`
EoI

 [ "$VGS" ] && sleep 2

if test "$FFORCE_OP"; then :; else
 VGSCAN_OUT=`lvm vgscan 2>&1`
 [ "$VGSCAN_OUT" ] && { echo "$VGSCAN_OUT" | grep $Q -i 'no .* found' || _exit 1 "Still VG groups found."; }
fi

 #PVS=`lvm pvscan | grep '^[[:blank:]]*PV .* VG' | awk '{print $2}'`
  PVS=`lvm pvscan | grep '^[[:blank:]]*PV /dev/.*' | awk '{print $2}'`

 echo PVS=$PVS

 while read -r volume
 do

 [ "$volume" ]    || continue
 [ -b "$volume" ] || continue

 echo removing $volume $DBG $VERB $FORCE_OP $FFORCE_OP $YES_OP ...
 echo removing $volume $DBG $VERB $FORCE_OP $FFORCE_OP $YES_OP ... >&2
 if test "$HAVE_NO_CONTROL"; then
 #yes $YES_STR | lvm pvremove $DBG $VERB $FORCE_OP $FFORCE_OP $YES_OP "$volume"
 lvm pvremove $DBG $VERB $FORCE_OP $FFORCE_OP $YES_OP "$volume" <<<$YES_STR
 else
 lvm pvremove $DBG $VERB $FORCE_OP $FFORCE_OP $YES_OP "$volume" <$TTY
 fi
 [ $? = 0 ] && losetup -v -d "$volume"

 done <<EoI
`echo "$PVS"`
EoI

_print_lvm_scans

) 2>>"$ERR_LOG"

sleep 2


(
which dmsetup || exit 0

MAPPERS=`grep '^/dev/mapper/' /proc/mounts | cut -f2 -d' '`

 while read -r  mntpt
 do

 mntpt=`echo -e "$mntpt"`
 [ "$mntpt" ] || continue
 [ -d "$mntpt" ] || continue
 mountpoint ${Q:+-q} "$mntpt" || continue

    FsUsers=`fuser -m "$mntpt"`
     for each in $FsUsers; do
         case $each in 1) continue;; esac
      kill -9 $each
     done

 echo unmounting $mntpt ...
 /bin/umount ${VERB:+-v} -fl "$mntpt"
 sleep 1

 done <<EoI
`echo "$MAPPERS"`
EoI

 DEVICES=`dmsetup status | awk '{print $1}'`

 while read -r dev
 do

 [ "$dev" ] || continue
 [ -b /dev/mapper/$dev ] || continue

 dmsetup suspend /dev/mapper/$dev
 dmsetup clear   /dev/mapper/$dev
 dmsetup remove -f --retry /dev/mapper/$dev

 done << EoI
`echo "$DEVICES"`
EoI

 dmsetup remove_all --force

) 2>>"$ERR_LOG"

;;

*help|*)
 (
 echo ${0##*/} Usage
 echo $0 \<command\> [ options ]
 echo commands:
  echo start -- activate all found LVs,
  echo otherwise creating a LV setup from scratch with variables at top of this script
  echo activate-all -- activate all inactive marked partitions to kernel
  echo status -- show output of pv\|vg\|lv scans
  echo stop   -- unmount all mounted LV partitions
  echo de-activate-all -- unregister all LV partitions from kernel
  echo remove-all -- unregister all LV, VG and PV from kernel \(may cause data loss stored in LV\)
 echo options:
  echo -f --force : lvm do not ask questions
  echo -ff : two times force to pvremove \(may cause data loss stored in PV\)
  echo -y --yes : in case of -ff answer all yes to questions to force shutdown
  echo -v --verbose : lvm accepts -v option
  echo -d --debug : lvm accepts -d option
 ) >&2
 case $1 in *help) exit 0;; esac
 exit 1
;;

esac
