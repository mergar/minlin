#include <stdio.h>
#include <unistd.h>

int main() {
    while (1) {
        printf("Hello world\n");
        fflush(stdout); // Чтобы текст выводился мгновенно
        sleep(1);       // Пауза на 1 секунду
    }
    return 0;
}
