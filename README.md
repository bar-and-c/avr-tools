# avr-tools

This repo contains code and makefiles to be able to build, debug and simulate code for AVR MCUs, 
both for assembly and C code.

This repo contains code and makefiles intended to simplify building and debugging
C and assembler code for AVR targets – as an alternative to Microchip Studio.
At the time of writing, the C code is compiled with avr-gcc, and the assembler code is assembled with avra on 
macOS and Linux, and avrasm2 on Windows, but it is possible to use avr-gcc for assembler as well (however, note that 
the assembly language avr-gcc uses differs somewhat from standard AVR assembler, see example code). 


## Quick start

You will need the following:

- `avr-gcc` for compiling C code for AVR
- either `avrasm2.exe` or `avra` for compiling AVR assembly code
- `avrdude` for uploading the firmware (FW) to the board
- `make` for building the firmware
- possibly some Unix-style tools I have forgotten to document
- some Unix-style terminal

This quick start guide is written with Windows in mind; the same basic requirements 
are valid on other OS:es, but things are easier. See [the getting started guide](getting_started.md) 
to get up and running quickly. The bottom line for any OS is that some tools are needed, and 
they need to be in the PATH environment variable for the makefiles (the build system) to work. 


Unfortunately, on Windows you will have to install Microchip Studio, to get an AVR 
assembler and `make`. Granted, with Microchip Studio installed, you can naturally
use it as your build environment, if you enjoy old and clunky IDEs. 

Seriously, though: there is a point in avoiding an IDE when you're learning: you get 
closer to the tools that are being used – basically the same tools that an IDE uses,
so knowing them better makes it easier to understand what an IDE does. 

### The Microchip Studio path
If you choose to use Microchip Studio, you can still use the source code for the labs, you
just have to create a project etc. – I'm sure there is a tutorial for that online!

### The `make` path

I suggest you use Git Bash as your "Unix-style terminal". Other options are 
MinGW/MSYS2 and WSL (WSL is Linux, though, so the tooling is different).

Install the tools:

