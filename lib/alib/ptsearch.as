;;; PTSEARCH
;;;
;;; Search for a pattern in memory.
;;;
;;; Other modules needed: COMPARE
;;;
;;; Entry:  X = The address to start searching.
;;;         U = The address to stop searching.
;;;         Y = The address of the pattern to search.
;;;         D = The length of the pattern to search.
;;;
;;; Set CASEMTCH = 0 for non-case comparison, or -1 for case comparison.
;;;
;;; Exit:   X = The address of the match, if found; otherwise unchanged.
;;;        CC = Zero bit set if there's a match; otherwize bit is clear.
;;;
;;; Registers A, B, Y, and Y are preserved.

                    section   .data

pattend             rmb       2                   end of pattern in memory
memend              rmb       2                   realend-pattern size
patsize             rmb       2                   saved <D>
memstrt             rmb       2                   saved <X>
patstrt             rmb       2                   saved <Y>
realend             rmb       2                   saved <U>

                    endsect

                    section   .text

* set up stack frame for variables

PTSEARCH:           pshs      d,x,y,u
                    leas      -4,s                room for temps
                    tfr       u,d                 end of memory to check
                    subd      patsize,s           end-pattern size
                    std       memend,s            where we stop looking
                    ldd       patstrt,s
                    addd      patsize,s
                    std       pattend,s

* loop here looking for a match of the first characters

inmatch             cmpx      memend,s            raeched end of memory
                    bhs       nomatch
                    lda       ,x+                 get char from memory
                    ldb       ,y                  compare to pattern
                    lbsr      COMPARE             compare them
                    bne       inmatch             keep looking for inital match

* see if rest of pattern matches

more                tfr       x,u                 save pointer
                    leay      1,y                 already matched that one

more1               cmpy      pattend,s           all chars matched, go home happy
                    beq       match
                    lda       ,x+
                    ldb       ,y+
                    lbsr      COMPARE
                    beq       more1               keep matching
                    tfr       u,x                 match fails, backup and do more
                    ldy       patstrt,s           start of pattern
                    bra       inmatch


nomatch             lda       #1                  clear zero
                    bra       exit

match               leau      -1,u                start of match
                    stu       memstrt,s           where pattern starts
                    clra                          set zero flag=found

exit                leas      4,s                 clean stack
                    puls      d,x,y,u,pc

                    endsect


