.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:

    # Prologue
    addi sp, sp, -4
    sw s0, 0(sp)
    #check a2
    li t0, 1
    bge a2, t0, ORa3
    li a0, 36
    j exit
ORa3:
    #check a3
    bge a3, t0, ORa4
    li a0, 37
    j exit
ORa4:
    #check a4
    bge a4, t0, PASS
    li a0, 37
    j exit
    
PASS:
    li t0, 0        #t0 = cur_used_nums
    li t1, 0        #t1 = cur_a1_index
    li t2, 0        #t2 = cur_a2_index
    li t3, 0        #t3 = cur_sum
loop_start:
    #put a[index] in t5, b[index] in t6
    slli t4, t1, 2
    add t4, t4, a0
    lw t5, 0(t4)
    li t4, 0
    slli t4, t2, 2
    add t4, t4, a1
    lw t6, 0(t4)
    #put mul in s0
    mul s0, t6, t5
    add t3, t3, s0
loop_end:
    add t1, t1, a3
    add t2, t2, a4
    addi t0, t0, 1
    blt t0, a2, loop_start
    # Epilogue
    lw s0, 0(sp)
    addi sp, sp, 4
    
    mv a0, t3
    jr ra
