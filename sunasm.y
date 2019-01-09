%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>
#include "symtab.h"
#include "sunasm.h"
#include "opcode.h"
#include "y.tab.h"

#define IMEM_LOCATION 0x00002000

#define head (symtab->next)

uint32_t line = 0;
uint32_t pc = 0;
symtab_t *symtab;
symtab_t *sym;
inst_t imem[IMEM_MAX];
symstat stat;
uint32_t adrs;


%}

%union {
	uint32_t ival;
	symtab_t symp;
	inst_t *ip;
}

%token <ival> REG INTEGER PC LR 
%token <ival> INST INST_U
%token <ival> ITYPE_LS ITYPE_LS_U
%token <ival> BTYPE BTYPE_RET NOP CMP
%token <ival> TEXT SEGMENT
%token <symp> LABEL
%token <ival> RTYPE ITYPE ITYPE_U BTYPE_REG ITYPE_CMP 
%token <ival> ITYPE_LS_S ITYPE_LS_US ITYPE_LS_A ITYPE_LS_UA ITYPE_LS_SA ITYPE_LS_USA
%token <ival> ITYPE_US ITYPE_S ITYPE_LUI INST_SUB
%type <ip> expr 

%%

program:
	init stmt
		{dump(); exit(EXIT_SUCCESS); }
	;
init:
		{ init(); }
	;
stmt:
	stmt expr
		{ 
			writeimem($2);
			free($2);
		}
	| stmt LABEL '\n'
		{
			insert_symtab(symtab, strdup($<symp>2.symbol), pc); 
		}
	| stmt '\n'
		{
			//new line is kind of statement but be ignored
		}
	| '.' SEGMENT TEXT '\n'
		{
			printf("text field\n");
		}
	|
	;
expr:
		/* R-TYPE instructions */
	 INST REG ',' REG ',' REG '\n'
		{ 
			$$ = newnode(RTYPE, 4, $1, $2, $4, $6);
		}
	| INST_SUB REG ',' REG ',' REG '\n'
		{
			$$ = newnode(RTYPE, 4, SUB_RTYPE_OP, $2, $4, $6);
		}
	| CMP REG ',' REG ',' REG '\n'
		{
			$$ = newnode(RTYPE, 4, CMP_RTYPE_OP, $2, $4, $6);
		}
		/* I-TYPE instructions */
	| INST REG ',' INTEGER '(' REG ')' '\n'
		{
			$$ = newnode(ITYPE, 4, $1, $2, $6, $4);
		}
	| INST_SUB REG ',' INTEGER '(' REG ')' '\n'
		{
			$$ = newnode(ITYPE, 4, SUB_ITYPE_OP, $2, $6, $4);
		}
	| ITYPE_LUI REG ',' INTEGER '\n'
		{
			$$ = newnode(ITYPE_LUI, 3, $1, $2, $4);	
		}
	| INST_U REG ',' INTEGER '(' REG ')' '\n'
		{
			$$ = newnode(ITYPE_U, 4, $1, $2, $6, $4);
		}
	| CMP REG ',' INTEGER '\n'
		{
			$$ = newnode(ITYPE_CMP, 3, CMP_ITYPE_OP, $2, $4);
		}
	| ITYPE_LS REG ',' INTEGER '(' REG ')' '\n'
		{
			$$ = newnode(ITYPE_LS, 4, $1, $2, $6, $4);
		}
	| ITYPE_LS_U REG ',' INTEGER '(' REG ')' '\n'
			/* unsigned load */
		{
			$$ = newnode(ITYPE_LS_U, 4, $1, $2, $6, $4);
		}
			/* signed shift */
	| ITYPE_LS REG ',' INTEGER '[' INTEGER ']' '(' REG ')' '\n'
		{
			$$ = newnode(ITYPE_LS_S, 5, $1, $2, $9, $4, $6);
		}
	| ITYPE_LS_U REG ',' INTEGER '[' INTEGER ']' '(' REG ')' '\n'
		{
			$$ = newnode(ITYPE_LS_US, 5, $1, $2, $9, $4, $6);
		}
		/*auto increment */
	| ITYPE_LS REG ',' INTEGER '{' REG '}' '\n'
		{
			$$ = newnode(ITYPE_LS_A, 5, $1, $2, $6, $4);
		}
	| ITYPE_LS_U REG ',' INTEGER '{' REG '}' '\n'
		{
			$$ = newnode(ITYPE_LS_UA, 5, $1, $2, $6, $4);
		}
		/* shift and auto increment */
	| ITYPE_LS REG ',' INTEGER '[' INTEGER ']' '{' REG '}' '\n'
		{
			$$ = newnode(ITYPE_LS_USA, 5, $1, $2, $9, $4, $6);
		}
	| ITYPE_LS_U REG ',' INTEGER '[' INTEGER ']' '{' REG '}' '\n'
		{
			$$ = newnode(ITYPE_LS_USA, 6, $1, $2, $9, $4, $6);
		}

	| BTYPE LABEL '\n'
		{
			$$ = newnode(BTYPE, 4, $1, 0, UNDEFINED, strdup($<symp>2.symbol));
		}
	| BTYPE INTEGER '(' REG ')' '\n'
		{
			$$ = newnode(BTYPE_REG, 4, $1, $4, $2, DEFINED);
		}
	| BTYPE_RET '\n'
		//ret instruction
		{
			$$ = newnode(BTYPE_RET, 4, $1, 0, DEFINED, NULL);
		}
	| NOP '\n'
		{
			//add r0, r0, r0
			$$ = newnode(RTYPE, 4, ADD_OP, 0, 0, 0);
		}
	;

