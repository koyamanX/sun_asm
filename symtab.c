#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include "symtab.h"

symtab_t *init_symtab(void)
{
	symtab_t *p;
	if((p = (symtab_t*) malloc(sizeof(symtab_t))) == NULL)
	{
		fprintf(stderr, "failed to allocate memoroy for new entry\n");
		exit(EXIT_FAILURE);
	}

	p->next = NULL;
	return p;
}


symtab_t *insert_symtab(symtab_t *symtab, char *symbol, int adrs)
{
	symtab_t *p, *t;

	if((p = (symtab_t *) malloc(sizeof(symtab_t))) == NULL)
	{
		fprintf(stderr, "failed to allocate memoroy for new entry\n");
		exit(EXIT_FAILURE);
	}

	p->t = SYMBOL;
	p->symbol = symbol;
	p->adrs = adrs;
	p->next = NULL;

	for(t = symtab; t->next != NULL; t = t->next)
		;
	t->next = p;
	return p;
}
symtab_t *lookup_symtab(symtab_t *symtab, char *symbol)
{
	symtab_t *t;

	for(t = symtab; t != NULL; t = t->next)
	{
		if(strcmp(t->symbol, symbol) == 0)
		{
			return t;
		}
	}
	return NULL;
}
void print_symtab(symtab_t *symtab)
{
	symtab_t *t;

	for(t = symtab; t != NULL; t = t->next)
	{
		printf("%s : symbol = %s, adrs = %d\n", __func__, t->symbol, t->adrs);
	}
}

