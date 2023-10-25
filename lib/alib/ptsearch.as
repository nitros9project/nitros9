***************************************

* Pattern Search

* OTHER MODULES REQUIRED: COMPARE

* ENTRY: X=start of memory to search
*        U=end of memory
*        Y=start of pattern
*        D=size of pattern
*        CASEMTCH (a global variable in COMPARE) =0 if A<>a, -1 if A=a

* EXIT: X=address of match if found, unchanged if no match
*       CC zero set if match, clear for no-match
*       A,B,U,Y preserved


                    nam       Pattern             Search
                    ttl       Assembler Library Module


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

PTSEARCH
                    pshs      d,x,y,u
                    leas      -4,s                room for temps
                    tfr       u,d                 end of memory to check
                    subd      patsize,s           end-pattern size
                    std       memend,s            where we stop looking
                    ldd       patstrt,s
                    addd      patsize,s
                    std       pattend,s

* loop here looking for a match of the first characters

inmatch
                    cmpx      memend,s            raeched end of memory
                    bhs       nomatch
                    lda       ,x+                 get char from memory
                    ldb       ,y                  compare to pattern
                    lbsr      COMPARE             compare them
                    bne       inmatch             keep looking for inital match

* see if rest of pattern matches

more
                    tfr       x,u                 save pointer
                    leay      1,y                 already matched that one

more1
                    cmpy      pattend,s           all chars matched, go home happy
                    beq       match
                    lda       ,x+
                    ldb       ,y+
                    lbsr      COMPARE
                    beq       more1               keep matching
                    tfr       u,x                 match fails, backup and do more
                    ldy       patstrt,s           start of pattern
                    bra       inmatch


nomatch
                    lda       #1                  clear zero
                    bra       exit

match
                    leau      -1,u                start of match
                    stu       memstrt,s           where pattern starts
                    clra                          set zero flag=found

exit
                    leas      4,s                 clean stack
                    puls      d,x,y,u,pc

                    endsect


