 /* Jeremy Johnston */
 /* YACC definition file  */
 
 /* Good YACC referenceces: */
 /* - http://dinosaur.compilertools.net/yacc/index.html */
 /* - Lex & Yacc, by Doug Brown, John Levine, and Tony Mason, O'Reilly Media, 1995. */
 /* - http://www.utdallas.edu/~pxx101020/TA/Compiler/lexyacc-epaperpress.pdf */
 
 /* Some code used from example in A COMPACT GUIDE TO LEX & YACC by Tom Niemann*/

%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include "FP.h"

/* prototypes */
nodeType *opr(int oper, int nops, ...);
nodeType *id(int i);
nodeType *con(int value);
void freeNode(nodeType *p);
int ex(nodeType *p);
int yylex(void);

void yyerror(char *s);
int yylineno;

char *symbols[200]; /*symbol table*/
char *types[200]; /*type table; types[i] is type of symbol[i] */
%}

%union {
	int iValue; /* integer value (and bool) */
	float fValue; /* float value */
	char *strPtr; /* string pointer */
	char sIndex; /* symbols and types table index */
	nodeType *nPtr; /* node pointer */
};

%token <iValue> INTEGER
%token <iValue> BOOLEAN
%token <fValue> FLOAT
%token <sIndex> IDENTIFIER
%token <strPtr> CHARACTER_STRING
%token IF THEN ELSE WHILE DO READ_INT READ_FLOAT PRINT 
%token GE GR EQ AND OR 
%token FUNCTION RETURN 
%token PROGRAM_NAME FUNCTION_NAME ARGUMENT RETURN_ARG ASSIGNMENT_ID EXPRESSION_ID PARAMETER
%type <nPtr> stmt expr stmt_list

%%

program:
	'{' PROGRAM program-name
		function-definitions
		'{' "Main" statements '}'
	'}'									{ exit(0); }
	;

program-name:
	IDENTIFIER							{ $$ = setUsageType($1, PROGRAM_NAME); }
	;
	
function-definitions:
	(function-definition)*				{ ex($1); freeNode($1); }
	;
	
function-definition:
	'{' FUNCTION function-name arguments 
		statements 
		RETURN return-arg 
	'}'										{ ex($3); freeNode($3); }
	;
	
function-name:
	IDENTIFIER							{ $$ = setUsageType($1, FUNCTION_NAME); }
	;
	
arguments:
	(argument)*							{ ex($1); freeNode($1); }
	;

argument:
	IDENTIFIER							{ $$ = setUsageType($1, ARGUMENT); }
	;
	
return-arg:
	IDENTIFIER							{ $$ = setUsageType($1, RETURN_ARG); }
	| /* empty */
	;
	
statements:
	(statement)+						{ ex($1); freeNode($1); /* Graph statements */}
	;
	
statement:
	assignment-stmt						{ $$ = $1; } 
	| function-call						{ $$ = findCallerOf($1); } /* When a function-call is a statement, it will eventually reduce to a function-definition or program (Main), the caller. */
	| if-stmt							{ $$ = $1; } 
	| while-stmt						{ $$ = $1; } 
	;

assignment-stmt:
	'{' '=' IDENTIFIER parameter '}'	{ $$ = opr('=', 2, id($3), $4); /* Analyze assignment and set usage type to ASSIGNMENT_ID */}
	;
	
function-call:
	'{' function-name parameters '}'			{ $$ = opr($1); } /* -Analyze stack before call to determine caller.-(Done on reduce to parameter) Parameters could be more function calls.*/
	| '{' predefined-function parameters '}' 	{ $$ = opr();}
	;
	
predefined-function:
	'+'									{ $$ = $1; }
	| '-'								{ $$ = $1; }
	| '*'								{ $$ = $1; }
	| '/'								{ $$ = $1; }
	| '%'								{ $$ = $1; }
	| READ_INT							{ $$ = $1; }
	| READ_FLOAT						{ $$ = $1; }
	| PRINT								{ $$ = $1; }
	;
	
parameters:
	(parameter)*						{ $$ = $1; }
	;
	
parameter:
	function-call						{ $$ = $1 } /* Being a parameter of a function does NOT mean I was called by that function, so no need to crawl stack */
	| IDENTIFIER						{ $$ = setUsageType($1, PARAMETER); }
	| number							{ $$ = $1; } /* already handled */
	| CHARACTER_STRING					{ $$ = $1; } /* handle like constant or no? */
	| BOOLEAN							{ $$ = con($1); }
	;

