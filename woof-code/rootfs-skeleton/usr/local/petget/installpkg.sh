#!/bin/sh
#(c) Copyright Barry Kauler 2009, puppylinux.com
#2009 Lesser GPL licence v2 (http://www.fsf.org/licensing/licenses/lgpl.html).
#called from /usr/local/petget/downloadpkgs.sh and petget.
#passed param is the path and name of the downloaded package.
#/tmp/petget_missing_dbentries-Packages-* has database entries for the set of pkgs being downloaded.
#w456 warning: petget may write to /tmp/petget_missing_dbentries-Packages-alien with missing fields.
#w478, w482 fix for pkg menu categories.
#w482 detect zero-byte pet.specs, fix typo.


###KRG Fr 31. Aug 23:34:58 GMT+1 2012



trap "exit 1" HUP INT QUIT KILL TERM


OUT=/dev/null;ERR=$OUT
[ "$DEBUG" ] && { OUT=/dev/stdout;ERR=/dev/stderr; }
[ "$DEBUG" = "2" ] && set -x


Version='1.1'


usage(){
USAGE_MSG="
$0 [ PARAMETERS ]

-V|--version : showing version information
-H|--help : show this usage information

*******  *******  *******  *******  *******  *******  *******  *******  *******
$2
"
exit $1
}

[ "`echo "$1" | grep -wiE "help|\-H"`" ] && usage 0
[ "`echo "$1" | grep -wiE "\-version|\-V"`" ] && { echo "$0 -version $Version";exit 0; }

echo "$0:$*" >&2

###KRG Fr 31. Aug 23:34:58 GMT+1 2012

#information from 'labrador', to expand a .pet directly to '/':
#NAME="a52dec-0.7.4"
#pet2tgz "${NAME}.pet"
#tar -C / --transform 's/^\(\.\/\)\?'"$NAME"'//g' -zxf "${NAME}.tar.gz"
#i found this also works:
#tar -z -x --strip=1 --directory=/ -f bluefish-1.0.7.tar.gz
#v424 .pet pkgs may have post-uninstall script, puninstall.sh

########################################################################
#
# ADDS/CHANGES by Karl Godt :
#
# 1.0) tar making backups
# 2.0) using /tmp/PetGet /tmp dir to have things more ordered
# 3.0) support for b2pet,lapet,lopet,xzpet
# 4.0) manually added the code for .rpm pkgs,
#      mostly a copy of the relevant parts of /usr/local/bin/pupzip .sh
# 5.0) added support for .pup in simple manner (extracts to tmp dir,
#      included archives need to be installed manually)
#
# /dev/sda1:
# UUID="0C18A53918A52326"
# /dev/sda7:
# UUID="2dfe19a9-7a5c-48aa-9e81-3758c67b12f6"
# /dev/sda9:
# UUID="e29717d3-b775-4dc8-9643-42a862f2b34f"
# /dev/sda2:
# LABEL="2nd"
# UUID="a4f28ea3-eede-49f8-93ca-dbeefe8f72fa"
# /dev/sda10:
# UUID="193a7e6b-8626-493e-8b77-940211a8fc9d"
# /dev/sda6:
# LABEL="1stLogicalPartit"
# UUID="8efb5611-ffb4-41ca-b8ef-8e64769ce9ef"
# /dev/sda3:
# LABEL="3rd"
# UUID="f711a43e-c5dc-4f92-84dc-6824feeb690c"
# /dev/sda11:
# LABEL="store"
# UUID="51600f00-d3cc-4fba-ba77-c34b0c94502c"
# /dev/sda8:
# UUID="7b5cd9dd-54c7-4d03-af79-566588111fcb"
# /dev/sda5:
# LABEL="1stSWAP"
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
# KERNVER=2.6.30.9-i586-dpup005-Celeron2G
# SATADRIVES='·sda'
# USB_SATAD=''
# PUP_HOME='/'
# PDEV1='sda2'
# Linux·puppypc·2.6.30.9-i586-dpup005-Celeron2G·#6·SMP·Sat·Jan·15·13:35:51·GMT-8·2011·i686·GNU/Linux
# Xserver=/usr/X11R7/bin/Xorg
# $LANG=de_DE@euro
# today=Sa·21.·Apr·19:35:49·GMT+1·2012
#
# TODO: TEST .rpm code ...
#FIRST TEST : overall OK:
#Fixed bugs related to pwd/cd and tar --strip= and empty .packages/${DLPKG_NAME}.files
#
########################################################################

