 nam Expression Interpreter
 use DEFS
 ttl External Linkage Section
 pag
 use LINKAGE

***************
* Expressions Global Entry Points

EXPRENT equ *
 fdb INIT-EXPRENT
 fdb VARREF-EXPRENT Variable ref
 fdb RLADD-EXPRENT Real add
 fdb XRLMUL-EXPRENT Real multiply
 fdb XRLDIV-EXPRENT Real divide
 fdb RLCMP-EXPRENT Real compare
 fdb FIX-EXPRENT Teat for real & make integer
 fdb FLOAT-EXPRENT Test for integer & make real

***************
* External Subroutine Refs

J$SBST jsr M.COMAND
 fcb X$SBST Search for substring
J$STER jsr M.STMTS
 fcb X$STER  statement error exit
J$CVIO jsr M.CNVIO
 fcb X$CVIO  call cnvio

 ifne INCLUDED&EDITOR
J$TEXP jsr M.COMAND
 fcb X$TEXP Trace expression addr
 endc

 ttl Symbolic Definitions
 pag

***************
*   Opstack Offsets

OPSIZE equ 6 Operand size
NOSMN4 equ 11 Next-on-stack least-signif.-byte
NOSMN3 equ 10
NOSMN2 equ 9
NOSMN1 equ 8 Next-on-stack most-signif.-byte
NOSEXP equ 7 Next-on-stack exponent
NOSINT equ 7 Next-on-stack integer
NOSTYP equ 6 Next-on-stack TYPE
TOSMN4 equ 5 Top-of-stack least-signif.-byte
TOSMN3 equ 4
TOSMN2 equ 3
TOSMN1 equ 2 Top-of-stack most-signif.-byte
TOSEXP equ 1 Top-of-stack exponent
TOSINT equ 1 Top-of-stack integer
TOSTYP equ 0 Top-of-stack TYPE


 ttl Dispatch Tables
 pag
***************
*
*  Operand/Operator Dispatch Table
*
OPRBGN fdb MIDFNC-OPRTBL
 fdb LFTFNC-OPRTBL
 fdb RGTFNC-OPRTBL
 fdb CHRFNC-OPRTBL
 fdb STRFNI-OPRTBL
 fdb STRFNR-OPRTBL
 fdb DATFNC-OPRTBL T.DATE
 fdb TABFNC-OPRTBL
 fdb FIXTOP-OPRTBL
 fdb FIXNEX-OPRTBL
 fdb FIXTHR-OPRTBL
 fdb FLTTOP-OPRTBL
 fdb FLTNEX-OPRTBL
 fdb BLNOT-OPRTBL
 fdb NEGINT-OPRTBL
 fdb NEGRL-OPRTBL
 fdb BLAND-OPRTBL
 fdb BLOR-OPRTBL
 fdb BLXOR-OPRTBL
 fdb INCMGT-OPRTBL
 fdb RLCMGT-OPRTBL
 fdb STCMGT-OPRTBL
 fdb INCMLT-OPRTBL
 fdb RLCMLT-OPRTBL
 fdb STCMLT-OPRTBL
 fdb INCMNE-OPRTBL
 fdb RLCMNE-OPRTBL
 fdb STCMNE-OPRTBL
 fdb BLCMNE-OPRTBL
 fdb INCMEQ-OPRTBL
 fdb RLCMEQ-OPRTBL
 fdb STCMEQ-OPRTBL
 fdb BLCMEQ-OPRTBL
 fdb INCMGE-OPRTBL
 fdb RLCMGE-OPRTBL
 fdb STCMGE-OPRTBL
 fdb INCMLE-OPRTBL
 fdb RLCMLE-OPRTBL
 fdb STCMLE-OPRTBL
 fdb INADD-OPRTBL
 fdb RLADD-OPRTBL
 fdb STRCAT-OPRTBL
 fdb INSUB-OPRTBL
 fdb RLSUB-OPRTBL
 fdb INMUL-OPRTBL
 fdb RLMUL-OPRTBL
 fdb INDIV-OPRTBL
 fdb RLDIV-OPRTBL
 fdb RLEXP-OPRTBL
 fdb RLEXP-OPRTBL
 fdb VARADD-OPRTBL
 fdb VARADD-OPRTBL
 fdb VARADD-OPRTBL
 fdb VARADD-OPRTBL
 fdb FLDADD-OPRTBL
 fdb FLDADD-OPRTBL
 fdb FLDADD-OPRTBL
 fdb FLDADD-OPRTBL
 fdb 0 $fa
 fdb 0 $fb
 fdb 0 $fc
 fdb 0 $fd
 fdb 0 $fe
 fdb 0 $ff
OPRTBL fdb SVBYTE-OPRTBL
 fdb SVINT-OPRTBL
 fdb SVREAL-OPRTBL
 fdb SVBOOL-OPRTBL
 fdb SVSTR-OPRTBL
 fdb GETVAR-OPRTBL
 fdb GETVAR-OPRTBL
 fdb GETVAR-OPRTBL
 fdb GETVAR-OPRTBL
 fdb GETFLD-OPRTBL
 fdb GETFLD-OPRTBL
 fdb GETFLD-OPRTBL
 fdb GETFLD-OPRTBL
 fdb BYTLIT-OPRTBL
 fdb INTLIT-OPRTBL
 fdb RLLIT-OPRTBL
 fdb STRLIT-OPRTBL
 fdb INTLIT-OPRTBL
 fdb ADRFNC-OPRTBL
 fdb ADRFNC-OPRTBL
 fdb LNGFNC-OPRTBL
 fdb LNGFNC-OPRTBL
 fdb POSFNC-OPRTBL
 fdb ERRFNC-OPRTBL
 fdb MODFNI-OPRTBL
 fdb MODFNR-OPRTBL
 fdb RNDFNC-OPRTBL
 fdb PIFNC-OPRTBL
 fdb SUBFNC-OPRTBL
 fdb SGNFNI-OPRTBL
 fdb SGNFNR-OPRTBL
 fdb SINFNC-OPRTBL
 fdb COSFNC-OPRTBL
 fdb TANFNC-OPRTBL
 fdb ASNFNC-OPRTBL
 fdb ACSFNC-OPRTBL
 fdb ATNFNC-OPRTBL
 fdb EXPFNC-OPRTBL
 fdb ABSFNI-OPRTBL
 fdb ABSFNR-OPRTBL
 fdb LOGFNC-OPRTBL
 fdb LOG10-OPRTBL
 fdb SQRFNI-OPRTBL
 fdb SQRFNR-OPRTBL
 fdb INTFNI-OPRTBL
 fdb INTFNR-OPRTBL
 fdb FIXFNI-OPRTBL
 fdb FIXFNR-OPRTBL
 fdb FLTFNI-OPRTBL
 fdb FLTFNR-OPRTBL
 fdb SQFNCI-OPRTBL
 fdb SQFNCR-OPRTBL
 fdb PEKFNC-OPRTBL
 fdb NOTFNC-OPRTBL
 fdb VALFNC-OPRTBL
 fdb LENFNC-OPRTBL
 fdb ASCFNC-OPRTBL
 fdb ANDFNC-OPRTBL
 fdb ORFNC-OPRTBL
 fdb XORFNC-OPRTBL
 fdb TRUFNC-OPRTBL
 fdb FALFNC-OPRTBL
 fdb EOFFNC-OPRTBL
 fdb TRMFNC-OPRTBL

* Variable Load Dispatch Table

VREFDT fdb BYTVAR-VREFDT
 fdb INTVAR-VREFDT
 fdb RLVAR-VREFDT
 fdb BLVAR-VREFDT
 fdb STRVAR-VREFDT
 fdb RCDVAR-VREFDT

 ttl expression Evaluation routines
 pag
* Subroutine EVAL

* Evaluates expression in Reverse Polish I-code using Operands from
* and returning results to the Opstack.  The main loop gets the next
* TOKEN, advances the I-code ptr, and uses the TOKEN to dispatch to
* an execution routine until a non-expression TOKEN is encountered.

* Input:  X = I-code ptr
* Output: X = I-code ptr (updated past Current Token)
*         Y = Opstack ptr (Tos is Result)
*         B = Current TOKEN
*         A = Result TYPE
*        CC = Carry Clear

EVAL ldy I.OPBG Get opstack ptr
 ldd I.STBG Init string stack ptr
 std I.STSP
 bra EVAL20
EVAL10 aslb Shift for two-byte entries
 ldu D.IOPD Get dispatch table addr
 ldd B,U Get routine offset
 jsr D,U Call routine
EVAL20 ldb ,X+ Get next TOKEN
 bmi EVAL10 bra if expression TOKEN
 clra Clear Carry
 lda TOSTYP,Y Get tos TYPE
 rts

***************
* Error Exit
*   Uses Statement Level Error Exit

EVLERR equ J$STER

 ttl COMPLEX Variable ref routines
 pag
***************
* Subroutine GETVAR
*   Get storage addr of variable, push value on Opstack

* Input: X = I-Code ptr
*        Y = Opstack ptr
* Output: X = I-Code ptr (updated)
*         Y = Opstack ptr (updated)
*         U = Variable Storage addr
* Local: D,CC Destroyed
* Global:

GETVAR bsr VARREF Get TYPE storage addr
GETVA0 pshs U,PC Save variable addr
 ldu D.IVRF Get dispatch
 asla TWO-BYTE Entries
 ldd A,U Get load routine offset
 leau D,U Get routine addr
 stu 2,S Set addr for puls
 puls U,PC Retrieve variable addr & dispatch

***************
* Subroutine GETFLD
*   Get Storage addr of Field of Structure

* Same as GETVAR

GETFLD bsr FLDREF Get TYPE & storage addr
 bra GETVA0

***************
* Subroutine VARADD
*   Get Variable Storage addr

* Same as GETVAR

VARADD leas 2,S return to eval's caller
 lda #T.AREF Set TOKEN for variable
 bra VARR01

***************
* Subroutine FLDADD
*   Get Record Component Storage addr

* Same as GETVAR

FLDADD leas 2,S return to eval's caller
 lda #T.APRD Set TOKEN for field addr
 bra FLDR01

 pag
***************
* Subroutine FLDREF
*   Process component of structure

* Same as VARREF

FLDREF lda #T.PERD Set TOKEN for field ref
FLDR01 sta TOKEN
 clr I.VRFL Set flag for field addr
 bra VARR02 Call varref

***************
* Subroutine VARREF
*   Process Variable Ref

* Process all forms of variable refs, returning the
*    absolute addr & TYPE of the variable

* Input: X = I-Code ptr
*        Y = Opstack ptr
* Output: A = Variable TYPE
*         X = I-Code ptr (updated)
*         Y = Opstack ptr (updated)
*         U = Storage addr
* Local: B,CC Destroyed
* Global: I.ASTR,I.VRFL,I.SYMT,I.DSCR,I.BASE,I.OFFS
*         I.PRLM,I.SIZE,TOKEN,DEFINT

VARREF lda #T.VREF Get base TOKEN
VARR01 sta TOKEN Set base TOKEN
 sta I.VRFL Set flag for variable addr
VARR02 ldd ,X++ Get symbol table offset
 addd I.SYMT Add base to offset
 std SYMPTR Set symbol table ptr
 ldu SYMPTR Get symbol table ptr
 lda  ,U Get TYPE byte
 anda #S.DEFM Get definition
 sta DEFINT Set definition
 eora #S.PARM Get flag (0=param; non 0=var)
 sta DEFNAS Set flag
 lda  ,U Get TYPE byte
 anda #S.TYPM Get TYPE
 ldb -3,X Get TOKEN
 subb TOKEN Less base gives subscript count
 pshs D Save TYPE & subscript count
 lda  ,U Get TYPE byte
 anda #S.SHPM Get SHAPE
 lbeq VARR14 bra if simple
 ldd 1,U Get array description offset
 addd I.DSCR Add base to offset
 tfr D,U Copy array description ptr
 ldd  ,U Get array base offset
 std I.OFFS Save it
 lda 1,S Get subscript count
 bne VARR03 bra if count > 0
 lda #S.RCRD Treat unsubscripted array as record
 sta  ,S return TYPE
 ldd 2,U Get array total size
 std I.SIZE Save it
 ifne H6309
 clrd Use zero indexing offset
 else
 clra
 clrb Use zero indexing offset
 endc
 bra VARR11
VARR03 leay -OPSIZE,Y Get scratch on opstack
 ifne H6309
 clrd Clear partial result
 else
 clra
 clrb Clear partial result
 endc
 std 1,Y
 leau 4,U Get dimension ptr
 bra VARR05

VARR04 ldd  ,U Get dimension
 std 1,Y Put in opstack
 lbsr INMUL Get (partial+(subscript-base))*dimension
VARR05 ldd 7,Y Get subscript
 subd I.BASE Get subscript-base
 cmpd ,U++ in range?
 bcs VARR5A bra if so
 ldb #M$SORG Err: subscript out of range
 lbra EVLERR

VARR5A addd 1,Y Get partial+(subscript-base)
 std 7,Y Move result to next-on-stack
 dec 1,S Count subscript
 bne VARR04 bra if more
 lda  ,S Get TYPE
 beq VARR06 bra if byte
 cmpa #S.REAL
 bcs VARR07 bra if integer
 beq VARR09 bra if real
 cmpa #S.STR
 bcs VARR06 bra if boolean
 ldd  ,U Get record size
 std I.SIZE Save it
 bra VARR10
VARR06 ldd 7,Y Get element offset
 bra VARR08
VARR07 ldd 7,Y Get index
 aslb Shift for two-byte elements
 rola
VARR08 leay 12,Y Clean opstack
 bra VARR11
VARR09 ldd #5 Get real element size
VARR10 std 1,Y Put on opstack
 lbsr INMUL Multiple index by element size
 ldd 1,Y Get indexing offset
 leay OPSIZE,Y Clean opstack
VARR11 tst DEFNAS parameter?
 bne VARR12 ..No
 pshs D Save element offset
 ldd I.OFFS Get parameter packet offset
 addd I.ASTR Add base to offset
 cmpd I.PRLM is it there?
 bcc PRMERR ..No
 tfr D,U Copy parameter packet ptr
 puls D Retrieve element offset
 cmpd 2,U Still in parameter bounds?
 bhi PRMERR ..No
 addd  ,U Add array base ptr to element offset
 bra VARR17
VARR12 addd I.OFFS Add array base offset to element offset
 tst I.VRFL field ref?
 bne VARR16 ..No
VARR13 addd 1,Y Add record ptr to field element offset
 leay OPSIZE,Y Clean opstack
 bra VARR17
VARR14 lda  ,S Get TYPE
 cmpa #S.STR string?
 ldd 1,U Get symbol table entry
 bcs VARR15 bra if simple TYPE (byte,int,real,bool)
 addd I.DSCR Add base to offset
 tfr D,U Copy description ptr
 ldd 2,U Get record size
 std I.SIZE Save it
 ldd  ,U Get record offset
VARR15 tst I.VRFL field ref?
 beq VARR13 bra if so
 addd I.ASTR Add storage base to offset
 tfr D,U Copy storage ptr
 tst DEFNAS parameter?
 bne VARR18 ..No
 cmpd I.PRLM is parameter there?
 bcc PRMERR ..No
 ldd I.SIZE Get declared size
 cmpd 2,U smaller then actual size?
 bcs VAR15A bra if so
 ldd 2,U Get actual size
 std I.SIZE Set size
VAR15A ldu  ,U Get parameter ptr
 bra VARR18
VARR16 addd I.ASTR Add storage base ptr to offset
VARR17 tfr D,U Copy storage ptr
VARR18 clra Clear Carry
 puls D,PC

PRMERR ldb #M$PRER ERR - missing parameter
 lbra EVLERR

 ttl INTEGER/BYTE Operand routines
 pag
***************
* Subroutine BYTLIT
*   Byte Literal

* Takes Byte Literal from I-Code and pushes it

* Input: X = I-Code ptr
*        Y = Opstack ptr
* Output: X = I-Code ptr (updated)
*         Y = Opstack ptr (updated)
* Local: D,CC Destroyed
* Global: None

BYTLIT leau ,X+ Get literal addr
 bra BYTVAR

***************
* Subroutine SVBYTE
*   Simple Variable; Byte

