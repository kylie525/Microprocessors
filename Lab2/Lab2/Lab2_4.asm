;************************************************************************
;	lab2_4.asm
;
;	Lab 2, Section 4
;	Name: Kylie Lennon
;	Class #: 11319
;	PI Name: Timothy Carpenter
;	Description: Create an animation using the switch and LED backpack
;************************************************************************

;*******INCLUDES*************************************

; The inclusion of the following file is REQUIRED for our course, since
; it is intended that you understand concepts regarding how to specify an 
; "include file" to an assembler. 
.include "ATxmega128a1udef.inc"
;*******END OF INCLUDES******************************

;*******DEFINED SYMBOLS******************************
.equ ANIMATION_START_ADDR	=	0x2000 ;useful, but not required
.equ ANIMATION_SIZE			=	0x1FFF	;useful, but not required

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
;*******END OF DEFINED SYMBOLS***********************

;*******MEMORY CONSTANTS*****************************
; data memory allocation
.dseg

.org ANIMATION_START_ADDR
ANIMATION:
.byte ANIMATION_SIZE
;*******END OF MEMORY CONSTANTS**********************

;*******MAIN PROGRAM*********************************
.cseg
; upon system reset, jump to main program (instead of executing
; instructions meant for interrupt vectors)
.org 0x0
	rjmp MAIN

; place the main program somewhere after interrupt vectors (ignore for now)
.org 0x100	; >= 0xFD
MAIN:
; initialize the stack pointer
	ldi r16, 0xFF
	sts CPU_SPL, r16
	ldi r16, 0X3F
	sts CPU_SPH, r16

; initialize relevant I/O modules (switches and LEDs)
	rcall IO_INIT

; initialize (but do not start) the relevant timer/counter module(s)
	rcall TC_INIT

; Initialize the X and Y indices to point to the beginning of the 
; animation table. (Although one pointer could be used to both
; store frames and playback the current animation, it is simpler
; to utilize a separate index for each of these operations.)
; Note: recognize that the animation table is in DATA memory
	ldi XL, low(ANIMATION_START_ADDR)
	ldi XH, high(ANIMATION_START_ADDR)
	ldi ZL, low(ANIMATION_START_ADDR)
	ldi ZH, high(ANIMATION_START_ADDR)


; begin main program loop 
	
; "EDIT" mode
EDIT:
	
; Check if it is intended that "PLAY" mode be started, i.e.,
; determine if the relevant switch has been pressed.
	lds r16, PORTF_IN ; read SLB tactile switch inputs

; If it is determined that relevant switch was pressed, 
; go to "PLAY" mode.
; if S2 is pressed aka 0
	sbrs r16, S2_bp
	rjmp PLAY 

; Otherwise, if the "PLAY" mode switch was not pressed,
; update display LEDs with the voltage values from relevant DIP switches
; and check if it is intended that a frame be stored in the animation
; (determine if this relevant switch has been pressed).

; update LEDs
; read dipswitchs inputs
	lds r16, PORTA_IN ; load dipswitch inputs into r16
	lds r17, PORTA_IN ; load dipswitch inputs into r17
	com r17 
	; r16 open = 1 closed = 0
	; r17 open = 0 closed = 1
	sts PORTC_DIRSET, r17	; if switch is closed turn on LED
	sts PORTC_DIRCLR, r16	; if switch is open turn off LED

; check if store frame was pushed
	lds r16, PORTF_IN ; read SLB tactile switch inputs

; If the "STORE_FRAME" switch was not pressed,
; branch back to "EDIT".
	sbrc r16, S1_bp
	rjmp EDIT

; Otherwise, if it was determined that relevant switch was pressed,
; perform debouncing process, e.g., start relevant timer/counter
; and wait for it to overflow. (Write to CTRLA and loop until
; the OVFIF flag within INTFLAGS is set.)

; After relevant timer/counter has overflowed (i.e., after
; the relevant debounce period), disable this timer/counter,
; clear the relevant timer/counter OVFIF flag,
; and then read switch value again to verify that it was
; actually pressed. If so, perform intended functionality, and
; otherwise, do not; however, in both cases, wait for switch to
; be released before jumping back to "EDIT".

; Wait for the "STORE FRAME" switch to be released
; before jumping to "EDIT".
STORE_FRAME_SWITCH_RELEASE_WAIT_LOOP:
; If overflow flag is not raised jump back to WAIT
	lds r16, TCC0_INTFLAGS
	sbrs r16, TC0_OVFIF_bp
	rjmp STORE_FRAME_SWITCH_RELEASE_WAIT_LOOP
