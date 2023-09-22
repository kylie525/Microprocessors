/*
* Lab7_4.c
*
* Name: Kylie Lennon
* Class #: 11319
* PI Name: Timothy Carpenter
* Description: Read at a rate of 137 Hz from the adc and output photoresistor data 
* over the usart to the serial plot.
*/



#include <avr/io.h>
#include <avr/interrupt.h>

// global variables
volatile int16_t photo_val = 0;
volatile uint8_t conversion_flag = 0;

void usartd0_out_char(char c);
void adc_init(void);
void tcc0_init(void);
void usartd0_init(void);

int main(void)
{
	// variables to transmit low and high bytes
	uint8_t photo_low, photo_high = 0;
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
			// convert data into low and high bytes
			photo_low = (uint8_t) photo_val;
			photo_high = (uint8_t) (photo_val >> 8);
			// output the low and high bytes
			usartd0_out_char(photo_low);
			usartd0_out_char(photo_high);
		}
	}
    
	return 0;
}


/************************************************************************************
* Name: ISR(ADCA_CH0_vect)
* Purpose: Toggle the red LED and copy the data from the photoresistor
* Inputs: None
* Outputs: None
***********************************************************************************/
ISR(ADCA_CH0_vect)
{ 
	// update the conversion flag
	conversion_flag = 1;
	// copy the data from the photoresistor
	photo_val = ADCA.CH0RES;
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
	
	// set the input source for the channel
	ADCA.CH0.MUXCTRL = ADC_CH_MUXPOS_PIN1_gc | ADC_CH_MUXNEG_PIN6_gc;
	
	// set the input mode for the channel
	ADCA.CH0.CTRL = ADC_CH_INPUTMODE_DIFFWGAIN_gc;
	
	// enable ADC interrupt when conversion is complete
	ADCA.CH0.INTCTRL = ADC_CH_INTMODE_COMPLETE_gc | ADC_CH_INTLVL_MED_gc;
	
	// initialize event system so the event channel 0 triggers the ADC conversion
	ADCA.EVCTRL = ADC_EVSEL_0123_gc | ADC_SWEEP0_bm | ADC_EVACT_CH0_gc; 
	
	// enable medium level interrupts
	PMIC.CTRL = PMIC_MEDLVLEN_bm;
	
	// enable global interrupts
	sei();
	
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
	// initialize the timer counter to have a rate of 137 Hz
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
 /* Enable interrupt (optional). */
/* USARTD0.CTRLA = USART_RXCINTLVL_MED_gc; */
}