* Gets U-Relative addr of Simple Byte Variable from
*    I-Code and pushes Value on Opstack

* Input: X = I-Code ptr
*        Y = Opstack ptr
* Output: X = I-Code ptr (updated)
*         Y = Opstack ptr (updated)
* Local: D,CC Destroyed
* Global: Variable Added to Opstack

SVBYTE ldd ,X++ Get u relative addr
 addd I.ASTR Add procedure storage addr
 tfr D,U
* Fall Thru to BYTVAR

***************
* Subroutine BYTVAR
*   pushes Byte Variable on Opstack

* Input: U = Variable Addr
*        Y = Opstack ptr
* Output: Y = Opstack ptr (updated)
* Local: D,CC Destroyed
* Global: Variable Added to Opstack

BYTVAR ldb  ,U Get value
 clra clear Msb
 leay -OPSIZE,Y make room on opstack
 std 1,Y store operand in new tos
 lda #S.INT push as integer
 sta  ,Y set TYPE
 rts

***************
* Subroutine INTLIT
*   pushes Integer Literal on Operand Stack

* Input: X = I-Code ptr
*        Y = Opstack ptr
* Output: X = I-Code ptr (updated)
*         Y = Opstack ptr updated
* Local: D,CC Destroyed
* Global: None

INTLIT leau ,X++ Load literal
 bra INTVAR

***************
* Subroutine SVINT
*   Simple Variable; Integer

* Same as SVBYTE

SVINT ldd ,X++ Get u relative addr
 addd I.ASTR Get procedure storage addr
 tfr D,U
* Fall Thru to INTVAR

***************
* Subroutine INTVAR
*   push Integer Variable

* Same as BYTVAR, Except For Integer

INTVAR ldd  ,U Get value
 leay -OPSIZE,Y make room on opstack
 std 1,Y store operand in new tos
 lda #S.INT push integer
 sta  ,Y set TYPE
 rts

 ttl INTEGER/BYTE Aritmetic routines
 pag
***************
* Integer Negate
 ifne H6309
NEGINT clrd
 else
NEGINT clra
 clrb
 endc
 subd TOSINT,Y
 std TOSINT,Y
 rts

***************
* Subroutine INADD
*   Adds Opstack Tos to Nos, Result
* is new Tos.  Exit to Error on Overflow.

* Input: Y = Opstack ptr
* Output: Y = Opstack ptr (updated)
* Local: D,CC Destroyed
* Global: Opstack Tos=Tos+Nos

INADD ldd NOSINT,Y First operand
 addd TOSINT,Y Add second
 leay OPSIZE,Y Pop one operand
 std TOSINT,Y Store result
 rts

***************
* Subroutine INSUB
*   Subrtact Integer

* Subtracts Opstack Tos from Nos, result is new Tos

* Input: Y = Opstack ptr
* Output: Y = Opstack ptr (updated)
* Local: D,CC Destroyed
* Global: Opstack Tos=Nos-Tos

INSUB ldd NOSINT,Y Load first
 subd TOSINT,Y Subtract second
 leay OPSIZE,Y Pop one operand
 std TOSINT,Y Save result
 rts

***************
* Subroutine INMUL
*   Integer Multiply

* Performs Integer Multiply by summing Partial Products
*    of the Operands' component bytes

* Input: Y = Opstack ptr
* Output: Y = Opstack ptr (updated)
* Local: D,CC Destroyed
* Global: Tos = Tos * Nos

 ifne H6309
INMUL ldd TOSINT,Y Get temp var integer
 muld NOSINT,Y Multiply (result in Q=D:W)
 stw NOSINT,Y Save 16-bit wrapped result
 leay OPSIZE,Y Eat temp var
 rts
 else
INMUL ldd NOSINT,Y Get nos
 beq INML30 bra if zero
 cmpd #2 Multiply by two?
 bne INML10 ..No
 ldd TOSINT,Y Get tos
 bra INML15
INML10 ldd TOSINT,Y Get tos
 beq INML20 bra if zero
 cmpd #2 Multiply by two?
 bne INML25 ..No
 ldd NOSINT,Y Get nos
INML15 aslb Multiply by shifting
 rola
INML20 std NOSINT,Y Set result
 bra INML30
INML25 lda NOSINT+1,Y Get nos lsb
 mul TOS Lsb * nos lsb
 sta 3,Y Save partial msb
 lda NOSINT+1,Y Get nos lsb
 stb NOSINT+1,Y Save partial lsb
 ldb TOSINT,Y Get tos msb
 mul TOS Msb * nos lsb
 addb 3,Y Add partial msb
 lda NOSINT,Y Get nos msb
 stb NOSINT,Y Save result msb
 ldb TOSINT+1,Y Get tos lsb
 mul
 addb NOSINT,Y Add result msb
 stb NOSINT,Y Save result msb
INML30 leay OPSIZE,Y Pop one operand
 rts
 endc

***************
* Subroutine SETSGN
*   Integer Set Sign Flag

* Determines sign of multiplication or division result,
* sets sign Flag accordingly, and negates negative operands

* Input: Y = Opstack ptr
* Output: None
* Local: D,CC - Destroyed
* Global: Tostyp,Y Set; 0=Pos, Ff=Neg

 ifne H6309
INDIV ldd TOSINT,Y Get divisor
 bne INDV_OK ..not zero; go do divide
 ldb #M$ZDIV error: divide by zero
 lbra EVLERR
INDV_OK ldw NOSINT,Y Get 16-bit signed dividend
 sexw Sign-extend W to Q
 divq TOSINT,Y 32/16 signed divide; Q=quotient:remainder
 tstw Answer positive?
 ble INDV_ChkD bra if <= 0
INDV_Pos tsta Is remainder positive?
 bmi INDV_NRm bra if not
INDV_Sav std 9,Y Save remainder for MOD
 stw NOSINT,Y Save quotient for /
 leay OPSIZE,Y Pop divisor
 rts
INDV_ChkD beq INDV_ChkZ If zero answer, need special handling
INDV_ChkD1 tsta Is remainder negative?
 bmi INDV_Sav bra if so
INDV_NRm negd Negate remainder
 bra INDV_Sav
INDV_ChkZ lde NOSINT,Y Get MSB of dividend
 bpl INDV_ChkZ1 bra if positive
 incf Negative: bump flag
INDV_ChkZ1 lde TOSINT,Y Get MSB of divisor
 bpl INDV_ChkZ2 bra if positive
 incf Negative: bump flag
INDV_ChkZ2 cmpf #1 Remainder must be negative?
 beq INDV_ChkZ3 bra if so
 clrw Zero out answer
 bra INDV_Pos
INDV_ChkZ3 clrw Zero out answer
 bra INDV_ChkD1
 else
SETSGN clr TOSTYP,Y Clear sign flag
 ldd NOSINT,Y Get nos
 bpl SETSG1 bra if positive
 nega
 negb
 sbca #0
 std NOSINT,Y Store operand
 com TOSTYP,Y Flip sign flag
SETSG1 ldd TOSINT,Y Get tos
 bpl SETSG2 bra if positive
 nega
 negb
 sbca #0
 std TOSINT,Y Store operand
 com TOSTYP,Y Flip sign flag
SETSG2 cmpd #2 return test for two
 rts

***************
* Subroutine INDIV
*   Integer Division

* Performs division by repeated subtraction of divisor
*  from successively less significant bits of dividend

* Input: Y = Opstack ptr
* Output: Y = Opstack ptr (updated)
* Local: D,CC Destroyed
* Global: Tos = Quotient:Remainder (integers)

INDIV bsr SETSGN Get sign flag
 bne INDV10 bra if not /2
 ldd NOSINT,Y Get dividend
 beq INDV20
 asra divide by shift
 rorb
 std NOSINT,Y Store result
 ldd #0 Make remainder
 rolb
 bra INDV55
INDV10 ldd TOSINT,Y zero divisor?
 bne INDV15 ..No
 ldb #M$ZDIV error: divide by zero
 lbra EVLERR

INDV15 ldd NOSINT,Y zero dividend?
 bne INDV25 ..No
INDV20 leay OPSIZE,Y Pop one operand
 std 3,Y Store remainder
 rts
INDV25 tsta dividend Msb zero?
 bne INDV30 ..No
 exg A,B Do eight bit shift
 std NOSINT,Y Save it
 ldb #8 Set remaining shift count
 bra INDV35
INDV30 ldb #16 Full shift count
INDV35 stb 3,Y Save shift count
 clra
 clrb clear D
INDV40 asl NOSINT+1,Y Shift bit from dividend
 rol NOSINT,Y Into D
 rolb
 rola
 subd TOSINT,Y Try divide
 bmi INDV45 bra if too big
 inc NOSINT+1,Y Set bit in quotient
 bra INDV50
INDV45 addd TOSINT,Y Add divisor back
INDV50 dec 3,Y Decr shift count
 bne INDV40 bra if not done
INDV55 std 9,Y Store remainder
 tst TOSTYP,Y Check sign flag
 bpl INDV60 bra if positive
 nega
 negb
 sbca #0
 std 9,Y Save remainder
 ldd NOSINT,Y Load quotient
 nega
 negb
 sbca #0
 std NOSINT,Y
INDV60 leay OPSIZE,Y Pop divisor
 rts
 endc

 ttl REAL Operand routines
 pag
***************
* Subroutine RLLIT
*   push Real Literal on Opstack

* Input: X = I-code ptr
*        Y = Opstack ptr
* Output: X = I-code ptr (updated)
*         Y = Opstack ptr (updated)
* Local: D,CC Destroyed
* Global: None

RLLIT leay -OPSIZE,Y Make room on opstack
 ldb ,X+ Get first operand byte
 lda #S.REAL Set TYPE
 std TOSTYP,Y Move to opstack
 ifne H6309
 ldq ,X Load 4 mantissa bytes
 stq TOSMN1,Y Store them
 ldb #4
 abx Advance X past mantissa
 else
 ldd ,X++ Finish moving operand
 std TOSMN1,Y .. to opstack
 ldd ,X++
 std TOSMN3,Y
 endc
 rts

***************
* Subroutine SVREAL
*   push Real Variable on Opstack

SVREAL ldd ,X++ Get storage offset
 addd I.ASTR Add storage ptr
 tfr D,U Copy variable storage ptr
*   Fall thru to RLVAR

***************
* Subroutine RLVAR
*   push Real Variable on Opstack

RLVAR leay -OPSIZE,Y Make room on opstack
 lda #S.REAL Set TYPE
 ldb  ,U Get exponent
 std TOSTYP,Y Move to opstack
 ifne H6309
 ldq 1,U Load 4 mantissa bytes
 stq 2,Y Store them
 else
 ldd 1,U
 std 2,Y
 ldd 3,U
 std 4,Y
 endc
 rts

 ttl Real Arithmetic routines
 pag
***************
* Real Negate - Flip Sign Bit

 ifne H6309
NEGRL eim #1,5,Y Negate sign bit of REAL #
 else
NEGRL lda 5,Y
 eora #1
 sta 5,Y
 endc
 rts

***************
* Subroutine RLSUB
*   Real Subtraction

* Input: Y = Opstack ptr
* Output: Y = Opstack ptr (updated)
* Local: D,CC Destroyed
* Global: I.SIGN Destroyed

 ifne H6309
RLSUB eim #1,5,Y Flip sign bit of subtrahend
 else
RLSUB ldb 5,Y Get subtrahend sign
 eorb #1 Flip it
 stb 5,Y Save it and fall to rladd
 endc

***************
* Subroutine RLADD
*   Real Addition

* Input: Y = Opstack ptr
* Output: Y = Opstack ptr (updated)
* Local: D,CC Destroyed
* Global: I.SIGN Destroyed

 ifne H6309
* Community 6309 Real Addition
RLADD pshs X Preserve X
 tst TOSMN1,Y 1st byte of mantissa 0?
 beq L3FC7 Yes, eat temp var & leave other var alone
 tst NOSMN1,Y Is original # a 0?
 bne L3FCB No, go do actual add
L3FBB ldq TOSEXP,Y Get Exponent & 1st 3 bytes of mantissa
 stq NOSEXP,Y Save in destination var space
 lda TOSMN4,Y Copy last byte of mantissa to orig var
 sta NOSMN4,Y
L3FC7 leay OPSIZE,Y Eat temp var & return
 puls PC,X
L3FCB lda NOSEXP,Y Get 1st exponent
 suba TOSEXP,Y Calculate difference in exponents
 bvc L3FD5 Didn't exceed +127 or -128
 bpl L3FBB Went too big on plus side
 bra L3FC7 Too small
L3FD5 bmi L3FDD If negative difference, skip ahead
 cmpa #31 Difference within 0-31?
 ble L3FE5 Yes, go deal with it
 bra L3FC7 Out of range
L3FDD cmpa #-31 Difference within -1 to -31?
 blt L3FBB Out of range, copy temp to answer
 ldb TOSEXP,Y Since negative, copy temp exponent
 stb NOSEXP,Y overtop destination exponent
L3FE5 ldb NOSMN4,Y Get sign of dest. var
 andb #$01 Keep sign bit only
 stb ,Y Save copy over var type
 eorb TOSMN4,Y EOR with sign bit of temp var
 andb #$01 Keep only merged sign bit
 stb TOSEXP,Y Save what resulting sign should be
 fcb $62,$FE,$2B AIM #$FE,NOSMN4,Y
 fcb $62,$FE,$25 AIM #$FE,TOSMN4,Y
 tsta Are exponents exactly the same?
 beq L4031 Yes, skip ahead
 bpl L4029 Exponent difference positive
 nega Force to positive
 leax OPSIZE,Y Point X to dest. var
 bsr L4082 Shift mantissa
 tst TOSEXP,Y Result going to be positive?
 beq L4039 Yes, skip ahead
L400B subw TOSMN3,Y Q=Q-[2,y]
 sbcd TOSMN1,Y
 bcc L404D No borrow required
 comw Do NEGQ
 comd
 addw #1
 adcd #0
L4025 dec ,Y Drop exponent by 1
 bra L404D
Shift24 beq SkpSh24 Even byte, skip ahead
 ldb 2,X Get MSB of # to shift
S24Lp lsrb Shift it down
 deca Until done
 bne S24Lp
 tfr d,w Copy to LSW
 clrb Clear out MSW
 rts
SkpSh24 ldf 2,X Get LSB
 clre Clear 2nd LSB
 clrb Clear MS 24 bits
 rts
L4029 leax ,Y Point X to temp var
 bsr L4082 Shift mantissa
 stq TOSMN1,Y Save shifted result
L4031 ldq NOSMN1,Y Get mantissa of dest var into Q
 tst TOSEXP,Y Check exponent of temp var
 bne L400B <>0, go do Subtract again
L4039 addw TOSMN3,Y 32 bit add of Q+[2,y]
 adcd TOSMN1,Y
 bcc L404D No overflow carry
 rord Overflow, divide by 2
 rorw
 inc NOSEXP,Y Bump up exponent
L404D tsta Check sign of MSb of Q
 bmi L4060 Set, skip ahead
 andcc #^Carry Force carry bit off
L4050 dec NOSEXP,Y Drop exponent of dest var by 1
 bvc L4054 Not underflowed
 puls X Pull X back before zeroing out answer
 bra FPZERO63 Underflow; answer=0
L4054 rolw 32 bit multiply by 2
 rold
 bpl L4050 Keep doing until a set bit comes out
L4060 addw #1 Add 1 to Q
 adcd #0
 bcc L4071 No carry
 rora
 inc NOSEXP,Y
L4071 std NOSMN1,Y Save MSW of answer
 tfr w,d Move LSW to D
 lsrb Eat sign bit
 lslb
 orb ,Y Put in sign of result
L407C std NOSMN3,Y Save LSW with sign bit
 leay OPSIZE,Y Eat temp var
 puls PC,X Restore X & return
L4082 suba #24 24-31 bit shift?
 bge Shift24 Yes
 adda #8 16-23 bit shift?
 bge Shift16 Yes
 adda #8 8-15 bit shift?
 bge Shift8 Yes
 adda #8 Restore 1-7 bit shift count
 sta <I.PRHI Save # of shifts required
 ldq 2,X Get # to shift
