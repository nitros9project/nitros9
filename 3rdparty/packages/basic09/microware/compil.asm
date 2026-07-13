
 nam Compiler
 use DEFS

 ttl External Linkage Section
 pag
 use LINKAGE

***************
* Global Entry Points

CMPENT equ * Global entry points
 fdb CMPRAM-CMPENT Compile RUN parameters
 fdb NAMSYM-CMPENT Check for a name
 fdb SEARC0-CMPENT Search a table
 fdb MOVDWN-CMPENT Block move down subroutine

 ifne INCLUDED&EDITOR
 fdb EXPDSC-CMPENT Expand description table
 fdb COMPIL-CMPENT Compile one statement
 endc

***************
* External Subroutine References

J$EREX jsr M.COMAND
 fcb X$EREX PRINT ERROR messsage and return
J$SEXT jsr M.COMAND
 fcb X$SEXT Set (error) exit address
J$EXIT jsr M.COMAND
 fcb X$EXIT Exit via (error) exit address
J$ASNM jsr M.CNVIO
 fcb X$ASNM  cnv ASCII > numeric
 ifne INCLUDED&EDITOR

J$LKTK jsr M.COMAND
 fcb X$LKTK Lookup token in decompile table
 endc

 ttl Compiler Local equates
 pag

Z$OPTR equ %00001000 Operator token flag

VARIAB equ 0  Namtok=variable ref.
STMBEG equ 1  Symtyp=statement beginning
STMEND equ 2  Symtyp=statement end
RESRVD equ 3  Symtyp=reserved
FNCREF equ 4  Symtyp=function reference
OPRTR  equ 5  SYMTYP=operator
LITRAL equ 6  Symtyp=literal
PROCDR equ 7  Symtyp=procedure reference
S.ASGN equ 8  Symtyp=assign
EQULTY equ 9  Symtyp=equality
RELATN equ 10 Symtyp=relational
CNLREF equ 11 Symtyp=channel ref
SEPRTR equ 12 Symtyp=separator

 ttl MAJOR Tables
 pag
***************
* INSTAB: Non-alphanumeric Symbol Table

 ifne INCLUDED&EDITOR
 fdb 33 Number of entries in INSTAB
 ELSE
 fdb 7 Number of entries in INSTAB
 endc
 fcb 3 Number of skip bytes per entry
INSTAB equ * Non-ALPHA symbol table
 ifne INCLUDED&EDITOR
 fcb INSYM2-LAUNCH,T.NE,RELATN,'<,'>+$80
 fcb INSYM2-LAUNCH,T.NE,RELATN,'>,'<+$80
 fcb INSYM2-LAUNCH,T.LE,RELATN,'<,'=+$80
 fcb INSYM2-LAUNCH,T.LE,RELATN,'=,'<+$80
 fcb INSYM2-LAUNCH,T.GE,RELATN,'>,'=+$80
 fcb INSYM2-LAUNCH,T.GE,RELATN,'=,'>+$80
 fcb INSYM2-LAUNCH,T.ASGN,S.ASGN,':,'=+$80
 fcb INSYM2-LAUNCH,T.POWR+1,OPRTR,'*,'*+$80
 fcb INSYM2-LAUNCH,T.REM2,STMBEG,'(,'*+$80
 fcb INSYM2-LAUNCH,T.BKSL,STMEND,'\+$80
 fcb INSYM2-LAUNCH,T.GT,RELATN,'>+$80
 fcb INSYM2-LAUNCH,T.LT,RELATN,'<+$80
 fcb INSYM2-LAUNCH,T.EQ,EQULTY,'=+$80
 fcb INSYM2-LAUNCH,T.PLUS,OPRTR,'++$80
 fcb INSYM2-LAUNCH,T.MINS,OPRTR,'-+$80
 fcb INSYM2-LAUNCH,T.MUL,OPRTR,'*+$80
 fcb INSYM2-LAUNCH,T.DIV,OPRTR,'/+$80
 fcb INSYM2-LAUNCH,T.POWR,OPRTR,'^+$80
 fcb INSYM2-LAUNCH,T.COL,SEPRTR,':+$80
 fcb INSYM2-LAUNCH,T.LBKT,SEPRTR,'[+$80
 fcb INSYM2-LAUNCH,T.RBKT,SEPRTR,']+$80
 fcb INSYM2-LAUNCH,T.SCOL,SEPRTR,';+$80
 fcb INSYM2-LAUNCH,T.CNUM,CNLREF,'#+$80
 fcb INSYM2-LAUNCH,T.PRNT,STMBEG,'?+$80
 fcb INSYM2-LAUNCH,T.REM1,STMBEG,'!+$80
 fcb PRSLF-LAUNCH,0,SEPRTR,V$LF+$80
 endc

 fcb INSYM2-LAUNCH,T.COMA,SEPRTR,',+$80
 fcb INSYM2-LAUNCH,T.LPAR,SEPRTR,'(+$80
 fcb INSYM2-LAUNCH,T.RPAR,SEPRTR,')+$80
 fcb PRSPER-LAUNCH,T.PERD,SEPRTR,'.+$80
 fcb PRSSTR-LAUNCH,T.SLIT,LITRAL,'"+$80
 fcb PRSHEX-LAUNCH,T.HLIT,LITRAL,'$+$80
 fcb INSYM2-LAUNCH,T.EOL,STMEND,$0D+$80

 ifne INCLUDED&EDITOR
 ttl Parser Keyword dispatch table
 pag
PRSTBL fdb ERIBEG-PRSTBL Global
 fdb DIM-PRSTBL Param
 fdb TYPES-PRSTBL
 fdb DIM-PRSTBL
 fdb PDATA-PRSTBL
 fdb PRINT-PRSTBL STOP
 fdb STOP-PRSTBL Bye
 fdb STOP-PRSTBL Tron
 fdb STOP-PRSTBL Troff
 fdb PRINT-PRSTBL Pause
 fdb STOP-PRSTBL Deg
 fdb STOP-PRSTBL Rad
 fdb STOP-PRSTBL return
 fdb LET-PRSTBL
 fdb ERIBEG-PRSTBL T.CXAS complex assignment
 fdb POKE-PRSTBL
 fdb IF-PRSTBL
 fdb ELSE-PRSTBL
 fdb STOP-PRSTBL Endif
 fdb FOR-PRSTBL
 fdb NEXT-PRSTBL
 fdb WHILE-PRSTBL
 fdb ENDLUP-PRSTBL Endwhile
 fdb STOP-PRSTBL Repeat
 fdb UNTIL-PRSTBL
 fdb STOP-PRSTBL Loop
 fdb ENDLUP-PRSTBL
 fdb EXITIF-PRSTBL
 fdb ENDLUP-PRSTBL Endext
 fdb ON-PRSTBL
 fdb ERROR-PRSTBL
 fdb GOTO-PRSTBL
 fdb ERIBEG-PRSTBL GOTO (bound)
 fdb GOTO-PRSTBL Gosub
 fdb ERIBEG-PRSTBL Gosub (bound)
 fdb RUN-PRSTBL RUN
 fdb KILL-PRSTBL KILL
 fdb input-PRSTBL
 fdb PRINT-PRSTBL
 fdb CHDIR-PRSTBL Chd
 fdb CHDIR-PRSTBL Chx
 fdb CREATE-PRSTBL
 fdb OPEN-PRSTBL
 fdb SEEK-PRSTBL
 fdb READ-PRSTBL
 fdb WRITE-PRSTBL
 fdb GET-PRSTBL
 fdb PUT-PRSTBL
 fdb CLOSE-PRSTBL
 fdb RESTOR-PRSTBL
 fdb DELETE-PRSTBL
 fdb CHAIN-PRSTBL
 fdb SYS-PRSTBL
 fdb BASE-PRSTBL BASE 0
 fdb BASE-PRSTBL BASE 1
 fdb REM-PRSTBL
 fdb REM-PRSTBL (* remark *)
 fdb PRINT-PRSTBL End

 endc
 ttl Compiler (parser) routines
 pag
