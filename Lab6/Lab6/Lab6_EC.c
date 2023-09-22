/*
 *  Lab6_EC.c
 *
 *  Name: Kylie Lennon
 *	Class #: 11319
 *	PI Name: Timothy Carpenter
 *	Description: Read gyroscope data and plot the values using SerialPlot
 */ 

#include <avr/io.h>
#include <avr/interrupt.h>
#include "spi.h"
#include "usart.h"
#include "lsm6dsl.h"

// global variable
volatile uint8_t gyro_flag = 0;

int main(void)
{
	// initialize usart
	usartd0_init();
	
	// initialize spi
	spi_init();
	
	// initialize lsm
	LSM_gyro_init();
	
	while(1)
	{
		if(gyro_flag == 1)
		{
			// reset flag
			gyro_flag = 0;
			
			//transmit data
			usart_send_gyro();
			
			//enable medium level interrupts
			PORTC_INTCTRL = 2;
		}
		
	}
	
	return 0;
}

// INTERRUPT SERVICE ROUTINES
/************************************************************************************
* Name: ISR(PORTC_INT0_vect)
* Purpose: Interrupt service routine for interrupt flag that shows when gyroscope data is ready 
* Inputs: None
* Outputs: Sets gyro_flag to 1
***********************************************************************************/
ISR(PORTC_INT0_vect)
{
	// disable medium level interrupts
	PORTC_INTCTRL = 0;
	// set flag to 1
	gyro_flag = 1;
	
}