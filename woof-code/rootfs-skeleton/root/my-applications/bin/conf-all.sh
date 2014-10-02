#!/bin/bash

#cd `pwd`



me_prog=`basename $0`
me_base="${me_prog%\.*}"
mkdir /tmp/$me_base/
date_now="`date +%F-%T`"

trap "mv /tmp/$me_base/$me_prog.edit /tmp/$me_base/$me_prog.edit-$date_now; \
 mv /tmp/$me_base/$me_prog.ckl /tmp/$me_base/$me_prog.ckl-$date_now; \
 exit 1" TERM INT KILL HUP QUIT TRAP STOP

#trap "mv /tmp/$me_base/$me_prog.ckl /tmp/$me_base/$me_prog.ckl-$date_now" TERM INT KILL HUP QUIT TRAP STOP
#trap exit TERM INT KILL HUP QUIT TRAP STOP

usage(){
	echo "
	$0
	[-d|--debug] 'set -x' .
	[-e|--experimental] install to /usr/local .
	[-f|--force] answer all questions with 'y|Y' , install to /usr/local .
	[-h|--help]  show this usage .
	[-l|--log]   log to ./logsave.'date +%d-%H:%M'.log .
	[-m|--menu]  use a dialog menue like kernel make menuconfig (default).
	[-o|--old]   when configure does not know old paths: ie.--localedir
	[-p DIR|--portable=DIR] ie. /PROGRAM_NAME; eq. to --prefix=/PROGRAM_NAME
	[-s|--simple] don't use a menu .
	[-v|--verbose] be verbose in output, pass these to the used bins .
	[ configure opts ...] additional configure options
	configures in dir
	(ATM: `pwd`)
	with these parameters :

	commandline args: '$@'

	$DIRES
	$W
	$E
	$CUSTOM
	$CMLP
"
exit $1
}

#CMLP="$@"
FORCE=0;OLD=0;EXPERIMENTAL=0;OUTPUT='/dev/null';ERR=$OUTPUT
NR=$#
for n in `seq 1 1 $NR`;do
param=$1;shift
case $param in
--[[:alnum:]]*)
 case $param in
 --debug) set -x;;
 --experimental) EXPERIMENTAL=1;;#shift;;
 --force) FORCE=1;rm -f /tmp/$me_base/$me_prog.edit;rm -f /tmp/$me_base/$me_prog.ckl;;#shift;;
 --help) usage 0;;
 --log) LOG_TO_FILE='1';;
 --menu) :;;
 --old) OLD=1;;
 --portable=*) PORTABLE_DIR="${param##*=}";;
 --simple) SIMPLE='1';;
 --verbose) VERBOSE='-v';LONG_VERBOSE='--verbose';X_LONG_VERBOSE='-verbose';OUTPUT=/dev/stdout;ERR=/dev/stderr;;
 *) CMDLP="$CMDLP $1";;
 esac
;;
-[[:alnum:]]*)
 pl="${param//-/}"
 #Pline="${pl//?/\1 }"
 Pline=`echo "$pl" | sed 's/\(.\)/\1 /g'`
 for sp in $Pline;do
 case $sp in
  d) set -x;;
  e) EXPERIMENTAL=1;; #shift;;
  f) FORCE=1;rm -f /tmp/$me_base/$me_prog.edit;rm -f /tmp/$me_base/$me_prog.ckl;;#shift;;
  h) usage 0;;
  l) LOG_TO_FILE='1';;
  m) :;;
  o) OLD=1;;
  p) PORTABLE_DIR="$1";shift;;
  s) SIMPLE='1';;
  v) VERBOSE='-v';LONG_VERBOSE='--verbose';X_LONG_VERBOSE='-verbose';OUTPUT=/dev/stdout;ERR=/dev/stderr;;
  *) CMDLP="$CMDLP $1";;
  esac;done;;
*) :;;
esac;done

CMLP="$@"
if [ "$SIMPLE" -o "$LOG_TO_FILE" ];then
logsave ./logsave.`date +%d-%H:%M`.log ./configure $CMLP
exit $?
fi

