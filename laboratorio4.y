%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define LT 	 1
#define LE 	 2
#define	GT	 3
#define	GE	 4
#define	EQ	 5
#define	NE	 6
#define MAIS     7
#define MENOS    8
#define VEZES    9
#define DIV     10
#define MOD     11

/*Definicao dos tipos de identificadores*/
#define 	IDPROG		1
#define 	IDVAR		2
#define 	IDFUNC		3

/*  Definicao dos tipos de passagem de parametros  */
#define PARAMVAL	1
#define PARAMREF	2

/*Definicao dos tipos de variaveis*/
#define 	NAOVAR		0
#define 	INTEIRO		1
#define 	LOGICO		2
#define 	REAL		     3
#define 	CARACTERE	     4
#define 	VAZIO	     5

/*Definicao de outras constantes*/
#define	NCLASSHASH	23
#define	VERDADE		1
#define	FALSO		0
#define   MAXDIMS		10

/*Strings para nomes dos tipos de identificadores*/
char *nometipid[3] = {" ", "IDPROG", "IDVAR"};

/*Strings para nomes dos tipos de variaveis*/
char *nometipvar[6] = {"NAOVAR","INTEIRO", "LOGICO", "REAL", "CARACTERE","VAZIO"};

/*Declaracoes para a tabela de simbolos*/
typedef struct elemlistsimb elemlistsimb;
typedef elemlistsimb *pontelemlistsimb;
typedef elemlistsimb *listsimb;
typedef struct celsimb celsimb;
typedef celsimb *simbolo;
struct celsimb {
	char *cadeia;
	int tid, tvar, qparam, ndims, dims[MAXDIMS+1], params[10];
	char inic, ref, array, parametro;
     listsimb listvardecl, listparam, listfunc; 
	simbolo prox, escopo;
};
struct elemlistsimb {
	simbolo simb; 
	pontelemlistsimb prox;
};
/*  Variaveis globais para a tabela de simbolos e analise semantica */
simbolo tabsimb[NCLASSHASH];
simbolo simb, escopo, aux, called, glob;
listsimb pontfunc, pontvardecl;
int tipocorrente;
int tipo_func_corrente;
int declparam;
int DeclArgs = 0;
int QArgs;
int tab = 0;
int countmain = 0;

/*Prototipos das funcoes para a tabela de simbolos e analise semantica*/
void InicTabSimb (void);
void ImprimeTabSimb (void);
simbolo InsereSimb (char *, int, int, simbolo);
int hash (char *);
simbolo ProcuraSimb (char *);
void DeclaracaoRepetida (char *);
void TipoInadequado (char *);
void NaoDeclarado (char *);
void VerificaInicRef (void);
void Incompatibilidade (char *);
void Esperado (char *);
void NaoEsperado (char *);

typedef union atribopnd atribopnd;
typedef struct operando operando;
union atribopnd {
	simbolo simb; int valint; float valfloat;
	char valchar; char vallogic; char *valcad;
};
struct operando {
	int tipo; 
     atribopnd atr;
};
typedef struct infoexpressao infoexpressao;
struct infoexpressao {
	int tipo;
	operando opnd;
};
typedef struct infovariavel infovariavel;
struct infovariavel {
	simbolo simb;
	operando opnd;
};

%}

%union {
char cadeia[50];
	int atr, valint;
	float valreal;
	char carac;
	simbolo simb;
	int tipoexpr;
     infoexpressao infoexpr;
	infovariavel infovar;
     int nsubscr;
     int nparam;
     int nargs;
} 
%type	<infovar>	        Variable FuncCall
%type 	<infoexpr> 	Expression  AuxExpr1  AuxExpr2 
                        AuxExpr3   AuxExpr4   Term   Factor Parameter
