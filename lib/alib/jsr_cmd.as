***************************************

* Subroutine to jsr to subroutine from 1 character command table

* OTHER MODULES NEEDED: none

* ENTRY: A=1 char command
*        X=start of jump table

* EXIT:  CC carry set if entry not found
*        all other regs can be modified by subs

* Note format of table: each entry is three bytes
*                       0-match character (command)
*                       1..2-offset to routine

* It is the user's job to set commands to proper case for matching...

* end of table=NULL

* sample table:  fcc /A/
*                fdb routineA-*
*                fcc /B/
*                fdb routineB-*
*                fcb 0


                    nam       Jsr                 to 1 char Command
                    ttl       Assembler Library Module

                    section   .text

JSR_CMD
                    tst       ,x                  end of table?
                    beq       jsrerr

                    cmpa      ,x+                 found match?
                    beq       docmd               yes, go do it

                    leax      2,x                 next entry
                    bra       JSR_CMD

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
