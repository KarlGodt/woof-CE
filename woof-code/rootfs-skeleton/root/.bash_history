chroot . /bin/sh
PSUBDIR=/PUPPY_SFS/LHP-503
echo "$PSUBDIR" | tr -s '/'
MAXD=`echo "$PSUBDIR" | tr -s '/'`
echo "$MAXD"
MAXD=`echo "$MAXD" | sed 's%^/*%%;s%/*$%%'`
echo "$MAXD"
MAXD="/${MAXD}/"
echo "$MAXD"
MAXD=`echo "$MAXD" | grep -o '/' | wc -L`
echo "$MAXD"
MAXD=`echo "$MAXD" | grep -o '/' | wc -l`
echo "$MAXD"
MAXDS=`echo "$PSUBDIR" | tr -s '/'`
MAXDS=`echo "$MAXDS" | sed 's%^/*%%;s%/*$%%'`
MAXDS="/${MAXDS}/"
echo "$MAXDS" | grep -o '/' | wc -l
killall sakura

Sun Mar 22 21:07:41 GMT+1 2015

e2fsck -v -n /mnt/sda1/PUPPY_SFS/tahr-6.0-CE/initrd.ext2
e2fsck -v /mnt/sda1/PUPPY_SFS/tahr-6.0-CE/initrd.ext2
e2fsck -v -f /mnt/sda1/PUPPY_SFS/tahr-6.0-CE/initrd.ext2
mkfs.edxt2 --version
mkfs.ext2 --version
mke2fs
mke2fs --version
mke2fs -V
cd /
while read dev mnt fs mops n m;  do  sleep 1;   case "$mnt" in   *oldstyle_initramdisk*)   umount -lr "$mnt";   ;;   esac;  done<./proc/mounts
ffff
ff
while read dev mnt fs mops n m;  do  sleep 1;  echo $mnt;  done<./proc/mounts
cat /proc/mounts

Sun Mar 22 22:20:32 GMT+1 2015

cpio -id <initrd
dd if=/dev/zero of=initrd.ext2 bs=1024 count=13000
mkfs.ext2 initrd.ext2
fsck initrd.ext2
e2fsck initrd.ext2
e2fsck -f initrd.ext2
mount
dmesg

Mon Mar 23 10:56:38 GMT+1 2015

cp -au . /mnt/sda1/PUPPY_SFS/LHpup443/unsquash/spup-443/usr/share/locale
grep ^Failed spup-443.out.txt 
grep ^Failed spup-443.out.txt | while read f t w FILE rest; do echo $FILE; done
grep ^Failed spup-443.out.txt | while read f t w FILE rest; do echo "$FILE" >/dev/null; test -e "$FILE" || echo "$FILE";done
grep ^Failed spup-443.out.txt | while read f t w FILE rest; do echo "$FILE" >/dev/null; FILE=${FILE%,};test -e "$FILE" || echo "$FILE";done
./busybox 
mksquashfs spup-443/ spup-443.sfs
df
mksquashfs --help
man unsquashfs
unsquashfs --help
unsquashfs -s 0spup-443.sfs 
unsquashfs -s 0spup-443.sfs >0spup-443.sfs.txt
unsquashfs -ll 0spup-443.sfs >>0spup-443.sfs.txt
unsquashfs //help
unsquashfs --help
unsquashfs -s spup-443.sfs 
pwd
unsquashfs -d spup-443 spup-443.sfs 
rm spup-443/
rm -r spup-443/
unsquashfs -n -d spup-443 spup-443.sfs >>spup-443.out.txt 2>&1
/mnt/0spup-443.sfs/bin/busybox
info chroot
info pivot_root
man 2 pivot_root
man chroot
man pivot_root

Tue Mar 24 01:05:37 GMT+1 2015

mount
cd /mnt/sdb19/SRC/F3p5/WOOF/GitHub.d/KarlGodt_WoofFork.Push.d
ls /mnt
mount /dev/sdb5
mkdir /mnt/sdb19
cd /mnt/sdb19/SRC/F3p5/WOOF/GitHub.d/KarlGodt_WoofFork.Push.d
ls
git commit
echo $PATH
export PATH=/usr/SVC/bin:$PATH
git commit
git add woof-code/boot/initrd-tree0/init
git commit -m "initrd-tree0/init: Added some code to make old-style initrd ext2 image possible.
This works in a combination of pivot_root and chroot .
Also code added to take care for accidental full install boot ( not tested ).
Some code cleanups and unneeded stability improvements."
git branch
git push krg Fox3-Dell755
git push MSkrg Fox3-Dell755
exit
mount /dev/sdb19
mount
cd /mnt/sdb19/SRC/F3p5/WOOF/GitHub.d/KarlGodt_WoofFork.Push.d
git commit
export PATH=/usr/SVC/bin:$PATH
git commit
git add woof-code/boot/initrd-tree0/init
git commit -m 'initrd-tree0/init: Code cleanups, and one BUGFIX mounting rootfs'
git branch
git push krg Fox3-Dell755
exit

Fri Mar 27 03:35:42 GMT+1 2015

geany /usr/local/bin/drive_all
geany /mnt/sdb6/usr/sbin/filemnt
man hdparm
opticalCNT=1; CDTYPE=""; DVDTYPE=""; CDBURNERTYPE=""
OPTICALS=`grep '^drive name:' /proc/sys/dev/cdrom/info | grep -o -E 'scd.*|sr.*|hd.*'`
[ -L /dev/cdrom ] &&  CDTYPE=`readlink /dev/cdrom | cut -f 3 -d '/'`
[ -L /dev/dvd ]   && DVDTYPE=`readlink /dev/dvd   | cut -f 3 -d '/'`
[ -f /etc/cdburnerdevice ] && CDBURNERTYPE=`cat /etc/cdburnerdevice`
[ "$CDTYPE" -a "`echo "$OPTICALS" | grep "$CDTYPE"`" = "" ]  && CDTYPE=""  #no longer exists.
[ "$DVDTYPE" -a "`echo "$OPTICALS" | grep "$DVDTYPE"`" = "" ] && DVDTYPE="" #no longer exists.
[ "$CDBURNERTYPE" -a "`echo "$OPTICALS" | grep "$CDBURNERTYPE"`" = "" ] && CDBURNERTYPE="" #no longer exists.
for oneOPTICAL in $OPTICALS; do  oneNUM=`echo -n "$oneOPTICAL" | cut -c 3`;  [ "$CDTYPE" = "" ]  && CDTYPE="$oneOPTICAL";  [ "$CDTYPE" -a "$DVDTYPE" ]  && CDTYPE="$oneOPTICAL"  [ "$DVDTYPE" = "" ] && [ "`grep '^Can read DVD' /proc/sys/dev/cdrom/info | head -n 1 | grep -o '[01]' | tr -d '\n' | sed -e 's/[^01]//g' | cut -c $opticalCNT`" = "1" ] && DVDTYPE="$oneOPTICAL";  [ "$CDBURNERTYPE" = "" ] && [ "`grep '^Can write CD' /proc/sys/dev/cdrom/info | head -n 1 | grep -o '[01]' | tr -d '\n' | sed -e 's/[^01]//g' | cut -c $opticalCNT`" = "1" ] && CDBURNERTYPE="$oneOPTICAL"   opticalCNT=$((opticalCNT+1)); done
rm -f /dev/cdrom; rm -f /dev/dvd; rm -f /etc/cdburnerdevice
[ "$CDTYPE" ]  && ln $VERB -sf /dev/$CDTYPE  /dev/cdrom
[ "$DVDTYPE" ] && ln $VERB -sf /dev/$DVDTYPE /dev/dvd
[ "$CDBURNERTYPE" ] && echo "$CDBURNERTYPE" >/etc/cdburnerdevice
[ "$DVDTYPE" ] && hdparm -d1 /dev/$DVDTYPE
opticalCNT=1; CDTYPE=""; DVDTYPE=""; CDBURNERTYPE=""
OPTICALS=`grep '^drive name:' /proc/sys/dev/cdrom/info | grep -o -E 'scd.*|sr.*|hd.*'`
[ -L /dev/cdrom ] &&  CDTYPE=`readlink /dev/cdrom | cut -f 3 -d '/'`
[ -L /dev/dvd ]   && DVDTYPE=`readlink /dev/dvd   | cut -f 3 -d '/'`
[ -f /etc/cdburnerdevice ] && CDBURNERTYPE=`cat /etc/cdburnerdevice`
[ "`echo "$OPTICALS" | grep "$CDTYPE"`" = "" ]  && CDTYPE=""  #no longer exists.
[ "`echo "$OPTICALS" | grep "$DVDTYPE"`" = "" ] && DVDTYPE="" #no longer exists.
[ "`echo "$OPTICALS" | grep "$CDBURNERTYPE"`" = "" ] && CDBURNERTYPE="" #no longer exists.
for oneOPTICAL in $OPTICALS; do  oneNUM=`echo -n "$oneOPTICAL" | cut -c 3`;  [ "$CDTYPE" = "" ]  && CDTYPE="$oneOPTICAL"  [ "$DVDTYPE" = "" ] && [ "`grep '^Can read DVD' /proc/sys/dev/cdrom/info | head -n 1 | grep -o '[01]' | tr -d '\n' | sed -e 's/[^01]//g' | cut -c $opticalCNT`" = "1" ] && DVDTYPE="$oneOPTICAL";  [ "$CDBURNERTYPE" = "" ] && [ "`grep '^Can write CD' /proc/sys/dev/cdrom/info | head -n 1 | grep -o '[01]' | tr -d '\n' | sed -e 's/[^01]//g' | cut -c $opticalCNT`" = "1" ] && CDBURNERTYPE="$oneOPTICAL"   opticalCNT=$((opticalCNT+1)); done
rm -f /dev/cdrom; rm -f /dev/dvd; rm -f /etc/cdburnerdevice
[ "$CDTYPE" ]  && ln $VERB -sf /dev/$CDTYPE  /dev/cdrom
[ "$DVDTYPE" ] && ln $VERB -sf /dev/$DVDTYPE /dev/dvd
[ "$CDBURNERTYPE" ] && echo "$CDBURNERTYPE" >/etc/cdburnerdevice
[ "$DVDTYPE" ] && hdparm -d1 /dev/$DVDTYPE 
grep '^Can read DVD' /proc/sys/dev/cdrom/info | head -n 1 | grep -o '[01]' | sed -e 's/[^01]//g'
grep '^Can read DVD' /proc/sys/dev/cdrom/info | head -n 1 | grep -o '[01]'
grep '^Can read DVD' /proc/sys/dev/cdrom/info | head -n 1
grep '^Can read DVD' /proc/sys/dev/cdrom/info
grep '.*' /proc/sys/dev/cdrom/info
grep '^Can read DVD' /proc/sys/dev/cdrom/info | head -n 1 | grep -o '[01]' | sed -e 's/[^01]//g' | cut -c 1
grep '^Can read DVD' /proc/sys/dev/cdrom/info | head -n 1 | grep -o '[01]' | sed -e 's/[^01]//g' | cut -c 2
grep '^Can read DVD' /proc/sys/dev/cdrom/info | head -n 1 | grep -o '[01]' | sed -e 's/[^01]//g' | cut -c 3
grep '^Can read DVD' /proc/sys/dev/cdrom/info | head -n 1 | grep -o '[01]' | tr -d '\n' | sed -e 's/[^01]//g' | cut -c 3
grep '^Can read DVD' /proc/sys/dev/cdrom/info | head -n 1 | grep -o '[01]' | tr -d '\n' | sed -e 's/[^01]//g' | cut -c 2
grep '^Can read DVD' /proc/sys/dev/cdrom/info | head -n 1 | grep -o '[01]' | tr -d '\n' | sed -e 's/[^01]//g' | cut -c 1
grep '^Can read DVD' /proc/sys/dev/cdrom/info | head -n 1 | grep -o '[01]' | head -n1 | sed -e 's/[^01]//g' | cut -c 1
grep '^Can read DVD' /proc/sys/dev/cdrom/info | head -n 1 | grep -o '[01]' | head -n1 | sed -e 's/[^01]//g' | cut -c 2
rm /devcdrom
rm /dev/cdrom
rm /dev/dvd
ls -l /dev/cdrom
ls -l /dev/dvd
cat /etc/cdburnerdevice 
ls -l /etc/cdburnerdevice
grep '^drive name:' /proc/sys/dev/cdrom/info | grep -o -E 'scd.*|sr.*|hd.*'
grep '^drive name:' /proc/sys/dev/cdrom/info | grep -o -E 'scd.*|sr.*|hd.*' | grep ""
ls -l /dev/dvd
ls -l /dev/cdrom
ls -l /dev/cdrom
ls -l /dev/dvd
ln -s sr0 /dev/sr0
ln -s sr0 /dev/dvd
gxine
cddetect
cddetect --help
eventmanager
./replace_commit_files.sh 
unrar --help
unrar --version
type -a unrar
find /usr -name "libgcc*"
find /usr -name "libbfd*"

Mon Mar 30 01:39:05 GMT+1 2015

grep $Q " $*/dev " /proc/mounts
echo "$*"
grep $Q " /dev " /proc/mounts
grep " /dev " /proc/mounts
grep " $*/dev " /proc/mounts
rmdir initrd*
losetup
losetup -a
mount

Mon Mar 30 22:24:07 GMT+1 2015

