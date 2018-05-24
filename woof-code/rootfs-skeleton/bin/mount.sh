#!/bin/ash

IS_MULTICALL=1
FSTAB_FILE=/etc/fstab
VERSION=2.5.1
. /etc/rc.d/f4puppy5

__debugt__(){  #$1 label #$2 time

test "$DEBUGT" || return 0
#unset LANG LC_ALL
local _TIME_ LC_NUMERIC=C LC_TIME=C LANG= LC_ALL=
_DATE_=`date +%s.%N | sed 's:.*\(..\..*\):\1:'`
#_DATE_=`date +%s,%N | sed 's:.*\(..\,.*\):\1:'`
if test "$2"; then
_TIME_=`dc $_DATE_ $2 \- p`
echo "$0:TIME:$1:$_TIME_"
else
#echo "$0:TIME:$*:`date +%s.%N | sed 's:.*\(..\..*\):\1:'`"
echo "$0:TIME:$*:$_DATE_"
fi
}

_debugt 8F
test "$*" || exec busybox mount
test "$#" = 2 -a "$1" = '-t' && exec busybox mount "$@"
_debugt 8E $_DATE_

Q=-q
QUIET=--quiet
# To prevent ROX-Filer presenting fake error messages,
# unset lesser important messages - set to ANY if you want to
NOTICE=
INFO=
DEBUG=
DEBUGX=
DEBUGT= #time debugging
test "$DEBUG" && { unset Q QUIET; }

_debug "$@:$*"

LANG_ROX=$LANG  # ROX-Filer may complain about non-valid UTF-8
#echo $LANG | grep $Q -i 'utf' || LANG_ROX=$LANG.UTF-8
[ "$LANG" = 'C' ] || { echo $LANG | grep $Q -i 'utf' || LANG_ROX=$LANG.utf8; }
_info "using '$LANG_ROX'"