%%

void init(void)
{
	symtab = init_symtab();	
}

inst_t *newnode(type_t nodetype, uint32_t fnum, ...)
{
	va_list ap;
	inst_t *new;
	
	if((new = malloc(sizeof(inst_t))) == NULL)
	{
		yyerror("failed to allocate memoery for new node");
	}
	va_start(ap, fnum);

	switch(nodetype)
	{
		case RTYPE:
		{
			new->rtype.nodetype = nodetype;
			new->rtype.type = RTYPE_TYPE_FIELD;				
			new->rtype.op   = va_arg(ap, uint32_t);
			new->rtype.rd   = va_arg(ap, uint32_t);
			new->rtype.ra   = va_arg(ap, uint32_t);
			new->rtype.rb   = va_arg(ap, uint32_t);
			break;
		}
			/* I-TYPE instructions */
		case ITYPE:
		case ITYPE_U:
		{
			new->itype.nodetype = nodetype;
			new->itype.type = ITYPE_TYPE_FIELD;
			new->itype.op   = va_arg(ap, uint32_t);
			new->itype.rd   = va_arg(ap, uint32_t);
			new->itype.ra   = va_arg(ap, uint32_t);
			new->itype.u    = (nodetype == ITYPE_U) ? 1 : 0;
			new->itype.imm  = 0x00003fff & va_arg(ap, uint32_t);
			break;
		}
		case ITYPE_CMP:
		{
			new->itype.nodetype = nodetype;
			new->itype.type = ITYPE_TYPE_FIELD;
			new->itype.op   = va_arg(ap, uint32_t);
			new->itype.ra   = va_arg(ap, uint32_t);
			new->itype.rd   = 0;
			new->itype.imm  = va_arg(ap, uint32_t);
			new->itype.u    = 0;
			break;
		}
		case ITYPE_LUI:
		{
			new->itype.nodetype = nodetype;
			new->itype.type = ITYPE_TYPE_FIELD;
			new->itype.op   = va_arg(ap, uint32_t);
			new->itype.rd   = va_arg(ap, uint32_t);
			new->itype.imm = 0x000fffff & va_arg(ap, uint32_t);
			break;
		}

			/* I-TYPE Load/Store instructions */
		case ITYPE_LS:
		case ITYPE_LS_U:
		case ITYPE_LS_S:
		case ITYPE_LS_US:
		case ITYPE_LS_A:
		case ITYPE_LS_UA:
		case ITYPE_LS_SA:
		case ITYPE_LS_USA:
		{
			new->itype.nodetype = nodetype;
			new->itype.type = ITYPE_TYPE_FIELD;
			new->itype.op   = va_arg(ap, uint32_t);
			new->itype.rd   = va_arg(ap, uint32_t);
			new->itype.ra   = va_arg(ap, uint32_t);
			new->itype.u    = (nodetype == ITYPE_LS_U || nodetype == ITYPE_LS_US || nodetype == ITYPE_LS_USA) ? 1 : 0;
			new->itype.a    = (nodetype == ITYPE_LS_A || nodetype == ITYPE_LS_UA || nodetype == ITYPE_LS_USA) ? 1 : 0;
			new->itype.s    = (nodetype == ITYPE_LS_S || nodetype == ITYPE_LS_US || nodetype == ITYPE_LS_USA) ? 1 : 0;
			new->itype.imm  = 0x00001fff & va_arg(ap, uint32_t);
			if(nodetype == ITYPE_LS_S || nodetype == ITYPE_LS_US || nodetype == ITYPE_LS_USA)
			{
				new->itype.shift = 0x00000007 & va_arg(ap, uint32_t);
			}
			break;
		}
		case BTYPE:
		case BTYPE_RET:
		case BTYPE_REG:
		{
			new->btype.nodetype = nodetype;
			new->btype.type = BTYPE_TYPE_FIELD;
			new->btype.cond = va_arg(ap, uint32_t);
			new->btype.amode = (nodetype == BTYPE_RET) ? 0 : ((nodetype == BTYPE_REG) ? 1 : 0);
			if(nodetype == BTYPE_REG)
			{
				new->btype.rd = va_arg(ap, uint32_t);
			}
			new->btype.target = (nodetype == BTYPE_RET) ? 0 : (nodetype == BTYPE_REG) ? (0x000fffff & va_arg(ap, uint32_t)) : (0x01ffffff & va_arg(ap, uint32_t));
			new->btype.stat = va_arg(ap, uint32_t);
			new->btype.symbol = (nodetype == BTYPE_REG) ? NULL : va_arg(ap, char *);
			break;
		}
	}
	va_end(ap);

	return new;
}

