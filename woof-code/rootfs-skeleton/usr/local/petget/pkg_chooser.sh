#!/bin/bash
#(c) Copyright Barry Kauler 2009, puppylinux.com
#2009 Lesser GPL licence v2 (/usr/share/doc/legal/lgpl-2.1.txt).
#The Puppy Package Manager main GUI window.
#v424 reintroduce the 'ALL' category, for ppup build only.
#v425 enable ENTER key for find box.
#100116 add quirky repo at ibiblio. 100126: bugfixes.
#100513 reintroduce the 'ALL' category for quirky (t2).

export LANG=C
mkdir -p /tmp/PetGet  ##+++2011-11-27
. /etc/DISTRO_SPECS #has DISTRO_BINARY_COMPAT, DISTRO_COMPAT_VERSION
. /root/.packages/DISTRO_PKGS_SPECS
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

repocnt=0
COMPAT_REPO=""
COMPAT_DBS=""
echo -n "" > /tmp/PetGet/petget_active_repo_list

#100116 quirky...
QUIRKY_DB=''
if [ "`echo "$DISTRO_NAME" | grep -i 'quirky'`" != "" ];then
 if [ "`echo -n "$PKG_REPOS_ENABLED" | grep 'puppy\-quirky'`" != "" ];then
  echo 'puppy-quirky-official' >> /tmp/PetGet/petget_active_repo_list
  QUIRKY_DB='<radiobutton><label>puppy-quirky</label><action>/tmp/PetGet/filterversion.sh puppy-quirky-official</action><action>/usr/local/petget/filterpkgs.sh</action><action>refresh:TREE1</action></radiobutton>'
  FIRST_DB='puppy-quirky-official'
  repocnt=1
 fi
fi

if [ "$DISTRO_BINARY_COMPAT" != "puppy" ];then #w477 if compat-distro is puppy, bypass.
 for ONE_DB in `ls -1 /root/.packages/Packages-${DISTRO_BINARY_COMPAT}-${DISTRO_COMPAT_VERSION}* | tr '\n' ' '`
 do
  BASEREPO="`basename $ONE_DB`"
  bPATTERN=' '"$BASEREPO"' '
  [ "`echo -n "$PKG_REPOS_ENABLED" | grep "$bPATTERN"`" = "" ] && continue
  repocnt=`expr $repocnt + 1`
  COMPAT_REPO="`echo -n "$ONE_DB" | rev | cut -f 1 -d '/' | rev | cut -f 2-4 -d '-'`"
  COMPAT_DBS="${COMPAT_DBS} <radiobutton><label>${COMPAT_REPO}</label><action>/tmp/PetGet/filterversion.sh ${COMPAT_REPO}</action><action>/usr/local/petget/filterpkgs.sh</action><action>refresh:TREE1</action></radiobutton>"
  echo "${COMPAT_REPO}" >> /tmp/PetGet/petget_active_repo_list #read in findnames.sh
  [ "$FIRST_DB" = "" ] && [ $repocnt = 1 ] && FIRST_DB="$COMPAT_REPO"
 done
fi

xrepocnt=$repocnt #w476
PUPPY_DBS=""
for ONE_DB in `ls -1 /root/.packages/Packages-puppy* | sort -r | tr '\n' ' '`
do
 BASEREPO="`basename $ONE_DB`"
 [ "$BASEREPO" = "Packages-puppy-quirky-official" ] && continue #100126 already handled above.
 bPATTERN=' '"$BASEREPO"' '
 [ "`echo -n "$PKG_REPOS_ENABLED" | grep "$bPATTERN"`" = "" ] && continue
 PUPPY_REPO="`echo -n "$ONE_DB" | rev | cut -f 1 -d '/' | rev | cut -f 2-4 -d '-'`"
 #chop size of label down a bit, to fit in 800x600 window...
 PUPPY_REPO_CUT="`echo -n "$ONE_DB" | rev | cut -f 1 -d '/' | rev | cut -f 2,3 -d '-'`"
 PUPPY_REPO_FULL="`echo -n "$ONE_DB" | rev | cut -f 1 -d '/' | rev | cut -f 2-9 -d '-'`"
 PUPPY_DBS="${PUPPY_DBS} <radiobutton><label>${PUPPY_REPO_CUT}</label><action>/tmp/PetGet/filterversion.sh ${PUPPY_REPO_FULL}</action><action>/usr/local/petget/filterpkgs.sh</action><action>refresh:TREE1</action></radiobutton>"
 echo "${PUPPY_REPO}" >> /tmp/PetGet/petget_active_repo_list #read in findnames.sh
 [ "$FIRST_DB" = "" ] && [ $repocnt = $xrepocnt ] && FIRST_DB="$PUPPY_REPO" #w476
 repocnt=`expr $repocnt + 1`
