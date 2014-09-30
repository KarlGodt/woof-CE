#!/bin/ash
for i in `mount | grep 'ram0' | cut -f 3 -d ' ' |sort -r` ; do

########################################################################
#
#
#
#
#
# /dev/hda7
# /dev/hda7:
# LABEL="/"
# UUID="429ee1ed-70a4-43a5-89f8-33496c489260"
# TYPE="ext4"
# DISTRO_NAME='LucidÂPuppy'
# DISTRO_VERSION=218
# DISTRO_MINOR_VERSION=00
# DISTRO_BINARY_COMPAT='ubuntu'
# DISTRO_FILE_PREFIX='luci'
# DISTRO_COMPAT_VERSION='lucid'
# DISTRO_KERNEL_PET='linux_kernel-2.6.33.2-tickless_smp_patched-L3.pet'
# PUPMODE=2
# SATADRIVES=''
# PUP_HOME='/'
# PDEV1='hda7'
# DEV1FS='ext4'
# LinuxÂpuppypcÂ2.6.31.14Â#1ÂMonÂJanÂ24Â21:03:21ÂGMT-8Â2011Âi686ÂGNU/Linux
# Xserver=/usr/bin/Xorg
# $LANG=en_US
# today=TueÂOctÂ25Â12:33:05ÂGMT+1Â2011
#
#
#
#
#
########################################################################

echo $i
umount -l $i
sleep 3s
rmdir $i
done
mkdir -p /mnt/ram0
mkfs.ext2 /dev/ram0
mount -t ext2 /dev/ram0 /mnt/ram0
dd if=/dev/zero of=/mnt/ram0/part1 bs=1048576 count=3
mkswap /mnt/ram0/part1
swapon /mnt/ram0/part1
cat /proc/swaps
ls -ls /mnt/ram0
free
df
dd if=/dev/zero of=/mnt/ram0/part2 bs=1048576 count=4
mkfs.ext2 /mnt/ram0/part2
mkdir -p /mnt/EXT2
mount -t ext2 -o loop /mnt/ram0/part2 /mnt/EXT2
df
dd if=/dev/zero of=/mnt/ram0/part3 bs=1048576 count=5
mkfs.ntfs -F -H 100 -S 5 -s 256 -p 0 /mnt/ram0/part3
mkdir -p /mnt/NTFS
mount -o loop -t ntfs /mnt/ram0/part3 /mnt/NTFS
df
umount -t ntfs /mnt/NTFS
ntfsresize -s 3M -f -v /mnt/ram0/part3


