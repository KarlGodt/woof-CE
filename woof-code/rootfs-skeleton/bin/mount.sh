#!/bin/ash

test "$*" || exec busybox mount

test -f /etc/rc.d/f4puppy5 && . /etc/rc.d/f4puppy5

QUIET=-q
DEBUG=
INFO=
test "$DEBUG" && QUIET='';

#busybox mountpoint does not recognice after
#mount --bind / /tmp/ROOTFS
#/tmp/ROOTFS as mountpoint ...
#but does for mount --bind / /tmp/SYSFS and bind mount of /proc ..???
#so using function with grep instead
mountpoint(){ [ "$1" = '-q' ] && shift;
set - `echo "$*" | sed 's!\ !\\\040!g'`
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
grep -w '/tmp' /proc/mounts | cut -f4 -d' ' | grep -q -w 'rw' && return 0 || { busybox mount -o remount,rw tmpfs /tmp; return $?; }
 } || {
grep '^/dev/root' /proc/mounts | cut -f4 -d' ' | grep -q -w 'rw' && return 0 || { busybox mount -o remount,rw /dev/root/ /; return $?; }
 }

}

allOPS=AaBbCcDdEeFfGgHhIiJjKkL:lMmNnO:o:Pp:QqRrSsTt:U:uVvWwXxYyZz-

  getOPS=`busybox getopt -u -l help,version,bind,rbind,move,make-private,make-rprivate,make-shared,make-rshared,make-slave,make-rslave,make-unbindable,make-runbindable -- $allOPS "$@"`
_debug "options='$getOPS'"
 longOPS=`echo "$getOPS" | grep -oe '\-\-[^ ]*' | tr '\n' ' ' |sed 's! --$!!;s! -- $!!'`
_info "long='$longOPS'"
test "$longOPS" || longOPS=--
shortOPS=`echo "$getOPS" | sed "s%$longOPS%%"`
_info "short='$shortOPS'"

_debug "1:$*"
#set - $getOPS
set - $shortOPS
_notice "2:$*"

test -f /proc/mounts && mountBEFORE=`cat /proc/mounts`

_update_partition_icon()
{

test -f /etc/eventmanager && . /etc/eventmanager
test "`echo "$ICONPARTITIONS" | grep -i 'true'`" || return 0

test -f /etc/rc.d/pupMOUNTfunctions && . /etc/rc.d/pupMOUNTfunctions

#test -f /etc/rc.d/f4puppy5 && . /etc/rc.d/f4puppy5

test -f /proc/mounts && mountAFTER=`cat /proc/mounts`

test "$mountBEFORE" -a "$mountAFTER" && {
        updateWHATA=`echo "$mountAFTER" | _command grep -v "$mountBEFORE"`
        updateWHATB=`echo "$mountBEFORE" | _command grep -v "$mountAFTER"`
        updateWHAT="$updateWHATA
$updateWHATB" ; }

 _check_tmp_rw || return 56
 while read oneUPDATE oneMOUNTPOINT REST
 do

 test "$oneUPDATE" || continue
 _debug "_update_partition_icon:'$oneUPDATE' '$oneMOUNTPOINT' '$REST'"

 test "$noROX" || { _pidof $QUIET ROX-Filer && {
      test -d "${oneMOUNTPOINT%/*}" && rox -x "${oneMOUNTPOINT%/*}"
         test -d "${oneMOUNTPOINT}" && rox -x "${oneMOUNTPOINT}"
         #test -e "${oneMOUNTPOINT}" && rox -d "${oneMOUNTPOINT}" || rox -D "${oneMOUNTPOINT}"
         mountpoint $QUIET "${oneMOUNTPOINT}" && rox -d "${oneMOUNTPOINT}" || rox -D "${oneMOUNTPOINT}"
         }
        }

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

 case $WHAT in
 umount)
   if [ "`_command df | tr -s ' ' | cut -f 1,6 -d ' ' | grep -w "$oneUPDATE" | grep -v ' /initrd/' | grep -v ' /$'`" = "" ];then
   #[ "$VERBOSE" ] && _info "IS in df"
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
 #test "$noROX" || { pidof ROX-Filer && rox -x "${oneMOUNTPOINT%/*}" -x "$oneMOUNTPOINT"; }
 ;;
 mount)
      icon_mounted_func ${oneUPDATE##*/} $DRV_CATEGORY
      #test "$noROX" || { pidof ROX-Filer && rox -x "${oneMOUNTPOINT%/*}" -x "$oneMOUNTPOINT" -d "$oneMOUNTPOINT"; }
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

while read device mountpoint fstype mntops dump check
do

test "$device" -a "$mountpoint" || continue
test "`echo "$device" | sed 's,[^#]*,,g'`" && continue

case $WHAT in
 mount)
  _debug "_parse_fstab:$WHAT:'$device' '$mountpoint' -t '$fstype' -o '$mntops'"

  test "$fstype" = swap && continue
  grep -q -w ${device##*/} /proc/partitions || continue
  test -d "$mountpoint" || mkdir -p "$mountpoint"
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
                while read loop nr loopmountpoint
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
  echo "$0:Unhandled option \"$oneOPT\""
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
  f) #fake dry-run
   opDRY=-f;;
  F) # FORK while using -a
   opFORK=-F;;
  i) #don'use mount helper
   opI=-i;;
  n) # don't write to /etc/mtab
   opN=-n;;
  r) #read-only
   opR=-r;;
  s) # sloppy
   opS=-s;;
  v) #verbose
   opVERB=-v;;
  w) # read-write, same as -o rw
   opW=-w;;
  t) #filesystem type
   opT=-t
   opT_ARGS="$OPTARG"
   #fsTYPE=$OPTARG
   opT="-t $opT_ARGS"
   shift
  ;;
  O) # mount options for -a
   opO=-O
   opO_ARGS="$OPTARG"
   opO_ARGS="${opO_ARGS//,/|}"
   shift
  ;;
  o) #mount options
   ops=$OPTARG
   opMO="-o $ops"
   shift
  ;;
  p) # passphrase from file_descriptor
   fd=$OPTARG
   opPASS="-p $fd"
   shift
  ;;
  l) #list, and show label if label exists
   opSHOWL=-l;;
  h) # help
   opH=-h;;
  V) #version
   opVERS=-V;;
  L) # mount label
   mLABEL=$OPTARG
   opLABEL="-L $mLABEL"
   shift
   ;;
  U) #mount UUID
   uLABEL=$OPTARG
   opUUID="-U $uLABEL"
   shift
  ;;
  *)
   #shift
   echo "$0:Unhandled option \"$oneOPT\""
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

