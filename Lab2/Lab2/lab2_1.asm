;************************************************************************
;	lab2_1.asm
;
;	Lab 2, Section 1
;	Name: Kylie Lennon
;	Class #: 11319
;	PI Name: Timothy Carpenter
;	Description: Output the value of the switch circuit to the 
;				 corresponding LED on the Switch and LED Backpack
;
;************************************************************************

;*********************************INCLUDES*******************************
.include "ATxmega128a1udef.inc"
;***********END OF INCLUDES******************************

;*********************************EQUATES********************************


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
	ldi r16, 0xFF
	sts PORTC_DIR, r16 ; set port C aka LEDs to be output pins
	ldi r16, 0x00
	sts PORTA_DIR, r16	; set port A aka dipswitches to be input pins

; Start infinite loop to read the dipswitches and write to the LEDs
LOOP:
	; read dipswitchs inputs
	lds r16, PORTA_IN ; load inputs into r16
	lds r17, PORTA_IN ; load inputs into r17
	com r17 
	; r16 open = 1 closed = 0
	; r17 open = 0 closed = 1
	sts PORTC_DIRSET, r17	; if switch is closed turn on LED
	sts PORTC_DIRCLR, r16	; if switch is open turn off LED

	;go back to LOOP
	rjmp LOOP

;***********END OF MAIN PROGRAM **********************
