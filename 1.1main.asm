;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file

;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section
            .retainrefs                     ; Additionally retain any sections
                                            ; that have references to current
                                            ; section
;-------------------------------------------------------------------------------


;KEYS
;basic functionality
;keyROM:			.byte	0xAC
;B Functionailty
;keyROM:			.byte	0xAC, 0xDF, 0x23
;A Functionality
keyROM:				.byte	0x73,0x9E

;-------------------------------------------------------------------------------
;needs to go in between the key and the message
endKeyROM:		.byte	0x02 ;0x02 is not contained in any of the messages.
;-------------------------------------------------------------------------------


;MESSAGES
;messageBasic:	.byte	0xef,0xc3,0xc2,0xcb,0xde,0xcd,0xd8,0xd9,0xc0,0xcd,0xd8,0xc5,0xc3,0xc2,0xdf,0x8d,0x8c,0x8c,0xf5,0xc3,0xd9,0x8c,0xc8,0xc9,0xcf,0xde,0xd5,0xdc,0xd8,0xc9,0xc8,0x8c,0xd8,0xc4,0xc9,0x8c,0xe9,0xef,0xe9,0x9f,0x94,0x9e,0x8c,0xc4,0xc5,0xc8,0xc8,0xc9,0xc2,0x8c,0xc1,0xc9,0xdf,0xdf,0xcd,0xcb,0xc9,0x8c,0xcd,0xc2,0xc8,0x8c,0xcd,0xcf,0xc4,0xc5,0xc9,0xda,0xc9,0xc8,0x8c,0xde,0xc9,0xdd,0xd9,0xc5,0xde,0xc9,0xc8,0x8c,0xca,0xd9,0xc2,0xcf,0xd8,0xc5,0xc3,0xc2,0xcd,0xc0,0xc5,0xd8,0xd5,0x8f
;messageB:		.byte	0xf8,0xb7,0x46,0x8c,0xb2,0x46,0xdf,0xac,0x42,0xcb,0xba,0x03,0xc7,0xba,0x5a,0x8c,0xb3,0x46,0xc2,0xb8,0x57,0xc4,0xff,0x4a,0xdf,0xff,0x12,0x9a,0xff,0x41,0xc5,0xab,0x50,0x82,0xff,0x03,0xe5,0xab,0x03,0xc3,0xb1,0x4f,0xd5,0xff,0x40,0xc3,0xb1,0x57,0xcd,0xb6,0x4d,0xdf,0xff,0x4f,0xc9,0xab,0x57,0xc9,0xad,0x50,0x80,0xff,0x53,0xc9,0xad,0x4a,0xc3,0xbb,0x50,0x80,0xff,0x42,0xc2,0xbb,0x03,0xdf,0xaf,0x42,0xcf,0xba,0x50,0x8f
messageA:		.byte	0x35,0xdf,0x00,0xca,0x5d,0x9e,0x3d,0xdb,0x12,0xca,0x5d,0x9e,0x32,0xc8,0x16,0xcc,0x12,0xd9,0x16,0x90,0x53,0xf8,0x01,0xd7,0x16,0xd0,0x17,0xd2,0x0a,0x90,0x53,0xf9,0x1c,0xd1,0x17,0x90,0x53,0xf9,0x1c,0xd1,0x17,0x90

RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer




;CONSTANTS
key_loc:	.equ	0xC000
write:		.equ	0x0200
beginning:	.equ	0x02
end:		.equ	0x8f
keyLength:	.equ	0xC000
ONE_W:		.equ	0x0001
ZERO_W:		.equ	0x0000




;REGISTERS
key_part:		.equ	r4
mess_loc:		.equ	r5
write_loc:		.equ	r6
key_length:		.equ	r7
decryp_reg:		.equ	r8
check_end:		.equ	r9
key_counter: 	.equ	r10
holder:			.equ	r11





;-------------------------------------------------------------------------------
                                            ; Main loop here
;-------------------------------------------------------------------------------

;FETCH LOCATIONS

			mov.w	#write, write_loc
			mov.w	#key_loc, key_part
			mov.w	#ZERO_W, key_counter
			mov.w	#ZERO_W, key_length

			call	#findKeyLength

			;for entire message
            call    #decryptMessage

forever:    jmp     forever

;-------------------------------------------------------------------------------
 ; Subroutines


;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
;Subroutine Name: decryptMessage
;Author:	John Paul Terragnoli
;Function: Decrypts a string of bytes and stores the result in memory.  Accepts
;           the address of the encrypted message, address of the key, and address
;           of the decrypted message (pass-by-reference).  Accepts the length of
;           the message by value.  Uses the decryptCharacter subroutine to decrypt
;           each byte of the message.  Stores theresults to the decrypted message
;           location.
;Inputs: MESS_LOC, CHECK_END, WRITE_LOC, KEY, decryptCharacter,
;Outputs:
;Registers destroyed:
;-------------------------------------------------------------------------------

decryptMessage:

;loop through each element in the message

			;;CHECK IF END
more_mess   mov.b 	0(mess_loc), check_end
			sub.b	#end, check_end
			jz		the_end

			;handle character
			call	#decryptCharacter
			inc		mess_loc
			inc		write_loc

			;jump to call if not finished with the message. Check for the key.
			jmp		more_mess

the_end
			call	#decryptCharacter
			ret

;-------------------------------------------------------------------------------
;Subroutine Name: decryptCharacter
;Author:	John Paul Terragnoli
;Function: Decrypts a byte of data by XORing it with a key byte.  Returns the
;           decrypted byte in the same register the encrypted byte was passed in.
;           Expects both the encrypted data and key to be passed by value.
;Inputs:
;Outputs:
;Registers destroyed:
;-------------------------------------------------------------------------------

decryptCharacter:

			;check which part of key using.
			mov.w	key_length, holder
			sub.w	key_counter, holder
			jz		beg_key

			;this decrypts a specific byte.
decrypt		mov.b	0(mess_loc), decryp_reg
			xor.b	0(key_part), decryp_reg
			mov.b	decryp_reg, 0(write_loc)
			inc		key_counter
			inc 	key_part
			jmp		end_char

			;reset to beginning of key
beg_key		mov.w	#key_loc, key_part
			mov.w	#ZERO_W, key_counter
			jmp		decrypt

end_char    ret

;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
;Subroutine Name: findKeyLength
;Author:	John Paul Terragnoli
;Function: Finds the length of the key and the beginning of the message.  Steps through
;ROM until 0x02 is found, which is the ending marker of the key.  This is because 02
;is not used in any of the keys or the messages for the test cases.
;Inputs:
;Outputs:
;Registers destroyed: holder
;-------------------------------------------------------------------------------

findKeyLength:

findLength	mov.b	0(key_part), holder
			sub.b	#beginning, holder
			jz		begOfMessage

			;check next spot
			inc		key_part
			inc 	key_length
			jmp		findLength

begOfMessage	inc		key_part
				mov.w	key_part, mess_loc
				mov.w	#key_loc, key_part
				mov.w	#ZERO_W, key_counter
		    ret
;-------------------------------------------------------------------------------


;-------------------------------------------------------------------------------
;           Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect    .stack

;-------------------------------------------------------------------------------
;           Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
