#!/bin/bash
echo '-'$1'-'$2'-'

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
# today=TueÂOctÂ25Â12:32:54ÂGMT+1Â2011
#
#
#
#
#
########################################################################

PATTERN="$1"
MD="$2"
 if test "`echo $MD | grep -i [a-z]`" != "" || test "$2" = ""; then 
 echo "$MD defaulting to 1"
	MD=1
fi

cd /proc
								#echo `pwd`
F=`find . -maxdepth $MD -type f`
F=`echo "$F" | sed '/kcore/d'` 	# ; /kcore/d /kmsg/d
echo "$F"								#echo "$F"
echo 'now beginning first for loop'
for i in $F; do
f=`file $i | grep empty`
echo $f
if test "$f" = ""; then 	#file not empty so ok to read
j=`echo $i | sed 's#^\.##'` #disturbing point away
gf="`pwd`$j" 				#realpath
echo $gf
g=`grep -n -i $PATTERN $gf 2>/dev/null`
echo $g
if test "$g" != "" ; then
							#echo
echo '###found File' $i
							#cat $i
							#grep -n -i $PATTERN `pwd`$i
echo "$g"
echo '***End od file' $i
echo
fi
fi
done
