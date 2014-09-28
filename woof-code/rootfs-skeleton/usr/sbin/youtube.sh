#!/bin/bash
#
# New header by Karl Reimer Godt, September 2014
  _TITLE_="Puppy_youtube.sh"
_VERSION_=1.0omega
_COMMENT_="$_TITLE_:Puppy Linux shell script [to TODO here]"

MY_SELF="/usr/sbin/youtube.sh"
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

# YouTube download script by John Lawrence (http://blog.johnlawrence.net)
#Modified for puppy by trio - 2009

use_err() {
  echo "Usage:   `basename $0` [-f savefile] video_id"
  echo "Example: `basename $0` -f Rick oHg5SJYRHA0"
  echo "         Saves video with id oHg5SJYRHA0 to Rick.flv in your current directory"
  echo
  exit 65
}

if [ ! "$1" ]; then use_err; fi

while getopts ":f:" Option
do
  case $Option in
    f     ) fn=$OPTARG;;
    *     ) use_err;;
  esac
done

shift $(($OPTIND - 1))

if [ -z "$1" ];  then use_err; fi
if [ -z "$fn" ]; then fn=$1; fi

vidID=$1
filename=$fn".mp4"
geturl() { echo "GET $1 HTTP/1.1";echo "Host: $2";echo;echo;sleep 2;echo '^C'; }

echo "Finding hostname"
hostl=`geturl /watch youtube.com | nc youtube.com 80 | grep Location | sed 's|Location: http://\([^/]*\)/.*|\1|' | tr -d '\r\n'`
echo "Connecting to "$hostl

watch="/watch?v="$vidID
tid=`geturl $watch $hostl | nc youtube.com 80 | grep '"t":' | sed 's/.*"t": "\([^"]*\)".*/\1/'`

echo "Locating video file"
get_video="/get_video?video_id="$vidID"&t="$tid"&el=detailpage&ps=&fmt=18"
url=`geturl $get_video $hostl | nc youtube.com 80 | grep Location | sed 's/Location: \(.*\)$/\1/' | tr -d '\r\n'`

wget -O - -t 7 -w 5 --waitretry=14 --random-wait '--user-agent=Mozilla/5.0' -e robots=off $url > "$filename"
# Very End of this file 'usr/sbin/youtube.sh' #
###END###
