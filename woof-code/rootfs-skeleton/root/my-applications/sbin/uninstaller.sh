#!/bin/sh
###
## Sat Oct 15 23:46:56 GMT+1 2011
###

########################################################################
#
#
#
#
#
# /dev/hda7
# /dev/hda7:
# LABEL="/"
# UUID="429ee1ed-70a4-43a5-89f8-33496c489260"
# TYPE="ext4"
# DISTRO_NAME='LucidÂPuppy'
# DISTRO_VERSION=218
# DISTRO_MINOR_VERSION=00
# DISTRO_BINARY_COMPAT='ubuntu'
# DISTRO_FILE_PREFIX='luci'
# DISTRO_COMPAT_VERSION='lucid'
# DISTRO_KERNEL_PET='linux_kernel-2.6.33.2-tickless_smp_patched-L3.pet'
# PUPMODE=2
# SATADRIVES=''
# PUP_HOME='/'
# PDEV1='hda7'
# DEV1FS='ext4'
# LinuxÂpuppypcÂ2.6.31.14Â#1ÂMonÂJanÂ24Â21:03:21ÂGMT-8Â2011Âi686ÂGNU/Linux
# Xserver=/usr/bin/Xorg
# $LANG=en_US
# today=TueÂOctÂ25Â12:33:28ÂGMT+1Â2011
#
#
#
#
#
########################################################################


options='\-h|\-\-help|\-i|\-\-interactive|\-p|\-\-package|\-\-program|\-v|\-\-verbose'
STARTDIR=`pwd`
DIR="$HOME/REMOVE.$$/$PROGRAM"
mkdir -p "$DIR"

