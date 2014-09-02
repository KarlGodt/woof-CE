#!/bin/sh
#(c) Copyright Barry Kauler 2009, puppylinux.com
#2009 Lesser GPL licence v2 (http://www.fsf.org/licensing/licenses/lgpl.html).
# Called from /usr/local/petget/installpreview.sh
# The database entries for the packages to be installed are in "$tmpDIR"/petget_missing_dbentries-*
# ex: "$tmpDIR"/petget_missing_dbentries-Packages-slackware-12.2-official
#v424 fix msg, x does not need restart to update menu.

_TITLE_=package_download
_COMMENT_="GTKdialog GUIs to download by PPM."

MY_SELF="$0"

#************
#KRG

OUT=/dev/null;ERR=$OUT
[ "$DEBUG" ] && { OUT=/dev/stdout;ERR=/dev/stderr; }
[ "$DEBUG" = 2 ] && set -x

Version=1.1-KRG-MacPup_O2

usage(){
MSG="
$0 [ help | version | PASSEDPARAM ]
PASSEDPARAM : DOWNLOADONLY
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


echo "$0: START" >&2

export LANG=C
PASSEDPARAM=""
[ $1 ] && PASSEDPARAM="$1" #DOWNLOADONLY

. /etc/DISTRO_SPECS                   #has DISTRO_BINARY_COMPAT, DISTRO_COMPAT_VERSION
. /root/.packages/DISTRO_PKGS_SPECS   #
. /root/.packages/DISTRO_PET_REPOS    #has PET_REPOS, PACKAGELISTS_PET_ORDER
. /root/.packages/DISTRO_COMPAT_REPOS #v431 has REPOS_DISTRO_COMPAT

tmpDIR=/tmp/petget
test -d "$tmpDIR" || mkdir -p "$tmpDIR"

echo -n "" > "$tmpDIR"/petget-installed-pkgs.log

for oneLIST in `ls -1 "$tmpDIR"/petget_missing_dbentries-Packages-*`
do
 echo -n "" > "$tmpDIR"/petget_repos
 LISTNAME=`echo -n "$oneLIST" | grep -o 'Packages.*'`

 #have the compat-distro repo urls in /root/.packages/DISTRO_PKGS_SPECS,
 #variable REPOS_DISTRO_COMPAT ...
 #REPOS_DISTRO_COMPAT has the associated Packages-* local database file...
 for oneURLENTRY in $REPOS_DISTRO_COMPAT
 do
  PARTPKGDB=`echo -n "$oneURLENTRY" | cut -f 3 -d '|'`
  #PARTPKGDB may have a glob * wildcard, convert to reg.expr., also backslash '-'...
  PARTPKGDB=`echo -n "$PARTPKGDB" | sed -e 's%\\-%\\\\-%g' -e 's%\\*%.*%g'`
  oneURLENTRY_1_2=`echo -n "$oneURLENTRY" | cut -f 1,2 -d '|'`
  [ "`echo "$LISTNAME" | grep "$PARTPKGDB"`" != "" ] && echo "${oneURLENTRY_1_2}|${LISTNAME}" >> "$tmpDIR"/petget_repos
 done

echo $LINENO >&2

 #or it may be one of the official puppy repos...
 if [ "`echo "$oneLIST" | grep 'Packages\\-puppy' | grep '\\-official'`" != "" ];then
  for onePETREPO in $PET_REPOS
  do
   onePETREPO_3_PATTERN=`echo -n "$onePETREPO" | cut -f 3 -d '|' | sed -e 's%\\-%\\\\-%g' -e 's%\\*%.*%g'`
   onePETREPO_1_2=`echo -n "$onePETREPO" | cut -f 1,2 -d '|'`
   [ "`echo -n "$LISTNAME" | grep "$onePETREPO_3_PATTERN"`" != "" ] && echo "${onePETREPO_1_2}|${LISTNAME}" >> "$tmpDIR"/petget_repos
   #...ex: ibiblio.org|http://distro.ibiblio.org/pub/linux/distributions/puppylinux|Packages-puppy-4-official
  done
 fi

 sort --key=1 --field-separator="|" --unique "$tmpDIR"/petget_repos > "$tmpDIR"/petget_repos-tmp
 mv -f "$tmpDIR"/petget_repos-tmp "$tmpDIR"/petget_repos

 #"$tmpDIR"/petget_repos has a list of repos for downloading these packages.
 #now put up a window, request which url to use...

 LISTNAMECUT=`echo -n "$LISTNAME" | cut -f 2-9 -d '-'` #take Packages- off.

 REPOBUTTONS=""
 for oneREPOSPEC in `cat "$tmpDIR"/petget_repos`
 do
  URL_TEST=`echo -n "$oneREPOSPEC" | cut -f 1 -d '|'`
  URL_FULL=`echo -n "$oneREPOSPEC" | cut -f 2 -d '|'`
  REPOBUTTONS="${REPOBUTTONS}<radiobutton><label>${URL_TEST}</label><variable>RADIO_URL_${URL_TEST}</variable></radiobutton>"
 done

echo $LINENO >&2

 PKGNAMES=`cat $oneLIST | cut -f 1 -d '|' | tr '\n' ' '`

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

echo $LINENO >&2

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
  DOWNLOADFROM=`cat "$tmpDIR"/petget_repos | grep "$URL_BASIC" | head -n 1 | cut -f 2 -d '|'`
 fi

echo $LINENO >&2

 #now download and install them...
 cd /root
 for oneFILE in `cat $oneLIST | cut -f 7,8 -d '|' | tr '|' '/'`
 do
  #if [ "$RADIO_URL_LOCAL" = "true" ];then
  if [ "`echo "$RETPARAMS" | grep 'RADIO_URL_LOCAL' | grep 'true'`" != "" ];then
   [ ! -f ${LOCALDIR}/${oneFILE} ] && oneFILE=`basename $oneFILE`
   cp -f ${LOCALDIR}/${oneFILE} ./
  else
   rxvt -title "Puppy Package Manager: download" -bg orange -fg black -geometry 80x10 -e wget ${DOWNLOADFROM}/${oneFILE}
  fi
  sync
  DLPKG=`basename $oneFILE`
  if [ -f $DLPKG -a "$DLPKG" != "" ];then
   if [ "$PASSEDPARAM" = "DOWNLOADONLY" ];then
    /usr/local/petget/verifypkg.sh /root/$DLPKG
   else
    /usr/local/petget/installpkg.sh /root/$DLPKG
    #...appends pkgname and category to "$tmpDIR"/petget-installed-pkgs-log if successful.
   fi
   if [ $? -ne 0 ];then
    #xmessage -bg red -title "Puppy Package Manager" "ERROR: faulty download of $DLPKG"
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
   #already removed, but take precautions...
   #[ "$PASSEDPARAM" != "DOWNLOADONLY" ] && rm -f /root/$DLPKG 2>$ERR
   #DLPKG_NAME=`basename $DLPKG .pet` 2>$ERR
   #DLPKG_NAME=`basename $DLPKG .deb` 2>$ERR
   #DLPKG_NAME=`basename $DLPKG .tgz` 2>$ERR
   #DLPKG_NAME=`basename $DLPKG .tar.gz` 2>$ERR
   #rm -rf /root/$DLPKG_NAME
  else
   #xmessage -bg red -title "Puppy Package Manager" "ERROR: Failed to download ${DLPKG}"
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
   gtkdialog3 --program=FAIL_DIALOG
  fi
 done

done

echo $LINENO >&2

if [ "$PASSEDPARAM" = "DOWNLOADONLY" ];then
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
fi

echo $LINENO >&2

#announce summary of successfully installed pkgs...
#installpkg.sh will have logged to "$tmpDIR"/petget-installed-pkgs-log
if [ -s "$tmpDIR"/petget-installed-pkgs.log ];then
 INSTALLEDMSG=`cat "$tmpDIR"/petget-installed-pkgs.log`
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

echo $LINENO >&2

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
   while read oneFILE
   do
    [ ! -f "$oneFILE" ] && continue
    [ -h "$oneFILE" ] && continue
    #find out if this is an international language file...
    if [ "$ENTRY_LOCALE" != "" ];then
     if [ "`echo -n "$oneFILE" | grep --extended-regexp '/locale/|/nls/|/i18n/' | grep -v -E "$elPATTERN"`" != "" ];then
      rm -f "$oneFILE"
      grep -v "$oneFILE" /root/.packages/${PKGNAME}.files > "$tmpDIR"/petget_pkgfiles_temp
      mv -f "$tmpDIR"/petget_pkgfiles_temp /root/.packages/${PKGNAME}.files
      continue
     fi
    fi
    #find out if this is a documentation file...
    if [ "$CHECK_DOCDEL" = "true" ];then
     if [ "`echo -n "$oneFILE" | grep --extended-regexp '/man/|/doc/|/doc-base/|/docs/|/info/|/gtk-doc/|/faq/|/manual/|/examples/|/help/|/htdocs/'`" != "" ];then
      rm -f "$oneFILE" 2>$ERR
      grep -v "$oneFILE" /root/.packages/${PKGNAME}.files > "$tmpDIR"/petget_pkgfiles_temp
      mv -f "$tmpDIR"/petget_pkgfiles_temp /root/.packages/${PKGNAME}.files
      continue
     fi
    fi
    #find out if this is development file...
    if [ "$CHECK_DEVDEL" = "true" ];then
     if [ "`echo -n "$oneFILE" | grep --extended-regexp '/include/|/pkgconfig/|/aclocal|/cvs/|/svn/'`" != "" ];then
      rm -f "$oneFILE" 2>$ERR
      grep -v "$oneFILE" /root/.packages/${PKGNAME}.files > "$tmpDIR"/petget_pkgfiles_temp
      mv -f "$tmpDIR"/petget_pkgfiles_temp /root/.packages/${PKGNAME}.files
      continue
     fi
     #all .a and .la files... and any stray .m4 files...
     if [ "`echo -n "$oneBASE" | grep --extended-regexp '\.a$|\.la$|\.m4$'`" != "" ];then
      rm -f "$oneFILE"
      grep -v "$oneFILE" /root/.packages/${PKGNAME}.files > "$tmpDIR"/petget_pkgfiles_temp
      mv -f "$tmpDIR"/petget_pkgfiles_temp /root/.packages/${PKGNAME}.files
     fi
    fi
   done
  done
  kill $X4PID
 fi

fi

echo "$0: END" >&2

###END###