%type     <nsubscr>       Subscripts  SubscrList
%type     <nparam>       Params  ParamList
%type     <nargs>        Arguments ExprList
%token <cadeia> ID
%token <valint> INTCT
%token <valreal> FLOATCT
%token <cadeia> CHARCT
%token <cadeia> STRING
%token <atr> ADOP
%token <atr> MULTOP
%token <atr> RELOP
%token CALL 
%token CHAR 
%token DO 
%token ELSE 
%token FALSE 
%token FLOAT 
%token FOR 
%token FUNCTIONS 
%token GLOBAL 
%token IF 
%token INT 
%token LOCAL 
%token LOGIC 
%token MAIN 
%token PROGRAM 
%token READ 
%token RETURN 
%token STATEMENTS
%token TRUE
%token VOID
%token WHILE
%token WRITE
%token OR 
%token AND 
%token NOT 
%token RELOP 
%token ADOP 
%token MULTOP 
%token NEG 
%token ASSIGN 
%token OPPAR 
%token CLPAR 
%token OPBRAK 
%token CLBRAK 
%token OPBRACE 
%token CLBRACE 
%token SCOLON 
%token COMMA 
%token COLON
%token	<carac>  INVAL
%%
Prog : {InicTabSimb ();} PROGRAM ID OPBRACE 
       {
          printf ("program %s {\n", $3);
          escopo = glob = InsereSimb ($3, IDPROG, NAOVAR, NULL);
          declparam = FALSO; 
          pontvardecl = escopo->listvardecl;
	     pontfunc = escopo->listfunc;
       }
       GlobDecls Functions CLBRACE {
          printf ("}\n");
          VerificaInicRef ();
          ImprimeTabSimb ();
        }
     ;
GlobDecls : 
          | GLOBAL  COLON  {printf ("\nglobal:\n"); tab++;} 
          DeclList {tab--;} 
          ;
DeclList : {tabular();} Declaration 
         | DeclList {tabular();} Declaration 
         ;
Declaration : Type ElemList SCOLON {printf (";\n");}
            ;
Type : INT {printf ("int "); tipocorrente = INTEIRO;} 
     | FLOAT {printf ("float "); tipocorrente = REAL;} 
     | CHAR {printf ("char "); tipocorrente = CARACTERE;}
     | LOGIC {printf ("logic "); tipocorrente = LOGICO;}
     | VOID {printf ("void "); tipocorrente = VAZIO;}
     ;
ElemList : Elem | ElemList COMMA {printf (",");} Elem
         ;
Elem : ID {  printf ("%s ", $1);
             aux = ProcuraSimb ($1);
             if (aux  !=  NULL && escopo == aux->escopo)
                   DeclaracaoRepetida ($1);
             else {simb = InsereSimb ($1, IDVAR, tipocorrente, escopo);
                   simb->array = FALSO; 
                   simb->ndims = 0;
             }
          }  Dims
     ;
Dims :
     | OPBRAK {printf ("\[");} DimList CLBRAK {printf ("]"); simb->array = VERDADE;}
     ;
DimList : INTCT {printf ("%d", $1);
                 if ($1 <= 0) Esperado ("Valor inteiro positivo");
                 simb->ndims++; 
                 simb->dims[simb->ndims] = $1;
                }
        | DimList COMMA {printf (",");} 
          INTCT {
               printf ("%d", $4);
               if ($4 <= 0) 
                    Esperado ("Valor inteiro positivo");
               simb->ndims++; 
               simb->dims[simb->ndims] = $4;
          }
        ;
Functions : FUNCTIONS COLON {tabular (); printf ("\nfunctions:\n");} FuncList {printf ("\n");} 
          ;
FuncList : Function | FuncList Function
         ;
Function : Header OPBRACE {tabular (); printf ("\{\n\n"); tab++;} 
         LocDecls Stats CLBRACE {tab--; tabular (); printf ("\n}\n");escopo=escopo->escopo;}
         ;
