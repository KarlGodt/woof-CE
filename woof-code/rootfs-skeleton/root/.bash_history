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
./replace_commit_files.sh 
top

Thu Dec 25 20:08:34 GMT+1 2014

ls /dev/inpu*
ls -l /dev/inpu*
ls -l /dev/in*
ls -l /dev/ev*
ls -l /dev/m*
ls -l /dev/input/mouse0 /dev/mouse0
ln -s /dev/input/mouse0 /dev/mouse0
ls -l /dev/m*
grep -i mouse /var/log/xwin/Xorg.3.7.10-KRG-i486-smp-pae-lzo-mini.2014-12-25-20\:08\:35.log 
ls -l /dev/m*
ls -l /dev/min*
ls -l /dev/in*
ls /proc/bus/input
ls /proc/bus/input/devices
grep -i mouse  /proc/bus/input/devices
grep -B10 -A10 -i mouse  /proc/bus/input/devices
less /proc/bus/input/devices
 wmexit
uname -r
env x='{ :; }; while [ 2 ];do echo background program running;sleep 10;done' geany 
env x='{ :; }; while [ 1 ];do echo background program running;sleep 10;done' geany 
env x='{ :; };' geany 
env x='{ while [ 1 ];do echo background program running;sleep 10; done; };' geany 
x
env x='{ while [ 1 ];do echo background program running;sleep 10; done; }' geany 
env x='{ while [ 1 ];do echo background program running;sleep 10; done; }'
x
env x='{ while [ 1 ];do echo background program running;sleep 10; done; }' bash -c geany
env x='{ while [ 1 ];do echo background program running;sleep 10; done; } ; echo vulnerable' bash -c geany
x
eval x
 $x
eval $x
echo $x
env x='{ :; } ; echo vulnerable' bash -c geany
env x='{ :; } ; echo vulnerable' bash -c "echo This is a test"
env x='{ :; } ; echo vulnerable; bash -c' echo "This is a test"
env x='{ :; }  echo vulnerable; bash -c' echo "This is a test"
env x='{ :; }  echo vulnerable bash -c' echo "This is a test"
env x='{ :; }  echo vulnerable' bash -c echo "This is a test"
env x='{ :; };  echo vulnerable' bash -c echo "This is a test"
env x='{ :; };  echo vulnerable bash -c' echo "This is a test"
env x='{ :; };echo vulnerable bash -c' echo "This is a test"
env x='{ :; };echo vulnerable; bash -c' echo "This is a test"
env x='{ :; };echo vulnerable' bash -c echo "This is a test"
export PATH=`pwd`/bin:`pwd`/sbin:$PATH
echo $PATH
export LD_LIBRARY_PATH=`pwd`/lib:$LD_LIBRARY_PATH
wine
wine /mnt/sdb1/Program Files/ABBYY FineReader 6.0 Sprint/Sprint.exe
wine "/mnt/sdb1/Program Files/ABBYY FineReader 6.0 Sprint/Sprint.exe"
wine "/mnt/sdb1/Program Files/Crossfire GTK Client/GTKClient.exe"
wine "/mnt/sdb1/Program Files/Internet Explorer/iexplore.exe"
wine "/mnt/sdb1/Program Files/Mozilla Firefox/firefox.exe"
find -size +6m
find -size +6M
hexedit /mnt/sdb1/Users/User/Music/FD136d01
file /Desktop-Hintergrund-640x480x16+A-dith.xpm
ffmpeg-sc-sh-0.8.10 -help
ffmpeg-sc-sh-0.8.10 -help 2>&1 | grep -i mtv

Fri Dec 26 18:46:18 GMT+1 2014

grub
mplayer "/mnt/sdd1/Dokumente und Einstellungen/Admin/Eigene Dateien/Eigene Videos/Video 1.MOV"
df
smartctl -A /dev/sdd
smartctl -A -d sat /dev/sdd
echo $((7497/24))
mplayer "/mnt/sdd1/Dokumente und Einstellungen/Admin/desktop/bushido/18 Nichts Ist F?r Immer.m4a"
ffplay "/mnt/sdd1/Dokumente und Einstellungen/Admin/desktop/bushido/18 Nichts Ist F?r Immer.m4a"
mplayer "/mnt/sdd1/Dokumente und Einstellungen/Admin/desktop/bushido/16 Schick Mir Einen Engel.m4a"

Fri Dec 26 21:07:46 GMT+1 2014

for i in *.jpg; do echo $i; done
for i in *.jpg; do echo "$i"; done
for i in *.jpg; do echo "$i"; convert "$i" "$i".png;done
for i in *.png; do mv "$i" ./PNG/; done
for i in *; do base=${i%%.*};echo $base-640x480.png;done
for i in *; do base=${i%%.*};convert -geometry 640x480 "$i" "$base"-640x480.png;done
F=`ls *640x480*`
echo $F
convert $F albanyouth.gif
convert -adjoin $F albanyouth.gif
for i in *; do mv "$i" "${i// /_/}"; done
for i in *; do mv "$i" "${i// /_}"; done
F=`ls *640x480*`
echo $F
convert -adjoin $F albanyouth.gif
convert -adjoin -delay 5 $F albanyouth.gif
convert -adjoin -delay 5000 $F albanyouth.gif
convert -adjoin -delay 50 $F albanyouth.gif
convert -adjoin -delay 500 $F albanyouth.gif
man conjure
man convert
conjure --help

Sat Dec 27 17:07:17 GMT+1 2014

wmexit
uname /r
uname -r
xmodmap pp
xmodmap -pp
xmodmap -pp | ./busybox-orig sed -n '/ *[0-9] *[0-9]/p'
./configure --prefix=`pwd`/_install
make
./configure --prefix=`pwd`/_install
make
info /root/COMPILE/Sed/sed-3.01/_install/info/sed.info
xmodmap -pp | ./sed -n '/ *[0-9] *[0-9]/p'
info grep
man grep
info /root/COMPILE/Sed/sed-4.0.7/_install/info/sed.info
./configure --prefix=`pwd`/_install
make
make install
./configure --prefix=`pwd`/_install
make
make install
xmodmap -pp
xmodmap -pp | sed -n '/ *[0-9] *[0-9]/p'
xmodmap -pp | busybox sed -n '/ *[0-9] *[0-9]/p'
xmodmap -pp | busybox_1.18.3_STATIC_upx9_648KB sed -n '/ *[0-9] *[0-9]/p'
xmodmap -pp | ./busybox-1.1.3-ST-99all-1897KB sed -n '/ *[0-9] *[0-9]/p'
chroot .

Sun Dec 28 15:08:38 GMT+1 2014

geany /sbin/init
fbsplash --help
uname -r

Sun Dec 28 15:30:44 GMT+1 2014

ASH
ash
_do_fbsplash(){ [ "$FBSPLASH_DONE" ] && return 1; PICURE=/boot/grub/boot-splash.ppm; test "$1" && PICTURE="$1"; test -f "$PICTURE" || return 2; DEVICE=/dev/fb0; test "$2" && DEVICE="$2"; test -e "$DEVICE" || return 3; fbsplash -s "$PICTURE" -d "$DEVICE"; if test $? = 0; then FBSPLASH_DONE=1; return 0; fi; return $?; }
_do_fbsplash; echo $?
ls /boot/grub/boot-splash.ppm
echo $PICTURE
echo $DEVICE
_do_fbsplash "/boot/grub/boot-splash.ppm" "/dev/fb0"
_do_fbsplash "/boot/grub/boot-splash.ppm" "/dev/fb0"; echo $?
_do_fbsplash "/boot/grub/boot-splash1.ppm" "/dev/fb0"; echo $?
echo $FBSPLASH_DONE 
FBSPLASH_DONE=
_do_fbsplash "/boot/grub/boot-splash1.ppm" "/dev/fb0"; echo $?
echo $FBSPLASH_DONE 
_do_fbsplash "/boot/grub/boot-splash.ppm" "/dev/fb0"; echo $?
echo $FBSPLASH_DONE 
FBSPLASH_DONE=
_do_fbsplash "/boot/grub/boot-splash.ppm" ""; echo $?
echo $FBSPLASH_DONE 
_do_fbsplash "" ""; echo $?
FBSPLASH_DONE=
_do_fbsplash "" ""; echo $?
FBSPLASH_DONE=
_do_fbsplash ""; echo $?
FBSPLASH_DONE=
_do_fbsplash; echo $?
FBSPLASH_DONE=
_do_fbsplash; echo $?
_do_fbsplash(){ [ "$FBSPLASH_DONE" ] && return 1; PICURE=/boot/grub/boot-splash.ppm; test "$1" && PICTURE="$1"; test -f "$PICTURE" || return 1; DEVICE=/dev/fb0; test "$2" && DEVICE="$2"; test -e "$DEVICE" || return 1; fbsplash -s "$PICTURE" -d "$DEVICE"; if test $? = 0; then FBSPLASH_DONE=1; return 0; fi; return $?; }
_do_fbsplash;echo $?

Sun Dec 28 15:42:57 GMT+1 2014


Sun Dec 28 17:41:48 GMT+1 2014

grub --batch <<EoI >>/tmp/md5crypt.txt
type -a grub
info grub

Sun Dec 28 20:24:44 GMT+1 2014

uname /r
uname -r

Sun Dec 28 22:43:27 GMT+1 2014

info grub
grep -r -m1 grub_open *
grep get_cmdline *
pwd
./configure --help
chmod +x configure
chmod +x config.sub
chmod +x config.guess
./configure --help
./configure --prefix=`pwd`/_install
make.tgl
make
make install
/boot/COMPILE/Grub-Again/Grub4dos/grub4dos-0.4.4/_install/lib/grub/i386-pc/bootlace.com --help
chmod +x --help
chmod +x 2014
chmod +x grub
pwd
chmod +x /boot/COMPILE/Grub-Again/Grub4dos/grub4dos-0.4.4/_install/lib/grub/i386-pc/bootlace.com
/boot/COMPILE/Grub-Again/Grub4dos/grub4dos-0.4.4/_install/lib/grub/i386-pc/bootlace.com --help
grep -r -i title *

Mon Dec 29 13:18:42 GMT+1 2014

mksquashfs4 COMPILE/ grub-everything.sfs
mksquashfs4 Sed/ SED.sfs

Mon Dec 29 14:44:18 GMT+1 2014


Mon Dec 29 15:31:34 GMT+1 2014

./replace_commit_files.sh 
make
info ./grub.info
make info
make pdf

Wed Dec 31 13:51:29 GMT+1 2014

./ApplyPatches.sh 
find -name "*.rej"
tar czf grub-0.95-fedora-13.tar.gz grub-0.95-fedora-13/
pwd
./ApplyPatches.sh 
tar czf grub-0.97-fedora-5.tar.gz grub-0.97-fedora-5/
./ApplyPatches.sh 
tar czf grub-0.97-fedora8-19.tar.gz grub-0.97-fedora8-19/
./ApplyPatches.sh 
tar czf grub-0.97-fedora-13.tar.gz grub-0.97-fedora-13/
./ApplyPatches.sh 
tar czf grub-0.97-fedora9-33.tar.gz grub-0.97-fedora9-33/
./ApplyPatches.sh 
tar czf grub-0.97-fedora14-66.tar.gz grub-0.97-fedora14-66/
./ApplyPatches.sh 
tar czf grub-0.97-mandriva2008.1-22.tar.gz grub-0.97-mandriva2008.1-22/
tar czf grub-0.97-mandriva2008.0-20.tar.gz grub-0.97-mandriva2008.0-20/
./ApplyPatches.sh 
tar czf grub-0.97-mandriva2009.0-24.tar.gz grub-0.97-mandriva2009.0-24/
./ApplyPatches.sh 
tar czf grub-0.97-mandriva2010.0-29.tar.gz grub-0.97-mandriva2010.0-29/
./ApplyPatches.sh 
tar czf grub-0.97-mandriva2009.1-25.tar.gz grub-0.97-mandriva2009.1-25/

./ApplyPatches.sh 
tar czf grub-0.97-mandriva2010.1-30.tar.gz grub-0.97-mandriva2010.1-30/
geany /etc/rc.d/f4puppy5
man patch
make
ls ..
patch -p1 -bz .mandriva <../gfxboot-3.3.18-mdv.patch 
make
./mkbootmsg --help
./mkblfont --help
./mkblfont -v
./addblack --help
./bin2c --help
./bincode --help
make
make
make -i
patch -Np1 -i ../special-devices.patch
patch -Np1 -i ../i2o.patch
patch -Np1 -i ../more-raid.patch
patch -Np1 -i ../intelmac.patch
patch -Np1 -i ../grub-inode-size.patch
patch -Np1 -i ../ext4.patch
patch -Np1 -i ../grub-0.97-ldflags-objcopy-remove-build-id.patch
patch -Np1 -i ../automake-pkglib.patch
patch -Np1 -i ../grub-0.97-graphics.patch
tar czf grub-0.97-arch-splash.tar.gz grub-0.97-arch-splash/
./ApplyPatches.sh 
./ApplyPatches.sh 
script --help
script patch.log
script patch.log

Thu Jan 1 16:02:10 GMT+1 2015


Thu Jan 1 23:07:04 GMT+1 2015

