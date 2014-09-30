#!/bin/bash


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
# DISTRO_NAME='Lucid�Puppy'
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
# Linux�puppypc�2.6.31.14�#1�Mon�Jan�24�21:03:21�GMT-8�2011�i686�GNU/Linux
# Xserver=/usr/bin/Xorg
# $LANG=en_US
# today=Tue�Oct�25�12:33:09�GMT+1�2011
#
#
#
#
#
########################################################################

probepart -s > /tmp/probepart.txt
cat /tmp/probepart.txt | grep -v none | grep -v swap | grep -v iso > /tmp/probepart2.txt
cat /tmp/probepart2.txt | tr -s ' ' | cut -f 1 -d '|' > /tmp/probepartDisks.txt
cat /tmp/probepart2.txt | tr -s ' ' | cut -f 2 -d '|' > /tmp/probepartFs.txt

#Disks=`cat /tmp/probepartDisks.txt`
#Fs=`cat /tmp/probepartFs.txt`

Nr=`grep -c dev /tmp/probepartDisks.txt`

#for (( i=1;i<$Nr;i++ )) ; do

i=1
while (( i != $Nr )); do
(( i++ ))

Drive=`cat -n /tmp/probepartDisks.txt | grep -w $i -m 1 | tr -s ' ' | sed "s/$i//"`
echo $Drive
MntPt=`echo $Drive | sed 's!/dev!!'`
mkdir -p /mnt/$MntPt
Fs=`cat -n /tmp/probepartFs.txt | grep -w $i -m 1 | tr -s ' ' | sed "s/$i//"`
echo $Fs
mount -t $Fs $Drive /mnt/$MntPt

done


