
 nam Binder
 use DEFS

 ttl External Linkages
 pag
 use LINKAGE

***************
* Global ENTRY Points

BNDENT equ *
 fdb PRPRAM-BNDENT Process run parameters
 ifne INCLUDED&EDITOR

 fdb BIND-BNDENT Bind procedure
 fdb PSTMT-BNDENT Bind stmt
 fdb PRT4HX-BNDENT Print hex addr

 else
PRPRAM rts
 endc

 ifne INCLUDED&EDITOR
***************
* EXTERNAL Subroutine References

J$EREX jsr M.COMAND
 fcb X$EREX Print error messsage and return
J$EXIT jsr M.COMAND
 fcb X$EXIT Abortive exit; recovering stack
J$RPLC jsr M.COMAND
 fcb X$RPLC Replace I-Code

J$EXDS jsr M.COMPIL
 fcb X$EXDS Expand desr tbl
J$MVDN jsr M.COMPIL
 fcb X$MVDN Block move down subroutine

 ttl Binder Definitions / variable storage
 pag
***************
*  The following tbl defines the possible treatment
*  of Operands/Arguments for the Operators/Functions

 org 0
NOARG rmb 1 No argument/operand
ONEINT rmb 1 One integer argument/operand
TWOINT rmb 1 Two integer
ONERL rmb 1 One real
TWORL rmb 1 Two real
ONENUM rmb 1 One numeric
TWONUM rmb 1 Two numeric
ONESTR rmb 1 One string
TWOSTR rmb 1 Two string
STRINT rmb 1 One string, one integer
STRIN2 rmb 1 One string, two integer
ONEBL rmb 1 One boolean
TWOBL rmb 1 Two boolean
TWOSN rmb 1 Two string-numeric
TWOBSN rmb 1 Two boolean-string-numeric

 ttl Dispatch Tables
 pag
* Statement Dispatch Table

STMDTB equ *

 fdb PGLOBL-STMDTB T.GLOB
 fdb PPARAM-STMDTB T.PRAM
 fdb PTYPE-STMDTB T.TYPE
 fdb PDIM-STMDTB T.DIM
 fdb PDATA-STMDTB T.DATA
 fdb PPRINT-STMDTB T.STOP
 fdb PBYE-STMDTB T.BYE
 fdb PTRON-STMDTB T.TRON
 fdb PTROFF-STMDTB T.TROF
 fdb PPRINT-STMDTB T.PAUS
 fdb PDEG-STMDTB T.DEG
 fdb PRAD-STMDTB T.RAD
 fdb PRETN-STMDTB T.RETN
 fdb PLET-STMDTB T.LET
 fdb PASSGN-STMDTB T.CXAS
 fdb PPOKE-STMDTB T.POKE
 fdb PIF-STMDTB T.IF
 fdb PELSE-STMDTB T.ELSE
 fdb PEIF-STMDTB T.EIF
 fdb PFOR-STMDTB T.FOR
 fdb PNEXT-STMDTB T.NEXT
 fdb PWHILE-STMDTB T.WHIL
 fdb PEWHL-STMDTB T.EWHL
 fdb PREPT-STMDTB T.REPT
 fdb PUNTIL-STMDTB T.UNTL
 fdb PLOOP-STMDTB T.LOOP
 fdb PELOOP-STMDTB T.ELOP
 fdb PEXIF-STMDTB T.EXIF
 fdb PEEXT-STMDTB T.EEXT
 fdb PON-STMDTB T.ON
 fdb PERROR-STMDTB T.EROR
 fdb PGOTO-STMDTB T.GOTO
 fdb COMERR-STMDTB T.GTBD
 fdb PGOSUB-STMDTB T.GOSB
 fdb COMERR-STMDTB T.GSBD
 fdb PRUN-STMDTB T.RUN
 fdb PKILL-STMDTB T.KILL
 fdb PINPUT-STMDTB T.INPT
 fdb PPRINT-STMDTB T.PRNT
 fdb PCHD-STMDTB T.CHD
 fdb PCHX-STMDTB T.CHX
 fdb PCREAT-STMDTB T.crt
 fdb POPEN-STMDTB T.OPEN
 fdb PSEEK-STMDTB T.SEEK
 fdb PREAD-STMDTB T.READ
 fdb PPRINT-STMDTB T.WRIT
 fdb PGET-STMDTB T.GET
 fdb PPUT-STMDTB T.PUT
 fdb PCLOSE-STMDTB T.CLOS
 fdb PREST-STMDTB T.REST
 fdb PDELET-STMDTB T.DELT
 fdb PCHAIN-STMDTB T.CHIN
 fdb PSYS-STMDTB T.SYS
 fdb PBASE0-STMDTB T.BAS0
 fdb PBASE1-STMDTB T.BAS1
 fdb PREMRK-STMDTB T.REM1
 fdb PREMRK-STMDTB T.REM2
 fdb PPRINT-STMDTB T.END
 fdb PLREF-STMDTB T.LREF
 fdb COMERR-STMDTB T.LRBD
 fdb PDEXC-STMDTB T.DEXC
 fdb PERRLN-STMDTB T.ERRL
 fdb PBKSL-STMDTB T.BKSL
 fdb PEOL-STMDTB T.EOL

* Expression Function Table

BADTOK equ 0
OUTTOK equ 7
OPLAST equ T.POS

EXPOPR equ *

 fcb S.INT*32 T.POS
 fcb S.INT*32 T.ERR
 fcb 0*32+TWONUM T.MOD
 fcb BADTOK*32 T.MOD
 fcb S.REAL*32+ONERL T.RND
 fcb S.REAL*32 T.PI
 fcb S.INT*32+TWOSTR T.SUBS
 fcb S.INT*32+ONENUM T.SGN
 fcb BADTOK*32 T.SGN
 fcb S.REAL*32+ONERL T.SIN
 fcb S.REAL*32+ONERL T.COS
 fcb S.REAL*32+ONERL T.TAN
 fcb S.REAL*32+ONERL T.ASN
 fcb S.REAL*32+ONERL T.ACS
 fcb S.REAL*32+ONERL T.ATN
 fcb S.REAL*32+ONERL T.EXP
 fcb 0*32+ONENUM T.ABS
 fcb BADTOK*32 T.ABS
 fcb S.REAL*32+ONERL T.LN
 fcb S.REAL*32+ONERL T.LOG
 fcb S.REAL*32+ONERL T.SQR
 fcb BADTOK*32 T.SQR
 fcb S.REAL*32+ONENUM T.INTF
 fcb BADTOK*32 T.INTF
 fcb S.INT*32+ONENUM T.FIX
 fcb BADTOK*32 T.FIX
 fcb S.REAL*32+ONENUM T.FLOT
 fcb BADTOK*32 T.FLOT
 fcb 0*32+ONENUM T.SQ
 fcb BADTOK*32 T.SQ
 fcb S.INT*32+ONEINT T.PEEK
 fcb S.INT*32+ONEINT T.NNOT
 fcb S.REAL*32+ONESTR T.VAL
 fcb S.INT*32+ONESTR T.LEN
 fcb S.INT*32+ONESTR T.ASC
 fcb S.INT*32+TWOINT T.NAND
 fcb S.INT*32+TWOINT T.NOR
 fcb S.INT*32+TWOINT T.NXOR
 fcb S.BOOL*32 T.TRUE
 fcb S.BOOL*32 T.FALS
 fcb S.BOOL*32+ONEINT T.EOF
 fcb S.STR*32+ONESTR T.TRIM
 fcb S.STR*32+STRIN2 T.MID
 fcb S.STR*32+STRINT T.LEFT
 fcb S.STR*32+STRINT T.RGHT
 fcb S.STR*32+ONEINT T.CHR
 fcb S.STR*32+ONENUM T.STRF
 fcb BADTOK*32 T.STRF
 fcb S.STR*32 T.DATE
 fcb S.STR*32+ONEINT T.TAB
 fcb OUTTOK*32 T.FIX1
 fcb OUTTOK*32 T.FIX2
 fcb OUTTOK*32 T.FIX3
 fcb OUTTOK*32 T.FLT1
 fcb OUTTOK*32 T.FLT2
 fcb S.BOOL*32+ONEBL T.NOT
 fcb 0*32+ONENUM T.NEG
 fcb BADTOK*32 T.NEG
 fcb S.BOOL*32+TWOBL T.AND
 fcb S.BOOL*32+TWOBL T.OR
 fcb S.BOOL*32+TWOBL T.XOR
 fcb S.BOOL*32+TWOSN T.GT
 fcb BADTOK*32 T.GT
 fcb BADTOK*32 T.GT
 fcb S.BOOL*32+TWOSN T.LT
 fcb BADTOK*32 T.LT
 fcb BADTOK*32 T.LT
 fcb S.BOOL*32+TWOBSN T.NE
 fcb BADTOK*32 T.NE
 fcb BADTOK*32 T.NE
 fcb BADTOK*32 T.NE
 fcb S.BOOL*32+TWOBSN T.EQ
 fcb BADTOK*32 T.EQ
 fcb BADTOK*32 T.EQ
 fcb BADTOK*32 T.EQ
 fcb S.BOOL*32+TWOSN T.GE
 fcb BADTOK*32 T.GE
 fcb BADTOK*32 T.GE
 fcb S.BOOL*32+TWOSN T.LE
 fcb BADTOK*32 T.LE
 fcb BADTOK*32 T.LE
 fcb 0*32+TWOSN T.PLUS
 fcb BADTOK*32 T.PLUS
 fcb BADTOK*32 T.PLUS
 fcb 0*32+TWONUM T.MINS
 fcb BADTOK*32 T.MINS
 fcb 0*32+TWONUM T.MUL
 fcb BADTOK*32 T.MUL
 fcb 0*32+TWONUM T.DIV
 fcb BADTOK*32 T.DIV
 fcb S.REAL*32+TWORL T.POWR
 fcb S.REAL*32+TWORL T.POWR

 ttl BINDER Routines
 pag
