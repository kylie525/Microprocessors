;************************************************************************
;	lab2_3_x.asm
;
;	Lab 2, Section 3 Exercise x
;	Name: Kylie Lennon
;	Class #: 11319
;	PI Name: Timothy Carpenter
;	Description: Create a timer that keeps track of minutes and seconds
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

; Initialize counter value
; Period*(Frequency/Prescalar)= counter value
; Calculated counter value is 31,250 aka 0x7A12
; Most precise counter value was around 0x7C6F
; load lower byte
	ldi r16, 0x6F
	sts TCC0_PER, r16
; load higher byte
	ldi r16, 0x7C
	sts TCC0_PER+1, r16

; Set prescalar value
	ldi r16, TC_CLKSEL_DIV64_gc
	sts TCC0_CTRLA, r16

; Set a register equal to 60 for comparison
	ldi r19, 60

; Initialize a register for seconds and minutes to 0
	ldi r17, 0	;second register
	ldi r18, 0	;minute register
SECOND:
	;Increment second register
	inc r17
	;If second register is equal to 60 branch to MINUTE
	cp r17, r19
	breq MINUTE
	;Jump to LOOP
	rjmp  LOOP

 LOOP:
; If overflow flag is not raised jump back to LOOP
	lds r16, TCC0_INTFLAGS
	sbrs r16, TC0_OVFIF_bp
	rjmp LOOP 
; If overflow flag is raised clear flag and branch to SECOND
	ldi r16, TC0_OVFIF_bm
	sts TCC0_INTFLAGS, r16
	rjmp SECOND

MINUTE:
	;Increment minute register
	inc r18
	;Set second register equal to 0
	ldi r17, 0
	;Jump back to LOOP
	rjmp LOOP



;***********END OF MAIN PROGRAM **********************