L40BD lsrd Shift 32 bit #
 rorw
 dec <I.PRHI Dec # shifts left to do
 bne L40BD Keep doing until done
 rts
Shift16 beq SkpSh16 Even 2 bytes
 ldw 2,X Get MSW of # to shift
S16Lp lsrw Shift it down
 deca Until done
 bne S16Lp
 clrb Clear MSW of Q
 rts
SkpSh16 ldw 2,X Get LSW of Q
 clrb
 rts
Shift8 beq SkpSh8 Exactly 8, use faster method
 ldb 2,X Get LS 24 bits
 ldw 3,X
S8Lp lsrb Shift it down
 rorw
 deca
 bne S8Lp
 rts
SkpSh8 ldb 2,X Get MSW of Q
 ldw 3,X Get LSW of Q
 rts
 else
* Community 6809 Real Addition
RLADD pshs X Preserve X
 tst TOSMN1,Y 1st byte of mantissa 0?
 beq L3FC7 Yes, eat temp var & leave other var alone
 tst NOSMN1,Y Is original # a 0?
 bne L3FCB No, go do actual add
L3FBB ldd TOSEXP,Y Copy temp var's value overtop original var
 std NOSEXP,Y
 ldd TOSMN2,Y
 std NOSMN2,Y
 lda TOSMN4,Y Copy last byte of mantissa to orig var
 sta NOSMN4,Y
L3FC7 leay OPSIZE,Y Eat temp var & return
 puls PC,X
L3FCB lda NOSEXP,Y Get 1st exponent
 suba TOSEXP,Y Calculate difference in exponents
 bvc L3FD5 Didn't exceed +127 or -128
 bpl L3FBB Went too big on plus side
 bra L3FC7 Too small
L3FD5 bmi L3FDD If negative difference, skip ahead
 cmpa #31 Difference within 0-31?
 ble L3FE5 Yes, go deal with it
 bra L3FC7 Out of range
L3FDD cmpa #-31 Difference within -1 to -31?
 blt L3FBB Out of range, copy temp to answer
 ldb TOSEXP,Y Since negative, copy temp exponent
 stb NOSEXP,Y overtop destination exponent
L3FE5 ldb NOSMN4,Y Get sign of dest. var
 andb #$01 Keep sign bit only
 stb ,Y Save copy over var type
 eorb TOSMN4,Y EOR with sign bit of temp var
 andb #$01 Keep only merged sign bit
 stb TOSEXP,Y Save what resulting sign should be
 ldb NOSMN4,Y
 andb #$FE
 stb NOSMN4,Y
 ldb TOSMN4,Y
 andb #$FE
 stb TOSMN4,Y
 tsta Are exponents exactly the same?
 beq L4031 Yes, skip ahead
 bpl L4029 Exponent difference positive
 nega Force to positive
 leax OPSIZE,Y Point X to dest. var
 bsr L4082 Shift mantissa (into X:D)
 tst TOSEXP,Y Result going to be positive?
 beq L4039 Yes, skip ahead
L400B subd TOSMN3,Y X:D=X:D-(2,y)
 exg D,X
 sbcb TOSMN2,Y
 sbca TOSMN1,Y
 bcc L404D No borrow required
 coma Compliment all 4 bytes
 comb
 exg D,X
 coma
 comb
 addd #1
 exg D,X
 bcc L4025 If no carry, skip ahead
 addd #1 +1 to rest of 32 bit #
L4025 dec ,Y Drop exponent by 1
 bra L404D
L4029 leax ,Y Point X to temp var
 bsr L4082 Shift mantissa (into X:D)
 stx TOSMN1,Y
 std TOSMN3,Y
L4031 ldx NOSMN1,Y Get mantissa of dest var into X:D
 ldd NOSMN3,Y
 tst TOSEXP,Y Check exponent of temp var
 bne L400B <>0, go process
L4039 addd TOSMN3,Y 32 bit add of X:D + [2,y]
 exg D,X
 adcb TOSMN2,Y
 adca TOSMN1,Y
 bcc L404D No overflow carry
 rora Overflow, divide by 2
 rorb
 exg D,X
 rora
 rorb
 inc NOSEXP,Y Bump up exponent
 exg D,X
L404D tsta
 bmi L4060
L4050 dec NOSEXP,Y
 lbvs FPZERO
 exg D,X
 lslb
 rola
 exg D,X
 rolb
 rola
 bpl L4050
L4060 exg D,X
 addd #1
 exg D,X
 bcc L4071
 addd #1
 bcc L4071
 rora
 inc NOSEXP,Y
L4071 std NOSMN1,Y
 tfr X,D
 andb #$FE Mask out sign bit
 tst ,Y Result supposed to be negative?
 beq L407C No, leave it alone
 incb Set sign bit
L407C std NOSMN3,Y Save LSW of mantissa
 leay OPSIZE,Y Eat temp var
 puls PC,X Restore X & return
L4082 suba #16 Subtract 16 from exponent difference
 blo L40A0 Wrapped to negative
 suba #8 Try subtracting 8
 blo L4091 Wrapped
 sta <I.PRHI Save number of rotates needed
 clra
 ldb 2,X
 bra L4097 Go get Low word into X & process
L4091 adda #8 Bump # shifts back up
 sta <I.PRHI Save number of rotates needed
 ldd 2,X
L4097 ldx #0
 tst <I.PRHI Any shifts required?
 bne L40BD Yes
 rts
L40A0 adda #8 Add 8 back (back to 1 byte shift)
 bhs L40B3 Still more
 sta <I.PRHI
 clra
 ldb 2,X
 ldx 3,X
 tst <I.PRHI Any shifts to do?
 bne L40BF Yes
 exg D,X
 rts
L40B3 adda #8 Add 8 back again
 sta <I.PRHI Save # bit shifts needed
 ldd 2,X Get 32 bit mantissa into D:X
 ldx 4,X
 bra L40BF Go perform shift
L40BD exg D,X
L40BF lsra
 rorb
 exg D,X
 rora
 rorb
 dec <I.PRHI
 bne L40BD
 rts
 endc

***************
* Subroutine RLMUL
*   Multiply Tos*Nos

* Input: Y = Opstack ptr
* Local: D,CC Destroyed
* Output: Y = Opstack ptr, updated
*         U,X Preserved

RLMUL bsr XRLMUL execute Real Multiply
 bcs RLMUL_ERR
 rts
RLMUL_ERR jsr <M.STMTS
 fcb $06

 ifne H6309
XRLMUL lda TOSMN1,Y          is tos=0
 bpl FPZERO63             if so dont multiply
 lda NOSMN1,Y             how about nos?
 bmi FPML63_E9            if no go do it
FPZERO63 clrd
 clrw
 stq NOSEXP,Y
 sta NOSMN4,Y
 leay OPSIZE,Y
 rts
FPZERO clrd
 clrw
 stq NOSEXP,Y
 sta NOSMN4,Y
 leay OPSIZE,Y
 puls X,PC
FPML63_E9 lda TOSEXP,Y         Get tos expo.
 adda NOSEXP,Y            Add nos expo.
 bvc FPML63_F6            bra if no overflow
MULOVRF63 bpl FPZERO63
 comb
 ldb #M$FPOV
 rts
FPML63_F6 sta NOSEXP,Y         Save exponent
 ldb NOSMN4,Y
 eorb TOSMN4,Y
 andb #$01
 stb ,Y
 lda NOSMN4,Y
 anda #$FE
 sta NOSMN4,Y
 ldb TOSMN4,Y
 andb #$FE
 stb TOSMN4,Y
 mul
 clre
 clr <I.PRHI
 tfr a,f
 lda NOSMN4,Y
 ldb TOSMN3,Y
 mul
 addr d,w
 bcc *+4
 inc <I.PRHI
 lda NOSMN3,Y
 ldb TOSMN4,Y
 mul
 addr d,w
 bcc *+4
 inc <I.PRHI
 tfr e,f
 lde <I.PRHI
 clr <I.PRHI
 lda NOSMN4,Y
 ldb TOSMN2,Y
 mul
 addr d,w
 bcc *+4
 inc <I.PRHI
 lda NOSMN3,Y
 ldb TOSMN3,Y
 mul
 addr d,w
 bcc *+4
 inc <I.PRHI
 lda NOSMN2,Y
 ldb TOSMN4,Y
 mul
 addr d,w
 bcc *+4
 inc <I.PRHI
 tfr e,f
 lde <I.PRHI
 clr <I.PRHI
 lda NOSMN4,Y
 ldb TOSMN1,Y
 mul
 addr d,w
 bcc *+4
 inc <I.PRHI
 lda NOSMN3,Y
 ldb TOSMN2,Y
 mul
 addr d,w
 bcc *+4
 inc <I.PRHI
 lda NOSMN2,Y
 ldb TOSMN3,Y
 mul
 addr d,w
 bcc *+4
 inc <I.PRHI
 lda NOSMN1,Y
 ldb TOSMN4,Y
 mul
 addr d,w
 bcc *+4
 inc <I.PRHI
 stf NOSMN4,Y
 tfr e,f
 lde <I.PRHI
 clr <I.PRHI
 lda NOSMN3,Y
 ldb TOSMN1,Y
 mul
 addr d,w
 bcc *+4
 inc <I.PRHI
 lda NOSMN2,Y
 ldb TOSMN2,Y
 mul
 addr d,w
 bcc *+4
 inc <I.PRHI
 lda NOSMN1,Y
 ldb TOSMN3,Y
 mul
 addr d,w
 bcc *+4
 inc <I.PRHI
 stf NOSMN3,Y
 tfr e,f
 lde <I.PRHI
 clr <I.PRHI
 lda NOSMN2,Y
 ldb TOSMN1,Y
 mul
 addr d,w
 bcc *+4
 inc <I.PRHI
 lda NOSMN1,Y
 ldb TOSMN2,Y
 mul
 addr d,w
 bcc *+4
 inc <I.PRHI
 lda NOSMN1,Y
 ldb TOSMN1,Y
 mul
 tfr w,u
 tfr e,f
 lde <I.PRHI
 exg d,u
 addr u,w
 bmi FPML63_02
 asl NOSMN4,Y
 rol NOSMN3,Y
 rolb
 rolw
 dec NOSEXP,Y
 bvs FPML63_1B
FPML63_02 tfr b,a
 ldb NOSMN3,Y
 exg d,w
 addw #1
 adcd #0
 bne FPML63_1B
 rora
 inc NOSEXP,Y
FPML63_1B exg d,w
 lsrb
 lslb
 orb ,Y
 std NOSMN3,Y
 stw NOSMN1,Y
 leay OPSIZE,Y
 clrb
 rts
 else
XRLMUL pshs X Save x
 lda TOSMN1,Y is tos=0
 bpl FPZERO if so we dont multiply
 lda NOSMN1,Y How about nos?
 bmi FPMUL3 if no go do it
FPZERO clra
 clrb
 std NOSEXP,Y Set nos to zero
 std NOSMN2,Y
 sta NOSMN4,Y
 leay OPSIZE,Y Pop tos
 puls X,PC exit (carry clear)

FPMUL3 lda TOSEXP,Y Get tos expo.
 adda NOSEXP,Y Add nos expo.
 bvc FPMUL2 bra if no overflow
MULOVRF bpl FPZERO bra if too small
 comb
 ldb #M$FPOV
 puls X,PC return error

* Find Result Sign; Process Mantissa Signs
FPMUL2 sta NOSEXP,Y Save exponent
 ldb NOSMN4,Y Get multiplicand sign
 eorb TOSMN4,Y Get difference with multiplier
 andb #1 Get sign difference only
 stb TOSTYP,Y Save result sign
 lda NOSMN4,Y Get nos ls byte
 anda #$FE Strip sign bit
 sta NOSMN4,Y Replace it
 ldb TOSMN4,Y Get tos ls byte
 andb #$FE
 stb TOSMN4,Y Replace it

* Setup For Mantissa Mult
 mul
 sta ,-S Set up partial product accumulator
 clr ,-S
 clr ,-S

* 2Nd Group Partial Products
 lda NOSMN4,Y
 ldb TOSMN3,Y
 mul
 addd 1,S
 std 1,S
 bcc *+4
 inc  ,S
 lda NOSMN3,Y
 ldb TOSMN4,Y
 mul
 addd 1,S
 std 1,S
 bcc *+4
 inc  ,S
 ldb 2,S
 ldx  ,S
 stx 1,S
 clr  ,S

* 3Rd Group Partal Products
 lda NOSMN4,Y
 ldb TOSMN2,Y
 mul
 addd 1,S
 std 1,S
 bcc *+4
 inc  ,S
 lda NOSMN3,Y
 ldb TOSMN3,Y
 mul
 addd 1,S
 std 1,S
 bcc *+4
 inc  ,S
 lda NOSMN2,Y
 ldb TOSMN4,Y
 mul
 addd 1,S
 std 1,S
 bcc *+4
 inc  ,S
 ldb 2,S
 ldx  ,S
 stx 1,S
 clr  ,S

* 4Th Group Partial Products
 lda NOSMN4,Y
 ldb TOSMN1,Y
 mul
 addd 1,S
 std 1,S
 bcc *+4
 inc  ,S
 lda NOSMN3,Y
 ldb TOSMN2,Y
 mul
 addd 1,S
 std 1,S
 bcc *+4
 inc  ,S
 lda NOSMN2,Y
 ldb TOSMN3,Y
 mul
 addd 1,S
 std 1,S
 bcc *+4
 inc  ,S
 lda NOSMN1,Y
 ldb TOSMN4,Y
 mul
 addd 1,S
 std 1,S
 bcc *+4
 inc  ,S
 ldb 2,S
 ldx  ,S
 stx 1,S
 clr  ,S
 stb NOSMN4,Y

* 5Th Group Partial Products
 lda NOSMN3,Y
 ldb TOSMN1,Y
 mul
 addd 1,S
 std 1,S
 bcc *+4
 inc  ,S
 lda NOSMN2,Y
 ldb TOSMN2,Y
 mul
 addd 1,S
 std 1,S
 bcc *+4
 inc  ,S
 lda NOSMN1,Y
 ldb TOSMN3,Y
 mul
 addd 1,S
 std 1,S
 bcc *+4
 inc  ,S
 ldb 2,S
 ldx  ,S
 stx 1,S
 clr  ,S
 stb NOSMN3,Y

* 6Th Group Partial Products
 lda NOSMN2,Y
 ldb TOSMN1,Y
 mul
 addd 1,S
 std 1,S
 bcc *+4
 inc  ,S
 lda NOSMN1,Y
 ldb TOSMN2,Y
 mul
 addd 1,S
 std 1,S
 bcc *+4
 inc  ,S

* Final Partial Product
 lda NOSMN1,Y
 ldb TOSMN1,Y
 mul
 addd  ,S Add partial

* See if Result Requires Normalization
 bmi FPMUL6 Bra if no norm required
 asl NOSMN4,Y Normalize - One Bit Worst Case
 rol NOSMN3,Y
 rol 2,S
 rolb
 rola
 dec NOSEXP,Y Decr exponent
 bvs FPMUL7 Bra if overflow
FPMUL6 std NOSMN1,Y Get Result Mantissa
 lda 2,S
 ldb NOSMN3,Y

* Check For Rounding
 addd #1 Round up
 bcc FPMUL8 Bra if no carry from lsdb
 inc NOSMN2,Y Propagate carry
 bne FPMUL9
 inc NOSMN1,Y Propagate carry
 bne FPMUL9 Bra if no carry from msdb

* If round overflowed, normalize again
* Also One Bit Worst Case
 ror NOSMN1,Y Shift in old carry
 inc NOSEXP,Y
 bvc FPMUL9

* Here on Exponent Under/Overflow
FPMUL7 leas 3,S return scratch
 lbra MULOVRF

* Put In Sign and Clean Up
FPMUL8 andb #$FE Clear sign pos
FPMUL9 orb TOSTYP,Y Put in sign bit
 std NOSMN3,Y Put result on stack
 leay OPSIZE,Y Pop tos
 leas 3,S return scratch
 clrb return carry clear
 puls X,PC exit
 endc

 pag
***************
* Subroutine RLDIV
*   Floating Point Divide

* Performs Floating Point Division by altering the
*    Dividend by Adding or Subtracting Successive
*    Products of the Divisor and 1/2.

