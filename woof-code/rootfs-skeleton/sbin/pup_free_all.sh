#!/bin/ash

. /etc/rc.d/f4puppy5
. /etc/rc.d/PUPSTATE
. /etc/eventmanager.cfg

### *** do not check for powertimeout if these apps are running *** #
# space delimited for loops and pidof
 DO_NOT_DISTURB_DL='axel curl dotpup downloadpkgs.sh gcurl gimv installpkg.sh petget wget'
# staff delimited and regular expr escaped by \ for grep -E ; max 15 chars
DO_NOT_DISTURB_DL2='axel|curl|dotpup|downloadpkgs\.sh|gcurl|gimv|installpkg\.sh|petget|wget'
 DO_NOT_DISTURB_APPS='burniso2cd cdrecord dotpup gimv growisofs mhwaveedit mplayer pburn pcdripper '\
' pdvdrsab ripoff vlc xfmedia xine xmms xorrecord xorriso'
DO_NOT_DISTURB_APPS2='burniso2cd|cdrecord|dotpup|gimv|growisofs|mhwaveedit|mplayer|pburn|pcdripper'\
'|pdvdrsab|ripoff|vlc|xfmedia|xine|xmms|xorrecord|xorriso'
 DO_NOT_DISTURB_COMPILE='gcc make'
DO_NOT_DISTURB_COMPILE2='gcc|make'
 DO_NOT_DISTURB_MM='ffplay gimv gmplayer gnome-mplayer gxine mhwaveedit mplayer vlc xfmedia xine xmms'
DO_NOT_DISTURB_MM2='ffplay|gimv|gmplayer|gnome-mplayer|gxine|mhwaveedit|mplayer|vlc|xfmedia|xine|xmms'

 DO_NOT_DISTURB_INSTALL='burniso2cd bzip2 bunzip2 cdrecord dotpup dpkg gimv growisofs grub4dosconfig grubconfig grub-install '\
' gunzip gzip installpkg.sh mksquashfs pburn pcdripper pdvdrsab ppm puppyinstaller pupzip rar ripoff rpm2cpio tar '\
' unrar unsquashfs unxz unzip xarchive xorrecord xorriso xz zip'\
'' #SED more into MARKER
DO_NOT_DISTURB_INSTALL2='burniso2cd|bzip2|bunzip2|cdrecord|dotpup|dpkg|gimv|growisofs|grub4dosconfig|grubconfig|grub-install|'\
'gunzip|gzip|installpkg\.sh|mksquashfs|pburn|pcdripper|pdvdrsab|ppm|puppyinstaller|pupzip|rar|ripoff|rpm2cpio|tar|'\
'unrar|unsquashfs|unxz|unzip|xarchive|xorrecord|xorriso|xz|zip'\
'' #SED more into MARKER

 DO_NOT_DISTURB_ALL='axel burniso2cd cdrecord curl dotpup downloadpkgs.sh gcc gcurl gimv growisofs installpkg.sh make mhwaveedit mplayer '\
' pburn pcdripper pdvdrsab petget ripoff vlc wget xfmedia xine xmms xorrecord xorriso'\
'' #SED more into MARKER
DO_NOT_DISTURB_ALL2='axel|burniso2cd|cdrecord|curl|dotpup|downloadpkgs\.sh|gcc|gcurl|gimv|growisofs|installpkg\.sh|make|mhwaveedit|mplayer'\
'|pburn|pcdripper|pdvdrsab|petget|ripoff|vlc|wget|xfmedia|xine|xmms|xorrecord|xorriso'\
'' #SED more into MARKER

 DO_NOT_DISTURB_ALL=`echo "$DO_NOT_DISTURB_DL
$DO_NOT_DISTURB_APPS
$DO_NOT_DISTURB_COMPILE
$DO_NOT_DISTURB_MM
$DO_NOT_DISTURB_INSTALL" | tr ' ' '\n' | sort -u | tr '\n' ' '`

echo $DO_NOT_DISTURB_ALL

DO_NOT_DISTURB_ALL2=`echo "$DO_NOT_DISTURB_DL
$DO_NOT_DISTURB_APPS
$DO_NOT_DISTURB_COMPILE
$DO_NOT_DISTURB_MM
$DO_NOT_DISTURB_INSTALL" | tr ' ' '\n' | sort -u  | tr '\n' '|' | sed 's#^|*##;s#|*$##;s#\.#\\\.#g' | tr -s '|'`

echo
echo $DO_NOT_DISTURB_ALL2

