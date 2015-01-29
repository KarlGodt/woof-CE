#! /usr/bin/python

"""
 probeport.py
 Copyright (c) 2010 George Farris <farrisg@shaw.ca>

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.


Version history
  0.1  Jan 20, 2010 First release


This is for use with Misterhouse but could be adapted to anything.

probeport.py will probe all the ports in the SERIAL_PORTS list for any of the
devices in the PROBE_DEVICES list.  Once a port is found it will be deleted
from the SERIAL_PORTS so it won't continually be probed.

In Misterhouse you should set the port devices accordingly, here is a sample
of my mh.private.ini file:

Insteon_PLM_serial_port=/dev/mh_plm_port
W800_module = X10_W800
W800_port   = /dev/mh_w800_port
weeder_port = /dev/mh_weeder_port
weeder_baudrate=9600

This script should be run at boot time or any time before Misterhouse starts

If you have more or less than 4 ports you can add or subtract them to the SERIAL_PORTS
list. Also, here is an example if you only have two devices such as a weeder board
and a plm.

PROBE_DEVICES = ['probe_plm', 'probe_w800']
SERIAL_PORTS = ['/dev/ttyUSB0', '/dev/ttyUSB1']

Please feel free to forward other devices we can probe and I'll add them
to the list and release a new version.  Also please feel free to forward changes
or bug fixes.  Thanks.  George farrisg@shaw.ca
"""


import sys, os, serial, string, binascii, time, tempfile

# -------------- User modifiable settings -----------------------------

#PROBE_DEVICES = ['test']
PROBE_DEVICES = ['probe_plm', 'probe_wtdio', 'probe_w800']
SERIAL_PORTS = ['/dev/ttyUSB0', '/dev/ttyUSB1', '/dev/ttyUSB2', '/dev/ttyUSB3']
INSTEON_PLM_BAUD_RATE = 19200
WEEDER_IO_BAUD_RATE = 9600
WEEDER_BOARD_ADDRESS = "A"
W800RF32_BAUD_RATE = 4800



# ------------- End of user modifiable settings -----------------------

def test():
    print "This is a test run...."


#-----------------------------------------------------------------------------
# Probe for the insteon serial PLM
# plm  send 0x02 0x73, receive 0x02 0x73 0xXX 0x00 0x00 0x06/0x15
#-----------------------------------------------------------------------------
def probe_plm():
    for myport in SERIAL_PORTS:
        print "Probing for Insteon PLM port -> " + myport

        try:
            id = SERIAL_PORTS.index(myport)
            ser = serial.Serial(myport, INSTEON_PLM_BAUD_RATE, timeout=2)
            # Probe for Insteon response to command

            ser.write(binascii.a2b_hex("0273"))
            s2 = binascii.b2a_hex(ser.read(8))
            print s2
            if s2[0:4] == "0273":
                print "linking " + myport + " to /dev/mh_plm_port"
                command = "/bin/ln -sf " + myport + " /dev/mh_plm_port"
                os.system(command)
                del SERIAL_PORTS[id]
                ser.close()
                break
            ser.close()

        except:
            print "Error - Could not open serial port..."

#-----------------------------------------------------------------------------
# Probe for the Weeder WTDIO-M 14 channel digital IO board
# weeder send A, receive A?
#-----------------------------------------------------------------------------
def probe_wtdio():
    for myport in SERIAL_PORTS:
        print "Probing for Weeder WTDIO-M IO board port -> " + myport

        try:
            id = SERIAL_PORTS.index(myport)
            ser = serial.Serial(myport, WEEDER_IO_BAUD_RATE, timeout=2)
            # Probe for Insteon response to command
            ser.write(WEEDER_BOARD_ADDRESS)
            s2 = ser.read(5)
            print s2
            if s2[0:2] == WEEDER_BOARD_ADDRESS + '?':
                print "linking " + myport + " to /dev/mh_weeder_port"
                command = "/bin/ln -sf " + myport + " /dev/mh_weeder_port"
                os.system(command)
                del SERIAL_PORTS[id]
                ser.close()
                break
            ser.close()

        except:
            print "Error - Could not open serial port..."

#-----------------------------------------------------------------------------
# Probe for the W800RF32 x10 RF receiver
# w800   send 0xf0 0x29, receive 0x29
#-----------------------------------------------------------------------------
def probe_w800():
    for myport in SERIAL_PORTS:
        print "Probing for W800RF32 port -> " + myport

        try:
            id = SERIAL_PORTS.index(myport)
            ser = serial.Serial(myport, W800RF32_BAUD_RATE, timeout=2)
            # Probe for Insteon response to command

            ser.write(binascii.a2b_hex("F029"))
            s2 = binascii.b2a_hex(ser.read(8))
            print s2
            if s2[0:2] == "29":
                print "linking " + myport + " to /dev/mh_w800_port"
                command = "/bin/ln -sf " + myport + " /dev/mh_w800_port"
                os.system(command)
                del SERIAL_PORTS[id]
                ser.close()
                break
            ser.close()

        except:
            print "Error - Could not open serial port..."

if __name__ == "__main__":
    for device in PROBE_DEVICES:
        func = globals()[device]
        func()


    print "Goodbye..."