***************
* Subroutine ERRDIE (ERRTYP)
*   PRINT source line and ERROR message

* Passed: (A)=ERRTYP
* Restores regs & control to routine that last
*    set the 'ERROR Exit' trap.

ERRCHR equ '^

EREVRB lda M$EVRB ERROR - excessive verbage

ERRDIE pshs A save ERROR code
 ldx SRCBUF
 lda #V$CR
ERRO05 asl  ,X
 lsr  ,X strip any high order bits set
 cmpa ,X+ end of line?
 bne ERRO05 ..No; loop until it is
 ldx SRCBUF buffer addr
 bsr PRTLIN
 ldd ERRPTR ERROR addr
 subd SRCBUF
 pshs B save number of spaces to ERROR
 ldx IBUF
 stx ICDPTR
 ldy SRCBUF
 lda #T.ERRL
 lbsr OUTCOD

 ifne INCLUDED&EDITOR
 lbsr REM Compile ERROR line just like a remark
 ELSE
 lda #T.EOL
 endc

 lbsr OUTCOD
 lda #V$SPAC
 ldx I.IOBG
ERRO07 sta ,X+ put spaces in i/o buffer
 dec  ,S
 bpl ERRO07 until ERROR addr is reached
 ldd #ERRCHR*256+V$CR
 std -1,X
 ldx I.IOBG
 bsr PRTLIN PRINT buffer

 puls A,B Restore ERROR code (B)
 lbsr J$EREX PRINT ERROR message
 ldx I.OPBG
 stx I.OPSP
ERRXIT lbra J$EXIT Exit

PRTLIN ldy #256 PRINT to carriage return
 lda I.OPTH
 OS9 I$WritLn PRINT line
 rts (IGNORE Any errors)

 ifne INCLUDED&EDITOR
 ttl STATEMENT Routines
 pag
***************
* Subroutine COMPIL
*   Compiles one line of source into I-Code

* Passed: SRCBUF = addr of Source Line

COMPIL puls X get return addr
 lbsr J$SEXT Set up exit addr
 lbsr SETUP
 lbsr OPTLRF Compile (optional) line reference
 sty SRCBUF Set beginning of line past line number
 ldx ICDPTR
 stx IBUF Also I-Code buffer ditto
COMPI1 bsr STATEM Compile statement
 lda TOKEN
 lbsr OUTCOD
 cmpa #T.BKSL is the next symbol a backslash?
 beq COMPI1 ..Yes; loop until it isnt
 cmpa #T.EOL is it a carriage return?
 bne EREVRB ..No; ERROR - excessive verbage
 bra ERRXIT Exit compiler

***************
* Subroutine STATEM
*   Determine the type of Statement and Dispatch
*   to the Appropriate Processing Routine.

* Passed: (Y)=SRCPTR

STATEM lbsr INSYM get next INPUT symbol
STATE0 lda SYMTYP get symbol type
 cmpa #STMBEG
 bne STATE1 ..No - go look for a variable reference

* Process statement that begins with a Keyword

 ldb TOKEN get token
 clra
 aslb
 rola TIMES 2
 leax PRSTBL,PCR get addr of parsing table
 ldd D,X get offset of this keyword
 jmp D,X Go parse keyword

* Check for an assignment statement

STATE1 cmpa #STMEND end of statement?
 lbne LET1 ..No; must be an assignment stmt - go get it
STATE8 pshs X
 ldx ICDPTR
 leax -1,X remove last byte from I-Code
 stx ICDPTR
 puls X,PC return

 pag
***************
* Subroutine TYPE
*   Parse TYPE Statement

TYPES lbsr ARRNAM Go get undimensioned (array) name
 cmpa #T.EQ is it followed by a "="?
 lbne ERMASS ..No; ERROR - missing assignment
 bsr STATE8 DELETE OLD "=" token from I-Code
 lda #T.ASG1
 lbsr OUTCOD Replace it with asssignment token
*  (Fall thru to process type declaration)

***************
* Subroutine DIM
*   Parse Dimension Statement

* DIM A(5,5,5),B(20) [,...]
* Passed: INSYM has put DIM token in I-Code
* Returns Via STOP

DIM lbsr ARRNAM Go get an array name
 cmpa #T.LPAR is it a left parenthesis?
 bne DIM2 ..No; undimensioned declaration
 lbsr REPFCT Go get a repeat factor
 bne DIM1 ..No commma - go handle left paren
 lbsr REPFCT get second dimension
 bne DIM1 ..No COMMA - go handle left paren
 lbsr REPFCT get third dimension
DIM1 lbsr CHKRPR Insure right paren follows
 bsr LINSYM get next symbol
DIM2 lbsr COMMA is it followed by a comma?
 beq DIM
 cmpa #T.COL Does the variable have type suffix?
 bne DIM3 ..No; go look for a semi-colon
 bsr LINSYM get type token
 ldb SYMTYP
 cmpb #VARIAB is it a var ref token?
 beq DIM25 ..Yes; ok-user type
DIM21 cmpb #RESRVD is it a reserved word?
 bne ERITYP ..No; ERROR - illegal type
 cmpa #T.STR is it higher than string?
 bne DIM25 not a string-bypass size stuff
 bsr LINSYM get next symbol
 cmpa #T.LBKT is it a '['?
 bne DIM3 ..No; end of this entry
 lbsr REPFCT get size
 cmpa #T.RBKT is it followed by a "]"?
 bne ERITYP ..No; ERROR - illegal type suffix
DIM25 bsr LINSYM get next token
DIM3 cmpa #T.SCOL is this the last of the dim?
 beq DIM ..No; go look for more
 bra STATE8 Remove trailing (eol) token and return

LINSYM lbra INSYM get next symbol; return

ERITYP lda #M$ITYP ERROR - illegal type suffix
 bra ERMDO9 (ERRDIE) exit via ERROR trap

***************
* Subroutine PDATA
*   Parse Data Statement

DATA0 lbsr OUTCOD
PDATA bsr FOR9 (ASSIG9) get expression *: data sin(x+y),rnd(0)... ok
 lbsr COMMA comma?
 beq DATA0 ..Yes; repeat
TLBNE lda #T.LBNE
TLBNE9 lbsr OUTCOD
 bra NEXT9 (IFFALS)

***************
* Subroutine POKE
*   Parse POKE Statement

* Passed: INSYM has put T.POKE in I-Code

POKE lbsr ASSIG9 get (hopefully numeric) POKE addr
 lbsr CKCOMA Insure comma follows
 lbra ASSIG1 put T.COMA in I-Code, get value exprsn; return

***************
* Subroutine IF
*   Parse IF Statement

* Passed: INSYM has put T.IF in I-Code

IF bsr UNTIL Compile <expr> followed by T.LBNE and two zero bytes
 cmpa #T.THEN is it a then token?
 bne ERMTHN ..No; ERROR - missing THEN clause
 lbsr OUTCOD put then token in I-Code
 lbsr OPTLRF compile (optional GOTO) line ref
 bcc ENDLU9 (STOP)
 lbra STATEM No line ref found - process new stmt beginning

ERMTHN lda #M$MTHN ERROR - missing then
 bra ERMDO9 (ERRDIE) exit via ERROR trap

***************
* Subroutine ELSE
*   Parse ELSE Statement

* Passed: INSYM has put T.ELSE in I-Code

ELSE bsr NEXT9 (IFFALS) make room in I-Code for endif branch
 bra EXITI9 (STATEM) processs new statement beginning

***************
* Subroutine FOR
*   Parse FOR Statement

* Passed: INSYM has put T.FOR in I-Code

