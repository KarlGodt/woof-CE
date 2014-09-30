#!/bin/bash

#cd `pwd`

me_prog=`basename $0`

usage(){
	echo "$0 \\
	[-e|--experimental -f|--force -h|--help -o|--old] [ configure opts ...]
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

first_func(){
FORCE=0;OLD=0
for p in $@;do
case $p in
f|force)FORCE=1;rm -f /tmp/$me_prog.edit;rm -f /tmp/$me_prog.ckl;shift;;
h|help)usage;;
o|old)OLD=1;shift;;
esac
done
}

#CMLP="$@"
FORCE=0;OLD=0;EXPERIMENTAL=0
NR=$#
for n in `seq 1 1 $NR`;do
param=$1
case $param in
--[[:alnum:]]*)
 case $param in
 --experimental) EXPERIMENTAL=1;shift;;
 --force) FORCE=1;rm -f /tmp/$me_prog.edit;rm -f /tmp/$me_prog.ckl;shift;;
 --help) usage 0;;
 --old) OLD=1;;
 *):;;
 esac
;;
-[[:alnum:]]*)
 pl="${param//-/}"
 #Pline="${pl//?/\1 }"
 Pline=`echo "$pl" | sed 's/\(.\)/\1 /g'`
 for sp in $Pline;do
 case $sp in
  e) EXPERIMENTAL=1;shift;;
  f) FORCE=1;rm -f /tmp/$me_prog.edit;rm -f /tmp/$me_prog.ckl;shift;;
  h) usage 0;;
  o) OLD=1;;
  #*) usage 1;;
  esac;done;;
*) :;;
esac;done

CMLP="$@"
function menu_dialog(){

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

#CUSTOM='--enable-policy-kit=no' #HAL

##ffmpeg : without --enable-cross-compile --enable-vaapi w32threads avisynth libcelt
##frei0r libaacplus libdc1394 libdirac libgsm libmp3lame libopencore-amrnb
##libopencore_amrwb opencv libopenjpeg librtmp schroedinger libtheora
##libvo-aacenc libvo-amrwbenc libvpx libxavs libxvid mlib

#W=`./configure --help | grep '\-\-with'|awk '{print $1}'| grep -v -E '=|disable|without|pic|policy|acl|maintainer|debug|test|check|verbose|lint'|tr '\n' ' '`

W=`./configure --help | grep '\-\-with'|awk '{print $1}'| grep -v -E '=|disable|without'|tr '\n' ' '`

O=`./configure --help | grep '\-\-without'|awk '{print $1}'|grep -v 'PACKAGE' | tr '\n' ' '`

#W=`./configure --help | grep '\-\-with'|awk '{print $1}'| grep -v -E '=|disable|without|pic|policy|acl|selinux|kqueue|gnu\-ld|ansi|dmx|tslib|maintainer|werror|null\-root\-cursor|xwin|multibuffer|\-dri|DEPRECATED|static|64|motif|mfb|afb|cfb|xprint|cross\-compile|vaapi|w32|avisynth|libcelt|frei0r|libaacplus|libdc1394|libdirac|libgsm|libmp3lame|libnut|libopencore\-amr|opencv|libopenjpeg|librtmp|schroedinger|libtheora|libvo\-aacenc|libvo-amrwbenc|libvpx|libxavs|libxvid|mlib'|tr '\n' ' '`

#

#E=`./configure --help | grep '\-\-enable'|awk '{print $1}'| grep -v -E '=|disable|without|pic|policy|acl|maintainer|debug|test|check|verbose|lint'|tr '\n' ' '`

D=`./configure --help | grep '\-\-disable'|awk '{print $1}' |grep -v 'FEATURE' |tr '\n' ' '`

E=`./configure --help | grep '\-\-enable'|awk '{print $1}'| grep -v -E '=|disable|without'|tr '\n' ' '`

#E=`./configure --help | grep '\-\-enable'|awk '{print $1}'| grep -v -E '=|disable|without|pic|policy|acl|selinux|kqueue|gnu\-ld|ansi|dmx|tslib|maintainer|werror|null\-root\-cursor|xwin|multibuffer|\-dri|DEPRECATED|static|64|motif|mfb|afb|cfb|xprint|cross\-compile|vaapi|w32|avisynth|libcelt|frei0r|libaacplus|libdc1394|libdirac|libgsm|libmp3lame|libnut|libopencore\-amr|opencv|libopenjpeg|librtmp|schroedinger|libtheora|libvo\-aacenc|libvo-amrwbenc|libvpx|libxavs|libxvid|mlib'|tr '\n' ' '`

#

if [ -r /tmp/$me_prog.edit ];then
#editbox:
#C=`cat /tmp/$me_prog.edit |tr '\n' ' '`

#checklist:
ONS=`cat /tmp/$me_prog.edit | tr -d '"'`
for n in $ONS;do
echo $n
OPTION=`grep -w "^$n " /tmp/$me_prog.ckl | cut -f 2 -d' '`
echo OPTION=$OPTION
OPTIONS="$OPTIONS
$OPTION"
done
OPTIONS=`echo $OPTIONS`
C='./configure '"$OPTIONS"

else
C='./configure '"$DIRES $W $O $E $D $CUSTOM $CMLP"
fi

echo "Do you want to
$C
.....................................................................?"

if [ "$FORCE" != '1' ];then
read -n1 -p "
Press 'y' to go , 'n' to edit above options ,
any other key quits with usage message " a;echo

if [ ! "$a" ];then
rm -f /tmp/$me_prog.ckl;rm -f /tmp/$me_prog.edit;exit 0;fi

a=`echo "$a" | tr '[[:upper:]]' '[[:lower:]]'`
case "$a" in

y)
logsave ./logsave.`date +%d-%H:%M`.log $C
LSCONFIGURE_RV=$?
echo "LSCONFIGURE_RV='$LSCONFIGURE_RV'"
case $LSCONFIGURE_RV in
0) exit 0;;
*) read -n1 -p "
An error occured , press any key to alter the configure options " b
menu_dialog ;;
esac
;;

n)
#new :
menu_dialog

#echo "EDIT :"
#cat 1>&2 <<EOS
#"$C"
#EOS

#dialog --editbox:
#cat >/tmp/$me_prog.edit <<EOS
#"$C"
#EOS
#sync
#xterm -hold -e dialog --editbox /tmp/$me_prog.edit
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
#echo option=$option
#CHECKLIST="$CHECKLIST
#$c $option on"
echo "$c $option on" >>/tmp/$me_prog.ckl
done
#echo "$CHECKLIST"
#CHECKLIST=`echo "$CHECKLIST" | sed '/^$/d'`
#echo "$CHECKLIST" > /tmp/$me_prog.ckl
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
*)rm -f /tmp/$me_prog.ckl;rm -f /tmp/$me_prog.edit;usage;;
esac
else
logsave ./logsave.`date +%d-%H:%M`.log $C
fi
exit $?

