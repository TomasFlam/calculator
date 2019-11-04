#include <stdio.h>

#define UNUSED(x) ((void) (x))

extern int result;
extern int yylex();

enum error {
	WRONG_USAGE = 2,
};

int main(int argc, char *argv[])
{
	UNUSED(argv);
	if (argc != 1)
		return WRONG_USAGE;
	yylex();
	printf("%d\n", result);
	return 0;
}
