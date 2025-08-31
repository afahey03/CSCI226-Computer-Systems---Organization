# calc.S implements a calculator-like program.
# After initializing the program, it starts by printing a greeting with some
# instructions. Then it interactively gets input and computes various results.

############# init #######################################

# Program startup initialization. This initializes registers then calls main.
.text
     li $29, 0xffc        # initialize the stack pointer to highest possible address
     li $30, 0            # set this register to zero, just in case
     li $4, 0             # main has no parameters, but set this to zero anyway
     li $5, 0             # main has no parameters, but set this to zero anyway
     li $6, 0             # main has no parameters, but set this to zero anyway
     li $7, 0             # main has no parameters, but set this to zero anyway
     jal main             # call main() function
     nop
loop_forever:             # after main, we just loop forever
     j loop_forever

############# main() #######################################
# Code for main(), which implements a calculator-like program.
# It expects no parameters.
# It returns nothing.
# The C/C++ equivalent of this function is roughly...
#   void main() {
#       printString(welcome);
#       while (true) {
#           printString(helpmsg);
#           ch = getchar();
#           if (ch == 'p') {
#               x = getnum()
#               y = getnum()
#               r = pow(x, y)
#               printnum(r)
#               printString("\n")
#           } else if (ch == 'f') {
#               x = getnum()
#               y = getnum()
#               fizzbuzz(x, y)
#           } else if (ch == 'q') {
#               break;
#           }
#       }
#       printString(goodbye);
#   }
# It uses (clobbers) lots of registers, and calls lots of other functions which in turn
#   also clobber various registers.
# It creates a 32-byte stack frame to hold:
#    A backup copy of $31, stored at 28(sp).
#    A backup copy of user input x, stored at 24(sp).
#    A backup copy of user input y, stored at 20(sp).
#    The rest of the space in the stack frame is not used in any way.
.data
welcome: .asciz "Welcome to calculator!\n"
goodbye: .asciz "All done, bye!\n"
helpmsg: .asciz "[q]uit, [p]ow, or [f]izzbuzz?\n"
newline: .asciiz "\n"
stringforfunc: .asciz "Close, but no cigar"
.text
main:
    # function prologue
    addiu $29, $29, -32  # create space for this function's stack frame
    sw $31, 28($29)      # store a backup copy of $31 into stack frame

    la $4, welcome
    jal printString      # call printString(welcome)
    nop

main_loop:
    la $4, helpmsg
    jal printString      # call printString(helpmsg)
    nop

try_again:
    jal getchar          # call ch = getchar()
    nop                  # result is in r2

    li $3, 0x71            # ascii 'q'
    beq $2, $3, exit_main  # if ch == 'q' then break out of loop

    li $3, 0x70            # ascii 'p'
    beq $2, $3, do_pow     # else if ch == 'p' then go to pow code

    li $3, 0x66            # ascii 'f'
    beq $2, $3, do_fizz    # else if ch == 'p' then go to pow code

    j try_again            # else get another char and try again

do_pow:
    jal getnum             # x = getnum()
    nop
    sw $2, 24($29)         # store x in stack frame for safe keeping

    jal getnum             # y = getnum()
    nop
    sw $2, 20($29)         # store y in stack frame for safe keeping

    lw $4, 24($29)         # load x into arg0 register
    lw $5, 20($29)         # load y into arg1 register
    jal pow                # call r = pow(x, y)
    nop

    move $4, $2            # copy result r into arg0 register
    jal printnum           # call printnum(r)
    nop

    la $4, newline
    jal printString        # call printnum(newline)
    nop

    j main_loop            # go to top of main loop

do_fizz:

    # TODO (4): get user inputs for x and y, then call fizzbuzz
    jal getnum             # x = getnum()
    nop
    sw $2, 24($29)         # store x in stack frame for safe keeping

    jal getnum             # y = getnum()
    nop
    sw $2, 20($29)         # store y in stack frame for safe keeping

    lw $4, 24($29)         # load x into arg0 register
    lw $5, 20($29)         # load y into arg1 register
    jal fizzbuzz           # call fizz buzz

    j main_loop            # go to top of main loop

