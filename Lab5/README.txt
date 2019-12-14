------------------------ 
Lab 5: Subroutines
CMPE 012 Winter 2019
Karlcut, Sukhveer
skarlcut 
-------------------------

What was your design approach? 
My design approach was to implement the lowest subroutines first, and then work my way up. In essence, completing give prompt, print strings, and checksum, and then completing the subroutines that call those methods, encrypt and decrypt, and finally cipher, which calls everything.
What did you learn in this lab? 
In this lab, I learned many things. First, I learned how to use subroutines across different files, and how to use the $ra register to keep track of where I was. I also learned how to use stacks, which I used to nest subroutines and return back once I was done. Finally, I learned how to allocate memory and save data in memory.
Did you encounter any issues? Were there parts of this lab you found enjoyable?
Some issues I encountered were addding a null terminator after the resulting string so that previous answers would be overwritten. Another problem I faced was figuring out how to use the stack to keep track of where I was in memory and in the subroutine. I enjoyed encrypting and decrypting strings.
How would you redesign this lab to make it better? 
To make this lab better, I would have a subroutine that talkes in a encrypted stirng and its decrypted form, and comes up with a possible key that would produce the checksum for that encryption.
Did you collaborate with anyone on this lab? Please list who you collaborated with and the nature of your collaboration.
I did not collaborate with anyone on this lab.
