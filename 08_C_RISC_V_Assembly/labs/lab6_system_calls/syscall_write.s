.data
    msg: .asciz "Hello, RISC-V System Call!\n"

.text
.globl main
main:
    # 使用write系统调用输出字符串
    li a0, 1          # 文件描述符1（标准输出）
    la a1, msg        # 字符串地址
    li a2, 27         # 字符串长度（包括换行符）
    li a7, 64         # write系统调用号
    ecall             # 触发系统调用

    # 使用exit系统调用退出程序
    li a0, 0          # 退出码0
    li a7, 93         # exit系统调用号
    ecall             # 触发系统调用