geany /usr/sbin/filemnt
geany '/root/my-roxapps/unknown_mime_handler.sh'
git commit
git add init
git commit -m '/init: Added old-style pivot_root switch.
Revert bootcnt.txt logic.'
gtit add sbin/switch
git add sbin/switch
git commit -m '/sbin/switch: Added old-style pivot_root switch.'
git add initOLD
git add sbin/switchOLD
git commit -m 'initOLD, sbin/switchOLD : Code backup.'
cd ..
pwd
git commit
git pull /mnt/sdb19/SRC/F3p5/WOOF/GitHub.d/KarlGodt_WoofFork.Push.d/
fixitup

Fri Jan 2 20:01:14 GMT+1 2015

./0D665d01 
find -size +5M
find -size +10M
find -size +2M

Sat Jan 3 18:28:43 GMT+1 2015

find -size +2M
find -maxdepth 7 -name "*{ED7BA470-8E54-465E-825C-99712043E01C}"
find -maxdepth 8 -name "*{ED7BA470-8E54-465E-825C-99712043E01C}"
find -maxdepth 9 -name "*{ED7BA470-8E54-465E-825C-99712043E01C}"
find -maxdepth 9 -name "*ED7BA470-8E54-465E-825C-99712043E01C*"
find -name "*ED7BA470-8E54-465E-825C-99712043E01C*"
find -iname "*ED7BA470-8E54-465E-825C-99712043E01C*"
guvcview 

Sun Jan 4 10:29:15 GMT+1 2015

convert --hlp
for i in *; do echo $i; done
for i in *; do echo $i; convert -geometry 160x120 $i $i-160x120.gif;done
GF=`ls -1 *.gif`
echo $GF
convert -adjoin -delay 200 $GF sample.gif
convert -adjoin -loop 0 -delay 200 $GF sample0.gif
convert -adjoin -loop 1 -delay 200 $GF sample1.gif
convert -adjoin -loop -1 -delay 200 $GF sample-1.gif
convert -geometry 100x100 sample-1.gif sample-1-100x100.gif
convert -geometry 80x80 sample-1.gif sample-1-80x80.gif
guvcview 

Tue Jan 6 00:59:14 GMT+1 2015

mount

Tue Jan 6 16:39:53 GMT+1 2015

qqqqqq[]
xkbconfigmanager 
dmesg
modinfo ehci-pci
modprobe -vr mei
modprobe -l | grep android
modprobe -v logger
modprobe -v timed_gpio
modprobe -l | grep i2c
modprobe -v i2c-gpio
modprobe -v i2c-pii4x
modprobe -v i2c-piix4
modprobe -v i2c-intel-mid
modprobe -v i2c-pca-platform
modprobe -v i2c-i801
modprobe -v i2c-hid
modprobe -v i2c-smbus
grep -i android *
uname -r
probedisk2
probepart
dmesg | tail
dmesg 

Tue Jan 6 22:00:03 GMT+1 2015

mount
mount /dev/sr1
pppoe-discovery 
pppoe-discovery --help
pppoe-discovery -h
pppoe-sniff -h
pppoe-sniff
pppoe-start
mkdir test
cd test
ftpget --help
ftpget 192.168.1.1 /bin/busybox
ftpget -P 21 192.168.1.1 /bin/busybox
ftpget -P 21 192.168.1.1 /bin/b*
ftpget -P 21 192.168.1.1 /bin/
ftpget -P 21 192.168.1.1 /sbin
ftpget -P 21 192.168.1.1 /
tftp --help
tftp -g -r /bin/busybox 192.168.1.1 21
ls
pwd
ftp --help
ftp -h
man telnet
man sshd
man ssh
sns
echo $((1024x64))
echo $((1024*64))

Wed Jan 7 03:34:24 GMT+1 2015