FOR lbsr FORVAR get counter variable
 lbsr ASSIG0 Compile the assignment part
 lda TOKEN
 cmpa #T.TO is it followed by TO?
 bne ERMTO ..No; ERROR - missing to
 bsr FOR8 compile TO variable
 lda TOKEN
 cmpa #T.STEP is it followed by a STEP?
 bne TLBNE ..No; done
 bsr FOR8
 bra TLBNE
FOR8 bsr TLBNE9 (OUTCOD, IFFALS)
FOR9 lbra ASSIG9 get (hopefully numeric) increment EXPRSN

ERMTO lda #M$MTO ERROR - missing to
 bra ERMDO9 (ERRDIE) exit via ERROR trap

***************
* Subroutine NEXT
*   Parse NEXT Statement

* Passed: INSYM has put T.NEXT in I-Code

NEXT lbsr FORVAR Parse a counter variable
 bsr NEXT9 Make room
 bsr NEXT9 for optional step counter
NEXT9 lbra IFFALS Make room for branch to FOR stmt & retn

***************
* Subroutine WHILE
*   Parse WHILE Statement

* Passed: INSYM has put T.WHIL in I-Code

WHILE bsr UNTIL Parse <expr>, T.LBNE, two zero bytes
 cmpa #T.DO is it followed by a DO?
 beq EXITI8 ..Yes; put DO in I-Code, get new stmt beginning

ERMDO lda #M$MDO ERROR - missing do
ERMDO9 lbra ERRDIE Exit via ERROR handler

***************
* Subroutine UNTIL
*   Parse UNTIL Statement

* Passed: INSYM has put T.Until in I-Code

UNTIL bsr FOR9 (ASSIG9) get expression
 bra TLBNE put T.LBNE and room for branch offset in I-Code

***************
* Subroutine ENDLUP
*   Parse Endloop Statement

* Passed: INSYM has put T.ELOP in I-Code

ENDLUP bsr NEXT9 (IFFALS) make room for branch to loop stmt
ENDLU9 bra GOTO9 (STOP) get next symbol; return

***************
* Subroutine EXITIF
*   Parse EXITIF Statement

EXITIF bsr UNTIL Process boolean expression part
 cmpa #T.THEN is it followed by a then clause?
 bne ERMTHN ERROR - missing THEN
EXITI8 bsr CMPRA9 (OUTCOD)
EXITI9 lbra STATEM Go get optional statement

***************
* Subroutine ON
*   Parse ON Statement

* Handles Both:
*     ON ERROR GOTO <LINREF>
*     ON <Expression> GOTO <LINREF>,<LINREF>,...

* Passed: INSYM has put T.ON in I-Code

ON ldd ICDPTR
 pshs D,Y save I-Code ptr & source ptr
 lbsr INSYM get next symbol
 cmpa #T.EROR is it ERROR?
 bne ON1 ..No; go handle computed GOTO
 leas 4,S Discard saved ICDPTR & SRCPTR
 bsr GOTO9 (STOP) get next symbol
 cmpa #T.GOTO is the next symbol a GOTO?
 beq GOTO1 ..Yes; go parse it
ON9 rts

ON1 puls D,Y Restore ICDPTR & SRCPTR
 std ICDPTR
 bsr UNTIL parse <EXPR> followed by T.LBNE & 2 zero bytes
 ldx ICDPTR
 leax -1,X
 pshs X save ptr to LSB of 'count of how many gotos are here'
 cmpa #T.GOTO is it followed by a goto?
 beq ON3 ..Yes; good - continue
 cmpa #T.GOSB is it a gosub?
 beq ON3
ERMGTO lda #M$MGTO ERROR - missing GOTO
 bra ERMDO9 (ERRDIE)

ON2 bsr CMPRA9 (OUTCOD) put COMMA in I-Code
 lda #T.LREF
ON3 inc [,S] Increment count
 bsr GOTO1 get line reference
 lbsr COMMA is it followed by a comma?
 beq ON2 ..Yes; loop until it isn't
 puls X,PC

***************
* Subroutine GOTO
*   Parse GOTO Statement

* Passed: INSYM has put T.GOTO in I-Code

GOTO lbsr STOP1 remove GOTO token from I-Code
GOTO1 lbsr LINREF get a line reference
GOTO9 lbra STOP get next symbol; return
 endc

SETUP sty SRCBUF
 ldx I.STBG
 stx IBUF
 stx ICDPTR
 clr ERR
 clr CNTASS
 rts

***************
* Subroutine RUN
*   Parse RUN Statement

* Passed: INSYM has put T.RUN in I-Code

CMPRAM bsr SETUP
 inc DEBUGGER set 'no variable names whatsoever' mode
 lbsr STOP get next token
 bsr RUN1 get parameters
 clr DEBUGGER
 lda TOKEN
 cmpa #T.EOL end of line?
 lbne EREVRB ..No; too much on command line
CMPRA9 lbra OUTCOD put it in I-Code; return

 ifne INCLUDED&EDITOR
RUN lbsr STOP1 Back up over T.RUN token
 pshs X
 lbsr FORVAR get procedure name
 ldb #T.RUN
 stb [,S++] Reset T.RUN token
 endc

RUN1 cmpa #T.LPAR Are there any parameters?
 bne RUN9 ..No; just return then
RUN3 bsr CMPRA9 (OUTCOD) put token in I-Code

PRSPRM ldd ICDPTR
 ifne INCLUDED&EDITOR
 pshs D,Y save ptr to here
 lbsr INSYM get next symbol
 ldd #VARIAB*256+OPRTR
 cmpa SYMTYP
 beq PRSP10
 stb SYMTYP
 bra PRSP20
PRSP10 lbsr PRSVA0 Look for a variable ref
PRSP20 puls D,Y
 std ICDPTR restore 'Here'
 ldb SYMTYP
 cmpb #OPRTR is this an expression?
 beq PRSP30 ..Yes; don't put in complex assignment
 lbsr OUTCXS OUTCOD complex assignment

PRSP30 lbsr FARG11 get (next) parameter

 ELSE
 lbsr INSYM get Literal param
 ldb SYMTYP
 cmpb #LITRAL literal?
 bne RUN9 ..No; return
 lbsr STOP get next token
 endc

 lbsr COMMA is it followed by a comma?
 beq RUN3 ..Yes; go get another parameter
 pshs A
 lbra FUNRE1 Check for ')' and put it in I-Code
RUN9 rts

 ifne INCLUDED&EDITOR
***************
* Subroutine INPUT
*   Parse INPUT Statement

* Passed: INSYM has put T.INPT in I-Code

INPUT sty SRCPTR
 lbsr CHLREF get (optional) chl ref
 bne INPUT1
 sty SRCPTR
 bsr CHKSEP insure i/o separator follows
 bsr CMPRA9 (OUTCOD)
 bsr GOTO9 (STOP)
INPUT1 ldy SRCPTR
 cmpa #T.SLIT String literal found?
 bne INPUT3 ..No; continue
 lbsr INSYM get prompt string
 lbsr GOTO9 (STOP)
INPU15 bsr CHKSEP insure i/o separator follows prompt string
INPUT2 lda #T.COMA
 bsr PUT9 (OUTCOD) put COMMA in I-Code
INPUT3 bsr GET10 (+PRSVAR) get next variable
INPUT4 lbsr PRTSEP (another) comma?
 beq INPUT2 ..Yes; loop until not
INPUT9 rts

CHKSEP lbsr PRTSEP check for separator
 beq INPUT9 ..return if found
 bra PUT8 (CKCOMA) otherwise return ERROR

***************
* Subroutine PRINT
*   Parse PRINT Statement

* Passed: INSYM has put T.PRNT in I-Code

PRINT sty SRCPTR
 lbsr CHLREF Channel ref?
 beq PRINT1
 cmpa #T.USNG Using?
 beq PRINT2
PRIN05 ldy SRCPTR
 bra PRINT4 No chl or using; go look for PRINT list
