 /* Jeremy Johnston */
 /* LEX Phase 1 definition file  */
 /* ****************************************************************/

 /* Some substitutions for convenience... */
digit	[0-9]
letter	[A-Za-z]
ws		[ \s\t\n]
number  ([0-9]+\.[0-9]+)|(0-9)+
%{
#include <stdio.h>
#include <string.h>

char *symbols[100];
int count;
int i;

%}

%%
 
 /* Comparison Operators ==, >, and >= */
==			printf("Comparison-operator: %s\n", yytext);
>=			printf("Comparison-operator: %s\n", yytext);
>			printf("Comparison-operator: %s\n", yytext);


 /* Boolean operators */
and			printf("Boolean-operator: %s\n", yytext);
or			printf("Boolean-operator: %s\n", yytext);

 /* Special symbols */
[\{\}]		printf("Special symbol: %s\n", yytext);

 /* Predefined functions */
=			printf("Predefined function: %s\n", yytext);
\+			printf("Predefined function: %s\n", yytext);
{ws}+\-{ws}+			printf("Predefined function: %s\n", yytext); /* a conflict with integer makes this a tricky one, as '8-9' would be 'integer integer', so we enforce whitespace wrapping so 8 - 9 behaves as expected*/
\/			printf("Predefined function: %s\n", yytext);
\*			printf("Predefined function: %s\n", yytext);
%			printf("Predefined function: %s\n", yytext);
read		printf("Predefined function: %s\n", yytext);
print		printf("Predefined function: %s\n", yytext);


 /* Keywords */
Program		printf("Keyword: %s\n", yytext);
Function	printf("Keyword: %s\n", yytext);
return		printf("Keyword: %s\n", yytext);
if			printf("Keyword: %s\n", yytext);
then		printf("Keyword: %s\n", yytext);
else		printf("Keyword: %s\n", yytext);
while		printf("Keyword: %s\n", yytext);
do			printf("Keyword: %s\n", yytext);

 /* IDENTIFIER													*/
 /* Matches any identifier of form starting with a letter,		*/
 /* with any number of digits or letters following				*/
 /* (up to a 6 character id, at least for phase 1).				*/
 /*																*/
 /* As from "A Compact Guide to Lex & Yacc" by Tom Niemann 		*/
 /* > {letter}({letter}|{digit})* 								*/
 /* for any length id but in our case we have to modify it a bit.*/

{letter}({letter}|{digit})?({letter}|{digit})?({letter}|{digit})?({letter}|{digit})?({letter}|{digit})?		{printf("identifier: %s\n", yytext); store();}


 /* INTEGER														*/
 /* Match integer which may be a single zero,					*/
 /* or any number with no leading zeros, 						*/
 /* and either may be preceded by a negation sign, 				*/
 /* with zero or more spaces (or any whitespace) between '-' and */
 /* the number. 													*/

-?{ws}*0						printf("integer: %s\n", yytext);
-?{ws}*[1-9]+{digit}*			printf("integer: %s\n", yytext);


 /* FLOAT */
 /* Has to have a decimal, and at least one digit on each side. */
 /* The left side of the decimal follows the rules of INTEGER, */
 /* while the right side may be any number. */

-?{ws}*0\.{digit}+				printf("float: %s\n", yytext);
-?{ws}*[1-9]+{digit}*\.{digit}+	printf("float: %s\n", yytext);


 /* CHARACTER STRING */
 /* A character string is enclosed within parentheses, (), */
 /* and may be any collection of letters, digits, and the */
 /* backslash character. '\' will represent a newline. */ 

\(({letter}|{digit}|{ws}|\\)+\)	printf("character-string: %s\n", yytext);


 /* BOOLEAN */
 /* A boolean may be T or F. To distinguish this from */
 /* a character string, this will be any literal T or F */
 /* not surrounded by parentheses. */
 /* Due to some odd behavior in LEX where the first boolean */
 /* token always fails, we'll enforce a minimum of one character */
 /* whitespace around the token */

{ws}+T{ws}+			printf("boolean: %s\n", yytext);
{ws}+F{ws}+			printf("boolean: %s\n", yytext);


 /* Skip whitespace */
[ \t\n]+	/* skip */

%%
/* Stores a new symbol table entry */
int store(){
	symbols[count] = strdup(yytext);
	count++;
	return 0;
}

int main(int argc, char *argv[]){
	count = 0;
	i = 0;
	yyin = fopen(argv[1], "r");
	yylex();
	fclose(yyin);
	
	printf("\n--------\nSymbol Table:\n--------\n");
	for(i = 0; i < count; i++){
		printf(" Entry %d: %s \n", i, symbols[i]);
	}
}

