#!/bin/ash



_ping(){
test "$PING_DO" || return 0
while :;
do
ping -c1 -w10 -W10 "${URL:-bing.com}" && break
sleep 1
done >/dev/null
}

__ping(){
test "$PING_DO" || return 0

local lFOREVER=''
local lPRV

case $1 in
-I|--infinite) lFOREVER=$((lFOREVER+1));;
esac

while :; do
ping -c 1 -w10 -W10 "${URL:-google.com}" >/dev/null 2>&1
lPRV=$?
 if test "$lFOREVER"; then
  case $lPRV in 0) :;;
  *) echo draw 3 "WARNING: Client seems disconnected.." >&1;;
  esac
  sleep 2
 else
  case $lPRV in 0) return 0;;
  *) :;;
  esac
 fi

 sleep 1
done
}

#_ping -I &  # when cut off by wonky mobile connection,
         # the whole script waits, even forked functions.
         # would need an external script, that shows a xmessage ..

_kill_jobs(){
for p in `jobs -p`; do kill -9 $p; done
}

_get_server_version(){

#echo watch drawinfo
_watch
#sleep 1

#echo issue 1 1 version
_is 1 1 version
#sleep 1

while :; do
read -t 2

case $REPLY in '') break;; esac

 VERSION_MSG="$REPLY
$VERSION_MSG"

unset REPLY
sleep 0.1
done

#This is Crossfire v1.12-beta-r17660M
#The authors can be reached at crossfire@metalforge.org
VERSION=`echo "$VERSION_MSG" | grep -oiE 'crossfire [v0-9.]+'`
#VERSION=`echo "$VERSION_MSG" | grep -i -o 'version [[0-9].]'`
SERVER_VERSION=`echo "$VERSION" | grep -oE '[0-9.]+'`

if test "$SERVER_VERSION"; then
 _debug "SERVER_VERSION=$SERVER_VERSION"
 if [ "$SERVER_VERSION" \< "1.13" ]; then
  DRAWINFO=drawinfo
 else
  DRAWINFO=drawextinfo
 fi
 DRAW_INFO=$DRAWINFO
 echo draw 8 "Using '$DRAWINFO' to catch messages."
else
echo draw 3 "Unable to receive or compute server version"
fi

}