out=/dev/null;err=$out
case $2 in
debug) set -x;;
verbose) DEBUG=1;VERB=-v;L_VERB=--verbose;A_VERB=-verbose;out=/dev/stdout;err=/dev/stderr;;
esac

error_1() {
    gxmessage -bg red "Failed to execute
    $1
    "

    #TODO
    PKG_NAME_WO_EXT="${DLPKG_BASE##*.}"
    if [ -f "$DLPKG_BASE" ];then
    :
    elif [ -f "$PKG_NAME_WO_EXT" ];then
    :
    elif [ -f "${PKG_NAME_WO_EXT}.tar.gz" ];then
    :
    fi
    #TODO#
    exit 1
}

export LANG=C
. /etc/rc.d/PUPSTATE  #this has PUPMODE and SAVE_LAYER.
. /etc/DISTRO_SPECS #has DISTRO_BINARY_COMPAT, DISTRO_COMPAT_VERSION

. /etc/xdg/menus/hierarchy #w478 has PUPHIERARCHY variable.
mkdir -p /tmp/PetGet  ##+++2012-02-04
DLPKG="$1"
DLPKG_BASE=`basename $DLPKG` #ex: scite-1.77-i686-2as.tgz
DLPKG_PATH=`dirname $DLPKG`  #ex: /root

#get the pkg name ex: scite-1.77 ...
dbPATTERN='|'"$DLPKG_BASE"'|'
DLPKG_NAME=`cat /tmp/PetGet/petget_missing_dbentries-Packages-* | grep "$dbPATTERN" | head -n 1 | cut -f 1 -d '|'`

###NOTE### not working properly with aufs...
###TODO### maybe fix by comparing content .files and copy-up.
#boot from flash: bypass tmpfs top layer, install direct to pup_save file...
DIRECTSAVEPATH=""
if [ $PUPMODE -eq 3 -o $PUPMODE -eq 7 -o $PUPMODE -eq 13 ];then
 if [ "`lsmod | grep '^unionfs' `" != "" ];then
  #note that /sbin/pup_event_frontend_d will not run snapmergepuppy if installpkg.sh or downloadpkgs.sh are running.
  #if snapmergepuppy is running, wait until it has finished...
  while [ "`pidof snapmergepuppy`" != "" ];do
   sleep 1
  done
  DIRECTSAVEPATH="/initrd${SAVE_LAYER}"
 fi
fi

cd $DLPKG_PATH
function tar_extract(){
    PETFILES=`tar --list -f ${DLPKG_MAIN}.tar`
    [ $? -ne 0 ] && error_1 "tar --list -f ${DLPKG_MAIN}.tar"
    if [ "`echo "$PETFILES" | grep '^\\./'`" != "" ];then
    #ttuuxx has created some pets with './' prefix...
     pPATTERN="s%^\\./${DLPKG_NAME}%%"
     echo "$PETFILES" | sed -e "$pPATTERN" > /root/.packages/${DLPKG_NAME}.files
     tar -x --strip=2 --directory=${DIRECTSAVEPATH}/ -f ${DLPKG_MAIN}.tar --backup --suffix=".backup.$DLPKG_BASE"
    else
    #new2dir and tgz2pet creates them this way...
     pPATTERN="s%^${DLPKG_NAME}%%"
     echo "$PETFILES" | sed -e "$pPATTERN" > /root/.packages/${DLPKG_NAME}.files
     tar -x --strip=1 --directory=${DIRECTSAVEPATH}/ -f ${DLPKG_MAIN}.tar --backup --suffix=".backup.$DLPKG_BASE"
    fi
}

case $DLPKG_BASE in
*.tar.*) TAR_COMPRESS_EXT="${DLPKG_BASE##*\.}"
esac

