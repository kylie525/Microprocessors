/*
* lab8_5.c
*
* Name: Kylie Lennon
* Class #: 11319
* PI Name: Timothy Carpenter
* Description: Output notes, based off of keyboard presses, on the speaker by
* creating either a sin or triangle waves using events, DMA, and usart
*/

#include <avr/io.h>

extern void clock_init(void);
void DAC_init(void);
void tcc0_init(void);
void DMA_init(void);
void usart_init(void);

uint16_t sin_tab[256] = {0x800,0x832,0x864,0x896,0x8c8,0x8fa,0x92c,0x95e,0x98f,0x9c0,0x9f1,0xa22,0xa52,0xa82,0xab1,0xae0,
	0xb0f,0xb3d,0xb6b,0xb98,0xbc5,0xbf1,0xc1c,0xc47,0xc71,0xc9a,0xcc3,0xceb,0xd12,0xd39,0xd5f,0xd83,
	0xda7,0xdca,0xded,0xe0e,0xe2e,0xe4e,0xe6c,0xe8a,0xea6,0xec1,0xedc,0xef5,0xf0d,0xf24,0xf3a,0xf4f,
	0xf63,0xf76,0xf87,0xf98,0xfa7,0xfb5,0xfc2,0xfcd,0xfd8,0xfe1,0xfe9,0xff0,0xff5,0xff9,0xffd,0xffe,
	0xfff,0xffe,0xffd,0xff9,0xff5,0xff0,0xfe9,0xfe1,0xfd8,0xfcd,0xfc2,0xfb5,0xfa7,0xf98,0xf87,0xf76,
	0xf63,0xf4f,0xf3a,0xf24,0xf0d,0xef5,0xedc,0xec1,0xea6,0xe8a,0xe6c,0xe4e,0xe2e,0xe0e,0xded,0xdca,
	0xda7,0xd83,0xd5f,0xd39,0xd12,0xceb,0xcc3,0xc9a,0xc71,0xc47,0xc1c,0xbf1,0xbc5,0xb98,0xb6b,0xb3d,
	0xb0f,0xae0,0xab1,0xa82,0xa52,0xa22,0x9f1,0x9c0,0x98f,0x95e,0x92c,0x8fa,0x8c8,0x896,0x864,0x832,
	0x800,0x7cd,0x79b,0x769,0x737,0x705,0x6d3,0x6a1,0x670,0x63f,0x60e,0x5dd,0x5ad,0x57d,0x54e,0x51f,
	0x4f0,0x4c2,0x494,0x467,0x43a,0x40e,0x3e3,0x3b8,0x38e,0x365,0x33c,0x314,0x2ed,0x2c6,0x2a0,0x27c,
	0x258,0x235,0x212,0x1f1,0x1d1,0x1b1,0x193,0x175,0x159,0x13e,0x123,0x10a,0xf2,0xdb,0xc5,0xb0,
	0x9c,0x89,0x78,0x67,0x58,0x4a,0x3d,0x32,0x27,0x1e,0x16,0xf,0xa,0x6,0x2,0x1,
	0x0,0x1,0x2,0x6,0xa,0xf,0x16,0x1e,0x27,0x32,0x3d,0x4a,0x58,0x67,0x78,0x89,
	0x9c,0xb0,0xc5,0xdb,0xf2,0x10a,0x123,0x13e,0x159,0x175,0x193,0x1b1,0x1d1,0x1f1,0x212,0x235,
	0x258,0x27c,0x2a0,0x2c6,0x2ed,0x314,0x33c,0x365,0x38e,0x3b8,0x3e3,0x40e,0x43a,0x467,0x494,0x4c2,
0x4f0,0x51f,0x54e,0x57d,0x5ad,0x5dd,0x60e,0x63f,0x670,0x6a1,0x6d3,0x705,0x737,0x769,0x79b,0x7cd};

