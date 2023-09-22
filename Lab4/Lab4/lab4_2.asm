;************************************************************************
; Lab4_2.asm
;
; Lab 4, Section 2
; Name: Kylie Lennon
; Class #: 11319
; PI Name: Timothy Carpenter
; Description: Using EBI, continuously read from external switches
;			and write to external LEDs
;
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
; load Z with IO port address
	ldi ZL, low(IO_START_ADDR)
	ldi ZH, high(IO_START_ADDR)
	ldi r16, byte3(IO_START_ADDR)
	sts CPU_RAMPZ, r16

LOOP:
; load inputs from switches
	ld r16, Z
; store outputs to LEDs
	st Z, r16
; jump to loop
	rjmp LOOP
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