PRINT1 cmpa #T.USNG Using too?
 bne PRINT6
PRINT2 lbsr ASSIG1 put it in I-Code, get using expression
 bra PRINT6
PRINT3 bsr PUT9 (OUTCOD)
PRINT4 lbsr SKIPSP
 cmpa #V$CR end of line?
PRINT5 lbeq STOP
 cmpa #'\ Other end of line?
 beq PRINT5
 bsr SEEK9 (ASSIG9) get expression
PRINT6 lbsr PRTSEP followed by a COMMA or semi-colon?
 beq PRINT3 ..Yes; loop
 rts

***************
READ sty SRCPTR
 lbsr CHLREF get (optional channel ref)
 beq INPU15 bra if found
 ldy SRCPTR
 bra INPUT3

***************
* Subroutine WRITE
*   Compile WRITE Statement

WRITE sty SRCPTR
 lbsr CHLREF get (optional) chl ref
 beq PRINT6
 bra PRIN05 get PRINT list

***************
* Subroutine GET/PUT
*   Parse GET Statement

PUT equ *
GET bsr PUT0 <chl ref>,
GET10 inc CNTASS set content of assignment
 lbra PRSVAR get variable id

PUT0 lbsr CHLREF get channel reference
 bne ERMCHL
PUT8 lbsr CKCOMA Insure comma follows
PUT9 lbra OUTCOD

SEEK bsr PUT0
SEEK9 lbra ASSIG9 Expression

***************
* Subroutine OPEN
*   Parse OPEN Statement

* Passed: INSYM has put T.OPEN in I-Code

* OPEN/CREATE MODES - must be in ascending order

MODES fcb T.READ,READ.
 fcb T.WRIT,WRITE.
 fcb T.UPDT,UPDAT.
 fcb T.EXEC,EXEC.
 fcb T.DIR,DIR.
 fcb 0

CREATE equ *
OPEN lbsr INSYM get channel ref
 cmpa #T.CNUM Channel reference token?
 bne ERMCHL ..No; error: missing channel
 bsr GET10 (+PRSVAR) get path variable
 bsr PUT8 (CKCOMA, OUTCOD) insure comma follows
 bsr SEEK9 (ASSIG9) get pathlist expression
 lda TOKEN
 cmpa #T.COL
 bne STOP9 ..No; return
 lda #T.MODE
 bsr PUT9 (OUTCOD)
 clr ,-S
OPEN10 bsr STOP get mode token
 leax <MODES,PCR
OPEN20 cmpa ,X++ mode token?
 bhi OPEN20 ..maybe, keep looking
 bne ERIMOD ..No; error: illegal mode
 ldb -1,X get mode value
 orb  ,S update T.MODE post-byte
 stb  ,S
 bsr STOP get next token
 cmpa #T.PLUS more modes?
 beq OPEN10 ..Yes; repeat
 lda ,S+ get composit mode byte
 bne PUT9 (OUTCOD) ..done if non-zero

ERIMOD lda #M$IMOD ERROR - illegal mode
 bra ERMCH9 (ERRDIE)

***************
* Subroutine CLOSE
*   Parse CLOSE Statement

* Passed: INSYM has put T.CLOS in I-Code

CLOSE0 lbsr COMMA Comma?
 bne STOP9 ..No; return
 bsr PUT9 (OUTCOD) put COMMA in I-Code
CLOSE lbsr CHLREF
 beq CLOSE0

ERMCHL lda #M$MCHL ERROR - missing channel reference
ERMCH9 lbra ERRDIE

***************
* Subroutine Restore
*   Restore [line Ref]

RESTOR bsr OPTLRF get optional line ref
 bra STOP get next (eol) token, exit

***************
* Subroutine BASE
*   Parse BASE Statement

BASE lbsr SKIPSP Skip any spaces
 leay 1,Y
 suba #'0 is the first non-blank a '0?
 beq STOP ..Yes; return
 cmpa #1 is it a '1?
 lbne ERIOPD ..No; ERROR - illegal operand
 bsr STOP1 REMOVE BASE0 token
 lda #T.BAS1
 lbsr OUTCOD replace with BASE1 token
 bra STOP

***************
* Subroutine REM
*   Parse REM Statement

* Passed: INSYM has put T.Rem in I-Code

REM ldx ICDPTR
 lbsr SKIPSP Skip spaces
 clra
REM1 lbsr OUTCOD put next char in I-Code
 inc  ,X Update I-Code byte count
 lda ,Y+ get (next) src char  ..{this is  entry pt}
 cmpa #V$CR is it a carriage return?
 bne REM1 ..No; loop until it is
 leay -1,Y Back up SRCPTR
* Fall Through to STOP

 endc
***************
* Subroutine STOP
*   Parse All Single Keyword Statements

* Passed: INSYM has put Keyword in I-Code

STOP lbsr INSYM get next symbol
STOP1 ldx ICDPRV get previous I-Code ptr
 stx ICDPTR Remove code just generated from I-Code
 lda TOKEN
STOP9 rts return

 ifne INCLUDED&EDITOR
CHKVAR lda SYMTYP
 cmpa #VARIAB Variable refeerence?
 beq STOP9 ..Yes; good; return

ERIBEG lda #M$ICON Error: illegal stmt construction
 bra ERMCH9 (ERRDIE)

ERMASS lda #M$MASS Error: missing assignment
ERMAS9 bra ERMCH9 (ERRDIE)


***************
* Subroutine LET
*   Parse LET Statement

* Passed:

LET lbsr INSYM get next symbol
LET1 bsr CHKVAR Insure its a variable
*     (Fall Through to Assign)

***************
* Subroutine ASSIGN
*   Parse ASSIGN Statement

* Passed: INSYM has put Var Ref token in I-Code

ASSIGN inc CNTASS Set complex assignment switch
 lbsr VARREF get variable reference
ASSIG0 lda TOKEN
 cmpa #T.ASGN is it an assignment symbol?
 beq ASSIG1 ..Yes; good - continue
 cmpa #T.EQ is it an equals token?
 bne ERMASS ..No; error: missing assignment
 lda #T.ASG1
ASSIG1 lbsr OUTCOD put asssignment token in I-Code

CHDIR  equ *
SYS  equ *
CHAIN  equ *
DELETE  equ *
ERROR  equ *
KILL equ *
ASSIG9 lda #T.END (fall through to get an expression, and return)

 ttl EXPRESSION Processors
 pag
***************
* Subroutine EXPRSN
*   Parse Expression

* Passed: (Y)=SRCPTR
* Returns: (Y)=updated
* Destroys: A,B,CC

EXPRSN ldx I.OPSP get operator stack ptr
 clrb set end marker (user supplied token) precedence=0
 lbsr OPRA85 set end mark in opstack
EXPR10 bsr NODE get operand
 lbsr OPRATR get operator
 bcc EXPR10 Repeat until none is present
EXPR90 rts return

 ttl NODE Processors
 pag
******************************
* Subroutine LINREF
*   Process a Line Number Reference

* Passed: (Y)=SRCPTR

OPTLRF lbsr SKIPSP (entry point for optional line reference)
 lbsr DECDIG is the next char a number
 bcs EXPR90 ..No; return (carry set)
 lda #T.LREF get line ref. token
*     Fall Through to get Line Reference
*       Note - OUTCOD Must return Carry Clear to indicate Found

LINREF bsr IFFAL1 (OUTCOD) put line ref token in I-Code
 lbsr GETNUM
 beq ERINUM Illegal number (real literal)
 ldd  ,X
 lbgt PRSNA8 Go put line number in I-Code; return

ERINUM lda #M$INUM Error: illegal number
 bra ERMAS9 (ERRDIE) exit via ERROR trap

***************
* Subroutine ARRNAM
*   get next Symbol and check for a legal
*   Array name.  Exit via ERROR trap if not.