#busybox mountpoint does not recognize after
#mount --bind / /tmp/ROOTFS
#/tmp/ROOTFS as mountpoint ...
#but does for mount --bind / /tmp/SYSFS and bind mount of /proc ..???
#so using function with grep instead
__mountpoint__(){
 #test -L /proc/mounts -a -f /proc/mounts || return 3
 #_test_Lef /proc/mounts && _test_Led /proc/self || return 3
 stat -f -c %T /proc 2>>$ERR | grep $Q '^proc$' || return 3
 test "$*" || return 2
 [ "$1" = '-q' ] && shift;
 #set - `echo "$*" | sed 's!\ !\\\040!g'`
 set - ${*//\\/\\\\}
 _debug "mountpoint:$*"
 grep $Q " $* " /proc/mounts
 return $?; }

__check_proc__()
{
 _debug "_check_proc:mountpoint $Q /proc"
  mountpoint $Q /proc && return $? || {
  busybox mount ${VERB:+'-vv'} -o remount,rw /dev/root /
  test -d /proc || mkdir $VERB -p /proc
  busybox mount ${VERB:+'-vv'} -t proc proc /proc
  return $?
 }
}

__check_tmp__()
{
 test -d /tmp && return $? || {
 busybox mount ${VERB:+'-vv'} -o remount,rw /dev/root /
 mkdir $VERB -p /tmp
 chmod $VERB 1777 /tmp
 return $?
 }
}

__check_tmp_rw__()
{
 _check_proc
 _check_tmp

_debug "_check_tmp_rw:mountpoint $Q /tmp"
mountpoint $Q /tmp && {
grep -w '/tmp' /proc/mounts | cut -f4 -d' ' | grep $Q -w 'rw' && return 0 || { busybox mount ${VERB:+'-vv'} -o remount,rw tmpfs /tmp; return $?; }
 } || {
grep '^/dev/root' /proc/mounts | cut -f4 -d' ' | grep $Q -w 'rw' && return 0 || { busybox mount ${VERB:+'-vv'} -o remount,rw /dev/root /; return $?; }
 }

}

__string_to_octal()
{
#_store_program_logging_level

_debug "__string_to_octal:$*"
unset oSTRING
if test "$*"; then
STRING_ORIG="$*"

STRING=`echo "$STRING_ORIG" | sed 's!\(.\)!"\1"\n!g'`
_debug "__string_to_octal:STRING='$STRING'"


while read -r oneCHAR
do

#test "$oneCHAR" || oneCHAR=$'"\n"'
test "$oneCHAR" && {
oneCHAR=`echo "$oneCHAR" | sed 's!^"!!;s!"$!!'`
oCHAR=`printf "%o" \'"$oneCHAR"`
} || oCHAR=12

oSTRING=$oSTRING"\\0$oCHAR"

done <<EoI
`echo "$STRING"`
EoI

else

while read -r oneLINE
do
#test "$oneLINE" || continue
 _debug "oneLINE='$oneLINE'"
 STRING=`echo "$oneLINE" | sed 's!\(.\)!"\1"\n!g'`
 _debugx "STRING='$STRING'"
 while read -r oneCHAR
 do
 _debugx "oneCHAR='$oneCHAR'"
 #test "$oneCHAR" || oneCHAR='" "'
 test "$oneCHAR" && {
 _debugx "oneCHAR='$oneCHAR'"
 oneCHAR=`echo "$oneCHAR" | sed 's!^"!!;s!"$!!'`
 _debug "oneCHAR='$oneCHAR'"
 oCHAR=`printf "%o" \'"$oneCHAR"`
 _debug "oCHAR='$oCHAR'"
 } || oCHAR=12
 #test "$oCHAR" = 134 && oCHAR=0134

 oSTRING=$oSTRING"\\0$oCHAR"
 _debugx "oSTRING='$oSTRING'"

 done <<EoI
`echo "$STRING"`
EoI

oSTRING=$oSTRING"\\012"
done

fi

echo "$oSTRING"
#_reset_program_logging_level
}

_posparams_to_octal()
{
_debug "_posparams_to_octal:$@"

#posPARAMS=`echo "$@" | _string_to_octal`
 posPARAMS=`__string_to_octal "$@"`
posPARAMS=`echo $posPARAMS | tr -d ' '`
#try to handle newline
posPARAMS=`echo "$posPARAMS" | sed 's!\\\0134\\\0156!NEWLINE!g'`

#convert to newline again
posPARAMS=`echo "$posPARAMS" | sed 's!\\\012\\\!\n\\\!g'`
_debugx "            posPARAMS='$posPARAMS'"

#get rid of \0 - why?
posPARAMS=`echo "$posPARAMS" | sed 's!\\\\0$!!g'`
_debug "             posPARAMS='$posPARAMS'"

}

_get_options()
{

allOPS=AaBbCcDdEeFfGgHhIiJjKkL:lMmNnO:o:Pp:QqRrSsT:t:U:uVvWwXxYyZz-

umount_longOPS=all,all-targets,no-canonicalize,detach-loop,fake,force,internal-only,no-mtab,lazy,test-opts:,recursive,read-only,types:,verbose,help,version
 mount_longOPS=all,no-canonicalize,fake,fork,fstab:,internal-only,show-labels,no-mtab,options:,test-opts:,read-only,types:,source:,target,verbose,rw,read-write,label,uuid,help,version
 mount_longOPS="$mount_longOPS",bind,rbind,move,make-private,make-rprivate,make-shared,make-rshared,make-slave,make-rslave,make-unbindable,make-runbindable

  #getOPS=`busybox getopt -u -l help,version,bind,rbind,move,make-private,make-rprivate,make-shared,make-rshared,make-slave,make-rslave,make-unbindable,make-runbindable -- $allOPS "$@"`
 getOPS=`busybox getopt -s tcsh -l help,version,bind,rbind,move,make-private,make-rprivate,make-shared,make-rshared,make-slave,make-rslave,make-unbindable,make-runbindable -- $allOPS "$@"`
 getoptRV=$?
_debug "                options='$getOPS'"

 #longOPS=`echo "$getOPS" | grep -Eoe '--[^ ]+' | tr '\n' ' ' |sed 's! --$!!;s! -- $!!;s!-- !!'`
 longOPS=${getOPS% -- *}
_debugx "           long options='$longOPS'"
 longOPS=`echo "$longOPS" | grep -Eoe '--[^ ]+' | tr '\n' ' ' |sed 's! --$!!;s! -- $!!;s!-- !!'`
 test "${longOPS//[[:blank:]]/}" || longOPS='';
_debug "           long options='$longOPS'"

shortOPS=${getOPS%%--*}
_debugx "          short options='$shortOPS'"
shortOPS=`echo "$shortOPS" | sed "s%'%%g"`
test "${shortOPS//[[:blank:]]/}" || shortOPS='';
_debug "          short options='$shortOPS'"

posPARAMS=${getOPS#*-- }
_debugx "positional parameters='$posPARAMS'"
posPARAMS=`echo "$posPARAMS" | sed 's!--$!!'`
_debugx "positional parameters='$posPARAMS'"

posPARAMS=`echo "$posPARAMS" | sed "s%' '%'\n'%g"`
_debugx "positional parameters='$posPARAMS'"

#util-linux/getopt.c
#if (*arg == '\'')
#           *bufptr ++= '\'';
#           *bufptr ++= '\\';
#           *bufptr ++= '\'';
#           *bufptr ++= '\'';
posPARAMS=`echo "$posPARAMS" | sed "s%'\\\\\\\''%\'%g"`    # ' ## tr -s "'"

#else if (shell_TCSH && *arg == '!')
#           *bufptr ++= '\'';
#           *bufptr ++= '\\';
#           *bufptr ++= '!';
#           *bufptr ++= '\'';
posPARAMS=`echo "$posPARAMS" | sed "s%'\\\\\\\!'%\!%g"`    # !

#else if (shell_TCSH && isspace(*arg))
#           *bufptr ++= '\'';
#           *bufptr ++= '\\';
#           *bufptr ++= *arg;
#           *bufptr ++= '\'';
posPARAMS=`echo "$posPARAMS" | sed "s%'\\\\\\\	'%\	%g"`   # tab   011
posPARAMS=`echo "$posPARAMS" | sed "s%'\\\\\\\ '%\ %g"`    # space 040

#else if (shell_TCSH && *arg == '\n')
#           *bufptr ++= '\\';
#           *bufptr ++= 'n';
# posPARAMS=`echo "$posPARAMS" | sed "s%\\\\\\\n%\n%g"`    # newline 012
# done in _posparams_to_octal

# else
#           /* Just copy */
#           *bufptr ++= *arg;

#posPARAMS=`echo "$posPARAMS" | sed "s%'\\\\\\\\'%\\\\\%g"` # \ #

_debugx "positional parameters='$posPARAMS'"
posPARAMS=`echo "$posPARAMS" | sed "s%^'%%;s%'$%%"`
_debugx "positional parameters='$posPARAMS'"

test "$posPARAMS" = "$shortOPS" && posPARAMS='' || _debugx "posPARAMS NOT same as shortOPS";
_debugx "positional parameters='$posPARAMS'"

test "$posPARAMS" && _posparams_to_octal "$posPARAMS"
_debug "  positional parameters='$posPARAMS'"

return $getoptRV
}

_get_options "$@" || _exit 1 "Error while processing parameters."
_debugt 8C $_DATE_

test -f /proc/mounts && mountBEFORE=`cat /proc/mounts`

_update_partition_icon()
{

test -f /etc/eventmanager.cfg && . /etc/eventmanager.cfg
#test "`echo "$ICONPARTITIONS" | grep -i 'true'`" || return 0
case $ICONDESK in true|True|TRUE|on|On|ON|yes|Yes|YES|y|Y|1) :;; *) return 0;; esac

test -f /etc/rc.d/functions4puppy4  && . /etc/rc.d/functions4puppy4
#test -f /etc/rc.d/pupMOUNTfunctions && . /etc/rc.d/pupMOUNTfunctions

test -f /proc/mounts && mountAFTER=`cat /proc/mounts`
_debugt 99 $_DATE_
test "$mountBEFORE" -a "$mountAFTER" && {
        grepMA=`echo "$mountAFTER"  | sed 's!\\\!\\\\\\\!g'` || _exit 33 "sed failed to escape backslash"
        grepMB=`echo "$mountBEFORE" | sed 's!\\\!\\\\\\\!g'`
        updateWHATA=`echo "$mountAFTER"  | _command grep -v "$grepMB"`
        updateWHATB=`echo "$mountBEFORE" | _command grep -v "$grepMA"`
        updateWHAT="$updateWHATA
$updateWHATB";
        updateWHAT=`echo "$updateWHAT" | awk '{print $1 " " $2}' | uniq`
}

_debugt 9f $_DATE_
 _check_tmp_rw || return 56
_debugt 9e $_DATE_

 while read -r oneUPDATE oneMOUNTPOINT REST  #REST ist just in case since it is reduced to $1 and $2 above
 do
 _debug "_update_partition_icon:'$oneUPDATE' '$oneMOUNTPOINT' '$REST'"

 test "$oneUPDATE" || continue
 case $oneMOUNTPOINT in
 *\\011*) oneMOUNTPOINT=`echo "$oneMOUNTPOINT" | sed -r 's!(\\\011)!\t!g'`;;
 *\\012*) oneMOUNTPOINT=`echo "$oneMOUNTPOINT" | sed -r 's!(\\\012)!\n!g'`;;
 *\\040*) oneMOUNTPOINT=`echo "$oneMOUNTPOINT" | sed -r 's!(\\\040)! !g'`;;
 esac
 eoneMOUNTPOINT=`echo -e "$oneMOUNTPOINT"`
 _debug "_update_partition_icon:'$oneUPDATE' '$eoneMOUNTPOINT' '$REST'"
