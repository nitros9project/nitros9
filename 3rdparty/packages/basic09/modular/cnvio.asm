
 nam CNVIO
 use DEFS

 ttl External Linkage
 pag
 use LINKAGE

***************
* Global Entry Points

CNVENT equ *
 fdb ASCNUM-CNVENT
 fdb IOFUNC-CNVENT

***************
* External Subroutine References

J$FIX jsr M.EXPRSN
 fcb X$FIX  Fix real
J$FLOT jsr M.EXPRSN
 fcb X$FLOT Float integer
J$FDIV jsr M.EXPRSN
 fcb X$FDIV Real divide
J$FMUL jsr M.EXPRSN
 fcb X$FMUL Real multiply

 ttl Constant Tables
 pag
***************
* I/O Function Request Dispatcher
*   Enter with code in (B
*
IOFUNC pshs D,X,PC
 aslb
 leax <T$IO,PCR Get tbl addr
 ldd B,X
 leax D,X
 stx 4,S
 puls D,X,PC

* I/O Dispatch Table
T$IO equ *
 fdb OUTLIN-T$IO
 fdb OUTINT-T$IO
 fdb OUTINT-T$IO
 fdb OUTRL-T$IO
 fdb OUTBL-T$IO
 fdb STROUT-T$IO
 fdb INPLIN-T$IO
 fdb INPBYT-T$IO
 fdb INPINT-T$IO
 fdb INPRL-T$IO
 fdb INPBL-T$IO
 fdb STRINP-T$IO
 fdb OUTCR-T$IO
 fdb SKPZON-T$IO
 fdb SEEK-T$IO
 fdb UNIMPL-T$IO Status
 fdb OUTTAB-T$IO
 fdb NXTFMT-T$IO
 fdb OUTCHR-T$IO
 fdb EXCFMT-T$IO
 fdb OUTHEX-T$IO

* Integer Powers of Ten Table
T$ITEN equ *
 fdb 10000
 fdb 1000
 fdb 100
 fdb 10

* Positive real Powers of 10 - 10E1 to 10E19
T$RL10 equ *
 fcb $04,$A0,0,0,0
 fcb $07,$C8,0,0,0
 fcb $0A,$FA,0,0,0
 fcb $0E,$9C,$40,0,0
 fcb $11,$C3,$50,0,0
 fcb $14,$F4,$24,0,0
 fcb $18,$98,$96,$80,0
 fcb $1B,$BE,$BC,$20,0
 fcb $1E,$EE,$6B,$28,0
 fcb $22,$95,$02,$F9,0
 fcb $25,$BA,$43,$B7,$40
 fcb $28,$E8,$D4,$A5,$10
 fcb $2C,$91,$84,$E7,$2A
 fcb $2F,$B5,$E6,$20,$F4
 fcb $32,$E3,$5F,$A9,$32
 fcb $36,$8E,$1B,$C9,$C0
 fcb $39,$B1,$A2,$BC,$2E
 fcb $3C,$DE,$0B,$6B,$3A
T$RL19 fcb $40,$8A,$C7,$23,$04

* Literal String for Boolean Values
T$TRUE fcc "True"
Len.True equ *-T$TRUE
 fcb V$ESTR
T$FALS fcc "False"
Len.Fals equ *-T$FALS
 fcb V$ESTR

 ttl ASCII to binary conversion
 pag
***************
* Subroutine ASCNUM
*   Convert ASCII String to Numeric

* The syntax for the source string is:
*   [-] [<int>] [.] [<frac>]  [E [<+/->] <exp>]

* The result is pushed on Opstack.  It will be of TYPE
*  real, unless the number has neither a decimal point
*  or exponent and is within the range of integers.

* The range and syntax of the source string is checked
* and error status is returned when appropriate.

* Input: [x] String to Convert
* Output: Num -> Tos
*         CC carry Set if Error
*         [x] = next byte Past Num String
*         A = Result TYPE Code
* Global: I.OPSP updated
*         Item Added to Opstack
* Local:  D,CC Destroyed

* Opstack offsets
TYPBYT equ 0 TYPE byte
BINEXP equ 1 exponent
MANT0  equ 2 MS byte mantissa
MANT1  equ 3 NS byte mantissa
MANT2  equ 4 NS byte mantissa
MANT3  equ 5 LS bye mantissa

* Initialize
ASCNUM pshs U save ureg
 leay -6,Y Room for new item on opstack
 clra
 clrb
 sta I.ESGN Clr exp sign
 sta I.DCNT Clr dig count
 sta I.DPFL Clr dec pt flag
 sta I.MSGN Clr mant sign
 sta I.DEXP Clr decimal exp
 std MANT2,Y Clr mantissa
 std MANT0,Y
 sta BINEXP,Y
* Skip Leading Spaces + Return Int Zero
* if Delimiter Found
 lbsr SKPDL1
 bcc ASCNM1 bra no delimiter
 leax -1,X Back up to delimiter
 cmpa #', Comma delimiter?
 bne NFERR Numeric format error if not
 lbra ASNIN1 Finish as integer if so
ASCNM1 cmpa #'$ Hex?
 lbeq INPHEX Goto hex routine if so
 cmpa #'+ Plus?
 beq ASCNM2
 cmpa #'- Minus?
 bne ASCNM3
 inc I.MSGN Set mant sgn neg
* Process Mantissa or Integer
ASCNM2 lda ,X+ Get next char
ASCNM3 cmpa #'. Dec pt?
 bne ASCNM4
 tst I.DPFL First one found?
 bne NFERR Format error if not
 inc I.DPFL Set dp flag
 bra ASCNM2
* Process digit
ASCNM4 lbsr CHKDIG Check that char is digit
 bcs ASCNM7 bra if not
* Add Current digit to Partial Mantissa
* T = T*10+D
ASCNM5 pshs A save digit val
 inc I.DCNT Incr digit count
 ldd MANT2,Y Get mant ls bytes
 ldu MANT0,Y Get mant lsdb
 bsr ROT32L Shift: t*2
 std MANT2,Y
 stu MANT0,Y save t*2
 bsr ROT32L T*2*2
 bsr ROT32L T*2*2*2 = t*8
 addd MANT2,Y
 exg D,U Swap ms:ls bytes
 adcb MANT1,Y T=t*8+t*2 = t*10
 adca MANT0,Y
 bcs NRERR1
 exg D,U Swap ms:ls
 addb ,S+ Add in new digit val
 adca #0 T*10+d
 bcc ASCNM6
 leau 1,U Inc MS bytes
 stu MANT0,Y Set cc zero bit
 beq NRERR Bra if overfl
ASCNM6 std MANT2,Y save TEMP ls bytes
 stu MANT0,Y save TEMP MS bytes
 tst I.DPFL in frac part?
 beq ASCNM2 Get another char if not
 inc I.DEXP Bump exponent
 bra ASCNM2

* Aux subroutine to Shift D:U Left 1 Bit
* (32 Bit Multiply by Two)

ROT32L aslb
 rola
 exg D,U
 rolb
 rola
 exg D,U
 bcs ROT32E Error if overfl
 rts
ROT32E leas 2,s dont return
NRERR1 leas 1,s return scratch

* Error Exits - Clean Up Stack
* and Return Status

* Range Error
NRERR ldb #M$NRNG Error code
 bra NEXIT

* Format Error
NFERR ldb #M$NFMT
NEXIT stb I.ERR
 coma
 puls U,PC

* Process Non-digit char
ASCNM7 eora #'E exp char?
 anda #^('a-'A) (upper or lower case e?)
 beq ASNEX1
 leax -1,X Back up buffer ptr
 tst I.DCNT Did we get digits?
 bne ASCN75
 bra NFERR Too bad

* Ascertain Result Range and Go To
* Associated Final Processing
* for Integer or real Result

ASCN75 tst I.DPFL Did we get dec. pt.?
 bne ASNRL1 Has to be TYPE real
 ldd MANT0,Y Get mant hi bytes
 bne ASNRL1 if not 0 must be real

* Final Processing for TYPE Integer
ASNIN1 ldd MANT2,Y Get ls bytes mantissa
 bmi ASNRL1 bra if out of integer range
 tst I.MSGN Check sign flag
 beq ASNIN2 Bra if result positive
 nega complement Result
 negb
 sbca #0
ASNIN2 std 1,Y Put res on opstack
ASNIN3 lda #S.INT Get TYPE code for integer
 lbra OKEXIT

* Process "E Form" Decimal exponent
ASNEX1 lda  ,X Get next char
 cmpa #'+ Plus sign?
 beq ASNEX2
 cmpa #'- Minus sign?
 bne ASNEX3
 inc I.ESGN Set neg exp flag
ASNEX2 leax 1,X Skip it
ASNEX3 lbsr TSTDIG
 bcs NFERR
 tfr A,B
 lbsr TSTDIG
 bcc ASNEX5
 leax -1,X
 bra ASNEX6
ASNEX5 pshs A
 lda #10
 mul
 addb ,S+
ASNEX6 tst I.ESGN Check sign of exp
 bne ASNEX7
 negb complement exp
ASNEX7 addb I.DEXP Add to part exp
 stb I.DEXP ..and save for later use


* Post-Processing for real numbers
*
* At This Point Mant[0:3] Has the Manissa
* in Integer Binary Format, I.DEXP is
* A Binary Representation of the Decimal
* exponent, and I.MSGN, I.ESGN Are their
* Respective Signs.
*
* the Following Routine Normalizes the Mantissa
* to A Binary Fraction/exponent and Compensates
* for the Decimal exponent by A Table Lookup of
* the Corresponding Binary Equivalent

ASNRL1 ldb #32 Trial exponent
 stb BINEXP,Y
 ldd MANT0,Y Get MS bytes exponent
 bne ASNRL3 Bra to norm if <>0
 cmpd MANT2,Y Check ls bytes
 bne ASNRL3 Test MS bytes
 clr BINEXP,Y number is zero
 bra ASNRL9
* Normalize Mantissa
ASNRL3 tsta
 bmi ASNRL5 Bra when normalized
ASNRL4 dec BINEXP,Y Decr exponent
 asl MANT3,Y
 rol MANT2,Y
 rolb
 rola
 bpl ASNRL4 Loop til normallized
ASNRL5 std MANT0,Y Replace mantissa MS bytes
* Look Up Decimal exponent Equivalent
* Binary Value
 clr I.ESGN Clear exp sign flag
 ldb I.DEXP Get dec exponent
 beq ASNRL8 if zero no adj needed
 bpl ASNRL6 exp must be pos ..
 negb make exp postive
 inc I.ESGN Set neg exp flag
ASNRL6 cmpb #19 Dec exp in tbl range?
 bls ASNRL7 Bra if ok
 subb #19 Reduce range otherwise
 pshs B save current exp
 leau >T$RL19,PCR Get add of const 1e+19
 bsr CNVOPR ..and reduce range ..
 puls B Restore exp and proceed
 lbcs NRERR ..exit if oper overflowed
ASNRL7 decb remove Bias from exp
 lda #5 Num bytes/entry in table
 mul CALC Tble entry addr
 leau T$RL10,PCR Get constant tbl addr
 leau B,U Add in entry offset
 bsr CNVOPR and reduce range (mult/div)
 lbcs NRERR Range error ..
ASNRL8 lda MANT3,Y Get ls byte mant
 anda #$FE
 ora I.MSGN Put in sign bit
 sta MANT3,Y
ASNRL9 lda #S.REAL Get TYPE byte
OKEXIT sta TYPBYT,Y
 andcc #$FE
 puls U,PC

***************
* Subroutine to copy constant from [U] Table ptr
* to Opstack and Perform real Multiply Or
* Divide, Depending on exponent Sign (I.Esgn)
CNVOPR leay -6,Y Room for new entry on opstack
 ldd  ,U
 std 1,Y
 ldd 2,U
 std 3,Y
 ldb 4,U
 stb 5,Y
 lda I.ESGN Get exp sign
 lbeq J$FDIV Do divide if pos
 lbra J$FMUL else do multiply

***************
* Subroutine INHEX
* Routine to Convert Hex Numeric Input
* (Still ASCNUM Main Routine)

INPHEX lbsr TSTDIG Get next char, chk if digit
 bcc INHEX3 Bra if good
 cmpa #'a Lower case?
 blo INHEX1 ..no; continue
 suba #'a-'A Shift to upper case
INHEX1 cmpa #'A
 blo INHEX5 Check for a-f
 cmpa #'F
 bhi INHEX5
 suba #$37 Make binary
INHEX3 inc I.DCNT Bump dig cnt
 ldb #4 Setup shift cnt
INHEX4 asl 2,Y
 rol 1,Y
 lbcs NRERR Exit on range error
 decb
 bne INHEX4
 adda 2,Y Add new digit
 sta 2,Y
 bra INPHEX
* Clean Up
INHEX5 leax -1,X Backup ptr
 tst I.DCNT Any digits?
 lbeq NFERR Error if not
 lbra ASNIN3 Return integer


 ttl INPUT Conversion and processing
 pag
* Subroutine INPRL
*
* Look for and Convert a real number from
* the Current Location in the I/O buffer.
*
* Input:  Y = Opstack ptr
*         Inp Str in I/O buffer
*
* Output: Res on Opstack
*         Y = Y-6 (New Entry)
*         CC = carry Clr if No Error
*               carry and I.ERR Set if Error
*
* Global: I.IOPT = Moved to 1St byte Past Input Str
*
INPRL pshs X
 ldx I.IOPT Get I/O ptr
 lbsr ASCNUM Call conv subr
 bcc INPRL2 Bra if no error
ITYPER puls X,PC Exit if ERR
INPRL2 cmpa #S.REAL Result real?
 beq INPRL3
 lbsr J$FLOT if not convert from int
INPRL3 lbsr SKPDEL Check past end
 bcs INPRL4 Bra if delim found
 ldb #M$IFMT
 stb I.ERR
 coma
 puls X,PC too bad
INPRL4 stx I.IOPT
 clra
 puls X,PC

* Subroutine INPBYT
*
* Look for and Convert Integer in 0-255 Range
*
* Parameters Identical to INPRL
*
INPBYT pshs X save x
 ldx I.IOPT Get I/O ptr
 lbsr ASCNUM Call cnv subr
 bcs ITYPER
 cmpa #S.INT Was int found?
 bne INPIN1 ERR if not
 tst 1,Y Check msb
 beq INPRL3 in range if zero
 bra INPIN1

* Subroutine INPINT
*
* Look for and Convert Integer from
* Current Position in Input buffer.
*
* Parameters Identical to INPRL
*
INPINT pshs X
 ldx I.IOPT
 lbsr ASCNUM Call cnv subr
 bcs ITYPER Exit if error
 cmpa #S.INT Was result int?
 beq INPRL3 Goto clean up if ok
INPIN1 ldb #M$INTM
 stb I.ERR
 coma
 puls X,PC

* Subroutine STRINP
*
* Input a String from the Current Location
* in the I/O buffer.  Output is Added To
* Stringstack, Opstack.  String is Delimited
* by A Comma or Cr.

STRINP pshs U,X
 leay -6,Y Make room on opstack
 ldu I.STBG Get str stack ptr
 stu 1,Y and put ptr on stack
 lda #S.STR then the TYPE code
 sta  ,Y
 ldx I.IOPT Get I/O buf ptr
INPST2 lda ,X+ Get input char
 bsr SKPDL2 Call delim test
 bcs INPST4 Exit move loop if delim
INPST3 sta ,U+ Move char to str stack
 bra INPST2
INPST4 stx I.IOPT Repl I/O ptr
 lda #V$ESTR Get end str char
 sta ,U+ Store it
 stu I.STSP Update the ptr
 clra
 puls X,U,PC

***************
* Subroutine INPBL

* Look for a boolean value in the I/O buffer.  The
* input must be a single character 'T or 'F.  Null
* input defaults to F.  Result returned on Opstack.

INPBL pshs X
 leay -6,Y Carve out room on opstack
 lda #S.BOOL
 sta  ,Y Set TYPE byte
 clr 2,Y Set res to false
 ldx I.IOPT
 bsr SKPDL1 Skip leading crap
 bcs INPBL4 Default if we hit delim
 cmpa #'T True?
 beq INPB25 Bra if so
 cmpa #'t Lower case t?
 beq INPB25 Bra if so
 eora #'F It better be false ..
 anda #^('a-'A) (or lower case false)
 beq INPBL3 Bra if so
 ldb #M$INTM
 stb I.ERR
 coma
 puls X,PC

INPB25 com 2,Y Make result true
INPBL3 bsr SKPDEL Look for end delim
 bcc INPBL3 Skip until delimiter encountered
INPBL4 stx I.IOPT
 clra
 puls X,PC

* Subroutine SKPDEL
*
* Load X With I/O Bufptr.  Skip Any Spaces.
* Look for Delimiters Cr, Comma on Endstr
* and Set carry if Found.  Will Not Adv Past
* Cr on Endstr.  if No Delim Found Return C
* Bit Clr and Last char Found in (A).

SKPDEL lda ,X+ Get current char
 cmpa #V$SPAC is it a space
 bne SKPDL2 Cont check if not
 bsr SKPDL1 Process more
 bcc SKPDL3 Back up if only spaces found
 bra SKPDL4
SKPDL1 lda ,X+ Get next char
 cmpa #V$SPAC Space?
 beq SKPDL1 if so scan more
SKPDL2 cmpa InpSprtr item separator?
 beq SKPDL4 Done if so
 cmpa #V$CR
 beq SKPDL3
 cmpa #V$ESTR
 beq SKPDL3
 andcc #$FE
 rts
SKPDL3 leax -1,X Back up ptr
SKPDL4 orcc #1
 rts

* Subroutine INTSTR
*
* Convert Integer to Decimal ASCII
* String.  Uses Subtract/Restore Method
* Using A Powers-of-Ten Constant Table.
* Returns Only Significant digits.
*
* Input: Y = Opstack ptr - number is Tos
*        X = Addr to Store Output Str
*
* Output: Converted number At X,X+N
*         I.DCNT = digit Count
*         I.MSGN = Sign of Result
*         Y = Opstack ptr, number Converted Popped
* Local:  D,CC Destroyed

ZFLG equ 3 offset for TEMP on opstack

INTSTR pshs X,U save regs
 clra
 sta ZFLG,Y Clear zero scan flag
 sta I.DCNT Clr digit count
 sta I.MSGN Clr sign flag
 lda #4
 sta I.LCNT Inz loop count
* Check Sign
 ldd 1,Y Get input num
 bpl INST2 Skp negate if pos
 nega
 negb
 sbca #0
 inc I.MSGN Set res neg flag
* Set Up for Conversion
INST2 leau T$ITEN-2,PCR Get table addr
* Conversion Loop
INST3 clr I.DSAV Clear digit
 leau 2,U Move to new tble entry
INST4 subd  ,U Subtract pwr of 10
 bcs INST5 Bra if underflow
 inc I.DSAV Else bump digit
 bra INST4 and loop again
INST5 addd  ,U Restore from underflow
* Pre-digit Output Tests
 tst I.DSAV Current dig zero?
 bne INST6 if not 0 go output
 tst ZFLG,Y All 0's so far?
 beq INST7 if so suppress this zero
* Output the Current digit
INST6 inc ZFLG,Y Set not-all-zeros
 pshs A
 lda I.DSAV Get the digit
 lbsr PUTDIG Output it
 puls A
* Bottom of Conv Loop
INST7 dec I.LCNT Decr loop count
 bne INST3 Loop if more to conv

* Conv Units digit
 tfr B,A Move units to a
 lbsr PUTDIG ..and output it
 leay 6,Y Pop old number
 puls X,U,PC All done ..


 ttl  Convert real to ASCII
 pag

* Subroutine RLASC
*
* Convert real Binary Value to ASCII
* Decimal Representation
*
* Input: Y - Opstack ptr, number to Convert
*            is Tos.
*        X - Beg Addr for Output String
*
* Output: X,X+8 = Fraction Part of Result in ASCII
*                 Dp to Left, Zero Filled
*         I.DEXP = Decimal exponent Val (2'S Compl)
*         I.DCNT = number of Significant digits
*                  of Result (1 to 9)
*         Y = Opstack ptr, Top Item Popped
* Local:  D,CC Destroyed
*
RLASC pshs X,U Inz variables
 clr I.ESGN exp sign
 clr I.MSGN Frac sign
 clr I.LOEX Low ext
 clr I.HIEX Hi ext
 clr I.DEXP
 clr I.DCNT digit count
* Fill Output buffer With Zeros
 leau  ,X Copy ptr
 ldd #10*256+'0 Clear 10 digits
CLRBUF stb ,U+
 deca
 bne CLRBUF
 ldd BINEXP,Y real zero?
 bne NMASC0 ..no
 inca
 lbra NMAS11 ..yes; skip conversion stuff

* Process Mantissa Sign
NMASC0 ldb MANT3,Y Get mantissa sign
 bitb #1 Mask sign bit
 beq NMASC1 Bra if pos
 stb I.MSGN Set sign flag
 andb #$FE Strip sign bit
 stb MANT3,Y Replace

* Process exponent Sign
NMASC1 ldd 1,Y Get exp, MS byte mant
 bpl NMASC2 Bra if exp positive
 inc I.ESGN Set neg exp flag
 nega GET Abs val exponent
NMASC2 cmpa #3 Range of n>1?
 bls NMASC5 if so no scaling needed
 pag
* Reduce Range of N by Scaling.  N
* is Reduced by Mult or Div by Power of
* Ten from Table.
* Function Int(Log10(N)) is Used to Index
* the Powers Table and is Approximated by:
* Log10(N) = Log2(N)*Log10(2)
* Log10(2) == .301 == 154/512

NMASC3 ldb #154
 mul EXP*154
 lsra HI byte/2 is divide by 512
 nop
 nop
 tfr A,B Copy decimal exp to b
* Conv Decimal exp in A to 2'S Comp
 tst I.ESGN Was exp pos?
 beq NMAS35 Bra if so
 negb OTHERWISE Compl
NMAS35 stb I.DEXP save dec exp
 cmpa #19 in table range?
 bls NMASC4 Bra if in range
* Scale N by 1E19
 pshs A save exp
 leau T$RL19,PCR Get addr of 10e+19
 lbsr CNVOPR and mult/div to scale
 puls A Restore exp
 suba #19
NMASC4 leau T$RL10,PCR Get const tbl addr
 deca remove exp bias
 ldb #5 5 bytes/entry in table
 mul CALCULATE Entry offset
 leau D,U Add to tbl base addr
 lbsr CNVOPR Scale number
* After Scaling, We Must Denornallize N
* So the Binary Residual exponent is
* Exactly Zero for the Bin>Dec Conv To
* Operate Correctly
NMASC5 ldd MANT0,Y Get msdb of frac
 tst BINEXP,Y Check sign of bin exp
 beq NMASC8 Bra if no adj needed
 bpl NMASC7 L shift required
* exp <0 Right Shift to Denorm
NMASC6 lsra
 rorb
 ror MANT2,Y
 ror MANT3,Y
 ror I.LOEX Shift LS bits to extension
 inc BINEXP,Y
 bne NMASC6 Loop til exp=0
 std MANT0,Y Restore msdb on stack
 bra NMASC8
* exp > 0 - Left Shift to Denorm
NMASC7 lsl MANT3,Y
 rol MANT2,Y
 rolb
 rola
 rol I.HIEX Shift MS bits into extension
 dec BINEXP,Y
 bne NMASC7 Loop til exp=0
 std MANT0,Y Replace msdb on stack
 inc I.DEXP Dec exp (decimal)
 lda I.HIEX Get ext byte
 bsr PUTDIG MS decimal digit out

* Convert Binary Fraction to Decimal by
* Repetitive Mult by 10.  Mult by Shift And
* Add.  Overflow Across Binary Point is the
* next Decimal Place Value.
NMASC8 ldd MANT0,Y Get frac in d and u
 ldu MANT2,Y
NMASC9 clr I.HIEX Clr ext byte
 bsr CSHIFT F*2
 std MANT0,Y
 stu MANT2,Y T=f*2
 pshs A
 lda I.HIEX
 sta I.LOEX
 puls A
 bsr CSHIFT F*4
 bsr CSHIFT F*8
 exg D,U
 addd MANT2,Y
 exg D,U
 adcb MANT1,Y
 adca MANT0,Y F*2+f*8=f*10
 pshs A
 lda I.HIEX Add carry to ext byte
 adca I.LOEX
 bsr PUTDIG Output decimal digit
 lda I.DCNT
 cmpa #9
 puls A
 beq NARND0
 cmpd #0 Loop until value is 0
 bne NMASC9
 cmpu #0
 bne NMASC9

* Round to 9 digits based on remainder of conversion divide
NARND0 sta  ,Y
 lda I.DCNT
 cmpa #9
 blo NASC10 No round if < 10 digits
 ldb  ,Y remainder >=.5?
 bpl NASC10 if so dont round up
NARND1 lda ,-X Get prev digit
 inca BUMP It
 sta  ,X Replace it
 cmpa #'9 Overflow?
 bls NASC10 if not we're done
 lda #'0 This digit is zero ..
 sta  ,X
 cmpx  ,S Was it first digit
 bne NARND1 if not keep rounding
* Round Overflowed - Fix It
 inc  ,X Make the zero a one
 inc I.DEXP Adjust dec exp

NASC10 lda #9 Set digit count
NMAS11 sta I.DCNT ..to a uniform 9
 leay 6,Y Clean up opstack
 puls X,U,PC - we're finished.

* Subroutine to Conv+ Output Decimal digit
PUTDIG ora #'0 Make ASCII
 sta ,X+ Out in buffer
 inc I.DCNT Incr digit count
 rts

* Conversion Left Shift Subr
* Shift D:U Left 1 Bit Into I.HIEX
CSHIFT exg D,U
 aslb
 rola
 exg D,U
 rolb
 rola
 rol I.HIEX
 rts

 ttl OPERATING System interface routines
 pag
* Subroutine INPLIN
*
* Call OS-9 to Read a Source Line from
* Console (Channel 0)

INPLIN pshs X,Y
 ldx I.IOBG
 stx I.IOPT Reset I/O ptr
 lda #1
 sta I.IOCT
 ldy #256 Size of input buffer
 lda I.CNCH Input path
 OS9 I$ReadLn
 bra OUTLN1 ..return error status

* Subroutine OUTLIN
* Call OS-9 to Write I/O buffer to Console
OUTLIN pshs X,Y
 ldd I.IOPT
 subd I.IOBG
 beq OUTLN2
 tfr D,Y
 ldx I.IOBG
 stx I.IOPT Reset ptr
 lda I.CNCH Output path
 OS9 I$WritLn Write line
OUTLN1 bcc OUTLN2 ..no error;exit
 stb I.ERR save error code
OUTLN2 puls X,Y,PC

* Subroutine Seek
*
* Call OS-9 to Seek a file to A Position

SEEK pshs X,U save registers
 lda  ,Y Get position TYPE
 cmpa #S.REAL What type?
 beq SEEK10 bra if real
 ldu 1,Y Get simple size
 bra SEEK20
SEEK10 lda 1,Y Get real exponent
 bgt SEEK30 bra if positive
 ldu #0 Seek zero
SEEK20 ldx #0
 bra SEEK60
SEEK30 ldx 2,Y
 ldu 4,Y
 suba #32 Seek in range?
 bcs SEEK40 bra if so
 ldb #M$SOR ERR - seek out of range
 coma set Carry
 bra SEEK70
SEEK40 exg X,D
 lsra
 rorb
 exg D,U
 rora
 rorb
 exg D,X
 exg X,U
 inca COUNT Up
SEEK50 bne SEEK40
SEEK60 lda I.CNCH
 OS9 I$Seek
 bcc SEEK80
SEEK70 stb I.ERR
SEEK80 puls X,U,PC

 ttl FREE Format output routines
 pag
* Format real: Free Format
* Subroutine OUTRL
*
* Convert real number to ASCII Free-Format
* and Place Result in I/O buffer
*
* Input:  N = Tos

OUTRL pshs U,X save regs
 leas -10,S TEMP buffer on stack
 leax  ,S Copy bufptr
 lbsr RLASC Convert ..
* Convert Output of RLASC To
* Floating Decimal if Possible,
* Otherwise Use "E" Format.
RLFMTF pshs X save digit str addr
 lda #9 Trial digit count
 leax 9,X Addr of last digit+1
TRLZER ldb ,-X Get prev digit
 cmpb #'0 is it zero
 bne TRLZ2 if not exit ..
 deca decr digit count
 cmpa #1 Leave one digit min.
 bne TRLZER
TRLZ2 sta I.DCNT Repl digit count
 puls X Restore digits addr
 ldb I.DEXP Get decimal exp
 bgt RFMTF2 if =>0 number has int part
* Convert W/Neg exponent
 negb make exp positve
 tfr B,A
 cmpb #9
 bhi RLFMTE Cant format in this mode
 addb I.DCNT Add # signif. digits
 cmpb #9
 bhi RLFMTE Still cant format
 pshs A save exp
 lbsr OUTSGN Output sign
 clra
 bsr OUTDP Output dec. pt.
 puls B Restore exp
 tstb
 beq RFMTF1
 lbsr OUTZER Output string of zeros
RFMTF1 lda I.DCNT Get sig digit cnt
 bra RFMTF3
* Convert for Positive exp
RFMTF2 cmpb #9 in range?
 bhi RLFMTE if not goto e format
 lbsr OUTSGN Output sign
 tfr B,A
 bsr MOVDIG Move frac digits
 bsr OUTDP Put out d.p
 lda I.DCNT
 suba I.DEXP Calc # of frac digits
 bls RFMTF4 Done if no frac digits
RFMTF3 bsr MOVDIG Output frac digits
* Cleanup and Return
RFMTF4 leas 10,S Pop conv buffer
 clra
 puls X,U,PC

* Free Format real in "E" Format
RLFMTE bsr OUTSGN Output mant sign
 lda #1
 bsr MOVDIG Output first digit
 bsr OUTDP Output dec. pt.
 lda I.DCNT Get digit count
 deca ADJ for first digit
 bne RFMTE2
 inca OUTPUT At least one zero ..
RFMTE2 bsr MOVDIG ..output the rest
 bsr OUTEXP Cnv+output exp part
 bra RFMTF4 Goto cleanup/exit


* Subroutine OUTEXP
*
* Convert and Output Decimal exponent
* I.DEXP is Input exp Param, Format:
*    E <+!-><Nn>

OUTEXP lda #'E
 bsr OUTCHR Output 'e'
 lda I.DEXP Get exponent
 deca CORRECT for scaling
 pshs A save exp val
 bpl OUTEX2
 neg  ,S Make it positive for output
 bsr OUTMIN Output minus sign
 bra OUTEX3
OUTEX2 bsr OUTPLS Output +
OUTEX3 puls B Restor exp
* Convert exp to Decimal
 clra A is tens val
OUTEX4 subb #10
 bcs OUTEX5 Underflow?
 inca
 bra OUTEX4 Loop til converted
OUTEX5 addb #10 Restore units
 bsr OUTDIG Output tens place
 tfr B,A
OUTDIG adda #'0 convert (A) to ASCII digit
 bra OUTCHR print and exit

 pag
***************
* Auxiliary Output Subroutines
* Called to move or insert chars in the output buffer

* Move Series of digits from Cnv Buf (X)
* to Output Buf(U).  Count Passed in (A)
MOVDIG tfr A,B Copy count
 tstb CHK for 0 count
 beq MOVDG2
MOVDG1 lda ,X+ Move loop
 bsr OUTCHR
 decb
 bne MOVDG1
MOVDG2 rts

* Put Space in Output buffer
OUTSP lda #V$SPAC Space char
 bra OUTCHR

* Put decimal pt in Output buffer
OUTDP lda #'.
* bra OUTCHR fall thru

* Put char in (A) in Outbuf
OUTCHR pshs A,U
 leau -64,S minimum stack
 cmpu I.IOPT output buffer overflow?
 bhi OUTCHR10 ..No
 cmpa #V$CR printing EOL?
 beq OUTCHR10 ..Yes; permit
 lda #M$IOVF I/O Buffer Overflow error
 sta I.ERR signal runtime error
 sta BufOvf
 bra OUTCHR99 exit

OUTCHR10 ldu I.IOPT
 sta ,U+
 stu I.IOPT
 inc I.IOCT
OUTCHR99 puls A,U,PC

* Output Series of Zeros Specified by B
OUTZER lda #'0
OUTZE1 tstb
 beq OUTZ3
OUTZ2 bsr OUTCHR
 decb
 bne OUTZ2
OUTZ3 rts

* Output Sign or Space
SGNSPC tst I.MSGN
 beq OUTSP

* Check I.MSGN and Output Minus if Set
* (Sign of Mantissa)
OUTSGN tst I.MSGN
 beq OUTZ3

* Output Minus char
OUTMIN lda #'-
 bra OUTCHR

* Output Plus char
OUTPLS lda #'+
 bra OUTCHR

* Put Spaces in Outbuf - Count Passed in (B)
SPACES lda #V$SPAC
 bra OUTZE1

***************
* Subroutine MOVSTR
*   Move char string (null terminated) to I/O buffer

* Input:  X = Add of Source String
* Output: String in Iobuf
* Local:  A,U,X Destroyed
* Global: I.IOCT updated
*         I.IOPT updated

MOVST0 bsr OUTCHR Output char
MOVSTR lda ,X+ next src char
 cmpa #V$ESTR End str?
 bne MOVST0 ..No; print it
 rts

 ttl Output Execution Routines
 pag
***************
*   Convert Tos value to ASCII and print in output buffer

* Subroutine STROUT
*   Output String (Tos) to I/O buffer

STROUT pshs X
 ldx 1,Y Get str addr
OUTST2 bsr MOVSTR Move to buffer
 clra
 puls X,PC

***************
* Subroutine OUTBL
*   Output Boolean Value to I/O buffer

OUTBL pshs X save regs
 leax T$TRUE,PCR Get aadr of true string
 lda 2,Y Get bool val from opstack
 bne OUTST2 if true output ..
 leax T$FALS,PCR ..otherwise get addr of false
 bra OUTST2 and output..

***************
* Sunroutine OUTINT
*   Put free format Integer Value in I/O buffer

OUTINT pshs U,X save regs
 leas -5,S Make TEMP buffer on stack
 leax  ,S Get addr of TEMP buffer
 lbsr INTSTR Convert n to ASCII
 bsr OUTSGN Output sign if neg
 lda I.DCNT Get digit count
 leax  ,S Restore TEMP buf ptr
 lbsr MOVDIG Copy digits
 leas 5,S Clean stack
 clra
 puls X,U,PC

* Subroutine OUTTAB
*
* Tab Output buffer to character
* Position Specified by (A)
OUTTAB tfr A,B

TAB pshs U
 ldu I.IOPT
 subb I.IOCT
 bls TAB2
 bsr SPACES
TAB2 clra
 puls U,PC


* Subroutine SKPZON
*
* Skip to Beginning of next Tab Zone
SKPZON lbsr OUTSP Output a space
SKPZ2 lda I.IOCT Get I/O char cnt
 anda #$0F Get 4 ls bits
 cmpa #1 First digit of group?
 beq SKIPZ3 if so done ..
 lbsr OUTSP if not output a space
 bra SKPZ2

* Subroutine OUTCR
* Put Eol in I/O Buf
OUTCR lda #V$CR (A)=carriage return
 clr I.IOCT Reset character count
 lbsr OUTCHR
SKIPZ3 clra
 rts

***************
* Subroutine OUTHEX
*   Convert Integer Tos to Hex ASCII

OUTHEX pshs U
 lda #4 Trial field size
 leau  ,Y
 tst  ,U First byte zero?
 bne OUTHX2 Go output if not
 asra ELSE Reduce field
 leau 1,U
OUTHX2 sta I.FWTH
 tfr A,B
 asrb form digit count
 lbsr HEXOUT Call conv subr
 puls U,PC

 ttl I/O and conversion: format parser
 pag
***************
* Subroutine PRSJST
*   Parse Justify/Fill

* Look for justify symbols, setting I.FJST to code:
*   ^ = -1
*   < = 0
*   > = 1

* Input:  A = Current char
*         X = Current char Addr+1
* Output  A = Current char
*         X = Current char

PRSJST clrb
 stb I.FJST Left is default
 cmpa #'< Left?
 beq PRJST3
 cmpa #'> Right?
 bne PRJST2
 incb CODE=1
 bra PRJST3
PRJST2 cmpa #'^ Center?
 bne PRJST4
 decb CODE=-1
PRJST3 stb I.FJST save code
 lda ,X+ Get next char
PRJST4 equ * Fall through to FDELIM

***************
* Subroutine FDELIM
*   Find Format Delimiter

* Looks For:
*  , = Specification Delimiter - Return next
*  ) = Block Delimter - Process Block Repeat
*  V$ESTR = End Fmt String - Reset ptr
*  Other = Error

* Input:  A = Current char
*         X = Current char Addr+1
* Output: I.FMPT = Current char Addr
*         I.FRFL = updated Repeat Flag
*        CC = carry Set if Error

FDELIM cmpa #', Normal separator?
 beq FDEL40
 cmpa #V$ESTR End of string?
 bne FDEL15
 lda I.FRFL in a repeat block?
 beq FDEL10 bra if not
 leax -1,X Back up to end string
 bra FDEL30
FDEL10 ldx I.FMBG if end wrap around ptr
 tst RESCAN Legal to RESCAN format?
 beq FDEL20 ..no; return error
 clr RESCAN Set to no RESCAN legal
 bra FDEL40
FDEL15 cmpa #') End block?
 beq FDEL25 bra if so
FDEL20 orcc #CARRY Set carry
 rts
FDEL25 lda I.FRFL Were we in a block?
 beq FDEL20 Error if not
FDEL30 dec I.FRCT Decr repeat cnt
 bne FDEL35 Bra if more to repeat
 ldu I.OPBG Get repeat stack ptr
 pulu A,Y Get previous count & beginning ptr
 sta I.FRCT Reset previous count
 sty I.FRBG Reset repeat beginning
 stu I.OPBG Update repeat stack ptr
 lda ,X+ Get next char
 dec I.FRFL Decrement rpt flag
 bra FDELIM Look for another delim
FDEL35 ldx I.FRBG Reset block repeat
FDEL40 stx I.FMPT Update perm ptr
 andcc #^CARRY
 rts

* Format Parser Decode/Dispatch Table
T$FMCD equ *
 fcb 'I
 fdb IFMTP-*+1
 fcb 'H
 fdb HFMTP-*+1
 fcb 'R
 fdb RFMTP-*+1
 fcb 'E
 fdb EFMTP-*+1
 fcb 'S
 fdb SFMTP-*+1
 fcb 'B
 fdb BFMTP-*+1
 fcb 'T
 fdb TFMTP-*+1
 fcb 'X
 fdb XFMTP-*+1
 fcb ''
 fdb QFMTP-*+1
 fcb 0

 pag
***************
* Format Specification Parsing Routines
*    for Literal TYPE Specifications

* Tab Format
TFMTP bsr FDELIM
 bcs FMTERR
 ldb I.FWTH
 lbsr TAB
 bra NXTFM1

* Space (X) Format
XFMTP bsr FDELIM
 bcs FMTERR
 ldb I.FWTH
 lbsr SPACES
 bra NXTFM1

* Literal char Format (')
QFMTP cmpa #V$ESTR
 beq FMTERR Missing end '
 cmpa #''
 bne QFMTP2
 lda ,X+
 bsr FDELIM
 bcs FMTERR
 bra NXTFM1
QFMTP2 lbsr OUTCHR
 lda ,X+
 bra QFMTP

 pag
* Decode next Format Specification
* End Dispatch to Format TYPE Parser
* Routine.
*
* Also Checks for Spec Repeat Blocks
* and Sets Up Repeat Parameters
*
* Input:  I.FMPT = Format String Pos of
*                  Current char
*         I.FMBG = Beginning of Fmt Str
*
* Output if No Error:
*         X = next char in Fmt Str
*         A = Current char
*         B, I.FWTH = Field Width/Count if Detected
*         CC carry Set if Not Fw/Cnt Found
*         I.FTYP = Fmt TYPE Code
*         I.Frpt, I.FRFL, I.FRCT Set Up
*             if Repeat Block Encountered
*         Old X,Y on Stack
* Output if Error (Return to Caller)
*        CC carry Set
*        B = Error Code
*
* Local: D

NXTFMT pshs X,Y save regs
 clr RESCAN
 inc RESCAN initialize fmt RESCAN flag
NXTFM1 ldx I.FMPT Init format ptr
 bsr FMTNUM Look for repeat count
 bcs NXTFM3 Bra if not found
 cmpa #'( Paren there?
 bne RPTERR Error if not
 lda I.FRCT Get current repeat count
 stb I.FRCT save count
 beq RPTERR Dont permit zero count
 inc I.FRFL Set flag
 ldu I.OPBG Get repeat stack ptr
 ldy I.FRBG Get repeat beginning ptr
 pshu A,Y Push count & ptr
 stu I.OPBG Update repeat stack ptr
 stx I.FRBG save repeat beginning ptr
NXTFM2 lda ,X+ Get next chr
NXTFM3 leay >T$FMCD,PCR Get addr of decode tbl
 clrb B is counter
* Decode Table Lookup Loop
NXTFM4 pshs A save character
 eora  ,Y Check for match
 anda #^('a-'A) (upper or lower case ok)
 puls A Restore character
 beq NXTFM5 Bra if match
 leay 3,Y Otherwise advance ptr..
 incb ..BUMP Count..
 tst  ,Y End of table (not found)?
 bne NXTFM4 ..no; loop
* Error Exits
FMTERR ldb #M$FSYN Format syntax error
 bra FMEXIT
RPTERR ldb #M$FRPT Repeat block error
FMEXIT stb I.ERR
 coma
 puls X,Y,PC

* Format Code Found - Process next Element (Should
* Be Field Width Count)
NXTFM5 stb I.FTYP save fmt code
 ldd 1,Y
 leay D,Y Get addr of format spec routine
 bsr FMTNUM Get field width
 bcc NXTFM51 ..got it
 ldb #1 error; default ONE
NXTFM51 stb I.FWTH save it
 jmp  ,Y Exit to TYPE parser


* Subroutine FMTNUM
*
* Look for Up to 3 Decimal digits And
* Convert to Binary.
*
* Input:  X = Current char Position
* Output: B = Converted number (0-255)
*         A = next char
*         X = next char Addr+1
*        CC = carry Set if No number Found

FMTNUM bsr TSTDIG Get char+test for digit
 bcs BADNUM Exit if not dig
 tfr A,B Copy it
 bsr TSTDIG Test next char
 bcs NUMOK Return if not digit
 bsr BLDNUM Mult/add
 bsr TSTDIG Test next char
 bcs NUMOK Ret if not digit
 bsr BLDNUM Mult/add
 tsta CHECK for overfl n>255
 beq FMTNM2
 clrb RETURN 0 if overfl
FMTNM2 lda ,X+ Get next char
 bra NUMOK

* Get next char, Test if Decimal+Convert
TSTDIG lda ,X+ Get next chr
CHKDIG cmpa #'0
 blo BADNUM
 cmpa #'9
 bhi BADNUM
 suba #'0 Conv to bin
NUMOK andcc #^CARRY
 rts

BADNUM orcc #1
 rts

* Build Partial Result for Conversion:
* B=B*10+A

BLDNUM pshs A
 lda #10
 mul
 addb ,S+
 adca #0 Propogate carry
 rts

 pag
* Format Specification Parsing Subroutines
*    for Variable TYPE Specifications

* real and expon Format (R,E Fmt)
* Syntax: <TYPE> <Int> . <Frac> [<Just>] <Delim>
EFMTP equ *
RFMTP cmpa #'.
 bne FMTERR
 bsr FMTNUM Find frac field size
 bcs FMTERR
 stb I.FSIZ save frac size
* Fall Thru to IFMTP


BFMTP equ * Boolean format
SFMTP equ * String format
IFMTP equ * Integer format
HFMTP equ * Hex format
*
* Syntax for All Above is: <TYPE> <Fw> [<Just>] <Delim>
*
 lbsr PRSJST Look for just & delim
 bcs FMTERR bra if error
 puls X,Y Restore registers
 inc RESCAN Fmt rescanning legal now
* Fall Thru to EXCFMT


 ttl FIXED Format output routines
 pag
* Formatted Output Decoder/Dispatcher
*
* Get Format TYPE Code from I.FTYP And
* Select Output Conversion Routine

EXCFMT ldb I.FTYP Get TYPE code
 lbeq I.FMT 0=integer fmt
 decb
 beq H.FMT 1=hex fmt
 decb
 lbeq R.FMT 2=real fmt
 decb
 lbeq E.FMT 3=exp fmt
 decb
 lbeq S.FMT 4=str fmt
 lbra B.FMT 5=bool fmt

* Hex Format Conversion
H.FMT jsr J$EVAL Evaluate expression
 cmpa #S.STR is result string or record?
 bcs H.FMT4 Not str if error
 ldu 1,Y Get str addr
 clrb
H.FMT2 lda ,U+ Find str len
 cmpa #V$ESTR 
 beq H.FMT3
 incb
 bne H.FMT2
H.FMT3 ldu 1,Y Set ptr to result
 bra HEXOUT
* Check Types
H.FMT4 leau 1,Y Set ptr to result
 lda  ,Y Get result TYPE
 cmpa #S.REAL TYPE real?
 bne H.FMT5 ..no
 ldb #5
 bra HEXOUT
H.FMT5 cmpa #S.INT is it integer?
 bne H.FMT6
 ldb #2 Len=2 bytes
 cmpb I.FWTH Field too small for integer?
 blo H.FMT7 ..no
H.FMT6 ldb #1 Must be byte or boolean
 leau 1,U Set ptr to result
H.FMT7 tfr B,A Copy digit count
 asla two bytes/digit
 cmpa I.FWTH Too many for field?
 bhi HEXO20 ..yes; skip 1st half of first byte

***************
* HEXOUT
* Output Hex to Max Field Width

* Passed: (B)=digit count
*         (U)=hex string addr
*         I.FWTH=field width
*         I.FJST=justification code

HEXOUT tst I.FJST check justification
 beq HEXO10 ..left justify
 bmi H$FMTC ..center justify

 pshs B Center justify
 aslb
 pshs b
 ldb I.FWTH
 subb ,S+
 bcs HEXO05
 bra HEXO03

H$FMTC pshs B --center justify--
 aslb
 pshs B
 ldb I.FWTH
 subb ,S+
 bcs HEXO05
 asrb
HEXO03 pshs b
 lda I.FWTH Decrement field width
 suba ,S+ by number of leading spaces
 sta I.FWTH
 lbsr SPACES
HEXO05 puls b

HEXO10 lda  ,U Get current byte
 lsra
 lsra shift MS nybble right
 lsra
 lsra
 bsr HEXCHR Output it
 beq HEXO90 Exit if fld full
HEXO20 lda ,U+ Do right nybble
 bsr HEXCHR
 beq HEXO90 Also exit if full
 decb decr bytecnt
 bne HEXO10

* Now Fill remaining Field with spaces
 ldb I.FWTH
 lbsr SPACES
HEXO90 clra
 rts

* Form Single Hex char + Output
HEXCHR anda #$0F Mask it
 cmpa #9 Check range
 bls HXCHR2
 adda #7 Adj for A-F
HXCHR2 lbsr OUTDIG Output digit
 dec I.FWTH Decr fld width
 rts

* Return Format Mismatch Error
FMSMAT coma
 rts

***************
* Subroutine I.FMT
*   Format Integer: Fixed Format

* Std Parameters

I.FMT jsr J$EVAL Evaluate expression
 cmpa #S.REAL What TYPE result?
 bcs I.FMT1 bra if byte/integer
 bne FMSMAT bra if not real
 lbsr J$FIX Convert to integer
I.FMT1 pshs U,X Local regs
 leas -5,S Conv buffer on stack
 leax  ,S X marks the spot
 lbsr INTSTR Call the master conv subr
 ldb I.FWTH Get fld width
 decb SUBT One for sign
 subb I.DCNT then # digits in result
 bpl I$FMT2 Keep going if fld big enough

* Field to small; give up
 leas 5,S Pop old buffer
 puls X,U then regs
 lbra BADFLD Go fill it with *** + rts

* Decode Justification
I$FMT2 tst I.FJST Check justify code
 beq I$FMTL 0=left
 bmi I$FMTC -1=right,zero fill

* Right Justify, Space Fill
I$FMTR lbsr SPACES Leading spaces
 lbsr SGNSPC Sign or space
 bra I$FMT4

* Left Justify, Space Fill
I$FMTL lbsr SGNSPC Sign/space
 pshs B save fill count
 lda I.DCNT
 lbsr MOVDIG
 puls B
 lbsr SPACES Now the fill
 bra I$FMTX

* Right Justify, Zero Fill
I$FMTC lbsr SGNSPC
 lbsr OUTZER Leading zeros
I$FMT4 lda I.DCNT
 lbsr MOVDIG
I$FMTX leas 5,S Pop buffer
 clra
 puls X,U,PC

***************
* Subroutine B.FMT
*   Output Boolean: Fixed Format

* Std Params

B.FMT jsr J$EVAL Evaluate expression
 cmpa #S.BOOL Boolean result?
 bne FMSMAT bra if not
 pshs U,X Are local
 leax T$TRUE,PCR Get addr of true string
 ldb #Len.True length of true string
 lda 2,Y is tos value true?
 bne S.FMT1 ..yes; join str routine
 leax T$FALS,PCR Get addr of false sttr
 ldb #Len.Fals
 bra S.FMT1

***************
* Subroutine S.FMT
*   Output String: Fixed Format

* Truncates if string too big for field 

* Std Parameters

S.FMT jsr J$EVAL Evaluate expression
 cmpa #S.STR String result?
 bne FMSMAT Exit if expr error
 pshs U,X Are local
 ldx 1,Y Get result addr off opstack
 ldd I.STSP String Stack ptr
 subd 1,Y (D)=length of string
 subd #1 Don't count eos byte
 tsta greater than 255 bytes?
 bne S.FMT2 ..Yes; too large
S.FMT1 cmpb I.FWTH larger than field size?
 bls S.FMT3 ..No; continue
S.FMT2 ldb I.FWTH use entire field
S.FMT3 tfr B,A copy string len
 negb Subtract
 addb I.FWTH ..Length from field size
 tst I.FJST check justify TYPE
 beq S.FMTL 0=left
 bmi S.FMTC -1=centered

* Right Justify
 pshs A save length
 lbsr SPACES Do the fill
 puls A
 lbsr MOVDIG Move it out
 bra S.FMTX

* Left Justify
S.FMTL pshs B save fill count
 bra S.FMT5

* Center Justify
S.FMTC lsrb B=FILL/2
 bcc S.FMT4 Was it odd?
 incb YES; Add extra char to trailing fill
S.FMT4 pshs D save len, fill count
 lbsr SPACES Leading fill
 puls A Pop length
S.FMT5 lbsr MOVDIG Copy the string
 puls B Pop the trailing fill count
 lbsr SPACES Do it
S.FMTX clra
 puls X,U,PC

***************
* Subroutine R.FMT
*   Format real: Fixed Format

* Convert (Tos) to a floating Point Decimal number With Fixed
* Format Specified by Format Specification Parser'S Global

* Variables:
*  I.FWTH = Total Field Width
*  I.FSIZ = Fraction Field Width
*  I.FJST = Justify TYPE Code

R.FMT jsr J$EVAL Evaluate expression
 cmpa #S.REAL What TYPE result?
 beq R.FMT1 bra if real
 lbcc FMSMAT bra if not byte/integer
 lbsr J$FLOT Convert to real
R.FMT1 pshs U,X Are local
 leas -10,S Conv buffer on stack
 leax  ,S (X)=its ptr
 lbsr RLASC Call the main conversion routine

* Check Decimal exponent Bounds, then Round
 lda I.DEXP Get dec exp val
 cmpa #9 exp must be <10e+10
 bgt R.FMTE Error if bigger
 lbsr RNDRL Call rounding subr

* Check Field Fit + Compute # of Fill chars Needed
 lda I.FWTH Get total field size
 suba #2 Knock 2 off for sign + dec. pt.
 bmi R.FMTE Error if negative
 suba I.FSIZ Subtract frac fld size
 bmi R.FMTE Also error if neg
 suba I.ICNT Subtract integer part size
 bpl R.FMT2 Ok if still positive..

* Error Exit When Impossible to Format: Clean Up Stack +
* Call Routine to Fill Field With Asterisks
R.FMTE leas 10,S Pop conv buffer
 puls U,X Restore local regs
 bra BADFLD Exit to error filler

* Decode Justification Mode and bra to Formatter Routines
R.FMT2 sta I.FILL Whats left is fill count
 leax  ,S Restore buffer ptr
 ldb I.FJST Get justify code
 beq R.FMTL O=left justify
 bmi R.FMTC -1=center justify(money)

* Right Justify, Space Fill on Left, Leading Sign
 bsr SPCFIL Do space fill
 bsr OUTRNS then sign+number
 bra R.FMTX ..proceed

* Left Justify, Leading Sign, Trailing Space Fill
R.FMTL bsr OUTRNS Output sign+number
 bsr SPCFIL then the space fill
 bra R.FMTX

* Center (Financial) Justify: Right Justify, Space Fill, Trailing Sign/Space
R.FMTC bsr SPCFIL Do the space fill
 bsr OUTRN then the number..
 lbsr SGNSPC and the trailing sign..

* Common Cleanup/Return
R.FMTX leas 10,s pop conv buffer
 clra
 puls X,U,PC

OUTRNS lbsr SGNSPC
OUTRN lda I.ICNT Get integer field size
 lbsr MOVDIG Output it
 lbsr OUTDP then decimal point
 ldb I.DEXP Get decimal exponent
 bpl OUTFP0 No problem if positive
 negb
 cmpb I.FSIZ to many for field?
 bls OUTRN1 ..no
 ldb I.FSIZ
OUTRN1 pshs B
 lbsr OUTZER Output leading zeroes
 ldb I.FSIZ
 subb ,S+ Adjust field size for number of zeros printed
 stb I.FSIZ
 lda I.FCNT Get fraction digit count
 cmpa I.FSIZ Too many for rest of field?
 bls OUTRN2 ..no
 lda I.FSIZ
OUTRN2 bra OUTFP1 Finish output

 pag
***************
* Common Subroutines for real/exp formatted Conversion

* Output Space-Fill field
SPCFIL ldb I.FILL Get fill count
 lbra SPACES Go do it

* Output Floating number elements with Leading Sign/Space
OUTFPS lbsr SGNSPC Output sign/space + fall through

* Output Floation Point number Elements
OUTFPN lda I.ICNT Get int field size
 lbsr MOVDIG Output it
 lbsr OUTDP then a decimal point
OUTFP0 lda I.FCNT Get #sign frac digits
OUTFP1 lbsr MOVDIG Output them
OUTFP2 ldb I.FSIZ Get frac field size
 subb I.FCNT Subtract #signif.
 ble BADRTS Skip fill if <=0
OUTFP9 lbra OUTZER Output trailing zero fill for rest of field

* Bad Field Routine
* Fills full field with Astericks when data can't fit
BADFLD ldb I.FWTH Get field width
 lda #'* Load fill char
 lbsr OUTZE1 Print the astericks
 clra
BADRTS rts

***************
* Subroutine E.FMT
*   Convert real Binary to ASCII exponential format

* Paramters Same As R.FMT

E.FMT jsr J$EVAL Evaluate expression
 cmpa #S.REAL What TYPE result
 beq E.FMT0 bra if real
 lbcc FMSMAT bra if not byte/integer
 lbsr J$FLOT Convert to real
E.FMT0 pshs U,X Are local
 leas -10,S Put cnv buffer on stack
 leax  ,S Get ptr to it
 lbsr RLASC Call the general conversion subr

* Make decimal exponent 1E+10 for formatting, rounding
 lda I.DEXP Get decimal exponent
 pshs A save it
 lda #1 Force exponent=1
 sta I.DEXP
 bsr RNDRL Call the rounder
 puls A Restore previous exp (adjusted)
 ldb I.DEXP
 cmpb #1
 beq E.FMT1 Skip if digits didnt shift
 inca
E.FMT1 ldb #1
 stb I.ICNT Force one int digit
 sta I.DEXP

* Check field fit and compute fill count
 lda I.FWTH Get total field size
 suba #6 Subtract chars for sign, dp and exponent
 bmi E.FMTE if negative error out
 suba I.FSIZ Subtr frac fld size
 bmi E.FMTE Also error if neg
 suba I.ICNT
 bpl E.FMT2 No error if still pos
E.FMTE leas 10,S Pop old dexp + cnv buf
 puls U,X Restore regs
 bra BADFLD
E.FMT2 sta I.FILL save fill count

* Decode Format TYPE
 ldb I.FJST Get TYPE code
 beq E.FMTL if zero do left justify

* Right Justify, Space Fill on Left
E.FMTR bsr SPCFIL
 bsr OUTFPS Do number+sign
 lbsr OUTEXP then exponent
 bra E.FMTX

* Left Justify, Space Fill on Right
E.FMTL bsr OUTFPS Output the number/sign
 lbsr OUTEXP Do the exponent


* Common Cleanup/Exit
E.FMTX lbra R.FMTX Same routine..

***************
* Subroutine RNDRL
*   Rounding subroutine for real format conversions

* Round Fractional Part Defined by I.FSIZ Up If
* Possible.  This is a 4/5 Round on the next digit
* Past the End of the Frac Field Specified by I.FSIZ.

RNDRL pshs X save cnv buffer ptr
 lda I.DEXP Get decimal exponent
 adda I.FSIZ Add # frac digits needed
 bne RNDRL1 >>begin patch
 lda  ,X
 cmpa #'5
 bhs RNDRL25 <<end patch
RNDRL1 deca and Adjust for offset
 bmi ENDRND if negative its out of range
 cmpa #7
 bhi ENDRND High range check

* (A) = digit offset of rounded digit
 leax A,X Move ptr to ronded digit
 ldb 1,X and get next LS digit
 cmpb #'5 Five or greater?
 blo ENDRND Don't round if so
* Here to Round Up
RNDRL2 inc  ,X Round this digit
 ldb  ,X and get it
 cmpb #'9 Did it overflow?
 bls ENDRND Were done if not
RNDRL25 ldb #'0 Else make if zero
 stb  ,X
 leax -1,X and move ptr to next MS digit
 cmpx  ,S Check for beffer bounds
 bhs RNDRL2 Continue if not there

* Here When MS digit in buffer Overflowed: Set MS=1
* and Shift Others Back One Place
 ldx  ,S Set ptr to buffer start
 leax 8,X then to last digit
RNDRL3 lda ,-X Get this digit
 sta 1,X Move it right
 cmpx  ,S Done yet?
 bhi RNDRL3 Loop if not
 lda #'1 Set MS digit to 1
 sta  ,X
 inc I.DEXP and adjust exponent
ENDRND puls X Pop buffer start
* Compute Subfield Sizes (Int,Frac)
 lda I.DEXP Get dec exp
 bpl IPART
 clra INT Part=0 if neg exp
IPART sta I.ICNT Get int field size
 nega
 adda #9 Compute frac size
 bpl FPART
 clra
FPART cmpa I.FSIZ Compare to full fld size
 bls FPART2
 lda I.FSIZ Use whatever is smaller
FPART2 sta I.FCNT save frac size
 rts

* Unimplemented routine error
*  currently used for: Status
UNIMPL ldb #M$UNIM
 stb I.ERR
 coma
 rts

 fcb 0,0,0 Room for Module CRC

* End of Conversion and I/O Routines
