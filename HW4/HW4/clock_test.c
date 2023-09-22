/*
* clock_test.c
* HW 4
* Name: Kylie Lennon
* Class #: 11319
* PI Name: Timothy Carpenter
* Description: Generate a 32 MHz or 4 MHz clock signal and output it to pin 7 of port c
*/

#include <avr/io.h>
extern void clock_init(void);

int main(void)
{
	// initializes the clock
	clock_init();
	// configures the CLKEVOUT register to output the system clock signal to pin 7 of PORTC
	PORTCFG_CLKEVOUT = PORTCFG_CLKOUT_PC7_gc;
	// set pin 7 of port c to be an output
	PORTC_DIRSET = PIN7_bm;
	// infinite loop
    while (1);
    return 0;
}

