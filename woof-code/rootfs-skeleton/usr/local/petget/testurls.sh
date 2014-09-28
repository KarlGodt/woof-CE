#!/bin/sh
#
# New header by Karl Reimer Godt, September 2014
  _TITLE_="Puppy_testurls.sh"
_VERSION_=1.0omega
_COMMENT_="$_TITLE_:Puppy Linux shell script [to TODO here]"

MY_SELF="/usr/local/petget/testurls.sh"
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
#called from /usr/local/petget/downloadpkgs.sh
#/tmp/petget_repos has the list of repos, each line in this format:
#repository.slacky.eu|http://repository.slacky.eu/slackware-12.2|Packages-slackware-12.2-slacky
#...only the first field is of interest in this script.

echo "$0:$*" >&2

echo '#!/bin/sh' >  /tmp/petget_urltest
echo 'echo "Testing the URLs:"' >>  /tmp/petget_urltest

for ONEURLSPEC in `cat /tmp/petget_repos`
do
 URL_TEST="`echo -n "$ONEURLSPEC" | cut -f 1 -d '|'`"

 #[ "`wget -t 2 -T 20 --waitretry=20 --spider -S $ONE_PET_SITE -o /dev/stdout 2>/dev/null | grep '200 OK'`" != "" ]

 echo 'echo' >> /tmp/petget_urltest
 echo "wget -t 2 -T 20 --waitretry=20 --spider -S $URL_TEST" >> /tmp/petget_urltest

done

echo 'echo "
TESTING FINISHED
Read the above, any that returned \"200 OK\" succeeded."' >>  /tmp/petget_urltest
echo 'echo -n "Press ENTER key to exit: "
read ENDIT'  >>  /tmp/petget_urltest

chmod 777 /tmp/petget_urltest
rxvt -title "Puppy Package Manager: download" -bg orange -fg black -e /tmp/petget_urltest

###END###
