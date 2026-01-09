#!/bin/sh

SCRIPT_DIR=$(dirname $0)

FW_HEX_FILE=""
if [ $# -eq 1 -a -f "$1" ]; then
        FW_HEX_FILE="$1"
else
        NUM_HEX_FILES_FOUND=$(find . -name "*.hex" | wc -l)

        if [ $NUM_HEX_FILES_FOUND -ne 1 ]; then
                echo "Expected exactly one .hex file – either pass hex file as argument OR delete those not relevant."
                exit 1
        fi


        FW_HEX_FILE=$(find . -name "*.hex")
fi
echo
echo "Using .hex file: $FW_HEX_FILE"

ARDUINO_DEVICE=$("${SCRIPT_DIR}"/scan_arduino.sh)

echo
echo "Flashing $FW_HEX_FILE to $ARDUINO_DEVICE..."
avrdude -v -p atmega32u4 -c avr109 -P $ARDUINO_DEVICE -b 57600 -D -U flash:w:${FW_HEX_FILE}:i
