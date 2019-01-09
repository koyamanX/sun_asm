CC=gcc
FLEX=flex
FLEXOPT=
BISON=bison
BISONOPT=-d --yacc

TOP=sunasm
SRC=symtab.c y.tab.c lex.yy.c 

all: $(TOP)
y.tab.c: $(TOP).y
	$(BISON) $(BISONOPT) $(TOP).y
lex.yy.c: $(TOP).l
	$(FLEX) $(TOP).l
$(TOP): $(SRC) 
	$(CC) $(SRC)  -o $@ -lfl
clean:
	rm -f $(OBJ) $(TOP) lex.yy.c y.tab.c y.tab.h 
