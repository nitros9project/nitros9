********************************************************************
* Shared BASIC09 statement execution handlers
*
* Used by both basic09.asm (Basic09 build) and runb_core.asm (RunB).
* Each function carries dual labels so neither file needs to rename
* any of its internal references.
*
* External symbols required (defined in each program's own file):
*   NULSTM / L0894  — simple rts return (fall-through from IF)
*   EXCERR / L0EDC  — run-time error handler entry

* ──────────────────────────────────────────────────────────────────
* GOTO / GTOSTM
* Convert I-code offset at ,x to an absolute PC and return.
* ──────────────────────────────────────────────────────────────────
GOTO
GTOSTM              ldd       ,x
                    addd      <u005E
                    tfr       d,x
                    rts

* ──────────────────────────────────────────────────────────────────
* ENDIF / L33D3 — skip ENDIF token and return
* ──────────────────────────────────────────────────────────────────
ENDIF
L33D3               leax      $01,x
                    rts

* ──────────────────────────────────────────────────────────────────
* IF / IFSTM — evaluate boolean; branch or fall through
* ──────────────────────────────────────────────────────────────────
IF
IFSTM               jsr       <u0016
                    tst       $02,y
                    beq       GOTO
                    leax      $03,x
                    ldb       ,x
                    cmpb      #$3B
                    lbne      NULSTM
                    leax      $01,x

* ──────────────────────────────────────────────────────────────────
* UNTIL / WHLSTM — WHILE/UNTIL loop condition test
* ──────────────────────────────────────────────────────────────────
UNTIL
WHLSTM              jsr       <u0016
                    tst       $02,y
                    beq       GOTO
                    leax      $03,x
                    rts

* ──────────────────────────────────────────────────────────────────
* DEG / DEGSTM — set trig mode to degrees (A=1)
* RAD / RADSTM — set trig mode to radians  (A=0)
* ──────────────────────────────────────────────────────────────────
DEG
DEGSTM              lda       #$01
                    bra       DEGR0
RAD
RADSTM              clra
DEGR0               ldu       <u0031
                    sta       1,u
                    leax      $01,x
                    rts

* ──────────────────────────────────────────────────────────────────
* TONSTM / UNK10 / L0F3F — enable trace flag
* TOFSTM / UNK11 / L0F49 — disable trace flag
* ──────────────────────────────────────────────────────────────────
TONSTM
UNK10
L0F3F               lda       <u0034
                    bita      #$01
                    bne       TOFSTM0
                    ora       #$01
                    bra       TOFSTM1
TOFSTM
UNK11
L0F49               lda       <u0034
                    bita      #$01
                    beq       TOFSTM0
                    anda      #$FE
TOFSTM1             sta       <u0034
                    ldd       <u0017
                    pshs      d
                    ldd       <u0019
                    std       <u0017
                    puls      d
                    std       <u0019
TOFSTM0             rts

* ──────────────────────────────────────────────────────────────────
* POKE / L35D2 — assign byte: POKE addr, value
* ──────────────────────────────────────────────────────────────────
POKE
L35D2               jsr       <u0016
                    ldd       $01,y
                    pshs      d
                    jsr       <u0016
                    ldb       $02,y
                    stb       [,s++]
                    rts

* ──────────────────────────────────────────────────────────────────
* GOSUB / GSBSTM — call sub-procedure
* GSBST1 / L0ADE — mid-entry used by ON..GOSUB
* ──────────────────────────────────────────────────────────────────
GOSUB
GSBSTM              ldd       ,x
                    leax      $03,x
GSBST1
L0ADE               ldy       <u0031
                    ldu       <$14,y
                    cmpu      <u004A
                    bhi       GOSUB0
                    ldb       #E$SubOvf
                    lbra      EXCERR
GOSUB0              stx       ,--u
                    stu       <$14,y
                    stu       <u0046
                    addd      <u005E
                    tfr       d,x
                    rts

* ──────────────────────────────────────────────────────────────────
* RETURN / RETSTM — return from sub-procedure
* ──────────────────────────────────────────────────────────────────
RETURN
RETSTM              ldy       <u0031
                    cmpy      <$14,y
                    bhi       RETURN0
                    ldb       #$36
                    lbra      EXCERR
RETURN0
RETST1              ldu       <$14,y
                    ldx       ,u++
                    stu       <$14,y
                    stu       <u0046
                    rts
