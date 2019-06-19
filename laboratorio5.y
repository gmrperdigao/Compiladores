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

/* Definicao de constantes para os operadores de quadruplas */
#define	OPOR			1
#define	OPAND	 	2
#define 	OPLT	 		3
#define 	OPLE	 		4
#define	OPGT		     5
#define	OPGE			6
#define	OPEQ			7
#define	OPNE			8
#define	OPMAIS	     9
#define	OPMENOS	    10
#define	OPMULTIP	    11
#define	OPDIV         12
#define	OPRESTO	    13
#define	OPMENUN	    14
#define	OPNOT	    15
#define	OPATRIB	    16
#define	OPENMOD	    17
#define	NOP		    18
#define	OPJUMP	    19
#define	OPJF		    20
#define   PARAM         21
#define   OPREAD        22
#define   OPWRITE       23
#define   OPJT          24
#define   OPCALL        25
#define   OPRETURN      26
#define   OPEXIT        27

/* Definicao de constantes para os tipos de operandos de quadruplas */
#define	IDLEOPND		0
#define	VAROPND	     1
#define	INTOPND	     2
#define	REALOPND		3
#define	CHAROPND		4
#define	LOGICOPND	     5
#define	CADOPND	     6
#define	ROTOPND	     7
#define	MODOPND	     8
#define	FUNCOPND	     9


/*Definicao de outras constantes*/
#define	NCLASSHASH	23
#define	VERDADE		1
#define	FALSO		0
#define   MAXDIMS		10

/*Strings para nomes dos tipos de identificadores*/
char *nometipid[3] = {" ", "IDPROG", "IDVAR"};

/*Strings para nomes dos tipos de variaveis*/
char *nometipvar[6] = {"NAOVAR","INTEIRO", "LOGICO", "REAL", "CARACTERE","VAZIO"};

/* Strings para operadores de quadruplas */
char *nomeoperquad[28] = {"",
	"OR", "AND", "LT", "LE", "GT", "GE", "EQ", "NE", "MAIS",
	"MENOS", "MULT", "DIV", "RESTO", "MENUN", "NOT", "ATRIB",
	"OPENMOD", "NOP", "JUMP", "JF", "PARAM", "READ", "WRITE", "JT","CALL","RETURN","EXIT"
};

/*	Strings para tipos de operandos de quadruplas */
char *nometipoopndquad[10] = {"IDLE",
	"VAR", "INT", "REAL", "CARAC", "LOGIC", "CADEIA", "ROTULO", "MODULO","FUNCAO"
};
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

/* Declaracoes para a estrutura do codigo intermediario */
typedef union atribopnd atribopnd;
typedef struct operando operando;
typedef struct celquad celquad;
typedef celquad *quadrupla;
typedef struct celmodhead celmodhead;
typedef celmodhead *modhead;

union atribopnd {
	simbolo simb; int valint; float valfloat;
	char valchar; char vallogic; char *valcad;
     char *func;
     quadrupla rotulo; modhead modulo;
};
struct operando {
	int tipo; 
     atribopnd atr;
};
struct celquad {
	int num, oper; operando opnd1, opnd2, result;
	quadrupla prox;
};
struct celmodhead {
	simbolo modname; modhead prox;
	quadrupla listquad;
};

/* Variaveis globais para o codigo intermediario */
quadrupla quadcorrente, quadaux, quadaux2;
modhead codintermed, modcorrente;
int oper, numquadcorrente;
operando opnd1, opnd2, result, opndaux;
int numtemp;
const operando opndidle = {IDLEOPND, 0};

/* Prototipos das funcoes para o codigo intermediario */
void InicCodIntermed (void);
void InicCodIntermMod (simbolo);
void ImprimeQuadruplas (void);
quadrupla GeraQuadrupla (int, operando, operando, operando);
simbolo NovaTemp (int);
void RenumQuadruplas (quadrupla, quadrupla);

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
     quadrupla quad;
} 
%type	<infovar>	        Variable FuncCall
%type 	<infoexpr> 	Expression  AuxExpr1  AuxExpr2 WriteElem
                        AuxExpr3   AuxExpr4   Term   Factor Parameter