case $DLPKG_BASE in
 *.pet)
  DLPKG_MAIN=`basename $DLPKG_BASE .pet`
  pet2tgz $DLPKG_BASE
  [ $? -ne 0 ] && error_1 "pet2tgz $DLPKG_BASE"
  PETFILES=`tar --list -z -f ${DLPKG_MAIN}.tar.gz`
  #slackware pkg, got a case where passed the above test but failed here...
  [ $? -ne 0 ] && error_1 "tar --list -z -f ${DLPKG_MAIN}.tar.gz"
  if [ "`echo "$PETFILES" | grep '^\\./'`" != "" ];then
   #ttuuxx has created some pets with './' prefix...
   pPATTERN="s%^\\./${DLPKG_NAME}%%"
   echo "$PETFILES" | sed -e "$pPATTERN" > /root/.packages/${DLPKG_NAME}.files
   tar -z -x --backup=simple --suffix=".${DLPKG_MAIN}~" --strip=2 --directory=${DIRECTSAVEPATH}/ -f ${DLPKG_MAIN}.tar.gz
  else
   #new2dir and tgz2pet creates them this way...
   pPATTERN="s%^${DLPKG_NAME}%%"
   echo "$PETFILES" | sed -e "$pPATTERN" > /root/.packages/${DLPKG_NAME}.files
   tar -z -x --backup=simple --suffix=".${DLPKG_MAIN}~" --strip=1 --directory=${DIRECTSAVEPATH}/ -f ${DLPKG_MAIN}.tar.gz
  fi
  tgz2pet ${DLPKG_PATH}/${DLPKG_MAIN}.tar.gz

 ;;
 *.b2pet)
  DLPKG_MAIN=`basename $DLPKG_BASE .b2pet`
  pet2tgz -b $DLPKG_BASE
  [ $? -ne 0 ] && error_1 "pet2tgz -b $DLPKG_BASE"
  PETFILES=`tar --list -j -f ${DLPKG_MAIN}.tar.gz`
  #slackware pkg, got a case where passed the above test but failed here...
  [ $? -ne 0 ] && error_1 "tar --list -j -f ${DLPKG_MAIN}.tar.gz"
  if [ "`echo "$PETFILES" | grep '^\\./'`" != "" ];then
   #ttuuxx has created some pets with './' prefix...
   pPATTERN="s%^\\./${DLPKG_NAME}%%"
   echo "$PETFILES" | sed -e "$pPATTERN" > /root/.packages/${DLPKG_NAME}.files
   tar -z -j --strip=2 --directory=${DIRECTSAVEPATH}/ -f ${DLPKG_MAIN}.tar.gz --backup --suffix=".backup.$DLPKG_BASE"
  else
   #new2dir and tgz2pet creates them this way...
   pPATTERN="s%^${DLPKG_NAME}%%"
   echo "$PETFILES" | sed -e "$pPATTERN" > /root/.packages/${DLPKG_NAME}.files
   tar -z -j --strip=1 --directory=${DIRECTSAVEPATH}/ -f ${DLPKG_MAIN}.tar.gz --backup --suffix=".backup.$DLPKG_BASE"
  fi
 ;;
 *.lapet)
  DLPKG_MAIN=`basename $DLPKG_BASE .lapet`
  pet2tgz -L $DLPKG_BASE
  [ $? -ne 0 ] && error_1 "pet2tgz -L $DLPKG_BASE"
  #decompress -d
  lzma -d $DLPKG_MAIN.tar.lzma
  [ $? -ne 0 ] && error_1 "lzma -d $DLPKG_MAIN.tar.lzma"
  tar_extract
 ;;
 *.lopet)
  DLPKG_MAIN=`basename $DLPKG_BASE .lopet`
  pet2tgz -l $DLPKG_BASE
  [ $? -ne 0 ] && error_1 "pet2tgz -l $DLPKG_BASE"
  #decompress -d , extract -x , -l list
  lzop -d $DLPKG_MAIN.tar.lzo
  [ $? -ne 0 ] && error_1 "lzop -d $DLPKG_MAIN.tar.lzo"
  tar_extract
 ;;
 *.xzpet)
  DLPKG_MAIN=`basename $DLPKG_BASE .xzpet`
  pet2tgz -x $DLPKG_BASE
  [ $? -ne 0 ] && error_1 "pet2tgz -x $DLPKG_BASE"
  #decompress -d , extract -x , -t test , -v verbose
  xz -d $DLPKG_MAIN.tar.xz
  [ $? -ne 0 ] && error_1 "xz -d $DLPKG_MAIN.tar.xz"
  tar_extract
 ;;

 *.pup)
  DLPKG_MAIN=`basename $DLPKG_BASE .pup`
  rm -fr /tmp/$DLPKG_MAIN
  mkdir -p /tmp/$DLPKG_MAIN
  gunzip -t $DLPKG_BASE -d /tmp/$DLPKG_MAIN
  [ $? -ne 0 ] && error_1 "gunzip -t $DLPKG_BASE -d /tmp/$DLPKG_MAIN"
  PETFILES=`gunzip -l $DLPKG_BASE -d /tmp/$DLPKG_MAIN`
  [ $? -ne 0 ] && error_1 "gunzip -l $DLPKG_BASE -d /tmp/$DLPKG_MAIN"
  gunzip -o $DLPKG_BASE -d /tmp/$DLPKG_MAIN
  [ $? -ne 0 ] && error_1 "gunzip -o $DLPKG_BASE -d /tmp/$DLPKG_MAIN"
  rox /tmp/$DLPKG_MAIN
  sleep 1
  gxmessage "NOTICE: This is a tmp folder.
 You still need to extract archives manually and
 move or copy the files to the appropiate places.
 "
  ;;

 *.deb)
  DLPKG_MAIN=`basename $DLPKG_BASE .deb`
  PFILES=`dpkg-deb --contents $DLPKG_BASE | tr -s ' ' | cut -f 6 -d ' '`
  [ $? -ne 0 ] && error_1 "dpkg-deb --contents $DLPKG_BASE"
  echo "$PFILES" > /root/.packages/${DLPKG_NAME}.files
  dpkg-deb -x $DLPKG_BASE ${DIRECTSAVEPATH}/
  if [ $? -ne 0 ];then
   rm -f /root/.packages/${DLPKG_NAME}.files
   error_1 "dpkg-deb -x $DLPKG_BASE ${DIRECTSAVEPATH}/"
  fi
 ;;
 *.tgz)
  DLPKG_MAIN=`basename $DLPKG_BASE .tgz` #ex: scite-1.77-i686-2as
  gzip --test $DLPKG_BASE >$out 2>&1
  [ $? -ne 0 ] && error_1 "gzip --test $DLPKG_BASE"
  PFILES=`tar --list -z -f $DLPKG_BASE`
  #hmmm, got a case where passed the above test but failed here...
  [ $? -ne 0 ] && error_1 "tar --list -z -f $DLPKG_BASE"
  echo "$PFILES" > /root/.packages/${DLPKG_NAME}.files
  tar -z -x --backup --suffix="$DLPKG_MAIN" --directory=${DIRECTSAVEPATH}/ -f $DLPKG_BASE
 ;;
 *.tar.gz)
  DLPKG_MAIN=`basename $DLPKG_BASE .tar.gz` #ex: acl-2.2.47-1-i686.pkg
  gzip --test $DLPKG_BASE >$out 2>&1
  [ $? -ne 0 ] && error_1 "gzip --test $DLPKG_BASE"
  PFILES=`tar --list -z -f $DLPKG_BASE`
  [ $? -ne 0 ] && error_1 "tar --list -z -f $DLPKG_BASE"
  echo "$PFILES" > /root/.packages/${DLPKG_NAME}.files
  tar -z -x --backup --suffix="$DLPKG_MAIN" --directory=${DIRECTSAVEPATH}/ -f $DLPKG_BASE
 ;;
  *.tar.bz2)
  DLPKG_MAIN=`basename $DLPKG_BASE .tar.gz` #ex: acl-2.2.47-1-i686.pkg
  bzip2 --test $DLPKG_BASE >$out 2>&1
  [ $? -ne 0 ] && error_1 "bzip2 --test $DLPKG_BASE"
  PFILES=`tar --list -j -f $DLPKG_BASE`
  [ $? -ne 0 ] && error_1 "tar --list -j -f $DLPKG_BASE"
  echo "$PFILES" > /root/.packages/${DLPKG_NAME}.files
  tar -j -x --backup --suffix="$DLPKG_MAIN" --directory=${DIRECTSAVEPATH}/ -f $DLPKG_BASE
 ;;
  *.txz)
  DLPKG_MAIN=`basename $DLPKG_BASE .tgz` #ex: scite-1.77-i686-2as
  xz --test $DLPKG_BASE >$out 2>&1
  [ $? -ne 0 ] && error_1 "xz --test $DLPKG_BASE"
  PFILES=`tar --list -J -f $DLPKG_BASE`
  #hmmm, got a case where passed the above test but failed here...
  [ $? -ne 0 ] && error_1 "tar --list -J -f $DLPKG_BASE"
  echo "$PFILES" > /root/.packages/${DLPKG_NAME}.files
  tar -J -x --backup --suffix="$DLPKG_MAIN" --directory=${DIRECTSAVEPATH}/ -f $DLPKG_BASE
 ;;
 *.tar.xz)
  DLPKG_MAIN=`basename $DLPKG_BASE .tar.gz` #ex: acl-2.2.47-1-i686.pkg
  xz --test $DLPKG_BASE >$out 2>&1
  [ $? -ne 0 ] && error_1 "xz --test $DLPKG_BASE"
  PFILES=`tar --list -J -f $DLPKG_BASE`
  [ $? -ne 0 ] && error_1 "tar --list -J -f $DLPKG_BASE"
  echo "$PFILES" > /root/.packages/${DLPKG_NAME}.files
  tar -J -x --backup --suffix="$DLPKG_MAIN" --directory=${DIRECTSAVEPATH}/ -f $DLPKG_BASE
 ;;
 *.rpm)
    DLPKG_MAIN=`basename $DLPKG_BASE .rpm`
  RPM2CPIO="rpm2cpio"
  [ "`which rpm2cpio2`" ] && RPM2CPIO="rpm2cpio2"
    mkdir -p /tmp/$DLPKG_MAIN
    mv $DLPKG /tmp/$DLPKG_MAIN/
    cd /tmp/$DLPKG_MAIN
    mkdir ./extract
    cd ./extract
    $RPM2CPIO ../$DLPKG_BASE | cpio -d -i -m
    FILES=`find . -type f`;ARCHIVE='';
    for i in $FILES;do
    file $i |grep -i 'compressed' && { ARCHIVE=$i;break; };done
    if [ "$ARCHIVE" ];then
    COMPRESSION=`file $ARCHIVE |cut -f2 -d':'|awk '{print $1}'`
    case $COMPRESSION in
    gzip)
    PETFILES=`tar --list -z -f $ARCHIVE`
    [ $? -ne 0 ] && error_1 "tar --list -z -f $ARCHIVE"
    if [ "`echo "$PETFILES" | grep '^\\./'`" != "" ];then
    echo "TTUUXXX ... --strip=1"
    #ttuuxx has created some pets with './' prefix...
     pPATTERN="s%^\\./${DLPKG_NAME}%%"
     echo "$PETFILES" | sed -e "$pPATTERN" > /root/.packages/${DLPKG_NAME}.files
     tar -x --strip=1 --directory=${DIRECTSAVEPATH}/ -f $ARCHIVE --backup --suffix=".backup.$DLPKG_BASE"
    else
    echo "NEW2DIR ... no strip"
    #new2dir and tgz2pet creates them this way...
     pPATTERN="s%^${DLPKG_NAME}%%"
     echo "$PETFILES" | sed -e "$pPATTERN" > /root/.packages/${DLPKG_NAME}.files
     tar -x --directory=${DIRECTSAVEPATH}/ -f $ARCHIVE --backup --suffix=".backup.$DLPKG_BASE"
    fi
    #tar -C / -xzf $ARCHIVE --backup --suffix=".backup.$DLPKG_BASE";;
    ;;
    bzip2)
    PETFILES=`tar --list -j -f $ARCHIVE`
    [ $? -ne 0 ] && error_1 "tar --list -j -f $ARCHIVE"
    if [ "`echo "$PETFILES" | grep '^\\./'`" != "" ];then
    #ttuuxx has created some pets with './' prefix...
     pPATTERN="s%^\\./${DLPKG_NAME}%%"
     echo "$PETFILES" | sed -e "$pPATTERN" > /root/.packages/${DLPKG_NAME}.files
     tar -x --strip=2 --directory=${DIRECTSAVEPATH}/ -f $ARCHIVE --backup --suffix=".backup.$DLPKG_BASE"
    else
    #new2dir and tgz2pet creates them this way...
     pPATTERN="s%^${DLPKG_NAME}%%"
     echo "$PETFILES" | sed -e "$pPATTERN" > /root/.packages/${DLPKG_NAME}.files
     tar -x --strip=1 --directory=${DIRECTSAVEPATH}/ -f $ARCHIVE --backup --suffix=".backup.$DLPKG_BASE"
    fi
    #tar -C / -xjf $ARCHIVE --backup --suffix=".backup.$DLPKG_BASE";;
    ;;
    *):
    ;;
    esac
    fi #.rpm"$ARCHIVE"
    cd /tmp;rm -rf ./$DLPKG_MAIN/
    ;;
