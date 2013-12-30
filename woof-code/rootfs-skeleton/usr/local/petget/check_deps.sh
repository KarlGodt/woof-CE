#!/bin/sh
#choose an installed pkg and find all its dependencies.
#when entered with a passed param, it is a list of pkgs, '|' delimited,
#ex: abiword-1.2.3|aiksaurus-3.4.5|yabby-5.0
#100718 bug fix: code block copied from /usr/local/petget/pkg_chooser.sh
#100718 reduce size of missing-libs list, to fit in window.

########################################################################
#
# CHANGES by Karl Reimer Godt
# 01.0 : table instead of radiobuttons
# 01.1 : added delimiter to table
# 02.0 : fixed bug in my original changes of looping 
#        if called with "$1" from installpreview.sh
# 03.0 : changed tmp dir to /tmp/PetGet
#
# /dev/hda7
# /dev/hda7:
# LABEL="/"
# UUID="429ee1ed-70a4-43a5-89f8-33496c489260"
# TYPE="ext4"
# DISTRO_NAME='Lucid·Puppy'
# DISTRO_VERSION=218
# DISTRO_MINOR_VERSION=00
# DISTRO_BINARY_COMPAT='ubuntu'
# DISTRO_FILE_PREFIX='luci'
# DISTRO_COMPAT_VERSION='lucid'
# DISTRO_KERNEL_PET='linux_kernel-2.6.33.2-tickless_smp_patched-L3.pet'
# PUPMODE=2
# SATADRIVES=''
# PUP_HOME='/'
# PDEV1='hda7'
# DEV1FS='ext4'
# Linux·puppypc·2.6.31.14·#1·Mon·Jan·24·21:03:21·GMT-8·2011·i686·GNU/Linux
# Xserver=/usr/bin/Xorg
# $LANG=en_US
# today=Tue·Oct·25·18:17:58·GMT+1·2011
#
# TODO1 : find if scrollbar possible to table
# TODO2 : change table to tree 
#
#
#
########################################################################


Pro="/check_deps.sh"
Script_Dir="/usr/local/petget"
if test -f $Script_Dir/path ; then . $Script_Dir/path ; fi
DBG="$Script_Dir$Pro line :"  ##krg---debugging value---<<<
mkdir -p /tmp/PetGet ##+++2011_10_25
. /etc/DISTRO_SPECS #has DISTRO_BINARY_COMPAT, DISTRO_COMPAT_VERSION
. /root/.packages/DISTRO_PKGS_SPECS

echo -n "" > /tmp/PetGet/missinglibs.txt
echo -n "" > /tmp/PetGet/missinglibs_details.txt
echo -n "" > /tmp/PetGet/missingpkgs.txt

#######100718 code block copied from /usr/local/petget/pkg_chooser.sh#######
. /root/.packages/PKGS_MANAGEMENT #has PKG_REPOS_ENABLED, PKG_NAME_ALIASES

#finds all user-installed pkgs and formats ready for display...
/usr/local/petget/finduserinstalledpkgs.sh #writes to /tmp/PetGet/installedpkgs.results

#100711 moved from findmissingpkgs.sh...
if [ ! -f /tmp/PetGet/petget_installed_patterns_system ];then
 INSTALLED_PATTERNS_SYS="`cat /root/.packages/woof-installed-packages | cut -f 2 -d '|' | sed -e 's%^%|%' -e 's%$%|%' -e 's%\\-%\\\\-%g'`"
 echo "$INSTALLED_PATTERNS_SYS" > /tmp/PetGet/petget_installed_patterns_system
 #PKGS_SPECS_TABLE also has system-installed names, some of them are generic combinations of pkgs...
 INSTALLED_PATTERNS_GEN="`echo "$PKGS_SPECS_TABLE" | grep '^yes' | cut -f 2 -d '|' |  sed -e 's%^%|%' -e 's%$%|%' -e 's%\\-%\\\\-%g'`"
 echo "$INSTALLED_PATTERNS_GEN" >> /tmp/PetGet/petget_installed_patterns_system
 sort -u /tmp/PetGet/petget_installed_patterns_system > /tmp/PetGet/petget_installed_patterns_systemx
 mv -f /tmp/PetGet/petget_installed_patterns_systemx /tmp/PetGet/petget_installed_patterns_system
fi
#100711 this code repeated in findmissingpkgs.sh...
cp -f /tmp/PetGet/petget_installed_patterns_system /tmp/PetGet/petget_installed_patterns_all
INSTALLED_PATTERNS_USER="`cat /root/.packages/user-installed-packages | cut -f 2 -d '|' | sed -e 's%^%|%' -e 's%$%|%' -e 's%\\-%\\\\-%g'`"
echo "$INSTALLED_PATTERNS_USER" >> /tmp/PetGet/petget_installed_patterns_all

