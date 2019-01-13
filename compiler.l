%{
	#include <string>
	#include <iostream>
	#include <list>
	#include "compiler.tab.h"
	#include <sys/ioctl.h>
	#include <stdio.h>
	#include <stdlib.h>
	#include <unistd.h>
	extern int errors;
	int line_no = 1;
%}

id [a-zA-Z_][a-zA-Z0-9_]*
int 0|[1-9][0-9]*

%%
"PROGRAM"	{ return TOK_PROGRAM; }
"VAR"		{ return TOK_VAR; }
"BEGIN"		{ return TOK_BEGIN; }
"END"		{ return TOK_END; }
"INTEGER"	{ return TOK_INTEGER; }
"DIV"		{ return TOK_DIV; }
"READ"		{ return TOK_READ; }
"WRITE"		{ return TOK_WRITE; }
"FOR"		{ return TOK_FOR; }
"DO"		{ return TOK_DO; }
"TO"		{ return TOK_TO; }
{int}		{ return TOK_LITERAL; }
{id}		{
				yylval.string = new std::string(yytext);
				return TOK_ID; 
			}
\n|\r[^n]	{
				line_no++;
				if (isatty(STDIN_FILENO) && isatty(STDOUT_FILENO))
					std::cout << line_no << '\t'; 
			}
[ \t]*		{}
":="		{ return TOK_ASSIGN; }
";"			{ return ';'; }
":"			{ return ':'; }
","			{ return ','; }
"+"			{ return '+'; }
"-"			{ return '-'; }
"*"			{ return '*'; }
")"			{ return ')'; }
"("			{ return '('; }
.			{ std::cerr << "Lexical error #" << ++errors << "\nInvalid character " << yytext[0] << " at line " << line_no << ".\n";}
<<EOF>>     { throw 0; }
%%