***************
* Subroutine PLREF
*   Process line reference; fix any Forward references

* Input:(Y)=I-Code ptr
* Output:(Y)=updated I-Code ptr
* Destroys: X,D,CC
* Global: I.LNT,I.APRC

PLREF ldd 0,Y get line number
 tst SMASH Compile mode?
 bne PLRE10 ..No
 pshs D save line number
 leay -1,Y Backup to token
 ldd I.ICLM copy I-Code limit
 std ICDPTR
 ldd #3 Delete three bytes
 lbsr J$RPLC Call replacer
 puls D Retrieve line number
 bra PLRE20
PLRE10 leay 2,Y Move past line definition
PLRE20 lbsr SRHLIN Find/insert line number
 bcc PLRE50 bra if already defined
 std 0,X Define line number (clear sign)
 tfr Y,D copy I-Code ptr
 subd I.ICBG Make ptr into offset
 leax 2,X get ptr to header link
PLRE30 ldu 0,X get next link
 std 0,X set offset in goto
PLRE40 leax 0,U copy next link
 bne PLRE30 bra if not end
 bra PSTMT Go do stmt
PLRE50 lda #M$MDLN Err: multiply defined line number
 bsr ERROR
* bra PSTMT fall thru

 pag
***************
* Subroutine PSTMT
* Process Statement
*
*   General Statement Dispatcher; Tests Initial token and
*   Determines whether declaration, executable, or neither

*    Then if First Executable, Out of Sequence Declaration, Or
*    Neither and Takes Appropriate Action

* Input:(Y)=I-Code ptr
* Output: (Y)=I-Code ptr (at Beginning of next stmt)
* Destroys: X,D,CC
* Global: I.OPSP,I.SYMT,I.DSCR,I.LNT

PSTMT leax STMDTB,PCR get dispatch tbl addr
 ldb ,Y+ get token
 bpl PSTMT1 bra if expression component
 ldd #PASSGN-STMDTB get offset of assignment routine
 bra PSTMT2
PSTMT1 aslb shift For two byte entries
 clra
 ldd D,X get dispatch offset
 cmpd #EXECUT-STMDTB executable?
 bcs PSTMT3 No; process it
PSTMT2 tst PEXECU are we doing executables?
 bne PSTMT3 Yes; go do it
 inc PEXECU We are now
 pshs D save routine offset
 tfr Y,D copy I-Code ptr
 subd I.ICBG Make ptr into offset
 subd #1 Correct for I-Code ptr position
 ldu I.APRC get ptr to procedure
 std P.EXEC,U set beginning ptr
 puls D Retrieve routine offset
PSTMT3 jmp D,X Process stmt

***************
* Subroutine PERRLN
*   Process line with compiler error

* Input: (Y)=I-Code ptr
* Output: (Y)=updated I-Code ptr
* Destroys: X,D,CC
* Global: I.APRC

PERRLN ldx I.APRC get procedure addr
 lda #1 set error flag
 sta P.STAT,X
* bra PREMRK fall thru

***************
* Subroutine PREMRK
*   Process REMARK

* Input: (Y)=I-Code ptr
* Output: (Y)=updated I-Code ptr
* Destroys: D,CC
* Global: none

PREMRK ldb ,Y+ get token & byte count
 clra clear Msb
 leay D,Y Skip REM stmt
 rts

***************
* Subroutine Error
*   Prints I-Code offset of offending location and error message

* Input: (A)=ERR Code
*        (Y)=I-Code ptr
* Output: none
* Destroys: CC
* Global: I.ASTR

ERROR pshs D,X,Y save registers
 ldx I.APRC get procedure addr
 lda #1 Mark error
 sta P.STAT,X
 lda PRTCTL Check print control
 bmi ERRO10 bra if no print
 ldd 4,S get I-Code ptr
 subd I.ICBG Make ptr an offset
 leas -5,S get scratch room
 leax 0,S get ptr to scratch for conversion
 bsr PRT4HX Call conversion
 lda #V$SPAC put blank in buffer
 sta ,X+
 lda #CMDOUT get I/O path
 leax 0,S get I/O ptr
 ldy #5 get length
 OS9 I$Write Print it
 leas 5,S Return scratch
 ldb 0,S get error code
 lbsr J$EREX Print error message
ERRO10 puls D,X,Y,PC and return

***************
* Subroutine PRT4HX

* Converts Contents of D To Four Hex Characters
*    at Location Specified in X

PRT4HX bsr PRT2HX
 tfr B,A
PRT2HX pshs A
 lsra
 lsra
 lsra
 lsra
 bsr PRTHEX
 puls A
 anda #$0F
PRTHEX adda #'0
 cmpa #'9
 bls PRTHE1
 adda #7
PRTHE1 sta ,X+
 rts

***************
* Stmt Separator & Terminator

PBKSL equ *
PEOL equ *
SKPEOL ldb 0,Y get next token
 bsr EOLTST Eol?
 bne PEOL10 ..no; just return
SKPONE leay 1,Y Skip token
PEOL10 rts

EOLTST cmpb #T.EOL end of line?
 beq EOLTXX ..Yes
 cmpb #T.BKSL end of stmt?
EOLTXX rts

 ttl BINDER Declarative stmt routines
 pag
***************
* Subroutine PTYPE
*   Process TYPE Stmt

* Input: (Y)=I-Code ptr
* Output: (Y)=updated I-Code ptr
* Destroys: X,D,CC
* Global: I.SYMT

PTYPE lbsr GETTYP get symbol ptr & decode type byte
 ldb DEFINT defined?
 beq PTYPE1 No; good
 lda #M$MDV Err: multiply defined variable
 bsr ERROR
PTYPE1 leay 4,Y Move past variable ref and '='
 lda #S.FLDD set definition to give components
 sta DEFNAS
 ldd NEXALC get current variable alocation
 pshs D save it
 clra
 clrb clear Allocation for record
 std NEXALC
 bsr PDECLR Process component declarations
 ldd PCOMPT get ptr to end of list
 subd I.ICLM get size of declr
 beq PTYPE3 bra if all errors
 addd #3 add room for total size & component count
 cmpd G.VARS enough memory?
 lbhs QuitBind ..No; abort
 pshs X,Y save symbol ptr & I-Code ptr
 lbsr J$EXDS get descr area
 ldd NEXALC set rcd size
 leau 0,Y copy descr ptr
 std ,Y++
 clr ,Y+ Clear component count
 ldx I.ICLM get ptr to component list
PTYPE2 ldd ,X++ get component symbol ptr
 subd I.SYMT Make ptr into offset
 std ,Y++ put in descr area
 inc 2,U Count component
 cmpx PCOMPT are there more components?
 bcs PTYPE2 Yes; go do them
 tfr U,D copy descr ptr
 puls X,Y get symbol ptr, I-Code ptr
 subd I.DSCR Make ptr into offset
 std 1,X put in symbol tbl
 lda #S.TYPD+S.RCRD
 sta 0,X set type byte
PTYPE3 puls D Retrieve current allocation
 std NEXALC Restore variable allocation
 rts

 pag
***************
* Subroutine PPARAM
*   Process parameter declarations

* Same as PTYPE

PPARAM lda #S.PARM get definition type
 bra PDIM1

***************
* Subroutine PDIM
*   Process DIM Stmt

* Same as PTYPE

PDIM lda #S.VAR get definition type
PDIM1 sta DEFNAS set definition
* bra PDECLR fall thru

***************
* Subroutine PDECLR
* Process Variable Declarations

* Input: (Y)=I-Code ptr
* Output: (Y)=updated I-Code ptr
* Destroys: D,CC
* Global: PCOMPT,TYPE,SHAPE,DEFINT,DEFNAS,SYMPTR

PDECLR ldd I.ICLM get bottom of free space
 pshs D,X save beginning of component list & x
 std PCOMPT set beginning of component list
PDECL1 bsr PID Process id
 ldb ,Y+ get next token
 cmpb #T.COMA is there another?
 beq PDECL1 Yes; go get it
 cmpb #T.COL is there explicit type?
 beq PDECL2 Yes; go get it
 leay -1,Y Back up to unknown
 ldb #1 set flag for implicit typing
 bra PDECL3
PDECL2 lbsr PVTYPE Process explicit type
 clrb set Flag for explicit typing
PDECL3 pshs B,Y save flag & I-Code ptr
 ldx 3,S get beginning of component list
 ldd PCOMPT get end of list
 std 3,S save end for looping
 stx PCOMPT Reset component stack
 subd PCOMPT
 aslb
 rola
 addd 3,S
 cmpd LNMTBL memory full?
 lbhs QuitBind ..Yes; abort
 bra PDECL6
PDECL4 ldu ,X++ Pop symbol ptr
 tst 0,S Test flag
 beq PDECL5 bra if explicit
 lda 0,U get implicit type
 sta TYPE set type
 lbsr GETVSZ get simple variable size
 std ELMSIZ set element size
PDECL5 lbsr DEFVAR Go define variable
PDECL6 cmpx 3,S is there another?
 bcs PDECL4 Yes; go do it
 ldd PCOMPT Mark current position in stack
 std 3,S
 puls B,Y Clean stack, restore I-Code ptr
 ldb ,Y+ get next token
 cmpb #T.SCOL is there another list?
 beq PDECL1 Yes
 puls D,X,PC

***************
* Subroutine PID
*   Process Variable Id

* Input: (Y)=I-Code ptr
* Output: (Y)=updated I-Code ptr
* Destroys: U,X,D,CC
* Global: SYMPTR,DEFINT,SHAPE,TYPE

