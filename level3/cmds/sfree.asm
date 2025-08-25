********************************************************************
* SFree - Show free memory for NitrOS-9 Level 3
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      ????/??/??  Alan DeKok
* Written from scratch.

                    nam       SFree
                    ttl       program module


                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

Cnt                 rmb       1                   number of free blocks found
MaxCnt              rmb       1                   size of maximum free block

u000F               rmb       256
                    rmb       200                 for the stack
size                equ       .

name                fcs       /SFree/
                    fcb       edition

L005A               fcb       $00                 temporary DAT image
                    fcb       $00

Global              fcb       C$LF
                    fcc       /----- Level III System Memory -----/
                    fcb       C$LF
                    fcc       /System memory:/
                    fcb       C$CR

SCF                 fcb       C$LF
                    fcc       /SCF local memory:/
                    fcb       C$CR

RBF                 fcb       C$LF
                    fcc       /RBF local memory:/
                    fcb       C$CR

skip                leax      1,x
start               lda       ,x
                    cmpa      #C$SPAC
                    beq       skip
                    cmpa      #C$CR               CR? (no parameters)
                    lbne      Help                no, print out help

                    leax      >L005A,pcr
                    tfr       x,d
                    ldx       #D.SysMem           ptr to system global memory map
                    ldy       #$0002              2 bytes
                    ldu       #u000F              to a buffer
                    os9       F$CpyMem            copy the memory
                    lbcs      Exit                exit on error
                    ldx       ,u                  grab the offset to the buffer
                    leax      $40,x               ignore the first 2 8k blocks
                    ldy       #$00C0              grab the rest of the page
                    os9       F$CpyMem            copy the buffer
                    lbcs      Exit                exit on error

                    leax      >Global,pc
                    lbsr      Print
                    lda       #$C0                maximum number of pages to check
                    bsr       Dump

                    leax      >L005A,pc
                    tfr       x,d
                    ldx       #$0660              Level III blocks
                    leas      -2,s                reserve 2 bytes on-stack
                    leau      ,s                  point to the bytes
                    ldy       #2                  copy 2 bytes over
                    os9       F$CpyMem

                    lda       ,s                  get SCF block number
                    ora       1,s                 and RBF block number
                    beq       Level.2             if none, we're on a Level II system

                    clr       ,-s                 make a temporary DAT image
                    leax      SCF,pc
                    bsr       Local

                    leas      1,s
                    clr       ,s
                    leax      RBF,pc
                    bsr       Local

Level.2             leas      2,s

ClnExit             clrb
Exit                os9       F$Exit

Local               lbsr      Print               print out the header
                    leax      2,s
                    tfr       x,d
                    ldu       #u000F
                    ldx       #$0000              from the start of the block
                    ldy       #$0040              64 bytes only
                    os9       F$CpyMem
                    lda       #$40                64 pages, and fall through to DUMP

Dump                clr       <MaxCnt             no maximum count of free blocks yet
                    clr       <Cnt                total count is zero, too.
                    ldx       #u000F              point to the buffer where the blocks are
                    pshs      a                   save number of pages to check
                    clra                          we haven't found a free block yet

d.skip              ldb       ,x+                 grab a page flag
                    beq       d.loop              this page is free, go check it
d.skip1             dec       ,s                  done one more byte
                    bne       d.skip              if we're not done them all yet, continue
                    bra       d.done              go to the 'done' routine

d.loop              inca                          found a maximum series of free page
                    inc       <Cnt                another total free page
                    dec       ,s                  count down by one byte
                    beq       d.done              exit if we're done everything

                    ldb       ,x+                 grab a page flag
                    beq       d.loop              if it's free, increment counters, etc.
                    cmpa      <MaxCnt             is this block larger than the previous free block?
                    bls       d.skip1             if not, exit
                    sta       <MaxCnt             it's larger, so save it.
                    clra                          reset the count to zero
                    bra       d.skip1             decrement counters, and find another free block

d.done              leas      1,s                 kill counter off of the stack
                    cmpa      <MaxCnt             A=maximum series of free pages
                    bls       d.done1
                    sta       <MaxCnt

d.done1             ldb       <Cnt                get total count of free pages
                    bsr       PNum                print out a decimal number in B
                    leax      MSize,pc
                    ldy       #MLen
                    lda       #$01                STDOUT
                    os9       I$Write             dump it out

                    ldb       <MaxCnt             get maximum size of the free area
                    bsr       PNum                print out the number

                    leax      ZSize,pc            to maximum free size message
                    bsr       Print               go print it out

                    ldb       <Cnt                get size again
                    lsrb
                    lsrb                          get number of K free
                    bsr       PNum                print it out
                    leax      KFree,pc
                    bra       Print

PNum                pshs      a                   save a junk byte
                    ldx       #$2F3A              other data
                    pshs      x
do.100              inc       ,s
                    subb      #100
                    bcc       do.100
do.10               dec       1,s
                    addb      #10
                    bcc       do.10
                    addb      #$30
                    stb       2,s

                    leax      ,s                  point to the numbers
                    ldy       #3                  number of bytes to print out
                    ldd       ,s
                    cmpa      #'0                 leading 0?
                    bne       pn.ok               no, go print
                    leax      1,x                 skip this byte
                    leay      -1,y                one less to print
                    cmpb      #'0                 another leading 0?
                    bne       pn.ok               no, go print
                    leax      1,x                 skip this byte
                    leay      -1,y                one less to print.

pn.ok               lda       #1
                    os9       I$Write             dump it out
                    puls      a,x,pc              dump 3 bytes off of the stack, and return

MSize               fcc       / free pages, largest block /
Mlen                equ       *-MSize
ZSize               fcc       / pages./
                    fcb       C$CR
KFree               fcc       /K of free RAM./
                    fcb       C$CR

Print               ldy       #$0200
                    lda       #$01                to STDOUT
                    os9       I$WritLn
                    rts

Help                leax      HMsg,pc             point to the message
                    bsr       Print               dump it out
                    lbra      ClnExit             and exit

HMsg                fcc       /SFree: Level III utility to show free system memory./
                    fcb       C$LF
                    fcc       /       Beta version 0.9/
                    fcb       C$CR

                    emod
eom                 equ       *
                    end

