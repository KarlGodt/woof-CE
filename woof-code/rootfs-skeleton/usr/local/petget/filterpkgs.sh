#!/bin/sh
#
# New header by Karl Reimer Godt, September 2014
  _TITLE_="Puppy_filterpkgs.sh"
_VERSION_=1.0omega
_COMMENT_="$_TITLE_:Puppy Linux shell script [to TODO here]"

MY_SELF="/usr/local/petget/filterpkgs.sh"
MY_PID=$$

test -f /etc/rc.d/f4puppy5 && {
source /etc/rc.d/f4puppy5

ADD_PARAMETER_LIST=""
ADD_PARAMETERS=""
_provide_basic_parameters

ADD_HELP_MSG="$_COMMENT_"
_parse_basic_parameters "$@"
[ "$DO_SHIFT" ] && [ ! "${DO_SHIFT//[[:digit:]]/}" ] && {
  for oneSHIFT in 1; do shift; done; }

_trap

}
# End new header
#
#(c) Copyright Barry Kauler 2009, puppylinux.com
#2009 Lesser GPL licence v2 (http://www.fsf.org/licensing/licenses/lgpl.html).
#called from pkg_chooser.sh, provides filtered formatted list of uninstalled pkgs.
# ...this has written to /tmp/petget_pkg_first_char, ex: 'mn'
#filter category may be passed param to this script, ex: 'Document'
# or, /tmp/petget_filtercategory was written by pkg_chooser.sh.
#repo may be written to /tmp/petget_filterversion by pkg_chooser.sh, ex: slackware-12.2-official
#/tmp/petget_pkg_name_aliases_patterns setup in pkg_chooser.sh, name aliases.
#written for Woof, standardised package database format.
#v425 'ALL' may take awhile, put up please wait msg.

__old_header__(){  #BEGIN
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

###KRG Fr 31. Aug 23:34:58 GMT+1 2012
}  ###__old_header__(){ #END

echo "$0:$*" >&2

export LANG=C

. /etc/DISTRO_SPECS #has DISTRO_BINARY_COMPAT, DISTRO_COMPAT_VERSION
. /root/.packages/DISTRO_PKGS_SPECS
. /root/.packages/PKGS_MANAGEMENT #has DISTRO_PPM_DEVX_EXCEPTIONS, PKG_ALIASES_INSTALLED, PKG_NAME_ALIASES

#alphabetic group...
PKG_FIRST_CHAR=`cat /tmp/petget_pkg_first_char` #written in pkg_chooser.sh, ex: 'mn'
[ "$PKG_FIRST_CHAR" = "ALL" ] && PKG_FIRST_CHAR='a-z0-9'

X1PID=0
if [ "`cat /tmp/petget_pkg_first_char`" = "ALL" ];then
 yaf-splash -font "8x16" -outline 0 -margin 4 -bg orange -text "Please wait, processing all entries may take awhile..." &
 X1PID=$!
fi

#which repo...
FIRST_DB=`ls -1 /root/.packages/Packages-${DISTRO_BINARY_COMPAT}-${DISTRO_COMPAT_VERSION}* | head -n 1 | rev | cut -f 1 -d '/' | rev | cut -f 2-4 -d '-'`
fltrVERSION="$FIRST_DB" #ex: slackware-12.2-official
#or, a selection was made in the main gui (pkg_chooser.sh)...
[ -f /tmp/petget_filterversion ] && fltrVERSION=`cat /tmp/petget_filterversion`

REPO_FILE=`find /root/.packages -type f -name Packages-${fltrVERSION}* | head -n 1`

#choose a category in the repo...
#$1 exs: Document, Internet, Graphic, Setup, Desktop
fltrCATEGORY="Desktop" #show Desktop category pkgs.
if [ $1 ];then
 fltrCATEGORY="$1"
 echo "$1" > /tmp/petget_filtercategory
else
 #or, a selection was made in the main gui (pkg_chooser.sh)...
 [ -f /tmp/petget_filtercategory ] && fltrCATEGORY=`cat /tmp/petget_filtercategory`
fi
categoryPATTERN="|${fltrCATEGORY}|"
[ "$fltrCATEGORY" = "ALL" ] && categoryPATTERN="|" #let everything through.