number:
	INTEGER								{ $$ = con($1); }
	| FLOAT								{ $$ = con($1); }
	;
	
if-stmt:
	'{' IF expression					
		THEN statements
		ELSE statements
	'}'									{ $$ = opr($2, 3, $3, $5, $7); } /* Process if statement */
	;
	
while-stmt:
	'{' WHILE expression
		DO	statements
	'}'									{ $$ = opr($2, 2, $3, $5); } /* Process while statement */
	;
	
expression:
	'{' comparison-operator parameter parameter '}'		{ $$ = opr($2, 2, $3, $4); } /* Analyze and check types of both parameter */
	| '{' Boolean-operator expression expression '}'	{ $$ = opr($2, 2, $3, $4); } /* Anaylze and check types of both expression */
	| BOOLEAN											{ $$ = con($1) };
	}
	;
	
comparison-operator:
	EQ											{ $$ = $1; }
	| GR										{ $$ = $1; }
	| GE										{ $$ = $1; }
	;
	
Boolean-operator:
	OR											{ $$ = $1; }
	| AND										{ $$ = $1; }
	;
	
/*
decl: usageType IDENTIFIER      { setUsageType($2, $1); }
    ;

usageType: 
    program-name                { $$ = $1; printf("Type 'program-name' detected. Becoming usageType token..."); }
    | function-name				{ $$ = $1; printf("Type 'function-name' detected. Becoming usageType token..."); }
    | argument					{ $$ = $1; printf("Type 'argument' detected. Becoming usageType token..."); }
    | return-arg				{ $$ = $1; printf("Type 'return-arg' detected. Becoming usageType token..."); }
    | assignment-id				{ $$ = $1; printf("Type 'assignment-id' detected. Becoming usageType token..."); }
    | expression-id				{ $$ = $1; printf("Type 'expression-id' detected. Becoming usageType token..."); }
    | parameter					{ $$ = $1; printf("Type 'parameter' detected. Becoming usageType token..."); }
    ;
*/

%%

extern int yy_flex_debug;

int setUsageType(int id, int type){
	
}

int findCallerOf(int callee){
}

/* From example in A COMPACT GUIDE TO LEX & YACC by Tom Niemann*/
nodeType *con(int value) {
	nodeType *p;
	size_t nodeSize;
	
	/* allocate node */
	nodeSize = SIZEOF_NODETYPE + sizeof(conNodeType);
	if ((p = malloc(nodeSize)) == NULL)
		yyerror("out of memory");
		
	/* copy information */
	p->type = typeCon;
	p->con.value = value;
	
	return p;
}

/* From example in A COMPACT GUIDE TO LEX & YACC by Tom Niemann*/
nodeType *id(int i) {
	nodeType *p;
	size_t nodeSize;
	
	/* allocate node */
	nodeSize = SIZEOF_NODETYPE + sizeof(idNodeType);
	if ((p = malloc(nodeSize)) == NULL)
		yyerror("out of memory");
		
	/* copy information */
	p->type = typeId;
	p->id.i = i;
	
	return p;
}

/* From example in A COMPACT GUIDE TO LEX & YACC by Tom Niemann*/
nodeType *opr(int oper, int nops, ...) {
	va_list ap;
	nodeType *p;
	size_t nodeSize;
	int i;
	
	nodeSize = SIZEOF_NODETYPE + sizeof(oprNodeType) + (nops - 1) * sizeof(nodeType*);
	
	if ((p = malloc(nodeSize)) == NULL)
		yyerror("out of memory");
		
	p->type = typeOpr;
	p->opr.oper = oper;
	p->opr.nops = nops;
	va_start(ap, nops);
	for (i = 0; i < nops; i++)
		p->opr.op[i] = va_arg(ap, nodeType*);
		
	va_end(ap);
	return p;
}

/* From example in A COMPACT GUIDE TO LEX & YACC by Tom Niemann*/
void freeNode(nodeType *p) {
	int i;
	
	if (!p) return;
	if (p->type == typeOpr) {
		for (i = 0; i < p->opr.nops; i++)
			freeNode(p->opr.op[i]);
	}
	
	free (p);
}

void yyerror(char *s) {
	fprintf(stderr, "line %d: %s\n", yylineno, s);
}

int main(void){
	yylineno = 1;
	yy_flex_debug = 1;
	yyparse();
}

