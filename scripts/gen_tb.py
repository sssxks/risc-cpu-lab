import test_case
import datetime

# Define the template file path
template_file = 'tbtemplate.v'

# Define the output testbench file path
output_file = 'div32_tb.v'

# Read the template file
with open(template_file, 'r') as file:
    template = file.read()

# Generate the test cases
testcase_template = """
       start = 1;
       dividend = 32'd{dividend};
       divisor  = 32'd{divisor};
       #335
       start = 0;
       #335
       `assert(quotient, {quotient})
       `assert(remainder, {remainder})
"""

test_cases = test_case.test_cases
testcase_strings = []

for dividend, divisor, expected_quotient, expected_remainder in test_cases:
    testcase_strings.append(testcase_template.format(
        dividend=dividend,
        divisor=divisor,
        quotient=expected_quotient,
        remainder=expected_remainder
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