##########################################################################
# Created by: Karlcut, Sukhveer
#             skarlcut
#             19 February 2019
#
# Assignment: Lab 4: ASCII Conversion
#             CMPE 012, Computer Systems and Assembly Language 
#             UC Santa Cruz, Winter 2019
# 
# Description: This program will read a string input and convert ASCII characters into a base 4 number and print it to the console.
# 
# Notes: 
##########################################################################

# Pseudocode:
# #Method to change the base of a number from decimal to base 4
#char* convert(char result[], int inputNum) 
#{ 
#    int i = 0;  // Initialize index of result  
#    # Convert input number to base 4 base by repeatedly dividing it by 4 and taking remainder 
#    while (inputNum > 0) 
#    { 
#        result[i++] = reVal(inputNum % 4); 
#        inputNum /= 4; 
#    } 
#    result[i] = '\0';    
#    strev(result); #Reverse the result 
#    return result; 
#} 
# #Method to determine base of inputs, convert to 2s complement, and call method to convert to base 4, and return sum
#char* calc(char* a, char* b)
#{
#    if(a[1] == 'b')
#        #a is in binary
#    else
#        #a is in hex
#    if(b[1] == 'b')
#        #b is in binary
#    else
#        #b is in hex
#    printf("You entered %s, %s", a, b); #print inputs
#    #Convert a and b to 2s complement and sign extend each value
#    char* c;
#    c = convert(c, int(a+b)); #convert sum to base 4
#    printf("Sum = %s", c); $print sum
#}

# REGISTER USAGE
# $t0: user input 1
# $t1: user input 2
# $t2: holds x or b, determined by type of first input
# $t3: holds x or b, determined by type of second input
# $t4: HEX: holds first hex digit of first input, BINARY: holds the whole value of the first input in binary, DECIMAL: holds first digit of first input
# $t5: HEX: holds second hex digit of first input, BINARY: holds the whole value of the second input in binary, DECIMAL: holds second digit of first input
# $t6: HEX: holds first hex digit of second input, BASE4: loop counter to get rid of leading 0s, DECIMAL: holds thirf digit of first input
# $t7: HEX: holds second hex digit of second input, BASE4: constant holding the power of 4 to divide by, DECIMAL: holds fourth digit of first input
# $t8: loop counter for binary input, BASE4: holds quotient, which turns into the character to print, DECIMAL: constant to hold negative sign
# $t9: used to load each bit of binary input, BASE4: holds remainder, DECIMAL: holds hex value of negative symbol
# $s0: signed decimal sum of two inputs
# $s1: signed decimal representation of first input
# $s2: signed decimal representation of second input
# $s3: first holds the absolute value of the sum, then holds the dividend when converting to base 4

.data
prompt: .asciiz "You entered the numbers:\n"
output: .asciiz "\nThe sum in base 4 is:\n"
newline: .asciiz "\n"

