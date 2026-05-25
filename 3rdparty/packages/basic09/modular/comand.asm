
 nam BASIC09

***************
* Edition History (started with edition 18)

*   Edition      Problem Fixed                            By
* -----------  ----------------------------------------- -----
* 18 82/10/13  "PROGRAM" literal changed to "Program"    (RFD)
* 18 82/10/13  Formatted strings could exceed field size (RFD)
* 18 82/10/13  Formatted boolean output phrases reversed (RFD)
* 18 82/10/18  Assembly subroutine errors now recognized (RFD)
* 18 82/10/19  Mem directive fixed to take more than 32k (RFD)
* 19 82/11/02  Default USING field size 1 if unspecified (RFD)
* 19 82/11/02  Prevent death on out of range input       (RFD)
* 19 82/11/16  Compiler var "CNTASS" initialized to fix
*             random crash if T.CXAS inserted by mistake.(RFD)
* 19 82/11/16  Mem comand made to request 1 less byte.   (RFD)
* 20 83/01/12  Changed string terminator from $FF to $00,
*               allowing 8-bit data in string functions  (RFD)
* 20 83/01/17  General clean up
* 20 83/01/19  Changed string terminator from $00 to $FF
*              to maintain I-Code compatability.         (RFD)
* 20 83/01/21  Fixed problem in USING with Real Zero.    (RFD)
* 20 83/01/24  Struct assignment of exaclty 256 crashed. (RFD)
* 20 83/01/24  Rename any Proc to number crashed system  (RFD)
* 20 83/01/25  Startup now clears all DP Globals.        (RFD)
* 20 83/01/25  IOBuff could overflow into system stack.  (RFD)
* 20 83/02/10  Added conditional asm for Tandy ^N.       (RFD)
* 20 83/02/10  Prevented DEBUG mode from recursive entry.(RFD)
* 20 83/02/07  Kept Opstack from going crazy, killing system
*               when exponentiation overflow occurred.   (LC)
* 20 83/02/15  Made aborted RunB return error to Shell.  (RFD)
* 20 83/02/17  Added Microware to copyright notice.      (RFD)
* 20 82/02/17  CTL-Q was ignored in asm subroutines.     (RFD)
* 20 83/02/17  RunB ON ERROR now intercepts CTL-C, CTL-Q.(RFD)
* 21 83/03/16  Fixed bug in TRON caused in edition 20.   (RFD)
* 22 83/04/27  Added conditionals for Basic09 minus trig.(RFD)
* 22 83/05/26  Changed message printed on tandy version. (MGH)
* 22 83/06/28  Added conditionals for dragon startup msg.(MGH)

Edition equ 22 Current edition

 ttl Runtime Stack Description
 pag
***************
* During I-Code interpretation, the Basic09 workspace
* is used more or less as described below:

*      ----------- <--(Y) initially
*      | params  |    absorbed after startup
*      |---------| <--(U) initially
*      |         | <--I.OPBG, I.OPSP
*      |         |    operand stack (expands downward)
*      |         |                        |
*      |  free   |                        V
*      |  space  |                        
*      |         |                        ^
*      |         |                        |
*      |         |    string stack (expands upward)
*      |---------| <--I.STBG, I.STSP
*      |         |
*      | program |
*      |---------|    I-Code procedure area
*      | program |    (expands upward, moving String
*      |---------|         Stack as necessary)
*      | program |
*      |         |
* 0500 |---------| <--G.PRCA
*      |directory|
* 0400 |---------| <--G.DIRA I-Code procedure directory
*      | hardware| <--(SP) Hardware stack ptr
*      |  stack  |
*      |         |  (output buffer is allowed to expand if required
* 0200 |---------|    as long as it stays below stack pointer)
*      |I/O buff |
* 0100 |---------| <--I.IOBG, I.IOPT
*      | globals |     direct page variables
* 0000 ----------- <--G.WSPA
* 
*      The total workspace size is kept in G.WSPS, while G.VARS 
* contains the free space available (I.OPBG - I.STBG usually).  The
* key places where variables are initialized are START (initialization),
* SETUP (resets Op stack between commands), and INTERP (moves Op stack 
* to top of workspace, and adjusts SP for I-Code interpretation.)

 pag
 use defs
BASEZERO mod 0000,B09NAM,PRGRM+OBJCT,REENT+0,START,$2000

O.COMAND fdb ENTRYPT offset of self
 fdb BYEBYE offset of Compile module
 fdb BYEBYE offset of Binder
 fdb BYEBYE offset of Statement Interpreter
 fdb BYEBYE offset of Expression Interpreter
 fdb BYEBYE offset of Conversion & I/O
 fdb 0 end of table

 ifne INCLUDED&EDITOR
B09NAM fcs "Basic09"
 else
B09NAM fcs "RunB"
 endc
 fcb Edition edition number
 fcb INCLUDED Conditional Assembly options

***************
* Basic09 was written by Microware Systems Corp.

*  The primary contributors to it's design and implementation
* were Ken Kaplan, Larry Crane, and Robert Doggett at Microware;
* and Terry Ritter at Motorola.

CPYRIT
 ifne Tandy-0
 ifne dragon-0
 fcb $0C Clear Screen
 fcc "            BASIC09"
 fcb V$LF
 fcc "COPYRIGHT 1980 BY MOTOROLA INC."
 fcb V$LF
 fcc "  AND MICROWARE SYSTEMS CORP."
 fcb V$LF
 fcc "   REPRODUCED UNDER LICENSE"
 fcb V$LF
 fcc "     TO DRAGON DATA LTD."
 fcb V$LF
 fcc "    ALL RIGHTS RESERVED."
 fcb V$LF+$80
 else
 fcb $0C Clear Screen
 fcc "            BASIC09"
 fcb V$LF
 fcc "      RS VERSION 01.00.00"
 fcb V$LF
 fcc "COPYRIGHT 1980 BY MOTOROLA INC."
 fcb V$LF
 fcc "  AND MICROWARE SYSTEMS CORP."
 fcb V$LF
 fcc "   REPRODUCED UNDER LICENSE"
 fcb V$LF
 fcc "       TO TANDY CORP."
 fcb V$LF
 fcc "    ALL RIGHTS RESERVED."
 fcb V$LF+$80
 endc
 else
 fcc "Copyright 1980 by Motorola and Microware."
 fcb V$LF
 fcc "Reproduced under license"
 endc
 ifeq INCLUDED&MATHPAK
 fcb V$LF
 fcc "(no trig functions)"
 fcb V$LF+$80
 endc

***************

 ttl External Linkage Section
 pag
 use LINKAGE

***************
* Global Entry Points

CMDENT equ *
 fdb DIRLNK-CMDENT Directory search & link if not found
 fdb PRTERR-CMDENT Print errmsg & return (J$erex)
 fdb SETEXT-CMDENT Set exit trap
 fdb EXIT-CMDENT   exit via exit trap
 fdb SUBST-CMDENT  Substring search
 fdb KILLEX-CMDENT Kill external procedure
 fdb BYEBYE-CMDENT Exit Basic09  give up workspace
 fdb KILALL-CMDENT Kill all external procedures
 fdb NXTSTM-CMDENT Skip to next (logical) stmt beginning
 ifne INCLUDED&EDITOR
 fdb LKTOKE-CMDENT Lookup token
 fdb REPLAC-CMDENT Replace icode
 fdb LSTBLN-CMDENT List a bound icode line
 fdb DEBUG-CMDENT  Enter debug mode
 fdb TRCEXP-CMDENT Trace expression
 fdb PRTEXP-CMDENT Print (opstack) expression
 endc

***************
* External Subroutine References

J$SRCH jsr M.COMPIL
 fcb X$SRCH Table search subroutine
J$NAME jsr M.COMPIL
 fcb X$NAME Look for a name subroutine
J$CPRM jsr M.COMPIL
 fcb X$CPRM Compile parameter list
J$BPRM jsr M.BINDER
 fcb X$BPRM Bind parameters
J$INTI jsr M.STMTS
 fcb X$INTI  initialize interpreter
J$IPRM jsr M.STMTS
 fcb X$IPRM  interpret parameters
J$INTX jsr M.STMTS
 fcb X$INTX  Execute Interpreter
J$CVIO jsr M.CNVIO
 fcb X$CVIO  call cnvio

 ifne INCLUDED&EDITOR
J$CMPL jsr M.COMPIL
 fcb X$CMPL Line compiler
J$MVDN jsr M.COMPIL
 fcb X$MVDN Block move down subroutine
J$BIND jsr M.BINDER
 fcb X$BIND Bind procedure
J$PHEX jsr M.BINDER
 fcb X$PHEX Print hex number
J$BSTM jsr M.BINDER
 fcb X$BSTM Bind statement
J$TRON jsr M.STMTS
 fcb X$TRON  turn on trace mode
J$TROF jsr M.STMTS
 fcb X$TROF  turn off trace mode
J$ISTM jsr M.STMTS
 fcb X$ISTM  interpret single statement
J$ASNM jsr M.CNVIO
 fcb X$ASNM  cnv ASCII > numeric

 ttl KEYWORD Table
 pag
***************
* Compiler equates

STMBEG equ 1
RESRVD equ 3
FNCREF equ 4
OPRTR equ 5

***************
* Keyword Table

 ifeq INCLUDED&MATHPAK
* If MATHPAK is not included in BASIC09, the following
* statements/functions are NOT recognized:

DEG equ *
RAD equ *
PI equ *
SIN equ *
COS equ *
TAN equ *
ASN equ *
ACS equ *
ATN equ *
EXP equ *
LOG equ *
LOG10 equ *
 fcs "???"
 fdb 102 Number of entries, when trig functions aren't used
 fcb 2

 else
 fdb 114 Number of entries in keytab
 fcb 2 number of skip bytes per entry
 endc

KEYTAB equ *
 fcb T.PRAM,STMBEG
PARAM fcs "PARAM"
 fcb T.TYPE,STMBEG
TYP fcs "TYPE"
 fcb T.DIM,STMBEG
DIM fcs "DIM"
 fcb T.DATA,STMBEG
DATAA fcs "DATA"
 fcb T.STOP,STMBEG
STOP fcs "STOP"
 fcb T.BYE,STMBEG
BYE fcs "BYE"
 fcb T.TRON,STMBEG
TRON fcs "TRON"
 fcb T.TROF,STMBEG
TROF fcs "TROFF"
 fcb T.PAUS,STMBEG