_free(){  # _free_savefile _free_rootfs
#called every POLL_PLUG_DEVICE seconds.
 case $PUPMODE in
  6|12) #frugal to whole partition|frugal to save-file (on HDD)
   #SIZEFREEM=`/bin/df -m | grep -m1 ' /initrd/pup_rw$' | tr -s ' ' | cut -f 4 -d ' '`
    SIZEFREESAVE_MB=`/bin/df -m | awk '{if ($NF == "/initrd/pup_rw") print $4}' | tail -n1`
  ;;
  *) # 2|5
   #SIZEFREEM=`/bin/df -m | grep -m1 ' /$'              | tr -s ' ' | cut -f 4 -d ' '`
    SIZEFREESAVE_MB=`/bin/df -m | awk '{if ($NF == "/") print $4}' | tail -n1`
  ;;
 esac
 WARNMSG=""
 [ "$SIZEFREESAVE_MB" ] || WARNMSG="Could not determine free space using df plus filters"
 [ -s /tmp/pup_event_sizefreem ] && read PREVSIZEFREEM </tmp/pup_event_sizefreem
 [ $PREVSIZEFREEM -eq $SIZEFREESAVE_MB ] && return
 if [ $SIZEFREESAVE_MB -lt 10 ];then
  WARNMSG="$WARNMSG
   WARNING: Personal storage getting full, strongly recommend you resize it or delete files!"
  if [ -d /initrd/pup_rw/lib/modules/all-firmware -a "$ZDRVINIT" = "yes" ];then
   case $PUPMODE in 6|12)
   _delete_drivers /initrd/pup_rw #save layer is at top, delete mods.
   ;;
   esac
  else
    :
  fi
  case $PUPMODE in 12)
   if test "$DISPLAY"; then
    pidof resizepfile.sh >>$OUT || resizepfile.sh &
   fi
  ;;
  esac
 fi

 if [ "$WARNMSG" != "" ];then
  if test "$DISPLAY"; then
   killall yaf-splash >>$OUT 2>>$ERR
   yaf-splash -margin 2 -bg red -bw 0 -placement top -font "9x15B" -outline 0 -text "$WARNMSG" &
  else
   echo -e '\033[1;31m'"$WARNMSG"'\033[0;39m'
  fi
 fi

 VIRTUALFREEM=$SIZEFREESAVE_MB

 if [ "$ZDRVINIT" = "yes" ];then                         #full set of modules present, moved from initrd.
  if [ -d /initrd/pup_rw/lib/modules/all-firmware ];then #have not yet deleted modules.
     #calc the "virtual" free space (would have if modules not there...)
     VIRTUALFREEM=$(( SIZEFREESAVE_MB + SIZE_MODS_MB ))
     #allow for some mods will not be deleted.
     VIRTUALFREEM=$(( VIRTUALFREEM - 1 ))
  fi
 fi

 #save to a file, freememapplet can read this...
 echo "$VIRTUALFREEM" >/tmp/pup_event_sizefreem
 #[ $PUPMODE -eq 5 -o $PUPMODE -eq 2 ] && return 0 #5=first boot, no msgs at top of screen. 2=full install

}

_free_flash(){
#PUPMODE 3,7,13. called every PULL_PLUG_DEVICE seconds. 3=full on internal flash, 7 frugal to whole partition, 13=frugal to save-file
# WARNMSG=""

  SIZEFREESAVE_MB=`/bin/df -m | awk '{if ($NF == "/initrd/pup_ro1") print $4}' | tail -n1`

   SIZEFREETMP_MB=`/bin/df -m | awk '{if ($NF == "/initrd/pup_rw") print $4}' | tail -n1`

 WARNMSG=""
 [ "$SIZEFREESAVE_MB" ] || WARNMSG="Could not determine free space in save-file using df and filters"
  [ "$SIZEFREETMP_MB" ] || WARNMSG="$WARNMSG
Could not determine free space in /tmp layer"

 [ -s /tmp/pup_event_sizefreem ] && read PREVSIZEFREEM </tmp/pup_event_sizefreem
 [ -s /tmp/pup_event_sizetmpm ]  && read PREVSIZETMPM  </tmp/pup_event_sizetmpm
 [ "$PREVSIZEFREEM" = $SIZEFREESAVE_MB -a "$PREVSIZETMPM" = $SIZEFREETMP_MB ] && return

 if [ $SIZEFREESAVE_MB -lt 10 ]; then
  WARNMSG="$WARNMSG
   WARNING: Personal storage file getting full, strongly recommend you resize it and reboot or delete files!"
  if [ -d /initrd/pup_ro1/lib/modules/all-firmware -a "$ZDRVINIT" = "yes" ];then
   _delete_drivers /initrd/pup_ro1 #delete modules in save layer only.
  WARNMSG="$WARNMSG
  NOTE: Have removed drivers and firmware in /initrd/pup_ro1/lib/modules"
  else
   :
  fi
  case $PUPMODE in 13)
   if test "$DISPLAY"; then
    pidof resizepfile.sh >>$OUT || resizepfile.sh &
   fi
  ;;
  esac
 fi

 # REM: try freeing ^unused^ RAM
 if [ $SIZEFREETMP_MB -lt 5 ]; then
  echo '3' >/proc/sys/vm/drop_caches && {
  sleep 2;
  SIZEFREETMP_MB=`/bin/df -m | awk '{if ($NF == "/initrd/pup_rw") print $4}' | tail -n1`
  }
 fi

 if [ $SIZEFREETMP_MB -lt 5 ]; then
  WARNMSG="$WARNMSG
   WARNING: RAM working space only ${SIZETMPM}MB, recommend a reboot which will flush the RAM"
  if [ -d /initrd/pup_rw/lib/modules/all-firmware -a "$ZDRVINIT" = "yes" ];then
   _delete_drivers /initrd/pup_rw #delete modules in top tmpfs layer only.
   WARNMSG="$WARNMSG
   NOTE: Have removed drivers and firmware in /initrd/pup_rw/lib/modules"
  else
  :
  fi
  case $PUPMODE in 13)
   if test "$DISPLAY"; then
    pidof resizepfile.sh >>$OUT || resizepfile.sh &
   fi
  ;;
  esac
 fi

 if [ "$WARNMSG" != "" ]; then
  if test "$DISPLAY"; then
   killall yaf-splash >>$OUT 2>>$ERR
   yaf-splash -margin 2 -bg red -bw 0 -placement top -font "9x15B" -outline 0 -text "$WARNMSG" &
  else
   echo -e '\033[1;31m'"$WARNMSG"'\033[0;39m'
  fi
 fi

 VIRTUALFREEM=$SIZEFREESAVE_MB
 if [ "$ZDRVINIT" = "yes" ]; then #full set of modules present at bootup.
  if [ -d /initrd/pup_ro1/lib/modules/all-firmware ];then #have not yet deleted modules.
   #calc the "virtual" free space (would have if modules not there...)
   VIRTUALFREEM=$(( SIZEFREESAVE_MB + SIZE_MODS_MB ))
   #allow for some mods will not be deleted.
   VIRTUALFREEM=$(( VIRTUALFREEM - 1 ))
  fi
 fi

 echo "$SIZEFREETMP_MB" > /tmp/pup_event_sizetmpm
 #save to a file, freememapplet can read this...
 echo "$VIRTUALFREEM" > /tmp/pup_event_sizefreem

}

