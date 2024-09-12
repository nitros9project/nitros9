********************************************************************
* fnsetdevfile - FujiNet utility
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2024/09/11  Boisy Gene Pitre
* Created.

DEBUG               set       0

OP_FUJI             equ       $E2
FN_SET_DEVICE_FULLPATH  equ       $E2
FN_MOUNT_IMAGE      equ       $F8

                    section   __os9
type                equ       Prgrm
lang                equ       Objct
attr                equ       ReEnt
rev                 equ       $00
edition             equ       1
stack               equ       200
                    endsect

                    section   bss
deviceslot          rmb       1					
hostslot            rmb       1					
mountmode           rmb       1					
options             rmb       1					
connected           rmb       1
netdatardy          rmb       1
keydatardy          rmb       1
lastsig             rmb       1
port                rmb       2
pbuffer             rmb       256
pbufferl            equ       *
pbend               rmb       2
cbuffer             rmb       256
ccount              rmb       1
opts                rmb       32
orgopts             rmb       32
tcmdbufl            equ       32
tcmdbuf             rmb       tcmdbufl
portdev             rmb       10
netpath             rmb       1
outpath             rmb       1
numbyt              rmb       1
state               rmb       1
telctrlbuf          rmb       3
                    endsect

                    section   code

help                lbsr      PRINTS
                    fcc       /Usage: fnsetdevfile <device_slot> <host_slot> <mode> <path>/
                    fcb       C$CR,0
					lbra      exit
					
* save initial parameters
__start				subd      #$0001
					beq       help
					      
	                clr       d,x

* set up parameters
                    lbsr      DEC_BIN
					stb       deviceslot,u
					tst       ,y
					beq       help
					tfr       y,x
					lbsr      TO_NON_SP
					lbsr      DEC_BIN
					stb       hostslot,u
					tst       ,y
					beq       help
					tfr       y,x
					lbsr      TO_NON_SP
					lbsr      DEC_BIN
					stb       mountmode,u
					tst       ,y
					beq       help
					tfr       y,x
					lbsr      TO_NON_SP
					tst       ,x
					beq       help
					pshs      x
					
* indicate we're setting the device path
                    lbsr      NOpen
                    lbcs      errex
                    sta       netpath,u
					
					leas      -6,s
					tfr       s,x
					ldd       #OP_FUJI*256+FN_SET_DEVICE_FULLPATH
					std       ,x
 					ldd       deviceslot,u
					std       2,x
 					lda       mountmode,u
					sta       4,x
					ldy       #5
					lda       netpath,u
					ldb       #SS.BlkWr
					os9       I$SetStt
					leas      6,s
                    puls      x
                    ldy       #256
					ldb       #SS.BlkWr
					os9       I$SetStt
					os9       I$Close
					
exit           		clrb
errex       		os9		  F$Exit

                    endsect
