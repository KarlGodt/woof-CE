#!/bin/bash
##
### Mo 17. Okt 16:57:11 GMT-1 2011
##

########################################################################
#
# Changes to puppy /sbin/init by Karl Reimer Godt
# Beacuse I am no educated programmer use at your own risk !
# I would thankfully appreciate every improvement , suggestion ,
# bugfix , code simplyfying and cleanup to this script !
# I am working since October $((1969+42)) on it . Enjoy !
#
# DISTRO_NAME='Lucid�Puppy'
# DISTRO_VERSION=218
# DISTRO_MINOR_VERSION=00
# DISTRO_BINARY_COMPAT='ubuntu'
# DISTRO_FILE_PREFIX='luci'
# DISTRO_COMPAT_VERSION='lucid'
# DISTRO_KERNEL_PET='linux_kernel-2.6.33.2-tickless_smp_patched-L3.pet'
# PUPMODE=2
# ATADRIVES='sda�'
# PUP_HOME='/'
# PDEV1='sda7'
# DEV1FS='ext4'
# Linux�puppypc�2.6.34-KRG-i486-compiled-AcerLaptop-rev5�#9�SMP�Sat�Jan�8�00:49:01�GMT-8�2011�i686�GNU/Linux
# Xserver=/usr/bin/Xorg
# $LANG=en_US
# today=Wed�Oct�19�21:48:03�GMT+1�2011
# TODO: manpage viewer if normal man installed~
# TODO: add /etc/passwd
# TODO: add /etc/sudoers
#
#
########################################################################

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
# DISTRO_NAME='Lucid�Puppy'
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
# Linux�puppypc�2.6.31.14�#1�Mon�Jan�24�21:03:21�GMT-8�2011�i686�GNU/Linux
# Xserver=/usr/bin/Xorg
# $LANG=en_US
# today=Tue�Oct�25�12:33:20�GMT+1�2011
#
#
#
#
#
########################################################################


choosen_lang="$LANG"
LANG=C
secondsSince1970=`date +%s`
minutesSince1970=`dc $secondsSince1970 60 \/ p`
hoursSince1970=`dc $minutesSince1970 60 \/ p`
daysSince1970=`dc $hoursSince1970 24 \/ p`
daysSince1970f=`echo "scale=0 ; $daysSince1970 * 1" | bc -l | sed 's/[[:punct:]].*//'`
echo daysSince1970=$daysSince1970f
yearsSince1970=`dc $daysSince1970 365.25 \/ p`
yearsSince1970f=`echo "scale=0 ; $daysSince1970 / 356.25" | bc -l | sed 's/[[:punct:]].*//'`
echo yearsSince1970=$yearsSince1970f
LANG=$choosen_lang

format_func(){
if [ -n "$1" ] && [ -n "$2" ] ; then
count=1
cat /tmp/$2 | while read line ; do
#echo count=$count
NR=${line%%|*}
#echo $NR
if [ "$NR" -lt 100 -a "$NR" -gt 9 ] ; then
NRf="0$NR"
elif [ "$NR" -lt 10 ] ; then
NRf="00$NR"
else
NRf=$NR
fi
#echo $NRf
sed -i "s/^$NR|/$NRf|/" /tmp/$1
count=$((count+1))
done
else
xmessage -bg red "Error , could not handle file \$1=$1 \$2=$2"
exit
fi
}

#####get input
if [ -f /etc/shadow ];then
cat -n /etc/shadow | sed 's/^[[:blank:]]*//g' | tr '[[:blank:]]' ' ' | tr -s ' ' | sed 's/:/|/g;s/\ /|/g' >/tmp/shadow9
cp /tmp/shadow9 /tmp/shadow

format_func shadow shadow9
LANG=C
earliestEntry=`cat /tmp/shadow | cut -f 4 -d '|' | grep -v -w '0' |sort -n | head -n1`
#difference=$((daysSince1970f-earliestEntry))
difference=`dc $daysSince1970 $earliestEntry \- p`
echo $difference
diffYears=`dc $difference 365.25 \/ p`
echo $diffYears
LANG=$choosen_lang
else
echo 'FILE /etc/shadow NOT found !' >/tmp/shadow
fi


