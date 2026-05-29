
 nam Statement Interpreter
 use DEFS

 ttl External Linkage Section
 pag
 use LINKAGE

***************
* Global Entry Points

STMTENT equ *
 fdb INIT-STMTENT Initialization entry
 fdb EXECUT-STMTENT Execution entry
 fdb RPARAM-STMTENT Process parameters
 fdb EXCERR-STMTENT Statement error exit
 fdb LETSTM-STMTENT Single statement execution
 fdb TONSTM-STMTENT Trace on statement
 fdb TOFSTM-STMTENT Trace off statement

***************
* External Subroutine References

J$EXIT jsr M.COMAND
 fcb X$EXIT Exit via (error) exit address
J$BYE jsr M.COMAND
 fcb X$BYE  exit basic09
J$KALL jsr M.COMAND
 fcb X$KALL kill all external procs
J$EREX jsr M.COMAND
 fcb X$EREX Print error messsage and return
J$SPRC jsr M.COMAND
 fcb X$SPRC Search directory for procedure
J$KILL jsr M.COMAND
 fcb X$KILL Kill external procedure
J$SKST jsr M.COMAND
 fcb X$SKST Skip one logical stmt

J$MVDN jsr M.COMPIL
 fcb X$MVDN block move down

J$FADD jsr M.EXPRSN
 fcb X$FADD Real add
J$FCMP jsr M.EXPRSN
 fcb X$FCMP Real compare
J$VREF jsr M.EXPRSN
 fcb X$VREF Evaluate variable reference
J$FIX jsr M.EXPRSN
 fcb X$FIX  Fix real
J$FLOT jsr M.EXPRSN
 fcb X$FLOT Float integer
J$EXPI jsr M.EXPRSN
 fcb X$EXPI Initialize expression

J$CVIO jsr M.CNVIO
 fcb X$CVIO  Call cnvio

 ifne INCLUDED&EDITOR
J$DBUG jsr M.COMAND
 fcb X$DBUG Enter DEBUG state
J$PBLN jsr M.COMAND
 fcb X$PBLN Print a bound line
J$TEXP jsr M.COMAND
 fcb X$TEXP Trace expression address
J$TEXR jsr M.COMAND
 fcb X$TEXR Trace result
 endc

 ttl Dispatch Tables
 pag
***************
* Statement Verb Dispatch Table

STMTDT fdb SKPSTM-STMTDT T.GLOB
 fdb SKPSTM-STMTDT T.PRAM
 fdb SKPSTM-STMTDT T.TYPE
 fdb SKPSTM-STMTDT T.DIM
 fdb SKPSTM-STMTDT T.DATA
 fdb STPSTM-STMTDT T.STOP
 fdb BYESTM-STMTDT T.BYE
 fdb TONSTM-STMTDT
 fdb TOFSTM-STMTDT
 fdb PASSTM-STMTDT
 fdb DEGSTM-STMTDT
 fdb RADSTM-STMTDT
 fdb RETSTM-STMTDT
 fdb LETSTM-STMTDT
 fdb ASGSTM-STMTDT
 fdb POKSTM-STMTDT
 fdb IFSTM-STMTDT
 fdb ELSSTM-STMTDT
 fdb EIFSTM-STMTDT
 fdb FORSTM-STMTDT
 fdb NXTSTM-STMTDT
 fdb WHLSTM-STMTDT
 fdb EWHSTM-STMTDT
 fdb RPTSTM-STMTDT
 fdb UNTSTM-STMTDT
 fdb LOPSTM-STMTDT
 fdb ELPSTM-STMTDT
 fdb EXTSTM-STMTDT
 fdb EEXSTM-STMTDT
 fdb ONSTM-STMTDT
 fdb ERRSTM-STMTDT
 fdb ELNSTM-STMTDT
 fdb GTOSTM-STMTDT
 fdb ELNSTM-STMTDT
 fdb GSBSTM-STMTDT
 fdb RUNSTM-STMTDT
 fdb KILSTM-STMTDT T.KILL
 fdb INPSTM-STMTDT
 fdb PRTSTM-STMTDT
 fdb CHDSTM-STMTDT
 fdb CHXSTM-STMTDT
 fdb CRTSTM-STMTDT
 fdb OPNSTM-STMTDT
 fdb SEKSTM-STMTDT
 fdb RDSTM-STMTDT
 fdb WRTSTM-STMTDT
 fdb GETSTM-STMTDT
 fdb PUTSTM-STMTDT
 fdb CLSSTM-STMTDT
 fdb RSTSTM-STMTDT
 fdb DLTSTM-STMTDT
 fdb CHNSTM-STMTDT
 fdb SYSSTM-STMTDT
 fdb B0STM-STMTDT
 fdb B1STM-STMTDT
 fdb REMSTM-STMTDT
 fdb REMSTM-STMTDT
 fdb ENDSTM-STMTDT
 fdb LINREF-STMTDT
 fdb LINREF-STMTDT
 fdb DIREXC-STMTDT
 fdb ELNSTM-STMTDT
 fdb NULSTM-STMTDT
 fdb NULSTM-STMTDT
 fdb SBYTAS-STMTDT
 fdb SINTAS-STMTDT
 fdb SRLAS-STMTDT
 fdb SBLAS-STMTDT
 fdb SSTRAS-STMTDT
 fdb SVARAS-STMTDT

* Stop Message String
STPMSG fcc "STOP Encountered"
 fcb V$LF,V$ESTR

 ttl STATEMENT Routines
 pag
***************
* Subroutine EXECUT
*   Execute I-Code

* Input:  X=Address of Procedure
*         Y=Top of Free Memory
* Output: None
* Local: X,Y,D,CC Destroyed

EXECUT lda P.STAT,X is procedure runable?
 bita #1 Are there errors?
 beq EXEC10 bra if not
 ldb #M$ERST Err: run aborted
 bra LBRERR

EXEC10 tfr S,D Check for stack overflow
 subd #256 Need at least 256 bytes
 cmpd I.IOBG is there that much?
 bcc EXEC15 bra if so
 ldb #M$SSOV Err: system stack overflow
 bra LBRERR
EXEC15 ldd G.VARS Get free space size
 subd P.VARC,X Remove needed variable storage
 bcs MEMFUL ..oops, not enough memory
 cmpd #256 minimum opstack?
 bcc EXEC20 bra if enough
MEMFUL ldb #M$MFUL Err: memory full
LBRERR lbra EXCERR
EXEC20 std G.VARS Update free space
 tfr Y,D
 subd P.VARC,X Make room for vars on u
 exg D,U
 sts U.S,U Save current stack
 std U.U,U Save caller's storage address
 stx U.PROC,U Set procedure address
 ldd #1
 std I.BASE Default array base to one
 sta U.DEG,U Default trig mode to radians
 sta U.ERRS,U Clear error flag
 stu U.SBSP,U Init subroutine stack
 bsr SETGLB Set I.xxxx globals
 ldd P.DATA,X Get offset of first data statement
 beq EXEC30 bra if none
 addd I.ICBG Add ptr to I-Code beginning
EXEC30 std I.DATA Save it
 ldd P.VARC,X Get variable storage size
 leay D,U Get ptr to storage end
 pshs Y Save it
 ldd P.PRCS,X Get beginning procedure link
 leay D,U Get ptr to it
 clra
 clrb
 bra EXEC45

EXEC40 std ,Y++ Clear link
EXEC45 cmpy 0,S More to clear?
 bcs EXEC40 bra if so
 leas 2,S Return scratch
 ldx I.APRC
 ldd I.ICBG Get ptr to I-Code beginning
 addd P.EXEC,X Add offset of first executable statement
 tfr D,X
 bra STML30 Jump into statment loop

***************
* Subroutine SETGLB
*   Set Procedure Global Variables