_debugt 9d $_DATE_

 test "$noROX" || { _pidof $Q ROX-Filer && {
      test -d "${eoneMOUNTPOINT%/*}" && rox -x "${eoneMOUNTPOINT%/*}"
         test -d "${eoneMOUNTPOINT}" && rox -x "${eoneMOUNTPOINT}"
         rox -D "${eoneMOUNTPOINT}"
         mountpoint $Q "${eoneMOUNTPOINT}" && rox -d "${eoneMOUNTPOINT}" || :
         }
        }
 _debugt 9c $_DATE_

 # REM: Remember myself: Have renamed DRV_CATEGORY to DISK_CATEGORY since it uses probedisk(2) not probedrive
 case $oneUPDATE in
 *loop*|*md*|*mtd*|*nbd*|*ram*|*zram*) _debug "Got loop, md, mtd, nbd, ram, zram -- won't update partition icon"; skipICON=YES ; continue;;
 /dev/fd[0-9]*)                     DISK_CATEGORY=floppy ;;
 /dev/sr*|/dev/scd*|/dev/hd[a-d])   DISK_CATEGORY=optical;;
 /dev/mmc*)                         DISK_CATEGORY=card   ;;
 /dev/*) DISK_CATEGORY=`probedisk2 | grep -w "${oneUPDATE:0:8}" | cut -f2 -d'|'`;
         _debug "DISK_CATEGORY='$DISK_CATEGORY'"
         test "$DISK_CATEGORY" || continue;;
 *) _debug "Got '$oneUPDATE' -- won't update partition icon"; skipICON=YES ; continue;;
 esac
 _debugt 9b $_DATE_

 case $WHAT in
 umount)
 _debugt 98 $_DATE_

  if _command df | grep $Q -w "^$oneUPDATE"; then
   # umount -r re-mounted partiton read-only or is boot partition
   _icon_mounted ${oneUPDATE##*/} $DISK_CATEGORY #see functions4puppy4
  else
   _debug "_update_partition_icon:$oneUPDATE is not boot partition"
   # redraw icon without "MNTD" text...
   _icon_unmounted ${oneUPDATE##*/} $DISK_CATEGORY #see functions4puppy4
  fi

 _debugt 97 $_DATE_
 ;;
 mount)
 _debugt 96 $_DATE_
 _debugx "_icon_mounted ${oneUPDATE##*/} $DISK_CATEGORY"
      _icon_mounted ${oneUPDATE##*/} $DISK_CATEGORY
 _debugt 95 $_DATE_
 ;;
 *) _err "_update_partition_icon:'$WHAT' not handled.";;
 esac

 done <<EoI
`echo "$updateWHAT"`
EoI
}

_mount_all_in_fstab()
{
test -f "$FSTAB_FILE" || return 57

while read -r device mountpoint fstype mntops dump check
do

test "$device" -a "$mountpoint" || continue
test "`echo "$device" | sed 's,[^#]*,,g'`" && continue

case $WHAT in
 mount)
  _debug "_mount_all_in_fstab:$WHAT:'$device' '$mountpoint' -t '$fstype' -o '$mntops'"

  test "$fstype" = swap && continue
  grep $Q -w "${device##*/}" /proc/partitions || continue   # continue if not in /proc/partitions
  test -d "$mountpoint" || LANG=$LANG_ROX mkdir $VERB -p "$mountpoint"
  _debug "_mount_all_in_fstab:$WHAT:mountpoint $Q \"$mountpoint\""
  mountpoint $Q "$mountpoint" && continue

  mountBEFORE=`cat /proc/mounts`
  busybox $WHAT $device "$mountpoint" -t $fstype -o $mntops
  RV=$?
  STATUS=$((STATUS+RV))
  noROX=1
  test "$RV" = 0 && { _update_partition_icon || :; } || rmdir $VERB "$mountpoint"
 ;;

