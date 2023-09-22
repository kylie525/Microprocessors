;************************************************************************
;	Lab3_1.asm
;
;	Lab 3, Section 1
;	Name: Kylie Lennon
;	Class #: 11319
;	PI Name: Timothy Carpenter
;	Description: Every 84 ms trigger an overflow interrupt to toggle 
;				an output pin
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

; interrupt vector
.org TCC0_OVF_vect
	rjmp TIMER_INTR_ISR

.org 0x100
MAIN:
; initialize MCU components like the stack
	ldi r16, 0xFF
	sts CPU_SPL, r16
	ldi r16, 0X3F
	sts CPU_SPH, r16

; initialize the necessary switch and LED ports
	ldi r16, BIT0_bm; bitmask to set pin0 to 1
	sts PORTC_DIRSET, r16 ; set port C aka J5 pin to be an output pin

; Initialize counter value
; Period*(Frequency/Prescalar)= counter value
; Calculated counter value is 42,000 aka 0xA410
; Most precise counter value was around 0xA750
; load lower byte
	ldi r16, 0x50
	sts TCC0_PER, r16
; load higher byte
	ldi r16, 0xA7
	sts TCC0_PER+1, r16

; Set prescalar value
	ldi r16, TC_CLKSEL_DIV4_gc
	sts TCC0_CTRLA, r16

; initialize interrupt 
	call INIT_INTERRUPT

LOOP:
	rjmp LOOP

;***********END OF MAIN PROGRAM **********************

/************************************************************************************
* Name:     INIT_INTERRUPT
* Purpose:  Subroutine to initialize the internal timer interrupt
* Inputs:   None			 
* Outputs:  None
* Affected: None
 ***********************************************************************************/
INIT_INTERRUPT:
; push r16 onto the stack
	push r16

; push status register onto the stack
	lds r16, CPU_SREG
	push r16

; set as high priority
	ldi r16, 0b00000011
	sts TCC0_INTCTRLA, r16

; enable high priority interrupts with PMIC
	ldi r16, PMIC_HILVLEX_bm
	sts PMIC_CTRL, r16

; pop status register off the stack
	pop r16
	sts CPU_SREG, r16

; pop r16 off of the stack
	pop r16

; enable global interrupts
	sei

; return 
	ret


/************************************************************************************
* Name:     TIMER_INTR_ISR
* Purpose:  Interrupt service routine to toggle the output pin every 84 ms
* Inputs:   None
* Outputs:  None
* Affected: PORTC_OUTTGL, TCC0_INTFLAGS
 ***********************************************************************************/
TIMER_INTR_ISR:
; push r16 onto the stack
	push r16

; push status register onto the stack
	lds r16, CPU_SREG
	push r16
	
; clear flag
	ldi r16, TC0_OVFIF_bm
	sts TCC0_INTFLAGS, r16

; toggle output pin
	ldi r16, BIT0_bm
	sts PORTC_OUTTGL, r16

; pop status register off the stack
	pop r16
	sts CPU_SREG, r16

; pop r16 off of the stack
	pop r16

; return
	reti