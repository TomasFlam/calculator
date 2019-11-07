#include <stdio.h>

#define UNUSED(x) ((void) (x))

extern int yylex();
extern int yylval;

enum error {
	WRONG_USAGE = 2,
	INVALID_SYNTAX = 3,
};

int main(int argc, char *argv[])
{
	UNUSED(argv);
	if (argc != 1)
		return WRONG_USAGE;
	int done = 0;
	int token;
	while ((token = yylex())) {
		if (done)
			return INVALID_SYNTAX;
		printf("%d\n", yylval);
		done = 1;
	}
	return 0;
}
