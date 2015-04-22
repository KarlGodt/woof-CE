For Puppy 4.1+
--------------

########################################################################
#
#
#
#
#
# /dev/hda8:
# LABEL="MacPup431_O2"
# UUID="6d9a8e91-c301-4ff8-9875-97ec708cbee8"
# TYPE="ext3"
# DISTRO_NAME='Puppy'
# DISTRO_VERSION=431
# DISTRO_BINARY_COMPAT='puppy'
# DISTRO_FILE_PREFIX='pup'
# DISTRO_COMPAT_VERSION='4'
# PUPMODE=2
# KERNVER=2.6.30.9-i586-dpup005-Celeron2G
# PUP_HOME='/'
# SATADRIVES='·'
# USBDRIVES='·'
# Linux·puppypc·2.6.30.9-i586-dpup005-Celeron2G·#6·SMP·Sat·Jan·15·13:35:51·GMT-8·2011·i686·GNU/Linux
# Xserver=/usr/X11R7/bin/Xorg
# $LANG=de_DE@euro
# today=Do·27.·Okt·22:46:24·GMT-1·2011
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
