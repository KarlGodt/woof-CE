#!/bin/ash

DEBUGT=
_debugt(){  #$1 label #$2 time

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
_debugt 8E $_DATE_
test -f /etc/rc.d/f4puppy5 && . /etc/rc.d/f4puppy5
_debugt 8D $_DATE_

QUIET=-q
DEBUG=
DEBUGX=
test "$DEBUG" && QUIET='';

LANG_ROX=$LANG  # ROX-Filer may complain about non-valid UTF-8
echo $LANG | grep $QUIET -i 'utf' || LANG_ROX=$LANG.UTF-8

#busybox mountpoint does not recognice after
#mount --bind / /tmp/ROOTFS
#/tmp/ROOTFS as mountpoint ...
#but does for mount --bind / /tmp/SYSFS and bind mount of /proc ..???
#so using function with grep instead
mountpoint(){
 test -f /proc/mounts || return 3
 test "$*" || return 2
 [ "$1" = '-q' ] && shift;
 #set - `echo "$*" | sed 's!\ !\\\040!g'`
 set - ${*//\\/\\\\}
 _debug "mountpoint:$*"
 grep $QUIET " $* " /proc/mounts
 return $?; }

_check_proc()
{
 _debug "_check_proc:mountpoint $QUIET /proc"
  mountpoint $QUIET /proc && return $? || {
  busybox mount -o remount,rw /dev/root/ /
  test -d /proc || mkdir -p /proc
  busybox mount -t proc none /proc
  return $?
 }
}

_check_tmp()
{
 test -d /tmp && return $? || {
 busybox mount -o remount,rw /dev/root/ /
 mkdir -p /tmp
 chmod 1777 /tmp
 return $?
 }
}

_check_tmp_rw()
{
 _check_proc
 _check_tmp

_debug "_check_tmp_rw:mountpoint $QUIET /tmp"
mountpoint $QUIET /tmp && {
grep -w '/tmp' /proc/mounts | cut -f4 -d' ' | grep $QUIET -w 'rw' && return 0 || { busybox mount -o remount,rw tmpfs /tmp; return $?; }
 } || {
grep '^/dev/root' /proc/mounts | cut -f4 -d' ' | grep $QUIET -w 'rw' && return 0 || { busybox mount -o remount,rw /dev/root/ /; return $?; }
 }

}

_string_to_octal()
{
_debug "_string_to_octal:$*" >&2
unset oSTRING
if test "$*"; then
STRING_ORIG="$*"

STRING=`echo "$STRING_ORIG" | sed 's!\(.\)!"\1"\n!g'`
_debug "_string_to_octal:STRING='$STRING'" >&2


while read -r oneCHAR
do
oneCHAR=`echo "$oneCHAR" | sed 's!^"!!;s!"$!!'`
oCHAR=`printf %o \'"$oneCHAR"`

oSTRING=$oSTRING"\\0$oCHAR"

done<<EoI
`echo "$STRING"`
EoI

else

while read -r oneLINE
do
#test "$oneLINE" || continue
 _debug "oneLINE='$oneLINE'" >&2
 STRING=`echo "$oneLINE" | sed 's!\(.\)!"\1"\n!g'`
 _debugx "STRING='$STRING'" >&2
 while read -r oneCHAR
 do
 _debugx "oneCHAR='$oneCHAR'" >&2
 oneCHAR=`echo "$oneCHAR" | sed 's!^"!!;s!"$!!'`
 _debug "oneCHAR='$oneCHAR'" >&2
 oCHAR=`printf %o \'"$oneCHAR"`
 _debug "oCHAR='$oCHAR'" >&2
 #test "$oCHAR" = 134 && oCHAR=0134

 oSTRING=$oSTRING"\\0$oCHAR"
 _debugx "oSTRING='$oSTRING'" >&2

 done<<EoI
`echo "$STRING"`
EoI

oSTRING=$oSTRING"\\012"
done

fi

echo "$oSTRING"

}

_posparams_to_octal()
{
        _debug "_posparams_to_octal:$@"
#echo -n "$@" | od -to1 | sed 's! !:!;s!$!:!' | cut -f2- -d':' | sed 's!\ !\\0!g;s!:$!!;/^$/d;s!^!\\0!' >/tmp/posPARAMS.od
echo "$@" | _string_to_octal >/tmp/posPARAMS.od
test -s /tmp/posPARAMS.od || _exit 5 "Something went wrong processing positional parameters."
posPARAMS=`cat /tmp/posPARAMS.od`
posPARAMS=`echo $posPARAMS | tr -d ' '`
posPARAMS=`echo "$posPARAMS" | sed 's!\\\012\\\!\n\\\!g'`
_debugx "            posPARAMS='$posPARAMS'"
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
_debug "               options='$getOPS'"

 #longOPS=`echo "$getOPS" | grep -oe '\-\-[^ ]*' | tr '\n' ' ' |sed 's! --$!!;s! -- $!!;s!-- !!'`
 longOPS=${getOPS% -- *}
 longOPS=`echo "$longOPS" | grep -oe '\-\-[^ ]*' | tr '\n' ' ' |sed 's! --$!!;s! -- $!!;s!-- !!'`
 test "${longOPS//[[:blank:]]/}" || longOPS='';
_info "           long options='$longOPS'"

shortOPS=${getOPS%%--*}
_debugx "        short options='$shortOPS'"
shortOPS=`echo "$shortOPS" | sed "s%'%%g"`
test "${shortOPS//[[:blank:]]/}" || shortOPS='';
_info "          short options='$shortOPS'"

posPARAMS=${getOPS#*-- }
_debugx "positional parameters='$posPARAMS'"
posPARAMS=`echo "$posPARAMS" | sed 's!--$!!'`
_debugx "positional parameters='$posPARAMS'"

posPARAMS=`echo "$posPARAMS" | sed "s%' '%'\n'%g"`
_debugx "positional parameters='$posPARAMS'"
posPARAMS=`echo "$posPARAMS" | sed "s%'\\\\\\\''%\'%g"`
posPARAMS=`echo "$posPARAMS" | sed "s%'\\\\\\\!'%\!%g"`
posPARAMS=`echo "$posPARAMS" | sed "s%'\\\\\\\ '%\ %g"`
_debugx "positional parameters='$posPARAMS'"
posPARAMS=`echo "$posPARAMS" | sed "s%^'%%;s%'$%%"`
_debugx "positional parameters='$posPARAMS'"

test "$posPARAMS" = "$shortOPS" && posPARAMS='' || _debugx "posPARAMS NOT same as shortOPS";
_debugx "positional parameters='$posPARAMS'"

_posparams_to_octal "$posPARAMS"
_info "  positional parameters='$posPARAMS'"
}
#_get_options "$*"
#_get_options $*
#_get_options $@
_get_options "$@"
_debugt 8C $_DATE_

test -f /proc/mounts && mountBEFORE=`cat /proc/mounts`

_update_partition_icon()
{

o_DEBUG=$DEBUG
o_DEBUGX=$DEBUGX
o_DEBUGT=$DEBUGT

test -f /etc/eventmanager && . /etc/eventmanager
test "`echo "$ICONPARTITIONS" | grep -i 'true'`" || return 0

test -f /etc/rc.d/functions4puppy4  && . /etc/rc.d/functions4puppy4
test -f /etc/rc.d/pupMOUNTfunctions && . /etc/rc.d/pupMOUNTfunctions

DEBUG=$o_DEBUG
DEBUGX=$o_DEBUGX
DEBUGT=$o_DEBUGT

test -f /proc/mounts && mountAFTER=`cat /proc/mounts`
_debugt 99 $_DATE_
test "$mountBEFORE" -a "$mountAFTER" && {
        grepMA=`echo "$mountAFTER" | sed 's!\\\!\\\\\\\!g'` || exit
        grepMB=`echo "$mountBEFORE" | sed 's!\\\!\\\\\\\!g'`
        updateWHATA=`echo "$mountAFTER" | _command grep -v "$grepMB"`
        updateWHATB=`echo "$mountBEFORE" | _command grep -v "$grepMA"`
        updateWHAT="$updateWHATA
$updateWHATB" ; }
_debugt 9f $_DATE_

 _check_tmp_rw || return 56
_debugt 9e $_DATE_

 while read -r oneUPDATE oneMOUNTPOINT REST
 do
 _debug "_update_partition_icon:'$oneUPDATE' '$oneMOUNTPOINT' '$REST'"
 test "$oneUPDATE" || continue
 eoneMOUNTPOINT=`echo -e "$oneMOUNTPOINT"`
 _debug "_update_partition_icon:'$oneUPDATE' '$eoneMOUNTPOINT' '$REST'" >&2
_debugt 9d $_DATE_

 test "$noROX" || { _pidof $QUIET ROX-Filer && {
      test -d "${eoneMOUNTPOINT%/*}" && rox -x "${eoneMOUNTPOINT%/*}"
         test -d "${eoneMOUNTPOINT}" && rox -x "${eoneMOUNTPOINT}"
         mountpoint $QUIET "${oneMOUNTPOINT}" && rox -d "${eoneMOUNTPOINT}" || rox -D "${eoneMOUNTPOINT}"
         }
        }
 _debugt 9c $_DATE_

 case $oneUPDATE in
 *loop*|*ram*|*md*|*mtd*|*nbd*) _debug "Got loop, ram, md, mtd, nbd -- won't update partition icon"; skipICON=YES ; continue;;
 /dev/fd[0-9]*)      DRV_CATEGORY=floppy ;;
 /dev/sr*|/dev/scd*) DRV_CATEGORY=optical;;
 /dev/mmc*)          DRV_CATEGORY=card   ;;
 /dev/*) DRV_CATEGORY=`probedisk2 | grep -w "${oneUPDATE:0:8}" | cut -f2 -d'|'`;
         _debug "DRV_CATEGORY='$DRV_CATEGORY'"
         test "$DRV_CATEGORY" || continue;;
 *) _notice "Got '$oneUPDATE' -- won't update partition icon"; skipICON=YES ; continue;;
 esac
 _debugt 9b $_DATE_

 case $WHAT in
 umount)
 _debugt 98 $_DATE_
   if [ "`_command df | tr -s ' ' | cut -f 1,6 -d ' ' | grep -w "$oneUPDATE" | grep -v ' /initrd/' | grep -v ' /$'`" = "" ];then
    if [ "`_command df | tr -s ' ' | cut -f 1,6 -d ' ' | grep -w "${oneUPDATE}" | grep -E ' /initrd/| /$'`" != "" ];then
     _info "_update_partition_icon:$oneUPDATE is boot partition"
     #only a partition left mntd that is in use by puppy, change green->yellow...
     icon_mounted_func ${oneUPDATE##*/} $DRV_CATEGORY #see functions4puppy4
    else
     _info "_update_partition_icon:$oneUPDATE is not boot partition"
     #redraw icon without "MNTD" text...
     icon_unmounted_func ${oneUPDATE##*/} $DRV_CATEGORY #see functions4puppy4
    fi
   fi
 _debugt 97 $_DATE_
 ;;
 mount)
 _debugt 96 $_DATE_
 _debugx "icon_mounted_func ${oneUPDATE##*/} $DRV_CATEGORY"
      icon_mounted_func ${oneUPDATE##*/} $DRV_CATEGORY
 _debugt 95 $_DATE_
 ;;
 *) _err "_update_partition_icon:'$WHAT' not handled.";;
 esac

 done<<EoI