_debug "3:$*"
[[ "$1" = '--' ]] && shift
_debug "4:$*"
set - $longOPS $*
_debug "5:$*"
_info "6:$WHAT $* "$opFL $opNFL $opF $opI $opN $opR $opL $opVERB $opMO $opS $opW $opLABEL $opUUID $opSHOWL

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

_debug "7:$*"
test "$1" == '--' && shift
_debug "8:$*"
_info "9:$WHAT $* "$opFL $opNFL $opF $opI $opN $opR $opL $opVERB $opMO $opS $opW $opLABEL $opUUID $opSHOWL

( test "$*" -o "$opUUID" -o "$opLABEL" || test "$opT" -o "$opSHOWL" ) || _exit 1 "No positional parameters left."

case $# in
1)
deviceORpoint=`echo $@ | sed "s%^'%%;s%'$%%"`
_debug "deviceORpoint='$deviceORpoint'"
;;
esac

case $WHAT in
mount)
if test "$deviceORpoint"; then
 _debug "$WHAT:$*"
 test -b $deviceORpoint -a ! -d /mnt/${deviceORpoint##*/} && mkdir -p /mnt/${deviceORpoint##*/}
 test -d /mnt/${deviceORpoint##*/} || mkdir -p /mnt/${deviceORpoint##*/}
 grep $QUIET -w $deviceORpoint /etc/fstab || { test "$@" = "$deviceORpoint" && set - $deviceORpoint /mnt/${deviceORpoint##*/}; }
 _debug "$WHAT:$*"
fi
for posPAR in $*; do  #hope, only file/device AND mountpoint left
case $posPAR in
-*):;;
*) test -e "$posPAR" || mkdir -p "$posPAR";;
esac
done
;;
umount) :;;
*) _exit 40 "Unhandled '$WHAT' -- use 'mount' or 'umount' ."
;;
esac

#mountBEFORE=`cat /proc/mounts`

case $WHAT in
umount)
if test "$deviceORpoint"; then
 NTFSMNTPT=`_command ps -eF | grep -o 'ntfs\-3g.*' | grep -w "$deviceORpoint" | tr '\t' ' ' | tr -s ' ' | tr ' ' "\n" | grep '^/mnt/'`
 NTFSMNTDV=`_command ps -eF | grep -o 'ntfs\-3g.*' | grep -w "$deviceORpoint" | tr '\t' ' ' | tr -s ' ' | tr ' ' "\n" | grep '^/dev/'`
 _debug "NTFSMNTPT='$NTFSMNTPT' NTFSMNTDV='$NTFSMNTDV'"