done

FILTER_CATEG="Desktop"
#note, cannot initialise radio buttons in gtkdialog...
echo "Desktop" > /tmp/PetGet/petget_filtercategory #must start with Desktop.
echo "$FIRST_DB" > /tmp/PetGet/petget_filterversion #ex: slackware-12.2-official

#if [ "$DISTRO_BINARY_COMPAT" = "ubuntu" -o "$DISTRO_BINARY_COMPAT" = "debian" ];then
if [ 0 -eq 1 ];then #w020 disable this choice.
 #filter pkgs by first letter, for more speed. must start with ab...
 echo "ab" > /tmp/PetGet/petget_pkg_first_char
 FIRSTCHARS="
<radiobutton><label>a,b</label><action>echo ab > /tmp/PetGet/petget_pkg_first_char</action><action>/usr/local/petget/filterpkgs.sh</action><action>refresh:TREE1</action></radiobutton>
<radiobutton><label>c,d</label><action>echo cd > /tmp/PetGet/petget_pkg_first_char</action><action>/usr/local/petget/filterpkgs.sh</action><action>refresh:TREE1</action></radiobutton>
<radiobutton><label>e,f</label><action>echo ef > /tmp/PetGet/petget_pkg_first_char</action><action>/usr/local/petget/filterpkgs.sh</action><action>refresh:TREE1</action></radiobutton>
<radiobutton><label>g,h</label><action>echo gh > /tmp/PetGet/petget_pkg_first_char</action><action>/usr/local/petget/filterpkgs.sh</action><action>refresh:TREE1</action></radiobutton>
<radiobutton><label>i,j</label><action>echo ij > /tmp/PetGet/petget_pkg_first_char</action><action>/usr/local/petget/filterpkgs.sh</action><action>refresh:TREE1</action></radiobutton>
<radiobutton><label>k,l</label><action>echo kl > /tmp/PetGet/petget_pkg_first_char</action><action>/usr/local/petget/filterpkgs.sh</action><action>refresh:TREE1</action></radiobutton>
<radiobutton><label>m,n</label><action>echo mn > /tmp/PetGet/petget_pkg_first_char</action><action>/usr/local/petget/filterpkgs.sh</action><action>refresh:TREE1</action></radiobutton>
<radiobutton><label>o,p</label><action>echo op > /tmp/PetGet/petget_pkg_first_char</action><action>/usr/local/petget/filterpkgs.sh</action><action>refresh:TREE1</action></radiobutton>
<radiobutton><label>q,r</label><action>echo qr > /tmp/PetGet/petget_pkg_first_char</action><action>/usr/local/petget/filterpkgs.sh</action><action>refresh:TREE1</action></radiobutton>
<radiobutton><label>s,t</label><action>echo st > /tmp/PetGet/petget_pkg_first_char</action><action>/usr/local/petget/filterpkgs.sh</action><action>refresh:TREE1</action></radiobutton>
<radiobutton><label>u,v</label><action>echo uv > /tmp/PetGet/petget_pkg_first_char</action><action>/usr/local/petget/filterpkgs.sh</action><action>refresh:TREE1</action></radiobutton>
<radiobutton><label>w,x</label><action>echo wx > /tmp/PetGet/petget_pkg_first_char</action><action>/usr/local/petget/filterpkgs.sh</action><action>refresh:TREE1</action></radiobutton>
<radiobutton><label>y,z</label><action>echo yz > /tmp/PetGet/petget_pkg_first_char</action><action>/usr/local/petget/filterpkgs.sh</action><action>refresh:TREE1</action></radiobutton>
<radiobutton><label>0-9</label><action>echo 0123456789 > /tmp/PetGet/petget_pkg_first_char</action><action>/usr/local/petget/filterpkgs.sh</action><action>refresh:TREE1</action></radiobutton>
<radiobutton><label>ALL</label><action>echo ALL > /tmp/PetGet/petget_pkg_first_char</action><action>/usr/local/petget/filterpkgs.sh</action><action>refresh:TREE1</action></radiobutton>
"
 xFIRSTCHARS="<hbox>
