import test_case
import datetime

# Define the template file path
template_file = 'tbtemplate.v'

# Define the output testbench file path
output_file = 'my_cpu_control_tb.v'

# Read the template file
with open(template_file, 'r') as file:
    template = file.read()

# Generate the test cases
testcase_template = """
        // {assembly}
        inst = 32'h{inst};
        MIO_ready = 1'b1;
        #10;
        `assert(ImmSel, 2'b{ImmSel});
        `assert(ALUSrc_B, 1'b{ALUSrc_B});
        `assert(MemtoReg, 2'b{MemtoReg});
        `assert(Jump, 1'b{Jump});
        `assert(Branch, 1'b{Branch});
        `assert(RegWrite, 1'b{RegWrite});
        `assert(MemRW, 1'b{MemRW});
        `assert(ALU_Control, 3'b{ALU_Control});
        `assert(CPU_MIO, 1'b{CPU_MIO});
"""

test_cases = test_case.test_cases
testcase_strings = []

for case in test_cases:
    testcase_strings.append(testcase_template.format(
        assembly=case['assembly'],
        inst=case['inst'],
        ImmSel=case['ImmSel'],
        ALUSrc_B=case['ALUSrc_B'],
        MemtoReg=case['MemtoReg'],
        Jump=case['Jump'],
        Branch=case['Branch'],
        RegWrite=case['RegWrite'],
        MemRW=case['MemRW'],
        ALU_Control=case['ALU_Control'],
        CPU_MIO=case['CPU_MIO']
    ))

testcases = "\n".join(testcase_strings)

# Replace placeholders in the template
testbench = template.format(testcases=testcases)

# Add a timestamp and warning not to modify the generated code
timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
testbench = f"// Generated on {timestamp}\n// WARNING: Do not modify this file. It is auto-generated.\n\n" + testbench

# Write the generated testbench to the output file
with open(output_file, 'w') as file:
    file.write(testbench)

print(f'Testbench generated and saved to {output_file}')