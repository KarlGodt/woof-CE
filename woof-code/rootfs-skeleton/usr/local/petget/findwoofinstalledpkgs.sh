#!/bin/sh
#(c) Copyright Barry Kauler 2009, puppylinux.com
#2009 Lesser GPL licence v2 (http://www.fsf.org/licensing/licenses/lgpl.html).
#this script finds all builtin packages in Puppy Linux.
#designed to work in a running Puppy that has been built by Woof.
#writes to /root/.packages/woof-installed-packages
#100331 bad hack for t2 8.0rc/8.0rcXorg7.3 variants. 100412 removed.
#100622 hack for pet search.
#100801 some common code extracted to file inline_get_pet.

export LANG=C

. /etc/DISTRO_SPECS #has DISTRO_BINARY_COMPAT, DISTRO_COMPAT_VERSION
. /root/.packages/DISTRO_PKGS_SPECS #has PKGS_SPECS_TABLE, FALLBACKS_COMPAT_VERSIONS
. /root/.packages/DISTRO_PET_REPOS #has PET_REPOS, PACKAGELISTS_PET_ORDER
. /root/.packages/DISTRO_COMPAT_REPOS #v431 has PKG_DOCS_DISTRO_COMPAT

#PKGS_SPECS_TABLE variable lists all builtin packages, however it is in a
#somewhat truncated format. What we need to do is find out the exact database
#entries of installed pkgs and what repo they came from. Which is what this script does.
#the basic structure of this script is similar to '2createpackages' in Woof.

#w469 modify compat-distro fallback list...
if [ "$FALLBACKS_COMPAT_VERSIONS" != "" ];then
 FALLBACKS_COMPAT_VERSIONS="`echo -n "$FALLBACKS_COMPAT_VERSIONS" | grep -o "${DISTRO_COMPAT_VERSION}.*"`"
 #ex: 'koala jaunty intrepid' gets reduced to 'jaunty intrepid' if DISTRO_COMPAT_VERSION=jaunty
fi

#w469 refer to file DISTRO_PET_REPOS...
PACKAGELISTS_PET_PRIMARY="`echo -n "$PACKAGELISTS_PET_ORDER" | cut -f 1 -d ' '`"
PACKAGELISTS_PET_LAST="`echo -n "$PACKAGELISTS_PET_ORDER" | tr ' ' '\n' | tail -n 1`"

PKGLISTS_PET="`ls -1 /root/.packages/Packages-puppy-* | sed -e 's%/root/\\.packages/%%' | tr '\n' ' '`"
#if [ "$DISTRO_BINARY_COMPAT" = "puppy" ];then #w477
# #need to narrow it down to the specific database file for this puppy-puppy build...
# PKGLISTS_COMPAT="`ls -1 /root/.packages/Packages-${DISTRO_BINARY_COMPAT}-${DISTRO_COMPAT_VERSION}-* | sed -e 's%/root/\\.packages/%%' | tr '\n' ' '`"
#else
# PKGLISTS_COMPAT="`ls -1 /root/.packages/Packages-${DISTRO_BINARY_COMPAT}-* | sed -e 's%/root/\\.packages/%%' | tr '\n' ' '`"
#fi
#w477 no, find database files as done in 1download and 2createpackages...
PKGLISTS_COMPAT="`echo "$PKG_DOCS_DISTRO_COMPAT" | tr ' ' '\n' | cut -f 3 -d '|' | tr '\n' ' '`" #see file DISTRO_PKGS_SPECS-ubuntu

#w480 if a Ppup (compat-distro is a version of puppy) then there is only one entry in PKGLISTS_COMPAT,
#and do not want it to stay there to avoid confusion. Ex for puppy4: Packages-puppy-4xx-official
PUP_PKGLIST_COMPAT=""
if [ "$DISTRO_BINARY_COMPAT" = "puppy" ];then
 num_pkglists_compat=`echo -n "$PKGLISTS_COMPAT" | wc -w`
 if [ $num_pkglists_compat -eq 1 ];then
  PUP_PKGLIST_COMPAT="$PKGLISTS_COMPAT"
  #this script is first called from 3builddistro and it builds woof-installed-packages file,
  #then deletes $PUP_PKGLIST_COMPAT (to avoid user confusion). If this script is run again
  #from a runnng puppy, create a partial $PUP_PKGLIST_COMPAT by the reverse copy...
  [ ! -f /root/.packages/$PUP_PKGLIST_COMPAT ] && cp -f /root/.packages/woof-installed-packages /root/.packages/$PUP_PKGLIST_COMPAT
 fi