fi
;;
mount) :;;
*) _exit 41 "Unhandled '$WHAT' -- use 'mount' or 'umount' .";;
esac

case $WHAT in
umount)
#deviceORpoint=`echo $@ | sed "s%^'%%;s%'$%%"`
mountPOINT=`echo "$mountBEFORE" | grep -w "$deviceORpoint" | cut -f 2 -d' '`
mountPOINT=`busybox echo -e "$mountPOINT"`
_debug "mountPOINT='$mountPOINT'"

#mountpoint $QUIET "$mountPOINT" && {
        if test -d "$mountPOINT"; then
        #_debug "Closing ROX-Filer if necessary..."
        #_pidof $QUIET ROX-Filer && rox -D "$mountPOINT";
        _debug "Showing Filesystem user PIDs of '$mountPOINT':"
        fuser -m "$mountPOINT" && {
                _err "Mountpoint is in use by above pids:"
                for aPID in `fuser -m "$mountPOINT"`
                do
                fsUSERS="$fsUSERS
`ps -o pid,ppid,args | grep -wE "$aPID|^PID" | grep -v 'grep'`
                "
                done
                echo "$fsUSERS"
                test "$DISPLAY" && xmessage -bg red -title "$WHAT" "$mountPOINT is in use by these PIDS:
$fsUSERS" &
                _exit 1 "Refusing to complete '$WHAT $*' ."; } ;
        fi
        #}
        _debug "Closing ROX-Filer if necessary..."
        _pidof $QUIET ROX-Filer && rox -D "$mountPOINT";
;;
mount) :;;
*) _exit 42 "Unhandled '$WHAT' -- use 'mount' or 'umount' .";;
esac

case $WHAT in
umount)

#mountpoint $QUIET "$deviceORpoint" && fuser -m "$deviceORpoint"

if [ "$NTFSMNTPT" != "" ]; then
        if [ "$opI" == '-i' ]; then #fusermount passes -i option to /bin/mount
        #deviceORpoint=`echo $@ | sed "s%^'%%;s%'$%%"`
        _notice "busybox $WHAT \"$deviceORpoint\" $opFL $opNFL $opF $opI $opN $opR $opL $opVERB"
                 busybox $WHAT "$deviceORpoint" $opFL $opNFL $opF $opI $opN $opR $opL $opVERB
        RETVAL=$?
        else
        #fusermount can only unmount by giving the mount-point...
        _notice "fusermount -u $NTFSMNTPT"
                 fusermount -u $NTFSMNTPT
        RETVAL=$?
        fi
else
 #deviceORpoint=`echo $@ | sed "s%^'%%;s%'$%%"`
 _info "busybox $WHAT \"$deviceORpoint\" $opFL $opNFL $opF $opI $opN $opR $opL $opVERB"
        busybox $WHAT "$deviceORpoint" $opFL $opNFL $opF $opI $opN $opR $opL $opVERB
 RETVAL=$?