%type     <nsubscr>       Subscripts  SubscrList
%type     <nparam>       Params  ParamList
%type     <nargs>        Arguments ExprList ReadList   WriteList
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
Prog : {InicTabSimb ();InicCodIntermed (); numtemp = 0;} PROGRAM ID OPBRACE 
       {
          printf ("program %s {\n", $3);
          escopo = glob = simb =InsereSimb ($3, IDPROG, NAOVAR, NULL);
          InicCodIntermMod (simb);
          opnd1.tipo = MODOPND;
          opnd1.atr.modulo = modcorrente;
          GeraQuadrupla (OPENMOD, opnd1, opndidle, opndidle);
          opnd1.tipo = FUNCOPND;
          opnd1.atr.func = malloc (strlen("Main") + 1);
          strcpy(opnd1.atr.func, "Main");
          opnd2.tipo = INTOPND;
          opnd2.atr.valint = 0;
          GeraQuadrupla (OPCALL, opnd1, opnd2, opndidle);
          GeraQuadrupla (OPEXIT, opndidle, opndidle, opndidle);
       }
       GlobDecls Functions CLBRACE {
          printf ("}\n");
          VerificaInicRef ();
          ImprimeTabSimb ();
          ImprimeQuadruplas ();
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
Header : MAIN {printf ("main"); countmain++; if(countmain > 1) NaoEsperado ("Main"); 
               escopo = InsereSimb ("Main", IDFUNC, NAOVAR, escopo);
               opnd1.tipo = MODOPND;
               InicCodIntermMod (escopo);
               opnd1.atr.modulo = modcorrente;
               GeraQuadrupla (OPENMOD, opnd1, opndidle, opndidle);
               } 
       | Type ID {printf ("%s", $2); 
                  aux = ProcuraSimb($2);
                  if((aux != NULL && aux->escopo->escopo != NULL)||aux == NULL)
                      escopo = InsereSimb ($2, IDFUNC, tipocorrente, escopo);
                  else NaoEsperado("funcao com nome de variavel global");
                  tipo_func_corrente = tipocorrente;
                  opnd1.tipo = MODOPND;
                  InicCodIntermMod (escopo);
                  opnd1.atr.modulo = modcorrente;
                  GeraQuadrupla (OPENMOD, opnd1, opndidle, opndidle); }  
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
Parameter : Type ID {printf ("%s", $2); InsereSimb ($2, IDVAR, tipocorrente, escopo)->inic = VERDADE; ProcuraSimb($2)->ndims = 0; $$.tipo = tipocorrente;}
          ;
LocDecls : 
         | LOCAL COLON {printf ("local:\n");} DeclList
         ;
Stats : STATEMENTS COLON {printf ("statements:");} StatList 
          {if (quadcorrente->oper != OPRETURN)
	          GeraQuadrupla (OPRETURN, opndidle, opndidle, opndidle);
          }
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
                    opndaux.tipo = ROTOPND;
                    $<quad>$ = GeraQuadrupla (OPJF, $4.opnd, opndidle, opndaux);
                    } CLPAR {printf(")");tab++;}
        Statement { tab--;
        $<quad>$ = quadcorrente;
        $<quad>5->result.atr.rotulo = GeraQuadrupla (NOP, opndidle, opndidle, opndidle);} 
        ElseStat  {
                        if ($<quad>9->prox != quadcorrente) {
                              quadaux = $<quad>9->prox;
                              $<quad>9->prox = quadaux->prox;
                              quadaux->prox = $<quad>9->prox->prox;
                              $<quad>9->prox->prox = quadaux;
                              RenumQuadruplas ($<quad>9, quadcorrente);
                        }
                    }
       ;
ElseStat : 
         | ELSE {printf("\n");tabular(); printf("else");tab++;opndaux.tipo = ROTOPND;
                 $<quad>$ = GeraQuadrupla (OPJUMP, opndidle, opndidle, opndaux);} 
           StatElse {tab--; $<quad>2->result.atr.rotulo = GeraQuadrupla (NOP, opndidle, opndidle, opndidle);}
         | ELSE {printf("\n"); tabular();printf("else"); opndaux.tipo = ROTOPND;
                 $<quad>$ = GeraQuadrupla (OPJUMP, opndidle, opndidle, opndaux);} IF OPPAR {printf(" if \(");} 
         Expression {
                    if ($6.tipo != LOGICO)
                        Incompatibilidade ("Expressao nao logica em comando if");
                    }
         CLPAR {printf(")");tab++;}
        Statement {tab--; $<quad>2->result.atr.rotulo = GeraQuadrupla (NOP, opndidle, opndidle, opndidle);} ElseStat 
         ;
