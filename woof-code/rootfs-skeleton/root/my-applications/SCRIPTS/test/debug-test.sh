#!/bin/sh


err='';out=''

#debug(){ echo "$@" 1>$out 2>$err ; }
debug(){ echo "$@" ; }



debug "$( echo "'ABOUT udev :'  ##+++2011-11-18
`ps | grep udev` #| grep -v 'grep'  ##+++2011-11-18
#rm -r /dev/.udev #KRG -f
##+++2011-12-02
 'ABOUT klogd :'
`ps | grep klogd` #| grep -v 'grep'
 'ABOUT syslogd :'
`ps | grep syslogd` #| grep -v 'grep'

`ps | grep -v '\['`
" ; )
"


D="ABOUT udev :
`ps | grep udev`
ABOUT klogd :
`ps | grep klogd`
ABOUT syslogd :
`ps | grep syslogd`
"

debug "$D"

debug "$( echo -e "\e[1;34m"`which rox`"\e[0;39m" )"
debug "$( echo "Killing parentless zombie process $ONEZOMBIE" )"