#find pkgs in db starting with $PKG_FIRST_CHAR and by distro and category...
#each line: pkgname|nameonly|version|pkgrelease|category|size|path|fullfilename|dependencies|description|
#optionally on the end: compileddistro|compiledrelease|repo| (fields 11,12,13)
#filter the repo pkgs by first char and category, also extract certain fields...
#w017 filter out all 'lib' pkgs, too many for gtkdialog (ubuntu/debian only)...
#w460 filter out all 'language-' pkgs, too many (ubuntu/debian)...
if [ ! -f /tmp/petget_fltrd_repo_${PKG_FIRST_CHAR}_${fltrCATEGORY}_Packages-${fltrVERSION} ];then
 if [ "$DISTRO_BINARY_COMPAT" = "ubuntu" -o "$DISTRO_BINARY_COMPAT" = "debian" ];then
  FLTRD_REPO=`printcols $REPO_FILE 1 2 3 5 10 6 9 | grep -v -E '^lib|^language\\-' | grep -i "^[${PKG_FIRST_CHAR}]" | grep "$categoryPATTERN" | sed -e 's%||$%|unknown|%'`
 else
  FLTRD_REPO=`printcols $REPO_FILE 1 2 3 5 10 6 9 | grep -i "^[${PKG_FIRST_CHAR}]" | grep "$categoryPATTERN" | sed -e 's%||$%|unknown|%'`
 fi
 echo "$FLTRD_REPO" > /tmp/petget_fltrd_repo_${PKG_FIRST_CHAR}_${fltrCATEGORY}_Packages-${fltrVERSION}
 #...file ex: /tmp/petget_fltrd_repo_a_Document_Packages-slackware-12.2-official
fi

#w480 extract names of packages that are already installed...
shortPATTERN=`cut -f 2 -d '|' /tmp/petget_fltrd_repo_${PKG_FIRST_CHAR}_${fltrCATEGORY}_Packages-${fltrVERSION} | sed -e 's%^%|%' -e 's%$%|%'`
echo "$shortPATTERN" > /tmp/petget_shortlist_patterns
INSTALLED_CHAR_CAT=`cat /root/.packages/woof-installed-packages /root/.packages/user-installed-packages | grep --file=/tmp/petget_shortlist_patterns`
#make up a list of filter patterns, so will be able to filter pkg db...
INSTALLED_PATTERNS=`echo "$INSTALLED_CHAR_CAT" | cut -f 2 -d '|' | sed -e 's%^%|%' -e 's%$%|%'`
echo "$INSTALLED_PATTERNS" > /tmp/petget_installed_patterns

#packages may have different names, add them to installed list (refer pkg_chooser.sh)...
INSTALLEDALIASES=`grep --file=/tmp/petget_installed_patterns /tmp/petget_pkg_name_aliases_patterns | tr ',' '\n'`
[ "$INSTALLEDALIASES" ] && echo "$INSTALLEDALIASES" >> /tmp/petget_installed_patterns

#w480 pkg_chooser has created this, pkg names that need to be ignored (for whatever reason)...
cat /tmp/petget_pkg_name_ignore_patterns >> /tmp/petget_installed_patterns

#clean it up...
grep -v '^$' /tmp/petget_installed_patterns > /tmp/petget_installed_patterns-tmp
mv -f /tmp/petget_installed_patterns-tmp /tmp/petget_installed_patterns

#filter out installed pkgs from the repo pkg list...
#ALIASES_PATTERNS=`echo -n "$PKG_ALIASES_INSTALLED" | tr -s ' ' | sed -e 's%^ %%' -e 's% $%%' | tr ' ' '\n' | sed -e 's%^%|%' -e 's%$%|%'`
#echo "$ALIASES_PATTERNS" >> /tmp/petget_installed_patterns
grep --file=/tmp/petget_installed_patterns -v /tmp/petget_fltrd_repo_${PKG_FIRST_CHAR}_${fltrCATEGORY}_Packages-${fltrVERSION} | cut -f 1,5 -d '|' > /tmp/filterpkgs.results
#...'pkgname|description' has been written to /tmp/filterpkgs.results for main gui.

[ $X1PID -ne 0 ] && kill $X1PID

###END###

