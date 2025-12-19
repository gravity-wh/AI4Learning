#include <stdio.h>

// 声明汇编函数
extern int asm_multiply(int a, int b);

int main() {
    int a = 5;
    int b = 3;
    int result = asm_multiply(a, b);
    printf("Result: %d\n", result);
    return 0;
}