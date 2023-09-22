/*
* lab8_1.c
* 
* Name: Kylie Lennon
* Class #: 11319
* PI Name: Timothy Carpenter
* Description: Create a constant waveform of 1.7v using the DAC
*/

#include <avr/io.h>
extern void clock_init(void);
void DAC_init(void);

int main(void)
{
    // initialize the clock
	clock_init();
	// initialize DAC
	DAC_init();
	
    while (1) 
    {
		// wait until DAC is ready to transmit data
		while(DACA.STATUS & DAC_CH0DRE_bm);
		// write 1.7v aka 0xAE1 to the DAC
		DACA.CH0DATA = 0xAE1;
    }
	return 0;
}

void DAC_init(void)
{
	// select DAC channel to channel 0 only
	DACA_CTRLB = DAC_CHSEL_SINGLE_gc;
	// set reference voltage and right alignment
	DACA_CTRLC = DAC_REFSEL_AREFB_gc;
	// enable channel 0 and DAC
	DACA.CTRLA = DAC_CH0EN_bm | DAC_ENABLE_bm;
}
