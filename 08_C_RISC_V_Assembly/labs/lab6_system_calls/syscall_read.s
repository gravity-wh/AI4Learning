.data
    prompt: .asciz "Enter your name: "
    hello:  .asciz "Hello, "
    buffer: .space 100  # 100字节的缓冲区

.text
.globl main
main:
    # 输出提示信息
    li a0, 1
    la a1, prompt
    li a2, 17
    li a7, 64
    ecall

    # 读取用户输入
    li a0, 0          # 文件描述符0（标准输入）
    la a1, buffer     # 缓冲区地址
    li a2, 100        # 缓冲区大小
    li a7, 63         # read系统调用号
    ecall

    # 保存读取的字节数
    mv t0, a0

    # 输出"Hello, "
    li a0, 1
    la a1, hello
    li a2, 7
    li a7, 64
    ecall

    # 输出用户输入
    li a0, 1
    la a1, buffer
    mv a2, t0         # 使用实际读取的字节数
    li a7, 64
    ecall

    # 退出程序
    li a0, 0
    li a7, 93
    ecall