void writeimem(inst_t *inst)
{
	imem[pc] = *inst;
	pc++;
}

void dump(void)
{
	int i;
	type_t nodetype;

	for(i = 0; i < pc; i++)
	{
		nodetype = imem[i].rtype.nodetype;
		switch(nodetype)
		{
			case RTYPE:
			{
				printbin(imem[i].rtype.type, 2);	
				printbin(imem[i].rtype.op, 5);	
				printbin(imem[i].rtype.rd, 5);	
				printbin(imem[i].rtype.ra, 5);	
				printbin(imem[i].rtype.rb, 5);	
				printbin(0, 10);	
				break;
			}
			case ITYPE:
			case ITYPE_CMP:
			{
				printbin(imem[i].itype.type, 2);	
				printbin(imem[i].itype.op, 5);	
				printbin(imem[i].itype.rd, 5);	
				printbin(imem[i].itype.ra, 5);	
				printbin(imem[i].itype.u, 1);	
				printbin(imem[i].itype.imm, 14);	
				break;
			}
			case ITYPE_LUI:
			{
				printbin(imem[i].itype.type, 2);	
				printbin(imem[i].itype.op, 5);	
				printbin(imem[i].itype.rd, 5);	
				printbin(imem[i].itype.imm, 20);	
				break;
			}
			case ITYPE_LS:
			case ITYPE_LS_U:
			case ITYPE_LS_S:
			case ITYPE_LS_US:
			case ITYPE_LS_A:
			case ITYPE_LS_UA:
			case ITYPE_LS_SA:
			case ITYPE_LS_USA:
			{
				printbin(imem[i].itype.type, 2);	
				printbin(imem[i].itype.op, 5);	
				printbin(imem[i].itype.rd, 5);	
				printbin(imem[i].itype.ra, 5);	
				printbin(imem[i].itype.u, 1);	
				printbin(imem[i].itype.s, 1);	
				printbin(imem[i].itype.a, 1);	
				printbin(imem[i].itype.shift, 3);	
				printbin(imem[i].itype.imm, 9);	
				break;
			}
			case BTYPE:
			case BTYPE_RET:
			case BTYPE_REG:
			{
				stat = imem[i].btype.stat;
				if(nodetype == BTYPE)
				{
					if(stat == UNDEFINED)
					{
						sym = lookup_symtab(head, imem[i].btype.symbol);
						if(sym == NULL)
						{
							yyerror("undefined label");
						}
					}
					//printf("%s pc : %d, adrs : %d\n", sym->symbol, i, sym->adrs);
					if(i > sym->adrs)
					{
						imem[i].btype.target = (-1 * (i - sym->adrs)) -1;
					}
					else if(i == sym->adrs)
					{
						imem[i].btype.target = -1;
					}
					else
					{
						imem[i].btype.target = sym->adrs - i - 1;
					}
				}
				printbin(imem[i].btype.type, 2);	
				printbin(imem[i].btype.cond, 4);	
				printbin(imem[i].btype.amode, 1);	
				if(nodetype == BTYPE_REG)
				{
					printbin(imem[i].btype.rd, 5);	
					printbin(imem[i].btype.target, 20);	
				}
				else
				{
					printbin(imem[i].btype.target, 25);	
				}
				break;
			}
			default:
			{
				yyerror("undefined instruction type");
				break;
			}
		}
		//printf("\n");
	}
}

int printbin(uint32_t data, uint32_t len)
{
	uint32_t x;
	static uint32_t cnt = 1;

	while(len-- > 0)
	{
		x = (data >> len) & 1;
		printf("%d", x);
		if(cnt % 8 == 0)
			printf("\n");
		if(cnt == 32)
			cnt = 1;
		else
			cnt++;
	}
#ifdef DEBUG
	printf("\n");
#endif
}
int yyerror(char *s)
{
	fprintf(stderr, "%s\n", s);
	exit(1);
}

int main(int argc, char **argv)
{
	return yyparse();
}