PID lbsr GETTYP get symbol ptr, decode type byte
 ldb DEFINT already defined?
 beq PID1 No; good
 lda #M$MDV Err: multiply defined variable
 lbsr ERROR
 leay 3,Y Skip varref
 ldb 0,Y get following token
 cmpb #T.LPAR are there subscripts?
 bne PID20 ..No
 leay 1,Y Skip '('
PID10 bsr GETSIZ Skip dimension
 ldb ,Y+ get next token
 cmpb #T.COMA Another dimension?
 beq PID10 ..Yes
PID20 rts
PID1 ldd PCOMPT
 addd #10
 cmpd LNMTBL Memory full?
 lbhs QuitBind ..Yes; abort
 ldx PCOMPT get component list ptr
 ldd SYMPTR get symbol ptr
 std ,X++ put in component list
 leau 0,X copy ptr to subscript count
 clr ,X+ Clear subscript count
 leay 3,Y Move past id
 ldb 0,Y get next token
 cmpb #T.LPAR are there subscripts?
 bne PID3 No; skip processing
 leay 1,Y Skip '('
PID2 bsr GETSIZ get dimension size
 std ,X++ put in component list
 inc 0,U Count it
 ldb ,Y+ get next token
 cmpb #T.COMA Another subscript?
 beq PID2 Yes; get it
PID3 stx PCOMPT save variable stack ptr
 rts

***************
* Subroutine GETSIZ
*   get a Size From an I-Code Literal

* Same as PID

GETSIZ ldb ,Y+ get literal token
 clra clear Msb
 cmpb #T.BLIT byte?
 beq GETSI1 Yes
 lda ,Y+ get msb value
GETSI1 ldb ,Y+ get lsb value
 rts

***************
* Subroutine PVTYPE
*   Process Variable type Declaration; Simple Types Only

* Input: (Y)=I-Code ptr
* Output: (Y)=updated I-Code ptr
* Destroys: CC
* Global: SYMPTR,TYPE,ELMSIZ

PVTYPE lda ,Y+ get type token
 cmpa #T.VREF user type?
 beq PVTYP2 Yes; handle it
 suba #T.BYTE Convert token to type
 sta TYPE set type
 cmpa #S.STR string type?
 bne PVTYP1 No; get size
 ldb 0,Y get token after type
 cmpb #T.LBKT '['?
 bne PVTYP1 No; get default size
 leay 1,Y Skip '['
 bsr GETSIZ get size
 leay 1,Y Skip ']'
 bra PVTYP4
PVTYP1 lbsr GETVSZ get simple variable size
 bra PVTYP4
PVTYP2 leay -1,Y Backup for GETTYP
 lbsr GETTYP get symbol ptr; decode type byte
 leay 3,Y Move past variable reference
 ldb DEFINT get definition
 cmpb #S.TYPD type definition?
 beq PVTYP3 Yes; good
 lda #M$ITYP Err: illegal type definition
 lbra ERROR

PVTYP3 ldd 1,X get rcd descr offset
 std SYMPTR save it
 ldx I.DSCR get descr area base
 ldd D,X get rcd size
PVTYP4 std ELMSIZ set size
 rts

***************
* Subroutine DEFVAR
*   Define Variable; Build Description Area

* save as PDECLR

DEFVAR ldb ,X+ get dimension count
 beq DEFV07 bra if simple
 pshs B save count
 aslb shift For symbol tbl type
 aslb
 aslb
 stb SHAPE save it
 lsrb shift Back
 lsrb count*2
 leax B,X get ptr to next variable
 addb #4 add for offset & totalsize
 pshs X,U save variable stack ptr & symbol ptr
 lda TYPE get type
 cmpa #S.STR string?
 bcs DEFV02 is simple
 addb #2 Need two more for string or record
DEFV02 clra clear Msb
 cmpd G.VARS enough room?
 lbhi QuitBind ..No; abort
 lbsr J$EXDS get description area
 ldx 0,S get variable stack ptr
 leau 2,Y get ptr to total size
 ldd #1 set totalsize
 std ,U++ put in descr area
DEFV03 ldd ,--X get subscript
 std ,U++ put in descr area
 bsr DIMMUL Multiply subscript by size
 dec 4,S Count down
 bne DEFV03 bra if more
 lda TYPE get type
 cmpa #S.STR What type?
 bls DEFV05 is simple
 ldd SYMPTR get rcd descr offset
 std 0,U put in descr area
 coma set Carry
DEFV05 ldd ELMSIZ get element size
 bcs DEFV06 bra if no descr init
 std 0,U
DEFV06 bsr DIMMUL get total array size
 tfr Y,D copy descr ptr
 puls X,U Restore ptrs
 subd I.DSCR Make ptr into offset
 std 1,U put in symbol tbl
 leas 1,S Return scratch
 bra DEFV10
DEFV07 stb SHAPE Clear shape
 lda TYPE get type
 cmpa #S.STR What type?
 bhi DEFV08 is record
 ldd ELMSIZ get string max len
 bra DEFV09
DEFV08 ldd SYMPTR get rcd descr offset
DEFV09 std 1,U put in symbol tbl
DEFV10 lda TYPE get type
 ora SHAPE Encode shape
 ora DEFNAS Encode definition
 sta 0,U set type byte
 pshs X save variable stack ptr
 leax 0,U copy symbol ptr
 lbsr ALCSTO Go allocate storage
 ldx PCOMPT get component list
 stu ,X++ put symbol ptr in list
 stx PCOMPT save component ptr
 puls X,PC

***************
* Subroutine DIMMUL
*   Multiple Totalsize By D

* Input: (D)=Factor To Multiply Totalsize By
*        (Y)=Description Area ptr
* Output: none
* Destroys: CC
* Global: none

DIMMUL pshs D save multiplier
 ldb 2,Y get totalsize msb
 mul
 bne DIMERR bra if overflow
 lda 1,S get multiplier lsb
 ldb 2,Y get totalsize msb
 mul
 tsta overflow?
 bne DIMERR Yes; too bad
 stb 2,Y save partial product
 lda 0,S get multplier msb
 ldb 3,Y get totalsize lsb
 mul
 tsta overflow?
 bne DIMERR Yes
 addb 2,Y add previous partial
 bcs DIMERR bra if overflow
 stb 2,Y save partial
 lda 1,S get multiplier lsb
 ldb 3,Y get totalsize lsb
 mul
 adda 2,Y add previous partial
 bcs DIMERR bra if overflow
 std 2,Y put in descr area
 puls D,PC Restore size & return
DIMERR lda #M$ASO Err - array size overflow
 lbsr ERROR
 puls D,PC Restore size & return

***************
* Subroutine PDATA
*   Process Data Stmt

* Binds expressions of DATA stmt & links stmts
*    into circular list

* Input: (Y)=I-Code ptr
* Output: (Y)=updated I-Code ptr
* Destroys: U,X,D,CC
* Global: DAT1ST, DATPTR

PDATA ldu DATPTR get ptr to previous stmt
 bne PDATA1 bra if there was one
* Mark First Data Stmt
 tfr Y,D copy I-Code ptr
 subd I.ICBG Make ptr into offset
 std DAT1ST set first data stmt
 bra PDATA2
* Make Previous Data Stmt Point To This One
PDATA1 tfr Y,D copy I-Code ptr
 subd I.ICBG Make ptr into offset
 std 0,U put in previous stmt
* Process Expressions
PDATA2 lbsr PEXPRN Bind expression
 lbsr POPOP Keep opstack clear
 ldb ,Y+ get next token
 cmpb #T.COMA is there another expression
 beq PDATA2 Yes; go do it
* Link This Stmt To First
 sty DATPTR save ptr to this data stmt
 ldd DAT1ST get offset of first stmt
 std ,Y++ put in this one
 lbra SKPONE Skip end of line

 ttl BINDER Executable stmt routines
 pag

EXECUT equ *
***************
* Subroutine PASSGN
*   Process Let stmt

* Input: (Y)=I-Code ptr
* Output: (Y)=updated I-Code ptr
* Destroys: X,D,CC
* Global: I.OPSP

PASSGN leay -1,Y Backup to expression beginning
* bra PLET fall thru

***************
* Subroutine PLET
*   Process Assignment stmt

* Same as PLET

PLET bsr PASGVR Process variable assignment
 leay 1,Y Move past assignment operator
 lbsr PEXPRN Process expression
 lbsr POPOP get result type
  sta TYPE save type
 lbsr POPOP get destination type
 cmpa TYPE Do types agree?
 beq PASSG4 Yes; good
 cmpa #S.REAL numeric?
 bhi PASSG3 No; error
 beq PASSG1 Real; set for float
 lda #T.FIX1 Fix real for integer destination
 bra PASSG2
PASSG1 lda #T.FLT1 Float integer for real destination
PASSG2 ldb TYPE get result type
 cmpb #S.REAL numeric?
 bhi PASSG3 No; error
 lbsr INSTOK Insert conversion token
 bra PASSG4
PASSG3 lbsr ERIET Err - illegal expression type
PASSG4 lbra SKPEOL

***************
* Subroutine PASGVR
*   Process Variable Assignment

* Input: (Y)=I-Code ptr
* Output: (Y)=updated I-Code ptr
* Destroys: X,D,CC
* Global: I.SYMT

PASGVR lda 0,Y get token
 cmpa #T.CXAS complex assignment?
 lbne PEXPRN Process variable reference
 leay 1,Y Skip token
 lbsr PEXPRN Process variable reference
PASG00 lda -3,Y get token of final level
 cmpa #T.VREF simple?
 bcc PASGV1 ..No
 ldd SYMPTR get symbol tbl ptr
 subd I.SYMT Make ptr into offset
 std -2,Y put in I-Code
 lda #T.VREF
PASGV1 adda #T.AREF-T.VREF Convert to addr reference
 sta -3,Y put in I-Code
 rts

***************
* Subroutine PPOKE
*   Process Poke stmt

