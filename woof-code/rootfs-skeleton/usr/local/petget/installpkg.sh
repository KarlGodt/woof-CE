#!/bin/sh
#(c) Copyright Barry Kauler 2009, puppylinux.com
#2009 Lesser GPL licence v2 (http://www.fsf.org/licensing/licenses/lgpl.html).
#called from /usr/local/petget/downloadpkgs.sh and petget.
#passed param is the path and name of the downloaded package.
#/tmp/petget_missing_dbentries-Packages-* has database entries for the set of pkgs being downloaded.
#w456 warning: petget may write to /tmp/petget_missing_dbentries-Packages-alien with missing fields.
#w478, w482 fix for pkg menu categories.
#w482 detect zero-byte pet.specs, fix typo.



#************
#KRG


OUT=/dev/null;ERR=$OUT
[ "$DEBUG" ] && { OUT=/dev/stdout;ERR=/dev/stderr; }
[ "$DEBUG" = 2 ] && set -x


Version=1.1-KRG-MacPup_O2

usage(){
MSG="
$0 [ help | version ]
"
echo "$MSG
$2"
exit $1
}
[ "`echo "$1" | grep -Ei "help|\-h"`" ] && usage 0
[ "`echo "$1" | grep -Ei "version|\-V"`" ] && { echo "$0: $Version";exit 0; }


trap "exit" HUP INT QUIT ABRT KILL TERM


#KRG
#************


#information from 'labrador', to expand a .pet directly to '/':
#NAME="a52dec-0.7.4"
#pet2tgz "${NAME}.pet"
#tar -C / --transform 's/^\(\.\/\)\?'"$NAME"'//g' -zxf "${NAME}.tar.gz"
#i found this also works:
#tar -z -x --strip=1 --directory=/ -f bluefish-1.0.7.tar.gz
#v424 .pet pkgs may have post-uninstall script, puninstall.sh

echo "$0: START" >&2

OUT=/dev/null;ERR=$OUT
[ "$DEBUG" ] && { OUT=/dev/stdout;ERR=/dev/stderr; }

export LANG=C
. /etc/rc.d/PUPSTATE  #this has PUPMODE and SAVE_LAYER.
. /etc/DISTRO_SPECS #has DISTRO_BINARY_COMPAT, DISTRO_COMPAT_VERSION

. /etc/xdg/menus/hierarchy #w478 has PUPHIERARCHY variable.

[ "$1" ] || { echo "Need parameter PKGNAME" >&2;exit 1; }

echo "$0: '$@'" >&2

DLPKG="$1"
DLPKG_BASE=`basename $DLPKG` #ex: scite-1.77-i686-2as.tgz
DLPKG_PATH=`dirname $DLPKG`  #ex: /root

#get the pkg name ex: scite-1.77 ...
dbPATTERN='|'"$DLPKG_BASE"'|'
DLPKG_NAME=`cat /tmp/petget_missing_dbentries-Packages-* | grep "$dbPATTERN" | head -n 1 | cut -f 1 -d '|'`

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
echo $LINENO >&2
function tar_extract_pet(){
  PETFILES=`tar --list -z -f ${DLPKG_MAIN}.tar.gz`
  #slackware pkg, got a case where passed the above test but failed here...
  [ $? -ne 0 ] && exit 1
  if [ "`echo "$PETFILES" | grep '^\\./'`" != "" ];then
   #ttuuxx has created some pets with './' prefix...
   pPATTERN="s%^\\./${DLPKG_NAME}%%"
   echo "$PETFILES" | sed -e "$pPATTERN" > /root/.packages/${DLPKG_NAME}.files
   tar -z -x --strip=2 --directory=${DIRECTSAVEPATH}/ -f ${DLPKG_MAIN}.tar.gz --backup --suffix=".backup.$DLPKG_BASE"
  else
   #new2dir and tgz2pet creates them this way...
   pPATTERN="s%^${DLPKG_NAME}%%"
   echo "$PETFILES" | sed -e "$pPATTERN" > /root/.packages/${DLPKG_NAME}.files
   tar -z -x --strip=1 --directory=${DIRECTSAVEPATH}/ -f ${DLPKG_MAIN}.tar.gz --backup --suffix=".backup.$DLPKG_BASE"
  fi
}