WhileStat : WHILE OPPAR {printf("\n");tabular(); printf("while \("); $<quad>$ = GeraQuadrupla (NOP, opndidle, opndidle, opndidle);} 
            Expression {
               if ($4.tipo != LOGICO)
                    Incompatibilidade ("Expressao nao logica em comando while");
               opndaux.tipo = ROTOPND;
               $<quad>$ = GeraQuadrupla (OPJF, $4.opnd, opndidle, opndaux);
               }
          CLPAR {printf(")");tab++;} Statement {tab--;opndaux.tipo = ROTOPND;
                        opndaux.atr.rotulo = $<quad>3;
                        GeraQuadrupla (OPJUMP, opndidle, opndidle, opndaux);
                        $<quad>5->result.atr.rotulo = GeraQuadrupla (NOP, opndidle, opndidle, opndidle);}
          ;
DoStat : DO {printf("\n");tabular(); printf("do"); $<quad>$ = GeraQuadrupla (NOP, opndidle, opndidle, opndidle);} Statement WHILE OPPAR {printf("while \(");} 
          Expression {
               if ($7.tipo != LOGICO)
                    Incompatibilidade ("Expressao nao logica em comando do-while");
                    opndaux.tipo = ROTOPND;
               	opndaux.atr.rotulo = $<quad>2;
	               GeraQuadrupla (OPJT, $7.opnd, opndidle, opndaux);
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
        SCOLON {printf(";");
                $<quad>$ = GeraQuadrupla (NOP, opndidle, opndidle, opndidle);}
        Expression {
               if ($13.tipo != LOGICO)
                    Incompatibilidade ("Expressao nao logica em comando for");
               opndaux.tipo = ROTOPND;
          	$<quad>$ = GeraQuadrupla (OPJF, $13.opnd, opndidle, opndaux);
               }
        SCOLON {printf(";");
               $<quad>$ = GeraQuadrupla (NOP, opndidle, opndidle, opndidle);} 
        Variable {if  ($5.simb != $17.simb) Incompatibilidade ("Variavel de atualizacao do cabecalho do comando for diferente da inicializacao");}
        ASSIGN {printf(" <- ");} 
        Expression {
                    if ($21.tipo != INTEIRO && $21.tipo != CARACTERE)
                        Incompatibilidade ("3 Expressao nao inteira ou caractere em comando for");
                   }
        CLPAR {printf(")");tab++;$<quad>$ = quadcorrente;} {$<quad>$ = GeraQuadrupla (NOP, opndidle, opndidle, opndidle); } 
        Statement   {tab--;
                    quadaux = quadcorrente;
	               opndaux.tipo = ROTOPND;  opndaux.atr.rotulo = $<quad>12;
	               quadaux2 = GeraQuadrupla (OPJUMP, opndidle, opndidle, opndaux);
	               $<quad>14->result.atr.rotulo = GeraQuadrupla(NOP, opndidle, opndidle, opndidle); 
                    $<quad>14->prox = $<quad>25;
                    quadaux->prox = $<quad>16;
                    $<quad>24->prox = quadaux2;
                    RenumQuadruplas ($<quad>14, quadcorrente);
        }
        ;
ReadStat : READ {printf("\n");tabular(); printf("read");} OPPAR {printf("\(");} ReadList CLPAR 
           {printf(")");
            opnd1.tipo = INTOPND;
            opnd1.atr.valint = $5;
            GeraQuadrupla (OPREAD, opnd1, opndidle, opndidle);} SCOLON {printf(";");}
         ;
ReadList : Variable {
               if  ($1.simb != NULL) 
                 $1.simb->inic = $1.simb->ref = VERDADE;
               $$ = 1;
               GeraQuadrupla (PARAM, $1.opnd, opndidle, opndidle);
           }
           | ReadList COMMA {printf(",");} Variable {
                    if  ($4.simb != NULL) 
                      $4.simb->inic = $4.simb->ref = VERDADE;
                    $$ = $1 + 1;
                    GeraQuadrupla (PARAM, $4.opnd, opndidle, opndidle);
           }
         ;
WriteStat : WRITE {printf("\n");tabular();printf("write");} OPPAR {printf("\(");} WriteList CLPAR 
           {printf(")");
           opnd1.tipo = INTOPND;
           opnd1.atr.valint = $5;
           GeraQuadrupla (OPWRITE, opnd1, opndidle, opndidle);} SCOLON {printf(";");}
          ;
WriteList : WriteElem  {
                        $$ = 1;
                        GeraQuadrupla (PARAM, $1.opnd, opndidle, opndidle);
                      } 
            | WriteList COMMA {printf(",");} WriteElem {
                        $$ = $1 + 1;
                        GeraQuadrupla (PARAM, $4.opnd, opndidle, opndidle);
                    }
          ;
WriteElem : STRING {printf("%s", $1);$$.opnd.tipo = CADOPND;
                        $$.opnd.atr.valcad = malloc (strlen($1) + 1);
                        strcpy ($$.opnd.atr.valcad, $1);} 
           | Expression
          ;
CallStat : CALL {printf("\n");tabular(); printf("call ");} 
           FuncCall {if($3.simb->tvar != VAZIO) Incompatibilidade("Funcao nao eh do tipo VOID");} SCOLON {printf(";");}
         ;
FuncCall : ID {printf ("%s ", $1);
                simb = ProcuraSimb ($1);
                if (simb == NULL)   NaoDeclarado ($1);
                else if (simb->tid != IDFUNC) TipoInadequado ($1);
                $<simb>$ = simb;} 
               OPPAR {printf("\(");} {if(DeclArgs == 0) called = ProcuraSimb($1);DeclArgs++;}
               Arguments CLPAR {printf(")");} {$$.simb = $<simb>2;
               if(called->qparam != $6 && !strcmp(called->cadeia,$1)) 
                  Incompatibilidade("Numero diferente entre argumentos e parametros");
               if(called->cadeia == escopo->cadeia) 
                  Incompatibilidade("A linguagem nao admite recursividade");
               DeclArgs--;
               opnd1.tipo = FUNCOPND; 
               opnd1.atr.func = malloc (strlen($1) + 1);
               strcpy(opnd1.atr.func, $1);
          	opnd2.tipo = INTOPND; opnd2.atr.valint = $6;
	          if ($$.simb->tvar == NAOVAR) result = opndidle;
	          else { result.tipo = VAROPND;
		          result.atr.simb = NovaTemp ($$.simb->tvar); } 	
	          GeraQuadrupla (OPCALL, opnd1, opnd2, result);
	          $$.opnd = result;
               }
         ;
Arguments : {$$ = 0;}
          | ExprList {$$ = $1;}
          ;
ReturnStat : RETURN {printf("\n");tabular();printf("return");} 
             SCOLON {printf(";\n"); if(tipo_func_corrente != VAZIO) Esperado("expressao");
                    GeraQuadrupla(OPRETURN, opndidle, opndidle, opndidle);
                    } 
           | RETURN {printf("\n");tabular();printf("return ");} 
           Expression {if(tipo_func_corrente == VAZIO ) 
                         NaoEsperado("expressao");
                       else if(((tipo_func_corrente == INTEIRO || tipo_func_corrente == CARACTERE) &&
                           ($3.tipo == REAL || $3.tipo == LOGICO)) ||
                           (tipo_func_corrente == REAL && $3.tipo == LOGICO) ||
                           (tipo_func_corrente == LOGICO && $3.tipo != LOGICO))
                         Incompatibilidade("Lado direito de comando de atribuicao improprio");
                         GeraQuadrupla(OPRETURN, $3.opnd, opndidle, opndidle);}
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
                         GeraQuadrupla (OPATRIB, $6.opnd, opndidle, $2.opnd);
           }
           ;
