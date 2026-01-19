%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylineno;
extern char* yytext;
extern FILE* yyin;

int yylex();
void yyerror(const char* s);
int syntax_errors = 0;
%}

%union {
    char* str;
}

/* ===== TOKENS ===== */
/* Literals and Identifiers */
%token <str> IDENTIFIER
%token <str> NUMBER_INTEGER NUMBER_FLOAT NUMBER_EXPONENTIAL
%token <str> STRING CHARACTER

/* Keywords */
%token SHURU KHATAM
%token MUSTAKIL ADAD ASHARIA MANTIQI
%token SAHI GHALAT KHALI
%token HUROOF JUMLA KUCHNAHI

/* IO and Control Flow */
%token DAKHILKARO LIKHO
%token AGAR WARNA WARNAAGAR
%token YEKARO JABTAK KELIYE
%token RUKJAO AAGECHALO BHEJDO

/* Operators */
%token ASSIGN
%token PLUS MINUS MULT DIV MOD
%token EQ NE LT GT LE GE
%token POWER XOR XNOR

/* Punctuation */
%token TILDE COLON
%token LPAREN RPAREN LBRACE RBRACE

/* ===== PRECEDENCE RULES ===== */
/* Ordered from lowest to highest precedence to resolve conflicts */
%left XOR XNOR
%left EQ NE LT GT LE GE
%left PLUS MINUS
%left MULT DIV MOD
%right POWER
%right UMINUS            

/* Handling the dangling-else ambiguity */
%nonassoc LOWER_THAN_WARNA
%nonassoc WARNA

%type <str> expr
%start program

%%

/* ===== GRAMMAR RULES ===== */

program
    : SHURU stmt_list KHATAM
      { 
           if (syntax_errors == 0) {
               printf("\n========================================\n");
               printf("   SYNTAX ANALYSIS SUCCESSFUL!\n");
               printf("========================================\n");
           } else {
               printf("\n========================================\n");
               printf("   PARSING COMPLETED WITH %d ERRORS\n", syntax_errors);
               printf("========================================\n");
           }
      }
    | SHURU KHATAM
      {
           printf("\n(Empty program parsed successfully)\n");
      }
    ;

stmt_list
    : stmt_list stmt
    | stmt
    ;

stmt
    : declaration
    | decl_assign
    | assignment
    | conditional
    | while_loop
    | io_stmt
    | jump
    | block
    ;

/* --- Data Types --- */
datatype
    : ADAD
    | ASHARIA
    | MANTIQI
    | HUROOF
    | JUMLA
    ;

/* --- Declarations (e.g., adad x ~ y :) --- */
declaration
    : datatype declaration_list COLON
    ;

declaration_list
    : IDENTIFIER
    | declaration_list TILDE IDENTIFIER
    ;

/* --- Declaration with Assignment (e.g., adad x = 5 :) --- */
decl_assign
    : datatype decl_assign_list COLON
    ;

decl_assign_list
    : IDENTIFIER ASSIGN expr
    | decl_assign_list TILDE IDENTIFIER ASSIGN expr
    ;

/* --- Assignment (e.g., x = 10 :) --- */
assignment
    : assign_list COLON
    | assign_list error { 
        yyerror("Missing token: Expected ':' at the end of assignment"); 
        yyerrok; 
    }
    ;

assign_list
    : IDENTIFIER ASSIGN expr
    | assign_list TILDE IDENTIFIER ASSIGN expr
    ;

/* --- Conditional Statements (agar/warna) --- */
conditional
    : AGAR LPAREN expr RPAREN block tail %prec LOWER_THAN_WARNA
    | AGAR error block tail { 
        yyerror("Invalid statement structure: Malformed 'agar' condition (check parentheses)"); 
        yyerrok; 
    }
    ;

tail
    : WARNAAGAR LPAREN expr RPAREN block tail
    | WARNA block
    | /* empty */
    ;

/* --- Loops --- */
while_loop
    : JABTAK LPAREN expr RPAREN block
    ;

/* --- I/O Statements --- */
io_stmt
    : LIKHO expr COLON
    | DAKHILKARO IDENTIFIER COLON
    | LIKHO error { 
        yyerror("Missing token: Expected ':' after likho statement"); 
        yyerrok; 
    }
    ;

/* --- Jumps --- */
jump
    : RUKJAO COLON
    | AAGECHALO COLON
    | BHEJDO expr COLON
    ;

/* --- Blocks --- */
block
    : LBRACE stmt_list RBRACE
    | LBRACE RBRACE
    ;

/* --- Expressions --- */
expr
    : expr PLUS expr
    | expr MINUS expr
    | expr MULT expr
    | expr DIV expr
    | expr MOD expr
    | expr EQ expr
    | expr NE expr
    | expr LT expr
    | expr GT expr
    | expr LE expr
    | expr GE expr
    | expr POWER expr
    | expr XOR expr
    | expr XNOR expr
    | MINUS expr %prec UMINUS { $$ = $2; } 
    | LPAREN expr RPAREN { $$ = $2; }
    | IDENTIFIER
    | NUMBER_INTEGER
    | NUMBER_FLOAT
    | NUMBER_EXPONENTIAL
    | STRING
    | CHARACTER
    | SAHI   { $$ = strdup("sahi"); }
    | GHALAT { $$ = strdup("ghalat"); }
    ;

%%

void yyerror(const char* s)
{
    fprintf(stderr, "SYNTAX ERROR at line %d near '%s' : %s\n", yylineno, yytext, s);
    syntax_errors++;
}

int main(int argc, char* argv[])
{
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <input_file>\n", argv[0]);
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror("File error");
        return 1;
    }

    yyparse();
    fclose(yyin);
    return syntax_errors;
}