For Puppy 4.1+
--------------

########################################################################
#
#
#
#
#
# /dev/sda5:
# LABEL="MacPup430_F3"
# UUID="07443de5-1fab-4656-a3ab-7b1c14ccc8c8"
# TYPE="ext3"
# DISTRO_VERSION=430·#481·#416·#218·#478······#####change·this·as·required#####
# DISTRO_BINARY_COMPAT="puppy"·#"ubuntu"·#"puppy"·#####change·this·as·required#####
# case·$DISTRO_BINARY_COMPAT·in
# ubuntu)
# DISTRO_NAME="Jaunty·Puppy"
# DISTRO_FILE_PREFIX="upup"
# DISTRO_COMPAT_VERSION="jaunty"
# ;;
# debian)
# DISTRO_NAME="Lenny·Puppy"
# DISTRO_FILE_PREFIX="dpup"
# DISTRO_COMPAT_VERSION="lenny"
# ;;
# slackware)
# DISTRO_NAME="Slack·Puppy"
# DISTRO_FILE_PREFIX="spup"
# DISTRO_COMPAT_VERSION="12.2"
# ;;
# arch)
# DISTRO_NAME="Arch·Puppy"
# DISTRO_FILE_PREFIX="apup"
# DISTRO_COMPAT_VERSION="200904"
# ;;
# t2)
# DISTRO_NAME="T2·Puppy"
# DISTRO_FILE_PREFIX="tpup"
# DISTRO_COMPAT_VERSION="puppy5"
# ;;
# puppy)·#built·entirely·from·Puppy·v2.x·or·v3.x·or·4.x·pet·pkgs.
# DISTRO_NAME="Puppy"
# DISTRO_FILE_PREFIX="pup"·#"ppa"·#"ppa4"·#"pup2"··#pup4··###CHANGE·AS·REQUIRED,·recommend·limit·four·characters###
# DISTRO_COMPAT_VERSION="4"·#"2"··#4·····###CHANGE·AS·REQUIRED,·recommend·single·digit·5,·4,·3,·or·2###
# ;;
# esac
# PUPMODE=2
# KERNVER=2.6.30.6-KRG-i486
# ATADRIVES='·sda'
# USB_SATAD=''
# PUP_HOME='/'
# Linux·puppypc·2.6.30.6-KRG-i486·#1·SMP·Sun·Jan·2·20:32:12·GMT-1·2011·i686·GNU/Linux
# Xserver=/usr/X11R7/bin/Xvesa_stripped_upx9
# $LANG=en_US
# today=Mon·Oct·24·22:48:08·CEST·2011
#
#
#
#
#
########################################################################


Firewall:

When the firewall is installed, it will be in /etc/rc.d
folder as "rc.firewall" and the file "rc.local" will
have an entry to start it.
"rc.local" is called from "rc.sysinit".

Startup:

When Puppy boots, the order of execution of the
scripts is (except for a full-hd installation and UniPup):

  /init (in the initial ramdisk)

  switch_root occurs, some content of / relocates to /initrd
  and the following scripts then executed:

  /etc/rc.d/rc.sysinit
    Called from rc.sysinit:
    /etc/rc.d/rc.update
    /etc/rc.d/rc.network  (as a parallel process)
    /etc/rc.d/rc.services (as a parallel process)
    /etc/rc.d/rc.country
    /etc/rc.d/rc.local    (created by rc.sysinit if doesn't exist)
    
  /etc/profile

Puppy doesn't use runlevels.

Note, the only script listed above that is not user-editable is init,
as this is pristine out of initrd.gz.

Full-hd installation
--------------------
An exception to the above description is a full hard drive installation.
In that case, initrd.gz is not used, and there is no pivot_root and no
/initrd folder. This mode has PUPMODE=2.
The above sequence is still correct, except that the Busybox /sbin/init
is the first thing that executes, then rc.sysinit, etc.

UniPup
------
UniPup is a variant of Puppy that runs totally in the initramfs.
The execution sequence is essentially the same as for the full-hd
installation.
In this case, the first script that executes is /init but this is just
a symlink to /bin/busybox. Then it is rc.sysinit and as shown above.


Note1: /etc/rc.d/functions is from Slackware. Some service scripts in /etc/init.d/
      may use it.
Note2: /etc/rc.d/functions4puppy4 are various functions needed by Puppy boot
       scripts, pup_event_backend* and pup_event_frontend* scripts.
