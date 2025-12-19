#include <stdio.h>

int main() {
    int a = 5;
    int b = 3;
    int result;

    // 内联汇编实现result = a + b
    asm volatile(
        "add %0, %1, %2"  /* 汇编指令: result = a + b */
        : "=r" (result)   /* 输出: result */
        : "r" (a), "r" (b) /* 输入: a, b */
        :                 /* 没有被修改的寄存器 */
    );

    printf("Result: %d\n", result);
    return 0;
}