* Input: (X)=Procedure Address
* Output: None
* Local: D,CC Destroyed
* Global: I.APRC = X
*         I.ASTR = U
*         I.OPBG, I.OPSP = U.SBSP,U
*         I.SYMT = P.SYMB+I.APRC
*         I.DSCR = P.DSCB+I.APRC
*         I.ICBG = P.PGMB+I.APRC

SETGLB stx I.APRC Set active procedure address
 stu I.ASTR Set storage base address
 ldd P.SYMB,X Get symbol table offset
 addd I.APRC Make offset a ptr
 std I.SYMT
 ldd P.DSCB,X Get description area offset
 addd I.APRC Make offset a ptr
 std I.DSCR
 std I.ICLM Also end of I-Code
 ldd P.PGMB,X Get I-Code area offset
 addd I.APRC Make ptr
 std I.ICBG
 ldd U.SBSP,U Get end of subroutine stack
 std I.OPBG Use as beginning of opstack
 std I.OPSP Init opstack ptr
 rts

***************
* Subroutine STMLUP
*   Statement Execution Loop

* Checks Interrupt Flag and Calls DEBUG Mode or Aborts
*  Execution as Appropriate.  If Flag is Clear, Gets
*  Next TOKEN, Calls Statement Dispatcher, and Loops.

* Input: (X)=I-Code ptr
* Output: (X)=I-Code ptr (Updated)
* Local: U,Y,D,CC Destroyed

STMLUP stx I.ICPT Set I-Code ptr to current line
 lda I.RUNM Continuous execution?
 beq STML20 bra if so
 bpl STML10 bra if not DEBUG call
 anda #$7F Clear DEBUG bit
 sta I.RUNM

 ifne INCLUDED&EDITOR
 lbsr J$DBUG Call DEBUG
 lda I.RUNM
STML10 rora is Trace bit set?
 bcc STML20 bra if not
 leay 0,X Copy I-Code ptr
 lbsr J$SKST Move copy to next statement
 clr I.OCNT Clear pretty print count
 lbsr J$PBLN Print line
 else
 ldb G.SIGN Return Signal as error
 bra LBRERR Signal Execution error
STML10 equ *
 endc

STML20 bsr LETSTM Call dispatcher
STML30 cmpx I.ICLM At procedure end?
 bcs STMLUP bra if not
 bra ENDS10 ..exit

***************
* Subroutine ENDSTM
*   END Statement

* Returns Up One Procedure Level; Error Status Clear

* Input: None
* Output: (U)=value on Descent to Current Level
*         CC = Clear
* Local: D Destroyed
* Global: I.ASTR

ENDSTM ldb 0,X get next TOKEN
 lbsr EOLTST End of line?
 beq ENDS10 ..yes; don't print anything
 lbsr PRTSTM Print message if there is one
ENDS10 lbsr TOFSTM Turn off trace
 ldu I.ASTR Get storage base address
 lds U.S,U Reset stack
 ldu U.U,U Get caller's storage address
NULSTM rts Do-nothing Statements use this return

***************
* Subroutine LINREF
*   Skip Line Reference & Dispatch Off Following TOKEN

* Input: (X)=I-Code ptr
* Output: (X)=I-Code ptr (Updated)
* Local: U,B,CC Destroyed
* Global: D.STMT

LINREF leax 2,X Skip line ref
* bra LETSTM fall through

***************
* Subroutine LETSTM
*   LET Statement

* LET is Executional do nothing, Dispatch on Following TOKEN

LETSTM ldb ,X+ Get next TOKEN
* bra STMDIS fall through

***************
* Subroutine STMDIS
*   Statement Dispatcher

* Input: (X)=I-Code ptr
* Output: (X)=I-Code ptr (Updated)
* Local: Y,D,CC Destroyed
* Global: I.ICPT Destroyed

STMDIS bpl STMD10 bra if statement TOKEN
 addb #T.LSTM Adjust TOKEN for simple assignment
STMD10 aslb SHIFT for two byte entries
 clra clear Msb
 ldu D.STMT Get statement dispatch table address
 ldd D,U Get routine offset
 jmp D,U Call routine

***************
* Subroutine IFSTM
*   IF Statement

* Calls Boolean Expression Evaluator; If the Result
*    is False Then the Goto Following the Expression
*    is Executed, If the Result is True the Goto is
*    Skipped and the Conditional Statement(s) Are
*    Executed

* Input: (X)=I-Code ptr
* Output: (X)=I-Code ptr (Updated)
* Local: Y,D,CC Destroyed
* Global: I.ICBG

IFSTM jsr J$EVAL Evaluate expression
 tst 2,Y Test result
 beq GTOSTM bra if false
 leax 3,X Move I-Code ptr
 ldb 0,X Get TOKEN following
 cmpb #T.LRBD is it line ref?
 bne NULSTM Yes; do next statement
 leax 1,X Skip line refernce TOKEN
* bra GTOSTM fall through

***************
* Subroutine GTOSTM
*   GOTO Statement

* Cause I-Code ptr to Be Moved to Specified Location

* Input: (X)=I-Code ptr
* Output: (X)=I-Code ptr (Updated)
* Local: D,CC Destroyed
* Global: I.ICBG Used In I-Code ptr Calc.

GTOSTM ldd 0,X Get destination offset
GTOST1 addd I.ICBG Make offset a ptr
 tfr D,X Move to I-Code ptr
 rts

***************
* Subroutine ELSSTM
*   ELSE Statement

* The ELSE TOKEN Marks the End of Conditional
*    Statements And Executes a Goto Past The
*    Corresponding ENDIF

ELSSTM equ GTOSTM

***************
* Subroutine EIFSTM
*   ENDIF Statement

* ENDIF is An Executional do nothing

* Input: (X)=I-Code ptr
* Output: (X)=I-Code ptr (Updated)
* Local: None
* Global: None

EIFSTM leax 1,X Skip statement terminator
 rts

***************
* Subroutine WHLSTM
*   WHILE Statement

* Calls Boolean Expression Evaluator; If the Result is
*    False Then the Goto Following is Executed, If The
*    Result is True, the Goto is Skipped and the Following
*    Statements Executed

* Input: (X)=I-Code ptr
* Output: (X)=I-Code ptr (Updated)
* Local: Y,D,CC Destroyed
* Global: None

WHLSTM jsr J$EVAL
 tst 2,Y Check result
 beq GTOSTM bra if false
 leax 3,X Skip goto & following (do, then)
 rts

***************
* Subroutine EWHSTM
*   ENDWHILE Statement

* ENDWHILE Executes a Goto to the Corresponding WHILE

EWHSTM equ GTOSTM

***************
* Subroutine RPTSTM
*   REPEAT Statement

* REPEAT is An Executional do nothing

RPTSTM equ LETSTM

***************
* Subroutine UNTSTM
*   UNTIL Statement

* Calls Boolean Expression Evaluator; If the Result
*    is False the Goto (To the Corresponding REPEAT)
*    is Executed, If the Result is True the Goto is Skipped
*    and the Following Statements Executed

UNTSTM equ WHLSTM

***************
* Subroutine LOPSTM
*   LOOP Statment

* LOOP is Another do nothing

LOPSTM equ LETSTM

***************
* Subroutine ELPSTM
*   ENDLOOP Statement

* ENDLOOP Executes a Goto to the Corresponding LOOP

ELPSTM equ GTOSTM

***************
* Subroutine EXTSTM
*   EXITIF Statement

* Calls Boolean Expression Evaluator; If the Result is
*    False Executes a Goto Past Corresponding ENDEXIT,
*    If Result is True Skips Goto & THEN and Executes
*    Following Statements

EXTSTM equ WHLSTM

***************
* Subroutine EEXSTM
*   ENDEXIT Statement

* ENDEXIT Executes a Goto Past Corresponding Control
*    Structure's End

EEXSTM equ GTOSTM

