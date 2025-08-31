.text
LUI $2, 0x8000 // sets register 2 to address
LI $3, 15 // for loop limit
LI $4, 64 // value to store at m[8]
LI $5, 97 // value to store at m[8]
LI $6, 33 // value to store at m[8]
LI $7, 32 // value to store at m[8]

main:
SB $4, 16($2) // sets m[8] to 64

loop:
BGT $2, $3, exit // is the loop
SB $5, 16($2) // sets m[8] to 97
ADDIU $2, $0, 1 // increments for loop
J loop // jumps to top of loop

exit: // after loop
SB $6, 16($2) // sets m[8] to 33
SB $7, 16($2) // sets m[8] to 32