#ifndef USART_H		// Header guard.
#define USART_H

/*------------------------------------------------------------------------------
  usart.h --
  
  Description:
    Provides some useful declarations regarding the USART system of the
    ATxmega128A1U.
  
  Author(s): Dr. Eric Schwartz, Christopher Crary, Wesley Piard
  Last modified by: Dr. Eric M. Schwartz
  Last modified on: 8 Mar 2023
------------------------------------------------------------------------------*/

/********************************DEPENDENCIES**********************************/

#include <avr/io.h>

/*****************************END OF DEPENDENCIES******************************/

/***********************************MACROS*************************************/
/********************************END OF MACROS*********************************/

/*******************************CUSTOM DATA TYPES******************************/
/***************************END OF CUSTOM DATA TYPES***************************/

/*****************************FUNCTION PROTOTYPES******************************/

/*------------------------------------------------------------------------------
  void usart_send_data(void) -- 
  
  Description:
    Sends x, y and z accelerometer data over the usart.

  Input(s): N/A
  Output(s): Send accelerometer data over the USARTD0 module.
------------------------------------------------------------------------------*/
void usart_send_data(void);

/*------------------------------------------------------------------------------
void usart_send_gyro(void) --

	Description:
	Sends x, y and z gyroscope data over the usart.

	Input(s): N/A
	Output(s): Send gyroscope data over the USARTD0 module.
------------------------------------------------------------------------------*/
void usart_send_gyro(void);

/*------------------------------------------------------------------------------
  void usart_out(uint8_t out); -- 
  
  Description:
    Sends 8 bit data value over the usart

  Input(s): out = 8 bit data value
  Output(s): Sends 8 bit data value over the usart
------------------------------------------------------------------------------*/
void usart_out(uint8_t out);

/*------------------------------------------------------------------------------
  usartd0_in_char -- 
  
  Description:
    Returns a single character via the receiver of the USARTD0 module.

  Input(s): N/A
  Output(s): Character received from USARTD0 module.
------------------------------------------------------------------------------*/
char usartd0_in_char(void);

/*------------------------------------------------------------------------------
  usartd0_in_string -- 
  
  Description:
    Reads in a string with the receiever of the USARTD0 module.

    The string is to be stored within a pre-allocated buffer, accessible
    via the character pointer `buf`.

  Input(s): `buf` - Pointer to character buffer.
  Output(s): N/A
------------------------------------------------------------------------------*/
void usartd0_in_string(char * buf);

/*------------------------------------------------------------------------------
  usartd0_init -- 
  
  Description:
    Configures the USARTD0 module for a specific asynchronous serial protocol.

  Input(s): N/A
  Output(s): N/A
------------------------------------------------------------------------------*/
void usartd0_init(void);

/*------------------------------------------------------------------------------
  usartd0_out_char -- 
  
  Description:
    Outputs a character via the transmitter of the USARTD0 module.

  Input(s): `c` - Read-only character.
  Output(s): N/A
------------------------------------------------------------------------------*/
void usartd0_out_char(char c);

/*------------------------------------------------------------------------------
  usartd0_out_string -- 
  
  Description:
    Outputs a string via the transmitter of the USARTD0 module.

    The string is to be stored within a pre-allocated buffer, accessible
    via the character pointer `str`.

  Input(s): `str` - Pointer to read-only character string.
  Output(s): N/A
------------------------------------------------------------------------------*/
void usartd0_out_string(const char * str);


/**************************END OF FUNCTION PROTOTYPES**************************/

#endif		// End of header guard.