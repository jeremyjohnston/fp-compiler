fp-compiler
===========

CS6353 Compiler Construction Project - FP Language Compiler

Jeremy Johnston, jpj054000@utdallas.edu
Oct. 2, 2012.

First phase of Compiler Project for CS 6353 Compiler Construction
----------------------------------------------------------------

To generate the c source from the FP.l lex definition file:
$> lex FP.l

Then, from the c source to the scanner program, use the following:
$> cc lex.yy.c -o scanner -lfl

Finally, to envoke the scanner on some FP source file:
$> ./scanner sample.fp

The scanner will then print to console each token and value, followed
by the symbol table for all identifiers found. Output is of form:

<token matched>: <token value, or string that matched token pattern>

Some design notes:
       Some tokens I had trouble matching. Notably, "-" as there
         is a conflict between detecting the minus sign as an
	   operator, as opposed to as the negation sign of an integer.
	     The admittingly poor workaround used was to enforce surrounding
	       whitespace around "-" when used as an operator.
	         
		   Better would be to use LEX's lookahead functionality, but
		     I had no success with it at this time.
		       
		         Other examples include the boolean literals "T" and "F".
			   
			     Left incomplete is the optimization for numerical operations.
			       
			         Various improvements will need to be made to prepare the
				   lexer for phase 2, such as a better symbol table and
				     better token recognition overall.
