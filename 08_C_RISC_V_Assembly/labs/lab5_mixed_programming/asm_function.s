.text
.globl asm_multiply
asm_multiply:
    mul a0, a0, a1  # a0 = a0 * a1
    ret