do_print_many:

    jal getnum             # x = getnum()
    nop
    sw $2, 24($29)         # store x in stack frame for safe keeping

    lw $4, 24($29)         # load x into arg0 register
    jal print_many

    j main_loop

exit_main:
    la $4, goodbye
    jal printString      # call printString(goodbye)
    nop

    # function epilogue
    # note: by this point, the function result should be in r2
    lw $31, 28($29)      # restore backup copy of $31 from our stack frame
    addiu $29, $29, 32   # deallocate space used by our stack frame
    jr $31               # return to whatever called this function


############# printString(s) #######################################
# Code for printString(s), which prints the given string to the TTY console output.
# It expects one parameter, the address of the string to be printed. The string should be
#   stored somewhere in memory, and it should end with a zero byte. The zero byte is not
#   printed.
# It returns the number of characters printed (i.e., the length of the string, not
#   including the zero byte at the end).
# It uses (clobbers) registers $2, $3, $4, and $8. It does not call any other functions, so
#   all other registers are left alone.
# It (unnecessarily) creates a 32-byte stack frame to hold:
#    A backup copy of $31, stored at 28(sp).
#    The rest of the space in the stack frame is not used in any way.
#
# The C/C++ equivalent of this function is roughly...
#   int printString(char *s) {
#     n = 0;
#     while (s[n] != 0) {
#       send character s[n] to console output
#       n++;
#     }
#     return n;
#   }
.text
printString:
    # function prologue
    addiu $29, $29, -32  # create space for this function's stack frame
    sw $31, 28($29)      # store a backup copy of $31 into stack frame

    # TODO (1): code for body of printString function goes here
    lui $8, 0x8000
    printLoop:
        lb $9, 0($4)
        sb $9, 8($8)
        addiu $4, $4, 1    # fixed by kwalsh, was addui
        #bne $4, $0, printLoop # fixed by kwalsh, wrong condition
        bne $9, $0, printLoop 

    # function epilogue
    # note: by this point, the function result should be in r2
    lw $31, 28($29)      # restore backup copy of $31 from our stack frame
    addiu $29, $29, 32   # deallocate space used by our stack frame
    jr $31               # return to whatever called this function

############# getString(buf) #######################################
# Code for getString(buf), which reads some user input from the keyboard. The input is
#    also echoed back to the TTY console output.
# It expects one parameter, the address of a location in memory where the input will be
#    stored.
# It returns the number of characters typed (i.e., the length of the string, not
#   including the zero byte at the end).
# It uses (clobbers) registers $2, $3, $4, and $9, and it calls getchar(), which clobbers only
#   $2 and $8.
# It creates a 32-byte stack frame to hold:
#    A backup copy of $31, stored at 28(sp).
#    The rest of the space in the stack frame is not used in any way.
.text
getString:
    # function prologue
    addiu $29, $29, -32  # create space for this function's stack frame
    sw $31, 28($29)      # store a backup copy of $31 into stack frame

    move $3, $0          # n = 0

input_loop:
    jal getchar          # get next character
    nop                  # note: getchar only clobbers $2 and $8
    li $9, 0x20          # put ascii space in temp register
    beq $2, $9, stop_input  # if input was a space, then break out of loop
    li $9, 0x0a          # put ascii newline in temp register
    beq $2, $9, stop_input  # if input was a newline, then break out of loop
    addu $9, $4, $3      # otherwise, calculate s+n, address of next location in memory
    sb $2, 0($9)         # and store result of getchar into that location
    addiu $3, $3, 1      # n++
    j input_loop

stop_input:
    addu $9, $4, $3      # calculate s+n, address of end of string in memory
    sb $0, 0($9)         # and store a zero byte there
    move $2, $3          # copy n into the result register

exit_getString:
    # function epilogue
    # note: by this point, the function result should be in r2
    lw $31, 28($29)      # restore backup copy of $31 from our stack frame
    addiu $29, $29, 32   # deallocate space used by our stack frame
    jr $31               # return to whatever called this function

