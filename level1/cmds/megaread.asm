***********************************************************************
* MegaRead - Disk Performance Utility
* $Id$
*
* Modified from an original program by Caveh Jalali
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  01/01   1987/05/30  Bruce Isted (CIS PPN 76625,2273)
* Released to the public domain
*
*  01/00   2004/04/22  Boisy G. Pitre
* Ported to NitrOS-9 style, no error on exit
*
*  01/01   2004/04/22  Rodney V. Hamilton
* Added EOF check for floppy
*
*  01/02   2009/03/14  Bob Devries
* Added functionality to read a number of 1K blocks as specified on the command line.
* Command line is now: megaread #####
* where ##### is the number of 1K blocks to read; default 1024
*
*  01/02   2010/05/22  Boisy G. Pitre
* Made source more configurable in terms of read chunk size and total read count

                    nam       MegaRead
                    ttl       Disk Performance Utilty

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $02
edition             set       1

ChunkSz             equ       1024
ChnkCnt             equ       1024^2/ChunkSz      1024^2 is 1 megabyte (modify as desired)

                    mod       eom,name,tylg,atrv,start,size

                    org       0
StartTm             rmb       5
EndTm               rmb       5
KiloBuff            rmb       ChunkSz
                    rmb       200                 stack space
size                equ       .

name                fcs       /MegaRead/
                    fcb       edition

start               clra
                    clrb
                    bsr       dec2bin             read a character from command line and convert to binary
                    bsr       dec2bin
                    bsr       dec2bin
                    bsr       dec2bin
                    bsr       dec2bin
* capture start time
                    leax      StartTm,u
                    os9       F$Time
                    ldx       #ChnkCnt            seed X with count value to read target size
                    cmpd      #0                  is command line number given?
                    beq       loop                no, so use default (in X)
                    tfr       d,x                 yes, use it
loop                pshs      x                   save counter
                    leax      KiloBuff,u          point (X) to buffer
                    ldy       #ChunkSz            read predetermined chunk
                    clra                          std input
                    os9       I$Read
                    bcs       eofchk
                    puls      x                   recover counter
                    leax      -1,x                done yet?
                    bne       loop                no, go get another chunk
                    bra       fini                yes, exit
eofchk              cmpb      #E$EOF              end of media?
                    bne       exit                no, a real error

* capture end time
fini
                    leax      EndTm,u
                    os9       F$Time

* calculate difference and report

                    clrb
exit                os9       F$Exit

dec2bin             pshs      b,a
                    ldb       ,x                  get char from command line at X
                    subb      #$30                convert decimal char to binary
                    bcs       exd2b               exit if < 0
                    cmpb      #$09
                    bhi       exd2b               or > 9
                    leax      1,x                 bump cmd line pointer
                    pshs      b                   save cmd line character
                    ldb       #$0a
                    mul                           multiply by 10
                    stb       1,s
                    lda       2,s
                    ldb       #$0a
                    mul
                    addb      ,s+
                    adca      ,s
                    std       ,s
exd2b               puls      pc,b,a

                    emod
eom                 equ       *
                    end