Header : MAIN {printf ("main"); countmain++; if(countmain > 1) NaoEsperado ("Main"); escopo = InsereSimb ("Main", IDFUNC, NAOVAR, escopo);} 
       | Type ID {printf ("%s", $2); 
                  aux = ProcuraSimb($2);
                  if((aux != NULL && aux->escopo->escopo != NULL)||aux == NULL)
                      escopo = InsereSimb ($2, IDFUNC, tipocorrente, escopo);
                  else NaoEsperado("funcao com nome de variavel global");
                  tipo_func_corrente = tipocorrente;}  
         OPPAR {printf(" \(");} Params CLPAR {printf(")");escopo->qparam = $6;}
       ;
Params : {$$ = 0; }
       | ParamList {$$ = $1;}
       ;
ParamList : Parameter { if ($1.tipo == VAZIO)
                            Incompatibilidade ("Tipo VOID inadequado para parametro");
                        $$ = 1;
                        escopo->params[1] = $1.tipo;
                      } 
          | ParamList COMMA {printf(",");} 
          Parameter { if ($4.tipo == VAZIO)
                        Incompatibilidade ("Tipo VOID inadequado para parametro");
                      $$ = $1 + 1;
                      escopo->params[$$] = $4.tipo;
                    } 
          ;
Parameter : Type ID {printf ("%s", $2); InsereSimb ($2, IDVAR, tipocorrente, escopo)->inic = VERDADE; $$.tipo = tipocorrente;}
          ;
LocDecls : 
         | LOCAL COLON {printf ("local:\n");} DeclList
         ;
Stats : STATEMENTS COLON {printf ("statements:");} StatList
      ; 
StatList : 
         | Statement
         | StatList Statement
         ;
Statement : CompStat | IfStat | WhileStat | DoStat
          | ForStat | ReadStat | WriteStat
          | AssignStat | CallStat | ReturnStat | SCOLON {printf(";");}
          ;
StatElse : CompStat | WhileStat | DoStat
          | ForStat | ReadStat | WriteStat
          | AssignStat | CallStat | ReturnStat | SCOLON {printf(";");}
          ;
CompStat : OPBRACE
         {printf ("\{");}
         StatList CLBRACE
         {printf("\n");tab--;tabular (); tab++;printf ("}");}
         ;
IfStat : IF OPPAR {printf("\n");tabular(); printf("if \(");} Expression {
                    if ($4.tipo != LOGICO)
                        Incompatibilidade ("Expressao nao logica em comando if");
                    } CLPAR {printf(")");tab++;}
        Statement {tab--;} ElseStat 
       ;
ElseStat : 
         | ELSE {printf("\n");tabular(); printf("else");tab++;} StatElse {tab--;}
         | ELSE {printf("\n"); tabular();printf("else");} IF OPPAR {printf(" if \(");} 
         Expression {
                    if ($6.tipo != LOGICO)
                        Incompatibilidade ("Expressao nao logica em comando if");
                    }
         CLPAR {printf(")");tab++;}
        Statement {tab--;} ElseStat 
         ;
WhileStat : WHILE OPPAR {printf("\n");tabular(); printf("while \(");} 
            Expression {
               if ($4.tipo != LOGICO)
                    Incompatibilidade ("Expressao nao logica em comando while");
               }
          CLPAR {printf(")");tab++;} Statement {tab--;}
          ;
DoStat : DO {printf("\n");tabular(); printf("do");} Statement WHILE OPPAR {printf("while \(");} 
          Expression {
               if ($7.tipo != LOGICO)
                    Incompatibilidade ("Expressao nao logica em comando do-while");
               } 
         CLPAR {printf(")");} SCOLON {printf(";\n");}
       ;
