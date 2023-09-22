/*------------------------------------------------------------------------------
  lsm6ds3tr.c --
  
  Description:
    LSM read and write functionality definitions
  
  Author(s):
  Last modified by: Kylie Lennon
  Last modified on: 17 July 2023
------------------------------------------------------------------------------*/

/********************************DEPENDENCIES**********************************/

#include <avr/io.h>
#include <avr/interrupt.h>
#include "lsm6ds3tr.h"
#include "lsm6dsl_registers.h"

/*****************************END OF DEPENDENCIES******************************/

/*****************************FUNCTION DEFINITIONS*****************************/
void LSM_init(void)
{
	// set port c pin 6 as an input pin
	PORTC.DIRCLR = PIN6_bm;
	
	// set pin 6 as the interrupt pin
	PORTC.INT0MASK = PIN6_bm;
	
	// set pin interrupt trigger to low level
	PORTC.PIN6CTRL = PORT_ISC_LEVEL_gc;
	
	// set interrupt level to medium
	PORTC.INTCTRL = PORT_INT0LVL_MED_gc;
	
	// enable medium level interrupts
	PMIC.CTRL = PMIC_MEDLVLEN_bm; 
	
	// perform a software reset
	LSM_write(CTRL3_C, 0b00000101); //bit 0 = software reset
	
	// enable x y and z values of the accelerometer
	LSM_write(CTRL9_XL, 0b11110000); // 7 = x, 6 = y, 5 = z
	
	// set full scale selection and output data rate
	LSM_write(CTRL1_XL, 0b01010000); //7-4 output data rate 3-2 full scale selection
	
	// enable accelerometer interrupt
	LSM_write(INT1_CTRL, 0b00000001); // bit 0 = accelerometer data ready INT1_DRDY_XL
	
	// enable global interrupts
	sei();
}


void LSM_write(uint8_t reg_addr, uint8_t data)
{
	// enable chip select
	PORTF.OUTCLR = PIN4_bm;
	
	// transfer the address with read enabled bit 7 cleared
	spi_write(reg_addr & 0x7F);
	
	// transfer the data
	spi_write(data);
	
	// disable chip select
	PORTF.OUTSET = PIN4_bm;
}

uint8_t LSM_read(uint8_t reg_addr)
{
	// enable chip select
	PORTF.OUTCLR = PIN4_bm;
	
	// transfer the address with read enabled bit 7 set
	spi_write(reg_addr | 1 << 7);
	
	// save the data transferred
	uint8_t data = spi_read();
	
	// disable chip select
	PORTF.OUTSET = PIN4_bm;
	
	// return data
	return data;
}

/***************************END OF FUNCTION DEFINITIONS************************/