umount)
  case $opT in
  -t) echo "$opT_ARGS" | grep $Q -w "$fstype" || continue ;;
  esac
  case $opO in
  -O) echo "$mntops" | grep $Q -E "$opO_ARGS" || continue ;;
  esac

  _debug "_mount_all_in_fstab:$WHAT:mountpoint='$mountpoint'"

                allSUB_MOUNTS=`losetup -a | grep -w "$mountpoint" | tac`
                _check_tmp_rw || return 58
                while read -r loop nr loopmountpoint
                do
                test "$loop" || continue
                echo "$loop is mounted on $loopmountpoint"
                #busybox umount -d $loop || return 3
                sleep 1
                done <<EoI
                `echo "$allSUB_MOUNTS"`
EoI

  _debug "_mount_all_in_fstab:$WHAT:mountpoint $Q \"$mountpoint\""
  mountpoint $Q "$mountpoint" && {
     mountBEFORE=`cat /proc/mounts`
     _pidof $Q ROX-Filer && rox -D "$mountpoint"
     busybox $WHAT "$mountpoint"
     RV=$?
     test $RV = 0 && _update_partition_icon
     STATUS=$((STATUS+RV))
    }

  #echo $device
  grep $Q -w "^$device" /proc/mounts || continue
  #umount $device
  ;;
*) _err "_mount_all_in_fstab:Got unhandled '$WHAT' -- use 'mount' or 'umount'"; break;;
esac

done <"$FSTAB_FILE"

return $STATUS
}

case $0 in
*umount*|*unmount*) WHAT=umount;;
*mount*)            WHAT=mount;;
*) _exit 38 "No such '$0' -- use 'mount' or 'umount' .";;
esac
_debugt 89 $_DATE_

_builtin_getopts()
{

local oneOPT
opN=-n;
case $WHAT in
umount)
 opFL=-d;

 while getopts $allOPS oneOPT; do
 noSHIFT=NO
 case $oneOPT in
 -*) #long options ?
  noSHIFT=YES;;
 a) #all
  opALL=-a;;
 A) #all-targets
  opAT=-A;;
 c) # no cononicalize
  opC=-c;;
 d) #free loop
  opFL=-d;;
 D) #don't free loop
  opNFL=-D;;
 f) #force
  opF=-f;;
 h) #help
  opH=-h;;
 i) #ignore helper
  opI=-i;;
 l) #lazy
  opL=-l;;
 n) # don't write into /etc/mtab
  opN=-n;;
 r) #read-only
  opR=-r;;
 R) # recurse
  opREC=-R;;
 v) #verbose
  opVERB=-v;;
 V) #version
  opVERS=-V;;
 O) #fs options
  opO=-O
  opO_ARGS="$OPTARG"
  opO_ARGS="${opO_ARGS//,/|}"
  shift
  ;;
 t) #fs type
  opT=-t
  opT_ARGS="$OPTARG"
  shift
 ;;
 *)
  #shift
  _notice "Unhandled option \"$oneOPT\""
 ;;
 esac
 test "$noSHIFT" = YES || shift
 #unset noSHIFT
 done

;;
 mount)

 while getopts $allOPS oneOPT; do
 noSHIFT=NO
 _debug "oneOPT='$oneOPT'"
 case $oneOPT in
  -*) #long options ?
   noSHIFT=YES;;
  a) # all
   opALL=-a;;
  B) # bind
   opB=-B;;
  c) #no canonicalize
   opC=-c;;
  f) #fake dry-run
   opDRY=-f;;
  F) # FORK while using -a
   opFORK=-F;;
  h) # help
   opH=-h;;
  i) #don'use mount helper
   opI=-i;;
  l) #list, and show label if label exists
   opSHOWL=-l;;
  L) # mount label
   mLABEL=$OPTARG
   opLABEL="-L $mLABEL"
   shift
  ;;
  M) # move
   opM=-M;;
  n) # don't write to /etc/mtab
   opN=-n;;
  o) #mount options
   ops=$OPTARG
   opMO="-o $ops"
   shift
  ;;
  O) # mount options for -a
   opO=-O
   opO_ARGS="$OPTARG"
   opO_ARGS="${opO_ARGS//,/|}"
   shift
  ;;
  p) # passphrase from file_descriptor
   fd=$OPTARG
   opPASS="-p $fd"
   shift
  ;;
  r) #read-only
   opR=-r;;
  R) # rbind
   opRB=-R;;
  s) # sloppy
   opS=-s;;
  t) #filesystem type
   opT=-t
   opT_ARGS="$OPTARG"
   #fsTYPE=$OPTARG
   opT="-t $opT_ARGS"
   shift
  ;;
  T) # altern. fstab file
   opAF=-T
   opAF_ARGS="$OPTARG"
   opAF="-T $opAF_ARGS"
   FSTAB_FILE="$opAF_ARGS"
   shift
  ;;
  U) #mount UUID
   uLABEL=$OPTARG
   opUUID="-U $uLABEL"
   shift
  ;;
  v) #verbose
   opVERB=-v;;
  V) #version
   opVERS=-V;;
  w) # read-write, same as -o rw
   opW=-w;;
  *)
   #shift
   _notice "Unhandled option \"$oneOPT\""
  ;;
 esac
  test "$noSHIFT" = YES || shift
  #unset noSHIFT
 done

;;
 *) _exit 39 "Unhandled '$WHAT' -- use 'mount' or 'umount' .";;
esac

}
_builtin_getopts "$@"
_debugt 88 $_DATE_

_debug '4*:'$*

