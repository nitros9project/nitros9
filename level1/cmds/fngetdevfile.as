********************************************************************
* fngetdevfile - FujiNet utility
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2024/09/11  Boisy Gene Pitre
* Created.

DEBUG               set       0

* Fuji Set Device Full Path command: OP_FUJI + FN_SET_DEVICE_FULLPATH + deviceSlot + hostSlot + mountMode + name[256] 
* Fuji Mount Image command: OP_FUJI + FUJICMD_MOUNT_IMAGE + deviceSlot + options + 

OP_FUJI             equ       $E2
FN_SET_DEVICE_FULLPATH  equ       $E2
FN_GET_DEVICE_FULLPATH	equ	   0xDA
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
netpath             rmb       1		
response            rmb       256
                    endsect

                    section   code

help                lbsr      PRINTS
                    fcc       /Usage: fngetdevfile <device_slot>/
                    fcb       C$CR,0
					lbra      exit
					
* save initial parameters
__start				subd      #$0001
					beq       help
					      
	                clr       d,x
					pshs      x

* set up parameters
                    lbsr      DEC_BIN
					stb       deviceslot,u
					
                    lbsr      NOpen
                    lbcs      errex
                    sta       netpath,u
					
					leas      -2,s
					tfr       s,x
					ldd       #OP_FUJI*256+FN_GET_DEVICE_FULLPATH
					std       ,x
					ldy       #2
					lda       netpath,u
					ldb       #SS.BlkWr
					os9       I$SetStt
					leas      2,s
					lda       netpath,u
					leax      response,u
					ldy       #256
					os9       I$Read
					lbsr      PUTS
					os9       I$Close
					
exit           		clrb
errex       		os9		  F$Exit

                    endsect
