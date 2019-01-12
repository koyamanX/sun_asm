%{
#include <stdio.h>
#include <stdlib.h>
#include "symtab.h"
#include "sunasm.h"
#include "opcode.h"
#include "y.tab.h"

extern uint32_t line;
%}
%%

#-?[0-9]+ {
	yylval.ival = atoi(yytext+1);
	return INTEGER;
}
#"0x"[a-fA-F0-9]+ {
	yylval.ival = strtol(yytext+1, NULL, 16);
	return INTEGER;
}
(r|R)(0|[12]?[0-9]|3[01]) {
	yylval.ival = atoi(yytext + 1); //excludes leading R(r)
	return REG;
}
$pc|$PC|pc|PC {
	return PC;
}
[(,)\[\]{}#_;.] {
	return *yytext;
}
text {
	return TEXT;
}
bss {
	return BSS;
}
data {
	return DATA;
}
sdata {
	return SDATA;
}
const {
	return CONST;
}
word {
	return WORD;
}
half {
	return HALF;
}
byte {
	return BYTE;
}
space {
	return SPACE;
}
align {
	return ALIGN;	
}
extern {
	return EXTERN;
}
lcomm {
	return LCOMM;
}
comm {
	return COMM;
}
segment {
	return SEGMENT;
}
[\n] {
	line++;
	return *yytext;
}
@[_A-Za-z0-9]+ {
	yylval.symp.symbol = yytext+1; //excludes leading @
	yylval.symp.adrs = line;
	yylval.symp.t = LABEL;
	return LABEL;
}
	/* RTYPE INSTRUCTIONS */
add|ADD {
	yylval.ival = ADD_OP;
	return INST;
}
sub|SUB {
	yylval.ival = SUB_OP;
	return INST_SUB;
}
sll|SLL {
	yylval.ival = SLL_OP;
	return INST;
}
srl|SRL {
	yylval.ival = SRL_OP;
	return INST;
}
sra|SRA {
	yylval.ival = SRA_OP;
	return INST;
}
xor|XOR {
	yylval.ival = XOR_OP;
	return INST;
}
or|OR {
	yylval.ival = OR_OP;
	return INST;
}
and|AND {
	yylval.ival = AND_OP;
	return INST;
}
mult|MULT {
	yylval.ival = MULT_OP;
	return INST;
}
multu|MULTU {
	yylval.ival = MULT_OP;
	return INST_U;
}
div|DIV {
	yylval.ival = DIV_OP;
	return INST;
}
divu|DIVU {
	yylval.ival = DIVU_OP;
	return INST_U;
}
cmp|CMP {
	yylval.ival = CMP_OP;
	return CMP;
}
	/* ITYPE load store instructions */
lw|LW {
	yylval.ival = LW_OP;
	return ITYPE_LS;
}
lh|LH {
	yylval.ival = LH_OP;
	return ITYPE_LS;
}
lhu|LHU {
	yylval.ival = LH_OP;
	return ITYPE_LS_U;
}
lb|LB {
	yylval.ival = LB_OP;
	return ITYPE_LS;
}
lbu|LBU {
	yylval.ival = LB_OP;
	return ITYPE_LS_U;
}
lui|LUI {
	yylval.ival = LUI_OP;
	return ITYPE_LUI;
}
sw|SW {
	yylval.ival = SW_OP;
	return ITYPE_LS;
}
sh|SH {
	yylval.ival = SH_OP;
	return ITYPE_LS;
}
sb|SB {
	yylval.ival = SB_OP;
	return ITYPE_LS;
}
	/* BTYPE INSTRUCTIONS */
bne|BNE {
	yylval.ival = BNE_COND;
	return BTYPE;
}
beq|BEQ {
	yylval.ival = BEQ_COND;
	return BTYPE;
}
bgt|BGT {
	yylval.ival = BGT_COND;
	return BTYPE;
}
bge|BGE {
	yylval.ival = BGE_COND;
	return BTYPE;
}
blt|BLT {
	yylval.ival = BLT_COND;
	return BTYPE;
}
ble|BLE {
	yylval.ival = BLT_COND;
	return BTYPE;
}
b|B {
	yylval.ival = B_COND;
	return BTYPE;
}
bult|BULT {
	yylval.ival = BULT_COND;
	return BTYPE;
}
bule|BULE {
	yylval.ival = BULE_COND;
	return BTYPE;
}
bugt|BUGT {
	yylval.ival = BUGT_COND;
	return BTYPE;
}
buge|BUGE {
	yylval.ival = BUGE_COND;
	return BTYPE;
}
call|CALL {
	yylval.ival = CALL_COND;
	return BTYPE;
}
ret|RET {
	yylval.ival = RET_COND;
	return BTYPE_RET;
}
reti|RETI {
	yylval.ival = RETI_COND;
	return BTYPE_RET;
}
nop|NOP {
	return NOP;
}

[\t ]+ {
	; //ignore spaces
}
";".* {
	; //ignore comment
}
. {
	yyerror("unknown character");
}

%%

int yywrap(void)
{
	return 1;
}