* Input: Y = Opstack ptr
* Output: Y = Opstack ptr (updated)
* Local: D,CC Destroyed
* Global:

RLDIV bsr XRLDIV execute Divide
 bcs RLDIV_ERR
RLDIV99 rts
RLDIV_ERR jsr <M.STMTS
 fcb $06

* Check For Exceptions
 ifne H6309
XRLDIV comb
 ldb #M$ZDIV
 tst TOSMN1,Y
 beq RLDIV99
 tst NOSMN1,Y
 lbeq FPZERO63
 lda NOSEXP,Y
 suba TOSEXP,Y
 lbvs MULOVRF63
 sta NOSEXP,Y
 lda #$21
 ldb TOSMN4,Y
 eorb NOSMN4,Y
 andb #1
 std ,Y
 ldq TOSMN1,Y
 lsrd
 rorw
 stq TOSMN1,Y
 ldq NOSMN1,Y
 lsrd
 rorw
 clr NOSMN4,Y
FPDV63_6F subw TOSMN3,Y
 sbcd TOSMN1,Y
 beq FPDV63_AB
 bmi FPDV63_A7
FPDV63_7E orcc #1
FPDV63_80 dec ,Y
 beq FPDV63_F8
 rol NOSMN4,Y
 rol NOSMN3,Y
 rol NOSMN2,Y
 rol NOSMN1,Y
 andcc #$FE
 rolw
 rold
 bcc FPDV63_6F
 addw TOSMN3,Y
 adcd TOSMN1,Y
 beq FPDV63_AB
 bpl FPDV63_7E
FPDV63_A7 andcc #$FE
 bra FPDV63_80
FPDV63_AB tstw
 bne FPDV63_7E
 ldb ,Y
 decb
 subb #$10
 blt FPDV63_CD
 subb #$08
 blt FPDV63_C2
 stb ,Y
 lda NOSMN4,Y
 ldb #$80
 andcc #$FE
 bra FPDV63_EB
FPDV63_C2 addb #$08
 stb ,Y
 ldw #$8000
 ldd NOSMN3,Y
 andcc #$FE
 bra FPDV63_EB
FPDV63_CD addb #$08
 blt FPDV63_DB
 stb ,Y
 ldq NOSMN2,Y
 ldf #$80
 andcc #$FE
 bra FPDV63_EB
FPDV63_DB addb #$07
 stb ,Y
 ldq NOSMN1,Y
 orcc #$01
FPDV63_E5 rolw
 rold
FPDV63_EB dec ,Y
 bpl FPDV63_E5
 tsta
 bra FPDV63_FC
FPDV63_F8 ldq NOSMN1,Y
FPDV63_FC bmi FPDV63_0C
 rolw
 rold
 dec NOSEXP,Y
 lbvs FPZERO63
FPDV63_0C addw #1
 adcd #0
 bcc FPDV63_21
 rora
 inc NOSEXP,Y
 lbvs FPZERO63
FPDV63_21 std NOSMN1,Y
 tfr w,d
 lsrb
 lslb
 orb TOSEXP,Y
 std NOSMN3,Y
 inc NOSEXP,Y
 lbvs MULOVRF63
FPDV95 leay OPSIZE,Y
 rts
 else
* Check For Exceptions
XRLDIV comb
 ldb #M$ZDIV Zero divisor error
 tst TOSMN1,Y Test divisor
 beq RLDIV99 error
 pshs X save X
 tst NOSMN1,Y Test dividend
 lbeq FPZERO Done if zero

* Get Result Exponent
 lda NOSEXP,Y Get dividend exponent
 suba TOSEXP,Y Subtract divisor exponent
 lbvs MULOVRF bra if overflow
 sta NOSEXP,Y Save result

* Set Cycle Count, Sign Flag, & Denormalize Operands
 lda #33 Set cycle count
 ldb TOSMN4,Y Get divisor sign byte
 eorb NOSMN4,Y Get difference with dividend
 andb #1 Get sign difference only
 std TOSTYP,Y Save cycle count & result sign
 lsr TOSMN1,Y Denormalize divisor
 ror TOSMN2,Y
 ror TOSMN3,Y
 ror TOSMN4,Y
 ldd NOSMN1,Y Get dividend msb
 ldx NOSMN3,Y Get dividend lsb
 lsra DENORMALIZE Dividend
 rorb
 exg D,X Lsb to D
 rora
 rorb
 clr NOSMN4,Y Clear result
 bra FPDV16 Start with subtract

* Subtract Divisor from Dividend
FPDV15 exg D,X Lsb to D
FPDV16 subd TOSMN3,Y Subtract divisor lsdb
 exg D,X Msb to D
 bcc FPDV20 bra if no borrow
 subd #1 Take borrow
FPDV20 subd TOSMN1,Y Subtract divisor msdb
 beq FPDV45 bra if possibly done
 bmi FPDV40 bra if divisor to large

* Set Bit For Result
FPDV25 orcc #carry Set carry
FPDV30 dec TOSTYP,Y Count down
 beq FPDV70 bra if done

* Shift Result & Dividend
 rol NOSMN4,Y Shift in next bit
 rol NOSMN3,Y
 rol NOSMN2,Y
 rol NOSMN1,Y
 exg D,X Lsb to D
 aslb
 rola
 exg D,X Msb to D
 rolb
 rola
 bcc FPDV15 bra if so

* Add Divisor to Dividend
 exg D,X Lsb to D
 addd TOSMN3,Y Add lsb
 exg D,X Msb to D
 bcc FPDV35
 addd #1 Propagate carry
FPDV35 addd TOSMN1,Y Add msb
 beq FPDV45
 bpl FPDV25

* Clear Bit For Result
FPDV40 andcc #^carry Clear carry
 bra FPDV30
* Check For Premature Completion
FPDV45 leax  ,X Done?
 bne FPDV25 ..No

* Check Shifting Possibilities
 ldb TOSTYP,Y Get remaining count
 decb ONLY Shift 32 times
 subb #16 Are there 16 cycles left?
 blt FPDV50 ..No
 subb #8 Are there 8 more?
 blt FPDV47 ..No

* 24 Bit Shift
 stb TOSTYP,Y Save count
 lda NOSMN4,Y Get lsb result
 ldb #$80 Get new bit
 bra FPDV64

* 16 Bit Shift
FPDV47 addb #8 Adjust count
 stb TOSTYP,Y Save count
 ldd #$8000 Get new bit
 ldx NOSMN3,Y Get msb result
 bra FPDV65
FPDV50 addb #8 Are there 8 cycles?
 blt FPDV55 ..No

* 8 Bit Shift
 stb TOSTYP,Y Save count
 ldx NOSMN2,Y Do 8 bit shift
 lda NOSMN4,Y
 ldb #$80 Get new bit
 bra FPDV65

* Plain Old Bit Shifts
FPDV55 addb #7 Fix count
 stb TOSTYP,Y Save it
 ldx NOSMN1,Y Get result
 ldd NOSMN3,Y
 orcc #carry Set carry for new bit
FPDV60 rolb DO Bit shifts
 rola
 exg D,X Msb to D
 rolb
 rola
FPDV64 exg D,X Lsb to D
FPDV65 andcc #^carry Clear carry
 dec TOSTYP,Y Count down
 bpl FPDV60 bra if more
 exg D,X Msb to D
 tsta set Condition codes for normalize
 bra FPDV75 Go finish

* Normalize
FPDV70 ldx NOSMN3,Y Get lsb result
 ldd NOSMN1,Y Get msb result
FPDV75 bmi FPDV80 bra if normalized
 exg D,X Lsb to D
 rolb SHIFT In last result bit
 rola
 exg D,X Msb to D
 rolb
 rola
 dec NOSEXP,Y Adjust exponent
 lbvs FPZERO

* Rounding
FPDV80 exg D,X Lsb to D
 addd #1
 exg D,X Msb to D
 bcc FPDV85
 addd #1 Propagate carry
 bcc FPDV85
 rora CARRIED Through whole thing!
 inc NOSEXP,Y Adjust exponent
 lbvs MULOVRF

* Set Sign & return
FPDV85 std NOSMN1,Y Save result msb
 tfr X,D Put lsb in d
 andb #$FE Clear sign bit
 orb TOSEXP,Y Set sign
FPDV90 std NOSMN3,Y

* Adjust For Result Range .5 to 1.99999
 inc NOSEXP,Y
 lbvs MULOVRF
FPDV95 leay OPSIZE,Y
 clrb return carry clear
 puls X,PC
 endc

***************
* Subroutine RLEXP
*   Real Exponentiation

* Calculates X^y by Exp(Log(X)*Y)

RLEXP pshs X Save x
 ldd 7,Y Get base exponent & msb
 beq FPDV95 return zero if base is zero
 ldx 1,Y Get power exponent & msb
 bne REXP20 bra if not zero
 leay OPSIZE,Y return one if power is zero
REXP10 ldd #$180 Store constant one
 std 1,Y
 clr 3,Y
 clr 4,Y
 clr 5,Y
 puls X,PC
REXP20 std 1,Y Exchange base & power
 stx 7,Y
 ldd 9,Y
 ldx 3,Y
 std 3,Y
 stx 9,Y
 lda 11,Y
 ldb 5,Y
 sta 5,Y
 stb 11,Y
 puls X Restore x
 lbsr LOGFNC Get log(x)
 lbsr RLMUL Get log(x)*y
 lbra EXPFNC Get exp(log(x)*y)

 ttl BOOLEAN Operand routines
 pag
***************
* Subroutine SVBOOL
*   Simple Variable; Boolean

* Same as SVBYTE

SVBOOL ldd ,X++ Get storage offset
 addd I.ASTR Make offset into ptr
 tfr D,U
* Fall Thru to BLVAR

***************
* Subroutine BLVAR
*   push Boolean Variable

* Same as BYTVAR, Except For Boolean

BLVAR ldb  ,U Get value
 clra
 leay -OPSIZE,Y make room on opstack
 std 1,Y store operand in new tos
 lda #S.BOOL push boolean
 sta  ,Y set TYPE
 rts

 ttl BOOLEAN Operation/comparison routines
 pag
***************
* Subroutine BLAND - Boolean AND
*   Performs AND of two Boolean Values

* Input: Y = Opstack ptr
* Output: Y = Opstack ptr (updated)
* Local: D,CC Destroyed
* Global: None

BLAND ldb 8,Y Load right operand
 andb 2,Y and left operand
 bra BLXOR10

***************
* Subroutine BLOR - Boolean OR
*   Performs or of two Boolean Values

* Input: Y = Opstack ptr
* Output: Y = Opstack ptr (updated)
* Local: D,CC Destroyed
* Global: None

BLOR ldb 8,Y Get second
 orb 2,Y or first
 bra BLXOR10

***************
* Subroutine BLXOR - Boolean Exclusive OR
*   Performs Exclusive or of two Boolean Values

* Input: X = Right Operand
*        Y = Left Operand
* Output: None
* Local: X,Y,D,CC Destroyed
* Global: I.OPSP updated

BLXOR ldb 8,Y Get second
 eorb 2,Y Exclusive or first
BLXOR10 leay OPSIZE,Y pop top-of-stack
 std 1,Y store result in new tos
 rts

***************
* Subroutine BLNOT - Boolean Not
*   Tos=NOT(Tos)

BLNOT com 2,Y
 rts

 pag
***************
* Subroutine STRCMP
*   String Relational Subroutine

* Compares Left String (Y) to Right String (X)
* Sets CC Bits According to Compare Result.

* Input: Y = Opstack ptr
* Output: Y = Opstack ptr (updated)
*         CC Bits According to Result
* Local: A Destroyed
* Global: I.STSP updated to Pop String Off Stack

STRCMP pshs X,Y Save regs
 ldx 1,Y Get right str ptr
 ldy 7,Y Get left str ptr
 sty I.STSP Update str stack ptr
STRCM1 lda ,Y+ Next chr of l str
 cmpa ,X+ Compare chars
 bne STRCM9 ..Exit if not equal
 cmpa #V$ESTR end of strings?
 bne STRCM1 ..No; keep checking

STRCM9 equ *
 inca note: V$ESTR must be $FF
 inc -1,X remove these 3 lines if V$ESTR equals zero
 cmpa -1,X set condition codes

 puls X,Y,PC return CC=result

***************
* String Compare Subroutines

* Called to perform relational tests on top two
* operand strings in String Stack. the two strings
* are deleted from the String Stack, and the Boolean
* result of the comparison is new TOS.

* Variables: See STRCMP

* String Compare <
STCMLT bsr STRCMP Compare strings
 bcs CMPTRU
 bra CMPFAL

* String Compare =<
STCMLE bsr STRCMP
 bls CMPTRU
 bra CMPFAL

* String Compare =
STCMEQ bsr STRCMP
 beq CMPTRU
 bra CMPFAL

* String Compare <>
STCMNE bsr STRCMP
 bne CMPTRU
 bra CMPFAL

* String Compare =>
STCMGE bsr STRCMP
 bcc CMPTRU
 bra CMPFAL

* String Compare >
STCMGT bsr STRCMP
 bhi CMPTRU
 bra CMPFAL

***************
* Subroutine INCMLT
*   Integer Compare Less Than

* Compares Nos to Tos; pushes True if Nos < Tos
*  Otherwise pushes False

* Input: Y = Opstack ptr
* Output: Y = Opstack ptr (updated)
* Local: D,CC Destroyed
* Global: Tos = Nos < Tos

INCMLT ldd 7,Y Load left operand
 subd 1,Y Subtract right operand
 blt CMPTRU if less than go push true
 bra CMPFAL Go push false

***************
* Subroutine INCMLE
*   Integer Compare Less Than or Equal To

* Compares Nos to Tos; pushes True if Nos <= Tos
*  Otherwise pushes False

* Input: Y = Opstack ptr
* Output: Y = Opstack ptr (updated)
* Local: D,CC Destroyed
* Global: Tos = Nos <= Tos

INCMLE ldd 7,Y Load left operand
 subd 1,Y Subtract right operand
 ble CMPTRU if less or equal go push true
 bra CMPFAL Go push false

***************
* Subroutine INCMNE
*   Integer Compare Not Equal

* Compares Nos to Tos; pushes True if Nos <> Tos
*  Otherwise pushes False

* Input: Y = Opstack ptr
* Output: Y = Opstack ptr (updated)
* Local: D,CC Destroyed
* Global: Tos = Nos <> Tos

INCMNE ldd 7,Y Load left operand
 subd 1,Y Subtract right operand
 bne CMPTRU if not equal go push true
 bra CMPFAL Go push false

***************
* Subroutine INCMEQ
*   Integer Compare Equal

* Compares Nos to Tos; pushes True if Nos = Tos
*  Otherwise pushes False

* Input: Y = Opstack ptr
* Output: Y = Opstack ptr (updated)
* Local: D,CC Destroyed
* Global: Tos = Nos = Tos

INCMEQ ldd 7,Y Load left operand
 subd 1,Y Subtract right operand
 beq CMPTRU if equal go push true
 bra CMPFAL Go push false

***************
* Subroutine INCMGE
*   Integer Compare Greater Than or Equal To

* Compares Nos to Tos; pushed True if Nos >= Tos
*  Otherwise pushed False

* Input: Y = Opstack ptr
* Output: Y = Opstack ptr (updated)
* Local: D,CC Destroyed
* Global: Tos = Nos >= Tos

INCMGE ldd 7,Y Load left operand
 subd 1,Y Subtract right operand
 bge CMPTRU if greater or equal go push true
 bra CMPFAL Go push false

***************
* Subroutine INCMGT
*   Integer Compare Greater Than

* Compares Nos to Tos; pushes True if Nos > Tos
*  Otherwise pushed False

* Input: Y = Opstack ptr
* Output: Y = Opstack ptr (updated)
* Local: D,CC Destroyed
* Global: Tos = Nos > Tos

INCMGT ldd 7,Y Load left operand
 subd 1,Y Subtract right operand
 ble CMPFAL if less or equal, push false
* Fall through to push true

***************
* Subroutine CMPTRU
*   Compare Result True

* Pops Tos and Set new Tos to Boolean True

* Input: Y = Opstack ptr
* Output: Y = Opstack ptr (updated)
* Local: D,CC Destroyed
* Global: None

