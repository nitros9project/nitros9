********************************************************************
* fnxreset - Foenix F256 reset utility
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          2024/06/28  Boisy Gene Pitre
* Started.

                    section   bss
                    rmb       100
                    endsect

                    section   code

**********************************************************
* Entry Point
*
* Here's how registers are set when this process is forked:
*
*   +-----------------+  <--  Y          (highest address)
*   !   Parameter     !
*   !     Area        !
*   +-----------------+  <-- X, SP
*   !   Data Area     !
*   +-----------------+
*   !   Direct Page   !
*   +-----------------+  <-- U, DP       (lowest address)
*
*   B = parameter area size
*  PC = module entry point abs. address
*  CC = F=0, I=0, others undefined
*
* The start of the program is here.
**********************************************************
__start
* This performs a proper reset of the F256.
                    ldd       #$DEAD              get the sentinel values
                    sta       RST0                store the first value
                    stb       RST1                and the second value
                    lda       #$80                set the high bit
                    sta       SYS0                store the high bit in the register
                    clr       SYS0                then clear the high bit in the register
l@                  bra       l@                  wait for the reset condition

                    endsect   0
