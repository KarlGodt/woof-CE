#!/bin/sh
#(c) Copyright Barry Kauler 2009, puppylinux.com
#2009 Lesser GPL licence v2 (http://www.fsf.org/licensing/licenses/lgpl.html).
#called from /usr/local/petget/installpreview.sh
#The database entries for the packages to be installed are in /tmp/petget_missing_dbentries-*
#ex: /tmp/petget_missing_dbentries-Packages-slackware-12.2-official
#v424 fix msg, x does not need restart to update menu.


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

out=/dev/null;err=/dev/stderr
case $2 in
debug) set -x;;
verbose) DEBUG=1;VERB=-v;L_VERB=--verbose;A_VERB=-verbose;out=/dev/stdout;err=/dev/stderr;;
esac

export LANG=C
PASSEDPARAM=""
[ $1 ] && PASSEDPARAM="$1" #DOWNLOADONLY

. /etc/DISTRO_SPECS #has DISTRO_BINARY_COMPAT, DISTRO_COMPAT_VERSION
. /root/.packages/DISTRO_PKGS_SPECS #
. /root/.packages/DISTRO_PET_REPOS #has PET_REPOS, PACKAGELISTS_PET_ORDER
. /root/.packages/DISTRO_COMPAT_REPOS #v431 has REPOS_DISTRO_COMPAT

echo -n "" > /tmp/petget-installed-pkgs-log

for ONELIST in `ls -1 /tmp/petget_missing_dbentries-Packages-*`
do  ##ONELIST
 echo -n "" > /tmp/petget_repos
 LISTNAME=`echo -n "$ONELIST" | grep -o 'Packages.*'`

 #have the compat-distro repo urls in /root/.packages/DISTRO_PKGS_SPECS,
 #variable REPOS_DISTRO_COMPAT ...
 #REPOS_DISTRO_COMPAT has the associated Packages-* local database file...
 for ONEURLENTRY in $REPOS_DISTRO_COMPAT
 do ##ONEURLENTRY
  PARTPKGDB=`echo -n "$ONEURLENTRY" | cut -f 3 -d '|'`
  #PARTPKGDB may have a glob * wildcard, convert to reg.expr., also backslash '-'...
  PARTPKGDB=`echo -n "$PARTPKGDB" | sed -e 's%\\-%\\\\-%g' -e 's%\\*%.*%g'`
  ONEURLENTRY_1_2=`echo -n "$ONEURLENTRY" | cut -f 1,2 -d '|'`
  [ "`echo "$LISTNAME" | grep "$PARTPKGDB"`" != "" ] && echo "${ONEURLENTRY_1_2}|${LISTNAME}" >> /tmp/petget_repos
 done ##ONEURLENTRY

 #or it may be one of the official puppy repos...
 if [ "`echo "$ONELIST" | grep 'Packages\\-puppy' | grep '\\-official'`" != "" ];then
  for ONEPETREPO in $PET_REPOS
  do ##ONEPETREPO
   ONEPETREPO_3_PATTERN=`echo -n "$ONEPETREPO" | cut -f 3 -d '|' | sed -e 's%\\-%\\\\-%g' -e 's%\\*%.*%g'`
   ONEPETREPO_1_2=`echo -n "$ONEPETREPO" | cut -f 1,2 -d '|'`
   [ "`echo -n "$LISTNAME" | grep "$ONEPETREPO_3_PATTERN"`" != "" ] && echo "${ONEPETREPO_1_2}|${LISTNAME}" >> /tmp/petget_repos
   #...ex: ibiblio.org|http://distro.ibiblio.org/pub/linux/distributions/puppylinux|Packages-puppy-4-official
  done ##ONEPETREPO
 fi

 sort --key=1 --field-separator="|" --unique /tmp/petget_repos > /tmp/petget_repos-tmp
 mv -f /tmp/petget_repos-tmp /tmp/petget_repos

 #/tmp/petget_repos has a list of repos for downloading these packages.
 #now put up a window, request which url to use...

 LISTNAMECUT=`echo -n "$LISTNAME" | cut -f 2-9 -d '-'` #take Packages- off.

 REPOBUTTONS=""
 for ONEREPOSPEC in `cat /tmp/petget_repos`
 do  ##ONEREPOSPEC
  URL_TEST=`echo -n "$ONEREPOSPEC" | cut -f 1 -d '|'`
  URL_FULL=`echo -n "$ONEREPOSPEC" | cut -f 2 -d '|'`
  REPOBUTTONS="${REPOBUTTONS}<radiobutton><label>${URL_TEST}</label><variable>RADIO_URL_${URL_TEST}</variable></radiobutton>"
 done  ##ONEREPOSPEC

 PKGNAMES=`cat $ONELIST | cut -f 1 -d '|' | tr '\n' ' '`

 export DEPS_DIALOG="<window title=\"Puppy Package Manager: download\" icon-name=\"gtk-about\">
