%{
#define LIST                { strncat(buf, yytext, sizeof(buf) - strlen(buf) - 1); }
#define STR_BUF             { strncat(str_buf, yytext, sizeof(str_buf) - strlen(str_buf) - 1); }
#define token(t)            { LIST; if (Opt_Token) printf("<\"%s\">\n", t); }
#define tokenString(t, s)   { LIST; if (Opt_Token) printf("<%s:%s>\n", t, s); }
#define MAX_LINE_LENGTH 257
#define MAX_ID_LENGTH 257
int Opt_Source = 1;
int Opt_Token = 1;
int Opt_Statistic = 1;
int linenum = 1;
char buf[MAX_LINE_LENGTH];
char str_buf[MAX_LINE_LENGTH];
%}

nonzero_digit [1-9]
digit   [0-9]
letter  [a-zA-Z_]
whitespace   [ \t]
keyword "while"|"do"|"if"|"else"|"true"|"false"|"for"|"int"|"print"|"const"|"read"|"boolean"|"bool"|"void"|"float"|"double"|"string"|"continue"|"break"|"return"
delimiter ","|";"|"("|")"|"["|"]"|"{"|"}"
operators "+"|"-"|"*"|"/"|"%"|"="|"<"|"<="|"!="|">="|">"|"=="|"&&"|"||"|"!"
identifier {letter}+({digit}|{letter})*
printable ([\40-\176])
string ([\40-\41]|[\43-\133]|[\135-\176])*
    //42 is double quoted, 134 is backslash
integer (0|{nonzero_digit}{digit}*)
float ({digit}+\.{digit}+)
scientific ({integer}|{float})[eE][+-]?[0]?{integer}

%Start STR_BEGIN STR_ESCAPE BLOCK_BEGIN
    //INITIAL

%%
\n {
    LIST;
    if (Opt_Source)
        printf("%d:%s\n", linenum, buf);
    ++linenum;
    buf[0] = '\0';
}

{whitespace}+ {
    LIST;
}

<INITIAL>"//"{printable}*/\n { // inline comment is followed by newline
    LIST;
}

<INITIAL>"/*" { // block comment start
    LIST;
    BEGIN(BLOCK_BEGIN);
    //printf("yytext:\"%s\" state: block start\n", yytext);
}

<BLOCK_BEGIN>{printable} {  // in block comment
    LIST;
    //printf("yytext:\"%s\" state: printable in block\n", yytext);
}

<BLOCK_BEGIN>"*/" { // last two char of block comment
    LIST;
    BEGIN(INITIAL);
    //printf("yytext:\"%s\" state: block end\n", yytext);
}

<INITIAL>{delimiter} {
    tokenString("delim", yytext); 
}

<INITIAL>{operators} {
    token(yytext);
}

<INITIAL>{keyword} {
    tokenString("KW", yytext);
}

<INITIAL>{identifier} {
    tokenString("id", yytext);
}

<INITIAL>{integer} {
    tokenString("integer", yytext);
}

<INITIAL>{float} {
    tokenString("float", yytext);
}

<INITIAL>{scientific} {
    tokenString("scientific", yytext);
}

<STR_ESCAPE>(\"|\\) { // when " or \ is found
    LIST;
    STR_BUF;
    BEGIN(STR_BEGIN);
    //printf("yytext:\"%s\" state: str escape end\n", yytext);
}

<STR_BEGIN>(\") { // end state
    BEGIN(INITIAL);
    tokenString("string", str_buf);
    //printf("yytext:\"%s\" state: str end\n", yytext);
}

<STR_BEGIN>(\\) { // when \ is found
    LIST;
    BEGIN(STR_ESCAPE);
    //printf("yytext:\"%s\" state: str escape begin\n", yytext);
}

<INITIAL>(\") {
    LIST;
    BEGIN(STR_BEGIN);
    str_buf[0] = '\0';
    //printf("yytext:\"%s\" state: str begin\n", yytext);
}

<STR_BEGIN>{string} {
    LIST;
    STR_BUF;
    //printf("yytext:\"%s\" state: str_begin\n", yytext);
}

. { // Unrecognized character
    fprintf(stderr, "Error at line %d: %s\n", linenum, yytext);
    exit(1);
}

%%

int main( int argc, char **argv )
{
    if (argc >= 2)
    {
        yyin = fopen( argv[1], "r" );
        if ( NULL == yyin ) {
            fprintf( stderr, "Cannot open: %s\n", argv[1] );
            exit(-1);
        }
    }
    else
    {
        yyin = stdin;
    }

    yylex();

    if (Opt_Statistic)
    {
        // Print frequency table
    }

    exit(0);
}
