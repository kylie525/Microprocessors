/************************************************************************
hw3.c

HW 3
Name: Kylie Lennon
Class #: 11319
PI Name: Timothy Carpenter
Description: To filter data stored within a predefined input table
				based on a set of given conditions and store
				a subset of filtered values into an output table.
;************************************************************************/

#define TABSIZE 16
#include <avr/io.h>
int main(void){
	// create an array of 8-bit value with a size of 16; replace ?? with the values in Table 1, separated by commas
	uint8_t IN_TAB [TABSIZE] = { 201, 0x22, 051, 91, 0x91, 0x2A, 'U', 0130, '#', 0b01010101, 'J', 0x21, 0x55, 32, 0b00011110, 0 };
	uint8_t *IN_TAB_P = &IN_TAB; // create a pointer to this table
	// Note that using the // create a pointer to this table & above is not necessary since by default, 8-bit arrays are
	// 	pointers which point to the first element of the array.
	// Thus, using both *IN_TAB_P = &IN_TAB;   or   *IN_TAB_P = IN_TAB; will produce the same
	// 	functionality since IN_TAB  is an address; however, to remain consistent we will use the  ampersand.

	// Initialize a pointer to point to the output table at location 0x3700. Call it OUT_TAB_P
	uint8_t *OUT_TAB_P = 0x3700;

	//To start the processing, we can use the following template:
	while(1){
		// Loop till null, i.e., loop while the values at that address are non-zero (not null)
		while(*IN_TAB_P){
			// Check for the conditions
			// Recall when using an *, we are analyzing the value at that pointer
			// Dereference IN_TAB_P and check if bit 5 is set (See the Example 2).
			//if bit 5 was set, then multiply by 2
			uint8_t num = *IN_TAB_P;
			if( num & 0b00100000 ){
				// check if the value at IN_TAB_P times two is greater than or equal to 70
				num *= 2;
				if( num >=70 ) {
					/*Store the result to address pointed by OUT_TAB_P */
					// remember to alter the data at an address using a pointer, then you must use an (*). (See Example 1)
					*OUT_TAB_P = num;
					/*Increment OUT_TAB_P to move to next available space */
					OUT_TAB_P++;
				}
			}
			else{
				// if the input value (dereference IN_TAB_P) +3 is less than 78 store in the output table
				num += 3;
				if( num < 78 ){
					/*Store the result to address pointed by OUT_TAB_P */
					*OUT_TAB_P = num;
					/*Increment OUT_TAB_P to move to available space */
					OUT_TAB_P++;
				}
			}
			IN_TAB_P+=1;  // increment IN_TAB_P, the next address in IN_TAB
		}
		return 0;
	}
}