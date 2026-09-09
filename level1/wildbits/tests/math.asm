********************************************************************
* math - integer math block probe (JR_Math_Block, $FEE0-$FEFF)
*
* The block sits in the FIXED I/O page, so a user program reaches it
* with no MMU work at all. Everything is big endian: a 6809 std or
* ldd lands the right way round.
*
* Every check prints what came back beside what the RTL says it
* should be, so a run is a wiring verdict, not a pass/fail box.
* Each line stays under 70 columns.
*
* What is being proved, and why each case was chosen:
*   1. operand read-back  - is the block decoded at all
*   2. 2 x 3              - the multiplier is alive
*   3. FFFF x FFFF        - UNSIGNED (FFFE0001); a signed multiplier
*                           would return 00000001 instead
*   4. 1234 x 5678        - a general case, full 32-bit width
*   5. 100 / 7            - quotient 000E, remainder 0002. A remainder
*                           below 256 comes back correct even with the
*                           known RTL bug, so this isolates the divider
*   6. 512 / 1000         - quotient 0000, remainder 0200. THIS is the
*                           bug case. JR_Math_Block.v line 114 reads
*                             {m_axis_dout_tdata[15:8], tdata[8:0]}
*                           which is 8 plus NINE bits concatenated into
*                           a 16-bit wire, so the top bit falls off and
*                           everything above bit 8 shifts up one place.
*                           A remainder of 0200 therefore reads as 0400
*                           on a core with the bug, 0200 on a fixed one.
*                           The fix belongs in rc14 or later and is one
*                           character: the second slice should be [7:0]
*   7. 32-bit adder       - operand read-back, a sum, and the wrap case
*   8. write to FEF0      - the write decode keys on address bit 3 only
*                           and IGNORES bit 4, so a write to the PRODUCT
*                           address lands in multiply operand A. Proving
*                           it matters: any code that writes a result
*                           address silently destroys an operand
*   9. FEFC               - the RTL returns 00 for the top four bytes
*
* Edt/Rev  YYYY/MM/DD  Modified by
* ------------------------------------------------------------------
*   1      2026/09/09  Claude
* Created.

                    nam       math
                    ttl       integer math block probe

                    ifp1
                    use       defsfile
                    endc

MATH_TOP            equ       $FEFC               the RTL zeroes FEFC-FEFF
LBLEN               equ       14                  every label is 14 wide

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

                    org       0
got                 rmb       4
expv                rmb       4
cnt                 rmb       1
rem                 rmb       2                   the FEF6 remainder as read
line                rmb       80
stack               rmb       200
size                equ       .

name                fcs       /math/
                    fcb       edition

hexch               fcc       /0123456789ABCDEF/

t0                  fcc       /math ed.1: integer math block at FEE0/
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

lb1                 fcc       /mulA readback /
lb2                 fcc       /mulB readback /
lb3                 fcc       /2 x 3         /
lb4                 fcc       /FFFF x FFFF   /
lb5                 fcc       /1234 x 5678   /
lb6                 fcc       ;100 / 7 quot  ;
lb7                 fcc       ;100 / 7 rem   ;
lb8                 fcc       ;512 / 1000 q  ;
lb9                 fcc       ;512 / 1000 rem;
lb10                fcc       /addA readback /
lb11                fcc       /addB readback /
lb12                fcc       /add sum       /
lb13                fcc       /add wrap      /
lb14                fcc       /FEF0 write ->A/
lb15                fcc       /FEFC reads    /

v0                  fcc       /remainder: CORRECT - the RTL shift bug is gone/
                    fcb       C$CR
v0l                 equ       *-v0
v1                  fcc       /remainder: SHIFTED - JR_Math_Block.v:114 is live/
                    fcb       C$CR
v1l                 equ       *-v1
v2                  fcc       /remainder: neither 0200 nor 0400 - divider suspect/
                    fcb       C$CR
v2l                 equ       *-v2
v3                  fcc       /operands do not read back - block not responding/
                    fcb       C$CR