* Form: T.POKE <Integer> T.COMA <Integer> <End-of-Line>

* Input: (Y)=I-Code ptr
* Output: (B)=Last token
*         (Y)=I-Code ptr (Updated past Last Token)
* Destroys: X,A,CC
* Global: I.OPSP

PPOKE bsr PPOK20 get an integer expression
PPOK20 bsr PIEXPR get another
PPOK30 leay 1,Y Move past next token
 rts

***************
* Subroutine PON
*   Process ON stmt

PON ldb ,Y+ get token following ON
 cmpb #T.EROR is this ON ERROR?
 beq PON20 Yes; process single line reference
 leay -1,Y Back up to expression
 bsr PPOK20 (piexpr ,y+) call integer expression processor
 ldd ,Y++ get element count
PON10 pshs D save it
 leay 1,Y Move I-Code ptr to jump position
 bsr PGOTO Call goto processor
 puls D Retrieve element count
 subd #1 Count down
 bne PON10 bra if more
 rts
PON20 ldb ,Y+ get next token
 lbsr EOLTST End of line?
 beq PGOTXX
*   fall thru to PGOTO

***************
* Subroutine PGOTO
*   Process GOTO stmt

* Input: (Y)=I-Code ptr
* Output: (Y)=updated I-Code ptr
* Destroys: X,D,CC
* Global: I.LNT

PGOTO ldd 0,Y get line number
 bsr SRHLIN Find/insert line number
 ldd 2,X get link/location
 bcc PGOT10 bra if defined
 sty 2,X set new header
PGOT10 std 0,Y set link/definition
 inc -1,Y Bind token
 leay 3,Y Move past goto & terminator
PGOTXX rts

PGOSUB equ PGOTO

***************
* Subroutine SRHLIN

* Find Line Number in Line Number Table; Insert Line
*    Line Number if Not Found

SRHLIN ldx I.DSCR get ptr to tbl top
 pshs D save line number
 bra SRHL20
SRHL10 ldd 0,X get tbl entry
 anda #$7F Clear sign
 cmpd 0,S Line number in question?
 beq SRHL30
SRHL20 leax -4,X Move to next entry
 cmpx LNMTBL Out of tbl?
 bcc SRHL10 ..No
 ldd G.VARS Take free space
 subd #4
 bcs QuitBind Abort if out of memory
 std G.VARS
 ldd 0,S get line number
 ora #$80 set undefined flag
 std 0,X put in tbl
 clra set End of list link
 clrb
 std 2,X
 stx LNMTBL Increase tbl
SRHL30 lda 0,X get udefined flag
 rola move Flag to carry
 puls D,PC

QuitBind lda #M$MFUL Err: memory full
 sta I.ERR
 lbsr ERROR Print error message
 lbsr DONE collapse I-code to reasonable state
 lbra J$EXIT ..Abort

***************
* Subroutine PERROR
*   Error stmt

PERROR equ *
* bra PIEXPR fall thru

***************
* Subroutine PIEXPR
*   Process an Expression and convert to Integer if necessary

* Input: (Y)=I-Code ptr
* Output: (B)=Current token
*         (Y)=updated I-Code ptr
* Destroys: X,A,CC
* Global: none

PIEXPR lbsr PEXPRN Process expression
 lbsr POPOP get result type
 cmpa #S.REAL numeric?
 beq PIEXP1 is real; fix it
 bcs PGOTXX Yes; good (rts)
ERIET lda #M$IET Err - illegal expression type
 lbra ERROR
PIEXP1 lda #T.FIX1
 lbra INSTOK

***************
* Subroutine PIF
*   Process IF stmt

* Input: (Y)=I-Code ptr
* Output: (Y)=updated I-Code ptr
* Destroys: X,D,CC
* Global: I.ICBG

PIF lbsr PBEXPR get boolean expression
 lda 3,Y get token following THEN
 cmpa #T.LREF is there a line ref?
 beq PIF1 Yes; do transfer
 lda #T.IF get token
 lbra PEXIF1

PIF1 pshs Y save I-Code ptr
 leay 4,Y Move I-Code ptr
 bsr PGOTO Process transfer
 tfr Y,D copy I-Code ptr
 subd I.ICBG get I-Code offset
 std [,S++] put offset in I-Code
 rts

***************
* Subroutine PELSE
*   Process ELSE stmt

* Same as PIF

PELSE ldd #T.IF*256+2 set parameters
 lbsr CONCHK Call control structure check
 ldu 1,X get ptr to IF stmt
 sty 1,X Replace top of stack
 leay 2,Y Move I-Code ptr
 lbsr SKPEOL Skip backslashes & eol
 tfr Y,D copy I-Code ptr
 subd I.ICBG get I-Code offset
 std 0,U put in I-Code
 rts

***************
* Subroutine PEIF
*   Process ENDIF stmt

* Same as PIF

PEIF ldd #T.IF*256+1 set parameters
 lbsr CONCHK Check control structure
 leay 1,Y Move I-Code ptr
PEIF1 tfr Y,D copy I-Code ptr
 subd I.ICBG get I-Code offset
 std [1,X] put in I-Code
 lbra POPCN

***************
* Subroutine PFOR
*   Process FOR stmt

* Same as PIF

PFOR lbsr GETTYP get type byte and decode
 lbsr CHKDEF Check if defined, define if not
 cmpa #S.VAR Check if variable
 bne PFOR1 Not variable; abort
 lda TYPE get type
 cmpa #S.INT integer?
 beq PFOR2 Yes; process it
 cmpa #S.REAL real?
 beq PFOR2 Yes; do it
PFOR1 lda #M$IFV Err - illegal for variable
 lbsr ERROR
 ldd #$FFFF Make SYMPTR illegal
 std SYMPTR
 bra PFOR3
PFOR2 ldb SHAPE simple variable?
 bne PFOR1 No; abort
 adda #T.SBYT get token
 sta 0,Y put in I-Code
 ldd 1,X get runtime storage offset
 std 1,Y put in I-Code
PFOR3 ldx I.OPSP get control stack ptr
 leax -7,X Make room for FOR
 stx I.OPSP save ptr
 lda TYPE get type
 sta 0,X Push it
 ldd SYMPTR get symbol tbl ptr
 subd I.SYMT Make ptr into offset
 std 1,X Push it
 clra clear D
 clrb
 std 5,X Push it
 leay 4,Y Move I-Code ptr to expression
 bsr FORTYP Check expression type
 bsr FORSUB Allocate terminal, process expression
 std 3,X Push terminal offset
 lda 0,Y get next token
 cmpa #T.STEP is there an increment?
 bne PFOR4 No; almost done
 bsr FORSUB Allocate increment, process expression
 std 5,X Push increment offset
PFOR4 leay 1,Y Move to branch
 sty ,--X Push I-Code ptr
 lda #T.FOR get structure token
 sta ,-X Push it
 stx I.OPSP save control stack ptr
 leay 3,Y Move to next stmt
PFOR9 rts

***************
* Subroutine FORSUB
*   Allocate storage for a FOR temp (terminal or increment)
*    and process it's expression

* Input: (Y)=I-Code ptr
* Output: (D)=Runtime Storage offset
*         (Y)=updated I-Code ptr
* Destroys: X,CC
* Global: I.APRC,P.VARC

FORSUB ldd NEXALC get current allocation
 pshs D save it for return
 std 1,Y put in I-Code
 ldx I.OPSP get control stack ptr
 lda 0,X get type
 leax ALCSZT,PCR get ptr to variable size tbl
 ldb A,X get variable size
 clra clear Msb
 addd NEXALC get new allocation
 std NEXALC save it
 leay 3,Y Move to expression
 bsr FORTYP Process it
 ldx I.OPSP get control stack ptr
 puls D,PC get offset & return

***************
* Subroutine FORTYP
*   Check type and Insert Conversion token if Necessary

* Same as PFOR

FORTYP lbsr PEXPRN Process initial expression
 lbsr POPOP get result type
 cmpa 0,U Expression types agree?
 beq PFOR9 Yes; done (rts)
 cmpa #S.REAL numeric?
 bcs FORTY2 Integer; float it
 lbne ERIET Err - illegal expression type

FORTY1 lda #T.FIX1 Fix real result
 bra FORTY3
FORTY2 lda #T.FLT1 Float integer result
FORTY3 lbra INSTOK Insert token

***************
* Subroutine PNEXT
*   Process NEXT stmt

* Same as PIF

PNEXT leay -1,Y Backup to stmt token
 ldd #T.FOR*256+11
 lbsr CONCHK Call control structure test
 ldd 2,Y get symbol tbl offset
 cmpd 4,X same as for's offset?
 beq PNEXT4 Yes; good
 lda #M$IFV Err - illegal for variable
 lbsr ERROR
 bra PNEXT6
PNEXT4 addd I.SYMT Make offset into ptr
 exg D,X Move symbol ptr to ptr register
 ldx 1,X get runtime storage offset
 exg D,X Switch back
 std 2,Y put in I-Code
 lda 3,X get type
 anda #2 set code 0=int step 1, 2=real step 1
 sta 1,Y put in I-Code
 ldd 6,X get terminal offset
 std 4,Y put in I-Code
 ldd 8,X get increment offset
 std 6,Y put in I-Code
 beq PNEXT5 bra if no increment
 inc 1,Y set code for step n
PNEXT5 ldu 1,X get ptr to FOR stmt
 tfr Y,D copy I-Code ptr
 subd I.ICBG Make ptr into offset
 addd #1 Make offset of next type byte
 std 0,U put in FOR stmt
 leau 3,U Move ptr to stmt following FOR
 tfr U,D
 subd I.ICBG Make it offset
 std 8,Y put in I-Code
