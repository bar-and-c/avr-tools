#!/usr/bin/env bash

# Edit here if your environment doesn't have make, AVR assembler, and/or avr-gcc in your path already

# NOTE: This script kinda assumes thaht if you're on macOS or Linux, you already have your
# tools in your PATH.
# If a reliable way is found to detect "OS", a more clever setup could be done (but it seems like
# Git Bash can report both "windows32" and "Linux").


have() {
 	command -v "$1" >/dev/null 2>&1
}

if ! have make; then
	GNU_MAKE_PATH=/c/7.0/shellutils
	export PATH=$GNU_MAKE_PATH:$PATH
	if ! have make; then
		echo "No make could be found (in $GNU_MAKE_PATH), check your system and update the setup script"
	fi
fi


if ! have avr-gcc; then
	AVR_GCC_PATH=/c/7.0/toolchain/avr8/avr8-gnu-toolchain/bin
	export PATH=$AVR_GCC_PATH:$PATH
	if ! have avr-gcc; then
		echo "No avr-gcc could be found (in $AVR_GCC_PATH), check your system and update the setup script"
	fi
fi


if ! ( have avrasm2 || have avra ); then
	AVR_ASSEMBLER_PATH=/c/7.0/toolchain/avr8/avrassembler
	export PATH=$AVR_ASSEMBLER_PATH:$PATH
	if ! ( have avrasm2 || have avra ); then
		echo "No AVR assembler could be found (in $AVR_ASSEMBLER_PATH), check your system and update the setup script"
	fi
fi
