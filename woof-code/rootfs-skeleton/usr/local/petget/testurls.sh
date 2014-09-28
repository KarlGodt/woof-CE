#!/bin/sh
# Called from /usr/local/petget/downloadpkgs.sh
# "$tmpDIR"/petget_repos has the list of repos, each line in this format:
# repository.slacky.eu|http://repository.slacky.eu/slackware-12.2|Packages-slackware-12.2-slacky
# ...only the first field is of interest in this script.

  _TITLE_=testurls
_COMMENT_="wget test for entries in petget_repos file"

MY_SELF="$0"

test -f /etc/rc.d/f4puppy5 && {
source /etc/rc.d/f4puppy5

ADD_PARAMETER_LIST=""
ADD_PARAMETERS=""
_provide_basic_parameters

TWO_HELP=''; TWO_VERSION=''; TWO_VERBOSE=''; TWO_DEBUG=''; ## Set to anything if code requires further down (ie. custom usage or version message)
ADD_HELP_MSG="Helper script for PPM ."
_parse_basic_parameters "$@"
[ "$DO_SHIFT" ] && [ ! "${DO_SHIFT//[[:digit:]]/}" ] && {
    for i in `seq 1 1 $DO_SHIFT`; do shift; done; }
_trap
}

echo "$0: START" >&2

[ "$ERR" ] || ERR=/dev/null
tmpDIR=/tmp/petget
test -d "$tmpDIR" || mkdir -p "$tmpDIR"

echo '#!/bin/sh' >  "$tmpDIR"/petget_urltest
echo 'echo "Testing the URLs:"' >>  "$tmpDIR"/petget_urltest

for ONEURLSPEC in `cat "$tmpDIR"/petget_repos`
do
 URL_TEST="`echo -n "$ONEURLSPEC" | cut -f 1 -d '|'`"

 #[ "`wget -t 2 -T 20 --waitretry=20 --spider -S $ONE_PET_SITE -o /dev/stdout 2>$ERR | grep '200 OK'`" != "" ]

 echo 'echo' >> "$tmpDIR"/petget_urltest
 echo "wget -t 2 -T 20 --waitretry=20 --spider -S $URL_TEST" >> "$tmpDIR"/petget_urltest

done

echo 'echo "
TESTING FINISHED
Read the above, any that returned \"200 OK\" succeeded."' >>  "$tmpDIR"/petget_urltest
echo 'echo -n "Press ENTER key to exit: "
read ENDIT_'  >>  "$tmpDIR"/petget_urltest

chmod 777 "$tmpDIR"/petget_urltest
rxvt -title "Puppy Package Manager: download" -bg orange -fg black -e "$tmpDIR"/petget_urltest
echo "$0: END" >&2
###END###
