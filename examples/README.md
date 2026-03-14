# Examples

## Example code

Here are a few examples to show how you can set up projects for AVR. The code itself does very 
little – all three basically just flash the LED on the Arduino board – but the structure can be
of interest when making other projects.


### Blinky in AVR assembler

An example for pure AVR assembler is found in `blinky_asm/`. It is compiled with `avra` on macOS,
`avrasm2.exe` on Windows/WSL – `avra` could probably be used on all OS:es, but the last official 
release doesn't support
ATmega32U4. 

### Blinky in avr-gcc assembler

The directory `blinky_gcc_asm/` contains an example of writing assembly code to be compiled with 
`avr-gcc`.
Note that the `avr-gcc` assembly language differs from pure AVR assembly. There are more things 
that differ than what is shown here.

### Blinky in C

And `blinky_c/` contains, unsurprisingly, an example of writing C code for AVR. At the time of 
writing, it does a little bit more than blink a LED, it also listens for input on PB0, and 
if that pin goes high, PB7 is also set high – this is done to test the custom built AVR simulator, `simsim`.

#### Run in `simsim`
To run this in this little AVR simulator, run the following commands (assuming you start in the `avr-tools` 
root):
```
make -C simsim
cd examples/blinky_c
make simsim
```

When the simulator is executing, you should see pin 7 in PORTC toggling. Entering "b" followed by "0"
and then "enter" should make pin 0 in PORTB go high, and then also pin 7 in PORTB.

Quit the simulator by typing "q" followed by "enter" (or Ctrl-C).

## Simulide 

The file `blinky_simulide.sim2` is made to be opened in SimulIDE, and any of these examples `.hex` files 
can be loaded – provided it is built for ATmega32.
