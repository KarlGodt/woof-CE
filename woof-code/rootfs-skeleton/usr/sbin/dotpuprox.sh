#!/bin/sh

# dotpup handler 0.0.4 - GuestToo - Feb 24, 2007
# this is NOT a package management system

DPDIR=/root
CONFIG=/etc/dotpup

[ -z $1 ] && exit 1
export TEXTDOMAIN=dotpuprox
export TEXTDOMAINDIR=/usr/share/locale
export CONFIG
FNAME="`basename "$1"`"
FPATH="$1"
echo $FPATH | grep '^/' > /dev/null || FPATH="`pwd`/$1" # absolute path
which eval_gettext || alias eval_gettext='gettext'
MSG=`which gxmessage` || MSG=xmessage
[ -d $CONFIG ] || mkdir $CONFIG

# workaround for MU
if ! pidof xinit-dummy > /dev/null
then
  /usr/X11R6/bin/xinit-dummy &
fi

TITLE1="`eval_gettext "DotPup"`"
TITLE2="`eval_gettext "DotPup Error"`"

# ----- sanity check

if [ ! -d "$DPDIR" ]
then
  MSG1="`eval_gettext "ERROR!"`"
  $MSG -title "$TITLE2" -center "$MSG1
DPDIR=$DPDIR
dir does not exist"
  exit 2
fi

export DPDIR="$DPDIR/DotPupTmpDir"

if ! echo "$DPDIR" | grep '/DotPupTmpDir' > /dev/null
then
  MSG1="`eval_gettext "ERROR!"`"
  $MSG -title "$TITLE2" -center "$MSG1
DPDIR=$DPDIR"
  exit 3
fi

if [ ! -r "$FPATH" ]
then
  MSG1="`eval_gettext "File not found:"`"
  $MSG -center -title "$TITLE2" "$MSG1 $FNAME"
  exit 4
fi

# ----- test empty file

if [ ! -s "$FPATH" ]
then
  MSG1="`eval_gettext " Empty file - 0 bytes"`"
  $MSG -center -title "$TITLE2" "$MSG1 - $FNAME"
  exit 9
fi


# ----- test zip integrity

if ! unzip -t "$FPATH"
then
  MSG1="`eval_gettext "File integrity ERROR:"`"
  MSG2="`eval_gettext "Suggestion: Download the Pup file again."`"
  $MSG -center -title "$TITLE2" "$MSG1 $FNAME
$MSG2"
  exit 5
fi


# ----- unzip? y/n

if [ ! -r $CONFIG/always-unzip ]
then
  MSG2="`eval_gettext "File integrity is OK:"`"
  MSG3="`eval_gettext "Unzip the dotpup package?"`"
  MSG1="`eval_gettext "Unzip,Always,Cancel"`"
  $MSG -buttons "$MSG1" -center -title "$TITLE1"  "$MSG2 $FNAME
$MSG3"
  case $? in
    101) true ;;
    102) touch $CONFIG/always-unzip ;;
    *) exit ;;
  esac
fi


# ----- setup clean workspace

dotpuprmtmpdir
mkdir "$DPDIR"

# sanity check, is it writable?
echo 5514549 > "$DPDIR/t155145492.txt"
if ! grep 5514549 "$DPDIR/t155145492.txt"
then
  dotpuprmtmpdir
  MSG1="`eval_gettext "ERROR!"`"
  MSG2="`eval_gettext "is not writable"`"
  $MSG -center -title "$TITLE2" "$MSG1 $DPDIR $MSG2"
  exit 6
fi
rm -f "$DPDIR/t155145492.txt"

cd "$DPDIR"


# ----- unzip the dotpup

if ! unzip -o "$FPATH"
then
  MSG1="`eval_gettext "ERROR unzipping:"`"
  MSG2="`eval_gettext "Not enough space to unzip?"`"
  $MSG -center -title "$TITLE2" "$MSG1 $FNAME
$MSG2"
  dotpuprmtmpdir
  exit 7
fi


# ----- check the md5sums

if [ -r md5sum.txt ]
then
  # busybox does not like crlf or *
  dos2unix -u md5sum.txt
  sed 's/\*//g' md5sum.txt > t155145492.txt
  mv -f  t155145492.txt md5sum.txt
fi

if ! md5sum -c md5sum.txt
then
  MSG1="`eval_gettext "MD5SUM ERROR:"`"
  MSG2="`eval_gettext "Package may be corrupted"`"
  MSG3="`eval_gettext "Not enough space to unzip?"`"
  $MSG -center -title "$TITLE2" "$MSG1 $FNAME
$MSG2
$MSG3"
  dotpuprmtmpdir
  exit 8
fi


# ----- run dotpup.sh script

if [ -r dotpup.sh ]
then
  if [ ! -r $CONFIG/always-run ]
  then
    MSG2=`eval_gettext "DO NOT RUN THE INSTALLER"`
    MSG3=`eval_gettext "IF YOU ARE NOT SURE IT IS SAFE"`
    MSG4="`eval_gettext "Run the Installer?"`"
    MSG1="`eval_gettext "Run,Always,Cancel"`"
    $MSG -buttons "$MSG1" -center -title "$TITLE1" "$MSG2
$MSG3
$MSG4"
    case $? in
      101) true ;;
      102) touch $CONFIG/always-run ;;
      *) exec dotpuprmtmpdir ;;
    esac
  fi
  chmod a+x dotpup.sh
  "$DPDIR/dotpup.sh"
  # popup a message if an error code was returned??
fi


# ----- cleanup the working space

cd
dotpuprmtmpdir


# ----- delete the dotpup file? (this section is not really necessary)

sleep 1
ALWAYS=$CONFIG/always-delete-dotpup
NEVER=$CONFIG/never-delete-dotpup
[ -r $ALWAYS ] && exec rm -f "$FPATH"
[ -r $NEVER ] && exit
MSG2="`eval_gettext "Delete the file"`"
MSG1="`eval_gettext "Yes,Always,Never,No"`"
$MSG -buttons "$MSG1" -center -title "$TITLE1" "$MSG2 $FNAME ?"
case $? in
  101) rm -f "$FPATH" ;;
  102) touch $ALWAYS ; rm -f $NEVER "$FPATH" ;;
  103) touch $NEVER ; rm -f $ALWAYS ;;
  *) exit ;;
esac

