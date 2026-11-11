# Assemble the code (output in build_output/)
# make

# Upload to board
# make upload

# Clean up compiled files
# make clean

MAKEFILES_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
ROOT_DIR := $(MAKEFILES_DIR)

# Name the build from the name of the directory, if not defined by including makefile
ifndef PROJECT_NAME
PROJECT_NAME := $(shell basename "$(CURDIR)")
endif


MCU ?= atmega328pb
AVRA_EXEC ?= avra


MAIN_SRC ?= $(wildcard *.asm) # This only works with one (1) .asm file
INCLUDE_SRC := $(wildcard *.inc) $(wildcard */*.inc)
BUILD_DIR := build_output
HEXFILE := $(BUILD_DIR)/$(PROJECT_NAME).hex
MAIN_WITH_DEVICE_INCLUDE = $(BUILD_DIR)/bogus.asm



# NOTE: To be able to build for different MCUs, a new .asm file is created that includes 
# the device include file and then the main .asm file.
ifeq ($(MCU),atmega32u4)
DEVICE_INCLUDE_NAME = m32U4def.inc
else ifeq ($(MCU),atmega32)
DEVICE_INCLUDE_NAME = m32def.inc
else ifeq ($(MCU),atmega328p)
DEVICE_INCLUDE_NAME = m328pdef.inc
else ifeq ($(MCU),atmega328pb)
DEVICE_INCLUDE_NAME = m328PBdef.inc
else
DEVICE_INCLUDE_NAME = unsupported_mcu.inc
endif

define CONCATENATED_MAIN
.include "$(DEVICE_INCLUDE_NAME)"
.include "$(strip $(MAIN_SRC))"
endef
export CONCATENATED_MAIN



all: $(HEXFILE)

include $(ROOT_DIR)os.mak

ifneq ($(AVR_DEVICE_INC),)
	EXTRA_INCLUDE_PATH += -I $(AVR_DEVICE_INC)
endif

$(BUILD_DIR):
	mkdir $@

$(MAIN_WITH_DEVICE_INCLUDE): $(BUILD_DIR) $(MAIN_SRC)
# NOTE: At some point, I changed to '$(file > ...)' – cannot remember why, and now
#       I see it fails on macOS. For now, reverting to old method.
#	$(file > $@,$(CONCATENATED_MAIN))
	echo "$$CONCATENATED_MAIN" > $@


$(HEXFILE): $(BUILD_DIR) $(MAIN_WITH_DEVICE_INCLUDE) $(INCLUDE_SRC)
	@echo "Building for $(MCU) with extra flags: $(EXTRA_INCLUDE_PATH)"
	"$(AVRA_EXEC)" -fI -I . $(EXTRA_INCLUDE_PATH) -m $(BUILD_DIR)/$(PROJECT_NAME).map -l $(BUILD_DIR)/$(PROJECT_NAME).lst -o $(HEXFILE) $(MAIN_WITH_DEVICE_INCLUDE)

clean:
	rm -rf $(BUILD_DIR)


simsim: simavr
	$(ROOT_DIR)/../simsim/simsim $(HEXFILE)

.PHONY: all upload clean
