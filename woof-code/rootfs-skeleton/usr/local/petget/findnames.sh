#!/bin/sh
#
# New header by Karl Reimer Godt, September 2014

  _TITLE_="Puppy_findnames.sh"
_VERSION_=1.0omega
_COMMENT_="$_TITLE_:Puppy Linux shell script [to TODO here]"

MY_SELF="/usr/local/petget/findnames.sh"
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
# Called from /usr/local/petget/pkg_chooser.sh
# ENTRY1 is a string, to search for a package.

__old_default_info_header__(){
_TITLE_=find_packages
_COMMENT_="CLI Search Engine for PPM"

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

. /etc/DISTRO_SPECS                 #has DISTRO_BINARY_COMPAT, DISTRO_COMPAT_VERSION
. /root/.packages/DISTRO_PKGS_SPECS #has PKGS_SPECS_TABLE.
. /root/.packages/DISTRO_PET_REPOS  #has PET_REPOS, PACKAGELISTS_PET_ORDER

tmpDIR=/tmp/petget
test -d "$tmpDIR" || mkdir -p "$tmpDIR"

entryPATTERN='^'"`echo -n "$ENTRY1" | sed -e 's%\\-%\\\\-%g' -e 's%\\.%\\\\.%g' -e 's%\\*%.*%'`"
CURRENTREPO=`cat "$tmpDIR"/petget_filterversion` #search here first.
REPOLIST="${CURRENTREPO} `cat "$tmpDIR"/petget_active_repo_list | grep -v "$CURRENTREPO"`"
FNDIT=no

for oneREPO in $REPOLIST
do
 FNDENTRIES=`cat /root/.packages/Packages-${oneREPO} | grep "$entryPATTERN"`

 if [ "$FNDENTRIES" != "" ];then
  FIRSTCHAR=`echo "$FNDENTRIES" | cut -c 1 | tr '\n' ' ' | sed -e 's% %%g'`

  #write these just in case needed...
  ALPHAPRE=`cat "$tmpDIR"/petget_pkg_first_char`

  #if [ "$ALPHAPRE" != "ALL" ];then
  # echo "$FIRSTCHAR" > "$tmpDIR"/petget_pkg_first_char
  #fi

  #echo "ALL" > "$tmpDIR"/petget_filtercategory
  echo "$oneREPO" > "$tmpDIR"/petget_filterversion #ex: slackware-12.2-official

  #this is read when update TREE1 in pkg_chooser.sh...
  echo "$FNDENTRIES" | cut -f 1,10 -d '|' > "$tmpDIR"/filterpkgs.results
  FNDIT=yes
  break

 fi

done

[ "$FNDIT" = "no" ] && xmessage -bg red -center -title "PPM find" "Sorry, no matching package name"
echo "$0: END" >&2

