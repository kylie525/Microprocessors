;************************************************************************
;	HW2.asm
;
;	HW 2
;	Name: Kylie Lennon
;	Class #: 11319
;	PI Name: Timothy Carpenter
;	Description: Create 24 bit color using the LEDs on the OOTB µPAD and
;				pulse-width modulation
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
.equ S1_bm = BIT2_bm
.equ S2_bm = BIT3_bm
.equ S1_bp = 2
.equ S2_bp = 3
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

; initialize the necessary switch and LED ports; set DIP switches to be inputs	ldi r16, 0xFF
	sts PORTA_DIRCLR, r16
; initialize RGB LEDS as outputs
	ldi r16, 0b01110000
	sts PORTD_DIRSET, r16 
; invert LED outputs so LEDs become active high
	ldi r16, BIT6_bm
	sts PORTD_PIN4CTRL, r16
	sts PORTD_PIN5CTRL, r16
	sts PORTD_PIN6CTRL, r16
; remap LEDs
	ldi r16, 0b00000111
	sts PORTD_REMAP, r16

	ldi r16, S1_bm
	ldi r17, S2_bm
	or r16, r17
	sts PORTF_DIRCLR, r16 ; set tactile switches on SLB to be inputs
	ldi r16, BIT0_bm
	sts PORTE_DIRCLR, r16; set s1 tacticle switch on MB to be an input
;SLB S1 = RED
;SLB S2 = BLUE
;MB S1 = GREEN

; initialize timer/counter
; initialize PER with 0x00FF
; load lower byte
	ldi r16, 0xFF
	sts TCC0_PER, r16
; load higher byte
	ldi r16, 0x00
	sts TCC0_PER+1, r16
; set prescaler
	ldi r16, TC_CLKSEL_DIV1_gc
	sts TCD0_CTRLA, r16

; set to single slope pulse wave modulation mode and enable CCx
	ldi r16, 0b01110011
	sts TCD0_CTRLB, r16

;load CCx registers with 0
	ldi r16, 0
	sts TCD0_CCA, r16
	sts TCD0_CCA+1, R16
	sts TCD0_CCB, r16
	sts TCD0_CCB+1, R16
	sts TCD0_CCC, r16
	sts TCD0_CCC+1, R16

LOOP:
	lds r16, PORTF_IN
	lds r17, PORTE_IN
; Check if red
	sbrs r16, S1_bp
	rjmp RED

; Check if blue
	sbrs r16, S2_bp
	rjmp BLUE

; Check if green
	sbrs r17, 0
	rjmp GREEN

	rjmp LOOP

RED:
; check blue
	sbrs r16, S2_bp
	rjmp LOOP
; check green
	sbrs r17, 0
	rjmp LOOP

; load dipswitch value into CCA
	lds r16, PORTA_IN
	com r16
	sts TCD0_CCA, r16
	ldi r16, 0
	sts TCD0_CCA+1, R16

	rjmp LOOP

BLUE:
; check green
	sbrs r17, 0
	rjmp LOOP

; load dipswitch value into CCC
	lds r16, PORTA_IN
	com r16
	sts TCD0_CCC, r16
	ldi r16, 0
	sts TCD0_CCC+1, R16

	rjmp LOOP

GREEN:
; load dipswitch value into CCB
	lds r16, PORTA_IN
	com r16
	sts TCD0_CCB, r16
	ldi r16, 0
	sts TCD0_CCB+1, R16

	rjmp LOOP