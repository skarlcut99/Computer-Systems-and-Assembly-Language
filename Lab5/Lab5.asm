##########################################################################
# Created by: Karlcut, Sukhveer
#             skarlcut
#             16 March 2019
#
# Assignment: Lab 5: Subroutines
#             CMPE 012, Computer Systems and Assembly Language 
#             UC Santa Cruz, Winter 2019
# 
# Description: This program will allow the user to encrypt or decrypt strings using a Caesar Cipher.
#              In order to generate the Caesar Cipher shift value, the user will also enter a key.
#              The program will calculate the checksum of the key, and use that checksum to shift
#              each letter in the string that should encrypted/decrypted. Then, the encrypted and
#              decrypted strings are displayed to the user.
# 
# Notes: This file is called by Lab5Main.asm, assemble thatfile to execute
##########################################################################

.data
error: .asciiz "Invalid input: Please input E, D, or X.\n"
option: .space 2
input: .space 101
result: .space 101
key: .space 101
newline: .asciiz "\n"
prompt3: .asciiz "\nHere is the encrypted and decrypted string"
prompt4: .asciiz "<Encrypted> "
prompt5: .asciiz "<Decrypted> "
prompt6: .asciiz "\nDo you want to (E)ncrypt, (D)ecrypt, or e(X)it? "

.text
#--------------------------------------------------------------------
# give_prompt
#
# This function should print the string in $a0 to the user, store the user’s input in 
# an array, and return the address of that array in $v0. Use the prompt number in $a1 
# to determine which array to store the user’s input in. ​Include error checking​ for 
# the first prompt to see if user input E, D, or X if not print error message and ask 
# again.
#
# arguments:  $a0 - address of string prompt to be printed to user
#             $a1 - prompt number(0, 1, or 2)
#
# note:       prompt0: Do you want to (E)ncrypt, (D)ecrypt, or e(X)it?
#             prompt1: What is the key?
#             prompt2: What is the string?
#
# return:     $v0 - address of the corresponding user input data
#--------------------------------------------------------------------

# REGISTER USAGE
# $t0: used to check for E, D, or X
# $t1: counter for each character in string

give_prompt:
    li $v0, 4                         #print prompt
    syscall
    beq $a1, 0, zero                  #determine what to do with input
    beq $a1, 1, one
    beq $a1, 2, two
    zero:
        li $v0, 8
        la $a0, option                #save character input into byte in memory
        li $a1, 2
        syscall
        move $t0, $a0
        lb $t1, 0($t0)                #load character entered
        beq $t1, 0x45, return         #if E,D, or X, then continue
        beq $t1, 0x44, return
        beq $t1, 0x58, return
        error_check:
            li $v0, 4
            la $a0, error             #if E,D, or X not entered, print error message     
            syscall
            li $v0, 4
            la $a0, prompt6           #ask for new input
            syscall
            j zero                    #loop back
        return:
            li $v0, 11
            la $a0, '\n'              #print a newline
            syscall
            move $v0, $t0             #return character
            jr $ra                    #jump back
    one:
        li $v0, 8
        la $a0, key                   #save key input in key       
        li $a1, 102
        syscall
        move $v0, $a0                 #return key
        jr $ra                        #jump back
    two:
        li $v0, 8
        la $a0, input                 #save input in input   
        li $a1, 102
        syscall
        move $v0, $a0                 #return input
        jr $ra                        #jummp back   

#------------------------------------- -------------------------------
# cipher
#
# Calls compute_checksum and encrypt or decrypt depending on if the user input E or
# D. The numerical key from compute_checksum is passed into either encrypt or decrypt
#
# note: this should call compute_checksum and then either encrypt or decrypt
#
# arguments:  $a0 - address of E or D character
#             $a1 - address of key string
#             $a2 - address of user input string
#
# return:     $v0 - address of resulting encrypted/decrypted string
#--------------------------------------------------------------------

# REGISTER USAGE
# $t0: copy of $a0, character to determine whether to encrypt or decrypt
# $t1: copy of $a1, address of key string
# $t2: copy of $a2, address of user input string
# $t3: holding address of space reserved for result
# $t8: constant holding 0 for padding resulting string