fi

#...ex: Packages-slackware-12.2-official Packages-slackware-12.2-slacky
#entries in these files have this format, last 3 fields are optional:
#pkgname|nameonly|version|pkgrelease|category|size|path|fullfilename|dependencies|description|compileddistro|compiledrelease|repo|
#...'compileddistro|compiledrelease' (fields 11,12) identify where the package was compiled.
#ex:
#bc-1.06.95|bc|1.06.95|1|BuildingBlock|240K|slackware/ap|bc-1.06.95-i486-1.tgz|+ncurses,+readline,+glibc|An arbitrary precision calculator language|
#ex last 3: slackware|12.2|official|

#note, fields 11,12,13 can be a bit tricky. 'slackware|12.2|slacky' is pretty straightforward,
#as there is /root/.packages/Packages-slackware-12.2-slacky, so you can see stright off what
#repo the pkg comes from.
#however I do have entries in Packages-puppy-woof-official that look like this:
# 'slackware|12.2|woof' which actually means the pkg was compiled in a Slackware version
# 12.2 based build of Woof-Puppy, but the repo where the pkg is to be found is 'woof'.
# ...a script will have to examine the Packages-* files to see which one has 'woof' in its
#    name to determine the repo.

#remove comments from PKGS_SPECS_TABLE
PKGS_SPECS_TABLE="`echo "$PKGS_SPECS_TABLE" | grep -v '^#'`"
#PKGS_SPECS_TABLE table format:
#will pkg be in woof.
#    Generic name for pkg. Note: PET packages, if exist, use this name + version#.
#            Comma-separated list of ubuntu/debian part-names for pkg(s). '-' prefix, exclude.
#            Empty field, then use PET pkg.
#                    How the package will get split up in woof (optional redirection '>' operator).
#                    Missing field, it goes into exe. Can also redirect >null, means dump it.
#yes|abiword|iceword_|exe,dev,doc,nls

echo -n "" > /root/.packages/woof-installed-packages
cd /root/.packages

for ONEPKGSPEC in $PKGS_SPECS_TABLE
do
 [ "$ONEPKGSPEC" = "" ] && continue
 YESNO="`echo "$ONEPKGSPEC" | cut -f 1 -d '|'`"
 [ "$YESNO" = "no" ] && continue
 GENERICNAME="`echo "$ONEPKGSPEC" | cut -f 2 -d '|'`"
 BINARYPARTNAMES="`echo "$ONEPKGSPEC" | cut -f 3 -d '|' | tr ',' ' '`"

 if [ "$BINARYPARTNAMES" = "" ];then
  #it's a pet pkg...
  
  #100801 common code extracted to a file...
  INLINE_PASSED1='findwoofinstalledpkgs.sh'
. /root/.packages/inline_get_pet

 else
 
  #100806 common code extracted to a file...
  INLINE_PASSED1='findwoofinstalledpkgs.sh'
. /root/.packages/inline_get_compat

 fi
 
done

#sort alphabetically...
sort --key=1 --field-separator="|" /root/.packages/woof-installed-packages > /tmp/PetGet/petget_woof-installed-packages
mv -f /tmp/PetGet/petget_woof-installed-packages /root/.packages/woof-installed-packages

#w480 original file only needed at first execution when called from 3builddistro...
if [ "$PUP_PKGLIST_COMPAT" != "" ];then #Ex: Packages-puppy-4xx-official
 #100814 only delete if has 'xx', want to keep Packages-puppy-wary5-official...
 [ "`echo "$PUP_PKGLIST_COMPAT" | grep 'xx'`" != "" ] && rm -f /root/.packages/$PUP_PKGLIST_COMPAT
fi

###END###