set - $longOPS $shortOPS $posPARAMS
_debug '5@:'$@
_debug "6:$WHAT "$@ $opFL $opNFL $opF $opI $opN $opR $opL $opVERB $opMO $opS $opW $opLABEL $opUUID $opSHOWL $opT

test "$opALL" && _debug "opALL='$opALL'"

if   test "$opALL" == "-a"; then
        _warn "${WHAT}ing all entries in '$FSTAB_FILE'..."
        _mount_all_in_fstab
exit $?

elif test "$opVERS" == "-V" -o "$1" == "--version"; then
        _notice "version of $WHAT-FULL:"
        $WHAT-FULL -V
        echo
        _notice "version of busybox:"
        busybox | head -n1
exit 0

elif test "$opH" == "-h" -o "$1" == "--help"; then
        _notice "help for $WHAT-FULL:"
        $WHAT-FULL -h
        echo
        _notice "help for busybox $WHAT:"
        busybox $WHAT --help
exit 0

fi
_debugt 87 $_DATE_

_debug "8@:"$@
_debug "9:$WHAT "$@ $opFL $opNFL $opF $opI $opN $opR $opL $opVERB $opMO $opS $opW $opLABEL $opUUID $opSHOWL $opT

( test "$*" -o "$opUUID" -o "$opLABEL" || test "$opT" -o "$opSHOWL" ) || _exit 1 "No positional parameters left."

case $# in
1)
deviceORpoint=`echo -e "$@" | sed 's!NEWLINE!\n!g'`
_debug "deviceORpoint='$deviceORpoint'"
;;
esac
_debugt 86 $_DATE_

case $WHAT in
mount)
if test "$deviceORpoint"; then
 _debug "$WHAT:"$@

 if test -b "$deviceORpoint"; then
  grep $Q -w "${deviceORpoint##*/}" /proc/partitions && {
   _notice "found '${deviceORpoint##*/}' in /proc/partitions"
  _FS_TYPE_=`guess_fstype $deviceORpoint`
  case $_FS_TYPE_ in
  xfs) HAVE_XFS=1;;
  esac
  } || {
   _warn "'${deviceORpoint##*/}' not found in /proc/partitions"; }
 fi

 test -e "$FSTAB_FILE" || touch "$FSTAB_FILE"
 grep $Q -w "$deviceORpoint" "$FSTAB_FILE" && {
  _notice "Found $deviceORpoint in '$FSTAB_FILE'"

  mountPOINT=`grep -m1 -w "$deviceORpoint" "$FSTAB_FILE" | awk '{print $2}'`
  deviceNODE=`grep -m1 -w "$deviceORpoint" "$FSTAB_FILE" | awk '{print $1}'`
  _debug "fstab: mountPOINT='$mountPOINT'"
  _debug "fstab: deviceNODE='$deviceNODE'"

  mountpoint $Q "$mountPOINT" && {
      test "`echo "$opMO" | grep 'remount'`" || _exit 3 "fstab: '$mountPOINT' already mounted. Use -o remount."; }
  test "$*" = "$mountPOINT" || set - $@ "$mountPOINT"
  test -e "$mountPOINT" && { _debug "fstab: $mountPOINT exists"; } || { _info "fstab: Creating $mountPOINT"; LANG=$LANG_ROX mkdir $VERB -p "$mountPOINT"; }
 } || { test "$*" = "$deviceORpoint" && {
         posPARAMS="$posPARAMS /mnt/${deviceORpoint##*/}"; set - "$deviceORpoint" "/mnt/${deviceORpoint##*/}"; }
          }
 _debug "$WHAT:"$@
fi

c=0
#for posPAR in `echo -e "$@"`; do  #hope, only file/device AND mountpoint left
 for posPAR in `echo    "$@"`; do  #hope, only file/device AND mountpoint left
c=$((c+1))
_debug "posPAR='$posPAR'"

case $posPAR in
-*)         :;; #break
none|nodev) :;;
shmfs)      :;;

adfs|affs|autofs|cifs|coda|coherent|cramfs|debugfs|devpts)       :;;
efs|ext|ext2|ext3|ext4|hfs|hfsplus|hpfs|iso9660|jfs|minix)         :;;
msdos|ncpfs|nfs|nfs4|ntfs|proc|qnx4|ramfs|reiserfs|romfs)            :;;
smbfs|sysv|tmpfs|udf|ufs|umsdos|usbfs|usbdevfs|vfat|xenix|xfs|xiafs) :;;
fuse*) :;;

*) test $c = $# || continue  # want the last parameter
   if test -f /proc/filesystems; then

   _debug "c=$c \$#=$# "$posPAR
o_ocposPAR="$posPAR"
   posPAR=`echo -e "$posPAR" |sed 's!NEWLINE!\n!g'` #need to handle space
o_posPAR="$posPAR"
   _debug "c=$c \$#=$# ""$posPAR"

   if test ! "`grep 'nodev' /proc/filesystems | grep "$posPAR"`"; then
   gPATTERN="${posPAR// /\\040}";gPATTERN="${gPATTERN//\\t/\\011}" #TAB
   gPATTERN="${gPATTERN//\\n/\\012}"
   _debugx "gPATTERN=$gPATTERN"
   grep -Fw "${gPATTERN}" /proc/mounts | grep $Q -vi fuse && {
       test "`echo "$opMO" | grep 'remount'`" ||  _exit 3 "not fuse: $posPAR already mounted. Use -o remount."; }

   test -e "$FSTAB_FILE" || touch "$FSTAB_FILE"
   grepPAR=`echo "$posPAR" | sed 'sV\([[:punct:]]\)V\\\\\\1Vg'`
   mountPOINT=`grep -F -m1 -w "$grepPAR" "$FSTAB_FILE" | awk '{print $2}'`
   deviceNODE=`grep -F -m1 -w "$grepPAR" "$FSTAB_FILE" | awk '{print $1}'`
   _debugx "fstab: mountPOINT='$mountPOINT'"
   _debugx "fstab: deviceNODE='$deviceNODE'"

   test "$mountPOINT" && { posPAR="$mountPOINT"
   _debug "Found '$posPAR' in '$FSTAB_FILE' -- using '$mountPOINT' as mount-point."; }

   _debugx "testing -b $posPAR"
   test -b "$posPAR" && posPAR="/mnt/${posPAR##*/}"

   _debugx "testing -d $posPAR"
   test -d "$posPAR" && test ! "`ls -A "$posPAR" 2>$ERR`" && mountPOINT="$posPAR"

   _debugx "testing -e $posPAR" #TODO if exist and has contents error out
   test -e "$posPAR" && { _debugx "`ls -lAv "$posPAR" 2>&1`"; true; } || { _notice "Assuming '$posPAR' being mountpoint..";
   LANG=$LANG_ROX mkdir $VERB -p "$posPAR"; mountPOINT="$posPAR"; }  ##BUGFIX 2014-11-27 need to set mountPOINT variable

   _debugx "posPAR='$posPAR'"
