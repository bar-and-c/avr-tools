#!/usr/bin/env bash

# Edit here if your environment doesn't have make, AVR assembler, and/or avr-gcc in your path already

# NOTE: This script kinda assumes that if you're on macOS or Linux, you already have your
# tools in your PATH.


if [ "$OS" == "Windows_NT" ]; then
	GNU_MAKE_PATH=/c/7.0/shellutils
	AVR_GCC_PATH=/c/7.0/toolchain/avr8/avr8-gnu-toolchain/bin
	AVR_ASSEMBLER_PATH=/c/7.0/toolchain/avr8/avrassembler
	AVRDUDE_PATH="/c/Program Files (x86)/Arduino/hardware/tools/avr/bin"
else
	echo "This script is only for Git Bash on Windows, for now"
	exit
fi


have() {
 	command -v "$1" >/dev/null 2>&1
}

if ! have make; then
	if [ ! -d "$GNU_MAKE_PATH" ]; then
		echo "Could not find the path $GNU_MAKE_PATH for tool make – install or find it, and update this script"
		exit 1
	fi
	export PATH=$GNU_MAKE_PATH:$PATH
	if ! have make; then
		echo "No make could be found (in $GNU_MAKE_PATH), check your system and update the setup script"
	fi
fi


if ! have avr-gcc; then
	if [ ! -d "$AVR_GCC_PATH" ]; then
		echo "Could not find the path $AVR_GCC_PATH for tool avr-gcc – install or find it, and update this script"
		exit 1
	fi
	export PATH=$AVR_GCC_PATH:$PATH
	if ! have avr-gcc; then
		echo "No avr-gcc could be found (in $AVR_GCC_PATH), check your system and update the setup script"
	fi
fi


if ! ( have avrasm2 || have avra ); then
	if [ ! -d "$AVR_ASSEMBLER_PATH" ]; then
		echo "Could not find the path $AVR_ASSEMBLER_PATH for tool avrasm2 – install or find it (or 'avra'), and update this script"
		exit 1
	fi
	export PATH=$AVR_ASSEMBLER_PATH:$PATH
	if ! ( have avrasm2 || have avra ); then
		echo "No AVR assembler could be found (in $AVR_ASSEMBLER_PATH), check your system and update the setup script"
	fi
fi

if ! have avrdude; then
	if [ ! -d "$AVRDUDE_PATH" ]; then
		echo "Could not find the path $AVRDUDE_PATH for tool avrdude – install or find it, and update this script"
		exit 1
	fi
	export PATH=$AVRDUDE_PATH:$PATH
	if ! have avr-gcc; then
		echo "No avr-gcc could be found (in $AVR_GCC_PATH), check your system and update the setup script"
		exit 1
	fi
	export AVRDUDE_CONFIG_PATH="/c/Program Files (x86)/Arduino/hardware/tools/avr/etc/avrdude.conf"
fi