PNEXT6 leay 11,Y Move I-Code ptr to next statment
 lbsr POPCN Pop endexits and this control structure
 leax 7,X Pop extra room for used
 stx I.OPSP get control stack ptr
 rts

***************
* Subroutine PWHILE
*   Process WHILE stmt

* Same as PIF

PWHILE leau -1,Y get ptr to stmt beginning
 pshs U save it
 bsr PBEXPR get boolean expression
 puls D get ptr to stmt beginning
 std 0,Y save in jump ptr
 lda #T.WHIL get token
 bra PEXIF1 Push on ctl stack, skip 'do' token

***************
* Subroutine PEWHL
*   Process ENDWHILE stmt

* Same as PIF

PEWHL ldd #T.WHIL*256+3 set structure type
 bsr CONCHK Call control structure check
 ldx 1,X get ptr to while jump ptr
 ldd 0,X get ptr to stmt beginning
 subd I.ICBG get I-Code offset
 std 0,Y put in endwhile jump ptr
 leay 3,Y Move I-Code ptr to next stmt
 tfr Y,D copy I-Code ptr
 subd I.ICBG get I-Code offset
 std 0,X put in while jump ptr
 lbra POPCN

***************
* Subroutine PREPT
*   Process REPEAT stmt
* Alternate entry for LOOP stmt is PRETP0

* Same as PIF

PREPT lda #T.REPT get sturcture token
PREP10 lbsr SKPONE Skip to next stmt
 bra PUSHCN Push on control stack

***************
* Subroutine PUNTIL
*   Process UNTIL stmt

* Same as PIF

PUNTIL bsr PBEXPR get boolean expression
 lda #T.REPT set structure type
PUNT10 leay -1,Y
 ldb #3 Number of bytes to skip if error
 bsr CONCHK Call control structure check
 ldd 1,X get ptr to after REPEAT
 subd I.ICBG get I-Code offset
 std 1,Y put in I-Code
 leay 4,Y Move I-Code ptr to next stmt
 bra POPCN Go pop structure

***************
* Subroutine PLOOP
*   Process LOOP Statment

* Same as PIF

PLOOP lda #T.LOOP get structure token
 bra PREP10

***************
* Subroutine PELOOP
*   Process ENDLOOP stmt

* Same as PIF

PELOOP lda #T.LOOP set structure type
 bra PUNT10

***************
* Subroutine PEXIF
*   Process EXITIF stmt

* Same as PIF

PEXIF bsr PBEXPR get boolean expression
 lda #T.EXIF get structure token
PEXIF1 bsr PUSHCN Push on control stack
 leay 3,Y Move I-Code ptr past THEN
 lbra SKPEOL

***************
* Subroutine PBEXPR
*   Process Boolean Expression

* Same as PIF

PBEXPR lbsr PEXPRN Process exprssion
 lbsr POPOP get result type
 cmpa #S.BOOL boolean?
 beq PBEXP1 Yes; good
 lda #M$IET Err - not boolean expression
 lbsr ERROR
PBEXP1 leay 1,Y Move I-Code ptr to jump ptr
 rts

***************
* Subroutine PEEXT
*   Process ENDEXIT stmt

* Same as PIF

PEEXT ldd #T.EXIF*256+3 set parameters
 bsr CONCHK Call control structure check
 leau 0,Y get ptr to jump offset
 leay 3,Y Move I-Code ptr to next stmt
 lbsr PEIF1 put in jump offset
 stu ,--X put in control stack
 lda #T.EEXT get structure token
 bra PUSHC1

***************
* Subroutine PUSHCN
*   Push Control Structure

* Input: (A)=token
*        (Y)=I-Code ptr
* Output: (X)=Control Stack ptr
* Destroys: none
* Global: I.OPSP

PUSHCN ldx I.OPSP get control stack
 sty ,--X Push I-Code ptr
PUSHC1 sta ,-X Push token
 stx I.OPSP save stack ptr
 rts

***************
* Subroutine CONCHK

* Skips Down Control Stack To First Non-Endexit, if none Error
*  Then Checks that First Non-Endexit is Specified TYPE, if Not
*  Errors.  If Error, Skips I-Code ptr Specified bytes

* Input: (A)=type of Control Structure
*        (B)=bytes of I-Code To Skip on Error
*        (Y)=I-Code ptr
* Output: (X)=Control Stack Entry ptr
*         (Y)=updated I-Code ptr
* Destroys: B,CC
* Global: I.OPSP

CONCHK pshs A save control structure type
 ldx I.OPSP get control stack ptr
 bra CONCH2
CONCH1 leax 3,X Move to next entry
CONCH2 cmpx I.OPBG End of stack?
 bcc CONCH3 Yes; error
 lda 0,X get token
 cmpa #T.EEXT is this an endexit?
 beq CONCH1 Yes; try next
 cmpa 0,S correct type?
 beq CONCH4
CONCH3 leas 3,S Return type & return addr
 lda #M$UCS Err - unmatched control structure
 lbsr ERROR
 leay B,Y Skip I-Code
 lbra SKPEOL
CONCH4 puls A,PC

***************
* Subroutine POPCN
*   Pops any ENDEXITs and following structure

* Input: (Y)=I-Code ptr
* Output: none
* Destroys: X,D,CC
* Global: I.OPSP

POPCN ldx I.OPSP get control stack ptr
 bra POPCN2
POPCN1 lda 0,X get token
 cmpa #T.EEXT endexit?
 bne POPCN3 No; go pop it
 tfr Y,D copy I-Code ptr
 subd I.ICBG get I-Code offset
 std [1,X] put in I-Code
 leax 3,X Pop endexit
POPCN2 cmpx I.OPBG End of stack?
 bcs POPCN1 No; do next one
 bra POPCN9 Return
POPCN3 leax 3,X Pop next structure
POPCN9 stx I.OPSP save control stack ptr
 rts

***************
* Subroutine PRUN
*   Process RUN stmt

* Input: (Y)=I-Code ptr
* Output: (Y)=I-Code ptr (updated)
* Destroys: X,D,CC
* Global: DEFINT, SHAPE, TYPE, NEXRUN

PRUN leay -1,Y Backup to token
 lbsr GETTYP get & decode type byte
 lda DEFINT get definition
 beq PRUN10 bra if undefined
 cmpa #S.PROC procedure?
 beq PRUN20 ..Yes
 cmpa #S.VAR variable?
 bcs PRUNER ..No
 lda SHAPE simple?
 bne PRUNER ..No
 lda TYPE get type
 cmpa #S.STR string?
 beq PRUN20 ..Yes
PRUNER lda #M$MDV Err: multiply defined variable
 lbsr ERROR
 bra PRUN20
PRUN10 lda #S.PROC get type
 sta 0,X Define entry
 ldd NEXRUN get next procedure link addr
 std 1,X put in symbol tbl
 addd #2 get next procedure link
 std NEXRUN
PRUN20 leay 3,Y Skip reference
PRPRAM ldb ,Y+ get next token
 cmpb #T.LPAR are there parameters?
 bne PRUN40 ..No
PRUN30 lbsr PASGVR Process assignment/expression
 lbsr POPOP Keep opstack clean
 ldb ,Y+ get next token
 cmpb #T.COMA Another parameter?
 beq PRUN30 ..Yes
 leay 1,Y Skip stmt terminator
PRUN40 rts

***************
* Subroutine PINPUT
*   Process INPUT stmt

* Input: (Y)=I-Code ptr
* Output: (Y)=I-Code ptr (Destroyed)
* Destroys: X,D,CC
* Global:

PREAD equ *
PINPUT equ *
 bsr PCHLNM Process optional path number
 leay -1,Y Backup to exprsn
 cmpb #T.SLIT prompt string?
 bne PINPU1 No; go do variable reference
 lbsr PSEXPR Process it
 leay 1,Y Skip comma
PINPU1 lbsr PASGVR get variable reference
 lbsr POPOP get result type
 cmpa #S.RCRD a nasty TYPE?
 bcs PINPU2 No; good
 lda #M$IIV Err - illegal input variable
 lbsr ERROR
PINPU2 lda ,Y+ get next token
 cmpa #T.COMA a comma?
 beq PINPU1 Yes; get next variable
 rts

***************
* Subroutine PPRINT
* Process PRINT stmt

* Same as PINPUT

PPRINT bsr PCHLNM Process optional channel number
 cmpb #T.USNG USING?
 bne PPRIN2 No; go look for expression
 bsr PSEXPR get format expression
PPRIN1 ldb ,Y+ get next token
PPRIN2 cmpb #T.COMA coma?
 beq PPRIN1 ..Yes
 cmpb #T.SCOL semi-colon?
 beq PPRIN1 ..Yes
 lbsr EOLTST End of line?
 beq PCHLXX ..Yes
 leay -1,Y Back up to expression
 lbsr PEXPRN get expression
 lbsr POPOP get result type
 cmpa #S.RCRD is result nasty type?
 bcs PPRIN1 ..No
 lda #M$IET Err: illegal print expression
 lbsr ERROR
 bra PPRIN1

***************
* Subroutine PCHLNM
*   Process path Number

* Same as PINPUT

PCHLNM ldb ,Y+ get next token
 cmpb #T.CNUM is there channel number?
 bne PCHLXX No; done
 lbsr PIEXPR Check for integer expression
PCHL10 ldb ,Y+ get next token
 cmpb #T.COMA comma?
 beq PCHL10 ..Yes
 cmpb #T.SCOL semi-colon?
 beq PCHL10 ..No
PCHLXX rts

***************
* Subroutine POPEN
*   OPEN File

* Same as PINPUT

PCREAT equ *
POPEN equ *
 leay 1,Y Skip '#'
 lbsr PASGVR Process destination variable
 lbsr POPOP get type
 cmpa #S.INT integer?
 beq POPE10
 lbsr ERIET Err - illegal expression type
POPE10 leay 1,Y Skip comma
 bsr PSEXPR Process name expression