***************
* Subroutine NXTSTM
*   NEXT Statement

* NEXT Breaks Down Into Four Routines:
*      Integer Counter, Step 1
*      Integer Counter, Step N
*      Real Counter, Step 1
*      Real Counter, Step N
*    NXTSTM Dispatches to the Appropriate Routine

* Input: (X)=I-Code ptr
* Output: (X)=I-Code ptr (Updated)
* Local: Y,D,CC Destroyed
* Global: None

* NXTSTM Dispatch Table
NXTTBL fdb NXT1IN-NXTTBL,NXTINT-NXTTBL
 fdb NXT1RL-NXTTBL,NXTRL-NXTTBL

NXTSTM leay <NXTTBL,PCR Get dispatch table addr
NXTS10 ldb ,X+ Get TYPE of next
 aslb
 ldd B,Y Get routine offset
 ldu I.ASTR
 jmp D,Y Go to routine


* Subroutine FOR1IN
*
* Perform Initial Counter-Terminal Comparison

FOR1IN ldd 0,X Get counter offset
 leay D,U Make offset into ptr
 bra NXTIN1


* Subroutine FORNIN
*
* Same as FOR1IN

FORNIN ldd 0,X Get counter offset
 leay D,U Make offset into ptr
 ldd 4,X Get increment offset
 lda D,U Test increment sign
 bpl NXTIN1
 bra NXTIN2


* Subroutine NXT1IN
*
* Next; Integer Counter, Step 1

NXT1IN ldd ,X Get counter offset
 leay D,U Get counter addr
 ldd 0,Y Get counter
 addd #1 Increment
 std 0,Y Save it
NXTIN1 ldd 2,X Get terminal offset
 leax 6,X Move icode ptr
 ldd D,U Get terminal
 cmpd 0,Y Compare to counter
 bge GTOSTM Loop if terminal >= counter
 leax 3,X Skip loop addr. & stmt terminator
 rts

***************
* Subroutine NXTINT
*   NEXT; Integer Counter, Step N

NXTINT ldd 0,X Get counter offset
 leay D,U Get counter addr
 ldd 4,X Get increment offset
 ldd D,U Get increment
 pshs A Save increment sign
 addd 0,Y Add counter
 std 0,Y Save it
 tst ,S+ Going up or down?
 bpl NXTIN1 bra if going up
NXTIN2 ldd 2,X Get terminal offset
 leax 6,X
 ldd D,U Get terminal
 cmpd 0,Y Compare to counter
 ble GTOSTM Loop if terminal <= counter
 leax 3,X Skip loop addr. & stmt term.
 rts

***************
* Subroutine FOR1RL
*   Same as FOR1IN

FOR1RL ldy I.OPBG
 clrb
 bsr NXTRLA
 bra NXTRL1

***************
* Subroutine FORNRL
*   Same as FOR1IN

FORNRL ldy I.OPBG
 clrb
 bsr NXTRLA
 ldd 4,X Get increment offset
 addd #4 Get offset of increment end
 ldu I.ASTR Get storage base
 lda D,U Get sign byte
 lsra GET Sign
 bcc NXTRL1
 bra NXTRL2

***************
* Subroutine NXT1RL
*   Next; Real Counter, Step 1

NXT1RL ldy I.OPBG Init opstack ptr
 clrb
 bsr NXTRLA Move counter to opstack
 leay -6,Y Make room for increment
 ldd #$0180 Set up constant one
 std 1,Y
 clra
 clrb
 std 3,Y
 sta 5,Y
 lbsr J$FADD Go do add
 bsr TRCTST Check for trace display
 ldd 1,Y Store new counter
 std 0,U
 ldd 3,Y
 std 2,U
 lda 5,Y
 sta 4,U
NXTRL1 ldb #2
 bsr NXTRLA Move terminal to opstack
 leax 6,X
 lbsr J$FCMP Go compare counter to terminal
 lble GTOSTM Loop if counter <= terminal
 leax 3,X Skip loop addr. & stmt term.
 rts

***************
* Subroutine NXTRLA
*   Move Real value to Opstack

* Input: (X)=I-Code ptr
*        (Y)=Opstack ptr
*        (B)=Offset X Rel to Fetch value
* Output: (U)=value Addr
*         (Y)=Opstack ptr (Updated)
* Local: D,CC Destroyed
* Global: I.ASTR

NXTRLA ldd B,X Get value offset
 addd I.ASTR Make offset into ptr
 tfr D,U
 leay -6,Y Make room on opstack
 lda #S.REAL Set TYPE
 ldb 0,U Move value
 std 0,Y
 ldd 1,U
 std 2,Y
 ldd 3,U
 std 4,Y
 rts

***************
* Subroutine NXTRL
*   NEXT; Real Counter, Step N

NXTRL ldy I.OPBG Init opstack ptr
 clrb
 bsr NXTRLA Move counter to opstack
 stu SYMPTR Save counter addr
 ldb #4
 bsr NXTRLA Move increment to opstack
 lda 4,U Get sign byte
 sta TYPE
 lbsr J$FADD Go add
 bsr TRCTST Check for trace display
 ldu SYMPTR Get counter address
 ldd 1,Y Store new counter
 std 0,U
 ldd 3,Y
 std 2,U
 lda 5,Y
 sta 4,U
 lsr TYPE Test increment sign
 bcc NXTRL1 bra if going up
NXTRL2 ldb #2
 bsr NXTRLA Move terminal to opstack
 leax 6,X
 lbsr J$FCMP Compare counter to terminal
 lbge GTOSTM Loop if counter >= terminal
 leax 3,X Skip loop addr. & stmt term.
NXTR30 rts

TRCTST ldb I.RUNM
 ifne INCLUDED&EDITOR
 bitb #1
 beq NXTR30
 lbra J$TEXR
 else
 rts
 endc

***************
* Subroutine FORSTM
*   FOR Statement

* FOR initializes the counter variable, the terminal value,
*  and optionally the STEP value.  As such it operates As
*  two or three assignment statements.

* FOR Dispatch Table
FORTBL fdb FOR1IN-FORTBL,FORNIN-FORTBL
 fdb FOR1RL-FORTBL,FORNRL-FORTBL

FORSTM ldb ,X+ Get TYPE
 cmpb #T.SRL is counter real?
 beq FORS20 bra if so
 bsr SINTAS Init counter
 bsr FORINT Init terminal
 ldb -1,X Get last TOKEN
 cmpb #T.STEP is increment=1?
 bne FORS10 bra if so
 bsr FORINT Init increment
FORS10 lbsr GTOSTM Move I-Code ptr
 leay <FORTBL,PCR Get dispatch table address
 lbra NXTS10
FORINT ldd ,X++ Get storage offset
 addd I.ASTR Make offset into ptr
 pshs D Save it
 jsr J$EVAL Evaluate expression
 ldd 1,Y Get result
 std [,S++] Store it
 rts

FORS20 bsr SRLAS Init counter
 bsr FORRL Init terminal
 ldb -1,X is increment=1.0?
 cmpb #T.STEP
 bne FORS10 bra if so
 bsr FORRL Init increment
 bra FORS10
FORRL ldd ,X++ Get storage offset
 addd I.ASTR Make offset into ptr
 pshs D Save it
 jsr J$EVAL Evaluate expression
 bra ASGRL Store result

***************
* Subroutine ASGSTM
*   Assignment Statement

* General Assignment Statement Processor for Complex
*   Structures (Strings, Arrays, Records)

* Input: (X)=I-Code ptr
* Output: (X)=I-Code ptr (Updated)
* Local: U,Y,D,CC Destroyed
* Global: I.ASTR, I.DSCR, I.SIZE