; If overflow flag is raised clear flag and check again
	ldi r16, TC0_OVFIF_bm
	sts TCC0_INTFLAGS, r16
	
; check if store frame was pushed
	lds r16, PORTF_IN ; read SLB tactile switch inputs

; If the "STORE_FRAME" switch was not pressed,
; branch back to "EDIT".
	sbrs r16, S1_bp
	rjmp STORE_FRAME_SWITCH_RELEASE_WAIT_LOOP ;if the switch is still pressed wait some more
; perform store
	; read dipswitchs inputs
	lds r16, PORTA_IN ; load inputs into r16
	st X+, r16 ; store frame into memory and increment X pointer
	rjmp EDIT ; go back to edit to record next pattern

	
; "PLAY" mode
PLAY:

; Reload the relevant index to the first memory location
; within the animation table to play animation from first frame.
	ldi ZL, low(ANIMATION_START_ADDR)
	ldi ZH, high(ANIMATION_START_ADDR)

PLAY_LOOP:

; Check if it is intended that "EDIT" mode be started
; i.e., check if the relevant switch has been pressed.`
	lds r16, PORTE_IN ; read MB tactile switch inputs

; If it is determined that relevant switch was pressed, 
; go to "EDIT" mode.
	sbrs r16, 0
	rjmp EDIT

; Otherwise, if the "EDIT" mode switch was not pressed,
; determine if index used to load frames has the same
; address as the index used to store frames, i.e., if the end
; of the animation has been reached during playback.
; (Placing this check here will allow animations of all sizes,
; including zero, to playback properly.)
; To efficiently determine if these index values are equal,
; a combination of the "CP" and "CPC" instructions is recommended.
	cp ZL, XL
	brne DISPLAY
	cp ZH, XH
	brne DISPLAY

; If index values are equal, branch back to "PLAY" to
; restart the animation.
	rjmp PLAY

; Otherwise, load animation frame from table, 
; display this "frame" on the relevant LEDs,
DISPLAY:
	ld r16, Z
	ld r17, Z+
	com r17
	sts PORTC_DIRSET, r17	; turn on LED
	sts PORTC_DIRCLR, r16	; turn off LED
; start relevant timer/counter,
; wait until this timer/counter overflows (to more or less
; achieve the "frame rate"), and then after the overflow,
; stop the timer/counter,
; clear the relevant OVFIF flag,
WAIT:
	; If overflow flag is not raised jump back to WAIT
	lds r16, TCC0_INTFLAGS
	sbrs r16, TC0_OVFIF_bp
	rjmp WAIT 
; If overflow flag is raised clear flag
	ldi r16, TC0_OVFIF_bm
	sts TCC0_INTFLAGS, r16
; and then jump back to "PLAY_LOOP".
	rjmp PLAY_LOOP

; end of program (never reached)
DONE: 
	rjmp DONE
;*******END OF MAIN PROGRAM *************************

;*******SUBROUTINES**********************************

;****************************************************
; Name: IO_INIT 
; Purpose: To initialize the relevant input/output modules, as pertains to the
;		   application.
; Input(s): N/A
; Output: N/A
;****************************************************
IO_INIT:
; protect relevant registers
	push r16
	push r17

; initialize the relevant I/O
	ldi r16, 0xFF
	sts PORTA_DIRCLR, r16 ; set DIP switches to be inputs
	sts PORTC_DIRSET, r16 ; set LEDs to be outputs
	ldi r16, S1_bm
	ldi r17, S2_bm
	or r16, r17
	sts PORTF_DIRCLR, r16 ; set tactile switches on SLB to be inputs
	ldi r16, BIT0_bm
	sts PORTE_DIRCLR, r16; set s1 tacticle switch on MB to be an input

; recover relevant registers
	pop r17
	pop r16

; return from subroutine
	ret
;****************************************************
; Name: TC_INIT 
; Purpose: To initialize the relevant timer/counter modules, as pertains to
;		   application.
; Input(s): N/A
; Output: N/A
;****************************************************
TC_INIT:
; protect relevant registers
	push r16

; initialize the relevant TC modules
; Initialize counter value
; Period*(Frequency/Prescalar)= counter value
; Calculated counter value is 50,000 aka 0xC350
; Most precise counter value was around 0xC724
; load lower byte
	ldi r16, 0x24
	sts TCC0_PER, r16
; load higher byte
	ldi r16, 0xC7
	sts TCC0_PER+1, r16

; Set prescalar value
	ldi r16, TC_CLKSEL_DIV8_gc
	sts TCC0_CTRLA, r16

; recover relevant registers
	pop r16

; return from subroutine
	ret

;*******END OF SUBROUTINES***************************