############# pow(a, b) #######################################
# Code for pow(a, b), which computes and returns a to the power b.
# It expects two parameter, the numbers a and b. Parameter b should not be negative.
# It returns the calculated result.
# It uses (clobbers) registers $2, $4, and $5. It does not call any other functions, so
#   all other registers are left alone.
# It (unnecessarily) creates a 32-byte stack frame to hold:
#    A backup copy of $31, stored at 28(sp).
#    The rest of the space in the stack frame is not used in any way.
#
# The C/C++ equivalent of this function is roughly...
#   int pow(int a, int b) {
#     ans = 1;
#     while (b > 0) {
#       ans = ans * a;
#       b--;
#     }
#     return ans;
#   }
.text
pow:
    # function prologue
    addiu $29, $29, -32  # create space for this function's stack frame
    sw $31, 28($29)      # store a backup copy of $31 into stack frame

    # TODO (2): code for body of pow function goes here
    li $2, 1
    powLoop:
        #mul $2, #2, $4
        mul $2, $2, $4          # fixed by kwalsh
        addiu $5, $5, -1
        bne $5, $0, powLoop

    # function epilogue
    # note: by this point, the function result should be in r2
    lw $31, 28($29)      # restore backup copy of $31 from our stack frame
    addiu $29, $29, 32   # deallocate space used by our stack frame
    jr $31               # return to whatever called this function


############# fizzbuzz(a, b) #######################################
# Code for fizzbuzz(a, b), which counts from a to b (including a, including b),
#   and for each number, prints the number and either "Fizz", "Buzz", or
#   "FizzBuzz", depending on whether that number is divisible by 3, divisible by
#   5, or divisible by both 3 and 5. one newline is printed after the output for
#   each number.
# It expects two parameter, the numbers a and b, both positive, with b >= a.
# It returns nothing.
# The pseudo-code equivalent of this function is roughly...
#   void fizzbuzz(int a, int b) {
#     Count from a to b (including a, including b), and for each number:
#        Print the number, then a space.
#        Then, either print "Fizz" if it's divisible by 3,
#        or, print "Buzz" if it's divisible by 5,
#        or, print "FizzBuzz" if it's divisible by both 3 and by 5.
#        Also print one newline after each loop.
#     Nothing is returned at the end of the function.
#   }
# It uses (clobbers) registers .... and it does / does't call other
# functions....
# It creates a ...-byte stack frame to hold:
#    A backup copy of $31, stored at ...(sp).
#    ... other things ? ...
#    The rest of the space in the stack frame is not used in any way.
.data
# string constants needed by fizzbuzz go here
fizz: .asciz "Fizz"
buzz: .asciz "Buzz"
fizzbuzz_kwalsh: .asciz "FizzBuzz"
space: .asciz " "
.text
fizzbuzz:
    # function prologue
    addiu $29, $29, -32  # create space for this function's stack frame
    sw $31, 28($29)      # store a backup copy of $31 into stack frame

    # TODO (3): code for body of fizzbuzz function goes here
    move $11, $4
    move $12, $5
    li $13, 3
    li $14, 5
    li $17, 15

    fizzBuzzMain:
        move $11, $4
        jal printnum # fixed by kwalsh, was spelled incorrectly
        nop
        la $4, space
        jal printString
        nop

        mod $15, $11, $13
        mod $16, $11, $14
        mod $18, $11, $17

        beq $18, $0, printFizzBuzz
        beq $15, $0, printFizz
        beq $16, $0, printBuzz
        
        printFizz:
            la $4, fizz
            jal printString
            nop
            jal endFizzBuzz

        printBuzz:
            la $4, buzz
            jal printString
            nop
            jal endFizzBuzz

        printFizzBuzz:
            la $4, fizzbuzz_kwalsh
            jal printString
            nop
            jal endFizzBuzz

        endFizzBuzz:
            la $4, newline
            jal printString
            nop
            addiu $11, $11, 1
            blt $11, $12, fizzBuzzMain  # fixed by kwalsh, added comma

    # function epilogue
    # note: there is no result, so we don't care what is in r2
    lw $31, 28($29)      # restore backup copy of $31 from our stack frame
    addiu $29, $29, 32   # deallocate space used by our stack frame
    jr $31               # return to whatever called this function


