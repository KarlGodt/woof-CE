#!/bin/sh
#Format floppy disks
#Copyright (c) Barry Kauler 2004 www.goosee.com/puppy
#2007 Lesser GPL licence v2 (http://www.fsf.org/licensing/licenses/lgpl.html)


###KRG Fr 31. Aug 23:34:58 GMT+1 2012



trap "exit 1" HUP INT QUIT KILL TERM


OUT=/dev/null;ERR=$OUT
[ "$DEBUG" ] && { OUT=/dev/stdout;ERR=/dev/stderr; }
[ "$DEBUG" = "2" ] && set -x


Version='1.1'


usage(){
USAGE_MSG="
$0 [ PARAMETERS ]

-V|--version : showing version information
-H|--help : show this usage information

*******  *******  *******  *******  *******  *******  *******  *******  *******
$2
"
exit $1
}

[ "`echo "$1" | grep -wE "\-help|\-H"`" ] && usage 0
[ "`echo "$1" | grep -wE "\-version|\-V"`" ] && { echo "$0 -version $Version";exit 0; }



###KRG Fr 31. Aug 23:34:58 GMT+1 2012

zapfloppy()
{
xmessage -bg "#c0ffff" -center -name "loformat choice" -title "Choose Floppy Drive" -buttons "Floppy1 (fd0)":20,"Floppy2 (fd1)":30,"EXIT":10  -file -<<XMSG
Which Floppy Drive to format
Choose the floppy drive
XMSG
ANS90=$?
if [ $ANS90 -eq 10 ];then
exit
fi
if [ $ANS90 -eq 20 ];then
echo fd0 chosen
FD="fd0"
Kind="u$1"
fi
if [ $ANS90 -eq 30 ];then
echo fd1 chosen
FD="fd1"
Kind=''
fi

mkdir -p /mnt/fd1
mount /dev/fd1 /mnt/fd1 2>/tmp/floppyformat.txt.$$
IN=`cat /tmp/floppyformat.txt.$$`
echo $IN
if test "$IN" = ""; then
echo fd1 wasnot mounted atprogram start ,is mounted now
umount /dev/fd1
echo and should be unmounted now
fi

#umount /dev/fd1 2>/tmp/floppyformat1.txt.$$
#IN2=`cat /tmp/floppyformat1.txt.$$`
#if test "$IN2" != ""
t#hen 
#xmessage -bg "#ffe0e0" -name "loformat2" -title "Puppy Lo-level Formatter" -center \
#  -buttons "Open Rox Filer at /mnt":20,"QUIT":10 -file -<<XMSG
#ERROR
#$IN2
#XMSG
#AN91=$?
#  if [ $AN91 -eq 10 ];then
#   exit
#  fi
#  if [ $AN91 -eq 20 ];then
#   `rox /mnt`
#   
#   floppy-format.sh
#   
#   exit
#  fi
#  if [ $AN91 -eq 0 ];then
#   echo '$AN91' $AN91
#  fi
#  if [ $AN91 -eq 1 ];then
#   ERR0=0
#  fi
#  fi


# Puppy will only allow 1440, 1680K and 1760K capacities.
ERR0=1
while [ ! $ERR0 -eq 0 ];do
xmessage -bg "#c0ffff" -center -title "Please wait..." -buttons "" "Low-level formatting disk with $1 Kbyte capacity" &
 fdformat /dev/$FD$Kind
 ERR0=$?
 killall xmessage
 if [ ! $ERR0 -eq 0 ];then
  xmessage -bg "#ffe0e0" -name "loformat" -title "Puppy Lo-level Formatter" -center \
  -buttons "Try again":20,"QUIT":10 -file -<<XMSG
ERROR low-level formatting disk.
Is the write-protect tab closed?
XMSG

  AN0=$?
  if [ $AN0 -eq 10 ];then
   ERR0=0
  fi
  if [ $AN0 -eq 0 ];then
   ERR0=0
  fi
  if [ $AN0 -eq 1 ];then
   ERR0=0
  fi
 else
  INTROMSG="`
echo "SUCCESS!"
echo -e "Now you should press the \"Msdos/vfat filesystem\" button."
`"
 fi
done
}

fsfloppy()
{
	
	xmessage -bg "#c0ffff" -center -name "loformat choice" -title "Choose Floppy Drive" -buttons "Floppy1 (fd0)":20,"Floppy2 (fd1)":30,"EXIT":10  -file -<<XMSG
Which Floppy Drive to format
Choose the floppy drive
XMSG
ANS90=$?
if [ $ANS90 -eq 10 ];then
exit
fi
if [ $ANS90 -eq 20 ];then
FD="fd0"
Kind="u$1"
fi
if [ $ANS90 -eq 30 ];then
FD="fd1"
Kind=''
fi

####krg----part to test if floppy is mounted---->>>>
mkdir -p /mnt/fd1
mount /dev/fd1 /mnt/fd1 2>/tmp/floppyformat.txt.$$
IN=`cat /tmp/floppyformat.txt.$$`
if test "$IN" = ""; then
umount /dev/fd1
fi
####

echo "Creating msdos filesystem on the disk..."

ERR1=1
while [ ! $ERR1 -eq 0 ];do
xmessage -bg "#c0ffff" -center -title "Please wait..." -buttons "" "Creating msdos/vfat filesystem on floppy disk" &
 mkfs.msdos -c /dev/$FD$Kind
 #mformat -f $1 a:
 #mbadblocks a:
 ERR1=$?
 killall xmessage
 if [ ! $ERR1 -eq 0 ];then
  xmessage -bg "#ffe0e0" -name "msdosvfat" -title "Floppy msdos/vfat filesystem" -center \
  -buttons "Try again":20,"QUIT":10 -file -<<XMSG
ERROR creating msdos/vfat filesystem on the floppy disk.
Is the write-protect tab closed?
XMSG

  AN0=$?
  if [ $AN0 -eq 10 ];then
   ERR1=0
  fi
  if [ $AN0 -eq 0 ];then
   ERR1=0
  fi
  if [ $AN0 -eq 1 ];then
   ERR1=0
  fi
 else
  INTROMSG="`
echo "SUCCESS!"
echo "The floppy disk is now ready to be used."
echo "Use the Puppy Drive Mounter to mount it."
echo "(NOTE: if you use the MToolsFM floppy file"
echo " manager, the floppy drive is accessed directly,"
echo " so do NOT use the Puppy Drive Mounter)"
echo "First though, press EXIT to get out of here..."
`"
 fi
done
sync
echo "...done."
echo " "
}

INTROMSG="`
echo "WELCOME!"
echo "My Puppy Floppy Formatter only formats floppies with"
echo "1440 Kbyte capacity and with the msdos/vfat filesystem,"
echo "for interchangeability with Windows."
echo " "
echo "You only need to lo-level format if the disk is formatted"
echo "with some other capacity, or it is corrupted. You do not"
echo "have to lo-level format a new disk, but may do so to"
echo "check its integrity."
echo "A disk is NOT usable if it is only lo-level formatted: it"
echo "also must have a filesystem, so this must always be the"
echo "second step."
echo "Doing step-2 only, that is, creating a filesystem on a"
echo "disk, is also a method for wiping any existing files."
`"

#big loop...
while :; do

MNTDMSG=" "
mount | grep "/dev/fd*" > /dev/null 2>&1
if [ $? -eq 0 ];then #=0 if string found

 CURRENTMNT=`mount | grep "/dev/fd*" | cut -f 3 -d ' '`
 echo "$CURRENTMNT"
 if test "$CURRENTMNT" != ""
 then
 echo "$CURRENTMNT"
 #this tells Rox to close any window with this directory and subdirectories open...
 rox -D "$CURRENTMNT"
 sync
 umount "$CURRENTMNT" #/mnt/floppy
 fi
 if [ ! $? -eq 0 ];then
  MNTDMSG="`
echo " "
echo "Puppy found a floppy disk already mounted in the drive, but"
echo "is not able to unmount it. The disk must be unmounted now."
echo "Please use the Puppy Drive Mounter (in the File Manager menu)"
echo "to unmount the floppy disk. DO THIS FIRST!"
echo " "
`"
 else
  MNTDMSG="`
echo " "
echo "Puppy found that the floppy disk was mounted, but has now"
echo "unmounted it. Now ok to format disk."
echo " "
`"
 fi
fi

xmessage -bg "#e0ffe0" -name "pformat" -title "Puppy Floppy Formatter" -center \
-buttons "Lo-level Format":20,"Msdos/vfat filesystem":30,"EXIT":10 -file -<<XMSG
$INTROMSG
$MNTDMSG
Press a button:
XMSG

ANS=$?

if [ $ANS -eq 0 ]; then
 break
fi
if [ $ANS -eq 1 ]; then
 break
fi
if [ $ANS -eq 10 ]; then
 break
fi

if [ $ANS -eq 20 ];then #format
 zapfloppy 1440
fi

if [ $ANS -eq 30 ];then #vfat
 fsfloppy 1440
fi

done
