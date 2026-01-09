#include <avr/io.h>

// LED blink for Arduino Leonardo

int main(void) {

    DDRC = 0x80;
    DDRB = 0x80;
    while (1)
    {
    	PORTC |= 0x80;
    	for (uint32_t i = 0; i < 0x6FFFF; i++) {
	    }
    	PORTC &= ~0x80;
    	for (uint32_t i = 0; i < 0x6FFFF; i++) {
	    }
        if (PINB & 0x01) {
            PORTB |= 0x80;
        }
    }
    return 0;
}