#process name aliases into patterns (used in filterpkgs.sh, findmissingpkgs.sh) ... 100126...
xPKG_NAME_ALIASES="`echo "$PKG_NAME_ALIASES" | tr ' ' '\n' | grep -v '^$' | sed -e 's%^%|%' -e 's%$%|%' -e 's%,%|,|%g' -e 's%\\*%.*%g'`"
echo "$xPKG_NAME_ALIASES" > /tmp/PetGet/petget_pkg_name_aliases_patterns

#100711 above has a problem as it has wildcards. need to expand...
#ex: PKG_NAME_ALIASES has an entry 'cxxlibs,glibc*,libc-*', the above creates '|cxxlibs|,|glibc.*|,|libc\-.*|',
#    after expansion: '|cxxlibs|,|glibc|,|libc-|,|glibc|,|glibc_dev|,|glibc_locales|,|glibc-solibs|,|glibc-zoneinfo|'
echo -n "" > /tmp/PetGet/petget_pkg_name_aliases_patterns_expanded
for ONEALIASLINE in `cat /tmp/PetGet/petget_pkg_name_aliases_patterns | tr '\n' ' '` #ex: |cxxlibs|,|glibc.*|,|libc\-.*|
do
 echo -n "" > /tmp/PetGet/petget_temp1
 for PARTONELINE in `echo -n "$ONEALIASLINE" | tr ',' ' '`
 do
  grep "$PARTONELINE" /tmp/PetGet/petget_installed_patterns_all >> /tmp/PetGet/petget_temp1
 done
 ZZZ="`echo "$ONEALIASLINE" | sed -e 's%\.\*%%g' | tr -d '\\'`"
 [ -s /tmp/PetGet/petget_temp1 ] && ZZZ="${ZZZ},`cat /tmp/PetGet/petget_temp1 | tr '\n' ',' | tr -s ',' | tr -d '\\'`"
 ZZZ="`echo -n "$ZZZ" | sed -e 's%,$%%'`"
 echo "$ZZZ" >> /tmp/PetGet/petget_pkg_name_aliases_patterns_expanded
done
cp -f /tmp/PetGet/petget_pkg_name_aliases_patterns_expanded /tmp/PetGet/petget_pkg_name_aliases_patterns

#w480 PKG_NAME_IGNORE is definedin PKGS_MANAGEMENT file... 100126...
xPKG_NAME_IGNORE="`echo "$PKG_NAME_IGNORE" | tr ' ' '\n' | grep -v '^$' | sed -e 's%^%|%' -e 's%$%|%' -e 's%,%|,|%g' -e 's%\\*%.*%g'`"
echo "$xPKG_NAME_IGNORE" > /tmp/PetGet/petget_pkg_name_ignore_patterns
#######100718 end copied code block#######

dependcheckfunc() { ##100
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
    echo "File $ONEFILE has these missing library files:" >> /tmp/PetGet/missinglibs_details.txt #100718
    echo " $MISSINGLIBS" >> /tmp/PetGet/missinglibs_details.txt #100718
    echo " $MISSINGLIBS" >> /tmp/PetGet/missinglibs.txt #100718
   fi
  fi
 done
 if [ -s /tmp/PetGet/missinglibs.txt ];then #100718 reduce size of list, to fit in window...
  MISSINGLIBSLIST="`cat /tmp/PetGet/missinglibs.txt | tr '\n' ' ' | tr -s ' ' | tr ' ' '\n' | sort -u | tr '\n' ' '`"
  echo "$MISSINGLIBSLIST" > /tmp/PetGet/missinglibs.txt
 fi
 kill $X1PID
} #END dependcheckfunc ##68

#searches deps of all user-installed pkgs...
missingpkgsfunc() { ##116
 yaf-splash -font "8x16" -outline 0 -margin 4 -bg orange -text "Checking all user-installed packages for any missing dependencies..." &
 X2PID=$!
  USER_DB_dependencies="`cat /root/.packages/user-installed-packages | cut -f 9 -d '|' | tr ',' '\n' | sort -u | tr '\n' ','`"
  /usr/local/petget/findmissingpkgs.sh "$USER_DB_dependencies"
  #creates /tmp/PetGet/petget_pkg_deps_patterns /tmp/PetGet/petget_missingpkgs_patterns
  #cp -f /tmp/PetGet/petget_installed_patterns_system /tmp/PetGet/petget_installed_patterns_all
  #adds severals to /tmp/PetGet/petget_installed_patterns_all
  #formats /tmp/PetGet/petget_installed_patterns_all
  #...returns /tmp/PetGet/petget_installed_patterns_all, /tmp/PetGet/petget_pkg_deps_patterns, /tmp/PetGet/petget_missingpkgs_patterns
  MISSINGDEPS_PATTERNS="`cat /tmp/PetGet/petget_missingpkgs_patterns`" #v431
  #/tmp/PetGet/petget_missingpkgs_patterns has a list of missing dependencies, format ex:
  #|kdebase|
  #|kdelibs|
  #|mesa|
  #|qt|
  kill $X2PID
} ##END missingpkgsfunc ##103

