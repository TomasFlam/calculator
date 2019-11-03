#include <stdio.h>

#define UNUSED(x) ((void) (x))

enum error {
	WRONG_USAGE = 2,
};

int main(int argc, char *argv[])
{
	UNUSED(argv);
	if (argc != 1)
		return WRONG_USAGE;
	char c = getchar();
	putchar(c);
	putchar('\n');
	return 0;
}
