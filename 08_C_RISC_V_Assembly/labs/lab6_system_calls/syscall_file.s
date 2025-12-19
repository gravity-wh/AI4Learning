.data
    filename: .asciz "test.txt"
    content:  .asciz "Hello, File World!\n"
    buffer:   .space 100

.text
.globl main
main:
    # 打开文件（创建并写入）
    li a0, 1024      # open系统调用号
    la a1, filename  # 文件名
    li a2, 1         # O_WRONLY
    li a3, 0o644     # 文件权限
    li a7, 1024
    ecall

    # 保存文件描述符
    mv t0, a0

    # 写入文件
    li a0, t0
    la a1, content
    li a2, 19        # 内容长度
    li a7, 64
    ecall

    # 关闭文件
    li a0, t0
    li a7, 1025      # close系统调用号
    ecall

    # 重新打开文件（只读）
    li a0, 1024
    la a1, filename
    li a2, 0         # O_RDONLY
    li a3, 0
    li a7, 1024
    ecall

    # 保存文件描述符
    mv t0, a0

    # 读取文件内容
    li a0, t0
    la a1, buffer
    li a2, 100
    li a7, 63
    ecall

    # 保存读取的字节数
    mv t1, a0

    # 输出文件内容
    li a0, 1
    la a1, buffer
    mv a2, t1
    li a7, 64
    ecall

    # 关闭文件
    li a0, t0
    li a7, 1025
    ecall

    # 退出程序
    li a0, 0
    li a7, 93
    ecall