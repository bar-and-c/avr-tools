#include <avr/io.h>

#include <util/delay.h>

int main(void) {
    DDRB |= 0x20;
    DDRD |= 0x04;

    while (1) {
        PORTD |= 0x04;
        PORTB |= 0x20;
        _delay_ms(500);

        PORTD &= ~0x04;
        PORTB &= ~0x20;
        _delay_ms(500);
    }
}
