#!/bin/bash
#
# New header by Karl Reimer Godt, September 2014
  _TITLE_="Puppy_pkg_chooser.sh"
_VERSION_=1.0omega
_COMMENT_="$_TITLE_:Puppy Linux shell script [to TODO here]"

MY_SELF="/usr/local/petget/pkg_chooser.sh"
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
# The Puppy Package Manager main GUI window.
#v424 reintroduce the 'ALL' category, for ppup build only.
#v425 enable ENTER key for find box.

_TITLE_=PPM
_COMMENT_="Puppy Package Manager main GUI"

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


echo "$0: START" >&2

export LANG=C

. /etc/DISTRO_SPECS #has DISTRO_BINARY_COMPAT, DISTRO_COMPAT_VERSION
. /root/.packages/DISTRO_PKGS_SPECS
. /root/.packages/PKGS_MANAGEMENT #has PKG_REPOS_ENABLED, PKG_NAME_ALIASES

tmpDIR=/tmp/petget
test -d "$tmpDIR" || mkdir -p "$tmpDIR"

#finds all user-installed pkgs and formats ready for display...
/usr/local/petget/finduserinstalledpkgs.sh #writes to "$tmpDIR"/installedpkgs.results

#process name aliases into patterns (used in filterpkgs.sh, findmissingpkgs.sh) ...
xPKG_NAME_ALIASES=`echo "$PKG_NAME_ALIASES" | tr ' ' '\n' | sed -e 's%^%|%' -e 's%$%|%' -e 's%,%|,|%g' -e 's%\\*%.*%g'  | tr '\n' ' ' | tr -s ' ' | tr ' ' '\n'`
echo "$xPKG_NAME_ALIASES" > "$tmpDIR"/petget_pkg_name_aliases_patterns

#w480 PKG_NAME_IGNORE is definedin PKGS_MANAGEMENT file...
xPKG_NAME_IGNORE=`echo "$PKG_NAME_IGNORE" | tr ' ' '\n' | sed -e 's%^%|%' -e 's%$%|%' -e 's%,%|,|%g' -e 's%\\*%.*%g'  | tr '\n' ' ' | tr -s ' ' | tr ' ' '\n'`
echo "$xPKG_NAME_IGNORE" > "$tmpDIR"/petget_pkg_name_ignore_patterns

repocnt=0
COMPAT_REPO=""
COMPAT_DBS=""
echo -n "" > "$tmpDIR"/petget_active_repo_list
if [ "$DISTRO_BINARY_COMPAT" != "puppy" ];then #w477 if compat-distro is puppy, bypass.
 for ONE_DB in `ls -1 /root/.packages/Packages-${DISTRO_BINARY_COMPAT}-${DISTRO_COMPAT_VERSION}*`
 do
  BASEREPO=`basename $ONE_DB`
  bPATTERN=' '"$BASEREPO"' '
  [ "`echo -n "$PKG_REPOS_ENABLED" | grep "$bPATTERN"`" = "" ] && continue
  repocnt=`expr $repocnt + 1`
  COMPAT_REPO=`echo -n "$ONE_DB" | rev | cut -f 1 -d '/' | rev | cut -f 2-4 -d '-'`
  COMPAT_DBS="${COMPAT_DBS} <radiobutton><label>${COMPAT_REPO}</label><action>$tmpDIR/filterversion.sh ${COMPAT_REPO}</action><action>/usr/local/petget/filterpkgs.sh</action><action>refresh:TREE1</action></radiobutton>"
  echo "${COMPAT_REPO}" >> "$tmpDIR"/petget_active_repo_list #read in findnames.sh
  #[ $repocnt = 1 ] && FIRST_DB="$COMPAT_REPO"
 done
fi

xrepocnt=$repocnt #w476
PUPPY_DBS=""
for ONE_DB in `ls -1 /root/.packages/Packages-puppy* | sort -r`
do
 BASEREPO=`basename $ONE_DB`
 bPATTERN=' '"$BASEREPO"' '
 [ "`echo -n "$PKG_REPOS_ENABLED" | grep "$bPATTERN"`" = "" ] && continue
 PUPPY_REPO=`echo -n "$ONE_DB" | rev | cut -f 1 -d '/' | rev | cut -f 2-4 -d '-'`
 #chop size of label down a bit, to fit in 800x600 window...
 PUPPY_REPO_CUT=`echo -n "$ONE_DB" | rev | cut -f 1 -d '/' | rev | cut -f 2,3 -d '-'`
 PUPPY_REPO_FULL=`echo -n "$ONE_DB" | rev | cut -f 1 -d '/' | rev | cut -f 2-9 -d '-'`
 PUPPY_DBS="${PUPPY_DBS} <radiobutton><label>${PUPPY_REPO_CUT}</label><action>$tmpDIR/filterversion.sh ${PUPPY_REPO_FULL}</action><action>/usr/local/petget/filterpkgs.sh</action><action>refresh:TREE1</action></radiobutton>"
 echo "${PUPPY_REPO}" >> "$tmpDIR"/petget_active_repo_list #read in findnames.sh
 [ $repocnt = $xrepocnt ] && FIRST_DB="$PUPPY_REPO" #w476
 repocnt=`expr $repocnt + 1`
done

FILTER_CATEG="Desktop"
#note, cannot initialise radio buttons in gtkdialog...
echo "Desktop" > "$tmpDIR"/petget_filtercategory #must start with Desktop.
echo "$FIRST_DB" > "$tmpDIR"/petget_filterversion #ex: slackware-12.2-official