function tar_extract(){
	PETFILES=`tar --list -f ${DLPKG_MAIN}.tar`
	[ $? -ne 0 ] && exit 1
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
 *.pet)
  DLPKG_MAIN=`basename $DLPKG_BASE .pet`
  pet2tgz $DLPKG_BASE
  [ $? -ne 0 ] && exit 1
  PETFILES=`tar --list -z -f ${DLPKG_MAIN}.tar.gz`
  #slackware pkg, got a case where passed the above test but failed here...
  [ $? -ne 0 ] && exit 1
  if [ "`echo "$PETFILES" | grep '^\\./'`" != "" ];then
   #ttuuxx has created some pets with './' prefix...
   pPATTERN="s%^\\./${DLPKG_NAME}%%"
   echo "$PETFILES" | sed -e "$pPATTERN" > /root/.packages/${DLPKG_NAME}.files
   tar -z -x --strip=2 --directory=${DIRECTSAVEPATH}/ -f ${DLPKG_MAIN}.tar.gz --backup --suffix=".backup.$DLPKG_BASE"
  else
   #new2dir and tgz2pet creates them this way...
   pPATTERN="s%^${DLPKG_NAME}%%"
   echo "$PETFILES" | sed -e "$pPATTERN" > /root/.packages/${DLPKG_NAME}.files
   tar -z -x --strip=1 --directory=${DIRECTSAVEPATH}/ -f ${DLPKG_MAIN}.tar.gz --backup --suffix=".backup.$DLPKG_BASE"
  fi
  tgz2pet ${DLPKG_MAIN}.tar.gz
 ;;
 *.b2pet)
  DLPKG_MAIN=`basename $DLPKG_BASE .b2pet`
  pet2tgz -b $DLPKG_BASE
  [ $? -ne 0 ] && exit 1
  PETFILES=`tar --list -j -f ${DLPKG_MAIN}.tar.gz`
  #slackware pkg, got a case where passed the above test but failed here...
  [ $? -ne 0 ] && exit 1
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
  tgz2pet -b ${DLPKG_MAIN}.tar.bz2
 ;;
 *.lapet)
  DLPKG_MAIN=`basename $DLPKG_BASE .lapet`
  pet2tgz -L $DLPKG_BASE
  [ $? -ne 0 ] && exit 1
  #decompress -d
  lzma -d $DLPKG_MAIN.tar.lzma
  [ $? -ne 0 ] && exit 1
  tar_extract
  tgz2pet -L ${DLPKG_MAIN}.tar.lzma
 ;;
 *.lopet)
  DLPKG_MAIN=`basename $DLPKG_BASE .lopet`
  pet2tgz -l $DLPKG_BASE
  [ $? -ne 0 ] && exit 1
  #decompress -d , extract -x , -l list
  lzop -d $DLPKG_MAIN.tar.lzo
  [ $? -ne 0 ] && exit 1
  tar_extract
  tgz2pet -l ${DLPKG_MAIN}.tar.lzo
 ;;
 *.xzpet)
  DLPKG_MAIN=`basename $DLPKG_BASE .xzpet`
  pet2tgz -x $DLPKG_BASE
  [ $? -ne 0 ] && exit 1
  #decompress -d , extract -x , -t test , -v verbose
  xz -d $DLPKG_MAIN.tar.xz
  [ $? -ne 0 ] && exit 1
  tar_extract
  tgz2pet -x ${DLPKG_MAIN}.tar.xz
 ;;
 *.pup)

 :
 ;;
 *.deb)
  DLPKG_MAIN=`basename $DLPKG_BASE .deb`
  PFILES=`dpkg-deb --contents $DLPKG_BASE | tr -s ' ' | cut -f 6 -d ' '`
  [ $? -ne 0 ] && exit 1
  echo "$PFILES" > /root/.packages/${DLPKG_NAME}.files
  for cont in $PFILES;do
  if [ -f "$cont" ]; then
  mv "$cont" "$cont".backup.$DLPKG_BASE
  fi
  done
  dpkg-deb -x $DLPKG_BASE ${DIRECTSAVEPATH}/
  if [ $? -ne 0 ];then
   rm -f /root/.packages/${DLPKG_NAME}.files
   exit 1
  fi
 ;;
 *.tgz)
  DLPKG_MAIN=`basename $DLPKG_BASE .tgz` #ex: scite-1.77-i686-2as
  gzip --test $DLPKG_BASE >$OUT 2>$ERR
  [ $? -ne 0 ] && exit 1
  PFILES=`tar --list -z -f $DLPKG_BASE`
  #hmmm, got a case where passed the above test but failed here...
  [ $? -ne 0 ] && exit 1
  echo "$PFILES" > /root/.packages/${DLPKG_NAME}.files
  tar -z -x --directory=${DIRECTSAVEPATH}/ -f $DLPKG_BASE --backup --suffix=".backup.$DLPKG_BASE"
 ;;
 *.tar.gz)
  DLPKG_MAIN=`basename $DLPKG_BASE .tar.gz` #ex: acl-2.2.47-1-i686.pkg
  gzip --test $DLPKG_BASE >$OUT 2>$ERR
  [ $? -ne 0 ] && exit 1
  PFILES=`tar --list -z -f $DLPKG_BASE`
  [ $? -ne 0 ] && exit 1
  echo "$PFILES" > /root/.packages/${DLPKG_NAME}.files
  tar -z -x --directory=${DIRECTSAVEPATH}/ -f $DLPKG_BASE --backup --suffix=".backup.$DLPKG_BASE"
 ;;
esac

#rm -f $DLPKG_BASE 2>$ERR
#rm -f $DLPKG_MAIN.tar.gz 2>$ERR

echo $LINENO >&2

