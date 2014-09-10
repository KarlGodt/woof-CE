#!/bin/sh -e
# print "1" if device $1 is either removable, on the ieee1394 or on the usb bus,
# and "0" otherwise.

check_bus() {
  # check if the DEVICE is on the given bus 
  # This is done by checking if any of the devices on the bus is a prefix 
  # of the device
  BUSDEVP="/sys/bus/$1/devices"
  for x in $BUSDEVP/*; do
    [ -L "$x" ] || continue
    if echo "$DEVICE" | grep -q "^$(readlink -f $x)"; then 
      return 0
    fi
  done
  return 1
}

DEV="${1%[0-9]*}"
BLOCKPATH="/sys/block/$DEV"

if [ ! -d "${BLOCKPATH}" ]; then 
  exit 1
fi

REMOVABLE="${BLOCKPATH}/removable"
DEVICE="$(readlink -f "${BLOCKPATH}/device")"
IS_REMOVABLE="0"

if [ -e "$REMOVABLE" ]; then
  IS_REMOVABLE="$(cat $REMOVABLE)"
fi

if [ "$IS_REMOVABLE" = "1" ] || check_bus "usb" || check_bus "ieee1394" ; then 
  echo 1
else 
  echo 0
fi
exit 0
