********************************************************************
* PMap - Show process map information
*
* $Id$
*
* From "Inside Level II" by Kevin Darling
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   ?      1987/02/08  Kevin Darling
* Original version.
*
*   2      1989/09/12  Ken Drexler
* Revised to handle 4K or 8K blocks.
*
*   3      2004/05/28  Rodney Hamilton
* Revised for NitrOS-9/OS9Tools compatibility.
* Revised to build for either 8K or 4K blocksize
* based on DAT parameters in SysType file.
*
*   4      2004/06/03  Rodney Hamilton
* Added test for DEAD processes.

                    nam       PMap
                    ttl       Show process map information

                    ifp1
                    use       defsfile
                    endc

Type                set       Prgrm+Objct
Revs                set       ReEnt+0
Bufsiz              set       512
Edition             set       4

Stdout              set       1
Maxnam              set       30
Buflen              set       80

                    pag
***************************************************
*
                    mod       PrgSiz,Name,Type,Revs,Entry,DatSiz

Name                fcs       /PMap/
                    fcb       Edition

* Data Equates
umem                rmb       2
datimg              rmb       2                   datimg for copymem
lineptr             rmb       2
number              rmb       3
leadflag            rmb       1
pid                 rmb       1
hdr                 rmb       12
outbuf              rmb       Buflen
buffer              rmb       Bufsiz              working proc. desc.
stack               rmb       200
DatSiz              equ       .

*************************************************
*
* Messages
*
                    ifeq      DAT.BlSz-8192       8K blocks
Head1               fcc       / ID   01 23 45 67 89 AB CD EF  Program    /
                    fcb       C$CR

Head2               fcc       /____  __ __ __ __ __ __ __ __  ___________/
                    else                          4K blocks
Head1               fcc       / ID   0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F   Program/
                    fcb       C$CR

Head2               fcc       /____  __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __  _______/
                    endc
Hdrcr               fcb       C$CR

SysNam              fcs       "SYSTEM"
Syslen              equ       *-SysNam
DeadNam             fcs       "DEAD"
Deadlen             equ       *-DeadNam

                    spc       3
***************************************************
*
Entry               stu       <umem
                    lda       #1                  start with process 1
                    clr       <pid

* Print header
                    leax      buffer,u            point at storage
                    os9       F$GBlkMp            get block info
                    bcs       Error
                    ifeq      DAT.BlSz-8192
                    cmpd      #8192               8k?
                    else
                    cmpd      #4096               4k?
                    endc
                    bne       Error               we only do 4k/8k

                    leax      <Hdrcr,pcr          print line
                    lbsr      PrintL1             print it
                    leax      <Head1,pcr
                    lbsr      PrintL1             print it
                    leax      <Head2,pcr

                    lbsr      PrintL1

* Main Program Loop
Main                ldu       <umem
                    leax      outbuf,u            set line pointer
                    stx       <lineptr
                    inc       <pid                next process
                    beq       Bye                 >= 255 --> exit
                    lda       <pid                get proc id
                    leax      buffer,u            set destination
                    os9       F$GPrDsc
                    bcs       Main                loop if no descriptor
                    bsr       Output              print data for descriptor
                    bra       Main

Bye                 clrb
Error               os9       F$Exit

* Subroutines

Output              lda       P$ID,x              process id
                    lbsr      Outdecl
                    lbsr      Space
                    lbsr      Space

* Print Process DAT Image
*  IN:  x = process descriptor
*
                    pshs      x
                    leax      P$DATImg,x          point to DAT image
                    ifeq      DAT.BlSz-8192
                    ldb       #DAT.BlCt           set count
                    else
                    ldb       #64/4               set count
                    endc
                    pshs      b

PrntImg             ldd       ,x++                get DAT block
                    cmpd      #DAT.Free           empty?
                    bne       PrntImg2
                    ldy       <lineptr
                    ldd       #$2E2E              was #".. (os9asm beta bug)
                    std       ,y++
                    sty       <lineptr
                    lbsr      Space
                    bra       PrntImg3

PrntImg2            tfr       b,a                 print block no.
                    lbsr      Out2HS

