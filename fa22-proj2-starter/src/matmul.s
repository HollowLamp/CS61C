.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:

    # Error checks

    #check a1
    li t0, 1
    bge a1, t0, ORa2
    li a0, 38
    j exit
ORa2:
    #check a2
    bge a2, t0, ORa4
    li a0, 38
    j exit
ORa4:
    #check a4
    bge a4, t0, ORa5
    li a0, 38
    j exit
ORa5:
    #check a5
    bge a5, t0, OReq
    li a0, 38
    j exit
OReq:
    #check a2,4
    beq a2, a4, PASS
    li a0, 38
    j exit
PASS:
    # Prologue
    addi sp, sp, -8
    sw s0, 0(sp)
    sw ra, 4(sp)
    #t0,1correspond to row1, col2
    li t0, 0
    li t1, 0
    li s0, 0        #s0 = current_index
outer_loop_start:   #row iteration
    li t1, 0
inner_loop_start:
    #store
    addi sp, sp, -36
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    sw a6, 24(sp)
    sw t0, 28(sp)
    sw t1, 32(sp)
    ebreak
    slli t2, a2, 2
    mul t2, t2, t0
    add a0, t2, a0
    slli t2, t1, 2
    mv a1, a3
    add a1, a1, t2
    mv a2, a4
    mv a4, a5
    li a3, 1
    jal dot
    mv t3, a0

    #load
    lw t1, 32(sp)
    lw t0, 28(sp)
    lw a6, 24(sp)
    lw a5, 20(sp)
    lw a4, 16(sp)
    lw a3, 12(sp)
    lw a2, 8(sp)
    lw a1, 4(sp)
    lw a0, 0(sp)
    addi sp, sp, 36
    slli t2, s0, 2
    add t2, t2, a6  #t2 = current_address
    sw t3, 0(t2)
    

inner_loop_end:
    addi t1, t1, 1
    addi s0, s0, 1
    blt t1, a5, inner_loop_start

outer_loop_end:
    addi t0, t0, 1
    blt t0, a1, outer_loop_start
    # Epilogue
    lw ra, 4(sp)
    lw s0, 0(sp)
    addi sp, sp, 8
    jr ra