function menu_dialog(){

LA_0=`echo "$CA" | tr '[[:blank:]]' ' ' | tr -s ' ' | tr ' ' '\n'`
LA_1=`echo "$LA_0" | grep -v configure`
LA_2=`echo "$LA_1" | sed '/^$/d'`

echo "LA_2 :"
echo "$LA_2"
read -n1 -p "DEBUG, press Key to go on " GO_ON_KEY;echo

ON_LIST0=`echo "$C" | tr '[[:blank:]]' ' ' | tr -s ' ' | tr ' ' '\n'`
ON_LIST1=`echo "$ON_LIST0" | grep -v configure`
ON_LIST2=`echo "$ON_LIST1" | sed '/^$/d'`
#grep: unrecognized option `--bindir=/usr/bin
ON_LIST3=`echo "$ON_LIST2" |sed 's,\([[:punct:]]\),\\\\\1,g'`
OFF_LIST_0=`echo "$LA_2" |grep -v "$ON_LIST3"`

echo "ON_LIST2 :"
echo "$ON_LIST2"
read -n1 -p "DEBUG, press Key to go on " GO_ON_KEY;echo

echo "OFF_LIST_0 :"
echo "$OFF_LIST_0"
read -n1 -p "DEBUG, press Key to go on " GO_ON_KEY;echo

c=0
rm /tmp/$me_base/$me_prog.ckl
#echo "$ON_LIST2" | while read option;do
echo "$LA_2" | while read option;do echo "$option"
c=$((c+1))
grepP=`echo "$option" |sed 's,\([[:punct:]]\),\\\\\1,g'`
if [ "`echo "$ON_LIST2" |grep "$grepP"`" ];then
echo "$c $option on" >>/tmp/$me_base/$me_prog.ckl
else
echo "$c $option off" >>/tmp/$me_base/$me_prog.ckl
fi
done
read -n1 -p "DEBUG, press Key to go on " GO_ON_KEY;echo
#read -n1 FURTHERKEY

CHECKLIST=`cat /tmp/$me_base/$me_prog.ckl`
CHECKLIST=`echo "$CHECKLIST" | sed '/^$/d'`
echo "$CHECKLIST"
read -n1 -p "DEBUG, press Key to go on " GO_ON_KEY;echo
#read -n1 FURTHERKEY

#xterm -hold -e dialog --checklist "Edit configure options" 0 0 25 $CHECKLIST 2>/tmp/$me_prog.edit
dialog --nocancel --checklist "Deselect/Select configure options :" 100 100 16 $CHECKLIST 2>/tmp/$me_base/$me_prog.edit
if [ ! "$?" -eq 0 ];then
rm -f /tmp/$me_base/$me_prog.ckl;rm -f /tmp/$me_base/$me_prog.edit;exit $?;fi

sync

exec $0
}

#Fine tuning of the installation directories:
#  --bindir=DIR            user executables [EPREFIX/bin]
#  --sbindir=DIR           system admin executables [EPREFIX/sbin]
#  --libexecdir=DIR        program executables [EPREFIX/libexec]
#  --sysconfdir=DIR        read-only single-machine data [PREFIX/etc]
#  --sharedstatedir=DIR    modifiable architecture-independent data [PREFIX/com]
#  --localstatedir=DIR     modifiable single-machine data [PREFIX/var]
#  --libdir=DIR            object code libraries [EPREFIX/lib]
#  --includedir=DIR        C header files [PREFIX/include]
#  --oldincludedir=DIR     C header files for non-gcc [/usr/include]
#  --datarootdir=DIR       read-only arch.-independent data root [PREFIX/share]
#  --datadir=DIR           read-only architecture-independent data [DATAROOTDIR]
#  --infodir=DIR           info documentation [DATAROOTDIR/info]
#  --localedir=DIR         locale-dependent data [DATAROOTDIR/locale]
#  --mandir=DIR            man documentation [DATAROOTDIR/man]
#  --docdir=DIR            documentation root [DATAROOTDIR/doc/mesa]
#  --htmldir=DIR           html documentation [DOCDIR]
#  --dvidir=DIR            dvi documentation [DOCDIR]
#  --pdfdir=DIR            pdf documentation [DOCDIR]
#  --psdir=DIR             ps documentation [DOCDIR]

DIRES='
--bindir=/usr/bin
--sbindir=/usr/sbin
--libexecdir=/usr/libexec
--sysconfdir=/etc
--sharedstatedir=/usr/com
--localstatedir=/var
--libdir=/usr/lib
--includedir=/usr/include
--oldincludedir=/usr/include
--datarootdir=/usr/share
--datadir=/usr/share
--infodir=/usr/share/info
--localedir=/usr/share/locale
--mandir=/usr/share/man
--docdir=/usr/share/doc
--htmldir=/usr/share/html
--dvidir=/usr/share/dvi
--pdfdir=/usr/share/pdf
--psdir=/usr/share/ps
'

DIRES=`echo $DIRES`
DIRES="$DIRES"