ForStat : FOR {printf("\n");tabular(); printf("for");} OPPAR {printf("\(");} 
        Variable {if  ($5.simb != NULL) $5.simb->inic = $5.simb->ref = VERDADE;} 
        ASSIGN {printf(" <- ");} 
        Expression {
                    if ($9.tipo != INTEIRO && $9.tipo != CARACTERE)
                        Incompatibilidade ("1 Expressao nao inteira ou caractere em comando for");
                   }
        SCOLON {printf(";");}
        Expression {
               if ($13.tipo != LOGICO)
                    Incompatibilidade ("Expressao nao logica em comando for");
               }
        SCOLON {printf(";");} 
        Variable {if  ($5.simb != $17.simb) Incompatibilidade ("Variavel de atualizacao do cabecalho do comando for diferente da inicializacao");}
        ASSIGN {printf(" <- ");} 
        Expression {
                    if ($21.tipo != INTEIRO && $21.tipo != CARACTERE)
                        Incompatibilidade ("3 Expressao nao inteira ou caractere em comando for");
                   }
        CLPAR {printf(")");tab++;} Statement {tab--;}
        ;
ReadStat : READ {printf("\n");tabular(); printf("read");} OPPAR {printf("\(");} ReadList CLPAR {printf(")");} SCOLON {printf(";");}
         ;
ReadList : Variable {
               if  ($1.simb != NULL) 
                 $1.simb->inic = $1.simb->ref = VERDADE;
           }
           | ReadList COMMA {printf(",");} Variable {
                    if  ($4.simb != NULL) 
                      $4.simb->inic = $4.simb->ref = VERDADE;
           }
         ;
WriteStat : WRITE {printf("\n");tabular();printf("write");} OPPAR {printf("\(");} WriteList CLPAR {printf(")");} SCOLON {printf(";");}
          ;
WriteList : WriteElem | WriteList COMMA {printf(",");} WriteElem
          ;
WriteElem : STRING {printf("%s", $1);} | Expression
          ;
CallStat : CALL {printf("\n");tabular(); printf("call ");} 
           FuncCall {if($3.simb->tvar != VAZIO) Incompatibilidade("Funcao nao eh do tipo VOID");} SCOLON {printf(";");}
         ;
FuncCall : ID {printf ("%s ", $1);
                simb = ProcuraSimb ($1);
                if (simb == NULL||(simb->tid == IDVAR && (simb->escopo!=escopo && simb->escopo!=glob)))   NaoDeclarado ($1);
                else if (simb->tid != IDFUNC) TipoInadequado ($1);
                $<simb>$ = simb;} 
               OPPAR {printf("\(");} {if(DeclArgs == 0) called = ProcuraSimb($1);DeclArgs++;}
               Arguments CLPAR {printf(")");} {$$.simb = $<simb>2;
               if(called->qparam != $6 && !strcmp(called->cadeia,$1)) 
                  Incompatibilidade("Numero diferente entre argumentos e parametros");
               if(called->cadeia == escopo->cadeia) 
                  Incompatibilidade("A linguagem nao admite recursividade");
               DeclArgs--;}
         ;
Arguments : {$$ = 0;}
          | ExprList {$$ = $1;}
          ;
ReturnStat : RETURN {printf("\n");tabular();printf("return");} 
             SCOLON {printf(";\n"); if(tipo_func_corrente != VAZIO) Esperado("expressao");} 
           | RETURN {printf("\n");tabular();printf("return ");} 
           Expression {if(tipo_func_corrente == VAZIO ) 
                         NaoEsperado("expressao");
                       else if(((tipo_func_corrente == INTEIRO || tipo_func_corrente == CARACTERE) &&
                           ($3.tipo == REAL || $3.tipo == LOGICO)) ||
                           (tipo_func_corrente == REAL && $3.tipo == LOGICO) ||
                           (tipo_func_corrente == LOGICO && $3.tipo != LOGICO))
                         Incompatibilidade("Lado direito de comando de atribuicao improprio");}
           SCOLON {printf(";\n");}
           ;
AssignStat : {printf("\n");tabular();} Variable {if  ($2.simb != NULL) $2.simb->inic = $2.simb->ref = VERDADE;}
           ASSIGN {printf (" <- ");}
           Expression SCOLON {
                   printf(";");
                   if ($2.simb != NULL)
                        if ((($2.simb->tvar == INTEIRO || $2.simb->tvar == CARACTERE) &&
                           ($6.tipo == REAL || $6.tipo == LOGICO)) ||
                           ($2.simb->tvar == REAL && $6.tipo == LOGICO) ||
                           ($2.simb->tvar == LOGICO && $6.tipo != LOGICO))
                           Incompatibilidade ("Lado direito de comando de atribuicao improprio");
           }
           ;
