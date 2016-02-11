#!/bin/ash
# Environment variables for the Qt package.
#
# It's best to use the generic directory to avoid
# compiling in a version-containing path:

#OUT=/dev/null
#[ "$DEBUG" ] || { DEBUG=`grep -iw 'debug' /proc/cmdline`; OUT=/dev/stdout; }
. /etc/rc.d/f4puppy5

if [ "$QTDIR" ];then
_debug "QTDIR was set to '$QTDIR'"
unset QTDIR
 if [ "$QTDIR" ];then
    _warn "Failed unset QTDIR"
 fi
fi

if test "$DEBUG"; then
if [ -d /opt ];then
ls -1d /opt/qt* >$OUT && qt_OPT=Y
fi
fi

if [ "$qt_OPT" ];then
_debug "Found QT in /opt directory"
for d in `ls -d1 /opt/qt*`;do
QTDIR="$d"
QT_QMAKE_EXECUTABLE=`/bin/find $d/bin -name qmake       |head -n1`
  QT_MOC_EXECUTABLE=`/bin/find $d/bin -name moc         |head -n1`
  QT_RCC_EXECUTABLE=`/bin/find $d/bin -name rcc         |head -n1`
  QT_UIC_EXECUTABLE=`/bin/find $d/bin -name uic         |head -n1`
     QT_INCLUDE_DIR=`/bin/find $d -type d -name include |head -n1`
     QT_LIBRARY_DIR=`/bin/find $d -type d -name lib     |head -n1`
  QT_QTCORE_LIBRARY=`/bin/find $d/lib -type f -iname "*core*.so*" |head -n1`
done
elif [ -d /usr/lib/qt ]; then
  QTDIR=/usr/lib/qt
  _info "QTDIR set to '$QTDIR'"
else
  # Find the newest Qt directory and set $QTDIR to that:
  for qtd in /usr/lib/qt-* ; do
    if [ -d "$qtd" ]; then
      QTDIR=$qtd
      _notice "QTDIR set to '$QTDIR'"
    fi
  done
fi

if [ "$CPLUS_INCLUDE_PATH" != "" ]; then
  CPLUS_INCLUDE_PATH=$QTDIR/include:$CPLUS_INCLUDE_PATH
else
  CPLUS_INCLUDE_PATH=$QTDIR/include
fi
_info "CPLUS_INCLUDE_PATH set to '$CPLUS_INCLUDE_PATH'"

if [ -d "$QTDIR" ];then
_info "QTDIR='$QTDIR' is a directory: OK"
PATH="$PATH:$QTDIR/bin"
export PATH
export QTDIR
export QT_QMAKE_EXECUTABLE QT_MOC_EXECUTABLE QT_RCC_EXECUTABLE QT_UIC_EXECUTABLE
export QT_INCLUDE_DIR QT_LIBRARY_DIR
export QT_QTCORE_LIBRARY
export CPLUS_INCLUDE_PATH
fi
