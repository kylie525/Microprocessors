/*
* Lab7_2.c
*
* Name: Kylie Lennon
* Class #: 11319
* PI Name: Timothy Carpenter
* Description: Initialize the adc. Read from the adc every 1/6th second, 
	write to a 16-bit variable, and toggle the red led.
*/



#include <avr/io.h>
#include <avr/interrupt.h>

volatile int16_t photo_val = 0;

void adc_init(void);
void tcc0_init(void);

int main(void)
{
	// set red led as an output
	PORTD.DIRSET = PIN4_bm;
	// initialize adc
	adc_init();
	// initialize the timer counter
	tcc0_init();
	
    while (1);
    
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
	// toggle the red led
	PORTD.OUTTGL = PIN4_bm;
	// copy the data from the photoresistor
	photo_val = ADCA.CH0RES;
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
	ADCA.CTRLB = ADC_CONMODE_bm | ADC_RESOLUTION_12BIT_gc;	
	
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
* Purpose: Initialize the timer counter to have an overflow time of 1/6th. Have the
* overflow trigger the event channel 0.
* Inputs: None
* Outputs: None
***********************************************************************************/
void tcc0_init(void)
{
	// initialize the timer counter 
	TCC0.PER = 41667;
	TCC0.CTRLA = TC_CLKSEL_DIV8_gc;
	
	// trigger event channel when counter overflows
	EVSYS.CH0MUX = EVSYS_CHMUX_TCC0_OVF_gc;
}