###that was shadow

### now group
if [ -f /etc/group ];then
cat -n /etc/group | sed 's/^[[:blank:]]*//g' | tr '[[:blank:]]' ' ' | tr -s ' ' | sed 's/:/|/g;s/\ /|/g' | sort -g -k4 -t '|' >/tmp/group9
cp /tmp/group9 /tmp/group

format_func group group9
else
echo 'FILE /etc/group NOT found !' >/tmp/group
fi
###

###now gshadow
if [ -f /etc/gshadow ];then
cat -n /etc/gshadow | sed 's/^[[:blank:]]*//g' | tr '[[:blank:]]' ' ' | tr -s ' ' | sed 's/:/|/g;s/\ /|/g' >/tmp/gshadow9
cp /tmp/gshadow9 /tmp/gshadow

format_func gshadow gshadow9
else
echo 'FILE /etc/gshadow NOT found !' >/tmp/gshadow
fi
###

###now passwd
# TODO
if [ -f /etc/passwd ];then
cat -n /etc/passwd | sed 's/^[[:blank:]]*//g' | tr '[[:blank:]]' ' ' | tr -s ' ' | sed 's/:/|/g' >/tmp/passwd9
sed -i 's#^\([0-9]*\)\( \)#\1|#g' /tmp/passwd9
cp /tmp/passwd9 /tmp/passwd
format_func passwd passwd9
else
echo 'FILE /etc/passwd NOT found !' >/tmp/passwd
fi
###
###now sudoers
# TODO
if [ -f /etc/sudoers ];then
cat -n /etc/sudoers | sed 's/^[[:blank:]]*//g' | tr '[[:blank:]]' ' ' | tr -s ' ' | sed 's/ /|/g;s/=/|/g' >/tmp/sudoers9
#sed -i 's#^\([0-9]*\)\( \)#\1|#g' /tmp/sudoers9
cat /tmp/sudoers9 | grep '=' >/tmp/sudoers8
cat /tmp/sudoers9 | grep -v '=' >/tmp/sudoers7
cat /tmp/sudoers8 > /tmp/sudoers6
cat /tmp/sudoers7 >>/tmp/sudoers6
cp /tmp/sudoers6 /tmp/sudoers
format_func sudoers sudoers6

#echo "
#*****
#" >/tmp/sudoers8
#cat -n /etc/sudoers | grep -v '=' >>/tmp/sudoers8
#cat /tmp/sudoers8 >>/tmp/sudoers

else
echo 'FILE /etc/sudoers NOT found !' >/tmp/sudoers
fi
###

#echo '
#!/binbash
#

man_func(){  #does not work as func from gtkdialog
pMan="";pmanShell="";exeCute="";quote=""
pMan=`which pman`

if [ -n "$pMan" ] ; then
filePman=`file $pMan`
binPman=`echo $filePman | grep -e 'ELF [0-9]*\-bit LSB executable'`
[ "$binPman" ] && exeCute="rxvt -e man 5"
shellPman=`echo $filePman | grep -e 'shell script .* executable'`
#[ "$shellPman" ] && quote="'" && exeCute="pman $quote\man 5"
#[ "$shellPman" ] && quote="'" && exeCute="pman ${quote}man${quote} ${quote}5${quote}"
[ "$shellPman" ] && quote="'" && exeCute="pman ${quote}5${quote}"

fi
if [ ! "$shellPman" ] && [ ! "$binPman" ] ; then
readLink_e_man=''
readLink_e_man=`readlink -e $(which man)`
fileMan=`file $readLink_e_man`
binMan=`echo $fileMan | grep -e 'ELF [0-9]*\-bit LSB executable'`
shellMan=`echo $fileMan | grep -e 'shell script .* executable'`
[ "$binMan" ] && exeCute="rxvt -e man 5"
[ "$shellPman" ] && exeCute="man 5"
fi
}

man_func

