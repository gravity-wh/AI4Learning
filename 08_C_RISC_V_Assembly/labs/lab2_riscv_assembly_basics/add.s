.text
.globl main
main:
    li a0, 5        # 将立即数5加载到a0
    li a1, 3        # 将立即数3加载到a1
    add a2, a0, a1  # a2 = a0 + a1
    ret