CMPTRU ldb #V$TRUE Set up true value
 bra CMPFAL10 push result

***************
* Subroutine CMPFAL
*   Compare Result False

* Pops Tos and Set new Tos to Boolean False

* Input: Y = Opstack ptr
* Output: Y = Opstack ptr (updated)
* Local: D,CC Destroyed
* Global: None

CMPFAL ldb #V$FALS Set up false value
CMPFAL10 clra
 leay OPSIZE,Y pop top-of-stack
 std 1,Y store result in new tos
 lda #S.BOOL get TYPE
 sta  ,Y
 rts

***************
* Subroutine BLCMEQ
*   Boolean Compare Equal

* Compares two Boolean Values; pushes True if same
*  Otherwise False

* Input: Y = Opstack ptr
* Output: Y = Opstack ptr (updated)
* Local: D,CC Destroyed
* Global: None

BLCMEQ ldb 8,Y Get first
 cmpb 2,Y Compare second
 beq CMPTRU bra if equal
 bra CMPFAL

***************
* Subroutine BLCMNE
*   Boolean Compare Not Equal

* Compares two Boolean Values; pushes True if Not Same
*    Otherwise False

* Input: Y = Opstack ptr
* Output: Y = Opstack ptr (updated)
* Local: D,CC Destroyed
* Global: None

BLCMNE ldb 8,Y Get first
 cmpb 2,Y Compare second
 bne CMPTRU bra if not equal
 bra CMPFAL

***************
* Subroutine RLCMLT
*   Real Compare Less Than

* Compares two Real Values
*    pushes True if [y]<[x], Else False

* Input: Y = Opstack ptr
* Output: Y = Opstack ptr (updated)
* Local: D,CC Destroyed
* Global: None

RLCMLT bsr RLCMP Call compare
 blt CMPTRU
 bra CMPFAL

***************
* Subroutine RLCMLE
*   Real Compare Less Than or Equal

* Same as RLCMLT Except Condition is [y]<=[x]

RLCMLE bsr RLCMP Call compare
 ble CMPTRU
 bra CMPFAL

***************
* Subroutine RLCMNE
*   Real Compare Not Equal

* Same as RLCMLT Except Contition is [y]<>[x]

RLCMNE bsr RLCMP Call compare
 bne CMPTRU
 bra CMPFAL

***************
* Subroutine RLCMEQ
*   Real Compare Equal

* Same as RLCMLT Except Condition is [y]=[x]

RLCMEQ bsr RLCMP Call compare
 beq CMPTRU
 bra CMPFAL

***************
* Subroutine RLCMGE
*   Real Compare Greater Than or Equal

* Same as RLCMLT Except Condition is [y]>=[x]

RLCMGE bsr RLCMP Call compare
 bge CMPTRU
 bra CMPFAL

***************
* Subroutine RLCMGT
*   Real Compare Greater Than

* Same as RLCMLT Except Condition is [y]>[x]

RLCMGT bsr RLCMP Call compare
 bgt CMPTRU
 bra CMPFAL

***************
* Subroutine RLCMP
*   Real Compare

* Compares two Real Numbers and Sets
*    Condition Codes Accordingly

* Input: Y = Opstack ptr
* Output: Y = Opstack ptr (updated)
*         CC Set For two's comp compare branches
* Local: D Destroyed
* Global: None

RLCMP pshs Y Save opstack ptr
 andcc #$F0 Clear condition codes
 lda 8,Y Zero left operand?
 bne RLCM40 ..No
 lda 2,Y Zero right operand?
 beq RLCM30 bra if so
RLCM10 lda 5,Y Get sign byte right
RLCM15 anda #1 Get sign bit
 bne RLCM30 bra if right negative
RLCM20 andcc #$F0 Clear n, z, v, & c
 orcc #Negative
RLCM30 puls Y,PC
RLCM40 lda 2,Y Zero right operand?
 bne RLCM50 ..No
 lda 11,Y Get sign byte left
 eora #1 Flip sign
 bra RLCM15
RLCM50 lda 11,Y Get sign byte left
 eora 5,Y Get difference with sign byte right
 anda #1 Get sign bit
 bne RLCM10 bra if signs differ
 leau OPSIZE,Y
 lda 5,Y Get sign right
 anda #1 Get sign bit
 beq RLCM60 bra if positive
 exg U,Y Reverse test for negative operands
RLCM60 ldd 1,U Get exponent & mantissa (msb)
 cmpd 1,Y Compare
 bne RLCM30
 ldd 3,U Get next msdb
 cmpd 3,Y Compare
 bne RLCM70
 lda 5,U Get lsdb
 cmpa 5,Y Compare
 beq RLCM30
RLCM70 blo RLCM20 Go set less than
 andcc #$F0 Set greater than
 puls Y,PC

 ttl STRING Operand routines
 pag
***************
* Subroutine STRLIT
*   Process String Literal

* Moves String to String Stack, String addr to Opstack

* Input: X = I-Code ptr
*        Y = Opstack ptr
* Output: X = I-Code ptr (updated)
*         Y = Opstack ptr (updated)
* Local: D,CC Destroyed
* Global: I.STSP updated

STRLIT clrb 256 Max str lit len
 stb I.SIZE
STLIT1 ldu I.STSP Get string stack ptr
 leay -OPSIZE,Y Make room on opstack
 stu 1,Y Store string addr
 sty I.OPSP Mark end of free space
STLIT2 cmpu I.OPSP String stack full?
 bcc STLIT4 bra if so
 lda ,X+ Get source chr
 sta ,U+ Store at dest
 cmpa #V$ESTR
 beq STLIT3 exit if end of string
 decb
 bne STLIT2 Loop til end
 dec I.SIZE is there more?
 bpl STLIT2
 lda #V$ESTR Get end of string code
 sta ,U+ Put in string stack
STLIT3 stu I.STSP Save new string sp
 lda #S.STR Set TYPE
 sta TOSTYP,Y
 rts
STLIT4 ldb #M$STOV String overflow
 lbra EVLERR

***************
* Subroutine SVSTR
*  Simple Variable; String

* Gets simple string variable's symbol table offset, evaluates
*    expression, calculates storage addr, and stores result

* Same as SVBYTE

SVSTR ldd ,X++ Get descr area offset
 addd I.DSCR Make offset a ptr
 tfr D,U
 ldd  ,U Get storage offset
 addd I.ASTR Add procedure storage addr
 ldu 2,U Get size
 stu I.SIZE
 tfr D,U
* Fall Thru to STRVAR

***************
* Subroutine STRVAR
*   Process String Variable; Same as STRLIT

* Input: U = String ptr
*        Y = Opstack ptr
* Output: Y = Opstack ptr (updated)
* Local: D,CC Destroyed
* Global: I.STSP updated
*         Str -> Str Stack
*         TYPE, addr -> Opstack

STRVAR pshs X Save x
 ldb I.SIZE+1
 bne STRVAR10
 dec I.SIZE
STRVAR10 leax  ,U
 bsr STLIT1 push string
 puls X,PC

 ttl STRING Operation routine
 pag
***************
* Subroutine STRCAT
*   String Concatenate

* Concatenates strings in str stack and Tos, Nos ptrs
*  on Opstack to Form Single String: Nos:Tos -> Tos

* Input: Y = Opstack ptr
* Output: Y = Opstack ptr (updated)
* Local: A,CC Destroyed
* Global: I.STSP updated
*         Opstack Tos Popped

STRCAT ldu 1,Y Get right str ptr
 leay OPSIZE,Y Pop tos
STCAT2 lda ,U+ Get char
 sta -2,U Move back
 cmpa #V$ESTR
 bne STCAT2 Loop til str end
 leau -1,U Decr str sp
 stu I.STSP Save new sp
 rts

 ttl RECORD Operand routine
 pag
***************
* Subroutine RCDVAR
*   Push Record Storage addr & Size on Opstack

* Same as BYTVAR

RCDVAR ldd I.SIZE Get record size
 leay -OPSIZE,Y Make room on opstack
 std 3,Y push size
 stu 1,Y push addr
 lda #S.RCRD Set TYPE
 sta TOSTYP,Y
 rts

 ttl TYPE Conversion routines
 pag
***************
* Subroutine FLOAT, FLTTOP
*   Convert Tos from TYPE integer to real.

* Input : Y = Opstack ptr
* Global: Opstack Tos(Int) -> Tos(Real)
* Local:  D,CC Destroyed
*         Y,X,U,S Preserved

FLTTOP equ *
FLOAT
 ifne H6309
 clrd
 else
 clra
 clrb
 endc
 std 4,Y Clr lsdb mantissa
 ldd 1,Y Get integer value
 bne FLOAT1 zero?
 stb 3,Y Fast Cleanup For Zero Value
 lda #S.REAL Setup TYPE byte
 sta TOSTYP,Y Put on stack
 rts

FLOAT1 ldu #S.REAL*256+16 Trial exponent
 tsta
 bpl FLOAT2 Not negative?
 nega make Positive
 negb
 sbca #0
 inc 5,Y Set result sign bit
FLOAT2 tsta CAN We do a byte shift?
 bne FLOAT3 ..No
 ldu #S.REAL*256+8 Next trial exponent
 exg A,B Swap ms:ls
FLOAT3 tsta NEED to normalize?
 bmi FLOAT5 bra if no
FLOAT4 leau -1,U Decr exponent
 aslb
 rola shift
 bpl FLOAT4 bra if not norm. yet
FLOAT5 std 2,Y Put msdb mant on stack
 stu TOSTYP,Y Save TYPE & exponent
 rts

***************
* Subroutine FLTNEX
*   Float Next on Stack

FLTNEX leay OPSIZE,Y Set opstack ptr to nos
 bsr FLOAT
 leay -OPSIZE,Y Move ptr back to top
 rts

***************
* Subroutine FIX, FIXTOP
*   Convert Tos from Real to Integer

* Tos = Tos Rounded to Nearest Integer
* For 0 <= Abs(Tos) <= 32767; Otherwise Error

* Input:  Y = Opstack ptr
* Output: X,Y,U Preserved

FIXTOP equ *
FIX ldb 1,Y Get exponent
 bgt FIX1 Try to cnv if pos exp
 bmi FIXZER Ret 0 if neg exp
 lda 2,Y Round to 0/1 if 0 exp
 bpl FIXZER Res=0 if < .5
 ldd #1 Otherwise = 1
 bra FIX4A

FIXZER
 ifne H6309
 clrd
 else
 clra
 clrb
 endc
 bra FIX5

FIX1 subb #16 Subtr int bias
 bhi FIXERR bra if too large
 bne FIX2 bra if in range
 ldd 2,y get value
 ror 5,Y check sign
 bcc FIX5 bra if positive
 cmpd #$8000 -32768?
 bne FIXERR ..No
 tst 4,y would it round out?
 bpl FIX5 ..No
 bra FIXERR
FIX2 cmpb #-8 Can we do a byte shift?
 bhi FIX3 ..No
 pshs B Save exp
 ldd 2,Y Shift Mant 1 Byte Right
 std 3,Y
 clr 2,Y
 puls B
 addb #8 Bump exp by a byte worth
 beq FIX4 if exp=0 skip bit shift
FIX3 lsr 2,Y Bit Shift to Denormallize
 ror 3,Y
 ror 4,Y
 incb BUMP Exp
 bne FIX3 Loop if not yet norm
FIX4 ldd 2,Y Get result+round
 tst 4,Y Check remainder
 bpl FIX4A if <.5 dont round
 addd #1 Round up
 bvc FIX4A bra if no overfl

FIXERR ldb #M$ORNG Error: value out of range
 lbra EVLERR
FIX4A  ROR 5,y get sign bit
 bcc FIX5 bra if positive
 nega   make negative
 negb
 sbca #0
FIX5 std 1,Y Save int result
 lda #S.INT Get integer code
 sta TOSTYP,Y
 rts

***************
* Subroutine FIXNEX
*   Fix Next on Stack

FIXNEX leay OPSIZE,Y Move opstack ptr to nos
 bsr FIX Fix it
 leay -OPSIZE,Y Move ptr to top
 rts

***************
* Subroutine FIXTHR
*   Fix Third on Stack

FIXTHR leay OPSIZE*2,Y Move opstack ptr to third on stack
 bsr FIX
 leay -(OPSIZE*2),Y Move ptr to top
 rts

 ttl NUMERIC Intrinsic function routines
 pag
***************
* ABS(X) Function Routines

* ABS - TYPE Real
ABSFNR lda 5,Y Get ls byte
 anda #$FE Clr sign bit
 sta 5,Y Replace it
 rts

* ABS - TYPE Int
ABSFNI ldd 1,Y Get operand
 bpl ABSIN2 bra if pos
 nega
 negb
 sbca #0
 std 1,Y Repl with compl
ABSIN2 rts

***************
* PEEK(X) Function Routine
*   Tos = Byte[tos]

* Tos Must Be TYPE Integer

PEKFNC clra
 ldb [1,Y]
 std 1,Y
 rts

***************
* SGN(X) Function Routines

* For Real or Integer Tos:
*  Tos = -1 if Tos<0
*         0 if Tos=0
*         1 if Tos>0

* SGN - TYPE Real
SGNFNR lda 2,Y Get ms byte
 beq SGNZER Test - TYPE zero
 lda 5,Y Get ls byte
 anda #1 Mask sign bit
 bne SGNMIN bra if negative

SGNPLS ldb #1
 bra RETINT

* SGN For Integer
SGNFNI ldd 1,Y Get operand
 bmi SGNMIN
 bne SGNPLS
SGNZER clrb
 bra RETINT

SGNMIN ldb #-1
RETINT sex
 bra RETBYT10

***************
* ERR Function
*   Returns most recent Error Code, resetting it to Zero

ERRFNC ldb I.ERR
 clr I.ERR

RETBYT clra return Byte Result
 leay -OPSIZE,Y make room on opstack
RETBYT10 std 1,Y store operand in tos
 lda #S.INT
 sta  ,Y set TYPE
RETBYT99 rts

***************
* Fix(X) Function Routine
*   Convert Tos to TYPE Integer if Real

FIXFNI equ RETBYT99
FIXFNR equ FIX

***************
* FLOAT(X) Function
*   Convert Real or Int Tos to Real

FLTFNI equ FLOAT
FLTFNR equ RETBYT99

***************
* POS Function
*   return Print Position

POSFNC ldb I.IOCT
 bra RETBYT

***************
* Subroutine SQRFNI, SQRFNR
*   Integer or Real Square Root

SQRFNI equ *
SQRFNR ldb 5,Y Get sign byte
 asrb MOVE Sign to carry
 lbcs ILLARG bra if negative
SQRR05 ldb #31 Set cycle count
 stb I.CNTR
 ldd 1,Y Get exponent & msb
 beq RETBYT99 return zero
 inca ADJUST Exponent for even/odd test
 asra EXPONENT/2
 sta 1,Y Save it
 ldd 2,Y Get msb
 bcs SQRR10 bra if even exponent
 lsra ADJUST Mantissa for odd exponent
 rorb
 std -4,Y
 ldd 4,Y
 rora
 rorb
 bra SQRR20
SQRR10 std -4,Y Copy mantissa
 ldd 4,Y
SQRR20 std -2,Y
 ifne H6309
 clrd
 else
 clra
 clrb
 endc
 std 2,Y
 std 4,Y
 std -OPSIZE,Y Clear temporary
 std -8,Y
 bra SQRR30 Jump into loop
SQRR25 orcc #carry Set carry
 rol 5,Y Shift in result bit
 rol 4,Y
 rol 3,Y
 rol 2,Y
 dec I.CNTR Count down
 beq SQRR40 bra if done
 bsr SQRSHF Call double shifter
SQRR30 ldb -4,Y Get lsb effected
 subb #$40
 stb -4,Y
 ldd -OPSIZE,Y Get next lsb
 sbcb 5,Y Subtract result
 sbca 4,Y
 std -OPSIZE,Y
 ldd -8,Y Get msb
 sbcb 3,Y Subtract more result
 sbca 2,Y
 std -8,Y
 bpl SQRR25 bra if successful subtract
