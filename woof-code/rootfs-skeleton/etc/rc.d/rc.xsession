#!/bin/ash

exec 2>/tmp/rc_xsession.log
[ -z "$DISPLAY" ] || exit #echo $DISPLAY # || exit
#sleep 20
#exit

T=`cat /etc/inittab | grep tty | grep -v -E -e '^#.*|^[[:blank:]]*#' | sed 's#^[[:blank:]]##' | sort -u`
N=`echo "$T" | grep -o 'tty[0-9]*[0-9]' | sort -u | tail -n 1 | cut -b 4-`
N=$(($N + 1))
###let N="$N +1" ###N=`expr $N + 1` ###N=`dc $N 1 \+ p` ###N=`echo "$N + 1" | bc`
echo "chvt to $N .."
chvt $N



echo 'running /etc/rc.d/rc.xsession'
echo '$0     :'"$0"
echo 'pwd    :'`pwd`
echo 'whoami :'`whoami`
echo 'sleep 10 now'
sleep 10
echo 'slept 10 ....'
echo 'starting now jwm and rox -p'
/usr/bin/jwm &
sleep 5
/usr/local/bin/rox -p /root/Choices/ROX-Filer/PuppyPin &
echo 'now have launched jwm and rox'
echo 'starting now pup_event_frontend_d'
/sbin/clean_desk_icons
/sbin/pup_event_frontend_d &

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
# today=Mon·Oct·24·22:47:55·CEST·2011
#
#
#
#
#
########################################################################

