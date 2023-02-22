.globl update_list

.data
arrays: .word 5, 6, 7, 8, 9
        .word 1, 2, 3, 4, 7
        .word 5, 2, 7, 4, 3
        .word 1, 6, 3, 8, 4
        .word 5, 2, 7, 8, 1

start_msg:  .asciiz "Lists before: \n"
end_msg:    .asciiz "Lists after: \n"

.text
main:
    jal create_default_list # returns a pointer to the head of the list into a0
    mv s0, a0   # s0 = a0 =  is head of node list

    #print "lists before: "
    la a1, start_msg
    li a0, 4
    ecall

    #print the list
    add a0, s0, x0
    jal print_list

    # print a newline
    jal print_newline

    # call update_list
    add a0, s0, x0      # load the address of the first node into a0
    la a1 square        # load the address of square
    jal update_list

    # print "lists after: "
    la a1, end_msg
    li a0, 4
    ecall

    # print the list
    add a0, s0, x0
    jal print_list

    li a0, 10
    ecall

update_list:
    # TODO: which registers do we need to save? (complete this after you have finished the other todos because
    # we don't know which registers we need to save until we implement the function)
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s1, 4(sp)
    sw s0, 8(sp)
    # TODO: implement if (!curr_node) { return; }
    beq a0, x0, done
    
    add s0, a0, x0      # save address of the current node in s0
    add s1, a1, x0      # save address of function in s1
    add t0, x0, x0      # t0 is a counter that we will used to know when we have reached the end of the array

    # remember that each node is 12 bytes long:
    # - 4 for the array pointer
    # - 4 for the size of the array
    # - 4 more for the pointer to the next node

    # Also keep in mind that we should not make ANY assumption on which registers
    # are modified by the callees, even when we know the content inside the functions 
    # we call. This is to enforce the abstraction barrier of calling convention.
update_list_loop:
    # TODO: load the address of the array of current node into t1
    lw t1, 0(s0)
    # TODO: load the size of the node's array into t2
    lw t2, 4(s0)
    # TODO: load the value of the current number that we want to square into a0
    # Remember that t1 = address of array and t0 = index we are modifying
    slli t3, t0, 2
    add t1, t1, t3
    lw a0, 0(t1) 
    # TODO: which registers do we need to save before calling square?
    # (do this after implementing the rest of update_list_loop)
    addi sp sp -12
    sw t0, 0(sp)
    sw t1, 4(sp)
    sw t2, 8(sp)
    jalr s1

    lw t0, 0(sp)
    lw t1, 4(sp)
    lw t2, 8(sp)
    addi sp, sp, 12
    # TODO: restore the registers we saved before calling square
    # (do this after implementing the rest of update_list_loop)

    # TODO: store the value returned by square back into the array
    sw a0, 0(t1)
    
    addi t0, t0, 1
    bne t0, t2, update_list_loop

    # TODO: load the address of the next node into a0
    lw a0, 8(s0)
    
    mv a1, s1

    jal  update_list

done:
    # EPILOUGE
    # TODO: restore the registers that we saved at the beginning of update_list
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw ra, 8(sp)
    addi sp, sp, 12
    jr ra

print_newline:
    li a1, '\n'
    li a0, 11
    ecall
    jr ra

# === Definition of the "square" function ===
square:
    mul a0, a0, a0
    jr ra

# ==== Helper Functions ====
# You don't need to touch anything below here
create_default_list:
    addi sp, sp, -24
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    li s0, 0  # pointer to the last node we handled
    li s1, 0  # number of nodes handled
    li s2, 5  # size
    la s3, arrays
loop: #do...
    li a0, 12
    jal malloc      # get memory for the next node
    mv s4, a0
    li a0, 20
    jal  malloc     # get memory for this array

    sw a0, 0(s4)    # node->arr = malloc
    lw a0, 0(s4)
    mv a1, s3
    jal fillArray   # copy ints over to node->arr

    sw s2, 4(s4)    # node->size = size (4)
    sw  s0, 8(s4)   # node-> next = previously created node

    add s0, x0, s4  # last = node
    addi s1, s1, 1  # i++
    addi s3, s3, 20 # s3 points at next set of ints
    li t6 5
    bne s1, t6, loop # ... while i!= 5
    mv a0, s4
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 24
    jr ra

fillArray: lw t0, 0(a1) #t0 gets array element
    sw t0, 0(a0) #node->arr gets array element
    lw t0, 4(a1)
    sw t0, 4(a0)
    lw t0, 8(a1)
    sw t0, 8(a0)
    lw t0, 12(a1)
    sw t0, 12(a0)
    lw t0, 16(a1)
    sw t0, 16(a0)
    jr ra

print_list:
    bne a0, x0, printMeAndRecurse
    jr ra   # nothing to print
printMeAndRecurse:
    mv t0, a0 # t0 gets address of current node
    lw t3, 0(a0) # t3 gets array of current node
    li t1, 0  # t1 is index into array
printLoop:
    slli t2, t1, 2
    add t4, t3, t2
    lw a1, 0(t4) # a0 gets value in current node's array at index t1
    li a0, 1  # preparte for print integer ecall
    ecall
    li a1, ' ' # a0 gets address of string containing space
    li a0, 11  # prepare for print string ecall
    ecall
    addi t1, t1, 1
  li t6 5
    bne t1, t6, printLoop # ... while i!= 5
    li a1, '\n'
    li a0, 11
    ecall
    lw a0, 8(t0) # a0 gets address of next node
    j print_list # recurse. We don't have to use jal because we already have where we want to return to in ra

malloc:
    mv a1, a0 # Move a0 into a1 so that we can do the syscall correctly
    li a0, 9
    ecall
    jr ra