SQRR35 andcc #^carry Clear carry
 rol 5,Y Shift in next bit
 rol 4,Y
 rol 3,Y
 rol 2,Y
 dec I.CNTR Count down
 beq SQRR40 bra if done
 bsr SQRSHF Call double shifter
 ldb -4,Y Get lsb effected
 addb #$C0
 stb -4,Y
 ldd -OPSIZE,Y Get next lsb
 adcb 5,Y Add result
 adca 4,Y
 std -OPSIZE,Y
 ldd -8,Y Get msb
 adcb 3,Y
 adca 2,Y
 std -8,Y
 bmi SQRR35
 bra SQRR25
SQRR40 ldd 2,Y Get result msb
 bra SQRR50 Do last shift
SQRR45 dec 1,Y Adjust exponent
 lbvs FPZERO
SQRR50 asl 5,Y
 rol 4,Y
 rolb
 rola
 bpl SQRR45 bra if not normalized
 std 2,Y
 rts

SQRSHF bsr SQRS10
SQRS10 asl -1,Y
 rol -2,Y
 rol -3,Y
 rol -4,Y
 rol -5,Y
 rol -OPSIZE,Y
 rol -7,Y
 rol -8,Y
 rts

***************
* Subroutine MODFNI
*   Integer Mod Function

MODFNI lbsr INDIV Call integer division
 ldd 3,Y Get remainder
 std 1,Y return it
 rts

***************
* Subroutine MODFNR
*   Real Mod Function

MODFNR leau -12,Y Get ptr to temporary space
 pshs Y Save opstack ptr
MODF10 ldd ,Y++ Copy arguments
 std ,U++
 cmpu  ,S Copied enough?
 bne MODF10 ..No
 leas 2,S Scratch ptr
 leay -12,U Move opstack ptr to top of stack
 lbsr RLDIV Get a/b
 bsr INTFNR Get INT(a/b)
 lbsr RLMUL Get b*INT(a/b)
 lbra RLSUB Get a-b*INT(a/b)

***************
* Subroutine INTFNI
*   Integer Int Function

INTFNI equ FLOAT

***************
* Subroutine INTFNR
*   Real Int Function

INTFNR lda 1,Y Get exponent
 bgt INTF20 bra if arg>=1
 ifne H6309
 clrd
 else
 clra
 clrb
 endc
 std 1,Y return zero
 std 3,Y
 stb 5,Y
INTF10 rts

INTF20 cmpa #31 Are there any right of binary point?
 bcc INTF10 ..No
 leau OPSIZE,Y Get ptr to end+1 of arg
 ldb -1,U Get sign byte
 andb #1 Get sign
 pshs B,U Save sign & end ptr
 leau 1,Y
INTF30 leau 1,U Move to next byte
 suba #8 Down count
 bcc INTF30 bra if more to left of binary point
 beq INTF50 bra if exact
 ldb #$FF Make mask for byte
INTF40 aslb
 inca
 bne INTF40
 andb  ,U Clear bits to right
 stb ,U+
 bra INTF70
INTF50 leau 1,U Move to next byte
INTF60 sta ,U+ Get bits to right
INTF70 cmpu 1,S at end of number?
 bne INTF60 ..No
 puls B,U Clean stack
 orb 5,Y Set sign
 stb 5,Y
 rts

***************
* SQ(X) Function
*   Tos = Tos*Tos

SQFNCI leay -OPSIZE,Y Get next opstack
 ldd 7,Y Get value
 std 1,Y Copy it
 lbra INMUL Go do multiply

SQFNCR leay -OPSIZE,Y Carve out some opstack
 ldd 10,Y Copy tos to new tos
 std 4,Y
 ldd 8,Y
 std 2,Y
 ldd OPSIZE,Y
 std  ,Y
 lbra RLMUL Go do multiply

***************
* Subroutine VALFNC
*   Convert String to Real

VALFNC ldd I.IOBG Get I/O buffer ptrs
 ldu I.IOPT
 pshs D,U Save them
 ldd 1,Y Get ptr to string
 std I.IOBG Set I/O buffer ptrs
 std I.IOPT
 std I.STSP Pop string off string stack
 leay OPSIZE,Y Adjust opstack
 ldb #V$INRL Set code for convert to real
 lbsr J$CVIO Call conversion
 puls D,U Retrieve I/O buffer ptrs
 std I.IOBG Restore them
 stu I.IOPT
 lbcs ILLARG bra if error
 rts

***************
* Subroutine ADRFNC
*   Variable Address Function

ADRFNC lbsr EVAL20 Call eval recursively
 leay -OPSIZE,Y Make room on opstack
 stu 1,Y Store variable addr
ADRF10 lda #S.INT Set TYPE
 sta TOSTYP,Y
 leax 1,X Skip terminal TOKEN
 rts

***************
* Subroutine LNGFNC
*   Variable Length Function

VARSIZ fcb 1,2,5,1 Variable sizes

LNGFNC lbsr EVAL20 Call eval recursively
 leay -OPSIZE,Y Make room on opstack
 cmpa #S.STR What TYPE variable?
 bcc LNGF10 bra if string or record
 leau >VARSIZ,PCR Get variable size ptr
 ldb A,U Get variable size
 clra clear Msb
 bra LNGF20
LNGF10 ldd I.SIZE Get variable size
LNGF20 std 1,Y return it
 bra ADRF10

 ttl BOOLEAN Intrinsic function routines
 pag
***************
* Functions TRUFNC and FALFNC

* These are not really user functions, but a tricky way
* for the compiler and interpreter to process boolean
* literals quickly, avoiding the wierd syntactical case
* they would otherwise revert to.

* Therefore, they are argumentless functions that
* push a boolean (constant) result on OPSTACK.

TRUFNC ldd #V$TRUE Setup literal
 bra FALFN2

FALFNC ldd #V$FALS
FALFN2 leay -OPSIZE,Y make room on opstack
 std 1,Y store operand in new tos
 lda #S.BOOL push on opstack
 sta  ,Y set TYPE
 rts

 ttl LOGICAL Intrinsic function routines

 pag
***************
* NUMNOT(X) Function
*   Evaluate INT argument, returning One's complement

NOTFNC com 1,Y Complement msb
 com 2,Y Complement lsb
 rts

***************
* NUMAND(X,Y) Function
*   Numeric AND

* Evaluate Integer expressions X and Y performing
* bitwise AND.  Result is new Tos.

ANDFNC ldd 1,Y Get args
 anda 7,Y and with nos
 andb 8,Y
 bra LGCRES

***************
* NUMXOR(X,Y) Function
*   Numeric Exclusive OR

* Evaluate two Integer expressions and perform
*  bitwise Exclusive or.  Int Result is new Tos.

XORFNC ldd 1,Y Get args
 eora 7,Y XOR with nos
 eorb 8,Y
 bra LGCRES Save result + cleanup

***************
* NUMOR(X) Function
*   Numeric OR function

* Evaluate two Integer expressions and
* Perform Bitwise OR.  Int Result is new Tos.

ORFNC ldd 1,Y Get args
 ORa 7,Y or with nos
 orb 8,Y

* Save Result of Locical Function
LGCRES std 7,Y Save res at nos
 leay OPSIZE,Y Pop old tos
 rts

 ttl CORDIC Functions
 pag
 ifne INCLUDED&MATHPAK
***************
* Cordic Stack Offset Definitions

CORDX equ 0 X offset
CORDXP equ 5 X' offset
CORDY equ 10 Y offset
CORDYP equ 15 Y' offset
CORDZ equ 20 Z addr
CORDT equ 25 Test routine addr
CORDA equ 27 Angle offset
CORDSZ equ 32 Cordic temporary size

LOG10E fcb $FF,$DE,$5B,$D8,$AA

***************
* Subroutine LOG10
*  Base 10 Log

LOG10 bsr LOGFNC Get natural log
 leau >LOG10E,PCR Get constant addr
 lbsr RLVAR push on opstack
 lbra RLMUL Convert to base 10 log

***************
* Subroutine LOGFNC
*   Natural Log

LOGFNC pshs X Save x
 ldb 5,Y Get sign byte
 asrb GET Sign
 lbcs ILLARG bra if illegal
 ldd 1,Y Ln(0)?
 lbeq ILLARG bra if so
 pshs A Save exponent
 ldb #1 Set exponent to one
 stb 1,Y
 leay 6-CORDSZ,Y Make room for cordic
 leax CORDA,Y Get ptr to argument
 leau CORDX,Y
 lbsr CMOVE
 lbsr CDENOR Denormalize it
 ifne H6309
 clrd Clear cordic TEMP
 else
 clra
 clrb Clear cordic TEMP
 endc
 std CORDZ,Y
 std CORDZ+2,Y
 sta CORDZ+4,Y
 leax CLN,PCR Get addr of test routine
 stx CORDT,Y Save it
 lbsr ELCOR
 leax CORDZ,Y Get ptr to result
 leau CORDA,Y
 lbsr CMOVE
 lbsr CNORM
 leay CORDSZ-6,Y return cordic TEMP
 ldb #S.REAL Replace TYPE
 stb TOSTYP,Y
 ldb 5,Y Get sign byte
 orb #1 Make it negative
 stb 5,Y
 puls B Get argument exponent
 bsr CBLN2 Multiply by ln(2)
 puls X
 lbra RLADD Add product to cordic result

***************
* Subroutine CBLN2
*   B*Ln(2)

* Ln(2.) Constant
LN2 fcb 0,$B1,$72,$17,$F8

CBLN2 sex EXTEND Sign
 bpl CBLN10 bra if positive
 negb NEGATE Exponent
CBLN10 anda #1 Get sign bit
 pshs D Save sign, ABS(exponent)
 leau >LN2,PCR Get addr ln(2) constant
 lbsr RLVAR Move to stack
 ldb 5,Y Get lsb
 lda 1,S Get ABS(exponent)
 cmpa #1 one?
 beq CBLN40
 mul
 stb 5,Y Save lsb result
 ldb 4,Y Get next multiplicand
 sta 4,Y Save partial
 lda 1,S Get ABS(exponent)
 mul
 addb 4,Y Add partial
 adca #0 Propagate carry
 stb 4,Y Save result
 ldb 3,Y Get next multiplicand
 sta 3,Y Save partial
 lda 1,S
 mul
 addb 3,Y Add partial
 adca #0 Propagate carry
 stb 3,Y Save result
 ldb 2,Y Next multiplicand
 sta 2,Y Save partial
 lda 1,S
 mul
 addb 2,Y Add partial
 adca #0 Propagate carry
 beq CBLN30 bra if msb clear
CBLN20 inc 1,Y Increment exponent
 lsra normalize
 rorb
 ror 3,Y
 ror 4,Y
 ror 5,Y
 tsta NORMALIZE Done?
 bne CBLN20 ..No
CBLN30 stb 2,Y Save msb
 ldb 5,Y Get sign byte
CBLN40 andb #$FE Clear sign bit
 orb  ,S Set sign
 stb 5,Y Save it
 puls D,PC

***************
* Subroutine EXPFNC
*   E to the X

EXPFNC pshs X Save x
 ldb 1,Y Get exponent
 beq EXPF21 bra if zero
 cmpb #7 in computable range?
 ble EXPF10 bra if so
 ldb 5,Y Get sign byte
 rorb move sign to carry
 rorb move sign to sign
 eorb #Sign reverse sign
 lbra FPOVRF
EXPF10 cmpb #-28 too small?
 lble REXP10 return one if not
EXPF20 tstb IS Exponent positive?
 bpl EXPF25 bra if so
EXPF21 clr ,-S Clear result exponent
 ldb 5,Y Get arg sign byte
 andb #1 Ge sign
 beq EXPF50 bra if positive
 bra EXPF45 Make positive
EXPF25 lda #113 Multiply exponent by 1/ln(2)
 mul
 adda 1,Y
 ldb 5,Y Get sign byte
 andb #1 Get sign
 pshs D Save result exponent & arg sign
 eorb 5,Y Clear sign
 stb 5,Y Replace it
 ldb  ,S
EXPF30 lbsr CBLN2 Multiply new exponent by ln(2)
 lbsr RLSUB Subtract adjustment from argument
 ldb 1,Y Get result exponent
 ble EXPF40
 addb  ,S
 stb  ,S
 ldb 1,Y
 bra EXPF30
EXPF40 puls D Retrieve result exponent & arg sign
 pshs A Save result exponent
 tstb IS Arg positive
 beq EXPF50 bra if so
 nega NEGATE Exponent
 sta  ,S
 orb 5,Y Replace sign
 stb 5,Y
EXPF45 leau LN2,PCR Move constant to stack
 lbsr RLVAR
 lbsr RLADD Add constant
 dec  ,S
 ldb 5,Y Get result sign byte
 andb #1 Get sign
 bne EXPF45 bra if not positive yet
EXPF50 leay 6-CORDSZ,Y Make room for cordic
 leax CORDA,Y
 leau CORDZ,Y
 lbsr CMOVE
 lbsr CDENOR
 ldd #$1000 Initialize cordic TEMP
 std CORDX,Y
 clra
 std CORDX+2,Y
 sta CORDX+4,Y
 leax CEXP,PCR Get routine addr
 stx CORDT,Y Save it
 bsr ELCOR
 leax CORDX,Y
 leau CORDA,Y
 lbsr CMOVE
 lbsr CNORM
 leay CORDSZ-6,Y
 puls B
 addb 1,Y Add new exponent to cordic result
 bvs FPOVRF
 lda #S.REAL Replace TYPE
 std TOSTYP,Y
 puls X,PC
ELCOR lda #1 Set exponential/log flag
 sta I.HYPF
 leax LN1.2I,PCR
 stx I.ANGP
 leax >LN1END-LN1.2I,X
 stx I.ANGL
 lbra CORDIC

FPOVRF leay -6,y adjust opstack for recovery
 lbpl FPZERO return zero if too small
 ldb #M$FPOV
 lbra EVLERR

***************
* Subroutine ASNFNC
*   Trigonometric ArcSine

ASNFNC pshs X Save i-code ptr
 bsr CSIGN
 ldd 1,Y Check argument range
 lbeq SINFN4 bra if zero
 cmpd #$180 Compare to one
 bgt ASNERR bra if out of range
 bne ASNF10 ..No
 ldd 3,Y Keep checking
 bne ASNERR
 lda 5,Y
 lbeq RETPI2 return pi/2 if arg is one
ASNERR lbra ILLARG Err: illegal argument
ASNF10 lbsr ARCSUB Adjust argument
 leay 12-CORDSZ,Y Make room for cordic
 leax CORDSZ-11,Y Get x-coord ptr
 leau CORDX,Y
 lbsr CMOVE Move x-coord
 lbsr CDENOR Denormalize it
 leax CORDSZ-5,Y Get y-coord ptr
 lbra ATNSUB Get arctangent

***************
* Subroutine CSIGN
*   Set I.SIGN According to Sign of Top of Stack

CSIGN ldb 5,Y Get sign byte
 andb #1 Get sign bit
 stb I.SIGN Save it
 eorb 5,Y Get Absolute value
 stb 5,Y
 rts

***************
* Subroutine ACSFNC
*   Trigonometric ArcCosine

ACSFNC leau <ACSRET,PCR Get return addr
 pshs X,U Save i-code ptr
 bsr CSIGN
 ldd 1,Y Check for zero arg
 lbeq RETPI2 bra if so
 cmpd #$180 Compare to one
 bgt ASNERR bra if out of range
 bne ACSF10 bra if not one
 ldd 3,Y Test next two bytes
 bne ASNERR
 lda 5,Y Test last byte
 bne ASNERR
 lda I.SIGN
 bne ACSF05
 clrb
 std 1,Y
 puls X,U,PC
ACSF05 leay OPSIZE,Y
 puls X,U
 lbra PIFNC
ACSF10 bsr ARCSUB Adjust argument
 leay 12-CORDSZ,Y Make room for cordic
 leax CORDSZ-5,Y Get x-coord ptr
 leau CORDX,Y
 lbsr CMOVE
 lbsr CDENOR Denormalize it
 leax CORDSZ-11,Y Get y-coord ptr
 lbra ATNSUB Use arctangent
ACSRET lda 5,Y Get result sign
 bita #1 is it negative?
 beq ACSF25 ..No
 ldu I.ASTR Get storage ptr
 tst U.DEG,U in degree mode?
 beq ACSF15 ..No
 leau <CON180,PCR Get constant addr
 lbsr RLVAR Move to opstack
 bra ACSF20
