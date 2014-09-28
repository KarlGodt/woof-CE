#!/bin/sh
#
# New header by Karl Reimer Godt, September 2014
  _TITLE_="Puppy_removepreview.sh"
_VERSION_=1.0omega
_COMMENT_="$_TITLE_:Puppy Linux shell script [to TODO here]"

MY_SELF="/usr/local/petget/removepreview.sh"
MY_PID=$$

test -f /etc/rc.d/f4puppy5 && {
[ "$HAVE_F4PUPPY5" ] || source /etc/rc.d/f4puppy5

ADD_PARAMETER_LIST=""
ADD_PARAMETERS=""
_provide_basic_parameters

TWO_HELP=''; TWO_VERSION=''; TWO_VERBOSE=''; TWO_DEBUG=''; ## Set to anything if code requires further down (ie. custom usage or version message)
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
#called from pkg_chooser.sh and petget.
#package to be removed is TREE2, ex TREE2=abiword-1.2.3 (corrresponds to 'pkgname' field in db).
#installed pkgs are recorded in /root/.packages/user-installed-packages, each
#line a standardised database entry:
#pkgname|nameonly|version|pkgrelease|category|size|path|fullfilename|dependencies|description|
#optionally on the end: compileddistro|compiledrelease|repo| (fields 11,12,13)
#If X not running, no GUI windows displayed, removes without question.
#v424 support post-uninstall script for .pet pkgs.
#v424 need info box if user has clicked when no pkgs installed.



. /etc/DISTRO_SPECS #has DISTRO_BINARY_COMPAT, DISTRO_COMPAT_VERSION
. /root/.packages/DISTRO_PKGS_SPECS

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

SUF="${DB_pkgname}~"

if [ -f /root/.packages/${DB_pkgname}.files ];then
 cat /root/.packages/${DB_pkgname}.files |
 while read ONESPEC
 do
  echo "$ONESPEC" >&2
  if [ ! -d "$ONESPEC" ];then
   if [ -e "/initrd/pup_ro2$ONESPEC" ];then
    #the problem is, deleting the file on the top layer places a ".wh" whiteout file,
    #that hides the original file. what we want is to remove the installed file, and
    #restore the original pristine file...
    echo "Restoring /initrd/pup_ro2$ONESPEC" >&2
    cp -a --remove-destination "/initrd/pup_ro2$ONESPEC" "$ONESPEC"
    if [ -e "${ONESPEC}.$SUF" ];then
    echo "Restoring ${ONESPEC}.$SUF as $ONESPEC" >&2
    mv "${ONESPEC}.$SUF" "$ONESPEC"
    fi
   else
    echo "Removing $ONESPEC" >&2
    rm -f "$ONESPEC"
    if [ -e "${ONESPEC}.$SUF" ];then
    echo "Restoring ${ONESPEC}.$SUF as $ONESPEC" >&2
    mv "${ONESPEC}.$SUF" "$ONESPEC"
    fi
   fi
  fi
 done
 #do it again, looking for empty directories...
 cat /root/.packages/${DB_pkgname}.files |
 while read ONESPEC
 do
  if [ -d "$ONESPEC" ];then
   [ "`ls -1 $ONESPEC`" = "" ] && rmdir $ONESPEC 2>$ERR
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
grep -v "$remPATTERN" /root/.packages/user-installed-packages > /tmp/petget-user-installed-pkgs-rem
cp -f /tmp/petget-user-installed-pkgs-rem /root/.packages/user-installed-packages

#v424 .pet pckage may have post-uninstall script, which was originally named puninstall.sh
#but /usr/local/petget/installpkg.sh moved it to /root/.packages/$DB_pkgname.remove
if [ -f /root/.packages/${DB_pkgname}.remove ];then
 /bin/sh /root/.packages/${DB_pkgname}.remove
 rm -f /root/.packages/${DB_pkgname}.remove
fi

#remove temp file so main gui window will re-filter pkgs display...
FIRSTCHAR=`echo -n "$DB_pkgname" | cut -c 1 | tr '[A-Z]' '[a-z]'`
rm -f /tmp/petget_fltrd_repo_${FIRSTCHAR}* 2>$ERR
rm -f /tmp/petget_fltrd_repo_?${FIRSTCHAR}* 2>$ERR
[ "`echo -n "$FIRSTCHAR" | grep '[0-9]'`" != "" ] && rm -f /tmp/petget_fltrd_repo_0* 2>$ERR

#announce any deps that might be removable...
echo -n "" > /tmp/petget-deps-maybe-rem
cut -f 1,2,10 -d '|' /root/.packages/user-installed-packages |
while read ONEDB
do
 ONE_pkgname=`echo -n "$ONEDB" | cut -f 1 -d '|'`
 ONE_nameonly=`echo -n "$ONEDB" | cut -f 2 -d '|'`
 ONE_description=`echo -n "$ONEDB" | cut -f 3 -d '|'`
 opPATTERN='^'"$ONE_nameonly"'$'
 [ "`echo "$DEP_PKGS" | grep "$opPATTERN"`" != "" ] && echo "$ONE_pkgname DESCRIPTION: $ONE_description" >> /tmp/petget-deps-maybe-rem
done
EXTRAMSG=""
if [ -s /tmp/petget-deps-maybe-rem ];then
 #MAYBEREM=`cat /tmp/petget-deps-maybe-rem` # wrap=\"false\"
 #nah, just list the names, not descriptions...
 MAYBEREM=`cat /tmp/petget-deps-maybe-rem | cut -f 1 -d ' ' | tr '\n' ' '`
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

###END###
