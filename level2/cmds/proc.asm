********************************************************************
* Proc - Show process information
*
* $Id$
*
* NOTE: SHOULD ADD IN TO HANDLE PRINTING NAME OF CURRENT MODULE
*       RUNNING IN A RUNB or BASIC09 PROCESS
*
* From "Inside Level II" by Kevin Darling
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      1988/10/28  Kevin Darling
* Original version.
*
*   ?      1989/07/30
* Modified to show status in English, stderr and the system process.
*
*  11      1994/11/08  L. Curtis Boyle
* Modified to add current executing/editing module name for Basic09
* and/or RunB programs.

                    nam       Proc
                    ttl       Show process information

                    ifp1
                    use       defsfile
                    endc

Type                set       Prgrm+Objct
Revs                set       ReEnt+0
edition             set       11

bufsiz              set       512
stdout              set       1

                    pag
***************************************************
                    mod       PrgSiz,Name,Type,Revs,Entry,DatSiz

Name                fcs       /Proc/
                    fcb       edition

* Data Equates
umem                rmb       2                   Data mem ptr
sysimg              rmb       2                   pointer to sysprc datimg
datimg              rmb       2                   datimg for copymem
datimg2             rmb       2                   2nd copy for non-descriptor use
basicflg            rmb       1                   Flag that primary module is BASIC09 or RUNB
outptr              rmb       2                   pointer in outbuf
number              rmb       3
leadflag            rmb       1
path                rmb       3                   stdin, stdout and stderr
pid                 rmb       1
namlen              rmb       1
hdr                 rmb       64
outbuf              rmb       80                  Buffer for output string
buffer              rmb       bufsiz              working proc. desc.
sysprc              rmb       bufsiz              system proc. desc.
stack               rmb       200
datsiz              equ       .

**************************************************
* Messages
* Headers
Header              fcc       " ID Prnt User Pty  Age  Tsk  Status  Signal   Module    I/O Paths "
                    fcb       C$CR
Hdrlen              equ       *-Header

Header2             fcc       /___ ____ ____ ___  ___  ___  _______ __  __  _________ __________________/
Hdrcr               fcb       C$CR
Hdrlen2             equ       *-Header2

* State Strings (6 characters each)
Quesstr             fcc       /??????/
TimSlpSt            fcc       /TSleep/
TimOStr             fcc       /TimOut/
ImgChStr            fcc       /ImgChg/
SuspStr             fcc       /Suspnd/
CondmStr            fcc       /Condem/
DeadStr             fcc       /Dead          /
Spaces              fcc       /              /
SystmSt             fcc       /System        /

* Special case module names
basic09             fcc       'BASIC'
b09sz               equ       *-basic09
runb                fcc       'RUNB'
runbsz              equ       *-runb
basicms2            fcc       ')'
                    fcb       C$CR
Nomodule            fcc       'Not Defined'
Nomodsz             equ       *-Nomodule

************************************************
Entry               stu       <Umem               save data mem ptr
                    lda       #stdout             Std out path=1
                    leax      Hdrcr,PC            print blank line
                    ldy       #1
                    os9       I$WritLn
                    bcs       Error
                    leax      Header,pcr          Print header line 1
                    ldy       #Hdrlen
                    os9       I$WritLn
                    bcs       Error
                    leax      Header2,pcr         Print header line 2
                    ldy       #Hdrlen2
                    os9       I$WritLn
                    bcs       Error
                    lda       #1
                    leax      >sysprc,U           get system proc. desc.
                    os9       F$GPrDsc
                    bcs       Error
                    leax      P$DatImg,X          just for its dat image
                    stx       <sysimg
                    clra                          set <pid = start -1
                    sta       <basicflg           Default: not a RUNB or BASIC09
                    sta       <pid

* Main Program Loop
Main                ldu       <umem               Get data mem ptr
                    leax      OutBuf,U            Point to line buffer to print to screen
                    stx       <outptr
                    inc       <pid                next process
                    beq       Exit                If wrapped, we are done
                    lda       <pid                get proc ID to check
                    leax      Buffer,U            Point to place to hold process dsc.
                    os9       F$GPrDsc            Get it
                    bcs       Main                loop if no descriptor
                    bsr       Output              print data for descriptor
                    bra       Main                Do rest of descriptors