<vbox>
 <text><label>You have chosen to download these packages:</label></text>
 <text use-markup=\"true\"><label>\"<b>${PKGNAMES}</b>\"</label></text>
 <text><label>Please choose which URL you would like to download them from. Choose 'LOCAL FOLDER' if you have already have them on this computer (on hard drive, USB drive or CD):</label></text>

 <frame ${LISTNAMECUT}>
  ${REPOBUTTONS}
  <radiobutton><label>LOCAL FOLDER</label><variable>RADIO_URL_LOCAL</variable></radiobutton>
 </frame>

 <hbox>
  <button>
   <label>Test URLs</label>
   <action>/usr/local/petget/testurls.sh</action>
  </button>
  <button>
   <label>Download packages</label>
   <action type=\"exit\">BUTTON_PKGS_DOWNLOAD</action>
  </button>
  <button cancel></button>
 </hbox>
</vbox>
</window>
"

 RETPARAMS=`gtkdialog3 --program=DEPS_DIALOG`
 #RETPARAMS ex:
 #RADIO_URL_LOCAL="false"
 #RADIO_URL_repository.slacky.eu="true"
 #EXIT="BUTTON_PKGS_DOWNLOAD"

 #eval "$RETPARAMS"

 #[ "$EXIT" != "BUTTON_PKGS_DOWNLOAD" ] && exit 1
 [ "`echo "$RETPARAMS" | grep 'BUTTON_PKGS_DOWNLOAD'`" = "" ] && exit 1

 #determine the url to download from....
 #if [ "$RADIO_URL_LOCAL" = "true" ];then
 if [ "`echo "$RETPARAMS" | grep 'RADIO_URL_LOCAL' | grep 'true'`" != "" ];then
  #put up a dlg box asking for folder with pkgs...
  LOCALDIR="/root"
  if [ -s /var/log/petlocaldir ];then
   OLDLOCALDIR=`cat /var/log/petlocaldir`
   [ -d $OLDLOCALDIR ] && LOCALDIR="$OLDLOCALDIR"
  fi
  LOCALDIR=`Xdialog --backtitle "Note: Files not displayed, only directories" --title "Choose local directory" --stdout --no-buttons --dselect "$LOCALDIR" 0 0`
  [ $? -ne 0 ] && exit 1
  [ "$LOCALDIR" != "" ] && echo "$LOCALDIR" > /var/log/petlocaldir
  DOWNLOADFROM="file://${LOCALDIR}"
 else
  URL_BASIC=`echo "$RETPARAMS" | grep 'RADIO_URL_' | grep '"true"' | cut -f 1 -d '=' | cut -f 3 -d '_'`
  DOWNLOADFROM=`cat /tmp/petget_repos | grep "$URL_BASIC" | head -n 1 | cut -f 2 -d '|'`
 fi

 #now download and install them...
 cd /root
 for ONEFILE in `cat $ONELIST | cut -f 7,8 -d '|' | tr '|' '/'`
 do  ##ONEFILE
  #if [ "$RADIO_URL_LOCAL" = "true" ];then
  if [ "`echo "$RETPARAMS" | grep 'RADIO_URL_LOCAL' | grep 'true'`" != "" ];then
   [ ! -f ${LOCALDIR}/${ONEFILE} ] && ONEFILE=`basename $ONEFILE`
   cp -f ${LOCALDIR}/${ONEFILE} ./
  else
   #rxvt -title "Puppy Package Manager: download" -bg orange -fg black -geometry 80x10 -e wget ${DOWNLOADFROM}/${ONEFILE}
   #xterm -hold -title "Puppy Package Manager: download" -bg orange -fg black -geometry 80x10 -e wget ${DOWNLOADFROM}/${ONEFILE}  #NOT with "" || ;WGET_ERROR=$?
   echo "DOWNLOADFROM='$DOWNLOADFROM' ONEFILE='$ONEFILE'" >$err
   DOWNLOADFROM="$DOWNLOADFROM" ONEFILE="$ONEFILE" xterm -title "Puppy Package Manager: download" -bg orange -fg black -geometry 80x10 -e /usr/local/petget/wget.sh
   XTERM_ERROR=$?
   source /tmp/wget_sh.err
  fi
  sync
  DLPKG=`basename $ONEFILE`
  if [ "$DLPKG" != "" -a -f $DLPKG ];then
   if [ "$PASSEDPARAM" = "DOWNLOADONLY" ];then
    /usr/local/petget/verifypkg.sh /root/$DLPKG
   if [ $? -ne 0 ];then
    xmessage -bg red -title "Puppy Package Manager" "ERROR: faulty download of $DLPKG"
    export FAIL_DIALOG="<window title=\"Puppy Package Manager\" icon-name=\"gtk-about\">
  <vbox>
  <pixmap><input file>/usr/local/lib/X11/pixmaps/error.xpm</input></pixmap>
   <text use-markup=\"true\"><label>\"<b>Error, faulty download of ${DLPKG}</b>\"</label></text>
   <hbox>
    <button ok></button>
   </hbox>
  </vbox>
 </window>"
    gtkdialog3 --program=FAIL_DIALOG
   fi
   else
    /usr/local/petget/installpkg.sh /root/$DLPKG
   if [ $? -ne 0 ];then
    xmessage -bg red -title "Puppy Package Manager" "ERROR: faulty download of $DLPKG"
    export FAIL_DIALOG="<window title=\"Puppy Package Manager\" icon-name=\"gtk-about\">
  <vbox>
  <pixmap><input file>/usr/local/lib/X11/pixmaps/error.xpm</input></pixmap>
   <text use-markup=\"true\"><label>\"<b>Error, faulty download of ${DLPKG}</b>\"</label></text>
   <hbox>
    <button ok></button>
   </hbox>
  </vbox>
 </window>"
    gtkdialog3 --program=FAIL_DIALOG
   fi
    #...appends pkgname and category to /tmp/petget-installed-pkgs-log if successful.
   fi

   #already removed, but take precautions...
   #[ "$PASSEDPARAM" != "DOWNLOADONLY" ] && rm -f /root/$DLPKG 2>$ERR
   #DLPKG_NAME=`basename $DLPKG .pet` 2>$ERR
   #DLPKG_NAME=`basename $DLPKG .deb` 2>$ERR
   #DLPKG_NAME=`basename $DLPKG .tgz` 2>$ERR
   #DLPKG_NAME=`basename $DLPKG .tar.gz` 2>$ERR
   #rm -rf /root/$DLPKG_NAME

  else
   DL_ERROR=1
   xmessage -bg red -title "Puppy Package Manager" "ERROR: Failed to download ${DLPKG}"
   export FAIL_DIALOG="<window title=\"Puppy Package Manager\" icon-name=\"gtk-about\">
  <vbox>
  <pixmap><input file>/usr/local/lib/X11/pixmaps/error.xpm</input></pixmap>
   <text use-markup=\"true\"><label>\"<b>Error, failed to download ${DLPKG}</b>\"</label></text>
   <hbox>
    <button ok></button>
   </hbox>
  </vbox>
 </window>