ASGSTM jsr J$EVAL Get destination address
ASGST0 cmpa #S.STR need to save size?
 bcs *+6 branch if not
 pshs U save address
 ldu I.SIZE get size
 pshs A,U save TYPE & address(size)
 leax 1,X Skip assignment TOKEN
 jsr J$EVAL Evaluate expression
* bra ASGDIS fall through

***************
* Routine ASGDIS
*   Dispatch for Result Storage

* Input: [S] = Variable TYPE
* Output: None
* Local: A,U,CC Destroyed
* Global: None

ASGDIS puls A Get TYPE
 asla TYPE*2
 leau <ASGBRA,PCR Get ptr to bra table
 jmp A,U
ASGBRA bra ASGBYT
 bra ASGINT
 bra ASGRL
 bra ASGBYT
 bra ASGSTR
 bra ASGRCD

***************
* Subroutine SBYTAS
*   Simple Byte Assignment

* Get Variable Addr, Call Expression Evaluator,
*    and Store Result for TYPE Byte

* Input: (X)=I-Code ptr
* Output: (X)=I-Code ptr (Updated)
* Local: D,CC Destroyed
* Global: I.ASTR

SBYTAS ldd 0,X get offset
 addd I.ASTR make offset into ptr
 pshs D save it
 leax 3,X move I-Code ptr
 jsr J$EVAL Evaluate expression
* bra ASGBYT fall through

***************
* Subroutine ASGBYT
*   Store Byte Result

* Input: [S,S+1] = Variable Addr
*        [S+2,S+3] = Return Addr.
* Output: (X)=I.Icpt
*         S = S+2
* Local: B,CC Destroyed
* Global: I.ICPT Used to Load X

ASGBYT ldb 2,Y Get result
 stb [,S++] Store & pop addr
 rts

***************
* Subroutine SINTAS
*   Simple Integer Assignment

* Same as SBYTAS, Except for Integer

SINTAS ldd 0,X get offset
 addd I.ASTR make offset into ptr
 pshs D save it
 leax 3,X move I-Code ptr
 jsr J$EVAL Evaluate expression
* bra ASGINT fall through

***************
* Subroutine ASGINT
*   Store Integer Result

* Same as ASGBYT, Except D Destroyed

ASGINT ldd 1,Y Get result
 std [,S++] Store it & pop addr
 rts

***************
* Subroutine SRLAS
*   Simple Real Assignment

* Same as SBYTAS, Except for Real

SRLAS ldd 0,X get offset
 addd I.ASTR make offset into ptr
 pshs D save it
 leax 3,X move I-Code ptr
 jsr J$EVAL Evaluate expression
* bra ASGRL fall through

***************
* Subroutine ASGRL
*   Store Real Result

* Same as ASGINT

ASGRL puls U Get variable addr
ASGRL1 ldd 1,Y Get result msdb
 std 0,U
 ldd 3,Y
 std 2,U
 lda 5,Y
 sta 4,U
 rts

***************
* Subroutine SBLAS
*   Simple Boolean Assignment

* Same as SBYTAS, Except for Boolean

SBLAS equ SBYTAS

***************
* Subroutine SSTRAS
*   Simple String Assignment

* Same as SBYTAS

SSTRAS ldd 0,X Get symbol table offset
 addd I.DSCR Make offset into ptr
 tfr D,U
 ldd 0,U Get storage offset
 addd I.ASTR Make offset into ptr
 pshs D Save it
 ldd 2,U Get string max length
 pshs D Save it
 leax 3,X Skip offset & asgnmnt op
 jsr J$EVAL Evaluate expression
* bra ASGSTR fall through

***************
* Subroutine ASGSTR
*   Store String Result

* Same as ASGINT, Except [S] = Max Result Length

ASGSTR puls D,U Get variable size & address
 tstb
 bne ASGSR0
 deca
ASGSR0 sta I.SIZE Save msb
 ldy 1,Y Get result addr
 sty I.STSP Clean string stack
ASGSR1 lda ,Y+ Get next byte
 sta ,U+ Store it
 cmpa #V$ESTR
 beq ASGSR2 Check for end
 decb
 bne ASGSR1
 dec I.SIZE
 bpl ASGSR1
ASGSR2 clra clear Carry
 rts

***************
* Subroutine SVARAS
*   Simple Variable Assignment

* General Assignment Statement Processor for Simple
*    Variables (Unbound Variables, Parameters)

* Same as ASGSTM

SVARAS lbsr J$VREF Call variable address eval
 lbra ASGST0

***************
* Subroutine ASGRCD
*   Move Record

* Same as ASGINT

ASGRCD puls D,U Get destination size & address
 cmpd 3,Y is result smaller?
 bls ASGR10 bra if not
 ldd 3,Y Get result size
ASGR10 ldy 1,Y result addr
 exg Y,U
 lbra J$MVDN move result to destination

***************
* Subroutine POKSTM
*   Poke Statement Routine

* Evaluate Expression for Address, Evaluate Expression For
*    Data, Store Data Byte At Address

POKSTM jsr J$EVAL Evaluate expression
 ldd 1,Y Use result as destination address
 pshs D Save it
 jsr J$EVAL Evaluate expression
 ldb 2,Y Get result
 stb [,S++]
 rts

***************
* Subroutine STPSTM
*   STOP Statement

* Print Message and Exit

STPSTM lbsr PRTSTM Print message if there is one
 lda I.OPTH
 sta I.CNCH
 leax STPMSG,PCR Get message addr
 lbsr STROUT
 lbra J$EXIT

***************
* Subroutine BYESTM
*   BYE Statement

* Exit Basic09

BYESTM lbra J$BYE Call command to exit

***************
* Subroutine PASSTM
*   Pause Statement

PASSTM lbsr PRTSTM Print something
 ifne INCLUDED&EDITOR
 lbra J$DBUG Jump to DEBUG
 else
 rts
 endc

***************
* Subroutine GSBSTM
*   GOSUB Statement

* Pushes Current I-Code ptr on Subroutine Stack And
*    Jumps to Subroutine

* Input: (X)=I-Code ptr
* Output: (X)=I-Code ptr (Updated)
* Local: U,Y,D,CC Destroyed
* Global: U.SBSP,U Updated

GSBSTM ldd 0,X Get destination offset
 leax 3,X Skip offset & statement end
GSBST1 ldy I.ASTR Get storage address
 ldu U.SBSP,Y Get subroutine stack ptr
 cmpu I.STBG Check for overflow
 bhi GSBST2 bra if ok
 ldb #M$SBOV
 lbra EXCERR
GSBST2 stx ,--U Push return addr
 stu U.SBSP,Y Save sub stack ptr
 stu I.OPBG Reset opstack
 addd I.ICBG Make offset a ptr
 tfr D,X Move to I-Code ptr
 rts

***************
* Subroutine RETSTM
*   RETURN Statement

* Performs Subroutine Return

* Input: (X)=I-Code ptr
* Output: (X)=I-Code ptr (Updated)
* Local: U,Y,CC Destroyed
* Global: U.SBSP Updated

RETSTM ldy I.ASTR Get storage address
 cmpy U.SBSP,Y Are there any return addrs?
 bhi RETST1 bra if so
 ldb #M$SBUN
 lbra EXCERR
RETST1 ldu U.SBSP,Y Get subroutine stack ptr
 ldx ,U++ Pop return addr
 stu U.SBSP,Y Save sub stack ptr
 stu I.OPBG Reset opstack
 rts

***************
* Subroutine ONSTM
*   ON Statement

* Performs on Statement; Either Expression Based Dispatch Or
*    Initializes Error Trap Address

* Input: (X)=I-Code ptr
* Output: (X)=I-Code ptr (Updated)
* Local: Y,D,CC Destroyed
* Global: I.OPSP,I.ICBG