Exit                clrb
Error               os9       F$Exit

***********************************************
*  Subroutines
* Print Data re Process
* Entry: X=Ptr to buffer copy of process descriptor (Buffer,u)
Output              lda       P$ID,X              process id
                    lbsr      Outdecl             print pid
                    lda       P$PID,X             parent's id
                    lbsr      Outdecl
                    lbsr      Spce
                    ldd       P$User,X            user id
                    lbsr      Outdec
                    lbsr      Spce
                    lda       P$Prior,X           priority
                    lbsr      Outdecl
                    lbsr      Spce
                    lda       P$Age,X             age
                    lbsr      Outdecl
                    lbsr      Spce
                    lbsr      Spce
                    lda       P$Task,X            task no.
                    lbsr      Out2HS
                    lbsr      Spce
                    lda       P$State,X           state
                    pshs      X                   save X
                    lbsr      OutState
                    puls      X                   restore x
                    lda       P$Signal,X          signal
                    lbsr      Outdecl             - in decimal
                    lbsr      Spce
                    lda       P$Signal,X          signal
                    lbsr      Out2HS              - in hex
                    lbsr      Spce
                    ldd       P$Path,X            get stdin and stdout
                    std       <path
                    lda       P$Path+2,X          and stderr
                    sta       <path+2
* Print primary module name
* IN: X - ptr to process descriptor copy (buffer,u)
                    leay      P$DATImg,X
                    tfr       Y,D                 d=dat image
                    std       <datimg
                    std       <datimg2            2nd copy for 2ndary name
                    lda       <pid                working on system process?
                    cmpa      #1
                    beq       Outp2               yes, print name
                    ldx       P$PModul,X          x=offset in map
                    ldb       #9                  set minimum space padded size of name
                    stb       <namlen
                    lbsr      Printnam            Go append name to buffer
                    bra       Outp3

Outp2               leax      SystmSt,pcr         print "System"
                    ldb       #9                  name length
                    lbsr      PutSt1
* Print Standard input Device
Outp3               lbsr      Spce
                    lda       #'<
                    lbsr      Print
                    lbsr      Device
                    lda       <path+1             get stdout
                    sta       <path
                    lda       #'>
                    lbsr      Print
                    lbsr      Device
Stderr              lda       <path+2             get stderr
                    sta       <path
                    lda       #'>
                    lbsr      Print               print first >
                    lda       #'>
                    lbsr      Print
                    bsr       Device
* Print Line
                    ldx       <outptr             now print line
                    lda       #C$CR
                    sta       ,X                  terminate line with CR
                    ldu       <umem
                    leax      outbuf,U            Print it (up to 80 chars)
                    ldy       #80
                    lda       #stdout
                    os9       I$Writln
                    lbcs      Error
                    lda       <basicflg           Was module RUNB or BASIC09?
                    beq       notbasic            No, finished this entry
                    clr       <basicflg           Yes, clear out flag for 2nd call to Printnam
                    leax      outbuf,u            Point to output buffer start
                    ldd       #$20*256+45         45 spaces
copylp              sta       ,x+                 Put spaces into output buffer
                    decb                          Drop size counter
                    bne       copylp              Copy entire message
                    lda       #'(                 Add opening parenthesis
                    sta       ,x+
                    stx       <outptr             Save new output buffer ptr
                    ldd       <datimg2            Get programs DAT img
                    std       <datimg             Save over descriptor one
                    ldx       #$002f              $002f in basic09 is ptr to current module
                    ldy       #2                  Just need ptr for now
                    ldu       <umem
                    leau      hdr,u               Point to place to hold it
                    os9       F$CpyMem            Get current module ptr
                    ldu       <umem               Get data mem ptr
                    ldx       hdr,u               Get ptr to module start in BASIC09 workspace
                    beq       NotDef              If 0, no 'current module' defined
                    lbsr      Printnam            Go append sub-module name to output buffer
                    bra       printit             Add closing chars & print it

NotDef              ldx       <outptr             Get current output buffer ptr
                    leay      Nomodule,pcr        Point to 'Not Defined'
                    ldb       #Nomodsz            Size of message
