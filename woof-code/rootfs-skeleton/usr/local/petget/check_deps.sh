#!/bin/sh
#choose an installed pkg and find all its dependencies.
#when entered with a passed param, it is a list of pkgs, '|' delimited,
#ex: abiword-1.2.3|aiksaurus-3.4.5|yabby-5.0

echo "$0: START" >&2

OUT=/dev/null;ERR=$OUT
[ "$DEBUG" ] && { OUT=/dev/stdout;ERR=/dev/stderr; }

Pro="/check_deps.sh"
Script_Dir="/usr/local/petget"
if test -f $Script_Dir/path ; then . $Script_Dir/path ; fi
DBG="echo $Script_Dir$Pro line :$LINENO"  ####krg---debugging value---<<<<

. /etc/DISTRO_SPECS #has DISTRO_BINARY_COMPAT, DISTRO_COMPAT_VERSION
. /root/.packages/DISTRO_PKGS_SPECS

files(){
/tmp/missinglibs.txt
/tmp/missingpkgs.txt
/root/.packages/user-installed-packages
/tmp/petget_missingpkgs_patterns
/tmp/petget_depchk_buttons
/tmp/sort.criteria
/usr/local/petget/check_deps.sh
}

echo -n "" > /tmp/missinglibs.txt
echo -n "" > /tmp/missingpkgs.txt

dependcheckfunc() {
 #entered with ex: APKGNAME=abiword-1.2.3

 yaf-splash -font "8x16" -outline 0 -margin 4 -bg orange -text "Checking ${APKGNAME} for missing shared library files..." &
 X1PID=$!

 #a hack if OO is installed...
 if [ "`echo -n "$APKGNAME" | grep 'openoffice'`" != "" ];then
  [ -d /opt ] && FNDOO="`find /opt -maxdepth 2 -type d -iname 'openoffice*'`"
  [ "$FNDOO" = "" ] && FNDOO="`find /usr -maxdepth 2 -type d -iname 'openoffice*'`"
  [ "$FNDOO" = "" ] && LD_LIBRARY_PATH="${FNDOO}/program:${LD_LIBRARY_PATH}"
 fi
cat /root/.packages/${APKGNAME}\.files
 FNDFILES=`cat /root/.packages/${APKGNAME}\.files`
 for ONEFILE in $FNDFILES
 do
  ISANEXEC="`file --brief $ONEFILE | grep --extended-regexp "LSB executable|shared object"`"
  if [ ! "$ISANEXEC" = "" ];then
   LDDRESULT="`ldd $ONEFILE`"
   MISSINGLIBS="`echo "$LDDRESULT" | grep "not found" | cut -f 2 | cut -f 1 -d " " | tr "\n" " "`"
   if [ ! "$MISSINGLIBS" = "" ];then
    echo "File $ONEFILE has these missing library files:" >> /tmp/missinglibs.txt
    echo " $MISSINGLIBS" >> /tmp/missinglibs.txt
   fi
  fi
 done
 echo 43
 kill $X1PID
}

#searches deps of all user-installed pkgs...
missingpkgsfunc() {
 yaf-splash -font "8x16" -outline 0 -margin 4 -bg orange -text "Checking all user-installed packages for any missing dependencies..." &
 X2PID=$!
  USER_DB_dependencies="`cat /root/.packages/user-installed-packages | cut -f 9 -d '|' | tr ',' '\n' | sort -u | tr '\n' ','`"
  /usr/local/petget/findmissingpkgs.sh "$USER_DB_dependencies"
  #...returns /tmp/petget_installed_patterns_all, /tmp/petget_pkg_deps_patterns, /tmp/petget_missingpkgs_patterns
  MISSINGDEPS_PATTERNS="`cat /tmp/petget_missingpkgs_patterns`" #v431
  #/tmp/petget_missingpkgs_patterns has a list of missing dependencies, format ex:
  #|kdebase|
  #|kdelibs|
  #|mesa|
  #|qt|
  kill $X2PID
}

