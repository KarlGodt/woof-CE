For Puppy 4.1+
--------------

########################################################################
#
#
#
#
#
# /dev/hda7
# /dev/hda7:
# LABEL="/"
# UUID="429ee1ed-70a4-43a5-89f8-33496c489260"
# TYPE="ext4"
# DISTRO_NAME='LucidÂPuppy'
# DISTRO_VERSION=218
# DISTRO_MINOR_VERSION=00
# DISTRO_BINARY_COMPAT='ubuntu'
# DISTRO_FILE_PREFIX='luci'
# DISTRO_COMPAT_VERSION='lucid'
# DISTRO_KERNEL_PET='linux_kernel-2.6.33.2-tickless_smp_patched-L3.pet'
# PUPMODE=2
# SATADRIVES=''
# PUP_HOME='/'
# PDEV1='hda7'
# DEV1FS='ext4'
# LinuxÂpuppypcÂ2.6.31.14Â#1ÂMonÂJanÂ24Â21:03:21ÂGMT-8Â2011Âi686ÂGNU/Linux
# Xserver=/usr/bin/Xorg
# $LANG=en_US
# today=TueÂOctÂ25Â12:48:05ÂGMT+1Â2011
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
