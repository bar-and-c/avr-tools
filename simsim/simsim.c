#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <signal.h>
#include <string.h>
#include <sys/time.h>
#include <pthread.h>

#include <sim_avr.h>
#include <sim_elf.h>
#include <sim_hex.h>
#include <sim_time.h>
#include <avr_ioport.h>


/********* TODO: 

// 1. At the moment, this relies on a home built simavr – the reason is to be able to load 
//    .hex firmware (for .asm/avra); maybe try to copy that code?
2. Make it build for Intel macOS as well.
// 3. It would be nice to have a better grasp on timing: make sure that the firmware runs 
//    as fast as on the target (so that its timings are realistic), update the UI in a sane way, 
//    provide some way to slow down the execution (the current method is a bit weird), ...
// 4. Figure out a sane command line UI.
//// LATER, DUDE!  5. Figure out some way to communicate I/O over a socket, for a better UI.

ALSO: maybe add 
a) proper command line options (for e.g. MCU and freq)
b) --help
c) maybe a UI guide (like how to enter GPIO input, "slow mode", and "quit" commands) that 
   is shown briefly at start
*/

#define ASCII_ESC 27

struct gpio_info {
    struct avr_irq_t *irq;
    uint32_t value;
};

enum port_group {
    PORT_GROUP_A,
    PORT_GROUP_B,
    PORT_GROUP_C,
    PORT_GROUP_D,
    PORT_GROUP_E,
    PORT_GROUP_F,
    PORT_GROUP_MAX
};

#define MAX_PINS_IN_GROUP 8 // All ports are 8 bits

static struct gpio_info all_pins[PORT_GROUP_MAX][MAX_PINS_IN_GROUP] = {{0}};
static bool values_changed = false;

static bool running = true;
static bool run_slowly = false;

static void present_changes(void);
static void signal_handler(int dummy);
static void pin_changed_callback(struct avr_irq_t * irq, uint32_t value, void * param);
static uint64_t get_current_us(void);
static void cursor_visible(bool show);
static void *kbd_input_thread(void *param);


int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("This software requires exactly one (1) argument, the AVR elf file\n");
        return 1;
    }
    char *elf_or_hex_file = argv[1];

    signal(SIGINT, signal_handler);

    pthread_t run;
    pthread_create(&run, NULL, kbd_input_thread, NULL);

    setbuf(stdout, NULL);

    // TODO: For now hardcoded to ATmega32U4
    avr_t *avr = avr_make_mcu_by_name("atmega32u4");
    if (avr == NULL) {
        fprintf(stderr, "Could not create AVR\n");
        return 1;
    }

    elf_firmware_t fw = {
          .frequency = 16000000,
          .mmcu = "atmega32u4",
    };

    sim_setup_firmware(elf_or_hex_file, AVR_SEGMENT_OFFSET_FLASH, &fw, argv[0]);
    avr_init(avr);

    if (strlen(elf_or_hex_file) < (sizeof(fw.tracename) - 4)) {
        char vcd_name[sizeof(fw.tracename)] = {0};
        strncpy(vcd_name, elf_or_hex_file, sizeof(vcd_name) - 4);
        char *last_period = strrchr(vcd_name, '.');
        if (last_period == NULL) {
            last_period = vcd_name + strlen(vcd_name);
        }
        snprintf(last_period + 1, 4, "vcd");
        snprintf(fw.tracename, sizeof(fw.tracename), "%s", vcd_name);
        printf("%s (%lu / %lu)\n", fw.tracename, strlen(fw.tracename), sizeof(fw.tracename));
    }

    for (int port = PORT_GROUP_A; port < PORT_GROUP_MAX; port++) {
        for (int pin = 0; pin < MAX_PINS_IN_GROUP; pin++) {
            // TODO: This is for Leonardo – different for different boards, would be nice to have dynamic
            // ATmega32U4 ONLY:
            if ((port == PORT_GROUP_B) || (port == PORT_GROUP_C) || (port == PORT_GROUP_D) ||
                ((port == PORT_GROUP_E) && ((pin == 2) || (pin == 6))) ||
                ((port == PORT_GROUP_F) && ((pin != 2) && (pin != 3)))) {
                all_pins[port][pin].irq = avr_io_getirq(avr, AVR_IOCTL_IOPORT_GETIRQ(port + 'A'), pin);
                avr_irq_register_notify(all_pins[port][pin].irq, pin_changed_callback, &all_pins[port][pin]);
                all_pins[port][pin].value = 0;

                // Adding to FW struct makes avr_load_firmware() add traces automatically
                fw.trace[fw.tracecount].kind = AVR_MMCU_TAG_VCD_PORTPIN;
                fw.trace[fw.tracecount].mask = port + 'A';
                fw.trace[fw.tracecount].addr = pin;
                fw.tracecount += 1;
            } else {
                all_pins[port][pin].irq = NULL;
            }
        }
    }

    avr_load_firmware(avr, &fw);

    uint32_t us_per_slice = 10000;
    uint32_t cycles_per_slice = avr_usec_to_cycles(avr, us_per_slice);

    cursor_visible(false);

    while (running) {
        uint64_t start_us = get_current_us();
        uint64_t start_cycle = avr->cycle;

        while (avr->cycle < start_cycle + cycles_per_slice) {
            avr_run(avr);
        }

        uint32_t elapsed_cycles = avr->cycle - start_cycle;
        int32_t expected_us = avr_cycles_to_usec(avr, elapsed_cycles);
        expected_us = (run_slowly) ? expected_us * 3 : expected_us;

        if (values_changed) {
            present_changes();
            values_changed = false;
        }
        int32_t elapsed_us = get_current_us() - start_us;

        if (elapsed_us < expected_us) {
            const struct timespec requested_sleep = {
                .tv_nsec = 1000 * (expected_us - elapsed_us),
            };
            nanosleep(&requested_sleep, NULL);
        }
    }
    avr_terminate(avr);
    cursor_visible(true);
}