ONSTM ldd 0,X Get tokens following ON
 cmpa #T.EROR is this ON ERROR?
 beq ONSTM2 Yes; go init error address
 jsr J$EVAL Get dispatch value
 ldd 0,X Get count (of line nums)
 aslb COUNT*2
 rola
 aslb COUNT*4
 rola
 addd #2 Add for count
 leau D,X Get ptr to next statement
 pshs U Save it
 ldd 1,Y Get dispatch value
 ble ONSTM1 bra if <=0
 cmpd ,X++ is it out of range?
 bhi ONSTM1 Yes; skip to next statement
 subd #1 Adjust from 1,2,3,.. to 0,1,2,..
 aslb DISPATCH*2
 rola
 aslb DISPATCH*4
 rola
 addd #1 Add one for TOKEN
 ldd D,X Get I-Code offset of destination
 pshs D Save it
 ldb 0,X Get TOKEN following dispatch expression
 cmpb #T.GSBD is this ON .. GOSUB?
 puls D,X Get registers ready
 beq GSBST1 bra if ON .. GOSUB
 addd I.ICBG Make offset into ptr
 tfr D,X Use as I-Code ptr
 rts
ONSTM1 puls X,PC
ONSTM2 ldu I.ASTR Get storage base
 cmpb #T.GTBD is it ON ERROR GOTO?
 bne ONSTM3 bra if not
 ldd 2,X Get I-Code offset
 addd I.ICBG Make offset into ptr
 std U.ERRA,U Set error trap address
 lda #1 Mark error trap armed
 sta U.ERRS,U
 leax 5,X Skip to next statement
 rts
ONSTM3 clr U.ERRS,U Cleat error trap armed
 leax 2,X Skip to next statement
 rts
 pag
* Subroutine CRTSTM
*
* Create Statement
*
* Same as INPSTM

CRTSTM bsr OPNSUB Set up for create
 ldb #PREAD.+WRITE.+READ. Set initial attributes
 OS9 I$Create
 bra OPNS10


* Subroutine OPNSTM
*
* Open Statement
*
* Same as INPSTM

OPNSTM bsr OPNSUB Set up for open
 OS9 I$Open
OPNS10 lbcs EXCERR bra if error
 puls B,U Get TYPE & address
 cmpb #S.INT is it integer?
 bne OPNS20 bra if not
 clr ,U+ Clear msb
OPNS20 sta 0,U Set path number
 puls X,PC

OPNSUB leax 1,X Skip '#'
 lbsr ASGVAR Get variable address
 leax 1,X Skip comma
 jsr J$EVAL Get path name
 lda #UPDAT. default update mode
 cmpb #T.MODE is there declared mode?
 bne OPNS30 bra if not
 lda ,X++ get mode specified
OPNS30 ldu 3,S Get return address
 stx 3,S Save I-Code ptr
 ldx 1,Y Get pathlist ptr
 jmp 0,U

***************
* Subroutine SEKSTM
*   SEEK Statement

* Same as INPSTM

SEKSTM lbsr SETCHL Set path number
 jsr J$EVAL Get position
 ldb #V$SEEK Set code
 lbsr J$CVIO
 lbcs EXCER1 bra if error
 rts

***************
* Subroutine INPSTM
*   INPUT Statement

* Inputs a Line and Calls I/O Routines to Process
*    the Variable References

* Input: (X)=I-Code ptr
* Output: (X)=I-Code ptr (Updated)
* Local: Y,D,CC Destroyed
* Global: I.ICPT Destroyed

* Input PROMPT String
PROMPT fcc "? "
 fcb V$ESTR

* Input Error Message
INERST fcc "** Input error - reenter **"
 fcb V$CR,V$ESTR

* Set Path Number
INPSTM lda I.OPTH Set default path
 lbsr SETCHL Set path number
 lda #', use comma as item separator
 sta InpSprtr set item separator

* Print PROMPT
 pshs X Save x
INPS10 ldx 0,S Restore I-Code ptr
 ldb 0,X Get next TOKEN
 cmpb #T.SLIT is there prompt?
 bne INPS20 No; use default
 jsr J$EVAL Evaluate it
 pshs X Save I-Code ptr
 ldx 1,Y Get ptr to string
 bra INPS30
INPS20 pshs X Save I-Code ptr
 leax <PROMPT,PCR Get address of PROMPT
INPS30 bsr STROUT
 puls X Restore I-Code ptr

* Call CNVIO for the Input Line
 lda I.CNCH
 cmpa I.OPTH
 bne INPS35
 lda I.IPTH
 sta I.CNCH
INPS35 ldb #V$INLN Get input line code
 lbsr J$CVIO Call conversion & I/O
 bcc INPS40 ..continue if no error
 cmpb #S$Intrpt Keyboard interrupt?
 lbne EXCER1
 lbsr DEBUG print line, call debugger
 clr I.ERR
 bra INPS10 Re-issue input request

INPS40 bsr INPVAR Call variable input
 bcc INPS50 bra if no error
 leax <INERST,PCR
 bsr STROUT Print error msg
 bra INPS10
INPS50 ldb ,X+ Get next TOKEN
 cmpb #T.COMA Are there more?
 beq INPS40
INPS60 puls D,PC Clean stack & return

INPVAR bsr ASGVAR Get variable address
 ldb 0,S Get TYPE
 addb #V$INBY Get code for input of TYPE
 ldy I.OPBG Init opstack ptr
 lbsr J$CVIO Go input
 lbcc ASGDIS Go dispatch for assignment
* bra BADLIN fall through

* Bad Input Handler
BADLIN lda 0,S Get TYPE
 cmpa #S.STR What type?
 bcs BADLI1 is simple; do normal clean up
 leas 2,S Remove extra bytes
BADLI1 leas 3,S Remove TYPE & storage
 coma set Carry
 rts

* Call CNVIO to Output String
STROUT pshs Y
 leas -6,S
 leay 0,S
 stx 1,Y
 ldd I.IOBG Reset I/O buffer ptr
 std I.IOPT
 ldb #V$PRST
 lbsr J$CVIO Output the string
 ldb #V$PRLN
 lbsr J$CVIO Output the line
 leas 6,S Clean up stack
 puls Y,PC

***************
* Subroutine ASGVAR
*   Get Variable Address

* Input: (X)=I-Code ptr
* Output: (X)=I-Code ptr (Updated)
* Local: U,Y,D,CC Destroyed
* Global: I.DSCR, I.SIZE, I.ASTR

ASGVAR lda ,X+ Get next TOKEN
 cmpa #T.CXAS is it complex assignment?
 bne ASGV10 No; do simple
 jsr J$EVAL Evaluate it
 bra ASGV50
ASGV10 suba #T.SBYT Convert TOKEN to TYPE
 cmpa #S.STR What type?
 bcs ASGV30 Simple; go do it
 beq ASGV20 String
 lbsr J$VREF Must be parameter or unbound variable
 bra ASGV50
ASGV20 ldd ,X++ Get string descr offset
 addd I.DSCR Make offset into ptr
 tfr D,U
 ldd 2,U Get string size
 std I.SIZE Save it
 ldd 0,U Get storage offset
 bra ASGV40
ASGV30 ldd ,X++ Get storage offset
ASGV40 addd I.ASTR Make offset into ptr
 tfr D,U
 lda -3,X Get TOKEN
 suba #T.SBYT Change TOKEN to TYPE
ASGV50 puls Y Get return address
 cmpa #S.STR need to save size?
 bcs *+6 branch if not
 pshs U save address
 ldu I.SIZE get size
 pshs A,U save TYPE & address(size)
 jmp 0,Y Return

***************
* Subroutine SETCHL
*   Set Path Number

* Same as PINPUT

SETCHL ldb 0,X Get TOKEN
 cmpb #T.CNUM is it path token?
 bne SETC10 bra if not
 leax 1,X Skip '#'
 jsr J$EVAL Process path number expression
 cmpb #T.COMA Skip comas if present
 beq SETC05 bra if coma last
 leax -1,X Compensate for eval
