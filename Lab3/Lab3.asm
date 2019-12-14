##########################################################################
# Created by: Karlcut, Sukhveer
#             skarlcut
#             February 13, 2019
#
# Assignment: Lab 3: MIPS Looping ASCII Art
#             CMPE 012, Computer Systems and Assembly Language 
#             UC Santa Cruz, Fall 2018
#
# Description: 
#
# Notes: 
##########################################################################

# REGISTER USAGE
# $t0: user input (length of triangle) 
# $t1: user input (number of triangles)
# $t2: Outer loop counter (for number of triangles)
# $t3: Inner loop counter for first half of tree, for counting number of slashes
# $t4: Inner loop counter for second half of tree, for counting number of slashes
# $t5: Inner loop counter for first half of tree, for counting spaces
# $t6: Inner loop counter for second half of tree, for counting spaces
.text
main:
    li $v0, 4                            #Reads in user input for length of triangle, and stores that value in $t0
    la $a0, prompt1
    syscall
    li $v0, 5
    syscall
    move $t0, $v0
    
    li $v0, 4                            #Reads in user input for number of triangles, and stores that value in $t1
    la $a0, prompt2
    syscall
    li $v0, 5
    syscall
    move $t1, $v0
    
    li $t2, 0                            #sets counter of outer loop for number of triangles to 0
    li $t3, 0                            #sets inner loop counter for slashes to 0
    li $t4, 0                            #sets inner loop counter for slashes to 0
    li $t5, 2                            #sets inner loop counter for spaces to 2
    li $t6, 0                            #sets inner loop counter for spaces to 0
    sub $t6, $t0, 2                      #sets inner loop counter for spaces to length of triangle - 2
    
    loop1:
        ble $t1, $t2, exit               #if the correct number have triangles have been printed, exit the loop, else continue with loop
        addi $t2, $t2, 1                 #increment loop counter
        loop2:
            ble $t0, $t3, loop3          #if the correct number have backslashes have been printed, exit the loop, else continue with loop
            li $v0, 11
            la $a0, '\n'                 #print a newline
            syscall
            loop4:
                blt $t3, $t5, outputF    #if the correct number of spaces have been printed, go to outputF to print slash, else continue with loop
                addi $t5, $t5, 1         #increment loop counter
                li $v0, 11
                li $a0, 0x20             #print a space
                syscall
                j loop4                  #loop back
                outputF:
                    li $v0, 11
                    li $a0, 0x5C         #print the slash
                    syscall
            addi $t3, $t3, 1             #increment loop counter
            li $t5, 1
            j loop2                      #loop back
        loop3:
            ble $t0, $t4, ending         #if the correct number have backslashes have been printed, exit the loop, else continue with loop
            li $v0, 11
            la $a0, '\n'                 #print a newline
            syscall
            loop5:
                bgt $t4, $t6, outputB    #if the correct number of spaces have been printed, go to outputF to print slash, else continue with loop
                subi $t6, $t6, 1         #decrement loop counter
                li $v0, 11
                li $a0, 0x20             #print a space
                syscall
                j loop5                  #loop back
                outputB:
                    li $v0, 11
                    li $a0, 0x2F         #print the slash
                    syscall
            addi $t4, $t4, 1             #increment loop counter
            sub $t6, $t0, 2
            j loop3
        ending:
            li $t3, 0                    #resets inner loop counter for slashes to 0
            li $t4, 0                    #resets inner loop counter for slashes to 0
            li $t5, 2                    #resets inner loop counter for spaces to 2
            li $t6, 0                    #resets inner loop counter for spaces to 0
            sub $t6, $t0, 2              #sets inner loop counter for spaces to length of triangle - 2
        j loop1
            
        exit:
            li $v0, 10                   #exits program cleanly
            syscall
    
.data
prompt1: .asciiz "Enter the length of one of the triangle legs: "
prompt2: .asciiz "Enter the number of triangles to print: "
newline: .asciiz "\n"
