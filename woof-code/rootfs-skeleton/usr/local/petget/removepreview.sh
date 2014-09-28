#!/bin/sh
#
# New header by Karl Reimer Godt, September 2014

  _TITLE_="Puppy_removepreview.sh"
_VERSION_=1.0omega
_COMMENT_="$_TITLE_:Puppy Linux shell script [to TODO here]"

MY_SELF="/usr/local/petget/removepreview.sh"
MY_PID=$$

test -f /etc/rc.d/f4puppy5 && {
source /etc/rc.d/f4puppy5

ADD_PARAMETER_LIST=""
ADD_PARAMETERS=""
_provide_basic_parameters

ADD_HELP_MSG="$_COMMENT_"
_parse_basic_parameters "$@"
[ "$DO_SHIFT" ] && [ ! "${DO_SHIFT//[[:digit:]]/}" ] && {
  for oneSHIFT in `seq 1 1 $DO_SHIFT`; do shift; done; }

_trap
}
# End new header
#
#(c) Copyright Barry Kauler 2009, puppylinux.com
#2009 Lesser GPL licence v2 (http://www.fsf.org/licensing/licenses/lgpl.html).
# Called from pkg_chooser.sh and petget.
# Package to be removed is TREE2, ex TREE2=abiword-1.2.3 (corrresponds to 'pkgname' field in db).
# Installed pkgs are recorded in /root/.packages/user-installed-packages, each
# Line a standardised database entry:
# pkgname|nameonly|version|pkgrelease|category|size|path|fullfilename|dependencies|description|
# Optionally on the end: compileddistro|compiledrelease|repo| (fields 11,12,13)
# If X not running, no GUI windows displayed, removes without question.
#v424 support post-uninstall script for .pet pkgs.
#v424 need info box if user has clicked when no pkgs installed.

__old_default_info_header__(){
  _TITLE_=uninstall_preview
_COMMENT_="Confirm uninstallation of a software package."

MY_SELF="$0"

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
}

echo "$0: START" >&2

. /etc/DISTRO_SPECS #has DISTRO_BINARY_COMPAT, DISTRO_COMPAT_VERSION
. /root/.packages/DISTRO_PKGS_SPECS

tmpDIR=/tmp/petget
test -d "$tmpDIR" || mkdir -p "$tmpDIR"

DB_pkgname="$TREE2"

#v424 info box, nothing yet installed...
if [ "$DB_pkgname" = "" ];then
 export REM_DIALOG="<window title=\"Puppy Package Manager\" icon-name=\"gtk-about\">
  <vbox>
   <pixmap><input file>/usr/local/lib/X11/pixmaps/error.xpm</input></pixmap>
   <text><label>There are no user-installed packages yet, so nothing to uninstall!</label></text>
   <hbox>
    <button ok></button>
   </hbox>
  </vbox>
 </window>
"

 [ "$DISPLAY" != "" ] && gtkdialog3 --program=REM_DIALOG
 exit
fi

export REM_DIALOG="<window title=\"Puppy Package Manager\" icon-name=\"gtk-about\">
  <vbox>
   <pixmap><input file>/usr/local/lib/X11/pixmaps/question.xpm</input></pixmap>
   <text><label>Click 'OK' button to confirm that you wish to uninstall package '$DB_pkgname'</label></text>
   <hbox>
    <button ok></button>
    <button cancel></button>
   </hbox>
  </vbox>
 </window>
"

if [ "$DISPLAY" != "" ];then
 RETPARAMS=`gtkdialog3 --program=REM_DIALOG`
 eval "$RETPARAMS"
 [ "$EXIT" != "OK" ] && exit
fi

if [ -f /root/.packages/${DB_pkgname}.files ];then

 cat /root/.packages/${DB_pkgname}.files |
 while read ONESPEC
 do
  if [ ! -d "$ONESPEC" ];then

   if [ -e "/initrd/pup_ro2$ONESPEC" ];then
    #the problem is, deleting the file on the top layer places a ".wh" whiteout file,
    #that hides the original file. what we want is to remove the installed file, and
    #restore the original pristine file...
    cp -a --remove-destination "/initrd/pup_ro2$ONESPEC" "$ONESPEC"
   else
    rm -f "$ONESPEC"
   fi

  fi
 done

 #do it again, looking for empty directories...
 cat /root/.packages/${DB_pkgname}.files |
 while read ONESPEC
 do
  if [ -d "$ONESPEC" ];then
   [ "`ls -1 $ONESPEC`" = "" ] && rmdir $ONESPEC 2>$OUT
  fi
 done
