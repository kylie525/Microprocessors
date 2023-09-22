/*
 *  Lab6_2.c
 *
 *  Name: Kylie Lennon
 *	Class #: 11319
 *	PI Name: Timothy Carpenter
 *	Description: Initialize SPI and continuously transmit 0x2A
 */ 
#include <avr/io.h>
#include "spi.c"

int main(void)
{
	// initialize spi
	spi_init();
	
	while(1)
	{
		// set cs to true aka 0
		PORTF.OUTCLR = PIN4_bm;
		
		// transmit 0x2A
		spi_write(0x2A);
		
		// set cs to false aka 1
		PORTF.OUTSET = PIN4_bm;
		
	}
	return 0;
}