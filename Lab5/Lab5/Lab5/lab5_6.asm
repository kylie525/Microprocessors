;************************************************************************
; lab5_6.asm
;
; Name: Kylie Lennon
; Class #: 11319
; PI Name: Timothy Carpenter
; Description: Receive a string up until the carriage return character
;				and then echo the string back. Also be able to handle
;				backspace and delete.
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
.equ BS = 0x08	; backspace
.equ DEL = 0x7F	; delete

.equ MEMORY_SAVED = 0x200

;***********END OF EQUATES*******************************

;***********MEMORY CONFIGURATION*************************
; program memory constants (if necessary)
.cseg

; data memory allocation (if necessary)
.dseg
.org 0x2000
DATA_STORED:
	.byte MEMORY_SAVED
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
; set Y to the start of memory
	ldi YL, low(DATA_STORED)
	ldi YH, high(DATA_STORED)
; get inputted string
	rcall IN_STRING
; set Y to the start of memory
	ldi YL, low(DATA_STORED)
	ldi YH, high(DATA_STORED)
; output saved string
	rcall OUT_STRING_DATA_MEMORY
END:
	rjmp END

;***********END OF MAIN PROGRAM **********************
/************************************************************************************
* Name: IN_STRING
* Purpose: Stores inputted string into data memory until CP character is read
* Inputs: Y pointer
* Outputs: Stores inputted string and a null character in data memory
* Destroys: None
* Reg Used: Y
* Calls: IN_CHAR
***********************************************************************************/
IN_STRING:

LOAD_CHAR:
; get character
	rcall IN_CHAR
; if backspace or delete decrement Y
	cpi r16, BS
	breq DEC_Y
	cpi r16, DEL
	breq DEC_Y
	rjmp CR_CHECK
DEC_Y:
	ld r18, -Y ; loading something random to decrement Y
	rjmp LOAD_CHAR
CR_CHECK:
; if CR go to END_STRING
	cpi r16, CR
	breq END_STRING
; store character and intrement Y
	st Y+, r16
; go to LOAD_CHAR
	rjmp LOAD_CHAR

END_STRING:
; store null character
	ldi r16, 0
	st Y+, r16
; return 
	ret
/************************************************************************************
* Name: OUT_STRING_DATA_MEMORY
* Purpose: Outputs a string from data memory		
* Inputs: Y pointer
* Outputs: Transmit the string of data until the null character
* Destroys: None
* Reg Used: Y
* Calls: OUT_CHAR
***********************************************************************************/
OUT_STRING_DATA_MEMORY:
	push r16

OUTPUT_DATA_MEMORY:
; load character and increment pointer
	ld r16, Y+
; check if null character
	cpi r16, 0
; go to exit if null
	breq EXIT
; output character
	rcall OUT_CHAR
; loop
	rjmp OUTPUT_DATA_MEMORY

EXIT_DATA_MEMORY:
	pop r16

; return 
	ret
/************************************************************************************
* Name: OUT_STRING
* Purpose: Output a string from program memory
* Inputs: Z pointer
* Outputs: Transmit the string of data until the null character
* Destroys: None
* Reg Used: Z
* Calls: OUT_CHAR
***********************************************************************************/
OUT_STRING:
	push r16

OUTPUT:
; load character and increment pointer
	lpm r16, Z+
; check if null character
	cpi r16, 0
; go to exit if null
	breq EXIT
; output character
	rcall OUT_CHAR
; loop
	rjmp OUTPUT

EXIT:
	pop r16

; return 
	ret

/************************************************************************************
* Name: OUT_CHAR
* Purpose: recieves a character via r16 and will poll the DREIF (data register
*	empty flag) until it is true, then the character will be sent to the USART dat register		
* Inputs: Data to be transmitted is in register 16
* Outputs: Transmit the data
* Destroys: None
* Reg Used: USARTD0_STATUS, USARTD0_DATA
* Calls: NONE
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
* Name: IN_CHAR
* Purpose: recieves typed character (from PC terminal program through the PC to
* the PORTD0 USART Rx pin) into r16
* Inputs: None
* Outputs: R16 = input from SCI
* Destroys: r16
* Reg Used: USARTD0_STATUS, USARTD0_DATA
* Calls: None
***********************************************************************************/
IN_CHAR:

RX_POLL:
; load status register
	lds r16, USARTD0_STATUS
; check if the recieve flag (RXCIF) is set (to read in a character)
; else go back to polling
	sbrs r16, USART_RXCIF_bp ; bit 7
	rjmp RX_POLL
; read the character into r16
	lds r16, USARTD0_DATA
; return
	ret

/************************************************************************************
* Name: INIT_USART
* Purpose: Subroutine to initialize Port D pin3 for output (PORTD0 TX)
*			and Port D pin2 for inout (PORTD0 Rx). Initialize USARTD0 TX and RX
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

; Set PortD_PIN2 as inout for RX pin of USARTD0
	ldi r16, BIT2_bm
	sts PORTD_DIRCLR, r16

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
	
; enable TX and RX
	ldi r16, (BIT4_bm | BIT3_bm)
	sts USARTD0_CTRLB, r16

; return
	ret