Notlp               lda       ,y+                 Copy it
                    sta       ,x+
                    decb                          Until done
                    bne       Notlp
                    stx       <outptr             Save output buffer ptr for below
printit             ldd       basicms2,pcr        Get closing ')' + CR
                    ldx       <outptr             Get current output buffer ptr
                    std       ,x                  Append to output buffer
                    ldu       <umem
                    leax      outbuf,U            Print it (up to 80 chars)
                    ldy       #80
                    lda       #stdout
                    os9       I$Writln
                    lbcs      Error
notbasic            rts

* Print Character in A and Device Name
Device              ldu       <umem               restore U
                    lda       <path
                    bne       Device2             if <path = 0, print spaces
                    leax      Spaces,pcr
                    lbra      PutStr

* Get device name
Device2             leau      hdr,U               get table offset in sys map
                    ldd       <sysimg
                    ldx       #D.PthDBT           from direct page
                    ldy       #2
                    os9       F$CpyMem
                    lbcs      Error
                    ldx       hdr                 get <path descriptor table
                    ldy       #64
                    ldd       <sysimg
                    os9       F$CpyMem
                    lbcs      Error
                    ldb       <path               point to <path block
                    lsrb                          four           <paths/ block
                    lsrb
                    lda       B,U                 a=msb block addr.
                    pshs      A
                    ldb       <path               point to <path
                    andb      #3
                    lda       #$40
                    mul
                    puls      A                   d= <path descriptor address
                    addb      #PD.Dev             get device table pointer
                    tfr       D,X
                    ldd       <sysimg
                    ldy       #2
                    os9       F$CpyMem
                    lbcs      Error
                    ldx       hdr                 x= dev. table entry sys.
                    ldb       #V$Desc             we want descr. pointer
                    abx
                    ldd       <sysimg
                    ldy       #2
                    os9       F$CpyMem
                    lbcs      Error
                    ldx       hdr                 get descriptor addr.
                    ldu       <umem
                    ldd       <sysimg
                    std       <datimg
                    ldb       #5
                    stb       <namlen
** Find and print a module name
* IN:  X - module offset
*      U - data area
*      <datimg = pointer
* Read module header
Printnam            pshs      U                   save u
                    leau      hdr,U               destination
                    ldd       <datimg             proc <datimg pointer
                    ldy       #10                 set length (M$Name ptr is @ 4)
                    os9       F$CpyMem            Get 1st 10 bytes of module header
                    lbcs      Error
* Read name from Module to buffer
                    ldd       M$Name,U            get name offset from header
                    ldu       <outptr             move name to outbuf
                    leax      D,X                 X - offset to name
                    ldd       <datimg
                    ldy       #40                 max length of name we will accept
                    os9       F$CpyMem            Get copy of module name
                    puls      U
                    lbcs      Error

                    pshs      X
                    ldx       <outptr
                    pshs      X                   Save start of module name ptr
                    clrb                          set            length = 0
Name3               incb                          Bump up # chars long name is
                    lda       ,X+                 Get char from module name
                    bpl       Name3               No hi-bit terminator yet, keep checking
                    cmpb      #40                 Done, is it >39 chars?
                    bhs       Name5               Yes, skip ahead
                    anda      #$7F                Take out hi-bit
                    sta       -1,X                Save char back without hi-bit
                    cmpb      <namlen             Bigger than max name size we allow?
                    bhs       Name5               No, skip ahead
                    lda       #C$SPAC             If smaller, pad with spaces
Name4               sta       ,X+
                    incb
                    cmpb      <namlen
                    blo       Name4
Name5               stx       <outptr             Save new output buffer ptr
                    lda       <basicflg           Are we here doing a basic09 sub-module?
                    bne       notbas              Yes, don't get stuck in recursive loop
                    ldx       ,s                  Get ptr to start of module name again
                    leay      basic09,pcr         Check for BASIC09 1st
                    ldb       #b09sz              Size of module to check
