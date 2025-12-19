.text
.globl asm_main
.globl main

asm_main:
    # 调用print_message函数
    jal ra, print_message

    # 调用add函数，计算5+3
    li a0, 5
    li a1, 3
    jal ra, add

    # 调用printf函数，打印结果
    mv a1, a0       # 将结果移动到a1
    la a0, format   # 将格式字符串地址加载到a0
    jal ra, printf

    ret

.data
format: .asciz "5 + 3 = %d\n"