${FIRSTCHARS}
</hbox>"
else
 #do not dispay the alphabetic radiobuttons...
 echo "ALL" > /tmp/PetGet/petget_pkg_first_char
 FIRSTCHARS=""
 xFIRSTCHARS=""
fi

#finds pkgs in repository based on filter category and version and formats ready for display...
/usr/local/petget/filterpkgs.sh $FILTER_CATEG #writes to /tmp/PetGet/filterpkgs.results

echo '#!/bin/sh
echo $1 > /tmp/PetGet/petget_filterversion
' > /tmp/PetGet/filterversion.sh
chmod 777 /tmp/PetGet/filterversion.sh

#  <text use-markup=\"true\"><label>\"<b>To install or uninstall,</b>\"</label></text>

ALLCATEGORY=''
if [ "$DISTRO_BINARY_COMPAT" = "puppy" ];then #v424 reintroduce the 'ALL' category.
 ALLCATEGORY='<radiobutton><label>ALL</label><action>/usr/local/petget/filterpkgs.sh ALL</action><action>refresh:TREE1</action></radiobutton>'
fi
#100513 also for 't2' (quirky) builds...
if [ "$DISTRO_BINARY_COMPAT" = "t2" ];then #reintroduce the 'ALL' category.
 ALLCATEGORY='<radiobutton><label>ALL</label><action>/usr/local/petget/filterpkgs.sh ALL</action><action>refresh:TREE1</action></radiobutton>'
fi

#w476 reverse COMPAT_DBS, PUPPY_DBS...
#100412 make sure first radiobutton matches list of pkgs...
DB_ORDERED="${QUIRKY_DB}
${PUPPY_DBS}
${COMPAT_DBS}"
fdPATTERN='>'"$FIRST_DB"'<'
DB1="`echo "$DB_ORDERED" | grep "$fdPATTERN"`"
if [ "`echo "$QUIRKY_DB" | grep "$fdPATTERN"`" = "" ];then
 if [ "`echo "$PUPPY_DBS" | grep "$fdPATTERN"`" != "" ];then
  DB_ORDERED="${PUPPY_DBS}
${QUIRKY_DB}
${COMPAT_DBS}"
 else
  DB_ORDERED="${COMPAT_DBS}
${QUIRKY_DB}
${PUPPY_DBS}"
 fi
fi
DBe="`echo "$DB_ORDERED" | grep -v "$fdPATTERN"`"
DB_ORDERED="${DB1} ${DBe}"

export MAIN_DIALOG="<window title=\"Puppy Package Manager\" icon-name=\"gtk-about\">