"
   #gtkdialog3 --program=FAIL_DIALOG
   #exit 1
  fi
 done  ##ONEFILE

done  ##ONELIST

echo "XTERM_ERROR='$XTERM_ERROR' DL_ERROR='$DL_ERROR' WGET_ERROR='$WGET_ERROR'" >/dev/stderr

if [ "$PASSEDPARAM" = "DOWNLOADONLY" ];then

for ONEFILE in `cat $ONELIST | cut -f 7,8 -d '|' | tr '|' '/'`;do
echo "ONEFILE='$ONEFILE'" >$err
BN_ONEFILE="${ONEFILE##*/}"
echo "BN_ONEFILE='$BN_ONEFILE'" >$err
file /root/"$BN_ONEFILE" >$err

if [ -f /root/"$BN_ONEFILE" ];then
:
else
FAIL=$((FAIL+1))
fi
done

if [ ! "$FAIL" ];then
 export DL_DIALOG="<window title=\"Puppy Package Manager\" icon-name=\"gtk-about\">
  <vbox>
  <pixmap><input file>/usr/local/lib/X11/pixmaps/ok.xpm</input></pixmap>
   <text><label>Finished. The packages have been downloaded to /root directory.</label></text>
   <hbox>
    <button ok></button>
   </hbox>
  </vbox>
 </window>