geany /usr/sbin/sns
geany /etc/resolv.conf
geany `which netsetup.sh`
geany `which net-setup.sh`
net-setup.sh 
grep -e 'net-setup' /usr/share/applications/*
geany /usr/local/net_setup/usr/sbin/net-setup.sh
which net-setup.sh
geany /usr/sbin/net-setup.sh
which sns
type -a ifplugstatus
file /sbin/ifplugstatus
chmod +x /etc/dhcpcd.sh
geany `which ipinfo`
sns
geany /usr/local/simple_network_setup/rc.network
sns
ifconfig
ifconfig -a
sns
net-setup.sh 
ps | grep dhcpcd
ps | grep dhcpcd
killall dhcpcd
ps | grep dhcpcd
killall dhcpcd
ps | grep dhcpcd
killall dhcpcd
top
killall -9 superscan
man dhcpcd

Wed Jan 7 13:21:31 GMT+1 2015

./update_files.sh 
geany /usr/sbin/wag-profiles.sh 
geany /usr/sbin/ndiswrapperGUI.sh 
net-setup.sh
sns
ps | grep dhcpcd
man dhcpcd
man -w gzip
man -w gzip;echo $?
man -w netsetup;echo $?
net-setup.sh
man net-setup;echo $?
man man
net-setup.sh
man net_setup
man net
man netsetup
man net-setup
net-setup.sh
type -a net-setup.sh
/usr/sbin/net-setup.sh
help timeout
timeout --help
/usr/sbin/net-setup.sh

Thu Jan 8 20:45:15 GMT+1 2015

./configure
./configure --help
./configure
make
./configure
./autogen.sh 
./configure
./autogen.sh 
./configure
make
./configure
make
./configure
./configure
probedisk
probedisk2
probepart
modprobe -l | grep android
modinfo logger
modprobe -v logger
modinfo timed_gpio
modprobe -v timed_gpio
modprobe -l | grep usb
modprobe -l | grep scsi
modprobe -l | grep ide
modprobe -l | grep ata
modprobe -l | grep sata
modprobe -l | grep scsi
modprobe -l | grep scsi | while read mod; do echo $mod;done
modprobe -l | grep scsi | while read mod; do echo $mod;insmod /lib/modules/`uname -r`/$mod;sleep 1;done
modprobe -v i2o_scsi
modprobe -l | grep scsi | while read mod; do echo $mod;busybox insmod /lib/modules/`uname -r`/$mod;sleep 1;done
type -a insmod
file /bininsmod
file /bin/insmod
modprobe -l | grep scsi | while read mod; do echo $mod;/sbin/insmod /lib/modules/`uname -r`/$mod;sleep 1;done
strace /lib/modules/3.9.9-KRG-iCore2-smp-pae-srv1000gz/kernel/drivers/target/iscsi/iscsi_target_mod.ko
strace /sbun/insmod /lib/modules/3.9.9-KRG-iCore2-smp-pae-srv1000gz/kernel/drivers/target/iscsi/iscsi_target_mod.ko
strace /sbin/insmod /lib/modules/3.9.9-KRG-iCore2-smp-pae-srv1000gz/kernel/drivers/target/iscsi/iscsi_target_mod.ko
insmod --help
/sbin/insmod --help
man insmod
make
./dog
./dog --help
fixitup
dmesg
lsusb
lspci
dmesg
/tmp/go-mtpfs-20130628/go-mtpfs-20130628/usr/bin/go-mtpfs
/tmp/go-mtpfs-20130628/go-mtpfs-20130628/usr/bin/go-mtpfs --help
/mnt/sdb19/PET.D/Android/go-mtpfs-20130628/go-mtpfs-20130628/usr/bin/go-mtpfs --help
dmesg
modprobe -vr mei
killall -9 go-mtpfs
killall -9 mount
umount -f /mnt/MTPdevice
umount /mnt/MTPdevice
mount
cat /etc/mtab
file /etc/mtab
cat /etc/mtab
cat /etc/fstab
ls /mnt/MTPdevice
file /mnt/MTPdevice
go-mtpfs /mnt/MTPdevice
umount -f /mnt/MTPdevice
ls /bin/mount
ls /bin/mount*
ln -sf mount-old /bin/mount
go-mtpfs /mnt/MTPdevice
ln -sf mount-orig /bin/mount
go-mtpfs /mnt/MTPdevice
mkdir /mnt/MTPdevice
go-mtpfs /mnt/MTPdevice
fusermount --version
go-mtpfs --help
go-mtpfs --android=true /mnt/MTPdevice
go-mtpfs -android=true /mnt/MTPdevice
pwd
ls
source /etc/profile
pwd
help pushd
dirs
help popd
popd
pwd
fixitup
killall ROX-Filer
killall -9 ROX-Filer
fixitup
pidof mount
killall -9 mount
mount-old
killall -9 mount
umount -f /mnt/MTPdevice
killall -9 mount
umount -f /mnt/MTPdevice
pwd
mount
./mtpdevice
./mtpdevice mount
./mtpdevice umount
./mtpdevice mount
./mtpdevice
./mtpdevice mount
./mtpdevice
./mtpdevice mount
/mnt/sdb19/PET.D/Android/mtp_detect-0.8-exper-noarch/mtp_detect-0.8-exper-noarch/usr/sbin/mtpdevice
ls
pwd
/mnt/pup_420-sfs4.sfs/usr/bin/fusermount
/mnt/pup_420-sfs4.sfs/usr/bin/fusermount --version
ln -sf mount-FULL /bin/mount
go-mtpfs /mnt/MTPdevice
grep Locked /etc/mtab
grep Locked /etc/fstab
ln -sf mount.sh /bin/mount
filemnt /mnt/sdb19/ISO.D/PUPPY/Quirky-1.3/puppy.sfs
grep loop /proc/mounts
mkdir /mnt/q
mount-FULL -o loop /mnt/sdb19/ISO.D/PUPPY/Quirky-1.3/puppy.sfs /mnt/q
mount-FULL -type squashfs -o loop /mnt/sdb19/ISO.D/PUPPY/Quirky-1.3/puppy.sfs /mnt/q
mount-FULL -t squashfs -o loop /mnt/sdb19/ISO.D/PUPPY/Quirky-1.3/puppy.sfs /mnt/q
filemntOLD /mnt/sdb19/ISO.D/PUPPY/Quirky-1.3/zdrv.sfs
filemnt /mnt/sdb19/ISO.D/PUPPY/Quirky-1.3/zdrv.sfs
geany `which filemnt`
filemnt /mnt/sdb19/ISO.D/PUPPY/Quirky-1.3/zdrv.sfs
disktypr /mnt/sdb19/ISO.D/PUPPY/Quirky-1.3/zdrv.sfs
disktype /mnt/sdb19/ISO.D/PUPPY/Quirky-1.3/zdrv.sfs
file /mnt/sdb19/ISO.D/PUPPY/Quirky-1.3/zdrv.sfs
filemnt /mnt/sdb19/ISO.D/PUPPY/Quirky-1.3/zdrv.sfs
filemnt /mnt/sdb19/ISO.D/PUPPY/Quirky-1.3/puppy.sfs
tail -n2 /mnt/sdb19/ISO.D/PUPPY/Quirky-1.3/puppy.sfs
hexedit /mnt/sdb19/ISO.D/PUPPY/Quirky-1.3/puppy.sfs
./update_files_from_running_system 
filemnt /mnt/sda1/PUPPY_SFS/fd64_611/initrd.d/kernel-modules.sfs
file /mnt/sda1/PUPPY_SFS/fd64_611/initrd.d/kernel-modules.sfs
disktype /mnt/sda1/PUPPY_SFS/fd64_611/initrd.d/kernel-modules.sfs
ls bin/fus*
ls sbin/fus*
cd ..
ls sbin/fus*
pwd
ls bin/fus*
bin/fusermount --help
type -a fusermount
/sbin/fusermount --version
/usr/bin/fusermount --version
file /usr/bin/fusermount
file /sbin/fusermount
./update_files_from_running_system 
cd /mnt/sdb19/ISO.D/PUPPY/Quirky-1.3/
ls
ls -s
unsquashfs4 puppy.sfs 
unsquashfs3 puppy.sfs 
unsquashfs --help
unsquashfs -l puppy.sfs
unsquashfs3 -l puppy.sfs
unsquashfs3 -l puppy.sfs;echo $?
unsquashfs3 -s puppy.sfs;echo $?
unsquashfs4 -s puppy.sfs;echo $?
filemnt /mnt/sdb19/ISO.D/PUPPY/Quirky-1.3/puppy.sfs
filemnt ./zdrv.sfs
hexedit ./zdrv.sfs
go-mtpfs /mnt/MTPdevice
mkdir /mnt/MTPdevice
go-mtpfs /mnt/MTPdevice
mkdir /mnt/MTPdevice
go-mtpfs /mnt/MTPdevice
killall -9 mount
mount -i -f -t fuse.Locked(DeviceFs(Arch -o rw,nosuid,nodev Locked(DeviceFs(Arch /mnt/MTPdevice
mount -i -f -t fuse.Locked(DeviceFs(Arch -o rw,nosuid,nodev 'Locked(DeviceFs(Arch' /mnt/MTPdevice
mount -i -f -t 'fuse.Locked(DeviceFs(Arch' -o rw,nosuid,nodev 'Locked(DeviceFs(Arch' /mnt/MTPdevice
mount /dev/sdb15
umount /dev/sdb15
mount /dev/sdb15 /mnt/sdb15
umount -lrf /mnt/sdb15
a=$"\"\n\""
echo "'$a'"
a=$"\n"
echo "'$a'"
a=$"\\n"
echo "'$a'"
a=$'\n'
echo "'$a'"
a=$'"\n"'
echo "'$a'"
printf "%o" \'
killall mkdir
killall -9 mkdir
killall -9 grep
killall -9 awk
killall -9 test
killall -ls
killall ls
killall -9 ls
killall -9 mount
echo -e " \0114\0157\0143\0153\0145\0144\050\0104\0145\0166\0151\0143\0145\0106\0163\050\0101\0162\0143\0150 \057\0155\0156\0164\057\0115\0124\0120\0144\0145\0166\0151\0143\0145"
echo -e "'\012'"
mkdir -p /mnt/MTPdevice
go-mtpfs /mnt/MTPdevice
mkdir /mnt/MTPdevice
go-mtpfs /mnt/MTPdevice
dmesg
mount
uname -r
rox --help
killall ROX-Filer
killall -9 ROX-Filer
fixitup
killall -9 ls
killall -9 find
ps
kill -9 5069
kill -9 5260
kill -9 5402
killall vlc
ps
killall -9 mount
ps
mount
ls /mnt
ls /mnt/MTPdevice
file /mnt/MTPdevice
which go-mtpfs
ldd /root/my-applications/bin/go-mtpfs
find /usr -name "libusb*"
find /usr -name "libusb*" | sort -d
file /usr/local/lib/libusb.so
file /usr/local/lib/libusb-1.0.so
file /usr/local/lib/libusb
file /usr/local/lib/libusb-0.1.so.4
killall -9 fuser
killall -9 umount
killall -9 fuser
killall -9 umount
mount
killall -9 umount
mount
ls /mnt/MTPdevice
killall fusermount
ps | grep fusermount
killall -9 fusermount
mount
killall -9 fusermount
killall -9 umount
mount
killall -9 umount
mount
rox
killall ROX-Filer
killall -9 ROX-Filer
fixitup
mount
umount -l /dev/loop0
mount
umount -l /dev/loop7
umount -l /dev/loop6
umount -l /dev/loop5
umount -l /dev/loop4
umount -l /dev/loop3
umount -l /dev/loop1
mount
umount /dev/sdb2
umount /mnt/sdb2
umount /mnt/sdb1
fusermount -u /mnt/MTPdevice
umount -f /mnt/MTPdevice
umount -lfr /mnt/MTPdevice
geany /bin/mount.sh
mount
umount /mnt/MTPdevice
mount
umount /mnt/sdb7
mount
umount /mnt/sda1
mount
umount /mnt/sdb19
geany /etc/rc.d/f4puppy5

Fri Jan 9 03:24:42 GMT+1 2015

killall -9 mkdir
killall -9 grep
ps
killall -9 mount
mount
git log
git log --grep usb
git log --grep usb_ch9.h
git log --grep 'Dec.*2006'
git log --grep 'Linux 2\.6'
./update_files.sh
geany /root/.profile
ls woof-code/rootfs-skeleton/usr/sbin/pman
ls woof-code/rootfs-skeleton/usr/bin/pman
file woof-code/rootfs-skeleton/usr/bin/pman
file /usr/bin/pman
which pman
diff z99_alsa DRIVER/z99_alsa 
diff mount DEFAULT/mount 
./Xorg -version
./Xorg-1.3.0.0 -version
./Xorg-1.3.0. -version
./Xorg-1.3.0 -version
./Xorg-1-3-0-0 -version
./Xorg --version
./Xorg -version
killall -9 ls
grep -i endpoint /usr/include/linux/*
ls -d /usr/include*
grep -i endpoint /usr/include_orig/linux/*
grep -i endpoint /usr/include/linux/usb/*
grep -i endpoint /usr/include_orig/linux/usb/*
grep -i endpoint /usr/include_orig/linux/*
ls /mnt
ls /mnt/MTPdevice
killall -9 mount
killall -9 fusermount
grep -i endpoint /usr/lib/libusb*
grep -i endpoint /usr/local/lib/libusb*
ps
killall -9 mkdir
killall -9 ls
mount
ls /mnt/MTPdevice
mount
killall ls
killall -9 ls
mount
ps | grep mount
killall fusermount
killall -9 fusermount
mount
ps | grep mount
killall -9 mount
mount
ps | grep mount
ls /mnt/MTPdevice
find /usr -name "libusb*" | sort
go-mtpfs /mnt/MTPdevice
mkdir -p /mnt/MTPdevice
go-mtpfs /mnt/MTPdevice
ls /mnt
ls /mnt/MTPdevice
dmesg
uname /r
uname -r
dmesg
ls /mnt/MTPdevice
ls /mnt/MTPdevice/"Interner Speicher"
ls /mnt/MTPdevice/"Interner Speicher"/System
ls /mnt/MTPdevice/"Interner Speicher"/Android
ls /mnt/MTPdevice/SD-Karte
ls -a /mnt/MTPdevice/SD-Karte
ls /mnt/MTPdevice/"Interner Speicher"/Android
ls -a /mnt/MTPdevice/"Interner Speicher"
ls -a /mnt/MTPdevice/"Interner Speicher"/System
ls -a /mnt/MTPdevice/"Interner Speicher"/tools
ls -a /mnt/MTPdevice/"Interner Speicher"/Android
ls -a /mnt/MTPdevice/"Interner Speicher"/Android/obb
ls -a /mnt/MTPdevice/"Interner Speicher"/Android/data
man fusermount
fusermount --help
ln -sf mount-mtp /bin/mount
mount
mount.sh
tail -n1 /proc/mounts
man mount
killall -9 strace
killall -9 fusermount
mount
killall -9 fusermount
mount
killall -9 fusermount
killall -9 mount
mount
killall -9 mount
mount
mount-FULL --help
mount-FULL --version
mount-FULL
mount
ps | grep mount
ps | grep umount
ps | grep fuse
fusermount -uz /mnt/MTPdevice
mount
mount-FULL
fusermount -uz /mnt/MTPdevice
go-mtpfs /mnt/MTPdevice
probedisk
strace go-mtpfs /mnt/MTPdevice
strace go-mtpfs /mnt/MTPdevice 2>go_mtpfs_ptp.strace
pwd
strace go-mtpfs /mnt/MTPdevice 2>go_mtpfs_mtp.strace
mkdir /mnt/MTPdevice
strace go-mtpfs /mnt/MTPdevice 2>go_mtpfs_mtp.strace
ps | grep mount
killall -9 mount
ps | grep mount
mount
ls /sys/fs/fuse
ls /sys/fs/fuse/connections
go-mtpfs -help
go-mtpfs -debug=usb -allow-other=true /mnt/MTPdevice
go-mtpfs -debug=fuse -allow-other=true /mnt/MTPdevice
fusermount -uz /mnt/MTPdevice
umount -lf /mnt/MTPdevice
go-mtpfs -debug=fuse -allow-other=true /mnt/MTPdevice
mkdir /mnt/MTPdevice
go-mtpfs -debug=fuse -allow-other=true /mnt/MTPdevice
mount -i -f -t fuse.Locked(DeviceFs(Arch -o rw,nosuid,nodev,allow_other Locked(DeviceFs(Arch /mnt/MTPdevice
mount -i -f -t fuse.Locked(DeviceFs(Arch -o rw,nosuid,nodev,allow_other 'Locked(DeviceFs(Arch' /mnt/MTPdevice
mount -i -f -t 'fuse.Locked(DeviceFs(Arch' -o rw,nosuid,nodev,allow_other 'Locked(DeviceFs(Arch' /mnt/MTPdevice
mount -f -t 'fuse.Locked(DeviceFs(Arch' -o rw,nosuid,nodev,allow_other 'Locked(DeviceFs(Arch' /mnt/MTPdevice
mount -t 'fuse.Locked(DeviceFs(Arch' -o rw,nosuid,nodev,allow_other 'Locked(DeviceFs(Arch' /mnt/MTPdevice
mkdir /mnt/MTPdevice
mount -t 'fuse.Locked(DeviceFs(Arch' -o rw,nosuid,nodev,allow_other 'Locked(DeviceFs(Arch' /mnt/MTPdevice
/sbin/fusermount /mnt/MTPdevice -o subtype='Locked(DeviceFs(Arch'
ln -sf mount-FULL /bin/mount
/sbin/fusermount /mnt/MTPdevice -o subtype='Locked(DeviceFs(Arch'
mount -t 'fuse.Locked(DeviceFs(Arch' -o rw,nosuid,nodev,allow_other 'Locked(DeviceFs(Arch' /mnt/MTPdevice
mkdir /mnt/MTPdevice
mount -t 'fuse.Locked(DeviceFs(Arch' -o rw,nosuid,nodev,allow_other 'Locked(DeviceFs(Arch' /mnt/MTPdevice
dmesg | tail
go-mtpfs -debug=data -allow-other=true /mnt/MTPdevice
go-mtpfs -help
go-mtpfs -debug=mtp -allow-other=true /mnt/MTPdevice
chmod +x /bin/mount-mtp
go-mtpfs -debug=mtp -allow-other=true /mnt/MTPdevice
dmesg 
go-mtpfs -debug=mtp -allow-other=true /mnt/MTPdevice
go-mtpfs -debug=usb -allow-other=true /mnt/MTPdevice
mkdir /mnt/MTPdevice
go-mtpfs -debug=usb -allow-other=true /mnt/MTPdevice
dmesg
dmesg
dmesg
killall udevd
adevadm --trgger
udevadm --trgger
udevadm --trigger
udevadm --help
udevadm trigger
udevd --help
udevd --version
pidof udevd
udevd --daemon
udevadm trigger
udevd --daemon
udevadm trigger
udevd --daemon
udevadm trigger
ln -sf mount.sh /bin/mount
umount /mnt/sdb14
umount /mnt/sdb1
mount /dev/sdb14
mount /dev/sdb1
umount /mnt/sdb1
mount -t ntfs /dev/sdb1
geany /var/log/xwin/Xerrs.2.6.31.14-core2-Flens-Gold-dirty.2015-01-09-03\:24\:46.Xorg.log 
mount
umount /dev/sdb1
umount /dev/sdb14
mount
umount /dev/loop1
umount /dev/loop0
mount
umount /dev/sdb19
mount
timeout -s 9 -t 4 umount -lf /mnt/MTPdevice
timeout --help
timeout -t 4 -s 9 umount -lf /mnt/MTPdevice
timeout -t 4 -s 9 /bin/umount -lf /mnt/MTPdevice
timeout -t 4 -s 9 /bin/umount /mnt/MTPdevice
umount /dev/sdb19
grep 'grep .* \*' /bin/mount.sh
grep 'grep.*\*' /bin/mount.sh

Sat Jan 10 07:46:13 GMT+1 2015

git commit
git add woof-code/rootfs-skeleton/bin/mount-mtp
git add woof-code/rootfs-skeleton/bin/mountMTP
git add woof-code/rootfs-skeleton/bin/mountMTP.sh
git add woof-code/rootfs-skeleton/bin/umountMTP
git commit -m '(u)mountMTP : Scripts added for MTP mounts.'
mountMTP
umountMTP
mountMTP
umountMTP
geany /usr/sbin/
geany /usr/local/bin/defaultaudioplayer
aqualung --help
mount6
mount

Sun Jan 11 11:16:28 GMT+1 2015

ffplay "/mnt/sdc11/MSC.d/p7/VIDEOS/TRASH/THUNDHERSTRUCK LIVE - Rockin' the Rivers 2007 (SD).RoQ"
ffplay "/mnt/sdc11/MSC.d/p7/VIDEOS/TRASH/THUNDHERSTRUCK-All girl AC-DC tribute band (Low).mpeg2video"
./ffconvert_FlashW0uJfx.sh 
mkdir /root/test
./ffconvert_FlashW0uJfx.sh 
ffconvert
lame -h
lame --preset help
lame --longhelp
mpg123 -h
type -a ffmpeg
/usr/bin/ffmpeg
file /usr/bin/ffmpeg
/usr/local/bin/ffmpeg
type -a ffmpeg
type -a ffconvert
file /usr/bin/ffconvert
geany /usr/bin/ffconvert-0.9
ffmpeg -i /mnt/sda1/VID/MSC/Flash.d/FlashW0uJfx.mp4
ffmpeg-0.5.8-mov -i /mnt/sda1/VID/MSC/Flash.d/FlashW0uJfx.mp4
ffmpeg-0.5.13 -i /mnt/sda1/VID/MSC/Flash.d/FlashW0uJfx.mp4
ffmpeg-0.6.7 -i /mnt/sda1/VID/MSC/Flash.d/FlashW0uJfx.mp4
ffmpeg-sc-0.6.5 -i /mnt/sda1/VID/MSC/Flash.d/FlashW0uJfx.mp4
ffconvert
man lame
LC_ALL=C man lame
lavinfo
mencoder --help
mencoder -help
man mencoder
mencoder -oac help
mencoder -of help
man ffmpeg
which lav2avi.sh
geany /usr/local/bin/lav2avi.sh
lavtrans --help
lav2mpeg --help
mpeg2enc --help
sox FlashVh1Zth.mp4 FlashVh1Zth.mp3
ffmpeg -codecs
ps | grep -i aqua
which aqualung
file /usr/bin/aqualung
geany /usr/bin/aqualung
aqualung-new
ffmpeg -formats
LC_ALL=C man ffmpeg
ffmpeg /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashVh1Zth.mp4 -f mp3 /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashVh1Zth.mp3
ffmpeg /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashVh1Zth.mp3 -f mp3 /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashVh1Zth.mp4
ffmpeg -i /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashVh1Zth.mp4 -f mp3 /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashVh1Zth.mp3
ffmpeg-0.9.3 -i /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashVh1Zth.mp4 -f mp3 /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashVh1Zth.mp3
ffmpeg-0.8.15 -i /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashVh1Zth.mp4 -f mp3 /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashVh1Zth.mp3
ffmpeg-0.8.10-pic -i /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashVh1Zth.mp4 -f mp3 /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashVh1Zth.mp3
ffmpeg-0.8.10-pic -i /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashVh1Zth.mp4 -f mp3  -acodec copy /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashVh1Zth.mp3
aqualung --play /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashVh1Zth.mp3
ffmpeg-0.8.10-pic -i /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashVh1Zth.mp4 -f mp3  -acodec mp3 /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashVh1Zth.mp3
ffmpeg-0.8.10-pic -i /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashVh1Zth.mp4 -f mp3  -acodec aac /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashVh1Zth.mp3
ffmpeg-0.8.10-pic -strict experimental -i /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashVh1Zth.mp4 -f mp3  -acodec aac /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashVh1Zth.mp3
ffmpeg-0.8.10-pic -i /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashVh1Zth.mp4 -f mp3  -strict experimental #-acodec aac /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashVh1Zth.mp3
ffmpeg-0.8.10-pic -i /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashVh1Zth.mp4 -f mp3  -strict experimental -acodec aac /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashVh1Zth.mp3
aqualung --play /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashVh1Zth.mp3
ffmpeg-0.8.10-pic -i /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashVh1Zth.mp4 -f mp3  -strict experimental -acodec msmpeg /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashVh1Zth.mp3
ffmpeg-0.8.10-pic -i /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashVh1Zth.mp4 -f mp3  -strict experimental -acodec msmpeg4 /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashVh1Zth.mp3
ffmpeg-0.8.10-pic -i /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashVh1Zth.mp4 -f mp3  -strict experimental -acodec mp1 /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashVh1Zth.mp3
ffmpeg-0.8.10-pic -i /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashVh1Zth.mp4 -f mp3  -strict experimental -acodec mp2 /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashVh1Zth.mp3
aqualung --play /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashVh1Zth.mp3
ffmpeg-0.9.3 -i /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashW0uJfx.mp4 -f mp3  -strict experimental -acodec mp2 /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashW0uJfx.mp3
ffmpeg-0.8.15 -i /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashW0uJfx.mp4 -f mp3  -strict experimental -acodec mp2 /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashW0uJfx.mp3
defaultaudioplayer /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashW0uJfx.mp3
aqualung --play /mnt/sda1/VID/MSC/Flash.d/Saxon/FlashW0uJfx.mp3
man sox
man /usr/local/man/man1/cue2toc.1
man --help
man -f mp3
man -k mp3
man -K mp3
for i in *; do realpath $i; done
for i in *.mp4; do realpath $i; done
for i in *.mp4; do F=`realpath $i`; bnF=`basename $F .mp4`;echo $bnF;done
for i in *.mp4; do F=`realpath $i`; bnF=`basename $F .mp4`;lame $i $bnF.mp3;done
for i in *.mp4; do F=`realpath $i`; bnF=`basename $F .mp4`;mencoder $i $bnF.mp3;done
for i in *.mp4; do F=`realpath $i`; bnF=`basename $F .mp4`;mencoder -i $i -o $bnF.mp3;done
for i in *.mp4; do F=`realpath $i`; bnF=`basename $F .mp4`;mencoder $i -o $bnF.mp3;done
for i in *.mp4; do F=`realpath $i`; bnF=`basename $F .mp4`;mencoder -oac mp3 $i -o $bnF.mp3;done
for i in *.mp4; do F=`realpath $i`; bnF=`basename $F .mp4`;mencoder -oac mp3lame $i -o $bnF.mp3;done
for i in *.mp4; do F=`realpath $i`; bnF=`basename $F .mp4`;mencoder -oac mp3lame -of mp3 $i -o $bnF.mp3;done
for i in *.mp4; do F=`realpath $i`; bnF=`basename $F .mp4`;mencoder -oac mp3lame -of mpeg $i -o $bnF.mp3;done
for i in *.mp4; do F=`realpath $i`; bnF=`basename $F .mp4`;ffmpeg -i $i -o $bnF.mp3;done
for i in *.mp4; do F=`realpath $i`; bnF=`basename $F .mp4`;ffmpeg -i $i $bnF.mp3;done
for i in *.mp4; do F=`realpath $i`; bnF=`basename $F .mp4`;echo $bnF;done
for i in *.mp4; do F=`realpath $i`; bnF=`basename $F .mp4`;lame -b 128 -2 $i $bnF.mp3;done
for i in *.mp4; do F=`realpath $i`; bnF=`basename $F .mp4`;lame -b 128 -mj $i $bnF.mp3;done
for i in *.mp4; do nf=`basename $i .mp4`; ffmpeg-0.8.15 -i $i -f mp3 -acodec mp2 $nf.mp3; sleep 1; done
for i in *.mp4; do nf=`basename $i .mp4`; ffmpeg-0.8.15 -i $i -f mp3 -acodec mp2 -ac 2 -y $nf.mp3; sleep 1; done
for i in *; do case $i in *.*)continue;;esac;echo $i; done
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file $i`; case $F in *MPEG4*) echo IS MP4;;*Flash*) echo is flash;;esac;done
file 352D26E1d01
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file $i`; case $F in *MPEG*v4) echo IS MP4;;*Flash*) echo is flash;;esac;done
file 352D26E1d01
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file $i`; case $F in *MPEG*v4*) echo IS MP4;;*Flash*) echo is flash;;esac;done
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file $i`; case $F in *MPEG*v4*) echo IS MP4;mv $i $i.mp4;;*Flash*) echo is flash; mv $i $i.flv;;esac;done
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file $i`; case $F in *MPEG*v4*) echo IS MP4;;*Flash*) echo is flash;;esac;done
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file $i`; case $F in *MPEG*v4*) echo IS MP4;mv $i $i.mp4;;*Flash*) echo is flash; mv $i $i.flv;;esac;done
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file $i`; case $F in *MPEG*v4*) echo IS MP4;;*Flash*) echo is flash;;esac;done
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file $i`; case $F in *MPEG*v4*) echo IS MP4;mv $i $i.mp4;;*Flash*) echo is flash; mv $i $i.flv;;esac;done
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file $i`; case $F in *MPEG*v4*) echo IS MP4;;*Flash*) echo is flash;;esac;done
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file $i`; case $F in *MPEG*v4*) echo IS MP4;mv $i $i.mp4;;*Flash*) echo is flash; mv $i $i.flv;;esac;done
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file $i`; case $F in *MPEG*v4*) echo IS MP4;;*Flash*) echo is flash;;esac;done
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file $i`; case $F in *MPEG*v4*) echo IS MP4;mv $i $i.mp4;;*Flash*) echo is flash; mv $i $i.flv;;esac;done
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file $i`; case $F in *MPEG*v4*) echo IS MP4;;*Flash*) echo is flash;;esac;done
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file $i`; case $F in *MPEG*v4*) echo IS MP4;mv $i $i.mp4;;*Flash*) echo is flash; mv $i $i.flv;;esac;done
for i in *.mp4; do nf=`basename $i .mp4`; ffmpeg-0.8.15 -i $i -f mp3 -acodec mp2 -ac 2 -y $nf.mp3; sleep 1; done
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file $i`; case $F in *MPEG*v4*) echo IS MP4;;*Flash*) echo is flash;;esac;done
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file $i`; case $F in *MPEG*v4*) echo IS MP4;mv $i $i.mp4;;*Flash*) echo is flash; mv $i $i.flv;;esac;done
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file $i`; case $F in *MPEG*v4*) echo IS MP4;;*Flash*) echo is flash;;esac;done
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file $i`; case $F in *MPEG*v4*) echo IS MP4;mv $i $i.mp4;;*Flash*) echo is flash; mv $i $i.flv;;esac;done
for i in *.mp4; do nf=`basename $i .mp4`; ffmpeg-0.8.15 -i $i -f mp3 -acodec mp2 -ac 2 -y $nf.mp3; sleep 1; done
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file $i`; case $F in *MPEG*v4*) echo IS MP4;;*Flash*) echo is flash;;esac;done
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file "$i"`; case $F in *MPEG*v4*) echo IS MP4;;*Flash*) echo is flash;;esac;done
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file "$i"`; case $F in *MPEG*v4*) echo IS MP4;mv "$i" "$i".mp4;;*Flash*) echo is flash; mv $i "$i".flv;;esac;done
for i in *.mp4; do nf=`basename $i .mp4`; ffmpeg-0.8.15 -i $i -f mp3 -acodec mp2 -ac 2 -y $nf.mp3; sleep 1; done
for i in *.mp4; do nf=`basename "$i" .mp4`; ffmpeg-0.8.15 -i "$i" -f mp3 -acodec mp2 -ac 2 -y "$nf".mp3; sleep 1; done
for i in *.mp4; do nf=`basename $i .mp4`; ffmpeg-0.8.15 -i $i -f mp3 -acodec mp2 -ac 2 -y $nf.mp3; sleep 1; done
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file "$i"`; case $F in *MPEG*v4*) echo IS MP4;mv "$i" "$i".mp4;;*Flash*) echo is flash; mv $i "$i".flv;;esac;done
for i in *.mp4; do nf=`basename "$i" .mp4`; ffmpeg-0.8.15 -i "$i" -f mp3 -acodec mp2 -ac 2 -y "$nf".mp3; sleep 1; done
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file "$i"`; case $F in *MPEG*v4*) echo IS MP4;mv "$i" "$i".mp4;;*Flash*) echo is flash; mv $i "$i".flv;;esac;done
for i in *.mp4; do nf=`basename "$i" .mp4`; ffmpeg-0.8.15 -i "$i" -f mp3 -acodec mp2 -ac 2 -y "$nf".mp3; sleep 1; done
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file "$i"`; case $F in *MPEG*v4*) echo IS MP4;mv "$i" "$i".mp4;;*Flash*) echo is flash; mv $i "$i".flv;;esac;done
for i in *.mp4; do nf=`basename "$i" .mp4`; ffmpeg-0.8.15 -i "$i" -f mp3 -acodec mp2 -ac 2 -y "$nf".mp3; sleep 1; done
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file "$i"`; case $F in *MPEG*v4*) echo IS MP4;mv "$i" "$i".mp4;;*Flash*) echo is flash; mv $i "$i".flv;;esac;done
for i in *.mp4; do nf=`basename "$i" .mp4`; ffmpeg-0.8.15 -i "$i" -f mp3 -acodec mp2 -ac 2 -y "$nf".mp3; sleep 1; done
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file "$i"`; case $F in *MPEG*v4*) echo IS MP4;mv "$i" "$i".mp4;;*Flash*) echo is flash; mv $i "$i".flv;;esac;done
for i in *.mp4; do nf=`basename "$i" .mp4`; ffmpeg-0.8.15 -i "$i" -f mp3 -acodec mp2 -ac 2 -y "$nf".mp3; sleep 1; done
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file "$i"`; case $F in *MPEG*v4*) echo IS MP4;mv "$i" "$i".mp4;;*Flash*) echo is flash; mv $i "$i".flv;;esac;done
for i in *.mp4; do nf=`basename "$i" .mp4`; ffmpeg-0.8.15 -i "$i" -f mp3 -acodec mp2 -ac 2 -y "$nf".mp3; sleep 1; done
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file "$i"`; case $F in *MPEG*v4*) echo IS MP4;mv "$i" "$i".mp4;;*Flash*) echo is flash; mv $i "$i".flv;;esac;done
for i in *.mp4; do nf=`basename "$i" .mp4`; ffmpeg-0.8.15 -i "$i" -f mp3 -acodec mp2 -ac 2 -y "$nf".mp3; sleep 1; done
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file "$i"`; case $F in *MPEG*v4*) echo IS MP4;mv "$i" "$i".mp4;;*Flash*) echo is flash; mv $i "$i".flv;;esac;done
for i in *.mp4; do nf=`basename "$i" .mp4`; ffmpeg-0.8.15 -i "$i" -f mp3 -acodec mp2 -ac 2 -y "$nf".mp3; sleep 1; done
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file "$i"`; case $F in *MPEG*v4*) echo IS MP4;mv "$i" "$i".mp4;;*Flash*) echo is flash; mv $i "$i".flv;;esac;done
for i in *.mp4; do nf=`basename "$i" .mp4`; ffmpeg-0.8.15 -i "$i" -f mp3 -acodec mp2 -ac 2 -y "$nf".mp3; sleep 1; done
ffmpeg-0.8.15 -i FlashC0mPIo.flv -f mp3 -acodec mp2 -ac 2 FlashC0mPIo.mp3
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file "$i"`; case $F in *MPEG*v4*) echo IS MP4;mv "$i" "$i".mp4;;*Flash*) echo is flash; mv $i "$i".flv;;esac;done
for i in *.mp4; do nf=`basename "$i" .mp4`; ffmpeg-0.8.15 -i "$i" -f mp3 -acodec mp2 -ac 2 -y "$nf".mp3; sleep 1; done
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file "$i"`; case $F in *MPEG*v4*) echo IS MP4;;*Flash*) echo is flash;;esac;done
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file "$i"`; case $F in *MPEG*v4*) echo IS MP4;mv "$i" "$i".mp4;;*Flash*) echo is flash; mv $i "$i".flv;;esac;done
for i in *.mp4; do nf=`basename "$i" .mp4`; ffmpeg-0.8.15 -i $i -f mp3 -acodec mp2 -ac 2 -y "$nf".mp3; sleep 1; done
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file $i`; case $F in *MPEG*v4*) echo IS MP4;;*Flash*) echo is flash;;esac;done
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file $i`; case $F in *MPEG*v4*) echo IS MP4;mv $i $i.mp4;;*Flash*) echo is flash; mv $i $i.flv;;esac;done
for i in *.mp4; do nf=`basename $i .mp4`; ffmpeg-0.8.15 -i $i -f mp3 -acodec mp2 -ac 2 -y $nf.mp3; sleep 1; done
for i in *; do nf=`basename $i .mp4`; ffmpeg-0.8.15 -i $i -f mp3 -acodec mp2 -ac 2 -y $nf.mp3; sleep 1; done
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file "$i"`; case $F in *MPEG*v4*) echo IS MP4;mv "$i" "$i".mp4;;*Flash*) echo is flash; mv $i "$i".flv;;esac;done
for i in *.mp4; do nf=`basename "$i" .mp4`; ffmpeg-0.8.15 -i "$i" -f mp3 -acodec mp2 -ac 2 -y "$nf".mp3; sleep 1; done
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file "$i"`; case $F in *MPEG*v4*) echo IS MP4;mv "$i" "$i".mp4;;*Flash*) echo is flash; mv $i "$i".flv;;esac;done
for i in *.mp4; do nf=`basename "$i" .mp4`; ffmpeg-0.8.15 -i "$i" -f mp3 -acodec mp2 -ac 2 -y "$nf".mp3; sleep 1; done
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file "$i"`; case $F in *MPEG*v4*) echo IS MP4;mv "$i" "$i".mp4;;*Flash*) echo is flash; mv $i "$i".flv;;esac;done
for i in *.mp4; do nf=`basename "$i" .mp4`; ffmpeg-0.8.15 -i "$i" -f mp3 -acodec mp2 -ac 2 -y "$nf".mp3; sleep 1; done
for i in *; do case $i in *.*)continue;;esac;echo $i; F=`file "$i"`; case $F in *MPEG*v4*) echo IS MP4;mv "$i" "$i".mp4;;*Flash*) echo is flash; mv $i "$i".flv;;esac;done
for i in *.mp3; do cp -a "$i" /mntf/MTPdev/SD-Karte/MSC/2015-01-11/MA/ || break; sleep 3; done
for i in *.mp3; do cp -a "$i" /mntf/MTPdev/SD-Karte/MSC/2015-01-11/JoanJet/ || break; sleep 3; done
for i in *.mp3; do cp -a "$i" /mntf/MTPdev/SD-Karte/MSC/2015-01-11/Billy/ || break; sleep 3; done
for i in *.mp3; do cp -a "$i" /mntf/MTPdev/SD-Karte/MSC/2015-01-11/Motörhead/ || break; sleep 3; done
for i in *.mp3; do cp -au "$i" /mntf/MTPdev/SD-Karte/MSC/2015-01-11/Motörhead/ || break; sleep 3; done
for i in *.mp3; do cp -au "$i" /mntf/MTPdev/SD-Karte/MSC/2015-01-11/JoanJet/ || break; sleep 3; done
for i in *.mp3; do cp -au "$i" /mntf/MTPdev/SD-Karte/MSC/2015-01-11/Genesis/ || break; sleep 3; done
mkdir 70s
mkdir Billy
mkdir Crow
mkdir JoanJet
mkdir MA
mkdir Motörhead
mkdir Genesis
for i in *.mp3; do cp -a "$i" /mntf/MTPdev/SD-Karte/MSC/2015-01-11/Crow/ || break; sleep 3; done
for i in *.mp3; do cp -a "$i" /mntf/MTPdev/SD-Karte/MSC/2015-01-11/70s/ || break; sleep 3; done
mountMTP
umountMTP
mount
umountMTP
mountMTP
for i in *.flv; do nf=`basename "$i" .mp4`; ffmpeg-0.8.15 -i "$i" -f mp3 -acodec mp2 -ac 2 -y "$nf".mp3; sleep 1; done
man ffmpeg
for i in *.flv; do nf=`basename "$i" .flv`; ffmpeg-0.8.15 -i "$i" -f mp3 -acodec mp2 -ac 2 -y "$nf".mp3; sleep 1; done
umountMTP
mountMTP
umountMTP
mount

Mon Jan 12 18:23:12 GMT+1 2015


Tue Jan 13 14:21:06 GMT+1 2015

for i in *; do case $i in *.*) continue;;esac;echo $i;done
for i in *; do case $i in *.*) continue;;esac;file $i;done
for i in *; do case $i in *.*) continue;;esac;mv "$i" "$i".mp4;done
cd /mntf/MTPdev/NAND\ FLASH/
ls
vd VideoClips/
cd VideoClips/
ls
for i in Flash*;do echo $i; done
for i in Flash*;do mv "$i" "$i".mp4; done
pwd
umountMTP
mountMTP
dmesg
busybox top
echo $((5319/1600))
echo $((5319/2666))
echo $((5319/2600))
ls /cproc/c*
ls /proc/c*
cat /proc/cmdline
ls -l /proc/c*
find /sys -type d -name "cpu*"
cd /sys/devices/system/cpu/
ls -l
cat uevent
cat release
cat present
cat possible 
cat online 
cat offline 
cat modalias 
cat kernel_max 
cd cpu0
ls -l
cd topology
ls -l
cat core_id
cat core_siblings
cat core_siblings_list 
cat physical_package_id 
cat thread_siblings
cat thread_siblings_list
cat /proc/cpuinfo
grep -h -I '.\+' /proc/*
grep -h -I '.\+' /proc/[^k]*
grep -H -I '.\+' /proc/[^k]*
grep -H -I '.\+' /proc/[^k]* >/root/proc.txt
lsusb
geany /et/rc.d/rc.sysinit.run
geany /etc/rc.d/rc.sysinit.run
grep -i 'nox' /proc/cmdline
geany /usr/bin/xwin
basename $(readlink -f $(which X))
wine
which wirelesswizard
file /usr/sbin/wirelesswizard
geany /usr/sbin/wirelesswizard
which wag

Wed Jan 14 18:39:14 GMT+1 2015

for i in }< do file $i< done
for i in *; do file $i; done
for i in *; do mv "$i" "$i".flv; done
for i in *; do file $i; done
for i in *; do file $i | grep -i flash || continue; done
for i in *; do file $i 2>&1 | grep -i 'flash video' || continue; done
for i in *; do file $i 2>&1 | grep -i 'flash video' || continue; mv "$i" "$i".flv;done
for i in *; do file $i 2>&1 | grep -i 'MPEG' || continue; mv "$i" "$i".mp4;done
for i in *; do file $i 2>&1 | grep -i 'flash video' || continue; mv "$i" "$i".flv;done
for i in Flash*; do file $i 2>&1 | grep -i 'flash video' || continue; mv "$i" "$i".flv;done
for i in *; do file $i 2>&1 | grep -i 'MPEG' || continue; mv "$i" "$i".mp4;done
for i in Flash*; do file $i 2>&1 | grep -i 'flash video' || continue; mv "$i" "$i".flv;done
for i in Flash*; do file $i 2>&1 | grep -i 'MPEG' || continue; mv "$i" "$i".mp4;done
for i in Flash*; do file $i 2>&1 | grep -i 'flash video' || continue; mv "$i" "$i".flv;done
for i in Flash*; do file $i 2>&1 | grep -i 'MPEG' || continue; mv "$i" "$i".mp4;done
for i in Flash*; do case $i in *.*)continue;;esac;file $i 2>&1 | grep -i 'MPEG' || continue; mv "$i" "$i".mp4;done
for i in *; do case $i in *.*)continue;;esac;file $i 2>&1 | grep -i 'MPEG' || continue; mv "$i" "$i".mp4;done
for i in *; do case $i in *.*)continue;;esac;file $i 2>&1 | grep -i 'flash video' || continue; mv "$i" "$i".flv;done
for i in plugin*; do file $i 2>&1 | grep -i 'flash video' || continue; mv "$i" "$i".flv;done
for i in plugin*; do file $i 2>&1 | grep -i 'MPEG' || continue; mv "$i" "$i".mp4;done
for i in Flash*; do file $i 2>&1 | grep -i 'MPEG' || continue; mv "$i" "$i".mp4;done

Sun Jan 18 14:50:37 GMT+1 2015

geany /usr/bin/xwin
for i in *.mp4;do test -e "$i" || continue; echo "$i"; done
for i in *.mp4;do test -e "$i" || continue; echo "$i"; cp "$i" "/mntf/MTPdev/NAND FLASH/VideoClips/AcDc"/;done
for i in *.flv;do test -e "$i" || continue; echo "$i"; cp "$i" "/mntf/MTPdev/NAND FLASH/VideoClips/AcDc"/;done
umountMTP
mountMTP
for i in *; do test -d "$i" || continue;echo $i; done
for i in *; do test -d "$i" || continue;echo $i; for j in "$i"/.swf; do test -e "$j" || continue; echo "$j";done;done
for i in *; do test -d "$i" || continue;echo $i; for j in "$i"/*.swf; do test -e "$j" || continue; echo "$j";done;done
for i in *; do test -d "$i" || continue;echo $i; for j in "$i"/*.swf; do test -e "$j" || continue; echo "$j";bn=${j%.*}; echo "$bn";done;done
for i in *; do test -d "$i" || continue;echo $i; for j in "$i"/*.swf; do test -e "$j" || continue; echo "$j";bn=${j%.*}; echo "$bn";mv "$j" "$bn".flv;done;done
who
which who
file /bin/who
who --help
who -aH

Fri Jan 23 21:14:36 GMT+1 2015

fixitup
find size +2M
find -size +2M
file ./6/6B/35DEFd01
file ./6/EE/BB2CBd01
file ./D/52/46AF2d01
defaultmediaplayer ./D/52/46AF2d01
du -s -BM .
find -size +2M
file ./A/6A/CC8E6d01
file ./6/6B/35DEFd01
file ./6/EE/BB2CBd01
find -size +2M
pwd
cd ../..
ls
cd 8eguvdtc.3.5/
ls
cd Cache/
find -size +2M
cat ,
cat .
cat plugin-crossdomain.xml 
pwd
ls
ls /sys/class/net
ls /sys/class/net/eth1
ls -F /sys/class/net/eth1
ls -F /sys/class/net/eth1/*
ls -F /sys/class/net/eth1/statistics
cat /sys/class/net/eth1/statistics/rx_bytes
cat /sys/class/net/eth1/statistics/tx_bytes
cat /sys/class/net/eth1/statistics/rx_bytes
cat /sys/class/net/eth1/statistics/tx_bytes
cat /sys/class/net/eth1/statistics/rx_bytes
cat /sys/class/net/eth1/statistics/tx_bytes
cat /sys/class/net/eth1/statistics/rx_bytes
echo $((41469799/8))
echo $((41469799/1024))
cat /sys/class/net/eth1/statistics/rx_bytes
cat /sys/class/net/eth1/statistics/tx_bytes
cat /sys/class/net/eth1/statistics/rx_bytes
killall sylpheed
sylpheed
net-setup.sh
./autorun.sh
ifconfig -a

Sat Jan 24 15:34:24 GMT+1 2015

./git_pull_all_directories-03.sh 
./replace_commit_files.sh 
git branch
git push krg Fox3-Dell755
git remote -v
git push MSkrg Fox3-Dell755
cfclient-1.10.0
gcfclient2-1.11.0-sdl-dmeta2-O2 
gcfclient1-1.11.0
net-setup.sh 
ps | grep mbb
ifconfig
ifconfig /a
ifconfig -a
ifconfig
ifconfig -a

Mon Jan 26 12:36:40 GMT+1 2015

./Script-cp2android 
umountMTP
mountMTP
modprobe -v usb-video
modprobe -l | grep usb
modprobe -l | grep usb | grep video
modprobe -v usbvision
mountMTP
dmesg
guvcview
modprobe -v usb-storage
dmesg
modprobe -v ptp
modprobe -l | grep mtp
modprobe -l | grep ptp
modinfo ptp
find -name "FlashwgVN*"
find -name "FlashwgVN*"

Wed Feb 18 18:09:45 GMT+1 2015

probedisk
ls -l /mnt/sdc1/swapfile.swp
chmod +w /mnt/sdc1/swapfile.swp
ls -l /mnt/sdc1/swapfile.swp
chmod 0777 /mnt/sdc1/swapfile.swp
ls -l /mnt/sdc1/swapfile.swp
mount
swapon /mnt/sdc1/swapfile.swp
cat /proc/swaps
swapoff /mnt/sdc1/swapfile.swp
cat /proc/swaps
chown
chown root:ystem /mnt/sdc1/swapfile.swp
chown root:system /mnt/sdc1/swapfile.swp
ls -l /mnt/sdc1/swapfile.swp
chown -c root:system /mnt/sdc1/swapfile.swp
swapon /mnt/sdc1/swapfile.swp
file /mnt/sdc1/swapfile.swp
blkid /mnt/sdc1/swapfile.swp
disktype /mnt/sdc1/swapfile.swp
disktype /dev/sdb21
probedisk
probedisk2
probepart /d&dev&sdc
probepart -d/dev/sdc
probepart -d /dev/sdc
probepart /dev/sdc
file /sbin/probepart
probepart2.09
probepart2.09 /dev/sdc
grep -r -i port *
grep -r -i -m3 port *
grep -r -i port * | grep -v -E 'report|support'
grep -r -i port * | grep -v -i -E 'report|support'
grep -r -i port * | grep -v -i -E 'report|support|export'
find -name "*port*"
mount
umount /mnt/sdc1
fuser -m /mnt/sdc1
cat /proc/swaps
swapoff /mnt/sdc1/swapfile.swp
cat /proc/swaps
umount /mnt/sdc1
dd if=/dev/zero of=swapfile.swp bs=$((1024*1024)) count=512
mkswap --help
mkswap -L SWAP /mnt/sdc1/swapfile.swp
swapon /mnt/sdc1/swapfile.swp
swapon /mnt/sdd1/swapfile.swp
cat /proc/swaps
swapoff /mnt/sdc1/swapfile.swp
swapoff /mnt/sdd1/swapfile.swp
cat /proc/swaps
probedisk
geany /bin/mount
geany /etc/rc.d/f4puppy5
geany /usr/local/bin/drive_all
./update_files_from_running_system 
grep pstopwatch *
git commit
git add pstopwatch/
git commit -m '/usr/local/pstopwatch: Added.'
ps | grep -v '\['
xmessage --help
xmessage -help
ptimer
pstopwatch
which ptimer
file /usr/local/bin/ptimer
geany /usr/local/bin/ptimer
geany /usr/local/ptimer/ptimer
./android
mount
pstopwatch 
df

Fri Feb 20 17:17:23 GMT+1 2015

mountMTP
umountMTP
df

Mon Mar 2 23:32:27 GMT+1 2015

mountMTP
cp -a "/mntf/MTPdev/NAND FLASH" /mnt/sdc1/
df
ls /sys/block
umountMTP
umount /mnt/sdc1
umount /mnt/sdd1
dmesg

Thu Mar 5 17:38:50 GMT+1 2015

pgprs-connect
  geany /usr/bin/pgprs-connect
pgprs-connect -F
Thu Mar 5 17:38:50 GMT+1 2015
exit
wget https://www.youtube.com/v/1FlQCtg96SQ
wget --no-check-certificate https://www.youtube.com/v/1FlQCtg96SQ
pwd
/android
./android
free
df
ps | grep fire
top
unzip --help
type -a unzip
file /usr/bin/unzip
/usr/bin/unzip --help
/usr/bin/unzip -t /root/Android/android-sdk-linux/temp/docs-21_r01.zip
df
du /root/Android/android-sdk-linux/temp/android-17_r03.zip
du -BM /root/Android/android-sdk-linux/temp/android-17_r03.zip
du /root/Android/android-sdk-linux/temp/docs-21_r01.zip
ps | grep java
du /root/Android/android-sdk-linux/temp/docs-21_r01.zip
type -a cp
file /bin/cp
cp --help
cp -au /root/Android /mnt/sdb16
help fc
fc -l
fc fc -l make
fc fc -l make make
man fc
fc --help
info fc
mountMTP
umountMTP
umountMTP
dmesg
ls -l /dev/ttyUSB*
ls -l /dev/ttyA*
ls -l /dev/tty*
ls -l /dev/[A-Z]*
lsusb
dmesg | grep cfs
/usr/sbin/usb_modeswitch.sh -v 0x19d2 -p 0x2000 -V 0x19d2 -P 0x0031 -M '55534243123456782000000080000c85010101180101010101000000000000'
lsusb
geany /usr/sbin/usb_modeswitch.sh
/usr/sbin/usb_modeswitch.sh -v 0x19d2 -p 0x2000 -V 0x19d2 -P 0x0031 -M '55534243123456782000000080000c85010101180101010101000000000000'
dmesg
cat /var/log/xwin/Xerrs.3.9.9-KRG-iCore2-smp-pae-srv1000gz.2015-03-05-17\:38\:51.Xorg.log 
probepart
man mount
modprobe -l | grep -i zte
modprobe -v zte_ev
modprobe -v option
dmesg
modem-stats /dev/ttyUSB0
modem-stats /dev/ttyUSB1
modem-stats /dev/ttyUSB2
modprobe -vr mei
mount
mount /dev/sr2
modem-stats -c 'AT+CMGL' /dev/ttyUSB2
modem-stats -c 'AT+CMGL' /dev/ttyUSB1
modem-stats -c 'AT+CMGL' /dev/ttyUSB0
modem-stats -c 'AT+CMGF?' /dev/ttyUSB2
modem-stats -c 'AT+CMGR' /dev/ttyUSB2
modem-stats -c 'AT+CMGR=1' /dev/ttyUSB2
modem-stats -c 'AT+CMGR?' /dev/ttyUSB2
modem-stats -c 'AT+CMGF?' /dev/ttyUSB2
modem-stats -c 'AT+CMGF=?' /dev/ttyUSB2
modem-stats -c 'AT+CMGF=1' /dev/ttyUSB2
modem-stats -c 'AT+CMGL' /dev/ttyUSB2
geany /sbin/pup_event_frontend_d
geany /tmp/usb_modeswitch.log
modprobe -l | grep option
pgprs-connect -F
dmesg
ppgprs-setup
pgprs-setup
pgprs-connect
dmesg
pgprs-shell
file /usr/sbin/pgprs-shell
pgprs-setup
723
modem-stats /dev/ttyUSB1
modem-stats -c AT*CLAC /dev/ttyUSB1
modem-stats -c 'AT+CLAC' /dev/ttyUSB1
modem-stats -c 'AT+CPIN?' /dev/ttyUSB1
modem-stats -c 'AT+CSMS?' /dev/ttyUSB1
modem-stats -c 'AT+GCSMS?' /dev/ttyUSB1
modem-stats -c 'AT+GCSMS?' /dev/ttyUSB0
modem-stats -c 'AT+GCSMS?' /dev/ttyUSB2
modem-stats -c 'AT+CSMS?' /dev/ttyUSB0
modem-stats -c 'AT+CMER?' /dev/ttyUSB1
modem-stats -c 'AT+CMGR?' /dev/ttyUSB1
modem-stats -c 'AT+CMGR' /dev/ttyUSB1
modem-stats -c 'AT+CMGS' /dev/ttyUSB1
modem-stats -c 'AT+CMGS?' /dev/ttyUSB1
modem-stats -c 'AT+CRSM?' /dev/ttyUSB1
modem-stats -c 'AT+CRSM' /dev/ttyUSB1
modem-stats -c 'AT+CRSM=0' /dev/ttyUSB1
modem-stats -c 'AT+CRSM?' /dev/ttyUSB0
modem-stats -c 'AT+CRSM?' /dev/ttyUSB2
modem-stats -c 'AT+CLAC' /dev/ttyUSB2
modem-stats -c 'AT+CLAC' /dev/ttyUSB0
modem-stats -c 'AT+CLAC' /dev/ttyUSB1
dmesg
modem-stats -c 'AT+CLAC' /dev/ttyUSB1
find /root/.mozilla/ -type d -iname cache
find /root/.mozilla/firefox/2y8awogj.16.0b3/Cache -size +2M
find /root/.mozilla/firefox/47p0emkb.default/Cache -size +2M
find /root/.mozilla/firefox/2y8awogj.16.0b3/Cache -size +2M | while read file; do file $file; done
defaultmediaplayer /root/.mozilla/firefox/2y8awogj.16.0b3/Cache/D/52/46AF2d01
defaultmediaplayer /root/.mozilla/firefox/2y8awogj.16.0b3/Cache/2/A6/44557d01
defaultmediaplayer /root/.mozilla/firefox/2y8awogj.16.0b3/Cache/3/B4/DD688d01
defaultmediaplayer /root/.mozilla/firefox/2y8awogj.16.0b3/Cache/5/39/F3AB5d01
find /root/.mozilla/ -type d -iname cache
find /root/.mozilla/firefox/8eguvdtc.3.5/Cache  -size +2M | while read file; do file $file; done

Fri Mar 6 21:58:27 GMT+1 2015

lsusb
mv /root/Android /mnt/sdb19/
cp -au /root/Android /mnt/sdb16/
dmesg
lsusb
 /usr/sbin/usb_modeswitch.sh -v 0x19d2 -p 0x2000 -V 0x19d2 -P 0x0031 -M '55534243123456782000000080000c85010101180101010101000000000000'
lsmod | grep option
modprobe -l | grep zte
modprobe -v zte_ev
lsusb
elinks
df
./android
./android
df
lynx
geany /etc/ppp/pap-secrets
type -a cut
file /bin/cut
modem-stats /dev/ttyUSB1
modem-stats /dev/ttyUSB2
pgprs-setup
pgprs-connect
pgprs-connect -F
pgprs-setup
geany /usr/bin/pgprs-setup
pgprs-setup
pgprs-connect -F
geany /etc/ppp/scripts/pgprs-functions
pgprs-setup
pgprs-connect -F
geany /usr/bin/pgprs-connect
pgprs-connect -F
pgprs-setup
pgprs-connect -F
pgprs-setup
pgprs-connect -F
uname -r
lsmod | grep ztw
lsmod | grep zte
modinfo zte_ev
dmesg
modprobe -vr mei
dmesg
lsusb
history | grep usb_modeswitch
/usr/sbin/usb_modeswitch.sh -v 0x19d2 -p 0x2000 -V 0x19d2 -P 0x0031 -M '55534243123456782000000080000c85010101180101010101000000000000'
geany /usr/sbin/usb_modeswitch.sh
/usr/sbin/usb_modeswitch.sh -v 0x19d2 -p 0x2000 -V 0x19d2 -P 0x0031 -M '55534243123456782000000080000c85010101180101010101000000000000'
/usr/sbin/usb_modeswitch.sh -v 0x19d2 -p 0x0039 -V 0x19d2 -P 0x0031 -M '55534243123456782000000080000c85010101180101010101000000000000'
history | grep usb_modeswitch
/usr/sbin/usb_modeswitch.sh -v 0x19d2 -p 0x0039 -V 0x19d2 -P 0x0031 -M '55534243123456782000000080000c85010101180101010101000000000000'
/usr/sbin/usb_modeswitch.sh -v 0x19d2 -p 0x2000 -V 0x19d2 -P 0x0031 -M '55534243123456782000000080000c85010101180101010101000000000000'
dmesg
probedisk
probepart
./android

Fri Mar 13 10:49:01 GMT+1 2015

echo $((25*160))
sylpheed
net-setup.sh
geany `which net-setup.sh`
net-setup.sh
lsmod | grep cdc
modprobe /l | grep cdc
modprobe -l | grep cdc
lsmod | grep cdc
echo AQIFvrfQNmJ28K-zLXsFIGxQ0SqsDlyu2GpkGstmgdrC4qAqE-Ou6A56JrT31Xzadaugpj5EbTskpi4ZFAfHAYr3g7CKqnxhDXBvDEhPqDjVF9hvy_o24TWaCerbaokG_VoMGKEWdWoKsSZcUD2iN8J4n7bqTP7_dVzAM5BL0DV8GfhttC1zPtclHJtB0wUFTJWlNfVzTsiJokjz3ewPwwnhXWo0a1scsuCQUGzZaTTwP88g9gYJyACbxg8F1c-Ny37JvmiP2ES5lSh8bSmQyrrWSIvjqHC7X_PBvjprrTmt-d_Yk706GJg6uqP0ULpnWoEE7ids5zmtBmZbsmYwUbMTR5IQ2JtXQ14JGHe7X-unPGsut3xRSQiHf9W16WwePQgYtDGhfzvfBt7FTidbeG6ziCcAi5AZ8xMVM33opgD7eFjCzyTBC0wOzRap5F4PoZrH9beFgFxwhwgs-1D-KYV1b5OdmD6TBALY3tF3ad5UDfgedonRHb2vei4JGkyjE5Lygvc_E2HV4y-OVybZbbA_mumbrl3yYo96LIT2buZN0Mg1CA4rkGc7T8Qf2I0F09-x-kX_0itU6FB_-ASX9f1N8cFDehvpThZJvMMy4saVdcRNzi5CHzpd2WfP5UzRZtWwoHbnNPsPqDs8_pcl6AOuvbWeDqkfkEHbQSKo-neXb3-ydGKgoDNHn9Jk1BJSsNOCDDEISniqOX8q5W7sUE9PGmiAFc6Pq3oSf-kV8cMkY-CjAV_4HwEJxPCkvSeIDin75i6KeUb-7oMaRFa1RaKbps5V5AQ00mpZF5BaZcQf5TLn_zltm9XCFOjkGtINx_l7aaOadXWobygybuycQiDOxv54w1fS7Q0ZETOHHd1Az-B3PQw4o1qLpI5uZTCgVCMkmK1453Q-T4UjBA3Ce_LEC5e2qSFQtMilCpGu_AGtUiB-tJgzi7TsLfDi46I_jsnJFMvxIUanMCU2m1pdWP_kLeD9MgNiPmGF9VQepKtARXP7Vs46vXcWbVzOOG3VlJVuZhuEPzYDtHb6EXfMqa6Ncmba-xxDj8I8TsQ-xt8TlacafZEYhcCycpvo0qq9OJ6uaXR7kdHJn8y_ab6LuS8tH3HJqBoNWO5ZwqiQ9JUdza-oFQvMjTuApgUxmPdzgFzRu_VeAZcqnFWtxCM4dXKplejxZLWAwlJEnZ0LknBNx130qEkOdtAsYM3MfRS3PHwEs8P5xgNztFnOsKjSyLGiVSL1HwsRXvk8W8nvHzfWVwkd9ViAX_rkK7uKMgKYL7v7945kSf5bCuF8Jnv4rE0RZ5FUDXKMDL6KTPqVUHCBJK1w_-a39mmzD7vv-kZ1muqZOgglsRYVdPLJoWA_vcRM1Oo8KKF7xh_boixjEZu1UdK2nGkl32qRhrvPktYlBO9eVU4z2IG8ZT-joW1D3WRPoRTBvwKW_migx0MeHZRtGtOMHwij0TauJy8x446cAFgnGG_PdprfLalwhHckjlaCfeK7lyH6fngEbIW5XyYXopfitJ1Mm51vVssBTmmc_X2enL9Hmdu_Fxv_OgoOJiB_klP8UJz7O9-aCeSmsy4KuEa0c0zFQp3gqCJLa01st2MN-6jOA7F2R--8y-kOAWZ7poqirH-suK33oZ_IHvuUhuJIsQwVQ7zYryWNtSmmQAV0C48SbP0Z8fZDRh5L1awhuJ821v2iMVUwzr4-bdalxxjJmshei-OEyP4XyNyuYST_IJpO2zLLlrv0IO6KKLtLpLPme1v8BoSjr_Q9f8TWeXXS1vtRETitYeMjiv3hF2cJuK5vXNDSNwAzQdrEuPkN6GvoYXWq3lltIUJ2g-CJ6syZeyjPlxTJbUYz86Xuc7S2QVOMv9fwrMzX5jQnBZMs9hjBaG68TQAIDtSboiOJhHSXZaAbZxi-YmSfcN9O3QDU6LUEWf2MBh95vnGZvafvPEi8cGbWMRsrY01jUULqydboWmIUV5hoIDe6Mio9yqOfAYtySjmLz3M4TkD-2_6E2PZ_omS73lUrMx95ld146gSbBDdpMaPTPFLnG5uQ1Zy6MavV4ejHzyJmdgKgdZFBHKq81iwF2lweZqL24r96AG7pmHw5OBRDWch3N2H82E8
echo AQIFvrfQNmJ28K-zLXsFIGxQ0SqsDlyu2GpkGstmgdrC4qAqE-Ou6A56JrT31Xzadaugpj5EbTskpi4ZFAfHAYr3g7CKqnxhDXBvDEhPqDjVF9hvy_o24TWaCerbaokG_VoMGKEWdWoKsSZcUD2iN8J4n7bqTP7_dVzAM5BL0DV8GfhttC1zPtclHJtB0wUFTJWlNfVzTsiJokjz3ewPwwnhXWo0a1scsuCQUGzZaTTwP88g9gYJyACbxg8F1c-Ny37JvmiP2ES5lSh8bSmQyrrWSIvjqHC7X_PBvjprrTmt-d_Yk706GJg6uqP0ULpnWoEE7ids5zmtBmZbsmYwUbMTR5IQ2JtXQ14JGHe7X-unPGsut3xRSQiHf9W16WwePQgYtDGhfzvfBt7FTidbeG6ziCcAi5AZ8xMVM33opgD7eFjCzyTBC0wOzRap5F4PoZrH9beFgFxwhwgs-1D-KYV1b5OdmD6TBALY3tF3ad5UDfgedonRHb2vei4JGkyjE5Lygvc_E2HV4y-OVybZbbA_mumbrl3yYo96LIT2buZN0Mg1CA4rkGc7T8Qf2I0F09-x-kX_0itU6FB_-ASX9f1N8cFDehvpThZJvMMy4saVdcRNzi5CHzpd2WfP5UzRZtWwoHbnNPsPqDs8_pcl6AOuvbWeDqkfkEHbQSKo-neXb3-ydGKgoDNHn9Jk1BJSsNOCDDEISniqOX8q5W7sUE9PGmiAFc6Pq3oSf-kV8cMkY-CjAV_4HwEJxPCkvSeIDin75i6KeUb-7oMaRFa1RaKbps5V5AQ00mpZF5BaZcQf5TLn_zltm9XCFOjkGtINx_l7aaOadXWobygybuycQiDOxv54w1fS7Q0ZETOHHd1Az-B3PQw4o1qLpI5uZTCgVCMkmK1453Q-T4UjBA3Ce_LEC5e2qSFQtMilCpGu_AGtUiB-tJgzi7TsLfDi46I_jsnJFMvxIUanMCU2m1pdWP_kLeD9MgNiPmGF9VQepKtARXP7Vs46vXcWbVzOOG3VlJVuZhuEPzYDtHb6EXfMqa6Ncmba-xxDj8I8TsQ-xt8TlacafZEYhcCycpvo0qq9OJ6uaXR7kdHJn8y_ab6LuS8tH3HJqBoNWO5ZwqiQ9JUdza-oFQvMjTuApgUxmPdzgFzRu_VeAZcqnFWtxCM4dXKplejxZLWAwlJEnZ0LknBNx130qEkOdtAsYM3MfRS3PHwEs8P5xgNztFnOsKjSyLGiVSL1HwsRXvk8W8nvHzfWVwkd9ViAX_rkK7uKMgKYL7v7945kSf5bCuF8Jnv4rE0RZ5FUDXKMDL6KTPqVUHCBJK1w_-a39mmzD7vv-kZ1muqZOgglsRYVdPLJoWA_vcRM1Oo8KKF7xh_boixjEZu1UdK2nGkl32qRhrvPktYlBO9eVU4z2IG8ZT-joW1D3WRPoRTBvwKW_migx0MeHZRtGtOMHwij0TauJy8x446cAFgnGG_PdprfLalwhHckjlaCfeK7lyH6fngEbIW5XyYXopfitJ1Mm51vVssBTmmc_X2enL9Hmdu_Fxv_OgoOJiB_klP8UJz7O9-aCeSmsy4KuEa0c0zFQp3gqCJLa01st2MN-6jOA7F2R--8y-kOAWZ7poqirH-suK33oZ_IHvuUhuJIsQwVQ7zYryWNtSmmQAV0C48SbP0Z8fZDRh5L1awhuJ821v2iMVUwzr4-bdalxxjJmshei-OEyP4XyNyuYST_IJpO2zLLlrv0IO6KKLtLpLPme1v8BoSjr_Q9f8TWeXXS1vtRETitYeMjiv3hF2cJuK5vXNDSNwAzQdrEuPkN6GvoYXWq3lltIUJ2g-CJ6syZeyjPlxTJbUYz86Xuc7S2QVOMv9fwrMzX5jQnBZMs9hjBaG68TQAIDtSboiOJhHSXZaAbZxi-YmSfcN9O3QDU6LUEWf2MBh95vnGZvafvPEi8cGbWMRsrY01jUULqydboWmIUV5hoIDe6Mio9yqOfAYtySjmLz3M4TkD-2_6E2PZ_omS73lUrMx95ld146gSbBDdpMaPTPFLnG5uQ1Zy6MavV4ejHzyJmdgKgdZFBHKq81iwF2lweZqL24r96AG7pmHw5OBRDWch3N2H82E8 | wc -L
echo AQIFvrfQNmJ28K-zLXsFIGxQ0SqsDlyu2GpkGstmgdrC4qAqE-Ou6A56JrT31Xzadaugpj5EbTskpi4ZFAfHAYr3g7CKqnxhDXBvDEhPqDjVF9hvy_o24TWaCerbaokG_VoMGKEWdWoKsSZcUD2iN8J4n7bqTP7_dVzAM5BL0DV8GfhttC1zPtclHJtB0wUFTJWlNfVzTsiJokjz3ewPwwnhXWo0a1scsuCQUGzZaTTwP88g9gYJyACbxg8F1c-Ny37JvmiP2ES5lSh8bSmQyrrWSIvjqHC7X_PBvjprrTmt-d_Yk706GJg6uqP0ULpnWoEE7ids5zmtBmZbsmYwUbMTR5IQ2JtXQ14JGHe7X-unPGsut3xRSQiHf9W16WwePQgYtDGhfzvfBt7FTidbeG6ziCcAi5AZ8xMVM33opgD7eFjCzyTBC0wOzRap5F4PoZrH9beFgFxwhwgs-1D-KYV1b5OdmD6TBALY3tF3ad5UDfgedonRHb2vei4JGkyjE5Lygvc_E2HV4y-OVybZbbA_mumbrl3yYo96LIT2buZN0Mg1CA4rkGc7T8Qf2I0F09-x-kX_0itU6FB_-ASX9f1N8cFDehvpThZJvMMy4saVdcRNzi5CHzpd2WfP5UzRZtWwoHbnNPsPqDs8_pcl6AOuvbWeDqkfkEHbQSKo-neXb3-ydGKgoDNHn9Jk1BJSsNOCDDEISniqOX8q5W7sUE9PGmiAFc6Pq3oSf-kV8cMkY-CjAV_4HwEJxPCkvSeIDin75i6KeUb-7oMaRFa1RaKbps5V5AQ00mpZF5BaZcQf5TLn_zltm9XCFOjkGtINx_l7aaOadXWobygybuycQiDOxv54w1fS7Q0ZETOHHd1Az-B3PQw4o1qLpI5uZTCgVCMkmK1453Q-T4UjBA3Ce_LEC5e2qSFQtMilCpGu_AGtUiB-tJgzi7TsLfDi46I_jsnJFMvxIUanMCU2m1pdWP_kLeD9MgNiPmGF9VQepKtARXP7Vs46vXcWbVzOOG3VlJVuZhuEPzYDtHb6EXfMqa6Ncmba-xxDj8I8TsQ-xt8TlacafZEYhcCycpvo0qq9OJ6uaXR7kdHJn8y_ab6LuS8tH3HJqBoNWO5ZwqiQ9JUdza-oFQvMjTuApgUxmPdzgFzRu_VeAZcqnFWtxCM4dXKplejxZLWAwlJEnZ0LknBNx130qEkOdtAsYM3MfRS3PHwEs8P5xgNztFnOsKjSyLGiVSL1HwsRXvk8W8nvHzfWVwkd9ViAX_rkK7uKMgKYL7v7945kSf5bCuF8Jnv4rE0RZ5FUDXKMDL6KTPqVUHCBJK1w_-a39mmzD7vv-kZ1muqZOgglsRYVdPLJoWA_vcRM1Oo8KKF7xh_boixjEZu1UdK2nGkl32qRhrvPktYlBO9eVU4z2IG8ZT-joW1D3WRPoRTBvwKW_migx0MeHZRtGtOMHwij0TauJy8x446cAFgnGG_PdprfLalwhHckjlaCfeK7lyH6fngEbIW5XyYXopfitJ1Mm51vVssBTmmc_X2enL9Hmdu_Fxv_OgoOJiB_klP8UJz7O9-aCeSmsy4KuEa0c0zFQp3gqCJLa01st2MN-6jOA7F2R--8y-kOAWZ7poqirH-suK33oZ_IHvuUhuJIsQwVQ7zYryWNtSmmQAV0C48SbP0Z8fZDRh5L1awhuJ821v2iMVUwzr4-bdalxxjJmshei-OEyP4XyNyuYST_IJpO2zLLlrv0IO6KKLtLpLPme1v8BoSjr_Q9f8TWeXXS1vtRETitYeMjiv3hF2cJuK5vXNDSNwAzQdrEuPkN6GvoYXWq3lltIUJ2g-CJ6syZeyjPlxTJbUYz86Xuc7S2QVOMv9fwrMzX5jQnBZMs9hjBaG68TQAIDtSboiOJhHSXZaAbZxi-YmSfcN9O3QDU6LUEWf2MBh95vnGZvafvPEi8cGbWMRsrY01jUULqydboWmIUV5hoIDe6Mio9yqOfAYtySjmLz3M4TkD-2_6E2PZ_omS73lUrMx95ld146gSbBDdpMaPTPFLnG5uQ1Zy6MavV4ejHzyJmdgKgdZFBHKq81iwF2lweZqL24r96AG7pmHw5OBRDWch3N2H82E8 | wc -c
echo AQIFvrfQNmJ28K-zLXsFIGxQ0SqsDlyu2GpkGstmgdrC4qAqE-Ou6A56JrT31Xzadaugpj5EbTskpi4ZFAfHAYr3g7CKqnxhDXBvDEhPqDjVF9hvy_o24TWaCerbaokG_VoMGKEWdWoKsSZcUD2iN8J4n7bqTP7_dVzAM5BL0DV8GfhttC1zPtclHJtB0wUFTJWlNfVzTsiJokjz3ewPwwnhXWo0a1scsuCQUGzZaTTwP88g9gYJyACbxg8F1c-Ny37JvmiP2ES5lSh8bSmQyrrWSIvjqHC7X_PBvjprrTmt-d_Yk706GJg6uqP0ULpnWoEE7ids5zmtBmZbsmYwUbMTR5IQ2JtXQ14JGHe7X-unPGsut3xRSQiHf9W16WwePQgYtDGhfzvfBt7FTidbeG6ziCcAi5AZ8xMVM33opgD7eFjCzyTBC0wOzRap5F4PoZrH9beFgFxwhwgs-1D-KYV1b5OdmD6TBALY3tF3ad5UDfgedonRHb2vei4JGkyjE5Lygvc_E2HV4y-OVybZbbA_mumbrl3yYo96LIT2buZN0Mg1CA4rkGc7T8Qf2I0F09-x-kX_0itU6FB_-ASX9f1N8cFDehvpThZJvMMy4saVdcRNzi5CHzpd2WfP5UzRZtWwoHbnNPsPqDs8_pcl6AOuvbWeDqkfkEHbQSKo-neXb3-ydGKgoDNHn9Jk1BJSsNOCDDEISniqOX8q5W7sUE9PGmiAFc6Pq3oSf-kV8cMkY-CjAV_4HwEJxPCkvSeIDin75i6KeUb-7oMaRFa1RaKbps5V5AQ00mpZF5BaZcQf5TLn_zltm9XCFOjkGtINx_l7aaOadXWobygybuycQiDOxv54w1fS7Q0ZETOHHd1Az-B3PQw4o1qLpI5uZTCgVCMkmK1453Q-T4UjBA3Ce_LEC5e2qSFQtMilCpGu_AGtUiB-tJgzi7TsLfDi46I_jsnJFMvxIUanMCU2m1pdWP_kLeD9MgNiPmGF9VQepKtARXP7Vs46vXcWbVzOOG3VlJVuZhuEPzYDtHb6EXfMqa6Ncmba-xxDj8I8TsQ-xt8TlacafZEYhcCycpvo0qq9OJ6uaXR7kdHJn8y_ab6LuS8tH3HJqBoNWO5ZwqiQ9JUdza-oFQvMjTuApgUxmPdzgFzRu_VeAZcqnFWtxCM4dXKplejxZLWAwlJEnZ0LknBNx130qEkOdtAsYM3MfRS3PHwEs8P5xgNztFnOsKjSyLGiVSL1HwsRXvk8W8nvHzfWVwkd9ViAX_rkK7uKMgKYL7v7945kSf5bCuF8Jnv4rE0RZ5FUDXKMDL6KTPqVUHCBJK1w_-a39mmzD7vv-kZ1muqZOgglsRYVdPLJoWA_vcRM1Oo8KKF7xh_boixjEZu1UdK2nGkl32qRhrvPktYlBO9eVU4z2IG8ZT-joW1D3WRPoRTBvwKW_migx0MeHZRtGtOMHwij0TauJy8x446cAFgnGG_PdprfLalwhHckjlaCfeK7lyH6fngEbIW5XyYXopfitJ1Mm51vVssBTmmc_X2enL9Hmdu_Fxv_OgoOJiB_klP8UJz7O9-aCeSmsy4KuEa0c0zFQp3gqCJLa01st2MN-6jOA7F2R--8y-kOAWZ7poqirH-suK33oZ_IHvuUhuJIsQwVQ7zYryWNtSmmQAV0C48SbP0Z8fZDRh5L1awhuJ821v2iMVUwzr4-bdalxxjJmshei-OEyP4XyNyuYST_IJpO2zLLlrv0IO6KKLtLpLPme1v8BoSjr_Q9f8TWeXXS1vtRETitYeMjiv3hF2cJuK5vXNDSNwAzQdrEuPkN6GvoYXWq3lltIUJ2g-CJ6syZeyjPlxTJbUYz86Xuc7S2QVOMv9fwrMzX5jQnBZMs9hjBaG68TQAIDtSboiOJhHSXZaAbZxi-YmSfcN9O3QDU6LUEWf2MBh95vnGZvafvPEi8cGbWMRsrY01jUULqydboWmIUV5hoIDe6Mio9yqOfAYtySjmLz3M4TkD-2_6E2PZ_omS73lUrMx95ld146gSbBDdpMaPTPFLnG5uQ1Zy6MavV4ejHzyJmdgKgdZFBHKq81iwF2lweZqL24r96AG7pmHw5OBRDWch3N2H82E8 | wc -b
echo AQIFvrfQNmJ28K-zLXsFIGxQ0SqsDlyu2GpkGstmgdrC4qAqE-Ou6A56JrT31Xzadaugpj5EbTskpi4ZFAfHAYr3g7CKqnxhDXBvDEhPqDjVF9hvy_o24TWaCerbaokG_VoMGKEWdWoKsSZcUD2iN8J4n7bqTP7_dVzAM5BL0DV8GfhttC1zPtclHJtB0wUFTJWlNfVzTsiJokjz3ewPwwnhXWo0a1scsuCQUGzZaTTwP88g9gYJyACbxg8F1c-Ny37JvmiP2ES5lSh8bSmQyrrWSIvjqHC7X_PBvjprrTmt-d_Yk706GJg6uqP0ULpnWoEE7ids5zmtBmZbsmYwUbMTR5IQ2JtXQ14JGHe7X-unPGsut3xRSQiHf9W16WwePQgYtDGhfzvfBt7FTidbeG6ziCcAi5AZ8xMVM33opgD7eFjCzyTBC0wOzRap5F4PoZrH9beFgFxwhwgs-1D-KYV1b5OdmD6TBALY3tF3ad5UDfgedonRHb2vei4JGkyjE5Lygvc_E2HV4y-OVybZbbA_mumbrl3yYo96LIT2buZN0Mg1CA4rkGc7T8Qf2I0F09-x-kX_0itU6FB_-ASX9f1N8cFDehvpThZJvMMy4saVdcRNzi5CHzpd2WfP5UzRZtWwoHbnNPsPqDs8_pcl6AOuvbWeDqkfkEHbQSKo-neXb3-ydGKgoDNHn9Jk1BJSsNOCDDEISniqOX8q5W7sUE9PGmiAFc6Pq3oSf-kV8cMkY-CjAV_4HwEJxPCkvSeIDin75i6KeUb-7oMaRFa1RaKbps5V5AQ00mpZF5BaZcQf5TLn_zltm9XCFOjkGtINx_l7aaOadXWobygybuycQiDOxv54w1fS7Q0ZETOHHd1Az-B3PQw4o1qLpI5uZTCgVCMkmK1453Q-T4UjBA3Ce_LEC5e2qSFQtMilCpGu_AGtUiB-tJgzi7TsLfDi46I_jsnJFMvxIUanMCU2m1pdWP_kLeD9MgNiPmGF9VQepKtARXP7Vs46vXcWbVzOOG3VlJVuZhuEPzYDtHb6EXfMqa6Ncmba-xxDj8I8TsQ-xt8TlacafZEYhcCycpvo0qq9OJ6uaXR7kdHJn8y_ab6LuS8tH3HJqBoNWO5ZwqiQ9JUdza-oFQvMjTuApgUxmPdzgFzRu_VeAZcqnFWtxCM4dXKplejxZLWAwlJEnZ0LknBNx130qEkOdtAsYM3MfRS3PHwEs8P5xgNztFnOsKjSyLGiVSL1HwsRXvk8W8nvHzfWVwkd9ViAX_rkK7uKMgKYL7v7945kSf5bCuF8Jnv4rE0RZ5FUDXKMDL6KTPqVUHCBJK1w_-a39mmzD7vv-kZ1muqZOgglsRYVdPLJoWA_vcRM1Oo8KKF7xh_boixjEZu1UdK2nGkl32qRhrvPktYlBO9eVU4z2IG8ZT-joW1D3WRPoRTBvwKW_migx0MeHZRtGtOMHwij0TauJy8x446cAFgnGG_PdprfLalwhHckjlaCfeK7lyH6fngEbIW5XyYXopfitJ1Mm51vVssBTmmc_X2enL9Hmdu_Fxv_OgoOJiB_klP8UJz7O9-aCeSmsy4KuEa0c0zFQp3gqCJLa01st2MN-6jOA7F2R--8y-kOAWZ7poqirH-suK33oZ_IHvuUhuJIsQwVQ7zYryWNtSmmQAV0C48SbP0Z8fZDRh5L1awhuJ821v2iMVUwzr4-bdalxxjJmshei-OEyP4XyNyuYST_IJpO2zLLlrv0IO6KKLtLpLPme1v8BoSjr_Q9f8TWeXXS1vtRETitYeMjiv3hF2cJuK5vXNDSNwAzQdrEuPkN6GvoYXWq3lltIUJ2g-CJ6syZeyjPlxTJbUYz86Xuc7S2QVOMv9fwrMzX5jQnBZMs9hjBaG68TQAIDtSboiOJhHSXZaAbZxi-YmSfcN9O3QDU6LUEWf2MBh95vnGZvafvPEi8cGbWMRsrY01jUULqydboWmIUV5hoIDe6Mio9yqOfAYtySjmLz3M4TkD-2_6E2PZ_omS73lUrMx95ld146gSbBDdpMaPTPFLnG5uQ1Zy6MavV4ejHzyJmdgKgdZFBHKq81iwF2lweZqL24r96AG7pmHw5OBRDWch3N2H82E8 | wc -m
./replace_commit_files.sh 
git branch
git remote -v
git push krg Fox3-Dell755
git push MSkrg Fox3-Dell755
/etc/rc.d/rc.country
tty
exit
/etc/rc.d/rc.country
type -a hwclock
file /bin/hwclock
/etc/rc.d/rc.country
file /dev/rtc0
/etc/rc.d/rc.country -s
/etc/rc.d/rc.country -s | grep -o [[:alnum:]_-]$
/etc/rc.d/rc.country -s | grep -o [[:alnum:]_-]\+$
/etc/rc.d/rc.country -s | grep -o [[:alnum:]_-]+$
/etc/rc.d/rc.country -s | grep -o [[:alnum:]_-]*$
/etc/rc.d/rc.country -s | grep -o [[:alnum:]_-]\\+$
/etc/rc.d/rc.country -s
/etc/rc.d/rc.country -S
/etc/rc.d/rc.country -h
/etc/rc.d/rc.country new
/etc/rc.d/rc.country -d new
/etc/rc.d/rc.country -d any
/etc/rc.d/rc.country -S
/etc/rc.d/rc.country -s
/etc/rc.d/rc.country -h
/etc/rc.d/rc.country --help
/etc/rc.d/rc.country --version
/etc/rc.d/rc.country -s
/etc/rc.d/rc.country -d -s
/etc/rc.d/rc.country -ds
/etc/rc.d/rc.country -Sd
/etc/rc.d/rc.country -S
/etc/rc.d/rc.country -s
/etc/rc.d/rc.country -S
/etc/rc.d/rc.country -s
/etc/rc.d/rc.country -dS
/etc/rc.d/rc.country -DS
/etc/rc.d/rc.country -Dh
/etc/rc.d/rc.country --help
/etc/rc.d/rc.country --version
/etc/rc.d/rc.country --help
/etc/rc.d/rc.country -X
locale
ls /usr/lib/locale
/etc/rc.d/rc.country -cli
pkeys=fr /etc/rc.d/rc.country
pkeys=dk /etc/rc.d/rc.country
pkeys=dk /etc/rc.d/rc.country -D
pkeys=de /etc/rc.d/rc.country -v
pkeys=de /etc/rc.d/rc.country -d
/etc/rc.d/rc.country -d
pkeys=de /etc/rc.d/rc.country
grep LANG /etc/profile
/etc/rc.d/rc.country -d new
rm /etc/keymap
/etc/rc.d/rc.country -d new
pkeys=dk /etc/rc.d/rc.country
locale -a | grep -i set
pkeys=de /etc/rc.d/rc.country
 /etc/rc.d/rc.country
/usr/sbin/chooselocale
/usr/sbin/chooselocale -D cli
/usr/sbin/chooselocale -d cli
cat /usr/share/i18n/dialog_table_x
cat /usr/share/i18n/dialog_table_cli
/usr/sbin/chooselocale -d cli
/usr/sbin/chooselocale cli
ls -1 /usr/share/i18n/locales | grep -v -E 'i18n|iso|translit|POSIX'
/usr/sbin/chooselocale cli
grep LANG /etc/profile
/usr/sbin/chooselocale
grep LANG /etc/profile
/usr/sbin/chooselocale
exit
/mnt/sdb5/tmp/xdialog-chooselocale
/tmp/xdialog-chooselocale
pwd
/mnt/sdb5/tmp/xdialog-chooselocale
mount
ls /mnt/sdb5/tmp/xdialog-chooselocale
ls /mnt/sdb5/tmp/
ls /mnt/sdb5/
ls /mnt/
exit
pwd
/usr/sbin/chooselocale
killall Xdialog
killall dialog
ps | grep 23852
date
help getopts
tty
/etc/rc.d/rc.country
cat /etc/keymap
rm /etc/keymap
/etc/rc.d/rc.country
sakura
exit

Thu Mar 19 02:16:05 GMT+1 2015

geany /etc/rc.d/rc.counrty
geany /etc/rc.d/rc.country
geany /etc/rc.d/f4puppy5
/etc/rc.d/rc.country
rm /etc/keymap
/etc/rc.d/rc.country
pkeys=fr /etc/rc.d/rc.country
pkeys=dk /etc/rc.d/rc.country
pkeys=abcde /etc/rc.d/rc.country
/etc/rc.d/rc.country
grep LANG /etc/profile
/etc/rc.d/rc.country -s
/etc/rc.d/rc.country -S
/etc/rc.d/rc.country -D
/etc/rc.d/rc.country -v
which hwclock
/etc/rc.d/rc.country -h
/etc/rc.d/rc.country -s
ls /usr/share/kbd/keymaps/i386/