ACSF15 lbsr PIFNC Move PI to stack
ACSF20 lbra RLADD Let add finish
ACSF25 rts

CON180 fcb 8,$B4,0,0,0  constant 180

***************
* Subroutine ARCSUB
*   Adjust Argument For ArcSine & ArcCosine

ARCSUB lda I.SIGN Save sign
 pshs A
 leay -18,Y Make room on opstack
 ldd #$201 Set constant of one
 std 12,Y
 lda #$80
 clrb
 std 14,Y
 clra
 std 16,Y
 ldd 18,Y Copy argument
 std TOSTYP,Y
 std OPSIZE,Y
 ldd 20,Y
 std 2,Y
 std 8,Y
 ldd 22,Y
 std 4,Y
 std 10,Y
 lbsr RLMUL Get arg*arg
 lbsr RLSUB Get 1-arg*arg
 lbsr SQRFNR Get sqr(1-arg*arg)
 puls A Retrieve sign
 sta I.SIGN
 rts

***************
* Subroutine ATNFNC
*   Trigonometric ArcTangent

ATNFNC pshs X Save x
 lbsr CSIGN Set sign
 ldb 1,Y Get argument exponent
 cmpb #24 is it in computable range?
 blt ATNF10 bra if so
RETPI2 leay OPSIZE,Y Pop argument
 lbsr PIFNC Return pi/2
 dec 1,Y Pi/2
 bra ATNF35
ATNF10 leay 6-CORDSZ,Y
 ldd #$1000 Set x coordinate to 1
 std CORDX,Y
 clra
 std CORDX+2,Y
 sta CORDX+4,Y
 ldb CORDA,Y Get argument exponent
 bra ATNF30
ATNF20 asr CORDX,Y Shift x
 ror CORDX+1,Y
 ror CORDX+2,Y
 ror CORDX+3,Y
 ror CORDX+4,Y
 decb ADJUST Argument exponent
ATNF30 cmpb #2 Exponent small enough?
 bgt ATNF20 ..No
 stb CORDA,Y Save it
 leax CORDA,Y
ATNSUB leau CORDY,Y
 lbsr CMOVE Move argument to y
 lbsr CDENOR Denormalize it
 ifne H6309
 clrd
 else
 clra
 clrb
 endc
 std CORDZ,Y
 std CORDZ+2,Y
 sta CORDZ+4,Y
 leax CCIRY0,PCR
 stx CORDT,Y
 lbsr CIRCOR
 leax CORDZ,Y Get result address
 leau CORDA,Y
 lbsr CMOVE Move to top
 lbsr CNORM Normalize it
 leay CORDSZ-6,Y Fix opstack
ATNF35 lda 5,Y Get sign byte
 ora I.SIGN Set sign
 sta 5,Y
ATNF40 ldu I.ASTR Get storage base
 tst U.DEG,U in radian mode?
 beq SINFN4 bra if so
 leau D180PI,PCR Convert to degrees
 lbsr RLVAR Move constant to stack
 lbsr RLMUL Multiply
 bra SINFN4

***************
* Subroutine SINFNC
*   Trigonometric Sine

SINFNC pshs X Save I-Code ptr
 lbsr TRIG Call trig function
 leax CORDY,Y Get address of y coordinate
 bsr SINFN1 Fix stack & multiply by constant
 lda 5,Y Get sign byte
SINFN2 eora I.YSGN Set y coordinate sign
SINFN3 sta 5,Y Replace it
SINFN4 lda #S.REAL Set TYPE
 sta TOSTYP,Y
 puls X,PC

SINFN1 leau CORDA,Y Get address for result
 lbsr CMOVE Call mover
 lbsr CNORM Normalize it
 leay CORDSZ-12,Y Pop extra room
 leax TRGKON,PCR Get trig constant
 leau 1,Y Get stack location
 lbsr CMOVE Move constant to stack
 lbra RLMUL Call multiply

***************
* Subroutine COSFNC
*   Trigonometric Cosine

COSFNC pshs X Save I-Code ptr
 bsr TRIG Call trig function
 leax CORDX,Y Get address of result
 bsr SINFN1 Fix stack & multiply by constant
 lda 5,Y Get sign byte
 eora I.XSGN Set x coordinate sign
 bra SINFN3

***************
* Subroutine TANFNC
*   Trigonometric Tangent

TANFNC pshs X Save I-Code ptr
 bsr TRIG Call trig cordic
 leax CORDY,Y Get address of y coordinate
 leau CORDA,Y Get address of result
 lbsr CMOVE Call mover
 lbsr CNORM Normalize it
 leax CORDX,Y Get address of result
 leay CORDSZ-12,Y Pop extra room
 leau 1,Y Get address of divisor
 lbsr CMOVE Call mover
 lbsr CNORM Normalize it
 ldd 1,Y Check for zero divisor
 bne TANF10
 leay OPSIZE,Y Pop divisor
 ldd #$7FFF Return large number
 std 1,Y
 lda #$FF
 std 3,Y
 deca clear Sign
 bra TANF20
TANF10 lbsr RLDIV
 lda 5,Y Get sign byte
TANF20 eora I.XSGN Set x coordinate sign
 bra SINFN2

***************
* Trig Constants

PI fcb $2,$C9,$0F,$DA,$A2
DPI180 fcb $FB,$8E,$FA,$35,$12
D180PI fcb $06,$E5,$2E,$E0,$D4

***************
* Subroutine PIFNC
*   Pi Constant

PIFNC leau >PI,PCR Get address of pi value
 lbra RLVAR Go push pi on stack

***************
* Subroutine TRIG
*   Set Up For Trig Cordic

* Same as SINFNC

TRIG ldu I.ASTR Get storage base
 tst U.DEG,U in radian mode?
 beq TRIG05 bra if so
 leau >DPI180,PCR Convert to radians
 lbsr RLVAR Move constant to stack
 lbsr RLMUL Multiply
TRIG05 clr I.XSGN Clear x coordinate sign
 ldb 5,Y Get argument sign byte
 andb #1 Get sign
 stb I.YSGN Use as sign of y
 eorb 5,Y Get abs value
 stb 5,Y
 bsr PIFNC Get pi
 inc 1,Y Pi*2
 lbsr RLCMP Compare arg to 2pi
 blt TRIG10
 lbsr MODFNR Get mod(arg,2pi)
 bsr PIFNC Get pi
 bra TRIG20
TRIG10 dec 1,Y Pi
TRIG20 lbsr RLCMP Compare arg to pi
 blt TRIG30
 inc I.XSGN Set x coordinate sign
 lda I.YSGN Get y coordinate sign
 eora #1 Change it
 sta I.YSGN Save it
 lbsr RLSUB
 bsr PIFNC Get pi
TRIG30 dec 1,Y Pi/2
 lbsr RLCMP Compare arg to pi/2
 ble TRIG40
 lda I.XSGN Get x coordinate sign
 eora #1 Flip it
 sta I.XSGN
 inc 1,Y Get pi
 lda 11,Y Get arg sign byte
 ora #1 Set arg sign
 sta 11,Y
 lbsr RLADD Get pi-arg
 leay -OPSIZE,Y Get spare stack room
TRIG40 leay 12-CORDSZ,Y Get room for cordic temps
 leax CCIRZ0,PCR Get test routine address
 stx CORDT,Y Put in stack
 leax CORDA,Y Get angle address
 leau CORDZ,Y Move to input location
 bsr CMOVE
 lbsr CDENOR Denormalize
 ldd #$1000 Set to one
 std CORDX,Y
 clra
 std CORDX+2,Y
 sta CORDX+4,Y
 std CORDY,Y Set to zero
 std CORDY+2,Y
 sta CORDY+4,Y
CIRCOR leax CIRANG,PCR Get circular angle table address
 stx I.ANGP
 leax >CIREND-CIRANG,X Get end of table address
 stx I.ANGL
 clr I.HYPF
* Fall Thru to Cordic

***************
* Subroutine CORDIC
*   Performs Cordic Calculations

* Input: Y = Opstack Ptr
* Output: Y = Opstack Ptr
* Local: U,X,D,CC Destroyed
* Global: I.CLC, I.Angs, I.ANGP, I.ANGL, I.BITS

CORDIC ldb #37 Set iteration count
 stb I.CLC
 clr I.BITS Set shift count
CORD10 leau CORDA,Y Get angle address
 ldx I.ANGP Get angle ptr
 cmpx I.ANGL at table end?
 bcc CORD20 bra if so
 bsr CMOVE Move to stack
 leax 5,X Move ptr
 stx I.ANGP Save it
 bra CORD30
CORD20 ldb #1 Get shift count
 bsr CSRONE Call shifter
CORD30 leax CORDX,Y Get x address
 leau CORDXP,Y Get x' address
 bsr CSR Call shifter
 tst I.HYPF is trig cordic?
 bne CORD40 ..No
 leax CORDY,Y Get y address
 leau CORDYP,Y Get y' address
 bsr CSR Call shifter
CORD40 jsr [CORDT,Y] Call routine
 inc I.BITS Increment shift count
 dec I.CLC Count down
 bne CORD10
 rts

***************
* Subroutine CMOVE
*   Move Five Bytes at X to U

* Input: X = Source Address
*        U = Destination Address
* Output: None
* Local: D,CC Destroyed
* Global: None

CMOVE pshs X,Y Save registers
 lda  ,X Get operand
 ldy 1,X
 ldx 3,X
 sta  ,U
 sty 1,U
 stx 3,U
 puls X,Y,PC

***************
* Subroutine CSR
*   Cordic Shift Right

CSR ldb  ,X Get msb
 sex GET Prime msb
 ldb I.BITS Get byte shift count
 lsrb
 lsrb
 lsrb
 bcc CSR05 bra if mod(count,8)<4
 incb
CSR05 pshs B Save it
 beq CSR2
CSR1 sta ,U+ Store msb
 decb
 bne CSR1 bra if more high order bytes
CSR2 ldb #5 Get # bytes to move
 subb ,S+
 beq CSR35 bra if none
CSR3 lda ,X+ Move x to x prime
 sta ,U+
 decb
 bne CSR3
CSR35 leau -5,U Move ptr to beginning
 ldb I.BITS Get bit shift count
 andb #7
 beq CSR5
 cmpb #4 Shift left or right?
 bcs CSRONE bra if right
 subb #8 Adjust shift count
 lda  ,X Get least significant byte
CSR4 asla shift Left
 rol 4,U
 rol 3,U
 rol 2,U
 rol 1,U
 rol  ,U
 incb
 bne CSR4 bra if not done
 rts

CSRONE asr  ,U Do bit shift
 ror 1,U
 ror 2,U
 ror 3,U
 ror 4,U
 decb ENUF Bit shifts?
 bne CSRONE ..No
CSR5 rts

***************
* Subroutine CCIRY0
*   Test For Trig Cordic, Y -> 0

CCIRY0 lda CORDY,Y Get sign y
 eora CORDX,Y
 coma
 bra CTEST

***************
* Subroutine CCIRZ0
*   Test Routine For Trig Cordic, Z -> 0

CCIRZ0 lda CORDZ,Y Get msb
* Fall Thru to CTEST

***************
* Subroutine CTEST
*   Test Value Polarity And Set Routine Addresses

* Same as Cordic

CTEST tsta ADD Y' to x?
 bpl CT10 ..No
 leax CORDX,Y Get x-coord ptr
 leau CORDYP,Y Get y-prime ptr
 bsr CADD Add (u) > (x)
 leax CORDY,Y Get y-coord ptr
 leau CORDXP,Y Get x-prime ptr
 bsr CSUB
 leax CORDZ,Y Get z-coord ptr
 leau CORDA,Y Get angle ptr
 bra CADD
CT10 leax CORDX,Y Get x-coord ptr
 leau CORDYP,Y Get y-prime ptr
 bsr CSUB Subtract (u) > (x)
 leax CORDY,Y Get y-coord ptr
 leau CORDXP,Y Get x-prime ptr
 bsr CADD
 leax CORDZ,Y Get z-coord ptr
 leau CORDA,Y Get angle ptr
 bra CSUB

***************
* Subroutine CEXP
*   Cordic Exponential

CEXP leax CORDZ,Y
 leau CORDA,Y
 bsr CSUB is trial greater than table?
 bmi CADD bra if so
 bne CEXP10 bra if not done
 ldd 1,X Done?
 bne CEXP10
 ldd 3,X
 bne CEXP10
 ldb #1
 stb I.CLC
CEXP10 leax CORDX,Y
 leau CORDXP,Y
 bra CADD

***************
* Subroutine CLN
*   Cordic Log

CLN leax CORDX,Y
 leau CORDXP,Y
 bsr CADD
 cmpa #$20
 bcc CSUB
 leax CORDZ,Y
 leau CORDA,Y
* Fall Thru to CADD

***************
* Subroutine CADD
*   Cordic Add Routine

* Input: X = Lsb+1 of Augend
*        U = Lsb+1 of Addend
* Output: X = Msb Result Address
*         U = Msb Addend Address
* Local: D,CC Destroyed
* Global: None

CADD ldd 3,X Get lsdb
 addd 3,U Add lsdb
 std 3,X
 ldd 1,X Get next msdb
 bcc CADD10
 addd #1 Propogate carry
 bcc CADD10
 inc  ,X
CADD10 addd 1,U Add next msdb
 std 1,X
 lda  ,X
 adca  ,U
 sta  ,X
 rts

***************
* Subroutine CSUB
*   Cordic Subtract

* Same as CADD

CSUB ldd 3,X Get lsdb
 subd 3,U Subtract prime lsdb
 std 3,X
 ldd 1,X Get next msdb
 bcc CSUB10
 subd #1
 bcc CSUB10
 dec  ,X
CSUB10 subd 1,U Subtract next msdb
 std 1,X
 lda  ,X Get msb
 sbca  ,U
 sta  ,X
 rts

***************
* Subroutine CDENOR
*   Denormalize Real Number For Cordic

CDENOR ldb  ,U Get exponent
 clr  ,U Clear msb
 addb #4 Adjust for current position
 bge CDEN20 bra if left shift needed
 negb MAKE Positive shift count
 lbra CSRONE Call right shifter
CDEN10 asl 4,U
 rol 3,U
 rol 2,U
 rol 1,U
 rol  ,U
 decb COUNT Shift down
CDEN20 bne CDEN10
 rts

***************
* Subroutine CNORM
*   Normalizes Result of Cordic

CNORM lda  ,U Get msb
 bpl CNOR05 bra if positive
 ifne H6309
 clrd
 else
 clra
 clrb
 endc
 std  ,U
 std 2,U
 sta 4,U
 rts
CNOR05 ldd #32*256+4 Get shift count & initial exponent
CNOR10 decb DECREMENT Exponent
 asl 4,U Shift result
 rol 3,U
 rol 2,U
 rol 1,U
 rol  ,U
 bmi CNOR20 bra if done
 deca shifted Enough?
 bne CNOR10 ..No
 clrb RETURN Zero
 std  ,U
 rts
CNOR20 lda  ,U Shuffle mantissa down
 stb  ,U Store exponent
 ldb 1,U Mantissa shuffle
 sta 1,U
 lda 2,U
 stb 2,U
 ldb 3,U
 addd #1 Round
 andb #$FE Clear sign
 std 3,U
 bcc CNOR30 bra if rounding done
 inc 2,U Propagate carry
 bne CNOR30
 inc 1,U
 bne CNOR30
 ror 1,U Overflow
 inc  ,U
CNOR30 rts

 ttl CORDIC Tables
 pag
***************
* Rotation Angle Table

CIRANG fcb $C,$90,$FD,$AA,$22 Arc tan 1.0
 fcb $7,$6B,$19,$C1,$58  "   "   .5
 fcb $3,$EB,$6E,$BF,$26  "   "   .25
 fcb $1,$FD,$5B,$A9,$AB  "   "   .125
 fcb 0,$FF,$AA,$DD,$B9  "   "   .0625
 fcb 0,$7F,$F5,$56,$EF  "   "   .03125
 fcb 0,$3F,$FE,$AA,$B7  "   "   .015625
 fcb 0,$1F,$FF,$D5,$56  "   "   .0078125
 fcb 0,$F,$FF,$FA,$AB  "   "   .00390625
 fcb 0,$7,$FF,$FF,$55
 fcb 0,$3,$FF,$FF,$EB
 fcb 0,$1,$FF,$FF,$FD
 fcb 0,$1,0,0,0