ls -l /dev/cdrom
ls -l /dev/dvd
disktype /dev/sr0
mount /dev/sr0
umount /dev/sr0
pidof ROX-Filer
fixitup
mencoder VID_20150330_225222.3gp -o VID_20150330_225222-90.mp4 -vf rotate=2 -oac copy -ovc lavc -lavcopts vcodec=mpeg4
mencoder VID_20150330_225222.3gp -o VID_20150330_225222-90.mp4 -vf rotate=2  -ovc lavc -lavcopts vcodec=mpeg4
mencoder VID_20150330_225222.3gp -o VID_20150330_225222-90.mp4 -vf rotate=2  -oac mp4 -ovc lavc -lavcopts vcodec=mpeg4
mencoder VID_20150330_225222.3gp -o VID_20150330_225222-90.mp4 -vf rotate=2  -oac lavc -ovc lavc -lavcopts vcodec=mpeg4
mencoder VID_20150330_225222-90.mp4 -o VID_20150330_225222-180.mp4 -vf rotate=2  -oac lavc -ovc lavc -lavcopts vcodec=mpeg4
mencoder VID_20150330_225222.3gp -o VID_20150330_225222-90.mp4 -vf rotate=2  -oac pcm -ovc raw -lavcopts vcodec=mpeg4
mencoder VID_20150330_225222-90.mp4 -o VID_20150330_225222-180.mp4 -vf rotate=2  -oac pcm -ovc raw -lavcopts vcodec=mpeg4
mencoder VID_20150330_225222.3gp -o VID_20150330_225222-90.mp4 -vf rotate=2  -oac faad -ovc copy -lavcopts vcodec=mpeg4
mencoder VID_20150330_225222.3gp -o VID_20150330_225222-90.mp4 -vf rotate=2  -oac faac -ovc copy -lavcopts vcodec=mpeg4
mencoder VID_20150330_225222.3gp -o VID_20150330_225222-90.mp4 -vf rotate=2 
mencoder VID_20150330_225222.3gp -o VID_20150330_225222-90.mp4 -nosound -vf rotate=2 
mencoder VID_20150330_225222.3gp -o VID_20150330_225222-90.mp4 -nosound -vf rotate=2 -ovc lacv
mencoder VID_20150330_225222.3gp -o VID_20150330_225222-90.mp4 -nosound -vf rotate=2 -ovc lavc
mencoder VID_20150330_225222.3gp -o VID_20150330_225222-90.mp4 -nosound -vf rotate=2,spp=0 -ovc lavc
mencoder VID_20150330_225222.3gp -o VID_20150330_225222-90.mp4 -nosound -vf rotate=2,spp=6 -ovc lavc
mencoder VID_20150330_225222.3gp -o VID_20150330_225222-90.mp4 -nosound -vf rotate=2,uspp=6 -ovc lavc
mencoder VID_20150330_225222.3gp -o VID_20150330_225222-90.mp4 -nosound -vf rotate=2,uspp=6 -ovc lavc -lavdopts idct=99
mencoder VID_20150330_225222.3gp -o VID_20150330_225222-90.mp4 -nosound -vf rotate=2,lavc=128 -ovc lavc
mencoder VID_20150330_225222.3gp -o VID_20150330_225222-90.mp4 -nosound -vf rotate=2,lavc=64 -ovc lavc
mencoder VID_20150330_225222.3gp -o VID_20150330_225222-90.mp4 -nosound -vf rotate=2,lavc=33 -ovc lavc
mencoder VID_20150330_225222.3gp -o VID_20150330_225222-90.mp4 -nosound -vf rotate=2,lavc=32 -ovc lavc
mencoder VID_20150330_225222.3gp -o VID_20150330_225222-90.mp4 -nosound -vf rotate=2,lavc=24 -ovc lavc
mencoder VID_20150330_225222.3gp -o VID_20150330_225222-90.mp4 -nosound -vf rotate=2,lavc=1 -ovc lavc
mencoder VID_20150330_225222.3gp -o VID_20150330_225222-90.mp4 -nosound -vf rotate=2 -ovc lavc -faac quality=100
mencoder VID_20150330_225222.3gp -o VID_20150330_225222-90.mp4 -nosound -vf rotate=2 -ovc lavc -lavcopts format=YVU9
mencoder VID_20150330_225222.3gp -o VID_20150330_225222-90.mp4 -nosound -vf rotate=2 -ovc lavc -lavcopts format=422P
mencoder VID_20150330_225222.3gp -o VID_20150330_225222-90.mp4 -nosound -vf rotate=2 -ovc lavc -lavcopts
mencoder VID_20150330_225222.3gp -o VID_20150330_225222-90.avi -nosound -vf rotate=2 -ovc copy
mencoder VID_20150330_225222.3gp -o VID_20150330_225222-90.avi -nosound -vf rotate=2 -ovc lavc
mencoder VID_20150330_225222.3gp -o VID_20150330_225222-90.avi -nosound -vf rotate=2 -ovc vfw
probedisk
mount /dev/sdc1
umount /mnt/sdc1
mount /dev/sdc1
grep '^Can read DVD' /proc/sys/dev/cdrom/info | head -n 1 | grep -o '[01]' | tr -d '\n' | sed -e 's/[^01]//g' | cut -c $opticalCNT
opticalCNT=1
grep '^Can read DVD' /proc/sys/dev/cdrom/info | head -n 1 | grep -o '[01]' | tr -d '\n' | sed -e 's/[^01]//g' | cut -c $opticalCNT
grep '^Can read DVD' /proc/sys/dev/cdrom/info | head -n 1 | grep -o '[01]' | tr -d '\n' | sed -e 's/[^01]//g'
grep '^Can read DVD' /proc/sys/dev/cdrom/info | head -n 1 | grep -o '[01]' | tr -d '\n'
vlc /mnt/sda1/boot/VID_20150330_225222.3gp
mplayer -vo rotate=1 /mnt/sda1/boot/VID_20150330_225222.3gp
mplayer -vf rotate=1 /mnt/sda1/boot/VID_20150330_225222.3gp
mplayer -vf rotate=2 /mnt/sda1/boot/VID_20150330_225222.3gp
mplayer -vf rotate=3 /mnt/sda1/boot/VID_20150330_225222.3gp
mplayer -vf rotate=0 /mnt/sda1/boot/VID_20150330_225222.3gp
mplayer -vf rotate=4 /mnt/sda1/boot/VID_20150330_225222.3gp
mplayer -vf rotate=5 /mnt/sda1/boot/VID_20150330_225222.3gp
mplayer -vf rotate=0 -vf rotate=0 /mnt/sda1/boot/VID_20150330_225222.3gp
mplayer -vf rotate=0 -vf rotate=1 /mnt/sda1/boot/VID_20150330_225222.3gp
find /usr -wholepath "*/man/*/ffmpeg*"
find /usr -path "*/man/*/ffmpeg*"
man /usr/multimedia/share/man/man1/ffmpeg.1
mencoder
mencoder --help
mencoder -vc help
mencoder -ivc help
mencoder -ovc help
mplayer -of help
mencoder -of help
mencoder -ovc help
mencoder -oac help
mencoder -vc help
mencoder -ac help
man vlc
vlc-wrapper 
man cvlc
cvlc
cvlc --help
cvlc --help --advanced
cvlc -H
cvlc -H | grep rotate
cvlc -H | grep output
cvlc -H | grep file
mpg123
man mencoder
man ffmpeg
man xrandr
man mplayer
man bash
exit
. /etc/profile
/var/bin/man mount.aufs
which mount.aufs
type -a mount.aufs
file /sbin/mount.aufs
. /etc/profie
. /etc/profile
echo $PATH
/var/bin/man mount.cifs
exit
. /etc/profile
man aufs
busybox man aufs
man mount
busybox man mount
echo $PATH
/var/bin/man mount
exit
smartctl
which smartctl
file /usr/sbin/smartctl
ldd /usr/sbin/smartctl
echo $((4802/24))

Sat Apr 11 16:42:22 GMT+1 2015

man find
find /mnt/home -maxdepth 1
find -H /mnt/home -maxdepth 1
find -P /mnt/home -maxdepth 1
find -L /mnt/home -maxdepth 1
find -L /mnt/home/recLINKS/ -maxdepth 1
find -L /mnt/home/recLINKS/ -maxdepth 3
find -H /mnt/home/recLINKS/ -maxdepth 3
find -P /mnt/home/recLINKS/ -maxdepth 3
find -H /mnt/home/recLINKS/ -maxdepth 3
find /mnt/home/recLINKS/ -maxdepth 3
find /mnt/home/recLINKS/ -maxdepth 3 -type f
find -H /mnt/home/recLINKS/ -maxdepth 3 -type f
find -P /mnt/home/recLINKS/ -maxdepth 3 -type f
find -L /mnt/home/recLINKS/ -maxdepth 3 -type f
for i in `seq 1 1 10`; do mkdir d$i;done
for i in `seq 1 1 10`; do ln -s d$i l$i;done
for i in `seq 1 1 10`; do ln -s . d$i/l$i;done
for i in `seq 1 1 10`; do ln -s ../ d$i/L$i;done

Sat Apr 11 17:38:32 GMT+1 2015

fsck -n -f -v /dev/sda1
fsck -v /dev/sda1
mount -dev-sda1
mount /dev/sda1

Sat Apr 11 18:17:08 GMT+1 2015


Sat Apr 11 18:46:37 GMT+1 2015


Tue Apr 14 20:49:57 GMT+1 2015

dd if=/dev/zero of=initrh.ext2 bs=1024 count=220000
mkfs.ext2 initrh.ext2
mount
umount /dev/loop0
umount /dev/loop1

Wed Apr 15 14:45:04 GMT+1 2015

find . | cpio -o -H newc >/newinitrdRAMFS/initrh
gzip -9 /newinitrdRAMFS/initrh
rm macpup_550.sfs 
rmdir *
rm -rf /dev
rm -rf dev
rm -rf bin
rm -rf etc
rm -r *
pwd
mount /mnt/sda1/PUPPY_SFS/Slacko-5.5/initrd.ext2
mount
filemnt /mnt/sda1/PUPPY_SFS/Slacko-5.5/initrd.ext2
mdev -s
ls -l /dev/loop*
filemnt /mnt/sda1/PUPPY_SFS/Slacko-5.5/initrd.ext2
pwd
find . | cpio -o -H newc >/newinitrdRAMFS/initrh
gzip -9 /newinitrdRAMFS/initrh
rm -r *
find . | cpio -o -H newc >/newinitrdRAMFS/initrh
gzip -9 /newinitrdRAMFS/initrh
rm -r *
find . | cpio -o -H newc >/newinitrdRAMFS/initrh
gzip -9 /newinitrdRAMFS/initrh
rm -r *
find . | cpio -o -H newc >/newinitrdRAMFS/initrh
gzip -9 /newinitrdRAMFS/initrh
rm -r *
find . | cpio -o -H newc >/newinitrdRAMFS/initrh
gzip -9 /newinitrdRAMFS/initrh
rm -r *
find . | cpio -o -H newc >/newinitrdRAMFS/initrh
gzip -9 /newinitrdRAMFS/initrh
rm -r *
cd ..
mount
losetup
losetup -a
mount | grep ram
umount /initrdRAMFS
umount /newinitrdRAMFS/
umount /initrdRAMFS
umount /dev/loop7
umount /dev/loop6
umount /dev/loop5
umount /dev/loop4
umount /dev/loop3
umount /dev/loop2
umount /dev/loop1
umount /dev/loop0
mount -t ramfs ramfs /initrdRAMFS
mkdir /newinitrdRAMFS
mount -t ramfs ramfs /newinitrdRAMFS
pwd
info cpio
type -a cpio
/bin/cpio --version
/usr/local/bin/cpio --version
tzpe /a cpio
type -a cpio
file /bin/cpio
./configure
make
make install
which e4defrag
file /usr/sbin/e4defrag
fileinfo
fileinfo /mnt/home/PUPPY_SFS/Slacko-5.5/initrh.gz
which filefrag
which e2freefrag
exit

Thu Apr 16 11:56:50 GMT+1 2015

./git_pull_all_directories-02.sh 
ifconfig
ifconfig /a
ifconfig /-a
ifconfig -a
ifconfig eth1 up
dhcpcd -d -I ''
dhcpcd -d eth1
./git_pull_all_directories-03.sh 
killall mount
mount /dev/sde1
mount-FULL /dev/sde1 /mnt/sde1
mount
umount /mnt/sde2
umount /mnt/sde5
umount /mnt/sde6
umount /mnt/sde7
mount
umount /dev/sdb18
blkid /dev/sdd
blkid /dev/sdd7
blkid /dev/sdd6
disktype /dev/sdd7
quess_fstype /dev/sdd7
guess_fstype /dev/sdd7
guess_fstype-static /dev/sdd7
guess_fstype-orig /dev/sdd7
guess_fstype-dyn /dev/sdd7
guess_fstype-mut -noserv /dev/sdd7
guess_fstype-mut --noserv /dev/sdd7
pid of mut
pidof mut
mut --exit
guess_fstype-mut /dev/sdd7
mut --exit
probedisk
probepart
mount
umount /dev/loop9
umount /dev/loop8
umount /dev/loop7
umount /dev/loop6
umount /dev/loop5
umount /dev/loop4
umount /dev/loop3
mount
umount /dev/loop2
umount /dev/loop1
umount /dev/loop0
mount
umount /dev/sdd1
umount /dev/sdd5
umount /dev/sde2
mount
killall 'busybox mount'
ps | grep busybox
kill -9 13963
kill -15 13963
ps | grep busybox
pidof sync
top
killall -9 wmpoweroff
killall yaf-splash
wmpoweroff

