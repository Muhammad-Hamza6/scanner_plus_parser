%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"

void lexical_error(const char* msg)
{
    fprintf(stderr, "Line %d: Lexical Error -> %s\n", yylineno, msg);
}
%}

%option yylineno noyywrap

identifier	[A-Za-z_][A-Za-z0-9_]*

integer		[0-9]+

decimal		(([0-9]+\.[0-9]*)|(\.[0-9]+))

exponential	([Ee][+-]?[0-9]+)

character	\'(([^'\\])|(\\[0-3]?[0-7]{1,2})|(\\x[A-Fa-f0-9]{1,2})|(\\[abfnrtv'\\]))\'

string		\"(([^"\\])|(\\[0-3]?[0-7]{1,2})|(\\x[A-Fa-f0-9]{1,2})|(\\[abfnrtv"\\]))*\"

delim		[ \t\r\n]+



%%
"shuru"        { return SHURU; }
"khatam"       { return KHATAM; }
"mustakil"     { return MUSTAKIL; }
"adad"         { return ADAD; }
"asharia"      { return ASHARIA; }
"mantiqi"      { return MANTIQI; }
"sahi"         { return SAHI; }
"ghalat"       { return GHALAT; }
"khali"        { return KHALI; }
"huroof"       { return HUROOF; }
"jumla"        { return JUMLA; }
"kuch-nahi"    { return KUCHNAHI; }
"dakhil-karo"  { return DAKHILKARO; }
"likho"        { return LIKHO; }
"agar"         { return AGAR; }
"warna-agar"   { return WARNAAGAR; }
"warna"        { return WARNA; }
"ye-karo"      { return YEKARO; }
"jab-tak"      { return JABTAK; }
"ke-liye"      { return KELIYE; }
"ruk-jao"      { return RUKJAO; }
"aage-chalo"   { return AAGECHALO; }
"bhej-do"      { return BHEJDO; }
{identifier}   { yylval.str = strdup(yytext);
    		 return IDENTIFIER;
	       }
{integer}      { yylval.str = strdup(yytext);
    		 return NUMBER_INTEGER;
	       }
{decimal}      { yylval.str = strdup(yytext);
    		 return NUMBER_FLOAT;
	       }
({integer}|{decimal}){exponential}   { yylval.str = strdup(yytext);
    				       return NUMBER_EXPONENTIAL;
	       }
{character}    { yylval.str = strdup(yytext);
    		 return CHARACTER;
	       }
{string}       { yylval.str = strdup(yytext);
                 return STRING;
	       }
"^"            { return POWER; }
"|&"           { return XOR; }
"&|"           { return XNOR; }
"=="           { return EQ; }
"!="           { return NE; }
">="           { return GE; }
"<="           { return LE; }
">"            { return GT; }
"<"            { return LT; }
"+"            { return PLUS; }
"-"            { return MINUS; }
"*"            { return MULT; }
"/"            { return DIV; }
"%"            { return MOD; }
"="            { return ASSIGN; }
"~"            { return TILDE; }     
":"            { return COLON; }
"("            { return LPAREN; }
")"            { return RPAREN; }
"{"            { return LBRACE; }
"}"            { return RBRACE; }
{delim}        {}           
.	       { lexical_error(yytext);
	       }

%%