cipher:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    la $t3, result                    #load address of where to store resulting string
    lb $t0 ($a0)
    move $t1, $a1                     #copy $a1 in $t1
    move $t2, $a2                     #copy $a2 in $t2
    beq $t0, 0x45, encr               #if E was entered, encrypt, else decrypt
    decr:
        move $a0, $t1
        jal compute_checksum          #call check_sum
        move $a1, $v0                 #save check_sum resuilt in $a1
        looper:
            lb $a0, ($t2)             #load next character
            beq $a0, 0x0A, ex
            jal decrypt               #call decrypt
            sb $v0, ($t3)             #add decrypted character
            addi $t3, $t3, 1          #increase pointer
            addi $t2, $t2, 1
            j looper                  #loop back
        ex:
            li $t8, 0x00              #pad with 0
            sb $t8, ($t3)
            la $v0, result            #return result
            lw $ra, 0($sp)
            addi $sp, $sp, 4
            jr $ra                    #jump back
    encr:
        move $a0, $t1
        jal compute_checksum
        move $a1, $v0
        looper2:
            lb $a0, ($t2)             #load next character
            beq $a0, 0x0A, ex2
            jal encrypt               #call encrypt
            sb $v0, ($t3)             #add encrypted character
            addi $t3, $t3, 1          #increase pointer
            addi $t2, $t2, 1
            j looper2                 #loop back
        ex2:
            li $t8, 0x00              #pad with 0
            sb $t8, ($t3)
            la $v0, result            #return result
            lw $ra, 0($sp)
            addi $sp, $sp, 4
            jr $ra                    #jump back

#--------------------------------------------------------------------
# compute_checksum
#
# Computes the checksum by xor’ing each character in the key together. Then,
# use mod 26 in order to return a value between 0 and 25.
#
# arguments:  $a0 - address of key string
#
# return:     $v0 - numerical checksum result (value should be between 0 - 25)
#--------------------------------------------------------------------

# REGISTER USAGE
# $t0: sum of each character
# $t1: counter for each character in string
# $t9: constant holding 26 for calculation of checksum

compute_checksum:
    
    li $t0, 0                         #set initial sum to 0
    l:
        lb $t1, ($a0)                 #load new character
        beq $t1, 0x0A, e              #if end of stirng then branch
        xor $t0, $t0, $t1             #xor current sum and character
        addi $a0, $a0, 1              #increase address pointer
        j l                           #loop back
    e:
        li $t9, 26                    #constant holding 26
        div $t0, $t9                  #divide by 26, for remainder
        mfhi $v0                      #return remainder    
        jr $ra
#--------------------------------------------------------------------
# encrypt
#
# Uses a Caesar cipher to encrypt a character using the key returned from
# compute_checksum. This function should call check_ascii.
#
# arguments:  $a0 - character to encrypt
#             $a1 - checksum result
#
# return:     $v0 - encrypted character
#--------------------------------------------------------------------

# REGISTER USAGE
# $t0: copy of $a0, character to encrypt
# $t1: copy of $a1, checksum result

encrypt:
    move $t0, $a0
    move $t1, $a1
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal check_ascii                   #call check__ascii
    beq $v0, 1, lowercase             #determnine how to encrypt character
    beqz $v0, uppercase
    beq $v0, -1, not_character
    lowercase:
        add $t0, $t0, $t1             #add checksum
        bgt $t0, 0x7A, subtract_lower #if outside range of characters, loop back
        move $v0, $t0                 #return updated character
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra
        subtract_lower:
            subi $t0, $t0, 26         #if the cahracter ends up outside of the alphabet, loop it back
            move $v0, $t0             #return updated character
            lw $ra, 0($sp)
            addi $sp, $sp, 4
            jr $ra
    uppercase:
        add $t0, $t0, $t1             #add checksum
        bgt $t0, 0x5A, subtract_upper #if outside range of characters, loop back
        move $v0, $t0                 #return updated character
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra
        subtract_upper:
            subi $t0, $t0, 26         #if the cahracter ends up outside of the alphabet, loop it back
            move $v0, $t0             #return updated character
            lw $ra, 0($sp)
            addi $sp, $sp, 4
            jr $ra
    not_character:
        move $v0, $t0                 #if not a character it doesnt need to be changed
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra                        #jump back 

#--------------------------------------------------------------------
# decrypt
#
# Uses a Caesar cipher to decrypt a character using the key returned from
# compute_checksum. This function should call check_ascii.
#
# arguments:  $a0 - character to decrypt
#             $a1 - checksum result
#
# return:     $v0 - decrypted character
#--------------------------------------------------------------------

# REGISTER USAGE
# $t0: copy of $a0, character to decrypt
# $t1: copy of $a1, checksum result

