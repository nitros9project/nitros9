;;; JSR_CMD
;;;
;;; Jump to a subroutine from a two character command table.
;;;
;;; Entry:  D = Two character command.
;;;         X = The start of the jump table.
;;;
;;; Exit:  CC = Carry set if entry isn't found.
;;;
;;; Each table entry is composed of four bytes:
;;;     - Byte 0: The first command character.
;;;     - Byte 1: The second command character.
;;;     - Byte 2: The upper 8 bits of the address of the routine.
;;;     - Byte 3: The lower 8 bits of the address of the routine.
;;;
;;; Mark the end of the table with a null byte.
;;;
;;; The commands are case significant.
;;;
;;; Here's an example:
;;;
;;;    fcc /A1/
;;;    fdb routineA-*
;;;    fcc /B1/
;;;    fdb routineB-*
;;;    fcb 0

                    section   .text

JSR_CMD2:           tst       ,x                  end of table?
                    beq       jsrerr

                    cmpd      ,x++                found match?
                    beq       docmd               yes, go do it

                    leax      2,x                 next entry
                    bra       JSR_CMD2

* no match found, return with carry set

jsrerr              coma                          set error flag
                    rts

* command found, do call and return

docmd               ldd       ,x                  get offset to routine
                    jsr       d,x
                    andcc     #%11111110          clear carry
                    rts

                    endsect
