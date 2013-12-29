#!/bin/sh
#choose an installed pkg and find all its dependencies.
#when entered with a passed param, it is a list of pkgs, '|' delimited,
#ex: abiword-1.2.3|aiksaurus-3.4.5|yabby-5.0

echo "$0:$*" >&2

Pro="/check_deps.sh"
Script_Dir="/usr/local/petget"
if test -f "$Script_Dir/path" ; then . "$Script_Dir/path" ; fi
DBG="$Script_Dir$Pro line :"  ##krg---debugging value---<<<

. /etc/DISTRO_SPECS #has DISTRO_BINARY_COMPAT, DISTRO_COMPAT_VERSION
. /root/.packages/DISTRO_PKGS_SPECS

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

 FNDFILES="`cat /root/.packages/$APKGNAME.files`"
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

if [ "$1" ];then
 for APKGNAME in `echo -n $1 | tr '|' ' '`
 do
  [ -f /root/.packages/${APKGNAME}.files ] && dependcheckfunc
 done
else
 #ask user what pkg to check...
 ACTIONBUTTON="<button>
     <label>Check dependencies</label>
     <action type=\"exit\">BUTTON_CHK_DEPS</action>
     </button>"
 echo -n "" > /tmp/petget_depchk_buttons

 yaf-splash -font "8x16" -outline 0 -margin 4 -bg blue -fg white -timeout 10 -text "If many PKGS are installed , please wait ..." &
 X1PID=$!

 NR=0
 cat /root/.packages/user-installed-packages | cut -f 1,10 -d '|' |
 while read ONEPKGSPEC
 do
  [ "$ONEPKGSPEC" = "" ] && continue
  ONEPKG="`echo -n "$ONEPKGSPEC" | cut -f 1 -d '|'`"
  ONEDESCR="`echo -n "$ONEPKGSPEC" | cut -f 2 -d '|'`"
  NR=$((NR+1)) ; fNR="$NR" ; if [ $fNR -lt 10 ] ; then fNR="00$fNR" ; elif [ $fNR -lt 100 ] ; then  fNR="0$fNR" ; fi
  echo "${ONEPKG} | $fNR : | ${ONEDESCR}" >> /tmp/petget_depchk_buttons
 done

 [ -n "`ps-FULL --pid $X1PID | sed '1 d'`" ] && kill $X1PID

 RADBUTTONS="`cat /tmp/petget_depchk_buttons`"
 #if [ "$RADBUTTONS" != "" ];then #100902 test if too many installed pkgs
 # nRADBUT=`echo "$RADBUTTONS" | wc -l`
 # if [ $nRADBUT -gt 23 ];then
 #  #layout as two columns...
 #  RADBUTTONS1="`cat /tmp/petget_depchk_buttons | head -n 23`"
 #  RADBUTTONS2="`cat /tmp/petget_depchk_buttons | tail -n +24`"
 #  RADBUTTONS="<hbox><vbox>${RADBUTTONS1}</vbox><vbox>${RADBUTTONS2}</vbox></hbox>"
 # fi
 #fi
 if [ "$RADBUTTONS" = "" ];then
  ACTIONBUTTON=""
  #RADBUTTONS="<text use-markup=\"true\"><label>\"<b>No packages installed by user, click 'Cancel' button</b>\"</label></text>"
  echo "No packages installed by user, click 'Cancel' button." > /tmp/petget_depchk_buttons
 fi
 export DEPS_DIALOG="<window title=\"Puppy Package Manager\" icon-name=\"gtk-about\">
  <vbox>
   <text><label>Please choose what package you would like to check the dependencies of:</label></text>
   <frame /root/.packages/user-installed-packages>
    <tree>
     <label>Package List | | and Description           </label>
      <variable>ONEPKG</variable>
       <input>cat /tmp/petget_depchk_buttons</input>
       <width>700</width><height>180</height>
    </tree>
   </frame>
   <hbox>
    ${ACTIONBUTTON}
    <button cancel></button>
   </hbox>
  </vbox>
 </window>
"
 RETPARAMS="`gtkdialog3 --program=DEPS_DIALOG`"
 #ex returned:
 #RADIO_audacious-1.5.1="true"
 #EXIT="BUTTON_CHK_DEPS"

 #eval "$RETPARAMS"
 #[ "$EXIT" != "BUTTON_CHK_DEPS" ] && exit
 [ "`echo "$RETPARAMS" | grep 'BUTTON_CHK_DEPS'`" = "" ] && exit

 # APKGNAME="`echo "$RETPARAMS" | grep '^RADIO_' | grep '"true"' | cut -f 1 -d '=' | cut -f 2 -d '_'`"
 APKGNAME="`echo "$RETPARAMS" | grep ONEPKG | cut -f 2 -d '\"' | cut -f 1 -d ' '`"
 echo $DBG 191 ONEPKG $ONEPKG
 echo $DBG 192 RETPARAMS $RETPARAMS
 echo $DBG 193 APKGNAME $APKGNAME
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

DETAILSBUTTON=""
if [ -s /tmp/missinglibs.txt -o -s /tmp/missinglibs_hidden.txt ];then #100830 details button
 DETAILSBUTTON="<button><label>View details</label><action>defaulttextviewer /tmp/missinglibs_details.txt & </action></button>"
fi

PKGS="$APKGNAME"
[ "$1" ] && PKGS="`echo -n "${1}" | tr '|' ' '`"

export DEPS_DIALOG="<window title=\"Puppy Package Manager\" icon-name=\"gtk-about\">
  <vbox>
   <text><label>Puppy has searched for any missing shared libraries of these packages:</label></text>
   <text><label>${PKGS}</label></text>
   ${MISSINGMSG1}
   <text><label>Puppy has examined all user-installed packages and found these missing dependencies:</label></text>
   ${MISSINGMSG2}
   <hbox>
    ${DETAILSBUTTON}
    <button ok></button>
   </hbox>
  </vbox>
 </window>
"
 RETPARAMS="`gtkdialog3 --center --program=DEPS_DIALOG`"
###krg---Start again --->>>
[ -z "$1" ] && . /usr/local/petget/check_deps.sh
###END###
