#ifndef OPCODE_H
#define OPCODE_H

#define RTYPE_TYPE_FIELD 0x0
#define ITYPE_TYPE_FIELD 0x1
#define BTYPE_TYPE_FIELD 0x2

#define DUMMY 0x0

//definition of constants in op field
#define ADD_OP 0x0
#define SUB_OP DUMMY 
#define SUB_RTYPE_OP 0x10
#define SUB_ITYPE_OP ADD_OP 
#define SLL_OP 0x1
#define SRL_OP 0x2
#define SRA_OP 0x3
#define XOR_OP 0x4
#define OR_OP 0x14
#define AND_OP 0x5
#define MULT_OP 0x6
#define MULTU_OP 0x16
#define DIV_OP 0x7
#define DIVU_OP 0x17
#define CMP_RTYPE_OP 0x18
#define CMP_ITYPE_OP 0x10
#define CMP_OP DUMMY 
#define LUI_OP 0x8

#define LW_OP 0x19
#define LH_OP 0x1a
#define LB_OP 0x1b
#define SW_OP 0x1d
#define SH_OP 0x1e
#define SB_OP 0x1f

#define BNE_COND  0x0 
#define BEQ_COND  0x1
#define BGT_COND  0x2 
#define BGE_COND  0x3 
#define BLT_COND  0x4 
#define BLE_COND  0x5 
#define B_COND  0x6 
#define BULT_COND 0x7 
#define BULE_COND 0x8 
#define BUGT_COND 0x9 
#define BUGE_COND 0xa 
#define CALL_COND 0xd
#define RET_COND 0xb 
#define RETI_COND 0xc 

#endif
