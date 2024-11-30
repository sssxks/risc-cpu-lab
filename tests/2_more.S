main:
    andi x5, x0, 0x0        # x5 = 0x0000_0000
    andi x6, x0, 0x0        # x6 = 0x0000_0000
    lui  x2, 0x88888        # x2 = 0x8888_8000
    lw   x3, 0x8(x6)        # x3 = 0x8000_0000
    sw   x3, 0x4(x5)        # mem[1] = 0x8000_0000
    lw   x1, 0x4(x0)        # x1 = 0x8000_0000

nochange:
    lw   x7, 0x1c(x0)       # x7 = 0x8000_0000
    beq  x7, x3, cmd_add    # jump to cmd_add
    jal x0, error           
    lui  x1, 0x55555        # 不执行
    slt  x1, x1, x7         # 不执行
    bne  x1, x0, nochange   # 不执行

cmd_add:
    add  x5, x5, x7         # x5 = 0x8000_0000
    add  x6, x6, x2         # x6 = 0x8888_8000
    bne  x6, x5, cmd_sub    # jump to cmd_sub
    jal x0, error

cmd_sub: 
    sub  x8, x6, x5         # x8 = 0x0888_8000
    sub  x9, x5, x6         # x9 = 0xF777_8000
    jal  x0, cmd_and        # jump to cmd_and
    jal x0, error

cmd_and: 
    and  x10, x5, x7        # x10 = 0x8000_0000
    andi x11, x10, 0x1      # x11 = 0x0000_0000
    bne  x10, x11 cmd_or    # jump to cmd_or
    jal x0, error

cmd_or:
    or   x11, x11, x10      # x11 = 0x8000_0000
    ori  x10, x11, 0x1      # x10 = 0x8000_0001 
    beq  x11, x5, cmd_xor   # jump to cmd_xor
    jal x0, error

cmd_xor: 
    xor  x12, x11, x10      # x12 = 0x0000_0001
    xori x13, x12, 0x1      # x13 = 0x0000_0000
    bne  x12, x11, cmd_srl  # jump to cmd_srl
    jal x0, error

cmd_srl: 
    srli x14, x5, 0x3       # x14 = 0x1000_0000
    srl  x15, x6, x12       # x15 = 0x4444_4000
    beq  x13, x0, cmd_sll   # jump to cmd_sll
    jal x0, error

cmd_sll: 
    slli x16, x12, 0x1c     # x16 = 0x1000_0000
    sll  x17, x9,  x12      # x17 = 0xEEEF_0000 
    beq  x16, x14, cmd_slt  # jump to cmd_slt
    jal x0, error

last:
    addi x24, x0, 160        # x24 = 0x0000_00A0
    jalr x25, x24, -160      # x25 = 0x0000_00A8

cmd_slt: 
    slt   x18, x0, x1        # x18 = 0x0000_0000
    sltu  x19, x0, x5        # x19 = 0x0000_0001
    slti  x20, x5, -1        # x20 = 0x0000_0001
    sltiu x21, x5, 2         # x21 = 0x0000_0000
    bne   x19, x21, cmd_sra  # jump to cmd_sra
    jal x0, error

cmd_sra:
    sra  x22, x16, x20       # x22 = 0x0800_0000
    srai x23, x17, 0x1       # x23 = 0xF777_8000
    jal  x0, last            # jump to last
    jal  x0, error

error:
    addi x31, x0, 1
    jal x0, error