help_func(){
echo "`cat 2>&1 <<_EOT
Usage : $0 [-option --option[=]] PAKAGENAME
-b , --backup
-h , --help
-i , --interactive
-p , --package=PAKGNAME
-v , --verbose
_EOT`"
exit $1
}

positionalParameters="$@"
[ -z "$positionalParameters" ] && help_func 1
interActive='no';PROGRAM='';debugVal=0;two='';three='';trace='no';backUp='no';##command='rm $one';


for param in $positionalParameters ; do
case $param in
-b|--backup)
#command='three=`dirname $one`;mkdir -p $two/$three;mv $one $two/$three/$one'
#two="$DIR/${PROGRAM}-backup"
backUp='yes';trace='yes'
#mkdir "$two"
;;
-h|--help)
help_func 0;exit
;;
-i|--interactive)
interActive='yes'
;;
-p|--package=*|--program=*)
PROGRAM=`echo $positionalParameters | grep -o -E '\-p.*|\-\-program=.*|\-\-package=.*'`
PROGRAM=`echo $PROGRAM | cut -f 1,2 -d ' ' | sed 's/-d//;s/--program=//;s/--package=//'`
PROGRAM=`echo $PROGRAM | sed 's/^[[:blank:]]*//' | cut -f 1 -d ' '`
;;
-v|--verbose)
debugVal=1;trace='yes'
;;
*)
if [ -z "`echo "$param" | grep -E "$options"`" ] ; then
PROGRAM="$param"
else
help_func 1;exit
fi
;;
esac
done

[ "$debugVal" == 1 ] && echo PROGRAM=$PROGRAM debugVal=$debugVal interActive=$interActive
#exit

#[ "$1" ] && PROGRAM="$1"
#[ "$INPUT" ] && PROGRAM="$INPUT"
#[ -z "$PROGRAM" ] && echo 'goof , no program or package to care for ! Try again with additional param !' && exit
[ -z "$DISPLAY" ] && interActive='no'
[ "$backUp" == 'yes' ] && two="$DIR/${PROGRAM}-backup" && mkdir "$two"


command(){
if [ "$backUp" == 'yes' ] ; then
echo one=$one two=$two three=$three
three=`dirname $one`;
echo three=$three
mkdir -p $two/$three;
mv $one $two/$three/
else
echo one=$one	
rm $one
fi
}

#STARTDIR=`pwd`
#DIR="$HOME/REMOVE.$$/$PROGRAM"
#mkdir -p "$DIR"

cd "$DIR"
[ "$debugVal" == 1 ] && echo  STARTDIR=$STARTDIR DIR=$DIR pwd=`pwd`
wget http://packages.debian.org/en/lenny/i386/"$PROGRAM"/filelist
if [ -e filelist ] ; then
[ "$debugVal" == 1 ] && echo 'dl db file successfully'
if [ -z "`head -n 5 filelist | grep -i 'ERROR'`" ] ; then
[ "$debugVal" == 1 ] && echo 'no error message in db file'
cat filelist | sed 's#><#>\n<#g;s#>#>\n#g;s#<#\n<#g;/^$/d' > filelist_9.txt
[ "$debugVal" == 1 ] && echo ' transforming db file to text file stage 1'
cat filelist_9.txt | grep -v '^<' | grep '^/' >filelist.txt
[ "$debugVal" == 1 ] && echo ' transforming db file to text file stage 2'
F=`cat filelist.txt` ##| grep "$PROGRAM" | grep -v -E '<|>' | grep '^/.*'` ### F=`grep "$PROGRAM" filelist.txt`
[ "$debugVal" == 1 ] && echo "Filelist="$F
for one in $F; do 
[ "$debugVal" == 1 ] && echo "checking $one"
if [ -e "$one" ] ; then #&&
[ "$debugVal" == 1 ] && echo "$one installed"
if [ "$interActive" == "yes" ] ; then 
[ "$debugVal" == 1 ] && echo "interActive=$interActive"
xmessage -buttons "Yes-uninstall,Nope-keep" "Do you want to
remove $one from the $OSTYPE `uname -n` ?"
returnValue=$?
[ "$debugVal" == 1 ] && echo "xmessage returnValue=$returnValue"
if [ "$returnValue" -eq 101 ] ; then
#$command ##"$i"
command
[ "$debugVal" == 1 ] && echo "removed $one"
[ "$debugVal" == 1 ] && [ ! -e "$one" ] && echo "$one removed succesfullly"
[ "$debugVal" == 1 ] && [ -e "$one" ] && echo "$one could not be removed" 
else
:
fi
else
#$command  ##"$i"
command
[ "$debugVal" == 1 ] && echo "removed $one"
[ "$debugVal" == 1 ] && [ ! -e "$one" ] && echo "$one removed succesfullly"
[ "$debugVal" == 1 ] && [ -e "$one" ] && echo "$one could not be removed" 
fi
fi
done
[ "$debugVal" == 1 ] && echo "now searching for menu entry"
MF=`find /usr/share/applications -name "*$PROGRAM*"`
if [ -n "$MF" ] ; then ##&&
for one in $MF ; do
if [ "$interActive" == "yes" ] ; then
xmessage -buttons "Yes-uninstall,Nope-keep" "Do you wat to remove $enrty
from the $OSTYPE `uname -n` ?"
 returnValue=$?
[ "$debugVal" == 1 ] && echo "xmessage returnValue=$returnValue"
if [ "$returnValue" -eq 101 ] ; then
#$command ##"$entry"
command
[ "$debugVal" == 1 ] && echo "removed $one"
[ "$debugVal" == 1 ] && [ ! -e "$one" ] && echo "$one removed succesfullly"
[ "$debugVal" == 1 ] && [ -e "$one" ] && echo "$one couild not be removed"
else
:
fi 
else
#$command ##"$entry"
command
[ "$debugVal" == 1 ] && echo "removed $one"
[ "$debugVal" == 1 ] && [ ! -e "$one" ] && echo "$one removed succesfullly"
[ "$debugVal" == 1 ] && [ -e "$one" ] && echo "$one couild not be removed" 
fi
done
fi

else
[ "$debugVal" == 1 ] && echo "apparently $PROGRAM not found in repository"
xmessage -bg orange "`head -n 20 filelist.txt | sed '/^$/d'`"
fi
else
[ "$debugVal" == 1 ] && echo "apparently $PROGRAM not found in repository"
xmessage -bg red "Sorry , but '$PROGRAM' not found
in the debian lenny repository ."
fi
[ "$debugVal" == 1 ] && echo 
cd "$STARTDIR"
[ "$debugVal" == 1 ] && echo 
[ "$trace" == 'no' ] && $command -rf "$DIR"
[ "$debugVal" == 1 ] && echo 