_savepuppy(){
#called every POLL_PLUG_DEVICE seconds.
 #if [ -f /tmp/snapmergepuppyrequest ]; then #by request.
  #rm $VERB -f /tmp/snapmergepuppyrequest
  SAVECNT=$((SAVECNT + POLL_PLUG_DEVICE + POLL_PLUG_DEVICE))
  [ "$SAVECNT" -ge $RAMSAVEINTERVAL -o -f /tmp/snapmergepuppyrequest ] || return 0
  SAVECNT=0
  rm $VERB -f /tmp/snapmergepuppyrequest
  yaf-splash -font "8x16" -outline 0 -margin 4 -bg orange -placement top -text "Saving RAM to 'pup_save' file..." &
  YAFPID=$!
  pidof sync >>$OUT || sync
  nice -n 19 /usr/sbin/snapmergepuppy
  kill $YAFPID >>$OUT 2>>$ERR
 #fi
}

#note that init script in initrd takes care of restoring modules if enough space.
_delete_drivers(){
# Called from _free() and _free_flash().
# Deletes modules to create more free space.
# passed param: /pup_rw=delete tmpfs top layer only.
 [ "$*" ] || return
 DEL_LAYER=$1
 #find out what modules are loaded, keep those...
 for oneKEEP_MOD in `lsmod | cut -f 1 -d ' ' | grep -v 'Module'`
 do
  oneKEEP_SPEC=`modinfo -F filename ${oneKEEP_MOD}`
  oneKEEP_PATH=${oneKEEP_SPEC%/*}
  mkdir $VERB -p /tmp/${oneKEEP_PATH}
  cp $VERB -af ${oneKEEP_SPEC} /tmp/${oneKEEP_PATH}/
 done
 if [ "$DEL_LAYER" != "" ];then
  rm $VERB -rf ${DEL_LAYER}/lib/modules
 else
  if [ $PUPMODE -eq 3 -o $PUPMODE -eq 7 -o $PUPMODE -eq 13 ];then  #flash
   rm $VERB -rf ${SAVE_LAYER}/lib/modules
  fi
  rm $VERB -rf /lib/modules
 fi
 cp $VERB -af /tmp/lib/modules /lib/modules
 depmod $VERB -a
}

_check_disturb_ps_grep(){ # 25-50% less CPU signature than pidof
local RUNPS=`ps -o comm`
echo "$RUNPS" | grep $Q -E "$DO_NOT_DISTURB_ALL2"
}

_check_disturb_pidof(){ # same heavy as for pidof done
pidof $DO_NOT_DISTURB_ALL >$OUT
}

while :
do

sleep $POLL_PLUG_DEVICE

 case $PUPMODE in
  3|7|13)  #flash
     _free_flash;;
  5|16|24|17|25) #unipup. 2015-10-14 testing PUPMODE 5 set here
     _free_initrd;;
  *) #2|5 6|12 #normal harddrive
     _free;;
 esac

sleep $POLL_PLUG_DEVICE
_check_disturb_ps_grep && continue

 case $PUPMODE in 3|7|13)
   [ "$RAMSAVEINTERVAL" -ge 1 -o -f /tmp/snapmergepuppyrequest ] && _savepuppy
   ;;
 esac

done