if [ "$exeCute" ] ; then
for page in shadow gshadow group passwd sudoers ; do
echo $page
done

echo "#!/bin/bash
#######
####
$exeCute ${quote}group${quote}   || xmessage -bg 'red' 'WARNING : man 5 group not found' &
$exeCute ${quote}gshadow${quote} || xmessage -bg 'red' 'WARNING : man 5 gshadow not found' &
$exeCute ${quote}shadow${quote}  || xmessage -bg 'red' 'WARNING : man 5 shadow not found' &
$exeCute ${quote}passwd${quote}  || xmessage -bg 'red' 'WARNING : man 5 passwd not found' &
$exeCute ${quote}sudoers${quote} || xmessage -bg 'red' 'WARNING : man 5 sudoers not found' &
">/tmp/man_func.sh
else
exeCute="xmessage -bg 'red' 'WARNING : neither <pman> or <man> seem to be installed'"
echo "#!/bin/bash
#######
####
$exeCute
">/tmp/man_func.sh
fi
sleep 1s
chmod 0777 /tmp/man_func.sh


gtkDialog=`which gtkdialog4`
[ -z "$gtkDialog" ] && gtkDialog=`which gtkdialog3`
[ -z "$gtkDialog" ] && gtkDialog=`which gtkdialog2`

export gtk_view_shadow="
<window title=\"$gtkDialog Pupppy Shadow Viewer\">
<vbox>
<frame>
<hbox><text use-markup=\"true\"><label>\"FYI today :$daysSince1970f: days or $yearsSince1970f years after Jan 01 1970 00:00:00 \"</label></text></hbox>
<hbox><text use-markup=\"true\"><label>\"earliest entry (without '0') : $diffYears years back from today \"</label></text></hbox>
</frame>
<vbox>
<notebook labels=\" 1 | 2 | 3\">
<frame pw-group>
<frame shadow>
<text><label>for the /etc/shadow file</label></text>
<tree>
<label>Nr | login name | encrypted passwd | days since Jan 1, 1970 that password was last changed | days before password may be changed | days after which password must be changed | days before password is to expire that user is warned | days after password expires that account is disabled | days since Jan 1, 1970 that account is disabled | a reserved field</label>
<variable>loginUser</variable>
<input>cat /tmp/shadow</input>
<width>700</width><height>120</height>
</tree>
</frame>
<frame gshadow>
<text><label>for the /etc/gshadow file</label></text>
<tree>
<label>Nr | group name | encrytped passwd | group administrators | group member(s)</label>
<variable>gshadowName</variable>
<input>cat /tmp/gshadow</input>
<width>700</width><height>120</height>
</tree>
</frame>
<frame group>
<text><label>for the /etc/group file</label></text>
<tree>
<label>Nr | group__name | encrytped passwd | group-ID | user__list</label>
<variable>groupName</variable>
<input>cat /tmp/group</input>
<width>700</width><height>120</height>
</tree>
</frame>
</frame>
<frame pw-sudo>
<frame passwd>
<text><label>for the /etc/passwd file</label></text>
<tree>
<label>Nr | login name | optional encrytped passwd | user ID | group ID | user name or comment field | user home directory | optional user command interpreter</label>
<variable>userPasswd</variable>
<input>cat /tmp/passwd</input>
<width>700</width><height>120</height>
</tree>
</frame>
<frame sudoers>
<text><label>for the /etc/sudoers file</label></text>
<tree>
<label>Nr | user__name | group__ALIAS | as__USER | allowed__commands </label>
<variable>userSudo</variable>
<input>cat /tmp/sudoers</input>
<width>700</width><height>120</height>
</tree>
</frame>
</frame>
</notebook></vbox>
<hbox><button><label><Show manpages 'man 5 files'</label>
<action>/tmp/man_func.sh &</action>
</button></hbox>
</vbox>
</window>
"

if [ -n "$gtkDialog" ] ; then
$gtkDialog --program=gtk_view_shadow
else
xmessage -bg "red" "Sorry no gtkdialog[2-4] installed"
fi





