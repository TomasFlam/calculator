%{
int yylval;
enum yytokentype {
	NUMBER = 1,
};
%}

%%
[0-9]+	{ yylval = atoi(yytext); return NUMBER; }
.	{ }
%%
