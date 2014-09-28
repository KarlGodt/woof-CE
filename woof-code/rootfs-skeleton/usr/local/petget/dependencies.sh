#!/bin/sh
# Called from /usr/local/petget/installpreview.sh
# "$tmpDIR"/petget_installpreview_pkgname (writen in installpreview.sh) has name of package being
# previewed prior to installation. ex: abiword-1.2.3
# "$tmpDIR"/petget_filterversion has the repository that installing from (written in pkgchooser.sh).
# ex: slackware-12.2-slacky
# ...full package database file is /root/.packages/Packages-slackware-12.2-slacky
# "$tmpDIR"/petget_missingpkgs_patterns (written in findmissingpkgs.sh) has a list of missing dependencies, format ex:
#  |kdebase|
#  |kdelibs|
#  |mesa-lib|
#  |qt|
# ...that is, pkg name-only with vertical-bars on both ends, one name per line.
# "$tmpDIR"/petget_installed_patterns_all (writen in findmissingpkgs.sh) has a list of already installed
#  packages, both builtin and user-installed. One on each line, exs:
#  |915resolution|
#  |a52dec|
#  |absvolume_puppy|
#  |alsa\-lib|
#  |cyrus\-sasl|
# ...notice the '-' are backslashed.

_TITLE_=dependencies_check_two
_COMMENT_="Check for missing dependencies."

MY_SELF="$0"

test -f /etc/rc.d/f4puppy5 && {
[ "$HAVE_F4PUPPY5" ] || source /etc/rc.d/f4puppy5

ADD_PARAMETER_LIST=""
ADD_PARAMETERS=""
_provide_basic_parameters

TWO_HELP=''; TWO_VERSION=''; TWO_VERBOSE=''; TWO_DEBUG=''; ## Set to anything if code requires further down (ie. custom usage or version message)
ADD_HELP_MSG="Helper script for PPM .
$_COMMENT_"
_parse_basic_parameters "$@"
[ "$DO_SHIFT" ] && [ ! "${DO_SHIFT//[[:digit:]]/}" ] && {
    for i in `seq 1 1 $DO_SHIFT`; do shift; done; }
_trap
}

echo "$0: START" >&2

OUT=/dev/null;ERR=$OUT
[ "$DEBUG" ] && { OUT=/dev/stdout;ERR=/dev/stderr; }

. /root/.packages/PKGS_MANAGEMENT #has DISTRO_PPM_DEVX_EXCEPTIONS, PKG_ALIASES_INSTALLED

#a problem is that the dependencies may have their own dependencies. Some pkg
#databases have all dependencies up-front, whereas some only list the higher-level
#dependencies and the dependencies of those have to be looked for.

yaf-splash -font "8x16" -outline 0 -margin 4 -bg orange -text "Please wait, processing package database files..." &
X1PID=$!

tmpDIR=/tmp/petget
test -d "$tmpDIR" || mkdir -p "$tmpDIR"

ALLINSTALLEDPKGS="`cat "$tmpDIR"/petget_installed_patterns_all`"
TREE1="`cat "$tmpDIR"/petget_installpreview_pkgname`"

#this is the db of the main pkg...
DB_MAIN="/root/.packages/Packages-`cat "$tmpDIR"/petget_filterversion`" #ex: Packages-slackware-12.2-official
#...should have first preference when looking for dependencies...
DB_OTHERS="`ls -1 /root/.packages/Packages-* | grep -v "$DB_MAIN"`"
#if DB_MAIN is puppy-4, puppy-3 or puppy-2, then only look in those...
if [ "`echo "$DB_MAIN" | grep '\\-puppy\\-2'`" != "" ];then
 DB_OTHERS="`echo "$DB_OTHERS" | grep '\\-puppy\\-2'`"
else
 if [ "`echo "$DB_MAIN" | grep '\\-puppy\\-3'`" != "" ];then
  DB_OTHERS="`echo "$DB_OTHERS" | grep '\\-puppy\\-3'`"
 else
  if [ "`echo "$DB_MAIN" | grep '\\-puppy\\-4'`" != "" ];then
   DB_OTHERS="`echo "$DB_OTHERS" | grep '\\-puppy\\-4'`"
  else
   #do not look in puppy-2, puppy-3 or puppy-4...
   DB_OTHERS="`echo "$DB_OTHERS" | grep -v '\\-puppy\\-[234]'`"
  fi
 fi
fi
DB_OTHERS="`echo "$DB_OTHERS" | tr '\n' ' '`"