PAUSE fcs "PAUSE"

 ifne INCLUDED&MATHPAK
 fcb T.DEG,STMBEG
DEG fcs "DEG"
 fcb T.RAD,STMBEG
RAD fcs "RAD"
 endc

 fcb T.RETN,STMBEG
RETURN fcs "RETURN"
 fcb T.LET,STMBEG
LET fcs "LET"
 fcb T.POKE,STMBEG
POKE fcs "POKE"
 fcb T.IF,STMBEG
IF fcs "IF"
 fcb T.ELSE,STMBEG
ELSE fcs "ELSE"
 fcb T.EIF,STMBEG
ENDIF fcs "ENDIF"
 fcb T.FOR,STMBEG
FOR fcs "FOR"
 fcb T.NEXT,STMBEG
NEXT fcs "NEXT"
 fcb T.WHIL,STMBEG
WHILE fcs "WHILE"
 fcb T.EWHL,STMBEG
ENDWHL fcs "ENDWHILE"
 fcb T.REPT,STMBEG
REPEAT fcs "REPEAT"
 fcb T.UNTL,STMBEG
UNTIL fcs "UNTIL"
 fcb T.LOOP,STMBEG
LOOP fcs "LOOP"
 fcb T.ELOP,STMBEG
ENDLUP fcs "ENDLOOP"
 fcb T.EXIF,STMBEG
EXITIF fcs "EXITIF"
 fcb T.EEXT,STMBEG
ENDEXT fcs "ENDEXIT"
 fcb T.ON,STMBEG
ON fcs "ON"
 fcb T.EROR,STMBEG
ERROR fcs "ERROR"
 fcb T.GOTO,STMBEG
GOTO fcs "GOTO"
 fcb T.GOSB,STMBEG
GOSUB fcs "GOSUB"
 fcb T.RUN,STMBEG
RUN fcs "RUN"
 fcb T.KILL,STMBEG
KILL fcs "KILL"
 fcb T.INPT,STMBEG
INPUT fcs "INPUT"
 fcb T.PRNT,STMBEG
PRINT fcs "PRINT"
 fcb T.CHD,STMBEG
CHD fcs "CHD"
 fcb T.CHX,STMBEG
CHX fcs "CHX"
 fcb T.CRET,STMBEG
CREATE fcs "CREATE"
 fcb T.OPEN,STMBEG
OPEN fcs "OPEN"
 fcb T.SEEK,STMBEG
SEEK fcs "SEEK"
 fcb T.READ,STMBEG
READ fcs "READ"
 fcb T.WRIT,STMBEG
WRITE fcs "WRITE"
 fcb T.GET,STMBEG
GET fcs "GET"
 fcb T.PUT,STMBEG
PUT fcs "PUT"
 fcb T.CLOS,STMBEG
CLOSE fcs "CLOSE"
 fcb T.REST,STMBEG
RESTOR fcs "RESTORE"
 fcb T.DELT,STMBEG
DELETE fcs "DELETE"
 fcb T.CHIN,STMBEG
CHAIN fcs "CHAIN"
 fcb T.SYS,STMBEG
SHELL fcs "SHELL"
 fcb T.BAS0,STMBEG
BASE fcs "BASE"
 fcb T.REM1,STMBEG
REM fcs "REM"
 fcb T.END,STMBEG
END fcs "END"
 fcb T.BYTE,RESRVD
BYTE fcs "BYTE"
 fcb T.INT,RESRVD
INTGER fcs "INTEGER"
 fcb T.REAL,RESRVD
REAL fcs "REAL"
 fcb T.BOOL,RESRVD
BOOL fcs "BOOLEAN"
 fcb T.STR,RESRVD
STRING fcs "STRING"
 fcb T.THEN,RESRVD
THEN fcs "THEN"
 fcb T.TO,RESRVD
TO fcs "TO"
 fcb T.STEP,RESRVD
STEP fcs "STEP"
 fcb T.DO,RESRVD
DO fcs "DO"
 fcb T.USNG,RESRVD
USING fcs "USING"
 fcb T.ERRL,RESRVD
 fcs "PROCEDURE"
 fcb T.ADDR,FNCREF
ADDR fcs "ADDR"
 fcb T.LENG,FNCREF
LENG fcs "SIZE"
 fcb T.POS,FNCREF
POS fcs "POS"
 fcb T.ERR,FNCREF
ERRR fcs "ERR"
 fcb T.MOD,FNCREF
MOD fcs "MOD"
 fcb T.RND,FNCREF
RND fcs "RND"
 fcb T.SUBS,FNCREF
SUBSTR fcs "SUBSTR"

 ifne INCLUDED&MATHPAK
 fcb T.PI,FNCREF
PI fcs "PI"
 fcb T.SIN,FNCREF
SIN fcs "SIN"
 fcb T.COS,FNCREF
COS fcs "COS"
 fcb T.TAN,FNCREF
TAN fcs "TAN"
 fcb T.ASN,FNCREF
ASN fcs "ASN"
 fcb T.ACS,FNCREF
ACS fcs "ACS"
 fcb T.ATN,FNCREF
ATN fcs "ATN"
 fcb T.EXP,FNCREF
EXP fcs "EXP"
 fcb T.LN,FNCREF
LOG fcs "LOG"
 fcb T.LOG,FNCREF
LOG10 fcs "LOG10"
 endc

 fcb T.SGN,FNCREF
SGN fcs "SGN"
 fcb T.ABS,FNCREF
ABS fcs "ABS"
 fcb T.SQR,FNCREF
SQRT fcs "SQRT"
 fcb T.SQR,FNCREF
SQR fcs "SQR"
 fcb T.INTF,FNCREF
INTF fcs "INT"
 fcb T.FIX,FNCREF
FIX fcs "FIX"
 fcb T.FLOT,FNCREF
FLOAT fcs "FLOAT"
 fcb T.SQ,FNCREF
SQ fcs "SQ"
 fcb T.PEEK,FNCREF
PEEK fcs "PEEK"
 fcb T.NNOT,FNCREF
NUMNOT fcs "LNOT"
 fcb T.VAL,FNCREF
VAL fcs "VAL"
 fcb T.LEN,FNCREF
LEN fcs "LEN"
 fcb T.ASC,FNCREF
ASC fcs "ASC"
 fcb T.NAND,FNCREF
NUMAND fcs "LAND"
 fcb T.NOR,FNCREF
NUMOR fcs "LOR"
 fcb T.NXOR,FNCREF
NUMXOR fcs "LXOR"
 fcb T.TRUE,FNCREF
TRUELit fcs "TRUE"
 fcb T.FALS,FNCREF
FALSELit fcs "FALSE"
 fcb T.EOF,FNCREF
EOF fcs "EOF"
 fcb T.TRIM,FNCREF
TRIM$ fcs "TRIM$"
 fcb T.MID,FNCREF
MID$ fcs "MID$"
 fcb T.LEFT,FNCREF
LEFT$ fcs "LEFT$"
 fcb T.RGHT,FNCREF
RIGHT$ fcs "RIGHT$"
 fcb T.CHR,FNCREF
CHR$ fcs "CHR$"
 fcb T.STRF,FNCREF
STR$ fcs "STR$"
 fcb T.DATE,FNCREF
DATE$ fcs "DATE$"
 fcb T.TAB,FNCREF
TAB fcs "TAB"
 fcb T.NOT,OPRTR
NOT fcs "NOT"
 fcb T.AND,OPRTR
AND fcs "AND"
 fcb T.OR,OPRTR
OR fcs "OR"
 fcb T.XOR,OPRTR
XOR fcs "XOR"
 fcb T.UPDT,RESRVD
UPDATE fcs "UPDATE"
 fcb T.EXEC,RESRVD
EXEC fcs "EXEC"
 fcb T.DIR,RESRVD
DIRECT fcs "DIR"

 ttl DECOMPILE Table
 pag
Z$GARB equ %10000000 Garbage element (fix,float,addr2)

Z$STR equ %00000000 Keyword str ptr
Z$SUB equ %00100000 Special subroutine handler
Z$1CH equ %01000000 One character literal
Z$2CH equ %01000000 Two character literal
Z$STSK equ %01100000 String+2 byte offset

Z$BCTL equ %00000001 Begin control struct (indent)
Z$ECTL equ %00000010 End control struct (un-indent)
Z$CCTL equ %00000011 Continued ctl strct (else)

Z$FREF equ %00010000 Token is a function reference

Z$OPTR equ %00001000 Token is an operator
Z$1PRC equ %00000001 1 precedence
Z$2PRC equ %00000010 2
Z$3PRC equ %00000011 3
Z$4PRC equ %00000100 4
Z$5PRC equ %00000101 5
Z$6PRC equ %00000110 6
Z$NULL equ %11111111 Null operator

Z$LIT equ %00000100 Token is a literal
Z$2BYT equ %00000010 2 byte literal (byte)
Z$3BYT equ %00000011 3 byte literal (integer)
Z$6BYT equ %00000000 6 byte literal (real)

Z$1DIM equ %00000001 1 dim or arg
Z$2DIM equ %00000010 2 dims or args
Z$3DIM equ %00000011 3 dims or args
 pag
