************************************************
*
* Binary to decimal conversion (32 bit)

* OTHER MODULES NEEDED: DECTAB$

* ENTRY: X=buffer for ascii string
*        Y=bits 31-16 of binary value to convert
*        D=bits 15-0  of binary value to convert

* EXIT: all registers (except cc) preserved


                    nam       32                  bit Binary to Decimal Conversion
                    ttl       Assembler Library Module


BIN_DEC32           export

                    section   code

Base                fcb       $3B,$9A,$CA,$00     1,000,000,000
                    fcb       $05,$F5,$E1,$00     100,000,000
                    fcb       $00,$98,$96,$80     10,000,000
                    fcb       $00,$0F,$42,$40     1,000,000
                    fcb       $00,$01,$86,$A0     100,000
                    fcb       $00,$00,$27,$10     10,000
                    fcb       $00,$00,$03,$E8     1,000
                    fcb       $00,$00,$00,$64     100
                    fcb       $00,$00,$00,$0A     10
                    fcb       $00,$00,$00,$01     1


* Entry:
* A = format flag (0 = write leading zeros, 1 = do not)
* X = address of buffer to hold number
* Y = address of 32 bit value
* Exit:
* X = address of buffer holding number
BIN_DEC32
                    pshs      d,x,y,u
                    tfr       x,u
                    tfr       y,x
                    ldb       #10                 max number of numbers (10^9)
                    pshs      b                   save count on stack
                    leay      <Base,pcr           point to base of numbers
s@                  lda       #$30                put #'0
                    sta       ,u                  at U
s1@                 bsr       Sub32               ,X=,X-,Y
                    inc       ,u
                    bcc       s1@                 if X>0, continue
                    bsr       Add32               add back in
                    dec       ,u+
                    dec       ,s                  decrement counter
                    beq       done@
                    lda       ,s
                    cmpa      #$09
                    beq       comma@
                    cmpa      #$06
                    beq       comma@
                    cmpa      #$03
                    bne       s2@
comma@              ldb       #',
                    stb       ,u+
s2@                 leay      4,y                 point to next
                    bra       s@
done@               leas      1,s
                    clr       ,u                  put nil byte at end
* 1,234,567,890
                    tst       ,s                  format flag
                    beq       ex2@
                    ldb       #14                 length of string with commas + 1
                    ldx       2,s                 get pointer to buffer
a@                  decb
                    beq       ex@
                    lda       ,x+                 get byte
                    cmpa      #'0
                    beq       a@
                    cmpa      #',
                    beq       a@
ex@                 leax      -1,x
                    stx       2,s
ex2@                puls      d,x,y,u,pc

* Entry:
* X = address of 32 bit minuend
* Y = address of 32 bit subtrahend
* Exit:
* X = address of 32 bit difference
Sub32               ldd       2,x
                    subd      2,y
                    std       2,x
                    ldd       ,x
                    sbcb      1,y
                    sbca      ,y
                    std       ,x
                    rts


* Entry:
* X = address of 32 bit number
* Y = address of 32 bit number
* Exit:
* X = address of 32 bit sum
Add32               ldd       2,x
                    addd      2,y
                    std       2,x
                    ldd       ,x
                    adcb      1,y
                    adca      ,y
                    std       ,x
                    rts

                    endsect