esac

#rm -f $DLPKG_BASE 2>$ERR
#rm -f ${DLPKG_MAIN}.tar.gz 2>$ERR
echo "$0:$LINENO"
cat /root/.packages/${DLPKG_NAME}.files
#pkgname.files may need to be fixed...
FIXEDFILES=`cat /root/.packages/${DLPKG_NAME}.files | grep -v '^\\./$'| grep -v '^/$' | sed -e 's%^\\.%%' -e 's%^%/%' -e 's%^//%/%'`
echo "$FIXEDFILES" > /root/.packages/${DLPKG_NAME}.files
echo "$0:$LINENO"
cat /root/.packages/${DLPKG_NAME}.files
#flush unionfs cache, so files in pup_save layer will appear "on top"...
if [ "$DIRECTSAVEPATH" != "" ];then
 #but first, clean out any bad whiteout files...
 find /initrd/pup_rw -mount -type f -name .wh.\* |
 while read ONEWHITEOUT
 do
  ONEWHITEOUTFILE=`basename "$ONEWHITEOUT"`
  ONEWHITEOUTPATH=`dirname "$ONEWHITEOUT"`
  if [ "$ONEWHITEOUTFILE" = ".wh.__dir_opaque" ];then
   [ "`grep "$ONEWHITEOUTPATH" /root/.packages/${DLPKG_NAME}.files`" != "" ] && rm -f "$ONEWHITEOUT"
   continue
  fi
  echo "$0:$LINENO"
  ONEPATTERN=`echo -n "$ONEWHITEOUT" | sed -e 's%/\\.wh\\.%/%'`'$'
  [ "`grep "$ONEPATTERN" /root/.packages/${DLPKG_NAME}.files`" != "" ] && rm -f "$ONEWHITEOUT"
 done
 #now re-evaluate all the layers...
 mount -t unionfs -o remount,incgen unionfs /
 sync