* Decompiler Token Lookup Table
*
DCMTBL equ *
 fcb Z$1CH Global
 fdb 0
 fcb Z$STR
 fdb PARAM-*
 fcb Z$STR
 fdb TYP-*
 fcb Z$STR
 fdb DIM-*
 fcb Z$STR
 fdb DATAA-*
 fcb Z$STR
 fdb STOP-*
 fcb Z$STR
 fdb BYE-*
 fcb Z$STR
 fdb TRON-*
 fcb Z$STR
 fdb TROF-*
 fcb Z$STR
 fdb PAUSE-*
 fcb Z$STR
 fdb DEG-*
 fcb Z$STR
 fdb RAD-*
 fcb Z$STR
 fdb RETURN-*
 fcb Z$STR
 fdb LET-*
 fcb Z$1CH
 fdb 0 Complex assignment
 fcb Z$STR
 fdb POKE-*
 fcb Z$STR
 fdb IF-*
 fcb Z$STSK+Z$CCTL
 fdb ELSE-*
 fcb Z$STR+Z$ECTL
 fdb ENDIF-*
 fcb Z$STR+Z$BCTL
 fdb FOR-*
 fcb Z$SUB+Z$ECTL
 fdb DCNEXT-*
 fcb Z$STR+Z$BCTL
 fdb WHILE-*
 fcb Z$STSK+Z$ECTL
 fdb ENDWHL-*
 fcb Z$STR+Z$BCTL
 fdb REPEAT-*
 fcb Z$STR+Z$ECTL
 fdb UNTIL-*
 fcb Z$STR+Z$BCTL
 fdb LOOP-*
 fcb Z$STSK+Z$ECTL
 fdb ENDLUP-*
 fcb Z$STR+Z$ECTL
 fdb EXITIF-*
 fcb Z$STSK+Z$CCTL
 fdb ENDEXT-*
 fcb Z$STR
 fdb ON-*
 fcb Z$STR
 fdb ERROR-*
 fcb Z$SUB
 fdb DCGOTO-*
 fcb Z$SUB
 fdb DCGOTO-* (dup)
 fcb Z$SUB
 fdb DCGOSB-*
 fcb Z$SUB
 fdb DCGOSB-* (dup)
 fcb Z$SUB
 fdb DCRUN-*
 fcb Z$STR
 fdb KILL-*
 fcb Z$STR
 fdb INPUT-*
 fcb Z$STR
 fdb PRINT-*
 fcb Z$STR
 fdb CHD-*
 fcb Z$STR
 fdb CHX-*
 fcb Z$STR
 fdb CREATE-*
 fcb Z$STR
 fdb OPEN-*
 fcb Z$STR
 fdb SEEK-*
 fcb Z$STR
 fdb READ-*
 fcb Z$STR
 fdb WRITE-*
 fcb Z$STR
 fdb GET-*
 fcb Z$STR
 fdb PUT-*
 fcb Z$STR
 fdb CLOSE-*
 fcb Z$STR
 fdb RESTOR-*
 fcb Z$STR
 fdb DELETE-*
 fcb Z$STR
 fdb CHAIN-*
 fcb Z$STR
 fdb SHELL-*
 fcb Z$SUB
 fdb DCBASE-* Base 0
 fcb Z$SUB
 fdb DCBASE-* Base 1
 fcb Z$SUB
 fdb DCREM-* Rem
 fcb Z$SUB
 fdb DCSREM-* Rem2 '(*'
 fcb Z$STR
 fdb END-*
 fcb Z$SUB
 fdb DCLREF-* Line reference
 fcb Z$SUB
 fdb DCLREF-* Line reference (dup)
 fcb Z$1CH
 fdb 0 Direct execution
 fcb Z$SUB
 fdb DCERLN-* Error line
 fcb Z$2CH
 fdb $205C T.bksl
 fcb Z$SUB
 fdb DCEOL-* Eol carriage return

* Secondary Keyword/Misc. Symbol Tokens

 fcb Z$STR+Z$FREF
 fdb BYTE-* (Z$FREF inhibits spaces around literals)
 fcb Z$STR+Z$FREF
 fdb INTGER-*
 fcb Z$STR+Z$FREF
 fdb REAL-*
 fcb Z$STR+Z$FREF
 fdb BOOL-*
 fcb Z$STR+Z$FREF
 fdb STRING-*
 fcb Z$SUB
 fdb DCTHEN-*
 fcb Z$STSK
 fdb TO-*
 fcb Z$STSK
 fdb STEP-*
 fcb Z$STR
 fdb DO-*
 fcb Z$STR
 fdb USING-*
 fcb Z$SUB
 fdb DCMODE-*
 fcb Z$1CH
 fdb $2C00 Coma ','
 fcb Z$1CH
 fdb ':*256 Col ':'
 fcb Z$1CH
 fdb $2800 Lpar '('
 fcb Z$1CH
 fdb $2900 Rpar ')'
 fcb Z$1CH
 fdb '[*256 Lbkt '['
 fcb Z$1CH
 fdb ']*256 Rbkt ']'
 fcb Z$2CH
 fdb $3B20 Scol semicolon
 fcb Z$2CH
 fdb $3A3D  asgn ':='
 fcb Z$1CH
 fdb '=*256 Asg1 '='
 fcb Z$1CH
 fdb '#*256 Cnum '#'
 fcb Z$SUB
 fdb SK2-* Lbne invisible goto

* Operand Tokens

 fcb Z$SUB
 fdb DCVREF-* Simple byte variable
 fcb Z$SUB
 fdb DCVREF-* Simple integer variable
 fcb Z$SUB
 fdb DCVREF-* Simple real variable
 fcb Z$SUB
 fdb DCVREF-* Simple boolean variable
 fcb Z$SUB
 fdb DCVREF-* Simple string variable
 fcb Z$SUB
 fdb DCVREF-* Variable ref.
 fcb Z$SUB+Z$1DIM
 fdb DCVREF-* One dim var.
 fcb Z$SUB+Z$2DIM
 fdb DCVREF-* Two dim var.
 fcb Z$SUB+Z$3DIM
 fdb DCVREF-* Three dim var.
 fcb Z$SUB
 fdb DCRREF-* Field ref.
 fcb Z$SUB+Z$1DIM
 fdb DCRREF-* One dim field ref.
 fcb Z$SUB+Z$2DIM
 fdb DCRREF-* Two dim field ref.
 fcb Z$SUB+Z$3DIM
 fdb DCRREF-* Three dim field ref.
 fcb Z$SUB+Z$LIT+Z$2BYT
 fdb DBYTLT-* Byte lit.
 fcb Z$SUB+Z$LIT+Z$3BYT
 fdb CNVINT-* Integer lit.
 fcb Z$SUB+Z$LIT+Z$6BYT
 fdb DRLLIT-* Real lit.
 fcb Z$SUB+Z$LIT
 fdb DCSTLT-* String lit.
 fcb Z$SUB+Z$LIT+Z$3BYT
 fdb DHXLIT-* Hex lit.
 fcb Z$STR+Z$FREF+Z$1DIM
 fdb ADDR-*
 fcb Z$GARB
 fdb 0 Prefix addr
 fcb Z$STR+Z$FREF+Z$1DIM
 fdb LENG-*
 fcb Z$GARB
 fdb 0 Prefix leng
 fcb Z$STR+Z$FREF
 fdb POS-*
 fcb Z$STR+Z$FREF
 fdb ERRR-*
 fcb Z$STR+Z$FREF+Z$2DIM
 fdb MOD-*
 fcb Z$STR+Z$FREF+Z$2DIM
 fdb MOD-* (dup)
 fcb Z$STR+Z$FREF+Z$1DIM
 fdb RND-*
 fcb Z$STR+Z$FREF
 fdb PI-*
 fcb Z$STR+Z$FREF+Z$2DIM
 fdb SUBSTR-*
 fcb Z$STR+Z$FREF+Z$1DIM
 fdb SGN-*
 fcb Z$STR+Z$FREF+Z$1DIM
 fdb SGN-* (dup)
 fcb Z$STR+Z$FREF+Z$1DIM
 fdb SIN-*
 fcb Z$STR+Z$FREF+Z$1DIM
 fdb COS-*
 fcb Z$STR+Z$FREF+Z$1DIM
 fdb TAN-*
 fcb Z$STR+Z$FREF+Z$1DIM
 fdb ASN-*
 fcb Z$STR+Z$FREF+Z$1DIM
 fdb ACS-*
 fcb Z$STR+Z$FREF+Z$1DIM
 fdb ATN-*
 fcb Z$STR+Z$FREF+Z$1DIM
 fdb EXP-*
 fcb Z$STR+Z$FREF+Z$1DIM
 fdb ABS-*
 fcb Z$STR+Z$FREF+Z$1DIM
 fdb ABS-* (dup)
 fcb Z$STR+Z$FREF+Z$1DIM
 fdb LOG-*
 fcb Z$STR+Z$FREF+Z$1DIM
 fdb LOG10-*
 fcb Z$STR+Z$FREF+Z$1DIM
 fdb SQRT-*
 fcb Z$STR+Z$FREF+Z$1DIM
 fdb SQRT-* (dup)
 fcb Z$STR+Z$FREF+Z$1DIM
 fdb INTF-*
 fcb Z$STR+Z$FREF+Z$1DIM
 fdb INTF-* (dup)
 fcb Z$STR+Z$FREF+Z$1DIM
 fdb FIX-*
 fcb Z$STR+Z$FREF+Z$1DIM
 fdb FIX-* (dup)
 fcb Z$STR+Z$FREF+Z$1DIM
 fdb FLOAT-*
 fcb Z$STR+Z$FREF+Z$1DIM
 fdb FLOAT-* (dup)
 fcb Z$STR+Z$FREF+Z$1DIM
 fdb SQ-*
 fcb Z$STR+Z$FREF+Z$1DIM
 fdb SQ-* (dup)
 fcb Z$STR+Z$FREF+Z$1DIM
 fdb PEEK-*
 fcb Z$STR+Z$FREF+Z$1DIM
 fdb NUMNOT-*
 fcb Z$STR+Z$FREF+Z$1DIM
 fdb VAL-*
 fcb Z$STR+Z$FREF+Z$1DIM
 fdb LEN-*
 fcb Z$STR+Z$FREF+Z$1DIM
 fdb ASC-*
 fcb Z$STR+Z$FREF+Z$2DIM
 fdb NUMAND-*
 fcb Z$STR+Z$FREF+Z$2DIM
 fdb NUMOR-*
 fcb Z$STR+Z$FREF+Z$2DIM
 fdb NUMXOR-*
 fcb Z$STR+Z$FREF
 fdb TRUELit-*
 fcb Z$STR+Z$FREF
 fdb FALSELit-*
 fcb Z$STR+Z$FREF+Z$1DIM
 fdb EOF-*
 fcb Z$STR+Z$FREF+Z$1DIM
 fdb TRIM$-*
 fcb Z$STR+Z$FREF+Z$3DIM
 fdb MID$-*
 fcb Z$STR+Z$FREF+Z$2DIM
 fdb LEFT$-*
 fcb Z$STR+Z$FREF+Z$2DIM
 fdb RIGHT$-*
 fcb Z$STR+Z$FREF+Z$1DIM
 fdb CHR$-*
 fcb Z$STR+Z$FREF+Z$1DIM
 fdb STR$-*
 fcb Z$STR+Z$FREF+Z$1DIM
 fdb STR$-* (dup)
 fcb Z$STR+Z$FREF
 fdb DATE$-*
 fcb Z$STR+Z$FREF+Z$1DIM
 fdb TAB-*
 fcb Z$GARB
 fdb 0 Fix1
 fcb Z$GARB
 fdb 0 Fix2
 fcb Z$GARB
 fdb 0 Fix3
 fcb Z$GARB
 fdb 0 Fl1
 fcb Z$GARB
 fdb 0 Flt2

