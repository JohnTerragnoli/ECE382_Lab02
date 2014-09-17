ECE382_Lab02
============





#A Functionality
##The Struggle/Process/Reasoning
This problem looks pretty hard.  However, I used the two previous to guess my way through.  First, I noticed that every message ended with the all famous octothorpe.  This made me guess, then that the last character in the A functionality message is also #.  # is written as 23 in hex, as described by this cite [here](http://en.wikipedia.org/wiki/ASCII#mediaviewer/File:ASCII_Code_Chart-Quick_ref_card.png).  If one may XOR the last byte in the message with this result, the answer should be one half of the key.  This answer is 0xB3.  Doing a quick check of 0x90 XOR 0xB3 results in 23, or the octothorpe at the end of the message.  

Next, it is possible to determine which byte in the key 0xB3 belongs to by finding the length of the message.  If it is even, then 0xB3 will be the second part of the key.  If the message is of odd length, it will be the first part of the key.  I counted the length to be 42.  This means that the second byte in the key is B3.

Using this knowledge, I decided to put this into my code, picking a random byte for the first half of the key.  My prediction was that every other letter would be correct, and that I might be able to guess what at least one of the bytes in the answer should be.  

Also, before I did this, I calculated which register that the program should finish writing the answer on.  I did this simply by adding 42, the length of the message, to 0x0200, where the answer is written to.  The result was 0x2A.  Therefore, if I did this correctly, there should be an octothrope at location 0x022A.  There was!!

This was the answer that resulted:

```
0x0200      0	l	.	y	X	-	8	h	.	y	X	-	7	{	.
0x020F      .	.	j	.	#	V	K	.	d	.	c	.	a	.	#
0x21E       V	J	.	b	.	#	V	J	.	b	.	#	.	.	E

```

The last octothorpe on the last line signifies the end of the message, since it is at 0x022A.  



#Documentation: 
Used this website to check if my [XORing](http://www.miniwebtool.com/bitwise-calculator/?data_type=16&number1=CB&number2=CA&operator=XOR) was correct.  This was done until I realized that the right answer actually spelled out an answer in characters.  