if [ $1 ];then
 for APKGNAME in `echo -n $1 | tr '|' ' '`
 do
  [ -f /root/.packages/${APKGNAME}.files ] && dependcheckfunc
 done
else
 #ask user what pkg to check...
 ACTIONBUTTON="<button>
     <input file stock=\"gtk-convert\"></input>
     <label>Check dependencies</label>
     <action type=\"exit\">BUTTON_CHK_DEPS</action>
     </button>"
 #echo -n "" > /tmp/petget_depchk_buttons

 #rm -f /tmp/petget_depchk_buttons.*
 if [ ! -f /tmp/petget_depchk_buttons ] ; then
 echo -n "" > /tmp/petget_depchk_buttons
 TOTAL=`cat /root/.packages/user-installed-packages | wc -l`
 yaf-splash -bg yellow -timeout $((TOTAL/5)) -text "Building database list ..." &
 rm -f /root/.packages/user-installed-packages-rev
 for i in `seq $TOTAL -1 1` ; do
 sed -n "$i p" /root/.packages/user-installed-packages >> /root/.packages/user-installed-packages-rev
 done

 cat -n /root/.packages/user-installed-packages | cut -f 1,10 -d '|' | sed 's/^[[:blank:]]*//g' | tr '\t' ' ' | tr -s ' ' | sed 's/^\([0-9]* \)\(.*\)/\2\|\1/g' > /tmp/petget_depchk_buttons-orig

 ls -l /root/.packages/* | tr '[[:blank:]]' ' ' | tr -s ' ' | cut -f 6,8 -d ' ' >/tmp/petget_chdeps_ls_l

 NR=$TOTAL
 cat /root/.packages/user-installed-packages-rev | cut -f 1,10 -d '|' |
 while read ONEPKGSPEC
 do
  [ "$ONEPKGSPEC" = "" ] && continue
  ONEPKG="`echo -n "$ONEPKGSPEC" | cut -f 1 -d '|'`"
  #echo 87
  grepPattern9=${ONEPKG//-/\\-}
  grepPattern=${grepPattern9//./\\.}
  echo grepPattern="$grepPattern"
  oneTime=`grep "$grepPattern" /tmp/petget_chdeps_ls_l | head -n1 | cut -f 1 -d ' '`
  [ -z "$oneTime" ] && oneTime='Name of flieslist file and package differ'
  ONEDESCR="`echo -n "$ONEPKGSPEC" | cut -f 2 -d '|'`"

  if [ "$NR" -lt 10 ] ; then NRf="00$NR";
  elif [ "$NR" -gt 9 ] && [ "$NR" -lt 100 ] ; then NRf="0$NR";
  else NRf=$NR;
  fi
  # echo "<radiobutton><label>${ONEPKG} DESCRIPTION: ${ONEDESCR}</label><variable>RADIO_${ONEPKG}</variable></radiobutton>" >> /tmp/petget_depchk_buttons
  echo "${ONEPKG} | DESCRIPTION: ${ONEDESCR} | ${oneTime} | $NRf" >> /tmp/petget_depchk_buttons
  NR=$((NR-1)) ;
 done
 fi
 cp /tmp/petget_depchk_buttons /tmp/petget_depchk_buttons-rev
 echo 'rev' > /tmp/sort.criteria

 RADBUTTONS="`cat /tmp/petget_depchk_buttons`"
 if [ "$RADBUTTONS" = "" ];then
  ACTIONBUTTON=""
  # RADBUTTONS="<text use-markup=\"true\"><label>\"<b>No packages installed by user, click 'Cancel' button</b>\"</label></text>"
  echo "No packages installed by user, click 'Cancel' button." > /tmp/petget_depchk_buttons
 fi ; echo '0' > /tmp/sort.count
 export DEPS_DIALOG="<window title=\"Puppy Package Manager\" icon-name=\"gtk-about\">
  <vbox>
   <text><label>Please choose what package you would like to check the dependencies of:</label></text>
   <frame User-installed packages>
    <tree>
     <label> Package List              | Description       | Time stamp | Nr  </label>
      <variable>ONEPKG</variable>
      <input>cat /tmp/petget_depchk_buttons</input>
      <width>700</width><height>180</height>
    </tree>
   </frame>
   <hbox>
    ${ACTIONBUTTON}
    <button><input file stock=\"gtk-add\"></input><label>Refresh db</label>
    <action>rm -f /tmp/petget_depchk*</action>
    <action>$0 &</action>
    <action>EXIT:newDB</action>
    </button>
    <button><input file stock=\"gtk-find\"></input><label>File Browser</label>
    <action>rox $HOME/.packages</action>
    </button>
    <button><input file stock=\"gtk-refresh\"></input><label>SORT</label>
    <action>/usr/local/petget/01_check_deps.sh</action>
    <action>refresh:ONEPKG</action>
    <action>refresh:SORTCRITERIA</action>
    </button>
    <text><label>\"\"</label><variable>SORTCRITERIA</variable><input file>/tmp/sort.criteria</input></text>
    <button><input file stock=\"gtk-quit\"></input><label>..bye..</label>
    <action>EXIT:QUIT</action>
    </button>
   </hbox>
  </vbox>
 </window>
"
#   ${RADBUTTONS}
 RETPARAMS="`gtkdialog3 --program=DEPS_DIALOG`"
 #ex returned:
 #RADIO_audacious-1.5.1="true"
 #EXIT="BUTTON_CHK_DEPS"

 #eval "$RETPARAMS"
 #[ "$EXIT" != "BUTTON_CHK_DEPS" ] && exit
 [ "`echo "$RETPARAMS" | grep 'BUTTON_CHK_DEPS'`" = "" ] && exit

 # APKGNAME="`echo "$RETPARAMS" | grep '^RADIO_' | grep '"true"' | cut -f 1 -d '=' | cut -f 2 -d '_'`"
 APKGNAME=`echo "$RETPARAMS" | grep -w 'ONEPKG' | cut -f 2 -d '"' | cut -f 1 -d ' '`
 echo $DBG 119 ONEPKG $ONEPKG
 echo $DBG 120 RETPARAMS $RETPARAMS
 echo $DBG 121 'APKGNAME='"$APKGNAME"'='
 dependcheckfunc

fi

missingpkgsfunc

#present results to user...
MISSINGMSG1="<text use-markup=\"true\"><label>\"<b>No missing shared libraries</b>\"</label></text>"
if [ -s /tmp/missinglibs.txt ];then
 MISSINGMSG1="<text use-markup=\"true\"><label>\"<b>`cat /tmp/missinglibs.txt`</b>\"</label></text>"
fi
MISSINGMSG2="<text use-markup=\"true\"><label>\"<b>No missing dependent packages</b>\"</label></text>"
if [ "$MISSINGDEPS_PATTERNS" != "" ];then #[ -s /tmp/petget_missingpkgs ];then
 MISSINGPKGS="`echo "$MISSINGDEPS_PATTERNS" | sed -e 's%|%%g' | tr '\n' ' '`" #v431
 MISSINGMSG2="<text use-markup=\"true\"><label>\"<b>${MISSINGPKGS}</b>\"</label></text>"
fi

PKGS="$APKGNAME"
[ $1 ] && PKGS="`echo -n "${1}" | tr '|' ' '`"

export DEPS_DIALOG="<window title=\"Puppy Package Manager\" icon-name=\"gtk-about\">
  <vbox>
   <text><label>Puppy has searched for any missing shared libraries of these packages:</label></text>
   <text><label>${PKGS}</label></text>
   ${MISSINGMSG1}
   <text><label>Puppy has examined all user-installed packages and found these missing dependencies:</label></text>
   ${MISSINGMSG2}
   <hbox>
    <button ok></button>
   </hbox>
  </vbox>
 </window>
"
 RETPARAMS="`gtkdialog3 --program=DEPS_DIALOG`"

echo "$RETPARAMS" > /dev/console

echo "$0: END" >&2

#krg---Start again --->>>>
[ ! "$1" ] && . /usr/local/petget/check_deps.sh
###END###
