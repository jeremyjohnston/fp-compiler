 /* Jeremy Johnston */
 /* LEX Phase 2 definition file  */
 /* ****************************************************************/

 /* Some substitutions for convenience... */
digit	[0-9]
letter	[A-Za-z]
ws		[ \s\t\n]
number  ([0-9]+\.[0-9]+)|(0-9)+

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "FP.h"
#include "y.tab.h"

char buf[200];
char *s;

%}

%x STRING

%%
 
 /* Comparison Operators ==, >, and >= */
==			{ return EQ; }
>=			{ return GE; }
>			{ return GR; }

 /* Boolean operators */
and			{ return AND; }
or			{ return OR; }

 /* Special symbols */
[\{\}]		{ return *yytext; }

 /* Predefined functions */
read-int	{ return READ_INT; }
read-float	{ return READ_FLOAT; }
print		{ return PRINT; }

[-=+*/]		{ return *yytext; }

 /* Keywords */
Program		{ return PROGRAM; }
Function	{ return FUNCTION; }
return		{ return RETURN; }
if			{ return IF; }
then		{ return THEN; }
else		{ return ELSE; }
while		{ return WHILE; }
do			{ return DO; }

 /* IDENTIFIER													*/
 /* Matches any identifier of form starting with a letter,		*/
 /* with any number of digits or letters following				*/
 /* (up to a 6 character id, at least for phase 1).				*/
 /*																*/
 /* As from "A Compact Guide to Lex & Yacc" by Tom Niemann 		*/
 /* > {letter}({letter}|{digit})* 								*/
 /* for any length id but in our case we have to modify it a bit.*/

{letter}({letter}|{digit})?({letter}|{digit})?({letter}|{digit})?({letter}|{digit})?({letter}|{digit})?		{ 
																												return IDENTIFIER; 
																											}


 /* INTEGER														*/
 /* Match integer which may be a single zero,					*/
 /* or any number with no leading zeros, 						*/
 /* and either may be preceded by a negation sign, 				*/
 /* with zero or more spaces (or any whitespace) between '-' and */
 /* the number. 													*/

-?{ws}*0						{
									yylval.iValue = atoi(yytext);
									return INTEGER;
								}
								
-?{ws}*[1-9]+{digit}*			{
									yylval.iValue = atoi(yytext);
									return INTEGER;
								}


 /* FLOAT */
 /* Has to have a decimal, and at least one digit on each side. */
 /* The left side of the decimal follows the rules of INTEGER, */
 /* while the right side may be any number. */

-?{ws}*0\.{digit}+				{
									yylval.fValue = atof(yytext);
									return FLOAT;
								}
								
-?{ws}*[1-9]+{digit}*\.{digit}+	{
									yylval.fValue = atof(yytext);
									return FLOAT;
								}


 /* CHARACTER STRING */
 /* A character string is enclosed within parentheses, (), */
 /* and may be any collection of letters, digits, and the */
 /* backslash character. '\' will represent a newline. */ 								
\( 								{ BEGIN STRING; s = buf; }
<STRING>\\ 					    { *s++ = '\n'; }
<STRING>\) 						{
									*s = 0;
									BEGIN 0;
									yylval.strPtr = strdup(buf);
									printf("found '%s'\n", buf);
									return CHARACTER_STRING;
								}
<STRING>({letter}|{digit}|{ws}) { *s++ = *yytext; }
<STRING>.						{ 
									*s = 0;
									BEGIN 0;
									yyerror("invalid string: " + buf);
									return error;
								}


 /* BOOLEAN */
 /* A boolean may be T or F. To distinguish this from */
 /* a character string, this will be any literal T or F */
 /* not surrounded by parentheses. */
 /* Due to some odd behavior in LEX where the first boolean */
 /* token always fails, we'll enforce a minimum of one character */
 /* whitespace around the token */

{ws}+T{ws}+			{
						yylval.iValue = 1;
						return BOOLEAN;
					}
					
{ws}+F{ws}+			{
						yylval.iValue = 0;
						return BOOLEAN;
					}


 /* Skip whitespace */
[ \t\n]+	/* skip */

.			yyerror("invalid character: " + yytext);

%%
 
int yywrap(void)
{
	return 1;
}