"
 gtkdialog3 --program=DL_DIALOG
 exit 0
 else  #FAIL
 export DL_DIALOG="<window title=\"Puppy Package Manager\" icon-name=\"gtk-about\">
  <vbox>
  <pixmap><input file>/usr/local/lib/X11/pixmaps/error.xpm</input></pixmap>
   <text><label>Finished. $FAIL of the packages failed to download to /root directory.</label></text>
   <hbox>
    <button ok></button>
   </hbox>
  </vbox>
 </window>
"
 gtkdialog3 --program=DL_DIALOG
 exit 1
 fi #FAIL
fi #DOWNLOADONLY

#announce summary of successfully installed pkgs...
#installpkg.sh will have logged to /tmp/petget-installed-pkgs-log
if [ -s /tmp/petget-installed-pkgs-log ];then
 INSTALLEDMSG=`cat /tmp/petget-installed-pkgs-log`
 CAT_MSG="Note: the package(s) do not have a menu entry."
 [ "`echo "$INSTALLEDMSG" | grep -o 'CATEGORY' | grep -v 'none'`" != "" ] && CAT_MSG="...look in the appropriate category in the menu (bottom-left of screen) to run the application. Note, some packages do not have a menu entry." #424 fix.
 export INSTALL_DIALOG="<window title=\"Puppy Package Manager\" icon-name=\"gtk-about\">
  <vbox>
  <pixmap><input file>/usr/local/lib/X11/pixmaps/ok.xpm</input></pixmap>
   <text><label>The following packages have been successfully installed:</label></text>
   <text wrap=\"false\" use-markup=\"true\"><label>\"<b>${INSTALLEDMSG}</b>\"</label></text>
   <text><label>${CAT_MSG}</label></text>
   <text><label>NOTE: If you are concerned about the large size of the installed packages, Puppy has some clever code to delete files that are not likely to be needed for the application to actually run. If you would like to try this, click 'Trim the fat' button (otherwise just click 'OK'):</label></text>
   <hbox>
  <button>
   <label>Trim the fat</label>
   <action type=\"exit\">BUTTON_TRIM_FAT</action>
  </button>
    <button ok></button>
   </hbox>
  </vbox>
 </window>
