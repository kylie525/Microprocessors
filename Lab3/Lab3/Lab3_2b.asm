;************************************************************************
;	Lab3_2a.asm
;
;	Lab 3, Section 2, Part B
;	Name: Kylie Lennon
;	Class #: 11319
;	PI Name: Timothy Carpenter
;	Description: Have tactile switch S2 on the SLB trigger an interrupt to
;				increment a count. The green LED should be flashing and the 
;				SLB LEDs should display the count value. S2 is debounced.
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

; interrupt vectors
.org PORTF_INT0_vect
	rjmp S2_INTERRUPT
.org TCC0_OVF_vect
	rjmp TIMER_INTR_ISR

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

; set as medium level priority
	ldi r16, PORT_INT0LVL_MED_gc 
	sts PORTF_INTCTRL, r16 ; medium priority

; interrupt will trigger when button is pressed aka falling edge
	ldi r16, 0b00000010
	sts PORTF_PIN3CTRL, r16

; initialize counter for 2 ms period found in Lab 2
; Period*(Frequency/Prescalar)= counter value
; Calculated counter value is 50,000 aka 0xC350
; Most precise counter value was around 0xC724
; load lower byte
	ldi r16, 0x24
	sts TCC0_PER, r16
; load higher byte
	ldi r16, 0xC7
	sts TCC0_PER+1, r16

; set as high priority
	ldi r16, 0b00000011; high
	sts TCC0_INTCTRLA, r16

; initialize count to 0
	ldi r17, 0

; enable high priority interrupts with PMIC
	;ldi r16, PMIC_HILVLEX_bm
	;sts PMIC_CTRL, r16

; enable medium priority interrupts with PMIC
	ldi r16, PMIC_MEDLVLEX_bm ; 0x04
	sts PMIC_CTRL, r16

; pop status register off the stack
	pop r16
	sts CPU_SREG, r16

; enable global interrupts
	sei

; return 
	ret



/************************************************************************************
* Name:     S2_INTERRUPT
* Purpose:  Interrupt service routine runs every time S2 is pressed. Starts timer counter.
* Inputs:   r17 (count)
* Outputs:  r17
* Affected: r16, r17, PORTC_OUT, PORTF_INTFLAGS
 ***********************************************************************************/
S2_INTERRUPT:
; push status register onto the stack
	lds r16, CPU_SREG
	push r16

; disable S2_INTERRUPT so it isn't triggered again
	lds r16, PORTF_INTFLAGS
	andi r16, 0b11111101 ; zeros out only bit 1 the medium level enable
	sts PORTF_INTFLAGS, r16

; enable high priority interrupts with PMIC aka timer counter interrupt
	ldi r16, PMIC_HILVLEX_bm
	sts PMIC_CTRL, r16

; start timer counter
	ldi r16, TC_CLKSEL_DIV8_gc
	sts TCC0_CTRLA, r16

; pop status register off the stack
	pop r16
	sts CPU_SREG, r16

; return
	reti

/************************************************************************************
* Name:     TIMER_INTR_ISR
* Purpose:  Debounces the switch 
* Inputs:   None
* Outputs:  None
* Affected: PORTC_OUTTGL, TCC0_INTFLAGS
 ***********************************************************************************/
TIMER_INTR_ISR:
; push status register onto the stack
	lds r16, CPU_SREG
	push r16

; disable timer counter interrupt
	ldi r16, PMIC_HILVLEX_bm
	sts PMIC_CTRL, r16

; turn off timer counter
	ldi r20, TC_CLKSEL_OFF_gc
	sts TCC0_CTRLA, r20

; clear timer flag
	ldi r16, TC0_OVFIF_bm
	sts TCC0_INTFLAGS, r16

; reset timer value
	ldi r16, 0
	sts TCC0_CNT, r16
	sts TCC0_CNT+1, r16

; check if S2 is still pressed
	lds r16, PORTF_IN

; skip increment if button is still pressed
	sbrc r16, S2_bp
		rjmp SKIP

; increment count
	inc r17

; update LEDs
	sts PORTC_OUT, r17

SKIP:
; clear switch flag write a 0 to clear it without changing other flags
	lds r16, PORTF_INTFLAGS
	andi r16, 0b11111110 ; zeros out only bit 0 
	sts PORTF_INTFLAGS, r16

; enable medium level interrupt aka switch interrupt
	ldi r16, PMIC_MEDLVLEN_bm
	sts PMIC_CTRL, r16

; pop status register off the stack
	pop r16
	sts CPU_SREG, r16

; return
	reti