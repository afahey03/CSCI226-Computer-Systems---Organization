.text
LUI $8, 0x8000   # sets m = 0x80000000, our base address for input/output

waitloop:
LB $9, 0($8)     # reads a byte from m[0], to query the keyboard status
BEQ $9, $0, waitloop

LB $10, 4($8)    # reads a byte from m[1], to query the keyboard data

ADDIU $10, $10, -48    # decrement r10 by 48, which is the ascii code for '0'
ADDIU $10, $10, 97    # increment r10 by 97, which is the ascii code for 'a'
LB $10, 16($8)        # store r10 as a single byte into memory address 0x80000008
J waitloop            # go back to the waitloop near the top