* Passed: (A)=ERRTYP
*         (Y)=SRCPTR
* Returns: (A)=ERRTYP (Unchanged)
*          (B)=Symtyp
*          (Y)=SRCPTR (updated)
* Destroys: CC

ARRNAM bsr ARRNA9 (INSYM) get next symbol
 bsr CHKVAR
ARRNA9 lbra LINSYM get next symbol; return

***************
* Subroutine REPFCT
*   Parse (Numeric Literal) Dimension

* Passed: (Y)=SRCPTR
* Returns: (Y)=SRCPTR (updated)
* Destroys: A,B,CC

REPFCT lda #T.ILIT
 bsr LINREF
 bsr ARRNA9 (INSYM)
 bra COMMA Test what you've gotten

***************
* Subroutine IFFALS
*   Make Room in I-Code for Later Insertion
*   of 'IF' Statement Branches.

* Passed: None
* Returns: (A)=Cleared
* Destroys: CC

IFFALS clra
 bsr IFFAL1 put two zero bytes in I-Code buffer
 bsr IFFAL1
 bra GETTOK
IFFAL1 lbra OUTCOD ..return

***************
* Subroutine PRSVAR
*   Parse variable

* Passed: (Y) = SRCPTR

PRSVAR bsr ARRNA9 (INSYM) get next symbol
PRSVA0 bsr CHKVAR Insure its a variable
 bra VARREF Go get variable ref

**************
* Subroutine CHLREF
*   Process Channel Reference

CHLREF bsr STOP get next symbol
 cmpa #T.CNUM
 bne CHLRE9 return not found
 bsr ASSIG1 put token in I-Code, get channel expression
GETTOK lda TOKEN
 cmpa TOKEN Set found (eq)
CHLRE9 rts

***************
* Subroutine FORVAR

* Passed: (Y)=SRCPTR
* Returns: (Y)=SRCPTR (updated)
* Destroys: A,B,CC

FORVAR bsr ARRNA9 (INSYM) get next symbol
 lbsr CHKVAR Insure its a variable
FORVA9 lbra STOP get next symbol; return

***************
* Subroutine PRTSEP

* Passed: None
* Returns: (A)=Token
* Destroys: CC

PRTSEP lda TOKEN
 cmpa #T.SCOL is it a ';' token?
 beq COMMA9 ..Yes; return
*  If not a Semi-Colon Look for a COMMA

 endc
***************
* Subroutine COMMA

* Passed: None
* Returns: (A)=Token
* Destroys: CC

COMMA lda TOKEN get token
 cmpa #T.COMA is it a ',' token?
COMMA9 rts return
 ifne INCLUDED&EDITOR

CKCOMA bsr COMMA
 beq COMMA9
ERMCOM lda #M$MCOM
 bra ERIOP9 (ERRDIE)

 pag
***************
* Subroutine NODE
*   Process an expression NODE, which is:
*    [optional PREFIX]
*    (parenthetical expression)  ..or
*    Literal, Variable, or Function reference

* Passed: (Y)=SRCPTR
* Returns: (Y)=SRCPTR (updated)
* Destroys: A,B,CC

NODE1 clrb set Precedence = 0
 bsr PUSHOP push left paren token ON opstack
 lbsr STOP1 remove it from I-Code
NODE bsr PREF20 (INSYM) get symbol
 bsr PREFIX Handle any PREFIX present
 cmpa #T.LPAR is it a '(' token?
 beq NODE1 ..Yes; go handle a parenthetical expr
 ldb SYMTYP get symbol type
 cmpb #LITRAL is SYMTYP a literal?
 beq FORVA9 (STOP) ..Yes; get next symbol & return
 cmpb #FNCREF is SYMTYP a function reference?
 bne PRSVA0 ..No; go process variable reference
 lbra FUNREF ..Yes; handle it & return

ERIOPD lda #M$IOPD Error: 'illegal operand'
ERIOP9 lbra ERRDIE Exit via ERROR trap

***************
* Subroutine PREFIX
*   Check for a PREFIX Operator

* Passed: (Y)=SRCPTR
* Returns: (Y)=SRCPTR (updated if PREFIX Found)
* Destroys: A,B,CC

PREFIX cmpa #T.NOT is it a NOT token?
 beq PREFX2 ..Yes; process as a polish operator
 cmpa #T.MINS is it a '-' token?
 bne COMMA9 ..No; return
 lda  ,Y get next source char
 lbsr DECDIG is it a digit?
 bcc PREFX3 ..Yes; good - go get number
 cmpa #'. is it a period (fractional number)?
 beq PREFX3 ..Yes; good - go get number
 lda #T.NEG Change minus token into negation
PREFX2 ldb #7 ;give PREFIX operators utmost precedence
 bsr PUSHOP Push PREFIX oprator ON opstack
 lbsr STOP1 Remove token from I-Code
PREF20 lbra INSYM get next symbol & return

PREFX3 leay -1,Y Backup source ptr
 lbsr STATE8 Take '+/-' token out of I-Code buffer
 lbra PRSNUM Parse numeric literal & return

PUSHOP ldx I.OPSP
PUSH10 std ,--X push onto opstack
 stx I.OPSP update opstack ptr
 rts

 pag
***************
* Subroutine VARREF
*   Process variable Reference

* Passed: (Y)=SRCPTR
* Returns: (Y)=SRCPTR (updated)
* Destroys: A,B,CC

VARREF ldd #T.VREF*256 get simple variable type
VARRE0 pshs D save it
 ldd SYMPT get symbol ptr
 bsr PUSHOP Push SYMPT onto opstack
 puls D
 bsr PUSHOP Push smtyp ON opstack
 lbsr STOP1 remove it from I-Code
 lbsr STOP get next symbol
 clrb set Number of subsrcripts = 0
 cmpa #T.LPAR is it a '('  (array reference)?
 beq VARRE2 ..Yes; go get subscript(s)
VARRE1 cmpa #T.PERD is it a '.' (record qualifier)?
 bne VARRE9 ..No; simple type - return

* This Section Handles Record Names

 bsr CKCASS Check for content of assignment
 bsr VARRE9 put qualifier in I-Code
 bsr PREF20 (INSYM) get next symbol
 lbsr CHKVAR Insure its a variable
VARR15 ldd #T.PERD*256 get 'simple' record reference
 bra VARRE0 Process record

VARRE2 bsr CKCASS Check content of assignment
VARR25 incb INCREMENT Subscript count
 pshs B save subscript count
 lbsr FARG11 get subscript expression
 lbsr COMMA is it followed by a comma?
 bne VARRE3 ..No; no more subscripts - split
 ldb ,S+ get subscript count
 cmpb #3 is it < 3?
 blo VARRE2 ..Yes; loop for another
 lda #M$SUBS Error: too many subscripts
 lbra ERRDIE Exit via ERROR trap

VARRE3 bsr CHKRPR Insure right paren follows
 lbsr STOP get next symbol
 puls B Restore number of subscripts
 bra VARRE1 Go see if its a record or not

VARRE9 clr CNTASS Insure complex assignment switch is clear
 ldx I.OPSP get operator stack ptr
 addb ,X++ Pop  variable ref token
 lbsr OUTCDB (OUTCOD b)
 ldd ,X++ get SYMPT to variable
 stx I.OPSP save opstack ptr
 lbra PRSNA8 put SYMPTR in I-Code & return

CKCASS tst CNTASS is this a content of assignment?
 beq NOTFN9 (rts) ..No; don't put in T.CXAS
 clr CNTASS Clear content of assignment flag
OUTCXS lda #T.CXAS
CKCAS9 lbra OUTCOD put it in I-Code

 pag
***************
* Subroutine OPRATR
*   Check for a Valid Operator
*    And Handle Polish Conversion Routine
*    from the Operator's Point of View.

*   (Called By Expression Through Opopop with Node)

* Passed:
*        (Assumes INSYM Has Been Called)
* Destroys: A,X,CC

