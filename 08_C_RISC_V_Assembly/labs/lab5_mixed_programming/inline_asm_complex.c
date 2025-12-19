#include <stdio.h>

#define ARRAY_SIZE 10

int main() {
    int arr[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    int sum = 0;

    asm volatile(
        "li t0, 0"                 /* t0 = 0 (索引) */
        "li %0, 0"                 /* sum = 0 */
        "loop:"                    /* 循环开始 */
        "slli t1, t0, 2"           /* t1 = t0 * 4 (字节偏移) */
        "add t2, %1, t1"           /* t2 = &arr[t0] */
        "lw t3, 0(t2)"             /* t3 = arr[t0] */
        "add %0, %0, t3"           /* sum += t3 */
        "addi t0, t0, 1"           /* t0 += 1 */
        "blt t0, %2, loop"         /* 如果t0 < ARRAY_SIZE，跳转到loop */
        : "=r" (sum)               /* 输出: sum */
        : "r" (arr), "i" (ARRAY_SIZE) /* 输入: arr, ARRAY_SIZE */
        : "t0", "t1", "t2", "t3"     /* 被修改的寄存器 */
    );

    printf("Sum: %d\n", sum);
    return 0;
}