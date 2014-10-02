#!/bin/bash

#
#
#

#
#
#


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
#  --docdir=DIR            documentation root
#                          [DATAROOTDIR/doc/xf86-input-keyboard]
#  --htmldir=DIR           html documentation [DOCDIR]
#  --dvidir=DIR            dvi documentation [DOCDIR]
#  --pdfdir=DIR            pdf documentation [DOCDIR]
#  --psdir=DIR             ps documentation [DOCDIR]

CONFOPTS='
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
--localedir=/usr/share/locale
--mandir=/usr/share/man
--docdir=/usr/share/doc
--htmldir=/usr/share/html
--dvidir=/usr/share/dvi
--pdfdir=/usr/share/pdf
--psdir=/usr/share/ps
--infodir=/usr/share/info
--enable-static
--enable-dependency-tracking
'
#LDFLAGS     linker flags, e.g. -L<lib dir> if you have libraries in a
#              nonstandard directory <lib dir>
#LIBS        libraries to pass to the linker, e.g. -l<library>
#CPPFLAGS    C/C++/Objective C preprocessor flags, e.g. -I<include dir> if
#              you have headers in a nonstandard directory <include dir>

if [ "$1" = "old" ];then
#configure: error: unrecognized option: --datarootdir=/usr/share
CONFOPTS=`echo "$CONFOPTS" |grep -vE '\-\-datarootdir|\-\-localedir|\-\-docdir|\-\-htmldir|\-\-dvidir|\-\-pdfdir|\-\-psdir'`
#CONFOPTS="$CONFOPTS
#--infodir=/usr/share/info"
fi

CONFOPTS=`echo $CONFOPTS`
rm -f /tmp/headers.db
touch /tmp/headers.db

DIRES=`ls -1F |grep '/$' |grep '^xf86\-' | grep -v '\-i[0-9]??$'`

for dir in $DIRES;do
echo $dir
cd ./$dir
pwd

if [ -f ./Makefile ];then
make clean
make distclean
fi

if [ -x ./configure ];then

./configure $CONFOPTS 2>configure.errs.log
if [ "$?" = '0' ];then
echo "$dir :"

rm -f local_headers.db
touch local_headers.db
rm -f headers.check

files=`find . -type f \( -name "*.c" -o -name "*.cc" -o -name "*.h" \)`
for file in $files;do
echo "Checking for include s in $file..."
echo "Checking for include s in $file..." >>headers.check
header=''
includes=`grep -E -e '#include[[:blank:]]*.*|#[[:blank:]]*include[[:blank:]]*.*' $file |awk '{print $2 $3}' |sed 's%include%%;s%/\*.*%%' |tr -d '"' |tr -d '<' |tr -d '>' |awk '{print $1}'`
includes=`echo "$includes" |grep -v 'config\.h'`

for inc in $includes;do
echo "Checking for header files for $inc..."
if [ "$inc" = 'fb.h' ] ;then
echo "FOUND fb.h"
echo "FOUND fb.h for $file in $dir" >>/tmp/fb_h.lst
break
fi

gpj=`echo "$inc" | sed 's%\([[:punct:]]\)%\\\\\1%g'`
echo "gpj='$gpj'"
header=''
if [ ! "`echo "$inc" | grep '/'`" ];then #NO dirslash
header=''
header=`grep -m1 -w "$gpj" local_headers.db`
echo "1 header='$header'"
if [ ! "$header" ];then #NOT (yet) local header
if [ "`find . -name "$inc"`" ];then
if [ "$inc" != 'xf86OSKbd.h' -a "$inc" != 'xf86Keymap.h' ];then ##likely more to come
echo "$inc local header"
echo "$inc" >>local_headers.db
header=''
continue
else echo "Skipping $inc for local header check.." >>headers.check
fi
else echo "NOT found local header $inc..?" >>headers.check
fi
else
echo "$inc already noted local header" >>headers.check
header=''
continue
fi #local header
if [ ! "$header" ];then
header=`grep -m1 -w "$gpj" /tmp/headers.db`
echo "A header='$header'"
if [ ! "$header" ];then #NOT local header
header=`find -L /usr/X11R7/include -name "$inc" |head -n1`
echo "B header='$header'"
for k in `seq 1 1 5` ;do
if [ ! "$header" ];then
header=`find /usr/include -maxdepth $k -name "$inc" |head -n1`
echo "C header='$header' $k"
fi
done
[ ! "$header" ] && header=`find /usr/local/include -name "$inc" |head -n1`
echo "D header='$header'"
[ "$header" ] && echo "$header" >>/tmp/headers.db
fi #NOT local header
fi

echo "E header='$header'"
fi #NO dirslash

echo "F header='$header'"
if [ "$header" ];then
echo "Found $header" >>headers.check
new=`echo "$header" |sed 's%/usr%%;s%/X11R7%%;s%/local%%;s%/include%%'`
new=`echo "$new" |sed 's%^/%%;s%xorg/xorg/%xorg/%;s%^/%%;s%//%/%g'`
if [ "$inc" != "$new" ];then
J=`echo "$inc" |sed 's%\([[:punct:]]\)%\\\\\1%g'`
#J=`echo "$j" |sed 's%\.%\\\\.%g'`
echo "Substitution of $J with $new in
$file" >>headers.check
sed -i "s%\"$J\"%\"$new\"%;s%xorg/xorg/%xorg/%" $file
[ "$?" != '0' ] && exit
sleep 1s
sed -i "s%<$J>%<$new>%;s%xorg/xorg/%xorg/%" $file
[ "$?" != '0' ] && exit
fi
fi

header=''
done
echo "$file :"
done



else
echo "
configure returned NOT 0 in $file
">>/tmp/batch_conf_inst.missing
fi
else
echo "
NO configure script for $file
">>/tmp/batch_conf_inst.missing
fi

[ ! -s ./configure.errs.log ] && rm -f ./configure.errs.log

cd ..

sleep 2s
done


