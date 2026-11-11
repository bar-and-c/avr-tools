MAKEFILES_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

# Name the build from the name of the directory, if not defined by including makefile
ifndef PROJECT_NAME
PROJECT_NAME := $(shell basename "$(CURDIR)")
endif


ROOT_DIR := $(MAKEFILES_DIR)
BUILD_DIR := build_output
ELFFILE := $(BUILD_DIR)/$(PROJECT_NAME).elf
HEXFILE := $(BUILD_DIR)/$(PROJECT_NAME).hex
MCU ?= atmega328pb
F_CPU = 16000000UL

SKIP_OPTIMIZATION ?= 0

# If the main makefile has defined sources explicitly, use that,
# otherwise take all in project dir and one level deeper
ifeq ($(SOURCE_FILES),)
	SOURCE_FILES := $(wildcard *.c */*.c *.s */*.s)
endif

OBJECTS = $(patsubst %.c,$(BUILD_DIR)/%.o,\
          $(patsubst %.s,$(BUILD_DIR)/%.o,\
          $(SOURCE_FILES)))


# Add sources from any shared module dirs the project makefile defined
SHARED_SOURCE_FILES = $(foreach d,$(SHARED_DIRS),$(wildcard $(d)/*.c $(d)/*.s))
# This puts shared object files directly in $(BUILD_DIR), i.e. not in subdirs
# (could result in names clashing, but probably not).
SHARED_OBJECTS = $(addprefix $(BUILD_DIR)/,$(addsuffix .o,$(basename $(notdir $(SHARED_SOURCE_FILES)))))
# VPATH lets make find the shared module files without path prefixes in rules
VPATH += $(SHARED_DIRS)

OBJECTS += $(SHARED_OBJECTS)

# Add include paths for module headers
CFLAGS += $(addprefix -I,$(dir $(SHARED_DIRS)))

ifeq ($(SKIP_OPTIMIZATION),1)
	GCC_OPT_FLAG = -O0
else
	GCC_OPT_FLAG = -Os
endif

all: $(HEXFILE)

include $(ROOT_DIR)os.mak

CFLAGS += -mmcu=$(MCU) -DF_CPU=$(F_CPU) $(GCC_OPT_FLAG) -g -Wall \
         -funsigned-char -funsigned-bitfields -fpack-struct -fshort-enums
ASM_FLAGS += -mmcu=$(MCU) -g -x assembler-with-cpp 
LDFLAGS += -mmcu=$(MCU) -lm

$(ELFFILE): $(OBJECTS)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(LDFLAGS) -o $@ $^

$(HEXFILE): $(ELFFILE)
	$(OBJCOPY) -O ihex -R .eeprom $< $@

$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

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
simavr: CFLAGS += -D_SIMAVR_BUILD_ $(shell pkg-config --cflags simavr)
simavr: $(ELFFILE)
	@echo "simavr build"

simsim: simavr
	$(ROOT_DIR)/../simsim/simsim $(ELFFILE)

.PHONY: all clean debug
