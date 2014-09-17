ECE382_Lab02
============





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
Next I decided to look for spaces.  There will most likely be spaces in this sort of message, and if not exactly spaces, something similar.  Dots have been used in previous examples so they were chosen for this guess.  This [website](http://en.wikipedia.org/wiki/ASCII#mediaviewer/File:ASCII_Code_Chart-Quick_ref_card.png) had the list of what the codes are for characters.  Dots/spaces turned out to be 0x20.  Since spaces are normally used a lot, I figured that the most common hex numbers that showed up must correspond to spaces.  The most common left and right bits are shown below: 

```
hex(left)	dec(left)
35      	53
0	        0
1	        1
12	      18
12	      18
16	      22
16	      22
16	      22
17	      23
17	      23
17	      23
32	      50
53	      83
53	      83
53	      83
0A	      10
1C	      28
1C	      28
3d	      61
5d	      93
5D	      93


hex(left)	|dec(left)|	hex(right)|		dec(right)
35|		53	|	90|		144
0|		0	|	90	|	144
1	|	1|		90	|	144
12|		18|		90|		144
12|		18|		9e|		158
16|		22|		9E|		158
16|		22|		C8|		200
16|		22|		ca|		202
17|		23|		CA|		202
17|		23|		CC|		204
17|		23|		D0|		208
32|		50|		D1|		209
53|		83|		D1|		209
53|		83|		D2|			210
53|		83|		D7|		215
0A|		10|		D9|		217
1C|		28|		db|		219
1C|		28|		df|		223
3d|		61|		F8|		248
5d|		93|		F9|		249
5D|		93|		F9|		249

  
```



#Documentation: 
Used this website to check if my [XORing](http://www.miniwebtool.com/bitwise-calculator/?data_type=16&number1=CB&number2=CA&operator=XOR) was correct.  This was done until I realized that the right answer actually spelled out an answer in characters.  
