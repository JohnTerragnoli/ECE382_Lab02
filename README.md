ECE382_Lab02
============

#Purpose:
The purpose of this lab is to create an assembly code program that decodes bytes into a readable message given a message and a key.  Using a key, each byte of the coded message will be XORed with the key, or a part of the key, in order to find out the answer.  At first the key was only one byte long, but then the program was altered so that keys of arbirary length can be used.  The final code for this project can be seen [here](https://raw.githubusercontent.com/JohnTerragnoli/ECE382_Lab02/master/1.1main.asm).  

After this was finished, a coded method was given without a key.  In order to find the answer, then, the key had to be guessed.  The process for guessing this key can be found under the section "A Functionality".  

#Prelab:

Before any coding was done in Code Composer Studio, a flow chart was made depicting the big idea of what the program should do.  This was done in pseudocode.  This picture can be seen below.


**prelab schematic**



#Basic Functionality:
In order to perform the basic functionality, the problem was broken down into smaller parts.  First, a few lines of code were created that were meant to pull the address of where the message, where the key was from memory, and where the answer will be written.  The key and the message were in ROM, which starts at 0xC000 and the answer was written in 0x0200.  For basic functionality this was easy because the key length was knew to be one, so these addresses could be hardcoded.  A launch was done to ensure that the program was receiving these numbers correctly.  It worked correctly.  

Next, the subroutine decryptCharacter was created.  The whole point of this was to bring in a byte, XOR that byte with another byte, and then store the answer.  This was tested by hardcoding and moving/XORing byte into a register.  This was done for several cases just to make sure that the XORing process was working correctly.  It did work correctly. 

Then the subroutine decryptMessage was created.  The point of this subroutine is to step through the message and send one byte at a time through the subroutine decryptCharacter.  Each iteration through decryptMessage calls decryptCharacter.  In order to test that decryptMessage was stepping through correctly, I had the subroutine only read from the location in memeory and rewrite the coded message into the answer location.  It did work correctly.  Also, a creative way to had to be determined for finding the end of the message.  It was noted that the basic message ended in 0x8f, and that byte was found no where else in the message.  Therefore, when this byte was found the end of the message was found.  I then tested the program again to make sure that it stopped at the correct place.  Then, instead of writing the original message to the answer location, the decryptCharacter subroutie was utilized to decode each bit.  To check the answer, the location 0x0200 was viewed and the data type changed to be "character".  The following message was displayed.  


**Basic Functionality Answer**
```
0x0200  C	o	n	g	r	a	t	u	l	a	t	i	o	n	s	!	.	.	Y	o	u	.	d	e	c	r
0x021A  y	p	t	e	d	.	t	h	e	.	E	C	E	3	8	2	.	h	i	d	d	e	n	.	m	e
0x0234  s	s	a	g	e	.	a	n	d	.	a	c	h	i	e	v	e	d	.	r	e	q	u	i	r	e
0x024E  d	.	f	u	n	c	t	i	o	n	a	l	i	t	y	#	.	.	7	.	.	.	.	.	.	.
```

This is correct and therefore basic functionality was achieved.

The code for this program may be seen [here](https://raw.githubusercontent.com/JohnTerragnoli/ECE382_Lab02/master/1.1main.asm).  

#B Functionality
After this was done, B Functionality was achieved.  To do this, the program was supposed to work regardless of how long the key was.  Several changes were done with the code to ensure that it handled this new capability and that it was still backwards compatable with basic functionality.  

The first problem to solve was to figure out how long the key was.  This was tried a couple of different ways.  First, I just assumed that the first byte of the message was going to be 0xf8.  This would work for B functionality, since there are no bytes in the rest of the message or the key of 0xf8.  However, this is not compatable with A Functionality, which I knew I was going to have to work eventually.  So I decided to set up a marker byte.  I chose 0x02, since this byte was neither in in any of the messages or the keys.  

**How the Marker Works**
The key and the message are written in the code at the beginning.  This places them into ROM, specifically at 0xC000, one right after the other in whatever order they are written.  I chose to write the key before the message, but it could be done either way.  Therefore, the marker was written right in between them.  This can be seen in the [final code](https://raw.githubusercontent.com/JohnTerragnoli/ECE382_Lab02/master/1.1main.asm).  Since it is known that the key will start at exactly 0xC000, I started reading it from this address and stepped through ROM until I found the marker byte.  The address right before the marker byte was marked as the end of the key, which was stored in another register.  Once the beginning and the end of the key were known and stored separate registers, then the key itself can be stepped through during the decryption process and reset to the beginning of the key once the program has reached the end of the key.  Also, during this process of finding the key length, the beginning of the message is found and stored in a register.  The subroutine that found the length of the key, as well as the location of the beginning of the message is called "findKeyLength."  It was put into a subroutine so that the specifics of the code could be hidden once it was figured out, and then the simple command could just be called from the main section of code.  

**KeyLength Problems**
During this process I encountered a few problems.  The first one was rather simple but it took me a few minutes to figure out.  I forgot to increment the message starting point and decrement the key ending point in "findKeyLength".  This needed to be done because of the marker taking up one space inbetween the two and the subroutine ends when it finds the counter.  Therefore, I was getting some really weird messages at the end.  To fix this problem, I decided to check the most recent code I just created.  This was the findKeyLength subroutine.  I stepped through the program and watched the registers and realized that the key end point and the messge start point were off by one.  This helped me realize the root problem so that I could fix it.  I simply added an increment and a decrement for the message location and the key end respectively.  

**Looping through the Key**
Also, I created the registers key_counter, to keep track of what point in the key I am currently working on and when it needs to return to the beginning of the key, and also the key_part, which stored the byte value of that part of the key for the XORing process.  The numberical value for the key length was stored in the register key_length.  

After knowing the needed started values, I cam up with a way to step through and restart the key at the same time I was stepping through the message.  I decided that the best way to do this was in the decryptCharacter subroutine, where I would check if the key_counter equaled the key_length.  If it did, then I would reset the key_part to be referenced at 0xC000, and continue on in the XORing process.  If it did not, then I would XOR the key_part with the message and store the result as usual, and then increment where key_part was referenced.  

There were no issues with the code written for looping through the key.  


**Ending the Program**
As with basic functionality, 0x8F was the last byte in the message, and it was found no where else in the program.  Therefore, when the program comes across 0x8F, the program XORs that last byte and then jumps out of decode message and into an infinite loop.  The message that came up after the decoding was: 

```
0x0200  T	h	e	.	m	e	s	s	a	g	e	.	k	e	y	.	l	e	n	g	t	h	.	i	s
0x0219  .	1	6	.	b	i	t	s	.	.	.	I	t	.	o	n	l	y	.	c	o	n	t	a	i
0x0232  n	s	.	l	e	t	t	e	r	s	,	.	p	e	r	i	o	d	s	,	.	a	n	d	.
0x024B  s	p	a	c	e	s	#	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.
```

This is the right answer.  It was also very helpful because it gave a hint towards solving A Functionality, a problem that was tackeled below.   

Code that handles B Functionality can be seen [here](https://raw.githubusercontent.com/JohnTerragnoli/ECE382_Lab02/master/1.1main.asm).


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
