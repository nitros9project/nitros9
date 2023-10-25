***************************************

* Subroutine to calc. a random number
* Based on routine by L.A. Middaugh
*                     The Rainbow Jan/85 p. 277

* Value truncated so that it is =>0 and <=passed value in D.

* OTHER MODULES NEEDED: none

* ENTRY: D=max value of number to be returned
* EXIT:  D = value


                    nam       Rnd
                    ttl       Assembler Library Module


                    section   .bss

SEED                rmb       4

                    endsect

                    section   .text

RND
                    pshs      d,x,u

rnd0
                    ldx       #SEED               point to seed
                    ldb       #8                  number of shifts
loop
                    lda       3,x                 exclusive or bit 28 with 31
                    rora
                    rora
                    rora
                    eora      3,x
                    rora                          result in carry
                    rora
                    ror       0,x                 rotate carry into bit0
                    ror       1,x
                    ror       2,x
                    ror       3,x
                    decb                          do 8 times
                    bne       loop
                    ldd       1,x                 get rnd value
                    bne       trunc               ensure we never return a 0
                    inc       1,x                 fudge it so we get a non-zero
                    inc       3,x
                    bra       rnd0

trunc
                    cmpd      ,s                  in range specified?
                    bls       exit                yes
                    subd      ,s
                    bra       trunc

exit
                    leas      2,s                 forget original D
                    puls      x,u,pc


**********************************************
*
* Subroutine to seed the random number buffer
* with the current system date

* ENTRY: none
* EXIT:  none

SEEDRND
                    pshs      d,x
                    leas      -6,s                make room for date
                    tfr       s,x                 point X to buffer
                    os9       F$Time
                    addd      4,x                 add min/secs to value in D
                    addd      <SEED               add to orig value
                    std       <SEED               set msb of seed
                    addd      <SEED+2             add lsb of seed to new msb
                    std       <SEED+2
                    leas      6,s
                    puls      d,x,pc

                    endsect