#if [ "$DISTRO_BINARY_COMPAT" = "ubuntu" -o "$DISTRO_BINARY_COMPAT" = "debian" ];then
if [ 0 -eq 1 ];then #w020 disable this choice.
 #filter pkgs by first letter, for more speed. must start with ab...
 echo "ab" > "$tmpDIR"/petget_pkg_first_char
 FIRSTCHARS="
<radiobutton><label>a,b</label><action>echo ab > $tmpDIR/petget_pkg_first_char</action><action>/usr/local/petget/filterpkgs.sh</action><action>refresh:TREE1</action></radiobutton>
<radiobutton><label>c,d</label><action>echo cd > $tmpDIR/petget_pkg_first_char</action><action>/usr/local/petget/filterpkgs.sh</action><action>refresh:TREE1</action></radiobutton>
<radiobutton><label>e,f</label><action>echo ef > $tmpDIR/petget_pkg_first_char</action><action>/usr/local/petget/filterpkgs.sh</action><action>refresh:TREE1</action></radiobutton>
<radiobutton><label>g,h</label><action>echo gh > $tmpDIR/petget_pkg_first_char</action><action>/usr/local/petget/filterpkgs.sh</action><action>refresh:TREE1</action></radiobutton>
<radiobutton><label>i,j</label><action>echo ij > $tmpDIR/petget_pkg_first_char</action><action>/usr/local/petget/filterpkgs.sh</action><action>refresh:TREE1</action></radiobutton>
<radiobutton><label>k,l</label><action>echo kl > $tmpDIR/petget_pkg_first_char</action><action>/usr/local/petget/filterpkgs.sh</action><action>refresh:TREE1</action></radiobutton>
<radiobutton><label>m,n</label><action>echo mn > $tmpDIR/petget_pkg_first_char</action><action>/usr/local/petget/filterpkgs.sh</action><action>refresh:TREE1</action></radiobutton>
<radiobutton><label>o,p</label><action>echo op > $tmpDIR/petget_pkg_first_char</action><action>/usr/local/petget/filterpkgs.sh</action><action>refresh:TREE1</action></radiobutton>
<radiobutton><label>q,r</label><action>echo qr > $tmpDIR/petget_pkg_first_char</action><action>/usr/local/petget/filterpkgs.sh</action><action>refresh:TREE1</action></radiobutton>
<radiobutton><label>s,t</label><action>echo st > $tmpDIR/petget_pkg_first_char</action><action>/usr/local/petget/filterpkgs.sh</action><action>refresh:TREE1</action></radiobutton>
<radiobutton><label>u,v</label><action>echo uv > $tmpDIR/petget_pkg_first_char</action><action>/usr/local/petget/filterpkgs.sh</action><action>refresh:TREE1</action></radiobutton>
<radiobutton><label>w,x</label><action>echo wx > $tmpDIR/petget_pkg_first_char</action><action>/usr/local/petget/filterpkgs.sh</action><action>refresh:TREE1</action></radiobutton>
<radiobutton><label>y,z</label><action>echo yz > $tmpDIR/petget_pkg_first_char</action><action>/usr/local/petget/filterpkgs.sh</action><action>refresh:TREE1</action></radiobutton>
<radiobutton><label>0-9</label><action>echo 0123456789 > $tmpDIR/petget_pkg_first_char</action><action>/usr/local/petget/filterpkgs.sh</action><action>refresh:TREE1</action></radiobutton>
<radiobutton><label>ALL</label><action>echo ALL > $tmpDIR/petget_pkg_first_char</action><action>/usr/local/petget/filterpkgs.sh</action><action>refresh:TREE1</action></radiobutton>
"
 xFIRSTCHARS="<hbox>
${FIRSTCHARS}
</hbox>"
else
 #do not dispay the alphabetic radiobuttons...
 echo "ALL" > "$tmpDIR"/petget_pkg_first_char
 FIRSTCHARS=""
 xFIRSTCHARS=""
fi

#finds pkgs in repository based on filter category and version and formats ready for display...
/usr/local/petget/filterpkgs.sh $FILTER_CATEG #writes to "$tmpDIR"/filterpkgs.results

echo '#!/bin/bash
echo $1 > "$tmpDIR"/petget_filterversion
' > "$tmpDIR"/filterversion.sh
chmod 777 "$tmpDIR"/filterversion.sh

#  <text use-markup=\"true\"><label>\"<b>To install or uninstall,</b>\"</label></text>

ALLCATEGORY=''
if [ "$DISTRO_BINARY_COMPAT" = "puppy" ];then #v424 reintroduce the 'ALL' category.
 ALLCATEGORY='<radiobutton><label>ALL</label><action>/usr/local/petget/filterpkgs.sh ALL</action><action>refresh:TREE1</action></radiobutton>'
fi

#w476 reverse COMPAT_DBS, PUPPY_DBS...
export MAIN_DIALOG="<window title=\"Puppy Package Manager\" icon-name=\"gtk-about\">

<vbox>
 <hbox>
  <text><label>Repo:</label></text>
  ${PUPPY_DBS}
  ${COMPAT_DBS}
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
    <input>cat $tmpDIR/filterpkgs.results</input>
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
    <input>cat $tmpDIR/installedpkgs.results</input>
    <action signal=\"button-release-event\">/usr/local/petget/removepreview.sh</action>
    <action signal=\"button-release-event\">/usr/local/petget/finduserinstalledpkgs.sh</action>
    <action signal=\"button-release-event\">refresh:TREE2</action>
  </tree>
 </frame>
</hbox>
</vbox>
</window>
"

RETPARAMS=`gtkdialog3 --program=MAIN_DIALOG`

#eval "$RETPARAMS"
echo "$0: END" >&2
###END###