| **What**                                | **How** |
|---                                      |---      |
| [Git for Windows](https://gitforwindows.org) | Install it |
| [Microchip Studio](https://www.microchip.com/en-us/tools-resources/develop/microchip-studio) | Install it |
| [avr-gcc](https://sourceforge.net/projects/winavr/files/avr-gcc/avr-gcc-16.1_2026-05-20_mingw32.tar.xz/download) | Download and unpack |
| [avrdude](https://github.com/avrdudes/avrdude/releases/download/v8.3/avrdude-v8.3-windows-x64.zip) | Download and unpack |

You can unpack the latter two where you like – the source script expects them to be in 
`C:\Embedded_Systems`, but if you choose another location, just update the source script. 

To be able to see debug prints over USB, install 
[Tera Term](https://github.com/TeraTermProject/teraterm/releases/download/v5.7.0/teraterm-5.7.0-x64.exe) 
or some other serial console. 

You will also need some code-friendly text editor, like [Notepad++](https://notepad-plus-plus.org/downloads/v8.9.8.1/).


### How to use it

To download the repository with `git`:

```
git clone https://codeberg.org/bar-and-c/avr-tools.git
cd avr-tools
```

To set up for building (done when you start Git Bash, unless you've put the tools in your PATH):

```
. tools/source_for_build_env.sh
```

To build, you use `make` – you can add extra arguments like `clean` to remove previously built
artifacts, and `upload` to upload it to the board.

```
cd examples/blinky_c/
make
```

To upload it to the board:

```
make upload
```

#### About `make upload`...

The build environment tries to find the board automatically. It works OK on macOS,
if there are no other similar devices connected. I suspect this automatic device 
detection might work less smoothly on Windows. If it does, use DeviceManager to
see which COM port your board has. When you find it, either update `makefiles/os.mak`
or explicitly set the device on command line, like this: 

```
ARDUINO_DEVICE=COM5 make upload
```

The `upload` command also assumes you're using a board with `urboot` bootloader – which 
is typically **not** the case with Arduino boards. 


## Example code
A few example code projects can be found in the `examples` directory. These are documented 
[here](examples/README.md)

## Two project types

Two types of projects are supported, pure AVR assembler code and mixed C/assembler. In the latter, 
`avr-gcc` is used; `avr-gcc` can be used for assembler projects as well, but the assembly language differs 
somewhat from the pure AVR assembler. For pure AVR assembly language, either `avra` or `avrasm2.exe` 
is used as assembler.

[Check out the makefiles for more info](makefiles/README.md).


## Adding your own code
There are some hackish assumptions made here, to keep things simple. Some features (e.g. the VSCode
sourcing the setup script) rely on the source code being two directories down from here, i.e. like 
in the examples directory.

So, unless you want to improve the build system, make a directory with one subdirectory per project,
for instance:
```
./examples/ [...]

./my_avr_code/
             ce_lab1/
                 .vscode/
                 Makefile
                 main.c
             ce_lab2/
```


## Building the AVR code
The simplest way to build is to go to the main code directory (using `cd` in the terminal) and then enter 
`make` in the terminal, like this:

```
cd examples/blinky_c
make
```
This will build an ELF file (to be used for debugging) and a HEX file (which can be transferred to an AVR 
board or used in SimulIDE).

By default, this makefile builds for ATmega328PB; if you want to build for another 
MCU, do like this:

```
MCU=atmega328p make
```

**NOTE:** At the time of writing, for AVR assembler projects, the only supported MCUs are ATmega32, 
ATmega32U4, ATmega328P, and ATmega328PB. If the CPU of your choice causes the AVR assembler build 
to fail, add it in `makefiles/avra.mak`, like this:

```
else ifeq ($(MCU),atmega328p)
DEVICE_INCLUDE_NAME = m328pdef.inc
```

### Build and upload to an AVR board
If you want to upload the built firmware to the board, use the make target `upload`. There is an automatic 
scan for the board, but **note:** this is currently only for macOS, and only with one (1) board connected. 
If the automatic scan fails, you can add the port by setting the variable `ARDUINO_DEVICE`on the command 
line, like this:
```
ARDUINO_DEVICE=/dev/ttyACM0 make upload
```

### Build and debug
To debug on the actual board, you will need other tools, but if building with avr-gcc you can
debug on the host computer. You will need to install simavr to use as a simulated AVR MCU, and
`avr-gdb` for debugging (using homebrew on macOS). The makefiles have a target for debugging:
```
make debug
```
This starts a simulated AVR environment, and drops you into `main` in gdb. Learn about gdb commands online, 
here is a brief intro:

- 'l': list the source code around the current line
- 'n': step over next line
- 's': step _into_ next line (i.e. into a function call)
- 'b': set a breakpoint, like this: `b lcd_init`
- 'bt': show a "backtrace", the current call stack (the function "call chain")
- 'c': continue execution (**note:** not sure how to pause; Ctrl-C disconnects the simulator, so make sure to have a breakpoint set)
- 'p <x>': print variable x – also possible to print registers, by prefixing register name with a dollar sign, like `p $r16` <br>
- 'set <x> = <y>': set variable x to y, for instance `set $r16 = 0xA8`
- 'display <x>': show variable x continuously
- 'help': displays help; you can also get help on a specific subject (like `help data`)
- 'exit': exit gdb (Ctrl-D also works, as does 'q')

Pressing the return key repeats the last command.

## Build and debug using Visual Studio Code
To run in VSCode, the code directory must contain a subdirectory called `.vscode` containing settings 
for VSCode. The example code directories contain such setup that uses the makefiles to build. For code 
built using avr-gcc, it is also possible to debug in VSCode, with a graphical interface.

### Open project
To open a code directory as a VSCode project, simply choose File->Open Folder. The directory must contain a 
.vscode subdirectory to work properly in VSCode.

### To build
Use menu selection Terminal->Run Build Task

### To debug
Set a breakpoint by opening a source file and click on a line of code _in_the_left_margin_, to the left of 
the line number. It should result in a red dot.

Start the simavr simulator by choosing menu option Terminal->Run Task, and then choose "Start simavr". 
This starts the simulator in a terminal window at the bottom. 
**NOTE:** The simulator must be explicitly terminated by pressing Ctrl-C in that terminal window.

Start the debugger by clicking the play button in the left toolbar. This opens a debug control panel to the 
left; click the play button at the top ("AVR Debug").

That should result in the code being executed and then stopped at the breakpoint (if it is reached). There 
are controls in the top of the code window to step into/over/out as well as pause/continue.

In the debug control panel to the left you can look at registers and variables. You can also enter `gcc` 
commands in the terminal at the bottom, prefixed with `-exec`.

Debugging like this works for both assembly and C code, but only if built by avr-gcc.


## Running in a simulated MCU

There are a few options to run AVR code in a simulated environment, on your computer.

Here is an overview, there is [much more on this subject here](simsim/README.md).

### simavr
The tool simavr, which is used for executing the firmware code when debugging, can also be used to
run the code freely, without a debugger attached. The problem is that by default, it just runs the
code, with no visible output. It is possible to add traces on port pins, IRQs, et cetera,
with the `--add-trace` option, and then get this saved as a `.vcd` file to be viewed in an 
external waveform viewer.

This command sets a trace on PORTC, pin 7. The simulation is stopped with `Ctrl-C` in the terminal, and then the output VCD file
is created.

```
simavr -v -m atmega32u4 -f 16000000 \
       --add-trace C7=portpin@0x7/0x43 \
       -o output.vcd build_output/blinky_asm.hex
Adding portpin trace on address 0x0007, mask 0x43 ('C7')
```

One can observe other registers as well, not just GPIO pins. 


### Simple AVR simulator

The tool `simavr` is useful in the sense that it is readily available, but not very user friendly.

I have tried to make something intended to be slightly easier to use, called `simsim` ("**sim**ple
**sim**ulator").

It is not very pretty, the best thing about it is that it displays the status of all ports in the 
terminal, live. The immediate feedback of what is happening is one of the benefits, another is 
that it is possible to pass input to it, to toggle port pins.


### Viewing VCD files
The VCD files produced by simavr can be viewed using several tools. One that often is mentioned is GTKWave.
I have used an extension to VS Code called [Vaporview](https://github.com/Lramseyer/vaporview). It looks 
like the screen of an oscilloscope or a logic analyzer.

![An image showing a VCD file in Vaporview](simsim/vcd_trace_overview.png "VCD trace in Vaporview")


### Running in SimulIDE
For a richer simulation environment, you can use [SimulIDE](https://simulide.com/p/). This is a standalone 
applicaton for all major operating systems that can simulate not only many AVR MCUs and some Arduino boards, 
but also things like digital circuits, passive and active analog components, power sources, measurement tools, 
and even peripherals like LCD displays.

Unfortunately, ATmega32U4 is not available there (yet). What you can do instead is to build for ATmega32, but
note that not all ports are the same as on ATmega32U4. What you can do for those ports is to define a symbolic
name for the port/pin, that you use in the code, and define them differently depending on MCU.

In pure AVR assembly language:

```
#ifdef _M32DEF_INC_
	.equ LED_OUTPUT_PORT = PORTC
	.equ LED_OUTPUT_DDR = DDRC
	.equ LED_OUTPUT_PIN_NUM = 7
#else
	.equ LED_OUTPUT_PORT = PORTE
	.equ LED_OUTPUT_DDR = DDRE
	.equ LED_OUTPUT_PIN_NUM = 2
#endif

[...]
	SBI LED_OUTPUT_DDR, LED_OUTPUT_PIN_NUM

	SBI LED_OUTPUT_PORT, LED_OUTPUT_PIN_NUM

```

When building with avr-gcc, another macro must be used: 

```
#ifdef __AVR_ATmega32__
#define LED_OUTPUT_PORT PORTC
#define LED_OUTPUT_DDR DDRC
#define LED_OUTPUT_PIN_NUM 7
#else
#define LED_OUTPUT_PORT PORTE
#define LED_OUTPUT_DDR DDRE
#define LED_OUTPUT_PIN_NUM 2
#endif
```

To build for the ATmega32 MCU, do this:

```
MCU=atmega32 make clean all
```


## Known issues

This has mainly been used and developed on macOS. Most of it ought to work on Linux and in WSL (or
Git Bash) on Windows. 

- There are some things done in the makefiles that assume a Unix type of environment (simply because
  I lack the necessary `make` and Windows skills). It should be possible to fix, but I will not do it 
  anytime soon. I have tried a lot of it in WSL, and it works OK. If you only want to build (not debug),
  Git Bash is even simpler (assuming Microchip Studio and other tools are installed).
- On macOS, there is a script that tries to detect the board, and on Windows there is a much less 
  tested variant, but if that fails, or if on Linux, the device has to be passed on command line, 
  `ARDUINO_DEVICE=/dev/ttyACM0 make` (or whatever the device is, something like `COM7` on Windows). 
  Or edit `os.mak`.
- The device detection script mentioned above only works if there is one (1) device that matches the
  crude check. This can be improved, but is not (yet).
- The upload command assumes the `urboot` bootloader is used – other ones may need another 
  programmer ("wiring"?).
