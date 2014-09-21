ECE382_Lab02
============

#Purpose:
The purpose of this lab is to create an assembly code program that decodes bytes into a readable message given a message and a key.  Using a key, each byte of the coded message will be XORed with the key, or a part of the key, in order to find out the answer.  At first the key was only one byte long, but then the program was altered so that keys of arbirary length can be used.  The final code for this project can be seen [here](https://raw.githubusercontent.com/JohnTerragnoli/ECE382_Lab02/master/1.1main.asm).  

After this was finished, a coded method was given without a key.  In order to find the answer, then, the key had to be guessed.  The process for guessing this key can be found under the section "A Functionality".  

#Prelab:

Before any coding was done in Code Composer Studio, a flow chart was made depicting the big idea of what the program should do.  This was done in pseudocode.  This picture can be seen below.


**prelat schematic**



#Basic Functionality:
In order to perform the basic functionality, the problem was broken down into smaller parts.  First, a few lines of code were created that were meant to pull the address of where the message, where the key was from memory, and where the answer will be written.  The key and the message were in ROM, which starts at 0xC000 and the answer was written in 0x0200.  For basic functionality this was easy because the key length was knew to be one, so these addresses could be hardcoded.  A launch was done to ensure that the program was receiving these numbers correctly.  It worked correctly.  

Next, the subroutine decryptCharacter was created.  The whole point of this was to bring in a byte, XOR that byte with another byte, and then store the answer.  This was tested by hardcoding and moving/XORing byte into a register.  This was done for several cases just to make sure that the XORing process was working correctly.  It did work correctly. 

Then the subroutine decryptMessage was created.  The point of this subroutine is to step through the message and send one byte at a time through the subroutine decryptCharacter.  In order to test that decryptMessage was stepping through correctly, I had the subroutine only read from the location in memeory and rewrite the coded message into the answer location.  It did work correctly.  Also, a creative way to had to be determined for finding the end of the message.  It was noted that the basic message ended in 0x8f, and that byte was found no where else in the message.  Therefore, when this byte was found the end of the message was found.  I then tested the program again to make sure that it stopped at the correct place.  Then, instead of writing the original message to the answer location, the decryptCharacter subroutie was utilized to decode each bit.  To check the answer, the location 0x0200 was viewed and the data type changed to be "character".  The following message was displayed.  


**basic functionality answer**


After this was done, basic functionality was complete.  

#A Functionality
##The Struggle/Process/Reasoning
###Octothorpe Guess
This problem looks pretty hard.  However, I used the two previous to guess my way through.  First, I noticed that every message ended with the all famous octothorpe.  This made me guess, then that the last character in the A functionality message is also #.  # is written as 23 in hex, as described by this cite [here](http://en.wikipedia.org/wiki/ASCII#mediaviewer/File:ASCII_Code_Chart-Quick_ref_card.png).  If one may XOR the last byte in the message with this result, the answer should be one half of the key.  This answer is 0xB3.  Doing a quick check of 0x90 XOR 0xB3 results in 23, or the octothorpe at the end of the message.  

Next, it is possible to determine which byte in the key 0xB3 belongs to by finding the length of the message.  If it is even, then 0xB3 will be the second part of the key.  If the message is of odd length, it will be the first part of the key.  I counted the length to be 42.  This means that the second byte in the key is B3.

Using this knowledge, I decided to put this into my code, picking a random byte for the first half of the key.  My prediction was that every other letter would be correct, and that I might be able to guess what at least one of the bytes in the answer should be.  

Also, before I did this, I calculated which register that the program should finish writing the answer on.  I did this simply by adding 42, the length of the message, to 0x0200, where the answer is written to.  The result was 0x2A.  Therefore, if I did this correctly, there should be an octothrope at location 0x022A.  There was!!

This was the answer that resulted:

```
0x0200      0	l	.	y	X	-	8	h	.	y	X	-	7	{	.
0x020F      .	.	j	.	#	V	K	.	d	.	c	.	a	.	#
0x021E       V	J	.	b	.	#	V	J	.	b	.	#	.	.	E

```

Unfortunately, it does not even look like the humble octothorpe is in the right spot. Because of this, I started to think that my initial assumption of the octothorpe was off.  I began to look for different answers.  


###Spaces Guess
Next I decided to look for spaces.  There will most likely be spaces in this sort of message, and if not exactly spaces, something similar.  Dots have been used in previous examples so they were chosen for this guess.  This [website](http://en.wikipedia.org/wiki/ASCII#mediaviewer/File:ASCII_Code_Chart-Quick_ref_card.png) had the list of what the codes are for characters.  Dots/spaces turned out to be 0x20.  Since spaces are normally used a lot, I figured that the most common hex numbers that showed up must correspond to spaces.  The hex left and right bits are shown below:


![alt tag](https://raw.githubusercontent.com/JohnTerragnoli/ECE382_Lab02/master/2Left%20and%20Right%20smallest%20to%20largest.PNG "Right and Left Bytes")
This is a list of all of the bytes in the message.  They are separated into right and left, because each side will share a commond byte key.  They have been rearranged in order from smallest to largest to see which bytes occur the most often.  

On the right side 90 seems to be the most common. On the left side, there seems to be a tie between 16,17, and 53.  These numbers XORed with 20 is shown below:

Message|XOR w/ 0x20| Key
---|---|---
0x16|0x20|0x36
0x17|0x20|0x37
0x53|0x20|0x73
0x90|0x20|0xb0

Therefore, the keys 0x36, 0x90; 0x37, 0x90; and 0x73, 0xB0 were tried next.  



**0x36, 0xB0** Guess
```
0x0200  .	o	6	z	k	.	.	k	$	z	k	.	.	x	.
0x020F  |	$	i	.	.	e	H	7	g	.	`	!	b	<	.
0x021E   e	I	*	a	!	.	e	I	*	a	!	.	5	.	v
```

**0x37, 0xB0** Guess
```
0x0200  .	o	7	z	j	.	.	k	%	z	j	.	.	x	!
0x020F  |	%	i	!	.	d	H	6	g	!	`	.	b	=	.
0x021E  d	I	+	a	.	.	d	I	+	a	.	.	4	.	w
```

**0x73, 0xB0** Guess
```
0x0200  F	o	s	z	.	.	N	k	a	z	.	.	A	x	e
0x020F  |	a	i	e	.	.	H	r	g	e	`	d	b	y	.
0x021E  .	I	o	a	d	.	.	I	o	a	d	.	p	.	3
```
It's getting really close!! At least answer looks like its in the form of words.  And since the spaces look right for each of the cases and 0xB0 was the uniting factor among them, 0xB0 looks like it is part of the right answer.  

The next most common bytes on the left side are 0x12, 0x1C, 0x5D.  These were converted to their appropriate key again: 

Message|XOR w/ 0x20| Key
---|---|---
0x12|0x20|0x32
0x1C|0x20|0x3C
0x5D|0x20|0x7D

These cases were then attempted.  

**0x32, 0xB0** Guess
```
0x0200  .	o	2	z	o	.	.	k	.	z	o	.	.	x	$
0x020F  |	.	i	$	.	a	H	3	g	$	`	%	b	8	.
0x021E	a	I	.	a	%	.	a	I	.	a	%	.	1	.	r

```

**0x3C, 0xB0** Guess
```
0x0200  .	o	<	z	a	.	.	k	.	z	a	.	.	x	*
0x020F  |	.	i	*	.	o	H	=	g	*	`	+	b	6	.
0x021E	I	.	a	+	.	o	I	.	a	+	.	?	.	|

```

**0x7D, 0xB0** Guess
```
0x0200  .	o	<	z	a	.	.	k	.	z	a	.	.	x	*
0x020F  |	.	i	*	.	o	H	=	g	*	`	+	b	6	.
0x021E  o	I	.	a	+	.	o	I	.	a	+	.	?	.	|
```

Based on these last three findings it looks like the trend it moving away from correct.  Therfore, I'm going to revert back to the guess I made with 0x73, 0xB0, which looked pretty close.  It looks like it forms words and it is the closest guess with almost all letters.  I'm going to replace 0x90 with the next most common bytes in the odds.  Each of these bytes have two occurances: 0x9E, 0xD1, 0xF9.  These will be the next three trials then.  



**0x73, 0x9E** Guess
```
0x0200  F	A	s	T	.	.	N	E	a	T	.	.	A	V	e
0x020F  R	a	G	e	.	.	f	r	I	e	N	d	L	y	.
0x021E  .	g	o	O	d	.	.	g	o	O	d	.	p	.	3
```

Now we're in familiar territory!  With this first guess, I went no further because it looks like the answer.  Therefore, the key 0x73, 0x9E looks like it is the right key for the message.    




#Documentation: 
Used this website to check if my [XORing](http://www.miniwebtool.com/bitwise-calculator/?data_type=16&number1=CB&number2=CA&operator=XOR) was correct.  This was done until I realized that the right answer actually spelled out an answer in characters.  
