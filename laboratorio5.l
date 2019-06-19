%{
void comentario (void);
char tratachar (char *);
void tratacadeia (char *);
%}
delim [ \t\n\r]
caractere [^ \t\n\r]
ws {delim}+
digito [0-9]
letra [A-Za-z]
ctint {digito}+
ctreal {digito}+"."{digito}*([Ee][+-]?{digito}+)?
carac1 \\.|[^\\']
ctcarac '{carac1}'
carac2 \\.|[^\\\"]
string \"{carac2}*\"
id {letra}({letra}|{digito})*
%%
{ws} { ;}
call {return CALL;}
char {return CHAR;}
do {return DO;}
else {return ELSE;}
false {return FALSE;}
float {return FLOAT;}
for {return FOR;}
functions {return FUNCTIONS;}
global {return GLOBAL;}
if {return IF;}
int {return INT;}
local {return LOCAL;}
logic {return LOGIC;}
main {return MAIN;}
program {return PROGRAM;}
read {return READ;}
return {return RETURN;}
statements {return STATEMENTS;}
true {return TRUE;}
void {return VOID;}
while {return WHILE;}
write {return WRITE;}
"<-" {return ASSIGN;}
"(" {return OPPAR;}
")" {return CLPAR;}
"[" {return OPBRAK;}
"]" {return CLBRAK;}
"{" {return OPBRACE;}
"}" {return CLBRACE;}
";" {return SCOLON;}
"," {return COMMA;}
":" {return COLON;}
{id} {strcpy (yylval.cadeia, yytext); return ID;}
{ctint} {yylval.valint = atoi(yytext); return INTCT;}
{ctreal} {yylval.valreal = atof(yytext); return FLOATCT;}
{ctcarac}	{strcpy (yylval.cadeia, yytext); return CHARCT;}
{string}	{strcpy (yylval.cadeia, yytext); return STRING;}
"||"        {return OR;}
"&&"        {return AND;}
"!"         {return NOT;}
"<"		    {yylval.atr = LT; return RELOP;}
"<="		{yylval.atr = LE; return RELOP;}
">"		    {yylval.atr = GT; return RELOP;}
">="		{yylval.atr = GE; return RELOP;}
"=" 		{yylval.atr = EQ; return RELOP;}
"!="        {yylval.atr = NE; return RELOP;}
"+"         {yylval.atr = MAIS; return ADOP;}
"-"         {yylval.atr = MENOS; return ADOP;}
"*"         {yylval.atr = VEZES; return MULTOP;}
"/"         {yylval.atr = DIV; return MULTOP;}
"%"         {yylval.atr = MOD; return MULTOP;}
"~"         {return NEG;}
"/*"        {comentario ();}
.			{yylval.carac = yytext[0]; return INVAL;}
%%
void comentario () {
    char c; int estado;
    estado = 1;
    while (estado != 3) {
        switch (estado) {
            case 1:
                c = input ();
                if (c == EOF) estado = 3;
                else if (c == '*') estado = 2;
            break;
            case 2:
                c = input ();
                if (c == EOF) estado = 3;
                else if (c == '*') estado = 2;
                else if (c == '/') estado = 3;
                else estado = 1;
                break;
            case 3:
            break;
        }
    }
}
/*
	tratachar: retorna o codigo ASCII de uma constante do tipo char,
   eliminando os apostrofos e as barras invertidas
 */

char tratachar (char *s) {
	if (s[1] != '\\') return s[1];
	else switch (s[2]) {
		case 'a': 	return 7;		case '\\': 	return 92;
		case 'b': 	return 8;		case 'r': 	return 13;
		case '\"': 	return 34;		case 'f': 	return 12;
		case 't': 	return 9;		case 'n': 	return 10;
		case '0': 	return 0;		case '\'': 	return 39;
		case 'v': 	return 11;
		default:	return s[2];
	}
}

/*
	tratacadeia: elimina as aspas e as barras invertidas
	de uma constante do tipo char, substituindo-as pelo respectivo
	codigo ASCII
 */

 void tratacadeia (char *s) {
	int i, n, d;
	n = strlen (s);
	for (i = 0, d = 1; i <= n-2-d; i++)   {
		if (s[i+d] != '\\') s[i] = s[i+d];
		else {
			switch (s[i+d+1]) {
				case 'a': 	s[i] = 7;break;
				case '\\': 	s[i] = 92; break;
				case 'b': 	s[i] = 8; break;
				case 'r': 	s[i] = 13; break;
				case '\"': 	s[i] = 34; break;
				case 'f': 	s[i] = 12; break;
				case 't': 	s[i] = 9;  break;
				case 'n': 	s[i] = 10; break;
				case '\0': 	s[i] = 0;  break;
				case '\'': 	s[i] = 39; break;
				case 'v': 	s[i] = 11; break;
				default:		s[i] = s[i+d+1];
			}
			d++;
		}
	}
	s[i] = s[n];
}
