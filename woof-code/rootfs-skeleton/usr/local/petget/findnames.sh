#!/bin/sh
#
# New header by Karl Reimer Godt, September 2014
  _TITLE_="Puppy_findnames.sh"
_VERSION_=1.0omega
_COMMENT_="$_TITLE_:Puppy Linux shell script [to TODO here]"

MY_SELF="/usr/local/petget/findnames.sh"
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
#called from /usr/local/petget/pkg_chooser.sh
#  ENTRY1 is a string, to search for a package.

. /etc/DISTRO_SPECS #has DISTRO_BINARY_COMPAT, DISTRO_COMPAT_VERSION
. /root/.packages/DISTRO_PKGS_SPECS #has PKGS_SPECS_TABLE.
. /root/.packages/DISTRO_PET_REPOS #has PET_REPOS, PACKAGELISTS_PET_ORDER

entryPATTERN='^'"`echo -n "$ENTRY1" | sed -e 's%\\-%\\\\-%g' -e 's%\\.%\\\\.%g' -e 's%\\*%.*%'`"

CURRENTREPO="`cat /tmp/PetGet/petget_filterversion`" #search here first.
REPOLIST="${CURRENTREPO} `cat /tmp/PetGet/petget_active_repo_list | grep -v "$CURRENTREPO" | tr '\n' ' '`"

FNDIT=no
for ONEREPO in $REPOLIST
do
 FNDENTRIES="`cat /root/.packages/Packages-${ONEREPO} | grep "$entryPATTERN"`"
 if [ "$FNDENTRIES" != "" ];then
  FIRSTCHAR="`echo "$FNDENTRIES" | cut -c 1 | tr '\n' ' ' | sed -e 's% %%g'`"
  #write these just in case needed...
  ALPHAPRE="`cat /tmp/PetGet/petget_pkg_first_char`"
  #if [ "$ALPHAPRE" != "ALL" ];then
  # echo "$FIRSTCHAR" > /tmp/PetGet/petget_pkg_first_char
  #fi
  #echo "ALL" > /tmp/PetGet/petget_filtercategory
  echo "$ONEREPO" > /tmp/PetGet/petget_filterversion #ex: slackware-12.2-official
  #this is read when update TREE1 in pkg_chooser.sh...
  echo "$FNDENTRIES" | cut -f 1,10 -d '|' > /tmp/PetGet/filterpkgs.results
  FNDIT=yes
  break
 fi
done

[ "$FNDIT" = "no" ] && xmessage -bg red -center -title "PPM find" "Sorry, no matching package name"

# Very End of this file 'usr/local/petget/findnames.sh' #
###END###