fi
;;
mount)
      case $opT in
      *ntfs*)               #*ntfs*)?
       test -b "$*" && {   #ntfs-3g does not look into /etc/fstab?

        test "`which ntfs-3g.probe`" && {
         _debug "Running ntfs-3g.probe --readwrite on '$*':"
         ntfs-3g.probe --readwrite $*
         RETVAL=$?
         test "$RETVAL" = 0 && _debug "OK."
                }

        mkdir -p /mnt/${@##*/}; set - $@ /mnt/${@##*/}; _debug "ntfs:$*";
        }

       test "$RETVAL" || RETVAL=0

       test "$RETVAL" = 0 && {
       _notice "ntfs-3g -o umask=0,no_def_opts $@ $opVERB $opLABEL $opUUID $opDRY $opO $opR $opW $opI $opS"
                ntfs-3g -o umask=0,no_def_opts $@ $opVERB $opLABEL $opUUID $opDRY $opO $opR $opW $opI $opS $opSHOWL
       RETVAL=$?
        }

       test "$RETVAL" = 0 || {
               if test "$RETVAL" = 14; then { _warn "Need to remove hibernation file to mount read-write";
                 _notice "ntfs-3g $@ -o umask=0,no_def_opts,remove_hiberfile $opVERB $opLABEL $opUUID $opDRY $opO $opR $opW $opI $opS"
                          ntfs-3g $@ -o umask=0,no_def_opts,remove_hiberfile $opVERB $opLABEL $opUUID $opDRY $opO $opR $opW $opI $opS $opSHOWL
                 RETVAL=$?
               }
             elif test "$RETVAL" = 4 -o "$RETVAL" = 10 -o "$RETVAL" = 15; then { _warn "Attempt to force read-write mount";
                 _notice "ntfs-3g $@ -o force,umask=0,no_def_opts $opVERB $opLABEL $opUUID $opDRY $opO $opT $opR $opW $opI $opS"
                          ntfs-3g $@ -o force,umask=0,no_def_opts $opVERB $opLABEL $opUUID $opDRY $opO $opT $opR $opW $opI $opS $opSHOWL
                 RETVAL=$?
               }
             else { _err "Unhandled ntfs-3g return code '$RETVAL'"; } # 11:Wrong Option,No mountpoint specified ; 21:No such File or Dir
               fi
                        }
        test "$RETVAL" = 0 || { _notice "Will attempt to mount ntfs partition using the limited kernel driver";
         _notice "busybox mount $@ $opVERB $opLABEL $opUUID $opDRY $opO $opT $opR $opW $opI $opN $opS"
                  busybox mount $@ $opVERB $opLABEL $opUUID $opDRY $opO $opT $opR $opW $opI $opN $opS
         RETVAL=$?
         }
      ;;
      *fat*|*FAT*|*Fat*)
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
       _notice "busybox mount -t vfat -o shortname=mixed,quiet${NLS_PARAM} $* $opVERB $opLABEL $opUUID $opDRY $opO $opT $opR $opW $opI $opN $opS"
                busybox mount -t vfat -o shortname=mixed,quiet${NLS_PARAM} $* $opVERB $opLABEL $opUUID $opDRY $opO $opT $opR $opW $opI $opN $opS
       RETVAL=$?
      ;;
      *)
      if test "$opFORK" -o "$opUUID" -o "$opLABEL" -o "$opSHOWL" -o "`echo "$longOPS" | grep -E 'bind|move|make'`"; then
      # use mount-FULL
        if test "$opUUID"; then
         MntPoints=$(grep -w "`echo "$opUUID" | cut -f2 -d' '`" /etc/fstab | awk '{print $2}')
         for oneMTP in $MntPoints; do
         test -d "$oneMTP" || mkdir -p "$oneMTP"
         done
        fi
        if test "$opLABEL"; then
         _debug "opLABEL='$opLABEL'"
         lONLY=`echo "$opLABEL" | cut -f2 -d' '`
         _debug "lONLY='$lONLY'"
         MntPoints=$(grep -w "$lONLY" /etc/fstab | awk '{print $2}')
         for oneMTP in $MntPoints; do
         _debug "oneMTP='$oneMTP'"
         test -d "$oneMTP" || mkdir -p "$oneMTP"
         done
        fi
       _notice "$WHAT-FULL $@ $opVERB $opLABEL $opUUID $opDRY $opO $opMO $opT $opR $opW $opI $opN $opS $opFORK $opSHOWL"
                $WHAT-FULL $@ $opVERB $opLABEL $opUUID $opDRY $opO $opMO $opT $opR $opW $opI $opN $opS $opFORK $opSHOWL
       RETVAL=$?
      else # use busybox mount
       _notice "busybox $WHAT $@ $opVERB $opLABEL $opUUID $opDRY $opO $opMO $opT $opR $opW $opI $opN $opS"
                busybox $WHAT $@ $opVERB $opLABEL $opUUID $opDRY $opO $opMO $opT $opR $opW $opI $opN $opS
       RETVAL=$?
      fi #use mount-FULL
      ;;
      esac
;;
*) _exit 43 "Unhandled '$WHAT' -- use 'mount' or 'umount' .";;
esac

_notice "RETVAL=$RETVAL"

_umount_rmdir()
{
 [ "$DISPLAY" ] && rox -D "$mountPOINT";
 _debug "_umount_rmdir:mountpoint $QUIET $*";
 mountpoint $QUIET $* || rmdir $*;
}

_update()
{
 test "$DISPLAY" && _update_partition_icon
 #test "$noROX" || rox -x /mnt -x "`pwd`"
 test $WHAT = umount || return 0

 test "`echo "$mountPOINT" | grep -E '/proc|/sys'`" && return 0
 test -d "$mountPOINT" && _umount_rmdir "$mountPOINT"

 _check_tmp_rw || return 59
 while read oneDIR
 do
 test "$oneDIR" || continue
 #test "`echo "$oneDIR" | grep -E '/proc|/sys'`" && continue
 _umount_rmdir "$oneDIR"
 done<<EoI
`_command find /mnt -maxdepth 1 -type d -empty`
EoI
}

test "$RETVAL" = 0 && _update

test "`readlink /etc/mtab`" = "/proc/mounts" || ln -sf /proc/mounts /etc/mtab

exit $RETVAL
