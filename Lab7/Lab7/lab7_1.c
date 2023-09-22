/*
* Lab7_1.c
*
* Name: Kylie Lennon
* Class #: 11319
* PI Name: Timothy Carpenter
* Description: Initialize the adc. Continually read from the adc
	and write to a 16-bit variable
*/



#include <avr/io.h>

void adc_init(void);

int main(void)
{
	// create 16-bit variable to store the data from the photoresistor
	int16_t photo_val = 0;
	
	// initialize adc
	adc_init();
	
    while (1) 
    {
		// start adc conversion
		ADCA.CTRLA = ADC_ENABLE_bm | ADC_CH0START_bm;
		
		// wait until conversion is complete
		while(!(ADCA.INTFLAGS & 0x01));
		
		// copy the value into the variable
		photo_val = ADCA_CH0RES;
		
		// clear the conversion flag
		ADCA.INTFLAGS = 0x01;
    }
	return 0;
}


/************************************************************************************
* Name: void adc_init(void)
* Purpose: Initialize the adc to be 12 bit signed right adjusted, normal, and 
* a 2.5 v voltage reference
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
	
	// enable the adc 
	ADCA.CTRLA = ADC_ENABLE_bm;
}