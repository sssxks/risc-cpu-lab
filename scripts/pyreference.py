# 非常幸运，python 整数没有长度限制，可以表达任意长度的寄存器

def binary_division(dividend, divisor):
    if divisor == 0:
        raise ValueError("除数不能为零！")
    
    scratch = dividend
    
    for _ in range(0, 32):
        print(f"scratch = {scratch:016x}, quotient = {scratch & 0xFFFFFFFF}, remainder = {scratch >> 32}")
        subtracted = (((scratch >> 31) & 0x7f_ff_ff_ff) - divisor)
        scratch = scratch << 1
        if subtracted < 0:
            continue
        
        scratch = subtracted << 32 | (scratch & 0xFFFFFFFF) | 1 # quotient[LSB] = 1

    quotient = scratch & 0xFFFFFFFF
    remainder = scratch >> 32

    
    return quotient, remainder

def run_tests():
    import test_case
    test_cases = test_case.test_cases
        
    for dividend, divisor, expected_quotient, expected_remainder in test_cases:
        try:
            quotient, remainder = binary_division(dividend, divisor)
            assert quotient == expected_quotient, f"Test failed for {dividend} / {divisor}: Expected quotient {expected_quotient}, got {quotient}"
            assert remainder == expected_remainder, f"Test failed for {dividend} / {divisor}: Expected remainder {expected_remainder}, got {remainder}"
            print(f"Test passed for {dividend} / {divisor}: Quotient = {quotient}, Remainder = {remainder}")
        except ValueError as e:
            print(f"Test raised ValueError as expected for {dividend} / {divisor}: {e}")

run_tests()
