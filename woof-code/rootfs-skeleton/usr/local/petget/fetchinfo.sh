#!/bin/sh
#called from installpreview.sh.
#passed param (also variable TREE1) is name of pkg, ex: abiword-1.2.3.
#/tmp/PetGet/petget_filterversion has the repository that installing from.
#w019 now have /root/.packages/PKGS_HOMEPAGES

. /etc/DISTRO_SPECS #has DISTRO_BINARY_COMPAT, DISTRO_COMPAT_VERSION
. /root/.packages/DISTRO_PKGS_SPECS

#ex: TREE1=abiword-1.2.4 (first field in database entry).
DB_FILE=Packages-`cat /tmp/PetGet/petget_filterversion` #ex: Packages-slackware-12.2-official

tPATTERN='^'"$TREE1"'|'
DB_ENTRY="`grep "$tPATTERN" /root/.packages/$DB_FILE | head -n 1`"
#line format: pkgname|nameonly|version|pkgrelease|category|size|path|fullfilename|dependencies|description|
#optionally on the end: compileddistro|compiledrelease|repo| (fields 11,12,13)

DB_nameonly="`echo -n "$DB_ENTRY" | cut -f 2 -d '|'`"
DB_fullfilename="`echo -n "$DB_ENTRY" | cut -f 8 -d '|'`"

DB_DISTRO="`echo -n "$DB_FILE" | cut -f 2 -d '-'`"  #exs: slackware  arch     ubuntu
DB_RELEASE="`echo -n "$DB_FILE" | cut -f 3 -d '-'`" #exs: 12.2       200902   intrepid
DB_SUB="`echo -n "$DB_FILE" | cut -f 4 -d '-'`"     #exs: official   extra    universe

case $DB_DISTRO in
 slackware)
  if [ ! -f /root/.packages/PACKAGES.TXT-${DB_SUB} ];then
   yaf-splash -font "8x16" -outline 0 -margin 4 -bg orange -text "Please wait, downloading database file to /root/.packages/PACKAGES.TXT-${DB_SUB}..." &
   X5PID=$!
   cd /root/.packages
   case $DB_SUB in
    official)
     wget http://slackware.cs.utah.edu/pub/slackware/slackware-${DB_RELEASE}/PACKAGES.TXT
    ;;
    slacky)
     wget http://repository.slacky.eu/slackware-${DB_RELEASE}/PACKAGES.TXT
    ;;
   esac
   sync
   mv -f PACKAGES.TXT PACKAGES.TXT-${DB_SUB}
   kill $X5PID
  fi
  cat /root/.packages/PACKAGES.TXT-${DB_SUB} | tr -s ' ' | sed -e 's% $%%' | tr '%' ' ' | tr '\n' '%' | sed -e 's/%%/@/g' | grep -o "PACKAGE NAME: ${DB_fullfilename}[^@]*" | tr '%' '\n' > /tmp/PetGet/petget_slackware_pkg_extra_info
  sync
  nohup leafpad /tmp/PetGet/petget_slackware_pkg_extra_info &
 ;;
 debian)
  nohup defaulthtmlviewer http://packages.debian.org/${DB_RELEASE}/${DB_nameonly} &
 ;;
 ubuntu)
  nohup defaulthtmlviewer http://packages.ubuntu.com/${DB_RELEASE}/${DB_nameonly} &
 ;;
 arch)
  nohup defaulthtmlviewer http://www.archlinux.org/packages/${DB_SUB}/i686/${DB_nameonly}/ &
 ;;
 puppy|t2)
  #rm -f /tmp/PetGet/gethomepage_1 2>/dev/null
  #wget --tries=2 --output-document=/tmp/PetGet/gethomepage_1 http://club.mandriva.com/xwiki/bin/view/rpms/Application/$DB_nameonly
  #LINK1="`grep 'View package information' /tmp/PetGet/gethomepage_1 | head -n 1 | grep -o 'href=".*' | cut -f 2 -d '"'`"
  #rm -f /tmp/PetGet/gethomepage_2 2>/dev/null
  #wget --tries=2 --output-document=/tmp/PetGet/gethomepage_2 http://club.mandriva.com/xwiki/bin/view/rpms/Application/${LINK1}
  #HOMELINK="`grep 'Homepage:' /tmp/PetGet/gethomepage_2 | grep -o 'href=".*' | cut -f 2 -d '"'`"
  #w019 fast (see also /usr/sbin/indexgen.sh)...
  HOMESITE="http://en.wikipedia.org/wiki/${DB_nameonly}"
  nEXPATTERN="^${DB_nameonly} "
  REALHOME="`cat /root/.packages/PKGS_HOMEPAGES | grep -i "$nEXPATTERN" | head -n 1 | cut -f 2 -d ' '`"
  [ "$REALHOME" != "" ] && HOMESITE="$REALHOME"
  nohup defaulthtmlviewer $HOMESITE &
 ;;
esac

###END###