POPE20 lda ,Y+ is mode given?
 cmpa #T.MODE is there a mode specified?
 bne POPE30 ..No
 leay 2,Y Skip mode
POPE30 rts

***************
* Subroutine PSEEK
*   SEEK To Position

* Same as PINPUT

PSEEK bsr PIOBGN Process path number
 bsr PEXPRN
 lbsr POPOP
 cmpa #T.REAL
 bls LBREOL
 lbra ERIET Err - illegal expression type

PGET equ *
PPUT equ *
 bsr PIOBGN
SKPASG lbsr PASGVR Process variable/expression
 lbsr POPOP Keep opstack clean
 bra LBREOL Skip end of statment

***************
* Subroutine PCLOSE
*   CLOSE File

* Same as PINPUT

PCLOSE bsr PIOBGN Process path number
 cmpb #T.COMA Another path?
 beq PCLOSE ..Yes
 bra LBREOL

PIOBGN leay 1,Y Skip token & '#'
 lbra PPOK20

***************
* Subroutine PDELET
*   DELETE File

* Same as PINPUT

PGLOBL equ *
PCHD equ *
PCHX equ *
PKILL equ *
PDELET equ *
PCHAIN equ *
PSYS equ *
 bsr PSEXPR Process string expression
 bra LBREOL

***************
* Subroutine PSEXPR
*   Process String Expression

PSEXPR bsr PEXPRN Process expression
 lbsr POPOP get result type
 cmpa #S.STR string?
 beq PSEXXX
 lbsr ERIET Err: illegal expression type
PSEXXX rts

***************
* Subroutine PREST
*   RESTORE stmt

PREST ldb ,Y+ get next token
 cmpb #T.LREF line reference?
 lbeq PGOTO
* bra LBREOL fall thru

***************
* Subroutine Pnulls

* Process null stmts, those stmts that perform a
*  function when interpreted but require no binding

* Input: (Y)=I-Code ptr
* Output: (Y)=updated I-Code ptr
* Destroys: none
* Global: none

PBYE equ *
PTRON equ *
PTROFF equ *
PDEG equ *
PRAD equ *
PRETN equ *
PBASE0 equ *
PBASE1 equ *

LBREOL lbra PEOL

 ttl Pass Two expression routines
 pag
***************
* Subroutine PEXPRN
*   Process Expression

* Evaluates an Expression; Leaving The Result on The Top
*    of The Operand Stack

* Input: (Y)=I-Code ptr
* Output: (Y)=updated I-Code ptr
* Destroys: X,D,CC
* Global: I.OPSP

* Note - Entry at Bottom
PEXP10 cmpb #OPLAST special?
 bcc PEXP20 ..No
 lbsr PEXSUB Call specials processor
 bra PEXPRN
PEXP20 cmpb #T.AREF out of range?
 lbcc COMERR ..Yes
 subb #OPLAST Change value range
 leax EXPOPR,PCR get expression tbl
 leax B,X get entry ptr
 ldb 0,X get code byte
 lbeq COMERR bra if bad token
 andb #$1F get argument processor code
 beq PEXP30 bra if no arguments/operands
 leau <EXPBRA,PCR get branch tbl addr
 aslb shift For two-byte entries
 jsr B,U Process arguments/operands
PEXP30 ldb 0,X get code byte
 andb #$E0 get result type
 beq PEXP40 Use argument/operand TYPE
 clra clear Result type
 rolb shift High-order B to low-order A
 rola
 rolb
 rola
 rolb
 rola
 cmpa #OUTTOK Should token be deleted?
 bne PEXP40 ..No
 lbsr DELTOK Delete token
 bra PEXPRN
PEXP40 lbsr PUSHOP Push result
 leay 1,Y Move I-Code ptr
PEXPRN ldb 0,Y get next token
 bmi PEXP10
 rts

***************
* Subroutine P2INT
*   Process Two Integer Arguments/Operands

P2INT bsr P1INT Process one integer
 incb ADJUST Conversion token
 bra PINT Process another integer

***************
* Subroutine P1INT
*   Process One Integer

P1INT ldb #T.FIX1 get conversion token
* bra PINT fall thru

***************
* Subroutine PINT
*   Process Integer Argument/Operand

PINT lbsr POPOP get argument/operand TYPE
 cmpa #S.REAL numeric?
 bcs PINTXX bra if integer
 beq PINT10 bra if real
 bsr ERRIAR Report error
 bra PINT20
PINT10 tfr B,A copy conversion token
 lbsr INSTOK Stick it in
PINT20 lda #S.INT Return type
PINTXX rts

***************
* Subroutine P2REAL
*   Process Two Real Arguments/Operands

P2REAL bsr P1REAL
 incb
 bra PREAL

***************
* Subroutine P1REAL
*   Process One Real

P1REAL ldb #T.FLT1 get conversion token
* bra PREAL fall thru

***************
* Subroutine PREAL
*   Process Real Argument/Operand

PREAL lbsr POPOP get argument/operand TYPE
 cmpa #S.REAL
 beq PREAXX
 bcs PREA10
 bsr ERRIAR Report error
 bra PREA20

PREA10 tfr B,A copy conversion token
 lbsr INSTOK Stick it in
PREA20 lda #S.REAL
PREAXX rts

EXPBRA bra LBRCOM
 bra P1INT One integer argument/operand
 bra P2INT Two integer
 bra P1REAL One real
 bra P2REAL
 bra P1NUM
 bra P2NUM
 bra P1STR
 bra P2STR
 bra P1S1I
 bra P1S2I One string, two integer
 bra P1BOOL One boolean
 bra P2BOOL Two boolean
 bra P2SN Two string-numeric
 bra P2BSN Two boolean-string-numeric
LBRCOM lbra COMERR

ERRIAR lda #M$IARG Err: illegal argument
 lbra ERROR

***************
* Subroutine P2NUM
*   Process Two Numeric Arguments/Operands

P2NUM bsr PNUM Process first argument/operand
 pshs A save type
 bsr PNUM Process second
 cmpa ,S+ Compare results
 beq P1NU10 bra if equal
 lda #T.FLT1 get conversion token
 bcc P2NU10
 inca ADJUST token
P2NU10 lbsr INSTOK Stick it in
 lda #S.REAL Return type
 bra P1NU20

***************
* Subroutine P1NUM
*   Process One Numeric

P1NUM bsr PNUM Process numeric argument/operand
P1NU10 cmpa #S.REAL is result real
 bne P1NUXX ..No
P1NU20 inc 0,Y Adjust token
P1NUXX rts

***************
* Subroutine PNUM
*   Process Numeric Argument/Operand

PNUM bsr POPOP get argument/operand TYPE
 cmpa #S.REAL numeric?
 bls PNUMXX ..Yes
 bsr ERRIAR Report error
 lda #S.REAL Return real
PNUMXX rts

***************
* Subroutine P2STR
*   Process Two String Arguments/Operands

P2STR bsr P1STR Process first argument
* bra P1STR fall thru

***************
* Subroutine P1STR
*   Process One String Argument/Operand

P1STR bsr POPOP Pop argument/operand
 cmpa #S.STR string type?
 beq P1STXX ..Yes
 bsr ERRIAR Report error
 lda #S.STR
P1STXX rts


***************
* Subroutine P1S1I
*   Process One String & One Integer Argument/Operand

P1S1I lbsr P1INT Process integer
 bra P1STR Process string

***************
* Subroutine P1S2I
*   Process One String & Two Integer Arguments/Operands

P1S2I lbsr P2INT Process two integers
 bra P1STR Process string

***************
* Subroutine P2BSN
*   Process Two Boolean-String-Numeric Arguments/Operands

P2BSN lda #S.BOOL set type
 bsr P2ARG Process for boolean
 bne P2SN bra if not successful
 ldb #3 set increment
 bra P2SN10

***************
* Subroutine P2SN
*   Process Two String-Numeric Arguments/Operands

P2SN lda #S.STR set type
 bsr P2ARG Process for string
 bne P2NUM bra if not successful
 ldb #2 set increment
P2SN10 addb 0,Y Adjust token
 stb 0,Y
 rts

***************
* Subroutine P2ARG
*   Process Two Arguments/Operands

P2ARG ldu I.OPSP get opstack ptr
 cmpa ,U+ is first correct type?
 bne P2ARXX ..No
 cmpa ,U+ is second correct?
 bne P2ARXX ..No
 stu I.OPSP Pop arguments/operands
 clrb set Z bit
P2ARXX rts

***************
* Subroutine P2BOOL
*   Process Two Boolean Argument/Operands

P2BOOL bsr P1BOOL Process first
* bra P1BOOL fall thru

***************
* Subroutine P1BOOL
*   Process One Boolean Argument/Operand

P1BOOL bsr POPOP Pop argument/operand
 cmpa #S.BOOL boolean?
 beq P1BOXX ..Yes
 bsr ERRIAR Report error
 lda #S.BOOL
P1BOXX rts

***************
* Subroutine PUSHOP
*   Push operand type and descr ptr on Operand stack

* Input: (A)=type
* Output: (X)=Operand Stack ptr
* Destroys: CC
* Global: I.OPSP Updated

PUSHOP cmpa #S.BYTE byte type?
 bne PUSHO1 No; leave as is
 lda #S.INT Use integer for byte
PUSHO1 ldu I.OPSP get operand stack ptr
 cmpa #S.RCRD rcd type?
 bne PUSHO2 No; do simple
 ldd DSCPTR get descr ptr
 std ,--U Push it
 lda #S.RCRD
PUSHO2 sta ,-U Push type
 stu I.OPSP save stack ptr
 rts

***************
* Subroutine POPOP
*   Pop type and descr ptr off Operand stack

* Input: none
* Output: (A)=type
* Destroys: CC
* Global: I.OPSP Updated