ExprList : Expression { if (((called->params[1] == INTEIRO || called->params[1] == CARACTERE) &&
                           ($1.tipo == REAL || $1.tipo == LOGICO)) ||
                           (called->params[1] == REAL && $1.tipo == LOGICO) ||
                           (called->params[1] == LOGICO && $1.tipo != LOGICO))
                            Incompatibilidade ("Tipo inadequado para argumento");
                        $$ = 1;
                        GeraQuadrupla (PARAM, $1.opnd, opndidle, opndidle);
                      }
          | ExprList COMMA {printf(",");} Expression { $$ = $1 + 1;
                      if (((called->params[$$] == INTEIRO || called->params[$$] == CARACTERE) &&
                           ($4.tipo == REAL || $4.tipo == LOGICO)) ||
                           (called->params[$$] == REAL && $4.tipo == LOGICO) ||
                           (called->params[$$] == LOGICO && $4.tipo != LOGICO))
                            Incompatibilidade ("Tipo inadequado para argumento");
                       $$ = $1 + 1;
                       GeraQuadrupla(PARAM, $4.opnd, opndidle, opndidle);
                    } 
         ;
Expression : AuxExpr1
           | Expression OR {printf (" || ");} 
             AuxExpr1 {
                    if ($1.tipo != LOGICO || $4.tipo != LOGICO)
                       Incompatibilidade ("Operando improprio para operador or");
                    $$.tipo = LOGICO;
                    $$.opnd.tipo = VAROPND;
                    $$.opnd.atr.simb = NovaTemp ($$.tipo);
                    GeraQuadrupla (OPOR, $1.opnd, $4.opnd, $$.opnd);
             }
           ;
