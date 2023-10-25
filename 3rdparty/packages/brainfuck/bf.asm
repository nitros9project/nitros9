********************************************************************
* bf - Brainfuck Language Interpreter
*
* $Id$
*
* This is a simple interpreter for the Brainfuck language:
* https://en.wikipedia.org/wiki/Brainfuck
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2015/10/02  Boisy G. Pitre
* Created.
*

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

pSize               equ       12000
dSize               equ       3000

                    org       0
pmem                rmb       pSize
dmem                rmb       dSize
stack               rmb       200
size                equ       .

name                fcs       /bfp/
                    fcb       edition

* initialize interpreter
* clear program memory
start
                    lda       #READ.
                    os9       I$Open
                    lbcs      error
                    ldy       #pSize
                    leax      pmem,u
                    os9       I$Read
                    lbcs      error
                    os9       I$Close
                    tfr       y,d                 nul terminate program string in memory
                    clr       d,x

                    leay      dmem,u
                    ldd       #dSize
clrloop             clr       ,y+
                    subd      #$0001
                    bne       clrloop
                    leay      dmem,u
                    bra       parse

ptrInc
                    leay      1,y
                    bra       parse

ptrDec
                    leay      -1,y
                    bra       parse

dataInc
                    inc       ,y
                    bra       parse

dataDec
                    dec       ,y
                    bra       parse

putChar
                    pshs      d,x,y
                    lda       #1
                    tfr       y,x
                    ldy       #1
                    os9       I$Write
                    puls      d,x,y,pc

getChar
                    pshs      d,x,y
                    clra
                    tfr       y,x
                    ldy       #1
                    os9       I$Read
                    puls      d,x,y,pc


brOpen              lda       #1
                    pshs      a
                    tst       ,y
                    bne       brOpenBye
brOpenDo
                    lda       ,x+
                    cmpa      #'[
                    bne       brOpenCkClose
                    inc       ,s
                    bra       brOpenDoTest
brOpenCkClose
                    cmpa      #']
                    bne       brOpenDoTest
                    dec       ,s
brOpenDoTest
                    tst       ,s
                    bne       brOpenDo
brOpenBye
                    puls      a,pc

brClose
                    clr       ,-s
brCloseDo
                    lda       ,-x
                    cmpa      #'[
                    bne       brCloseCkClose
                    inc       ,s
                    bra       brCloseDoCont
brCloseCkClose
                    cmpa      #']
                    bne       brCloseDoCont
                    dec       ,s
brCloseDoCont
                    tst       ,s
                    bne       brCloseDo
                    puls      a,pc

* X = Brainfuck program pointer (nul byte terminates)
* Y = Brainfuck data pointer
parse
                    lda       ,x+
                    beq       parseEnd
                    cmpa      #'>
                    bne       a1
                    leay      1,y
                    bra       parse
a1                  cmpa      #'<
                    bne       a2
                    leay      -1,y
                    bra       parse
a2                  cmpa      #'+
                    bne       a3
                    inc       ,y
                    bra       parse
a3                  cmpa      #'-
                    bne       a4
                    dec       ,y
                    bra       parse
a4                  cmpa      #'.
                    bne       a5
                    bsr       putChar
                    bra       parse
a5                  cmpa      #',
                    bne       a6
                    bsr       getChar
                    bra       parse
a6                  cmpa      #'[
                    bne       a7
                    bsr       brOpen
                    bra       parse
a7                  cmpa      #']
                    bne       parse               unrecognized character -- keep parsing
                    bsr       brClose
                    bra       parse


parseEnd
                    clrb
error
                    os9       F$Exit

                    emod
eom                 equ       *
                    end
