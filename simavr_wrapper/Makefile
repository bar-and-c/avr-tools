CCFLAGS += $(shell pkg-config -cflags simavr)
CCFLAGS += $(shell pkg-config -cflags libelf)

LDFLAGS += $(shell pkg-config -libs simavr)
LDFLAGS += $(shell pkg-config -libs libelf)

simavr_wrapper: simavr_wrapper.c Makefile
	clang $(CCFLAGS) -g $(LDFLAGS) simavr_wrapper.c -o simavr_wrapper

clean:
	rm -rf simavr_wrapper simavr_wrapper.dSYM