ocposPAR=`echo "$posPAR" | _string_to_octal`
   _debugx "ocposPAR='$ocposPAR'"

ocposPAR=`echo "$ocposPAR" | sed 's!\\\\0$!!g'`
_debug "             ocposPAR='$ocposPAR'"

   test -b "$o_posPAR" && posPARAMS="$posPARAMS $ocposPAR"
   fi;fi ;;
esac
done
c=0

;;
umount)
 # handle unmounting of no-existent dir
 # give better error message instead 'invalid argument'
  if test "$deviceORpoint"; then
   test -b "$deviceORpoint" || {
    mountpoint $Q "$deviceORpoint" || { _warn "'$deviceORpoint' not a current mountpoint"; }
   }
  fi

 :;;
*) _exit 40 "Unhandled '$WHAT' -- use 'mount' or 'umount' ."
;;
esac
_debugt 85 $_DATE_

case $WHAT in
umount)
if test "$deviceORpoint"; then
 mountpoint $Q /proc && {
 NTFSMNTPT=`_command ps -eF | grep -Eo 'ntfs\-3g.+' | grep -w "$deviceORpoint" | tr '\t' ' ' | tr -s ' ' | tr ' ' "\n" | grep '^/mnt/'`
 NTFSMNTDV=`_command ps -eF | grep -Eo 'ntfs\-3g.+' | grep -w "$deviceORpoint" | tr '\t' ' ' | tr -s ' ' | tr ' ' "\n" | grep '^/dev/'`
 _debug "NTFSMNTPT='$NTFSMNTPT' NTFSMNTDV='$NTFSMNTDV'"
 }
fi
;;
mount) :;;
*) _exit 41 "Unhandled '$WHAT' -- use 'mount' or 'umount' .";;
esac
_debugt 84 $_DATE_

case $WHAT in
umount)
if test "$deviceORpoint"; then
grepP=${deviceORpoint// /\\040};grepP=${grepP//\\t/\\011}; #TAB
grepP="${grepP//\\n/\\012}"
_debug "grepP='$grepP'"
mountPOINT=`echo "$mountBEFORE" | grep -Fw "$grepP" | cut -f 2 -d' '`
_debug "mountPOINT='$mountPOINT'"
case $mountPOINT in
*\\011*) mountPOINT=`echo "$mountPOINT" | sed -r 's!(\\\011)!\t!g'`;;
*\\012*) mountPOINT=`echo "$mountPOINT" | sed -r 's!(\\\012)!\n!g'`;;
*\\040*) mountPOINT=`echo "$mountPOINT" | sed -r 's!(\\\040)! !g'`;;
esac
_debug "mountPOINT='$mountPOINT'"
mountPOINT=`busybox echo -e "$mountPOINT"`
_debug "mountPOINT='$mountPOINT'"
fi
        if test -d "$mountPOINT"; then
        _debug "Closing ROX-Filer if necessary..."
        _pidof $Q ROX-Filer && rox -D "$mountPOINT";
        _debug "Showing Filesystem user PIDs of '$mountPOINT':"
        #fuser -m "$mountPOINT" >>$OUT 2>>$ERR && {
         fuser $VERB -m "$mountPOINT" 1>&2 && {
           if test "$opL" -o "$opF"; then
           _warn "^Mountpoint is in use by above pids^"
           else
           _err "^Mountpoint is in use by above pids^"
           fi
                for aPID in `fuser -m "$mountPOINT"`
                do
                fsUSERS="$fsUSERS
`ps -o pid,ppid,args | grep -wE "$aPID|^PID" | grep -vE 'grep|xmessage'`
                "
                done
                _debug "fsUSERS=
fsUSERS"
                fsUSERS=`echo "$fsUSERS" | sort -u` ###+++2015-11-08
                _notice "fsUSERS=
$fsUSERS"
           if test "$opL" -o "$opF"; then
           :
           else
                test "$DISPLAY" && {
                # REM: Since drive_all runs umount twice, want to kill previous xmessage
                FORMER_XMESSAGE=`ps -o pid,args | grep 'xmessage' | grep -v 'grep' | grep -e "-title $WHAT" | awk '{print $1}'`
                for x in $FORMER_XMESSAGE; do kill $x; done

                    xmessage -bg red -title "$WHAT" "$mountPOINT is in use by these PIDS:
$fsUSERS" &
                }
                _notice "Use -l or -f option to skip this sanity check."
                _exit 1 "Refusing to complete $WHAT $@ ."
           fi
         }
        fi
;;
mount) :;;
*) _exit 42 "Unhandled '$WHAT' -- use 'mount' or 'umount' .";;
esac
_debugt 83 $_DATE_

case $WHAT in
umount)

set --  #unset everything
set - $longOPS $shortOPS

