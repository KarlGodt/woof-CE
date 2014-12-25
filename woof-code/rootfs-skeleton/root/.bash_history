dosfsck -n /dev/sdc1
dosfsck -n -v /dev/sdc1
dosfsck -n -v /dev/sdc2
dosfsck -n -v /dev/sdd1
ps | grep strace
top

Mon Nov 10 22:56:41 GMT+1 2014

dmesg | grep -i squash | grep -o -i 'version.*'
dmesg | grep -i squash | busybox grep -o -i 'version.*'
dmesg | grep -i squash | busybox grep -o 'version.*'
dmesg | grep -i squash*'
dmesg | grep -i squash
modprobe -v squashfs
dmesg | grep -i squash
dmesg | grep -i squash | busybox grep -o -i 'version.*'
dmesg | grep -i squash | busybox grep -oi  'version.*'
dmesg | grep -i squash | grep -oi  'version.*'
dmesg | grep -i squash | grep -io  'version.*'
dmesg | grep -i squash | grep -i -o  'version.*'
dmesg | grep -i squash | busybox grep -i -o  'version.*'
ls -1v /dev/loop* | wc -l
ls -1v /dev/loop*
ls -1v /dev/loop[0-9]*
ls -1v /dev/loop[0-9]* | wc -l
ls -1v /dev/loop[0-9]*
echo `ls -1v /dev/loop[0-9]*`
echo `ls -1v /dev/loop[0-9]*` | grep -w
cat Xmessage*
xmessage "HELLO"
strace xmessage "HELLO"
xmessage "HELLO"
scrollHorizontal=Never xmessage "HELLO"
message.scrollHorizontal=Never xmessage "HELLO"
"message.scrollHorizontal"=Never xmessage "HELLO"
xmessage "HELLO"
geany /usr/bin/xwin
geany /usr/bin/filemnt
geany /usr/sbin/filemnt
ls /sys/devices/pci0000:00/power/wakeup
ls /sys/devices/pci0000:00/power/
cat /sys/devices/pci0000:00/power/autosuspend
cat /sys/devices/pci0000:00/power/autosuspend_delay
cat /sys/devices/pci0000:00/power/autosuspend_delay_ms
grep -H '.*'  /sys/devices/pci0000:00/power/autosuspend_delay_ms
grep -H -E '|.*'  /sys/devices/pci0000:00/power/autosuspend_delay_ms
grep -H -E '|.*'  /sys/devices/pci0000:00/power/autosuspend_delay_ms 2>&1
ash
ls /sys/devices/pci0000:00/power/
grep -H '.*' /sys/devices/pci0000:00/power/*
F=`grep -H '.*' /sys/devices/pci0000:00/power/*`
echo "$F"
F=`grep -H '.*' /sys/devices/pci0000:00/power/* 2>&1`
echo "$F"
F=` grep -H '.*' /sys/devices/pci0000:00/power/* 2>&1`
echo "$F"
ash
F=` grep -s -H '.*' /sys/devices/pci0000:00/power/* 2>&1`
echo "$F"
ps -o pid | grep -v grep | grep $yPID
ps -o pid | grep -v grep | grep -w "$yPID"
yPID=1
ps -o pid | grep -v grep | grep -w "$yPID"
ps -o pid | grep -v grep
ps -A -o pid | grep -v grep
ps -A -o pid | grep -v grep | grep -w "$yPI"
ps -A -o pid | grep -v grep | grep -w "$yPID"
ps -A -o pid | grep -v grep | grep -w "$yPID"; echo $?
yPID=1001
ps -A -o pid | grep -v grep | grep -w "$yPID"; echo $?
dmesg | grep -i squash | grep -o -i 'version.*'
dmesg | grep -i squash | busybox grep -o -i 'version.*'
dmesg | grep -i squash | busybox grep -o 'version.*'
dmesg | grep -i squash*'
dmesg | grep -i squash
modprobe -v squashfs
dmesg | grep -i squash
dmesg | grep -i squash | busybox grep -o -i 'version.*'
dmesg | grep -i squash | busybox grep -oi  'version.*'
dmesg | grep -i squash | grep -oi  'version.*'
dmesg | grep -i squash | grep -io  'version.*'
dmesg | grep -i squash | grep -i -o  'version.*'
dmesg | grep -i squash | busybox grep -i -o  'version.*'
ls -1v /dev/loop* | wc -l
ls -1v /dev/loop*
ls -1v /dev/loop[0-9]*
ls -1v /dev/loop[0-9]* | wc -l
ls -1v /dev/loop[0-9]*
echo `ls -1v /dev/loop[0-9]*`
echo `ls -1v /dev/loop[0-9]*` | grep -w
echo `ls -1v /dev/loop[0-9]*` | wc -w
echo `ls /dev/loop[0-9]*` | wc -w
echo `ls /dev/loop[0-9]*`
echo `ls /dev/loop[0-9]*` | wc -w
read NR <<EoI
echo $NR
read NR <<EoI
echo $NR
losetup -f; echo $?
xmessage -buttons "Quit:190,ROX-Filer:191,console:192,Unmount:193,Unmount all $IMGBASE:194,Mount another time:199" -title "$xmTITLE" "$imgFILE
is already mounted and in-use by Puppy .
Do you want to unmount it or mount it
to another mount point ?
"
xmessage -buttons "Quit:190,ROX-Filer:191,console:192" -buttons "Unmount:193,Unmount all $IMGBASE:194,Mount another time:199" -title "$xmTITLE" "$imgFILE
is already mounted and in-use by Puppy .
Do you want to unmount it or mount it
to another mount point ?
"
xmessage -buttons "Quit:190,ROX-Filer:191,console:192,Unmount:193,Unmount all $IMGBASE:194,Mount another time:199" -title "$xmTITLE" "$imgFILE
is already mounted and in-use by Puppy .
Do you want to unmount it or mount it
to another mount point ?
"
xmessage -buttons "Quit:190,ROX-Filer:191,console:192,\nUnmount:193,Unmount all $IMGBASE:194,Mount another time:199" -title "$xmTITLE" "$imgFILE
is already mounted and in-use by Puppy .
Do you want to unmount it or mount it
to another mount point ?
"
xmessage -buttons "Quit:190,ROX-Filer:191,console:192,
Unmount:193,Unmount all $IMGBASE:194,Mount another time:199" -title "$xmTITLE" "$imgFILE
is already mounted and in-use by Puppy .
Do you want to unmount it or mount it
to another mount point ?
"
for i in yellow green blue red; do yaf-splash -bg $i -text "   Hello from color $i   " &yPID=$! ; done
for i in yellow green ; do yaf-splash -bg $i -text "   Hello from color $i   " &yPID=$! ; done
for i in yellow green ; do yaf-splash -bg $i -text "   Hello from color $i   " &yPID=$! ; sleep 3;done
fuser -v -m /mnt/sda2
mount
mount | grep -E '^/dev/loop[0-9]? ' |grep -v '/initrd'
mount | grep -E '^/dev/loop[0-9]\? ' |grep -v '/initrd'
mount | grep -E '^/dev/loop[0-9]* ' |grep -v '/initrd'
mount | grep -E '^/dev/loop[0-9]+ ' |grep -v '/initrd'
mount | grep -E '^/dev/loop[0-9]* ' |grep -v '/initrd'
mount | grep -E '^/dev/loop[0-9]? ' |grep -v '/initrd'
mount | grep -e '^/dev/loop[0-9]? ' |grep -v '/initrd'
mount | grep -Ee '^/dev/loop[0-9]? ' |grep -v '/initrd'
mount | grep -Ee '^/dev/loop[0-9]\? ' |grep -v '/initrd'
mount | grep -G '^/dev/loop[0-9]? ' |grep -v '/initrd'
mount | grep -G '^/dev/loop[0-9]\? ' |grep -v '/initrd'
mount
geany /usr/bin/xwin
source /etc/rc.d/f4puppy5
_notice "\\033[0;31m"'Has hardware profile changed ?'"\\033[0;39m"
lsmod
uname -r
ddcprobe
dmidecode| grep -i capacity
free
find -type f
dmidecode
df
modprobe -l | grep apm
modprobe -v apm
pwd
grep -m3 init *
grep -m3 __init *
grep -r -m3 __init *
grep -r -m3 __init * >/root/kernel_doc___init.lst
grep -r -m3 __setup *
find -name "*.h" -exec grep -H -m1 '_init' {} \;
find -name "*.h" -exec grep -H -m1 -w '__init' {} \;
find -name "*.h" -exec grep -H -m1 -w 'INIT' {} \;
find -name "*.h" -exec grep -H -m1 -w 'INIT' {} \; >/root/kernel_INIT.lst
find /sys -name ".*"
find /sys -name ".*" >kernel_sysfs_hidden_files.lst

Tue Nov 11 13:14:03 GMT+1 2014

which strace
cat /proc/cmdline

Tue Nov 11 14:35:07 GMT+1 2014

awk '{print $1}' /proc/modules
grep 'photplug' /proc/sys/kernel/hotplug
dmidecode | grep -m3 iE 'maunfacturer|product|serial'
dmidecode | grep -m3 -iE 'maunfacturer|product|serial'
dmidecode | grep -m3 -iE 'manufacturer|product|serial'
dmidecode | grep -m3 -iE 'manufacturer|product|serial number'
dmidecode | grep -m3 iE 'manufacturer|product|serial number' | awk -F':' '{print $1}'
dmidecode | grep -m3 -iE 'manufacturer|product|serial number' | awk -F':' '{print $1}'
dmidecode | grep -m3 -iE 'manufacturer|product|serial number' | awk -F':' '{print $2}'
dmidecode | grep -m3 -iE 'UUID"
dmidecode | grep -m3 -iE 'UUID'
/root/_create_fstbootmodules_list.sh
time /root/_create_fstbootmodules_list.sh
echo ABC >/tmpa.tst /tmp/b.tst /tmp/c.tst
;s /tmp/*.tst
ls /tmp/*.tst
echo ABC >/tmp/a.tst /tmp/b.tst /tmp/c.tst
ls /tmp/*.tst
echo ABC >/tmp/a.tst >/tmp/b.tst >/tmp/c.tst
ls /tmp/*.tst
grep -H '.*'  /tmp/*.tst
echo ABC >/tmp/a.tst /tmp/b.tst /tmp/c.tst
grep -H '.*'  /tmp/*.tst
time /root/_create_fstbootmodules_list.sh
ddcprobe
uname -r
ddcprobe
uname -r
df

Tue Nov 11 18:51:33 GMT+1 2014

awk '{ if ($3 == "0") print $1}' /proc/modules
cat /proc/modules
geany /etc/rc.d/rc.shutdown
ps -A grep while
ps -A | grep while
ps -A | grep read
ps | grep _unnload
ps | grep _unload
kill -9 27186
ps | grep _unload
top
chmod +x _unload_unused_modules.sh 
./_unload_unused_modules.sh 
ps
./_unload_unused_modules.sh 

Tue Nov 11 19:23:01 GMT+1 2014

./heroes3
df
./heroes3
pwd
mount
./heroes3
ddcprobe
/mnt/heroes-3_5.5.sfs.12962/usr/local/games/Heroes3/heroes3
ddcprobe

Tue Nov 11 20:16:55 GMT+1 2014

ddcprobe

Tue Nov 11 21:53:13 GMT+1 2014

/mnt/heroes-3_5.5.sfs.17760/usr/local/games/Heroes3/heroes3
uname -r
./heroes3
ddcprobe

Tue Nov 11 22:14:42 GMT+1 2014

/mnt/heroes-3_5.5.sfs.12763/usr/local/games/Heroes3/heroes3
./heroes3
ddcprobe
serace -o /dev/null ddcprobe
strace -o /dev/null ddcprobe

Tue Nov 11 22:26:31 GMT+1 2014

/mnt/heroes-3_5.5.sfs.13026/usr/local/games/Heroes3/heroes3
./heroes3
./heroes2
./heroes3
/mnt/sda7/CHROOT.D/usr/local/games/Heroes3/heroes3
chroot .
pwd
mount -o bind /dev ./dev
mount -o bind /sys ./sys
mount -o bind /proc ./proc
chroot .
cp -a /usr/bin/strace .
Xorg --version
Xorg -version
which strace
ddcprobe
ddcprobe
xterm-266
cp -a /proc/config.gz .
mkdir "`uname -r`"
ls /proc/con*
modprobe -v configs
pwd
ls -l /dev/sda
ls -l /dev/sr0
uname -r
diff -up /mnt/sdb19/src/CONFIGS/3.6.11-KRG-iP4CelXeon-smp-pae-1000lzo/config /mnt/sdb19/src/CONFIGS/3.9.9-KRG-iCore2-smp-pae-srv1000gz/config >config_3.6.11-3.9.9_.diff
guvcview
uname -r
pwd
umount -l ./proc
umount -l ./dev
ls -l /dev/sd*

Wed Nov 12 00:15:35 GMT+1 2014

ls -l /dev/sd*
./replace_commit_files.sh 

Wed Nov 12 10:20:09 GMT+1 2014

wmexit
geany /boot/grub/menu-3.7.10.lst 
geany /sbin/pup_event_frontend_d
xwininfo -root
Xorg -help
man Xorg
wmexit
grep -i mouse /proc/bus/input/devices
grep -A 10 -i mouse /proc/bus/input/devices
grep -A 10 -ikbd /proc/bus/input/devices
grep -A 10 -i kbd /proc/bus/input/devices
grep -i event /proc/bus/input/devices
grep -B4 -i event /proc/bus/input/devices
wmexit
ls -l /dev/sd*
modprobe -l | grep cpu
modprobe -v cpuid
modinfo cpuid
geany /etc/rc.d/rc.sysinit
geany /etc/rc.d/rc.sysinit.run
geany /sbin/init
top
ddcprobe

Wed Nov 12 15:02:16 GMT+1 2014

./update_files_from_running_system 
uname -r
modprobe -l | grep ipmi
modprobe -l | grep ram
modprobe -l | grep apei
modinfo einj
modprobe -l | grep apei
modinfo erst-dbg
modprobe -v erst-dbg
modprobe -l | grep apei
modprobe -v einj
geany /etc/rc.d/f4puppy5
geany /bin/mount.sh
geany /etc/rc.d/rc.sysinit
geany /etc/rc.d/rc.sysinit.run
geany /sbin/init
dmesg
umount ./smack
which mountpoint
tupe -a mountpoint
type -a mountpoint
file /bin/mountpoint
file /usr/local/bin/mountpoint
grep selinux /usr/local/bin/mountpoint
grep this /usr/local/bin/mountpoint
strings /usr/local/bin/mountpoint | grep this
grep -r XUSER /etc/
grep mount *
cd ..
grep -r 'do this'  *
grep -r '-t proc'  *
grep -r '\-t proc'  *
find -name "*mdev*"
grep -r -m3 'selinuxfs' *
find /etc -iname "*selinux*"
find /etc -iname "*sec*"
ls /etc/securetty/*
ls /etc/securetty*
ls /etc/security
which ps
file /bin/ps
grep mount /bin/ps-FULL
pwd
cd ..
find -name "mount.c"
mount 
grep 'mount' *
grep 'Error,' *
grep -i 'Error,' *
grep -i 'do this' *
pwd
cd ..
pwd
grep -r -i 'do this' *
grep -r -i 'do this' * | grep -v '\*'
grep -r -i 'Error' * | grep -v '\*'
grep -r -i 'Error,' * | grep -v '\*'
pwd
cd ..
grep -r -i 'mount -t proc' * | grep -v '\*'
dmesg --help
dmesg
ls /tmp*
mkdir /tmp/mount.d
cd /tmp/mount.d
mkdir /dev/pstore
/bin/mount -v -t pstore nodev /dev/pstore
mkdir smack
/bin/mount -v -t smackfs nodev smack
dmesg | grep -i sel
dmesg | head
dmesg | grep -i sec
dmesg | grep -i security
dmesg | grep -A 10 -i security
dmesg | grep -i mount
ddcprobe
uname -r
NewKernelStats.sh 
uname -r
bbconfig | grep -i sel
./update_files_from_running_system 
geany /etc/rc.d/rc.shutdown

Wed Nov 12 19:35:21 GMT+1 2014

uname -r
top
kill 4723
top
kill -9 4723
top
/mnt/heroes-3_5.5.sfs.3990/usr/local/games/Heroes3/heroes3
ddcprobe
cat /proc/cmdline

Wed Nov 12 20:23:38 GMT+1 2014

uname -r
cat /proc/cmdline
modprobe -l | grep ipmi
grep TICK_ONESHOT /etc/modules/DOTconfig*
grep NO_HZ /etc/modules/DOTconfig*
grep HIGH_RES_TIMERS /etc/modules/DOTconfig*
geany `which wmexit`
ddd
./update_files_from_running_system 

Wed Nov 12 22:01:48 GMT+1 2014

uname -r
cat /proc/cmdline
dcprobe
dccprobe
ddcprobe

Wed Nov 12 23:17:52 GMT+1 2014


Thu Nov 13 01:14:36 GMT+1 2014


Thu Nov 13 01:43:04 GMT+1 2014

uname -r
cat /proc/cpuinfo
diff DOTconfig-3.7.10-KRG-pentiumpro-smp-lzo-klein-O2 DOTconfig-3.7.10-KRG-i486-smp-pae-lzo-little
diff -up DOTconfig-3.7.10-KRG-pentiumpro-smp-lzo-klein-O2 DOTconfig-3.7.10-KRG-i486-smp-pae-lzo-little >DIFF-DOTconfig.diff
geany DIFF-DOTconfig.diff 
make.tgl
make clean
make menuconfig
ls DOT*
diff DOTconfig-3.7.10-KRG-pentiumpro-smp-lzo-klein-O2 .confug
diff DOTconfig-3.7.10-KRG-pentiumpro-smp-lzo-klein-O2 .config
diff -s DOTconfig-3.7.10-KRG-pentiumpro-smp-lzo-klein-O2 .config
make menuconfig
diff -s DOTconfig-3.7.10-KRG-pentiumpro-smp-lzo-klein-O2 .config
make help
rm .config
make menuconfig
make help
make listnewconfig
find /lib/modules -name ".config"
find /lib/modules -name "*.config"
make localmodconfig
make menuconfig
cp -a .config LOCAL_MOD_CONFIG-`uname -r`
make menuconfig
cp -a DOTconfig-3.7.10-KRG-pentiumpro-smp-lzo-klein-O2 .config
make menuconfig
make.tgl
make
./make_install.sh 
make help
make kernelversion
date
geany /usr/include/ctype.h
geany /usr/include/selinux/selinux.h
geany /usr/include/selinux/*.h
find /usr/{local/lib,lib} -name "libselinux*"
file /usr/lib/libselinux.so
find /lib -name "libselinux*"
file /lib/libselinux.so.1
grep -i mount /lib/libselinux.so.1
strings /lib/libselinux.so.1 | grep -i mount
grep -r SELINUX_ENABLE * 
grep -r SELINUX * 
grep -r ENABLE_SELINUX * 
grep -r ENABLE_SELINUX * >/root/bb_ENABLE_SELINUX.lst
grep -r selinux_init_load_policy * 

Thu Nov 13 15:06:33 GMT+1 2014

dmesg
pidof sync
ps
uname -r
ddcprobe
uname -r
top
cp -a /lib/modules/3.5.0-KRG-iCore2-smp-pae-srv1000gz .
cp -a /lib/modules/3.9.9-KRG-iCore2-smp-pae-srv1000gz .
cp -a /lib/modules/3.7.10-KRG-i486-smp-pae-lzo-little .
cp -a /mnt/sdb6/lib/modules/2.6.31.14-KRG-i486-rev11.0-2014-11-08-dirty .
cp -a /lib/modules/3.6.11-KRG-i586-bonenkamp-64Gb-jump_label .
df
./Script_create_firmware.sh 
./Script
make.tgl
make menuconfig
make kernelrelease
mkdir DOTconfig.d
cp .config DOTconfig.d/DOTconfig-3.7.10-KRG-i686-underberg250
make menuconfig
cp .config DOTconfig.d/DOTconfig-3.7.10-KRG-i686-underberg300
make menuconfig
make kernelrelease
cp .config DOTconfig.d/DOTconfig-3.7.10-KRG-i686-underberg1000
make menuconfig
make kernelrelease
cp .config DOTconfig.d/DOTconfig-3.7.10-KRG-i686-ramzotti
cp .config DOTconfig.d/DOTconfig-3.7.10-KRG-i686-ramazotti
make menuconfig
make kernelrelease
cp .config DOTconfig.d/DOTconfig-3.7.10-KRG-i686-ramazotti250
make menuconfig
make kernelrelease
cp .config DOTconfig.d/DOTconfig-3.7.10-KRG-i686-ramazotti300
make menuconfig
cp .config DOTconfig.d/DOTconfig-3.7.10-KRG-i686-ramazotti1000
make menuconfig
make kernelrelease
cp .config DOTconfig.d/DOTconfig-3.7.10-KRG-i686-averna
make menuconfig
make kernelrelease
cp .config DOTconfig.d/DOTconfig-3.7.10-KRG-i686-averna250
make menuconfig
cp .config DOTconfig.d/DOTconfig-3.7.10-KRG-i686-averna300
make menuconfig
make kernelrelease
cp .config DOTconfig.d/DOTconfig-3.7.10-KRG-i686-averna1000
cp -a /mnt/sdb19/SRC/F3p5/WOOF/GitHub.d/KarlGodt_WoofFork.Push.d .
cp -a /mnt/sdb19/SRC/F3p5/WOOF/GitHub.d/Code-Plex-KRG-Woof.d .
cp -a /mnt/sdb19/SRC/F3p5/WOOF/GitHub.d/PuppyLinux-WoofCE.Pull.d .
cp -a /mnt/sdb19/SRC/F3p5/WOOF/GitHub.d/KarlGodtFork.Pull.d ./test/
cp -a /mnt/sdb19/SRC/F3p5/WOOF/GitHub.d/KarlGodtFork-NEW.Pull.d .
df
git branch
cp -a /mnt/sdb6/root/GitHub.d/KarlGodt_WoofFork.Pull.d .
cp -a /mnt/sdb6/root/GitHub.d/KarlGodt_WoofFork.Push.d .
top
cp -a /mnt/sdb7/root/GitHub.d/KarlGodt_WoofFork.Pull.d .
cp -a /mnt/sdb7/root/GitHub.d/KarlGodt_WoofFork.Push.d .
grep ßi local .config
grep -i local .config
grep -i local ../.config
grep -i local DOT*
owd
pwd
grep -i local .config
cd ../
grep -i local .config
stat .config
grep -i local .config
pwd
grep -i local .config
pwd
make kernelrelease
pwd
grep 'auto\.conf' Makefile
stat DOTconfig*
smartctl -A /dev/sda
smartctl -A /dev/sdb
echo $((3600/24))
ash
pwd
cd ..
find -name "Makefile.clean"
find -name "Makefile" | wc -l
for Ö in (ö do echo "$
for Ö in *; do echo "$Ö"; done
locale
for Datei in *; do echo "$Datei"; done
for Datäei in *; do echo "$Datäei"; done
for Datei in *; do echo "$Datei"; done
df
de
df
eventmanager
df
git help config
pwd
git branch
./update_files.sh 
git commit
git add update_files.sh
git commit -m 'update_files.sh: Added.'
geany /usr/bin/eventmanager
geany /usr/sbin/eventmanager
readlink -f /bin/make
readlink -f /bin/make |grep '\.sh$'
readlink -f /bin/make |grep -G '.sh$'
readlink -f /bin/make |grep -G '.sh'
readlink -f /bin/make |grep -G '.sh$'
readlink -f /bin/make |grep -G '.sh'
readlink -f /bin/make |grep  '.sh'
echo "ABC.QAZ...WERT"
echo "ABC.QAZ...WERT" | grep '.W'
echo "ABC.QAZ...WERT" | grep '.A'
echo "ABC.QAZ...WERT" | grep -G '.A'
echo "ABC.QAZ...WERT" | grep -F '.A'
echo "ABC.QAZ...WERT" | grep -F '.W'
echo "ABC.QAZ...WERT" | grep -F '.sh'
echo "ABC.QAZ...WERT" | grep -F '.WERT$'
echo "ABC.QAZ...WERT" | grep -EF '.WERT$'
A=--version
case $A in -?version) echo A maybe -version or --version;;esac
case $A in -+version) echo A maybe -version or --version;;esac
case $A in -\+version) echo A maybe -version or --version;;esac
A=---version
case $A in -?version) echo A maybe -version or --version;;esac
readlink -f /bin/make | grep '\.sh$'
readlink -f /bin/make | busybox grep '\.sh$'
readlink -f /bin/make
uptime
./Script
tail make-errs.logs.all
tail ./make-errs.logs.all
tail ../make-errs.logs.all
tail -n200 ../make-errs.logs.all
rm ../make-errs.logs.all
df
./Script
pwd
./Script
geany /bin/make.sh
./Script
htop
mount

Sat Nov 15 01:10:08 GMT+1 2014

ddcprobe
top
uname -r
uname -r
top

Sat Nov 15 02:56:58 GMT+1 2014

uname -r
uname -r
top

Sat Nov 15 03:57:14 GMT+1 2014

uname -r
uname -r

Sat Nov 15 04:18:04 GMT+1 2014

NewKernelStats.sh 
busybox reboot --help
geany /sbin/reboot
uname -r
uname -r
uname -r
top

Sat Nov 15 05:33:50 GMT+1 2014

NewKernelStats.sh 
uname -r
ddcprobe
free
uname -r
geany /usr/sbin/bootmanager
bootmanager
NewKernelStats.sh 
uname -r
NewKernelStats.sh 
./script
./Script

Sat Nov 15 14:04:14 GMT+1 2014

cd /tmp
source /etc/rc.d/f4puppy5
_say_jwm_taskbar_autohide 
_say_jwm_taskbar_border 
_say_jwm_taskbar_halign 
_say_jwm_taskbar_height 
_say_jwm_taskbar_insert 
_say_jwm_taskbar_layout 
_say_jwm_taskbar_tray_line 
_say_jwm_taskbar_valign 
_say_jwm_taskbar_width 
_say_jwm_taskbar_x
_say_jwm_taskbar_y
uname -r
lsmod | grep pcspkr
geany /root/.jwmrc-tray
=grep '<Tray .*>' "$HOME"/.jwmrc-tray | grep -vE '^#|^[[:blank:]]*#' | tail -n1
grep '<Tray .*>' "$HOME"/.jwmrc-tray | grep -vE '^#|^[[:blank:]]*#' | tail -n1
diff DOTconfig-3.7.10-KRG-i\[56\]86-smp-lzo-klein-O2 DOTconfig-3.7.10-KRG-pentiumpro-smp-lzo-klein-O2 
diff DOTconfig-3.7.10-KRG-pentiumpro-smp-lzo-klein-O2 DOTconfig-3.7.10-KRG-i486-smp-pae-lzo-klein-O2 
diff -up DOTconfig-3.7.10-KRG-pentiumpro-smp-lzo-klein-O2 DOTconfig-3.7.10-KRG-i486-smp-pae-lzo-klein-O2 >diff.fiff
diff DOTconfig-3.7.10-KRG-i\[56\]86-smp-lzo-klein-O2 DOTconfig-3.7.10-KRG-pentiumpro-smp-lzo-klein-O2 
NewKernelStats.sh 
/etc/init.d/DRIVER/z99_alsa stop
modprobe -v snd-hda-intel
/etc/init.d/DRIVER/z99_alsa start

Sun Nov 16 21:26:34 GMT+1 2014

NewKernelStats.sh 
make menuconfig
defaultmediaplayer /mnt/sda1/VID/FlashM4uHFa
ls /etc/modules/DOTconfig
ls /etc/modules/DOTconfig*
uname -r
which vlc
/etc/acpi/wakealarm.sh
find /sys -name since_epoch
cat /sys/devices/pnp0/00:05/rtc/rtc0/since_epoch
/etc/acpi/wakealarm.sh
aplay /usr/share/audio/2barks.au
uname -r
ddcprobe
pwd

Mon Nov 17 16:32:21 GMT+1 2014

cat /proc/cmdline
uname -r
NewKernelStats.sh 

Mon Nov 17 17:14:15 GMT+1 2014

modprobe -l | grep kbd
type -a xz
/usr/local/bin/xz --version
/root/my-applications/bin/xz --version
pwd
exit
find /usr -iname "*lzma*"
pwd
find /usr -iname "*lzma*" |sort >lzma.files.list
find /usr -iname "*lzo*" |sort >lzo.files.list
find /usr -iname "*xz*" |sort >lzo.files.list
find /usr -iname "*xz*" |sort >xz.files.list
find /usr -iname "*lzo*" |sort >lzo.files.list
find /usr -iname "*gcc-*"
find /usr -name "i686*"

Fri Nov 21 21:15:35 GMT+1 2014

pwd
echo $MACHTYPE
uname -m
uname --help
uname -v
uname -r
uname -p
uname -i
uname -s
uname -o
readlink /usr/local/bin/i686-pc-linux-gnu-gcc
readlink -e /usr/local/bin/i686-pc-linux-gnu-gcc
gcc --help
man gcc
chmod +x /root/choose_gcc_version.sh 
/root/choose_gcc_version.sh 
ls /usr/local/bin/i686-pc-linux-gnu-gcc*
diff -qs /usr/local/bin/i686-pc-linux-gnu-gcc-3.3.6 /usr/local/bin/i686-pc-linux-gnu-gcc-3.3.6-3.3.6
rm /usr/local/bin/i686-pc-linux-gnu-gcc-3.3.6-3.3.6
diff -qs /usr/local/bin/i686-pc-linux-gnu-gcc-4.0.4 /usr/local/bin/i686-pc-linux-gnu-gcc-4.0.4-4.0.4
rm /usr/local/bin/i686-pc-linux-gnu-gcc-4.0.4-4.0.4
diff -qs /usr/local/bin/i686-pc-linux-gnu-gcc-4.2.4 /usr/local/bin/i686-pc-linux-gnu-gcc-4.2.4-4.2.4
rm /usr/local/bin/i686-pc-linux-gnu-gcc-4.2.4-4.2.4
diff -qs /usr/local/bin/i686-pc-linux-gnu-gcc-4.3.6 /usr/local/bin/i686-pc-linux-gnu-gcc-4.3.6-4.3.6
rm /usr/local/bin/i686-pc-linux-gnu-gcc-4.3.6-4.3.6
diff -qs /usr/local/bin/i686-pc-linux-gnu-gcc-4.4.7 /usr/local/bin/i686-pc-linux-gnu-gcc-4.4.7-4.4.7
rm /usr/local/bin/i686-pc-linux-gnu-gcc-4.4.7-4.4.7
diff -qs /usr/local/bin/i686-pc-linux-gnu-gcc-4.5.4 /usr/local/bin/i686-pc-linux-gnu-gcc-4.5.4-4.5.4
rm /usr/local/bin/i686-pc-linux-gnu-gcc-4.5.4-4.5.4
diff -qs /usr/local/bin/i686-pc-linux-gnu-gcc-4.6.3 /usr/local/bin/i686-pc-linux-gnu-gcc-4.6.3-4.6.3
ls /usr/local/bin/i686-pc-linux-gnu-gcc*
rm /usr/local/bin/i686-pc-linux-gnu-gcc-4.6.3-4.6.3
ls /usr/local/bin/i686-pc-linux-gnu-gcc*
ls /usr/local/bin/i686-pc-linux-gnu-g++*
ls /usr/local/bin/i686-pc-linux-gnu-c++*
mv /usr/local/bin/i686-pc-linux-gnu-gcc-3.4.5 /usr/local/bin/i686-pc-linux-gnu-gcc3-3.4.5
mv /usr/local/bin/i686-pc-linux-gnu-gcc-3.4.6 /usr/local/bin/i686-pc-linux-gnu-gcc3-3.4.6
ls /usr/local/bin/i686-pc-linux-gnu-g++*
ls /usr/local/bin/i686-pc-linux-gnu-gcc*
ls /usr/local/bin/i686-pc-linux-gnu-gcc-*
ls /usr/local/bin/i686-pc-linux-gnu-g++-*
ls /usr/local/bin/i686-pc-linux-gnu-c++-*
ln -sf i686-pc-linux-gnu-c++-4.6.3 /usr/local/bin/i686-pc-linux-gnu-c++
ln -sf i686-pc-linux-gnu-g++-4.6.3 /usr/local/bin/i686-pc-linux-gnu-g++
ln -sf i686-pc-linux-gnu-gcc-4.6.3 /usr/local/bin/i686-pc-linux-gnu-gcc
/root/choose_gcc_version.sh 
/usr/bin/gcc --version
which i486-t2-linux-gnu-gcc
/usr/bin/i486-t2-linux-gnu-gcc --version
/usr/bin/i486-t2-linux-gnu-gcc-4.2.2 --version
ln -sf i486-t2-linux-gnu-gcc-4.2.2 /usr/bin/i486-t2-linux-gnu-gcc
mv /usr/bin/i486-t2-linux-gnu-g++ /usr/bin/i486-t2-linux-gnu-g++-4.2.2 
mv /usr/bin/i486-t2-linux-gnu-c++ /usr/bin/i486-t2-linux-gnu-c++-4.2.2 
ln -s i486-t2-linux-gnu-c++-4.2.2 /usr/bin/i486-t2-linux-gnu-c++
ln -s i486-t2-linux-gnu-g++-4.2.2 /usr/bin/i486-t2-linux-gnu-g++
which i486-t2-linux-gnu-gcc
ls /usr/bin/i486*
ls -1  /usr/bin/i486*
ls -1  /usr/bin/gcc*
ls -1  /usr/bin/g++*
ls -1  /usr/bin/c++*
/usr/bin/c++filt --help
/usr/bin/c++ --help
ls -1  /usr/bin/c++*
ls -1  /usr/bin/g++*
ls -1  /usr/bin/gcc*
/usr/bin/gcc --version
ls /usr/bin/i486*
ln -sf i486-t2-linux-gnu-gcc /usr/bin/gcc
ln -sf i486-t2-linux-gnu-g++-4.2.2 /usr/bin/g++
ln -sf i486-t2-linux-gnu-c++-4.2.2 /usr/bin/c++
/usr/bin/gcc --version
/root/choose_gcc_version.sh 
ln -sf i686-pc-linux-gnu-gcc-4.6.3  /usr/local/bin/i686-pc-linux-gnu-gcc
rm /usr/local/bin/i686-pc-linux-gnu-gcc
ln -sf i686-pc-linux-gnu-gcc-4.6.3  /usr/local/bin/i686-pc-linux-gnu-gcc
/root/choose_gcc_version.sh 
file `which gcc`
file `which g++`
file `which c++`
/root/choose_gcc_version.sh 
/usr/local/bin/gcc --version
/usr/local/bin/g++ --version
/usr/local/bin/c++ --version
file /usr/local/bin/gcc
/usr/bin/gcc --version
ln -sf i486-t2-linux-gnu-c++-4.2.2 /usr/bin/c++
ln -sf i486-t2-linux-gnu-g++-4.2.2 /usr/bin/g++
ln -sf i486-t2-linux-gnu-gcc /usr/bin/gcc
/usr/local/bin/c++ --version
/usr/bin/gcc --version
/root/choose_gcc_version.sh 
gcc --version
/root/choose_gcc_version.sh 
i686-pc-linux-gnu
i686-pc-linux-gnu-g++ --version
i686-pc-linux-gnu-c++ --version
file --version
file /usr/local/bin/i686-pc-linux-gnu-g++
ldd /usr/local/bin/i686-pc-linux-gnu-g++
LC_ALL=C ld --help
./config.guess
ls /usr/libexec/gcc/i486-t2-linux-gnu/4.2.2/
ls - 1 /usr/libexec/gcc/i486-t2-linux-gnu/4.2.2/
ls -1 /usr/libexec/gcc/i486-t2-linux-gnu/4.2.2/
file /usr/local/lib/gcc-lib/i686-pc-linux-gnu/3.3.6/collect2
ldd /usr/local/lib/gcc-lib/i686-pc-linux-gnu/3.3.6/collect2
ls /usr/local/lib/gcc-lib/i686-pc-linux-gnu/3.3.6/
ls -l /usr/local/lib/gcc-lib/i686-pc-linux-gnu/3.3.6/
ldd /usr/local/lib/gcc-lib/i686-pc-linux-gnu/3.3.6/crt*
strings /usr/local/lib/gcc-lib/i686-pc-linux-gnu/3.3.6/crtend.o
grep __libc_csu_fini /usr/local/lib/gcc-lib/i686-pc-linux-gnu/3.3.6/*
grep __libc_csu_fini /usr/i486*
ls /usr/i486*
ls -d /usr/i486*
ls -d /usr/i486*/bin
ls /usr/i486*/bin
ls -d /usr/lib/i486*
ls -d /usr/lib/gcc*
ls /usr/lib/gcc*
ls /usr/lib/gcc*/*
ls -d /usr/lib/gcc*/*
ls -d /usr/lib/gcc*/*/*
ls -d /usr/lib/gcc*/*/*/*
find /usr -name "collect2"
/usr/local/lib/gcc-lib/i686-pc-linux-gnu/3.3.6/collect2 --gelp
/usr/local/lib/gcc-lib/i686-pc-linux-gnu/3.3.6/collect2 --help
readlink `which gcc`
which gcc
ls /usr/bin/gcc*
ls /usr/bin/i4*
file /usr/bin/i486-t2-linux-gnu-c++
ln -sf i486-t2-linux-gnu-gcc /usr/bin/gcc
make menuconfig
gcc --version
make clean
make menuconfig
gcc --version
make menuconfig
file /usr/lib/crt1.o
ls -l /usr/lib/c*
ls -l /usr/lib/cr*
ls -l /lib/cr*
ls -l /lib/libg*
ls -l /lib/libc*
diff -qs /usr/lib/crtn.o-F3orig /usr/lib/crtn.o-OPT-2.5.1
ldd /usr/local/bin/i686-pc-linux-gnu-gcc-3.3.6
ldd /usr/local/bin/ld
type -a ld
diff -qs /usr/local/bin/ld /usr/local/i686-pc-linux-gnu/bin/ld
/usr/local/bin/ld --help
find /usr -iname "*i686*"
find -name "crtl.o"
find -name "crt1.o"
find /usr -name "crt1.o*"
pwd
grep -I -r __libc_csu_fini *
grep  -r __libc_csu_fini *
ldd csu/Scrt1.o
echo $PATH
which ld
file /usr/bin/ld
file /usr/local/bin/ld
/usr/local/bin/ld --version
/usr/local/i686-pc-linux-gnu/bin/ld
/usr/local/i686-pc-linux-gnu/bin/ld --version
grep -r -I 
grep -r -I __libc_csu_fini *
grep fini *
hostinfo
arch
oslevel
df

Tue Nov 25 16:19:53 GMT+1 2014

killall aplay
pidof login rc.launchxwin X
ps | grep -w 6263
./update_files.sh
./update_files_from_running_system 
pupx
modprobe -l | grep cpufreq
modprobe -l | grep cpufreq | sort
modprobe -l | grep cpufreq_  | sort
for cpu in /sys/devices/system/cpu/cpu[0-9]*/*; do echo $cpu ; done
for cpu in /sys/devices/system/cpu/cpu[0-9]*/; do echo $cpu ; done
modinfo longrun
modinfo longhaul
modinfo gx-suspmod
modinfo pcc-cpufreq
modinfo mperf
modinfo freq-table
modinfo e_powersaver
modinfo cpufreq-stats
modinfo cpufreq-nforce2
grep -H '.*' /sys/devices/cpu
grep -H '.*' /sys/devices/cpu/*
grep -H '.*' /sys/devices/cpu/cpu0/*
ls /sys/devices
grep -H '.*' /sys/devices/system/cpu/cpu0/*
grep -H '.*' /sys/devices/system/cpu/cpu0/*/*
grep -H '.*' /sys/devices/system/cpu/*/*
grep -H '.*' /sys/devices/system/cpu/*/
grep -H '.*' /sys/devices/system/cpu/*
ls /sys/devices/system/cpu/
ls /sys/devices/system/cpu/cpufreq
ls /sys/devices/system/cpu/cpufreq/ondemand/
ls -l /sys/devices/system/cpu/cpufreq/ondemand/
grep cpufreq /proc/modules
geany `which pupx`
ls -1 /sys/block | grep -vE '^loop|^md|^mtd|^nbd|^ram|^zram'
ls -1v /sys/block | grep -vE '^loop|^md|^mtd|^nbd|^ram|^zram'
ls -1v /sys/block | grep -vE '^loop|^md|^mtd|^nbd|^*ram'
ls -1v /sys/block | grep -vE '^loop|^md|^mtd|^nbd|^?ram'
ls -1v /sys/block | grep -vE '^loop|^md|^mtd|^nbd|^ram'
ls -1v /sys/block | grep -vE '^loop|^md|^mtd|^nbd|^zram'
ls -1v /sys/block | grep -vE '^loop|^md|^mtd|^nbd|^*ram'
ls -1v /sys/block | grep -vE '^loop|^md|^mtd|^nbd|^?ram'
modprobe -l | grep ram
modinfo nvram
modprobe -v nvram
ls -1v /sys/block | grep -vE '^loop'
ls -1v /sys/block | grep -vE '^loop|^md|^mtd|^nbd|^+ram'
ls -1v /sys/block | grep -vE '^loop|^md|^mtd|^nbd|^\+ram'
ls -1v /sys/block | grep -vE '^loop|^md|^mtd|^nbd|^\?ram'
ls -1v /sys/block | grep -vE '^loop|^md|^mtd|^nbd|^{0,}ram'
ls -1v /sys/block | grep -vE '^loop|^md|^mtd|^nbd|^{1,}ram'
ls -1v /sys/block | grep -vE '^loop|^md|^mtd|^nbd|^\{1,\}ram'
ls -1v /sys/block | grep -vE '^loop|^md|^mtd|^nbd|^{1,}ram'
ls -1v /sys/block | grep -vE '^loop|^md|^mtd|^nbd|^{0,}ram'
ls -1v /sys/block | grep -vE '^loop|^md|^mtd|^nbd|\^{0,}ram'
ls -1v /sys/block | grep -vE '^loop|^md|^mtd|^nbd|\^{1,}ram'
ls -1v /sys/block | grep -vE '^loop|^md|^mtd|^nbd|^{1,}ram'
ls -1v /sys/block | grep -vE '^loop|^md|^mtd|^nbd|^{,}ram'
ls -1v /sys/block | grep -vE '^loop|^md|^mtd|^nbd|^{,0}ram'
ls -1v /sys/block | grep -vE '^loop|^md|^mtd|^nbd|^{,1}ram'
ls -1v /sys/block | grep -vE '^loop|^md|^mtd|^nbd|^{,2}ram'
ls -1v /sys/block | grep -vE '^loop|^md|^mtd|^nbd|^{0,}ram'
ls -1v /sys/block | grep -vE '^loop|^md|^mtd|^nbd|^{1,}ram'
ls -1v /sys/block | grep -vE '^loop|^md|^mtd|^nbd|^+ram'
ls -1v /sys/block | grep -vE '^loop|^md|^mtd|^nbd|^*ram'
grep '^/dev/[fhms][mcd]' /proc/mounts
grep '^/dev/[fhms][mcd][""d]' /proc/mounts
grep '^/dev/[fhms][mcd][d]' /proc/mounts
grep '^/dev/[fhms][mcd]\+' /proc/mounts
grep '^/dev/[fhms]\+[mcd]\+' /proc/mounts
grep -o '^/dev/[fhms]\+[mcd]\+' /proc/mounts
A=/dev/scd0p1
echo "$A" | grep -o '^/dev/[fhms]\+[mcd]\+'
echo "$A" | grep '^/dev/[fhms]\+[mcd]\+'
echo "$A" | grep '^/dev/[fhms]\{1\}[mcd]\{1,2}'
echo "$A" | grep '^/dev/[fhms]\{1\}[mcd]\{1,2\}'
A='\+'
echo "$A"
A='\*'
echo "$A"
/bin/ps -H -A | grep '<defunct>' | sed 's/^[[:blank:]]*//g;s/  /|/g' | grep -v 'S|||[0-9]\+:[0-9]\+' | cut -f 1 -d ' '
/bin/ps -H -A | grep '<defunct>'
/bin/ps -H -A | grep '<defunct>' | grep -v 'grep <defunct>' 
/bin/ps -H -A | grep '<defunct>' | grep -v 'grep <defunct>' | sed 's/^[[:blank:]]*//g;s/  /|/g' | grep -v '[DRSTWX]\{1\}|||[0-9]\+:[0-9]\+' | cut -f 1 -d ' '
/bin/ps -H -A | grep '<defunct>' | sed 's/^[[:blank:]]*//g;s/  /|/g' | grep -v '[DRSTWX]\{1\}|||[0-9]\+:[0-9]\+' | cut -f 1 -d ' '
/bin/ps -H -A | grep '<defunct>' | sed 's/^[[:blank:]]*//g;s/  /|/g' | grep -v '[DRSTWX]\{1\}|||[0-9]\+:[0-9]\+'
ash\
ash
xrandr | grep -o -m 1 'current [0-9]* x [0-9]*,' | awk -F' ' '{print $NF}'
xrandr | grep 'current [0-9]* x [0-9]*,' | awk -F' ' '{print $NF}'
xrandr | grep 'current [0-9]* x [0-9]*,'
xrandr | grep 'current \[0-9\]* x \[0-9\]*,'
xrandr | grep -e 'current [0-9]* x [0-9]*,'
xrandr | grep -E 'current [0-9]* x [0-9]*,'
A=`xrandr | grep -E 'current [0-9]* x [0-9]*,'`
echo "$A"
echo "$A" | grep '[[0-9]]*'
echo "$A" | grep -o '[[0-9]]*'
echo "$A" | grep -o '[[0-9]]?'
echo "$A" | grep -o '[[0-9]]\?'
echo "$A" | grep -o '[[0-9]]\+'
echo "$A" | grep -o '[[0-9]]+'
echo "$A" | grep -o '[[0-9]]\+*'
echo "$A" | grep -o '[[0-9]]*'
echo "$A" | grep -o '[0-9]*'
echo "$A" | grep -o '[0-9]\+'
echo "$A" | grep -o '[0-9]\?'
echo "$A" | grep -o '[0-9]\*'
grep 'grep.*[0-9]' *
grep 'grep.*\[0-9\]' *
cp -a /usr/bin/ffconvert .
cp /usr/bin/ffconvert .
cp `readlink /usr/bin/ffconvert` .
cp `readlink -f /usr/bin/ffconvert` .
for i in *; do readlink $i; done
for i in *; do currRL=`readlink $i`; echo "$currRL"; done
for i in *; do currRL=`readlink $i`; echo "$currRL"; case $currRL in .*|..*) continue;;esac;done
for i in *; do currRL=`readlink $i`; echo "$currRL"; case $currRL in .*|..*) continue;;esac;echo $i semms absolute;done
for i in *; do [ -L "$i" ] || continue;currRL=`readlink $i`; echo "$currRL"; case $currRL in .*|..*) continue;;esac;echo $i semms absolute;done
pwd
for i in *; do [ -L "$i" ] || continue;currRL=`readlink $i`; echo "$currRL"; case $currRL in .*|..*) continue;;esac;echo $i seems absolute;done
for i in *; do [ -L "$i" ] || continue;currRL=`readlink $i`; echo "$currRL"; case $currRL in .*|..*) continue;;esac;echo $i seems absolute;bnLT=${currRL##*/}; echo $bnLT;done
for i in *; do [ -L "$i" ] || continue;currRL=`readlink $i`; echo "$currRL"; case $currRL in .*|..*) continue;;esac;echo $i seems absolute;bnLT=${currRL##*/}; echo $bnLT; ln -v ../../../../../usr/bin/$bnLT $i;done
for i in *; do [ -L "$i" ] || continue;currRL=`readlink $i`; echo "$currRL"; case $currRL in .*|..*) continue;;esac;echo $i seems absolute;bnLT=${currRL##*/}; echo $bnLT; ln -v -s ../../../../../usr/bin/$bnLT $i;done
for i in *; do [ -L "$i" ] || continue;currRL=`readlink $i`; echo "$currRL"; case $currRL in .*|..*) continue;;esac;echo $i seems absolute;bnLT=${currRL##*/}; echo $bnLT; ln -v -sf ../../../../../usr/bin/$bnLT $i;done
type -a inkscapelite
type -a gimp
readlink *
for i in *; do readlink $i; done
pwd
cd ../../../../../
pwd
ls usr/bin
cd ../../
pwd
git commit
git add woof-code/rootfs-skeleton/usr/bin/ffconvert-0.9
git add woof-code/rootfs-skeleton/usr/bin/ffconvert
git commit -m '/usr/bin/ffconvert-0.9: Added with link /usr/bin/ffconvert .'
git commit 2>&1 | while reaf l f; do [ -e "$f" ] || continue; echo "$f"; done
git commit 2>&1 | while read l f; do [ -e "$f" ] || continue; echo "$f"; done
git commit 2>&1 | while read l f; do [ -e "$f" ] || continue; echo "$f"; git add "$f" && git commit -m "$f: Changed this link from absolute path to relative path";done
git commit
git commit 2>&1 | while read l f; do  echo "$f"; git add "$f" && git commit -m "$f: Changed this link from absolute path to relative path";done
git commit
uname -r
cp -a /usr/local/bin/mozstart .
cd ../../../../../
pwd
git commit
git add /usr/local/bin/mozstart
git add woof-code/rootfs-skeleton/usr/local/bin/mozstart
git commit -m '/usr/local/bin/mozstart: Added.'
type -a puppydownload
type -a EmbeddedBookmarks
geany /usr/local/bin/EmbeddedBookmarks
git commit
git commit 2>&1 | while read l f; do  echo "$f";done
git commit 2>&1 | while read f; do  echo "$f";done
git commit 2>&1 | while read f; do  [ -e "$f" ] || continue;echo "$f";done
git commit 2>&1 | while read f; do  [ -e "$f" ] || continue;echo "$f"; git add "$f" && git commit -m "$f: Added from original .sfs .";done
for i in *; do echo $i; done
for i in *; do echo $i; ls /mnt/sdb19/SRC/F3p5/WOOF/GitHub.d/KarlGodt_WoofFork.Push.d/woof-code/rootfs-skeleton/usr/local/bin/$i;done
for i in *; do echo $i; file "$i" | grep -iw -E 'ELF|LSB' && continue;ls /mnt/sdb19/SRC/F3p5/WOOF/GitHub.d/KarlGodt_WoofFork.Push.d/woof-code/rootfs-skeleton/usr/local/bin/$i;done
for i in *; do echo $i; file "$i" | grep -iw -E 'ELF|LSB' && continue;ls /mnt/sdb19/SRC/F3p5/WOOF/GitHub.d/KarlGodt_WoofFork.Push.d/woof-code/rootfs-skeleton/usr/local/bin/$i && continue; echo;echo $i needs to be added to git; echo;done
for i in *; do echo $i; file "$i" | grep -iw -E 'ELF|LSB|link' && continue;ls /mnt/sdb19/SRC/F3p5/WOOF/GitHub.d/KarlGodt_WoofFork.Push.d/woof-code/rootfs-skeleton/usr/local/bin/$i && continue; echo;echo $i needs to be added to git; echo;done
dmidecode --help
dmidecode -u
/root/_board_info.sh 
ls /sys/devices/system/cpu/$core/cpufreq/
ls /sys/devices/system/cpu/$core/cpufreq/*/
ls /sys/devices/system/cpu/cpu0/cpufreq/*/
ls /sys/devices/system/cpu/cpu0/cpufreq/*
/etc/init.d/DRIVER/start_cpu_freq 
grep -H '.*' /sys/devices/system/cpu/cpufreq/${GOVERNOR}/
grep -H '.*' /sys/devices/system/cpu/cpufreq//
grep -H '.*' /sys/devices/system/cpu/cpufreq/ondemand/
/etc/init.d/DRIVER/start_cpu_freq 
/etc/init.d/DRIVER/start_cpu_freq start
ls -1v /sys/devices/system/cpu/ | grep 'cpu[0-9]*'
ls -1v /sys/devices/system/cpu/ | grep '^cpu[0-9]*'
ls -1v /sys/devices/system/cpu/ | grep -E '^cpu[0-9]*'
ls -1v /sys/devices/system/cpu/ | grep -G '^cpu[0-9]*'
ls -1v /sys/devices/system/cpu/ | grep -e '^cpu[0-9]*'
ls -1v /sys/devices/system/cpu/ | grep -oe '^cpu[0-9]*'
ls -1v /sys/devices/system/cpu/ | grep -E '^cpu[0-9]*'
ls -1v /sys/devices/system/cpu/ | grep -E '^cpu[:digit:]*'
ls -1v /sys/devices/system/cpu/ | grep -E '^cpu[:digit:]'
ls -1v /sys/devices/system/cpu/ | grep -E 'cpu[:digit:]'
ls -1v /sys/devices/system/cpu/ | grep -E 'cpu[[:digit:]]'
ls -1v /sys/devices/system/cpu/ | grep -E 'cpu[[:digit:]]*'
ls -1v /sys/devices/system/cpu/ | grep -E 'cpu[[:digit:]]?'
ls -1v /sys/devices/system/cpu/ | grep -e 'cpu[[:digit:]]?'
ls -1v /sys/devices/system/cpu/ | grep  'cpu[[:digit:]]?'
ls -1v /sys/devices/system/cpu/ | grep  'cpu[[:digit:]]+'
ls -1v /sys/devices/system/cpu/ | grep  -E 'cpu[[:digit:]]+'
ls -1v /sys/devices/system/cpu/ | grep  -E 'cpu[[0-9]]+'
ls -1v /sys/devices/system/cpu/ | grep  -E 'cpu[0-9]+'
ls -1v /sys/devices/system/cpu/ | grep  -E 'cpu[0-9]*'
ls -1v /sys/devices/system/cpu/ | grep  -E 'cpu[[0-9]]*'
geany /sbin/pup_event_frontend_d
geany /sbin/pup_event_backend_modprobe
man wc
geany `which eventmanager`
eventmanager
FALL=$(ffmpeg -formats 2>/dev/null)
echo "$FALL"
FORMATS=$(echo "$FALL"| head -n $(($N1 - 1))| grep '^[ D]*E'|sed -e 's/^[ A-Z]*[ ]//' |cut -d ' ' -f1)
echo "$FORMATS"
FORMATS=$(echo "$FALL"| head -n $(($N1 - 1))| grep '^[ D]\+E'|sed -e 's/^[ A-Z]*[ ]//' |cut -d ' ' -f1)
echo "$FORMATS"
FORMATS=$(echo "$FALL"| head -n $(($N1 - 1))| grep '^[ D]\{2\}E'|sed -e 's/^[ A-Z]*[ ]//' |cut -d ' ' -f1)
echo "$FORMATS"
FORMATS=$(echo "$FALL"| head -n $(($N1 - 1))| grep '^[ D]\{1\}E'|sed -e 's/^[ A-Z]*[ ]//' |cut -d ' ' -f1)
echo "$FORMATS"
FORMATS=$(echo "$FALL"| head -n $(($N1 - 1))| grep '^[ D]\{2\}E'|sed -e 's/^[ A-Z]*[ ]//' |cut -d ' ' -f1)
echo "$FORMATS"
locale
FORMATS=$(echo "$FALL"| head -n $(($N1 - 1))| grep '^[ D]\{2\}E'|sed -e 's/^[ DE]*[ ]//' |cut -d ' ' -f1)
echo "$FORMATS"
echo "$FALL"| grep '^ [ D][ E] ' |sed 's/^ *//;s/^D /D-/;s/^E/-E/' |awk '{print $1"_"$2}'
cat --help
which ffconvert
file /usr/bin/ffconvert
geany /usr/bin/ffconvert-0.9
geany /usr/bin/ffconvert-0.7_orig
grep -r 'grep.*\[0-9\]' *
ln --help
for i in *; do [ -L "$i" ] || continue;currRL=`readlink $i`; echo "$currRL"; case $currRL in .*|..*) continue;;esac;echo $i seems absolute;bnLT=${currRL##*/}; echo $bnLT; ln -v -sf ../../../../usr/bin/$bnLT $i;done
file /usr/bin/mozstart
which mozstart
file /usr/local/bin/mozstart
geany /usr/local/bin/mozstart
man ps
cut --help
busybox cut --help
echo "$JwmL" | grep -o ' height=.*$' | tr -d ' ' | cut -f 2 -d '"'
/bin/df -m | grep -m1 ' /$'
/bin/df -m | awk '{if ($NF == "/") print}'
/bin/df -m | awk '{if ($6 == "/") print}'
time /bin/df -m | awk '{if ($6 == "/") print}'
time /bin/df -m | grep -m1 ' /$'
time /bin/df -m | awk '{if ($6 == "/") print}'
df
time SIZEFREEM=`/bin/df -m | grep -m1 ' /$'              | tr -s ' ' | cut -f 4 -d ' '`
time SIZEFREEM=`/bin/df -m | awk '{if ($NF == "/") print $4}' | tail -n1`
time SIZEFREEM=`/bin/df -m | grep -m1 ' /$'              | tr -s ' ' | cut -f 4 -d ' '`
time SIZEFREEM=`/bin/df -m | grep -m1 ' /$' | tr -s ' ' | cut -f 4 -d ' '`
time SIZEFREEM=`/bin/df -m | awk '{if ($NF == "/") print $4}' | tail -n1`
time SIZEFREEM=`/bin/df -m | awk '{if ($NF == "/") print $4}'`
ash
/bin/ps -H -A |sed 's/^[[:blank:]]*//g;s/  /|/g'
grep '^/dev/[fhms][md]' /proc/mounts
grep '^/dev/[fhms]\{1\}[md]' /proc/mounts
grep '^/dev/[fhms]\{1\}[md]\{1\}' /proc/mounts
grep '^/dev/[fhms]\+[md]\{1\}' /proc/mounts
grep '^/dev/[fhms]\+[md]\+' /proc/mounts
grep '^/dev/[fhms]\?[md]\?' /proc/mounts
grep '^/dev/' /proc/mounts
grep '^\</dev/' /proc/mounts
grep '\</dev/' /proc/mounts
grep '</dev/' /proc/mounts
grep '^</dev/' /proc/mounts
grep '^\</dev/' /proc/mounts
grep '^\</dev/sda1\>' /proc/mounts
grep '^</dev/sda1>' /proc/mounts
grep '^/dev/sda1' /proc/mounts
grep '^/dev/sda1\b' /proc/mounts
grep '^\b/dev/sda1\b' /proc/mounts
grep '^\b/dev/sda1' /proc/mounts
grep '\b/dev/sda1' /proc/mounts
grep '/dev/sda1\b' /proc/mounts
grep -w '/dev/sda1\b' /proc/mounts
grep -w '/mnt/sda1\b' /proc/mounts
grep -w '\b/mnt/sda1\b' /proc/mounts
grep -w '\b/mnt/sda1' /proc/mounts
grep -w '\B/mnt/sda1' /proc/mounts
grep -w '\B/mnt/sda1\b' /proc/mounts
grep '\B/mnt/sda1\b' /proc/mounts
grep -o '\B/mnt/sda1\b' /proc/mounts
grep -o '\</mnt/sda1\>' /proc/mounts
grep  '\</mnt/sda1\>' /proc/mounts
grep  '</mnt/sda1\>' /proc/mounts
grep  '</mnt/sda1>' /proc/mounts
grep  '< /mnt/sda1 >' /proc/mounts
grep  '\< /mnt/sda1 \>' /proc/mounts
grep  '\<  \>' /proc/mounts
grep  '\< \>' /proc/mounts
grep  '\<\>' /proc/mounts
grep  '\<\>' /tmp/test
touch /tmp/test
grep  '\<\>' /tmp/test
grep  '\< \>' /tmp/test
echo "" >/tmp/test
grep  '\< \>' /tmp/test
grep  '\<\>' /tmp/test
echo " " >/tmp/test
grep  '\<\>' /tmp/test
grep  '\< \>' /tmp/test
grep  '\B \>' /tmp/test
grep  '\B \b' /tmp/test
grep  ' ' /tmp/test
grep  '\b ' /tmp/test
grep  ' \b' /tmp/test
type -a ffplay
file /usr/bin/ffplay
ls -1v /sys/devices/system/cpu/ | grep -E 'cpu[[0-9]]*'
ash
chmod +x /root/_board_info.sh 
/root/_board_info.sh
dmidecode -s "processor-frequency"
string='processor‐version'
dmidecode -s "$string"
string='processor\‐version'
dmidecode -s "$string"
string='processor‐version'
dmidecode -s $string
/root/_board_info.sh
type -a dmidecode
file /usr/sbin/dmidecode
file /usr/local/sbin/dmidecode
/usr/local/sbin/dmidecode --version
/usr//sbin/dmidecode --version
/root/_board_info.sh
ps | grep man
man dmidecode
which less
file /usr/bin/less
man dmidecode
LC_PAPER=C man dmidecode
LC_CTYPE=C man dmidecode
LC_ALL=C man dmidecode
expoer LC_ALL=C
export LC_ALL=C
man dmidecode
busybox man dmidecode
man --help
man -d dmidecode
man -D dmidecode
grep -E 'tty|vc' /etc/inittab | grep -v -E '^#|^[[:blank:]]*#|^\t*#' | tr -s ' ' | sort -u | grep -o -w -E 'tty[0-9]+$|vc[0-9]+' | grep -o '[0-9]+$'
grep -E 'tty|vc' /etc/inittab | grep -v -E '^#|^[[:blank:]]*#|^\t*#' | tr -s ' ' | sort -u | grep -o -w -E 'tty[0-9]+$|vc[0-9]+' | grep -o '[0-9]\+$'
A=tty11
echo "$A" | grep -o [0-9]\+$'
echo "$A" | grep -o '[0-9]\+$'
grep -E 'tty|vc' /etc/inittab | grep -v -E '^#|^[[:blank:]]+#|^\t+#' | tr -s ' ' | sort -u | grep -o -w -E 'tty[0-9]+$|vc[0-9]+' | grep -o '[0-9]\+$'
grep -E 'tty|vc' /etc/inittab
grep ^processor /proc/cpuinfo |wc -l
grep ^processor /proc/cpuinfo
depmod --help
depmod-FULL --help
source /etc/rc.d/MODULESCONFIG 
echo "$SKIPLIST" | tr '\-' '_' | tr ' ' '\n'
echo "$SKIPLIST"
echo "$SKIPLIST" | tr '\-' '_' | tr ' ' '\n' | sed -e 's/^/blacklist /'
echo "'$SKIPLIST'"
SKIPLIST="${SKIPLIST} "
echo "'$SKIPLIST'"
echo "$SKIPLIST" | tr '\-' '_' | tr ' ' '\n' | sed -e 's/^/blacklist /'
ls -A /etc/modprobe.d/*
elspci -l | grep -o -E '0C0300|0C0310|0C0320'
elspci -l | grep -m1 -E '0C0300|0C0310|0C0320'
elspci -l | grep -E '0C0300|0C0310|0C0320'
modprobe -l | grep '[eoux]\{1\}hci[-_]hcd'
modprobe -l | grep '[eoux]hci[-_]hcd'
elspci -l
elspci -l | grep '<>$'
dmidecode | grep -m3 -iE 'manufacturer|product|serial number'
LANG=C ln --help
LC_ALL=C ln --help
uname --help
LC_ALL=C ld --help
ln --help
history | grep man
history | grep help
gcc --help
ls --help
dmidecode --help
ps -A -H
ps -H -A | grep '<defunct>' | sed -e 's/  /|/g' | grep -v '|||'
ps -H -A | grep '<defunct>' | sed -e 's/  /|/g'
ps -H -A | sed -e 's/  /|/g'
 ls /sys/*/system/cpu/cpufreq
 ls /sys/*/system/cpu/
 ls /sys/*/system/cpu/cpu0
 ls /sys/*/system/cpu/cpu0/cpufreq
grep -H '.*'  /sys/*/system/cpu/cpu0/cpufreq/*
echo ondemand >/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 
grep -H '.*'  /sys/*/system/cpu/cpu1/cpufreq/*
echo ondemand >/sys/devices/system/cpu/cpu1/cpufreq/scaling_governor 
help set
ICON_PLACE_SPACING=$(( (( $DriveIconsize / $PIN_GRID_STEP ) + 1 ) * $PIN_GRID_STEP ))
ICON_PLACE_SPACING=$(( (( DriveIconsize / PIN_GRID_STEP ) + 1 ) * PIN_GRID_STEP ))
set -u
ICON_PLACE_SPACING=$(( (( DriveIconsize / PIN_GRID_STEP ) + 1 ) * PIN_GRID_STEP ))
ICON_PLACE_SPACING=$(( (( $DriveIconsize / $PIN_GRID_STEP ) + 1 ) * $PIN_GRID_STEP ))
man grep
LANG=C man grep
LC_ALL=C man grep
/etc/init.d/DRIVER/start_cpu_freq 
/etc/init.d/DRIVER/start_cpu_freq start
echo 40000 >/sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
ls /sys/devices/system/cpu/cpu0/cpufreq/ondemand/
ls /sys/devices/system/cpu/cpu0/cpufreq/
grep -H '.*' /sys/devices/system/cpu/cpu0/cpufreq/*
ls -l /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_transition_latency
grep -H '.*' /sys/devices/system/cpu/cpufreq/ondemand/*
echo 25 >/sys/devices/system/cpu/cpufreq/ondemand/up_threshold
grep -H '.*' /sys/devices/system/cpu/cpufreq/ondemand/*
modprobe -v acpi-cpufreq
ls /sys/*/sysytem
ls /sys/*/system
ls /sys/*/system/cpu
ls /sys/*/system/cpu/cpufreq
modprobe -v cpufreq_ondemand
ls /sys/*/system/cpu/cpufreq
pupx
geany /usr/local/bin/drive_all
time mount /dev/sda1
time umount /dev/sda1
dmesg
rox /proc
ps | grep AppRun
kill -9 510
ps | grep AppRun
pup_event_frontend_d restart
grep sda1 /proc/diskstats
pup_event_frontend_d restart
grep sdc /proc/diskstats
grep sdc /proc/*stat*
cat /proc/stat
cat /proc/io*
grep sdc /proc/*stat*
grep sdc /proc/*stat* | awk '{print S9}'
grep sdc /proc/*stat* | awk '{print $9}'
grep sda /proc/*stat* | awk '{print $9}'
grep sdb /proc/*stat* | awk '{print $9}'
grep sdb /proc/*stat* | awk '{print $12}'
grep sdb /proc/*stat* | awk '{print}'
grep sdb /proc/*stat* | awk '{print $0}'
grep sdb /proc/*stat* | awk '{print $1}'
grep sdb /proc/*stat* | awk '{print $2}'
grep sdb /proc/*stat* | awk '{print $3}'
grep sdb /proc/*stat* | awk '{print $4}'
grep sdb /proc/*stat* | awk '{print $5}'
grep sdb19 /proc/*stat* | awk '{print $5}'
grep sdb19 /proc/*stat* | awk '{print}'
grep sdb19 /proc/diskstats | awk '{print}'
grep sdb19 /proc/diskstats | awk '{print $12}'
grep sdb19 /proc/diskstats | awk '{print $15}'
grep sdb19 /proc/diskstats | awk '{print $14}'
awk "{if (\$3 == \"$oneDRVNAME\") print \$12}" /proc/diskstats
oneDRVNAME=sdb19
awk "{if (\$3 == \"$oneDRVNAME\") print \$12}" /proc/diskstats
top
make menuconfig
make.tgl
manke clean
make clean
make menuconfig
git branch
git branch -a
git log --grep losetup
readlink /sys/block/$oneDRVNAME
readlink /sys/block/sdb
readlink /sys/block/sdc
readlink /sys/block/sdc | grep usb
pup_event_frontend_d restart
pup_event_frontend_d restart
pup_event_frontend_d restart

Thu Nov 27 01:03:19 GMT+1 2014

uname -r
ddcprobe
make menuconfig
make clean
make menuconfig
rime umount /dev/sdb20
iime umount /dev/sdb20
time umount /dev/sdb20
time mount /dev/sdb20
time umount /dev/sdb20
defaultmediaplayer "/mnt/sda1/VID/MSC/Deutsch/Seeed - &quot;Ding&quot; (Official Video) - YouTube.flv"
gnome-mplayer --help
type -a mplayer
type -a mplayer~
/usr/local/bin/mplayer~ --version
/usr/local/bin/mplayer --version
/usr/local/bin/mplayer -version
file /usr/local/bin/mplayer
file /usr/local/bin/mplayer~
ls -ls /usr/local/bin/mplayer
ls -ls /usr/local/bin/mplayer~
du -s -BM /usr/local/bin/mplayer~
mplayer "/mnt/sda1/VID/MSC/Deutsch/Seeed - &quot;Ding&quot; (Official Video) - YouTube.flv"
mplayer~ "/mnt/sda1/VID/MSC/Deutsch/Seeed - &quot;Ding&quot; (Official Video) - YouTube.flv"
mplayer "/mnt/sda1/VID/MSC/Deutsch/Seeed - &quot;Ding&quot; (Official Video) - YouTube.flv"
ls -l /usr/loacal/bin/mplayer
ls -l /usr/local/bin/mplayer
ls -l /usr/local/bin/mplayer~
strace mplayer "/mnt/sda1/VID/MSC/Deutsch/Seeed - &quot;Ding&quot; (Official Video) - YouTube.flv" 2>mplayer-X11-error.strace
pwd
mplayer --help vo
mplayer -vo help
mplayer -vo xv "/mnt/sda1/VID/MSC/Deutsch/Seeed - &quot;Ding&quot; (Official Video) - YouTube.flv"
mplayer -vo x11 "/mnt/sda1/VID/MSC/Deutsch/Seeed - &quot;Ding&quot; (Official Video) - YouTube.flv"
top
killall -9 heroes3
filemnt "/mnt/sda2/PUPSFS/boswars-2.6.1-linux_431.sfs"
uname -r
./update_files_from_running_system 
cat /proc/partitons
cat /proc/partitions
mkfs.ext2 /dev/loop5p1
mkfs.ext2 /dev/loop5p2
mkfs.ext2 /dev/loop5p3
mkfs.ext2 /dev/loop5p5
mkfs.ext2 /dev/loop5p6
mkfs.ext2 /dev/loop5p7
time mount -o loop -t ext2 /dev/loop5p1
df
pwd
dmesg
losetup /dev/loop5 ./loopfile.zero 
losetup
losetup -a
busybox losetup 
fdisk /dev/loop5
partprobe -s
fdisk /dev/loop5
type -a fdisk
/usr/local/sbin/fdisk /dev/loop5
partprobe -s /dev/loop5
mount
umount /dev/loop5p1
mount
uname -r
top
killall mplayer
top
geany /usr/sbin/filemnt

Thu Nov 27 13:26:18 GMT+1 2014

time mount /dev/sdb20
time umount -r /dev/sdb20

Thu Nov 27 17:14:53 GMT+1 2014

test -d /mnt/dpup-010-rc1-k2.6.32.24.iso
test -d /mnt/dpup-010-rc1-k2.6.32.24.iso; echo $?
filemnt /mnt/sda2/PUPPY-ISOs/2.6.32/dpup-010-rc1-k2.6.32.24.iso
time filemnt /mnt/sda2/PUPPY-ISOs/2.6.32/dpup-010-rc1-k2.6.32.24.iso
umount /dev/loop0
umount /dev/loop1
time filemnt /mnt/sda2/PUPPY-ISOs/2.6.32/dpup-010-rc1-k2.6.32.24.iso
time filemntOLD /mnt/sda2/PUPPY-ISOs/2.6.32/dpup-010-rc1-k2.6.32.24.iso
time filemnt /mnt/sda2/PUPPY-ISOs/2.6.32/dpup-010-rc1-k2.6.32.24.iso
grep loop /proc/mountd
grep loop /proc/mounts
time filemnt /mnt/sda2/PUPPY-ISOs/2.6.32/dpup-010-rc1-k2.6.32.24.iso
time filemnt --help
time filemnt -help
time filemnt --version
time filemnt /mnt/sda2/PUPPY-ISOs/2.6.32/dpup-010-rc1-k2.6.32.24.iso
file loopfile.zero
./filemntNEW2 ./initrd.gz
filemntNEW2 ./initrd.gz
chmod +x /usr/sbin/filemntNEW2
filemntNEW2 ./initrd.gz
file ./initrd.gz
disktype ./initrd.gz
filemntNEW2 ./initrd.gz
filemntNEW2 ./initrd.gz; echo $?
mktemp --help
mktemp -d -p `pwd` filemntXXXXXX
cp -a `which filemntNEW2` filemntNEW
cp /usr/bin/filemntNEW /usr/sbin/filemntNEW.scribble
cp /usr/sbin/filemntNEW /usr/sbin/filemntNEW.scribble
cp /usr/bin/filemntNEW2 /usr/bin/filemntNEW
cp /usr/sbin/filemntNEW2 /usr/sbin/filemntNEW
geany /usr/sbin/filemntNEW
git commit
git commit
./update_files_from_running_system 
git commit
git add woof-code/rootfs-skeleton/usr/sbin/filemntNEW
git commit -m '/usr/sbin/filemntNEW: Added to replace filemnt'
git mv woof-code/rootfs-skeleton/usr/sbin/filemnt woof-code/rootfs-skeleton/usr/sbin/filemntOLD
git commit
./update_files_from_running_system 
diff /mnt/sdb19/SRC/F3p5/WOOF/GitHub.d/KarlGodt_WoofFork.Push.d/woof-code/rootfs-skeleton/usr/sbin/filemntOLD /usr/sbin/filemntOLD
touch /mnt/sdb19/SRC/F3p5/WOOF/GitHub.d/KarlGodt_WoofFork.Push.d/woof-code/rootfs-skeleton/usr/sbin/filemntOLD
./update_files_from_running_system 
./update_files.sh 
./replace_commit_files.sh 
geany /etc/rc.d/f4puppy5
geany /usr/sbin/filemntOLD
time for i in `seq 1 1 10000`; do realpath /bin/bash; done
time for i in `seq 1 1 10000`; do readlink -f /bin/bash; done
./update_files_from_running_system 
filemntNEW2 /mnt/sda2/PUPPY-ISOs/2.6.32/dpup-010-rc1-k2.6.32.24.iso
losetup -a
filemntNEW2 /mnt/sda2/PUPPY-ISOs/2.6.32/dpup-010-rc1-k2.6.32.24.iso
geany /bin/mount.sh
filemntNEW2 /mnt/sda2/PUPPY-ISOs/2.6.32/dpup-010-rc1-k2.6.32.24.iso
losetup -f
umount /dev/loop1
umount /dev/loop0
filemntNEW2 /mnt/sda2/PUPPY-ISOs/2.6.32/dpup-010-rc1-k2.6.32.24.iso
losetup -d
losetup -a
filemntNEW2 /mnt/sda2/PUPPY-ISOs/2.6.32/dpup-010-rc1-k2.6.32.24.iso
losetup -a
mount
losetup -d /dev/loop1
losetup -d /dev/loop2
losetup -d /dev/loop3
filemntNEW2 /mnt/sda2/PUPPY-ISOs/2.6.32/dpup-010-rc1-k2.6.32.24.iso
dd if=/dev/zero of=initrd.ext2 bs=1024 count=$((5*1024))
mkfs.ext2 initrd.ext2
file initrd.ext2 
cp initrd.ext2 initrd.ext3
cp initrd.ext2 initrd.ext4
tube2fs -j initrd.ext3
tune2fs -j initrd.ext3
mkfs.ext4 initrd.ext4
file initrd.ext*
gzip -9 initrd.ext3
file initrd.ext*
disktype initrd.ext*
type -a filemnt
cp -ai /usr/sbin/filemnt /usr/sbin/filemntOLD
for oneLOOP in `mount | grep '^/dev/loop' | cut -f 1 -d ' '`;   do echo $oneLOOP; done
losetup-FULL /dev/loop1
losetup-FULL /dev/loop0
cp -ai /usr/sbin/filemntOLD /usr/sbin/filemnt
diff /usr/sbin/filemnt /usr/sbin/filemntOLD
diff /usr/sbin/filemnt /usr/sbin/filemntNEW
diff /usr/sbin/filemnt /usr/sbin/filemntNEW2
diff /usr/sbin/filemntNEW /usr/sbin/filemntNEW2
mv /usr/sbin/filemntNEW2 /usr/sbin/filemnt
cp -ai /usr/bin/filemnt .
cp -ai /usr/sbin/filemnt .
./update_files_from_running_system 
git commit
git add woof-code/rootfs-skeleton/usr/sbin/filemnt
git commit -m '/usr/sbin/filemnt: Re-added.'

Fri Nov 28 00:22:06 GMT+1 2014

filemnt initrd.gz 
filemnt initrd.ext2
filemnt ./initrd.ext2
pwd
cd ..
filemnt ./initrd.ext2
filemnt initrd.ext2
df
df -T
for i in *; do test [ -f "$i" ] || continue;echo "$i"; done
for i in *; do [ -f "$i" ] || continue;echo "$i"; done
for i in *; do [ -f "$i" ] || continue; ls -1 ./*/"$i";echo "$i"; done
for i in *; do [ -f "$i" ] || continue; ls -1 ./*/"$i"; echo $?;echo ""; done
uname -r
modinfo slram
./replace_commit_files.sh 
./check_perms.sh 
stat --help
uname -r
diff /mnt/sdb6/bin/mount.sh /bin/mount.sh >mount_sh.diff
diff -up /mnt/sdb6/bin/mount.sh /bin/mount.sh >mount_sh.diff

Fri Nov 28 11:38:01 GMT+1 2014

git commit
./update_files_from_running_system 
mount
NewKernelStats.sh 
filemnt ./heroes-3_5.5.sfs 
Xdialog -title "$TITLE" -stdout -menu 0x0 5 "TEXT" "Quit" "do nothing - just leave" "ROX" "open ROX-Filer window" "console" "open rxvt console window" "unmount" "just unmount $bn_imgFILE" "unmountall" "unmount all $bn_imgFILE" "mountagain" "mount $bn_imgFILE again"
Xdialog -title "$TITLE" -stdout -menu 0x0 5 "TEXT" "Quit" "do_nothing_-_just_leave" "ROX" "open_ROX-Filer_window" "console" "open_rxvt_console_window" "unmount" "just_unmount_$bn_imgFILE" "unmountall" "unmount_all_$bn_imgFILE" "mountagain" "mount_$bn_imgFILE_again"
Xdialog -title "$TITLE" -stdout -menubox 0x0 5 "TEXT" "Quit" "do_nothing_-_just_leave" "ROX" "open_ROX-Filer_window" "console" "open_rxvt_console_window" "unmount" "just_unmount_$bn_imgFILE" "unmountall" "unmount_all_$bn_imgFILE" "mountagain" "mount_$bn_imgFILE_again"
TITLE=menu
Xdialog -title "$TITLE" -stdout -menubox 0x0 5 "TEXT" "Quit" "do_nothing_-_just_leave" "ROX" "open_ROX-Filer_window" "console" "open_rxvt_console_window" "unmount" "just_unmount_$bn_imgFILE" "unmountall" "unmount_all_$bn_imgFILE" "mountagain" "mount_$bn_imgFILE_again"
bn_imgFILE=puppysfs
Xdialog -title "$TITLE" -stdout -menubox 0x0 5 "TEXT" "Quit" "do_nothing_-_just_leave" "ROX" "open_ROX-Filer_window" "console" "open_rxvt_console_window" "unmount" "just_unmount_$bn_imgFILE" "unmountall" "unmount_all_$bn_imgFILE" "mountagain" "mount_$bn_imgFILE_again"
Xdialog -title "$TITLE" -stdout -menubox 0x0 5 "TEXT" "Quit" "do_nothing_-_just_leave"
Xdialog -title "$TITLE" -stdout -menubox "TEXT" 0x0 5  "Quit" "do_nothing_-_just_leave"
Xdialog -title "$TITLE" -stdout -menu "TEXT" 0x0 5 "Quit" "do nothing - just leave" "ROX" "open ROX-Filer window" "console" "open rxvt console window" "unmount" "just unmount $bn_imgFILE" "unmountall" "unmount all $bn_imgFILE" "mountagain" "mount $bn_imgFILE again"
Xdialog -title "$TITLE" -stdout -menu "TEXT" 0x50 7 "Quit" "do nothing - just leave" "ROX" "open ROX-Filer window" "console" "open rxvt console window" "unmount" "just unmount $bn_imgFILE" "unmountall" "unmount all $bn_imgFILE" "mountagain" "mount $bn_imgFILE again"
Xdialog -title "$TITLE" -stdout -menu "TEXT" 0x90 7 "Quit" "do nothing - just leave" "ROX" "open ROX-Filer window" "console" "open rxvt console window" "unmount" "just unmount $bn_imgFILE" "unmountall" "unmount all $bn_imgFILE" "mountagain" "mount $bn_imgFILE again"
Xdialog -title "$TITLE" -stdout -menu "TEXT" 50x90 7 "Quit" "do nothing - just leave" "ROX" "open ROX-Filer window" "console" "open rxvt console window" "unmount" "just unmount $bn_imgFILE" "unmountall" "unmount all $bn_imgFILE" "mountagain" "mount $bn_imgFILE again"
Xdialog -title "$TITLE" -stdout -menu "TEXT" 150x90 7 "Quit" "do nothing - just leave" "ROX" "open ROX-Filer window" "console" "open rxvt console window" "unmount" "just unmount $bn_imgFILE" "unmountall" "unmount all $bn_imgFILE" "mountagain" "mount $bn_imgFILE again"
Xdialog -title "$TITLE" -stdout -menu "TEXT" 250x190 7 "Quit" "do nothing - just leave" "ROX" "open ROX-Filer window" "console" "open rxvt console window" "unmount" "just unmount $bn_imgFILE" "unmountall" "unmount all $bn_imgFILE" "mountagain" "mount $bn_imgFILE again"
Xdialog -title "$TITLE" -stdout -nocancel -menu "TEXT" 250x190 7 "Quit" "do nothing - just leave" "ROX" "open ROX-Filer window" "console" "open rxvt console window" "unmount" "just unmount $bn_imgFILE" "unmountall" "unmount all $bn_imgFILE" "mountagain" "mount $bn_imgFILE again"
Xdialog -title "$TITLE" -stdout -no-cancel -menu "TEXT" 250x190 7 "Quit" "do nothing - just leave" "ROX" "open ROX-Filer window" "console" "open rxvt console window" "unmount" "just unmount $bn_imgFILE" "unmountall" "unmount all $bn_imgFILE" "mountagain" "mount $bn_imgFILE again"
filemnt /mnt/sda2/PUPSFS/heroes-3_5.5.sfs

Fri Nov 28 20:26:43 GMT+1 2014

./update_files_from_running_system 
./replace_commit_files.sh 
git commit
git add check_perms.sh
git commit -m 'check_perms.sh: Added to compare permissions and ownerships 
of files in GIT with the ones currently in OS.'
git commit
git add replace_commit_files.sh
git commit -m 'replace_commit_files.sh: Added -A switch to ls -1v for hidden files.'
git add update_files_from_running_system
git commit -m 'update_files_from_running_system: Added echo $? to cp -ai;
needs to figure out handling if not copied what to do...'
git commit
ddcprobe
uname -r
make menuconfig
NewKernelStats.sh 
uname -r

Fri Nov 28 23:29:42 GMT+1 2014

NewKernelStats.sh 
git commit
git config user.email karlgodt@excite.de
git config user.name KarlGodt
git commit
git add kernel-kit
git commit -m 'kernel-kit: Initial commit for branch Fox3-Dell755
to remove old git commit messages to reduce size of git repository.'
git commit
git add woof-arch
git commit -m 'woof-arch: Initial commit for branch Fox3-Dell755
to remove old git commit messages to reduce size of git repository.'
git commit
git add woof-code
git commit -m 'woof-code: Initial commit for branch Fox3-Dell755
to remove old git commit messages to reduce size of git repository.'
git commit
git add woof-distro
git commit -m 'woof-distro: Initial commit for branch Fox3-Dell755
to remove old git commit messages to reduce size of git repository.'
git branch
git checkout -b Fox3-Dell755
git branch
rox
git init
filemnt heroes-3_5.5.sfs 
git pull --dry-run /mnt/sdb19/SRC/F3p5/WOOF/GitHub.d/KarlGodt_WoofFork.Push.d
git pull /mnt/sdb19/SRC/F3p5/WOOF/GitHub.d/KarlGodt_WoofFork.Push.d
filemnt ./heroes-3_5.5.sfs 
uname -r
geany /usr/local/bin/drive_all
geany /bin/mount.sh
git help pull
git help fetch
git help merge
git help clone
git help daemon
git help config
git help remote
modprobe -l | grep scsi
uname -r
grep -H ATA_VERBOSE_ERROR /etc/modules/DOTconfig*
grep -H SCSI_CONSTANTS  /etc/modules/DOTconfig*
sdparm --long --all /dev/sdc
sdparm --verbose --long --all /dev/sdc
man -w
ls /usr/local/share/man
file /usr/local/share/man
man -w
man hexedit
echo HALLO >>/dev/sdc4
echo HALLO3 >>/dev/sdc4
dd if=/dev/sdc4 of=sdc4.dd bs=1 count=512
hexedit sdc4.dd
man hexedit
find /usr -wholename "*/man/*/hex*"
man /usr/local/man/man1/hexedit.1
find /usr -wholename "*/man/*/hex*"
man --version
man --help
man -w
mandb --help
mandb --version
strace man -w
smartctl -A /dev/sdc
smartctl -d sat -A /dev/sdc
smartctl -d  help
smartctl -d scsi -A /dev/sdc
smartctl -d ata -A /dev/sdc
hdparm -I /dev/sdc
hdparm -I /dev/sdc >hdparm_I_AGFA16Gb.txt
hdparm -I /dev/sdc >hdparm_I_AGFA16Gb.txt 2>&1
geany 1
geany hdparm_I_AGFA16Gb.txt
hdparm -I /dev/sdc >hdparm_I_AGFA16Gb.txt
geany hdparm_I_AGFA16Gb.txt
hdparm -I /dev/sdc
hdparm -iI /dev/sdc
sdparm -e --all --long
sdparm -e --all --long >sdparm_e__all__long.txt
sdparm /dev/sdc
sdparm --all /dev/sdc
sdparm -e all
sdparm -e --all
sdparm -e --all | grep 'read'
sdparm -e --all | grep 'write'
sdparm -e --all >sdparm_e__all.txt
geany sdparm_e__all.txt
sdparm -e --all | grep '^[[:blank:]]\+[A-Z]\+' | awk '{print $1}'
sdparm -e --all | grep '^[[:blank:]]\+[A-Z]\+' | awk '{print $1}' | while read STR; do echo $STR; done
sdparm -e --all | grep '^[[:blank:]]\+[A-Z]\+' | awk '{print $1}' | while read STR; do echo $STR; sdparm -g $STR /dev/sdc; sleep 0.1;done
man sdparm
dmesg | tail -n20
dmesg | tail
dmesg | tail -n20
dmesg | tail
fdisk /dev/sdc
make menuconfig
realpath /sys/block/sdc
realpath --help
ln -s /tmp/non-existant link
realpath link
readlink link
readlink -e link
readlink -f link
busybox readlink -f link
busybox readlink -f link; echo $?
readlink -f link; echo $?
man readlink
mount /dev/sdc9
umount /mnt/sdc9
fdisk /dev/sdc9
uname -r
partprobe -s /dev/sdc9
partprobe -s /dev/sdc
partprobe -s /dev/sdc9
fdisk /dev/sdc9
fdisk -l /dev/sdx
fdisk -l /dev/sdc
fdisk /dev/sdc10
cat/proc/partitions
cat /proc/partitions
/etc/init.d/SOFTWARE/dictd start
/etc/init.d/SOFTWARE/dicod start
pdict
exit
info grub

Sun Nov 30 14:24:47 GMT+1 2014

fdisk /dev/sdb
fdisk -l /dev/sdb
/etc/init.d/SOFTWARE/dicod start
geany /boot/grub/menu-chainloader.lst 
ls /usr/bin/dic*
/usr/bin/dictl --help
/usr/bin/dico --help
fdisk /dev/sda
fdisk -l /dev/sda
partprobe -s /dev/sda
partprobe -s /dev/sdb
fdisk -l /dev/sdc
blkid | sort
for i in menu*.lst; do echo $i; done
find /usr -name "libdic*"
pdict
geany `which pdict`
dictd
dicod
grub
dmesg

Sun Nov 30 20:03:42 GMT+1 2014

pupx
xset q
for i in menu*.lst; do geany $i; sleep 1; done
geany /etc/rc.d/rc.shutdown
pupFS=$(awk '{if ($1 == "/dev/root") print $3}' /proc/mounts)
echo $pupFS
ABSPUPHOME="/initrd${PUP_HOME}"
if [ "`awk "{if (\\$2 == \"$ABSPUPHOME\") print}"`" ]; then echo Y;fi
if [ "`awk "{if (\\$2 == \"$ABSPUPHOME\") print}" /proc/mounts`" ]; then echo Y;fi
if [ "`awk "{if (\\$2 == "$ABSPUPHOME") print}" /proc/mounts`" ]; then echo Y;fi
if [ "`awk "{if (\\$2 == \\"$ABSPUPHOME\\") print}" /proc/mounts`" ]; then echo Y;fi
awk "{if {\\$2 == \"/initrd${SAVE_LAYER}\") print $3}" /proc/mounts
SAVEFS=`awk "{if {\\$2 == \"/initrd${SAVE_LAYER}\") print $3}" /proc/mounts`
SAVEFS=`awk "{if (\\$2 == \"/initrd${SAVE_LAYER}\") print $3}" /proc/mounts`
SAVEFS=`awk "{if (\$2 == \"/initrd${SAVE_LAYER}\") print $3}" /proc/mounts`
cat /proc/mounts
awk '{if ($1 == '/dev/root') print /proc/mounts
awk '{if ($1 == '/dev/root') print}' /proc/mounts
awk '{if ($2 == '/') print}' /proc/mounts
awk '{if ($2 == "/") print}' /proc/mounts
awk '{if ($1 == "/dev/root") print $3}' /proc/mounts
pupFS=`awk '{if ($1 == '/dev/root') print $3}' /proc/mounts`
 devROOT=`rdev | cut -f1 -d' '`
echo $pupFS
echo $pupFS 
echo $devROOT
uname -r
geany /sbin/reboot
killall --help

Sun Nov 30 22:34:39 GMT+1 2014

uname -r
fsck -n /dev/sdb6
fsck  /dev/sdb6
echo -e '^G'
echo -e '\\033[G'
echo -e '\\033[Gm'
echo -e '\033[G'
echo -e '\033[G50'
echo -e '\033[50G'
echo -e '\033[0G'
beep
echo -e '\033[^G'
echo -e '\0007'
echo -e '\00007'
echo -e '\0007'
echo -e '\0006'
echo -e '\0008'
echo -e '\0009'
echo -e '\0010'
echo -e '\0011'
echo -e '\0012'
echo -e '\0013'
echo -e '\0014'
echo -e '\0015'
echo -e '\0016'
echo -e '\0017'
echo -e '\0020'
echo -e '\0021'
echo -e '\0022'
echo -e '0x0022'
echo -e '\0x0022'
echo -e '\0x022'
printf  %c 0x022
printf  %c 0x007
printf  %c 0x0
printf  %c 0x1
printf  %c 0x2
printf  %c 0x3
printf  %s 0x3
printf  %c 0x3
printf  %c 0x123
printf  %c 0x0123
printf  %c 0x012
printf  %c 0x12
printf  %d 0x12
printf  %d \0123
printf  %d \012
printf  %d \019
printf  %d \017
printf  %d \020
printf  %d \097
printf  %d \077
man ms-sys
ms-sys --help
find /usr -wholepath "*/man/*/ms-sys*"
find /usr -wholename "*/man/*/ms-sys*"
ls /dev/ram0
ls /dev/ram1
ms-sys -m /dev/ram1
ms-sys -m -f /dev/ram1
cd /tmp
mkdir ram1
cd ram1
dd if=/dev/ram1 of=ram1 bs=1 count=512
hexdump -C ram1
ms-sys -9 -f /dev/ram1
dd if=/dev/ram1 of=ram1 bs=1 count=512
hexdump -C ram1
ms-sys -d -f /dev/ram1
dd if=/dev/ram1 of=ram1 bs=1 count=512
hexdump -C ram1
ms-sys -1 -f /dev/ram1
dd if=/dev/ram1 of=ram1 bs=1 count=512
hexdump -C ram1
ms-sys -2 -f /dev/ram1
dd if=/dev/ram1 of=ram1 bs=1 count=512
hexdump -C ram1
ms-sys -3 -f /dev/ram1
dd if=/dev/ram1 of=ram1 bs=1 count=512
hexdump -C ram1
ms-sys -4 -f /dev/ram1
dd if=/dev/ram1 of=ram1 bs=1 count=512
hexdump -C ram1
ms-sys -5 -f /dev/ram1
dd if=/dev/ram1 of=ram1 bs=1 count=512
hexdump -C ram1
ms-sys -6 -f /dev/ram1
dd if=/dev/ram1 of=ram1 bs=1 count=512
hexdump -C ram1
NewKernelStats.sh 
info grub

Mon Dec 1 03:56:05 GMT+1 2014

geany /bin/mount.sh
geany /sbin/init

Mon Dec 1 04:22:57 GMT+1 2014

for i in menu*.lst; do echo $i; geany $i; sleep 1;done
NewKernelStats.sh 

Mon Dec 1 06:05:12 GMT+1 2014

fsck -n /dev/sdb6
fsck  /dev/sdb6
grep -H USB_SUSPEND /etc/modules/DOT*
df
mksquashfs ASM ASM-O2.sfs
mksquashfs BLADE BLADE-O2.sfs
mksquashfs Gpart Gpart-O2.sfs
mksquashfs HDPARM HDPARRM-9.4x-O2.sfs
mksquashfs MUSL MUSL-O2.sfs
mksquashfs SOUND SOUND-O2.sfs
mksquashfs SYSLINUX SYSLINUX-O2.sfs
mksquashfs LINCITY LINCITY-O2.sfs
for i in *; do echo $i; done
for i in *; do [ -d "$i" ] || continue;echo $i; done
for i in *; do [ -d "$i" ] || continue;[ -e "$i"-O2.sfs ] && continue;echo $i; done
for i in *; do [ -d "$i" ] || continue;[ -e "$i"-O2.sfs ] && continue;echo $i; mksquashfs "$i" "$i"-O2.sfs;sleep 5;done
for i in *; do echo $i; done
for i in *; do [ -d "$i" ] || continue; [ "$i" = OLD ] && continue;echo $i; done
for i in *; do [ -d "$i" ] || continue; [ "$i" = OLD ] && continue;echo $i; mksquashfs $i $i-O2.sfs; sleep 5;done
df
git branch
git tag
git checkout grub-legacy
grep -i viewport *
grep -r -i -I viewport *
pwd
gti log --grep viewport
git log --grep viewport
git log
git branch
git checkout master
git branch
rox
grep -r -i -I viewport *
grep -r -i -I -m1 viewport *
grep -r -i -I -m1 viewport * | while read f r; do echo $f; done
grep -r -i -I -m1 viewport * | while read f r; do f=${f%%:*};echo $f; done
grep -r -i -I -m1 viewport * | while read f r; do f=${f%%:*};echo $f; geany $f; sleep 1;done
info grub
greub
grub
grep -i -I enter *
pwd
grep -H USB_SUSPEND ./DOT*
grep -i splash *
grep -r -i splash *
grep -r -i title *
grep -r -i splash *
grep -r -i view *
info grub
man modprobe
echo $PATH
PATH=/var/bin:/var/sbin:$PATH
man modprobe
modprobe --help

Fri Dec 5 07:00:48 GMT+1 2014

chroot .
help chroot
chroot --help
chroot . /bin/ash
dumpe2fs -h /mnt/initrd.ext2
mount
dumpe2fs /dev/loop0
ls -l /mnt/initramdisk.ext2/dev/ram*
mount
df
umount /dev/loop0
fsck -n /mnt/sdb7/JUMP-6/initramdisk.ext2
fsck -f -v -n /mnt/sdb7/JUMP-6/initramdisk.ext2
fsck -f -v /mnt/sdb7/JUMP-6/initramdisk.ext2
dumpe2fs -J /mnt/sdb7/JUMP-6/initramdisk.ext2
dumpe2fs -h /mnt/sdb7/JUMP-6/initramdisk.ext2
dumpe2fs -h /dev/loop1
info grub
git log
git log --grep initrd
yes
NewKernelStats.sh 

Fri Dec 5 09:05:58 GMT+1 2014

cpio -id <initrd
cpio -id <initrd
mount -o loop -t minix /
rox /JUMP-2/
mount -o loop -t minix /JUMP-2/initrd.mnx /mnt/initrd.mnx
cpio -id <initrd
man switch_root
switch_root --help
man pivot_root
find /usr -name "pivot_root*"
man /usr/local/share/man/man8/pivot_root.8
dd if=/dev/zero of=initrd.ext3 bs=1024 count=((6*1024))
dd if=/dev/zero of=initrd.ext3 bs=1024 count=$((6*1024))
dd if=/dev/zero of=initrd.ext4 bs=1024 count=$((8*1024))
dd if=/dev/zero of=initrd.rfs3 bs=1024 count=$((7*1024))
dd if=/dev/zero of=initrd.mnx bs=1024 count=$((4*1024))
mkfs.ext3 initrd.ext3
mkfs.ext4 initrd.ext4
mkreiserfs initrd.rfs3
mkreiserfs -f initrd.rfs3
rm initrd.rfs3
dd if=/dev/zero of=initrd.rfs3 bs=1024 count=$((17*1024))
mkreiserfs -f initrd.rfs3
rm initrd.rfs3
dd if=/dev/zero of=initrd.rfs3 bs=1024 count=$((34*1024))
mkreiserfs -f initrd.rfs3
mkfs.minix initrd.mnx
df
mount -o loop -t reiserfs initrd.rfs3 /mnt/initrd.rfs3
df
umount /mnt/initrd.rfs3
rm initrd.rfs3
dd if=/dev/zero of=initrd.rfs3 bs=1024 count=$((40*1024))
mkreiserfs -f initrd.rfs3
mount -o loop -t reiserfs initrd.rfs3 /mnt/initrd.rfs3
df
df
geany /sbin/init
echo $((13824/1024))
uname -r
mount

Fri Dec 5 10:44:40 GMT+1 2014

mount -o loop -t reiserfs initrd.rfs3 /mnt/initrd.rfs3
mount -o loop -t minix /JUMP-2/initrd.mnx /mnt/initrd.mnx
yes

Fri Dec 5 12:12:37 GMT+1 2014

mount -o loop -t minix /JUMP-2/initrd.mnx /mnt/initrd.mnx
mount -o loop -t reiserfs initrd.rfs3 /mnt/initrd.rfs3
chroot .
chroot . /bin/ash
find -name chroot

Mon Dec 8 22:16:15 GMT+1 2014

geany /rtc/rc.d/rc.shutdown
geany /etc/rc.d/rc.shutdown
geany /sbin/poweroff
geany /sbin/reboot
busybox poweroff --help

Mon Dec 8 23:37:20 GMT+1 2014

geany /sbin/pup_event_backend_modprobe_protect
source /etc/rc.d/f4puppy5
_pidof -q pup_event_backend_modprobe_protect
_pidof  pup_event_backend_modprobe_protect
_pidof  pup_event_backend_modprobe_protect; echo $?
_pidof --quiet pup_event_backend_modprobe_protect; echo $?
_pidof -q pup_event_backend_modprobe_protect; echo $?
_pidof --quiet pup_event_backend_modprobe_protect; echo $?
_pidof  pup_event_backend_modprobe_protect; echo $?
/bin/ps -elF | grep -eE 'pup_event_backend_modprobe_protect[ ]+--daemon' | grep -v 'grep'
/bin/ps -elF
/bin/ps -elF | grep -Ee 'pup_event_backend_modprobe_protect[ ]+--daemon' | grep -v 'grep'
/bin/ps -elF | grep -eE 'pup_event_backend_modprobe_protect[ ]+--daemon' | grep -v 'grep'
pup_event_backend_modprobe_protect --stop
/bin/ps -elF | grep -eE 'pup_event_backend_modprobe_protect[ ]+--daemon' | grep -v 'grep'
/bin/ps -elF | grep -Ee 'pup_event_backend_modprobe_protect[ ]+--daemon' | grep -v 'grep'
pup_event_backend_modprobe_protect --daemon

Tue Dec 9 00:55:55 GMT+1 2014


Tue Dec 9 01:15:45 GMT+1 2014

git branch
git log --grep reboot

Tue Dec 9 01:47:15 GMT+1 2014

ls -l /dev/sda*
ls -l /dev/sdb*

Tue Dec 9 07:28:37 GMT+1 2014

echo -en "\rsnapmergepuppy still running "
while [ 1 ]; do echo -en "\rsnapmergepuppy still running "; echo -n '.'; slepp 1; done
while [ 1 ]; do echo -en "\rsnapmergepuppy still running "; echo -n '.'; sleep 1; done
while [ 1 ]; do a-$(( a = 1 ));echo -en "\rsnapmergepuppy still running "; echo -n $a; sleep 1; done
while [ 1 ]; do a=$(( a + 1 ));echo -en "\rsnapmergepuppy still running "; echo -n $a; sleep 1; done
git branch
git commit
git checkout linux-3.9.y
git log --grep reboot
echo $((16*60))
df
dd if=/dev/sdc of=/mnt/sdc/boot/mbr.dd bs=1 count=512
dd if=/dev/sdc of=/mnt/sdc1/boot/mbr.dd bs=1 count=512
hexedit /mnt/sdc1/boot/mbr.dd
info grub2

Wed Dec 10 02:41:26 GMT+1 2014

git branch -a
git checkout grub-legacy
git log
autom4te --help
autom4te --version
./autogen.sh
autoconf --version
file `which autom4te`
type -a autom4ate
type -a autom4te
file /usr/bin/autom4te
file /usr/local/bin/autom4te
/usr/local/bin/autom4te
/usr/local/bin/autom4te --version
which autom4te-2.67
which autom4te-2.68
mv /usr/bin/autom4te /usr/bin/autom4te-2.59
ln -s autom4te-2.67 /usr/bin/autom4te
./autogen.sh
ln -s ../local/bin/autom4te-2.68 /usr/bin/autom4te
ln -sf ../local/bin/autom4te-2.68 /usr/bin/autom4te
autom4te --version
./autogen.sh
./autogen.sh 
make clean
git commit
git tag -l
git checkount 1.99
git checkout 1.99
./autogen.sh 
autoreconf -vi
./configure
type -a m4
/usr/bin/m4 --version
/usr/local/bin/m4 --version
file /usr/bin/m4
mv /usr/bin/m4 /usr/bin/m4OLD
m4
type -a m4
ln -s ../local/bin/m4 /usr/bin/m4
make clean
make distclean
make
make -i clean
make -k clean
make
make -k
ldd linux.mod
find -name "*.img"
rm "*.module"
ls -1 "*.module"
ls -1 *.module
rm *.module
grp xput *
grep xput *

Thu Dec 11 01:58:47 GMT+1 2014

uname -r
cat /proc/cmdline
gzip -c -7 cloud-640x480x16.xpm >gz7-cloud-640x480x16.xpm
gzip -c -7 cloud-640x480x16.xpm >gz7-cloud-640x480x16.xpm.gz

Thu Dec 11 02:22:39 GMT+1 2014

ls /mnt/home/boot/grub/grubv0-640x480-16-nontr-I.xpm
ls /boot/grub/grubv0-640x480-16-nontr-I.xpm
ls /boot/grub/grubv0-640x480-16-nontr-I.xpm| wc -m
ls /boot/grub/grubv0-640x480-16-nontr-I.xpm| wc -b
ls /boot/grub/grubv0-640x480-16-nontr-I.xpm| wc -c
ls /boot/grub/grubv0-640x480-16-nontr-I.xpm| wc -L
echo "11121106901411144444444664CC44414141121121213212221222224213212212212120B612122212121212212212219C2222276222225F82323233323B5333323352332333253333333236393232322222222222223233623233333353633D533333333953333335357555555B557778DDDC77757777789CFFD8B777775B878777B8777878888788AA788DDC855568363333332538933363233337535335335537333333336ED955555555537835333338653393358332753333333333332333363623333333338333753337537388335387365533333333983333357335533333357335555575555877787888B7877778888B888AA8888887887887777887777788AA887C56566663636636446C24365434634242242424242424242414141119D41111110411101141111011101010101010110401044011101010100101"
echo "11121106901411144444444664CC44414141121121213212221222224213212212212120B612122212121212212212219C2222276222225F82323233323B5333323352332333253333333236393232322222222222223233623233333353633D533333333953333335357555555B557778DDDC77757777789CFFD8B777775B878777B8777878888788AA788DDC855568363333332538933363233337535335335537333333336ED955555555537835333338653393358332753333333333332333363623333333338333753337537388335387365533333333983333357335533333357335555575555877787888B7877778888B888AA8888887887887777887777788AA887C56566663636636446C24365434634242242424242424242414141119D41111110411101141111011101010101010110401044011101010100101" | wc -L
echo "11121106901411144444444664CC44414141121121213212221222224213212212212120B612122212121212212212219C2222276222225F82323233323B5333323352332333253333333236393232322222222222223233623233333353633D533333333953333335357555555B557778DDDC77757777789CFFD8B777775B878777B8777878888788AA788DDC855568363333332538933363233337535335335537333333336ED955555555537835333338653393358332753333333333332333363623333333338333753337537388335387365533333333983333357335533333357335555575555877787888B7877778888B888AA8888887887887777887777788AA887C56566663636636446C24365434634242242424242424242414141119D41111110411101141111011101010101010110401044011101010100101" | wc -c

Thu Dec 11 02:45:22 GMT+1 2014

geany /sbin/pup_event_backend_modprobe_protect
grep -r -I 'unknown operand' *
ash
exit
ps | grep pup
pup_event_backend_modprobe_protect --stop
[ "$VERBOSE" -o "$DEBUG" ]
[ "$VERBOSE" - o "$DEBUG" ]
ash

Thu Dec 11 03:50:25 GMT+1 2014


Thu Dec 11 05:33:17 GMT+1 2014


Thu Dec 11 06:54:22 GMT+1 2014


Thu Dec 11 07:17:18 GMT+1 2014

grub

Thu Dec 11 07:38:37 GMT+1 2014


Thu Dec 11 08:10:29 GMT+1 2014


Thu Dec 11 09:22:24 GMT+1 2014

/bin/df
A=/path/to/file/
echo ${A%/}
echo ${A%%/}
B=/path/to/file////
echo ${B%%/}
echo ${B%/}
echo ${A%/}
echo ${A%%/}
ash
free
bootmanager

Thu Dec 11 23:53:05 GMT+1 2014

./replace_commit_files.sh 
info grub2

Sat Dec 13 01:56:16 GMT+1 2014

./replace_commit_files.sh 
git commit
yaf-splash -bg yellow -fg black -timeout $MOUSEMSG_TT -text "OK, If your mouse receiver is
attached to a keyboard integrated hub,

and you don't want to wake the system by mouse moves,

or light up any LEDs on the keyboard,

then you have $MOUSEMSG_TT seconds from now,
to switch off the mouse..."
MOUSEMSG_TT=30
yaf-splash -bg yellow -fg black -timeout $MOUSEMSG_TT -text "OK, If your mouse receiver is
attached to a keyboard integrated hub,

and you don't want to wake the system by mouse moves,

or light up any LEDs on the keyboard,

then you have $MOUSEMSG_TT seconds from now,
to switch off the mouse..."
yaf-splash -bg yellow -fg black -timeout $MOUSEMSG_TT -text " OK, If your mouse receiver is
 attached to a keyboard integrated hub,

 and you don't want to wake the system by mouse moves,

 or light up any LEDs on the keyboard,

 then you have $MOUSEMSG_TT seconds from now,
 to switch off the mouse..."
yaf-splash -bg yellow -fg black -timeout $MOUSEMSG_TT -text " OK, If your mouse receiver is
 attached to a keyboard integrated hub,

 and you don't want to wake the system by mouse moves,

 or light up any LEDs on the keyboard,

 then you have $MOUSEMSG_TT seconds from now,
 to switch off the mouse..."
yaf-splash -bg yellow -fg black -timeout $MOUSEMSG_TT -text " OK, If your mouse receiver is \
 attached to a keyboard integrated hub, \

 and you don't want to wake the system by mouse moves, \

 or light up any LEDs on the keyboard, \

 then you have $MOUSEMSG_TT seconds from now, \
 to switch off the mouse..."
yaf-splash -bg yellow -fg black -timeout $MOUSEMSG_TT -text " OK, If your mouse receiver is ""
 ""attached to a keyboard integrated hub, ""

 ""and you don't want to wake the system by mouse moves, ""

 ""or light up any LEDs on the keyboard, ""

 ""then you have $MOUSEMSG_TT seconds from now, ""
 ""to switch off the mouse..."
yaf-splash -bg yellow -fg black -timeout $MOUSEMSG_TT -text "
| OK, If your mouse receiver is                         |
| attached to a keyboard integrated hub,                |
|                                                       |
| and you don't want to wake the system by mouse moves, |
|                                                       |
| or light up any LEDs on the keyboard,                 |
|                                                       |
| then you have $MOUSEMSG_TT seconds from now,          |
| to switch off the mouse...                            |
_________________________________________________________"
yaf-splash -bg yellow -fg black -timeout $MOUSEMSG_TT -text "_________________________________________________________
| OK, If your mouse receiver is                         |
| attached to a keyboard integrated hub,                |
|                                                       |
| and you don't want to wake the system by mouse moves, |
|                                                       |
| or light up any LEDs on the keyboard,                 |
|                                                       |
| then you have $MOUSEMSG_TT seconds from now,                  |
| to switch off the mouse...                            |
_________________________________________________________"
yaf-splash -bg yellow -fg black -timeout $MOUSEMSG_TT -text "---------------------------------------------------------
| OK, If your mouse receiver is                         |
| attached to a keyboard integrated hub,                |
|                                                       |
| and you don't want to wake the system by mouse moves, |
|                                                       |
| or light up any LEDs on the keyboard,                 |
|                                                       |
| then you have $MOUSEMSG_TT seconds from now,                   |
| to switch off the mouse...                            |
_________________________________________________________"
yaf-splash -bg yellow -fg black -timeout $MOUSEMSG_TT -text "---------------------------------------------------------
| OK, If your mouse receiver is                         |
| attached to a keyboard integrated hub,                |
|                                                       |
| and you don't want to wake the system by mouse moves, |
|                                                       |
| or light up any LEDs on the keyboard,                 |
|                                                       |
| then you have $MOUSEMSG_TT seconds from now,                    |
| to switch off the mouse...                            |
---------------------------------------------------------"
grep boot_loader_name *
grep -r boot_loader_name ../*
git log
git branch
git tag
grep viewport *
diff -urAnd grub-0.94 grub-0.95
diff -uraNd grub-0.94 grub-0.95
diff -uraNd grub-0.94 grub-0.95 >grub-0.94_0.95.diff
help2man
geany `which pupzip`
./replace_commit_files.sh 
type -path rpm2cpio
ash 
grep splashimage *
grep gfxmenu *
grep -r gfxmenu *
grep -r splashimage *
grep -r viewport *
pupzip /mnt/sdb7/boot/temporary/trustedgrub-1.1.0-14.1.src.rpm
grep 'GNU GRUB' *
geany /usr/local/bin/drive_all
geany /etc/rc.d/f4puppy5
source /etc/rc.d/f4puppy5
__get_jobs
xmessage "HELLO" &
__get_jobs
DEBUG=1
__get_jobs
echo $MY_SELF
echo $0
ps | grep bash
tty
jobs
jobs -l
ps | grep bash
__get_jobs xmessage
mount
mount /dev/sr1
umount /mnt/sr1
mount /dev/sr1
umount /mnt/sr1
dpkg-deb ./grub-installer_1.07.1_i386.udeb .
dpkg-deb -x ./grub-installer_1.07.1_i386.udeb .
dpkg-deb --help
dpkg-deb -x ./grub-installer_1.07.1_i386.udeb ./
dpkg-deb -x ./grub-installer_1.07.1_i386.udeb /tmp
dpkg-deb -X ./grub-installer_1.07.1_i386.udeb /tmp
dpkg-deb -I ./grub-installer_1.07.1_i386.udeb 
mkdir _install
dpkg-deb -X ./grub-installer_1.07.1_i386.udeb ./_install
dpkg-deb -c ./grub-installer_1.07.1_i386.udeb 
dpkg-deb -c ./lilo-installer_1.07_i386.udeb 
dpkg-deb -I ./lilo-installer_1.07_i386.udeb 
dpkg-deb --help
dpkg-deb -X -D ./lilo-installer_1.07_i386.udeb .
dpkg-deb -D -X ./lilo-installer_1.07_i386.udeb .
dpkg-deb -D --fsys-tarfile ./lilo-installer_1.07_i386.udeb .
dpkg-deb -D --fsys-tarfile ./lilo-installer_1.07_i386.udeb
dpkg-deb -D -w ./lilo-installer_1.07_i386.udeb
dpkg-deb -D -W ./lilo-installer_1.07_i386.udeb
dpkg-deb -D -f ./lilo-installer_1.07_i386.udeb
dpkg-deb -D --new -X ./lilo-installer_1.07_i386.udeb .
dpkg-deb -D --old -X ./lilo-installer_1.07_i386.udeb .
top
mount
pidof mount
mount /dev/sr1
mount
/mnt/home/root/.pup_event/drive_sr1/AppRun
uname -runame -r
uname -r
cat /proc/cmdline
echo /tmp/grub-disk_0.95+cvs20040624-17sarge1_all/usr/share/grub-disk/grub-0.95-i386-pc.iso | wc -L
losetup
losetup -a
busybox losetup -a
busybox losetup
mount
umount //mnt/grub-0.95-i386-pc.iso
filemnt /tmp/grub-disk_0.95+cvs20040624-17sarge1_all/usr/share/grub-disk/grub-0.95-i386-pc.iso
./replace_commit_files.sh 
gzip grubv0-640x480-16-nontr-I.xpm 
geany /etc/rc.d/functions4puppy4
geany /bin/mount.sh
geany /usr/local/petget/petget

Sun Dec 14 06:11:04 GMT+1 2014

grep pager *
grub
grep '\(hd1,4\)' *
sed -i 's/(hd1,4)/(hd1,14)/' *.lst
grep '\(hd1,4\)' *.lst
grep '\(hd1,14\)' *.lst
grep '\(hd1,4\)' *.lst
sed -i 's! hd1,4/! hd1,14/!' *.lst
grep '\(hd1,4\)' *.lst
sed -i 's! hd1,4 ! hd1,14 !' *.lst
grep '\(hd1,4\)' *.lst
grep '\(hd0,4\)' *.lst
pwd
grep 'sdb5' *.lst
sed -i 's!sdb5!sdb15!' *.lst
grep 'sdb5' *.lst
grep 'sdb15' *.lst
grep '\(hd1,4\)' *
sed -i 's/(hd1,4)/(hd1,19)/' *.lst
sed -i 's!sdb5!sdb20!' *.lst
sed -i 's! hd1,4/! hd1,19/!' *.lst
sed -i 's! hd1,4 ! hd1,19 !' *.lst
df
man /mnt/sdb19/PET.D/grub-gfxboot-ext4-and inode256-compatible/grub-gfxboot_0.97-36mepis1/usr/share/man/man8/grub.8.gz
man /mnt/sdb19/PET.D/grub-gfxboot-ext4-and\ inode256-compatible/grub-gfxboot_0.97-36mepis1/usr/share/man/man8/grub.8.gz
man "/mnt/sdb19/PET.D/grub-gfxboot-ext4-and inode256-compatible/grub-gfxboot_0.97-36mepis1/usr/share/man/man8/grub.8.gz"
man /mnt/sdb19/PET.D/grub-gfxboot-ext4-and-inode256-compatible/grub-gfxboot_0.97-36mepis1/usr/share/man/man8/grub.8.gz
ls /usr/lib/grub4dos
file /usr/lib/grub4dos/*
du /usr/lib/grub4dos/*
which bootlace.com
bootlace.com --help
info grub4dos
man bootlace
man bootlace.com
find /usr -name grub4dos

Sun Dec 14 09:39:04 GMT+1 2014

git branch
make
git tag
./configure
for i in *_mntd48.*; do echo $i; done
for i in *_mntd48.*; do j=${i%48*};echo $i $j; done
for i in *_mntd48.*; do j=${i%48*};echo $i $j; [ -e ${j}rw48.png ] || cp ${i} ${j}rw48.png;[ -e ${j}ro48.png ] || cp $i ${j}ro48.png;done
geany `which grub-install`
grep -r MAX_FALLBACK_ENTRIES *
grub
info grub2
info grub

Tue Dec 16 08:44:50 GMT+1 2014

diff -urp grub-0.97-reiser4/ Grub-Legacy-0.97/
diff -urp Grub-Legacy-0.97/ grub-0.97-reiser4/ >grub1-grub1reiser4.diff
mplayer BEFB8d01 
file BEFB8d01
./BEFB8d01 
head -n10 BEFB8d01 
hexedit BEFB8d01 
find -size +4M
./replace_commit_files.sh 
cat /root/.jwmrc-tray | grep -v -x '^[[:blank:]]*'
cat /root/.jwmrc-tray | grep -v -x '^[[:blank:]]\+'
jwm -v 2>/dev/null | head -n1 | grep -oe '[[:digit:]]*'
jwm -v 2>/dev/null | head -n1 | grep -oe '[[:digit:]]\+'
git commit
git commit 2>&1 | while read l f; do [ -e "$f" ] || continue; echo "$f"; done
git commit 2>&1 | while read l f; do [ -e "$f" ] || continue; echo "$f"; git add "$f" && git commit -m "$f: grep '+*' fixes";sleep 2;done
pwd
cd ../../
./replace_commit_files.sh 
ls /usr/share/i18n/layouts
ls /usr/share/i18n/
ls /proc/dma
cat /proc/dma
cat /proc/interrupts 
grep -m 1 -x 'gtk\-font\-name.*' $HOME/.gtkrc-2.0 2>$ERR | grep -v -E -e '^#|^[[:blank:]]*#'
ERR=/dev/stdout
grep -m 1 -x 'gtk\-font\-name.*' $HOME/.gtkrc-2.0 2>$ERR | grep -v -E -e '^#|^[[:blank:]]*#'
grep -m 1 -x 'gtk\-font\-name.*' $HOME/.gtkrc-2.0 2>$ERR | grep -v -E -e '^[[:blank:]]*#'
geany usr/sbin/pmount
geany usr/sbin/pupdial
geany usr/sbin/partview2.03
cat $HOME/.Xresources | grep -vEe '^Xft\.dpi:|^[[:blank:]]*Xft\.dpi:'
cat $HOME/.Xresources | grep -vEe '^[[:blank:]]*Xft\.dpi:'
cat $HOME/.Xresources | grep -Ee '^[[:blank:]]*Xft\.dpi:'
geany usr/sbin/set-xftdpi
geany usr/sbin/petget
geany usr/sbin/ptooltips
xrandr -q | grep '*' | egrep "[0-9]+[ ]*x[ ]*[0-9]+" -o
xrandr -q | grep '*'
xrandr -q | grep '\*'
xrandr -q | grep '*' | egrep -o "[0-9]+[ ]*x[ ]*[0-9]+"
geany usr/sbin/xorgwizard
geany usr/bin/new2dir
geany usr/bin/xwin
geany sbin/init
VARS=`dumpe2fs $DEVROOTDRIVE | grep -E 'Maximum mount count|Mount count|Next check after|Check interval'
VARS=`dumpe2fs $DEVROOTDRIVE | grep -E 'Maximum mount count|Mount count|Next check after|Check interval'`
DEVROOTDRIVE=/dev/sdb5
VARS=`dumpe2fs $DEVROOTDRIVE | grep -E 'Maximum mount count|Mount count|Next check after|Check interval'`
echo "$VARS" | grep 'Check interval' | tr '\n' ' '
interC=`echo "$VARS" | grep 'Check interval' | tr '\n' ' '`
echo "$interC"
echo "$interC" | tr -s ' ' | cut -f 3 -d ' ' | grep -o -e '[[:digit:]]*'
echo "$interC" | tr -s ' ' | cut -f 3 -d ' '
echo "$interC" | tr -s ' ' | cut -f 3 -d ' ' | grep -o -e '[[:digit:]]+'
echo "$interC" | tr -s ' ' | cut -f 3 -d ' ' | grep -o -e '[[:digit:]]\+'
geany usr/local/jwmconfig2/virtualDesk
geany usr/local/jwmconfig2/panel-buttons
geany usr/local/jwmconfig2/gtk2jwm
geany usr/local/jwmconfig2/taskbarPlace
geany usr/local/jwmconfig3/virtualDesk
geany usr/local/jwmconfig3/panel-buttons
geany usr/sbin/keymap-set
geany usr/sbin/usb_modeswitch.sh
geany usr/sbin/alsaconf
geany usr/sbin/partview
grep -H -r -m1 'grep .*\*' *
grep -H -r -m1 'grep .*\*' * 2>/dev/null
geany /sbin/pup_event_frontend_d
geany /etc/rc.d/f4puppy5
which input-wizard
file /usr/sbin/input-wizard
geany /usr/sbin/input-wizard
`jwm -v 2>/dev/null | grep -o -e 'vsvn\-[0-9]\+'
jwm -v 2>/dev/null | grep -o -e 'vsvn\-[0-9]\+'
jwm -v
jwm -v 2>/dev/null | grep -o -E -e 'vsvn-[0-9]+|vgit-[0-9]+'
/sbin/pup_event_frontend_d restart
find /usr -name xmodmap
/usr/X11R7-2013-12-28/bin/xmodmap -pp
ash
xmodmap -pp
xmodmap -pp | grep -E " *[0-9] *[0-9]"
xmodmap -pp | grep -E " +[0-9] +[0-9]"
input-wizard
/sbin/pup_event_frontend_d restart

Tue Dec 16 15:02:33 GMT+1 2014


Tue Dec 16 15:09:10 GMT+1 2014


Tue Dec 16 17:54:20 GMT+1 2014

ffconvert
freecraft
grep -r -m1 -I viewport *
patch <../grub-fedora-9.patch 
pwd
pwd
ls /boot/COMPILE/Patch.d/centos/grub-0.97-93.el6.src/grub-0.97/stage2/fsys_ext2fs.c
pwd
ls -d
ls -d .
ls -d *
ls stage2/fat.h
ls ./stage2/fat.h
pwd
patch -p1 <grub-fedora-9.patch 
tar -c -z -f grub-0.97-fedora-9patched.tar.gz grub-0.97-fedora-9patched/
find -name "*xpm*"
uname -r
grep tinfo *
grep -i tinfo *
/mnt/home/root/COMPILE/grub-0.97-fedora-9patched/grub/grub
./configure --prefix=`pwd`/_install0
autoreconf
./configure --prefix=`pwd`/_install0
make
make clean
make.tgl
make
make.tgl
make
make install
/mnt/home/root/COMPILE/grub-0.97-fedora-9patched/_install0/sbin/grub-terminfo
/mnt/home/root/COMPILE/grub-0.97-fedora-9patched/_install0/sbin/grub-terminfo xterm
echo -e '\033[27m'
/mnt/home/root/COMPILE/grub-0.97-fedora-9patched/_install0/sbin/grub-terminfo vt100
/mnt/home/root/COMPILE/grub-0.97-fedora-9patched/_install0/sbin/grub-terminfo vt101
/mnt/home/root/COMPILE/grub-0.97-fedora-9patched/_install0/sbin/grub-terminfo vt102
find /usr -name "libtinfo*"
infocmp
type -a gcc
file /usr/bin/gcc
file /usr/local/bin/gcc
/usr/bin/gcc --version
/usr/local/bin/gcc --version
geany /usr/include/reiser4/*
./configure --prefix=`pwd`/_install0
make.tgl
make
patch -p <grub_0.97-29ubuntu50.diff 
pwd
patch -p1 <grub_0.97-29ubuntu50.diff 
pwd
rox
patch -p1 <grub_0.97-29ubuntu53.diff 
ls debian
ls -1 debian
ls -1 debian/
ls -1 debian/patches/
while read oneLINE; do echo "$oneLINE"; done <debian/00list
while read oneLINE; do echo "$oneLINE"; done <debian/patches/00list
while read oneLINE; do test "$oneLINE" || continue;echo "$oneLINE"; done <debian/patches/00list
while read oneLINE; do test "$oneLINE" || continue;case $oneLINE in \#*)continue;;esac;echo "$oneLINE"; done <debian/patches/00list
while read oneLINE; do test "$oneLINE" || continue;case $oneLINE in \#*)continue;;esac;echo "$oneLINE"; patch -p1 <debian/patches/$oneLINE || break;done <debian/patches/00list
while read oneLINE; do test "$oneLINE" || continue;case $oneLINE in \#*)continue;;esac;echo "$oneLINE"; done <debian/patches/00list
while read oneLINE; do test "$oneLINE" || continue;case $oneLINE in \#*)continue;;esac;echo "$oneLINE"; patch -p1 <debian/patches/$oneLINE || break;done <debian/patches/00list
geany /usr/include/stdio.h
find -name "stddef.h"
find /usr -name "stddef.h"
./configure --prefix=`pwd`/_install0
make
geany stage2/char_io.c
pwd
make
make clean
./configure --prefix=`pwd`/_install0 CFLAGS="-I/usr/include"
make
make clean
./configure --prefix=`pwd`/_install0 CFLAGS="-I/usr/include -I/usr/lib/gcc/i486-t2-linux-gnu/4.2.2/include/"
make
make clean
make
make clean
make
grep -m3 va_list /usr/include/*
grep -m1 va_list /usr/include/*
geany /usr/include/stdarg.h
geany /usr/include/stdio.h
tar -c -z -f grub-0.97-ubuntu29-50.tar.gz grub-0.97-ubuntu29-50/
tar -c -z -f grub-0.97-ubuntu29-53.tar.gz grub-0.97-ubuntu29-53/
rox
make install
./configure --prefix=`pwd`/_install0
make
make clean
./configure --prefix=`pwd`/_install0 CFLAGS="-I/usr/include -I/usr/lib/gcc/i486-t2-linux-gnu/4.2.2/include/"
make
make.tgl
make install
for i in *.patch; do echo $i; done
for i in *.patch; do echo $i; patch -p1 <$i || break;done
for i in *.patch; do echo $i; patch -p1 <$i;done
./configure --prefix=`pwd`/_install0
make.tgl
make
make.tgl
make install
/root/COMPILE/grub-0.97-slackware/_install0/sbin/grub
grub
mktmp --help
mktemp --help
mktemp -u -d -t today
mktemp -u -d -p today
mount -a
mount -a -o ro
ps | grep mplayer

Wed Dec 17 14:52:50 GMT+1 2014

/usr/multimedia/bin/aqualung /mnt/sdc12/MSC.d/p1/1E373d01
mplayer /mnt/sdc12/MSC.d/p1/1E373d01
geany /usr/local/bin/defaultaudioplayer
mplayer -help
man maplayer
man mplayer
find /usr -wholename "*/man/*/mplayer*"
man /usr/share/man/man1/mplayer.1.gz

Thu Dec 18 12:38:57 GMT+1 2014

pwd
mkdir /proc
mkdir ./proc
mkdir ./sys
mount -t proc proc ./proc
mount -t sysfs sysfs ./sys
chroot . ./ash
umount ./sys
umount ./proc
umount ./dev
mount
pwd
mkdir ./dev
mount -t ramfs devramfs ./dev
umount ./dev
mount -o bind /dev ./dev
mount /dev/sdc1
pwd
ln -s /mnt ./mnt
ldd /root/COMPILE/grub-0.97-fedora-9patched/_install0/sbin/grub
mount
pwd
mount -o bind /proc ./proc
mount -o bind /sys ./sys
mount -o bind /dev ./dev
chroot . ash
umount ./dev
mount
pwd
mount -o bind /dev ./dev
mount -o bind /proc ./proc
mount -o bind /sys ./sys
chroot . ash
umount ./dev
ldd *
pwd
mount --bind /dev ./dev
mount --bind /proc ./porc
mount --bind /proc ./proc
umount ./porc
mount --bind /sys ./sys
chroot . ash
umount ./dev
mount
umount /root/COMPILE/grub-0.97-slackware/_install0/mnt/sdc8

Fri Dec 19 21:05:33 GMT+1 2014

geany /etc/rc.d/rc.shutdown
geany /usr/bin/xwin
geany /etc/rc.d/rc.sysinit
geany /etc/rc.d/rc.sysinit.run
ash
git branch
git log --grep kbd
git log --grep hotplug
Xorg -help
geany /etc/X11/xorg.conf
df

Sat Dec 20 06:07:01 GMT+1 2014

geany /etc/rc.d/f4puppy5
mount /dev/sda1
geany /etc/rc.d/rc.sysinit.run
man xorg.conf
echo $PATH
PATH=/var/bin:$PATH
man xorg.conf
find /usr -wholename "*/man/*/xorg.conf*"
man /usr/share/man/man5/xorg.conf.5.gz
exit

Sat Dec 20 18:23:32 GMT+1 2014

geany /usr/bin/xwin
geany /etc/rc.d/rc.sysinit
geany /etc/rc.d/rc.sysinit.run
mount /dev/sda1

Sat Dec 20 23:10:14 GMT+1 2014

geany /etc/rc.d/f4puppy5

Sat Dec 20 23:32:02 GMT+1 2014

grin ls -l 
date
mount /dev/sda1

Sun Dec 21 05:51:01 GMT+1 2014

geany `which plogout`
geany /usr/bin/gojwmgo
geany /usr/bin/goe17go
which restartwm
geany /usr/bin/restartwm
geany /usr/bin/wmexit
geany /usr/bin/wmpoweroff
geany /usr/bin/wmreboot
geany /geany /etc/X11/xorg.conf0
Xorg --version
Xorg -version
geany /etc/profile.d/06_shell 
git commit
./replace_commit_files.sh 
ash
for x in {,/usr,/usr/local,/opt}/{,/*}/{bin,sbin} {$HOME/my-applications,/root/my-applications}/{bin,sbin} ; do echo $x; done
echo $PATH
unset PATH
echo $PATH
/etc/profile.d/06_shell 
echo $PATH
/etc/profile.d/06_shell 
echo $PATH
source /etc/profile.d/06_shell 
echo $PATH
geany /etc/rc.d/f4puppy5
unset PATH
echo $PATH
source /etc/profile.d/06_shell 
echo $PATH
unset PATH
echo $PATH
/etc/profile.d/06_shell 
echo $PATH
/etc/profile.d/06_shell 
echo $PATH
source /etc/profile.d/06_shell 
help type
type which
type -t which
type -P which
unset PATH
echo $PATH
source /etc/profile.d/06_shell 
echo $PATH
source /etc/profile.d/06_shell 
unset PATH
source /etc/profile.d/06_shell 
/etc/profile.d/06_shell 
unset PATH
/etc/profile.d/06_shell 
unset PATH
echo $PATH
/etc/profile.d/06_shell 
echo $PATH
source /etc/profile.d/06_shell 
/etc/profile.d/06_shell 
echo $PATH
find /usr -wholename "*/man/*/*xorg.conf*"
man /usr/X11R7.7-1.10.6-BIG/share/man/man5/xorg.conf.5
man 5 xorg.conf
LC_ALL=C man xorg.conf
LANG=C man xorg.conf
man --help
man -f xorg.conf
man -k xorg.conf
man -w
man -w xorg.conf
ls /usr/X11R7.7-1.7.7-BIG/
ls /usr/X11R7.7-1.7.7-BIG/man
ls /usr/X11R7.7-1.7.7-BIG/man/man4
man -C /etc/man.conf -w xorg.conf
man xorg.conf
geany /etc/man.conf
find /usr -name "xorg.conf*"
which man
file /var/bin/man
strace /var/bin/man xorg.conf
strace /var/bin/man xorg.conf 2>man_xorg_conf.strace
geany man_xorg_conf.strace
find /usr -name "xorg.conf*"
file /usr/share/man
rox -d /usr/hare/man
rox -d /usr/share/man
man xorg.conf
grep -r -H -i hotplug *
grep -r AutoAddDevices *
exit

Sun Dec 21 13:08:14 GMT+1 2014

geany /etc/rc.d/rc.sysinit.run
geany /sbin/pup_event_frontend_d
geany /usr/bin/wmrestart
geany /usr/bin/wmexit
geany /usr/bin/wmreboot
geany /usr/bin/wmpoweroff
geany /usr/bin/restartwm
geany /usr/bin/xwin
trap -l
man trap
help trap
trap -p
ash
killall -SIGHUP pup_event_frontend_d
killall -1 pup_event_frontend_d
killall -HUP pup_event_frontend_d
ash
ps | grep pup
/sbin/pup_event_backend_modprobe_protect --stop
ps | grep pup
ps | grep pup
trap -l
/root/PupEvent/pup_event_frontend_d
ps -C pup_event_frontend_d -o pid
ps -C pup_event_frontend_d --no-header -o pid
geany /usr/bin/xwin
geany /usr/sbin/xorgwizard
geany /sbin/clean_desk_icons 
geany /usr/sbin/eventmanager
cp -i /sbin/pup_event_frontend_d /sbin/pup_event_frontend_d-2014-12-21
eventmanager
pup_event_frontend_d restart
pup_event_frontend_d restart
./replace_commit_files.sh 
git commit
git add woof-code/rootfs-skeleton/etc/man.conf
git commit -m '/etc/man.conf: Added.'

Sun Dec 21 15:58:28 GMT+1 2014

grub
mtpaint
mtpaint-3.31

Sun Dec 21 20:35:20 GMT+1 2014

ps | grep fb
killall fbxkb
fbxkb

Mon Dec 22 11:29:30 GMT+1 2014


Tue Dec 23 06:41:17 GMT+1 2014

oneFS=securityfs
echo ${oneFS%fs}
ls /sys/kernel/debug/
ls /sys/kernel/debug/usb
cat /proc/filesystems
cat /proc/filesystems | grep sel

Tue Dec 23 11:31:42 GMT+1 2014

grep -e 'Console: switching to colour frame buffer device [0-9]\+x[0-9]\+' /var/log/bootkernel.log
grep -e 'Console: switching to colour frame buffer device [0-9]\+x[0-9]\+' /var/log/bootkernel.log | awk '{print $NF}'
grep -m1 -e .*=.*\.lo[g\'\"]*$ $(which pup_event_backend_modprobe) | grep -vE '<|>'
grep -m1 -e .*=.*\.lo[g\'\"]+$ $(which pup_event_backend_modprobe) | grep -vE '<|>'
grep -m1 -e .*=.*\.lo[g\'\"]\+$ $(which pup_event_backend_modprobe) | grep -vE '<|>'
grep -m1 -E -e .*=.*\.lo[g\'\"]\+$ $(which pup_event_backend_modprobe) | grep -vE '<|>'
grep -m1 -e .*=.*\.lo[g\'\"]\\+$ $(which pup_event_backend_modprobe) | grep -vE '<|>'
grep -e 'Console: switching to colour frame buffer device [0-9]\+x[0-9]\+' /var/log/bootkernel.log| tail -n1 | awk '{print $NF}' | cut -f1 -dx
geany /usr/bin/xwin
find -type f
find -type f -not -name "*ORIG"
find -type f -not -name "*ORIG" | while read f; do absf=${f#./}; echo $absf; done
find -type f -not -name "*ORIG" | while read f; do absf=${f#.}; echo $absf; done
find -type f -not -name "*ORIG" | while read f; do absf=${f#.}; echo $absf; [ -e "$absf" ] || continue; file $f | grep -E 'shell|ash|bash' || continue;done
find -type f -not -name "*ORIG" | while read f; do absf=${f#.}; echo $absf; [ -e "$absf" ] || continue; file $f | grep -E 'shell|ash|bash|text' || continue;done
find -type f -not -name "*ORIG" | while read f; do absf=${f#.}; echo $absf; [ -e "$absf" ] || continue; file $f | grep -E 'shell|ash|bash|text' || continue;diff -qs $f $absf;echo;done
find -type f -not -name "*ORIG" | while read f; do absf=${f#.}; echo $absf; [ -e "$absf" ] || continue; file $f | grep -E 'shell|ash|bash|text' || continue;diff -qs $f $absf || echo $f:$absf >>/root/difffiles.lst;echo;done
diff -up ./bin/mount.sh /bin/mount.sh
diff -up ./etc/rc.d/functions4puppy4 /etc/rc.d/functions4puppy4
diff -up ./etc/rc.d/f4puppy5 /etc/rc.d/f4puppy5
diff -up ./root/.xinitrc /root/.xinitrc
diff -up ./usr/bin/xorgwizard /usr/bin/xorgwizard
diff -up ./usr/sbin/xorgwizard /usr/sbin/xorgwizard
diff -up ./usr/bin/xwin /usr/bin/xwin
geany /etc/init/vc8
find /usr/lib -xdev -type f -name vesa_drv.so
find /usr/lib/X11 -xdev -type f -name vesa_drv.so
find -L /usr/lib/X11 -xdev -type f -name vesa_drv.so
ls /usr/lib/X11
ls -F /usr/lib/X11
ls -F /usr/lib/X11/*
find -L /usr/lib/xorg -xdev -type f -name vesa_drv.so
find -L /usr/lib/ -xdev -type f -name vesa_drv.so
file /usr/lib/X11/
file /usr/lib/X11
file /usr/lib/X11/../X11R7/lib/X11
file /usr/lib/../X11R7/lib/X11
ls /usr/lib/../X11R7/lib/X11
ls /usr/lib/../X11R7/lib/xorg
ls /usr/lib/../X11R7/lib/xorg/modules
ls /usr/lib/../X11R7/lib/xorg/modules/drivers
SPECVESA=`find -L /usr/lib -xdev -type f -name vesa_drv.so | head -n1`
if [ "$SPECVESA" ]; then  DRVRSPATH=`dirname $SPECVESA`; DRVRCURR=`grep '#card0driver' /etc/X11/xorg.conf | grep -vE '^[[:blank:]]*#' | tail -n1 | cut -f 2 -d '"'`; if [ "$DRVRCURR" ]; then ls -1 $DRVRSPATH/* | grep -w "${DRVRCURR}_drv.so"; fi; fi
ls -1 $DRVRSPATH/* | grep -w "$DRVRCURR[-_]drv.*"
ls -1 $DRVRSPATH/* | grep -w "/$DRVRCURR[-_]drv.*"
ls -1 $DRVRSPATH/* | grep  "$DRVRCURR[-_]drv.*"
ls -1 $DRVRSPATH/* | grep  "/$DRVRCURR[-_]drv.*"
ls -1 $DRVRSPATH/* | grep  -w "/$DRVRCURR[-_]drv.*"
ls -1 $DRVRSPATH/* | grep  -w "\/$DRVRCURR[-_]drv.*"
ls -1 $DRVRSPATH/* | grep  -w "\\/$DRVRCURR[-_]drv.*"
ls -1 $DRVRSPATH/* | grep  -w '/'"$DRVRCURR[-_]drv.*"
ls -1 $DRVRSPATH/* | grep  -w '/'"$DRVRCURR[-_]drv"
ls -1 $DRVRSPATH/* | grep  -w '/'"$DRVRCURR[-_]drv.so"
ls -1 $DRVRSPATH/* | grep  -w "$DRVRCURR[-_]drv.so"

Tue Dec 23 14:17:09 GMT+1 2014

man xrdb
man xrbd
find /usr -name "*xrbd*"
find /usr -name "*xrdb*"
geany .Xdefaults
xrdb
xrdb --help
xrdb -n
sed -n 43p *
for i in * ;do sed -n 43p $i;done
for i in * ;do echo ;echo $i;sed -n 43p $i;done
find /usr -iname "Xdefaults"
find /usr -iname ".Xdefaults"
find /usr -iname ".Xdefaults*"
find /usr -iname "Xdefaults*"
./replace_commit_files.sh 
git commit
git commit 2>&1| while read f;do [ -e "$f" ] || continue;echo $f;done
git commit 2>&1| while read f;do [ -e "$f" ] || continue;echo $f;git add $f;done
git commit -m '/usr/local/lib/X11/themes/Original/ : Several _mntdro48.png and _mntdrw48.png added.'

Tue Dec 23 17:37:22 GMT+1 2014


Tue Dec 23 19:36:36 GMT+1 2014

SPECVESA=`find -L /usr/lib /usr/X11/lib -xdev -type f -name vesa_drv.so | head -n1`
DRVRSPATH=`dirname $SPECVESA`
DRVRCURR=`grep 'Driver .* #card0driver' /etc/X11/xorg.conf | grep -vE '^[[:blank:]]*#' | head -n1 | cut -f 2 -d '"'`
ls -1 $DRVRSPATH/* | grep -w "${DRVRCURR}_drv"
readlink --help
cut -c 1-4 /etc/mousedevice
readlink -qs /usr/bin/X
readlink -s /usr/bin/X
readlink -q /usr/bin/X
ash

Tue Dec 23 21:20:14 GMT+1 2014

help deallocvt
deallocvt --help
openvt --help
freevt
busybox | grep vt
chvt --help
ps -A -o tty,args

Wed Dec 24 09:29:25 GMT+1 2014

busybox ps -o tty,args
busybox ps -o tty,args|cut -f2 -d','
busybox ps -o tty,args|awk -F'[ ,]' '{print $2}'
ash
ps | grep acpi
/etc/init.d/DRIVER/bb_mkbd_acpid.init 
/etc/init.d/DRIVER/bb_mkbd_acpid.init start
./replace_commit_files.sh 
find -name openvt.c
fgconsole
tty
chmod +x /root/get_fgconsole.sh 
/root/get_fgconsole.sh
exec /root/get_fgconsole.sh
./replace_commit_files.sh 
./busybox
file ./busybox
pwd
ldd pwd
busybox-slacko5571 
./replace_commit_files.sh 
grep grab *
xsetpointer -help
man xsetpointer
xsetpointer -l
man yaf-splash
man xmessgae
man xmessage
man xrefresh
man cvt
cvt
cvt 1920 1080
man xmodmap
man xlib
xrender -help
xrandr -help
xset -help
xwininfo --help
xmessage -help
yaf-splash -help
yaf-splash -geometry 1920x1020 -text "HELLO"
yaf-splash -geometry 1920x1020 -transparent -text "HELLO"
yaf-splash -geometry 1920x1020  -text "HELLO"
XIGrabEnter=1 xmessage "HELLO"
XIGrabFocusIn=1 xmessage "HELLO"
XIGrabFocusIn=:0 xmessage "HELLO"
xmessage -buttons "OK:100,NO" -default "NO" "HELLO"
xmessage -buttons "OK:100,NO" -default "NO" "HELLO";echo $?
xmessage -maxwidth 1920 "HELLO"
xmessage -maxWidth 1920 "HELLO"
xmessage -geometry 1920+1020 "HELLO"
xmessage -geometry 0x0+1920+1020 "HELLO"
xmessage -geometry 1x1+1920+1020 "HELLO"
xmessage -geometry 1920x1020 "HELLO"
find -iname "*grab*"
geany /usr/bin/wmexit
man /usr/X11R6/man/man3/XF86MiscSetMouseSettings.3x
geany /etc/rc.d/f4puppy5
source /etc/rc.d/f4puppy5
_get_screen_resolution
man yaf-splash
yaf-splash --help
yaf-splash -geometry 1920x1080 -text "SOME YAF SPLASH TEXT"
yaf-splash -geometry 1920x1080 -text "SOME yet another fine YAF SPLASH TEXT"
yaf-splash -geometry 1920x1080 -transparent -text "SOME yet another fine YAF SPLASH TEXT"
yaf-splash -transparent -text "SOME yet another fine YAF SPLASH TEXT"
yaf-splash  -text "SOME yet another fine YAF SPLASH TEXT"
yaf-splash  -text "SOME yet another fine YAF SPLASH TEXT" &
exec yaf-splash  -text "SOME yet another fine YAF SPLASH TEXT" &
ls /etc/event*
geany /etc/event*
mount | grep -E '^/dev/loop[0-9]*'
mount | grep -E '^/dev/loop[0-9p]*'
mount | grep -E '^/dev/loop[0-9p]+'
M_LOOP=`mount | grep -E '^/dev/loop[0-9p]+ ' |grep -v '/initrd'`
M_LOOP=`echo $M_LOOP |rev|sed 's! )!\n)!g'|rev`
M_LOOP=`echo "$M_LOOP" |grep -o ' on .\+ type ' |sed -r 's!( on )(.*)( type )!\2!'`
echo "$M_LOOP"
yaf-splash -help
 yaf-splash -display :0 -margin 2 -bg thistle -bw 0 -placement top -font "9x15B" -outline 0 -text "Welcome! Click here for getting-started information" &
ash
./replace_commit_files.sh 
git pull /mnt/sdb19/SRC/F3p5/WOOF/GitHub.d/KarlGodt_WoofFork.Push.d/
mount -o remount,ro /dev/sda2 /mnt/sda2
fuser -m /mnt/sda2
fuser -c /dev/sda2
losetup
losetup -a
yaf-splash -bg green -text "Exiting to prompt..." &
./replace_commit_files.sh 
geany `which plogout`
geany /usr/sbin/exitprompt
chkmap
chmod +x /bin/chkmap
chkmap de
file /usr/share/kbd/keymaps/i386/qwertz/de.map
geany /usr/share/kbd/keymaps/i386/qwertz/de.map
find /usr -name "de.gz"
find /usr -wholename "*map*"
find /usr/share -wholename "*map*"
find /usr/bin -wholename "*map*"
find /usr/sbin -wholename "*map*"
man makemap
git pull 
git pull /mnt/sdb19/SRC/F3p5/WOOF/GitHub.d/KarlGodt_WoofFork.Push.d/

Thu Dec 25 11:18:11 GMT+1 2014

patch -p1 <grub_0.97-47lenny2.diff 
mv grub-0.97 grub-0.97-lenny
tar xzf grub-0.97-lenny.tar.gz grub-0.97-lenny
tar czf grub-0.97-lenny.tar.gz grub-0.97-lenny
patch -p1 <grub_0.97-16.1~bpo.1.diff 
tar czf grub-0.97-Sarge-bpo.tar.gz grub-0.97-Sarge-bpo
patch -p1 <grub_0.97-27etch1.diff 
tar czf grub-0.97-etch.tar.gz grub-0.97-etch
patch -p1<grub_0.97-64.diff 
tar czf grub-0.97-squeeze.tar.gz grub-0.97-squeeze
patch -p1 <grub_0.97-67.diff 
tar czf grub-0.97-Wheezy.tar.gz grub-0.97-Wheezy/
patch -p1 <grub_0.97-29ubuntu60.diff 
patch -p1 <grub_0.97-29ubuntu60.10.04.2.diff 
tar -czf grub-0.97-lucid.tar.gz grub-0.97-lucid 
tar -czf grub-0.97-lucid-bpo.tar.gz grub-0.97-lucid-bpo 
patch -p1 <grub_0.97-29ubuntu66.diff 
tar -czf grub-0.97-Precise.tar.gz grub-0.97-Precise/
./Apply_patches 
type -a patch
./Apply_patches 
pwd
cd ..
ls
cd grub-0.97-156.4.src/
tar czf grub-0.97-Suse11.1-156.4.tar.gz grub-0.97-Suse11.1-156.4/
grep gfxmenu *
autoreconf --force --install
EXTRACFLAGS=' -fno-stack-protector -fno-strict-aliasing -minline-all-stringops -fno-asynchronous-unwind-tables -fno-unwind-tables'
CFLAGS="$RPM_OPT_FLAGS -Os -DNDEBUG -W -Wall -Wpointer-arith $EXTRACFLAGS" ./configure   --prefix=/usr --infodir=%{_infodir} --mandir=%{_mandir} --datadir=/usr/lib   --disable-auto-linux-mem-opt --enable-diskless   --enable-{3c50{3,7},3c5{0,2}9,3c595,3c90x,cs89x0,davicom,depca,eepro{,100},epic100}   --enable-{exos205,lance,ne,ne2100,ni{50,52,65}00,ns8390}   --enable-{rtl8139,sk-g16,smc9000,tiara,tulip,via-rhine,w89c840,wd}
CFLAGS="$RPM_OPT_FLAGS -Os -DNDEBUG -W -Wall -Wpointer-arith $EXTRACFLAGS" ./configure   --prefix=/usr --infodir=/usr/share/info --mandir=/usr/share/man --datadir=/usr/lib   --disable-auto-linux-mem-opt --enable-diskless   --enable-{3c50{3,7},3c5{0,2}9,3c595,3c90x,cs89x0,davicom,depca,eepro{,100},epic100}   --enable-{exos205,lance,ne,ne2100,ni{50,52,65}00,ns8390}   --enable-{rtl8139,sk-g16,smc9000,tiara,tulip,via-rhine,w89c840,wd}
make.tgl
make
make clean
make.tgl
CFLAGS="$RPM_OPT_FLAGS -Os -DNDEBUG -W -Wall -Wpointer-arith $EXTRACFLAGS" ./configure   --prefix=`pwd`/_install_diskless  --disable-auto-linux-mem-opt --enable-diskless   --enable-{3c50{3,7},3c5{0,2}9,3c595,3c90x,cs89x0,davicom,depca,eepro{,100},epic100}   --enable-{exos205,lance,ne,ne2100,ni{50,52,65}00,ns8390}   --enable-{rtl8139,sk-g16,smc9000,tiara,tulip,via-rhine,w89c840,wd}
make.tgl
make
make.tgl
make install
make clean
CFLAGS="$RPM_OPT_FLAGS -Os -DNDEBUG -W -Wall -Wpointer-arith $EXTRACFLAGS" ./configure   --prefix=/usr --infodir=%{_infodir} --mandir=%{_mandir} --datadir=/usr/lib   --disable-auto-linux-mem-opt --disable-ffs --disable-ufs2
CFLAGS="$RPM_OPT_FLAGS -Os -DNDEBUG -W -Wall -Wpointer-arith $EXTRACFLAGS" ./configure   --prefix=`pwd`/_install  --disable-auto-linux-mem-opt --disable-ffs --disable-ufs2
echo $EXTRACFLAGS 
make.tgl
make
make.tgl
make install
uname -r
  
uname -r
_mouse_message(){ yaf-splash -bg yellow $mmsgGEOMETRY -fg black $genYAFOPS -timeout $MOUSEMSG_TT -text "---------------------------------------------------------
| OK, so if your mouse receiver is                      |
| attached to a keyboard integrated hub,                |
|                                                       |
| and you don't want to wake the system by mouse moves, |
|                                                       |
| or light up any LEDs on the keyboard dito,            |
|                                                       |
| then you have $MOUSEMSG_TT seconds from now,                    |
| to switch off the mouse...                            |
|                                                       |
| Note: Unmounting of partitions may still go on        |
|       in the background .                             |
| When switched off mouse, press any keyboard key ...   |
---------------------------------------------------------"; }
source /etc/rc.d/f4puppy5
rootSCREEN_XY=`_get_screen_resolution`    || rootSCREEN_XY=800x600+0+0
 rootCENTER_X=$((${rootSCREEN_XY%%x*}/2))
 _Y_=$(echo "$rootSCREEN_XY" | awk -F'[x+]' '{print $2}')
 rootCENTER_Y=$((_Y_ / 2))
MOUSEMSG_TT=30
genYAFOPS='-outline 0'
_mouse_message
     _get_screen_resolution
mmsgGEOMETRY="-geometry $rootSCREEN_XY"
_mouse_message
                                      
_mouse_message
         kkkll
sleep 10 && _mouse_message
fbsplsh --help
fbsplash --help
test -f /boot/grub/boot-splash.ppm && fbsplash -s /boot/grub/boot-splash.ppm
test -f /boot/grub/boot-splash.ppm;echo $?
fbsplash
test -f /boot/grub/boot-splash.ppm && fbsplash -s /boot/grub/boot-splash.ppm -d `tty`
tty
test -f /boot/grub/boot-splash.ppm && fbsplash -s /boot/grub/boot-splash.ppm -d /dev/pts/3
geany /sbin/init
help
help suspend
