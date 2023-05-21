#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void print_usage() {
    printf("Usage: rep <string> <int>\n");
}

int main(int argc, char* argv[]) {
    // Check if correct number of arguments are provided
    if (argc != 3) {
        print_usage();
        return 1;
    }

    // Get the string and integer from command line arguments
    char* str = argv[1];
    int n = atoi(argv[2]);

    // Copy the string n times and print to stdout
    for (int i = 0; i < n; i++) {
        printf("%s", str);
    }

    return 0;
}