############# getchar() #######################################
# Code for getchar(), which queries the keyboard and returns the next character typed. It
#   also echoes the user input by printing it to the TTY console output.
# It expects no parameters.
# It returns the next character typed at the keyboard, as an ascii byte.
# It uses (clobbers) registers $2 and $8. It does not call any other functions, so
#   all other registers are left alone.
# It doesn't create or use a stack frame.
#
# The C/C++ equivalent of this function is roughly...
#   char getchar() {
#     while (keyboard status is zero) { do nothing }
#     ch = get keyboard data;
#     send ch to TTY console output;
#     return ch;
#   }
.text
getchar:
    # function prologue (omitted)

    lui $8, 0x8000       # special address for input/output operations

    # wait until user types something
wait_for_input:
    lb $2, 0($8)                 # query keyboard status using special address
    beq $2, $0, wait_for_input   # keep waiting if it was zero

    # get whatever they typed
    lb $2, 4($8)                 # query keyboard data using special address

    # echo whatever they typed
    sb $2, 8($8)                 # send character to TTY console special address

    # function epilogue (abbreviated)
    jr $31


############# getnum() #######################################
# Code for getnum(), which prints a message, then converts the user input to an integer.
# It expects no parameters.
# It returns the user's input, as an integer.
# It uses (clobbers) registers $2, $3, $4, $12, and $13, and it calls getString()
#   and printString(), which clobber a few other registers.
# It creates a 32-byte stack frame to hold:
#    A backup copy of $31, stored at 28(sp).
#    The rest of the space in the stack frame is not used in any way.
.data
prompt: .asciz "Enter number: "
buffer: .asciz "                   "   # an empty space to use as an input buffer
.text
getnum:
    # function prologue
    addiu $29, $29, -32  # create space for this function's stack frame
    sw $31, 28($29)      # store a backup copy of $31 into stack frame

    la $4, prompt
    jal printString      # call printString("Enter number: ")
    nop                  # we don't use the result in r2 at all

    la $4, buffer
    jal getString        # call getString(buffer)
    nop                  # we don't use the result in r2 at all

    la $4, buffer
    jal atoi             # call atoi(buffer)
    nop                  # the result, in r2, is left there to serve as our result

    # function epilogue
    # note: by this point, the function result should be in r2
    lw $31, 28($29)      # restore backup copy of $31 from our stack frame
    addiu $29, $29, 32   # deallocate space used by our stack frame
    jr $31               # return to whatever called this function

############# atoi(s) #######################################
# Code for atoi(), which converts a string to an integer.
# It expects one parameter, the address of the string in memory to be converted. This
#   string should end with a zero byte. The string can start with an ascii minus sign, but
#   otherwise it should contain only ascii characters '0' through '9'. For example,
#   it might contain "-123" or "42" (and these must end in a zero byte).
# It returns an integer, the result of converting the string.
# It uses (clobbers) registers $2, $3, $4, $12, and $13. It does not call other functions.
# It creates a 32-byte stack frame to hold:
#    A backup copy of $31, stored at 28(sp).
#    The rest of the space in the stack frame is not used in any way.
.text
atoi:
    # function prologue
    addiu $29, $29, -32  # create space for this function's stack frame
    sw $31, 28($29)      # store a backup copy of $31 into stack frame

    li $2, 0             # ans = 0
    li $3, 0             # negative = 0

    lb $12, 0($4)          # look at next char
    beq $12, $0, exit_atoi # if it was zero, exit function immediately
    li $13, 0x2d           # ascii minus sign
    bne $12, $13, convert  # if it wasn't a minus sign, skip next few lines
    li $3, 1               # negative = 1
    addiu $4, $4, 1        # advance pointer

