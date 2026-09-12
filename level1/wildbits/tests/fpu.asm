********************************************************************
* fpu - floating point block probe (FP_Math_Module, $FFE0-$FFEF)
*
* IEEE-754 single precision, big endian, in the FIXED I/O page, so no
* MMU work is needed. The Xilinx cores inside are PIPELINED and their
* tvalid inputs are LEVELS taken from control register 2, not pulses:
* write the operands, then assert tvalid, then let the pipe fill.
*
* Writes land in all sixteen registers; reads return control, status
* or results depending on the address. Operands are therefore write
* only - reading FFE8 gives the RESULT, never the operand.
*
* Each line stays under 70 columns.
*
* The order of the checks is deliberate, cheapest wiring proof first:
*   1. control read-back  - is the block decoded at all
*   2. constant 1.0       - control 1 = 3 puts the hardwired constant
*                           3F800000 on the output mux. No operands, no
*                           tvalid, no pipeline. If this fails nothing
*                           else is worth reading
*   3. the same constant through the float-to-20.12 converter
*   4. 2.0 x 3.0, then the product in 20.12
*   5. 6.0 / 4.0, then 1.5 in 20.12
*   6. 1.5 + 2.25 and 1.5 - 2.25 (control 0 bit 3 picks subtract)
*   7. 1.0 / 0.0 - the divide-by-zero flag. The RTL assigns the AXI
*      core's divide-by-zero bit to FP_Div_Status_zero, which lands at
*      status BIT 3; the wire named FP_Div_Status_DivideByZero, read at
*      BIT 4, is declared and never driven. So bit 3 set and bit 4 clear
*      means the RTL is as written; bit 4 set means it has been fixed
*   8. 0.0 x 0.0 - multiply status bit 3 is the same kind of undriven
*      wire (FP_Mult_Status_zero), so it should stay 0 even though the
*      result is zero
*   9. 2.0 written as 20.12 fixed and multiplied by 1.0, which proves
*      the fixed-to-float converter on the input side
*
* Edt/Rev  YYYY/MM/DD  Modified by
* ------------------------------------------------------------------
*   1      2026/09/09  Claude
* Created.

                    nam       fpu
                    ttl       floating point block probe

                    ifp1
                    use       defsfile
                    endc

LBLEN               equ       14                  every label is 14 wide

* control 0: b0/b1 route input 0/1 through the 20.12 converter,
* b3 add(0)/sub(1), b5:4 adder input A source, b7:6 adder input B
C0RAW               equ       $00                 raw inputs, adder A+B=in0+in0
C0ADD               equ       $40                 adder = input0 + input1
C0SUB               equ       $48                 adder = input0 - input1
C0CNV0              equ       $01                 input 0 through the converter
* control 1: output mux 0 mult, 1 div, 2 add/sub, 3 the constant 1.0
C1MUL               equ       $00
C1DIV               equ       $01
C1ADD               equ       $02
C1ONE               equ       $03
* control 2: b0 converter A tvalid, b1 raw input 0, b2 converter B,
* b3 raw input 1
C2RAW               equ       $0A                 both raw inputs valid
C2CNV0              equ       $09                 converter A + raw input 1

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

                    org       0
got                 rmb       4
expv                rmb       4
cnt                 rmb       1
stat                rmb       1                   a status byte as read
line                rmb       80
stack               rmb       200
size                equ       .

name                fcs       /fpu/
                    fcb       edition

hexch               fcc       /0123456789ABCDEF/

t0                  fcc       /fpu ed.1: floating point block at FFE0/
                    fcb       C$CR
t0l                 equ       *-t0
t1                  fcc       /check          got  exp/
                    fcb       C$CR
t1l                 equ       *-t1
texp                fcc       / exp /
texpl               equ       *-texp
tok                 fcc       / OK/
                    fcb       C$CR
tokl                equ       *-tok
tbad                fcc       / BAD/
                    fcb       C$CR
tbadl               equ       *-tbad

