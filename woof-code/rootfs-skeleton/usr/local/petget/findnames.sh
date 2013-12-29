#!/bin/sh
#(c) Copyright Barry Kauler 2009, puppylinux.com
#2009 Lesser GPL licence v2 (http://www.fsf.org/licensing/licenses/lgpl.html).
#called from /usr/local/petget/pkg_chooser.sh
#  ENTRY1 is a string, to search for a package.



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

OUT=/dev/null;ERR=$OUT
[ "$DEBUG" ] && { OUT=/dev/stdout;ERR=/dev/stderr; }

. /etc/DISTRO_SPECS #has DISTRO_BINARY_COMPAT, DISTRO_COMPAT_VERSION
. /root/.packages/DISTRO_PKGS_SPECS #has PKGS_SPECS_TABLE.
. /root/.packages/DISTRO_PET_REPOS #has PET_REPOS, PACKAGELISTS_PET_ORDER

entryPATTERN='^'"`echo -n "$ENTRY1" | sed -e 's%\\-%\\\\-%g' -e 's%\\.%\\\\.%g' -e 's%\\*%.*%'`"

CURRENTREPO=`cat /tmp/petget_filterversion` #search here first.
REPOLIST="${CURRENTREPO} `cat /tmp/petget_active_repo_list | grep -v "$CURRENTREPO" | tr '\n' ' '`"

FNDIT=no
for ONEREPO in $REPOLIST
do
 FNDENTRIES=`cat /root/.packages/Packages-${ONEREPO} | grep "$entryPATTERN"`
 if [ "$FNDENTRIES" != "" ];then
  FIRSTCHAR=`echo "$FNDENTRIES" | cut -c 1 | tr '\n' ' ' | sed -e 's% %%g'`
  #write these just in case needed...
  ALPHAPRE=`cat /tmp/petget_pkg_first_char`
  #if [ "$ALPHAPRE" != "ALL" ];then
  # echo "$FIRSTCHAR" > /tmp/petget_pkg_first_char
  #fi
  #echo "ALL" > /tmp/petget_filtercategory
  echo "$ONEREPO" > /tmp/petget_filterversion #ex: slackware-12.2-official
  #this is read when update TREE1 in pkg_chooser.sh...
  echo "$FNDENTRIES" | cut -f 1,10 -d '|' > /tmp/filterpkgs.results
  FNDIT=yes
  break
 fi
done

[ "$FNDIT" = "no" ] && xmessage -bg red -center -title "PPM find" "Sorry, no matching package name"

echo "$0: END" >&2
