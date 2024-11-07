loop: 
    addi x1, x0, 1      # x1  = 0x0000_0001
    slt  x2, x0, x1     # x2  = 0x0000_0001    
    add  x3, x2, x1     # x3  = 0x0000_0002  
    add  x4, x3, x2     # x4  = 0x0000_0003
    add  x5, x4, x3     # x5  = 0x0000_0005 
    add  x6, x5, x5     # x6  = 0x0000_000A 
    add  x7, x6, x5     # x7  = 0x0000_000F 
    and  x8, x7, x6     # x8  = 0x0000_000A  
    xor  x9, x8, x7     # x9  = 0x0000_0005 
    or   x10, x9, x3    # x10 = 0x0000_0007 
    sub  x11, x7, x10   # x11 = 0x0000_0008
    sub  x12, x9, x10   # x12 = 0xFFFF_FFFE(-2) 
    addi x13, x11, -2   # x13 = 0x0000_0006
    slti x14, x13, 5    # x14 = 0x0000_0000
    slti x15, x12, 1    # x15 = 0x0000_0001
    xori x16, x14, 20   # x16 = 0x0000_0014
    ori  x17, x15, 10   # x17 = 0x0000_000B 
    andi x18, x17, 31   # x18 = 0x0000_000B
    srl  x19, x18, x3   # x19 = 0x0000_0002
    srli x20, x16, 4    # x20 = 0x0000_0001
    beq  x15, x20, test # jump to test
    addi x21, x20, 1    # 不执行, x21始终为0

test: 
    lw  x22, 0x34(x0)     # x22 = 0x5555_5555 
    lw  x23, 0x48(x0)     # x23 = 0xAAAA_AAAA 
    add x24, x22, x0    
    sub x25, x23, x0 
    sw  x24, 0x48(x0)  
    sw  x25, 0x34(x0)
    jal x26,  loop          # x26 = 0x0000_0074
    add x0, x0, x0        	 

