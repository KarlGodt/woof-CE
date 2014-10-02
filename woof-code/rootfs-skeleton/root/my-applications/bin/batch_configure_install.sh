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

#configure: error: unrecognized option: --datarootdir=/usr/share

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
'

CONFOPTS=`echo $CONFOPTS`

DIRES=`ls -1F |grep '/$'`


for i in $DIRES;do
echo $i
cd ./$i
pwd

if [ -f ./Makefile ];then
make clean
make distclean
fi

if [ -x ./configure ];then

./configure $CONFOPTS 2>configure.errs.log
if [ "$?" = '0' ];then
echo "$i :"
files=`find . -type f \( -name "*.c" -o -name "*.cc" -o -name "*.h" \)`
for i in $files;do
echo "Checking for include s in $i..."
includes=`grep -E -e '#include .*|#[[:blank:]]*include .*' $i |awk '{print $2 $3}' |sed 's%include%%' |tr -d '"' |tr -d '<' |tr -d '>' |awk '{print $1}'`
includes=`echo "$includes" |grep -v 'config\.h'`
for j in $includes;do
echo "Checking for header files for $j..."
if [ "`echo "$j" | grep '/'`" ];then
header=`find /usr/X11R7/include -wholename "$j" |head -n1`
for k in `seq 1 1 5` ;do
[ ! "$header" ] && header=`find /usr/include -maxdepth $k -wholename "$j" |head -n1`
done
[ ! "$header" ] && header=`find /usr/local/include -wholename "$j" |head -n1`
else
header=`find /usr/X11R7/include -name "$j" |head -n1`
for k in `seq 1 1 5` ;do
[ ! "$header" ] && header=`find /usr/include -maxdepth $k -name "$j" |head -n1`
done
[ ! "$header" ] && header=`find /usr/local/include -name "$j" |head -n1`
fi
if [ "$header" ];then
echo "Found $header"
new=`echo "$header" |sed 's%/usr%%;s%/X11R7%%;s%/local%%;s%/include%%'`
new=`echo "$new" |sed 's%^/%%'`
if [ "$j" != "$new" ];then
echo "Substitution of $j with $new in
$i"
sed -i "s%$j%$new%" $i
[ "$?" != '0' ] && exit
sleep 1s
fi
fi
done
done


if [ -f ./Makefile ];then
make 2>make.errs.log
if [ "$?" = '0' ];then
make install
if [ "$?" = '0' ];then
new2dir f r make install
fi;
fi;
else
echo "
No Makefile created in $i
">>/tmp/batch_conf_inst.missing
fi
else
echo "
configure returned NOT 0 in $i
">>/tmp/batch_conf_inst.missing
fi
else
echo "
NO configure script for $i
">>/tmp/batch_conf_inst.missing
fi

[ ! -s ./configure.errs.log ] && rm ./configure.errs.log
[ ! -s ./make.errs.log ] && rm ./make.errs.log
cd ..

sleep 2s
done