uint16_t tri_tab[256] = {0x20,0x40,0x60,0x80,0xa0,0xc0,0xe0,0x100,0x120,0x140,0x160,0x180,0x1a0,0x1c0,0x1e0,0x200,
	0x220,0x240,0x260,0x280,0x2a0,0x2c0,0x2e0,0x300,0x320,0x340,0x360,0x380,0x3a0,0x3c0,0x3e0,0x400,
	0x420,0x440,0x460,0x480,0x4a0,0x4c0,0x4e0,0x500,0x520,0x540,0x560,0x580,0x5a0,0x5c0,0x5e0,0x600,
	0x620,0x640,0x660,0x680,0x6a0,0x6c0,0x6e0,0x700,0x720,0x740,0x760,0x780,0x7a0,0x7c0,0x7e0,0x800,
	0x81f,0x83f,0x85f,0x87f,0x89f,0x8bf,0x8df,0x8ff,0x91f,0x93f,0x95f,0x97f,0x99f,0x9bf,0x9df,0x9ff,
	0xa1f,0xa3f,0xa5f,0xa7f,0xa9f,0xabf,0xadf,0xaff,0xb1f,0xb3f,0xb5f,0xb7f,0xb9f,0xbbf,0xbdf,0xbff,
	0xc1f,0xc3f,0xc5f,0xc7f,0xc9f,0xcbf,0xcdf,0xcff,0xd1f,0xd3f,0xd5f,0xd7f,0xd9f,0xdbf,0xddf,0xdff,
	0xe1f,0xe3f,0xe5f,0xe7f,0xe9f,0xebf,0xedf,0xeff,0xf1f,0xf3f,0xf5f,0xf7f,0xf9f,0xfbf,0xfdf,0xfff,
	0xfdf,0xfbf,0xf9f,0xf7f,0xf5f,0xf3f,0xf1f,0xeff,0xedf,0xebf,0xe9f,0xe7f,0xe5f,0xe3f,0xe1f,0xdff,
	0xddf,0xdbf,0xd9f,0xd7f,0xd5f,0xd3f,0xd1f,0xcff,0xcdf,0xcbf,0xc9f,0xc7f,0xc5f,0xc3f,0xc1f,0xbff,
	0xbdf,0xbbf,0xb9f,0xb7f,0xb5f,0xb3f,0xb1f,0xaff,0xadf,0xabf,0xa9f,0xa7f,0xa5f,0xa3f,0xa1f,0x9ff,
	0x9df,0x9bf,0x99f,0x97f,0x95f,0x93f,0x91f,0x8ff,0x8df,0x8bf,0x89f,0x87f,0x85f,0x83f,0x81f,0x800,
	0x7e0,0x7c0,0x7a0,0x780,0x760,0x740,0x720,0x700,0x6e0,0x6c0,0x6a0,0x680,0x660,0x640,0x620,0x600,
	0x5e0,0x5c0,0x5a0,0x580,0x560,0x540,0x520,0x500,0x4e0,0x4c0,0x4a0,0x480,0x460,0x440,0x420,0x400,
	0x3e0,0x3c0,0x3a0,0x380,0x360,0x340,0x320,0x300,0x2e0,0x2c0,0x2a0,0x280,0x260,0x240,0x220,0x200,
0x1e0,0x1c0,0x1a0,0x180,0x160,0x140,0x120,0x100,0xe0,0xc0,0xa0,0x80,0x60,0x40,0x20,0x0};

