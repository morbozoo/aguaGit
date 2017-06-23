#!/usr/bin/python2.7

import serial
ser = serial.Serial("/dev/ttyUSB0", 9600, timeout =1)
onString = "\x02\x41\x44\x5A\x5A\x3B\x50\x4F\x4E\x03"
            #STX  A   D   Z   Z   ;   P   O   N   ETX
offString = "\x02\x41\x44\x5A\x5A\x3B\x50\x4F\x46\x03"
            #STX  A   D   Z   Z   ;   P   O   F   ETX
#ser.write("Hello world")
#ser.write('\x03')#ETX end of text ASCII
ser.write(offString)