AuxExpr1 : AuxExpr2 | AuxExpr1 AND {printf (" && ");} 
           AuxExpr2 {
               if ($1.tipo != LOGICO || $4.tipo != LOGICO)
                  Incompatibilidade ("Operando improprio para operador and");
               $$.tipo = LOGICO;
               $$.opnd.tipo = VAROPND;
               $$.opnd.atr.simb = NovaTemp ($$.tipo);
               GeraQuadrupla (OPAND, $1.opnd, $4.opnd, $$.opnd);
           }
         ;
AuxExpr2 : AuxExpr3 | NOT {printf ("!");} 
           AuxExpr3 {
               if ($3.tipo != LOGICO)
                    Incompatibilidade ("Operando improprio para operador not");
               $$.tipo = LOGICO;
               $$.opnd.tipo = VAROPND;
               $$.opnd.atr.simb = NovaTemp ($3.tipo);
               GeraQuadrupla (OPNOT, $3.opnd, opndidle, $$.opnd);
           }
         ;
AuxExpr3 : AuxExpr4 | AuxExpr4 RELOP {
           if ($2 == LT) {printf (" < ");}
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
               $$.opnd.tipo = VAROPND;
               $$.opnd.atr.simb = NovaTemp($$.tipo);
               switch ($2) {
                    case LT:
                         GeraQuadrupla (OPLT, $1.opnd, $4.opnd, $$.opnd);
                         break;
                    case LE:
                         GeraQuadrupla (OPLE, $1.opnd, $4.opnd, $$.opnd);
                         break;
                    case GT:
                         GeraQuadrupla (OPGT, $1.opnd, $4.opnd, $$.opnd);
                         break;
                    case GE:
                         GeraQuadrupla (OPGE, $1.opnd, $4.opnd, $$.opnd);
                         break;
                    case EQ:
                         GeraQuadrupla (OPEQ, $1.opnd, $4.opnd, $$.opnd);
                         break;
                    case NE:
                         GeraQuadrupla (OPNE, $1.opnd, $4.opnd, $$.opnd);
                         break;
               }
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
                    $$.opnd.tipo = VAROPND;
                    $$.opnd.atr.simb = NovaTemp($$.tipo);
                    if ($2 == MAIS)
                       GeraQuadrupla (OPMAIS, $1.opnd, $4.opnd, $$.opnd);
                    else  GeraQuadrupla (OPMENOS, $1.opnd, $4.opnd, $$.opnd);
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
                           $$.opnd.tipo = VAROPND;
                           $$.opnd.atr.simb = NovaTemp ($$.tipo);
                           if ($2 == VEZES)
                              GeraQuadrupla   (OPMULTIP, $1.opnd, $4.opnd, $$.opnd);
                           else  GeraQuadrupla  (OPDIV, $1.opnd, $4.opnd, $$.opnd);
                           break;
                        case MOD:
                           if ($1.tipo != INTEIRO && $1.tipo != CARACTERE
                                ||  $4.tipo != INTEIRO && $4.tipo != CARACTERE)
                              Incompatibilidade ("Operando improprio para operador resto");
                           $$.tipo = INTEIRO;
                           $$.opnd.tipo = VAROPND;
                           $$.opnd.atr.simb = NovaTemp ($$.tipo);
                           GeraQuadrupla (OPRESTO, $1.opnd, $4.opnd, $$.opnd);
                           break;
                        }
                    }
     ;
