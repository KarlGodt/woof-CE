#! /bin/sh
# #############################################################################

       NAME_="html2txt"
       HTML_="html to text"
    PURPOSE_="convert html file to ascii text; write the converted file to disk"
   SYNOPSIS_="$NAME_ [-vhmlr] <file> [file...]"
   REQUIRES_="standard GNU commands, lynx"
    VERSION_="1.1"
       DATE_="2004-04-18; last update: 2005-03-03"
     AUTHOR_="Dawid Michalczyk <dm@eonworks.com>"
        URL_="www.comp.eonworks.com"
   CATEGORY_="www"
   PLATFORM_="Linux"
      SHELL_="bash"
 DISTRIBUTE_="yes"

# #############################################################################
# This program is distributed under the terms of the GNU General Public License

usage () {

echo >&2 "$NAME_ $VERSION_ - $PURPOSE_
Usage: $SYNOPSIS_
Requires: $REQUIRES_
Options:
     -r,   remove input file after conversion
     -v,   verbose
     -h,   usage and options (help)
     -m,   manual
     -M,   see this scrip
     -l    use lynx to convert
     -e    use elinks to convert
-s/path/to name of source directory
-t/path/to name of target directory"
    if [ "$2" ];then
echo >&2 "
$2";fi
    exit $1
}

manual () { echo >&2 "

NAME

    $NAME_ $VERSION_ - $PURPOSE_

SYNOPSIS

    $SYNOPSIS_

DESCRIPTION

    $NAME_ converts ascii files with html content to plain text. It replaces the
    previous suffix, if any, with a \"txt\" suffix. It skips the following files:

    - binary files
    - directories
    - files that already have the same name as <input_file>.txt

    Option -r, removes the input file after conversion.

EXAMPLES

    Use find with xargs to run the script recursively on multiple files. For
    example, to convert all html files to text recursively:

    find . -name \"*.html\" | xargs $NAME_

AUTHOR

    $AUTHOR_ Suggestions and bug reports are welcome.
    For updates and more scripts visit $URL_

"; exit 1; }

# arg check
[ $# -eq 0 ] && { echo >&2 missing argument, type $NAME_ -h for help; exit 1; }

# var initializing
rm_html=
verbose=

# option and argument handling
#bash-3.2# help getopts
#getopts: getopts optstring name [arg]
#    Getopts is used by shell procedures to parse positional parameters.
#
#    OPTSTRING contains the option letters to be recognized; if a letter
#    is followed by a colon, the option is expected to have an argument,
#    which should be separated from it by white space.

#    Each time it is invoked, getopts will place the next option in the
#    shell variable $name, initializing name if it does not exist, and
#    the index of the next argument to be processed into the shell
#    variable OPTIND.  OPTIND is initialized to 1 each time the shell or
#    a shell script is invoked.  When an option requires an argument,
#    getopts places that argument into the shell variable OPTARG.

#    getopts reports errors in one of two ways.  If the first character
#    of OPTSTRING is a colon, getopts uses silent error reporting.  In
#    this mode, no error messages are printed.  If an invalid option is
#    seen, getopts places the option character found into OPTARG.  If a
#    required argument is not found, getopts places a ':' into NAME and
#    sets OPTARG to the option character found.  If getopts is not in
#    silent mode, and an invalid option is seen, getopts places '?' into
#    NAME and unsets OPTARG.  If a required argument is not found, a '?'
#    is placed in NAME, OPTARG is unset, and a diagnostic message is
#    printed.

#    If the shell variable OPTERR has the value 0, getopts disables the
#    printing of error messages, even if the first character of
#    OPTSTRING is not a colon.  OPTERR has the value 1 by default.

#    Getopts normally parses the positional parameters ($0 - $9), but if
#    more arguments are given, they are parsed instead.


echo "OPTERR='$OPTERR'"
while getopts vhmlrs:t: option; do
    echo "option='$option'
    \$1='$1'"
    #case $option in
    #t|s)
    #shift;;


    #esac
    echo "option='$option'
    \$1='$1'"
    echo "$OPTIND='$OPTIND'
    OPTARG='$OPTARG'"


    case $option in
        r) rm_html=on ;;
        v) verbose=on ;;
        h) usage ;;
        m) manual | more; exit 1 ;;
        M) more $0 ;;
        #s) shift;SOURCEDIR="$option";;
        #t) shift;TARGETDIR="$option";;
        s) SOURCEDIR="$OPTARG";;
        t) TARGETDIR="$OPTARG";;
        l) BIN='lynx' ;;
        e) BIN='elinks' ;;
       \?) echo invalid or missing argument, type $NAME_ -h for help; exit 1 ;;
    esac

done

shift $(( $OPTIND - 1 ))

echo "
SOURCEDIR='$SOURCEDIR'
TARGETDIR='$TARGETDIR'
"
#exit

