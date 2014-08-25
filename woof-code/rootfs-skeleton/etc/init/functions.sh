

head_function(){
###KRG Fr 31. Aug 23:34:58 GMT+1 2012

trap "exit 1" HUP INT QUIT KILL TERM

OUT=/dev/null;ERR=$OUT
[ "$DEBUG" ] || DEBUG=`sed 's#[[:punct:]]#_#g;s# #\n#g' /proc/cmdline |grep -iw 'debug'`
[ "$DEBUG" ] && { OUT=/dev/stdout;ERR=/dev/stderr; }
[ "$DEBUG" = "2" ] && set -x

Version='1.1'

usage(){
USAGE_MSG="
$0 [ PARAMETERS ]

-V|--version : showing version information
-H|--help : show this usage information

*******  *******  *******  *******  *******  *******  *******  *******  *******
$2
"
#exit $1
return 1
}

[ "`echo "$1" | grep -wiE "help|\-H"`" ] && usage 1
#[ "`echo "$1" | grep -wiE "version|\-V"`" ] && { echo "$0 -version $Version";exit 0; }
[ "`echo "$1" | grep -wiE "version|\-V"`" ] && { echo "$0 -version $Version";return 1; }
export DEBUG="$DEBUG" OUT="$OUT" ERR="$ERR" ###+2012-03-17
return 0
###KRG Fr 31. Aug 23:34:58 GMT+1 2012
}

modem_param_func(){
##If a different modem selected, quit...
#[ -h /dev/modem ] && exit
#[ ! $1 ] && exit
#[ "$1" != "start" ] && exit
if [ ! "$1" -o -h /dev/modem -o "$1" != 'start' ]; then
    return 1
    else
    return 0
fi

}

link_func(){
 if [ "`lsmod | grep "^${1} "`" ]; then
#if [ "`lsmod | grep '^pl2303'`" != "" ];then
 ##ln -snf usb/ttyUSB0 /dev/modem
 #ln -snf ttyUSB0 /dev/modem
 NODE=`dmesg | grep -A1 "$1" | grep -m1 'attached' |sed 's#^.* to \(.*\)#\1#'`
 [ -c /dev/"$NODE" ] && ln -snf "$NODE" "$2"
fi
}

country_func(){
#the module doesn't seem to support any country setting, so...
if [ -f /etc/countryinfo ];then
 SPATTERN="s/^MODEM_COUNTRY_STRING.*/MODEM_COUNTRY_STRING=''/"
 sed -i -e "$SPATTERN" /etc/countryinfo
fi
#.../usr/sbin/gen_modem_init_string reads this variable.
}

export -f head_function modem_param_func link_func country_func
#caller 50
#caller
