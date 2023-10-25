***************************************

* Subroutine to convert binary number to roman numerals

* OTHER MODULES NEEDED: none

* ENTRY: D=number to convert
*        X=start of buffer (20 bytes)


* EXIT:  all registers preserved

* Note: the buffer should be set to 20 bytes. This permits the
* longest possible number to be converted without a buffer overflow.
* This routine trunates any numbers >8191 to ensure that no number
* is longer than 19 characters (plus null terminator).
* The number 7888 converts to a 19 character string. To permit larger
* number conversions one could delete the anda #%00011111 statement.

* This routine has been converted from the BASIC09 sample in
* the Basic09 Reference Manual (Microware) page a-3.

                    nam       Binary              to Roman numberal conversion
                    ttl       Assembler Library Module


                    section   .text


BIN_ROM
                    pshs      d,x,y,u

                    leau      nums,pcr            number conversion table
                    clr       ,-s                 counter on stack
                    lda       1,s                 restore value
                    anda      #%00011111          ensure no value>8191 permitted

roman1
                    cmpd      ,u
                    blo       roman2
                    leay      chars,pcr
                    bsr       addchar
                    subd      ,u
                    bra       roman1

roman2
                    pshs      d
                    ldd       ,u
                    subd      2,u
                    cmpd      ,s
                    puls      d
                    bhi       roman3

                    leay      subs,pcr
                    bsr       addchar
                    leay      chars,pcr
                    bsr       addchar
                    subd      ,u
                    addd      2,u

roman3
                    leau      4,u                 next pair of values
                    pshs      d
                    inc       2,s                 counter
                    lda       2,s
                    cmpa      #7                  done?
                    puls      d
                    bne       roman1              no, do more

                    puls      a
                    clr       ,x                  null terminator

                    puls      d,x,y,u,pc

addchar
                    pshs      d
                    lda       4,s                 get loop count
                    lda       a,y                 get char
                    sta       ,x+
                    puls      d,pc

nums                fdb       1000,100
                    fdb       500,100
                    fdb       100,10
                    fdb       50,10
                    fdb       10,1
                    fdb       5,1
                    fdb       1,0

chars               fcc       /MDCLXVI/
subs                fcc       /CCXXII/

                    endsect