`echo "$updateWHAT"`
EoI

}

_parse_fstab()
{
test -f /etc/fstab || return 57

while read -r device mountpoint fstype mntops dump check
do

test "$device" -a "$mountpoint" || continue
test "`echo "$device" | sed 's,[^#]*,,g'`" && continue

case $WHAT in
 mount)
  _debug "_parse_fstab:$WHAT:'$device' '$mountpoint' -t '$fstype' -o '$mntops'"

  test "$fstype" = swap && continue
  grep $QUIET -w "${device##*/}" /proc/partitions || continue
  test -d "$mountpoint" || LANG=$LANG_ROX mkdir -p "$mountpoint"
  _debug "_parse_fstab:$WHAT:mountpoint $QUIET \"$mountpoint\""
  mountpoint $QUIET "$mountpoint" && continue

  mountBEFORE=`cat /proc/mounts`
  busybox $WHAT $device "$mountpoint" -t $fstype -o $mntops
  RV=$?
  STATUS=$((STATUS+RV))
  noROX=1
  test "$RV" = 0 && _update_partition_icon || rmdir "$mountpoint"
 ;;

umount)
  case $opT in
  -t) echo "$opT_ARGS" | grep -q -w "$fstype" || continue ;;
  esac
  case $opO in
  -O) echo "$mntops" | grep -q -E "$opO_ARGS" || continue ;;
  esac

  _debug "_parse_fstab:$WHAT:mountpoint='$mountpoint'"

                allSUB_MOUNTS=`losetup -a | grep -w "$mountpoint" | tac`
                _check_tmp_rw || return 58
                while read -r loop nr loopmountpoint
                do
                test "$loop" || continue
                echo "$loop is mounted on $loopmountpoint"
                #busybox umount -d $loop || return 3
                sleep 1
                done<<EoI
                `echo "$allSUB_MOUNTS"`