"
 RETPARAMS=`gtkdialog3 --program=INSTALL_DIALOG`
 eval "$RETPARAMS"

 #trim the fat...
 if [ "$EXIT" = "BUTTON_TRIM_FAT" ];then
  INSTALLEDPKGNAMES=`echo "$INSTALLEDMSG" | cut -f 2 -d ' ' | tr '\n' ' '`
  export TRIM_DIALOG="<window title=\"Puppy Package Manager\" icon-name=\"gtk-about\">
  <vbox>
   <pixmap><input file>/usr/local/lib/X11/pixmaps/question.xpm</input></pixmap>
   <text><label>You have chosen to 'trim the fat' of these installed packages:</label></text>
   <text use-markup=\"true\"><label>\"<b>${INSTALLEDPKGNAMES}</b>\"</label></text>
   <frame Locale>
   <text><label>Type the 2-letter country designations for the locales that you want to retain, separated by commas. Leave blank to retain all locale files (see /usr/share/locale for examples):</label></text>
   <entry><default>en</default><variable>ENTRY_LOCALE</variable></entry>
   </frame>
   <frame Documentation>
   <checkbox><default>true</default><label>Tick this to delete documentation files</label><variable>CHECK_DOCDEL</variable></checkbox>
   </frame>
   <frame development>
   <checkbox><default>true</default><label>Tick this to delete development files</label><variable>CHECK_DEVDEL</variable></checkbox>
   <text><label>(only needed if these packages are required as dependencies when compiling another package from source code)</label></text>
   </frame>
   <text><label>Click 'OK', or if you decide to chicken-out click 'Cancel':</label></text>
   <hbox>
    <button ok></button>
    <button cancel></button>
   </hbox>
  </vbox>
  </window>"
  RETPARAMS=`gtkdialog3 --program=TRIM_DIALOG`
  eval "$RETPARAMS"
  [ "$EXIT" != "OK" ] && exit
  yaf-splash -font "8x16" -outline 0 -margin 4 -bg orange -text "Please wait, trimming fat from packages..." &
  X4PID=$!
  elPATTERN=`echo -n "$ENTRY_LOCALE" | tr ',' '\n' | sed -e 's%^%/%' -e 's%$%/%' | tr '\n' '|'`
  for PKGNAME in $INSTALLEDPKGNAMES
  do
   cat /root/.packages/${PKGNAME}.files |
   while read ONEFILE
   do
    [ ! -f "$ONEFILE" ] && continue
    [ -h "$ONEFILE" ] && continue
    #find out if this is an international language file...
    if [ "$ENTRY_LOCALE" != "" ];then
     if [ "`echo -n "$ONEFILE" | grep --extended-regexp '/locale/|/nls/|/i18n/' | grep -v -E "$elPATTERN"`" != "" ];then
      rm -f "$ONEFILE"
      grep -v "$ONEFILE" /root/.packages/${PKGNAME}.files > /tmp/petget_pkgfiles_temp
      mv -f /tmp/petget_pkgfiles_temp /root/.packages/${PKGNAME}.files
      continue
     fi
    fi
    #find out if this is a documentation file...
    if [ "$CHECK_DOCDEL" = "true" ];then
     if [ "`echo -n "$ONEFILE" | grep --extended-regexp '/man/|/doc/|/doc-base/|/docs/|/info/|/gtk-doc/|/faq/|/manual/|/examples/|/help/|/htdocs/'`" != "" ];then
      rm -f "$ONEFILE" 2>$ERR
      grep -v "$ONEFILE" /root/.packages/${PKGNAME}.files > /tmp/petget_pkgfiles_temp
      mv -f /tmp/petget_pkgfiles_temp /root/.packages/${PKGNAME}.files
      continue
     fi
    fi
    #find out if this is development file...
    if [ "$CHECK_DEVDEL" = "true" ];then
     if [ "`echo -n "$ONEFILE" | grep --extended-regexp '/include/|/pkgconfig/|/aclocal|/cvs/|/svn/'`" != "" ];then
      rm -f "$ONEFILE" 2>$err
      grep -v "$ONEFILE" /root/.packages/${PKGNAME}.files > /tmp/petget_pkgfiles_temp
      mv -f /tmp/petget_pkgfiles_temp /root/.packages/${PKGNAME}.files
      continue
     fi
     #all .a and .la files... and any stray .m4 files...
     if [ "`echo -n "$ONEBASE" | grep --extended-regexp '\.a$|\.la$|\.m4$'`" != "" ];then
      rm -f "$ONEFILE"
      grep -v "$ONEFILE" /root/.packages/${PKGNAME}.files > /tmp/petget_pkgfiles_temp
      mv -f /tmp/petget_pkgfiles_temp /root/.packages/${PKGNAME}.files
     fi
    fi
   done
  done
  kill $X4PID
 fi

fi
exit $?
###END###