SETC05 lda 2,Y Get path number
SETC10 sta I.CNCH Set path number
 rts

***************
* Subroutine RDSTM
*   READ Statement

* Same as INPSTM

RDSTM ldb 0,X Get next TOKEN
 cmpb #T.CNUM is it channel number?
 bne RDST30
 bsr SETCHL Set path number
 clr InpSprtr use zero as item separator
 cmpb #T.COMA is it coma?
 bne RDST05 bra if not
 leax -1,X Back up to it
RDST05 ldb #V$INLN Get a line
 lbsr J$CVIO
 bcc RDST20 bra if no error
 cmpb #E$PrcAbt Keyboard abort?
 beq RDST05 ..yes; re-issue input request
RDSTErr lbra EXCER1

RDST10 lbsr INPVAR
 bcs RDSTErr
RDST20 ldb ,X+ Get next TOKEN
 cmpb #T.COMA Another variable?
 beq RDST10
 rts

RDST30 bsr EOLTST End of statement?
 beq SKPDAT Yes; skip a data entry
RDST40 bsr RDDATA Get a data value
 ldb ,X+ Get next TOKEN
 cmpb #T.COMA is there another?
 beq RDST40 Yes; do it
 rts

RDDATA lbsr ASGVAR Get variable address
 bsr EVLDAT Evaluate data value
 lda 0,S Get variable TYPE
 bne RDDAT1 bra if not byte
 inca MAKE TYPE byte be integer
RDDAT1 cmpa 0,Y Same as result type?
 lbeq ASGDIS Yes; dispatch to assignment routine
 cmpa #S.REAL is variable numeric?
 bcs RDDAT3 Integer; check for real result
 beq RDDAT4 Real; check for integer result
RDDAT2 ldb #M$IET ERR - illegal expression TYPE
 bra RDDATErr

RDDAT3 lda 0,Y Get result TYPE
 cmpa #S.REAL is it real?
 bne RDDAT2 No; error
 lbsr J$FIX Fix it
 lbra ASGDIS Dispatch to assignment
RDDAT4 cmpa 0,Y is result integer?
 bcs RDDAT2 No; error
 lbsr J$FLOT Float it
 lbra ASGDIS Dispatch to assignment

SKPDAT leax 1,X Skip end of line
EVLDAT pshs X Save I-Code ptr
 ldx I.DATA Get ptr to next data value
 bne EVLD10 bra if there is one
 ldb #M$MDAT ERR - missing data statements
RDDATErr lbra EXCERR

EVLD10 jsr J$EVAL Evaluate it
 cmpb #T.COMA is there another value?
 beq EVLD20 Yes; done
 ldd 0,X Get offset of next data statement
 addd I.ICBG Make ofset into ptr
 tfr D,X
EVLD20 stx I.DATA Save data ptr
 puls X,PC

EOLTST cmpb #T.EOL End of line?
 beq EOLT99
 cmpb #T.BKSL Other end of line?
EOLT99 rts

***************
* Subroutine PRTSTM
*   PRINT Statement

* Prints List of values of Expressions

* Input: (X)=I-Code ptr
* Output: (X)=I-Code ptr (Updated)
* Local: Y,D,CC Destroyed
* Global: I.ICPT Destroyed

PRTSTM lda I.OPTH Set default path
 lbsr SETCHL
 ldd I.IOBG Init I/O buffer ptr
 std I.IOPT
PRTST1 ldb ,X+ Get next TOKEN
 cmpb #T.USNG Print using?
 beq PUSING Goto using routine if so
PRTST2 bsr EOLTST End of statement?
 beq PRTST6
PRTST3 cmpb #T.COMA Comma?
 beq PRTST4
 cmpb #T.SCOL Semicolon?
 beq PRTST5
 leax -1,X Must be expression
 jsr J$EVAL Evaluate it
 ldb 0,Y Get TYPE
 addb #V$PRBY Get output code
 bsr IODISP
 ldb -1,X Get last TOKEN
 bra PRTST2 Check it out
PRTST4 ldb #V$SKPZ Get skip zone code
 bsr IODISP
PRTST5 ldb ,X+ Get next TOKEN
 bsr EOLTST End of statement?
 bne PRTST3 bra if not
 bra PRTST7

PRTST6 ldb #V$CRLF Get out CR/LF code
 bsr IODISP
PRTST7 ldb #V$PRLN Get output line code
 bsr IODISP print the line
 lda BufOvf
 clr BufOvf
 tsta did buffer overflow occur in this I/O?
 bne IOError ..Yes; abort
PRTST9 rts

IODISP lbsr J$CVIO
 bcc PRTST9 ..No
IOError lbra EXCER1 ..Yes

***************
* Subroutine PUSING
*   PRINT USING Routine

* Process Format Spec String and Reestablish
* New String Buffer Beg Addr Past Format String
* Call Format Parser to Decode Each Spec, Then
* Format Execution Handler.

PUSING jsr J$EVAL Process format string
* Move String Stack, Init Fmt Spec Buffer
 ldd I.STBG Get old beg addr
 std I.FMBG it becomes fmt buffer
 std I.FMPT
 ldu I.OPBG Get opstack beginning
 pshs D,U Save it
 clr I.FRFL Clear format repeat flag
 ldd I.STSP Set new start
 std I.STBG
* List Process Loop
PUSNG2 ldb -1,X Look at last expr terminator
 bsr EOLTST End of sstatement?
 beq PUSN30 bra if so
 ldb ,X+ Get next TOKEN
 bsr EOLTST End of statement?
 beq PUSN25 bra if so
 leax -1,X Back up to expression
 ldb #V$PARS Call spec parser
 lbsr J$CVIO
 bcc PUSNG2 Continue if no error
 puls D,U Retrieve stack ptrs
 std I.STBG Restore string stack beginning
 stu I.OPBG Reset opstack beginning
 bra IOError abort

PUSN25 leay <PRTST7,PCR Exit no CR/LF
 bra PUSN35
PUSN30 leay <PRTST6,PCR Exit CR/LF
PUSN35 puls D,U Retrieve stack ptrs
 std I.STBG Reset string stack beginning
 stu I.OPBG Reset opstack beginning
 jmp 0,Y Exit properly

***************
* Subroutine WRTSTM
*   WRITE Statement

* Same as PINPUT

WRTSTM lda I.OPTH Set default path number
 lbsr SETCHL Set path number
 ldu I.IOBG Reset I/O buffer ptr
 stu I.IOPT
 ldb ,X+ Get first TOKEN
 lbsr EOLTST End of statement?
 beq WRTS30 bra if so
 cmpb #T.COMA is it comma?
 beq WRTS20 bra if so
 leax -1,X Backup to unknown
 bra WRTS20
WRTS10 clra use zero byte separator
 ldb #V$OBYT
 lbsr J$CVIO Output it
 bcs IOError abort

WRTS20 jsr J$EVAL Evaluate it
 ldb 0,Y Get TYPE
 addb #V$PRBY Make code
 lbsr J$CVIO Output result
 bcs IOError bra if error
 ldb -1,X Get last TOKEN
 lbsr EOLTST End of statement?
 bne WRTS10 bra if not
WRTS30 lbra PRTST6

***************
* Subroutine GETSTM
*   GET Statement

* Same as INPSTM

GETSTM bsr GPSET do get/put setup
 OS9 I$Read
 bra PUTSTM90

***************
* Subroutine PUTSTM
*   PUT Statement

* Same as INPSTM

PUTSTM bsr GPSET do get/put setup
 OS9 I$Write Put record
PUTSTM90 leax 0,U Copy I-Code ptr
 bcc GPSE99
PUTErr lbra EXCERR bra if error

***************
* Subroutine GPSET
*   Setup for Get/Put