OPRATR ldb TOKEN get token
 clra
 cmpb #T.RPAR is it a right paren (pseudo operator)?
 beq OPRAT3 ..Yes; go do it with 0 precedence
 tstb EXPRESSION Component?
 bpl OPRAT1 ..No; not an operator
 lbsr J$LKTK Lookup token
 bita #Z$OPTR is it an operator?
 bne OPRAT3 ..Yes; good - go process it
OPRAT1 ldx I.OPSP not an operator - get opstack ptr
OPRAT2 ldd ,X++ Pop operator token & precedence
 cmpa #T.LPAR is it an OPEN parenthesis (for precedence)?
 beq ERMRPR ..Yes; error: missinng right parenthesis
 bsr CKCAS9 (OUTCOD) put token into I-Code
 tstb is This the end of the expression?
 bne OPRAT2 ..No; pop some more
NOTFND cmpa #T.END
 bne NOTFN1
 lbsr STATE8 Remove (T.END) token from I-Code
NOTFN1 stx I.OPSP
 coma tell. EXPRSN that there wasn't an operator
NOTFN9 rts

OPRAT3 anda #7 Mask operator's precedence (from table)
 tfr A,B
 ldx I.OPSP get opstack ptr
 bra OPRAT5
OPRAT4 lda ,X++ Pop earlier (higher prec) operator
 bsr FARG09 (OUTCOD) put the operator in I-Code
OPRAT5 cmpb 1,X Compare current precedence : next previous
 blo OPRAT4 ..current is lower; go pop some more
 bhi OPRAT8 ..prev prec is lower; go push operator
 cmpb #6 Power function?
 beq OPRAT8 ..Yes; push operator (right to left evaluation)
 tstb is This an ')' token (prec=0)?
 bne OPRAT4 ..No; pop the previous OPRATR into I-Code
 lda ,X++ Pop operator from stack
 cmpa #T.LPAR Was it a matching '('?
 bne OPRAT6 ..No; go check for an end token
 stx I.OPSP save opstack ptr
 bsr FUNRE9 (STOP) get next symbol
 bra OPRATR Go see if it's another operator
OPRAT6 cmpa #T.END is it an end token?
 beq ERMLPR ..Yes; error: missing left paren
 bsr FARG09 (OUTCOD) put popped token in I-Code
 bra NOTFN1 return not found

OPRAT8 lda TOKEN get token again
OPRA85 std ,--X Push this operator onto stack
 stx I.OPSP save the opstack ptr
 endc
OPRAT9 rts return

CHKRPR lda TOKEN
 cmpa #T.RPAR Right parenthesis?
 beq OPRAT9 ..Yes; return
ERMRPR lda #M$MRPR Error: missing right parenthesis
ERMRP9 lbra ERRDIE Exit via ERROR trap

 ifne INCLUDED&EDITOR
 pag
***************
* Subroutine FUNREF
*   Parse Function Reference & put it in I-Code

* Passed: (X)=SYMPT
*                   (Y)=SRCPTR
* Destroys: X

FUNREF lbsr STATE8 Remove (function ref) token from I-Code
 lda TOKEN get token
 pshs A save function code
 bsr FUNRE9 (STOP) get next token
 ldb  ,S
 lbsr J$LKTK find function ref token in Decompiler tbl
 leax <FUNRE1,PCR
 pshs X push Return addr
 anda #3 get number of args of function
 beq FARG0 Process 0 argument functions
 cmpa #2
 beq FARG2 Process 2 argument functions
 bhi FARG3 Process 3 argument functions
 ldb 2,S
 cmpb #T.ADDR
 beq FARGVR Process ADDR function
 cmpb #T.LENG
 beq FARGVR Process LEN function
 cmpb #T.EOF
 beq FARGCN Process STATUS function
 bra FARG1 Process 1 argument functions

 endc
FUNRE1 bsr CHKRPR
 puls A
 lbsr OUTCOD
FUNRE9 lbra STOP get next token & return
 ifne INCLUDED&EDITOR

CHKLPR lda TOKEN get current token
 cmpa #T.LPAR is it a left paren?
 beq OPRAT9 ..Yes; return

ERMLPR lda #M$MLPR Error: missing left parenthesis
 bra ERMRP9 (ERRDIE) exit via ERROR trap

***************
* Subroutines FARG0 - Farg9
*   Function Argument Parser Helpers

***************
* Subroutine FARG0
*   Process Zero Arguments

FARG0 leas 2,S Discard return address
 puls A Restore function token
FARG09 lbra OUTCOD ..return to caller's caller

***************
* Subroutine FARG1
*   Process One Argument

FARG1 bsr CHKLPR Make sure theres a left paren
FARG11 clra
 lbsr EXPRSN Go get one expression
 lbra STATE8 Remove junk token from I-Code & return

***************
* Subroutine FARG2
*   Process Two Arguments

FARG2 bsr FARG1 get first parameter
FARG21 lbsr CKCOMA Insure it's followed by a COMMA
 bra FARG11 get 2nd arg & return

***************
* Subroutine FARG3
*   Process Three Arguments

FARG3 bsr FARG2 get two arguments
 bra FARG21 get third argument & return