EoI

  _debug "_parse_fstab:$WHAT:mountpoint $QUIET \"$mountpoint\""
  mountpoint $QUIET "$mountpoint" && {
     mountBEFORE=`cat /proc/mounts`
     _pidof $QUIET ROX-Filer && rox -D "$mountpoint"
     busybox $WHAT "$mountpoint"
     RV=$?
     test $RV = 0 && _update_partition_icon
     STATUS=$((STATUS+RV))
    }

  #echo $device
  grep -q -w "^$device" /proc/mounts || continue
  #umount $device
  ;;
*) _err "_parse_fstab:Got unhandled '$WHAT' -- use 'mount' or 'umount'"; break;;
esac

done</etc/fstab
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
  #_parse_short_ops_u()
  #{
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
  #}
  #_parse_short_ops_u $*
;;
 mount)
  #_parse_short_ops_m()
  #{
  #_debug "_parse_short_ops_m $allOPS"
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
  #}
  #_parse_short_ops_m $*;;
;;
 *) _exit 39 "Unhandled '$WHAT' -- use 'mount' or 'umount' .";;
esac
}
_builtin_getopts "$@"
_debugt 88 $_DATE_

#_debug '3*:'$*
#while test 1 = 1; do
#[[ "$1" = '--' ]] && shift || break
#done
_debug '4*:'$*
#set - $longOPS $@
set - $longOPS $shortOPS $posPARAMS
_debug '5@:'$@
_info "6:$WHAT "$@ $opFL $opNFL $opF $opI $opN $opR $opL $opVERB $opMO $opS $opW $opLABEL $opUUID $opSHOWL $opT

