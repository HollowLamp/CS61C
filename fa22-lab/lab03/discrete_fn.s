.globl f # this allows other files to find the function f

# f takes in two arguments:
# a0 is the value we want to evaluate f at
# a1 is the address of the "output" array (defined above).
# The return value should be stored in a0
f:
    addi a0, a0, 3
    slli a0, a0, 2
    mv t0, x0
    addi t0, t0, 6
    sw t0, 0(a1)
    mv t1, x0
    addi t1, t1, 61
    sw t1, 4(a1)
    mv t2, x0
    addi t2, t2, 17
    sw t2, 8(a1)
    mv t3, x0
    addi t3, t3, -38
    sw t3, 12(a1)
    mv t4, x0
    addi t4, t4, 19
    sw t4, 16(a1)
    mv t5, x0
    addi t5, t5, 42
    sw t5, 20(a1)
    mv t6, x0
    addi t6, t6, 5
    sw t6, 24(a1)
    
    add a1, a1, a0
    lw a0, 0(a1)
    # This is how you return from a function. You'll learn more about this later.
    # This should be the last line in your program.
    jr ra  