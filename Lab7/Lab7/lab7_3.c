/*
* Lab7_3.c
*
* Name: Kylie Lennon
* Class #: 11319
* PI Name: Timothy Carpenter
* Description: Every second read from the adc and output photoresistor data 
* over the usart to the putty in decimal and hex.
*/



#include <avr/io.h>
#include <avr/interrupt.h>

// global variables
volatile int16_t photo_val = 0;
volatile uint8_t conversion_flag = 0;

void output_voltage(int16_t photo_val);
void usartd0_out_char(char c);
void adc_init(void);
void tcc0_init(void);
void usartd0_init(void);

int main(void)
{
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
			output_voltage(photo_val);
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
* Name: void output_voltage(int16_t photo_val)
* Purpose: Output photoresistor data over the usart to the putty in decimal and hex.
* Inputs: int16_t photo_val is the data from the photoresistor 
* Outputs: Outputs in the form "+1.37 V (0x22)" based off of the inputted value from the photoresistor
***********************************************************************************/
void output_voltage(int16_t photo_val)
{
	float voltage = (float)photo_val/819.0;
	if(photo_val >= 0)
	{
	  // if the value is positive output a + 	
		usartd0_out_char('+');
	}
	else
	{
	  // if the value is positive output a -
		usartd0_out_char('-');
	// stops errors from occurring for negative numbers
		voltage *= -1;
	}
	// calculate decimal digits
	uint8_t dig1 = (uint8_t) voltage;
	float voltage2 = 10*(voltage-dig1);
	uint8_t dig2 = (uint8_t)voltage2;
	float voltage3 = 10*(voltage2-dig2);
	uint8_t dig3 = (uint8_t)voltage3;
	
	//calculate hex digits
	uint8_t hex1 = (uint8_t)(photo_val >> 8);
	uint8_t hex2 = (uint8_t)(photo_val >> 4 & 0x0F);
	uint8_t hex3 = (uint8_t)(photo_val & 0x0F);

	//output digits
	usartd0_out_char(dig1+48);
	usartd0_out_char('.');
	usartd0_out_char(dig2+48);
	usartd0_out_char(dig3+48);
	usartd0_out_char(' ');
	usartd0_out_char('V');
	usartd0_out_char(' ');
	usartd0_out_char('(');
	usartd0_out_char('0');
	usartd0_out_char('x');
	if(hex1 < 10)
		usartd0_out_char(hex1+48);
	else
		usartd0_out_char(hex1+55);	
	if(hex2 < 10)
		usartd0_out_char(hex2+48);
	else
		usartd0_out_char(hex2+55);
	if(hex3 < 10)
		usartd0_out_char(hex3+48);
	else
		usartd0_out_char(hex3+55);	
	usartd0_out_char(')');
		
	// start a new line with carriage return and new line
	usartd0_out_char('\r');
	usartd0_out_char('\n');
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
* Purpose: Initialize the timer counter to have an overflow time of 1 second. Have the
* overflow trigger the event channel 0.
* Inputs: None
* Outputs: None
***********************************************************************************/
void tcc0_init(void)
{
	// initialize the timer counter 
	TCC0.PER = 31250;
	TCC0.CTRLA = TC_CLKSEL_DIV64_gc;
	
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