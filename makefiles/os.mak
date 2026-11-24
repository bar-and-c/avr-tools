
ifeq ($(OS),Windows_NT)
	ARDUINO_DEVICE ?= $(shell $(ROOT_DIR)../tools/scan_arduino.sh)

	# Trying to guess where the Atmel_DFP pack is
	ATMEL_PACK_ROOT ?= C:/7.0
	DFP_BASE := $(ATMEL_PACK_ROOT)/packs/atmel/ATmega_DFP
	DFP_VERSIONS := $(wildcard $(DFP_BASE)/*)
	DFP_DIR := $(lastword $(sort $(DFP_VERSIONS)))
	ifeq ($(DFP_DIR),)
		DFP_DIR := C:/Embedded_Systems/Atmel.ATmega_DFP.2.4.522
	endif

	ifneq ($(DFP_DIR),)
		AVR_DEVICE_INC ?= $(DFP_DIR)/avrasm/inc
	else
		AVR_DEVICE_INC := "ATmega_DFP_dir_not_found__see_readme_files"
	endif

	CC = avr-gcc
	OBJCOPY = avr-objcopy
	AVRA_EXEC = avrasm2.exe

else
	# For macOS and Linux, assume the tools are in the PATH
	CC = avr-gcc
	OBJCOPY = avr-objcopy

	UNAME_S := $(shell uname -s)

	ifeq ($(UNAME_S),Linux)
		ARDUINO_DEVICE ?= /dev/ttyACM0

		# All this is to be able to use avrasm2.exe in WSL on Linux.
		# One could use avra, BUT the latest official version doesn't 
		# support ATmega32U4.
		ifeq ($(findstring WSL, $(shell uname -a)), WSL)
			AVRA_EXEC = avrasm2.exe

			ATMEL_PACK_ROOT ?= /mnt/c/7.0
			DFP_BASE := $(ATMEL_PACK_ROOT)/packs/atmel/ATmega_DFP
			DFP_VERSIONS := $(wildcard $(DFP_BASE)/*)
			DFP_DIR := $(lastword $(sort $(DFP_VERSIONS)))
			ifneq ($(DFP_DIR),)
				AVRASM2_FRIENDLY_DFP_DIR = $(subst /mnt/c, C:, $(DFP_DIR))
				AVR_DEVICE_INC ?= $(AVRASM2_FRIENDLY_DFP_DIR)/avrasm/inc
			else
				AVR_DEVICE_INC := "ATmega_DFP_dir_not_found__see_readme_files"
			endif

		else
			AVRA_EXEC = avra
		endif
	endif

	ifeq ($(UNAME_S),Darwin)
		ARDUINO_DEVICE ?= $(shell $(ROOT_DIR)../tools/scan_arduino.sh)
		AVRA_EXEC ?= $(ROOT_DIR)../avra_macos/usr/local/bin/avra
		AVR_DEVICE_INC ?= $(ROOT_DIR)../avra_macos/usr/local/include/avr
	endif


endif


# Programmer selection based on MCU
ifeq ($(MCU), atmega32u4)
	ARDUINO_PROGRAMMER = avr109
else ifeq ($(MCU), atmega328p)
	ARDUINO_PROGRAMMER = arduino
else ifeq ($(MCU), atmega328pb)
	ARDUINO_PROGRAMMER = urclock
else ifeq ($(MCU), atmega2560)
	ARDUINO_PROGRAMMER = wiring
else
	ARDUINO_PROGRAMMER = avr109
endif


ifeq (${AVRDUDE_CONFIG_PATH},)
	AVRDUDE_CONFIG_OPTION = 
else
	AVRDUDE_CONFIG_OPTION = -C "${AVRDUDE_CONFIG_PATH}"
endif

AVRDUDE_BAUD ?= 115200

upload: $(HEXFILE)
	@echo 'Will upload "$(HEXFILE)" to "$(ARDUINO_DEVICE)"...'
	@# -D disables auto-erase
	avrdude -v $(AVRDUDE_CONFIG_OPTION) -p $(MCU) -c $(ARDUINO_PROGRAMMER) -b $(AVRDUDE_BAUD) -P $(ARDUINO_DEVICE) -D -U flash:w:$<
	@echo 'Program "$(HEXFILE)" uploaded to "$(ARDUINO_DEVICE)"'
