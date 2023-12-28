;;; JSR_CMD
;;;
;;; Jump to a subroutine from a one character command table.
;;;
;;; Entry:  A = One character command.
;;;         X = The start of the jump table.
;;;
;;; Exit:  CC = Carry set if entry isn't found.
;;;
;;; Each table entry is composed of three bytes:
;;;     - Byte 0: The command character.
;;;     - Byte 1: The upper 8 bits of the address of the routine.
;;;     - Byte 1: The lower 8 bits of the address of the routine.
;;;
;;; Mark the end of the table with a null byte.
;;;
;;; The commands are case significant.
;;;
;;; Here's an example:
;;;
;;;    fcc /A/
;;;    fdb routineA-*
;;;    fcc /B/
;;;    fdb routineB-*
;;;    fcb 0

                    section   .text

JSR_CMD:            tst       ,x                  end of table?
                    beq       jsrerr

                    cmpa      ,x+                 found match?
                    beq       docmd               yes, go do it

                    leax      2,x                 next entry
                    bra       JSR_CMD

* no match found, return with carry set

jsrerr              coma                          set error flag
                    rts

* command found, do call and return

docmd               ldd       ,x                  get offset to routine
                    jsr       d,x
                    andcc     #%11111110          clear carry
                    rts

                    endsect
