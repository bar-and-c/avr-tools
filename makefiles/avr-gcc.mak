
# Name the build from the name of the directory, if not defined by including makefile
CODE_DIR = $(lastword $(subst /, ,$(dir $(realpath $(firstword $(MAKEFILE_LIST))))))
PROJECT_NAME ?= $(CODE_DIR)

ROOT_DIR ?= $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
BUILD_DIR := build_output
ELFFILE := $(BUILD_DIR)/$(PROJECT_NAME).elf
HEXFILE := $(BUILD_DIR)/$(PROJECT_NAME).hex
MCU ?= atmega32u4
F_CPU = 16000000UL

C_SOURCES = $(wildcard *.c) $(wildcard */*.c)
ASM_SOURCES = $(wildcard *.s) $(wildcard */*.s)

C_OBJECTS = $(patsubst %.c,$(BUILD_DIR)/%.o,$(C_SOURCES))
ASM_OBJECTS = $(patsubst %.s,$(BUILD_DIR)/%.o,$(ASM_SOURCES))
OBJECTS = $(C_OBJECTS) $(ASM_OBJECTS)



all: $(HEXFILE)

include $(ROOT_DIR)os.mak

CFLAGS = -mmcu=$(MCU) -DF_CPU=$(F_CPU) -O0 -g -Wall \
         -funsigned-char -funsigned-bitfields -fpack-struct -fshort-enums
ASM_FLAGS = -mmcu=$(MCU) -g -x assembler-with-cpp 
LDFLAGS = -mmcu=$(MCU) -lm

$(ELFFILE): $(C_OBJECTS) $(ASM_OBJECTS)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(LDFLAGS) -o $@ $^

$(HEXFILE): $(ELFFILE)
	$(OBJCOPY) -O ihex -R .eeprom $< $@

# Also generate an assembly language output, for educational purposes
$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@
	$(CC) $(CFLAGS) -S -c $< -o $@.assembly

$(BUILD_DIR)/%.o: %.s
	@mkdir -p $(dir $@)
	$(CC) $(ASM_FLAGS) -c -o $@ $<

clean:
	rm -rf $(BUILD_DIR)

debug: $(ELFFILE)
	simavr -v -v -m $(MCU) -f $(F_CPU) --gdb $(ELFFILE) >  "$(BUILD_DIR)/simavr_log.txt"  2>&1 &
	avr-gdb  --eval-command="target remote :1234" --eval-command="break main" --eval-command="continue"  $(ELFFILE)
	@pkill -TERM simavr || echo "No simavr running"

# The ".mmcu" stuff is for simavr macros in the code (requires avr_mcu_section.h)
simavr: LDFLAGS += -Wl,--undefined=_mmcu,--section-start=.mmcu=0x910000
simavr: CFLAGS += -D_SIMAVR_BUILD_ $(shell pkg-config -cflags simavr)
simavr: $(ELFFILE)
	@echo "simavr build"

.PHONY: all clean debug