POPOP ldu I.OPSP get operand stack ptr
 lda ,U+ get type
 cmpa #S.RCRD record?
 bne POPOP1 ..No
 leau 2,U Return descr space
POPOP1 stu I.OPSP save stack ptr
 rts

***************
* Subroutine PEXSUB
*   Process Special Expression Components
* Includes Variables, Literals, and Special Functions

PEXSUB cmpb #T.VREF legal?
 lbcs COMERR ..No
 cmpb #T.PERD variable?
 bcs PVREF ..Yes
 subb #T.BLIT field reference?
 lbcs PFREF ..Yes
 leau <EXPSPC,PCR
 aslb shift For two byte entries
 jmp B,U

EXPSPC bra PBLIT T.BLIT
 bra PILIT T.ILIT
 bra PRLIT T.RLIT
 bra PSLIT T.SLIT
 bra PILIT T.HLIT
 bra PADDR1 T.ADDR
 bra PADDR2 T.ADDR
 bra PADDR1 T.LENG
 bra PADDR2 T.LENG

***************
* Subroutine PBLIT
*   Process Byte Literal

* Input: (Y)=I-Code ptr
* Output: (Y)=updated I-Code ptr
* Destroys: X,D,CC
* Global: I.OPSP

PBLIT leay -1,Y Move I-Code ptr
* bra PILIT fall thru

***************
* Subroutine PILIT
*   Process Integer Literal

* Same as PBLIT

PILIT leay 3,Y Move I-Code ptr
 lda #S.INT set type
 bra PUSHOP Push on operand stack

***************
* Subroutine PRLIT
*   Process Real Literal

* Same as PBLIT

PRLIT leay 6,Y Move I-Code ptr
 lda #S.REAL set type
 bra PUSHOP Push it on operand stack

***************
* Subroutine PSLIT
*   Process String Literal

* Same as PBLIT

PSLIT ldb ,Y+ get next byte of string
 cmpb #V$ESTR end?
 bne PSLIT No; do more
 lda #S.STR
 bra PUSHOP

***************
* Subroutine PADDR
*   Process ADDR Function

* Same as Pndyad

PADDR1 lbsr PASG00 Do final token processing
 bsr POPOP Throw away variable type
 lda #S.INT Addr gives integer result
 bsr PUSHOP
PADDR2 leay 1,Y
 rts

***************
* Subroutine PVREF
*   Process Variable Reference

* Evaluates a variable reference and pushes its type
*    and descr ptr on the Operand stack

* Input: (Y)=I-Code ptr
* Output: (Y)=updated I-Code ptr
* Destroys: X,D,CC
* Global: I.OPSP

PVREF lbsr GETTYP get type byte and decode
 bsr CHKDEF Check variable definition
 cmpa #S.VAR variable?
 beq PVR10 Yes; check its subscripts
 cmpa #S.PARM parameter?
 beq PVR10 Yes; keep going
 lda #M$IOPD Err: illegal operand
 lbsr ERROR
 bra PVR20
PVR10 ldb #T.VREF get base token
 lbsr CHKVAR Check variable type & subscripts
 ldb 0,Y get token
 cmpb #T.VREF subscripted?
 bne PVR20 Yes; leave as is
 ldb DEFINT get definition
 cmpb #S.VAR variable?
 bne PVR20 No; leave as is
 cmpa #S.RCRD rcd type?
 bcc PVR20 ..Yes
 adda #T.SBYT Convert type to token
 sta 0,Y put in I-Code
 ldd 1,X get storage offset
 std 1,Y put in I-Code
PVR20 lda TYPE get type
 leay 3,Y Move I-Code ptr
 lbra PUSHOP Push on operand stack

***************
* Subroutine CHKDEF
*   Check Variable definition & define as simple
*    variable if undefined

* Input: (X)=Symbol ptr
* Output: (A)=Variable Definition
* Destroys: B,CC
* Global: DEFINT,SHAPE,TYPE

CHKDEF lda DEFINT get definition
 cmpa #S.UNDF undefined name?
 bne CHKD20 No; skip defining
 ldd #S.SIMP*256+S.VAR set shape=simple, def=variable
 sta SHAPE
 stb DEFINT
 lda #S.VAR+S.SIMP set type byte
 ora TYPE
 sta 0,X
 anda #S.TYPM get type
 cmpa #S.STR string?
 bne CHKD10 No; go allocate storage
 ldd #32 set default size
 std 1,X
CHKD10 lbsr ALCSTO Allocate storage
 lda DEFINT get definition
CHKD20 rts

***************
* Subroutine PFREF
*   Process Field Reference

* Evaluates a field reference, insures its a rcd member,
* and pushes its type and descr ptr on the operand stack

* Input: (Y)=I-Code ptr
* Output: (Y)=updated I-Code ptr
* Destroys: X,D,CC
* Global: I.OPSP

PFREF bsr GETTYP get type byte and decode it
 ldb #T.PERD get base token
 bsr CHKVAR Check definition & subscripts
 lbsr POPOP get preceding reference
 cmpa #S.RCRD record?
 beq PFREF1 Yes; good
 ldu #$FFFF set containing record's descr ptr to nil
 bra PFREF2
PFREF1 ldu -2,U get rcd descr ptr
PFREF2 pshs U save containing record's descr ptr
 bsr PVR20 Push element on operand stack
 puls U get containing record's descr ptr
 cmpu #$FFFF nil?
 beq PFREF5 Yes; error
 ldb 2,U get element count
 stb ELMSIZ save it
 ldd SYMPTR get symbol ptr
 subd I.SYMT Make ptr into offset
 leau 3,U Move ptr to next element
PFREF3 cmpd ,U++ this element?
 beq GETTY9 Yes; done (rts)
 dec ELMSIZ are there more?
 bne PFREF3 Yes; try next
 lda #M$IRFN Err - illegal rcd field name
 bra PFREF9
PFREF5 lda #M$NRTO Err - non rcd type operand
PFREF9 lbra ERROR

***************
* Subroutine GETTYP
*   get type byte and decode it

* Input: (Y)=I-Code ptr
*            Assumes I-Code ptr is Pointing at token Preceding
*               Variable's Symbol Table offset
* Output: (A)=type
*         (X)=Symbol Table ptr
* Destroys: B,CC
* Global: I.SYMT,SYMPTR,DEFINT,SHAPE,TYPE

GETTYP ldd 1,Y get symbol tbl offset
 addd I.SYMT get symbol tbl base
 std SYMPTR save symbol ptr
 ldx SYMPTR
GETTY1 lda 0,X get type byte
 anda #S.DEFM get definition
 sta DEFINT
 lda 0,X get type byte
 anda #S.SHPM get shape
 sta SHAPE
 lda 0,X get type byte
 anda #S.TYPM get type
 sta TYPE
GETTY9 rts

***************
* Subroutine CHKVAR
*   Checks that Subscripts are Numeric
* and gets rcd description area offset

* Same as PVREF

CHKVAR pshs B save base token
 ldb 0,Y get token
 subb ,S+ Convert token to shape
 bne CHKV10 bra if subscripted
 tst SHAPE array?
 beq CHKV60 No; do simple
 lda #S.RCRD Change unsubscripted array to record
 sta TYPE
 ldd #$FFFF But with no rcd description
 bra CHKV90
CHKV10 aslb
 aslb
 aslb
 cmpb SHAPE Shapes agree?
 beq CHKV20 Yes; good
 lda #M$IES Err - insufficient or excessive subscripts
 lbsr ERROR
CHKV20 lda #T.FIX1 get conversion token
 sta CNVTOK save it
CHKV30 lbsr POPOP Pop operand stack
 cmpa #S.REAL is subscript numeric?
 blo CHKV50 Yes; good
 beq CHKV40 is real; fix it
 lda #M$IET Err: non-numeric subscript
 lbsr ERROR
 bra CHKV50
CHKV40 lda CNVTOK get conversion token
 bsr INSTOK
CHKV50 inc CNVTOK Bump token
 subb #S.SHP1 Count subscripts
 bne CHKV30 Go do more
CHKV60 lda TYPE get type
 cmpa #S.RCRD is rcd type?
 bne CHKV99 No; return
 ldd 1,X get descr offset
 addd I.DSCR Make offset into ptr
 tfr D,U
 ldb SHAPE array?
 beq CHKV70 No; get ptr to rcd descr
 lsrb shift For two byte entries
 lsrb
 addb #4 add for offset & total size
 ldd B,U get descr offset
 bra CHKV80
CHKV70 ldd 2,U get descr offset
CHKV80 addd I.DSCR Make offset into ptr
CHKV90 std DSCPTR save description area ptr
 lda TYPE Return type
CHKV99 rts

***************
* Subroutine INSTOK
*   Insert token Into I-Code

* Input: (Y)=I-Code ptr
* Output: (Y)=updated I-Code ptr
* Destroys: none
* Global: I.ICLM, ICDPTR

INSTOK pshs B,X save registers
 ldx G.VARS
 cmpx #16 is there reasonable memory?
 lbls QuitBind ..No; abort
 ldx I.ICLM get I-Code limit
 sta ,X+ Store token
 stx ICDPTR set parameter
 clrb
 bsr DELT10 Call I-Code replacer
 puls B,X,PC

***************
* Subroutine DELTOK
*   Delete token

* Input: (Y)=I-Code ptr (at token To Delete)
* Output: none
* Destroys: A,CC
* Global: none

DELTOK ldd I.ICLM get end of I-Code
 std ICDPTR set parameter
 ldb #1 set delete count
DELT10 clra
 lbra J$RPLC

 pag
***************
* Subroutine ALCSTO
*   Allocate Storage

* Input: (X)=Symbol Table ptr of Variable To Allocate
* Output: none
* Destroys: D,CC
* Global: I.APRC,P.VARC