CURRDIR=`basename $(pwd)`
if [ "`echo "$CURRDIR" |grep -i '^x'`" ];then

DIRESX='
--bindir=/usr/X11R7/bin
--sbindir=/usr/X11R7/sbin
--libexecdir=/usr/X11R7/libexec
--sysconfdir=/etc
--sharedstatedir=/usr/X11R7/com
--localstatedir=/var
--libdir=/usr/X11R7/lib
--includedir=/usr/X11R7/include
--oldincludedir=/usr/include
--datarootdir=/usr/share
--datadir=/usr/share
--infodir=/usr/share/info
--localedir=/usr/share/locale
--mandir=/usr/share/man
--docdir=/usr/share/doc
--htmldir=/usr/share/html
--dvidir=/usr/share/dvi
--pdfdir=/usr/share/pdf
--psdir=/usr/share/ps
'

DIRES=`echo $DIRESX`
DIRES="$DIRES"
fi

#if [ "`echo "$CMLP" |grep -i 'EXPERIMENTAL'`" -o "$FORCE" = '1' ];then
if [ "$EXPERIMENTAL" = '1' -o "$FORCE" = '1' ];then

DIRESL='
--bindir=/usr/local/bin
--sbindir=/usr/local/sbin
--libexecdir=/usr/local/libexec
--sysconfdir=/usr/local/etc
--sharedstatedir=/usr/local/com
--localstatedir=/usr/local/var
--libdir=/usr/local/lib
--includedir=/usr/local/include
--oldincludedir=/usr/local/include
--datarootdir=/usr/local/share
--datadir=/usr/local/share
--infodir=/usr/local/share/info
--localedir=/usr/local/share/locale
--mandir=/usr/local/share/man
--docdir=/usr/local/share/doc
--htmldir=/usr/local/share/html
--dvidir=/usr/local/share/dvi
--pdfdir=/usr/local/share/pdf
--psdir=/usr/local/share/ps
'

DIRES=`echo $DIRESL`
DIRES="$DIRES"
fi

P="--prefix=$PREFIX"
PRE_FIX_ONLY=''
PRE_FIX_ONLY=`echo "$@" | grep -o 'prefix=.* ' |cut -f 2 -d '='`
if [ "$PRE_FIX_ONLY" ];then
DIRESP="
--bindir=$PRE_FIX_ONLY/bin
--sbindir=$PRE_FIX_ONLY/sbin
--libexecdir=$PRE_FIX_ONLY/libexec
--sysconfdir=$PRE_FIX_ONLY/etc
--sharedstatedir=$PRE_FIX_ONLY/com
--localstatedir=$PRE_FIX_ONLY/var
--libdir=$PRE_FIX_ONLY/lib
--includedir=$PRE_FIX_ONLY/include
--oldincludedir=$PRE_FIX_ONLY/include
--datarootdir=$PRE_FIX_ONLY/share
--datadir=$PRE_FIX_ONLY/share
--infodir=$PRE_FIX_ONLY/share/info
--localedir=$PRE_FIX_ONLY/share/locale
--mandir=$PRE_FIX_ONLY/share/man
--docdir=$PRE_FIX_ONLY/share/doc
--htmldir=$PRE_FIX_ONLY/share/html
--dvidir=$PRE_FIX_ONLY/share/dvi
--pdfdir=$PRE_FIX_ONLY/share/pdf
--psdir=$PRE_FIX_ONLY/share/ps
"

DIRES=`echo $DIRESP | tr -s '/'`
DIRES="$DIRES"
fi

if [ "$OLD" = '1' ];then
DIRES=`echo "$DIRES" |grep -vE '\-\-datarootdir|\-\-localedir|\-\-docdir|\-\-htmldir|\-\-dvidir|\-\-pdfdir|\-\-psdir'`
fi

I='--build=i486-pc-linux-gnu'

##CUSTOM='--enable-policy-kit=no' #HAL

#with_all
WA=`./configure --help | grep '\-\-with'|awk '{print $1}'| grep -v -E '=|disable|without'|tr '\n' ' '`

#need_interactive_intervention
NIW=`./configure --help | grep '\-\-with'|awk '{print $1}'| grep -v 'without' | grep '=' |tr '\n' ' '`

#without_all
OA=`./configure --help | grep '\-\-without'|awk '{print $1}'|grep -vE 'FEATURE|PACKAGE|NAME|MUXER|CODER' | tr '\n' ' '`

