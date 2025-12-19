.text
.globl main
main:
    li a0, 10       # 第一个数
    li a1, 15       # 第二个数
    bgt a0, a1, a0_bigger
    mv a0, a1       # 如果a1更大，将a1的值赋给a0
a0_bigger:
    ret             # 返回a0中的最大值