PrntImg3            dec       ,s                  count -= 1
                    bne       PrntImg
                    puls      b,x

* Print primary module name
* IN: X - process descriptor
*
                    lbsr      Space
                    leay      P$DATImg,x
                    sty       <datimg             save pointer
                    ldb       P$State,x           check process state
                    andb      #Dead               was it DEAD?
                    beq       Undead              no, print name
                    leax      >DeadNam,pcr
                    ldb       #Deadlen
                    bra       Copy0               yes, print "DEAD"

Undead              ldx       P$PModul,x          x=offset in map
                    bne       Doname
                    leax      >SysNam,pcr         point at name
                    ldb       #Syslen
Copy0               ldy       <lineptr

Copy                lda       ,x+
                    sta       ,y+
                    decb
                    bne       Copy
                    bsr       Name2
                    bra       Printlin

Doname              bsr       Printnam

* Print Line
Printlin            ldx       <lineptr            terminate line
                    lda       #C$CR
                    sta       ,x
                    ldu       <umem
                    leax      outbuf,u

* Print line
PrintL1             ldy       #Buflen
                    lda       #Stdout
                    os9       I$WritLn
                    lbcs      Error
                    rts

** Find and print a module name
* IN:  X - module offset
*      U - data area
*      datimg = pointer
*
Printnam            equ       *

* Read module header
                    pshs      u                   save u
                    leau      hdr,u               destination
                    ldd       <datimg             proc datimg pointer
                    ldy       #10                 set length
                    os9       F$CpyMem
                    lbcs      Error

* Read name from Module to buffer
                    ldd       M$Name,u            get name offset from header
                    ldu       <lineptr            move name to outbuf
                    leax      d,x                 X - offset to name
                    ldd       <datimg
                    ldy       #Maxnam             set maximum length
                    os9       F$CpyMem
                    puls      u
                    lbcs      Error

Name2               pshs      x
                    ldx       <lineptr
                    clrb                          set length = 0
Name3               incb
                    lda       ,x+
                    bpl       Name3
                    cmpb      #40
                    bcc       Name5
                    anda      #$7F                clear d7
                    sta       -1,x
                    cmpb      #9
                    bcc       Name5
                    lda       #C$SPAC
Name4               sta       ,x+
                    incb
                    cmpb      #9
                    bcs       Name4
Name5               stx       <lineptr
                    puls      x,pc

* Print hex digit in A
Out2HS              bsr       Hexl

Space               lda       #C$SPAC
                    bra       Print


* Print Hexidecimal Digit in A
Hexl                tfr       a,b
                    lsra
                    lsra
                    lsra
                    lsra
                    bsr       Outhex
                    tfr       b,a
Outhex              anda      #$0F
                    cmpa      #$0A                0 - 9
                    bcs       Outdig
                    adda      #$07                A - F
Outdig              adda      #'0                 make ASCII

* Put character in A in buf
Print               pshs      x
                    ldx       <lineptr
                    sta       ,x+
                    stx       <lineptr
                    puls      x,pc

* Print 1 Decimal Digit in A
*
Outdecl             tfr       a,b                 number to B
                    clra

* Print 2 Decimal Digits in D
Outdec              clr       <leadflag
                    pshs      x
                    ldx       <umem
                    leax      number,x
                    clr       ,x
                    clr       1,x
                    clr       2,x
Hundred             inc       ,x
                    subd      #100
                    bcc       Hundred
                    addd      #100
Ten                 inc       1,x
                    subd      #10
                    bcc       Ten
                    addd      #10
                    incb
                    stb       2,x
                    bsr       Printled
                    bsr       Printled
                    bsr       Printnum
                    bsr       Space
                    puls      x,pc

Printnum            lda       ,x+                 get char
                    adda      #'0-1               make ASCII
                    bra       Print

Printled            tst       <leadflag           print leading zero?
                    bne       Printnum            yes
                    ldb       ,x                  is it zero?
                    inc       <leadflag
                    decb
                    bne       Printnum            no, print zeros
                    clr       <leadflag
                    lda       #C$SPAC
                    leax      1,x
                    bra       Print

                    emod
PrgSiz              equ       *
                    end