CIREND equ *

* Trig Constant
TRGKON fcb 0,$9B,$74,$ED,$A8

***************
* Exp/Log Table

LN1.2I fcb $B,$17,$21,$7F,$7E
 fcb $6,$7C,$C8,$FB,$30
 fcb $3,$91,$FE,$F8,$F3
 fcb $1,$E2,$70,$76,$E3
 fcb 0,$F8,$51,$86,$01
 fcb 0,$7E,$0A,$6C,$3A
 fcb 0,$3F,$81,$51,$62
 fcb 0,$1F,$E0,$2A,$6B
 fcb 0,$F,$F8,$05,$51
 fcb 0,$7,$FE,$00,$AA
 fcb 0,$3,$FF,$80,$15
 fcb 0,$1,$FF,$E0,$03
 fcb 0,0,$FF,$F8,$00
 fcb 0,0,$7F,$FE,$00
 fcb 0,0,$3F,$FF,$80
 fcb 0,0,$1F,$FF,$E0
 fcb 0,0,$F,$FF,$F8
 fcb 0,0,$7,$FF,$FE
 fcb 0,0,$4,0,0
LN1END equ *

 else
***************
* CORDIC Trig Functiond Deleted in this version

LOG10  equ *
LOGFNC equ *
EXPFNC equ *
ASNFNC equ *
ACSFNC equ *
ATNFNC equ *
SINFNC equ *
COSFNC equ *
TANFNC equ *
PIFNC  equ *
 ldb #M$UNIM Unimplimented Routine
 lbra EVLERR
 endc

 ttl Random Number Generator
 pag
***************
* Subroutine RNDFNC
*   Rnd(X) - Random Number Generator.

*  If X = 0 Then X = Seed'
*  If X < 0 Then Seed = ABS(X), X = Seed'
*  If X > 0 Then X = Seed'*X

*  Formula: Seed' = (A*Seed+C)Mod M

RSEED fdb $0E12,$14A2
RNDA fdb $BB40,$E62D a=3141592621
RNDC fdb $3619,$62E9 c=907633385

RNDFNC
 ifne H6309
 clrd
 else
 clra
 clrb
 endc
 std I.ACC
 std I.ACC+2
 pshs A Save sign flag
 lda 2,Y load ms byte of x
 beq RND1 if 0, take old seed,
 ldb 5,Y else look at sign bit 
 bitb #1 zero?
 bne RMOVE ..No
 com  ,S set pos flag to FF
 bra RND1 use old seed
RMOVE addb #$FE Clear sign bit
 addb 1,Y Add exponent to low byte
 lda 4,Y get byte to its left
 std I.SEED+2 and move both.
 ldd 2,Y move two low bytes, too.
 std I.SEED

* I.ACC = I.SEED * I.A
RND1 lda I.SEED+3
 ldb I.A+3
 mul D=s4*a4
 std I.ACC+2 acc3=D
 lda I.SEED+2
 ldb I.A+3
 mul D=s3*a4
 addd I.ACC+1 +acc2
 bcc RND11 if carry
 inc I.ACC then inc next byte
RND11 std I.ACC+1 acc2=D
 lda I.SEED+3
 ldb I.A+2
 mul D=s4*a3
 addd I.ACC+1 +acc2
 bcc RND12 if carry
 inc I.ACC then inc next byte
RND12 std I.ACC+1 acc2=D
 lda I.SEED+1
 ldb I.A+3
 mul D=s2*a4
 addd I.ACC +acc1
 std I.ACC acc1=D
 lda I.SEED+2
 ldb I.A+2
 mul D=s3*a3
 addd I.ACC +acc1
 std I.ACC acc1=D
 lda I.SEED+3
 ldb I.A+1
 mul D=s4*a2
 addd I.ACC +acc1
 std I.ACC acc1=D
 lda I.SEED
 ldb I.A+3
 mul D=s1*a4
 addb I.ACC +acc1(1 byte)
 stb I.ACC acc1=B
 lda I.SEED+1
 ldb I.A+2
 mul D=s2*a3
 addb I.ACC +acc1(1 byte)
 stb I.ACC acc1=B
 lda I.SEED+2
 ldb I.A+1
 mul D=s3*a2
 addb I.ACC +acc1(1 byte)
 stb I.ACC
 lda I.SEED+3
 ldb I.A
 mul D=s4*a1
 addb I.ACC
 stb I.ACC
* I.SEED = I.ACC + I.C
 ldd I.ACC+2 add low two bytes
 addd I.C+2
 std I.SEED+2 and use as new seed
 ldd I.ACC
 adcb I.C+1 add high two bytes
 adca I.C
 std I.SEED
 tst ,S+ was arg positive?
 bne RND2 ..Yes; go multiply
 ldd I.SEED else move seed
 std 2,Y to stack -- it's the result
 ldd I.SEED+2
 std 4,Y
 clr 1,Y

* Normalize the Result
RNDNOR lda #31 set shift counter
 pshs A
 ldd 2,Y get high double-byte
 bmi RNDNR2 if normalized, exit
RNDNR1 dec  ,S 31 iterations?
 beq RNDNR2 ..Yes; exit
 dec 1,Y decrement exponent
 asl 5,Y rotate all four bytes
 rol 4,Y
 rolb
 rola
 bpl RNDNR1 repeat
RNDNR2 std 2,Y store high double-byte
 ldb 5,Y Clear sign
 andb #$FE
 stb 5,Y
 puls B,PC Clean stack & return
RND2 ldd I.SEED+2 Get seed
 andb #$FE clear sign
 std ,--Y and put it on
 ldd I.SEED the operand stack
 std ,--Y
 ifne H6309
 clrd
 else
 clra
 clrb
 endc
 std ,--Y
 bsr RNDNOR normalize before mult
 lbra RLMUL mult random num by arg

 ttl STRING Intrinsic function routines
 pag
***************
* Subroutine LENFNC
*   Len(A$) Function

* Return Integer Length of Str(Tos) as Tos

LENFNC ldd I.STSP Get string stack ptr
 ldu 1,Y Get string ptr
 subd 1,Y Get string length
 subd #1 Dont count end-of-string byte
 stu I.STSP Pop it
LENF10 std 1,Y Put length on opstack
 lda #S.INT Change TYPE byte to int
 sta TOSTYP,Y
 rts

***************
* Subroutine ASCFNC
*   ASC(A$) Function

* Evaluate the String Argument.  Get the ASCII Value
*  of its first character and make Integer Tos.

ASCFNC ldd 1,Y Get beg addr in strstack
 std I.STSP Pop it
 ldb [1,Y] Get 1st char of str
 clra CLR Hi byte
 bra LENF10 Go finish

***************
* Subroutine CHRFNC
*   Chr$(N) Function

* Evaluate integer argument and use the result as
* an ASCII character code which is put in Str Stack.

CHRFNC ldd 1,Y
 tsta
 lbne ILLARG If msb<>0 we cant do ascii
 ldu I.STSP Get strstack ptr
 stu 1,Y Put str addr on opstack
 stb ,U+ Put char in strstack
 lbsr ENDS00 Setup str delimiter
 sty I.OPSP Mark end of free space
 cmpu I.OPSP Str stack overflow?
 lbcc STLIT4 If so abort
 rts

***************
* Subroutine LFTFNC
*   LEFT$(A$,N) Function

* Evaluate string and numeric arguments. Replace string
* arg with leftmost N characters.  If A$ is not long enough,
* return whatever is there.

LFTFNC ldd 1,Y Get number of chars needed
 ble RETNUL exit if zero or less
 addd 7,Y Add address of string
 tfr D,U Ritterize u with d
 cmpd I.STSP Will it be longer than original?
 bhs LFTFN2 If so old str will do
 bsr TRMFN3 setup string delimiter
LFTFN2 leay OPSIZE,Y Pop old int arg
 rts

RETNUL leay OPSIZE,Y
 ldu 1,Y
 bra TRMFN3 setup string delimiter

***************
* Subroutine RGTFNC
*   Right$(A$,N) Function

* Evaluate the String And Numeric Arguments. Return the
* Rightmost N Chars of A$.  If A$ is too Short, return
* whatever was obtained in A$.

RGTFNC ldd 1,Y Get # of chars needed
 ble RETNUL bra if zero or less
 pshs X Save x
 ldd I.STSP Get string stack ptr
 subd 1,Y Subtract # of chars
 subd #1 Dont count end-of-string
 cmpd 7,Y Need more than there are?
 bls RGTFN2 Yes; return entire string
 tfr D,X
 ldu 7,Y Get string address
RGTFN1 lda ,X+ Move string
 sta ,U+
 cmpa #V$ESTR
 bne RGTFN1 Loop til done
 stu I.STSP Update strstack ptr
RGTFN2 leay OPSIZE,Y Pop num arg
 puls X,PC

***************
* Subroutine MIDFNC
*   MID$(A$,M,N) Function
*
* Evaluate one string and two integer arguments.  Return
* the part of A$ beginning with the Mth character and
* extending for N characters.  If LEN(A$) < M return null
* string.  If LEN(A$)+-M < N return all chars  after the Mth
* position.  Result is Tos.


MIDFNC ldd 1,Y Get # of chars needed
 ble MIDFN1 bra if zero or less
 ldd 7,Y Get offset count
 bgt MIDFN2 bra if greater than zerp
MIDFN1 ldd 1,Y Get # needed
 leay OPSIZE,Y Dump offset
 std 1,Y Replace # needed
 bra LFTFNC
MIDFN2 subd #1 Shift from 1,2,3.. to 0,1,2..
 beq MIDFN1 bra if offset zero
 addd 13,Y Add string address
 cmpd I.STSP Are there enough?
 bcs MIDFN3 bra if so
 leay OPSIZE,Y Pop one arg
 bra RETNUL
MIDFN3 pshs X Save x
 tfr D,X
 ldb 2,Y Get # needed lsb
 ldu 13,Y Get string address
MIDFN4 lda ,X+
 sta ,U+
 cmpa #V$ESTR
 beq MIDFN5
 decb
 bne MIDFN4
 dec 1,Y
 bpl MIDFN4
 lda #V$ESTR
 sta ,U+
MIDFN5 stu I.STSP
 leay 12,Y
 puls X,PC

***************
* Subroutine TRMFNC
*   TRIM$(A$) Function

* Evaluate string arg and return it as Tos less any
*  trailing spaces which it may have had.

TRMFNC ldu I.STSP Get end addr + 1 of str arg
 leau -1,U Backup to delim
TRMFN2 cmpu 1,Y at beg of str yet?
 beq TRMFN3 If so we're done
 lda ,-U Get chars backwards
 cmpa #V$SPAC is it a space?
 beq TRMFN2 If so do it again
 leau 1,U Move up to delim pos
TRMFN3 lda #V$ESTR Get delim
 sta ,U+ Mark end
 stu I.STSP Update strstack ptr
 rts

***************
* Subroutine SUBFNC
*   Search String For a Pattern

SUBFNC pshs X,Y Save registers
 ldd I.STSP Get ptr to end of string
 subd 1,Y Get size of string
 addd 7,Y Make ptr to end of string - length pattern
 addd #1
 ldx 7,Y Get ptr to pattern
 ldy 1,Y Get ptr to string
 lbsr J$SBST Call search
 bcc SUBF10 bra if found
 ifne H6309
 clrd
 else
 clra
 clrb
 endc
 bra SUBF20
SUBF10 tfr Y,D Copy ptr to where found
 ldx 2,S Get opstack ptr
 subd 1,X Get position
 addd #1 Convert from 0,1,2,.. to 1,2,3,..
SUBF20 puls X,Y Restore registers
 std 7,Y Return position
 lda #S.INT Set TYPE
 sta OPSIZE,Y
 leay OPSIZE,Y Pop second arg
 rts

***************
* Subroutine STRFNI
*   Convert Integer to String

STRFNI ldb #V$PRIN Get print integer code
 bra STRF10

***************
* Subroutine STRFNR
*   Convert Real to String

STRFNR ldb #V$PRRL Get print real code
STRF10 lda I.IOCT Get position count
 ldu I.IOPT
 pshs A,X,U Save regs
 lbsr J$CVIO Call conversion
 bcs ILLARG bra if error
 ldx I.IOPT
 lda #V$ESTR
 sta  ,X insert string terminator
 ldx 3,S get addr of converted string
 lbsr STRLIT move string to String buffer
 puls A,X,U
 sta I.IOCT Restore I/O state
 stu I.IOPT
 rts

ILLARG ldb #M$IARG Set error code
 lbra J$STER

***************
* Subroutine TABFNC
*   TAB(N) Function

* Returns a string of spaces corresponding to the number
* required to fill the output buffer to column N.

TABFNC pshs X Save I-Code ptr
 ldd 1,Y Get position
 blt ILLARG Error if negative
 sty I.OPSP Mark end of free space
 ldu I.STSP Get string stack ptr
 stu 1,Y Put on opstack
 lda #V$SPAC Load space char
TABF10 cmpb I.IOCT is position past tab?
 bls ENDSTR bra if so
 sta ,U+ Put space in str stack
 decb
 cmpu I.OPSP String stack overflow?
 bcs TABF10 ..No
 lbra STLIT4

ENDS00 pshs X
ENDSTR lda #V$ESTR Mark end of string
 sta ,U+
 stu I.STSP Update sstr sp global
 lda #S.STR Put string TYPE byte on stack
 sta TOSTYP,Y
 puls X,PC

***************
* Subroutine DATFNC
*   Returns current system date as "yy/mm/dd hh:mm:ss"

DATFNC pshs X Save I-Code ptr
 leay -OPSIZE,Y Make room on opstack
 leax -OPSIZE,Y Get scratch for time
 ldu I.STSP Get string stack ptr
 stu 1,Y Set beginning of string
 OS9 F$TIME Get system time
 bcs ENDSTR Return blank if none
 bsr DATC05 Convert year
 lda #'/
 bsr DATCNV Convert month
 lda #'/
 bsr DATCNV Convert day
 lda #V$SPAC
 bsr DATCNV Convert hour
 lda #':
 bsr DATCNV Convert minute
 lda #':
 bsr DATCNV Convert second
 bra ENDSTR

DATCNV sta ,U+ Insert delimiter
DATC05 lda ,X+ Get binary byte
 ldb #'0-1 Prime ascii byte
DATC10 incb
 suba #10
 bcc DATC10
 stb ,U+
 ldb #'9+1
DATC20 decb
 inca
 bne DATC20
 stb ,U+
 rts

***************
* Subroutine EOFFNC
*   End-of-File Function

EOFFNC lda TOSINT+1,Y Get path number
 ldb #SS.EOF Get status code
 OS9 I$GetStt Get path status
 bcc EOFF10 bra if not eof
 cmpb #E$EOF End of file?
 bne EOFF10 ..no; return false
 ldb #V$TRUE
 bra EOFF20
EOFF10 ldb #V$FALS
EOFF20 clra
 std TOSINT,Y
 lda #S.BOOL
 sta TOSTYP,Y Set TYPE
 rts

 ttl Initialization
 pag
***************
* Subroutine INIT
*   Initialize interpreter
INIT ldb #6 Set move count
 pshs B,X,Y
 tfr DP,A Make direct page ptr
 ldb #I.SEED
 tfr D,Y
 leax RSEED,PCR Get ptr to random initial values
INIT1 ldd ,X++ Copy values
 std ,Y++
 dec  ,S Count down
 bne INIT1
 leax OPRTBL,PCR Get exprssion dispatch table
 stx D.IOPD Set it
 leax VREFDT,PCR Get variable reference dispatch
 stx D.IVRF Set it
 lda #$7E Get jump opcode
 sta J$EVAL
 leax EVAL,PCR Get entry address
 stx J$EVAL+1 Set jump to it

 ifne INCLUDED&EDITOR
 leax J$TEXP,PCR Get trace expression entry
 stx J$EVAL+3
 endc
 puls B,X,Y,PC

* End of Exprsn

