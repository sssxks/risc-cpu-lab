start:
    jal x0, main        # pc = 0x00
    jal x0, ill_init    # pc = 0x04
    jal x0, eca_init    # pc = 0x08
    jal x0, int_init    # pc = 0x0c
    add x0, x0, x0      # pc = 0x10
    add x0, x0, x0      # pc = 0x14
    add x0, x0, x0      # pc = 0x18
    add x0, x0, x0      # pc = 0x1c

main:
    andi x5, x0, 0x0    # x5 = 0x0000_0000
    andi x6, x0, 0x0    # x6 = 0x0000_0000
    lui  x2, 0x88888    # x2 = 0x8888_8000
    bge  x5, x6, main   # illegal instruction
    lw x3, 0x8(x6)      # x3 = 0x8000_0000
    sw x3, 0x4(x5)      # mem[1] = 0x8000_0000
    lw x1, 0x4(x0)      # x1 = 0x8000_0000

nochange:
    lw x7, 0x1c(x0)         # x7 = 0x8000_0000
    beq x7, x3, cmd_add     # jump to cmd_add
    lui x1, 0x55555
    slt x1, x1, x7
    bne x1, x0, nochange

cmd_add:
    add x5, x5, x7          # x5 = 0x8000_0000
    add x6, x6, x2          # x6 = 0x8888_8000
    bne x6, x5, cmd_sub     # jump to cmd_sub
    jal  x0, error

cmd_sub: 
    sub x8, x6, x5          # x8 = 0x0888_8000
    sub x9, x6, x5          # x9 = 0x0888_8000
    jal x0, cmd_and         # jump to cmd_and
    jal  x0, error

cmd_and: 
    and  x10, x5, x7        # x10 = 0x8000_0000
    ecall                   # pc  = 0x0000_0074
    andi x11, x10, 0x1      # x11 = 0x0000_0000
    bne  x10, x11 cmd_or    # jump to cmd_and
    jal  x0, error

cmd_or: 
    or  x11, x11, x10       # x11 = 0x8000_0000
    ori x10, x11, 0x1       # x10 = 0x8000_0001
    beq x11, x5, cmd_xor    # jump to cmd_xor
    jal  x0, error

cmd_xor: 
    xor  x12, x11, x10      # x12 = 0x0000_0001
    xori x12, x12, 0x1      # x12 = 0x0000_0000
    bne  x12, x11, cmd_srl  # jump to cmd_srl
    jal  x0, error

cmd_srl: 
    srli x5, x5, 0x1        # x5 = 0x4000_0000
    beq  x12, x0, cmd_sll   # jump to cmd_sll
    jal  x0, error

cmd_sll: 
    slli x5, x5, 0x1        # x5 = 0x8000_0000
    beq  x5, x11, cmd_slt   # jump to cmd_slt
    jal  x0, error

cmd_slt: 
    slt  x13, x0, x1        # x13 = 0x0000_0000
    sltu x14, x0, x5        # x14 = 0x0000_0001
    jal  x0, main

ill_init: 
    addi x15, x13, 0x1      # x15 = 0x0000_0001 
    addi x15, x15, 0x1      # x15 = 0x0000_0002
    mret                    # ret to "lw x3, 0x8(x6)"

int_init: 
    lui  x16, 0x66666        
    addi x16, x16, 0x666    # x16 = 0x6666_6666
    mret

eca_init: 
    addi x17, x5, 0x1       # x17 = 0x8000_0001
    addi x17, x17,0x1       # x17 = 0x8888_8002
    mret

error:
    addi x31, x0, 0x1       # x31 = 0x0000_0001
    jal  x0, error           