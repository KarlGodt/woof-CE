#!/bin/sh
#
# New header by Karl Reimer Godt, September 2014
  _TITLE_="Puppy_rtf2ps.sh"
_VERSION_=1.0omega
_COMMENT_="$_TITLE_:Puppy Linux shell script [to TODO here]"

MY_SELF="/usr/local/bin/rtf2ps.sh"
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

########################################################################
#
#  Convert an rtf document to PostScript format using 'Ted'.
#
#  Usage	rtf2ps.sh --paper paper something.rtf something.ps
#  Or		rtf2ps.sh something.rtf something.ps
#
#  Valid values for paper are a4, a5, a6, letter, legal and executive
#
#  This is an example. Refer to http://www.nllgg.nl/Ted/index.html for the
#  'Ted' documentation.
#
#  If you want 'Ted' to use X11 configurable resources, use
#  Ted ++printToFilePaper ... In conjuction with X11 resources, the 
#  standard X11 command line arguments to set resources can be practical. E.G:
#  Ted -xrm Ted.usePostScriptFilters:1 -xrm Ted.usePostScriptIndexedImages:1 
#	++printToFilePaper .....
#
########################################################################

PAPER=

case $# in
    2)
	;;
    4)
	case $1 in
	    --paper)
		;;
	    *)
		echo $0: '$1='$1 'Expected --paper'
		exit 1
		;;
	esac

	case $2 in
	    a4|a5|a6|letter|legal|executive)
		PAPER=$2
		;;
	    *)
		echo $0: '$2='$2 'Expected a4|a5|a6|letter|legal|executive'
		exit 1
		;;
	esac
	shift; shift;
	;;
    *)
	echo $0: '$#='$#
	exit 1
	;;
esac

case $PAPER in
    ?*)
	Ted --printToFilePaper $1 $2 $PAPER
	;;
    *)
	Ted --printToFile $1 $2
	;;
esac

# Very End of this file 'usr/local/bin/rtf2ps.sh' #
###END###