#the question is, how deep to search for deps? i'll go down 2 levels... make it 3...
cp -f "$tmpDIR"/petget_missingpkgs_patterns "$tmpDIR"/petget_missingpkgs_patternsx
echo "HIERARCHY OF MISSING DEPENDENCIES OF PACKAGE $TREE1" > "$tmpDIR"/petget_deps_visualtreelog #w017
echo "Format of each line: 'a-missing-dependent-pkg: missing dependencies of a-missing-dependent-pkg'" >> "$tmpDIR"/petget_deps_visualtreelog #w017
for oneLEVEL in 1 2 3
do
 echo "" >> "$tmpDIR"/petget_deps_visualtreelog #w017
 echo -n "" > "$tmpDIR"/petget_missingpkgs_patterns2
 for depPATTERN in `cat "$tmpDIR"/petget_missingpkgs_patternsx`
 do
  oneDEP="`echo -n "$depPATTERN" | sed -e 's%|%%g'`" #convert to exact name, ex: abiword
  depPATTERN="`echo -n "$depPATTERN" | sed -e 's%\\-%\\\\-%g'`" #backslash '-'
  #find database entry for this package...
  for oneDB in $DB_MAIN $DB_OTHERS
  do
   DB_dependencies="`cat $oneDB | cut -f 1,2,9 -d '|' | grep "$depPATTERN" | cut -f 3 -d '|' | head -n 1 | sed -e 's%,$%%'`"
   if [ "$DB_dependencies" != "" ];then
    ALLDEPS_PATTERNS="`echo -n "$DB_dependencies" | tr ',' '\n' | grep '^+' | sed -e 's%^+%%' -e 's%$%|%' -e 's%^%|%'`" #put '|' on each end.
    echo "$ALLDEPS_PATTERNS" > "$tmpDIR"/petget_subpkg_deps_patterns
    MISSINGDEPS_PATTERNS="`grep --file="$tmpDIR"/petget_installed_patterns_all -v "$tmpDIR"/petget_subpkg_deps_patterns`"
    echo "$MISSINGDEPS_PATTERNS" >> "$tmpDIR"/petget_missingpkgs_patterns2
    #w017 log a visual tree...
    MISSDEPSLIST="`echo "$MISSINGDEPS_PATTERNS" | sed -e 's%|%%g' | tr '\n' ' '`"
    case $oneLEVEL in
     1)
      echo "$oneDEP: $MISSDEPSLIST" >> "$tmpDIR"/petget_deps_visualtreelog
     ;;
     2)
      echo "    $oneDEP: $MISSDEPSLIST" >> "$tmpDIR"/petget_deps_visualtreelog
     ;;
     3)
      echo "        $oneDEP: $MISSDEPSLIST" >> "$tmpDIR"/petget_deps_visualtreelog
     ;;
    esac
    break
   fi
  done
 done
 sort -u "$tmpDIR"/petget_missingpkgs_patterns2 > "$tmpDIR"/petget_missingpkgs_patternsx
 cat "$tmpDIR"/petget_missingpkgs_patternsx >> "$tmpDIR"/petget_missingpkgs_patterns #accumulate them.
done
sort -u "$tmpDIR"/petget_missingpkgs_patterns > "$tmpDIR"/petget_missingpkgs_patternsx
mv -f "$tmpDIR"/petget_missingpkgs_patternsx "$tmpDIR"/petget_missingpkgs_patterns

#now find the entries in the databases...
rm -f "$tmpDIR"/petget_missing_dbentries* 2>$OUT
for depPATTERN in `cat "$tmpDIR"/petget_missingpkgs_patterns`
do
 depPATTERN="`echo -n "$depPATTERN" | sed -e 's%\\-%\\\\-%g'`" #backslash '-'.
 for oneREPODB in $DB_MAIN $DB_OTHERS
 do
  DBFILE="`basename $oneREPODB`" #ex: Packages-slackware-12.2-official
  #find database entry(s) for this package...
  DB_ENTRY="`cat $oneREPODB | grep "$depPATTERN"`"
  if [ "$DB_ENTRY" != "" ];then
   echo "$DB_ENTRY" >> "$tmpDIR"/petget_missing_dbentries-${DBFILE}-2
   break
  fi
 done
done
#clean them up...
for oneREPODB in $DB_MAIN $DB_OTHERS
do
 DBFILE="`basename $oneREPODB`" #ex: Packages-slackware-12.2-official
 if [ -f "$tmpDIR"/petget_missing_dbentries-${DBFILE}-2 ];then
  sort -u "$tmpDIR"/petget_missing_dbentries-${DBFILE}-2 > "$tmpDIR"/petget_missing_dbentries-${DBFILE}
  rm -f "$tmpDIR"/petget_missing_dbentries-${DBFILE}-2
 fi
done

kill $X1PID
echo "$0: END" >&2
###END###

