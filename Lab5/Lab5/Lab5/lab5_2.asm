;************************************************************************
; lab5_2.asm
;
; Name: Kylie Lennon
; Class #: 11319
; PI Name: Timothy Carpenter
; Description: Initialize USART and continuously transmit 'U' with 
;				72000 BAUD, 8 data bits, 1 stop bit, 1 start bit, odd parity
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

.equ CR = 13	; carrige return. could also use '/r'
.equ LF = 10	; line feed. could also use '/n'

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
; initialize the USART
	rcall INIT_USART

LOOP:
	ldi r16, 'U'
	rcall OUT_CHAR
	rjmp LOOP

;***********END OF MAIN PROGRAM **********************

/************************************************************************************
* Name: OUT_CHAR
* Purpose: recieves a character via r16 and will poll the DREIF (data register
*	empty flag) until it is true, then the character will be sent to the USART dat register		
* Inputs: Data to be transmitted is in register 16
* Outputs: Transmit the data
* Destroys: None
* Reg Used: USARTD0_STATUS, USARTD0_DATA
* Calls: None
***********************************************************************************/
OUT_CHAR:
	push r17

TX_POLL:
; load status register
	lds r17, USARTD0_STATUS

; check if the data register empty flag (DREIF) is set (to send out a character)
; else go back to polling
	sbrs r17, USART_DREIF_bp ; bit 5
	rjmp TX_POLL

; send the character out over the USART
	sts USARTD0_DATA, r16

	pop r17

; return 
	ret

/************************************************************************************
* Name: INIT_USART
* Purpose: Subroutine to initialize Port D pin3 for output (PORTD0 TX)
*			72000 BAUD, 8 data bits, 1 stop bit, 1 start bit, odd parity
* Inputs: None
* Outputs: None
* Destroys: r16
* Reg Used: PORTD_DIR, PORTD_OUT, USARTD0_CTRLB, USARTD0_CTRLC, USARTD0_BAUDCTRLA,
*			USARTD0_BAUDCTRLB
* Calls: None
***********************************************************************************/
INIT_USART:
; Set the Tx line to default to '1' idle
; Set PortD_PIN3 as output for TX pin of USARTDO
	ldi r16, BIT3_bm
	sts PORTD_OUTSET, r16
	sts PORTD_DIRSET, r16

; equate statements for BSel and BScale
.equ BSel = 47
.equ BScale = -6	; 72000 Hz

; set parity mode to odd, 8 bit frame, 1 stop bit
	ldi r16, (USART_PMODE_ODD_gc | \
				USART_CMODE_ASYNCHRONOUS_gc | \
				USART_CHSIZE_8BIT_gc)
	sts USARTD0_CTRLC, r16

; initialize baud rate
; set BAUDCTRLA with only the lower 8 bits of BSel
	ldi r16, low(BSel)
	sts USARTD0_BAUDCTRLA, r16

; set BAUDCTRLB to BScale(4 bits) | BSel (upper 4 bits)
	ldi r16, ( (BScale <<4) | high(BSel) )
	sts USARTD0_BAUDCTRLB, r16
	
; enable TX 
	ldi r16, BIT3_bm
	sts USARTD0_CTRLB, r16

; return
	ret
