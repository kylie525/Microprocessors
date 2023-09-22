/*
* Lab7_5.c
*
* Name: Kylie Lennon
* Class #: 11319
* PI Name: Timothy Carpenter
* Description: Read at a rate of 137 Hz from the adc and output photoresistor data 
* over the usart to the serial plot if L is inputted. If F is inputted output the
* value from J3 over the usart to the serial plot.
*/


#include <avr/io.h>
#include <avr/interrupt.h>

// global variables
volatile int16_t photo_val = 0;
volatile int16_t j3_val = 0;
volatile uint8_t conversion_flag = 0;
volatile uint8_t letter_flag = 0; // 0 is photoresistor and 1 is J3

void usartd0_out_char(char c);
void adc_init(void);
void tcc0_init(void);
void usartd0_init(void);

int main(void)
{
	// variables to transmit low and high bytes
	uint8_t photo_low, photo_high, j3_low, j3_high = 0;
	// initialize adc
	adc_init();
	// initialize the timer counter
	tcc0_init();
	// initialize usart
	usartd0_init();
	
    while (1)
	{
		if(conversion_flag)
		{
			conversion_flag = 0;
			if(letter_flag)
			{
				// convert data into low and high bytes
				j3_low = (uint8_t) j3_val;
				j3_high = (uint8_t) (j3_val >> 8);
				// output the low and high bytes
				usartd0_out_char(j3_low);
				usartd0_out_char(j3_high);
				
			}
			else
			{
				// convert data into low and high bytes
				photo_low = (uint8_t) photo_val;
				photo_high = (uint8_t) (photo_val >> 8);
				// output the low and high bytes
				usartd0_out_char(photo_low);
				usartd0_out_char(photo_high);
				
			}
		}
	}
    
	return 0;
}


/************************************************************************************
* Name: ISR(ADCA_CH0_vect)
* Purpose: Copy the data from the photoresistor and j3 when the counter overflows
* Inputs: None
* Outputs: None
***********************************************************************************/
ISR(ADCA_CH0_vect)
{ 
	// update the conversion flag
	conversion_flag = 1;
	// copy the data from the photoresistor
	photo_val = ADCA.CH0RES;
	// copy the value from j3
	j3_val = ADCA.CH1RES;
}

/************************************************************************************
* Name: ISR(USARTD0_RXC_vect)
* Purpose: Read character from the usart and then set the letter flag. L = 0 and F = 1
* Inputs: None
* Outputs: None
***********************************************************************************/
ISR(USARTD0_RXC_vect)
{
	// read the value from usart
	char input = USARTD0_DATA;
	// set the letter flag based off of inputted letter
	if(input == 'L')
	{
		letter_flag = 0;
	}
	else if(input == 'F')
	{
		letter_flag = 1;
	}
}

/************************************************************************************
* Name: void usartd0_out_char(char c)
* Purpose: Output a character over the usart to the putty.
* Inputs: char c the character you are trying to output
* Outputs: Outputs the character on the putty
***********************************************************************************/
void usartd0_out_char(char c)
{
	while(!(USARTD0.STATUS & USART_DREIF_bm));
	USARTD0.DATA = c;
}

/************************************************************************************
* Name: void adc_init(void)
* Purpose: Initialize the adc to be 12 bit signed right adjusted, normal, and 
* a 2.5 v voltage reference. Enable ADC interrupt when conversion is complete.
* Initialize event system so the event channel 0 triggers the ADC conversion.
* Inputs: None
* Outputs: None
***********************************************************************************/
void adc_init(void)
{
	// set to signed mode
	ADCA.CTRLB = ADC_CONMODE_bm;	
	
	// set voltage reference to be 2.5v from port b references
	ADCA.REFCTRL = ADC_REFSEL_AREFB_gc; 
	
	// set the input source for channel 0
	ADCA.CH0.MUXCTRL = ADC_CH_MUXPOS_PIN1_gc | ADC_CH_MUXNEG_PIN6_gc;
	
	// set the input mode for channel 0
	ADCA.CH0.CTRL = ADC_CH_INPUTMODE_DIFFWGAIN_gc;
	
	// enable ADC interrupt when conversion is complete
	ADCA.CH0.INTCTRL = ADC_CH_INTMODE_COMPLETE_gc | ADC_CH_INTLVL_MED_gc;
	
	// set the input source for channel 1
	ADCA.CH1.MUXCTRL = ADC_CH_MUXPOS_PIN5_gc | ADC_CH_MUXNEG_PIN4_gc;
	
	// set the input mode for channel 1
	ADCA.CH1.CTRL = ADC_CH_INPUTMODE_DIFFWGAIN_gc;
	
	// initialize event system so the event channel 0 and 1 triggers the ADC conversion
	//ADCA.EVCTRL = ADC_EVSEL_0123_gc | ADC_SWEEP_01_gc | ADC_EVACT_CH01_gc; 
	ADCA.EVCTRL = ADC_EVSEL_0123_gc | ADC_SWEEP_01_gc | ADC_EVACT_SWEEP_gc; 
	
	// enable the adc (last)
	ADCA.CTRLA = ADC_ENABLE_bm;
}

/************************************************************************************
* Name: void tcc0_init(void)
* Purpose: Initialize the timer counter to have an overflow rate of 137 Hz. Have the
* overflow trigger the event channel 0.
* Inputs: None
* Outputs: None
***********************************************************************************/
void tcc0_init(void)
{
	// initialize the timer counter 
	TCC0.PER = 14599;
	TCC0.CTRLA = TC_CLKSEL_DIV1_gc;
	
	// trigger event channel when counter overflows
	EVSYS.CH0MUX = EVSYS_CHMUX_TCC0_OVF_gc;
}

/************************************************************************************
* Name: void usartd0_init(void)
* Purpose: Initialize the usart to have 116,500 baud rate, eight data bits, 
* odd parity, and one stop bit.
* Inputs: None
* Outputs: None
***********************************************************************************/
void usartd0_init(void)
{
/* BSEL and BSCALE to get 116500 baud rate */
#define BSEL (1)
#define BSCALE (-4)
 /* Configure relevant TxD and RxD pins. */
	PORTD.OUTSET = PIN3_bm;
	PORTD.DIRSET = PIN3_bm;
	PORTD.DIRCLR = PIN2_bm;
 /* Configure baud rate. */
	USARTD0.BAUDCTRLA = (uint8_t) BSEL;
	USARTD0.BAUDCTRLB = (uint8_t)((BSCALE << 4)|(BSEL >> 8));
 /* Configure remainder of serial protocol. */
 /* (In this example, a protocol with 8 data bits, odd parity, and
 * one stop bit is chosen.) */
	USARTD0.CTRLC = (USART_CMODE_ASYNCHRONOUS_gc |
	USART_PMODE_ODD_gc |
	USART_CHSIZE_8BIT_gc) &
	~USART_SBMODE_bm;
 /* Enable receiver and/or transmitter systems. */
	USARTD0.CTRLB = USART_RXEN_bm | USART_TXEN_bm;
 /* Set as high level interrupt. */
    USARTD0.CTRLA = USART_RXCINTLVL_HI_gc;
// enable medium and high level interrupts
	PMIC.CTRL = PMIC_MEDLVLEN_bm | PMIC_HILVLEN_bm;
// enable global interrupts
	sei();
}