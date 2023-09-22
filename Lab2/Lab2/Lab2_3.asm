;************************************************************************
;	lab2_3.asm
;
;	Lab 2, Section 3
;	Name: Kylie Lennon
;	Class #: 11319
;	PI Name: Timothy Carpenter
;	Description: Toggle an output pin every 40 ms using a timer/counter 
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

.org 0x100
MAIN:
; initialize MCU components like the stack
	ldi r16, 0xFF
	sts CPU_SPL, r16
	ldi r16, 0X3F
	sts CPU_SPH, r16

; initialize the necessary switch and LED ports
	ldi r17, BIT0_bm; bitmask to set pin0 to 1
	sts PORTC_DIRSET, r17 ; set port C aka J5 pin to be an output pin

; Initialize counter value
; Period*(Frequency/Prescalar)= counter value
; Counter value is approximately 10,000 aka 0x2710
; Most precise counter value was around 0x27CA
; load lower byte
	ldi r16, 0x24
	sts TCC0_PER, r16
; load higher byte
	ldi r16, 0xC7
	sts TCC0_PER+1, r16

; Set prescalar value
	ldi r16, TC_CLKSEL_DIV8_gc
	sts TCC0_CTRLA, r16

TOGGLE:
; toggle pin 0
; bit mask was set previously for output initialization
	sts PORTC_OUTTGL, r17 ; set port C aka J5 pin to toggle

LOOP:
; If overflow flag is not raised jump back to LOOP
	lds r16, TCC0_INTFLAGS
	sbrs r16, TC0_OVFIF_bp
	rjmp LOOP 
; If overflow flag is raised clear flag and branch to TOGGLE
	ldi r16, TC0_OVFIF_bm
	sts TCC0_INTFLAGS, r16
	rjmp TOGGLE


;***********END OF MAIN PROGRAM **********************

