#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void print_usage() {
    printf("Usage: rep <string> <int>\n");
}

int main(int argc, char* argv[]) {
    if (argc != 3) {
        print_usage();
        return 1;
    }

    char* str = argv[1];
    int n = atoi(argv[2]);

    for (int i = 0; i < n; i++) {
        printf("%s", str);
    }

    return 0;
}
