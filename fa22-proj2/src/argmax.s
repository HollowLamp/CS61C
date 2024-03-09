.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
    # Prologue
    
    #check a1
    li t0, 1
    bge a1, t0, ELSE
    li a0, 36
    j exit
ELSE:
    li t0, 1        #t0 = next_index
    li t1, 0        #t1 = cur_max_index
    lw t2, 0(a0)    #t2 = cur_max_ele
    bge t0, a1, real_end
loop_start:
    slli t3, t0, 2  
    add t3, t3, a0  
    lw t4, 0(t3)    #t4 = next_ele
    bge t2, t4, loop_end
loop_continue:
    mv t1, t0
    mv t2, t4
loop_end:
    addi t0, t0, 1
    blt t0, a1, loop_start
real_end:
    mv a0, t1
    # Epilogue

    jr ra
