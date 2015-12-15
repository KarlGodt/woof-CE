#!/bin/sh
#Barry Kauler 2006. written for puppyos, www.puppyos.com
#a script to replace the man command.
#w464 updated for PKGS_HOMEPAGES homepages db.
#w482 changed die.net/man/1 url.

# -iname option is case-insensitive, -name is case-sensitive.

BBAPPLETS="|addgroup|adduser|adjtimex|ar|arping|ash|awk|basename|bunzip2|busybox|bzcat|cal|cat|chgrp|chmod|chown|chroot|chvt|clear|cmp|cp|cpio|crond|crontab|cut|date|dc|dd|deallocvt|delgroup|deluser|devfsd|df|dirname|dmesg|dos2unix|dpkg|dpkg-deb|du|dumpkmap|dumpleases|echo|egrep|env|expr|false|fbset|fdflush|fdformat|fdisk|fgrep|find|fold|free|freeramdisk|fsck.minix|ftpget|ftpput|getopt|getty|grep|gunzip|gzip|halt|hdparm|head|hexdump|hostid|hostname|httpd|hush|hwclock|id|ifconfig|ifdown|ifup|inetd|init|insmod|install|ip|ipaddr|ipcalc|iplink|iproute|iptunnel|kill|killall|klogd|lash|last|length|linuxrc|ln|loadfont|loadkmap|logger|login|logname|logread|losetup|ls|lsmod|makedevs|md5sum|mesg|mkdir|mkfifo|mkfs.minix|mknod|mkswap|mktemp|modprobe|more|mount|msh|mt|mv|nameif|nc|netstat|nslookup|od|openvt|passwd|patch|pidof|ping|ping6|pipe_progress|pivot_root|poweroff|printf|ps|pwd|rdate|readlink|realpath|reboot|renice|reset|rm|rmdir|rmmod|route|rpm|rpm2cpio|run-parts|rx|sed|seq|setkeycodes|sha1sum|sleep|sort|start-stop-daemon|strings|stty|su|sulogin|swapoff|swapon|sync|sysctl|syslogd|tail|tar|tee|telnet|telnetd|test|tftp|time|top|touch|tr|traceroute|true|tty|udhcpc|udhcpd|umount|uname|uncompress|uniq|unix2dos|unzip|uptime|usleep|uudecode|uuencode|vconfig|vi|vlock|watch|watchdog|wc|wget|which|who|whoami|xargs|yes|zcat|"

SYMLNKS="`find /usr/share/doc -maxdepth 1 -type l | tr "\n" " "`"

FNDTXT="`find /usr/share/doc -maxdepth 3 -mount -xtype f -iname ${1}.txt`"
#find does not follow symlinks in paths unless followed by at least a "/", need this crap...
if [ "$FNDTXT" = "" ];then
 for ONELNK in $SYMLNKS
 do
  [ ! "`echo -n "$ONELNK" | grep -i "${1}.txt$"`" = "" ] && FNDTXT="$ONELNK"
  [ ! "$FNDTXT" = "" ] && break
  FNDTXT="`find ${ONELNK}/  -mount -maxdepth 3 -xtype f -iname ${1}.txt`"
  [ ! "$FNDTXT" = "" ] && break
 done
fi
if [ "$FNDTXT" != "" ];then
 exec defaulttextviewer "$FNDTXT"
else
 FNDHTM="`find /usr/share/doc -maxdepth 9 -mount -xtype f -iname ${1}.htm*`"
 #v2.12 improved find code contributed by Dougal...
 if [ "$FNDHTM" = "" ];then
   FNDDIR="`find /usr/share/doc -maxdepth 9 -mount -type d -iname ${1}*`"
   [ $? -eq 0 ] && [ -f $FNDDIR/index.html ] && FNDHTM=$FNDDIR/index.html
 fi
 #find does not follow symlinks in paths unless followed by at least a "/", need this crap...
 if [ "$FNDHTM" = "" ];then
  for ONELNK in $SYMLNKS
  do
   [ ! "`echo -n "$ONELNK" | grep -i "${1}.htm"`" = "" ] && FNDHTM="$ONELNK"
   [ ! "$FNDHTM" = "" ] && break
   FNDHTM="`find ${ONELNK}/ -mount -maxdepth 3 -xtype f -iname ${1}.htm*`"
   [ ! "$FNDHTM" = "" ] && break
  done
 fi
 
 if [ ! "$FNDHTM" = "" ];then
  [ "`echo -n "$FNDHTM" | cut -b 1`" = "/" ] && FNDHTM=file://$FNDHTM
  exec defaulthtmlviewer "$FNDHTM"
 fi
fi

#w464 search pkg homepages db...
pPATTERN='^'"${1}"' '
HOMESITE="`grep -i "$pPATTERN" /root/.packages/PKGS_HOMEPAGES | head -n 1 | cut -f 2 -d ' '`"
if [ "$HOMESITE" != "" ];then
 exec defaulthtmlviewer $HOMESITE
fi

#exec defaulthtmlviewer http://en.wikipedia.org/wiki/${1}
#exec defaulthtmlviewer http://unixhelp.ed.ac.uk/CGI/man-cgi?${1}
#exec defaulthtmlviewer http://threads.seas.gwu.edu/cgi-bin/man2web?program=${1}
#exec defaulthtmlviewer http://linux.die.net/man/1/${1}
#v431 fix thanks to technosaurus...
exec defaulthtmlviewer "http://www.google.com/search?&q=man+\"${1}\"+site:linux.die.net&btnI=Search"
  
###END###