GPSET lbsr SETCHL Set path number
 lbsr ASGVAR Get variable address
 leau 0,X Copy I-Code ptr
 puls A Get TYPE
 cmpa #S.STR
 bcc GPSE10
 leax ALCSZT,PCR Get size table ptr
 ldb A,X Get variable size
 clra clear Msb size
 tfr D,Y
 bra GPSE20
GPSE10 puls Y Get size
GPSE20 puls X Get address
 lda I.CNCH Get path number
GPSE99 rts

***************
* Subroutine CLSSTM
*   CLOSE Statement

* Same as INPSTM

CLSSTM lbsr SETCHL Get path number
 OS9 I$Close Close path
 bcs PUTErr
 cmpb #T.COMA Another path?
 beq CLSSTM
 rts

***************
* Subroutine RSTSTM
*   RESTORE Statement

* Same as INPSTM

RSTSTM ldb ,X+ Get next TOKEN
 cmpb #T.LRBD is it line reference?
 beq RSTS20 bra if so
 ldu I.APRC Get ptr to procedure
 ldd P.DATA,U Get offset of first data statement
RSTS10 addd I.ICBG Make offset into ptr
 std I.DATA Reset data ptr
 rts
RSTS20 ldd 0,X Get I-Code offset
 addd #1 Skip DATA TOKEN
 leax 3,X Skip line reference
 bra RSTS10

***************
* Subroutine DLTSTM
*   DELETE Statement

* Same as INPSTM

DLTSTM jsr J$EVAL Get path name
 pshs X Save I-Code ptr
 ldx 1,Y Get ptr to pathlist
 OS9 I$Delete
DLTS10 bcs PUTErr abort if close error
 puls X,PC

***************
* Subroutines CHDSTM, CHXSTM
*   Change working directories

CHDSTM jsr J$EVAL
 lda #UPDAT.
CHDS10 pshs X save I-Code ptr
 ldx 1,Y
 OS9 I$ChgDir
 bra DLTS10

CHXSTM jsr J$EVAL
 lda #EXEC.
 bra CHDS10

***************
* Subroutine SPATH
*   Set Variable to Path

SPATH lbsr ASGVAR Get variable address
 ldy I.OPBG Get opstack ptr
 leay -6,Y Get room
 ldb I.CNCH Get path number
 clra
 std 1,Y Put in stack
 lbra ASGDIS

***************
* Subroutine CHNSTM
*   CHAIN Statement

CHNSTM jsr J$EVAL Get module name
 ldy 1,Y extract name address
 pshs x,y,u
 lbsr J$KALL kills all external procs
 puls x,y,u
 bsr SYSSUB Set up for system call
 sts TEMP borrow compiler's TEMP variable
 lds I.IOBG make stack very small  <--patch <--
 OS9 F$Chain Execute it
 lds TEMP restore stack if unsuccessful
 bra EXCERR Error if return

***************
* Subroutine SYSSTM
*   SHELL Statement

SYSSTM jsr J$EVAL Get module name
 pshs X,U Save I-Code ptr
 ldy 1,Y extract name ptr
 bsr SYSSUB Set up for system call
 OS9 F$Fork
 bcs EXCERR
 pshs A save child's process ID
SYSSTM10 OS9 F$Wait
 cmpa 0,S proper child dead?
 bne SYSSTM10 ..No; back to sleep
 leas 1,S
 tstb
 bne EXCERR
 puls X,U,PC

***************
* Subroutine SYSSUB

* Returns: (A)=(B)=0
*          (X)=ptr to "Shell"
*          (Y)=Param Size
*          (U)=Param ptr

SHELST fcc "SHELL"
 fcb V$CR

SYSSUB ldx I.STSP Get ptr to end of string
 lda #V$CR Insert carriage return
 sta -1,X
 tfr X,D
 leax SHELST,PCR Shell ptr
 leau 0,Y param ptr
 pshs Y
 subd ,S++
 tfr D,Y parameter size
 clra
 clrb HIGHEST Revision
 rts

***************
* Subroutine ERRSTM
*   ERROR Statement

ERRSTM jsr J$EVAL Evaluate error code
 ldb 2,Y Get it
* bra EXCERR fall through

***************
* Subroutine EXCERR
*   Execution Error Handler

* Clean Up Stacks and Return to Caller

EXCERR stb I.ERR Save error code
EXCER1 ldu I.ASTR Get storage address
 beq EXCER4 bra if top level procedure
 tst U.ERRS,U is error trap set?
 beq EXCER2 No; abort
 lds U.S,U Reset stack
 ldx U.ERRA,U Set I-Code ptr to trap address
 ldd U.SBSP,U Reset opstack beginning
 std I.OPBG
 lbra STMLUP

EXCER2 bsr DEBUG print offending line; call debugger
 bsr TOFSTM Turn trace off
 lbra J$EXIT Abort

EXCER4 lbsr J$EREX Print error message
 lbra J$EXIT

 ifne Tandy-0 If it's for Tandy, then
SETALPHA fcb C$Alpha,V$ESTR
DEBUG leax <SETALPHA,PC
 lbsr STROUT
 else
DEBUG equ *
 endc

 ifne INCLUDED&EDITOR
 ldx I.ICPT Get current line ptr
 leay 0,X Copy I-Code ptr
 lbsr J$SKST Find next statement
 clr I.OCNT Clear pretty print count
 lbsr J$PBLN Print line
 ldb I.ERR Get error code
 lbsr J$EREX Print error message
 lbra J$DBUG call debugger; then return
 else
 lbsr J$KALL kill all external procs
 ldb I.ERR Get error code
 OS9 F$Exit Abort
 rts
 endc

***************
* Subroutine B0STM
*   BASE 0 Statement

* Set Array Base to Zero

* Input: (X)=I-Code ptr
* Output: (X)=I-Code ptr (Updated)
* Local: D,CC Destroyed
* Global: I.BASE Set to Zero

B0STM clrb Set I.BASE to zero
 bra BASSTM

***************
* Subroutine B1STM
*   BASE 1 Statement

* Set Array Base to One

* Same as B0STM, Except I.BASE Set to One

B1STM ldb #1 Set I.BASE to one
BASSTM clra
 std I.BASE
 leax 1,X Skip stmt term
 rts

***************
* Subroutine REMSTM
*   REM Statement

* Skip to End of Statement

* Input: (X)=I-Code ptr
* Output: (X)=I-Code ptr (Updated)
* Local: B,CC Destroyed
* Global: None

REMSTM ldb ,X+ Get char count byte
 clra clear Msb
 leax D,X Advance ptr past rem
 rts

***************
* Subroutine DIREXC
*   Direct Execution

* Causes I-Code to Be Executed as Machine Code;
*    Machine Code Routine Should Rts to Return

* Input: (X)=I-Code ptr
* Output: (X)=I-Code ptr (Updated)
* Local: None
* Global: None

DIREXC exg X,PC
 rts

***************
* Subroutine SKPSTM
*   Skip Statement; for Declarative Statements

SKPSTM leay 0,X Copy I-Code ptr
 lbsr J$SKST Move copy to next statement
 leax 0,Y Update I-Code ptr
 rts

***************
* Error Line Statement
*   Line With Compile Error

ELNSTM ldb #M$ERST
 bra EXCERR

***************
* Subroutine DEGSTM
*   DEG/RAD Statements

* Set/Clear Flag
*  0 = Radians
*  1 = Degrees

DEGSTM lda #1
 bra RAD2

RADSTM clra
RAD2 ldu I.ASTR Get storage address
 sta U.DEG,U
 leax 1,X
 rts

***************
* Subroutine TONSTM
*   Trace On/Off Statements

* Set/Clear Trace Flag
TONSTM lda I.RUNM Get run mode
 bita #1 is trace on?
 bne NOCHG bra if so
 ora #1 Set trace on
 bra CHGTRC