ExprList : Expression { if (((called->params[1] == INTEIRO || called->params[1] == CARACTERE) &&
                           ($1.tipo == REAL || $1.tipo == LOGICO)) ||
                           (called->params[1] == REAL && $1.tipo == LOGICO) ||
                           (called->params[1] == LOGICO && $1.tipo != LOGICO))
                            Incompatibilidade ("Tipo inadequado para argumento");
                        $$ = 1;
                      }
          | ExprList COMMA {printf(",");} Expression { $$ = $1 + 1;
                      if (((called->params[$$] == INTEIRO || called->params[$$] == CARACTERE) &&
                           ($4.tipo == REAL || $4.tipo == LOGICO)) ||
                           (called->params[$$] == REAL && $4.tipo == LOGICO) ||
                           (called->params[$$] == LOGICO && $4.tipo != LOGICO))
                            Incompatibilidade ("Tipo inadequado para argumento");
                       $$ = $1 + 1;
                    } 
         ;
Expression : AuxExpr1
           | Expression OR {printf (" || ");} 
             AuxExpr1 {
                    if ($1.tipo != LOGICO || $4.tipo != LOGICO)
                       Incompatibilidade ("Operando improprio para operador or");
                    $$.tipo = LOGICO;
             }
           ;
AuxExpr1 : AuxExpr2 | AuxExpr1 AND {printf (" && ");} 
           AuxExpr2 {
               if ($1.tipo != LOGICO || $4.tipo != LOGICO)
                  Incompatibilidade ("Operando improprio para operador and");
               $$.tipo = LOGICO;
           }
         ;
AuxExpr2 : AuxExpr3 | NOT {printf ("!");} 
           AuxExpr3 {
               if ($3.tipo != LOGICO)
                    Incompatibilidade ("Operando improprio para operador not");
               $$.tipo = LOGICO;
           }
         ;
AuxExpr3 : AuxExpr4 | AuxExpr4 RELOP {
           if ($2 == LT) printf (" < ");
           else if ($2 == LE) printf (" <= ");
           else if ($2 == GE) printf (" >= ");
           else if ($2 == GT) printf (" > ");
           else if ($2 == EQ) printf (" = ");
           else printf (" != ");
           } AuxExpr4 {
               switch ($2) {
                    case LT: 
                    case LE: 
                    case GT: 
                    case GE:
                         if ($1.tipo != INTEIRO && $1.tipo != REAL && $1.tipo != CARACTERE || $4.tipo != INTEIRO && $4.tipo != REAL && $4.tipo != CARACTERE)
                              Incompatibilidade	("Operando improprio para operador relacional");
                         break;
                    case EQ: 
                    case NE:
                         if (($1.tipo == LOGICO || $4.tipo == LOGICO) && $1.tipo != $4.tipo)
                              Incompatibilidade ("Operando improprio para operador relacional");
                         break;
               }
               $$.tipo = LOGICO;
           }
         ;
AuxExpr4 : Term | AuxExpr4 ADOP {
           if ($2 == MAIS) printf (" + ");
           else printf (" - ");
           } Term {
                    if ($1.tipo != INTEIRO && $1.tipo != REAL && $1.tipo != CARACTERE || $4.tipo != INTEIRO && $4.tipo!=REAL && $4.tipo!=CARACTERE)
                       Incompatibilidade ("Operando improprio para operador aritmetico");
                    if ($1.tipo == REAL || $4.tipo == REAL) $$.tipo = REAL;
                    else $$.tipo = INTEIRO;
                    }
         ;
