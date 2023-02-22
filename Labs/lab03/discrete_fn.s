.globl f # this allows other files to find the function f
output:	.word	6, 61, 17, -38, 19, 42, 5
# f takes in two arguments:
# a0 is the value we want to evaluate f at
# a1 is the address of the "output" array (defined above).
# The return value should be stored in a0
.text
main:
    lw a1, output
    li a0, -3
    jal f
    
    li a0, -2
    jal f
    
    li a0, -1
    jal f
    
    li a0, 0
    jal f
    
    li a0, 1
    jal f
    
    li a0, 2
    jal f
    
    li a0, 3
    jal f
    
    li a0, 10
    ecall

f:
    addi a0, a0, 3
    addi t1, zero, 4
    mul a0, a0, t1
    add a1, a1, a0
    lw a0, 0(a1)
    lw a1, output

    jr ra