TOFSTM lda I.RUNM Get run mode
 bita #1 is trace on?
 beq NOCHG bra if not
 anda #$FE Set trace off
CHGTRC sta I.RUNM
 ldd J$EVAL+1 Switch expression entry
 pshs D Save it
 ldd J$EVAL+3
 std J$EVAL+1
 puls D Retrieve entry
 std J$EVAL+3
NOCHG rts

 pag
***************
*  Subroutine RUNSTM
*   Run Statement

* Run I-code or Object Procedure

RUNSTM lbsr J$VREF Get TYPE & storage ptr
 pshs X Save I-Code ptr
 ldb DEFINT Get variable definition
 cmpb #S.PROC is it procedure?
 beq RUNS10 bra if so
 ldy I.STSP get string stack ptr
 ldx I.SIZE get size of procedure name
RUNS05 lda ,U+ copy proc name
 leax -1,X last character?
 beq RUNS07 ..Yes
 sta ,Y+
 cmpa #V$ESTR
 bne RUNS05 repeat until end of name
 lda ,--Y
RUNS07 ora #$80 set high order bit
 sta 0,Y
 ldy I.STSP ptr to name
 lbsr J$SPRC Find procedure
 bcs BADPRC bra if not found
 leau 0,X Copy procedure entry ptr
RUNS10 ldd 0,U Get procedure ptr
 bne RUNS20 bra if set
 ldy SYMPTR Get symbol table ptr
 leay 3,Y Get name ptr
 lbsr J$SPRC Find procedure
 bcs BADPRC bra if not found
 ldd 0,X Get procedure ptr
 std 0,U Save for future use
RUNS20 ldx 0,S Retrieve I-Code ptr
 std 0,S Save procedure ptr
 ldu I.ASTR Get storage base
 lda I.RUNM Get current run mode
 sta U.RUNM,U Save it
 ldb I.BASE+1 Get array base lsb
 stb U.BASE,U Save it
 ldd I.STBG Get string stack beginning
 std U.STBG,U Save it
 ldd I.PRLM Get parameter limit
 std U.PRLM,U Save it
 ldd I.DATA Get data ptr
 std U.DATA,U Save it
 bsr RPARAM Process parameters
 stx U.ICPT,U Save I-Code ptr
 puls X Retrieve procedure ptr
 lda M$TYPE,X Get procedure TYPE
 beq RUNS40 Internal (un-typed); continue
 cmpa #SBRTN+ICODE I-code procedure?
 beq RUNS40 bra if so
 cmpa #SBRTN+OBJCT Object procedure?
 beq RUNS30 bra if so
BADPRC ldb #M$UPRC Err: unknown procedure
RUNERR lbra EXCERR
RUNS30 ldd U.S,U Get data stack ptr
 pshs D Save it
 sts U.S,U Mark current stack
 leas 0,Y Get parameter ptr
 ldd I.PRLM Get number of parameters
 pshs Y Save parameter ptr
 subd ,S++ Get parameter area size
 lsra Divide by four to get number
 rorb
 lsra
 rorb
 pshs D Save number of parameters
 ldd M$EXEC,X Get execution offset
 leay EXECUT,PCR (programmer: know thyself)
 jsr D,X Run procedure
* (CC,B)=Error status
 ldu I.ASTR Get storage ptr
 lds U.S,U Restore stack
 puls X Get old stack
 stx U.S,U Save it
 bcc RUNS50 continue if no error
 bra RUNERR signal runtime error
RUNS40 lbsr TOFSTM Turn off trace
 lda I.RUNM
 anda #$7F disable step mode
 sta I.RUNM
 lbsr EXECUT Execute basic09 procedure
 lda U.RUNM,U Get old run mode
 bita #1 is trace on?
 beq RUNS50 bra if not
 lbsr TONSTM Turn on trace
 lda U.RUNM,U restore old run mode
 sta I.RUNM Restore it
RUNS50 ldd U.STBG,U Get string stack beginning
 std I.STBG Restore it
 ldd U.PRLM,U Get parameter limit
 std I.PRLM Restore it
 ldd U.DATA,U Get data ptr
 std I.DATA Restore it
 ldb U.BASE,U Get array base lsb
 sex Set Msb
 std I.BASE Restore array base
 ldx U.PROC,U Get procedure ptr
 lbsr SETGLB Set I.xxxx
 ldx U.ICPT,U Restore I-Code ptr
 ldd I.OPSP Reset free space
 subd I.STBG
 std G.VARS
 rts

***************
* Subroutine RPARAM
*   Run Parameters

* Set Up Parameters for Internal Procedure

ALCSZT fcb 1,2,5,1

RPARAM pshs U Save u
 ldb ,X+ Get next TOKEN
 clra clear Parameter count
 pshs A,X Save count & I-Code ptr
 cmpb #T.LPAR Are there parameters?
 bne RPAR50 No; done
 leay 0,S Copy ptr to parameter count
RPAR10 pshs Y Save count ptr
 ldb 0,X Get next TOKEN
 cmpb #T.CXAS is it variable?
 beq RPAR25 Yes; handle it
 jsr J$EVAL Get expression result
 leax -1,X Compensate for eval
 cmpa #S.REAL is it real?
 beq RPAR15 Yes; handle it
 cmpa #S.STR is it string?
 beq RPAR20 Yes; handle it
 ldd 1,Y Get result value
 std 4,Y Move to back of stack
 lda 0,Y Get TYPE
RPAR15 ldb #6 Find ptr to value
 leau <ALCSZT,PCR
 subb A,U Get 6-size
 leau B,Y Use as offset from opstack
 stu I.OPBG Reset opstack
 bra RPAR30
RPAR20 ldu 1,Y Get ptr to string
 ldd I.STSP Get ptr to string end
 subd I.STBG Get string length
 std I.SIZE Save it
 ldd I.STSP Reset string stack
 std I.STBG
 lda #S.STR Get TYPE
 bra RPAR30
RPAR25 leax 1,X Skip complex TOKEN
 jsr J$EVAL Call eval
RPAR30 puls Y Retrieve count ptr
 inc 0,Y Count parameter
 cmpa #S.STR need to save size?
 bcs *+6 branch if not
 pshs U save address
 ldu I.SIZE get size
 pshs A,U save TYPE & address(size)
 ldb ,X+ Get next TOKEN
 cmpb #T.COMA Another parameter?
 beq RPAR10 Yes; go do it
 leax 1,X Skip statement terminator
 stx 1,Y Save I-Code ptr
 leax <ALCSZT,PCR Get ptr to size table
 ldu I.OPBG
 stu I.PRLM Set parameter limit
RPAR35 puls B Get TYPE of last parameter
 cmpb #S.STR What type?
 bcs RPAR40 Simple; do normal
 puls D String or record; get two byte size
 bra RPAR45
RPAR40 ldb B,X Get size
 clra clear Msb
RPAR45 std ,--U Push size
 puls D Get ptr to runtime storage
 std ,--U Push it
 dec 0,Y More parameters?
 bne RPAR35 Yes; go to it
 leay 0,U
 bra RPAR55
RPAR50 ldy I.OPBG Get top of free memory
 sty I.PRLM Set parameter limit
RPAR55 tfr Y,D Copy top of free space
 subd I.STBG Subtract bottom
 lbcs MEMFUL
 std G.VARS Update free space
 puls A,X,U,PC Clean stack, restore u, & return

 pag
***************
* Subroutine KILSTM
*   Kill Statement

* Remove Procedure from Procedure Directory

KILSTM jsr J$EVAL Evaluate expression
 ldy 1,Y Get name string ptr
 pshs X Save I-Code ptr
 lbsr J$KILL Call command to kill
 puls X,PC

 ttl MISC
 pag

INIT lbsr J$EXPI Init expr
 leax STMTDT,PCR
 stx D.STMT
 rts

* End of Statement Interpreter routines