* Operator Tokens

 fcb Z$STR+Z$FREF+Z$1DIM
 fdb NOT-*
 fcb Z$1CH+Z$FREF+Z$1DIM
 fdb '-*256 '-' (monadic)
 fcb Z$1CH+Z$FREF+Z$1DIM
 fdb '-*256 '-' (monadic) (dup)
 fcb Z$STR+Z$OPTR+Z$2PRC
 fdb AND-*
 fcb Z$STR+Z$OPTR+Z$1PRC
 fdb OR-*
 fcb Z$STR+Z$OPTR+Z$1PRC
 fdb XOR-*
ARROW equ *+1
 fcb Z$1CH+Z$OPTR+Z$3PRC
 fdb '>*256 Gt '>'
 fcb Z$1CH+Z$OPTR+Z$3PRC
 fdb '>*256 Gt '>' (dup)
 fcb Z$1CH+Z$OPTR+Z$3PRC
 fdb '>*256 Gt '>' (dup)
 fcb Z$1CH+Z$OPTR+Z$3PRC
 fdb '<*256 LT '<'
 fcb Z$1CH+Z$OPTR+Z$3PRC
 fdb '<*256 LT '<' (dup)
 fcb Z$1CH+Z$OPTR+Z$3PRC
 fdb '<*256 LT '<' (dup)
 fcb Z$2CH+Z$OPTR+Z$3PRC
 fdb '<*256+'> NE '<>' or '><'
 fcb Z$2CH+Z$OPTR+Z$3PRC
 fdb '<*256+'> NE '<>' or '><' (dup)
 fcb Z$2CH+Z$OPTR+Z$3PRC
 fdb '<*256+'> NE '<>' or '><' (dup)
 fcb Z$2CH+Z$OPTR+Z$3PRC
 fdb '<*256+'> NE '<>' or '><' (dup)
 fcb Z$1CH+Z$OPTR+Z$3PRC
 fdb '=*256 Eq '='
 fcb Z$1CH+Z$OPTR+Z$3PRC
 fdb '=*256 Eq '=' (dup)
 fcb Z$1CH+Z$OPTR+Z$3PRC
 fdb '=*256 Eq '=' (dup)
 fcb Z$1CH+Z$OPTR+Z$3PRC
 fdb '=*256 Eq '=' (dup)
 fcb Z$2CH+Z$OPTR+Z$3PRC
 fdb '>*256+'= GE '>=' or '=>'
 fcb Z$2CH+Z$OPTR+Z$3PRC
 fdb '>*256+'= GE '>=' or '=>' (dup)
 fcb Z$2CH+Z$OPTR+Z$3PRC
 fdb '>*256+'= GE '>=' or '=>' (dup)
 fcb Z$2CH+Z$OPTR+Z$3PRC
 fdb '<*256+'= LE '<=' or '=<'
 fcb Z$2CH+Z$OPTR+Z$3PRC
 fdb '<*256+'= LE '<=' or '=<' (dup)
 fcb Z$2CH+Z$OPTR+Z$3PRC
 fdb '<*256+'= LE '<=' or '=<' (dup)
 fcb Z$1CH+Z$OPTR+Z$4PRC
 fdb '+*256 Plus '+'
 fcb Z$1CH+Z$OPTR+Z$4PRC
 fdb '+*256 Plus '+' (dup)
 fcb Z$1CH+Z$OPTR+Z$4PRC
 fdb '+*256 Plus '+' (dup)
 fcb Z$1CH+Z$OPTR+Z$4PRC
 fdb '-*256 Mins '-' (dyadic)
 fcb Z$1CH+Z$OPTR+Z$4PRC
 fdb '-*256 Mins '-' (dyadic) (dup)
 fcb Z$1CH+Z$OPTR+Z$5PRC
 fdb '**256 Mul '*'
 fcb Z$1CH+Z$OPTR+Z$5PRC
 fdb '**256 Mul '*' (dup)
 fcb Z$1CH+Z$OPTR+Z$5PRC
 fdb '/*256 Div '/'
 fcb Z$1CH+Z$OPTR+Z$5PRC
 fdb '/*256 Div '/' (dup)
 fcb Z$1CH+Z$OPTR+Z$6PRC
 fdb '^*256 Powr '^'
 fcb Z$2CH+Z$OPTR+Z$6PRC
 fdb $2A2A Powr '**'

* Address Reference Tokens

 fcb Z$SUB
 fdb DCVREF-* Address ref
 fcb Z$SUB+Z$1DIM
 fdb DCVREF-* One dim address
 fcb Z$SUB+Z$2DIM
 fdb DCVREF-* Two dim address
 fcb Z$SUB+Z$3DIM
 fdb DCVREF-* Three dim address
 fcb Z$SUB
 fdb DCRREF-* Field address ref
 fcb Z$SUB+Z$1DIM
 fdb DCRREF-* One dim field address
 fcb Z$SUB+Z$2DIM
 fdb DCRREF-* Two dim field address
 fcb Z$SUB+Z$3DIM
 fdb DCRREF-* Three dim field addr

 ttl SYSTEM Command verb tables
 pag

***************
* Basic09 System Commands
*
 fdb 2 number of non-alphabetic entries
 fcb 2 number of skip bytes per entry
CMDVRB equ *
 fdb INVOKE-*
 fcs "$"
 fdb DIR05-*
 fcb V$CR+$80

 fdb 14 number of alphabetic entries
 fcb 2 number of skip bytes per entry
 fdb BYEBYE-*
 fcs "BYE"
 fdb DIR-*
 fcs "DIR"
 fdb EDIT-*
 fcs "EDIT"
 fdb EDIT-*
 fcs "E"
 fdb LIST-*
 fcs "LIST"
 fdb INTERP-*
 fcs "RUN"
 fdb KILLER-*
 fcs "KILL"
 fdb SAVE-*
 fcs "SAVE"
 fdb LOAD-*
 fcs "LOAD"
 fdb RENAME-*
 fcs "RENAME"
 fdb DUMP-*
 fcs "PACK"
 fdb CHGMEM-*
 fcs "MEM"
 fdb CHDDIR-*
 fcs "CHD"
 fdb CHXDIR-*
 fcs "CHX"

***************
* Debug Mode Commands
*
 fdb 2 number of debug symbol commands
 fcb 2 number of skip bytes per entry
DBGVRB equ *
 fdb INVOKE-*
 fcs "$"
 fdb STEP0-*
 fcb V$CR+$80

 fdb 14 number of alphabetic debug commands
 fcb 2 number of skip bytes per entry
 fdb CONTIN-*
 fcs "CONT"
 fdb DIR-*
 fcs "DIR"
 fdb HALT-*
 fcs "Q"
 fdb LSTBND-*
 fcs "LIST"
 fdb DIREXQ-*
 fcs "PRINT"
 fdb STATE-*
 fcs "STATE"
 fdb DIREXQ-*
 fcs "TRON"
 fdb DIREXQ-*
 fcs "TROFF"
 fdb DIREXQ-*
 fcs "DEG"
 fdb DIREXQ-*
 fcs "RAD"
 fdb DIREXQ-*
 fcs "LET"
 fdb STEPM-*
 fcs "STEP"
 fdb BREAK-*
 fcs "BREAK"

***************
* Editor Commands
*
 fdb 8 number of symbol entries in editor command tbl
 fcb 2 number of skip bytes per entry
EDTVRB fdb ELIST-*
 fcs "L"
 fdb ELIST-*
 fcs "l"
 fdb EDELET-*
 fcs "D"
 fdb EDELET-*
 fcs "d"
 fdb EMOVE-*
 fcs "+" foreward
 fdb EMOVE-*
 fcs "-" backward
 fdb EMOVE-*
 fcb V$CR+$80 Move one
 fdb EINSRT-*
 fcs " " space: insert

 fdb 4 number of alphabetic editor commands
 fcb 2 number of skip bytes per entry
 fdb SEARCH-*
 fcs "S"
 fdb CHANGE-*
 fcs "C"
 fdb ERESEQ-*
 fcs "R"
 fdb EQUIT-*
 fcs "Q"
 endc

 ttl CHARACTER String constants
 pag
READY equ *
 ifne Tandy-0
 fcb C$Alpha change to alpha screen
 endc
 fcs "Ready"
WHAT fcs "What?"
FREE fcs " free"
DEFNAM fcs "Program"
PRCEDR fcs "PROCEDURE"
CR.RET fcb V$CR
DIRHDR fcb $A
 fcs "  Name      Proc-Size  Data-Size"

OVWRIT fcc "Rewrite?: "
OVWLEN equ *-OVWRIT
RNGERR fcc "RANGE"
 fcb $87
DBGMSG equ *
 ifne Tandy-0
 fcb C$Alpha change to alpha screen
 endc
 fcs "BREAK: "
CALLBY fcs "called by"
OKMSG fcs "ok"
DBGPMT fcs "D:"
EDTPMT fcs "E:"
CMDPMT fcs "B:"
NOTFND fcs "can't find:"

 ttl Basic09 Command module
 pag
***************
* Intercept Vector
*   System Passes Non-Fatal Signals Here

INTCPT lda R$DP,S
 tfr A,DP reset Basic09's direct page
 stb G.SIGN Save signal
 ifne H6309
 oim #$80,I.RUNM Set high bit (flag signal was received)
 else
 lsl I.RUNM
 coma set Break flag
 ror I.RUNM
 endc
 rti

***************
* Basic09 Entry Point

 ifne H6309
START tfr U,D Save start of data mem into D
 ldw #$100 Size of DP area to clear
 clr ,-S Clear byte on stack
 tfm S,U+ Clear out DP
 else
START pshs U bottom of workspace
 leau $100,U
 clra
 clrb
START0 std ,--U clear DP Globals
 cmpu  ,S
 bhi START0
 puls D bottom of workspace
 endc
 leau  ,X top of workspace (below params)
 std G.WSPA
 inca
 sta SMASH Set binder for non-compil mode (non-zero)
 std I.IOBG
 std I.IOPT
 adda #2
 std I.OPBG Set initial opstack
 std I.OPSP
 inca
 tfr D,S
 std G.DIRA
 inca
 std G.PRCA
 std I.STBG
 tfr U,D
 subd G.WSPA
 std G.WSPS
 clra
 ldb #1
 std I.IPTH Stdin=0, stdout=1 (interpreter)
 sta BASINP Stdin=0, stdout=2 (comand)
