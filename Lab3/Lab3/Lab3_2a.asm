;************************************************************************
;	Lab3_2a.asm
;
;	Lab 3, Section 2, Part A
;	Name: Kylie Lennon
;	Class #: 11319
;	PI Name: Timothy Carpenter
;	Description: Have tactile switch S2 on the SLB trigger an interrupt to
;				increment a count. The green LED should be flashing and the 
;				SLB LEDs should display the count value. S2 is not debounced.
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

.equ S2_bm = BIT3_bm
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
.org 0x00
	rjmp MAIN

; interrupt vector
.org PORTF_INT0_vect
	rjmp S2_INTERRUPT

.org 0x200
MAIN:
; initialize MCU components like the stack
	ldi r16, 0xFF
	sts CPU_SPL, r16
	ldi r16, 0x3F
	sts CPU_SPL, r16

; initialize the necessary switch and LED ports
; initialize the 8 LEDs
	ldi r16, 0xFF
	sts PORTC_DIRSET, r16 ; set port C to be output pins
	; invert LEDs to make them active high
	ldi r16, BIT6_bm
	sts PORTC_PIN0CTRL, r16
	sts PORTC_PIN1CTRL, r16
	sts PORTC_PIN2CTRL, r16
	sts PORTC_PIN3CTRL, r16
	sts PORTC_PIN4CTRL, r16
	sts PORTC_PIN5CTRL, r16
	sts PORTC_PIN6CTRL, r16
	sts PORTC_PIN7CTRL, r16
	sts PORTC_OUTCLR, r16 ; turn off leds

 ; initialize the green LED
	ldi r16, BIT5_bm
	sts PORTD_DIRSET, r16

; initialize interrupt 
	call INIT_INTERRUPT

LOOP: ; start forever loop
	ldi r18, BIT5_bm
	sts PORTD_OUTTGL, r18
	rjmp LOOP;

;***********END OF MAIN PROGRAM **********************

/************************************************************************************
* Name:     INIT_INTERRUPT
* Purpose:  Subroutine to initialize the S2 interrupt
* Inputs:   None			 
* Outputs:  r17
* Affected: r16, r17, PORTF_DIRCLR, PORTF_INT0MASK, PORTF_INTCTRL, PMIC_CTRL, PORTF_PIN3CTRL
 ***********************************************************************************/
INIT_INTERRUPT:
; push status register onto the stack
	lds r16, CPU_SREG
	push r16

; initialize S2 as an input
	ldi r16, S2_bm
	sts PORTF_DIRCLR, r16

; set as interrupt pin
	ldi r16, S2_bm
	sts PORTF_INT0MASK, r16

; set as high level priority
	ldi r16, PORT_INT0LVL_HI_gc ;0x03
	sts PORTF_INTCTRL, r16 ; high priority

; enable high priority interrupts with PMIC
	ldi r16, PMIC_HILVLEX_bm ; 0x04
	sts PMIC_CTRL, r16
 
 ; interrupt will trigger when button is pressed aka low
	ldi r16, 0b00000011 ; low 0x03
	sts PORTF_PIN3CTRL, r16

; initialize count to 0
	ldi r17, 0

; pop status register off the stack
	pop r16
	sts CPU_SREG, r16

; enable global interrupts
	sei

; return 
	ret



/************************************************************************************
* Name:     S2_INTERRUPT
* Purpose:  Interrupt service routine to increment a count every time S2 is 
			pressed and update the LEDs
* Inputs:   r17 (count)
* Outputs:  r17
* Affected: r16, r17, PORTC_OUT, PORTF_INTFLAGS
 ***********************************************************************************/
S2_INTERRUPT:
; push status register onto the stack
	lds r16, CPU_SREG
	push r16

; clear flag write a 0 to clear it without changing other flags
	lds r16, PORTF_INTFLAGS
	andi r16, 0b11111110 ; zeros out only bit 0 
	sts PORTF_INTFLAGS, r16

; increment count
	inc r17

; update LEDs
	sts PORTC_OUT, r17

; pop status register off the stack
	pop r16
	sts CPU_SREG, r16

; return
	reti