Term : Factor | Term MULTOP {
           if ($2 == VEZES) printf ("*");
           else if ($2 == DIV) printf ("/");
           else printf ("%");
           } Factor {switch ($2) {
                        case VEZES: 
                        case DIV:
                           if ($1.tipo != INTEIRO && $1.tipo != REAL && $1.tipo != CARACTERE
                                || $4.tipo != INTEIRO && $4.tipo!=REAL && $4.tipo!=CARACTERE)
                              Incompatibilidade ("Operando improprio para operador aritmetico");
                           if ($1.tipo == REAL || $4.tipo == REAL) 
                              $$.tipo = REAL;
                           else $$.tipo = INTEIRO;
                           break;
                        case MOD:
                           if ($1.tipo != INTEIRO && $1.tipo != CARACTERE
                                ||  $4.tipo != INTEIRO && $4.tipo != CARACTERE)
                              Incompatibilidade ("Operando improprio para operador resto");
                           $$.tipo = INTEIRO;
                           break;
                        }
                    }
     ;
Factor : Variable { if  ($1.simb != NULL)  {
                    $1.simb->ref  =  VERDADE;
                    $$.tipo = $1.simb->tvar;
                    }
                  }
       | INTCT {printf ("%d", $1); $$.tipo = INTEIRO;} 
       | FLOATCT  {printf ("%f", $1); $$.tipo = REAL;}
       | CHARCT {printf ("%s", $1); $$.tipo = CARACTERE;}
       | TRUE  {printf ("true"); $$.tipo = LOGICO;}
       | FALSE {printf ("false"); $$.tipo = LOGICO;}
       | NEG {printf ("~");} Factor {
                if ($3.tipo != INTEIRO && $3.tipo != REAL && $3.tipo != CARACTERE)
                        Incompatibilidade  ("Operando improprio para menos unario");
                if ($3.tipo == REAL) $$.tipo = REAL;
                else $$.tipo = INTEIRO;
         }
       | OPPAR {printf("\(");} Expression CLPAR {printf (")");$$ = $3;}
       | FuncCall {if($1.simb->tvar == VAZIO) Incompatibilidade("Funcao eh do tipo VOID");
                   if(DeclArgs != 0) Incompatibilidade("Funcao nao eh argumento de chamada");}
       ;
Variable : ID { printf ("%s ", $1);
                simb = ProcuraSimb ($1);
                if (simb == NULL||(simb->tid == IDVAR && (simb->escopo!=escopo && simb->escopo!=glob)))   NaoDeclarado ($1);
                else if (simb->tid != IDVAR) TipoInadequado ($1);
                $<simb>$ = simb;} Subscripts {
                        $$.simb = $<simb>2;
                        if ($$.simb != NULL) {
                            if ($$.simb->array == FALSO && $3 > 0)
                                NaoEsperado ("Subscrito\(s)");
                            else if ($$.simb->array == VERDADE && $3 == 0)
                                Esperado ("Subscrito\(s)");
                            else if ($$.simb->ndims != $3)
                                Incompatibilidade ("Numero de subscritos incompativel com declaracao");
                        }
                    }
         ;
Subscripts : {$$ = 0;}
           | OPBRAK {printf("\[");} SubscrList CLBRAK {printf("]"); $$ = $3;}
           ;
SubscrList : AuxExpr4 {
                        if ($1.tipo != INTEIRO && $1.tipo != CARACTERE)
                            Incompatibilidade ("Tipo inadequado para subscrito");
                        $$ = 1;
                    }
           | SubscrList COMMA {printf (",");} AuxExpr4 {
                        if ($4.tipo != INTEIRO && $4.tipo != CARACTERE)
                            Incompatibilidade ("Tipo inadequado para subscrito");
                        $$ = $1 + 1;
                    }
           ;     
%%
#include "lex.yy.c"
/*  InicTabSimb: Inicializa a tabela de simbolos   */
void InicTabSimb () {
	int i;
	for (i = 0; i < NCLASSHASH; i++)
		tabsimb[i] = NULL;
}
/*
	ProcuraSimb (cadeia): Procura cadeia na tabela de simbolos;
	Caso ela ali esteja, retorna um ponteiro para sua celula;
	Caso contrario, retorna NULL.
 */