if [ $1 ];then
 for APKGNAME in `echo -n $1 | tr '|' ' '`
 do
  [ -f /root/.packages/${APKGNAME}.files ] && dependcheckfunc
 done
 exit  ##+++2011_10_25 added to prevent never ending loop , 
       ## also done second time at the very end of script
else
 #ask user what pkg to check...
 ACTIONBUTTON="<button>
     <label>Check dependencies</label>
     <action type=\"exit\">BUTTON_CHK_DEPS</action>
     </button>"
 echo -n "" > /tmp/PetGet/petget_depchk_buttons
 yaf-splash -font "8x16" -outline 0 -margin 4 -bg orange -text "Creating data base ...
 ... Please wait ..." &
 yafPID=$!
 cat /root/.packages/user-installed-packages | cut -f 1,10 -d '|' |
 while read ONEPKGSPEC
 do
  [ "$ONEPKGSPEC" = "" ] && continue
  ONEPKG="`echo -n "$ONEPKGSPEC" | cut -f 1 -d '|'`"
  ONEDESCR="`echo -n "$ONEPKGSPEC" | cut -f 2 -d '|'`"
  #echo "<radiobutton><label>${ONEPKG} DESCRIPTION: ${ONEDESCR}</label><variable>RADIO_${ONEPKG}</variable></radiobutton>" >> /tmp/PetGet/petget_depchk_buttons
  echo "${ONEPKG} | ${ONEDESCR}" >> /tmp/PetGet/petget_depchk_buttons  ##+-2011_10_25 sdded | , removed DESCRIPTION:
 done
 RADBUTTONS="`cat /tmp/PetGet/petget_depchk_buttons`"
 if [ "$RADBUTTONS" = "" ];then
  ACTIONBUTTON=""
  #RADBUTTONS="<text use-markup=\"true\"><label>\"<b>No packages installed by user, click 'Cancel' button</b>\"</label></text>"
  echo "No packages installed by user, click 'Cancel' button." > /tmp/PetGet/petget_depchk_buttons
 fi
 kill -1 $yafPID
 export DEPS_DIALOG="<window title=\"Puppy Package Manager\" icon-name=\"gtk-about\">
  <vbox>
   <text><label>Please choose what package you would like to check the dependencies of:</label></text>
   <frame User-installed packages>
   
   <table>
     <label>Package List            | Description           </label>
      <variable>ONEPKG</variable>
       <input>cat /tmp/PetGet/petget_depchk_buttons</input>
       <width>700</width><height>180</height>
    </table>
   
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
 echo $DBG 215 175 191 ONEPKG=${ONEPKG}_EOS
 echo $DBG 216 176 192 RETPARAMS=${RETPARAMS}_EOS
 echo $DBG 217 177 193 APKGNAME="${APKGNAME}"_EOS
 dependcheckfunc  ##passes APKGNAME ; creates /tmp/PetGet/missinglibs.txt
 
fi

missingpkgsfunc  ##returns MISSINGDEPS_PATTERNS

#present results to user...
MISSINGMSG1="<text use-markup=\"true\"><label>\"<b>No missing shared libraries</b>\"</label></text>"
if [ -s /tmp/PetGet/missinglibs.txt ];then
 MISSINGMSG1="<text use-markup=\"true\"><label>\"<b>`cat /tmp/PetGet/missinglibs.txt`</b>\"</label></text>"
fi
MISSINGMSG2="<text use-markup=\"true\"><label>\"<b>No missing dependent packages</b>\"</label></text>"
if [ "$MISSINGDEPS_PATTERNS" != "" ];then #[ -s /tmp/PetGet/petget_missingpkgs ];then
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
 RETPARAMS="`gtkdialog3 --center --program=DEPS_DIALOG`"
###krg---Start again --->>>
[ ! "$1" ] && . /usr/local/petget/check_deps.sh  ##+2011_10_25 added test $1 
# to prevent never ending loop from if called from installpreview.sh
###END###