convert:
    lb $12, 0($4)              # get next char
    addiu $4, $4, 1            # advance pointer
    beq $12, $0, done_convert  # if it was zero, break out of loop
    li $13, 0x39               # ascii '9'
    bgt $12, $13, done_convert # if above ascii '9', error, break out of loop
    li $13, 0x30               # ascii '0'
    blt $12, $13, done_convert # if below ascii '0', error, break out of loop
    subu $12, $12, $13         # subtract ascii '0' from character to get a decimal digit
    li $13, 10
    mul $2, $2, $13
    addu $2, $2, $12           # ans = 10 * ans + decimal digit
    j convert

done_convert:
    beq $3, $0, exit_atoi    # if not negative, skip next few lines
    sub $2, $0, $2           # ans = 0 - ans, which negates the answer
    
exit_atoi:
    # function epilogue
    # note: by this point, the function result should be in r2
    lw $31, 28($29)      # restore backup copy of $31 from our stack frame
    addiu $29, $29, 32   # deallocate space used by our stack frame
    jr $31               # return to whatever called this function


############# printnum(i) #######################################
# Code for printnum(i), which prints an integer to the TTY output console.
# It expects one parameter, the integer to be printed.
# It returns nothing.
# It uses (clobbers) registers $2, $3, $4, $8, $10, $12, and $13. It also calls
#    printString() which likely clobbers other registers.
# It creates a 32-byte stack frame to hold:
#    A backup copy of $31, stored at 28(sp).
#    An array of characters, stored at 16(sp) through 27(sp).
#    The rest of the space in the stack frame is not used in any way.
.text
printnum:
    # function prologue
    addiu $29, $29, -32  # create space for this function's stack frame
    sw $31, 28($29)      # store a backup copy of $31 into stack frame

    lui $8, 0x8000       # special address for input/output operations

    bgez $4, positive    # if i >= 0 then skip the next few lines
    li $3, 0x2d          # put ascii minus sign in temp register
    sb $3, 8($8)         # print minus sign
    subu $4, $0, $4      # negate i

positive:
    li $10, 10           # ten = 10
    addiu $13, $29, 27   # pointer = 27 bytes above bottom of stack frame
    sb $0, 0($13)        # put a zero byte at the end of the string
    addiu $13, $13, -1   # move pointer backwards by one memory location
itoa_loop:
    divu $4, $10          # divide i by 10
    mfhi $3               # get remainder, which is the rightmost digit of i
    mflo $4               # i = get quotient
    addiu $3, $3, 0x30    # convert that digit to ascii by adding ascii '0'
    sb $3, 0($13)         # store ascii byte into memory
    beq $4, $0, itoa_done # if i has reached zero then stop this loop
    addiu $13, $13, -1    # move pointer backwards by one memory location
    j itoa_loop

itoa_done:
    move $4, $13         # copy pointer to arg0 register
    jal printString      # call printString(pointer)
    nop                  # we don't use the result in r2 at all

    # function epilogue
    # note: by this point, the function result should be in r2
    lw $31, 28($29)      # restore backup copy of $31 from our stack frame
    addiu $29, $29, 32   # deallocate space used by our stack frame
    jr $31               # return to whatever called this function

############# print_many(a) #######################################
# Code for print_many(a), which prints a string the number of times specified by the user
# It expects one arguments, the number of times to print the string
# It returns nothing
# Merry Christmas
.text
print_many:
    # function prologue
    addiu $29, $29, -32  # create space for this function's stack frame
    sw $31, 28($29)      # store a backup copy of $31 into stack frame

    move $15, $4

    printManyLoop:
	la $4, stringforfunc
    	jal printString
    	nop
	addiu $15, $15, -1
	#bne $15, $0, printManyLoop:
	bne $15, $0, printManyLoop     # fixed by kwalsh, punctuation

    # function epilogue
    # note: by this point, the function result should be in r2
    lw $31, 28($29)      # restore backup copy of $31 from our stack frame
    addiu $29, $29, 32   # deallocate space used by our stack frame
    jr $31               # return to whatever called this function
