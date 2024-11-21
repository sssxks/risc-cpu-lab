test_cases = [
    {
        'assembly': 'add x1, x2, x3',
        'inst': '003100B3',
        'ImmSel': '00', # doesn't matter
        'ALUSrc_B': '0', # rs2
        'MemtoReg': '00', # alu result
        'Jump': '0',
        'Branch': '0',
        'RegWrite': '1',
        'MemRW': '0',
        'ALU_Control': '010', # add
        'CPU_MIO': '0'
    },
    {
        'assembly': 'addi x2, x1, 1',
        'inst': '00108113',
        'ImmSel': '00', # i type
        'ALUSrc_B': '1', # imm
        'MemtoReg': '00', # alu result
        'Jump': '0',
        'Branch': '0',
        'RegWrite': '1',
        'MemRW': '0',
        'ALU_Control': '010', # add
        'CPU_MIO': '0'
    },
    {
        'assembly': 'lw x2, 0(x1)',
        'inst': '0000A103',
        'ImmSel': '00', # i type
        'ALUSrc_B': '1', # imm
        'MemtoReg': '01', # mem
        'Jump': '0',
        'Branch': '0',
        'RegWrite': '1',
        'MemRW': '0',
        'ALU_Control': '010', # add
        'CPU_MIO': '1'
    },
    {
        'assembly': 'sw x2, 0(x1)',
        'inst': '0020A023',
        'ImmSel': '01', # s type
        'ALUSrc_B': '1', # imm
        'MemtoReg': '00', # doesn't matter
        'Jump': '0',
        'Branch': '0',
        'RegWrite': '0',
        'MemRW': '1', # write
        'ALU_Control': '010', # add
        'CPU_MIO': '1'
    },
    {
        'assembly': 'beq x5, x6, -8',
        'inst': 'FE628CE3',
        'ImmSel': '10', # sb type
        'ALUSrc_B': '0', # rs2
        'MemtoReg': '00', # doesn;t matter
        'Jump': '0',
        'Branch': '1',
        'RegWrite': '0',
        'MemRW': '0',
        'ALU_Control': '110', # sub 
        'CPU_MIO': '0'
    },
    {
        'assembly': 'jalr x1, x5, 100',
        'inst': '064280E7',
        'ImmSel': '01', # i type
        'ALUSrc_B': '1', # imm
        'MemtoReg': '10', # PC+4
        'Jump': '1', # jump
        'Branch': '0',
        'RegWrite': '1',
        'MemRW': '0',
        'ALU_Control': '010', 
        'CPU_MIO': '0'
    }
]