fi

#some .pet pkgs have images at '/'...
mv /*24.xpm /usr/local/lib/X11/pixmaps/ 2>$err
mv /*32.xpm /usr/local/lib/X11/pixmaps/ 2>$err
mv /*32.png /usr/local/lib/X11/pixmaps/ 2>$err
mv /*48.xpm /usr/local/lib/X11/pixmaps/ 2>$err
mv /*48.png /usr/local/lib/X11/pixmaps/ 2>$err
mv /*.xpm /usr/local/lib/X11/mini-icons/ 2>$err
mv /*.png /usr/local/lib/X11/mini-icons/ 2>$err

#post-install script?...
if [ -f /pinstall.sh ];then #pet pkgs.
 chmod +x /pinstall.sh
 cd /
 sh /pinstall.sh
 rm -f /pinstall.sh
fi
if [ -f /install/doinst.sh ];then #slackware pkgs.
 chmod +x /install/doinst.sh
 cd /
 sh /install/doinst.sh
 rm -rf /install
fi

#v424 .pet pkgs may have a post-uninstall script...
if [ -f /puninstall.sh ];then
 mv -f /puninstall.sh /root/.packages/${DLPKG_NAME}.remove
fi

#w465 <pkgname>.pet.specs is in older pet pkgs, just dump it...
#maybe a '$APKGNAME.pet.specs' file created by dir2pet script...
rm -f /*.pet.specs 2>$err
#...note, this has a setting to prevent .files and entry in user-installed-packages, so install not registered.

#add entry to /root/.packages/user-installed-packages...
#w465 a pet pkg may have /pet.specs which has a db entry...
if [ -f /pet.specs -a -s /pet.specs ];then #w482 ignore zero-byte file.
 DB_ENTRY=`cat /pet.specs | head -n 1`
 rm -f /pet.specs
else
 echo "$0:$LINENO"
 [ -f /pet.specs ] && rm -f /pet.specs #w482 remove zero-byte file.
 dlPATTERN='|'"`echo -n "$DLPKG_BASE" | sed -e 's%\\-%\\\\-%'`"'|'
 DB_ENTRY=`cat /tmp/PetGet/petget_missing_dbentries-Packages-* | grep "$dlPATTERN" | head -n 1`
fi

echo "DLPKG_BASE='$DLPKG_BASE'"
echo "DLPKG_NAME='$DLPKG_NAME'"
echo "DB_ENTRY='$DB_ENTRY'"
##+++2011-12-27 KRG check if $DLPKG_BASE matches DB_ENTRY 1 so uninstallation works :Ooops:
db_pkg_name=`echo "$DB_ENTRY" |cut -f 1 -d '|'`
echo "db_pkg_name='$db_pkg_name'"
if [ "$db_pkg_name" != "$DLPKG_NAME" ];then
echo "not equal , sed ing now"
DB_ENTRY=`echo "$DB_ENTRY" |sed "s#$db_pkg_name#$DLPKG_NAME#"`
fi
##+++2011-12-27 KRG

#see if a .desktop file was installed, fix category...
ONEDOT=""
DEFICON='Executable.xpm'
CATEGORY=`echo -n "$DB_ENTRY" | cut -f 5 -d '|'`
#fix category so finds a place in menu... (same code in woof 2createpackages)
#i think allow field5 to specify a sub-category, 'category;subcategory'
#if no sub-cat then it will come into one of these cases:
case $CATEGORY in
 Desktop)    CATEGORY='Desktop;X-Desktop' ; DEFICON='mini.window3d.xpm' ;;
 System)     CATEGORY='System' ; DEFICON='mini-term.xpm' ;;
 Setup)      CATEGORY='Setup;X-SetupEntry' ; DEFICON='so.xpm' ;;
 Utility)    CATEGORY='Utility' ; DEFICON='mini-hammer.xpm' ;;
 Filesystem) CATEGORY='Filesystem;FileSystem' ; DEFICON='mini-filemgr.xpm' ;;
 Graphic)    CATEGORY='Graphic;Presentation' ; DEFICON='image_2.xpm' ;;
 Document)   CATEGORY='Document;X-Document' ; DEFICON='mini-doc1.xpm' ;;
 Calculate)  CATEGORY='Calculate;X-Calculate' ; DEFICON='mini-calc.xpm' ;;
 Personal)   CATEGORY='Personal;X-Personal' ; DEFICON='mini-book2.xpm' ;;
 Network)    CATEGORY='Network' ; DEFICON='pc-2x.xpm' ;;
 Internet)   CATEGORY='Internet;X-Internet' ; DEFICON='pc2www.xpm' ;;
 Multimedia) CATEGORY='Multimedia;AudioVideo' ; DEFICON='Animation.xpm' ;;
 Fun)        CATEGORY='Fun;Game' ; DEFICON='mini-maze.xpm' ;;
 Develop)    CATEGORY='Utility' ; DEFICON='mini-hex.xpm' ;;
 Help)       CATEGORY='Utility' ; DEFICON='info16.xpm' ;;
 *)          CATEGORY='BuildingBlock' ; DEFICON='Executable.xpm' ;; #w482
esac
cPATTERN="s%^Categories=.*%Categories=${CATEGORY}%"
iPATTERN="s%^Icon=.*%Icon=${DEFICON}%"
for ONEDOT in `grep '\.desktop$' /root/.packages/${DLPKG_NAME}.files`
do
 #w478 find if category is already valid...
 CATFOUND="no"
 for ONEORIGCAT in `cat $ONEDOT | grep '^Categories=' | head -n 1 | cut -f 2 -d '=' | tr ';' ' '`
 do
  oocPATTERN=' '"$ONEORIGCAT"' '
  echo "$0:$LINENO"
  [ "`echo "$PUPHIERARCHY" | tr -s ' ' | cut -f 3 -d ' ' | tr ',' ' ' | sed -e 's%^% %' -e 's%$% %' | grep "$oocPATTERN"`" != "" ] && CATFOUND="yes"
 done
 if [ "$CATFOUND" = "no" ];then
  echo "$0:$LINENO"
  sed -e "$cPATTERN" $ONEDOT > /tmp/PetGet/petget_category
  mv -f /tmp/PetGet/petget_category $ONEDOT
 else
  CATEGORY=`echo -n "$ONEORIGCAT" | rev | cut -f 1 -d ' ' | rev` #w482
 fi
 #w019 does the icon exist?...
 ICON=`grep '^Icon=' $ONEDOT | cut -f 2 -d '='`
 if [ "$ICON" != "" ];then
  [ -e $ICON ] && continue #it may have a hardcoded path.
  [ "`find /usr/local/lib/X11 /usr/share/icons /usr/share/pixmaps /usr/local/share/pixmaps -name $ICON -o -name $ICON.png -o -name $ICON.xpm -o -name $ICON.jpg 2>/dev/null`" != "" ] && continue
  #substitute a default icon...
  echo "$0:$LINENO"
  sed -e "$iPATTERN" $ONEDOT > /tmp/PetGet/petget-installpkg-tmp
  mv -f /tmp/PetGet/petget-installpkg-tmp $ONEDOT
 fi
done

#due to images at / in .pet and post-install script, .files may have some invalid entries...
INSTFILES=`cat /root/.packages/${DLPKG_NAME}.files`
echo "$INSTFILES" |
while read ONEFILE
do
 if [ ! -e "$ONEFILE" ];then
  ofPATTERN='^'"$ONEFILE"'$'
  grep -v "$ofPATTERN" /root/.packages/${DLPKG_NAME}.files > /tmp/PetGet/petget_instfiles
  mv -f /tmp/PetGet/petget_instfiles /root/.packages/${DLPKG_NAME}.files
 fi
done
echo "$0:$LINENO"
cat /root/.packages/${DLPKG_NAME}.files
#w482 DB_ENTRY may be missing DB_category and DB_description fields...
#pkgname|nameonly|version|pkgrelease|category|size|path|fullfilename|dependencies|description|
#optionally on the end: compileddistro|compiledrelease|repo| (fields 11,12,13)
DESKTOPFILE=`grep '\.desktop$' /root/.packages/${DLPKG_NAME}.files | head -n 1`
if [ "$DESKTOPFILE" != "" ];then
 DB_category=`echo -n "$DB_ENTRY" | cut -f 5 -d '|'`
 DB_description=`echo -n "$DB_ENTRY" | cut -f 10 -d '|'`
 CATEGORY="$DB_category"
 DESCRIPTION="$DB_description"
 if [ "$DB_category" = "" ];then
  CATEGORY=`cat $DESKTOPFILE | grep '^Categories=' | cut -f 2 -d '=' | rev | cut -f 1 -d ';' | rev`
  #v424 but want the top-level menu category...
  catPATTERN="[ ,]${CATEGORY},|[ ,]${CATEGORY}"'$'
  CATEGORY=`grep -E "$catPATTERN" /etc/xdg/menus/hierarchy | grep ':' | cut -f 1 -d ' ' | head -n 1`
 fi
 if [ "$DB_description" = "" ];then
  DESCRIPTION=`cat $DESKTOPFILE | grep '^Comment=' | cut -f 2 -d '='`
  [ "$DESCRIPTION" = "" ] && DESCRIPTION=`cat $DESKTOPFILE | grep '^Name=' | cut -f 2 -d '='`
 fi
 if [ "$DB_category" = "" -o "$DB_description" = "" ];then
  newDB_ENTRY=`echo -n "$DB_ENTRY" | cut -f 1-4 -d '|'`
  newDB_ENTRY="$newDB_ENTRY"'|'"$CATEGORY"'|'
  newDB_ENTRY="$newDB_ENTRY""`echo -n "$DB_ENTRY" | cut -f 6-9 -d '|'`"
  newDB_ENTRY="$newDB_ENTRY"'|'"$DESCRIPTION"'|'
  newDB_ENTRY="$newDB_ENTRY""`echo -n "$DB_ENTRY" | cut -f 11-14 -d '|'`"
  #[ "`echo -n "newDB_ENTRY" | rev | cut -c 1`" != "|" ] && newDB_ENTRY="$newDB_ENTRY"'|'
  DB_ENTRY="$newDB_ENTRY"
 fi
fi

echo "$DB_ENTRY" >> /root/.packages/user-installed-packages

#announcement of successful install...
#announcement is done after all downloads, in downloadpkgs.sh...
CATEGORY=`echo -n "$CATEGORY" | cut -f 1 -d ';'`
[ "$CATEGORY" = "" ] && CATEGORY="none"
[ "$CATEGORY" = "BuildingBlock" ] && CATEGORY="none"
echo "PACKAGE: $DLPKG_NAME CATEGORY: $CATEGORY" >> /tmp/PetGet/petget-installed-pkgs-log
echo "$0:$LINENO '${DLPKG_NAME}'"
cat /root/.packages/${DLPKG_NAME}.files
###END###
