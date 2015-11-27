#!/bin/sh


########################################################################
#
#
#
#
#
# /dev/sda5:
# LABEL="MacPup430_F3"
# UUID="07443de5-1fab-4656-a3ab-7b1c14ccc8c8"
# TYPE="ext3"
# DISTRO_VERSION=430·#481·#416·#218·#478······#####change·this·as·required#####
# DISTRO_BINARY_COMPAT="puppy"·#"ubuntu"·#"puppy"·#####change·this·as·required#####
# case·$DISTRO_BINARY_COMPAT·in
# ubuntu)
# DISTRO_NAME="Jaunty·Puppy"
# DISTRO_FILE_PREFIX="upup"
# DISTRO_COMPAT_VERSION="jaunty"
# ;;
# debian)
# DISTRO_NAME="Lenny·Puppy"
# DISTRO_FILE_PREFIX="dpup"
# DISTRO_COMPAT_VERSION="lenny"
# ;;
# slackware)
# DISTRO_NAME="Slack·Puppy"
# DISTRO_FILE_PREFIX="spup"
# DISTRO_COMPAT_VERSION="12.2"
# ;;
# arch)
# DISTRO_NAME="Arch·Puppy"
# DISTRO_FILE_PREFIX="apup"
# DISTRO_COMPAT_VERSION="200904"
# ;;
# t2)
# DISTRO_NAME="T2·Puppy"
# DISTRO_FILE_PREFIX="tpup"
# DISTRO_COMPAT_VERSION="puppy5"
# ;;
# puppy)·#built·entirely·from·Puppy·v2.x·or·v3.x·or·4.x·pet·pkgs.
# DISTRO_NAME="Puppy"
# DISTRO_FILE_PREFIX="pup"·#"ppa"·#"ppa4"·#"pup2"··#pup4··###CHANGE·AS·REQUIRED,·recommend·limit·four·characters###
# DISTRO_COMPAT_VERSION="4"·#"2"··#4·····###CHANGE·AS·REQUIRED,·recommend·single·digit·5,·4,·3,·or·2###
# ;;
# esac
# PUPMODE=2
# KERNVER=2.6.30.6-KRG-i486
# ATADRIVES='·sda'
# USB_SATAD=''
# PUP_HOME='/'
# Linux·puppypc·2.6.30.6-KRG-i486·#1·SMP·Sun·Jan·2·20:32:12·GMT-1·2011·i686·GNU/Linux
# Xserver=/usr/X11R7/bin/Xvesa_stripped_upx9
# $LANG=en_US
# today=Mon·Oct·24·22:32:57·CEST·2011
#
#
#
#
#
########################################################################

cd `pwd`
pwd
sleep 9s

DIRS=`find . -maxdepth 1 -type d | sed 's#\./##g'`
PATCHES=`find . -maxdepth 1 -name "*.diff" -o -name "*.patch"`
[ -z "$PATCHES" ] && echo "No patches found. Exiting" && exit
for i in $PATCHES ; do
echo "$i"
#grep -A 1 '\-\-\-' $i
pathline=`grep -m 1 '\-\-\- .*' $i | cut -f 2 -d ' '`
echo '$pathline='"$pathline"
for j in $DIRS ; do
pathdir=`echo $pathline | grep -o ".*$j/" | sed "s,$j/(.*),$j/,"`
echo '$pathdir='"$pathdir"
[ -z "$pathdir" ] && continue
[ -n "$pathdir" ] && break
done
patchline=`echo $pathdir | sed 's#^/## ; s#/$##'`
echo '$patchline='"$patchline"
pVal=`echo $patchline | grep -o '/' | wc -l`
echo '$pVal='"$pVal"
patch -p $pVal < $i
echo
echo
done


###EXPRIEMENTAL for XORG compile>>>
cleanup_func(){
mkdir _A_LA
A=`find . -name "*.a"`
for i in $A ; do echo $i; cp $i _A_LA/`basename $i` ; done
LA=`find . -name "*.la"`
for i in $LA ; do echo $i; cp $i _A_LA/`basename $i` ; done
mkdir _SO
SO=`find . -name "*.so"`
for i in $SO ; do echo $i; cp $i _SO/`basename $i` ; done
}
##########<<<<