***************
* Subroutine FARGCN
*   Parse Eof(#<expr>) function

FARGCN bsr CHKLPR Must be a left paren
 bsr FUNRE9 (STOP) get next token
 cmpa #T.CNUM path reference?
 beq FARG11 ..Yes; get path expression
 lbra ERMCHL Error: missing channel ref

***************
* Subroutine FARGVR
*   Parse addr,Size functions

* Passed: (B)=T.addr or T.LEN token

FARGVR bsr CHKLPR Must be a left paren
 incb make Pre-token
 lbsr OUTCDB out to I-Code
 lbra PRSVAR
 endc

ERBSYM lda #M$BSYM Error: unrecognized symbol
 bra ERMRP9 (ERRDIE) exit via ERROR trap

 ttl SYNTAX Routines
 pag
***************
* Subroutine INSYM (SRCPTR)
*   Parse Logical Symbol

* Passed: (Y)=SRCPTR
* Returns:  (Y)=SRCPTR (updated)
* Destroys: X,D,CC

* Note: if INSYM exits via INSYM2 (Insym9),
*   (A) will contain the input token.  This is
*   true of all KEYWORDS, and most INSTAB symbols

PRSLF
INSYM ldd ICDPTR
 std ICDPRV save old I-Code ptr
 lbsr SKIPSP
 sty ERRPTR Update ERROR ptr
 ifne INCLUDED&EDITOR
 lbsr NAMSYM is the next symbol a name?
 lbne PRSNAM ..Yes; parse name & return
 endc

 lda  ,Y char=[SRCPTR]
 lbsr DECDIG is the next symbol a number?
 bcc PRSNUM ..Yes; parse number & return

 leax INSTAB,PCR get non-numeric symbol table
 lda #$80 match if high order bit clear
 lbsr SEARC0 ..and search for a valid symbol
 beq ERBSYM Error: bad symbol
 ldb  ,X get address of routine - LAUNCH pad
 leau <LAUNCH,PCR get LAUNCH pad address
 jmp B,U Go process symbol found

* Subroutine INSYM2
*   Put symbol found in I-Code, update SRCPTR
* (Most non-numeric symbols come her)

* Passed: (X)=SYMPT (entry of Symbol found)
*                   (Y)=SRCPTR (char that was found)
* Returns: (X)=unchanged
*          (Y)=updated past char
* Destroys: A,B

INSYM2 ldd 1,X Token=[SYMPT+1]; SYMTYP=[SYMPT+2]
INSYM9 stb SYMTYP save SYMTYP
 sta TOKEN save token
 lbra OUTCOD put it in I-Code & return

***************
* Subroutine PRSPER
*   Check to See if Period is a Number Or
*   A Record Separater.

* Passed: (Y)=SRCPTR
* Returns: All
* Destroys: A,CC

PRSPER lda  ,Y get char that follows period
 lbsr DECDIG is it a decimal digit?
 bcs INSYM2 ..No; go put record separater in I-Code
 leay -1,Y Point to decimal point
* Fall Through to PRSNUM

***************
* Subroutine PRSNUM
*   Parse a Numeric Literal

* Passed: (Y)=SRCPTR
* Returns: (Y)=SRCPTR (updated if Number Was Found)
* Destroys: A,B,X

PRSNUM bsr GETNUM get numeric literal
 bne NUMVA3 Real?
 ldd #T.RLIT*256+5 get real lit token & real lit size
NUMVA0 sta TOKEN
NUMVA1 bsr PRSST9 (OUTCOD) put it in I-Code
 lda ,X+ get next byte of number
 decb
 bpl NUMVA1
 lda #LITRAL get 'literal' symbol type
 sta SYMTYP
 rts DONE; return

NUMVA3 ldd #T.ILIT*256+2 get integer literal & size
 tst  ,X is this really a byte literal?
 bne NUMVA0 ..No; go put integer in I-Code

 ldd #T.BLIT*256+1 get byte lit token & size
 leax 1,X
 bra NUMVA0 put it in I-Code

LAUNCH equ *  launching pad for non-ALPHA symbols

***************
* Subroutine PRSHEX
*   Parse Hex Literal
*
PRSHEX leay -1,Y Back up to '$'
 bsr GETNUM
 ldd #T.HLIT*256+2
 bra NUMVA0

***************
GETNUM lbsr SKIPSP skip any preceeding spaces
 leax  ,Y
 ldy I.OPSP
 lbsr J$ASNM Go get numeric literal
 exg X,Y
 bcs ERILIT ERROR if J$ASNM found a bad number
 lda ,X+ get type of numeric literal
 cmpa #S.REAL is it real?
 rts

ERILIT lda #M$ILIT Error: illegal literal
 bra ERNOQ9 (ERRDIE)

***************
* Subroutine PRSSTR
*   Parse String Expression
*   And put it in I-Code Buffer

* Passed: (X)=SYMPT (Pointing to " Entry)
*                   (Y)=SRCPTR
* Returns: (Y)=SRCPTR updated Past String
* Destroys: A,B

PRSSTR bsr INSYM2 Set token & SYMTYP
 bra PRSST2
PRSST1 bsr OUTCOD put string char in I-Code
PRSST2 lda ,Y+ get (next) char of string literal
 cmpa #V$CR end of line?
 beq ERNOQU ..Yes; error: no ending quote
 cmpa #'" Embedded or ending quote?
 bne PRSST1 ..No; go get next string char
 cmpa ,Y+ Embedded quote?
 beq PRSST1 ..Yes; go get next string char
 leay -1,Y
 lda #V$ESTR Mark end of string
PRSST9 bra OUTCOD

ERNOQU lda #M$NOQU Error: missing quote
ERNOQ9 lbra ERRDIE
ERUDVR lda #M$UDVR Error: undefined variable
 bra ERNOQ9

 ifne INCLUDED&EDITOR
***************
* Subroutine PRSNAM
*   Parse Name in Source Line

* Passed:(Y)=SRCPTR
* Returns: (Y)=SRCPTR (updated if Name Found)
* Destroys: A,B,X,CC

PRSNAM ldx KEYWORDS get keyword tbl ptr
 lbsr SCHALL .. and search for a keyword (upper or lower case)
 beq PRSNA2 not found; go look for variable name
 stx SYMPT save symbol ptr
 ldd  ,X get SYMTYP & token from table
PRSNA0 lbra INSYM9 save token,SYMTYP; put token in I-Code; exit

PRSNA2 tst DEBUGGER Are variable references permitted?
 bmi ERUDVR ..No; error: undefined variable
 ldx I.SYMT get ptr to symbol table
 lbsr SCHALL Search symbol table for name
 bne PRSNA3 Found; continue
 tst DEBUGGER Are variable definitions allowed?
 bne ERUDVR ..No; error: undefined variable ref
 lbsr ADDSYM Add undefined name to symbol table
PRSNA3 ldd #T.VREF*256+VARIAB token & SYMTYP = variable ref
 bsr PRSNA0 save SYMTYP,token; put token in I-Code
 tfr X,D get symbol table ptr
 subd I.SYMT Subtract beginning of symtbl for fun
 std SYMPT save symbol ptr
PRSNA8 bsr OUTCOD put MSB in I-Code
 bsr OUTCDB
 lda TOKEN
 rts

OUTCDB tfr B,A put LSB in I-Code
* Fall through to OUTCOD

 endc
 pag
***************
* Subroutine OUTCOD (Byte)
*   put I-Code Byte Into I-Code Buffer

* Passed: (A)=Byte to put in IBUF
* Updates:           ICDPTR (I-Code Ptr)
* Destroys: CC

OUTCOD pshs D,X save regs
 ldx ICDPTR
 sta ,X+ put byte into buffer
 stx ICDPTR
 ldd ICDPTR
 subd I.STBG
 cmpb #$FF only permitted to generate 255 bytes per line
 bhs ERICOV
 clra clear carry (for OPTLRF)
 puls D,X,PC Restore regs & return

ERICOV lda #M$ICOV Error: I-Code overflow
 lbsr J$EREX PRINT ERROR message
 lbra J$EXIT Exit via ERROR trap

***************
* Subroutine NAMSYM
*   Parse a Symbolic Name in the Source Line
*   And Set the High-Order Bit of Its Last Byte

* Passed: (Y)=SRCPTR
* Returns: (Y)=First Non-Blank char
*          (A)=NAMTYP (Set By This Routine)
*          (B)=NAMLEN (Set By This Routine)
*          CC - Will Branch Equal if Name not Found
* Destroys: X

NAMSYM bsr SKIPSP Skip any spaces in source line
 pshs Y save it for return
 ldb #S.REAL
 stb NAMTYP Set default type=real
 clrb NAMLEN=0
 bsr ALPHA is it alphabetic?
 bcs NAMSY9 ..No; not a name, so return
 leay 1,Y Move SRCPTR to next char
NAMSY1 incb INCREMENT NAMLEN
 lda ,Y+ get next char
 bsr ALFNUM is it alphanumeric?
 bcc NAMSY1 ..Yes; loop until it isn't
 cmpa #'$ String suffix?
 bne NAMSY2 ..No; continue
 incb
 leay 1,Y
 lda #4
 sta NAMTYP
NAMSY2 leay -1,Y Backup source ptr
 lda #$80
 ora -1,Y Set the high order bit
 sta -1,Y of the name as a delimiter
NAMSY9 stb NAMLEN save NAMLEN
 puls Y,PC Restore SRCPTR & return

***************
* Subroutine SKIPSP (SRCPTR)
*   Skip Any Spaces in Source Line At [SRCPTR]

* Passed: (Y)=SRCPTR
* Returns: (A)=First Non-Blank char Found
*          (Y)=SRCPTR (addr (A) +1)

SKIPSP lda ,Y+ get (next) char
 cmpa #'  is it a space?
 beq SKIPSP ..Yes; skip it
 cmpa #V$LF linefeed?
 beq SKIPSP  ..Yes; skip it too
 leay -1,Y
 rts return

***************
* Subroutine ALFNUM (char)
*   Test is char is An Alphanumeric char

* Passed: (A)=char
* Returns: Carry=Set if (A) is not Alphanumeric
* Destroys: None

ALFNUM bsr ALPHA is char alphabetic?
 bcc ALPHA9 ..Yes; return (alphanumeric)
* Fall Through to DECDIG

***************
* Subroutine DECDIG (char)
*   Check to See if char is a Decimal Digit

* Passed: (A)=char
* Returns: (A)= Binary Value of Digit (If Found)
*          Carry Set (If not Found)
* Destroys: None

DECDIG cmpa #'0 is char below zero?
 bcs ALPHA9 ..Yes; return 'not a digit'
 cmpa #'9 is char above '9'?
 bls ALPHA8 ..No; then it's a digit
 bra ALPHA7 return (not a digit)

***************
* Subroutine ALPHA (char)
*   Test char to See if it is Alphabetic

* Passed: (A)=char
* Returns Carry=Set if Alphabetic
* Destroys: None

ALPHA anda #$7F Strip any parity bit
 cmpa #'A is char below "A"?
 bcs ALPHA9 ..Yes; exit (not alpha)
 cmpa #'Z is char between a-z?
 bls ALPHA8 ..Yes; exit (alpha)
 cmpa #'_ Underscore?
 beq ALPHA9 ..Yes; exit ALPHA
 cmpa #'a is char <= lowercase(a)?
 bcs ALPHA9 ..Yes; exit (not alpha)
 cmpa #'z is char between lowercase(a-z)?
 bls ALPHA8 ..Yes; exit (alpha)
ALPHA7 orcc #1 not ALPHA
 rts
ALPHA8 andcc #^Carry Clear carry bit (alpha)
ALPHA9 rts

 ifne INCLUDED&EDITOR
 ttl WORKSPACE/TABLE Routines
 pag
***************
* Subroutine ADDSYM
*   Add Symbol to Symbol Table

* Passed: NAMLEN Must Be Set
*                   (Y)=SRCPTR => Start of new Name
* Returns: (X)=Symbol Table Ptr
* Destroys: A,B,X,CC

ADDSYM ldx I.SYMT get symbol table address
 ldd -3,X get symbol table count
 addd #1 Increment number of symbol table entries
 std -3,X save updated number of entries
 ldb NAMLEN get name length
 clra
 addd #3 Add room for type bytes
 sty SRCPTR save source ptr
 bsr EXPSYM Expand symbol table
 pshs Y save symbol table ptr
 lda NAMTYP
 clrb
 std ,Y++
 clr ,Y+
 ldx SRCPTR get source ptr
ADDSY1 lda ,X+
 sta ,Y+ Move name string into table
 bpl ADDSY1
 leay  ,X Update source ptr
 puls X,PC get symbol tbl ptr and return

***************
* Subroutine EXPDSC (Size)
*   Increase the Data Description Table By (Size)
*   Bytes.  the Routine Checks for Available Free
*   Space, Then Relocates the Entire Tbl Downward.

* Passed: (D)=Size
* Returns: (D)=updated Size of Desc. Table
*          (X)=Ptr to DSCTBL end + 1
*          (Y)=Ptr to DSCTBL end - Size
*               (This is the addr of the new Entry)
* Destroys: CC

EXPDSC pshs D,U Save regs
 ldd G.VARS get count of free memory
 subd  ,S is there more than (size)?
 bhs EXPDS1 ..Yes; good-go do move
 lda #M$MFUL Error='memory full'
 lbra ERRDIE Exit through ERROR routine
EXPDS1 std G.VARS Update free memory count
 ldd I.DSCR (old) description tbl addr
 subd  ,S Minus size
 std I.DSCR Save (new) address
 ldu LNMTBL Move from
 ldd LNMTBL
 subd  ,S Minus size
 std LNMTBL Equals new destination
 tfr D,Y Move to
 ldd I.DSCR
 subd LNMTBL Size of area to move
 addd I.DSCS
 bsr MOVDWN Move it down
 ldd I.DSCS
 addd ,S++ Update descr tbl size
 std I.DSCS Save it
 leax  ,U Save dsctbl end for caller
 puls U,PC Restore reg & return

***************
* Subroutine EXPSYM (Size)
*   Increase the Symbol Table By (Size) Bytes.
*   the Routine Checks for Available Free Space,
*   Then Relocates the Entire Table Downward.

* Passed: (D)=Size
* Returns: (D)=updated Size of Symbol Table
*          (X)=Ptr to SYMTBL end + 1
*          (Y)=Ptr to SYMTBL end - Size
*               (This is the addr of the new Entry)
* Destroys: CC

EXPSYM pshs D,U Save regs
 bsr EXPDSC Allocate storage by moving dsctbl down
 subd  ,S Fix size of desc table
 std I.DSCS Save it
 leau  ,X Move FROM address for call to MOVDWN
 leax 3,Y Skip entry count & skip count
 stx I.SYMT Save new symbol table addr
 ldd I.SYMS get symbol table size
 bsr MOVDWN Move symbol table down
 addd ,S++ Update symbol table size
 std I.SYMS Save it
 leax  ,U Save symtbl end for caller
 puls U,PC Restore reg and return
 endc

***************
* Subroutine MOVDWN (FROM, TO, COUNT)
*   Move COUNT Bytes from FROM addr to TO addr.

* Fast block move.  Notice that data will be propagated
* strangely on a left-to-right basis if fields overlap.
* Therefore, this routine should be used generally to move
* data from a higher address to a lower address.

* Passed: (D)=COUNT
*         (U)=FROM addr
*         (Y)=TO addr
* Returns: (D)=COUNT (Unchanged)
*          (U)=FROM addr + COUNT
*          (Y)=TO addr + COUNT
* Destroys: CC

MOVDWN pshs D,X save regs
 leax D,U
 pshs X
MOVDW1 bitb #3 count divisible by four?
 beq MOVDW3
 lda ,U+ ..No; move one byte at a time
 sta ,Y+
 decb
 bra MOVDW1
MOVDW2 pulu D,X move data 4-bytes at a time
 std ,Y++
 stx ,Y++
MOVDW3 cmpu  ,S
 blo MOVDW2
MOVDW9 clr ,S++ discard temp, clear carry
 puls D,X,PC Restore count & return

 ttl Search
 pag
***************
* Subroutine Search (Trgptr,Tblptr)
*   Symbol table entry search routine.  Compares
*   a variable-length target string with a table
*   of variable-length strings.  the search table
*   must be preceeded by:
*    A Two-Byte count of the Entries in the Table
*    A One-Byte Skip-count

*   Each Table entry consists of:
*     1) Zero or more bytes which are ignored by
*        the search.  These contain fixed-length
*        data for each entry.
*     2) A string of one or more bytes, the last
*        of which has it's high order bit set.

