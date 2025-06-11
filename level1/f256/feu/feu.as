********************************************************************
* FEU - Foenix Executive Utility
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------

                    nam       FEU
                    ttl       Foenix Executive Utility

VMAJOR              equ       0
VMINOR              equ       4

                    section   bss
keypressed          rmb       1
isflash             rmb       1
buffer              rmb       200
                    endsect

KeySig              equ       $84

                    section   code
Banner              equ       *
                    fcc       /FEU - Foenix Executive Utility/
                    fcb       C$CR
                    fcb       0

SetKeySignal        pshs      d,x
                    clr       keypressed,u
                    ldd       #0*256+SS.SSig      load path and SS.Sig
                    ldx       #KeySig             load the signal to receive when data arrives
                    os9       I$SetStt            call the driver
                    puls      d,x,pc

mainscript          fcs       "...../fscript/main.fscr"

**********************************************************
* Entry Point
**********************************************************
__start             bsr       SetKeySignal        set signal on keyboard input
                    leax      >Banner,pcr         point to the banner
                    lbsr      PUTS                print it

                    leax      mainscript,pcr
                    lbsr      LOADASCR

* Entry: X = menu to display
PromptAndRead       pshs      x                   save the menu pointer
                    lbsr      PUTCR               put a carriage return
                    lbsr      SHOWSCRMENU            show the menu
                    lbsr      PRINTS
                    fcc       /FEU: /
                    fcb       0
                    lbsr      GETC                get a character
                    lbsr      PUTCR
                    puls      x                   restore the menu pointer

                    os9       F$Exit
                    
                    endsect
				
				