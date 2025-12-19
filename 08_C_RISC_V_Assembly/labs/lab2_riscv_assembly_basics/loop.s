.text
.globl main
main:
    li a0, 0        # 累加结果，初始化为0
    li a1, 1        # 计数器，初始化为1
    li a2, 5        # 循环终止条件
loop:
    bgt a1, a2, end # 如果a1 > a2，跳转到end
    add a0, a0, a1  # a0 = a0 + a1
    addi a1, a1, 1  # a1 = a1 + 1
    j loop          # 跳转到loop
end:
    ret