***************
* Kluge to prevent chain from eating paths
 lda #3
START05 OS9 I$Close close all non-std paths
 inca
 cmpa #NumPaths
 blo START05
***************
 lda #CMDOUT Save std error path
 OS9 I$Dup
 sta BASOUT All command output through path #2
 clr G.SIGN No signals recieved
 pshs X Save command line ptr
 leax <INTCPT,PCR Set up intercept vector
 OS9 F$ICPT
 ldx G.PRCA
 ifne H6309
 clrd
 else
 clra
 clrb
 endc
START1 std ,--X Clear out directory
 cmpx G.DIRA
 bhi START1

***************
* Build Inter-Module Linkages

 leax BASEZERO,PCR get module load addr
 ifne H6309
 tfr x,w Move it to W
 else
 pshs x save BASE 0
 endc
 ldx G.WSPA
 leax M.COMAND,x get addr of Jump tbl
 leay O.COMAND,PCR get offset table addr
START15 lda #$7E JMP Opcode
 sta ,X+
 ldd ,Y++ get offset of module
 ifne H6309
 addr w,d make absolute
 else
 addd  ,S make absolute
 endc
 std ,X++ fill in jump table
 ldd  ,Y End of table?
 bne START15 ..No; no; repeat
 ifne H6309
 else
 leas 2,S discard scratch
 endc
* end of Inter module linkages

 lbsr J$INTI Initialize interpreter
 puls Y get initial shell params

 ifne INCLUDED&EDITOR
 leax KEYTAB,PCR
 stx KEYWORDS save Keyword Table addr for compiler
 ldb  ,Y
 cmpb #V$CR End of command line?
 beq COMAND ..yes; enter Basic09 command
 leax <START2,PCR
 pshs y Save param ptr
 bsr SETUP1
 lbsr DIRLNK try to find packed module
 bcc EXIT ..If found; don't do auto-load
 lbsr LOAD Auto-load file if specified
 bra EXIT cleanup stack

START2 puls Y get shell param ptr
 endc

 bsr SETUP
 ldx G.DIRA
 ldd  ,X get first procedure loaded
 std I.APRC make it ACTIVE
 lbsr INTERP (will exit to COMAN0)

***************
* Subroutine SETUP
*   Set up for command invocation

SETUP leax <COMAN0,PCR
SETUP1 puls U get return addr
 bsr SETEXT Set exit address
 pshs U Restore return addr
 clr I.RUNM
 ldd G.WSPA
 addd G.WSPS
 subd G.PRCA
 subd G.PRCS
 std G.VARS Reset free space size
 leau 2,S Set up default opstack ptr in (U)
 stu I.OPBG
 stu I.OPSP
 leas -254,S Chop out opstack space
 jmp [-2,U] Return

***************
* Subroutine EXIT

EXIT lds SP.ERR restore stack ptr
 puls D pop previous exit trap
 std SP.ERR reset it
EXNLIN lbra NEWLIN clear I/O buffer; return

***************
* Subroutine SETEXT
*   Set (Error) exit trap

* Passed: (X)=exit addr
* Destroys: D,Sp

SETEXT ldd SP.ERR previous exit ptr
 pshs D
 sts SP.ERR set up new exit ptr
 ldd 2,S return addr
 stx 2,S set up exit return addr
 tfr D,PC return to caller

 ifne INCLUDED&EDITOR
***************
* Subroutine COMAND
*   Top level Basic09 executive.  Given control by
*   initialization routine, calls routines as directed
*   by user.  Expects one command per line, terminated
*   with carriage-return.

COMAND leax CPYRIT,PCR
 bsr CMDER1 print copyright msg
 leax B09NAM,PCR Basic09 message
 bsr CMDER1 print "Basic09"
COMAN0 bsr SETUP
 leax READY,PCR Ready message
 bsr CMDER1 (prtlin) print message
 leax CMDPMT,PCR command mode prompt
 leay CMDVRB,PCR command verb table
 clr PRTCTL
 bsr RUNCMD process command
 bcc EXIT
 bsr CMDERR command error; print 'what?'
 bra EXIT

CMDERR leax WHAT,PCR ptr to "What?"
CMDER1 lbra PRTLIN print message
 else
COMAND equ *
COMAN0 bsr SETUP reserve opstack
 lbra BYEBYE
 endc
 ifne INCLUDED&EDITOR

***************
* Subroutine RUNCMD
*   Find and execute command

* Passed: (X)=Command Prompt String
*         (Y)=Command Verb Table
* Returns: Carry Set If Command Not Found
*          (Y)=Address of Input Line If Not Found
* Destroys: All

RUNCMD pshs X,Y Save regs
 clr G.SIGN any signal now is ignored
 lbsr PRTSTR print prompt
 bsr EXNLIN reset I/O buffer
 lda BASINP get working path number
 beq RUNCMD05
 OS9 I$Close Close input path
RUNCMD05 clr BASINP Default back to standard input
 lbsr INLINE read input line
 bcc RUNC10 ..continue if no error
 cmpb #E$EOF End of file?
 bne RUNC90 ..no; reprompt
 ifne H6309
 ldq #'b*$1000000+'y*$10000+'e*$100+V$CR default to "BYE" command
 stq  ,Y
 else
 ldd #"by default to "BYE" command
 std  ,Y
 ldd #'e*256+V$CR
 std 2,Y
 endc

RUNC10 ldx 2,S command verb tbl addr
 lda #$80 ignore high order bit
 lbsr J$SRCH search for command symbol
 bne RUNC20 ..found
 lbsr J$NAME name in command line?
 beq RUNC90 ..no; return carry set
 leax 3,X skip to alphabetic command tbl
 lda #'a-'A match upper/lower case
 lbsr J$SRCH command word found?
 beq RUNC90 ..no; return carry set
RUNC20 ldd  ,X
 leas 4,S
 jmp D,X execute command

RUNC90 coma return carry set
 puls X,Y,PC

***************
* Subroutine CHGMEM
*   Change Basic09'S Workspace Size

* Passed: (Y)=Command Line

CHGMEM lbsr CMDSEP Skip command separator
 bne CHGME1
 leax  ,Y
 ldd G.PRCA
 addd G.PRCS Find top of procedure storage
 inca round up
 subd G.WSPA Minimum amount of memory needed
 pshs D
 lbsr GETNUM get an integer
 bcs CHGERR ..error; what?
 cmpd ,S++ Higher than minimum needed?
 blo CHGER1 ..no; error
 OS9 F$MEM Set memory size
 bcs CHGME1 ..error; print current size
 subd #1 >>experimental fix<<
 std G.WSPS
CHGME1 lbsr NEWLIN Reset I/O ptrs
 ldd G.WSPS get current mem size
 bsr ItoA Put number in I/O buffer
CHGME9 lbra PRTEOL Print buffer; then end of line

CHGERR leas 2,S
CHGER1 coma RETURN Error - carry set
 rts

***************
* Subroutine DIR
*   Print (procedure) Directory list

* Passed: (Y)=Pathname Ptr
* Return: Nothing Useful
* Destroys: A,B,X,Y,CC

DIR leax  ,Y get pathname of listing device
 lbsr OPNCHL Open output path
DIR05 leax DIRHDR,PCR
 lbsr PRTLIN Print line
 ldy G.DIRA get proc. directory addr
 bra DIR2
DIR1 pshs X,Y Save 'em
 lda #V$SPAC
 tst M$TYPE,X internal (no type) procedure?
 beq DIR10 ..yes; don't mark it
 lda #'- Compiled marker
DIR10 lbsr  Putchr mark compiled/non-compiled state
 lda #V$SPAC
 cmpx I.APRC Is this procedure the active one?
 bne DIR15 ..no
 lda #'* Mark it with a star
DIR15 lbsr PUTCHR

 ldd M$NAME,X
 leax D,X
 lbsr STRSPC

 ldd #17*256+P.SIZE
 bsr DIRNUM Print procedure size

 ldd #28*256+P.VARC
 bsr DIRNUM Print variable size

 ldd P.VARC,X
 addd #64
 cmpd G.VARS Danger of overflowing memory?
 blo DIR18 ..no; print line
 lda #'?
 lbsr PUTCHR Print warning character

DIR18 bsr CHGME9 (prteol) print the buffer
 puls X,Y Restore 'em
 tst G.SIGN Any (abort) signals given?
 bne DIR3 ..yes; quit
DIR2 ldx ,Y++ get next procedure address
 bne DIR1 Loop until there are no more

DIR3 ldd G.VARS get free space count
 bsr ItoA Print it
 leax FREE,PCR
 lbsr STREOL PRINT " free BYTES"
 lbra CLSCHL Close output path

DIRNUM pshs B
 ldb #V$TAB
 lbsr J$CVIO Tab over to column given in (a)
 puls B Restore code of number to print
 ldx 2,S Restore procedure address (necessary?)
 ldd B,X get number to print
* Fall through to ItoA

***************
* Subroutine ItoA
*   convert Integer to ASCII in I/O buffer

* Passed: (D)=number to print
* Returns: ASCII representation in I/O buffer
* Destroys: cc

ItoA pshs D,X,Y save regs
 pshs D
 leay <Ten.Tbl,PCR ptr to 10's power table
ItoA.A ldx #$2F00 ASCII zero - 1
ItoA.B puls D restore remainder
ItoA.C leax $100,X build ASCII digit
 subd  ,Y
 bhs ItoA.C repeat until overflow
 addd ,Y++ skip to next table entry
 pshs D save remainder
 ldd  ,Y Is this the units digit?
 tfr X,D  prime (A)=ASCII digit
 beq ItoA.Z ..Yes; print it and exit
 cmpd #$3000 suppressed high-order digit?
 beq ItoA.A ..Yes; print nothing
 lbsr PUTCHR output digit
 ldx #$2F01 end zero suppression
 bra ItoA.B

ItoA.Z lbsr PUTCHR output Units Digit
 leas 2,S discard remainder
 puls D,X,Y,PC return

Ten.Tbl fdb 10000
 fdb 1000
 fdb 100
 fdb 10
 fdb 1
 fdb 0 end of tbl

***************
* Subroutine INVOKE
*   Execute OS-9 Shell command

INVOKE lbsr CMDSEP Skip any spaces in command line
 leau  ,Y Parameter string ptr
 clrb
