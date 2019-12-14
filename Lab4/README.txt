------------------------
Lab 4: ASCII (HEX or 2SC) to Base 4 
CMPE 012 Winter 2019

Karlcut, Sukhveer
skarlcut
-------------------------

What was your approach to converting each ASCII input to two’s complement form?
My approach had many steps. The first step was determining if the input was in hex or binary, which I did by loading the second bit of each input. For hex numbers, I read each digit of the string, and converted it to hex by anding it with 0xFF. Then I subtracted 48 from the digit if it was a number, or 55 if it was a letter, to get it in decimal form. Then I shifted the first number left 4 bits and or'd the two digits together to get the unsigned decimal representation of the number. Then, I sign extended, and saved this value in $s1. For binary, I looped through the input 8 times, each time looking at the next bit, starting at the first bit of the actual number. I then logically shifted left the register I used to hold the value. Then I loaded each bit and subtracted 48 to get the decimal value, and stored the bit inside the register holding the value. Then, I sign extended, and saved this value in $s2. Then I stored the sum of $s1 and $s2 in $s0.

What did you learn in this lab?
In this lab, I learned how to use memory locations to find inputs, how to convert between characters and integers of different bases, and how to store things in memory locations for later access.

Did you encounter any issues? Were there parts of this lab you found enjoyable?
Some issues I encoutered were when I had to convert between string and integer. It took my a while to figure out how to convert between an ASCII character value and its decimal representation. Another difficult part of the lab was converting the sum to base 4. An enjoyable part of the lab was sign extending because it was easy.

How would you redesign this lab to make it better?
To make this lab better I would make using a stack to convert ti base 4 mandatory, so the lab will teach how to implement stacks in MIPS.

Did you collaborate with anyone on this lab? Please list who you collaborated with and the nature of your collaboration.
I did not collaborate with anyone.