decrypt:
    move $t0, $a0
    move $t1, $a1
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal check_ascii                  #call check__ascii
    beq $v0, 1, lowercase1           #determnine how to decrypt character
    beqz $v0, uppercase1
    beq $v0, -1, not_character1
    lowercase1:
        sub $t0, $t0, $t1            #subtract checksum
        blt $t0, 0x61, add_lower     #if outside range of characters, loop back
        move $v0, $t0                #return updated character
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra
        add_lower:
            addi $t0, $t0, 26        #if the cahracter ends up outside of the alphabet, loop it back
            move $v0, $t0            #return updated character
            lw $ra, 0($sp)
            addi $sp, $sp, 4
            jr $ra
    uppercase1:
        sub $t0, $t0, $t1            #subtract checksum
        blt $t0, 0x41, add_upper     #if outside range of characters, loop back
        move $v0, $t0                #return updated character
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra
        add_upper:
            addi $t0, $t0, 26        #if the cahracter ends up outside of the alphabet, loop it back
            move $v0, $t0            #return updated character
            lw $ra, 0($sp)
            addi $sp, $sp, 4
            jr $ra
    not_character1:
        move $v0, $t0                #if not a character it doesnt need to be changed
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra                       #jump back    

#--------------------------------------------------------------------
# check_ascii
#
# This checks if a character is an uppercase letter, lowercase letter, or
# not a letter at all. Returns 0, 1, or -1 for each case, respectively.
#
# arguments:  $a0 - character to check
#
# return:     $v0 - 0 if uppercase, 1 if lowercase, -1 if not letter
#--------------------------------------------------------------------

check_ascii:
    ble $a0, 0x40, return_1          #if ascii value of character is less than 0x40, its not a character
    ble $a0, 0x5A, return0           #if ascii value of character is less than 0x5A, its uppercase
    ble $a0, 0x60, return_1          #if ascii value of character is less than 0x60, its not a character
    ble $a0, 0x7A, return1           #if ascii value of character is less than 0x7A, its lowercase
    j return_1                       #if ascii value of character is greater than than 0x&A, its not a character
    return1:
        li $v0, 1                    #return 1 if lowercase
        jr $ra
    return_1:
        li $v0, -1                   #return -1 if not a letter
        jr $ra
    return0:
        li $v0, 0                    #return 0 if uppercase
        jr $ra

#--------------------------------------------------------------------
# print_strings
#
# Determines if user input is the encrypted or decrypted string in order
# to print accordingly. Prints encrypted string and decrypted string. See
# example output for more detail.
#
# arguments:  $a0 - address of user input string to be printed
#             $a1 - address of resulting encrypted/decrypted string to be printed
#             $a2 - address of E or D character
#
# return:     prints to console
#--------------------------------------------------------------------

# REGISTER USAGE
# $t0: copy of $a0, address of user input string to be printed
# $t1: copy of $a1, address of resulting encrypted/decrypted string to be printed

print_strings:

    move $t0, $a0                    #copy $a0
    move $t1, $a1                    #copy $a1
    lb $t2, ($a2)                    #determine whether  character entered was E or D
    li $v0, 4
    la $a0, prompt3                  #print prompt
    syscall
    beq $t2, 0x45, E                 #branch if E was entered
    beq $t2, 0x44, D                 #branch if D was entered
    E:
        li $v0, 11
        la $a0, '\n'                 #print a newline
        syscall
        li $v0, 4
        la $a0, prompt4              #print "<Encrypted>"
        syscall
        li $v0, 4
        move $a0, $t1                #print resulting encrypted string
        syscall
        li $v0, 11
        la $a0, '\n'                 #print a newline
        syscall
        li $v0, 4
        la $a0, prompt5              #print "<Decrypted>"
        syscall
        li $v0, 4
        move $a0, $t0                #print original string
        syscall
        jr $ra
    D:
        li $v0, 11
        la $a0, '\n'                 #print a newline
        syscall
        li $v0, 4
        la $a0, prompt4              #print "<Encrypted
        syscall
        li $v0, 4
        move $a0, $t0                #print original string
        syscall
        li $v0, 4
        la $a0, prompt5              #print "<Decrypted>"
        syscall
        li $v0, 4
        move $a0, $t1                #print resulting decrypted string
        syscall
        li $v0, 11
        la $a0, '\n'                 #print a newline
        syscall
        jr $ra
        
