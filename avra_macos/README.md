### avra for macOS

The latest official release of avra (at the time of writing) is very old and doesn't support ATmega32U4.

This directory contains a custom built universal binary (and include files) from the latest (commit
c78607c5fe64d044001683cbe90f20e85a080cc4) of https://github.com/Ro5bert/avra.git.

That commit was patched to (hopefully!) enable universal macOS build, the patch is included in this directory.


Build command:
```
OS=osx DESTDIR=$HOME/kod/avr-tools/avra_macos make install
```