#need_interactive_intervention
NIO=`./configure --help | grep '\-\-without'|awk '{print $1}'|grep -E 'FEATURE|PACKAGE|NAME|MUXER|CODER' | tr '\n' ' '`


#disable_all
DA=`./configure --help | grep '\-\-disable'|awk '{print $1}' |grep -vE 'FEATURE|PACKAGE|NAME|MUXER|CODER' |tr '\n' ' '`

#need_interactive_intervention
NID=`./configure --help | grep '\-\-disable'|awk '{print $1}' |grep -E 'FEATURE|PACKAGE|NAME|MUXER|CODER' |tr '\n' ' '`

#enable_all
EA=`./configure --help | grep '\-\-enable'|awk '{print $1}'| grep -v -E '=|disable|without'|tr '\n' ' '`

#need_interactive_intervention
NIE=`./configure --help | grep '\-\-enable'|awk '{print $1}'| grep -v 'disable' |grep '='|tr '\n' ' '`


OTHER=`./configure --help | grep '\-\-' | grep -vE '\-\-with|\-\-enable|\-\-disable'`
#
echo "Skipping for now the treatment of :

$OTHER

$NIO

$NIW

$NID

$NIE
"
read -n1 -p "DEBUG, press Key to go on " GO_ON_KEY;echo

if [ -r /tmp/$me_base/$me_prog.edit ];then
#editbox:
#C=`cat /tmp/$me_prog.edit |tr '\n' ' '`

#checklist:
ONS=`cat /tmp/$me_base/$me_prog.edit | tr -d '"'`
for n in $ONS;do
echo $n
OPTION=`grep -w "^$n " /tmp/$me_base/$me_prog.ckl | cut -f 2 -d' '`
echo OPTION=$OPTION
OPTIONS="$OPTIONS
$OPTION"
done
OPTIONS=`echo $OPTIONS`
C='./configure '"$OPTIONS"

else
W="$WA";O="$OA";E="$EA";D="$DA"
CA='./configure '"$DIRES $W $O $E $D $CUSTOM $CMLP"
export CA
C="$CA"
fi

echo "Do you want to
$C
.....................................................................?"

if [ "$FORCE" != '1' ];then
read -n1 -p "
Press 'y' to go , 'n' to edit above options ,
any other key quits with usage message " a;echo

if [ ! "$a" ];then
rm -f /tmp/$me_base/$me_prog.ckl;rm -f /tmp/$me_base/$me_prog.edit;exit 0;fi

a=`echo "$a" | tr '[[:upper:]]' '[[:lower:]]'`
case "$a" in

y)
logsave ./logsave.`date +%d-%H:%M`.log $C
LSCONFIGURE_RV=$?
echo "LSCONFIGURE_RV='$LSCONFIGURE_RV'"
case $LSCONFIGURE_RV in
0) exit 0;;
*) read -n1 -p "
An error occured , press any key to alter the configure options " MENUKEY
echo ""
menu_dialog ;;
esac
;;

n)
#new :
menu_dialog


old(){
LIST=`echo "$C" | tr '[[:blank:]]' ' ' | tr -s ' ' | tr ' ' '\n'`
LIST=`echo "$LIST" | grep -v configure`
LIST=`echo "$LIST" | sed '/^$/d'`
echo LIST
echo "$LIST"
c=0
rm /tmp/$me_prog.ckl
echo "$LIST" | while read option;do
c=$((c+1))

echo "$c $option on" >>/tmp/$me_prog.ckl
done

CHECKLIST=`cat /tmp/$me_prog.ckl`
CHECKLIST=`echo "$CHECKLIST" | sed '/^$/d'`
echo "$CHECKLIST"
#xterm -hold -e dialog --checklist "Edit configure options" 0 0 25 $CHECKLIST 2>/tmp/$me_prog.edit
dialog --nocancel --checklist "Deselect/Select configure options :" 100 100 16 $CHECKLIST 2>/tmp/$me_prog.edit
if [ ! "$?" -eq 0 ];then
rm -f /tmp/$me_prog.ckl;rm -f /tmp/$me_prog.edit;exit $?;fi
sync

exec $0
}

;;
*)rm -f /tmp/$me_base/$me_prog.ckl;rm -f /tmp/$me_base/$me_prog.edit;usage;;
esac
else
logsave ./logsave.`date +%d-%H:%M`.log $C
fi

mv /tmp/$me_base/$me_prog.edit /tmp/$me_base/$me_prog.edit-$date_now
mv /tmp/$me_base/$me_prog.ckl /tmp/$me_base/$me_prog.ckl-$date_now

exit $?