INVK10 incb COUNT Parameter size
 lda ,Y+
 cmpa #V$CR End of line?
 bne INVK10 ..no; keep looking
 clra
 tfr D,Y Size of parameter area
 leax SHELL,PCR ptr to "SHELL"
 lda #OBJCT
 clrb
 OS9 F$Fork Fork to shell
 bcs ERREXT Report error, exit
 pshs A save child process ID
INVK20 OS9 F$Wait Wait for command to finish
 cmpa  ,S proper child dead?
 bne INVK20 ..No; wait again
 leas 1,S
 tstb
 bne ERREXT Report error, exit
 rts

***************
* Subroutine Chddir
*   Chd <dir name> or Chx <dir name>

CHDDIR lda #DIR.+UPDAT. change data directory
 bra CHXD10

CHXDIR lda #DIR.+EXEC. change execution directory
CHXD10 leax  ,Y (x)=pathname ptr
 OS9 I$ChgDir change directory
 bcs ERREXT if error; report it
 rts else return carry clear

***************
* Subroutine Rename
*   Rename <Old Proc Name>,<New Proc Name>

* Passed: (Y)=Command Line Following "Rename"

RENAME bsr PRCREF get (old) procedure name
 lbsr DIRSCH Is it in directory?
 bcs ERUPRC No; error - not in workspace
 pshs X
 ldx  ,X get procedure address
 tst M$TYPE,X internal (un-typed) procedure?
 bne ERUPRC ..no; sorry
 bsr CMDSEP Skip separator
 beq RENAM0 ..continue if separator present
RENAMErr comb
 puls X,PC Return error

RENAM0 lbsr J$NAME get (new) procedure name
 beq RENAMErr ..abort if not present
 pshs Y Save ptr to new name
 lbsr DIRSCH Is it in directory?
 bcs RENA05 ..no; good
 cmpx 2,S renaming same procedure?
 bne ERPRCX No; error - procedure already exists
RENA05 ldx 2,S get directory address
 lbsr UNBIND Unbind the procedure
 puls X get ptr to new name
 ldy I.STBG
RENAM1 lda ,X+ Move new name to workspace
 sta ,Y+
 bpl RENAM1
 sty ICDPTR Set end of name ptr
 ldx [,S++] get address of procedure
 ldd M$NAME,X
 leay D,X get address of old name
 ldb P.NAMS,X get size of old name
 lda NAMLEN Replace it with size of new name
 sta P.NAMS,X
 clra
 lbsr REPLAC Replace old name with new name
 addd I.ICBG
 std I.ICBG
RBIND1 lbra REBIND Rebind the procedure and return carry clear
 endc

ERPRCX ldb #M$MDPC Error - multiply defined proc
ERREXT lbsr PRTERR
EXIT1 lbra EXIT

ERUPRC ldb #M$UPRC Error - unknown procedure name
 bra ERREXT

***************
* Cmdsep
*   Skip a command separator

* Passed: (Y)=Command Line
* Returns: (Y)=Updated Past Separator
* Destroys: B,CC

CMDSEP ldb ,Y+
 cmpb #', Comma?
 beq CMDSE9 ..yes; return
 cmpb #V$SPAC Space?
 beq CMDSE9
 leay -1,Y
CMDSE9 rts

 pag
***************
* Subroutine Prcref
*   get A Procedure Reference From The Command Line

* Passed: (Y)=Command Line Where A Proc. Name Should Be
* Returns: (Y) Pointing to A Proc. Name With Last Byte Set
* Destroys: A,B,X,CC

PRCREF lbsr J$NAME Is there a name in the command line?
 bne PRCRE9 ..yes; good - return
DEFPRC ldy I.APRC
 beq PRCRE1
 ldd M$NAME,Y
 leay D,Y get "current" PROCEDURE NAME
 rts
PRCRE1 leay DEFNAM,PCR get default name
PRCRE9 rts RETURN

 ifne INCLUDED&EDITOR
***************
* Subroutine Load
*   Load A "Save" File

* Passed: (Y)=Command Ptr (After Save)

LODERR ldb #M$UPRC Error-unknown procedure
 bra LODER1

LODABT ldb #M$MFUL Error; memory full
LODEOF pshs B Save error code
 bsr RBIND1 Bind erroneous procedure
 puls B Restore error code
LODER1 cmpb #E$EOF End of File?
 beq EXIT1 ..yes; return
 bra ERREXT Print error message & return

LOAD leax  ,Y get path name ptr
 lda #READ. Open for input
 OS9 I$Open Open the input file
 bcs LODER1 Exit if error
 sta BASINP Save working path
 bsr INLINE Read next line
 bsr PRCLIT Does it contain a 'procedure' literal?
 bne LODERR ..no; error exit (dump file?)
LOAD1 lbsr J$NAME get procedure name
 beq LODERR No name found; error - path is open
 pshs Y Save procedure name ptr
 lbsr DIRSCH Is name in directory?
 bcs LOAD15 ..no; don't try kill
 ldy  ,S
 leay -1,Y Must have a preceeding space
 lbsr KILLER Destroy any old version that may have existed
LOAD15 ldy  ,S get ptr to procedure name
 lbsr DIRADD Add it to the directory
 lbsr UNBIND Unbind the new procedure
 puls X Restore proc name ptr
 lbsr PRTLIN Print it
LOAD2 ldb G.SIGN (abort) signal?
 bne LODEOF ..yes; return signal as error
 bsr INLINE Loop :get (next) source line
 bcs LODEOF I/O error ..end of file?
 lda G.VARS Enough memory to compile?
 cmpa #2 (at least 2 pages required)
 blo LODABT ..no; abort
 bsr PRCLIT Is it a procedure header?
 beq LOAD3 ..yes; exit
 ldy I.IOBG
 ldd I.ICLM
 std I.ICPT At end of icode-
 lbsr INSERT -insert this line
 bra LOAD2 Endloop
LOAD3 ldx I.IOBG
 pshs X,Y Save next procedure name ptr
LOAD35 lda ,X+
 cmpa #V$CR End of input line?
 bne LOAD35 ..no; skip to end of line
 stx I.IOBG Move I/O buffer up (binding errors wipe out)
 stx I.IOPT
 lbsr J$BIND Bind current procedure
 puls X,Y Restore next procedure name
 stx I.IOBG Reset I/O buffer addr
 stx I.IOPT
 bra LOAD1 Go load the new procedure

INLINE lda BASINP get Basic09's working path
 ldx I.IOBG
 ldy #256 Length of I/O buffer
 OS9 I$ReadLn Call OS9 to do the I/O
 ldy I.IOBG
 rts

PRCLIT lbsr J$NAME get a name in the source line
 leax PRCEDR,PCR get addr of PROCEDURE string
PRCLI1 lda ,X+
 eora ,Y+
 anda #^('a-'A) match upper or lower case
 bne PRCLI9 Exit if not equal
 tst -1,X
 bpl PRCLI1 Loop until all characters are checked
 clra
PRCLI9 rts RETURN to user

***************
* Subroutine Dump
*   Pack <Procedure List>;<File Spec> (?)
*   saves procedure icode suitable for Roming

DUMP lbsr DEFILE Parse procedure names, get pathnname
 ldu I.OPBG
 bra DUMP02 Repeat
DUMP01 ldy  ,Y get proc addr
 tst M$TYPE,Y internal (un-typed) procedure?
 lbne ERABRT ..no; illegal to compile
 lda P.STAT,Y
 rora any errors in procedure?
 lbcs ERABRT ..Yes; abort
 ldd P.SYMB,Y
 leay D,Y
 ldd -3,Y number of entries in symbol tbl
 aslb
 rola (times 2)
 inca plus $100 for safety
 cmpd G.VARS enough free space to pack?
 lbhi ERMFUL ..No; abort
DUMP02 ldy ,--U get next procedure in list
 bne DUMP01 Until end of list
 ldd #(EXEC.+WRITE.)*256+UPDAT.+EXEC. Mode
 lbsr OPNCH0 Open output path
 ldy I.OPBG
 stu I.OPBG chop out used portion of opstack
 lbra DUMP04 Repeat
DUMP03 pshs Y Save opstack (procedure list) ptr

 lbsr UNBIND Unbind procedure
 clr SMASH Tell binder to smash rems, dims, types, etc.
 lbsr J$BIND Rebind squished procedure
 inc SMASH Reset
 ldx I.SYMT get symbol tbl ptr
 leay  ,X (in case of no symbols)
 ldd G.WSPA
 addd G.WSPS
 tfr D,U ptr to top of free space
 ldd -3,X
 beq DUMP20 No symbols; exit squish phase
 pshs U
DUMP1 pshs D Save symbol table count
 leax 1,X
 ldd  ,X
 pshu D Build stack of save info from symbol table
 clr ,X+ Clear out symbol table entry
 clr ,X+
DUMP2 lda ,X+
 bpl DUMP2 Skip over name to next entry
 puls D Restore symbol table count
 subd #1
 bne DUMP1 Repeat until whole table copied
 ldy I.ICBG
 bra DUMP4 While not end of icode
DUMP3 ldd  ,Y get symbol table ptr
 ldx I.SYMT
 leax D,X Actual addr of symbol tbl entry
 ldd 1,X get linked list
 sty 1,X Make new head
 std ,Y++ Build link
DUMP4 lbsr NXTVAR Skip to next complex variable or run
 bcc DUMP3 Endwhile
 puls U get top of free space again
 ldx I.SYMT get old symbol table ptr
 ldd -3,X Number of entries in symbol table
 leay  ,X Set beginning of new symbol table
DUMP5 leau -2,U Move to current entry
 pshs D,U Save number of entries, stack ptr
 clra
 ldu 1,X get header link
 beq DUMP8 Branch unreferenced entry
 pshs X Save old symbol ptr
 tfr Y,D Copy new symbol ptr
 subd I.SYMT Make ptr into offset
 bra DUMP7
DUMP6 std  ,U Set symbol offset
 leau  ,X Copy ptr to next reference
DUMP7 ldx  ,U get ptr to next reference
 bne DUMP6 Branch if there is one
 std  ,U Set offset of last
 puls X Retrieve old symbol ptr
 lda  ,X get type byte
 sta ,Y+ Copy it
 ldu [2,S] get old contents
 stu ,Y++ Copy them
DUMP8 leax 3,X Skip symbol info
DUMP9 ldb ,X+ get next name byte
 cmpa #S.PROC Copy name?
 bne DUMP10 Branch if not
 stb ,Y+
