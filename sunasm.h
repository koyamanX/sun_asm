#ifndef SUNASM_H
#define SUNASM_H

#include <stdint.h>
#include <stdarg.h>
#include "symtab.h"
#include <stdio.h>

#define SYMTAB_MAX 20
#define IMEM_MAX 512

typedef struct 
{
	type_t nodetype;
	uint32_t type;
	uint32_t op;
	uint32_t rd;
	uint32_t ra;
	uint32_t rb;
}rtype_t;

typedef struct
{
	type_t nodetype;
	uint32_t type;
	uint32_t op;
	uint32_t rd;
	uint32_t ra;
	uint32_t u;
	uint32_t a;
	uint32_t s;
	uint32_t shift;
	uint32_t imm;
}itype_t;

typedef struct
{
	type_t nodetype;
	symstat stat;
	uint32_t type;
	uint32_t cond;
	uint32_t amode;
	uint32_t rd;
	uint32_t target;
	char *symbol;
}btype_t;

typedef union inst_t
{
	rtype_t rtype;	
	itype_t itype;
	btype_t btype;
}inst_t;

inst_t *newnode(type_t nodetype, uint32_t fnum, ...);
void dump(void);
void writeimem(inst_t *inst);
void init(void);
int printbin(uint32_t data, uint32_t len);

extern int yyerror(char *s);
extern int yylex(void);
extern int yywrap(void);

#endif