lb1                 fcc       /ctrl3 readback/
lb2                 fcc       /const 1.0     /
lb3                 fcc       /const 20.12   /
lb4                 fcc       /2.0 x 3.0     /
lb5                 fcc       /6.0 fixed     /
lb6                 fcc       /mul status    /
lb7                 fcc       ;6.0 / 4.0     ;
lb8                 fcc       /1.5 fixed     /
lb9                 fcc       /div status    /
lb10                fcc       /1.5 + 2.25    /
lb11                fcc       /3.75 fixed    /
lb12                fcc       /add status    /
lb13                fcc       /1.5 - 2.25    /
lb14                fcc       /-0.75 fixed   /
lb15                fcc       ;1.0 / 0.0     ;
lb16                fcc       /divzero stat  /
lb17                fcc       /0.0 x 0.0     /
lb18                fcc       /mulzero stat  /
lb19                fcc       /20.12 2.0 in  /

v0                  fcc       /block not responding - control 3 will not hold/
                    fcb       C$CR
v0l                 equ       *-v0
v1                  fcc       /constant 1.0 missing - output mux or read path dead/
                    fcb       C$CR
v1l                 equ       *-v1
v2                  fcc       /divzero: bit 3 set, bit 4 clear - RTL as written/
                    fcb       C$CR
v2l                 equ       *-v2
v3                  fcc       /divzero: bit 4 set - the undriven wire has been fixed/
                    fcb       C$CR
v3l                 equ       *-v3
v4                  fcc       /divzero: neither bit set - flag not reaching the CPU/
                    fcb       C$CR
v4l                 equ       *-v4

start               leax      t0,pcr
                    ldy       #t0l
                    lbsr      PutLine
                    leax      t1,pcr
                    ldy       #t1l
                    lbsr      PutLine

* ---- 1. control read-back on the spare byte
                    lda       #$5A
                    sta       >FPMATH_CTRL3
                    lda       >FPMATH_CTRL3
                    sta       <got
                    lda       #$5A
                    sta       <expv
                    leax      lb1,pcr
                    lbsr      Rpt8
                    lda       <got
                    cmpa      #$5A
                    beq       One1
                    leax      v0,pcr
                    ldy       #v0l
                    lbsr      PutLine

* ---- 2. the hardwired constant 1.0 on the output mux
One1                lda       #C1ONE
                    sta       >FPMATH_CTRL1
                    lbsr      Settle
                    lbsr      GetOut
                    ldd       #$3F80
                    std       <expv
                    ldd       #$0000
                    std       <expv+2
                    leax      lb2,pcr
                    lbsr      Rpt32
                    ldd       <got
                    cmpd      #$3F80
                    beq       One2
                    leax      v1,pcr
                    ldy       #v1l
                    lbsr      PutLine

* ---- 3. that same 1.0 through the float to 20.12 converter
One2                lbsr      GetFix
                    ldd       #$0000
                    std       <expv
                    ldd       #$1000
                    std       <expv+2
                    leax      lb3,pcr
                    lbsr      Rpt32

* ---- 4. 2.0 x 3.0 = 6.0
                    ldd       #$4000
                    std       >FPMATH_IN0
                    ldd       #$0000
                    std       >FPMATH_IN0+2
                    ldd       #$4040
                    std       >FPMATH_IN1
                    ldd       #$0000
                    std       >FPMATH_IN1+2
                    lda       #C0RAW
                    sta       >FPMATH_CTRL0
                    lda       #C2RAW
                    sta       >FPMATH_CTRL2
                    lda       #C1MUL
                    sta       >FPMATH_CTRL1
                    lbsr      Settle
                    lbsr      GetOut
                    ldd       #$40C0
                    std       <expv
                    ldd       #$0000
                    std       <expv+2
                    leax      lb4,pcr
                    lbsr      Rpt32
                    lbsr      GetFix
                    ldd       #$0000
                    std       <expv
                    ldd       #$6000
                    std       <expv+2
                    leax      lb5,pcr
                    lbsr      Rpt32
                    lda       >FPMATH_MUL_ST
                    sta       <got
                    lda       #$10                b4 tvalid, b3 zero undriven
                    sta       <expv
                    leax      lb6,pcr
                    lbsr      Rpt8