chkb09lp            lda       ,x+                 Get char from module name
                    anda      #$df                Force to uppercase
                    cmpa      ,y+                 Same as one for BASIC09?
                    bne       chkrunb             No, check runb
                    decb                          Done 'BASIC' yet?
                    bne       chkb09lp            No, keep checking
                    ldd       ,x++                Get last 2 chars from name
                    cmpd      #$3039              '09'?
                    bne       chkrunb             No, try runb
                    lda       ,x                  Next char space (end of name)?
                    cmpa      #C$SPAC
                    beq       setflag             Yes, set basic09 flag
chkrunb             leay      runb,pcr            Point to 'runb'
                    ldb       #runbsz
                    ldx       ,s                  Get ptr to name in buffer
chkrunlp            lda       ,x+                 Get char
                    anda      #$df                Force to uppercase
                    cmpa      ,y+                 Match?
                    bne       notbas              No, not either basic
                    decb                          Done whole check?
                    bne       chkrunlp            No, keep checking
setflag             sta       <basicflg           Set basic09 flag
notbas              leas      2,s                 Eat start of module name ptr
                    puls      X,PC                Restore X & return

* Print Hexidecimal Digit in D
Out4HS              pshs      B
                    bsr       Hexl
                    puls      A
Out2HS              bsr       Hexl

Spce                lda       #C$SPAC
                    bra       Print

* Print Hexidecimal Digit in A
Hexl                tfr       A,B
                    lsra
                    lsra
                    lsra
                    lsra
                    bsr       Outhex
                    tfr       B,A
Outhex              anda      #$0F
                    cmpa      #$0A                0 - 9
                    bcs       Outdig
                    adda      #$07                A - F
Outdig              adda      #'0                 make ASCII

Print               pshs      X
                    ldx       <outptr
                    sta       ,X+
                    stx       <outptr
                    puls      X,PC

* Print 1 Decimal Digit in B
*
Outdecl             tfr       A,B                 <number to B
                    clra

* Print 2 Decimal Digits in D
Outdec              clr       <leadflag
                    pshs      X
                    ldx       <umem
                    leax      <number,X
                    clr       ,X
                    clr       1,X
                    clr       2,X
Hundred             inc       ,X
                    subd      #100
                    bcc       Hundred
                    addd      #100
Ten                 inc       1,X
                    subd      #10
                    bcc       Ten
                    addd      #10
                    incb
                    stb       2,X
                    bsr       Printled
                    bsr       Printled
                    bsr       Printnum
                    bsr       Spce
                    puls      X,PC

Printnum            lda       ,X+                 get char
                    adda      #$30-1              make ASCII
                    bra       Print

Printled            tst       <leadflag           print leading zero?
                    bne       Printnum            yes
                    ldb       ,X                  is it zero?
                    inc       <leadflag
                    decb
                    bne       Printnum            no, print zeros
                    clr       <leadflag
                    lda       #C$SPAC
                    leax      1,X
                    bra       Print

* Print process state in English
*  IN:  A = P$State
OutState            tfr       A,B
                    bitb      #SysState           system?
                    beq       OutSt1              no
                    lda       #'s                 s = System state
                    bra       OutSt2

OutSt1              lda       #C$SPAC

OutSt2              bsr       Print
                    bitb      #TimSleep
                    bne       PTimSlp
                    bitb      #TimOut
                    bne       PTimOut
                    bitb      #ImgChg
                    bne       PImgCh
                    bitb      #Suspend
                    bne       PSuspnd
                    bitb      #Condem
                    bne       PCondem
                    bitb      #Dead
                    bne       PDead
                    bitb      #$04
                    bne       PQues
                    leax      Spaces,pcr          nothing to report
                    bra       PutStr

PQues               leax      QuesStr,pcr
                    bra       PutStr

PTimSlp             leax      TimSlpSt,pcr
                    bra       PutStr

PTimOut             leax      TimOStr,pcr
                    bra       PutStr

PImgCh              leax      ImgChStr,pcr
                    bra       PutStr

PSuspnd             leax      SuspStr,pcr
                    bra       PutStr

PCondem             leax      Condmstr,pcr
                    bra       PutStr

PDead               leax      Deadstr,pcr

Putstr              ldb       #6                  six characters

Putst1              lda       ,X+
                    lbsr      Print
                    decb
                    bne       PutSt1
                    rts

                    emod
Prgsiz              equ       *
                    end
