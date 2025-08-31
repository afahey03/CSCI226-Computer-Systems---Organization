.data

numvals: .word 6     # this memory holds an integer, the array size

vals:    .word 99    # these next values are the array contents
         .word 15
         .word 1044942
         .word -5
         .word 35
         .word 0x8BADF00D  # note: this is a negative number

         .word 3
         .word 4

msg1:    .asciz "Sorting..."  # a zero-terminated string

msg2:    .asciz "Done!\n"     # another zero-terminated string

.text

# initialization
LUI $8, 0x8000        # sets m = 0x80000000, our base address for input/output

# print msg1
LA $4, msg1           # r4 = address of msg1 in memory
loop1:
LB $7, 0($4)          # get next ascii byte of msg1
BEQ $7, $0, end2      # break out of this loop when end of msg1 is reached
SB $7, 8($8)          # print this ascii byte
ADDIU $4, $4, 1
J loop1               # go back to top of loop1

end1:
nop

# sort array
main:

LA $2, numvals # r2 = address of numvals variable in memory
LW $2, 0($2)  # r2 = get value (4 bytes) of numvals variable from memory

mainLoop:
ADDIU $3, $2, -1 # count for pass
BLEZ $3, mainDone # done main

LA $4, vals # address of array
LI $5, 0 # did swap check

JAL loopPass # single sort

BEQ $5, $0, mainDone # if no swaps, done

ADDIU $2, $2, -1 # decrement remaining passes
BEQ $0, $0, main

mainDone:
J end # done life

loopPass:
LW $6, 0($4) # load first element of array in $6
LW $7, 4($4) # load first element of array in $7
BGT $6, $7, swapPass # if $6 > $7, swap

passNext:
ADDIU $4, $4, 4 # increment pointer to next index
ADDIU $3, $3, -1 # decrement number of loops
BGTZ $3, loopPass # loop if not swap not passed
JR $RA # return to call

swapPass:
SW $6, 4 ($4) # store [i+1] in $6
SW $7, 0 ($4) # store [i] in $7
LI $5, 1 # tell main loop a swap happened
J passNext

end:
NOP # cry

# print msg2
LA $4, msg2           # r4 = address of msg2 in memory
loop2:
LB $7, 0($4)          # get next ascii byte of msg1
BEQ $7, $0, end2      # break out of this loop when end of msg1 is reached
SB $7, 8($8)          # print this ascii byte
ADDIU $4, $4, 1       # increment register to get next ascii byte
J loop2               # jump to top of loop

end2:
NOP
