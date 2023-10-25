                    nam       mach_coco
                    ttl       CoCo machine routines

                    section   code

PIA0Base            equ       $FF00
PIA1Base            equ       $FF20

mach_init
* CoCo 1/2 Initialization Code
                    ldx       #PIA1Base           PIA1
                    clr       -3,x                clear PIA0 Control Register A
                    clr       -1,x                clear PIA0 Control Register B
                    clr       -4,x                set PIA0 side A to input
                    ldd       #$FF34
                    sta       -2,x                set PIA0 side B to output
                    stb       -3,x                enable PIA0 peripheral reg, disable PIA0
                    stb       -1,x                MPU interrupts, set CA2, CA1 to outputs
                    clr       1,x                 $FF20 = DDR, motoroff
                    clr       3,x                 $FF22 = DDR, sound disabled
                    deca                          A = $FE after deca
                    sta       ,x                  bits 1-7 are outputs, bit 0 is input on PIA1 side A
                    lda       #$F8
                    sta       2,x                 bits 0-2 are inputs, bits 3-7 are outputs on B side
                    stb       1,x                 enable peripheral registers, disable PIA1 MPU
                    stb       3,x                 interrupts and set CA2, CB2 as outputs
                    clr       2,x                 set 6847 mode to alphanumeric
                    ldb       #$02
                    stb       ,x                  make RS-232 output marking
                    clrb
                    tfr       b,dp                B = 0
                    ldb       #$04
                    clr       -2,x
                    bitb      2,x

                    lda       #$37
                    sta       PIA1Base+3

                    lda       PIA0Base+3
                    ora       #$01
                    sta       PIA0Base+3

                    lda       PIA1Base+2
                    anda      #$07
                    sta       PIA1Base+2

* 64K DRAM (M0=0, M1=1)
                    sta       $FFDA               RESET M0
                    sta       $FFDD               SET   M1

                    rts

                    endsect
