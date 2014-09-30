#!/bin/sh


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
# today=TueÂOctÂ25Â12:33:31ÂGMT+1Â2011
#
#
#
#
#
########################################################################

cd /usr/local/lib/xarchive/wrappers

for i in *; do cat $i | sed 's#>/dev/stderr#>>/tmp/xarchive_errs.log#g' > /tmp/$i; mv -f /tmp/$i ./$i ; done 

for i in *; do cat $i | sed 's#> /dev/stderr#>>/tmp/xarchive_errs.log#g' > /tmp/$i; mv -f /tmp/$i ./$i ; done

                                               
for FILE in *; do L=`grep -n 'E_UNSUPPORTED=' $FILE | cut -f 1 -d ':'` ; echo $L ; SEDINSL=`expr $L - 2`; SEDINS='echo >>/tmp/xarchive_errs.log' ; sed -i "$SEDINSL i $SEDINS" $FILE ; done

for FILE in *; do L=`grep -n 'opt="$1"' $FILE | cut -f 1 -d ':'` ; echo $L ; SEDINSL=`expr $L + 1`; SEDINS='echo opt $opt >>/tmp/xarchive_errs.log' ; sed -i "$SEDINSL i $SEDINS" $FILE ; done

for FILE in *; do L=`grep -n 'archive="$1"' $FILE | cut -f 1 -d ':'` ; echo $L ; SEDINSL=`expr $L + 1`; SEDINS='echo archive $archive >>/tmp/xarchive_errs.log' ; sed -i "$SEDINSL i $SEDINS" $FILE ; done

for i in *; do chmod 0755 $i ; done

for i in *; do geany $i ; done

#ARJ_PROG="arj \-+ \-ja1 \-r"


FXARCHIVE=`which xarchive`
DIRXARCHIVE=`dirname "$FXARCHIVE"`
FILEXARCHIVE=`file "$FXARCHIVE"`

if [ -n "`echo $FILEXARCHIVE | grep 'ELF' | grep 'LSB' | grep -i 'executable'`" ] ; then
mv "$FXARCHIVE" "$DIRXARCHIVE"/xarchive.bin


echo '#!/bin/sh
###

exec 2>/tmp/xarchive.bin.err.log

xarchive.bin "$@"

'> "$FXARCHIVE"

chmod 0755 "$FXARCHIVE"

fi