for onePAR in $posPARAMS
do
ePAR="`echo -e "$onePAR" | sed 's!NEWLINE!\n!g'`"
_debugx "ePAR='$ePAR'"
set - $@ "$ePAR"
done


if [ "$NTFSMNTPT" != "" ]; then
        if [ "$opI" == '-i' ]; then #fusermount passes -i option to /bin/mount
        _notice busybox $WHAT "$@" $opFL $opNFL $opF $opI $opN $opR $opL $opVERB
                busybox $WHAT "$@" $opFL $opNFL $opF $opI $opN $opR $opL $opVERB
        RETVAL=$?
        else
        #fusermount can only unmount by giving the mount-point...
        _notice fusermount -u "$NTFSMNTPT"
                fusermount -u "$NTFSMNTPT"
        RETVAL=$?
        fi
else
 _info  busybox $WHAT "$@" $opFL $opNFL $opF $opI $opN $opR $opL $opVERB
        busybox $WHAT "$@" $opFL $opNFL $opF $opI $opN $opR $opL $opVERB
 RETVAL=$?
fi
;;
mount)

_do_mount_ntfs_3g()
{
set --  #unset everything

for onePAR in $posPARAMS
do
ePAR="`echo -e "$onePAR" | sed 's!NEWLINE!\n!g'`"
_debugx "ePAR='$ePAR'"
set - $@ "$ePAR"
done

       test -b "$*" && {   #ntfs-3g does not look into /etc/fstab?

        test "`which ntfs-3g.probe`" && {
         _debug "Running ntfs-3g.probe --readwrite on $@:"
         ntfs-3g.probe --readwrite "$@"
         RETVAL=$?
         test "$RETVAL" = 0 && _debug "OK."
                }

        LANG=$LANG_ROX mkdir $VERB -p "/mnt/${@##*/}"; set - $@ "/mnt/${@##*/}"; _debug "ntfs:$@";
        }

       test "$RETVAL" || RETVAL=0

       test "$RETVAL" = 0 && {
       _notice  ntfs-3g -o umask=0,no_def_opts "$@" $opVERB $opLABEL $opUUID $opDRY $opO $opR $opW $opI $opS $opSHOWL
                ntfs-3g -o umask=0,no_def_opts "$@" $opVERB $opLABEL $opUUID $opDRY $opO $opR $opW $opI $opS $opSHOWL
       RETVAL=$?
        }

       test "$RETVAL" = 0 || {
               if test "$RETVAL" = 14; then { _warn "Need to remove hibernation file to mount read-write";
                 _notice ntfs-3g "$@" -o umask=0,no_def_opts,remove_hiberfile $opVERB $opLABEL $opUUID $opDRY $opO $opR $opW $opI $opS $opSHOWL
                         ntfs-3g "$@" -o umask=0,no_def_opts,remove_hiberfile $opVERB $opLABEL $opUUID $opDRY $opO $opR $opW $opI $opS $opSHOWL
                 RETVAL=$?
               }
             elif test "$RETVAL" = 4 -o "$RETVAL" = 10 -o "$RETVAL" = 15; then { _warn "Attempt to force read-write mount";
                 _notice ntfs-3g "$@" -o force,umask=0,no_def_opts $opVERB $opLABEL $opUUID $opDRY $opO $opT $opR $opW $opI $opS $opSHOWL
                         ntfs-3g "$@" -o force,umask=0,no_def_opts $opVERB $opLABEL $opUUID $opDRY $opO $opT $opR $opW $opI $opS $opSHOWL
                 RETVAL=$?
               }
             else { _err "Unhandled ntfs-3g return code '$RETVAL'"; } # 11:Wrong Option,No mountpoint specified ; 21:No such File or Dir
               fi
                        }
        test "$RETVAL" = 0 || { _notice "Will attempt to mount ntfs partition using the limited kernel driver";
         _notice busybox mount "$@" $opVERB $opLABEL $opUUID $opDRY $opO $opT $opR $opW $opI $opN $opS $opVERB
                 busybox mount "$@" $opVERB $opLABEL $opUUID $opDRY $opO $opT $opR $opW $opI $opN $opS $opVERB
         RETVAL=$?
         }

return $RETVAL
}

_do_mount_vfat()
{

set --  #unset everything
set - $longOPS $shortOPS

for onePAR in $posPARAMS
do
ePAR="`echo -e "$onePAR" | sed 's!NEWLINE!\n!g'`"
_debugx "ePAR='$ePAR'"
set - $@ "$ePAR"
done

       NLS_PARAM=''
        if [ -f /etc/keymap ];then #set in /etc/rc.d/rc.country
         KEYMAP="`cat /etc/keymap | cut -f 1 -d '.'`"
         case $KEYMAP in
          de|be|br|dk|es|fi|fr|it|no|se|pt)
           NLS_PARAM=',codepage=850'
          ;;
          slovene|croat|hu101|hu|cz-lat2|pl|ro_win)
           NLS_PARAM=',codepage=852,iocharset=iso8859-2'
          ;;
         esac
        fi
       _notice busybox mount -o shortname=mixed,quiet${NLS_PARAM} "$@" $opVERB $opLABEL $opUUID $opDRY $opO $opT $opR $opW $opI $opN $opS $opVERB
               busybox mount -o shortname=mixed,quiet${NLS_PARAM} "$@" $opVERB $opLABEL $opUUID $opDRY $opO $opT $opR $opW $opI $opN $opS $opVERB
       RETVAL=$?

return $RETVAL
}