fi

#fix menu...
#master help index has to be updated...
##to speed things up, find the help files in the new pkg only...
/usr/sbin/indexgen.sh #${WKGDIR}/${APKGNAME}

#Reconstruct configuration files for JWM, Fvwm95, IceWM...
/usr/sbin/fixmenus

#what about any user-installed deps...
remPATTERN='^'"$DB_pkgname"'|'
DEP_PKGS=`grep -v "$remPATTERN" /root/.packages/user-installed-packages | cut -f 9 -d '|' | tr ',' '\n' | grep -v '^\\-' | sed -e 's%^+%%'`

#remove records of pkg...
rm -f /root/.packages/${DB_pkgname}.files
grep -v "$remPATTERN" /root/.packages/user-installed-packages > "$tmpDIR"/petget-user-installed-pkgs-rem
cp -f "$tmpDIR"/petget-user-installed-pkgs-rem /root/.packages/user-installed-packages

#v424 .pet pckage may have post-uninstall script, which was originally named puninstall.sh
#but /usr/local/petget/installpkg.sh moved it to /root/.packages/$DB_pkgname.remove
if [ -f /root/.packages/${DB_pkgname}.remove ];then
 /bin/sh /root/.packages/${DB_pkgname}.remove
 rm -f /root/.packages/${DB_pkgname}.remove
fi

#remove temp file so main gui window will re-filter pkgs display...
FIRSTCHAR=`echo -n "$DB_pkgname" | cut -c 1 | tr '[A-Z]' '[a-z]'`
rm -f "$tmpDIR"/petget_fltrd_repo_${FIRSTCHAR}* 2>$OUT
rm -f "$tmpDIR"/petget_fltrd_repo_?${FIRSTCHAR}* 2>$OUT
[ "`echo -n "$FIRSTCHAR" | grep '[0-9]'`" != "" ] && rm -f "$tmpDIR"/petget_fltrd_repo_0* 2>$OUT

#announce any deps that might be removable...
echo -n "" > "$tmpDIR"/petget-deps-maybe-rem

cut -f 1,2,10 -d '|' /root/.packages/user-installed-packages |
while read ONEDB
do

 ONE_pkgname=`echo -n "$ONEDB" | cut -f 1 -d '|'`
 ONE_nameonly=`echo -n "$ONEDB" | cut -f 2 -d '|'`
 ONE_description=`echo -n "$ONEDB" | cut -f 3 -d '|'`
 opPATTERN='^'"$ONE_nameonly"'$'
 [ "`echo "$DEP_PKGS" | grep "$opPATTERN"`" != "" ] && echo "$ONE_pkgname DESCRIPTION: $ONE_description" >> "$tmpDIR"/petget-deps-maybe-rem

done

EXTRAMSG=""

if [ -s "$tmpDIR"/petget-deps-maybe-rem ];then
 #MAYBEREM=`cat "$tmpDIR"/petget-deps-maybe-rem` # wrap=\"false\"
 #nah, just list the names, not descriptions...
 MAYBEREM=`cat "$tmpDIR"/petget-deps-maybe-rem | cut -f 1 -d ' ' | tr '\n' ' '`
 EXTRAMSG="<text><label>Perhaps you don't need these dependencies that you had also installed:</label></text> <text use-markup=\"true\"><label>\"<b>${MAYBEREM}</b>\"</label></text><text><label>...if you do want to remove them, you will have to do so back on the main window, after clicking the 'Ok' button below (perhaps make a note of the package names on a scrap of paper right now)</label></text>"
fi

#announce success...
export REM_DIALOG="<window title=\"Puppy Package Manager\" icon-name=\"gtk-about\">
  <vbox>
  <pixmap><input file>/usr/local/lib/X11/pixmaps/ok.xpm</input></pixmap>
   <text><label>Package '$DB_pkgname' has been removed.</label></text>
   ${EXTRAMSG}
   <hbox>
    <button ok></button>
   </hbox>
  </vbox>
 </window>
"

if [ "$DISPLAY" != "" ];then
 gtkdialog3 --program=REM_DIALOG
fi

echo "$0: END" >&2

###END###
