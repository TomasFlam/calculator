%{
int result = 0;
%}

%%
[0-9]+	{ result = atoi(yytext); }
.	{ }
%%