test "$opALL" && _debug "opALL='$opALL'"

if   test "$opALL" == "-a"; then
        _warn "${WHAT}ing all entries in /etc/fstab..."
        _parse_fstab
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

#_debug "7@:"$@
#while test 1 = 1; do
#test "$1" == '--' && shift || break
#done
_debug "8@:"$@
_info "9:$WHAT "$@ $opFL $opNFL $opF $opI $opN $opR $opL $opVERB $opMO $opS $opW $opLABEL $opUUID $opSHOWL $opT

( test "$*" -o "$opUUID" -o "$opLABEL" || test "$opT" -o "$opSHOWL" ) || _exit 1 "No positional parameters left."

case $# in
1)
deviceORpoint=`echo -e $@`
_debug "deviceORpoint='$deviceORpoint'"
;;
esac
_debugt 86 $_DATE_

case $WHAT in
mount)
if test "$deviceORpoint"; then
 _debug "$WHAT:"$@
 #test -b $deviceORpoint -a ! -d /mnt/${deviceORpoint##*/} && mkdir -p /mnt/${deviceORpoint##*/}
 if test -b $deviceORpoint; then
  grep $QUIET -w "${deviceORpoint##*/}" /proc/partitions && {
   _info "found '${deviceORpoint##*/}' in /proc/partitions"
  } || {
   _warn "'${deviceORpoint##*/}' not found in /proc/partitions"; }
 # grep $QUIET -w ${deviceORpoint} /proc/mounts && _exit 3 "'${deviceORpoint}' already mounted"
 fi
 #test -d /mnt/${deviceORpoint##*/} || mkdir -p /mnt/${deviceORpoint##*/}
 test -e /etc/fstab || touch /etc/fstab
 grep $QUIET -w "$deviceORpoint" /etc/fstab && {
  _info "Found $deviceORpoint in /etc/fstab"
  #mkdir -p `awk "/$deviceORpoint/ "'{print $2}' /etc/fstab`
  mountPOINT=`grep -m1 -w "$deviceORpoint" /etc/fstab | awk '{print $2}'`
  _debug "mountPOINT='$mountPOINT'"
  #test -e "$mountPOINT" || { set - $@ $mountPOINT; mkdir -p "$mountPOINT"; }
  mountpoint "$mountPOINT" && { test "`echo "$opMO" | grep 'remount'`" || _exit 3 "'$mountPOINT' already mounted."; }
  test "$*" = "$mountPOINT" || set - $@ "$mountPOINT"
  test -e "$mountPOINT" && { _debug "$mountPOINT exists"; } || { _info "Creating $mountPOINT"; LANG=$LANG_ROX mkdir -p "$mountPOINT"; }
 } || { test "$*" = "$deviceORpoint" && {
         posPARAMS="$posPARAMS /mnt/${deviceORpoint##*/}"; set - "$deviceORpoint" "/mnt/${deviceORpoint##*/}"; }
          }
 _debug "$WHAT:"$@
