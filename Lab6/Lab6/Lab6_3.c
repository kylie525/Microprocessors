/*
 *  Lab6_3.c
 *
 *  Name: Kylie Lennon
 *	Class #: 11319
 *	PI Name: Timothy Carpenter
 *	Description: Initialize SPI and receive data from the IMU
 */ 

#include <avr/io.h>
#include "spi.h"
#include "lsm6dsl.h"
#include "lsm6dsl_registers.h"

int main(void)
{
	// create a variable x
	uint8_t x = 0;
	
	// initialize spi
	spi_init();
	
	// read from WHO_AM_I register and store in x
	x = LSM_read(WHO_AM_I);
	
	return 0;
}