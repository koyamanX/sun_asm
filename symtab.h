#ifndef SYMTAB_H
#define SYMTAB_H

typedef enum
{
	SYMBOL,
	DEFINED,
	UNDEFINED
}type_t;

typedef type_t symstat;

typedef struct symtab
{
	type_t t;
	char *symbol;
	uint32_t adrs;
	struct symtab *next;
}symtab_t;
symtab_t *init_symtab(void);
symtab_t *insert_symtab(symtab_t *symtab, char *symbol, int adrs);
symtab_t *lookup_symtab(symtab_t *symtab, char *symbol);
void print_symtab(symtab_t *symtab);

#endif