* ---- 5. 6.0 / 4.0 = 1.5
                    ldd       #$40C0
                    std       >FPMATH_IN0
                    ldd       #$0000
                    std       >FPMATH_IN0+2
                    ldd       #$4080
                    std       >FPMATH_IN1
                    ldd       #$0000
                    std       >FPMATH_IN1+2
                    lda       #C1DIV
                    sta       >FPMATH_CTRL1
                    lbsr      Settle
                    lbsr      GetOut
                    ldd       #$3FC0
                    std       <expv
                    ldd       #$0000
                    std       <expv+2
                    leax      lb7,pcr
                    lbsr      Rpt32
                    lbsr      GetFix
                    ldd       #$0000
                    std       <expv
                    ldd       #$1800
                    std       <expv+2
                    leax      lb8,pcr
                    lbsr      Rpt32
                    lda       >FPMATH_DIV_ST
                    sta       <got
                    lda       #$20                b5 tvalid only
                    sta       <expv
                    leax      lb9,pcr
                    lbsr      Rpt8

* ---- 6. 1.5 + 2.25 = 3.75, then 1.5 - 2.25 = -0.75
                    ldd       #$3FC0
                    std       >FPMATH_IN0
                    ldd       #$0000
                    std       >FPMATH_IN0+2
                    ldd       #$4010
                    std       >FPMATH_IN1
                    ldd       #$0000
                    std       >FPMATH_IN1+2
                    lda       #C0ADD
                    sta       >FPMATH_CTRL0
                    lda       #C1ADD
                    sta       >FPMATH_CTRL1
                    lbsr      Settle
                    lbsr      GetOut
                    ldd       #$4070
                    std       <expv
                    ldd       #$0000
                    std       <expv+2
                    leax      lb10,pcr
                    lbsr      Rpt32
                    lbsr      GetFix
                    ldd       #$0000
                    std       <expv
                    ldd       #$3C00
                    std       <expv+2
                    leax      lb11,pcr
                    lbsr      Rpt32
                    lda       >FPMATH_ADD_ST
                    sta       <got
                    lda       #$10                b4 tvalid
                    sta       <expv
                    leax      lb12,pcr
                    lbsr      Rpt8
                    lda       #C0SUB
                    sta       >FPMATH_CTRL0
                    lbsr      Settle
                    lbsr      GetOut
                    ldd       #$BF40
                    std       <expv
                    ldd       #$0000
                    std       <expv+2
                    leax      lb13,pcr
                    lbsr      Rpt32
                    lbsr      GetFix
                    ldd       #$FFFF
                    std       <expv
                    ldd       #$F400
                    std       <expv+2
                    leax      lb14,pcr
                    lbsr      Rpt32

* ---- 7. 1.0 / 0.0 - which status bit carries divide by zero?
                    ldd       #$3F80
                    std       >FPMATH_IN0
                    ldd       #$0000
                    std       >FPMATH_IN0+2
                    std       >FPMATH_IN1
                    std       >FPMATH_IN1+2
                    lda       #C0RAW
                    sta       >FPMATH_CTRL0
                    lda       #C1DIV
                    sta       >FPMATH_CTRL1
                    lbsr      Settle
                    lbsr      GetOut
                    ldd       #$7F80
                    std       <expv
                    ldd       #$0000
                    std       <expv+2
                    leax      lb15,pcr
                    lbsr      Rpt32
                    lda       >FPMATH_DIV_ST
                    sta       <stat
                    sta       <got
                    lda       #$28                b5 tvalid + b3 divide by zero
                    sta       <expv
                    leax      lb16,pcr
                    lbsr      Rpt8
                    lda       <stat
                    bita      #$10                bit 4, the undriven wire
                    beq       Dz1
                    leax      v3,pcr
                    ldy       #v3l
                    bra       DzSay
Dz1                 bita      #$08                bit 3, where the RTL puts it
                    beq       Dz2
                    leax      v2,pcr
                    ldy       #v2l
                    bra       DzSay
Dz2                 leax      v4,pcr
                    ldy       #v4l
DzSay               lbsr      PutLine

* ---- 8. 0.0 x 0.0 - multiply status bit 3 should stay clear
                    ldd       #$0000
                    std       >FPMATH_IN0
                    std       >FPMATH_IN0+2
                    std       >FPMATH_IN1
                    std       >FPMATH_IN1+2
                    lda       #C1MUL
                    sta       >FPMATH_CTRL1
                    lbsr      Settle
                    lbsr      GetOut
                    ldd       #$0000
                    std       <expv
                    std       <expv+2
                    leax      lb17,pcr
                    lbsr      Rpt32
                    lda       >FPMATH_MUL_ST
                    sta       <got
                    lda       #$10                b4 only; b3 is undriven
                    sta       <expv
                    leax      lb18,pcr
                    lbsr      Rpt8