uint16_t out_tab[256] = {0x800,0x832,0x864,0x896,0x8c8,0x8fa,0x92c,0x95e,0x98f,0x9c0,0x9f1,0xa22,0xa52,0xa82,0xab1,0xae0,
	0xb0f,0xb3d,0xb6b,0xb98,0xbc5,0xbf1,0xc1c,0xc47,0xc71,0xc9a,0xcc3,0xceb,0xd12,0xd39,0xd5f,0xd83,
	0xda7,0xdca,0xded,0xe0e,0xe2e,0xe4e,0xe6c,0xe8a,0xea6,0xec1,0xedc,0xef5,0xf0d,0xf24,0xf3a,0xf4f,
	0xf63,0xf76,0xf87,0xf98,0xfa7,0xfb5,0xfc2,0xfcd,0xfd8,0xfe1,0xfe9,0xff0,0xff5,0xff9,0xffd,0xffe,
	0xfff,0xffe,0xffd,0xff9,0xff5,0xff0,0xfe9,0xfe1,0xfd8,0xfcd,0xfc2,0xfb5,0xfa7,0xf98,0xf87,0xf76,
	0xf63,0xf4f,0xf3a,0xf24,0xf0d,0xef5,0xedc,0xec1,0xea6,0xe8a,0xe6c,0xe4e,0xe2e,0xe0e,0xded,0xdca,
	0xda7,0xd83,0xd5f,0xd39,0xd12,0xceb,0xcc3,0xc9a,0xc71,0xc47,0xc1c,0xbf1,0xbc5,0xb98,0xb6b,0xb3d,
	0xb0f,0xae0,0xab1,0xa82,0xa52,0xa22,0x9f1,0x9c0,0x98f,0x95e,0x92c,0x8fa,0x8c8,0x896,0x864,0x832,
	0x800,0x7cd,0x79b,0x769,0x737,0x705,0x6d3,0x6a1,0x670,0x63f,0x60e,0x5dd,0x5ad,0x57d,0x54e,0x51f,
	0x4f0,0x4c2,0x494,0x467,0x43a,0x40e,0x3e3,0x3b8,0x38e,0x365,0x33c,0x314,0x2ed,0x2c6,0x2a0,0x27c,
	0x258,0x235,0x212,0x1f1,0x1d1,0x1b1,0x193,0x175,0x159,0x13e,0x123,0x10a,0xf2,0xdb,0xc5,0xb0,
	0x9c,0x89,0x78,0x67,0x58,0x4a,0x3d,0x32,0x27,0x1e,0x16,0xf,0xa,0x6,0x2,0x1,
	0x0,0x1,0x2,0x6,0xa,0xf,0x16,0x1e,0x27,0x32,0x3d,0x4a,0x58,0x67,0x78,0x89,
	0x9c,0xb0,0xc5,0xdb,0xf2,0x10a,0x123,0x13e,0x159,0x175,0x193,0x1b1,0x1d1,0x1f1,0x212,0x235,
	0x258,0x27c,0x2a0,0x2c6,0x2ed,0x314,0x33c,0x365,0x38e,0x3b8,0x3e3,0x40e,0x43a,0x467,0x494,0x4c2,
0x4f0,0x51f,0x54e,0x57d,0x5ad,0x5dd,0x60e,0x63f,0x670,0x6a1,0x6d3,0x705,0x737,0x769,0x79b,0x7cd};

volatile uint8_t letter = 0;
volatile float frequency = 1567.98;
volatile uint8_t select = 1;
volatile uint8_t on = 1;
volatile uint16_t wait = 0xFFFF;

int main(void)
{
	// initialize the clock
	clock_init();
	// initialize DAC
	DAC_init();
	// initialize DMA
	DMA_init();
	// initialize usart
	usart_init();
	// initialize the timer
	tcc0_init();
	
	// set the power down pin so that the speaker doesn't power down
	PORTC.OUTSET = PIN7_bm;
	PORTC.DIRSET = PIN7_bm;
	
	while (1)
	{
		// reset wait value
		wait = 0xFFFF;
		// reset on value
		on = 1;
		// wait until character is ready to be received
		while(!(USARTD0.STATUS & USART_RXCIF_bm)){}
		//read character
		letter = USARTD0.DATA;
		// swtich statement for each letter
		// s switch DMA channel and other letters update frequency
		switch(letter)
		{
			case 's':
				select = !select;
				if(select)
				{
					// copy sin table into output table
					for(int i = 0; i < 256; i++)
					out_tab[i] = sin_tab[i];	
				}
				else
				{
					// copy triangle table into output table
					for(int i = 0; i < 256; i++)
					out_tab[i] = tri_tab[i];
				}
				on = 0;
				break;
			case'e':
				frequency = 1046.50;
				break;
			case'4':
				frequency = 1108.73;
				break;
			case'r':
				frequency = 1174.66;
				break;
			case'5':
				frequency = 1244.51;
				break;
			case't':
				frequency = 1318.51;
				break;
			case'y':
				frequency = 1396.91;
				break;
			case'7':
				frequency = 1479.88;
				break;
			case'u':
				frequency = 1567.98;
				break;
			case'8':
				frequency = 1661.22;
				break;
			case'i':
				frequency = 1760.00;
				break;
			case'9':
				frequency = 1864.66;
				break;
			case'o':
				frequency = 1975.53;
				break;
			case'p':
				frequency = 2093.00;
				break;
			default:
			// if a different key is pressed
			on = 0;
		}
		
		
		if(!on)
		{
			// turn off timer 
			TCC0.CTRLA = TC_CLKSEL_OFF_gc;
		}
		else
		{
			// set the timer to the new frequency value
			TCC0.PER = (32000000/(frequency*256));
			TCC0.CTRLA = TC_CLKSEL_DIV1_gc;
		}
		
		
		// wait a short amount of time
		while(wait > 0)
		{
			//if timer counter overflows subtract from wait value
			if(TCC0.INTFLAGS & TC0_OVFIF_bm)
			wait--;
		}
		//turn off sound
		TCC0.CTRLA = TC_CLKSEL_OFF_gc;
	}
	return 0;
}

