.text
    .globl _start
_start:
    # Test JALR
    lui t0, 0x12345        # t0(x5) = 0x12345000
    addi t0, t0, 0x678     # t0(x5) = 0x12345678
    jalr ra, zero, 16      # x1(ra) = 0x0000000c PC = 16(after_jalr, 0x10)
    nop                    # This instruction should not execute if JALR works correctly

after_jalr:
    # Test AUIPC
    auipc t1, 0x12345      # x6(t1) = 0x12345010

    # Test LH (Load Halfword)
    li t0 0x12348678       # x5(t0) = 0x12348678
    # assemble to 123482b7        lui x5 0x12348
    #             67828293        addi x5 x5 1656
    sw t0, 0x100(zero)     # store 0x12348678
    lh t3, 0x100(zero)     # x28(t3) = 0xffff8678

    # Test LHU (Load Halfword Unsigned)
    lhu t4, 0x100(zero)     # x29(t4) = 0x00008678

    # Test LB (Load Byte)
    li t0 0x87
    sw t0 0x100(zero)
    lb t5, 0x100(zero)       # x30(t5) = 0xffffff87
    lbu t6, 0x100(zero)      # x30(t6) = 0x00000087
    
    # Test SH (Store Halfword)
    li t0, 0xABCD          # x5(t0) = 0xABCD
    # asseble to lui x5 0xb
    #            addi x5 x5 -1075
    sh t0, 0x102(x0)       # 0x100 = 0xabcd0087
    lw t0, 0x100(x0)       # x5(t0) = 0xabcd0087

    # Test SB (Store Byte)
    li t0, 0xEF            # x5(t0) = 0x000000ef
    sb t0, 0x103(x0) 
    lw t0, 0x100(x0)       # x5(t0) = 0xefcd0087

loop:
    jal loop