<vbox>
 <hbox>
  <text><label>Repo:</label></text>
  ${DB_ORDERED}
 </hbox>
 ${xFIRSTCHARS}
 <hbox>
  <vbox>
   <radiobutton><label>Desktop</label><action>/usr/local/petget/filterpkgs.sh Desktop</action><action>refresh:TREE1</action></radiobutton>
   <radiobutton><label>System</label><action>/usr/local/petget/filterpkgs.sh System</action><action>refresh:TREE1</action></radiobutton>
   <radiobutton><label>Setup</label><action>/usr/local/petget/filterpkgs.sh Setup</action><action>refresh:TREE1</action></radiobutton>
   <radiobutton><label>Utility</label><action>/usr/local/petget/filterpkgs.sh Utility</action><action>refresh:TREE1</action></radiobutton>
   <radiobutton><label>Filesystem</label><action>/usr/local/petget/filterpkgs.sh Filesystem</action><action>refresh:TREE1</action></radiobutton>
   <radiobutton><label>Graphic</label><action>/usr/local/petget/filterpkgs.sh Graphic</action><action>refresh:TREE1</action></radiobutton>
   <radiobutton><label>Document</label><action>/usr/local/petget/filterpkgs.sh Document</action><action>refresh:TREE1</action></radiobutton>
   <radiobutton><label>Business</label><action>/usr/local/petget/filterpkgs.sh Calculate</action><action>refresh:TREE1</action></radiobutton>
   <radiobutton><label>Personal</label><action>/usr/local/petget/filterpkgs.sh Personal</action><action>refresh:TREE1</action></radiobutton>
   <radiobutton><label>Network</label><action>/usr/local/petget/filterpkgs.sh Network</action><action>refresh:TREE1</action></radiobutton>
   <radiobutton><label>Internet</label><action>/usr/local/petget/filterpkgs.sh Internet</action><action>refresh:TREE1</action></radiobutton>
   <radiobutton><label>Multimedia</label><action>/usr/local/petget/filterpkgs.sh Multimedia</action><action>refresh:TREE1</action></radiobutton>
   <radiobutton><label>Fun</label><action>/usr/local/petget/filterpkgs.sh Fun</action><action>refresh:TREE1</action></radiobutton>
   ${ALLCATEGORY}
  </vbox>
  <vbox>
  <tree>
    <label>Package|Description</label>
    <height>280</height><width>668</width>
    <variable>TREE1</variable>
    <input>cat /tmp/PetGet/filterpkgs.results</input>
    <action signal=\"button-release-event\">/usr/local/petget/installpreview.sh</action>
    <action signal=\"button-release-event\">/usr/local/petget/finduserinstalledpkgs.sh</action>
    <action signal=\"button-release-event\">refresh:TREE2</action>
  </tree>
  </vbox>
 </hbox>
<hbox>
 <vbox>
  <text><label>\" \"</label></text>
  <text use-markup=\"true\"><label>\"<b>Just click on a package!</b>\"</label></text>
  <text><label>\" \"</label></text>
  <hbox>
   <text><label>Find:</label></text>
   <entry activates-default=\"true\">
    <variable>ENTRY1</variable>
   </entry>
   <button can-default=\"true\" has-default=\"true\" use-stock=\"true\">
    <label>Go</label>
    <action>/usr/local/petget/findnames.sh</action>
    <action>refresh:TREE1</action>
   </button>
  </hbox>
  <button>
   <input file icon=\"gtk-preferences\"></input>
   <label>Configure package manager</label>
   <action>/usr/local/petget/configure.sh</action>
   <action>/usr/local/petget/filterpkgs.sh</action>
   <action>refresh:TREE1</action>
  </button>
  <button type=\"exit\">
   <input file icon=\"gtk-close\"></input>
   <label>Exit package manager</label>
  </button>
 </vbox>
 <text><label>\" \"</label></text>
 <frame Installed packages>
  <tree>
    <label>Package|Description</label>
    <height>100</height><width>480</width>
    <variable>TREE2</variable>
    <input>cat /tmp/PetGet/installedpkgs.results</input>
    <action signal=\"button-release-event\">/usr/local/petget/removepreview.sh</action>
    <action signal=\"button-release-event\">/usr/local/petget/finduserinstalledpkgs.sh</action>
    <action signal=\"button-release-event\">refresh:TREE2</action>
  </tree>
 </frame>
</hbox>
</vbox>
</window>
"

RETPARAMS="`gtkdialog3 --program=MAIN_DIALOG`"

#eval "$RETPARAMS"

###END###