v3l                 equ       *-v3
v4                  fcc       /alias present: a write to a RESULT address changed/
                    fcb       C$CR
v4l                 equ       *-v4
v4b                 fcc       /an OPERAND. Never write above FEEF./
                    fcb       C$CR
v4bl                equ       *-v4b

start               leax      t0,pcr
                    ldy       #t0l
                    lbsr      PutLine
                    leax      t1,pcr
                    ldy       #t1l
                    lbsr      PutLine

* ---- 1. operand read-back: is anything home?
                    ldd       #$1234
                    std       >MATH_MUL_A
                    ldd       #$5678
                    std       >MATH_MUL_B
                    ldd       >MATH_MUL_A
                    std       <got
                    ldd       #$1234
                    std       <expv
                    leax      lb1,pcr
                    lbsr      Rpt16
                    ldd       >MATH_MUL_B
                    std       <got
                    ldd       #$5678
                    std       <expv
                    leax      lb2,pcr
                    lbsr      Rpt16
                    ldd       >MATH_MUL_A         nothing home at all?
                    cmpd      #$1234
                    beq       Mul1
                    leax      v3,pcr
                    ldy       #v3l
                    lbsr      PutLine

* ---- 2. multiply 2 x 3. The multiplier is combinational, no wait.
Mul1                ldd       #2
                    std       >MATH_MUL_A
                    ldd       #3
                    std       >MATH_MUL_B
                    lbsr      GetProd
                    ldd       #$0000
                    std       <expv
                    ldd       #$0006
                    std       <expv+2
                    leax      lb3,pcr
                    lbsr      Rpt32

* ---- 3. FFFF x FFFF: FFFE0001 unsigned, 00000001 if signed
                    ldd       #$FFFF
                    std       >MATH_MUL_A
                    std       >MATH_MUL_B
                    lbsr      GetProd
                    ldd       #$FFFE
                    std       <expv
                    ldd       #$0001
                    std       <expv+2
                    leax      lb4,pcr
                    lbsr      Rpt32

* ---- 4. 1234 x 5678 = 06260060
                    ldd       #$1234
                    std       >MATH_MUL_A
                    ldd       #$5678
                    std       >MATH_MUL_B
                    lbsr      GetProd
                    ldd       #$0626
                    std       <expv
                    ldd       #$0060
                    std       <expv+2
                    leax      lb5,pcr
                    lbsr      Rpt32

* ---- 5. 100 / 7 = 14 remainder 2. Divisor first, then dividend.
                    ldd       #7
                    std       >MATH_DIV_SOR
                    ldd       #100
                    std       >MATH_DIV_END
                    lbsr      Settle
                    ldd       >MATH_DIV_QUOT
                    std       <got
                    ldd       #14
                    std       <expv
                    leax      lb6,pcr
                    lbsr      Rpt16
                    ldd       >MATH_DIV_REM
                    std       <got
                    ldd       #2
                    std       <expv
                    leax      lb7,pcr
                    lbsr      Rpt16

* ---- 6. 512 / 1000 = 0 remainder 512. The remainder bug case.
                    ldd       #1000
                    std       >MATH_DIV_SOR
                    ldd       #512
                    std       >MATH_DIV_END
                    lbsr      Settle
                    ldd       >MATH_DIV_QUOT
                    std       <got
                    ldd       #0
                    std       <expv
                    leax      lb8,pcr
                    lbsr      Rpt16
                    ldd       >MATH_DIV_REM
                    std       <got
                    std       <rem
                    ldd       #$0200
                    std       <expv
                    leax      lb9,pcr
                    lbsr      Rpt16
                    ldd       <rem                which core is this?
                    cmpd      #$0200
                    bne       Rem1
                    leax      v0,pcr
                    ldy       #v0l
                    bra       RemSay
Rem1                cmpd      #$0400
                    bne       Rem2
                    leax      v1,pcr
                    ldy       #v1l
                    bra       RemSay
