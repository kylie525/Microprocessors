/*------------------------------------------------------------------------------
  usart.c --
  
  Description:
    Provides some useful definitions regarding the USART system of the
    ATxmega128A1U.
  
  Author(s): Dr. Eric Schwartz, Christopher Crary, Wesley Piard
  Last modified by: Dr. Eric M. Schwartz
  Last modified on: 8 Mar 2023
------------------------------------------------------------------------------*/

/********************************DEPENDENCIES**********************************/

#include <avr/io.h>
#include "usart.h"
#include "lsm6dsl_registers.h"
#include "lsm6dsl.h"

/*****************************END OF DEPENDENCIES******************************/

/***********************************MACROS*************************************/

/* At 2 MHz SYSclk, 5 BSEL, -6 BSCALE corresponds to 115200 bps */
#define BSEL     (5)
#define BSCALE   (-6)

/********************************END OF MACROS*********************************/

/*****************************FUNCTION DEFINITIONS*****************************/
void usart_send_data(void)
{
	// read the x, y and z values from the accelerometer and output them on the usart
	uint8_t XL = LSM_read(OUTX_L_XL);
	uint8_t XH = LSM_read(OUTX_H_XL);
	uint8_t YL = LSM_read(OUTY_L_XL);
	uint8_t YH = LSM_read(OUTY_H_XL);
	uint8_t ZL = LSM_read(OUTZ_L_XL);
	uint8_t ZH = LSM_read(OUTZ_H_XL);
	
	// output accelerometer value on the usart
	usart_out(XL);
	usart_out(XH);
	usart_out(YL);
	usart_out(YH);
	usart_out(ZL);
	usart_out(ZH);

}

void usart_send_gyro(void)
{
	// read the x, y and z values from the gyroscope and output them on the usart
	uint8_t XL = LSM_read(OUTX_L_G);
	uint8_t XH = LSM_read(OUTX_H_G);
	uint8_t YL = LSM_read(OUTY_L_G);
	uint8_t YH = LSM_read(OUTY_H_G);
	uint8_t ZL = LSM_read(OUTZ_L_G);
	uint8_t ZH = LSM_read(OUTZ_H_G);
	
	// output gyroscope values on the usart
	usart_out(XL);
	usart_out(XH);
	usart_out(YL);
	usart_out(YH);
	usart_out(ZL);
	usart_out(ZH);

}

void usart_out(uint8_t out)
{
	// wait until data register is empty and ready to receive data
	while(!(USARTD0.STATUS & USART_DREIF_bm));
	
	// send the data over the usart
	USARTD0.DATA = out;
}

char usartd0_in_char(void)
{
  /* intentionally left blank */
  return '0';
}

void usartd0_in_string(char * buf)
{
  /* intentionally left blank */
}

void usartd0_init(void)
{
  /* Configure relevant TxD and RxD pins. */
	PORTD.OUTSET = PIN3_bm;
	PORTD.DIRSET = PIN3_bm;
	PORTD.DIRCLR = PIN2_bm;

  /* Configure baud rate. */
	USARTD0.BAUDCTRLA = (uint8_t)BSEL;
	USARTD0.BAUDCTRLB = (uint8_t)((BSCALE << 4)|(BSEL >> 8));

  /* Configure remainder of serial protocol. */
  /* (In this example, a protocol with 8 data bits, no parity, and
   *  one stop bit is chosen.) */
	USARTD0.CTRLC =	(USART_CMODE_ASYNCHRONOUS_gc |
					 USART_PMODE_DISABLED_gc  	 |
					 USART_CHSIZE_8BIT_gc)       &
					~USART_SBMODE_bm;

  /* Enable receiver and/or transmitter systems. */
	USARTD0.CTRLB = USART_RXEN_bm | USART_TXEN_bm;

  /* Enable interrupt (optional). */
	/* USARTD0.CTRLA = USART_RXCINTLVL_MED_gc; */
}

void usartd0_out_char(char c)
{
	while(!(USARTD0.STATUS & USART_DREIF_bm));
	USARTD0.DATA = c;
}

void usartd0_out_string(const char * str)
{
	while(*str) usartd0_out_char(*(str++));
}

/***************************END OF FUNCTION DEFINITIONS************************/

