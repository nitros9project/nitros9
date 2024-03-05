********************************************************************
* basfork.asm - Test Forking Basic Banner
* 2024/02/22-2024/02/23
* Matt Massie - Repo test
********************************************************************

		nam	Basfork
		use ../defsfile
		* DATA SECTION
tylg               set       Prgrm+Objct
atrv               set       ReEnt+rev
rev                set       $00
edition            set       $00
                   org   0
MMUST              rmb   1
MMUSL1             rmb   1
                   rmb   50
STACK              equ   .-1
DATMEM             equ   .
                   * PROGRAM SECTION
                   mod ENDPRG,NAME,tylg,atrv,ENTRY,DATMEM
NAME               fcs  /Basfork/
ENTRY              equ   *
BannerGo           leax      Banner,pcr
ForkIt             lda       #$01
                   ldb	      #$00
                   ldy       #$0000
                   os9       F$Fork
                   bcs       Error
                   os9       F$Wait
                   bcs       Error
End                 os9       F$Exit
Error              leax      OUTSTR2,pcr
                    ldy       #STRLEN2
                    lda       #1
                   os9       I$Writln
                   bra       End
Banner             fcs       /basban/
                   fcb       $0D
OUTSTR2            fcc       /ERROR/
                   fcb       $0D
STRLEN2             equ       *-OUTSTR2
                   emod
ENDPRG             equ   *
                   end                  