Rem2                leax      v2,pcr
                    ldy       #v2l
RemSay              lbsr      PutLine

* ---- 7. the 32-bit adder: 12345678 + 10000001
                    ldd       #$1234
                    std       >MATH_ADD_A
                    ldd       #$5678
                    std       >MATH_ADD_A+2
                    ldd       #$1000
                    std       >MATH_ADD_B
                    ldd       #$0001
                    std       >MATH_ADD_B+2
                    ldd       >MATH_ADD_A
                    std       <got
                    ldd       >MATH_ADD_A+2
                    std       <got+2
                    ldd       #$1234
                    std       <expv
                    ldd       #$5678
                    std       <expv+2
                    leax      lb10,pcr
                    lbsr      Rpt32
                    ldd       >MATH_ADD_B
                    std       <got
                    ldd       >MATH_ADD_B+2
                    std       <got+2
                    ldd       #$1000
                    std       <expv
                    ldd       #$0001
                    std       <expv+2
                    leax      lb11,pcr
                    lbsr      Rpt32
                    ldd       >MATH_ADD_RES
                    std       <got
                    ldd       >MATH_ADD_RES+2
                    std       <got+2
                    ldd       #$2234
                    std       <expv
                    ldd       #$5679
                    std       <expv+2
                    leax      lb12,pcr
                    lbsr      Rpt32

* ---- 7b. FFFFFFFF + 1 wraps to 00000000 in 32 bits
                    ldd       #$FFFF
                    std       >MATH_ADD_A
                    std       >MATH_ADD_A+2
                    ldd       #$0000
                    std       >MATH_ADD_B
                    ldd       #$0001
                    std       >MATH_ADD_B+2
                    ldd       >MATH_ADD_RES
                    std       <got
                    ldd       >MATH_ADD_RES+2
                    std       <got+2
                    ldd       #$0000
                    std       <expv
                    std       <expv+2
                    leax      lb13,pcr
                    lbsr      Rpt32

* ---- 8. the write-decode alias. Address bit 4 is ignored on writes,
* so storing to the PRODUCT address should land in multiply operand A.
                    ldd       #$0000
                    std       >MATH_MUL_A
                    ldd       #$AAAA
                    std       >MATH_MUL_P         a RESULT address
                    ldd       >MATH_MUL_A         did it land in the operand?
                    std       <got
                    ldd       #$AAAA
                    std       <expv
                    leax      lb14,pcr
                    lbsr      Rpt16
                    ldd       <got
                    cmpd      #$AAAA
                    bne       Top1
                    leax      v4,pcr
                    ldy       #v4l
                    lbsr      PutLine
                    leax      v4b,pcr
                    ldy       #v4bl
                    lbsr      PutLine

* ---- 9. FEFC-FEFF are hardwired to zero in the read decode
Top1                ldd       >MATH_TOP
                    std       <got
                    ldd       #$0000
                    std       <expv
                    leax      lb15,pcr
                    lbsr      Rpt16

                    clrb
                    os9       F$Exit

* ---- GetProd: the 32-bit product into <got
GetProd             ldd       >MATH_MUL_P
                    std       <got
                    ldd       >MATH_MUL_P+2
                    std       <got+2
                    rts

* ---- Settle: let the pipelined AXI divider flush. Its tvalid inputs
* are tied high, so it reloads every clock; this is simply time.
Settle              pshs      x
                    ldx       #$0400
Set1                leax      -1,x
                    bne       Set1
                    puls      x,pc

* ---- Rpt16: X -> a 14-char label, got and expv hold one word each
Rpt16               ldy       #line
                    ldb       #LBLEN
                    lbsr      Copy
                    ldd       <got
                    lbsr      Hex4
                    leax      texp,pcr
                    ldb       #texpl
                    lbsr      Copy
                    ldd       <expv
                    lbsr      Hex4
                    ldd       <got
                    cmpd      <expv
                    bra       Verdict

* ---- Rpt32: the same for two words
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