.text
    li $v0, 4
    la $a0, prompt                       #Prints out stament before printing values entered
    syscall
    
    lw $t0, ($a1)
    la $a0, ($t0)                        #Prints out the first program argument
    li $v0, 4
    syscall
    
    li $v0, 11
    la $a0, 0x20                         #Prints a space in between program arguments
    syscall
    
    lw $t1, 4($a1)
    la $a0, ($t1)                        #prints out the second program argument
    li $v0, 4
    syscall

    lb $t2, 1($t0)                       #$t2 holds x or b for first input
    lb $t3, 1($t1)                       #$t3 holds x or b for second input
    check1:
        bne $t2, 0x78, check2            #check if the first input is in hex
        li $s1, 0
        lb $t4, 2($t0)                   #read the first digit of the number in hex as a string
        andi $t4, $t4, 0xFF              #convert the string to its hex value
        lb $t5, 3($t0)                   #read the second digit of the number in hex as a string
        andi $t5, $t5, 0xFF              #convert the string to its hex value

        ble $t4, 57, sub48               #check if the digit is a number or a letter
        subi $t4, $t4, 7                 #subtract 0x07 if the digit is a letter
        sub48:
            subi $t4, $t4, 48            #subtract 0x48 to get the decimal value
        sll $t4, $t4, 4                  #shift $t4 to the left by 4 bits to make space for the next digit
        
        ble $t5, 57, subt48              #check if the digit is a number or a letter
        subi $t5, $t5, 7                 #subtract 0x07 if the digit is a letter
        subt48:
            subi $t5, $t5, 48            #subtract 0x48 to get the decimal value

        or $s1, $t4, $t5                 #save the signed decimal value into $s1
    check2:
        bne $t3, 0x78, check3            #check if the first input is in hex 
        li $s2, 0
        lb $t6, 2($t1)                   #read the first digit of the number in hex as a string
        andi $t6, $t6, 0xFF              #convert the string to its hex value
        lb $t7, 3($t1)                   #read the second digit of the number in hex as a string
        andi $t7, $t7, 0xFF              #convert the string to its hex value

        ble $t6, 57, subtr48             #check if the digit is a number or a letter
        subi $t6, $t6, 7                 #subtract 0x07 if the digit is a letter
        subtr48:
            subi $t6, $t6, 48            #subtract 0x48 to get the decimal value
        sll $t6, $t6, 4                  #shift $t4 to the left by 4 bits to make space for the next digit
        
        ble $t7, 57, subtra48            #check if the digit is a number or a letter
        subi $t7, $t7, 7                 #subtract 0x07 if the digit is a letter
        subtra48:
            subi $t7, $t7, 48            #subtract 0x48 to get the decimal value

        or $s2, $t6, $t7                 #save the signed decimal value into $s2
    check3:
        bne $t2, 0x62, check4            #check if the firstinput is in binary
        li $t8, 0
        addi $t0, $t0, 1                 #offset the input so lb starts at the actual value
        li $t4, 0
        loop1:
            beq $t8, 8, set              #loop 8 times
            sll $t4, $t4, 1              #shift the current value left 1 bit
            addi $t0, $t0, 1             #offset the address pointing to the input by 1 to point to the next digit
            lb $t9, ($t0)                #load each bit of the binary number
            subi $t9, $t9, 48            #subtract 0x48 to get the decimal value
            or $t4, $t4, $t9             #save the signed decimal value into $t4
            addi $t8, $t8, 1             #increment counter
            j loop1                      #loop back
        set:
            move $s1, $t4                #save the signed decimal value into $s1
    check4:
        bne $t3, 0x62, check5            #check if the firstinput is in binary
        li $t8, 0
        addi $t1, $t1, 1                 #offset the input so lb starts at the actual value
        li $t5, 0
        loop2:
            beq $t8, 8, set1             #loop 8 times
            sll $t5, $t5, 1              #shift the current value left 1 bit
            addi $t1, $t1, 1             #offset the address pointing to the input by 1 to point to the next digit
            lb $t9, ($t1)                #load each bit of the binary number
            subi $t9, $t9, 48            #subtract 0x48 to get the decimal value
            or $t5, $t5, $t9             #save the signed decimal value into $t5
            addi $t8, $t8, 1             #increment counter
            j loop2                      #loop back
        set1:
            move $s2, $t5                #save the signed decimal value into $s2
   check5:
        bnez $s1, check6                 #if input has already been converted, jump to sum
        li $t9, 0x2D                     #negative symbol
        li $s1, 0
        li $t8, 1
        lb $t4, ($t0)                    #read the first digit of the number in hex as a string
        andi $t4, $t4, 0xFF              #convert the string to its hex value
        bne $t4, $t9, continue           #If positive, jump to next segment
        li $t4, 0x30                     #if negative, set negative symbol to 0, and store negative symbol somewhere else
        li $t8, -1
        
        
        continue:
        lb $t5, 1($t0)                   #read the second digit of the number in hex as a string
        andi $t5, $t5, 0xFF              #convert the string to its hex value
        beq $t5, $0, sub1                #if 1 digit positive, go to that branch
        lb $t6, 2($t0)                   #read the second digit of the number in hex as a string
        andi $t6, $t6, 0xFF              #convert the string to its hex value
        beq $t6, $0, sub2                #if 2 digit positive or 1 digit negative, go to that branch
        lb $t7, 3($t0)                   #read the second digit of the number in hex as a string
        andi $t7, $t7, 0xFF              #convert the string to its hex value
        beq $t7, $1, sub3                #if 3 digit positive or 2 digit negative, go to that branch
        j cont1                          #if 4 digit positive, go to that branch
        sub1:
            subi $t4, $t4, 48            #subtract 0x48 to get the decimal value
            move $s1, $t4
            j check6
        
        
        sub2:
            subi $t4, $t4, 48            #subtract 0x48 to get the decimal value
            mul $t4, $t4, 10             #multiply by 10 to shift over
            subi $t5, $t5, 48            #subtract 0x48 to get the decimal value
            add $s1, $t4, $t5            #save the signed decimal value into $s1
            mul $s1, $s1, $t8            #save the signed decimal value into $s1
            j check6
        
        sub3:
            subi $t4, $t4, 48            #subtract 0x48 to get the decimal value
            mul $t4, $t4, 100            #multiply by 100 to shift over
            subi $t5, $t5, 48            #subtract 0x48 to get the decimal value
            mul $t5, $t5, 10             #multiply by 10 to shift over
            subi $t6, $t6, 48            #subtract 0x48 to get the decimal value
            add $s1, $t4, $t5            #save the signed decimal value into $s1
            add $s1, $s1, $t6            #save the signed decimal value into $s1
            mul $s1, $s1, $t8
            j check6
        cont1:
            subi $t4, $t4, 48            #subtract 0x48 to get the decimal value
            subi $t5, $t5, 48            #subtract 0x48 to get the decimal value
            mul $t5, $t5, 100            #multiply by 100 to shift over
            subi $t6, $t6, 48            #subtract 0x48 to get the decimal value
            mul $t6, $t6, 10             #multiply by 10 to shift over
            subi $t7, $t7, 48            #subtract 0x48 to get the decimal value
            add $s1, $t5, $t6            #save the signed decimal value into $s1
            add $s1, $s1, $t7            #save the signed decimal value into $s1
            mul $s1, $s1, $t8            #if negative, multiply by -1
   
   check6:
        bnez $s2, sum                    #if input has already been converted, jump to sum
        li $t9, 0x2D                     #negative symbol
        li $s2, 0
        li $t8, 1
        lb $t4, ($t1)                    #read the first digit of the number in hex as a string
        andi $t4, $t4, 0xFF              #convert the string to its hex value
        bne $t4, $t9, continue1          #If positive, jump to next segment
        li $t4, 0x30                     #if negative, set negative symbol to 0, and store negative symbol somewhere else
        li $t8, -1
        
        continue1:
        lb $t5, 1($t1)                   #read the second digit of the number in hex as a string
        andi $t5, $t5, 0xFF              #convert the string to its hex value
        beq $t5, $0, sub4                #if 1 digit positive, go to that branch
        lb $t6, 2($t1)                   #read the second digit of the number in hex as a string
        andi $t6, $t6, 0xFF              #convert the string to its hex value
        beq $t6, $0, sub5                #if 2 digit positive or 1 digit negative, go to that branch
        lb $t7, 3($t1)                   #read the second digit of the number in hex as a string
        andi $t7, $t7, 0xFF              #convert the string to its hex value
        beq $t7, $0, sub6                #if 3 digit positive or 2 digit negative, go to that branch
        j cont2                          #if 4 digit positive, go to that branch
        sub4:
            subi $t4, $t4, 48            #subtract 0x48 to get the decimal value
            move $s2, $t4
            j sum
        
        
        sub5:
            subi $t4, $t4, 48            #subtract 0x48 to get the decimal value
            mul $t4, $t4, 10             #multiply by 10 to shift over
            subi $t5, $t5, 48            #subtract 0x48 to get the decimal value
            add $s2, $t4, $t5            #save the signed decimal value into $s2
            mul $s2, $s2, $t8            #save the signed decimal value into $s2
            j sum
        sub6:
            subi $t4, $t4, 48            #subtract 0x48 to get the decimal value
            mul $t4, $t4, 100            #multiply by 100 to shift over
            subi $t5, $t5, 48            #subtract 0x48 to get the decimal value
            mul $t5, $t5, 10             #multiply by 10 to shift over
            subi $t6, $t6, 48            #subtract 0x48 to get the decimal value
            add $s2, $t4, $t5            #save the signed decimal value into $s2
            add $s2, $s2, $t6            #save the signed decimal value into $s2
            mul $s2, $s2, $t8
            j sum
        cont2:
            subi $t4, $t4, 48            #subtract 0x48 to get the decimal value
            subi $t5, $t5, 48            #subtract 0x48 to get the decimal value
            mul $t5, $t5, 100            #multiply by 100 to shift over
            subi $t6, $t6, 48            #subtract 0x48 to get the decimal value
            mul $t6, $t6, 10             #multiply by 10 to shift over
            subi $t7, $t7, 48            #subtract 0x48 to get the decimal value
            add $s2, $t5, $t6            #save the signed decimal value into $s2
            add $s2, $s2, $t7            #save the signed decimal value into $s2
            mul $s2, $s2, $t8            #if negative, multiply by -1
        
    sum:
        sll $s1, $s1, 24                 #logical shift left for sign extension
        sra $s1, $s1, 24                 #arithmetic right shift for sign extension
        
        sll $s2, $s2, 24                 #logical shift left for sign extension
        sra $s2, $s2, 24                 #arithmetic right shift for sign extension
        li $v0, 4
        la $a0, newline                  #print newline
        syscall
    	add $s0, $s1, $s2                #store the sum of the two signed integers in $s0
    	
    abs $s3, $s0                         #store the absolute value of the sum to convert into base 4
    li $v0, 4
    la $a0, output                       #print a string stating the sum in base 4 is
    syscall
    bge $s0, 0, convert                  #check if the signed decimal sum is negative
        li $v0, 11
        li $a0, 0x2D                     #print the negative symbol if the sum is negative
        syscall
        
    convert:
        li $t7, 256                      #The divisor, in powers of 4, shifted down one power of 4 every loop cycle
        li $t6, 0                        #counter to get rid of leading 0s
        div4:
            div $s3, $t7                 #Divide the dividend by a power of 4
            mfhi $t9                     #store remainder in $t9
            mflo $t8                     #store quotient in $t8
            add $t6, $t6, $t8            #counter to see if there has been a non zero quotient to determine whether or not to print
            addi $t8, $t8, 48            #convert the decimal number into a character
            beqz $t6, skip               #if there has been a nonzero quotient, print the quotient
            li $v0, 11
            move $a0, $t8                #print the current quotient
            syscall
            skip:
                beqz $t9, exit           #if the remainder is 0, we are done!
                move $s3, $t9            #set the new dividend to be the remainder
                srl $t7, $t7, 2          #shift $t7, the constant with the powers of 4, right to move down a power of 4
            j div4                       #loop back

    exit:
    li $v0, 4
    la $a0, newline                      #print newline
    syscall
    li $v0, 10                           #exits program cleanly
    syscall