DUMP10 tstb
 bpl DUMP9
 puls D,U
 subd #1 Decrement symbol table count
 bne DUMP5
DUMP20 equ *

* Now, symbols are removed, Icode ptrs are fixed up

 ldx I.APRC get procedure addr
 ldd P.SIZE,X Adjust procedure size
 pshs D Save old size
 clr ,Y+ Make room for checksum
 clr ,Y+
 clr ,Y+
 tfr Y,D Copy procedure end ptr
 subd I.APRC Make ptr into size
 std P.SIZE,X Set size
 ldd  ,S get difference
 subd P.SIZE,X
 std  ,S Save it
 addd G.VARS Adjust free space size
 std G.VARS
 ldd G.PRCS Adjust procedure space
 subd ,S++
 std G.PRCS
 addd G.PRCA
 std I.STBG Adjust bottom of free space
 ldb #SBRTN+ICODE
 stb M$TYPE,X
 ldb #$80
 stb P.STAT,X Set compiled (and external) status
 leau  ,Y (u)=end of module
 ldd #$FFFF
 std ,--U initialize crc to $FFFFFF
 sta ,-U
 ldb #7
DUMP25 eora B,X form header parity
 decb
 bpl DUMP25
 sta M$Parity,X save header parity
 ldy P.SIZE,X Procedure size - 3
 leay -3,Y := size of area to perform crc
 OS9 F$CRC form crc
 com ,U+
 com ,U+
 com ,U+ (u)=end of procedure
 ldy P.SIZE,X get procedure size
 lda #CMDOUT
 OS9 I$Write Write the procedure
 lda #$C0 Set compiled and internal status
 sta P.STAT,X
 lbcs ERRST Error; reset std I/O
 puls Y Retrieve procedure list ptr

DUMP04 ldx ,--Y get next procedure directory addr
 lbne DUMP03 Repeat until there are no more
 lbra CLSCHL Close output path, exit

***************
* Defile
*   get list of procedure names and (possibly default) pathname

DEFILE bsr PCDLST get list of procedures
 lda  ,Y
 cmpa #V$CR End of line?
 bne DEFIL1 ..no; exit
 ldx I.OPBG get list of procedure names
 ldx [-2,X] get 1st procedure in list
 ldd M$NAME,X
 leax D,X Point to it's name
 lbsr STRSPC Put it in the I/O buffer
 lbsr CPYEOL Followed by a carriage return
DEFIL1 leax  ,Y Copy I.IOPT (ptr to pathname)
 rts
 endc

***************
* Subroutine Pcdlst
*   get list of procedure names from command line

* Passed: (Y)=Ptr to ASCII <Proc Name> [,<Proc Name>..]
* Returns: (Y)=Updated to Terminating Char+1
*          List of Directory Entry Ptrs on Opstack
*          Terminated By A $0000 Entry

PCDLST ldu I.OPBG
 stu I.OPSP reset opstack

 ifne INCLUDED&EDITOR
 lbsr CMDSEP Is there a comma or space in command line?
 beq PCDLS3 ..yes; go get name(s)
 cmpb #'* Entire directory?
 bne PCDL35 ..no; use default name
 endc

 ldx G.DIRA get directory addr
PCDLS1 ldd  ,X End of directory?
 beq PCDLS2 ..yes, exit
 tfr X,D get addr of directory entry
 leax 2,X Update directory ptr
PCDLS2 std ,--U Push directory addr on opstack
 bne PCDLS1 Repeat if not end marker
 stu I.OPSP Save updated opstack ptr
 lda  ,Y
 cmpa #V$CR End of line?
 beq PCDL25 ..yes; dont update icode ptr
 leay 1,Y Skip separator preceeding pathlist
PCDL25 sty I.IOPT
 rts RETURN

 ifne INCLUDED&EDITOR
PCDLS3 lbsr J$NAME Any procedure names given?
 bne PCDLS4 ..yes; go get em
PCDL35 sty I.IOPT Save I/O ptr
 lbsr DEFPRC get default procedure name
 lbsr DIRSCH Is it in directory?
 bcc PCDLS5 ..yes; good
PCDLSR lbra ERUPRC

PCDLS4 lbsr DIRSCH Is the procedure name known?
 bcs PCDLSR ..no; error
 sty I.IOPT Save I/O ptr
PCDLS5 stx ,--U Push directory addr
 ldy I.IOPT
 lbsr CMDSEP Is it followed by a command separater?
 bne PCDLS6 ..no; done
 lbsr J$NAME Another procedure name in source?
 bne PCDLS4 ..yes; repeat
PCDLS6
 ifne H6309
 clrd Make End mark on opstack
 else
 clra
 clrb Make End mark on opstack
 endc
 bra PCDLS2 Push it and return

***************
* Subroutine Save
*   Save <Procedure List>;<File Spec>
* Saves Procedure(S) In Source Format

* Passed: (Y)=Ptr to Command Line Following "Save"

SAVE tst G.VARS At least one page of free memory?
 lbeq ERMFUL ..no; give up
 lda #$80
 sta PRTCTL
 bsr DEFILE get procedure list, pathname
 bra LIST0

***************
* Subroutine List
*   List Procedure(S)

LIST bsr PCDLST Parse list of procedure names
 leax  ,Y get I/O ptr (pathname)
LIST0 stx I.ICPT out of range to KILL "*" on current
 bsr OPNCHL Open output path
 ldy I.OPBG get top of list
 stu I.OPBG Carve out opstack space used
 bra LIST2
LIST1 pshs Y Save proc list ptr
 ldy [,Y] get procedure addr
 sty I.APRC set active procedure
 ldd P.PGMB,Y set icode beginning offset
 addd I.APRC
 std I.ICBG
 ldd P.DSCB,Y compute icode limit
 addd I.APRC
 std I.ICLM
 ldd P.SYMB,Y compute symbol tbl addr
 addd I.APRC
 std I.SYMT
 tst M$TYPE,Y internal (type-less) procedure?
 bne LIST15 ..no, silence is golden
 leax <LIST12,PCR
 lbsr SETEXT
 lbsr LSTBND List it
LSEXIT lbra EXIT (this will fall through)
LIST12 tst PRTCTL doing a save?
 bmi LIST15 ..yes; don't produce error list
 ldx [,S] restore directory ptr
 lbsr UNBIND Unbind procedure
 lbsr J$BIND Rebind it (show errors)
LIST15 puls Y Restore proc list ptr
LIST2 ldx ,--Y get next directory addr
 bne LIST1

OPEXIT bsr CLSCHL reset comand output path
 bra LSEXIT then exit (no error)

CLSCHL pshs B save possible error code
 lda #CMDOUT close current command path
 OS9 I$Close
 lda BASOUT get initial command path
 OS9 I$Dup reset it
 puls B,PC return

***************
* Opnchl
*   Open Output Path

* Passed: (X)=Pathname Ptr

OPNCHL lbsr CMDSEP
 cmpb #V$CR End of line?
 beq OPNC99 (rts) no re-direction desired
 stx I.IOPT Save file name ptr
 ldd #WRITE.*256+UPDAT.+PREAD. Mode, attributes

OPNCH0 pshs D,X,U save regs
 lda #CMDOUT
 OS9 I$Close eliminate output path
OPNCH1 ldd  ,S get mode
 OS9 I$Create Open new file
 bcc OPNC90 Opened ok, return
 cmpb #E$CEF Creating existing file?
 bne ERRST Error; reset command output path
 ldd  ,S mode
 ldx 2,S pathname ptr
 OS9 I$Open open existing file
 bcs ERRST ..error; reset comand output
 leax OVWRIT,PCR
 ldy #OVWLEN
 lda BASOUT to 'normal' command path
 OS9 I$WritLn File exists, rewrite?:
 clra from Std input path
 leax ,--S Input buffer
 ldy #2 Read one byte
 OS9 I$ReadLn
 puls D get byte read
 eora #'Y Yes?
 anda #^('a-'A) (match lower case, too)
 bne OPEXIT ..no; reset comand path
 lda #CMDOUT
 ldb #SS.Size
 ldx #0
 leau  ,X
 OS9 I$SetStt set file size to zero
 bcs ERRST ..error; reset command path
OPNC90 puls D,Y,U,PC return, output redirected
OPNC99 rts

ERRST bsr CLSCHL Close the path
 lbra ERREXT Print error number
 endc

***************
NEWLIN clr I.IOCT
 inc I.IOCT
 pshs X
 ldx I.IOBG
 stx I.IOPT
 puls X,PC

***************
* Subroutine Interp

INTERP lbsr J$NAME Is a procedure name given?
 bne INTER1 ..yes; continue
INTE05 pshs Y Save command line ptr
 lbsr PRCREF get default procedure name
 ldx  ,S
INTER0 lda ,Y+
 sta ,X+ Copy the default name into command line
 bpl INTER0
 lda #V$CR
 sta  ,X
 puls Y Restore command line ptr
INTER1 lbsr DIRLNK Try to find procedure
 lbcs ERUPRC Not found - error
 ldx  ,X get active procedure addr
 stx I.APRC Set active procedure
 lda M$TYPE,X external or bound?
 beq INTE30 ..Yes; check type
 anda #LangMask check language
 cmpa #ICODE Basic09 Icode?
 bne ERABRT ..No; "Procedure Errors"
 bra INTE40 execute external
INTE30 lda P.STAT,X
 rora ANY Errors in procedure?
 bcs ERABRT Run aborted - procedure errors
INTE40 lbsr J$CPRM Call parameter list
 ldy I.STBG get ptr to parameter list
 ldb  ,Y test parameter
 cmpb #T.ERRL Error?
 beq ERABRT ..Yes; abort
 sty I.ICBG
 sty I.ICPT
 ldx ICDPTR
 stx I.ICLM
 stx I.STBG
 ldd G.VARS
 pshs D,Y
 lbsr J$BPRM Bind parameters
 puls D,Y
 std G.VARS
 sty I.STBG
 ldx I.APRC
 lda P.STAT,X
 rora ANY Errors in run stmt?
 bcs ERABRT Syntax errors - abort
 leas 258,S Discard opstack area
 ldd G.WSPA get workspace beginning
 addd G.WSPS Add workspace size
 tfr D,Y Top of free space
 std I.OPBG
 std I.OPSP
 ldu #0
 stu I.ASTR
 stu STEPS
 inc STEPS+1
 clr I.ERR
 ldd I.STBG
 ldx G.VARS
 pshs D,X
 leax INTRTS,PCR
 lbsr SETEXT
 ldx I.STBG Parameter list
 lbsr J$IPRM Interpret parameters
 lbsr NEWLIN Reset I/O ptrs
 ldx I.APRC
 lbsr J$INTX Execute interpreter
 bra INTER9 Return
