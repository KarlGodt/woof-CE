#!/bin/bash

#cd `pwd`

case $1 in
f|force)FORCE=1;;
esac

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


#W=`./configure --help | grep '\-\-with'|awk '{print $1}'| grep -v -E '=|disable|without|pic|policy|acl|maintainer|debug|test|check|verbose'|tr '\n' ' '`
W=`./configure --help |grep -ve '^[[:blank:]]+++'|awk '{print $1}'| grep '\-\-with'| grep -v -E '=|disable|without|pic|policy|acl|selinux|kqueue|gnu\-ld|ansi|dmx|tslib|maintainer|werror|null\-root\-cursor|xwin|multibuffer|\-dri|DEPRECATED|static|64|motif|mfb|afb|cfb|xprint'|tr '\n' ' '`

#E=`./configure --help | grep '\-\-enable'|awk '{print $1}'| grep -v -E '=|disable|without|pic|policy|acl|maintainer|debug|test|check|verbose'|tr '\n' ' '`
E=`./configure --help |grep -ve '^[[:blank:]]+++'|awk '{print $1}'| grep '\-\-enable'| grep -v -E '=|disable|without|pic|policy|acl|selinux|kqueue|gnu\-ld|ansi|dmx|tslib|maintainer|werror|null\-root\-cursor|xwin|multibuffer|\-dri|DEPRECATED|static|64|motif|mfb|afb|cfb|xprint'|tr '\n' ' '`

C="./configure $W $E $CUSTOM"

echo "Do you want to
$C
?"
if [ "$FORCE" != '1' ];then
read a
a=`echo "$a" | tr '[[:upper:]]' '[[:lower:]]'`
case "$a" in
y)logsave ./logsave.`date +%d-%H:%M`.log $C
exit 0;;
n)
echo "EDIT :"
cat 1>&2 <<EOS
"$C"
EOS
;;
*)exit 100;;
esac
else
logsave ./logsave.`date +%d-%H:%M`.log $C
fi
