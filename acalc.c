#include <stdio.h>

enum error {
	WRONG_USAGE,
};

int main(int argc, char *argv[])
{
	if (argc != 2)
		return WRONG_USAGE;
	puts(argv[1]);
}
