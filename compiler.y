%{
	#include <iostream>
	#include <string>
	#include <map>
	#include <list>
	int yylex();
	int yyerror(const char *msg);
	int errors = 0;
	std::map<std::string, bool> tvar;	
	extern int line_no;
%}

%union 	{
			std::string * string;
			std::list<std::string*> * list;
		}

%token TOK_EOF TOK_PROGRAM TOK_VAR TOK_BEGIN TOK_END TOK_INTEGER TOK_DIV TOK_LITERAL TOK_READ TOK_WRITE TOK_FOR TOK_DO TOK_TO TOK_ASSIGN
%token <string> TOK_ID
%type <list> id_list

%start prog

%left TOK_DIV

%%
prog : 
	TOK_PROGRAM prog_name TOK_VAR error TOK_BEGIN stmt_list TOK_END
	{
		std::cerr << "Syntax error #" << ++errors << "\nInvalid declaration at line " << line_no << "\n";
	}
	| TOK_PROGRAM prog_name TOK_VAR dec_list TOK_BEGIN error TOK_END
	{
		std::cerr << "Syntax error #" << ++errors << "\nInvalid statement at line " << line_no << "\n";
	}
	| TOK_PROGRAM prog_name TOK_VAR dec_list TOK_BEGIN stmt_list TOK_END
	{
		if (not errors)
			std::cerr << "Build successful!\n";
		return errors;
	};
prog_name : 
	TOK_ID;
dec_list : 
	dec
	| dec_list ';' dec
	| error ';' dec
	{
		std::cerr << "Syntax error #" << ++errors << "\nInvalid declaration at line " << line_no << "\n";
	};

dec : 
	id_list ':' type
	{
		for (auto& id : *$1)
			if(tvar.find(*id) == tvar.end())
				tvar.insert(std::pair<std::string, bool>(*id,false));
			else
				std::cerr << "Semantical error #" << ++errors << "\nRedeclaration of variable '" << *id << "' at line " << line_no << "\n";
		delete $1;
	};
type : 
	TOK_INTEGER;

id_list : 
	TOK_ID 
	{
		$$ = new std::list<std::string*>();
		$$->push_back($1);
	}
	| id_list ',' TOK_ID
	{
		$$ = $1;
		$$->push_back($3);
	};	

stmt_list : 
	stmt
	| stmt_list ';' stmt
	| error ';' stmt
	{
		std::cerr << "Syntax error #" << ++errors << "\nInvalid statement at line " << line_no;
	};

stmt : 
	read
	| write	
	| for		
	| assign;

read : 
	TOK_READ '(' id_list ')'
	{
		for (auto& id : *$3)
			if (tvar.find(*id) == tvar.end())
				std::cerr << "Semantical error #" << ++errors << "\nUndeclared variable '" << *id << "' used at line " << line_no << "\n";
			else
				tvar[*id] = true;
		delete $3;
	};
write : 
	TOK_WRITE '(' id_list ')'
	{
		for (auto& id : *$3)
			if (tvar.find(*id) == tvar.end())
				std::cerr << "Semantical error #" << ++errors << "\nUndeclared variable '" << *id << "' used at line " << line_no << "\n";
			else if (not tvar[*id])
				std::cerr << "Semantical error #" << ++errors << "\nUndefined variable '" << *id << "' used at line " << line_no << "\n";
		delete $3;
	};
assign : 
	TOK_ID TOK_ASSIGN exp
	{
		if (tvar.find(*$1) == tvar.end())
			std::cerr << "Semantical error #" << ++errors << "\nUndeclared variable '" << *$1 << "' used at line " << line_no << "\n";
		else
			tvar[*$1] = true;
	};
exp : 
	term 
	| exp '+' term
	| exp '-' term;

term : 
	factor
	| term '*' factor
	| term TOK_DIV factor;

factor : 
	TOK_ID
	{
		if (tvar.find(*$1) == tvar.end())
			std::cerr << "Semantical error #" << ++errors << "\nUndeclared variable '" << *$1 << "' used at line " << line_no << "\n";
		else if (not tvar[*$1])
			std::cerr << "Semantical error #" << ++errors << "\nUndefined variable '" << *$1 << "' used at line " << line_no << "\n";
	}
	| TOK_LITERAL
	| '(' exp ')';

for : 
	TOK_FOR index_exp TOK_DO body;
index_exp : 
	TOK_ID TOK_ASSIGN exp TOK_TO exp
	{
		if (tvar.find(*$1) == tvar.end())
			std::cerr << "Semantical error #" << ++errors << "\nUndeclared variable '" << *$1 << "' used at line " << line_no << "\n";
		else
			tvar[*$1] = true;
	};
body : 
	stmt
	| TOK_BEGIN stmt_list TOK_END;

%%

int main()
{
	try
	{
		yyparse();
	}
	catch (int c)
	{
		std::cerr << "Syntax error #" << ++errors << "\nUnexpected End-of-file\n";
		std::cerr << "";
	}
    return 0;
}

int yyerror(const char *msg){return 1;}