# check if required command is in $PATH variable

if [ ! "$BIN" ];then
BIN='lynx'
BIN='elinks'
fi
DUMP='-dump'

#which lynx &> /dev/null
which $BIN &> /dev/null
[[ $? != 0 ]] && { echo >&2 the required \"l$BIN\" command is not in your PATH; exit 1; }
if [ ! "$SOURCEDIR" ];then
SOURCEDIR='.'
else
[ ! -e "$SOURCEDIR" ] && usage 1 "SOURCEDIR '$SOURCEDIR' does not exist"
[ ! -d "$SOURCEDIR" ] && usage 1 "SOURCEDIR '$SOURCEDIR' not a directory"
cd "$SOURCEDIR"
fi
if [ ! "$TARGETDIR" ];then
TARGETDIR='.'
fi
[ ! -e "$TARGETDIR" ] && usage 1 "TARGETDIR '$TARGETDIR' does not exist"
[ ! -d "$TARGETDIR" ] && usage 1 "TARGETDIR '$TARGETDIR' not a directory"
echo "
SOURCEDIR='$SOURCEDIR'
TARGETDIR='$TARGETDIR'
"
#exit

# main
FILESLIST="$@"
if [ ! "$FILESLIST" ];then
if [ ! -f "${TARGETDIR}/.files.db" ];then
echo "No filename given, assuming recursive
in '$SOURCEDIR'"
FILESLIST=`find "$SOURCEDIR" -type f ! -name ".txt" |sort -d`
NR=`echo "$FILESLIST" |wc -l`
echo "Found '$NR' files to convert ."
read -p "Continue ? " K
[ ! "$K" ] && K=y
case $K in
y|Y):;;
*) exit 0
esac
echo "$FILESLIST" > "${TARGETDIR}/.files.db"
else
#FILESLIST=`grep -vE ' CONVERTED| SKIPPED| CONVERTED SKIPPED' "${TARGETDIR}/.files.db"`
#FILESLIST=`grep -v 'CONVERTED' "${TARGETDIR}/.files.db"`
FILESLIST=`grep '\.html$' "${TARGETDIR}/.files.db"`
fi
fi

#for a in "$@"; do
for a in $FILESLIST; do
 echo $a
 b=`basename "$a"`
 #break
  ADD_DIR=`dirname "$a" |sed 's|^\.||'`
  echo "$ADD_DIR"
  #if [ "$ADD_DIR" ];then
  #if [ ! -e "$TARGETDIR" ];then
  #TARGETDIR="$TARGETDIR/$ADD_DIR"
  mkdir -p "${TARGETDIR}${ADD_DIR}"
  #fi;fi
    if [ ! -f $a ];then
    echo "File '$a' does not exist in this name here , skipping .."
    sedp0=`echo "$a" | sed 's,\([[:punct:]]\),\\\\\1,g'`
    echo  "$sedp0"
    sed -i "/$sedp0/s,\(.*\),\1 SKIPPED," "${TARGETDIR}/.files.db"
    sleep 1s
    continue
    fi
    #file $a
    file $a | grep -q text # testing if input file is an ascii file
    [ $? == 0 ] && is_text=0 || is_text=1

    if [ -f $a ] && [[ ${a#*.} != txt ]] && (( $is_text == 0 )); then

        if [ -f $TARGETDIR${ADD_DIR}/${b%.*}.txt ]; then
            echo ${NAME_}: skipping: ${TARGETDIR}${ADD_DIR}/${b%.*}.txt file already exist
            sedp0=`echo "$a" | sed 's,\([[:punct:]]\),\\\\\1,g'`
            sed -i "/$sedp0/s,\(.*\),\1 FOUND_ALREADY_CONVERTED," "${TARGETDIR}/.files.db"
            continue
        else
            [[ $verbose ]] && echo "${NAME_}: converting: $a -> ${TARGETDIR}${ADD_DIR}/${b%.*}.txt"
            #lynx -dump $a > ${a%.*}.txt
            $BIN $DUMP $a > ${TARGETDIR}${ADD_DIR}/${b%.*}.txt
            [[ $? == 0 ]] && stat=0 || stat=1
            [[ $stat == 0 ]] && [[ $verbose ]] && [[ $rm_html ]] && echo ${NAME_}: removing: $a
            [[ $stat == 0 ]] && [[ $rm_html ]] && rm -f -- $a
            sedp0=`echo "$a" | sed 's,\([[:punct:]]\),\\\\\1,g'`
            sed -i "/$sedp0/s,\(.*\),\1 CONVERTED," "${TARGETDIR}/.files.db"
            sleep 2s
        fi

    else

        [[ $is_text == 1 ]] && echo ${NAME_}: skipping: $a not an ascii file

    fi
#sleep 2s
done
