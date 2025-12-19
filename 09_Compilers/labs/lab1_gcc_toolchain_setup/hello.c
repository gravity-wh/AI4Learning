#include <stdio.h>

int add(int a, int b) {
    return a + b;
}

int main() {
    int x = 5;
    int y = 3;
    int z = add(x, y);
    printf("Hello, RISC-V! %d + %d = %d\n", x, y, z);
    return 0;
}
