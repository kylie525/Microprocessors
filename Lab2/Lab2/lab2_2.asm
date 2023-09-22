;************************************************************************
;	lab2_2.asm
;
;	Lab 2, Section 2
;	Name: Kylie Lennon
;	Class #: 11319
;	PI Name: Timothy Carpenter
;	Description: Toggle an output pin at a rate of 25 Hz (0.04 s) to generate a square
;				waveform. Contains 2 subroutines: DELAY_10MS and DELAY_X_10MS 
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

.equ INNER = 200
.equ OUTER = 20

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
	ldi r16, BIT0_bm; bitmask to set pin0 to 1
	sts PORTC_DIRSET, r16 ; set port C aka J5 pin to be an output pin

LOOP:
; call DELAY_X_10MS
	ldi r19, 4
	call DELAY_X_10MS
; toggle pin 0
	sts PORTC_OUTTGL, r16 ; set port C aka J5 pin to toggle

	rjmp LOOP

;***********END OF MAIN PROGRAM **********************

; Put this org here only to "know" the address of the subroutine
.org 0x300	
;*********************SUBROUTINES**************************************
;*****************************************************
; Subroutine Name: DELAY_10MS
; Waits 10ms and then returns to main
; Inputs: None
; Ouputs: None
; Affected: r16, r17, r18
;*****************************************************
DELAY_10MS:
;If you don't want registers trashed by the subroutine, then push
;  them at beginning of subroutine and pop in reverse order at the
;  end of the subroutine.		
	push r16
	push r17
	push r18

	ldi r16, INNER
	ldi r17, OUTER
	ldi r18, 0

LOOP_INNER:
	dec r16
	cp r16, r18
	breq LOOP_OUTER
	rjmp LOOP_INNER

LOOP_OUTER:
	dec r17
	cp r17, r18
	breq END_10MS
	ldi r16, INNER
	rjmp LOOP_INNER

END_10MS:
; Restore the pushed registers to their initial values,
;   i.e., their values upon entering the subroutine
	pop r18
	pop r17
	pop r16
	
	ret		;return from subroutine

.org 0x400
;*****************************************************
; Subroutine Name: DELAY_X_10MS
; Waits 10ms and then returns to main
; Inputs: r19
; Ouputs: None
; Affected: r16, r17, r18, r19
;*****************************************************
DELAY_X_10MS:
;If you don't want registers trashed by the subroutine, then push
;  them at beginning of subroutine and pop in reverse order at the
;  end of the subroutine.		
	push r16
	push r17
	push r18
	push r19

	ldi r18, 0
	cp r19, r18
	breq END_X_10MS ; checks if input is 0

LOOP_X:
	; call DELAY_10MS
	call DELAY_10MS
	dec r19
	cp r19, r18
	breq END_X_10MS
	rjmp LOOP_X

END_X_10MS:
; Restore the pushed registers to their initial values,
;   i.e., their values upon entering the subroutine
	pop r19
	pop r18
	pop r17
	pop r16
	
	ret		;return from subroutine