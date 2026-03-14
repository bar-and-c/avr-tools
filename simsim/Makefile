CCFLAGS += $(shell pkg-config -cflags simavr)
CCFLAGS += $(shell pkg-config -cflags libelf)

LDFLAGS += $(shell pkg-config -libs simavr)
LDFLAGS += $(shell pkg-config -libs libelf)

simsim: simsim.c Makefile
	clang $(CCFLAGS) -g $(LDFLAGS) simsim.c -o simsim

clean:
	rm -rf simsim simsim.dSYM