Sun Apr 26 14:15:53 GMT+1 2015

geany /usr/bin/xwin
geany /usr/bin/xorgwizard
geany /usr/sbin/xorgwizard
git diff 57064a476fb62fb159377d2ea20b9359cac8cc08 c7869af1de258aedd8473a2b8cd924549c09c26e
git help mv
git diff c7869af1de258aedd8473a2b8cd924549c09c26e 30428e873b9ed1af98b80449a4c0f527e0c020d5
git diff 30428e873b9ed1af98b80449a4c0f527e0c020d5 4bb381eae7c392c330ba8f4ac18fe25406c199db
git commit --dry-run
git mv add_end.sh script-fixes.d/
for i in add*; do echo $i; done
for i in add*; do test -e script-fixes.d/$i && continue;echo $i; done
for i in add*; do test -e script-fixes.d/$i && continue;echo $i; git mv $i script-fixes.d/;done
for i in insert*; do test -e script-fixes.d/$i && continue;echo $i; git mv $i script-fixes.d/;done
for i in mark*; do test -e script-fixes.d/$i && continue;echo $i; git mv $i script-fixes.d/;done
for i in change*; do test -e script-fixes.d/$i && continue;echo $i; git mv $i script-fixes.d/;done
for i in check*; do test -e script-fixes.d/$i && continue;echo $i; git mv $i script-fixes.d/;done
for i in fix*; do test -e script-fixes.d/$i && continue;echo $i; git mv $i script-fixes.d/;done
for i in grep*; do test -e script-fixes.d/$i && continue;echo $i; git mv $i script-fixes.d/;done
for i in jump*; do test -e script-fixes.d/$i && continue;echo $i; git mv $i script-fixes.d/;done
for i in remove*; do test -e script-fixes.d/$i && continue;echo $i; git mv $i script-fixes.d/;done
for i in repair*; do test -e script-fixes.d/$i && continue;echo $i; git mv $i script-fixes.d/;done
git commit --dry-run
git commit
git commit --dry-run
git add woof-code/3builddistro
git commit -m "woof-code/3builddistro: Likely :space: cleanup by opening in geany."
git log
./update_files_from_running_system 
git log

Sun Apr 26 16:49:54 GMT+1 2015


Sun Apr 26 16:53:23 GMT+1 2015

fixitup
find /usr -iname "*greenapparatus*"
find /usr -iname "*Themes*"
pcur 
find -name "index.theme"
find -name "index.theme" -exec grep -i inherits {} \;
find -name "index.theme" -print -exec grep -i inherits {} \;
mkdir core
touch core/index.theme
find /usr -iname "*greenapparatus*"
find -name "*theme*"
killall ROX-Filer
rox -p /root/Choices/ROX-Filer/PuppyPin
killall ROX-Filer
rox -p /root/Choices/ROX-Filer/PuppyPin
killall ROX-Filer
rox -p /root/Choices/ROX-Filer/PuppyPin
geany
killall ROX-Filer
ps | grep -i ROX
killall ROX-Filer/ROX-Filer-2.10-MpF3-II-OK
killall ROX-Filer-2.10-MpF3-II-OK
rox -p /root/Choices/ROX-Filer/PuppyPin
grp -i greenapparatus *
grep -i greenapparatus *
grep -i greenapparatus libXcursor.*
grep -i green libXcursor.*
strace /usr/local/apps/ROX-Filer/ROX-Filer-2.10-MpF3-II-OK 
/usr/local/apps/ROX-Filer/ROX-Filer-2.10-MpF3-II-OK 
/usr/local/apps/ROX-Filer/ROX-Filer-2.10-MpF3-II-OK  -p /root/Choices/ROX-Filer/PuppyPin
killall ROX-Filer
/usr/local/apps/ROX-Filer/ROX-Filer-2.10-MpF3-II-OK  -p /root/Choices/ROX-Filer/PuppyPin
killall ROX-Filer
strace /usr/local/apps/ROX-Filer/ROX-Filer-2.10-MpF3-II-OK  -p /root/Choices/ROX-Filer/PuppyPin 2>ROXFILER.strace
geany ROXFILER.strace
killall ROX-Filer
pidof ROX-Filer
ps | grep -i rox
killall ROX-Filer-2.10-MpF3-II-OK
strace -s 128 /usr/local/apps/ROX-Filer/ROX-Filer-2.10-MpF3-II-OK  -p /root/Choices/ROX-Filer/PuppyPin 2>ROXFILER.strace
killall ROX-Filer-2.10-MpF3-II-OK
/usr/local/apps/ROX-Filer/ROX-Filer-2.10-MpF3-II-OK  -p /root/Choices/ROX-Filer/PuppyPin
strace --help
find /usr -name "libgtk*"
find /usr -name "libgtk*" -print -exec grep -i greenapparatus {} \;
find /usr -name "libgdk*"
find /usr -name "libgdk*" -print -exec grep -i greenappaatus {} \;
fdisk -l /dev/sde
mount /dev/sde1
killall acpid
busybox ?| head -na1
busybox | head -n1
top
uname -r
echo mem >/sys/power/state
df
df -k
df -m
./android
grep NEWSCHED DOT*
grep NEWSCHED /etc/modules/DOT*
find -name "*adb*"
find -name "*abd*"
pwd
cd ,,
cd ..
pwd
cd platform-tools
./adb --help
cd ../platform-tools-21/
./adb
make menuconfig
cat /proc/bus/input/devices
ls -l /dev/mouse
ls -l /dev/input
uname /r
uname -r
ls /sys/class/block
dmesg

Fri May 1 08:34:10 GMT+1 2015

history | grep mp3
cd /mnt/sdb19/
exit

Fri May 1 22:48:19 GMT+1 2015

chroot .
dmesg
lsusb
lsusb -v
dmesg | tail -n20
pwd
dmesg
dmesg|tail -n20
ls /sys/block
ls /sys/class/block
cat /proc/partitions
top
killall -9 fastboot
mount -o bind /proc ./proc
mount -o bind /sys ./sys
mount -o bind /dev ./dev
mount -o bind /mnt/sdb19 ./mnt/sdb19
pwd
wget http://www.mediafire.com/download/ioag3bc3fwc0kcv/Root+Motorola+Fire+XT.zip
ifconfig
ifconfig eth1 up
dhcpcd -d eth1
probepart
modprobe -v mmc_block
modprobe -l | grep mmc
modprobe -l | grep mtd
dmesg
modprobe -vr mei
dmesg
ls /sys/block
ls /sys/class/block
ls /sys/block
ls /sys/class/block
./adb devices
killall sdb
killall adb
./adb devices
pwd
exit
./adb devices
./adb version
uname -r
./adb devices -l
mount
mount --bind /mnt/sdb19 ./mnt/sdb19
chroot .
geany /bin/mount.sh
geany /usr/local/bin/drive_all
mount
exit
pup_event_frontend_d restart
exit
ps | grep acpi

Sat May 2 17:40:38 GMT+1 2015