fi
c=0
for posPAR in $*; do  #hope, only file/device AND mountpoint left
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

*) test $c = $# || continue
   if test -f /proc/filesystems; then
   if test ! "`grep 'nodev' /proc/filesystems | grep $posPAR`"; then
      #if test "`echo "$*" | grep -e '\-\-[[:alpha:]]*'`" = ""; then
   grep $QUIET -Fw "$posPAR" /proc/mounts && { test "`echo "$opMO" | grep 'remount'`" ||  _exit 3 "$posPAR already mounted."; }
      #fi
      _debug "c=$c \$#=$# "$posPAR
    #test $c = $# && { test -e "$posPAR" || {  _notice "Assuming '$posPAR' being mountpoint.."; mkdir -p "$posPAR"; } ; }
o_ocposPAR="$posPAR"
   posPAR=`echo -e "$posPAR"`
   #posPAR=${posPAR//\\/}
o_posPAR="$posPAR"
      _debug "c=$c \$#=$# ""$posPAR"
   test -e /etc/fstab || touch /etc/fstab
   grepPAR=`echo "$posPAR" | sed 'sV\([[:punct:]]\)V\\\\\\1Vg'`
   mountPOINT=`grep -F -m1 -w "$grepPAR" /etc/fstab | awk '{print $2}'`
   #mountPOINT=`grep -m1 -w "$posPAR" /etc/fstab | awk '{print $2}'`
   _debugx "mountPOINT='$mountPOINT'"
   test "$mountPOINT" && { posPAR="$mountPOINT"
   _debug "Found '$posPAR' in /etc/fstab -- using '$mountPOINT' as mount-point."; }
   test -b "$posPAR" && posPAR="/mnt/${posPAR##*/}"
   test -e "$posPAR" && ls -lv "$posPAR" || {  _notice "Assuming '$posPAR' being mountpoint.."; LANG=$LANG_ROX mkdir -p "$posPAR"; }
#ocposPAR=`echo "$posPAR" | od -to1 | sed 's! !:!;s!$!:!' | cut -f2- -d':' | sed 's!\\ !\\\0!g;s!:$!!;/^$/d;s!^!\\\0!'`
   _debugx "posPAR='$posPAR'"
ocposPAR=`echo "$posPAR" | _string_to_octal`
   _debugx "ocposPAR='$ocposPAR'"
#ocposPAR=`echo $ocposPAR | tr -d ' '`
#ocposPAR=`echo "$ocposPAR" | sed 's!\\012!\n!g'`
#_debugx "            ocposPAR='$ocposPAR'"
ocposPAR=`echo "$ocposPAR" | sed 's!\\\\0$!!g'`
_debug "             ocposPAR='$ocposPAR'"
   #test -b $oposPAR && set - $@ "$ocposPAR"
   #_debug "posPAR:$*"
   test -b $o_posPAR && posPARAMS="$posPARAMS $ocposPAR"
   fi;fi ;;
esac
done
c=0
;;
umount) :;;
*) _exit 40 "Unhandled '$WHAT' -- use 'mount' or 'umount' ."
;;
esac
_debugt 85 $_DATE_

