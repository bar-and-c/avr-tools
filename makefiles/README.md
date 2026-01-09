# Makefile structure

This directory contains the base makefiles used. The basic idea is that when you 
create a new "project" (e.g. for a lab), you create a directory somewhere (see 
the `examples` directory for inspiration), where the project code is gathered.

There are some limitations, caused by a lack of `make` knowledge, for 
instance: all source code in a project must be in the project directory or a
subdirectory therein. No deeper directory structures are supported.
The directory (with subdirs) is scanned for C and assembler files, which
are compiled into binaries with the project directory name as basename.

There are two different kind of projects suported.

1. Pure AVR assembler projects. Include `avra.mak` for pure assembler.
2. C projects, incuding avr-gcc style assembler. Include `avr-gcc.mak` for these.

## Pure AVR
There is one major quirk in the AVR makefile. The `avra` assembler is not the sharpest,
for instance it is not possible to pass the device specific include file on command line.
Obviously, it could be included in `main.asm`, but it is nice to be able to build for different
MCUs (not least since ATmega32U4 is not available in SimulIDE, but in some cases you can use 
ATmega32).

Currently, the makefile solves this by creating a _new_ file, `bogus.asm`, that includes
both the device include file and `main.asm`. 

**NOTE:** This file creation is one of the things that doesn't work on Windows cmd.exe.
