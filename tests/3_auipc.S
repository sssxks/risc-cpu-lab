    .section .data
# Data section to store test values
test_data: 
    .word 0x12345678       # Test word data
    .half 0x5678           # Test halfword data
    .byte 0x78             # Test byte data

result_lh: 
    .word 0                # Placeholder for LH result
result_lhu: 
    .word 0                # Placeholder for LHU result
result_lb: 
    .word 0                # Placeholder for LB result

result_sh: 
    .word 0                # Placeholder for SH result
result_sb: 
    .word 0                # Placeholder for SB result

    .section .text
    .globl _start
_start:
    # Test JALR
    lui t0, 0x0            # Load upper immediate into t0
    addi t0, t0, 0x100     # Set t0 to 0x100 (base address)
    jalr ra, 4(t0)         # Jump to address t0 + 4 and store return address in ra
    nop                    # This instruction should not execute if JALR works correctly

after_jalr:
    # Test AUIPC
    auipc t1, 0x1          # Load PC + (0x1 << 12) into t1
    sw t1, 0(t0)           # Store the result of AUIPC for verification

    # Test LUI
    lui t2, 0x12345        # Load upper immediate into t2
    sw t2, 4(t0)           # Store the result of LUI for verification

    # Test LH (Load Halfword)
    lh t3, test_data       # Load halfword from test_data into t3 (sign-extended)
    sw t3, result_lh       # Store the result of LH for verification

    # Test LHU (Load Halfword Unsigned)
    lhu t4, test_data      # Load halfword from test_data into t4 (zero-extended)
    sw t4, result_lhu      # Store the result of LHU for verification

    # Test LB (Load Byte)
    lb t5, test_data       # Load byte from test_data into t5 (sign-extended)
    sw t5, result_lb       # Store the result of LB for verification

    # Test SH (Store Halfword)
    li t6, 0xABCD          # Load immediate value into t6
    sh t6, result_sh       # Store halfword from t6 into result_sh

    # Test SB (Store Byte)
    li t7, 0xEF            # Load immediate value into t7
    sb t7, result_sb       # Store byte from t7 into result_sb

    # End of program
    nop
    nop
    nop
