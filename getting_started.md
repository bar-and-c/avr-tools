# Getting started with `avr-tools`

The most basic usage of these tools is to simplify building and uploading code to 
AVR based development boards, primarily Arduino Leonardo.

It also contains simulation tools, to enable debugging and (to a very limited extent)
live simulation, but that is next level. This covers getting started with the basics.

## Prerequisites

What this repo provides, at the basic level, is a set of makefiles to make it possible
to build AVR code for AVR – assembly as well as C – and also upload to an Arduino board.

> If the word "makefiles" makes no sense to you – in short, it is a way to build software
> using a tool called `make`. This tool and the makefiles handle dependencies, decides 
> what needs to be rebuilt, et cetera. 
> Learn more (at learnxinyminutes.com)[https://learnxinyminutes.com/make/], or do a 
> deeper dive (at makefiletutorial.com)[https://makefiletutorial.com], for instance.

The makefiles basically only call the different tools needed – the tools themselves 
will have to be installed separately. In addition to `git` and `make`, you will need
`avr-gcc`, `avrdude`, and `avra` or `avrasm2`.


### macOS
You will need to install `homebrew` on macOS, but after that it is as simple as on Linux.

Install the following:
- `brew tap osx-cross/avr`
- `brew install avr-gcc`
- `brew install avr-gdb`
- `brew install --HEAD simavr`
- `brew install avrdude`

**NOTE:** The official version of `simavr` is pretty old; I have been using the latest one.


### Linux

This is untested on proper Linux, but I _think_ the following is needed for the basic
setup (for building and uploading):
```
sudo apt-get update 

# For make and other build tools
sudo apt install build-essential

# For avr-gcc
sudo apt-get install gcc-avr
```

**NOTE:** For assembler, `avra` is available, but unfortunately not one with support
for ATmega32U4. Either download the source code and build your own, or use Microchip's
`avrasm2.exe`.


### Windows
Install a git that comes with Git Bash, and learn how to start and use Git Bash. 
It acts like a Linux terminal, and that is where much of this will be done. The 
makefiles (in their current state) will probably not work in a native Windows 
environment. Git Bash is probably the easiest entry point, but WSL ought to be
fairly straightforward as well (being Linux).

**NOTE:** If you have Microchip and Arduino installed, all the necessary tools
(for the basic usage) are there – you just need to make sure the paths are in 
the PATH environment variable, so that they can be easily called. 

There is a setup script in the `tools/` directory that you can source. 

> To "source" a script in this kind of shell means that instead of executing the 
> script – which would be done in a separate process – its instructions are executed
> in the current process. This means that any environment variables set up in that
> script will be available in the shell afterwards, which is exactly what we want here.
> This is done by putting a '.' (and space) before the script.

Like so:
```
. ./tools/setup_git_bash_win.sh
```

**NOTE:** This setup script (and `makefiles/os.mak`) assumes that the tools are in 
certain places. If your tools are elsewhere, edit the script accordingly.


## Downloading all this
To get these files to your computer, you can either download it as a zip file, or -- if you know (or 
would like to learn) `git` -- you can clone this repository.

Both options are available from the big green button labelled **Code** on the top of this page.

### Clone (or fork) this repo

To use git to clone this repo: create a directory somewhere for your code, go to that directory
in a terminal, and do the following:

```
git clone https://codeberg.org/bar-and-c/avr-tools.git
```

This downloads the latest version of `avr-tools` to a new directory with that name.
It contains makefiles and configuration for VS Code, as well as example code. 

Your own code, for labs and other projects, can be put in this directory, typically 
in a subdirectory, just like the existing examples.

**NOTE:** Depending on how you want to use this repo, you may want to clone it, or fork it,
or even include it as a submodule to your own repo. For now, I am assuming that you have 
cloned it and will put your code in it, as described above. 



## Using the tools 

### Add your code

Whether it is for a lab or some other project, a recommendation for beginners is to organise 
your code in subdirectories in the avr-tools repo. 

An example, assuming that you have a zip file of some code exercise:
```
cd avr-tools
mkdir cs-labs
cp ~/Downloads/lab1.zip cs-labs
cd cs-labs
unzip lab1.zip
```

You will need a makefile as well. If the directory structure is similar to the one used
in `examples/`, just copy a makefile from an example project (`blinky_asm/Makefile` for
assembler, `blinky_c/Makefile` for C).


### Editing the code

To edit the source code, you will need an editor. Many people seem to like VS Code. 


### Building the code

To build in a terminal, you can just type `make` and press enter. There is more to it, though,
the makefiles contain several targets.

```
# To clean the build result
make clean

# To build and upload to the Arduino
make upload
```

Everything that is built is put in a folder called `build_output`.


## Visual Studio Code
There are some preparations made to support VS Code. In the example projects, there are subdirectories 
called `.vscode` – if you have followed the suggested directory structure, it ought to be possible to
copy that directory into your project directory.
