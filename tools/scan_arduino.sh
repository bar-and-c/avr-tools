#!/bin/sh

DEV=""
i=0
while [ -z "$DEV" -a $i -lt 12 ]; do
        echo "Press reset on Leonardo" > /dev/stderr
        sleep 1
        DEV=$(find /dev/ -name "tty.usbmodem*" 2>/dev/null)
        i=$((i+1))
done
if [ ! -z "$DEV" ]; then
        ARDUINO_DEVICE=$DEV
else
        echo "Could not find device"
        exit 1
fi

echo "$ARDUINO_DEVICE"
