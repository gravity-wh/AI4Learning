#include <stdio.h>

extern void asm_main();

void print_message() {
    printf("Hello from C function!\n");
}

int add(int a, int b) {
    return a + b;
}

int main() {
    asm_main();
    return 0;
}