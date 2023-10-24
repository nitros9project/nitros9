***************************************

* Subroutine to jsr to subroutine from 2 character command table

* OTHER MODULES NEEDED: none

* ENTRY: D=2 char command
*        X=start of jump table

* EXIT:  CC carry set if entry not found
*        all other regs can be modified by subs
*        D and X always modified

* Note format of table: each entry is four bytes
*                       0..1-match characters (command)
*                       2..3-offset to routine

* It is the user's job to set commands to proper case for matching...

* end of table=NULL

* sample table:  fcc /A1/
*                fdb routineA-*
*                fcc /B1/
*                fdb routineB-*
*                fcb 0


                    nam       Jsr                 to 2 char Command
                    ttl       Assembler Library Module

                    section   .text

JSR_CMD2
                    tst       ,x                  end of table?
                    beq       jsrerr

                    cmpd      ,x++                found match?
                    beq       docmd               yes, go do it

                    leax      2,x                 next entry
                    bra       JSR_CMD2

* no match found, return with carry set

jsrerr
                    coma                          set error flag
                    rts

* command found, do call and return

docmd
                    ldd       ,x                  get offset to routine
                    jsr       d,x
                    andcc     #%11111110          clear carry
                    rts

                    endsect
