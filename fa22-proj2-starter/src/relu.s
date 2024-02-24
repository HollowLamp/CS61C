.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
    # Prologue
    
    #check a1
    li t0, 1
    bge a1, t0, ELSE
    li a0, 36
    j exit
ELSE:
    li t0, 0        #t0 = cur_index
loop_start:
    slli t1, t0, 2  #t1 = cur_offset
    add t1, t1, a0  #t1 = cur_address
    lw t2, 0(t1)    #t2 = cur_val
    blt t2, zero, loop_continue
    j loop_end
loop_continue:
    li t2, 0  #t2 = 0 
    sw t2, 0(t1)    
loop_end:
    addi t0, t0, 1
    blt t0, a1, loop_start 
    # Epilogue


    jr ra