#pkgname.files may need to be fixed...
FIXEDFILES=`cat /root/.packages/${DLPKG_NAME}.files | grep -v '^\\./$'| grep -v '^/$' | sed -e 's%^\\.%%' -e 's%^%/%' -e 's%^//%/%'`
echo "$FIXEDFILES" > /root/.packages/${DLPKG_NAME}.files

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
  ONEPATTERN=`echo -n "$ONEWHITEOUT" | sed -e 's%/\\.wh\\.%/%'`'$'
  [ "`grep "$ONEPATTERN" /root/.packages/${DLPKG_NAME}.files`" != "" ] && rm -f "$ONEWHITEOUT"
 done
 #now re-evaluate all the layers...
 mount -t unionfs -o remount,incgen unionfs /
 sync
fi

#some .pet pkgs have images at '/'...
mv /*24.xpm /usr/local/lib/X11/pixmaps/ 2>$ERR
mv /*32.xpm /usr/local/lib/X11/pixmaps/ 2>$ERR
mv /*32.png /usr/local/lib/X11/pixmaps/ 2>$ERR
mv /*48.xpm /usr/local/lib/X11/pixmaps/ 2>$ERR
mv /*48.png /usr/local/lib/X11/pixmaps/ 2>$ERR
mv /*.xpm /usr/local/lib/X11/mini-icons/ 2>$ERR
mv /*.png /usr/local/lib/X11/mini-icons/ 2>$ERR

echo $LINENO >&2

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
rm -f /*.pet.specs 2>$ERR
#...note, this has a setting to prevent .files and entry in user-installed-packages, so install not registered.

#add entry to /root/.packages/user-installed-packages...
#w465 a pet pkg may have /pet.specs which has a db entry...
if [ -f /pet.specs -a -s /pet.specs ];then #w482 ignore zero-byte file.
 DB_ENTRY=`cat /pet.specs | head -n 1`
 rm -f /pet.specs
else
 [ -f /pet.specs ] && rm -f /pet.specs #w482 remove zero-byte file.
 dlPATTERN='|'"`echo -n "$DLPKG_BASE" | sed -e 's%\\-%\\\\-%'`"'|'
 DB_ENTRY=`cat /tmp/petget_missing_dbentries-Packages-* | grep "$dlPATTERN" | head -n 1`
fi

echo $LINENO >&2

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
  [ "`echo "$PUPHIERARCHY" | tr -s ' ' | cut -f 3 -d ' ' | tr ',' ' ' | sed -e 's%^% %' -e 's%$% %' | grep "$oocPATTERN"`" != "" ] && CATFOUND="yes"
 done
 if [ "$CATFOUND" = "no" ];then
  sed -e "$cPATTERN" $ONEDOT > /tmp/petget_category
  mv -f /tmp/petget_category $ONEDOT
 else
  CATEGORY=`echo -n "$ONEORIGCAT" | rev | cut -f 1 -d ' ' | rev` #w482
 fi
 #w019 does the icon exist?...
 ICON=`grep '^Icon=' $ONEDOT | cut -f 2 -d '='`
 if [ "$ICON" != "" ];then
  [ -e $ICON ] && continue #it may have a hardcoded path.
  [ "`find /usr/local/lib/X11 /usr/share/icons /usr/share/pixmaps /usr/local/share/pixmaps -name $ICON -o -name $ICON.png -o -name $ICON.xpm -o -name $ICON.jpg 2>/dev/null`" != "" ] && continue
  #substitute a default icon...
  sed -e "$iPATTERN" $ONEDOT > /tmp/petget-installpkg-tmp
  mv -f /tmp/petget-installpkg-tmp $ONEDOT
 fi
done

echo $LINENO >&2

#due to images at / in .pet and post-install script, .files may have some invalid entries...
INSTFILES=`cat /root/.packages/${DLPKG_NAME}.files`
echo "$INSTFILES" |
while read ONEFILE
do
 if [ ! -e "$ONEFILE" ];then
  ofPATTERN='^'"$ONEFILE"'$'
  grep -v "$ofPATTERN" /root/.packages/${DLPKG_NAME}.files > /tmp/petget_instfiles
  mv -f /tmp/petget_instfiles /root/.packages/${DLPKG_NAME}.files
 fi
done

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
  DESCRIPTION=`cat $DESKTOPFILE |  | grep '^Comment=' | cut -f 2 -d '='`
  [ "$DESCRIPTION" = "" ] && DESCRIPTION=`cat $DESKTOPFILE |  | grep '^Name=' | cut -f 2 -d '='`
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

echo $LINENO >&2

echo "$DB_ENTRY" >> /root/.packages/user-installed-packages

#announcement of successful install...
#announcement is done after all downloads, in downloadpkgs.sh...
CATEGORY=`echo -n "$CATEGORY" | cut -f 1 -d ';'`
[ "$CATEGORY" = "" ] && CATEGORY="none"
[ "$CATEGORY" = "BuildingBlock" ] && CATEGORY="none"
echo "PACKAGE: $DLPKG_NAME CATEGORY: $CATEGORY" >> /tmp/PetGet/petget-installed-pkgs.log

echo "$0: END" >&2

###END###