* ---- 9. 2.0 as 20.12 fixed through the input converter, times 1.0
                    ldd       #$0000
                    std       >FPMATH_IN0
                    ldd       #$2000
                    std       >FPMATH_IN0+2       2.0 in 20.12
                    ldd       #$3F80
                    std       >FPMATH_IN1
                    ldd       #$0000
                    std       >FPMATH_IN1+2       1.0 as a float
                    lda       #C0CNV0
                    sta       >FPMATH_CTRL0
                    lda       #C2CNV0
                    sta       >FPMATH_CTRL2
                    lda       #C1MUL
                    sta       >FPMATH_CTRL1
                    lbsr      Settle
                    lbsr      GetOut
                    ldd       #$4000
                    std       <expv
                    ldd       #$0000
                    std       <expv+2
                    leax      lb19,pcr
                    lbsr      Rpt32

                    clrb
                    os9       F$Exit

* ---- GetOut: the selected 32-bit result into got
GetOut              ldd       >FPMATH_OUT
                    std       <got
                    ldd       >FPMATH_OUT+2
                    std       <got+2
                    rts

* ---- GetFix: that same result in 20.12 fixed point into got
GetFix              ldd       >FPMATH_FIXED
                    std       <got
                    ldd       >FPMATH_FIXED+2
                    std       <got+2
                    rts

* ---- Settle: let the AXI pipelines fill. Longest is the divider at
* 14 clocks; this is far more than enough.
Settle              pshs      x
                    ldx       #$0400
Set1                leax      -1,x
                    bne       Set1
                    puls      x,pc

* ---- Rpt8: X -> a 14-char label, got and expv hold one byte each
Rpt8                ldy       #line
                    ldb       #LBLEN
                    lbsr      Copy
                    lda       <got
                    lbsr      Hex2
                    leax      texp,pcr
                    ldb       #texpl
                    lbsr      Copy
                    lda       <expv
                    lbsr      Hex2
                    lda       <got
                    cmpa      <expv
                    bra       Verdict

* ---- Rpt32: the same for a 32-bit value
Rpt32               ldy       #line
                    ldb       #LBLEN
                    lbsr      Copy
                    ldd       <got
                    lbsr      Hex4
                    ldd       <got+2
                    lbsr      Hex4
                    leax      texp,pcr
                    ldb       #texpl
                    lbsr      Copy
                    ldd       <expv
                    lbsr      Hex4
                    ldd       <expv+2
                    lbsr      Hex4
                    ldd       <got
                    cmpd      <expv
                    bne       Verdict
                    ldd       <got+2
                    cmpd      <expv+2

* ---- Verdict: Z set on entry means the check matched
Verdict             beq       VOK
                    leax      tbad,pcr
                    ldb       #tbadl
                    bra       VPut
VOK                 leax      tok,pcr
                    ldb       #tokl
VPut                lbsr      Copy
                    tfr       y,d
                    subd      #line
                    tfr       d,y
                    ldx       #line
                    bra       PutLine

* ---- Copy: B bytes from X to Y, both advance
Copy                stb       <cnt
CopyLoop            lda       ,x+
                    sta       ,y+
                    dec       <cnt
                    bne       CopyLoop
                    rts

* ---- PutLine: X -> text with its CR, Y = length
PutLine             lda       #1
                    os9       I$WritLn
                    rts

* ---- Hex4: D -> four ASCII hex digits at ,y (X preserved)
Hex4                pshs      b
                    bsr       Hex2
                    puls      a
* ---- Hex2: A -> two ASCII hex digits at ,y++ (X preserved)
Hex2                pshs      a,x
                    lsra
                    lsra
                    lsra
                    lsra
                    bsr       Nib
                    lda       ,s
                    anda      #$0F
                    bsr       Nib
                    puls      a,x,pc
Nib                 leax      hexch,pcr
                    lda       a,x
                    sta       ,y+
                    rts

                    emod
eom                 equ       *
                    end
