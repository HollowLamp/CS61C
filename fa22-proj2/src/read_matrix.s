.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:

    # Prologue
    addi sp, sp, -24
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
                    
    mv s0, a0       #copy a0,1,2
    mv s1, a1
    mv s2, a2
    li a1, 0        #read    
    jal fopen
    li t1, -1
    beq a0, t1, fopen_fail
    mv t0, a0       #copy filepointer
    li a2, 4
    mv a1, s1       #points to num_row
    
    addi sp, sp, -4
    sw t0, 0(sp)
    jal fread
    li t1, 4
    bne a0, t1, fread_fail
    lw t0, 0(sp)
    addi sp, sp, 4
    
    mv a1, s2       #points to num_col
    li a2, 4        
    mv a0, t0       #paste filepointer
    
    addi sp, sp, -4 
    sw t0, 0(sp)
    jal fread
    li t1, 4
    bne a0, t1, fread_fail
    lw t0, 0(sp)
    addi sp, sp, 4
    
    lw t1, 0(s1)    
    lw t2, 0(s2)
    mul s3, t1, t2  #s3 = num_row * num_col
    
    slli s3, s3, 2
    mv a0, s3
    addi sp, sp, -4 
    sw t0, 0(sp)
    jal malloc
    beq a0, x0, malloc_fail
    lw t0, 0(sp)
    addi sp, sp, 4
    
    mv s4, a0       #s4 - allocated mem
    mv a0, t0       #fp
    mv a1, s4
    mv a2, s3
    addi sp, sp, -4 
    sw t0, 0(sp)    
    jal fread
    bne a0, s3, fread_fail
    lw t0, 0(sp)
    addi sp, sp, 4   
   
    mv a0, t0
    jal fclose
    bne a0, x0, fclose_fail
    
    mv a0, s4
    # Epilogue
    lw s4, 20(sp)
    lw s3, 16(sp)
    lw s2, 12(sp)
    lw s1, 8(sp)
    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 24

    jr ra
    
malloc_fail:
    li a0, 26
    j exit
fopen_fail:
    li a0, 27
    j exit
fclose_fail:
    li a0, 28
    j exit
fread_fail:
    li a0, 29
    j exit   
