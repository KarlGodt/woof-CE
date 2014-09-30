#!/bin/bash

cd `pwd`

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

I='--build=i486-pc-linux-gnu'
P="--prefix=$PREFIX"
#CUSTOM='--enable-policy-kit=no' #HAL
#CUSTOM='--disable-opengl=no' #MESA

#W=`./configure --help | grep '\-\-with'|awk '{print $1}'| grep -v -E '=|disable|without|pic|policy|acl|maintainer|debug|test|check|verbose'|tr '\n' ' '`
#W=`./configure --help | grep '\-\-with'|awk '{print $1}'| grep -v -E '=|disable|without|pic|policy|acl|selinux|kqueue|gnu\-ld|ansi|dmx|tslib|maintainer|werror|null\-root\-cursor|xwin|multibuffer|dri|DEPRECATED|static|64|motif'|tr '\n' ' '`

#E=`./configure --help | grep '\-\-enable'|awk '{print $1}'| grep -v -E '=|disable|without|pic|policy|acl|maintainer|debug|test|check|verbose'|tr '\n' ' '`
#E=`./configure --help | grep '\-\-enable'|awk '{print $1}'| grep -v -E '=|disable|without|pic|policy|acl|selinux|kqueue|gnu\-ld|ansi|dmx|tslib|maintainer|werror|null\-root\-cursor|xwin|multibuffer|dri|DEPRECATED|static|64|motif'|tr '\n' ' '`
D=`./configure --help | grep '\-\-disable'|awk '{print $1}' |grep -v -E 'FEATURE|opengl|shared' |tr '\n' ' '`
O=`./configure --help | grep '\-\-without'|awk '{print $1}'|grep -v -E 'PACKAGE|opengl|shared' | tr '\n' ' '`

C="./configure $D $O $CUSTOM"

echo "Do you want to
$C
?"

read a
a=`echo "$a" | tr '[[:upper:]]' '[[:lower:]]'`
case "$a" in
y)
logsave ./logsave.`date +%d-%H:%M`.log $C
exit 0
;;
n)
#go=''
echo "EDIT :"
#until [ "$go" ] ; do
cat 1>&2 <<EOS
"$C"
EOS
;;
*)
exit 100
;;
esac