Factor : Variable { if  ($1.simb != NULL)  {
                    $1.simb->ref  =  VERDADE;
                    $$.tipo = $1.simb->tvar;
                    $$.opnd = $1.opnd;
                    }
                  }
       | INTCT {printf ("%d", $1); $$.tipo = INTEIRO;$$.opnd.tipo = INTOPND; $$.opnd.atr.valint = $1;} 
       | FLOATCT  {printf ("%f", $1); $$.tipo = REAL;$$.opnd.tipo = REALOPND; $$.opnd.atr.valfloat = $1;}
       | CHARCT {printf ("%s", $1); $$.tipo = CARACTERE;$$.opnd.tipo = CHAROPND;$$.opnd.atr.valchar = $1[1];}
       | TRUE  {printf ("true"); $$.tipo = LOGICO;$$.opnd.tipo = LOGICOPND;$$.opnd.atr.vallogic = 1;}
       | FALSE {printf ("false"); $$.tipo = LOGICO;$$.opnd.tipo = LOGICOPND;$$.opnd.atr.vallogic = 0;}
       | NEG {printf ("~");} Factor {
                if ($3.tipo != INTEIRO && $3.tipo != REAL && $3.tipo != CARACTERE)
                        Incompatibilidade  ("Operando improprio para menos unario");
                if ($3.tipo == REAL) $$.tipo = REAL;
                else $$.tipo = INTEIRO;
                $$.opnd.tipo = VAROPND;
                $$.opnd.atr.simb = NovaTemp ($$.tipo);
                GeraQuadrupla  (OPMENUN, $3.opnd, opndidle, $$.opnd);
         }
       | OPPAR {printf("\(");} Expression CLPAR {printf (")");$$.tipo = $3.tipo;$$.opnd = $3.opnd;}
       | FuncCall {if($1.simb->tvar == VAZIO) Incompatibilidade("Funcao eh do tipo VOID");
                   if(DeclArgs != 0) Incompatibilidade("Funcao nao eh argumento de chamada");
                   if ($1.simb != NULL) {
	          	  $$.tipo = $1.simb->tvar;
		            $$.opnd = $1.opnd;
	              }}
       ;
