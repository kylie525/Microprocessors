;************************************************************************
;	lab1.asm
;
;	Lab 1,1
;	Name: Kylie Lennon
;	Class #: 11319
;	PI Name: Timothy Carpenter
;	Description: To filter data stored within a predefined input table 
;				 based on a set of given conditions and store 
;				 a subset of filtered values into an output table.
;************************************************************************
;*********************************INCLUDES*******************************
.include "ATxmega128a1udef.inc"
;***********END OF INCLUDES******************************
;*********************************EQUATES********************************
; potentially useful expressions
.equ NULL = 0
.equ ThirtySeven = 3*7 + 37/3 - (3-7)  ; 21 + 12 + 4
;***********END OF EQUATES*******************************
;***********MEMORY CONFIGURATION*************************
; program memory constants (if necessary)
.cseg
.org 0xF123
IN_TABLE:
.db 178, 0xD2, '#', 041, '6', 043, 0x24, 0b11111010, 0xCE, 073, '<', 0b00111111, 0x00, 0b00100100
.db NULL
; label below is used to calculate size of input table
IN_TABLE_END:

; data memory allocation (if necessary)
.dseg
; initialize the output table starting address
.org 0x3737
OUT_TABLE:
.byte (IN_TABLE_END - IN_TABLE)
;***********END OF MEMORY CONFIGURATION***************
;***********MAIN PROGRAM*******************************
.cseg
; configure the reset vector 
; (ignore meaning of "reset vector" for now)
.org 0x0
	rjmp MAIN

; place main program after interrupt vectors 
; (ignore meaning of "interrupt vectors" for now)
.org 0x100
MAIN:
; point appropriate indices to input/output tables (is RAMP needed?)
; Set register Z to the address of the input table 0xF123 aka 0x1E246
	ldi ZL, 0x46	; load the low byte of the input table address into ZL 
	ldi ZH, 0xE2	; load the high byte of the input table address into ZH
	ldi r16, 1	; load register 16 with 1
	sts CPU_RAMPZ, r16;	load the rampz with 1 because of address conversion
; Set register Y to the address of the output table 0x3737
	ldi YL, 0x37	; load the low byte of the output table address into YL
	ldi YH, 0x37	; load the high byte of the output table address into YH
; loop through input table, performing filtering and storing conditions
LOOP:
	; load value from input table into an appropriate register
	elpm r16, Z+	; Load the value from the input table and increment Z
	; determine if the end of table has been reached (perform general check)
	clr r17
	cp r16, r17
	breq DONE
	; if end of table (EOT) has been reached, i.e., the NULL character was 
	; encountered, the program should branch to the relevant label used to
	; terminate the program (e.g., DONE)

	; if EOT was not encountered, perform the first specified 
	; overall conditional check on loaded value (CONDITION_1)
CHECK_1:
	; check if the CONDITION_1 is met (bit 7 of # is set); 
	; if not, branch to FAILED_CHECK1
	sbrs r16, 7
	rjmp FAILED_CHECK1
	; since the CONDITION_1 is met, perform the specified operation
	; (divide # by 2)
	lsr r16
	; check if CONDITION_1a is met (result < 126); if so, then 
	; jump to LESS_THAN_126; else store nothing and go back to LOOP
	ldi r18, 126
	cp r16, r18
	brlo LESS_THAN_126
	rjmp LOOP

LESS_THAN_126:
	; subtract 6 and store the result
	subi r16, 6
	st Y+, r16
	; go back to LOOP
	rjmp LOOP
	
FAILED_CHECK1:
	; since the CONDITION_1 is NOT met (bit 7 of # is not set, 
	; i.e., clear), perform the second specified operation 
	; (multiply by 2 [unsigned])
	lsl r16
	; check if CONDITION_2b is met (result >= 75); if so, jump to
	; GREATER_EQUAL_75 (and do the next specified operation);
	; else store nothing and go back to LOOP	
	ldi r18, 75
	cp r16, r18
	brsh GREATER_EQUAL_75
	rjmp LOOP
	
GREATER_EQUAL_75:
	; subtract 4 and store the result 
	subi r16, 4
	st Y+, r16
	; go back to LOOP
	rjmp LOOP
	
; end of program (infinite loop)
DONE: 
	rjmp DONE
;***********END OF MAIN PROGRAM **********************