_do_mount_full()
{

set --  #unset everything
set - $longOPS $shortOPS

for onePAR in $posPARAMS
do
ePAR="`echo -e "$onePAR" | sed 's!NEWLINE!\n!g'`"
_debugx "ePAR='$ePAR'"
set - $@ "$ePAR"
done

        if test "$opUUID"; then
         MntPoints=$(grep -w "`echo "$opUUID" | cut -f2 -d' '`" "$FSTAB_FILE" | awk '{print $2}')
         for oneMTP in $MntPoints; do
         test -d "$oneMTP" || LANG=$LANG_ROX mkdir $VERB -p "$oneMTP"
         done
        fi
        if test "$opLABEL"; then
         _debug "opLABEL='$opLABEL'"
         lONLY=`echo "$opLABEL" | cut -f2 -d' '`
         _debug "lONLY='$lONLY'"
         MntPoints=$(grep -w "$lONLY" "$FSTAB_FILE" | awk '{print $2}')
         for oneMTP in $MntPoints; do
         _debug "oneMTP='$oneMTP'"
         test -d "$oneMTP" || LANG=$LANG_ROX mkdir $VERB -p "$oneMTP"
         done
        fi
        _notice $WHAT-FULL "$@" $opVERB $opLABEL $opUUID $opDRY $opO $opMO $opT $opR $opW $opI $opN $opS $opFORK $opSHOWL
                $WHAT-FULL "$@" $opVERB $opLABEL $opUUID $opDRY $opO $opMO $opT $opR $opW $opI $opN $opS $opFORK $opSHOWL
       RETVAL=$?

return $RETVAL
}

_do_mount_bb()
{

set --  #unset everything
set - $longOPS $shortOPS

for onePAR in $posPARAMS
do
ePAR="`echo -e "$onePAR" | sed 's!NEWLINE!\n!g'`"
_debugx "ePAR='$ePAR'"

set - $@ "$ePAR"
done
_debug "_do_mount_bb:$*"

       _info "busybox $WHAT ""$@"" $opVERB $opLABEL $opUUID $opDRY $opO $opMO $opT $opR $opW $opI $opN $opS $opVERB"
              busybox $WHAT  "$@"  $opVERB $opLABEL $opUUID $opDRY $opO $opMO $opT $opR $opW $opI $opN $opS $opVERB
       RETVAL=$?

return $RETVAL
}

_which_mount()
{

_debug "_which_mount:$*"
local oneOPT

for oneOPT in A B C D E F G H I J K L M N O P Q R S T U V W X Y Z \
 ALL DRY FORK SHOWL LABEL MO PASS RB AF UUID VERB
do

OPT=`eval echo \\$op$oneOPT`
_debugx "OPT='$OPT'"

case $OPT in
"") :;;
-a|-f|-i|-o*|-O*|-r|-s|-v|-w) :;;
-t*ntfs*)
 _info "Using ntfs-3g"
 _do_mount_ntfs_3g "$@"
 RV=$?
 return $RV
 ;;
-t*fat*)
 _info "vfat mount"
 _do_mount_vfat "$@"
 RV=$?
 return $RV
;;
-B|-c|-F|-l|-L*|-M|-p|-R|-T*|-U*|-t*xfs*)
 _info "Using mount-FULL"
 _do_mount_full "$@"
 RV=$?
 return $RV
;;
esac
done

if [ "$HAVE_XFS" ]; then
_debug Using mount-FULL "$@"
_do_mount_full "$@"
else
_debug Using busybox mount "$@"
_do_mount_bb "$@"
fi
RV=$?

return $RV
}

_have_long_options()
{

_debug "_have_long_options:$*"
case $longOPS in
--|"")
_debugt 82 $_DATE_
_which_mount "$@"
RV=$?
_debugt 81 $_DATE_
return $RV
;;
*)
_do_mount_full "$@"
RV=$?
return $RV
;;
esac

}

shortOPS=`echo "$shortOPS" | sed 's! -- .*$!!'`
_debugx "shortOPS='$shortOPS'"
_debugx " longOPS='$longOPS'"
set -- # unset everything
set - $longOPS $shortOPS $@ #$opVERB $opALL $opC $opDRY $opD $opND $opFORK $opLABEL $opMO $opPASS $opRB $opUUID $opT $opAF $opSHOWL $opVERB
_debugx 'A*:'$*
_debugx 'A@:'$@
_have_long_options "$@"

;;
*) _exit 43 "Unhandled '$WHAT' -- use 'mount' or 'umount' .";;
esac

case $RETVAL in
0)   _info "RETVAL=$RETVAL";;
*)    _err "RETVAL=$RETVAL";;
esac

_debugt 05 $_DATE_

_umount_rmdir()
{
 test "$*" || return 1
 [ "$DISPLAY" ] && { test -d "$mountPOINT" && rox -D "$mountPOINT"; }
 _debug "_umount_rmdir:mountpoint $Q $*";
 mountpoint $Q "$*" || rmdir $VERB "$@"
}

_update()
{

 _debug "DISPLAY='$DISPLAY'"
 test "$DISPLAY" && _update_partition_icon
 test "$WHAT" = umount || return 0

 _debugt 04 $_DATE_
 test "`echo "$mountPOINT" | grep -E '/dev|/proc|/sys|/tmp'`" && return 0
 test -d "$mountPOINT" && _umount_rmdir "$mountPOINT"

 _debugt 03 $_DATE_
 _check_tmp_rw || return 59
 _debugt 02 $_DATE_

 while read -r oneDIR
 do
 _debug "oneDIR='$oneDIR'"
 test "$oneDIR" || continue
 _umount_rmdir "$oneDIR"
 done <<EoI
`_command find /mnt -maxdepth 1 -type d -empty`
EoI
_debugt 01 $_DATE_

}

_debug "mountPOINT='$mountPOINT'"
test "$RETVAL" = 0 && { _update || :; } || _umount_rmdir "$mountPOINT"
_debugt 00 $_DATE_
test "`readlink /etc/mtab`" = "/proc/mounts" || ln $VERB -sf /proc/mounts /etc/mtab
_debugt 00
exit $RETVAL
# Very End of this file 'bin/mount.sh' #
###END###