void DAC_init(void)
{
	// select DAC channel to channel 1 only
	DACA.CTRLB = DAC_CHSEL_SINGLE1_gc;
	// set reference voltage and right alignment
	DACA.CTRLC = DAC_REFSEL_AREFB_gc;
	// enable channel 1 and DAC
	DACA.CTRLA = DAC_CH1EN_bm | DAC_ENABLE_bm;
}

void tcc0_init(void)
{
	// set overflow to event channel 0
	EVSYS_CH0MUX = EVSYS_CHMUX_TCC0_OVF_gc;
}

void DMA_init(void)
{
	// reset DMA
	DMA.CTRL |= DMA_RESET_bm;
	// address control: source  reload block and increment, destination burst and increment
	DMA.CH0.ADDRCTRL = DMA_CH_SRCRELOAD_BLOCK_gc | DMA_CH_SRCDIR_INC_gc | DMA_CH_DESTRELOAD_BURST_gc | DMA_CH_DESTDIR_INC_gc;
	// trigger source is tcc0 overflow
	DMA.CH0.TRIGSRC = DMA_CH_TRIGSRC_EVSYS_CH0_gc;
	// set the size of the transfer to be the size of the sin table
	DMA.CH0.TRFCNT = (uint16_t)(sizeof(out_tab));
	// repeat block transfer forever
	DMA.CH0.REPCNT = 0;

	// set the source address to the out_tab address
	DMA.CH0.SRCADDR0 = (uint8_t)((uintptr_t)out_tab);
	DMA.CH0.SRCADDR1 = (uint8_t)(((uintptr_t)out_tab) >> 8);
	DMA.CH0.SRCADDR2 = (uint8_t)(((uint32_t)(uintptr_t)out_tab) >> 16);
	// set the destination address to DAC_CH0DATA
	DMA.CH0.DESTADDR0 = (uint8_t)((uintptr_t)&DACA.CH1DATAL);
	DMA.CH0.DESTADDR1 = (uint8_t)((uintptr_t)&DACA.CH1DATAL >> 8);
	DMA.CH0.DESTADDR2 = (uint8_t)((uint32_t)(uintptr_t)&DACA.CH1DATAL >> 16);
	
	// enable channel 0, repeat mode, single data shot, 2 byte burst
	DMA.CH0.CTRLA = DMA_CH_ENABLE_bm | DMA_CH_REPEAT_bm | DMA_CH_SINGLE_bm | DMA_CH_BURSTLEN_2BYTE_gc;
	
	// enable DMA
	DMA.CTRL |= DMA_ENABLE_bm;
}

void usart_init(void)
{
	//Set the Tx line to default to '1' idle
	//Set PortD_PIN3 as output for TX pin of USARTDO
	PORTD.OUTSET = PIN3_bm;
	PORTD.DIRSET = PIN3_bm;
	//Set PortD_PIN2 as input for RX pin of USARTD0
	PORTD.DIRCLR = PIN2_bm;
	//Configure the baud rate to 72000 Hz bsel = 3428  bscale = -7
	USARTD0.BAUDCTRLA = (uint8_t)(3428);
	USARTD0.BAUDCTRLB = (uint8_t)(((-7) << 4)|((3428) >> 8));
	//Set parity mode to odd, 8 bit frame, 1 stop bit
	USARTD0.CTRLC = (USART_CMODE_ASYNCHRONOUS_gc | USART_PMODE_ODD_gc | USART_CHSIZE_8BIT_gc) & ~USART_SBMODE_bm;
	//Enable TX and RX
	USARTD0.CTRLB = USART_RXEN_bm | USART_TXEN_bm;
}