ALCVAR fdb ALCSMV-ALCVAR,ALCSTV-ALCVAR,ALCCXV-ALCVAR,ALCARV-ALCVAR
ALCPAR fdb ALCSMP-ALCPAR,ALCSTP-ALCPAR,ALCCXP-ALCPAR,ALCARP-ALCPAR

ALCSTO pshs X,Y,U save registers
 leay <ALCVAR,PCR get type size tbl
 ldb 0,X get type byte
 andb #S.DEFM get definition
 cmpb #S.VAR variable?
 beq ALCST1 Yes; set for it
 cmpb #S.FLDD rcd field?
 beq ALCST1 Yes; do as variable
 cmpb #S.PARM parameter?
 bne ALCST6 No; do nothing
 leay ALCPAR-ALCVAR,Y get parameter routine tbl
ALCST1 ldb 0,X get type byte
 andb #S.SHPM get shape
 beq ALCST2 bra if simple
 ldd 6,Y get array routine offset
 bra ALCST5
ALCST2 ldb 0,X get type byte
 andb #S.TYPM get type
 cmpb #S.STR What type?
 bcs ALCST4 is simple; go do it
 bhi ALCST3 is complex; go do it
 ldd 2,Y get string routine
 bra ALCST5
ALCST3 ldd 4,Y get complex routine
 bra ALCST5
ALCST4 ldd 0,Y get simple routine
ALCST5 jsr D,Y Go to routine
ALCST6 puls X,Y,U,PC

ALCSMV lda 0,X get type byte
 anda #S.TYPM get type
 leay 1,X set ptr to storage offset
 bsr GETVSZ get variable size
ALCSV1 pshs D save size
 ldd NEXALC get current allocation
 std 0,Y Use as run time offset
 addd ,S++ add size
 std NEXALC Update allocation
 rts

ALCSTV bsr ALCCMX get description area for string
 bra ALCSV1 Finish variable allocation

ALCCXV bsr ALCCMX get description area for structure
 addd I.DSCR get description area base
 tfr D,X get structure total size
 ldd 0,X
 bra ALCSV1 Finish variable allocation

ALCARV bsr ALCARR Do array prep
 bra ALCSV1 Finish

ALCSMP leay 1,X get ptr storage offset
ALCSP1 ldd NEXPRM get current parameter count
 std 0,Y Use as runtime parameter offset
 addd #4
 std NEXPRM
 rts

ALCSTP equ *
ALCCXP bsr ALCCMX get description area for structure
 bra ALCSP1 Finish parameter allocation

ALCARP bsr ALCARR
 bra ALCSP1

ALCARR ldd 1,X get descr offset
 addd I.DSCR Make offset into ptr
 tfr D,Y
 ldd 2,Y get array total size
 rts

ALCCMX ldd #4 set size needed
 lbsr J$EXDS get description area
 ldx 4,S get symbol tbl ptr
 ldd 1,X get offset to type description
 std 2,Y put in descr area
 tfr Y,D copy new descr area ptr
 subd I.DSCR Make ptr an offset
 std 1,X put in symbol tbl
 ldd 2,Y get descr offset
 rts

ALCSZT fcb 1,2,5,1,32 Simple variable sizes

GETVSZ pshs X save x
 leax <ALCSZT,PCR get size tbl addr
 ldb A,X get size
 clra clear Msb
 puls X,PC

PDEXC equ *
PBFN1C equ *
COMERR equ *
 ldy I.ICLM Skip to procedure end
 lda #M$UNIM Err: unimplemented routine
 lbra ERROR Record error & return

 ttl Initializer / main routine
 pag
***************
* Startup, Main Loop, and Cleanup

DELTKS fcb T.PRAM,T.TYPE,T.DIM,T.TRON,T.TROF
 fcb T.PAUS,T.REM1,T.REM2,T.BKSL,T.EOL
 fcb $FF

BIND ldd #U.SIZE Init variable storage size
 std NEXALC
 clrb
 std NEXPRM Clear next parameter offset
 std NEXRUN Clear next procedure offset
 sta PEXECU Clear processing executable flag
 std DAT1ST Clear first data stmt ptr
 std DATPTR Clear data stmt ptr
 ldx I.APRC get procedure addr
 sta P.STAT,X Clear errs in binding flag
 std P.EXEC,X Clear first executable offset
 ldy I.ICBG get I-Code beginning
 bra STAR20
START pshs Y save stmt beginning ptr
 lbsr PSTMT Process stmt
 puls X Retrieve stmt beginning ptr
 ldb <SMASH Compile mode?
 bne STAR20 ..No
 lda 0,X get first token of stmt
 leau <DELTKS,PCR get list of delete-line tokens
STAR10 cmpa ,U+ is this one?
 blo STAR20 ..no; don't delete it
 bne STAR10 ..maybe; keep looking
 pshs X
 tfr Y,D End of I-Code line (+1)
 subd ,S++ Minus start of I-Code line
 leay 0,X Delete from start of line
 ldu I.STBG
 stu ICDPTR Insert nothing
 lbsr J$RPLC Call replace I-Code routine
STAR20 ldx I.ICLM
 clr 0,X wipe out byte following procedure stmts
 cmpy I.ICLM End of I-Code?
 bcs START ..No
DONE ldx I.DSCR get line number tbl top
 bra DONE07
DONE05 lda 0,X get line number
 bpl DONE07 bra if defined
 anda #$7F Clear undefined flag
 sta 0,X Update tbl
 ldy 2,X get first link
DONE03 ldu 0,Y get next link
 ldd 0,X get line number
 std 0,Y Restore line number
 dec -1,Y Unbind token
 lda #M$ULN Err: undefined line number
 lbsr ERROR
 leay 0,U is there another reference?
 bne DONE03 ..Yes
DONE07 leax -4,X Move to next entry
 cmpx LNMTBL Out of tbl?
 bcc DONE05 ..No
 ldd I.DSCR Return line number tbl area
 subd LNMTBL get line number tbl size
 addd G.VARS Return to free memory
 std G.VARS
 ldx I.OPSP get control stack ptr
 bra DONE20
DONE10 ldy 1,X get error addr
 lda #M$UCS Err: unmatched control structure
 lbsr ERROR
 lda 0,X get structure token
 cmpa #T.FOR FOR?
 bne DONE15 No; do normal
 leax 7,X Pop extra FOR bytes
DONE15 leax 3,X Pop control structure
 stx I.OPSP Update stack ptr
DONE20 cmpx I.OPBG is stack empty?
 blo DONE10 No; go print error
 ldu I.DSCR get FROM ptr
 ldy I.ICLM get TO ptr
 ldd I.SYMS get symbol tbl size
 addd I.DSCS add description area size
 lbsr J$MVDN Call move down
 ldx I.APRC get procedure ptr
 ldd DAT1ST get first data ptr
 std P.DATA,X
 ldd NEXALC get variable allocation
 std P.PRCS,X set beginning procedure link
 addd NEXRUN add link size
 std NEXRUN save total size
 std P.VARC,X
 ldb P.NAMS,X get name size
 clra Clear Msb
 addd #P.NAME add p.e.t. size
 std P.PGMB,X set I-Code area offset
 addd I.ICLM add ptr to end of I-Code area
 subd I.ICBG Subtract ptr to I-Code beginning
 std P.DSCB,X set descr area offset
 addd I.DSCS add descr area size
 addd #3 Adjust for entry & skip counts
 std P.SYMB,X set symbol tbl offset
 subd #3 Re-adjust
 addd I.SYMS add symbol tbl size
 std P.SIZE,X set procedure total size
 addd I.APRC get ptr to procedure end
 std I.STBG set new string stack beginning
 subd G.PRCA Subtract procedure area beginning
 std G.PRCS set procedure area total size
 ldd I.APRC get procedure ptr
 addd P.SYMB,X add symbol tbl offset
 std I.SYMT Adjust symbol tbl ptr
 ldd I.APRC get procedure ptr
 addd P.DSCB,X add description offset
 std I.DSCR Adjust description ptr
 ldu I.SYMT get symbol tbl ptr
 bra DONE80
DONE25 leax 0,U copy symbol tbl ptr
 lbsr GETTY1 Decode type byte
 lda DEFINT get definition
 cmpa #S.VAR variable w/storage?
 bcs DONE55 ..No
 cmpa #S.PROC procedure definition?
 bne DONE30 ..No
 ldd 1,X get storage offset
 addd NEXALC Adjust for variable allocation
 std 1,X Update offset
 bra DONE70
DONE30 cmpa #S.PARM parameter?
 bne DONE55 ..No
 ldb SHAPE array parameter?
 bne DONE45 ..Yes
 lda TYPE get type
 cmpa #S.STR string?
 bcc DONE45 ..Yes
 leax 1,U get ptr to offset
 bra DONE50
DONE45 ldd 1,U get description offset
 addd I.DSCR Make offset into ptr
 tfr D,X
DONE50 ldd 0,X get storage offset
 addd NEXRUN Adjust for variable allocation
 std 0,X
DONE55 lda TYPE get type
 cmpa #S.RCRD record?
 bne DONE70 ..No
 ldb SHAPE array?
 beq DONE60 ..No
 lsrb Shift shape for two byte entries
 lsrb
 addb #4 add for offset & total size
 bra DONE65
DONE60 ldb #2 get simple rcd descr offset
DONE65 clra Clear Msb
 addd 1,U add array descr offset
 ldx I.DSCR get description area ptr
 leay D,X get ptr/size ptr
 ldd 0,Y get rcd descr offset
 ldd D,X get rcd size
 std 0,Y Put in array description
DONE70 leau 3,U Skip three byte header
DONE75 lda ,U+ get next byte of name
 bpl DONE75 bra if not end of name
DONE80 cmpu I.STBG end of symbol tbl?
 bcs DONE25 ..No
 rts

 endc
* End of Binder