Variable : ID { printf ("%s ", $1);
                simb = ProcuraSimb ($1);
                if (simb == NULL)   NaoDeclarado ($1);
                else if (simb->tid != IDVAR) TipoInadequado ($1);
                $<simb>$ = simb;
                } Subscripts {
                        $$.simb = $<simb>2;
                        if ($$.simb != NULL) {
                            if ($$.simb->array == FALSO && $3 > 0)
                                NaoEsperado ("Subscrito\(s)");
                            else if ($$.simb->array == VERDADE && $3 == 0)
                                Esperado ("Subscrito\(s)");
                            else if ($$.simb->ndims != $3)
                                Incompatibilidade ("Numero de subscritos incompativel com declaracao");
                            $$.opnd.tipo = VAROPND;
                            if ($3 == 0)
                                $$.opnd.atr.simb = $$.simb;
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
     ajuda = NULL;
     ajuda2 = NULL;
	i = hash (cadeia);
	for (s = tabsimb[i]; (s!=NULL); s = s->prox){
          if(!strcmp(cadeia, s->cadeia) && !strcmp(escopo->cadeia, s->escopo->cadeia))
               ajuda = s;
          else if(!strcmp(cadeia, s->cadeia) && !strcmp(glob->cadeia, s->escopo->cadeia))
               ajuda2 = s;
     };
     if(ajuda!=NULL) return ajuda;
     else if(ajuda2 != NULL) return ajuda2;
     else return s;
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
                         if (!strcmp(s->escopo->cadeia,glob->cadeia))
                              printf(", Global)\n");
				     else  printf(", %s)\n",s->escopo->cadeia);
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

/* Funcoes para o codigo intermediario */
void InicCodIntermed () {
	modcorrente = codintermed = malloc (sizeof (celmodhead));
    modcorrente->listquad = NULL;
	modcorrente->prox = NULL;
}

void InicCodIntermMod (simbolo simb) {
	modcorrente->prox = malloc (sizeof (celmodhead));
	modcorrente = modcorrente->prox;
	modcorrente->prox = NULL;
	modcorrente->modname = simb;
	modcorrente->listquad = malloc (sizeof (celquad));
	quadcorrente = modcorrente->listquad;
	quadcorrente->prox = NULL;
	numquadcorrente = 0;
	quadcorrente->num = numquadcorrente;
}

quadrupla GeraQuadrupla (int oper, operando opnd1, operando opnd2,operando result) {
	quadcorrente->prox = malloc (sizeof (celquad));
	quadcorrente = quadcorrente->prox;
	quadcorrente->oper = oper;
	quadcorrente->opnd1 = opnd1;
	quadcorrente->opnd2 = opnd2;
	quadcorrente->result = result;
	quadcorrente->prox = NULL;
	numquadcorrente ++;
    quadcorrente->num = numquadcorrente;
    return quadcorrente;
}

simbolo NovaTemp (int tip) {
	simbolo simb; int temp, i, j;
	char nometemp[10] = "##", s[10] = {0};

	numtemp ++; temp = numtemp;
	for (i = 0; temp > 0; temp /= 10, i++)
		s[i] = temp % 10 + '0';
	i --;
	for (j = 0; j <= i; j++)
		nometemp[2+i-j] = s[j];
	simb = InsereSimb (nometemp, IDVAR, tip, escopo);
	simb->inic = simb->ref = VERDADE;
    simb->array = FALSO;
	return simb;
}

void ImprimeQuadruplas () {
	modhead p;
	quadrupla q;
	for (p = codintermed->prox; p != NULL; p = p->prox) {
		printf ("\n\nQuadruplas do modulo %s:\n", p->modname->cadeia);
		for (q = p->listquad->prox; q != NULL; q = q->prox) {
			printf ("\n\t%4d) %s", q->num, nomeoperquad[q->oper]);
			printf (", (%s", nometipoopndquad[q->opnd1.tipo]);
			switch (q->opnd1.tipo) {
				case IDLEOPND: break;
				case VAROPND: printf (", %s", q->opnd1.atr.simb->cadeia); break;
				case INTOPND: printf (", %d", q->opnd1.atr.valint); break;
				case REALOPND: printf (", %g", q->opnd1.atr.valfloat); break;
				case CHAROPND: printf (", %c", q->opnd1.atr.valchar); break;
				case LOGICOPND: printf (", %d", q->opnd1.atr.vallogic); break;
				case CADOPND: printf (", %s", q->opnd1.atr.valcad); break;
				case ROTOPND: printf (", %d", q->opnd1.atr.rotulo->num); break;
				case MODOPND: printf(", %s", q->opnd1.atr.modulo->modname->cadeia); break;
                    case FUNCOPND: printf (", %s", q->opnd1.atr.func); break;
			}
			printf (")");
			printf (", (%s", nometipoopndquad[q->opnd2.tipo]);
			switch (q->opnd2.tipo) {
				case IDLEOPND: break;
				case VAROPND: printf (", %s", q->opnd2.atr.simb->cadeia); break;
				case INTOPND: printf (", %d", q->opnd2.atr.valint); break;
				case REALOPND: printf (", %g", q->opnd2.atr.valfloat); break;
				case CHAROPND: printf (", %c", q->opnd2.atr.valchar); break;
				case LOGICOPND: printf (", %d", q->opnd2.atr.vallogic); break;
				case CADOPND: printf (", %s", q->opnd2.atr.valcad); break;
				case ROTOPND: printf (", %d", q->opnd2.atr.rotulo->num); break;
				case MODOPND: printf(", %s", q->opnd2.atr.modulo->modname->cadeia); break;
                    case FUNCOPND: printf (", %s", q->opnd2.atr.func); break;
			}
			printf (")");
			printf (", (%s", nometipoopndquad[q->result.tipo]);
			switch (q->result.tipo) {
				case IDLEOPND: break;
				case VAROPND: printf (", %s", q->result.atr.simb->cadeia); break;
				case INTOPND: printf (", %d", q->result.atr.valint); break;
				case REALOPND: printf (", %g", q->result.atr.valfloat); break;
				case CHAROPND: printf (", %c", q->result.atr.valchar); break;
				case LOGICOPND: printf (", %d", q->result.atr.vallogic); break;
				case CADOPND: printf (", %s", q->result.atr.valcad); break;
				case ROTOPND: printf (", %d", q->result.atr.rotulo->num); break;
				case MODOPND: printf(", %s", q->result.atr.modulo->modname->cadeia); break;
                    case FUNCOPND: printf (", %s", q->result.atr.func); break;
			}
			printf (")");
		}
	}
   printf ("\n");
}

void RenumQuadruplas (quadrupla quad1, quadrupla quad2) {
	quadrupla q; int nquad;
	for (q = quad1->prox, nquad = quad1->num; q != quad2; q = q->prox) {
      nquad++;
		q->num = nquad;
	}
}


tabular () {
int i;
for (i = 1; i <= tab; i++)
printf ("\t");
}