simbolo ProcuraSimb (char *cadeia) {
	simbolo s; int i;
     simbolo ajuda, ajuda2;
	i = hash (cadeia);
	for (s = tabsimb[i]; (s!=NULL) && strcmp(cadeia, s->cadeia); s = s->prox);
     return s;
}
/*
	InsereSimb (cadeia, tid, tvar): Insere cadeia na tabela de
	simbolos, com tid como tipo de identificador e com tvar como
	tipo de variavel; Retorna um ponteiro para a celula inserida
 */
simbolo InsereSimb (char *cadeia, int tid, int tvar, simbolo escopo) {
	int i; simbolo aux, s;
	i = hash (cadeia); aux = tabsimb[i];
	s = tabsimb[i] = (simbolo) malloc (sizeof (celsimb));
	s->cadeia = (char*) malloc ((strlen(cadeia)+1) * sizeof(char));
	strcpy (s->cadeia, cadeia);
	s->tid = tid;		s->tvar = tvar;
	s->inic = FALSO;	s->ref = FALSO;
	s->prox = aux; s->escopo = escopo;	
     s->qparam = 0;
     return s;
}
/*
	hash (cadeia): funcao que determina e retorna a classe
	de cadeia na tabela de simbolos implementada por hashing
 */
int hash (char *cadeia) {
	int i, h;
	for (h = i = 0; cadeia[i]; i++) {h += cadeia[i];}
	h = h % NCLASSHASH;
	return h;
}
/* ImprimeTabSimb: Imprime todo o conteudo da tabela de simbolos  */
void ImprimeTabSimb () {
	int i; simbolo s;
	printf ("\n\n   TABELA  DE  SIMBOLOS:\n\n");
	for (i = 0; i < NCLASSHASH; i++)
		if (tabsimb[i]) {
			printf ("Classe %d:\n", i);
			for (s = tabsimb[i]; s!=NULL; s = s->prox){
				printf ("  (%s, %s", s->cadeia,  nometipid[s->tid]);
				if (s->tid == IDVAR) {
					printf (", %s, %d, %d", nometipvar[s->tvar], s->inic, s->ref);
                    if (s->array == VERDADE) {
                        int j;
                        printf (", EH ARRAY\n\tndims = %d, dimensoes:", s->ndims);
                        for (j = 1; j <= s->ndims; j++)
                            printf ("  %d", s->dims[j]);
					}
				}
                    if(s->escopo != NULL)
				printf(", %s)\n",s->escopo->cadeia);
                    else printf(", Global)\n");
			}
		}
}
void VerificaInicRef () {
	int i; simbolo s;

	printf ("\n");
	for (i = 0; i < NCLASSHASH; i++)
		if (tabsimb[i])
			for (s = tabsimb[i]; s!=NULL; s = s->prox)
				if (s->tid == IDVAR) {
					if (s->inic == FALSO)
						printf ("%s: Nao Inicializada\n", s->cadeia);
					if (s->ref == FALSO)
						printf ("%s: Nao Referenciada\n", s->cadeia);
				}
}
/*  Mensagens de erros semanticos  */
void DeclaracaoRepetida (char *s) {
	printf ("\n\n***** Declaracao Repetida: %s *****\n\n", s);
}
void NaoDeclarado (char *s) {
    printf ("\n\n***** Identificador Nao Declarado: %s *****\n\n", s);
}
void TipoInadequado (char *s) {
    printf ("\n\n***** Identificador de Tipo Inadequado: %s *****\n\n", s);
}
void Incompatibilidade (char *s) {
    printf ("\n\n***** Incompatibilidade: %s *****\n\n", s);
}
void Esperado (char *s) {
    printf ("\n\n***** Esperado: %s *****\n\n", s);
}
void NaoEsperado (char *s) {
	printf ("\n\n***** Nao Esperado: %s *****\n\n", s);
}
tabular () {
int i;
for (i = 1; i <= tab; i++)
printf ("\t");
}
