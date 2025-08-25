********************************************************************
* Shell - NitrOS-9 command line interpreter
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  17      1983/01/20  Kim Kempf
* Fix RESET to properly DUP paths on errors
*
*  18      1983/02/10  Robert F. Doggett
* Clear Mem size (#K) parameter between pipes
*
*  19      1983/03/28  Robert F. Doggett
* Clean up signal processing; fix #201 error.
*
*  20      1983/03/29  Robert F. Doggett
* Fix bug generated in edition 19. (wait)
*
*  21      1985/??/??
* Original Tandy/Microware version.
*
*  21/2    2003/01/22  Boisy Pitre
* CHD no longer requires WRITE. permission.
*
*  22      2010/01/19  Boisy Pitre
* Added code to honor S$HUP signal and exit when received to support
* networking.
*
*  22      2025/05/04  Boisy G. Pitre
* Added Microware comments from original sources at https://www.roug.org/retrocomputing/os/os9.

 nam Shell
 ttl NitrOS-9 command line interpreter

 ifp1
 use defsfile
 endc

tylg set Prgrm+Objct
atrv set ReEnt+rev
rev set $00
edition set 22

 mod eom,name,tylg,atrv,start,size

Yes set 1
NO set 0
PIPES set YES

BUFSIZ set 200 Input line buffer size
C$MEM set '# set memory size char
C$COMT set '* Comment parameter
C$LF set $0A
C$SPAC set $20
C$COMA set ',
C$DEAD set '-
C$LPAR set '( Shell recursion start
C$RPAR set ') ..end recursion
C$CR set $0D Carriage return
C$PIPE set '! pipeline separator
C$CURR set '& Concurrent execution separator
C$SEQ set '; Sequential execution separator
C$RINP set '< Redirect input char
C$ROUT equ '> Redirect output request

*********** Static Storage Offsets*
 org 0
 rmb 1 Std input  temp for redirection
 rmb 2 Std output temp for redirection
memsiz rmb 1 Std error temp for redirection
modnam rmb 2
prmsiz rmb 2
prmptr rmb 2
modstk rmb 2
useful rmb 1
prncnt rmb 1
kbdsignl rmb 1
OPTS equ . Above bytes are cleared each SHLINE
immort rmb 1 immortal flag
u0010 rmb 1
maxpth rmb 1
print rmb 1
INPTEE rmb 1
errxit rmb 1
temp rmb 1
devnam rmb 72
modbuf rmb 18
shlbuf rmb 400
stack rmb 256 
size equ .

name equ *
shlnam fcs /Shell/
 fcb edition

lantbl fcb Prgrm+PCode
 fcs "PascalS"
 fcb Sbrtn+CblCode
 fcs "RunC"
 fcb Sbrtn+ICode
 fcs "RunB"
 fcb $00 signals end of table
 fcb $00 room for expansion
 fcb $00
 fcb $00
 fcb $00
 fcb $00
 fcb $00
 fcb $00
 fcb $00
 
Intro fcb C$LF
 fcc "Shell"
 fcb C$CR
 
DefPrmpt fcb C$LF
OS9Prmpt fcc "OS9:"
OS9PrmL equ *-OS9Prmpt
DefPrmL equ *-DefPrmpt

 ttl Main Routines
 pag
**********
* Intercept routine
IcptRtn stb <kbdsignl
* +++ BGP added for Hang Up
 cmpb #S$HUP
 lbeq exit
* +++
 rti

start leas -$05,s make room in case first char is "("
 pshs y,x,b,a save param size, ptr, stack top
 ldb #SHLBUF-1
 lbsr clrmem clear out shell's temps
 leax <IcptRtn,pcr get dummy intercept routine
 os9 F$Icpt set up to prevent death
 puls x,b,a restore parameter ptr
 std <prmsiz any parameters?
 beq shel10 ..no; enter shell proper
 lbsr shline process it as a shell line
 bcs Exit2 ..error; return it
 tst <useful was anything useful done?
 bne shel90 ..yes; return (no error)
 
shel10 lds ,s++ recover parameter space
L005E leax <Intro,pcr "OS9 Shell" BANNER
 tst <print prompting turned off?
 bne shel30 ..yes
 bsr shout
 bcs Exit
shel20 leax <DefPrmpt,pcr
 ldy #DefPrmL
shel25 tst <print prompting turned off?
 bne shel30 ..yes
 bsr WritLin2 print prompt
shel30 clra read standard input
 leax <shlbuf,u get buffer ptr
 ldy #BUFSIZ
 os9 I$ReadLn read one line from terminal
 bcc shel40 continue if no error
 cmpb #E$EOF end of file?
 beq shel80 ..yes; exit (no error)
shel35 tst <immort immortal shell?
 bne shel36 ..yes
 tst <errxit exit if errors?
 bne Exit2 ..yes; return error
shel36 os9 F$PErr print error message
 bra shel20 ..repeat
 
shel40 cmpy #$0001 anything entered?
 bhi shel45 ..yes; try to do it
 leax >OS9Prmpt,pcr print new prompt
 ldy #OS9PrmL
 bra shel25 ..repeat
 
shel45 tst <INPTEE copy input to std error?
 beq shel50 ..no; continue
 bsr shout
shel50 lbsr shline process shell line
 bcc shel20 ..repeat if no error
 tstb syntax error?
 bne shel35 ..no; report error
 bra shel20

eofmsg fcc "eof"
 fcb C$CR

shel80 tst <print prompting?
 bne shel90 ..no; just exit
 leax <eofmsg,pcr
 bsr shout
shel90 clrb don't return error
Exit2 lda <immort immortal flag set?
 lbne shlimm ..yes
Exit os9 F$Exit

shout ldy #80
WritLin2 lda #$02 output to error path
 os9 I$WritLn write line
 rts

* I=...
Immortal lbsr L03B3
 lbcs reset
 pshs x
 ldb #SS.DevNm
 leax <devnam,u
 lda #PDELIM
 sta ,x+
 clra stdin
 os9 I$GetStt get device name
 puls x
 lbcs reset
 inc <immort
 inc <u0010
 lbsr reset
 clr <u0010
 rts

 ttl Tables and lists
 pag
**********
* ParamTable
* Table of Shell parameter Functions
*
ParamTable fdb Comment-*
 fcs "*"
 fdb Wait-*
 fcs "W"
 fdb Chd-*
 fcs "CHD"
 fdb Chx-*
 fcs "CHX"
 fdb Ex-*
 fcs "EX"
 fdb Kill-*
 fcs "KILL"
 fdb X-*
 fcs "X"
 fdb NOX-*
 fcs "-X"
 fdb Prompt-*
 fcs "P"
 fdb NoPrompt-*
 fcs "-P"
 fdb Echo-*
 fcs "T"
 fdb NoEcho-*
 fcs "-T"
 fdb SetPr-*
 fcs "SETPR"
 fdb Immortal-*
 fcs "I="
 fdb clrrts-*
 fcs ";"
 fdb $0000
 
**********
* TermTable
*   Table of Shell Options
*
TermTable fdb Pipe-*
 fcs "!"
 fdb shseq-*
 fcs ";"
 fdb Backgrnd-*
 fcs "&"
 fdb Return-*
 fcb $8D
PreTable fdb AllRedir-*
* rest may be pre-parameters
 fcs "<>>>"
 fdb IERedir-*
 fcs "<>>"
 fdb IORedir-*
 fcs "<>"
 fdb OERedir-*
 fcs ">>>"
 fdb ErrRedir-*
 fcs ">>"
 fdb InRedir-*
 fcs "<"
 fdb OutRedir-*
 fcs ">"
 fdb StkSize-*
 fcs "#"
 fdb $0000

* Lists Are Terminated By Negative Byte
*
prnlst fcb C$CR
 fcc "()"
 fcb $ff
trmlst fcb $0d
 fcc "!#&;<>"
 fcb $ff
*
* trmlst Must be in Ascending Sequence

clrmem clr b,u
 decb
 bpl clrmem
 rts
 
 ttl Line Processing routines
 pag
**********
* shline
*   process one Shell command line
*   (Will Never return if Chain is Requested)
*
* Passed: (X)=Shell command; Cr Terminated
*         (U)=Static Storage ptr
* Destroys: D,X,Y
* Error: CC=Set
*
shline ldb #OPTS-1
 bsr clrmem clear option defaults
shli10 clr <memsiz
 clr <kbdsignl
 leay >ParamTable,pcr shell parameter table
 lbsr shfunc ..process shell parameters
 bcs shli90 ..error; return it
 cmpa #C$CR end of line?
 beq shli90 ..yes; return
 sta <useful ..something useful about to happen
 cmpa #'( left paren?
 bne shli50 ..no; process shell command
 leay >shlnam,pcr get name of self
 sty <modnam ..setup to recurr
 leax $01,x
 stx <prmptr passing parenthesized stuff
shli20 inc <prncnt deeper into parens
shli30 leay <prnlst,pcr get paren list
 bsr scan search for end paren
 cmpa #'( ..another open paren?
 beq shli20 ..yes
 cmpa #') end paren?
 bne shli70 ..no; syntax error
 dec <prncnt outermost level?
 bne shli30 ..no; keep searching
 lda #C$CR
 sta -$01,x blast end paren
 bra shli60 ..process parameters
 
shli50 bsr shopts save module, process pre-param opts
 bcs shli90 ..error; return it
shli60 leay <trmlst,pcr List of param terminators
 bsr scan skip over params
 tfr x,d
 subd <prmptr
 std <prmsiz save parameter size for birth
 leax -$01,x back up to terminator
 leay >TermTable,pcr post-param function tbl
 bsr shfunc process command
 bcs shli90 ..error; exit
 ldy <modnam anything forked?
shli70 lbne shlstx ..no; syntax error
 cmpa #C$CR
 bne shli10
shli90 lbra reset reset I/O in case of error

 pag
**********
* shopts
*   process pre-parameter Shell Options
*
* Passed: (X)=command ptr
* Returns: (A)=next char in command line
*          (X)=command ptr updated
*          CC=Set, B=Error Code if Error
* Destroys: B,Y
*
shopts stx <modnam save module/path name ptr
 bsr prsnam
 bcs shop90 ..error; return
shop10 bsr prsnam
 bcc shop10  parse module/path name
 leay >PreTable,pcr pre-param function tbl
 bsr shfunc process pre-param options
 stx <prmptr save parameter ptr
shop90 rts

prsnam os9 F$PrsNam
 bcc prsn10 ..return if no error
 lda ,x+
 cmpa #C$PERD
 bne prsn20 ..error; exit
 cmpa ,x+
 beq prsn15
 leay -$01,x
prsn10 leax ,y
prsn15 clra
 rts
 
prsn20 comb
 leax -$01,x
 ldb #E$BPNam
 rts
 
**********
* shfunc
*   process a List of Shell Functions
*
* Passed: (X)=command line ptr
*         (Y)=Function Table ptr
* Returns: (A)=next char in command line
*          (X)=updated, CC=set if Error
* Destroys: B
*
shfunc bsr skpsep skip command separator
 pshs y save function tbl ptr
 bsr shsrch function symbol in input?
 bcs shfu20 ..no; return (done)
 ldd ,y get routine offset
 jsr d,y process function
 puls y restore function tbl ptr
 bcc shfunc ..repeat if no error
 rts
 
shfu20 clra
 lda ,x
 puls pc,y return (done)
 
**********
* scan
*   Find Desired char in command line
*
* Passed: (X)=command line ptr
*         (Y)=List of chars to Look For
*             --Terminated By $FF
*             --Must be Findable in String* Returns: (A)=char found
*          (X)=updated, one Past char found
*
scan10 puls y

scan pshs y save list of chars
 lda ,x+ get next command char
scan20 tst ,y ..end of list?
 bmi scan10 ..yes; try next char
 cmpa #$22
 bne L023B
L0233 lda ,x+
 cmpa #$22
 bne L0233
 lda ,x+
L023B cmpa ,y+ found?
 bne scan20 ..no
 puls pc,y return
 
**********
* skpsep
*   Skip command line separator
* Passed: (X)=Command line ptr
* Returns: (A)=separator char found
*          (X)=updated* Error: CC=set (No separator found
*
skpsep pshs x
 lda ,x+ get next char in line
 cmpa #C$SPAC
 beq skps20
 cmpa #C$COMA
 beq skps20
 leax >trmlst,pcr
skps10 cmpa ,x+ ..accepted terminator?
 bhi skps10 ..not this one
 puls pc,x ..return carry set if not
 
skps20 leas $02,s throw away saved command ptr
 lda #C$SPAC
skps30 cmpa ,x+ skip spaces
 beq skps30
 leax -$01,x (note: comma returns space)
clrrts andcc #^Carry return carry clear
 rts
 
**********
* shsrch
*   Search for Shell "Keyword"
*
* Passed: (X)=command line ptr
*         (Y)=Function Tbl
* Returns: (X)=updated, if found
*          (Y)=Ptr to Entry found
* Destroys: D
* Error: CC=set if not found
*
shsrch pshs y,x save regs
 leay $02,y
shsr10 ldx ,s reset command line ptr
shsr20 lda ,x+
 cmpa #'a lower case?
 bcs shsr30 ..no; continue
 suba #'a-'A convert to upper case
shsr30 eora ,y+
 lsla MATCH?
 bne shsr40 ..no; skip to next tbl entry
 bcc shsr20 repeat until end of tbl string
 lda -$01,y get last tbl char
 cmpa #'A+$80 symbol (not letter)?
 bcs shsr35 ..yes; don't require separator
 bsr skpsep must be followed by separator
 bcs shsr40 ..not; no match
shsr35 clra CLEAR Carry
 puls pc,y,b,a return; found
 
shsr40 leay -$01,y
shsr45 lda ,y+
 bpl shsr45 skip to end of tbl entry
 sty $02,s ipdate current table position
 ldd ,y++ end of table?
 bne shsr10 ..no; check next entry
 comb
 puls pc,y,x return not found

 ttl Parameters
 pag
 **********
* Ex
*   Chain to a process
*
Ex lbsr shopts process pre-param options
 clra
 bsr clspth close std input if redirected
 bsr clsp00 close std out   if redirected
 bsr clsp00 close std error if redirected
 bsr Comment skip to end of line
 leax $01,x
 tfr x,d
 subd <prmptr compute parameter size
 std <prmsiz
 leas $FF,u move stack onto dp
 lbsr setprm setup chain/fork parameters
 os9 F$Chain chain to process
 lbra Exit2 ..error if returns

clsp00 inca
clspth pshs a
 bra rstp10 (a)=path if redirected

**********
* Chx
*   Change Default Directory
*
Chx lda #DIR.+EXEC. change exec dir
 bra schd10

*Chd lda #DIR.+UPDAT.		note write mode!!
* Removed WRITE. requirement above (some devices are read only)

Chd lda #DIR.+READ. note write mode!!
schd10 os9 I$ChgDir change directory
 rts

**********
* Prompt
*   Turn On/Off "OS9: " printing
*
Prompt clra print prompt
 bra shnp10

NoPrompt lda #$01 don't print prompt
shnp10 sta <print
 rts

**********
* Echo
*   Turn On/Off Input "Tee" Echoing
*
Echo lda #$01 echo input lines
 bra shnt10
 
NoEcho clra don't echo input lines
shnt10 sta <INPTEE
 rts

 pag
 **********
* X
*   Turn On/Off Error Exiting
*
X lda #$01 exit if error
 bra shxr10

NOX clra don't exit if error
shxr10 sta <errxit
 rts
 
**********
* Comment
*   Skip Comment Line
*
Comment lda #C$CR
shcom1 cmpa ,x+
 bne shcom1
 cmpa ,-x backup to carriage return
 rts
L02E7 pshs b,a,cc

 lda #$01
 bra rese10

**********
* reset
*   Close Any Redirected I/O Or pipes
*
* Passed: (U)=Static storage
* Destroys: None
*
reset pshs b,a,cc save regs
 lda #$02 end at stderr
rese10 sta <maxpth save in temp area
 clra start at stdin
rese20 bsr rstpth reset path
 inca increment path
 cmpa <maxpth all reset?
 bls rese20 ..no
 ror ,s+
 puls pc,b,a
 
**********
* Rstpth
*   Reset Redirected path
*
* Passed: (A)=path to Reset
*         (U)=Static storage
* Destroys: B,CC
*
rstpth pshs a save path #
 tst <u0010
 bmi L031B
 bne rstp10
 tst a,u path redirected?
 beq rstp90 ..no; exit
 os9 I$Close close path
 lda a,u
 os9 I$Dup restore path
rstp10 ldb ,s
 lda b,u
 beq rstp90 not redirected; return
 clr b,u
L031B os9 I$Close close saved image
rstp90 puls pc,a

stxmsg fcc "WHAT?"
 fcb C$CR

shlstx bsr reset
 leax <stxmsg,pcr
 lbsr shout print syntax error message
 clrb
 coma
 rts

shlimm inc <u0010
 bsr reset
 lda #$FF
 sta <u0010
 bsr L02E7
 leax <devnam,u
 bsr L03BC
 lbcs Exit
 lda #$02
 bsr rstpth
 lbsr L03DC
 clr <u0010
 lbra L005E
 
 ttl Options
 pag
 **********
* Shrdin
*   Redirect Std Input path
*
* Passed: (X)=New Std Input path
* Returns: (X)=updated
*          CC=set if Error
*
InRedir ldd #READ. path zero, read
 bra shrdr
 
**********
* Shrdou
*   Redirect Std Output Or Error path
*
* Passed: (X)=New pathname
* returns (X)=updated
*         CC=set if Error
*
ErrRedir ldd #$0200+C$CR
 stb -$02,x blast redirection symbol
 bra shrd01

**********
* Shrdr
*   Redirect Output path
*
* Passed: (A)=Output path [0,1,2]
*         (B)=Mode: Read/Write/Update
*         (X)=New pathname ptr
* Returns: (X)=updated
*          CC=set if Error
*
OutRedir lda #$01
shrd01 ldb #$02
 bra shrdr
shrdr0 tst a,u path already redirected?
 bne shlstx ..yes; syntax error
 pshs b,a
 tst <u0010
 bmi L0386
 bra shrdr1
 
shrdr tst a,u path already redirected?
 bne shlstx ..syntax error if so
 pshs b,a save regs
 ldb #C$CR
 stb -$01,x blast redirection symbol
shrdr1 os9 I$Dup copy path
 bcs shrd90 ..exit if error
 ldb ,s
 sta b,u save std path
 lda ,s
 os9 I$Close close std path
L0386 lda $01,s get mode of new path
 bmi L0391
 ldb ,s
 bsr spcnam
 tsta
 bpl L0398
L0391 anda #$0F
 os9 I$Dup
 bra shrd20
L0398 bita #WRITE. output? update?
 bne shrd10 ..yes; create
 os9 I$Open
 bra shrd20
shrd10 ldb #PREAD.+READ.+WRITE. output file attributes
 os9 I$Create
shrd20 stb $01,s return error code
shrd90 puls pc,b,a

L03AA clra
L03AB ldb #$03
 bra shrdr0

AllRedir lda #$0D
L03B1 sta -$04,x
L03B3 bsr L03BC
 bcc L03DC
L03B7 rts
IORedir lda #C$CR
 sta -$02,x
L03BC bsr L03AA
 bcs L03B7
 ldd #$0180
 bra shrdr0

* <>> 
IERedir lda #C$CR
 sta -$03,x back up over <>>
 bsr L03AA
 bcs L03B7
 ldd #$0280
 bra shrdr0

* >>>
OERedir lda #C$CR
 sta -$03,x back up over >>>
 lda #$01
 bsr L03AB
 bcs L03B7
 
L03DC ldd #$0281 stderr in A, ?? in B
 bra shrdr0

* Handle /0 and /2 special names 
spcnam pshs x,b,a save regs
 ldd ,x++ get next two chars
 cmpd #'/*256+'0 /0?
 bcs spcex ..no
 cmpd #'/*256+'2 /2?
 bhi spcex ..no
 pshs x,b,a save regs
 lbsr skpsep skip separator
 puls x,b,a restore regs
 bcs spcex branch if error
 andb #$03 mask out all but lower 2 bits
 cmpb $01,s
 bne L0404
 ldb $01,s
 ldb b,u
L0404 orb #$80
 stb ,s store in A on stack
 puls b,a
 leas $02,s eat X on stack
 rts
spcex puls pc,x,b,a

**********
* StkSize
*   Change Default Memory Requirement
*
* Passed: (X)=Comand line ptr
* Returns: (X)=updated
* Error: CC=Set
*
StkSize ldb #C$CR
 stb -$01,x
 ldb <memsiz already changed?
 lbne shlstx ..yes; syntax error
 lbsr ASC2Int get number
 eora #'K
 anda #$FF-$20 UPPER OR LOWER CASE "K"?
 bne shcm20 ..no
 leax $01,x skip it
 lda #$04
 mul TIMES 4 PAGES PER "K"
 tsta
 lbne shlstx
shcm20 stb <memsiz set new memsize
 lbra skpsep ..must be followed by separator

*********
* Return
*   Sequential Execution (Fork, Wait)
*
Return leax -$01,x back up to end of line
 lbsr shfork give birth
 bra shsq05 wait for death

shseq lbsr shfk00 fork process
shsq05 bcs shsq90 ..exit if error
 lbsr reset reset any redirected I/O
 bsr shwt10 wait for death
shsq10 bcs shsq90 ..exit if error
 lbsr skpsep
 cmpa #C$CR end of command line?
 bne shsq80 ..no; return
 leas $04,s return to shfunc's caller

shsq80 clrb return Carry clear
shsq90 lbra reset

**********
* Backgrnd
*   Start Concurrent process
*
Backgrnd bsr shfk00 blast & char; fork child
 bcs shsq90 ..error; exit
 bsr shsq90 reset std I/O paths
 ldb #'&
 lbsr shpnum print child process id
 bra shsq10 return without waiting

**********
* Wait
*   Wait for any process to Die
Wait clra
shwt10 pshs a save process id
shwt20 os9 F$Wait
 tst <kbdsignl signal received by shell?
 beq shwt25 ..no; continue
 ldb <kbdsignl
 cmpb #S$Abort abort signal?
 bne shwt40 ..no; return error
 lda ,s get most recent child
 beq shwt40 ..unknown; return error
 os9 F$Send abort child process
 clr ,s
 bra shwt20 ..then wait for anybody to die

shwt25 bcs shwt90 ..error (no children); return it
 cmpa ,s desired process id?
 beq shwt40 ..yes; good
 tst ,s waiting for any?
 beq shwt30 ..yes; print proc id; return
 tstb unexpected error?
 beq shwt20 no; wait for another child
shwt30 pshs b save error status
 bsr shsq90 (reset) I/O
 ldb #'-
 lbsr shpnum print '-nn' obituary
 puls b restore status
shwt40 tstb
 beq shwt90
 coma
shwt90 puls pc,a

**********
* Shfork
*   Give Birth to New process
*
setprm lda #Prgrm+Objct
 ldb <memsiz
 ldx <modnam
 ldy <prmsiz
 ldu <prmptr
 rts
 
fork.b lda #EXEC. search for executable module
 os9 I$Open try to open file
 bcs shfork20 ..unable; look for procedure file
 leax <modbuf,u
 ldy #M$Mem+2
 os9 I$Read read module header
 pshs b,cc save status
 os9 I$Close close file
 puls b,cc
 lbcs shfker ..ERROR; abort
 lda M$Type,X get (A)=module type
 ldy M$Mem,X get (Y)=Static storage requirement
 bra shfork.c
 
shfk00 lda #C$CR
 sta -$01,x blast end of param token
 
shfork pshs u,y,x save caller's regs
 clra
 ldx <modnam
 ifgt Level-1
 os9 F$NMLink is module already in memory?
 else
 pshs u
 os9 F$Link is module already in memory?
 puls u
 endc
 bcs fork.b ..No; search 1st for executable module
 ldx <modnam
 ifgt Level-1
 os9 F$UnLoad
 else
 pshs a,b,x,y,u
 os9 F$Link
 os9 F$UnLink
 os9 F$UnLink
 puls a,b,x,y,u
 endc
shfork.c cmpa #Prgrm+Objct program module?
 beq shfork30 ..yes; FORK to it
 sty <modstk save module static storage
 
* Search subroutine library for class processor
 leax >lantbl,pcr
shfork07 tst ,x end of table?
 ifgt Level-1
 beq shfork90 ..yes; non-executable module
 else
 lbeq shfork90 ..yes; non-executable module
 endc
 cmpa ,x+ search table for language type
 beq shfork10 ..found
shfork08 tst ,x+ skip language name
 bpl shfork08
 bra shfork07
 
shfork10 ldd <prmptr
 subd <modnam
 addd <prmsiz
 std <prmsiz
 ldd <modnam
 std <prmptr
 bra shfork25 fork to class processor
 
shfork20 ldx <prmsiz
 leax $05,x
 stx <prmsiz
 ldx <modnam
 ldu $04,s DP pointer
 lbsr InRedir try redirecting input to file
 bcs shfker ..error; return it
 ldu <prmptr
 ldd #'X*256+C$SPAC
 std ,--u default exit if error to child
 ldd #'P*256+C$SPAC
 std ,--u
 ldb #'-
 stb ,-u default no prompts
 stu <prmptr
 leax >shlnam,pcr process "BATCH" FILE
 
shfork25 stx <modnam fork to language interpreter
shfork30 ldx <modnam restore module name
 lda #Prgrm+Objct
 ifgt Level-1
 os9 F$NMLink attempt to link executable module
 else
 pshs u
 os9 F$Link attempt to link executable module
 tfr u,y
 puls u
 endc
 bcc shfork35 ..found; great
 ifgt Level-1
 os9 F$NMLoad load if not in memory
 else
 pshs u
 os9 F$Load load if not in memory
 tfr u,y
 puls u
 endc
 bcs shfker ..return error if not found
shfork35
 ifeq Level-1
 ldy M$Mem,y get executable module's minimum
 endc
 tst <memsiz explicit memory given?
 bne shfork37 ..Yes; use it
 tfr y,d
 addd <modstk add in any required by "packed" modules
 addd #$00FF round up
 sta <memsiz
shfork37 lbsr setprm
 os9 F$Fork
 pshs b,a,cc save error status
 bcs shfork40
 ldx #$0001
 os9 F$Sleep give up time slice to give fetus head start
shfork40 lda #Prgrm+Objct
 ldx <modnam
 clr <modnam signal fork attempt
 clr <modnam+1
 ifgt Level-1
 os9 F$UnLoad release module
 else
 os9 F$Link
 os9 F$UnLink
 os9 F$UnLink
 endc
 puls pc,u,y,x,b,a,cc release module

shfork90 ldb #E$NEMod error; non-executable module
shfker coma
 puls pc,u,y,x return error

**********
* Pipe
*   Build pipeline
*
* Passed: (X)=command ptr
* Returns: (X)=updated
*
PipeName fcc "/pipe"
 fcb C$CR

Pipe pshs x save command ptr
 leax <PipeName,pcr get name of "pipe DEVICE"
 ldd #$0100+UPDAT.
 lbsr shrdr0 Redirect output
 puls x
 bcs shki90 ..error; exit
 lbsr shfk00 fork input side of pipe (blasting)
 bcs shki90 ..error; exit
 lda ,u get current std input path
 bne shpipe10 ..redirected; don't dupe
 os9 I$Dup clone std input path
 bcs shki90 ..exit if error
 sta ,u save path number
shpipe10 clra
 os9 I$Close erase old std input path
 lda #$01
 os9 I$Dup dup std output path to input
 lda #$01
 lbra rstpth reset std output path
 
**********
 * shpnum
 *    Print decimal number, proceeded by (B)
 *
 * Passed: (A)=Number
 *         (B)=Char To Print First
 * Destroys: None
 *
shpnum pshs y,x,b,a
 pshs y,x,b build output scratch
 leax $01,s addr of output ptr
 ldb #'0-1
shpn10 incb form hundred's digit
 suba #100
 bcc shpn10
 stb ,x+
 ldb #'9+1
shpn20 decb form tens digit
 adda #10
 bcc shpn20
 stb ,x+
 adda #'0 form units digit
 ldb #$0D
 std ,x
 leax ,s
 lbsr shout print it
 leas $05,s out goes the scratch
 puls pc,y,x,b,a

 pag
 
**********
* Kill
*   Kill a process
*
* Passed: (X)=param ptr
*       -->process number (dec) to kill
* Returns: (X)=updated
*          CC=set if Error
*
Kill bsr ASC2Int get number
 cmpb #$02 trying to kill process #1 (sysgo)?
 bls L05E7 ..yes; syntax error
 tfr b,a process number to kill
 ldb #S$Kill kill code
 os9 F$Send
shki90 rts

**********
* ASC2Int
*   Convert Ascii Number (0-255) to Binary
*
* Passed: (X)=Ascii String ptr
* Returns: (A)=next char After Number
*          (B)=Number
*          (X)=updated Past Number
*          CC=set if Error
*
ASC2Int clrb
shgn10 lda ,x+
 suba #'0 convert ascii to binary
 cmpa #9 valid decimal digit?
 bhi shgn20 ..no; end of number
 pshs a save digit
 lda #10
 mul MULTIPLY Partial result times 10
 addb ,s+ add in next digit
 bcc shgn10 get next digit if no overflow
shgn20 lda ,-x
 bcs shgn90 ..no; syntax error
 tstb non-zero?
 bne shki90 ..good; return
shgn90 leas $02,s discard return addr
L05E7 lbra shlstx syntax error

SetPr bsr ASC2Int get process number
 stb <temp save proc#
 lbsr skpsep
 bsr ASC2Int get priority
 lda <temp (a)=id, (b)=priority
 os9 F$SPrior set priority
 rts

 emod
eom equ *
 end
