****************************************

* DECIMAL to BINARY conversion routine

* OTHER MODULES NEEDED: DECTAB$, IS_TERMIN

* ENTRY: X = start of asci decimal string terminated by
*            a space, comma, CR or null.

* EXIT: D = binary value
*       CC carry set if error (too large, not numeric)
*       Y = terminator or error char.

                    nam       Convert             Decimal String to Binary
                    ttl       Assembler Library Module


                    section   .bss
nega                rmb       1
                    endsect

                    section   .text

DEC_BIN
                    clra                          set result to 0
                    clrb
                    pshs      a,b,x
                    leas      -1,s                temp variable

                    clr       nega,u
                    ldb       ,x+
                    cmpb      #'-
                    bne       decbn15
                    stb       nega,u
decbn1
                    ldb       ,X+                 get a digit
decbn15
                    lbsr      IS_DIGIT
                    bne       decbn3              end of string...
                    inca                          bump string len
                    bra       decbn1              loop for whole string

decbn3
                    lbsr      IS_TERMIN           valid terminator?
                    bne       error

ok
                    tsta                          length = 0?
                    beq       error               yes, error
                    cmpa      #6                  more than 6 chars?
                    bhi       error               yes, error

                    ldx       3,s                 get start of string again

                    pshs      A
                    lda       ,x
                    cmpa      #'-
                    bne       decbn35
                    leax      1,x
decbn35
                    lda       #5                  max length
                    suba      ,S+                 adjust for offset
                    asla                          2 bytes per table entry
                    leay      DECTAB$,PCR         addr of conversion table
                    leay      A,Y                 add in offset for actual len

decbn4
                    lda       ,X+                 get a digit
                    suba      #$30                strip off ASCII
                    beq       decbn6              zero, skip
                    sta       ,s                  save digit=# of adds
                    ldd       1,S                 get binary data

decbn5
                    addd      ,Y                  add in table value
                    bcs       error               past 0, too big
                    dec       ,S                  count down digit size
                    bne       decbn5              loop til 0
                    std       1,S                 save binary data


decbn6
                    leay      2,Y                 next entry
                    tst       1,y                 end of table?
                    bne       decbn4              loop til done
                    clr       ,s+                 clean up and clear carry
                    bra       exit


error
                    clr       0,s                 force data = 0
                    clr       1,s
                    com       ,s+                 clean up and set carry

exit
                    tfr       x,y                 end of string/error char
                    puls      a,b,x
                    bcs       leave
                    tst       nega,u
                    beq       leave
                    subd      #$0001
                    coma
                    comb
                    andcc     #$FE
leave
                    rts


                    endsect