static void pin_changed_callback(struct avr_irq_t * irq, uint32_t value, void * param) {
    struct gpio_info *pininfo = param;
    if (pininfo->value != value) {
        pininfo->value = value;
        values_changed = true;
    }
}

static uint64_t get_current_us(void) {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return tv.tv_sec * (uint64_t)1000000 + tv.tv_usec;
}

static void move_cursor(int x, int y) {
    printf("%c[%d;%dH", ASCII_ESC, y, x);
}

static void cursor_visible(bool show) {
    printf("%c[?25%c", ASCII_ESC, show ? 'h' : 'l');
}

static void clear_screen(void)  {
    // 0: To end of line, 1: to beginning of line, 2: entire screen, 3: entire screen and also scroll buffer
    printf("%c[2J", ASCII_ESC);
}

/* For now, a very basic terminal UI will do – a future improvement could be to
   open a socket för communication, so that a GUI could be written without having
   to do it in C. And also, for the bold, a way to run tests, perhaps. */
static void present_changes(void) {
    clear_screen();
    move_cursor(0, 0);
    for (int port = PORT_GROUP_A; port < PORT_GROUP_MAX; port++) {
        printf("PORT%c: ", port + 'A');
        for (int pin = MAX_PINS_IN_GROUP - 1; pin >= 0; pin--) {
            if (all_pins[port][pin].irq != NULL) {
                printf(" %d", all_pins[port][pin].value);
            } else {
                printf(" -");
            }
        }
        printf("\n");
    }
}

static void simsim_stop(void) {
    running = false;
}

static void simsim_speed_change(void) {
    run_slowly = !run_slowly;
}

static void simsim_pin_toggle(char port, unsigned int pin) {
    enum port_group port_in;
    struct gpio_info *gpio;

    switch (port) {
    case 'a':
    case 'A':
        port_in = PORT_GROUP_A;
        break;
    case 'b':
    case 'B':
        port_in = PORT_GROUP_B;
        break;
    case 'c':
    case 'C':
        port_in = PORT_GROUP_C;
        break;
    case 'd':
    case 'D':
        port_in = PORT_GROUP_D;
        break;
    case 'e':
    case 'E':
        port_in = PORT_GROUP_E;
        break;
    case 'f':
    case 'F':
        port_in = PORT_GROUP_F;
        break;
    default:
        return;
    }
    gpio = &all_pins[port_in][pin];
    if (gpio->irq == NULL) {
        return;
    }
    avr_raise_irq(gpio->irq, gpio->value == 0 ? 1 : 0);
}

static void signal_handler(int dummy) {
    simsim_stop();
}

static void *kbd_input_thread(void *param) {
    char pending_gpio_port = 0;
    while (running) {
        int c = getchar();
        if (((c >= 'A') && (c <= 'F')) || ((c >= 'a') && (c <= 'f'))) {
            pending_gpio_port = c;
        } else if (((c >= '0') && (c <= '7')) && (pending_gpio_port != 0)) {
            simsim_pin_toggle(pending_gpio_port, c - '0');
            pending_gpio_port = 0;
        } else {

            switch (c) {
            case EOF:
            case 'q':
                simsim_stop();
                break;
            case 's':
                pending_gpio_port = 0;
                simsim_speed_change();
                break;
            case '\n':
                continue;
            default:
                pending_gpio_port = 0;
                break;
            }
        }
    }
    return NULL;
}