* Passed: (X)=Tblptr Search table ptr
*         (Y)=Trgptr Target string ptr
*                (usually source ptr)

* Returns: (X)=Ptr to Table Entry (Before Skip
*                          Bytes) if Match Occurred
*                          else 'not Found' Entry
*          (Y)=Trgptr Advanced to Byte Following
*                          String if Match Occurred
*                          Unchanged if not Found
*          CC - Zero = not Found
*               Non-Zero = Found


SCHALL lda #$20 Entry point to match upper and lower case
SEARC0 pshs A,X,Y,U Save regs
*                        ,S = Lower Case Conversion
*                       1,S = Tblptr
*                       3,S = Trgptr

 ldu -3,X get number of entries in search table
 ldb -1,X get skip count
SEARC1 stx 1,S save current table ptr
 cmpu #0
 beq SEARC9 No more entries - not found
 leau -1,U
 ldy 3,S Reset TRGPTR
 leax B,X Ignore skip bytes (note: must be < 128)
SEARC3 lda ,X+ get next table char
SEARC4 eora ,Y+ is it equal to the next source char?
 beq SEARC6 ..Yes; go check for end of string
 cmpa  ,S Check for lower case match
 beq SEARC6
 leax -1,X
SEARC5 lda ,X+ get (next) table char
 bpl SEARC5 Loop until end of this entry
 bra SEARC1 Start search over with next entry
SEARC6 tst -1,X is this the last char to search?
 bpl SEARC3 ..No - go back and compare next char
 sty 3,S Table entry found - update TRGPTR
SEARC9 puls A,X,Y,U,PC return

* end of Compiler

