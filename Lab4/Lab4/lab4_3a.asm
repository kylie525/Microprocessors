;************************************************************************
; Lab4_3a.asm
;
; Lab 4, Section 3, Part A
; Name: Kylie Lennon
; Class #: 11319
; PI Name: Timothy Carpenter
; Description: Write the data from the text file into the external SRAM
;			Then read back the data to the external I/O port at a rate
;			of 1 byte per 300 ms
;************************************************************************

;*********************************INCLUDES*******************************
.include "ATxmega128a1udef.inc"
;***********END OF INCLUDES******************************

;*********************************EQUATES********************************
.equ BIT0_bm = 0x01 << 0
.equ BIT1_bm = 0x01 << 1
.equ BIT2_bm = 0x01 << 2
.equ BIT3_bm = 0x01 << 3
.equ BIT4_bm = 0x01 << 4
.equ BIT5_bm = 0x01 << 5
.equ BIT6_bm = 0x01 << 6
.equ BIT7_bm = 0x01 << 7
;***********END OF EQUATES*******************************

;***********MEMORY CONFIGURATION*************************
; program memory constants (if necessary)
.cseg
.org 0x200
START_SRAM_TABLE:
.include "sram_data_asm.txt"
END_SRAM_TABLE:

.equ SIZE = (END_SRAM_TABLE - START_SRAM_TABLE)*2

; data memory allocation (if necessary)
.dseg
;***********END OF MEMORY CONFIGURATION***************

;***********MAIN PROGRAM*******************************
.cseg
.org 0x0
	rjmp MAIN
; interrupt vectors

.org 0x100
MAIN:
; initialize MCU components like the stack
	ldi r16, 0xFF
	sts CPU_SPL, r16
	ldi r16, 0X3F
	sts CPU_SPH, r16

; initialize EBI
	rcall EBI_INIT

; initialize timer counter
; Period*(Frequency/Prescalar)= counter value
; Counter value is approximately 9,375 aka 0x249F
; Most precise counter value was around 0x2550
; load lower byte
	ldi r16, 0x50
	sts TCC0_PER, r16
; load higher byte
	ldi r16, 0x25
	sts TCC0_PER+1, r16

; load Z with the address of the start of the table
	ldi ZL, low(START_SRAM_TABLE << 1)
	ldi ZH, high(START_SRAM_TABLE << 1)

; load Y with the external SRAM address
	ldi YL, low(SRAM_START_ADDR)
	ldi YH, high(SRAM_START_ADDR)
	ldi r16, byte3(SRAM_START_ADDR)
	sts CPU_RAMPY, r16

; load X with IO port address
	ldi XL, low(IO_START_ADDR)
	ldi XH, high(IO_START_ADDR)
	ldi r16, byte3(IO_START_ADDR)
	sts CPU_RAMPX, r16

WRITE:
; load byte from SRAM table
	lpm r16, Z+ ; has to be Z!
; store into external SRAM
	st Y+, r16

; check if at end of SRAM table
	cpi ZL, low(END_SRAM_TABLE)
	brne WRITE

	cpi ZH, high(END_SRAM_TABLE)
	brne WRITE

; set Y back to the first external SRAM address
	ldi YL, low(SRAM_START_ADDR)
	ldi YH, high(SRAM_START_ADDR)
	ldi r16, byte3(SRAM_START_ADDR)
	sts CPU_RAMPY, r16

; start timer
	ldi r16, TC_CLKSEL_DIV64_gc
	sts TCC0_CTRLA, r16

READ_BACK:
; If overflow flag is not raised jump back to READ_BACK
	lds r16, TCC0_INTFLAGS
	sbrs r16, TC0_OVFIF_bp
	rjmp READ_BACK

; If overflow flag is raised clear flag
	ldi r16, TC0_OVFIF_bm
	sts TCC0_INTFLAGS, r16
; load from external SRAM
	ld r16, Y+

; output to external LEDs
	st X, r16

; check if at end of external SRAM
	cpi YL, low(END_EXTERNAL_SRAM)
	brne READ_BACK

	cpi YH, high(END_EXTERNAL_SRAM)
	brne READ_BACK

	lds r16, CPU_RAMPY
	cpi r20, byte3(END_EXTERNAL_SRAM)
	brne READ_BACK

END:
	rjmp END
;***********END OF MAIN PROGRAM **********************

/************************************************************************************
* Name: EBI_INIT
* Purpose: Subroutine to initialize the EBI system for hardware expansion
* Inputs: None
* Outputs: None
* Affected: None
***********************************************************************************/
EBI_INIT:
; Symbols for start of relevant memory address ranges
.equ SRAM_START_ADDR = 0x128000
.equ IO_START_ADDR = 0x224000
.equ END_EXTERNAL_SRAM = SRAM_START_ADDR + SIZE

; preserve the relevant registers
	push r16

; push status register onto the stack
	lds r16, CPU_SREG
	push r16

; initialize the relevant EBI control signals to be in a false state
	ldi r16, 0b01010011
	sts PORTH_OUTSET, r16
	ldi r16, 0b00000100
	sts PORTH_OUTCLR, r16

; initialize the EBI control signals to be output from the microcontroller
	ldi r16, 0b01010111
	sts PORTH_DIRSET, r16

; initialize the address signals to be output from the microcontroller
	ldi r16, 0xFF
	sts PORTK_DIRSET, r16

; initialize the EBI system for SRAM 3-PORT ALE1 mode
	ldi r16, 0b00000001
	sts EBI_CTRL, r16

; initialize the relevant chip selects
; configure CS0
	ldi r16, 0b00011101
	sts EBI_CS0_CTRLA, r16
	ldi r16, byte2(SRAM_START_ADDR)
	sts EBI_CS0_BASEADDR, r16
	ldi r16, byte3(SRAM_START_ADDR)
	sts EBI_CS0_BASEADDR+1, r16

; configure CS2
	ldi r16, 0b00000001
	sts EBI_CS2_CTRLA, r16
	ldi r16, byte2(IO_START_ADDR)
	sts EBI_CS2_BASEADDR, r16
	ldi r16, byte3(IO_START_ADDR)
	sts EBI_CS2_BASEADDR+1, r16

; pop status register off the stack
	pop r16
	sts CPU_SREG, r16

; recover the relevant register
	pop r16

; return 
	ret