case $WHAT in
umount)
if test "$deviceORpoint"; then
 mountpoint $QUIET /proc && {
 NTFSMNTPT=`_command ps -eF | grep -o 'ntfs\-3g.*' | grep -w "$deviceORpoint" | tr '\t' ' ' | tr -s ' ' | tr ' ' "\n" | grep '^/mnt/'`
 NTFSMNTDV=`_command ps -eF | grep -o 'ntfs\-3g.*' | grep -w "$deviceORpoint" | tr '\t' ' ' | tr -s ' ' | tr ' ' "\n" | grep '^/dev/'`
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
grepP=${deviceORpoint// /\\\\040}
_debug "grepP='$grepP'"
mountPOINT=`echo "$mountBEFORE" | grep -w "$grepP" | cut -f 2 -d' '`
mountPOINT=`busybox echo -e "$mountPOINT"`
_debug "mountPOINT='$mountPOINT'"
fi
        if test -d "$mountPOINT"; then
        _debug "Closing ROX-Filer if necessary..."
        _pidof $QUIET ROX-Filer && rox -D "$mountPOINT";
        _debug "Showing Filesystem user PIDs of '$mountPOINT':"
        fuser -m "$mountPOINT" && {
           if test "$opL" -o "$opF"; then
           _warn "Mountpoint is in use by above pids:"
           else
           _err "Mountpoint is in use by above pids:"
           fi
                for aPID in `fuser -m "$mountPOINT"`
                do
                fsUSERS="$fsUSERS
`ps -o pid,ppid,args | grep -wE "$aPID|^PID" | grep -v 'grep'`
                "
                done
                echo "$fsUSERS"
           if test "$opL" -o "$opF"; then
           :
           else
                test "$DISPLAY" && xmessage -bg red -title "$WHAT" "$mountPOINT is in use by these PIDS:
$fsUSERS" &
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
ePAR="`echo -e "$onePAR"`"
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
#set - $longOPS $shortOPS

for onePAR in $posPARAMS
do
ePAR="`echo -e "$onePAR"`"
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

        LANG=$LANG_ROX mkdir -p "/mnt/${@##*/}"; set - $@ "/mnt/${@##*/}"; _debug "ntfs:$@";
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
ePAR="`echo -e "$onePAR"`"
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
ePAR="`echo -e "$onePAR"`"
_debugx "ePAR='$ePAR'"
set - $@ "$ePAR"
done

        if test "$opUUID"; then
         MntPoints=$(grep -w "`echo "$opUUID" | cut -f2 -d' '`" /etc/fstab | awk '{print $2}')
         for oneMTP in $MntPoints; do
         test -d "$oneMTP" || LANG=$LANG_ROX mkdir -p "$oneMTP"
         done
        fi
        if test "$opLABEL"; then
         _debug "opLABEL='$opLABEL'"
         lONLY=`echo "$opLABEL" | cut -f2 -d' '`
         _debug "lONLY='$lONLY'"
         MntPoints=$(grep -w "$lONLY" /etc/fstab | awk '{print $2}')
         for oneMTP in $MntPoints; do
         _debug "oneMTP='$oneMTP'"
         test -d "$oneMTP" || LANG=$LANG_ROX mkdir -p "$oneMTP"
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
ePAR="`echo -e "$onePAR"`"
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
 _notice "Using ntfs-3g"
 _do_mount_ntfs_3g "$@"
 RV=$?
 return $RV
 ;;
-t*fat*)
 _notice "vfat mount"
 _do_mount_vfat "$@"
 RV=$?
 return $RV
;;
-B|-c|-F|-l|-L*|-M|-p|-R|-T*|-U*)
 _notice "Using mount-FULL"
 _do_mount_full "$@"
 RV=$?
 return $RV
;;
esac
done
_info Using busybox mount "$@"
_do_mount_bb "$@"
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

_notice "RETVAL=$RETVAL"
_debugt 05 $_DATE_

_umount_rmdir()
{
 test "$*" || return 1
 [ "$DISPLAY" ] && { test "$mountPOINT" && rox -D "$mountPOINT"; }
 _debug "_umount_rmdir:mountpoint $QUIET $*";
 mountpoint $QUIET "$*" || rmdir "$@";
}

_update()
{
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
 _debug "oneDIR='$oneDIR'" >&2
 test "$oneDIR" || continue
 _umount_rmdir "$oneDIR"
 done<<EoI
`_command find /mnt -maxdepth 1 -type d -empty`
EoI
_debugt 01 $_DATE_
}

test "$RETVAL" = 0 && _update || _umount_rmdir "$mountPOINT"
_debugt 00 $_DATE_
test "`readlink /etc/mtab`" = "/proc/mounts" || ln -sf /proc/mounts /etc/mtab
_debugt 00
exit $RETVAL