gcc -o zergRush zergRush.c
gcc -o zergRush zergRush.c 2>gcc_zergRush.errs
./adb devices -l
./adb shell
unzip Superuser-3.0.7-efgh-signed.zip 
/etc/rc.d/runmbbservice
/etc/init.d/runmbbservice
/etc/init.d/runmbbservice start
geany /usr/local/bin/rox
grep socket_local_client /lib/*
grep socket_local_client /usr/lib/*
grep socket_local_client /usr/local/lib/*
gcc -o zergRush zergRush.c
wget https://android.googlesource.com/platform/system/core/+/master/include/private/android_filesystem_config.h
wget --no-check-certificate https://android.googlesource.com/platform/system/core/+/master/include/private/android_filesystem_config.h
gcc -o zergRush zergRush.c
grep dlopen /lib/*
gcc -o zergRush zergRush.c -lc
gcc -o zergRush zergRush.c -ldl
tar -c -f zergRush_headers.tar android_filesystem_capability.h android_filesystem_config.h sockets.h system_properties.h 
gzip -9 zergRush_headers.tar 
find -name "*.h"
unzip --help
type -a unzip
/usr/bin/unzip --help
cp -a Superuser.apk Superuser.zip
Unzip Superuser.zip
unzip Superuser.zip
grep -m3 -w stat /usr/include/*
probepart9 -d/dev/sde1
probepart9 -d /dev/sde1
file /sbin/probepart
geany /sbin/probepart9
probedisk
probepart -d/dev/sde
dosfsck --help
dosfsck -n -v /dev/sde1
dosfsck -v /dev/sde1
probepart -d/dev/sde1
probepart -d /dev/sde1
probepart -d/dev/sde1
geany /etc/rc.d/rc.shutdown
mount -o bind /dev ./dev
mount -o bind /sys ./sys
mount -o bind /proc ./proc
chroot .
mount -o bind /mnt/sdb19 ./mnt/sdb19
diff -qs /root/Downloads/Android/Superuser-3.0.7-efgh-signed.zip /mnt/sdf1/SU/Superuser-3.0.7-efgh-signed.zip
diff -qs /root/Downloads/Android/su-2.3.6.3-efgh-signed.zip /mnt/sdf1/SU/su-2.3.6.3-efgh-signed.zip 
mountMTP
mkdir /mntf/MTPdev/SD-Karte/SU
umountMTP
mountMTP
sync
umountMTP

Sun May 3 01:10:31 GMT+1 2015

find -name "blacklist.conf"
find -name "blacklist.conf" | while read f; do grep mei "$f" && continue; echo 'blacklist mei' >>"$f"; done
dd if=/dev/sdc of=archos_sdcard16GB bs=1024 count=$((1024*10))
hexedit archos_sdcard16GB 
dd if=/dev/sdc of=archos_sdcard16GB
echo $((2281/60))
file archos_sdcard16GB 
fdisk -l archos_sdcard16GB 
mount -o loop archos_sdcard16GB /mnt/XX
mount -t vfat -o loop archos_sdcard16GB /mnt/XX
mount
ls /mnt/XX
ls /mnt/
mount -t vfat -o loop archos_sdcard16GB /mnt/XX
losetup 
losetup -a
losetup -d /dev/loop0
mount -t vfat -o loop archos_sdcard16GB /mnt/XX
losetup -d /dev/loop0
losetup -a
mount
losetup /dev/loop1 archos_sdcard16GB 
losetup -a
mount /dev/loop1 /mnt/XX
losetup /dev/loop2 archos_sdcard16GB 
mount-FULL /dev/loop2 /mnt/XX
mkdir /mnt/XX
mount-FULL /dev/loop2 /mnt/XX
ls /mnt
ls /mnt/XX
mount-FULL -t vfat /dev/loop2 /mnt/XX
losetup /dev/loop3 archos_sdcard16GB 
losetup -a
mount-FULL -t vfat /dev/loop3 /mnt/XX
dmesg | tail
modprobe -vr mei
busybox losetup
mount
busybox losetup -d /dev/loop3
busybox losetup -d /dev/loop2
busybox losetup -d /dev/loop1
busybox losetup -d /dev/loop0
busybox losetup
busybox losetup -d /dev/loop0
file archos_sdcard16GB 
blkid archos_sdcard16GB 
disktype archos_sdcard16GB 
fdisk -l archos_sdcard16GB 
mkfs.vfat --help
type -a mkfs.vfat
file /bin/mkfs.vfat
rm /bin/mkfs.vfat
file /sbin/mkfs.vfat
rm /sbin/mkfs.vfat
file /usr/sbin/mkfs.vfat
which mkfs.vfat
mkfs.vfat
help hash 
hash
hash -r
hash
mkfs.vfat
mkfs.vfat -help
mkfs.vfat --help
hash
/usr/local/sbin/mkfs.vfat
/usr/local/sbin/mkfs.vfat -h
/usr/local/sbin/mkfs.vfat --help
file /usr/local/sbin/mkfs.vfat 
mkfs.vfat -v archos_sdcard16GB 
fdisk -l archos_sdcard16GB 
disktype archos_sdcard16GB 
guess_fstype archos_sdcard16GB 
blkid archos_sdcard16GB 
losetup
losetup -a
losetup /dev/loop3 archos_sdcard16GB 
losetup -a
mount-FULL -t vfat /dev/loop3 /mnt/XX
mount
testdisk archos_sdcard16GB 
testdisk-6.9 archos_sdcard16GB 
ls -s archos_sdcard16GB 
echo $((5766644/1024))
busybox mkdosfs
man mkdosfs
df
echo $((16000/15))
echo $(1066/60))
echo $((1066/60))
probepart2.09 -d/dev/sdc
./fastboot
./fastboot erase recovery
./fastboot flash recovery recovery.img
./fastboot reboot
./fastboot devices -l
./fastboot erase recovery
./fastboot flash recovery recovery.img
./fastboot reboot
./fastboot devices -l
unzip cm-7.2.0-u8150.zip 
wget http://www.mediafire.com/download/ioag3bc3fwc0kcv/Root+Motorola+Fire+XT.zip
/etc/init.d/runmbbservice restart
unzip HUAWEI-IDEOS-X3-Software_Upgrade.zip 
pwd
mountMTP
umountMTP
for i in "/mntf/MTPdev/NAND FLASH/DCIM/Camera"/IMG*; do echo "$i"; done
for i in "/mntf/MTPdev/NAND FLASH/DCIM/Camera"/IMG*; do echo "$i"; mv -f "$i" "/mntf/MTPdev/SD card/DCIM/Camera"/; sleep 0.2;done
for i in "/mntf/MTPdev/NAND FLASH/DCIM/Camera"/IMG*; do echo "$i"; cp -f "$i" "/mntf/MTPdev/SD card/DCIM/Camera"/; sleep 0.2;done
mount
./configure
make
make install
find /usr/local/lib -mmin -5
./configure
make
mount -o bind /dev ./dev
mount -o bind /proc ./proc
mount -o bind /sys ./sys
mount -o bind /mnt/sdb19 ./mnt/sdb19
./chroot_for_android.sh 
ls /mnt/sdb7/root/.android
ls /mnt/sdb7/root/.android/
touch /mnt/sdb7/root/.android/adbkey
touch /mnt/sdb7/root/.and*
ls -l /mnt/sdb7/root/.and*
geany /root/Choices/MIME-types/application_x-bittorrent
file /root/Choices/MIME-types/application_x-bittorrent
/root/Choices/MIME-types/application_x-bittorrent
ls -ls /root/Choices/MIME-types/application_x-bittorrent
/root/Choices/MIME-types/application_x-bittorrent --help
transmission --help
which transmission
ls -l s /usr/bin/transmission
ls -ls /usr/bin/transmission
ifconfig eth1 down
ifconfig eth1 up
killall dhcpcd
dhcpcd -d eth1
ifconfig eth1 down
killall dhcpcd
ifconfig eth1 up
dhcpcd -d eth1
top
find (proc -name "*dmi*"
find /proc -name "*dmi*"
find /sys -name "*dmi*"
ls /sys/class
ls /sys/class/dmi
ls /sys/class/dmi/id
cat /sys/class/dmi/id/bios_date
ls /sys/class/diag
ps | grep -v '\['
ifconfig -a
ifconfig
ls -l *
chgroup 
chgrp 
chgrp -v plugdev *
ls -l *
chgrp -v plugdev *
chmod 0666 *
ls -l *
addgroup
cat /etc/group
addgroup
addgroup -g 114 -S plugdev
cat /etc/group
dmesg | grep usb
pwd
dmesg
./adb devices -l
dmesg
ifconfig eth1 down
ifconfig eth1 UP
ifconfig eth1 up
dhcpcd -d eth1
killall dhcpcd
dhcpcd -d eth1
ifconfig eth1 down
ifconfig eth1 up
killall -1 dhcpcd
dhcpcd -d eth1
ifconfig eth1 down
killall -1 dhcpcd
ifconfig eth1 up
dhcpcd -d eth1
dmesg | tail
chroot .
mount
umount /mnt/sdb7/sys
umount /mnt/sdb7/proc
umount -l /mnt/sdb7/proc
umount -l /mnt/sdb7/dev
mount
umount /mnt/sdb7/mnt/sdb19
umount /mnt/sdb7
mount
umount -f /mnt/XX
umount -l /dev/sda9

Mon May 4 11:43:51 GMT+1 2015

make -f rules
git init
git remote add yaffs git://www.aleph1.co.uk/yaffs2
git pull yaffs
git branch -r
git branch -r | while read rb; do br=${rb#*/}; echo "$br"; done
git branch -r | while read rb; do br=${rb#*/}; echo "$br"; git checkout --track "$br";done
git branch -r | while read rb; do br=${rb#*/}; echo "$br"; git checkout "$br";done
git branch -r | while read rb; do br=${rb#*/}; echo "$br"; git checkout "$br";sleep 2;done
ls /mnt/sdd1
dd if=/dev/sdd1 of=/dev/null bs=1 count=512
mount /dev/sdd1
mount
fixitup
killall ROX-Filer
/etc/init.d/runmbbservice restart
grep '^EXTS=.*' /usr/local/lib/xarchive/wrappers/*.sh | cut -f2 -d'"' | tr ' ' '|' | tr -s '|'
grep '^EXTS=.*' /usr/local/lib/xarchive/wrappers/*.sh | cut -f2 -d'"' | tr '\n' ' |' | tr ' ' '|' | tr -s '|'
grep '^EXTS=.*' /usr/local/lib/xarchive/wrappers/*.sh | cut -f2 -d'"' | tr '\n' ' |' | tr ' ' '|' | tr -s '|' | sed 's%^|*%%;s%|*$%%'
grep '^EXTS=.*' /usr/local/lib/xarchive/wrappers/*.sh | cut -f2 -d'"' | sed 's% %\$|\\\\\.'
grep '^EXTS=.*' /usr/local/lib/xarchive/wrappers/*.sh | cut -f2 -d'"' | sed 's% %\$|\\\\\.%'
grep '^EXTS=.*' /usr/local/lib/xarchive/wrappers/*.sh | cut -f2 -d'"' | sed 's% %\$|\\\\\.%g
'
grep '^EXTS=.*' /usr/local/lib/xarchive/wrappers/*.sh | cut -f2 -d'"' | sed 's% %\$|\\\\\.%g' | sed 's%^%\\\\\.%;s%$%\$' | tr '\n' '|'
grep '^EXTS=.*' /usr/local/lib/xarchive/wrappers/*.sh | cut -f2 -d'"' | sed 's% %\$|\\\\\.%g' | sed 's%^%\\\\\.%;s%$%\$%' | tr '\n' '|'
unzip --help
type -a unzip
file /usr/bin/unzip
rm /bin/unzip
geany `which pupzip`
pupzip /root/Downloads/Android/ROMs/CyanMod-7.2.0/system/app/AndroidTerm.apk
probedisk
make -f adb.mk
make
./unyaffs
./unyaffs -d /root/Downloads/Android/ROMs/CWM-Huawei_IdeosX3/recovery.img
./unyaffs -v -d /root/Downloads/Android/ROMs/CWM-Huawei_IdeosX3/recovery.img
./unyaffs -v -d /root/Downloads/Android/ROMs/CWM-Huawei_IdeosX3/flash.sh
disktype recovery.img
blkid recovery.img
modprobe -l | grep yaf
grep yaf /proc/filesystems
grep -Hi yaf /etc/modules/DOT*
./chroot_for_android.sh 
ls /sys/block
ls /sys/class/block
dosfsck -v -n /dev/sdd1
dosfsck -v -r /dev/sdd1
sfdisk -l -sU /dev/sdd
testdisk-6.9 /dev/sdd
sfdisk -l -sU /dev/sdd
partprobe -s
man dosfsck
dmesg
dmesg 
uname -r
umount -l /mnt/sdd1
dosfsck -n -v /dev/sdd1
dosfsck -r -v /dev/sdd1
dosfsck -v /dev/sdd1
grep 0x18d1 *
geany usb_vendors.c
fixitup
mount
make menuconfig
ls -s --block-size=1024 recovery.img
./chroot_for_android.sh stop
mount

Tue May 5 02:50:42 GMT+1 2015

make
git init
git remote add repobin https://android.googlesource.com/tools/repo
git remote -v
git pull repobin
git config http.sslVerify false
git pull repobin
git branch -r | while read rb; do echo $rb; br=${rb#*/}; echo $br;git checkout $br; sleep 2;done
git init
gt init 
git init
git remote add plBUILD https://android.googlesource.com/platform/build
git pull
git pull plBUILD
git config http.sslVerify false
git pull plBUILD
git branch -r | while read rb; do echo $rb; br=${rb#*/}; echo $br;git checkout $br; sleep 2;done
git branch
git checkout master
make -f rules
chmod +x busybox-1.17.1-armel
mkdir tmpfs
pwd
exit
mountMTP
mount
umount M
umountMTP
exit
make
make -k
make -i
git remote
git remote -v
git branch
find -type d -not -name "*.git.d"
find -maxdepth 1 -type d -not -name "*.git.d"
./git_pull_all_directories-03.sh 
./git_pull_all_directories-02.sh 
git init
git remote add cyan https://github.com/CyanogenMod/android.git
git pull cyan
git config ssl.Verify=false
git config ssl.Verify false
git pull cyan
which git
git config https.sslVerify false
git config https.ssl.Verify false
git pull cyan
git config http.sslVerify false
git pull cyan
git branch -r
git branch -r | while read rb; do echo $rb; done
git branch -r | while read rb; do echo $rb; br=${rb#*/}; echo $br;done
git branch -r | while read rb; do echo $rb; br=${rb#*/}; echo $br;git checkout $br; sleep 2;done
git remote add plFrwBASE https://android.googlesource.com/platform/frameworks/base
git config htp.sslVerify false
git pull plFrwBASE
git config http.sslverify false
git pull plFrwBASE
make -f debian/rules
grep -i production *
grep property_get *
grep -m1 property_get ../*
grep -m1 property_get ../*/*
grep -m1 __system_property_get ../*/*
grep -m1 __system_property_get ../*/*/*
transmission --help
transmission --help-gtk
transmission /root/Downloads/Android/flashtool-0.9.18.5-linux.tar.7z.torrent
file /root/Downloads/Android/flashtool-0.9.18.5-linux.tar.7z.torrent
7z
7zr 
7zr -l /root/Downloads/Android/flashtool-0.9.18.5-linux.tar.7z
7zr l /root/Downloads/Android/flashtool-0.9.18.5-linux.tar.7z
which dh
file /usr/bin/dh
which dh_shlibdeps
file /usr/bin/dh_shlibdeps
geany /usr/bin/dh_shlibdeps
which ctorrent
file /usr/bin/ctorrent
for i in *; do test -L "$i" && continue; echo "$i"; done
for i in *; do test -L "$i" && continue; echo "$i"; sed -i 's%#!/bin/sh%#!/bin/ash%' "$i" || break; sleep 0.2;done
for i in *; do test -L "$i" && continue;sed -i "2 i\DEFAULT=" "$i" || break; sleep 0.2; done
for i in *; do test -L "$i" && continue;sed -i "3 i\OPTIONS=" "$i" || break; sleep 0.2; done
for i in *; do test -L "$i" && continue;grep exec "$i";done
for i in *; do test -L "$i" && continue;P=`grep exec "$i" | grep -v '#'`; echo $P;done
for i in *; do test -L "$i" && continue;P=`grep exec "$i" | grep -v '#'`; test `echo $P | wc -l` != 1 && continue ;PR=`echo "$P" | awk '{print $2}'`; echo "$PR";done
for i in *; do test -L "$i" && continue;P=`grep exec "$i" | grep -v '#'`; test `echo $P | wc -l` != 1 && continue ;PR=`echo "$P" | awk '{print $2}'`; echo "$PR";sed -i "s%DEFAULT=.*%DEFAULT=$PR%" "$i" || break; sleep 0.2;done
for i in *; do test -L "$i" && continue;P=`grep exec "$i" | grep -v '#'`; test `echo $P | wc -l` != 1 && continue ;PR=`echo "$P" | awk '{print $2}'`; echo "$PR";sed -i "s%^exec $PR %exec \$DEFAULT " "$i" || break; sleep 0.2;done
for i in *; do test -L "$i" && continue;P=`grep exec "$i" | grep -v '#'`; test `echo $P | wc -l` != 1 && continue ;PR=`echo "$P" | awk '{print $2}'`; echo "$PR";sed -i "s%^exec $PR %exec \$DEFAULT %" "$i" || break; sleep 0.2;done
for i in *; do test -L "$i" && continue; echo "$i"; sed -i 's%#! /bin/sh%#!/bin/ash%' "$i" || break; sleep 0.2;done
type -a mozstart
file /usr/local/bin/mozstart
./update_files_from_running_system 
./update_files_from_running_system h
git commit
./update_files_from_running_system 
git remote
git branch
git push krg Fox3-Dell755
git push MSkrg Fox3-Dell755
git commit
git add woof-code/rootfs-skeleton/root/my-roxapps/
git commit -m "/root/my-roxapps/ : Added.
With unknown_mime_handler.sh ."
./replace_commit_files.sh j
./update_files.sh 
./update_files.sh f
./update_files.sh 
git commit
git add replace_commit_files.sh
git add update_files.sh
git add update_files_from_running_system
git commit -m 'update_files_from_running_system,
replace_commit_files,
update_files.sh :
Maintainance changes ; added help message and others.'
git commit
git commit 2>&1 | grep rox
git commit 2>&1 | grep rox | while read l f; do sysf=${f#*skeleton}; echo $sysf; done
git commit 2>&1 | grep rox | while read l f; do sysf=${f#*skeleton}; echo $sysf; cp -a "$f" "$sysf" || break;;done
git commit 2>&1 | grep rox | while read l f; do sysf=${f#*skeleton}; echo $sysf; cp -a "$f" "$sysf" || break;done
git commit 2>&1 | grep rox | while read l f; do sysf=${f#*skeleton}; echo $sysf; cp -a --remove-destination "$f" "$sysf" || break;done
transmission
git commit 2>&1 | grep rox
git commit 2>&1 | grep rox | while read l f; do echo "$f"; done
git commit 2>&1 | grep rox | while read l f; do echo "$f"; git add "$f";done
git commit --dry-run
git commit -m '/root/.config/rox.sourceforge.net/MIME-types/:
Changed files layout .
Will see if they work out.'
git branch
git push MSkrg Fox3-Dell755
git push krg Fox3-Dell755
pctorrent
which pctorrent
geany /usr/sbin/pctorrent
pctorrent
file /usr/bin/gtkdialog-splash
file /usr/bin/yaf-splash
pupzip android-platform-frameworks-base_21.orig.tar.gz 
which xarchive
file /usr/local/bin/xarchive
./chroot_for_android.sh start
./chroot_for_android.sh stop
./chroot_for_android.sh start
./chroot_for_android.sh stop
mount
./chroot_for_android.sh start
grep -r -i 'function not implemented' *
./update_files_from_running_system 
git commit
info chmod
mkdir /tmp/d
cd /tmp/d
echo TEST >file.test
ls -l file.test
chmod 1644 file.test
ls -l file.test
chmod 2644 file.test
ls -l file.test
chmod 3644 file.test
ls -l file.test
chmod 4644 file.test
ls -l file.test
ls -l /bin/busybox*
chmod 5644 file.test
ls -l file.test
chmod 6644 file.test
ls -l file.test
chmod 7644 file.test
ls -l file.test
chmod u=s file.test
ls -l file.test
chmod u=rwxs file.test
ls -l file.test
chmod 0744 file.test
ls -l file.test
chmod 4744 file.test
ls -l file.test
man chmod
man mount
/etc/init.d/runmbbservice reload
pidof dhcpcd
/etc/init.d/runmbbservice restart
df
df -T
df -aT
ps | grep adb
killall adb
df
./configure
man ./init.5
./configure
./split_bootimg.pl recovery.img 
git init
git remote add systemd git://git.freedesktop.org/systemd/
git pull systemd
git remote add Csystemd http://cgit.freedesktop.org/systemd/systemd
git pull Csystemd
git remote delete systemd
git remote remove systemd
git remote add systemd git://git.freedesktop.org/systemd/systemd
git pull systemd
git remote remove systemd
git remote remove Csystemd
git remote add systemd git://anongit.freedesktop.org/systemd/systemd
git pull systemd
git checkout master
grep -i signature *
./split_updata.txt.pl update.app
which perl
./split_updata.txt.pl update.app
./split_updata.pl update.app
./split_updata.pl `pwd`/update.app
/usr/bin/perl
./split_updata.pl `pwd`/update.app
perl --help
./split_updata.pl `pwd`/update.app
./split_updata.pl "`pwd`"/update.app
./split_updata.pl update.app
./split_updata.pl update.app update.app
perl --help
./split_updata.pl update.app update.app
perl split_updata.pl 
perl -e split_updata.pl 
perl -E split_updata.pl 
perl -En split_updata.pl 
perl -Ep split_updata.pl 
perl --version
./split_updata.pl update.app update.app
type env
type -a env
./split_updata.pl update.app update.app
./split_updata.pl  update.app
./split_updata.pl  update.app updaate.app
./split_updata.pl  update.app update.app updaate.app
./split_updata.pl  update.app update.app
./split_updata.pl  update.app
mkdir initrd
mv initrd initrd_recov.d
cd initrd_recov.d
zcat ../recovery.img-ramdisk.gz | cpio -id
git init
git remote add recov https://android.googlesource.com/platform/bootable/recovery
git config http.sslVerify false
git pull recov
hexedit android-terminal-emulator-1-0-63-multi-android.apk 
hexedit natural_notes.apk 
hexedit Browser.apk 
hexedit Music.apk 
tac FileManager.apk >FileManager.apk.tac 
hexedit FileManager.apk.tac 
grep -r verify_file *
grep -r Certificate *
pwd
grep -r verify_file
grep -r verify_file *
grep -r Certificate *
mkdir initrd
cd initrd
zcat ../boot.img-ramdisk.gz | cpio -id
pwd
./split_bootimg.pl 
./split_bootimg.pl boot.img
./mkbootfs --help
./mkbootimg --help
./make_ext4fs --help
dmesg
tail -n1 Superuser-3.0.7-efgh-signed.zip 
hexedit Superuser-3.0.7-efgh-signed.zip 
pwd
find -name "sign*"
find -name "keytool"
find -name "*jarsigner*"
find -name "*keytool*"
find -name "*zipalign*"
./android
find -name "*sign*"
adb
dmesg
./keytool --help
./java jar --help
jar
type -a jar
file /usr/local/bin/jar
jarsigner
jar-3.3.6 --help
jar-3.3.6 --version
jar --version
man ./init.5
man ./init.8
ifconfig
id -gn
id -un
id -u
man umask
info umask
man id
gjarsigner --help
./chroot_for_android.sh stop
mount
umount /dev/loop0
mount

Wed May 6 10:57:55 GMT+1 2015

hexedit libz.so.1.2.3.3 
rox
rox /
rox /; echo $?
rox /
rox /;echo $?
strings /lib/libz.so.1.2.3.3 | grep ZLIB
strings /lib/libz.so.1.2.3.3 | grep '1\.'
strings /lib/libz.so.*.* | grep '1\.'
for i in  /lib/libz.so.*.* ; do echo ":$i:";strings "$i" | grep '1\.'; echo; done
rox
ls -l libz*
diff libz.so.1.2.3 /lib/libz.so.1.2.3.3
diff -qs libz.so.1.2.3 /lib/libz.so.1.2.3.3
ls -l /mnt/sdb15/lib/libz.so.1.2.3.3
ls -l /mnt/sdb7/lib/libz.so.1.2.3.3
file /mnt/sdb7/lib/libz.so.1.2.3.3
grep ZLIB /tmp/libz.so.1.2.3.3
strings /tmp/libz.so.1.2.3.3 | grep ZLIB
hexedit /tmp/libz.so.1.2.3.3
hexedit libz.so.1.2.3.3 
grep 'ZLIB_1\.2\.3' /lib/libz.so
ls -l /lib/libz.so
grep 'ZLIB_1\.2\.3' /lib/libz.so.1.2.3
grep 'ZLIB_1' /lib/libz.so.1.2.3
grep 'ZLIB_' /lib/libz.so.1.2.3
grep 'VERSION_' /lib/libz.so.1.2.3
ls -l /lib/libz*
file /lib/libz.so
mount
mount /dev/sdf1
df
for i in /mnt/sdd1/*; do echo "$i"; sleep 3; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d;sleep 0.3; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d | sort | while read d; do echo "$d";done;sleep 0.3; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d | sort | while read d; do echo "$d";cp -a "$d" /mnt/sdf1/;sleep 1;done;sleep 2; done
df
for i in /mnt/sdd1/*; do echo "$i"; sleep 3; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d;sleep 0.3; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d | sort | while read d; do echo "$d";done;sleep 0.3; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d | sort | while read d; do echo "$d";cp -a "$d" /mnt/sdf1/;sleep 1;done;sleep 2; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d | sort | tac | while read d; do echo "$d";cp -au "$d" /mnt/sdf1/;sleep 1;done;sleep 2; done
df
for i in /mnt/sdd1/*; do echo "$i"; sleep 3; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d;sleep 0.3; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d | sort | while read d; do echo "$d";done;sleep 0.3; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d | sort | while read d; do echo "$d";cp -a "$d" /mnt/sdf1/;sleep 1;done;sleep 2; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d | sort | tac | while read d; do echo "$d";cp -au "$d" /mnt/sdf1/;sleep 1;done;sleep 2; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d | sort | tac | while read d; do dn=${d%/*}; mkdir -p "$dn";echo "$dn:$d";cp -au "$d" /mnt/sdf1/"$dn"/;sleep 1;done;sleep 2; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d | sort | tac | while read d; do dn=${d%/*}; dn=${dn#*/mnt/sdd1/}; echo "$dn:$d";mkdir -p /mnt/sdf1/"$dn";echo "$dn:$d";cp -au "$d" /mnt/sdf1/"$dn"/;sleep 1;done;sleep 2; done
df
for i in /mnt/sdd1/*; do echo "$i"; sleep 3; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d;sleep 0.3; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d | sort | while read d; do echo "$d";done;sleep 0.3; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d | sort | while read d; do echo "$d";cp -a "$d" /mnt/sdf1/;sleep 1;done;sleep 2; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d | sort | tac | while read d; do echo "$d";cp -au "$d" /mnt/sdf1/;sleep 1;done;sleep 2; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d | sort | tac | while read d; do dn=${d%/*}; mkdir -p "$dn";echo "$dn:$d";cp -au "$d" /mnt/sdf1/"$dn"/;sleep 1;done;sleep 2; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d | sort | tac | while read d; do dn=${d%/*}; dn=${dn#*/mnt/sdd1/}; echo "$dn:$d";mkdir -p /mnt/sdf1/"$dn";echo "$dn:$d";cp -au "$d" /mnt/sdf1/"$dn"/;sleep 1;done;sleep 2; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d | sort | tac | while read d; do dn=${d%/*}; dn=${dn#*/mnt/sdd1/}; echo "$dn:$d";echo "/mnt/sdf1/"dn";mkdir -p /mnt/sdf1/"$dn";cp -au "$d" /mnt/sdf1/"$dn"/;sleep 1;done;sleep 2; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d | sort | tac | while read d; do dn=${d%/*}; dn=${dn#*/mnt/sdd1/}; echo "$dn:$d";echo "/mnt/sdf1/$dn";mkdir -p /mnt/sdf1/"$dn";cp -au "$d" /mnt/sdf1/"$dn"/;sleep 1;done;sleep 2; done
df
for i in /mnt/sdd1/*; do echo "$i"; sleep 3; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d;sleep 0.3; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d | sort | while read d; do echo "$d";done;sleep 0.3; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d | sort | while read d; do echo "$d";cp -a "$d" /mnt/sdf1/;sleep 1;done;sleep 2; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d | sort | tac | while read d; do echo "$d";cp -au "$d" /mnt/sdf1/;sleep 1;done;sleep 2; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d | sort | tac | while read d; do dn=${d%/*}; mkdir -p "$dn";echo "$dn:$d";cp -au "$d" /mnt/sdf1/"$dn"/;sleep 1;done;sleep 2; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d | sort | tac | while read d; do dn=${d%/*}; dn=${dn#*/mnt/sdd1/}; echo "$dn:$d";mkdir -p /mnt/sdf1/"$dn";echo "$dn:$d";cp -au "$d" /mnt/sdf1/"$dn"/;sleep 1;done;sleep 2; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d | sort | tac | while read d; do dn=${d%/*}; dn=${dn#*/mnt/sdd1/}; echo "$dn:$d";echo "/mnt/sdf1/"dn";mkdir -p /mnt/sdf1/"$dn";cp -au "$d" /mnt/sdf1/"$dn"/;sleep 1;done;sleep 2; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d | sort | tac | while read d; do dn=${d%/*}; dn=${dn#*/mnt/sdd1/}; echo "$dn:$d";echo "/mnt/sdf1/$dn";mkdir -p /mnt/sdf1/"$dn";cp -au "$d" /mnt/sdf1/"$dn"/;sleep 1;done;sleep 2; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d | sort | tac | while read d; do echo "$d";dn=${d%/*}; echo "$dn";dn=${dn#*/mnt/sdd1/}; echo "$dn";echo "/mnt/sdf1/$dn";mkdir -p /mnt/sdf1/"$dn";cp -au "$d" /mnt/sdf1/"$dn"/;sleep 1;done;sleep 2; done
df
for i in /mnt/sdd1/*; do echo "$i"; sleep 3; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d;sleep 0.3; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d | sort | while read d; do echo "$d";done;sleep 0.3; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d | sort | while read d; do echo "$d";cp -a "$d" /mnt/sdf1/;sleep 1;done;sleep 2; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d | sort | tac | while read d; do echo "$d";cp -au "$d" /mnt/sdf1/;sleep 1;done;sleep 2; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d | sort | tac | while read d; do dn=${d%/*}; mkdir -p "$dn";echo "$dn:$d";cp -au "$d" /mnt/sdf1/"$dn"/;sleep 1;done;sleep 2; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d | sort | tac | while read d; do dn=${d%/*}; dn=${dn#*/mnt/sdd1/}; echo "$dn:$d";mkdir -p /mnt/sdf1/"$dn";echo "$dn:$d";cp -au "$d" /mnt/sdf1/"$dn"/;sleep 1;done;sleep 2; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d | sort | tac | while read d; do dn=${d%/*}; dn=${dn#*/mnt/sdd1/}; echo "$dn:$d";echo "/mnt/sdf1/"dn";mkdir -p /mnt/sdf1/"$dn";cp -au "$d" /mnt/sdf1/"$dn"/;sleep 1;done;sleep 2; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d | sort | tac | while read d; do dn=${d%/*}; dn=${dn#*/mnt/sdd1/}; echo "$dn:$d";echo "/mnt/sdf1/$dn";mkdir -p /mnt/sdf1/"$dn";cp -au "$d" /mnt/sdf1/"$dn"/;sleep 1;done;sleep 2; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d | sort | tac | while read d; do echo "$d";dn=${d%/*}; echo "$dn";dn=${dn#*/mnt/sdd1/}; echo "$dn";echo "/mnt/sdf1/$dn";mkdir -p /mnt/sdf1/"$dn";cp -au "$d" /mnt/sdf1/"$dn"/;sleep 1;done;sleep 2; done
for i in /mnt/sdd1/*; do echo "$i"; find "$i" -type d | sort | tac | while read d; do echo "$d";dn=${d%/*}; echo "$dn";dn=${dn#*/mnt/sdd1}; echo "$dn";echo "/mnt/sdf1/$dn";mkdir -p /mnt/sdf1/"$dn";cp -au "$d" /mnt/sdf1/"$dn"/;sleep 1;done;sleep 2; done
df
mkfs.ext2 /dev/sdf1
mount /dev/sdf1
df
find -type f
find -type f >/tmp/files32GB.lst
while read f; do test "$f" || continue; test -f "$f" || continue; bn=${f##*/}; echo "$f"" : ""$bn"; done</tmp/files32GB.lst
while read f; do test "$f" || continue; test -f "$f" || continue; bn=${f##*/}; echo "$f"" : ""$bn"; grep "/$bn" /tmp/files32GB.lst; echo;done</tmp/files32GB.lst
while read f; do test "$f" || continue; test -f "$f" || continue; bn=${f##*/}; echo "$f"" : ""$bn"; grep "/$bn" /tmp/files32GB.lst; echo;done</tmp/files32GB.lst >/tmp/files32GB.doulettes.lst
mkfs.ext2 /dev/sdf1
mount /dev/sdf1
umount /dev/sdf1
export LD_NOWARN=1
mount /dev/sdf1
export LD_NOWARN=
umount /dev/sdf1
export LD_DEBUG=help
mount /dev/sdf1
export LD_DEBUG=
export LD_DEBUG=versions
umount /dev/sdf1
man ld.so
pwd
man ld
grep TT_NEWSCHED *
info zlib
info libz
man libz
man mkdosfs
mkdir -p /mntT/sdf1
mount-FULL -t vfat /dev/sdf1 /mntT/sdf1
mount
ls /mntT/sdf1
umount-FULL -t vfat /mntT/sdf1
dosfsck --help
dosfsck -l -n -v /dev/sdf1
dosfsck -l -v /dev/sdf1
dosfsck -l -v -d / /dev/sdf1
dosfsck -l -v /dev/sdf1
mkfs.vfat --help
mount
probepart
ls /sys/class/block/sde*
ls -d /sys/class/block/sde*
ls -d /sys/class/block/sdd*
cat /proc/partitions
man mkfs.ext2
probedisk
./chroot_for_android.sh start
grep -w 71 *
grep -w 110 *
grep -w '\-71' *
grep -w '71' *
grep -r -m 3 usb_control_msg *
grep -I -r -m 3 usb_control_msg *
ls /sys/block
dmesg
killall adb
dmesg |tail
ifconfig
/etc/init.d/runmbbservice restart
grep -r 'device not accepting address' *
./chroot_for_android.sh stop
killall adb
geany `which rxvt`
rxvt
crossfire-client-gtk-1.12.svn 
pwd
ls
ls *
tac su-2.3.6.3-efgh-signed.zip >su-2.3.6.3-efgh-signed.tac.zip 
hexedit su-2.3.6.3-efgh-signed.tac.zip 
tac Superuser-3.0.7-efgh-signed.zip >Superuser-3.0.7-efgh-signed.tac.zip 
hexedit Superuser-3.0.7-efgh-signed.tac.zip 
make menuconfig
which dhcpcd
type -a dhcpcd
type -a pppd

Fri May 8 23:00:33 GMT+1 2015

./split_bootimg.pl boot_sirius_boot.img 
zcat ../boot_sirius_boot.img-ramdisk.gz | cpio -id
/bin/df /mnt/sdb19
/bin/df -T /mnt/sdb19
mkdir ramdisk.d
cd ramdisk.d
cat ../ramdisk.cpio | cpio -id
mkdir ramdisk-recv.d
cd ramdisk-recv.d
zcat ../ramdisk-recovery.cpio | cpio -id
cat ../ramdisk-recovery.cpio | cpio -id
df /mnt/sdb19
/etc/init.d/runmbbservice start
/etc/init.d/runmbbservice stop
/etc/init.d/runmbbservice start
/etc/init.d/runmbbservice stop
/etc/init.d/runmbbservice start
/etc/init.d/runmbbservice stop
pidof dhcpcd
killall dhcpcd
pidof dhcpcd
killall dhcpcd
/etc/init.d/runmbbservice stop
/etc/init.d/runmbbservice start
git branch
git remote -v
git branch -a
git pull recov
git branch -r
git branch -r | while read rb; do lb=${rb#*/}; echo $lb; done
git branch -r | while read rb; do lb=${rb#*/}; echo $lb; git checkout $lb; sleep 1;done
find -path "*/pack/tmp_pack*"
find -path "*/pack/tmp_pack*" -exec ls -s {} \;
git init
git remote add uboot https://android.googlesource.com/device/ti/bootloader/uboot
git config http.sslverify false
git pull uboot
git checkout master
rox .
git pull uboot
cddetect --help
cddetect -v -d/dev/sr0
cddetect -v -d/dev/sr0;echo $?
mount
mount /dev/sr0

Wed May 27 18:38:05 GMT+1 2015

killall firefox
#
killall firefox
timeout --help
ls -ld /sys/devices/system/cpu/$core/cpufreq
ls -ld /sys/devices/system/cpu/cpu0/cpufreq
probedisk
mount /dev/sr0
mount /dev/sr1
guessfs_type
guess_fstype
guess_fstype /dev/sr0
guess_fstype /dev/sr1
probedisk
grep -r -I COMMAND_LINE_SIZE *
ifconfig
ifconfig -a
ifconfig eth1 up
dhcpcd eth1
cat /proc/cmdline >/tmp/cmdline.txt
ls -s /tmp/cmdline.txt 
mktmemp
mktemp
mktemp --help
mktemp 2>/dev/null
find -name "cmdline*"
grep -I -i -r 'kernel command line'
grep -I -i -r 'kernel command line' *
grep -I -i -r 'kernel commandline' *
grep -I -i -r 'kernel cmdline' *
grep -I -i -r '[128]' *
grep -I -i -r '\[128\]' *
grep -I -i -r '\[256\]' *
grep -I -i -r '\[275\]' *
grep -I -i -r '\[276\]' *
echo $((276-256))
find -name "cmdline*"
lsmod | grep acpi
read CMDLINE </proc/cmdline
echo "$CMDLINE"
echo "$CMDLINE"                                 |wc -L
echo "$CMDLINE"                                 |wc -w
echo "$CMDLINE"                                 |wc -c
echo "$CMDLINE"                                 |wc -b
echo "$CMDLINE"                                 |wc -m
echo -n "$CMDLINE"                                 |wc -m
echo -n "$CMDLINE"                                 |wc -L
bash_3.2 
env
cat /proc/cmdline
ls -s /proc/cmdline
read CMDLINE </proc/cmdline
echo "$CMDLINE"
make menuconfig
killall firefox

Thu Jul 9 16:27:54 GMT+1 2015

geany /usr/local/bin/drive_all
dvd+rw-mediainfo /dev/sr0
dvd+rw-mediainfo /dev/sr0;echo $?
./git_pull_all_directories-03.sh 
geany /bin/ps
git branch
git remote
git pull
git branch
git checkout Fox3-Dell745
git pull
git branch
git checkout FOX3-ASUSTeK1005HAG
git checkout Fox3-GreatWallU310
git checkout Fox3-GreatWallU310-KRGall
git pull
git branch
git checkout Opera2-GreatWallU310-KRGall-2013-11-23
git pull
git branch
git checkout luci218-GreatWallU310-KRGall-2013-11-24
git pull
git branch
git checkout luci218-Dell755
git pull
git branch
git checkout Opera2-Dell755
git pull
git branch
git remote
git pull
ping -c 5 www.bing.com
git branch
git remote
git pull
git branch
git branch -r
git checkout Fox3-Dell755
git checkout Opera2-Dell755
git pull
git branch
git checkout luci218-Dell755
git pull
git branch
git branch -r
git checkout luci218-GreatWallU310-KRGall-2013-11-24
git checkout Opera2-GreatWallU310-KRGall-2013-11-23
git checkout Fox3-GreatWallU310-KRGall
cat /proc/cmdline
date
df
du -b G -c /mnt/sdd18/Git.d/
du -B G -S -c -s /mnt/sdd18/Git.d/
echo $(( (31779230880 / 1024) /1024 ))
echo $(( (31779230880 / 1024) / (1024*1024)  ))
du -bG -c /mnt/sda9/Git.d/
du -b G -c /mnt/sda9/Git.d/
du -B G -c /mnt/sda9/Git.d/
du -B G -S -c /mnt/sda9/Git.d/
for i in *; do :; rsync -a "$i" /mnt/sda9/Git.d/; sleep 20; done
du --help
rsync -a /mnt/sdd18/Kernel/Firmware.d/linux-firmware .
fsck -nv /dev/sdb18
fsck -fnv /dev/sdb18
fsck -Dfnv /dev/sdb18
fsck -Dfnv -E fragcheck /dev/sdb18
pwd
man e2fsck
pwd
rsync -a /mnt/sdd16/CF/* .
fsck -nv /dev/sda9
fsck -fnv /dev/sda9
fsck -Dfnv /dev/sda9
fsck -Dfnv -E fragcheck /dev/sda9
pwd
df
cddetect -d /dev/sr0
guess_fstype /dev/sr0
mount /dev/sr0
cddetect -d /dev/sr0: echo $?
cddetect -d/dev/sr0: echo $?
cddetect -d/dev/sr0; echo $?
cddetect_quick -d/dev/sr0; echo $?
cddetect -d/dev/sr1; echo $?
pwd
df
/etc/init.d/runmbbservice restart
fsck -nv /dev/sdb19
fsck -fnv /dev/sdb19
fsck -Dfnv /dev/sdb19
fsck -Dfnv -E fragcheck /dev/sdb19
fsck -fv /dev/sdb19
fsck -Dnv /dev/sdb19
fsck -Dfv /dev/sdb19
fsck -Dfv -E fragcheck /dev/sdb19
probedisk
man e2fsck
ps | grep mount
mount
mount -o remount,ro /dev/sdb19 /mnt/sdb19
mount -s -o remount,ro /dev/sdb19 /mnt/sdb19
umount /dev/sdb19
umount -l /dev/sdb19
mount
umount /dev/loop0
mplayer /mnt/sda1/VID/MSC/WebM/06CDDd01.webm
rsync --help | grep update\
rsync --help | grep update
rsync --help | grep '\-a'
pwd
for i in *; do :; rsync -au "$i" /mnt/sdd2/VID/; sleep 5; done
for i in *; do :; rsync -au "$i" /mnt/sda1/VID/MSC/; sleep 5; done
mount
df
pwd
man ps
man top
/etc/init.d/runmbbservice restart
ifconfig
ps | grep dhcpcd
killall dhcpcd
/etc/init.d/runmbbservice restart
mount
locale
LANG=de_DE abiword
LC_ALL=de_DE abiword
type -a abiword 
/usr/local/bin/abiword
/etc/init.d/runmbbservice restart
/opt/google/google-chrome-6.0.490.1-DEV/google-chrome
top

Sat Jul 11 06:06:17 GMT+1 2015

git commit
git add woof-code/boot/initrd-tree0/init
git commit -m 'initrd-tree0/init : Changes.'
./update_files_from_running_system 
./replace_commit_files.sh 
git commit
git add replace_commit_files.sh
git commit -m 'replace_commit_files.sh: Use /bin/cp .'
./replace_commit_files.sh 
git rm woof-code/rootfs-skeleton/root/.retrovolrc 
git commit -m '/root/.retrovolrc: removed.'
git log
git commit
git add woof-code/rootfs-skeleton/etc/init.d/runmbbservice
git commit -m '/etc/init.d/runmbbservice: Added.'
git remote
git branch
git push krg Fox3-Dell755
git push MSkrg Fox3-Dell755
git branch
git checkout Fox3-Dell755
git remote
git pull
geany /mnt/sdb6/etc/init.d/runmbbservice 
crossfire-client-gtk-1.12.svn 
df /
ps | grep git
kill 13728
ps | grep git
kill 5689
ps | grep git
kill 12027
ps | grep git
kill 18731
ps | grep git
kill 611
./_run_all_git.sh 
killall git
fsck -nv /dev/sda9
fsck -fnv /dev/sda9
fsck -fv /dev/sda9
fsck -fDv /dev/sda9
fsck -fDv -E fragcheck /dev/sda9
git branch
git checkout Fox3-Dell755
gir remote
git remote
git pull
git remote
git branch
git pull
git pull krg Fox3-Dell755
git log
git remote
git branch
git pull
/etc/init.d/runmbbservice stop
/etc/init.d/runmbbservice start
grep --help
jwm -reload
jwm -restart
geany /root/.jwmrc-tray
man grep
LC_ALL=C man grep
jwmconfig3
jwmconfig3
jwm -v 2>/dev/null | head -n1 | grep -oe '[[:digit:]]\+'
which jwmconfig3
file /usr/local/bin/jwmconfig3
geany /usr/local/bin/jwmconfig3
geany /usr/local/jwmconfig3/jwmConfigMgr 
git commit
pwd
git mv taskbarConfig.hight taskbarConfig.hide
. ./func
git mv path variables
grep -H -i 'vers' *
grep -H -i 'vers' * | grep -viE 'revers|two_vers'
git commit
pwd
git commit
git add replace_commit_files.sh
git commit -m 'replace_commit_files.sh: Be different verbose;
be relative .
'
mkdir git_helper
git mv replace_commit_files.sh git_helper/
git commit
./git_helper/replace_commit_files.sh 
git tag -l
git log
geany /etc/rc.d/f4puppy5
git branch
git remote
git push krg Fox3-Dell755
git push MSkrg Fox3-Dell755
./git_helper/update_files_from_running_system 
git commit
git add git_helper/replace_commit_files.sh
git commit -m 'update_files_from_running_system: Fixes for relative paths .'
git add git_helper/replace_commit_files.sh
git commit -m 'git_helper/replace_commit_files.sh:
git add update_files_from_running_system
git -commit -m 'update_files_from_running_system: Fixes for relative Path .'
git commit -m 'update_files_from_running_system: Fixes for relative Path .'
git mv update_files_from_running_system git_helper/
git commit
grep -i dvd /etc/rc.d/rc.sysinit
grep -i burn /etc/rc.d/rc.sysinit
grep -i burn /etc/rc.d/rc.sysinit.run
grep -i dvd /etc/rc.d/rc.sysinit.run
ls /proc/sys/dev/cdrom/info
cat /proc/sys/dev/cdrom/info
fbxkb & 
retrovol --version
retrovol --version 2>/dev/null
pidof glipper
jwm -restart
chmod +x /usr/bin/retrovol
chmod +x /usr/bin/jwm
jwm -restart
pidof fbxkb
killall fbxkb
fbxkb
jwm -restart
pidof fbxkb
jwm -restart
pidof fbxkb
jwm -restart
jwm -reload
jwm -restart
which jwm
file /bin/jwm
file /usr//bin/jwm
mv /usr/bin/jwm /usr/bin/jwm.bin
geany /usr/bin/jwm
geany /usr/sbin/delayedrun
geany /usr/bin/jwm
pidof jwm.bin
ps | grep jwm
jwm
geany
jwm -restart
cp -a /usr/bin/jwm .
git commit
cd ../../
git commit
git add usr/bin/jwm
git commit -m '/usr/bin/jwm: Wrapper added to handle -restart woes for some apps:
glipper
fbxkb
retrovol
'

Tue Jul 14 08:56:20 GMT+1 2015

git branch
git checkout Opera2-GreatWallU310-KRGall-2013-11-23
git checkout Fox3-Dell755
rox
wget -c http://www.slackware.com/~alien/slackbuilds/chromium/pkg64/13.37/chromium-37.0.2062.94-x86_64-1alien.txz
wget -c http://www.slackware.com/~alien/slackbuilds/chromium/pkg/13.37/chromium-37.0.2062.94-i486-1alien.txz
./google-chrome --user-data-dir=/root/.chrome/p0
locale
mkdir -p /root/.chrome
mkdir -p /root/.chrome/p0
./google-chrome --help
find -size +2M
file ./f_0000da
/lib/firefox/firefox -ProfileManager
/lib/firefox/firefox -help
/lib/firefox/firefox -safe-mode
file /lib/firefox/firefox
file /lib/firefox/
ls -l /lib/firefox/
ls -ld /lib/firefox/
strace /lib/firefox/firefox -ProfileManager
dd if=/dev/sdb5 of=/boot/sb_sdb5.bin count=1 bs=512
dd if=/dev/sdb6 of=/boot/sb_sdb6.bin count=1 bs=512
dd if=/dev/sdb7 of=/boot/sb_sdb7.bin count=1 bs=512
ps | grep -i fire
crossfire
crossfire-client-gtk-1.12.svn 
find /usr/X11/lib -name intel_drv.so
ls /usr/X11/lib/xorg/modules/drivers/i*
find /usr/X11/lib -name i965*
find /usr/X11/lib -name i*
find /usr/X11/lib -name "i*"
find /lib/modules/`uname -r`/ -name i915.ko
ls /lib/modules/3.9.9-KRG-iCore2-smp-pae-srv1000gz/kernel/drivers/gpu/
ls /lib/modules/3.9.9-KRG-iCore2-smp-pae-srv1000gz/kernel/drivers/gpu/drm
modinfo i915
/etc/init.d/runmbbservice restart
date
pidof ROX-Filer
fixitup
crossfire-client-gtk-1.12.svn 
crossfire-client-gtk-1.12.svn 
ps | grep -i fire
git checkout linux-3.16.y
git checkout linux-3.17.y
git checkout linux-3.18.y
git checkout linux-3.19.y
git checkout linux-4.0.y
git checkout linux-4.1.y
git checkout master
git checkout linux-3.15.y
git pull
git checkout linux-3.14.y
git pull
git checkout linux-3.12.y
git pull
git checkout linux-3.10.y
git pull
git checkout linux-3.4.y
git pull
git checkout linux-3.2.y
git pull
git branch
git checkout linux-2.6.32.y
git pull
git help checkout
ps| grep -i fire
ifconfig
git --version
ifconfig
git branch
git branch -r
git remote
git pull
git pull gitKernelOrgStable
git checkout master
git pull
./civ --version
./civ 
./freeciv1.7.2GUI.sh 
civclient
pidof civserver
killall civserver
civclient
ls /usr/share/games/freeciv/data
ls /usr/local/share/freeciv/data
which freeciv_server
file /usr/local/bin/freeciv_server
which freeciv_client
file /usr/local/bin/freeciv_client
find /usr -name "*civ*"
./civ
./ser
which freeciv_client
file /usr/local/bin/freeciv_client
./freeciv1.7.2GUI.sh 
civclient
which civlient
which civclient
file /usr/bin/civclient
geany /usr/bin/civclient
file /usr/bin/civclient
civclient
file /usr/bin/civclient.bin
civclient
ls /usr/games/freeciv
ls /usr/games/freeciv/freeciv-1.7.2/
civclient
find -path "*/Cache/*" -size +2M
find -path "*/Cache/*" -mmin -10
find -path "*/Cache/*" -mmin -10 -size +2M
find -path "*/Cache/*" -mmin -20 -size +2M
find -path "*/Cache/*" -size +2M
file ./47p0emkb.default/Cache/8/C5/9D3C0d01
file ./47p0emkb.default/Cache/7/1D/65114d01
defaultmediaplayer ./47p0emkb.default/Cache/7/1D/65114d01
defaultmediaplayer ./47p0emkb.default/Cache/8/C5/9D3C0d01
freeciv_client --version
freeciv_server --version
freeciv_server
eix
exit
freeciv_client
exit

Wed Jul 15 21:07:18 GMT+1 2015

diff -qs /usr/X11/lib/libX11.so.6.3.0 /mnt/sdb6/usr/X11/lib/libX11.so.6.3.0
file /usr/X11/lib/libX11.so.6.3.0
file /mnt/sdb6/usr/X11/lib/libX11.so.6.3.0
ls -s /usr/X11/lib/libX11.so.6.3.0
ls -s /mnt/sdb6/usr/X11/lib/libX11.so.6.3.0
diff -qs /usr/games/freeciv/freeciv-1.7.2/bin/civclient /usr/local/share/freeciv/bin/civclient
diff -qs /usr/games/freeciv/freeciv-1.7.2/bin/civclient /mnt/sdb6/usr/local/share/freeciv/bin/civclient
diff -qs /usr/games/freeciv/freeciv-1.7.2/bin/civclient /mnt/sdb6/usr/local/share/freeciv/freeciv-1.7.2/bin/civclient
/mnt/sdb6/usr/local/share/freeciv/freeciv-1.7.2/bin/civclient
LC_ALL=C /mnt/sdb6/usr/local/share/freeciv/freeciv-1.7.2/bin/civclient
LC_ALL=de_DE /mnt/sdb6/usr/local/share/freeciv/freeciv-1.7.2/bin/civclient
ldd /mnt/sdb6/usr/local/share/freeciv/freeciv-1.7.2/bin/civclient
Xorg -version
chroot .
chroot .
geany /mnt/sdb6/usr/local/share/freeciv/civ
cp -ai /mnt/sdb6/usr/local/share/freeciv/civ /mnt/sdb6/usr/local/share/freeciv/civORIG
fixmenus
jwm -p
jwm -reload
man xosview
man /mnt/sda9/Git.d/Xosview/xosview.1
grep -r -i netPriority *
grep -r -i Priority *
freeciv_server
freeciv_client
ldd `which freeciv_client`
/usr/games/freeciv/freeciv-1.7.2/bin/civclient
ldd /usr/games/freeciv/freeciv-1.7.2/bin/civclient
freeciv_server
freeciv_server --help
freeciv_server -f civgame-2400.sav
pwd
ifconfig eth1 down
find /usr -name civclient
/usr/bin/civclient
file /usr/bin/civclient
geeany /usr/bin/civclient
geany /usr/bin/civclient
/usr/bin/civclient.bin --version
find /usr -name civclient.bin
freeciv_client 
file /usr/local/bin/freeciv_client 
freeciv_client 
geany /usr/local/bin/civclient
file /usr/local/bin/civclient
geany /usr/local/bin/freeciv_client
/usr/local/bin/freeciv_client 
/usr/local/bin/freeciv_client --version
/usr/local/bin/freeciv_client --help
/usr/local/bin/freeciv_client -debug 2
mv /root/.civclientrc /root/.civclientrcOUT
/usr/local/bin/freeciv_client -debug 2
diff -qs /usr/games/freeciv/freeciv-1.7.2/bin/civclient /mnt/sdb6/usr/local/share/freeciv/freeciv-1.7.2/bin/civclient
ls -s /usr/games/freeciv/freeciv-1.7.2/bin/civclient /mnt/sdb6/usr/local/share/freeciv/freeciv-1.7.2/bin/civclient
ldd /usr/games/freeciv/freeciv-1.7.2/bin/civclient | sort
chroot .

Thu Jul 16 10:34:14 GMT+1 2015

realpath /usr/bin/X
freeciv_client
df
df -a
freeciv_server

Thu Jul 16 12:53:38 GMT+1 2015

git remote
git remote -v
git pull
git branch
git remote -v
git pull
./git_pull_all.sh 
git branch
rit remote -v
git remote -v
git pull
git checkout hjl/iamcu/improve
git checkout hjl/pr58066/gcc-5-branch
git checkout trunk
git pull
git checkout gcc-5-branch
git pull
git checkout gcc-4_9-branch
git pull
git branch
git remote -v
git pull
git checkout users/ppalka/readline-7.0-update
git checkout users/hjl/linux/master
git pull
git checkout users/hjl/compressed
git pull
git log
git reset --hard 749ef8f891fb921cf7ad57062deae6fa8c13b501
git branch | grep '\*'
git remote
git pull binutils users/hjl/compressed
git checkout gdb-7.10-branch
git checkout binutils-2_25-branch
git pull
git branch
git remote
git pull
git checkout gtk-3-16
git checkout wip/baedert/gtkimageview
git checkout wip/garnacho/touchpad-gestures
git checkou wip/gbsneto/other-locations
git checkout wip/gbsneto/other-locations
git checkout gtk-3-14
git pull
git checkout gtk-3-14
git pull
git remote -v
git branch
git branch | grep '\*'
git pull
./git_pull_all.sh 
git remote -v
git config http.sslverify false
git branch
git pull
git branch
git branch -r
git pull
git branch
git remote -v
git branch -r
git tag -l
git pull
git branch
git remote -v
git pull
git config http.sslverify false
git pull
git branch
git remote -v
git pull
git branch
git remote -v
git pull
git branch
git remote -v
git pull
git config http.sslverify false
git pull
git branch
git remote -v
git pull
git config http.sslverify false
git pull
git branch
git remote -v
git pull
git branch
git checkout aufs4.x-rcN
git checkout aufs4.0
git checkout master
git remote -v
git pull
git checkout aufs4.1
find -maxdepth 3 -path "*/.git/config" -exec grep -H -i github {} \;
find -maxdepth 4 -path "*/.git/config" -exec grep -H -i github {} \;
git branch
git branch -r
git remote -v
git pull
grep -H -I -r -i 'You asked to pull' *
git branch
git branch -r
git pull
git remote
git pull gitKernelOrg
git pull gitKernelOrg master
git checkout maint
git checkout master
git checkout next
git pull
git remote
git pull gitKernelOrg
git branch
git pull gitKernelOrg next
git pull -v gitKernelOrg next
git checkout maint
git pull -v gitKernelOrg maint
git checkout master
top
git branch
git pull
git remote -v
git pull gitKernelOrgStable
git pull gitKernelOrgStable master
git tag
git log
git checkout maint
git checkout master
git checkout next
git checkout pu
git checkout todo
git checkout master
git branch
git branch -r
git remote -v
git pull
git pull gitGitHub
git checkout pango-1-36
git checkout master
git pull
ggit branch
git branch
git pull
git branch
git remote -v
git pull
git branch
git checkout gnome-3-14
git checkout gnome-3-16
git checkout master
git pull
git checkout 1.14
git checkout color-emoji
git checkout 1.12
git pull
git branch
git checkout master
git pull
git checkout 1.12
git pull
git branch
git pull
git branch
git pull
git branch
git checkout glib-2-40
git checkout glib-2-42
git checkout glib-2-44
git branch
git pull
git branch
git pull
git checkout gdk-pixbuf-2-30
git help update-index
pwd
git checkout gtk-3-10
git pull
git checkout gtk-3-12
git checkout gtk-3-14
git checkout gtk-3-16
git branch
git pull
df
git branch
git checkout Fox3-GreatWallU310-KRGall
pwd
top
amixer set Master,0 off
amixer set Master,0 on
find -type -d -name "Cache"
find -type d -name "Cache"
find -type d -name "Cache" -exec du -c -s -BM {} \;
du -c -s -BM /root/.opera
du -c -s -BM /root/.cache
du -c -s -BM /root/.mozilla
for i in *; do test -d "$i" || continue; rmdir $i; done
for i in *; do test -d "$i" || continue; du -cs -BM $i; done
git branch
git checkout FOX3-ASUSTeK1005HAG
git checkout Fox3-GreatWallU310-KRGall
git checkout Fox3-Dell755
git log | grep powerbutton
git log | grep -B4 powerbutton
git log | grep -B4 -A1 powerbutton
git branch
./git_helper/update_files_from_running_system 
./git_helper/replace_commit_files.sh 
amixer set Line,0 10
amixer set Line,0 20
amixer set Line,0 30
amixer set Line,0 40
amixer set Line,0 20
amixer set Line,0 10
arecord -l
arecord -L
amixer
amixer Master,0
amixer --help
amixer sget Master,0
ash
cat /sys/class/rtc/rtc0/since_epoch
date +%s
cat /sys/class/rtc/rtc0/time
cat /sys/class/rtc/rtc0/date
/etc/acpi/wakealarm/wakealarm_wake.sh
which mplayer
/etc/acpi/wakealarm/wakealarm_wake.sh
/etc/init.d/runmbbservice restart
cd woof-code/rootfs-skeleton/root
mkdir .crossfire
git commit
git add woof-code/rootfs-skeleton/etc/acpi/wakealarm.sh
git add woof-code/rootfs-skeleton/etc/acpi/wakealarm/
git add woof-code/rootfs-skeleton/usr/share/applications/set_wakealarm.desktop
git commit -m 'set_wakealarm: Added .desktop file
and
/etc/acpi/ scripts
wakealarm.sh that runs busybox/powerbutton at the end
wakealarm/wakealarm_wake.sh
 that both are executed at wakeup event.
'
git commit
git add woof-code/rootfs-skeleton/etc/acpi/busybox/powerbuttonK
git add woof-code/rootfs-skeleton/etc/acpi/busybox/powerbuttonX
git commit -m '/etc/acpi/busybox/powerbuttonK
and
/etc/acpi/busybox/powerbuttonX
added.
'
pwd
git branch
git remote
git push MSkrg Fox3-Dell755
git push krg Fox3-Dell755
git commit
git add woof-code/rootfs-skeleton/root/.crossfire/
git commit -m '/root/.crossfire/: Directory added with
keys file
s/ directory for client scripts
scripts/ directory for script stubs
.'
git push krg Fox3-Dell755
git push MSkrg Fox3-Dell755
/etc/acpi/wakealarm.sh
 
man date
date --help
crossfire
crossfire-client-gtk-1.12.svn 
crossfire-client-gtk1-1.12.svn 
crossfire-client-gtk1v2-1.12.svn 
crossfire-client-gtk2-1.12.svn 
crossfire-client-gtk2-1.70.0 
export GTKRC_FILES=/root/.crossfire/crossfire_gtkrc-2.0 
export GTK2RC_FILES=/root/.crossfire/crossfire_gtkrc-2.0 
crossfire-client-gtk2-1.70.0 
export GTKRC2_FILES=/root/.crossfire/crossfire_gtkrc-2.0 
crossfire-client-gtk2-1.70.0 
export GTK2_RC_FILES=/root/.crossfire/crossfire_gtkrc-2.0 
crossfire-client-gtk2-1.70.0 
du -cs -BM /root
df
grep GTK *
type -a date
busybox date
/usr/local/bin/date
/usr/local/bin/date +%s
busybox date +%s
busybox date -u +%s
busybox date +%s
busybox date +%s; busybox date -u +%s
/usr/local/bin/date +%s;/usr/local/bin/date -u +%s
busybox date -R +%s; busybox date -R +%s
busybox date -R -u +%s; busybox date -R -u +%s
/usr/local/bin/date -R +%s;/usr/local/bin/date -R -u +%s
/usr/local/bin/date -R +%s;/usr/local/bin/date -R  +%s
/usr/local/bin/date -R;/usr/local/bin/date -R
/usr/local/bin/date -R ;/usr/local/bin/date -u +%s
/usr/local/bin/date --rfc-3339
/usr/local/bin/date --rfc-3339=date
/usr/local/bin/date --rfc-3339=seconds
/usr/local/bin/date --rfc-3339=ns
fixmenus
jwm -reload
pwd
grep -r -i wave *
crossfire-client-gtk-1.12.svn 
LC_TIME=C date +%s
cat /sys/class/rtc/rtc0/since_epoch
LC_TIME=C date +%s
date +%s
LC_ALL=C date +%s
LC_TIME=C date +%s
echo $((3600/60))
/etc/acpi/wakealarm.sh
echo abc,wert,qaz desxc dfg hji,123 | tr '[ ,]' '|'
pwd
branch
git branch
git checkout Fox3-GreatWallU310-KRGall
git checkout Opera2-GreatWallU310-KRGall-2013-11-23
git checkout luci218-GreatWallU310-KRGall-2013-11-24
git mv s/cf_request_inv.sh scripts/
git commit
git rm s/inv
git mv s/cf_watch_monitor.sh scripts/
git mv s/cf_watch_request_items_inv.sh scripts/
git commit
git add s/cf_cast_spell.sh s/cf_fire_item.sh
git commit
git add scripts/inv scripts/req_stats.sh
git commit
git add KARL.crossfire.metalforge.net.keys Karl.crossfire.metalforge.net.keys Karl_.crossfire.metalforge.net.keys Trollo.crossfire.metalforge.net.keys karl.crossfire.metalforge.net.keys karl.localhost.keys crossfire_gtkrc-2.0
git commit
cd ../../../
pwd
cd ..
pwd
./git_helper/replace_commit_files.sh 
git branch
git remote
git push MSkrg Fox3-Dell755
git push krg Fox3-Dell755
git branch
git checkout Fox3-Dell755
git remote
git pull
git remote
git branch
git pull
git branch
git remote
git pull
export GTK2_RC_FILES=/root/.crossfire/crossfire_gtkrc-2.0 
crossfire-client-gtk2-1.70.0 
export GTK2_RC_FILES=/root/.crossfire/crossfire_gtkrc-2.0 
crossfire-client-gtk-1.12.svn 
export GTK2_RC_FILES=/root/.crossfire/crossfire_gtkrc-2.0 
crossfire-client-gtk2-1.12.svn 
export GTK2_RC_FILES=/root/.crossfire/crossfire_gtkrc-2.0 
crossfire-client-gtk-1.12.svn 
crossfire-client-gtk2-1.70.0 
export GTK2_RC_FILES=/root/.crossfire/crossfire_gtkrc-2.0 
crossfire-client-gtk2-1.70.0 
diff -up glade-gtk2-1.12.svn/chthonic.glade glade-gtk2-1.70.0/chthonic.glade 
diff -up glade-gtk2-1.12.svn/chthonic.glade glade-gtk2-1.70.0/chthonic.glade >glade-112svn-1700_chthonic.diff
crossfire
which crossfire
whereis
whereis crossfire
file /usr/local/bin/crossfire
ls /usr/local/bin/crossfire
ls /usr/local/bin/crossfire/bin
rmdir /usr/local/bin/crossfire
rmdir /usr/local/bin/crossfire/bin
rmdir /usr/local/bin/crossfire
which crossfire-client-gtk1v2-1.12.svn
which crossfire-client-gtk2-1.70.0
mv start_cpu_freq cpu_freq_scaling.init
mv cpu_freq_scaling.init ./Driver
mv ./Driver cpu_freq_scaling.init
mv cpu_freq_scaling.init ./DRIVER
mv start_cpu_freq cpu_freq_scaling.init
git commit
git commit --short
git add cpu_freq_scaling.init
git commit
git mv start_cpu_freq cpu_freq_scaling.init
pwd
git commit
git mv cpu_freq_scaling.init start_cpu_freqORIG
modinfo cpufreq_governor
modinfo cpufreq_ondemand
ls -ld /sys/devices/system/cpu/cpu0/cpufreq
ls -ld /sys/devices/system/cpu/cpu0/cpufreq/
ls -ld /sys/devices/system/cpu/cpu0/cpufreq/*
cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_transition_latency
ls -l /sys/devices/system/cpu/cpufreq/${GOVERNOR}/
ls -l /sys/devices/system/cpu/cpufreq/ondemand/
cat /sys/devices/system/cpu/cpufreq/ondemand/ignore_nice_load 
cat /sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor 
cat /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
cat /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate_min
cat /sys/devices/system/cpu/cpufreq/ondemand/up_threshold 
echo 25 >/sys/devices/system/cpu/cpufreq/ondemand/up_threshold
cat /sys/devices/system/cpu/cpufreq/ondemand/up_threshold 
echo 225 >/sys/devices/system/cpu/cpufreq/ondemand/up_threshold
cat /sys/devices/system/cpu/cpufreq/ondemand/up_threshold 
echo 99 >/sys/devices/system/cpu/cpufreq/ondemand/up_threshold
cat /sys/devices/system/cpu/cpufreq/ondemand/up_threshold 
echo 100 >/sys/devices/system/cpu/cpufreq/ondemand/up_threshold
cat /sys/devices/system/cpu/cpufreq/ondemand/up_threshold 
echo 125 >/sys/devices/system/cpu/cpufreq/ondemand/up_threshold
cat /sys/devices/system/cpu/cpufreq/ondemand/up_threshold 
echo 1 >/sys/devices/system/cpu/cpufreq/ondemand/up_threshold
cat /sys/devices/system/cpu/cpufreq/ondemand/up_threshold 
echo 1 >/sys/devices/system/cpu/cpufreq/ondemand/up_threshold
cat /sys/devices/system/cpu/cpufreq/ondemand/up_threshold 
echo 10 >/sys/devices/system/cpu/cpufreq/ondemand/up_threshold
cat /sys/devices/system/cpu/cpufreq/ondemand/up_threshold 
echo 20 >/sys/devices/system/cpu/cpufreq/ondemand/up_threshold
cat /sys/devices/system/cpu/cpufreq/ondemand/up_threshold 
echo 15 >/sys/devices/system/cpu/cpufreq/ondemand/up_threshold
cat /sys/devices/system/cpu/cpufreq/ondemand/up_threshold 
echo 11 >/sys/devices/system/cpu/cpufreq/ondemand/up_threshold
cat /sys/devices/system/cpu/cpufreq/ondemand/up_threshold 
echo 10 >/sys/devices/system/cpu/cpufreq/ondemand/up_threshold
cat /sys/devices/system/cpu/cpufreq/ondemand/up_threshold 
echo 110 >/sys/devices/system/cpu/cpufreq/ondemand/up_threshold
cat /sys/devices/system/cpu/cpufreq/ondemand/up_threshold 
echo 101 >/sys/devices/system/cpu/cpufreq/ondemand/up_threshold
cat /sys/devices/system/cpu/cpufreq/ondemand/up_threshold 
echo 100 >/sys/devices/system/cpu/cpufreq/ondemand/up_threshold
cat /sys/devices/system/cpu/cpufreq/ondemand/up_threshold 
ls -l /sys/devices/system/cpu/cpufreq/ondemand/
cat /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
echo 20000 >/sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
cat /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
echo 200000 >/sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
cat /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
echo 2000000 >/sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
cat /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
echo 20000000 >/sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
cat /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
echo 200000000 >/sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
cat /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
echo 2000000000 >/sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
cat /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
echo 20000000000 >/sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
cat /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
cat /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate_min
echo 0 >/sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
cat /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate_min
echo 200000 >/sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
cat /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate_min
echo 0 >/sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
cat /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
echo 200000 >/sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
cat /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
echo 20000 >/sys/devices/system/cpu/cpufreq/ondemand/sampling_rate_min
echo 99 >/sys/devices/system/cpu/cpufreq/ondemand/up_threshold
cat /sys/devices/system/cpu/cpufreq/ondemand/up_threshold
ls /sys/devices/system/cpu/cpufreq/ondemand/
/etc/init.d/runmbbservice restart
cfclient
./cfclient
diff /root/my-applications/sbin/cfclient ./cfclient
cfclient
diff /root/my-applications/sbin/cfclient ./cfclient
diff -qs /root/my-applications/sbin/cfclient ./cfclient
cfclient
ifconfig
top
export GTK2_RC_FILES=/root/.crossfire/crossfire_gtkrc-2.0 
crossfire-client-gtk1v2-1.12.svn 
pidof crossfire-client-gtk1v2-1.12.svn
kill -9 16354
crossfire-client-gtk2-1.70.0 
crossfire-client-gtk2-1.70.0 -server crossfire.metalforge.net
crossfire-client-gtk2-1.12.svn -server crossfire.metalforge.net
realpath /usr/local/share/crossfire-client/glade
ifconfig
ln -snf glade-gtk2-1.12.svn glade-gtk2
cfclient
export GTK2_RC_FILES=/root/.crossfire/crossfire_gtkrc-2.0 
crossfire-client-gtk2-1.70.0
crossfire-client-gtk2-1.12.svn
/etc/init.d/runmbbservice restart
/etc/init.d/runmbbservice stop
/etc/init.d/runmbbservice start
/etc/init.d/runmbbservice restart
grep -I -i reset *
pupx
/etc/init.d/runmbbservice restart
man xorg.conf
git mv bb_mkbd_acpid.init-OLD bb_mkbd_acpid.initOLD
git mv bb_mkbd_acpid.init-VERYOLD bb_mkbd_acpid.initVERYOLD
git commit
which xlsfonts
type -a xlsfonts
xlsfonts --help
find /usr -name "*xlsfonts*"

Mon Jul 20 10:22:16 GMT+1 2015

df
partprobe
probepart
probedisk
mount /dev/sdc1
mount /dev/sdd1
/etc/init.d/runmbbservice restart
killall fbxkb
exec fbxkb &
cfclient
ifconfig

Tue Jul 21 02:54:24 GMT+1 2015

/etc/init.d/runmbbservice restart
echo $((48*40))

Tue Jul 21 10:28:32 GMT+1 2015

ifconfig
/etc/init.d/runmbbservice restart
./git_helper/replace_commit_files.sh 