INTRTS puls D,X
 std I.STBG
 stx G.VARS
INTER9 lbra EXIT Return

ERABRT ldb #M$ERST
 lbra ERREXT

***************
* Subroutine BYEBYE
*   Return nicely to OS-9

BYEBYE bsr KILALL kill all external procedures
 clrb
 OS9 F$Exit

***************
* Subroutine KILLEX
*   Runtime Kill command - must be external

KILLEX lbsr J$NAME name given?
 beq KILERR ..no; error
 lbsr DIRSCH
 bcs KILERR ..error; return it
 ldu I.OPBG
 ifne H6309
 clrd
 else
 clra
 clrb
 endc
 pshu D,X build procedure list stack
 inca
 sta G.SIGN signal killer: external only
 bsr KILL0
 clr G.SIGN
 rts
KILERR comb
 ldb #M$UPRC Error: unknown procedure
 rts

***************
* Subroutine KILLER
*   Kill a procedure leaving no residue

* Passed: (Y)=Command Line Ptr Following 'Kill'
* Returns: CC=Set If (Not Found) Error
*          (Returns Y Unharmed In Case of Error)
* Destroys D,X,Y

KILALL ldy I.IOPT build "All" name in I/O buffer
 lda #'*
 sta  ,Y (kill all)
 sta G.SIGN

KILLER lbsr PCDLST get list of procedures to kill
 clr I.APRC no active procedure
 clr I.APRC+1
KILL0 ldu I.OPBG
 stu I.OPSP Reset opstack ptr
 bra KILL2 For each member of list, do
KILL1 ldx  ,X get procedure addr
 ifne INCLUDED&EDITOR
 ldb M$TYPE,X internal (un typed) procedure?
 beq KILL15 ..yes; delete from workspace
 cmpb #SBRTN+ICODE Basic09 icode variety?
 bne KILL12 ..no; unlink external module
 ldb P.STAT,X
 aslb INTERNAL Procedure?
 bmi KILL15 ..yes; delete from workspace
 endc
KILL12 pshs U
 leau  ,X
 OS9 F$Unlink Unlink external modules
 puls U
 ifne INCLUDED&EDITOR
 bra KILL18 Zap directory entry
KILL15 tst G.SIGN Signal set?
 bne KILL2 ..yes; don't kill internal procs
 ldx  ,U Restore directory addr
 lbsr SHUFLE Shuffle it to the top
 ldy  ,X get procedure addr
 ldd G.PRCS
 subd P.SIZE,Y
 std G.PRCS Decrement procedure workspace size
 ldd P.SIZE,Y
 addd G.VARS Give procedure's area back to free space
 std G.VARS
 ldd I.STBG
 subd P.SIZE,Y
 std I.STBG
 endc
KILL18 ldd #-1
 std [,U] Zap directory addr
KILL2 ldx ,--U get next proc in list
 bne KILL1 Until there are no more
 ldx G.DIRA
 tfr X,Y
KILL3 ldd ,X++ Compress deleted entries
 cmpd #-1 Zapped?
 beq KILL3
KILL4 std ,Y++
 bne KILL3 Gotta check the whole list
 cmpd  ,Y
 bne KILL4 Wipe out tail end of directory
 rts

 ttl DIRECTORY Routines
 pag
 ifne INCLUDED&EDITOR
***************
* Subroutine DIRADD
*   Search procedure directory for procedure
*   Add it to directory if not found

* Passed: (Y)=Addr of Proc Name to Add
* Returns: (Y)=Updated Past Procedure Name
*          (X)=Addr of Directory Entry
* Destroys: A,CC

DIRADD bsr DIRSCH Search directory for proc. name
 bcs DIRA00 Return if found
 rts
DIRA00 pshs X,U Save registers
 tfr X,D get directory entry
 cmpb #-2 Is it the last
 beq ERMFUL ..yes; error - memory full
DIRAD0 ldx G.VARS get free memory size
 cmpx #$FF Is there enough room?
 blo ERMFUL ..no; error - memory full
 leax -(P.NAME+3),X
 ldu I.STBG get bottom of free space ptr
 ldb #-1
DIRAD1 incb
 clr B,U Clear out new procedure's p.stuff
 cmpb #P.NAMS
 bne DIRAD1 Loop until all clear except name
DIRAD2 incb
 leax -1,X Decrement free space size
 beq ERMFUL Exit if there isn't enough room
 inc P.NAMS,U Increment procedure name size
 lda ,Y+ get (next) procedure name character
 sta B,U Save it in the procedure's workspace
 bpl DIRAD2 Loop until the last name byte has been moved
 incb
 stx G.VARS Update free space count
 clra
 std P.EXEC,U First executable stmt
 std P.PGMB,U Icode beginning
 std P.DSCB,U Description tbl beginning
 stu [,S] Store addr of new procedure there
 pshs B Temp save b
 addd #3 Form actual size of new (null) procedure
 std P.SIZE,U Procedure size
 std P.SYMB,U Symbol table beginning
 addd G.PRCS
 std G.PRCS Update total procedure area size
 ldd #M$ID12 Build module header
 std M$ID,U
 ldd #P.NAME
 std M$NAME,U
 ldd #REENT+1 un-typed; attr/rev
 std M$TYPE,U
 ldd #U.SIZE
 std P.VARC,U Set initial variable size
 puls B
 leax D,U Form addr of new symbol table
 ldb #3 Number of skip bytes per entry
 sta ,X+
 std ,X++ Initialize procedure's symbol table
 stx I.STBG Update bottom of free space
 puls X,U,PC Return to caller
 endc

ERMFUL ldb #M$MFUL
 lbra ERREXT

***************
* Subroutine DIRSCH
*   Search procedure directory for procedure

* Passed: (Y)=Name
* Returns: (X)=Addr of Directory Entry
*          (Y)=Updated Past Procedure Name
*          CC=Set If Not Found
* Destroys: D

DIRSCH pshs Y,U Save registers
 ldx G.DIRA get directory addr
DIRSC0 ldy  ,S Reset proc name string
 ldu ,X++ get (next) procedure addr
 beq DIRSC9 End of directory - not found exit
 ldd M$NAME,U
 leau D,U get addr of name
DIRSC2 lda ,Y+ get (next) source char
 eora ,U+ Is it the same as that in the directory?
 anda #^('a-'A) (upper or lower case)
 bne DIRSC0 ..no; skip to the next entry
 clra insure carry clear
 tst -1,U
 bpl DIRSC2 Loop if this isnt the last char in the name
DIRSC3 leax -2,X
 puls D,U,PC Return

DIRSC9 coma set Carry (not found)
 bra DIRSC3 Return not found

***************
* Subroutine DIRLNK
*   Search For Icode Procedure, If Not Internal Try to Link

* Passed: (Y)=Name
* Returns: (X)=Addr of Directory Entry (If Found)
*          (Y)=Updated Past Name
*          CC=Set If Not Found
* Destroys: D

DIRLNK bsr DIRSCH Search internal directory
 bcs DIRLN1 ..not found,try to find in system
 rts

DIRLN1 pshs X,Y,U Save directory entry ptr (x)
 ldb 1,S
 cmpb #-2 Last entry?
 beq ERMFUL ..too bad
 leax  ,Y get proc name ptr
 ifne H6309
 clrd any revision
 else
 clra
 clrb any revision
 endc
 OS9 F$Link Try to find
 bcc DIRLN2 ..good
 ldx 2,S Restore proc name ptr
 ifne H6309
 clrd any revision
 else
 clra
 clrb any revision
 endc
 OS9 F$Load Try to load module
 bcs DIRLN9 ..not found; sorry
DIRLN2 stx 2,S Return updated module name ptr in (y)
 stu [,S] Module (procedure) addr goes in directory
DIRLN9 puls X,Y,U,PC Return

 ifne INCLUDED&EDITOR
***************
* Subroutine SHUFLE
*   Move a procedure to the top of workspace

* Passed: (X)=Directory Addr
* Returns: (X)=Unaltered
* Destroys: D,CC

SHUFLE pshs X,Y Save regs
 ldd G.PRCA
 addd G.PRCS
 tfr D,Y ..high addr
 ldx  ,X ..low addr
 sty [,S] Reset procedure addr in directory
 ldd P.SIZE,X get procedure size
 bsr FLOTUP "FLOAT" it up to bottom of free space
 pshs D,X,Y
 ldx G.DIRA
 bra SHUFL2
SHUFL1 cmpd 2,S Below affected addres?
 blo SHUFL2
 cmpd 4,S Above the one just shuffled up (external)?
 bhi SHUFL2 ..yes
 subd  ,S Adjust directory entry of each procedure that was moved down
 std -2,X
SHUFL2 ldd ,X++
 bne SHUFL1
 leas 6,S
 puls X,Y,PC Restore regs and return

***************
* Subroutine FLOTUP

* Passed: (D)=Size of Area to "Float" to Top
*         (X)=Low Memory of Move (Addr of Thing to Float Up)
*         (Y)=High Memory of Move (Bottom of Freespace Usually)
* Destroys: None

FLOTUP pshs D,X,Y,U Save parameters
 ldu #0 Bytecnt=0
 tfr X,D
 subd 4,S Size of memory involved in move
 pshs D,X
 addd 4,S Already at top?
 beq FLOTU9 ..yes, return
FLOTU1 lda  ,X
 pshs A Savebyte=[low memory]
 bra FLOTU3
FLOTU2 lda  ,Y [moveto]=[movefrom]
 sta  ,X
 leau 1,U Bytecnt=bytecnt+1
 tfr Y,X Moveto=movefrom
FLOTU3 tfr X,D
 addd 5,S Movefrom=moveto+size
 cmpd 9,S
 blo FLOTU4
 addd 1,S
FLOTU4 tfr D,Y
 cmpd 3,S Movefrom=lowmem?
 bne FLOTU2
 puls A
 sta  ,X [moveto]=savebyte
 leax 1,Y
 stx 2,S Update lowmem
 leau 1,U Bytecnt=bytecnt+1
 tfr U,D
 addd  ,S Total number of bytes moved?
 bne FLOTU1 ..no; keep moving
FLOTU9 leas 4,S
 puls D,X,Y,U,PC

 endc
* End of Command routines

 use editor
