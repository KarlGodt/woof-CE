#!/bin/bash

 DXC=0
# [[ "`ls /dev/xconsole`" = "" ]] && ln -s /dev/console /dec/xconsole && DXC=1
 [[ x`pidof xconsole` = x ]] && xconsole & 
 sleep 1
 
 WD=$5
 PATTERN=$1
 
 echo >>/dev/console
 echo 'NOW STARTING NEW in'`pwd` >>/dev/console
 for i in * ; do 
 A=`file $i| grep -i ascii` 
 [[ x$A = x ]] && continue 
 echo '***FOUND FILE' $i '***' >>/dev/console
 echo $i >>/dev/console
 echo $A >>/dev/console
 cat $i >>/dev/console
 if test x$1 != x ; then B=`grep -n -i $PATTERN $i`; 
 if test x$B = x ; then
 echo -e "\\033[1;31m $PATTERN not found\\033[0;39m" >>/dev/console
 else
 echo -e "\033[1;32m GREAT found $B\033[0;39m" >>/dev/console ;fi;fi
 #echo -e "\\033[1;30m" >>/dev/console
 echo '***END of FILE' $i '***' >>/dev/console
 echo >>/dev/console

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
# today=TueÂOctÂ25Â12:32:50ÂGMT+1Â2011
#
#
#
#
#
########################################################################

 done
echo >>/dev/console
DXC=0
