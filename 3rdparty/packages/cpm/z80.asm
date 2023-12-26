__LOAD8             MACRO
                    ldb       ,x+
                    ENDM
__LOAD16            MACRO
                    ldb       ,x+
                    lda       ,x+
                    ENDM
__STORE8            MACRO
                    stb       ,x+
                    ENDM
__STORE16           MACRO
                    stb       ,x+
                    sta       ,x+
                    ENDM
_LOAD8              MACRO
                    __LOAD8
                    ENDM
_STORE8             MACRO
                    __STORE8
                    ENDM
_LOAD16             MACRO
                    __LOAD16
                    ENDM
_STORE16            MACRO
                    __STORE16
                    ENDM
_FETCH              MACRO
                    lbra      _fetch
                    ENDM
__PUSH              MACRO
                    ldx       <SP
                    leax      -2,x
                    stx       <SP
                    __STORE16
                    ENDM
__POP               MACRO
                    ldx       <SP
                    __LOAD16
                    stx       <SP
                    ENDM
_PUSH               MACRO
                    __PUSH
                    ENDM
_POP                MACRO
                    __POP
                    std       \1
                    ENDM

_LDIMM8             MACRO
                    ldx       <PC
                    _LOAD8
                    stx       <PC
                    stb       \1
                    ENDM
_LDIMM16            MACRO
                    ldx       <PC
                    _LOAD16
                    stx       <PC
                    std       \1
                    ENDM

_TRAPADDR           MACRO
                    lbra      _trapaddr
                    ENDM

_emu                ldx       #$100
                    stx       <PC                 ; PC = 0x100
                    ldd       <himem
                    subd      #17*3               ; bdos bios table
                    ldb       #$00
                    std       <biostbl
                    ldx       #$0                 ; <tpastart
                    ldb       #$03
                    stb       1,x
                    sta       2,x
                    ldb       #$c3
                    stb       ,x                  ; cold start
                    clr       3,x                 ; i/o byte
                    clr       4,x                 ; default drive
                    stb       5,x                 ; call $0005
                    ldd       <biostbl
                    subd      #6
                    ldb       #$06
                    std       <SP                 ; SP = tpa's top
                    stb       6,x
                    sta       7,x                 ; bdos entry
                    leax      d,x
                    ldd       #$c3ff
                    std       ,x
                    stb       2,x
                    ldd       <biostbl
                    ldx       #$0                 ;<tpastart
                    std       <TMP0
                    leax      d,x
                    ldb       #17
@loop               pshs      b
                    lda       #$c3
                    sta       ,x
                    ldd       <TMP0
                    stb       1,x
                    sta       2,x
                    addd      #3
                    std       <TMP0
                    leax      3,x
                    puls      b
                    decb
                    bne       @loop               ; reset bdos tbl
                    ldd       #$0000
                    std       <AF
                    std       <BC
                    std       <DE
                    std       <HL
                    std       <AF_
                    std       <BC_
                    std       <DE_
                    std       <HL_
                    std       <IX
                    std       <IY
*			std		<IR
                    lda       #(ZF|PF)
                    sta       <F
                    clr       <escmode
                    clr       <dirpath
                    ldd       #$0080
                    std       <dta
                    ldd       #0
                    _PUSH
                    _FETCH

TRAP
NOP
DI
EI
HALT
_fetch              ldx       <PC
__fetch             ldb       ,x+
                    stx       <PC
                    clra
                    aslb
                    rola
                    leay      PTBL,pcr
                    ldd       d,y
                    jmp       d,y

_trapaddr           ldx       <PC
__trapaddr          cmpx      #$ffff
                    beq       @bdos
                    cmpx      <biostbl
                    bcc       @bios
                    bra       __fetch
@bdos               lbsr      _bdos
                    bra       RET
@bios               ldd       <PC
                    subd      <biostbl
                    lbsr      _bios
RET                 _POP      <PC
                    _TRAPADDR

LDAIMM              _LDIMM8   <A
                    _FETCH

LDBIMM              _LDIMM8   <B
                    _FETCH

LDCIMM              _LDIMM8   <C
                    _FETCH

LDDIMM              _LDIMM8   <D
                    _FETCH

LDEIMM              _LDIMM8   <E
                    _FETCH

LDHIMM              _LDIMM8   <H
                    _FETCH

LDLIMM              _LDIMM8   <L
                    _FETCH

LDBCIMM             ldx       <PC
                    _LOAD16
                    stx       <PC
                    std       <BC
                    _FETCH

LDDEIMM             ldx       <PC
                    _LOAD16
                    stx       <PC
                    std       <DE
                    _FETCH

LDHLIMM             ldx       <PC
                    _LOAD16
                    stx       <PC
                    std       <HL
                    _FETCH

LDSPIMM             ldx       <PC
                    _LOAD16
                    stx       <PC
                    std       <SP
                    _FETCH

CALLIMM             ldx       <PC
                    _LOAD16
                    std       <PC
                    tfr       x,d
                    _PUSH
                    _TRAPADDR

JMPIMM              ldx       <PC
                    _LOAD16
                    std       <PC
                    _TRAPADDR

PUSHAF              ldd       <AF
                    _PUSH
                    _FETCH

PUSHBC              ldd       <BC
                    _PUSH
                    _FETCH

PUSHDE              ldd       <DE
                    _PUSH
                    _FETCH

PUSHHL              ldd       <HL
                    _PUSH
                    _FETCH

POPAF               _POP      <AF
                    _FETCH

POPBC               _POP      <BC
                    _FETCH

POPDE               _POP      <DE
                    _FETCH

POPHL               _POP      <HL
                    _FETCH

_or                 ora       <A
                    tfr       cc,b
                    sta       <A
                    leay      PARTBL,pcr
                    lda       a,y                 ; get parity
                    sta       <TMP1
                    lda       <F
                    anda      #~(SF|ZF|HF|PF|NF|CF)
                    andb      #~(M_CF|M_HF)
                    leay      FLAGTBL,pcr
                    ora       b,y
                    ora       <TMP1
                    sta       <F
                    _FETCH

_OR                 MACRO
                    lda       \1
                    bra       _or
                    ENDM

ORA                 _OR       <A
ORB                 _OR       <B
ORC                 _OR       <C
ORD                 _OR       <D
ORE                 _OR       <E
ORH                 _OR       <H
ORL                 _OR       <L

ORIMM               _LDIMM8   <TMP0
                    _OR       <TMP0

_LD8_M              MACRO
                    ldx       \2
                    __LOAD8
                    stb       \1
                    ENDM

OR_HL               _LD8_M    <TMP0,<HL
                    _OR       <TMP0

_LD8                MACRO
                    ldb       \2
                    stb       \1
                    ENDM

_LD16               MACRO
                    ldd       \2
                    std       \1
                    ENDM

LDA_DE              _LD8_M    <A,<DE
                    _FETCH
LDA_BC              _LD8_M    <A,<BC
                    _FETCH

_ldm                __LOAD16
                    stx       <PC
                    tfr       d,x
                    rts

LDA_M               bsr       _ldm
                    _LOAD8
                    stb       <A
                    _FETCH

LDM_A               bsr       _ldm
                    ldb       <A
                    _STORE8
                    _FETCH

LDHL_M              bsr       _ldm
                    _LOAD16
                    std       <HL
                    _FETCH

LDM_HL              bsr       _ldm
                    ldd       <HL
                    _STORE16
                    _FETCH

LDSPHL              _LD16     <SP,<HL
                    _FETCH

_ST8_M              MACRO
                    ldb       \2
                    ldx       \1
                    _STORE8
                    ENDM

LDBC_A              _ST8_M    <BC,<A
                    _FETCH
LDDE_A              _ST8_M    <DE,<A
                    _FETCH

LDHL_A              _ST8_M    <HL,<A
                    _FETCH
LDHL_B              _ST8_M    <HL,<B
                    _FETCH
LDHL_C              _ST8_M    <HL,<C
                    _FETCH
LDHL_D              _ST8_M    <HL,<D
                    _FETCH
LDHL_E              _ST8_M    <HL,<E
                    _FETCH
LDHL_H              _ST8_M    <HL,<H
                    _FETCH
LDHL_L              _ST8_M    <HL,<L
                    _FETCH

LDHL_IMM8           ldx       <PC
                    _LOAD8
                    stx       <PC
                    ldx       <HL
                    _STORE8
                    _FETCH

EXDEHL              ldx       <DE
                    ldy       <HL
                    stx       <HL
                    sty       <DE
                    _FETCH

EXSP_HL             ldx       <SP
                    _LOAD16
                    ldy       <HL
                    std       <HL
                    leax      -2,x
                    tfr       y,d
                    _STORE16
                    _FETCH


_adc16              ldb       <F
                    andcc     #~M_CF
                    bitb      #1
                    beq       @CFc
                    orcc      #M_CF
@CFc                ldd       ,y
                    adcb      <L
                    adca      <H
                    std       <HL
                    tfr       cc,b
                    bra       _addflag
ADCHLBC             leay      <BC,u
                    bra       _adc16
ADCHLDE             leay      <DE,u
                    bra       _adc16
ADCHLHL             leay      <HL,u
                    bra       _adc16
ADCHLSP             leay      <SP,u
                    bra       _adc16


_add8               adda      <A
                    tfr       cc,b
                    sta       <A
_addflag            lda       <F
                    anda      #~(SF|ZF|HF|PF|NF|CF)
                    leay      FLAGTBL,pcr
                    ora       b,y
                    sta       <F
                    _FETCH

_ADD8               MACRO
                    lda       \1
                    bra       _add8
                    ENDM

ADDAA               _ADD8     <A
ADDAB               _ADD8     <B
ADDAC               _ADD8     <C
ADDAD               _ADD8     <D

ADDAE               _ADD8     <E
ADDAH               _ADD8     <H
ADDAL               _ADD8     <L

ADDA_HL             _LD8_M    <TMP0,<HL
                    _ADD8     <TMP0

ADDAIMM             _LDIMM8   <TMP0
                    _ADD8     <TMP0

_adc8               ldb       <F
                    andcc     #~M_CF
                    bitb      #1
                    beq       @CFc
                    orcc      #M_CF
@CFc                adca      <A
                    sta       <A
                    tfr       cc,b
                    bra       _addflag

_ADC8               MACRO
                    lda       \1
                    bra       _adc8
                    ENDM

ADCAA               _ADC8     <A
ADCAB               _ADC8     <B
ADCAC               _ADC8     <C
ADCAD               _ADC8     <D
ADCAE               _ADC8     <E
ADCAH               _ADC8     <H
ADCAL               _ADC8     <L

ADCA_HL             _LD8_M    <TMP0,<HL
                    _ADC8     <TMP0

ADCAIMM             _LDIMM8   <TMP0
                    _ADC8     <TMP0


_sbc16              ldb       <F
                    andcc     #~M_CF
                    bitb      #1
                    beq       @CFc
                    orcc      #M_CF
@CFc                ldd       <HL
                    sbcb      1,y
                    sbca      ,y
                    std       <HL
                    tfr       cc,b
                    bra       _subflag
SBCHLBC             leay      <BC,u
                    bra       _sbc16
SBCHLDE             leay      <DE,u
                    bra       _sbc16
SBCHLHL             leay      <HL,u
                    bra       _sbc16
SBCHLSP             leay      <SP,u
                    bra       _sbc16

_sub8               tfr       cc,b
                    sta       <A
_subflag            lda       <F
                    anda      #~(SF|ZF|HF|PF|CF|NF)
                    ora       #NF
                    andb      #~(M_HF)
                    leay      FLAGTBL,pcr
                    ora       b,y
                    sta       <F
                    _FETCH

_SUB8               MACRO
                    lda       <A
                    suba      \1
                    bra       _sub8
                    ENDM

SUBA                _SUB8     <A
SUBB                _SUB8     <B
SUBC                _SUB8     <C
SUBD                _SUB8     <D
SUBE                _SUB8     <E
SUBH                _SUB8     <H
SUBL                _SUB8     <L

SUB_HL              _LD8_M    <TMP0,<HL
                    _SUB8     <TMP0

SUBIMM              _LDIMM8   <TMP0
                    _SUB8     <TMP0


_SBC8               MACRO
                    ldd       <AF
                    andcc     #~M_CF
                    bitb      #1
                    beq       @CFc
                    orcc      #M_CF
@CFc                sbca      \1
                    bra       _sbc8
                    ENDM

SBCIMM              _LDIMM8   <TMP0
                    _SBC8     <TMP0

_sbc8               tfr       cc,b
                    sta       <A
                    bra       _subflag

SBCA                _SBC8     <A
SBCB                _SBC8     <B

SBCC                _SBC8     <C
SBCD                _SBC8     <D

SBCE                _SBC8     <E
SBCH                _SBC8     <H
SBCL                _SBC8     <L

SBC_HL              _LD8_M    <TMP0,<HL
                    _SBC8     <TMP0

_addhl              addd      <HL
                    std       <HL
                    tfr       cc,a
                    ldb       <F
                    andb      #~(HF|NF|CF)
                    bita      #%00100000
                    beq       @nHF
                    orb       #HF
@nHF                bita      #%00000001
                    beq       @nCF
                    orb       #CF
@nCF                stb       <F
                    _FETCH

_ADDHL              MACRO
                    lda       \1
                    ldb       \2
                    bra       _addhl
                    ENDM

ADDHLBC             _ADDHL    <B,<C
ADDHLDE             _ADDHL    <D,<E
ADDHLHL             _ADDHL    <H,<L
ADDHLSP             _ADDHL    <SPH,<SPL

_inc8               tfr       cc,b
                    lda       <F
                    anda      #~(SF|ZF|HF|PF|NF)
                    andb      #~(M_CF|M_HF)
                    leay      FLAGTBL,pcr
                    ora       b,y
                    sta       <F
                    rts

_INC8               MACRO
                    inc       \1
                    bsr       _inc8
                    ENDM

INCA                _INC8     <A
                    _FETCH
INCB                _INC8     <B
                    _FETCH
INCC                _INC8     <C
                    _FETCH
INCD                _INC8     <D
                    _FETCH
INCE                _INC8     <E
                    _FETCH
INCH                _INC8     <H
                    _FETCH
INCL                _INC8     <L
                    _FETCH

INC_HL              _LD8_M    <TMP0,<HL
                    _INC8     <TMP0
                    ldx       <HL
                    ldb       <TMP0
                    _STORE8
                    _FETCH

_dec8               tfr       cc,b
                    lda       <F
                    anda      #~(SF|ZF|HF|PF|NF)
                    ora       #NF
                    andb      #~(M_CF|M_HF)
                    leay      FLAGTBL,pcr
                    ora       b,y
                    sta       <F
                    rts


_DEC8               MACRO
                    dec       \1
                    bsr       _dec8
                    ENDM


DECA                _DEC8     <A
                    _FETCH
DECB                _DEC8     <B
                    _FETCH
DECC                _DEC8     <C
                    _FETCH
DECD                _DEC8     <D
                    _FETCH
DECE                _DEC8     <E
                    _FETCH
DECH                _DEC8     <H
                    _FETCH
DECL                _DEC8     <L
                    _FETCH

DEC_HL              _LD8_M    <TMP0,<HL
                    _DEC8     <TMP0
                    ldx       <HL
                    ldb       <TMP0
                    _STORE8
                    _FETCH

INCBC               ldx       <BC
                    leax      1,x
                    stx       <BC
                    _FETCH
INCDE               ldx       <DE
                    leax      1,x
                    stx       <DE
                    _FETCH
INCHL               ldx       <HL
                    leax      1,x
                    stx       <HL
                    _FETCH
INCSP               ldx       <SP
                    leax      1,x
                    stx       <SP
                    _FETCH
DECBC               ldx       <BC
                    leax      -1,x
                    stx       <BC
                    _FETCH
DECDE               ldx       <DE
                    leax      -1,x
                    stx       <DE
                    _FETCH
DECHL               ldx       <HL
                    leax      -1,x
                    stx       <HL
                    _FETCH
DECSP               ldx       <SP
                    leax      -1,x
                    stx       <SP
                    _FETCH


_and                tfr       cc,b
                    sta       <A
                    leay      PARTBL,pcr
                    lda       a,y                 ; get parity
                    sta       <TMP1
                    lda       <F
                    anda      #~(SF|ZF|HF|PF|NF|CF)
                    ora       #HF
                    andb      #~(M_CF|M_NF|M_HF)
                    leay      FLAGTBL,pcr
                    ora       b,y
                    ora       <TMP1               ; parity
                    sta       <F
                    _FETCH

_AND                MACRO
                    lda       <A
                    anda      \1
                    bra       _and
                    ENDM

ANDA                _AND      <A
ANDB                _AND      <B
ANDC                _AND      <C
ANDD                _AND      <D
ANDE                _AND      <E
ANDH                _AND      <H
ANDL                _AND      <L

ANDIMM              _LDIMM8   <TMP0
                    _AND      <TMP0

AND_HL              _LD8_M    <TMP0,<HL
                    _AND      <TMP0

_xor                tfr       cc,b
                    sta       <A
                    leay      PARTBL,pcr
                    lda       a,y                 ; get parity
                    sta       <TMP1
                    lda       <F
                    anda      #~(SF|ZF|HF|PF|NF|CF)
                    ora       <TMP1               ; parity flag
                    leay      FLAGTBL,pcr
                    andb      #~(M_VF|M_CF|M_HF)
                    ora       b,y
                    ora       <TMP1
                    sta       <F
                    _FETCH

_XOR                MACRO
                    lda       <A
                    eora      \1
                    bra       _xor
                    ENDM

XORA                _XOR      <A
XORB                _XOR      <B
XORC                _XOR      <C
XORD                _XOR      <D
XORE                _XOR      <E
XORH                _XOR      <H
XORL                _XOR      <L

XORIMM              _LDIMM8   <TMP0
                    _XOR      <TMP0

XOR_HL              _LD8_M    <TMP0,<HL
                    _XOR      <TMP0

DAA                 ldd       <AF
                    andcc     #~(M_HF|M_CF)
                    bitb      #HF
                    beq       @nMHF
                    orcc      #M_HF
@nMHF
                    bitb      #CF
                    beq       @nMCF
                    orcc      #M_CF
@nMCF
                    daa
                    pshs      cc
                    sta       <A
                    leay      PARTBL,pcr
                    lda       a,y                 ; get parity
                    sta       <TMP1
                    puls      a
                    andb      #~(SF|ZF|HF|PF|CF)
                    orb       <TMP1               ; parity flag
                    bita      #%00001000
                    beq       @nSF
                    orb       #SF
@nSF                bita      #%00000100
                    beq       @nZF
                    orb       #ZF
@nZF                bita      #%00000001
                    beq       @nCF
                    orb       #CF
@nCF                stb       <F
                    _FETCH

CPL                 ldd       <AF
                    coma
                    orb       #(HF|NF)
                    std       <AF
                    _FETCH

SCF                 ldb       <F
                    andb      #~(NF|HF)
                    orb       #CF
                    stb       <F
                    _FETCH

CCF                 ldb       <F
                    tfr       b,a
                    andb      #~(CF|NF|HF)
                    stb       <F
                    anda      #CF
                    beq       @zero
                    orb       #HF
                    stb       <F
@zero               coma
                    anda      #CF
                    ora       <F
                    sta       <F
                    _FETCH



RLCA                leay      <A,u
_rcl                lda       ,y
                    rola
                    tfr       cc,b
                    lda       ,y
                    rola
                    sta       ,y
                    lda       <F
                    anda      #~(CF|HF|NF)
                    andb      #M_CF
                    leay      FLAGTBL,pcr
                    ora       b,y
                    sta       <F
                    _FETCH

RRCA                leay      <A,u
_rrc                lda       ,y
                    rora
                    tfr       cc,b
                    lda       ,y
                    rora
_rrc2               sta       ,y
                    lda       <F
                    anda      #~(CF|HF|NF)
                    andb      #M_CF
                    leay      FLAGTBL,pcr
                    ora       b,y
                    sta       <F
                    _FETCH

RLA                 leay      <A,u
_rl                 lda       ,y
                    ldb       <F
                    andcc     #~M_CF
                    bitb      #CF
                    beq       @CFc
                    orcc      #M_CF
@CFc                rola
                    tfr       cc,b
                    bra       _rrc2

RRA                 leay      <A,u
_rr                 lda       ,y
                    ldb       <F
                    andcc     #~M_CF
                    bitb      #CF
                    beq       @CFc
                    orcc      #M_CF
@CFc                rora
                    tfr       cc,b
                    bra       _rrc2

__cp8               tfr       cc,b
                    lda       <F
                    anda      #~(SF|ZF|HF|PF|CF|NF)
                    ora       #NF
                    andb      #~(M_HF)
                    leay      FLAGTBL,pcr
                    ora       b,y                 ; get flags
                    sta       <F
                    rts

_cp8                bsr       __cp8
                    _FETCH

_CP8                MACRO
                    lda       <A
                    suba      \1
                    bra       _cp8
                    ENDM

CPA                 _CP8      <A
CPB                 _CP8      <B
CPC                 _CP8      <C
CPD                 _CP8      <D
CPE                 _CP8      <E
CPH                 _CP8      <H
CMPL                _CP8      <L

CP_HL               _LD8_M    <TMP0,<HL
                    _CP8      <TMP0

CPIMM               _LDIMM8   <TMP0
                    _CP8      <TMP0

DJNZ                __LOAD8
                    stx       <PC
                    dec       <B
                    bne       @jmp
                    _FETCH
@jmp                leax      b,x
                    stx       <PC
                    _TRAPADDR


_jmp                __LOAD16
                    std       <PC
                    _TRAPADDR
_nojmp              leax      2,x
                    stx       <PC
                    _FETCH

JPNZ                lda       <F
                    bita      #ZF
                    bne       _nojmp
                    bra       _jmp

JPZ                 lda       <F
                    bita      #ZF
                    beq       _nojmp
                    bra       _jmp

JPNC                lda       <F
                    bita      #CF
                    bne       _nojmp
                    bra       _jmp

JPC                 lda       <F
                    bita      #CF
                    beq       _nojmp
                    bra       _jmp

JPPO                lda       <F
                    bita      #PF
                    bne       _nojmp
                    bra       _jmp

JPPE                lda       <F
                    bita      #PF
                    beq       _nojmp
                    bra       _jmp

JPM                 lda       <F
                    bita      #SF
                    beq       _nojmp
                    bra       _jmp

JPP                 lda       <F
                    bita      #SF
                    bne       _nojmp
                    bra       _jmp

JP_HL               ldx       <HL
                    stx       <PC
                    _TRAPADDR


_call               _LOAD16
                    std       <PC
                    tfr       x,d
                    _PUSH
                    _TRAPADDR
_nocall             leax      2,x
                    stx       <PC
                    _FETCH


CALLNZ              lda       <F
                    bita      #ZF
                    bne       _nocall
                    bra       _call

CALLZ               lda       <F
                    bita      #ZF
                    beq       _nocall
                    bra       _call


CALLNC              lda       <F
                    bita      #CF
                    bne       _nocall
                    bra       _call

CALLC               lda       <F
                    bita      #CF
                    beq       _nocall
                    bra       _call

CALLPO              lda       <F
                    bita      #PF
                    bne       _nocall
                    bra       _call

CALLPE              lda       <F
                    bita      #PF
                    beq       _nocall
                    bra       _call


CALLM               lda       <F
                    bita      #SF
                    beq       _nocall
                    bra       _call


CALLP               lda       <F
                    bita      #SF
                    bne       _nocall
                    bra       _call


RETNZ               lda       <F
                    bita      #ZF
                    bne       _noret
_ret                _POP      <PC
_noret              _TRAPADDR

RETZ                lda       <F
                    bita      #ZF
                    beq       _noret
                    bra       _ret

RETNC               lda       <F
                    bita      #CF
                    bne       _noret
                    bra       _ret

RETC                lda       <F
                    bita      #CF
                    beq       _noret
                    bra       _ret

RETPO               lda       <F
                    bita      #PF
                    bne       _noret
                    bra       _ret

RETPE               lda       <F
                    bita      #PF
                    beq       _noret
                    bra       _ret

RETP                lda       <F
                    bita      #SF
                    bne       _noret
                    bra       _ret

RETM                lda       <F
                    bita      #SF
                    beq       _noret
                    bra       _ret


_RST                MACRO
                    ldx       <PC
                    _PUSH
                    ldd       \1
                    std       <PC
                    ENDM

RST0                _RST      $0
                    _FETCH

RST8                _RST      $8
                    _FETCH

RST10               _RST      $10
                    _FETCH

RST18               _RST      $18
                    _FETCH

RST20               _RST      $20
                    _FETCH

RST28               _RST      $28
                    _FETCH

RST30               _RST      $30
                    _FETCH

RST38               _RST      $38
                    _FETCH

EDGROUP             _LOAD8
                    stx       <PC
                    cmpb      #$4D
                    lbeq      RET
                    cmpb      #$45
                    lbeq      RET
                    cmpb      #$A1
                    lbeq      CPI
                    cmpb      #$B1
                    lbeq      CPIR
                    cmpb      #$A9
                    lbeq      _CPD1
                    cmpb      #$B9
                    lbeq      CPDR
                    cmpb      #$6F
                    lbeq      RLD
                    cmpb      #$67
                    lbeq      RRD
                    cmpb      #$44
                    lbeq      _NEG
                    cmpb      #$4A
                    lbeq      ADCHLBC
                    cmpb      #$5A
                    lbeq      ADCHLDE
                    cmpb      #$6A
                    lbeq      ADCHLHL
                    cmpb      #$7A
                    lbeq      ADCHLSP
                    cmpb      #$42
                    lbeq      SBCHLBC
                    cmpb      #$52
                    lbeq      SBCHLDE
                    cmpb      #$62
                    lbeq      SBCHLHL
                    cmpb      #$72
                    lbeq      SBCHLSP

                    cmpb      #$A0                ; LDIR
                    lbeq      LDI
                    cmpb      #$A8
                    lbeq      LDD
                    cmpb      #$B0                ; LDIR
                    lbeq      LDIR
                    cmpb      #$B8
                    lbeq      LDDR                ; LDDR
                    cmpb      #$4b
                    beq       LDBC_M
                    cmpb      #$5b
                    beq       LDDE_M
                    cmpb      #$6b
                    lbeq      LDHL_M
                    cmpb      #$7b
                    beq       LDSP_M
                    cmpb      #$43
                    beq       LDM_BC
                    cmpb      #$53
                    beq       LDM_DE
                    cmpb      #$6B
                    lbeq      LDM_HL
                    cmpb      #$73
                    beq       LDM_SP
                    lbra      TRAP


LDBC_M              leay      <BC,u
                    bra       _ldrr_m
LDDE_M              leay      <DE,u
                    bra       _ldrr_m
LDSP_M              leay      <SP,u
                    bra       _ldrr_m

_ldrr_m             lbsr      _ldm
                    _LOAD16
                    std       ,y
                    _FETCH

LDM_BC              leay      <BC,u
                    bra       _ldm_rr
LDM_DE              leay      <DE,u
                    bra       _ldm_rr
LDM_SP              leay      <SP,u
                    bra       _ldm_rr

_ldm_rr             lbsr      _ldm
                    ldd       ,y
                    _STORE16
                    _FETCH


_NEG                neg       <A
                    tfr       cc,b
                    lda       <F
                    anda      #~(SF|ZF|HF|PF|NF|CF)
                    ora       #NF
                    leay      FLAGTBL,pcr
                    ora       b,y
                    sta       <F
                    _FETCH

RRD                 lda       <A
                    ldx       <HL
                    _LOAD8
                    stb       <TMP0
                    lsl       <TMP0
                    lsl       <TMP0
                    lsl       <TMP0
                    lsl       <TMP0
                    anda      #$0F
                    ora       <TMP0
                    sta       <HL
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    lda       <A
                    anda      #$f0
                    stb       <A
                    ora       <A
                    sta       <A
                    _FETCH

RLD                 lda       <A
                    ldx       <HL
                    _LOAD8
                    stb       <TMP0
                    lsr       <TMP0
                    lsr       <TMP0
                    lsr       <TMP0
                    lsr       <TMP0
                    anda      #$0F
                    lsla
                    lsla
                    lsla
                    lsla
                    ora       <TMP0
                    sta       <HL
                    lda       <A
                    anda      #$f0
                    andb      #$0f
                    stb       <A
                    ora       <A
                    sta       <A
                    _FETCH

_cpi                ldx       <HL
                    lda       <A
                    suba      ,x
                    sta       <TMP0
                    lbsr      __cp8
                    leax      1,x
                    stx       <HL
                    lda       <F
                    ora       #PF|NF
                    ldx       <BC
                    leax      -1,x
                    stx       <BC
                    bne       @notZero
                    anda      #~PF
@notZero            sta       <F
                    rts
CPI                 bsr       _cpi
                    _FETCH
CPIR                bsr       _cpi
                    ldx       <BC
                    beq       @end
                    tst       <TMP0
                    beq       @end
                    bra       CPIR
@end                _FETCH



_cpd                ldx       <HL
                    lda       <A
                    suba      ,x
                    sta       <TMP0
                    lbsr      __cp8
                    leax      -1,x
                    stx       <HL
                    lda       <F
                    ora       #PF|NF
                    ldx       <BC
                    leax      -1,x
                    stx       <BC
                    bne       @notZero
                    anda      #~PF
@notZero            sta       <F
                    rts
_CPD1               bsr       _cpd
                    _FETCH
CPDR                bsr       _cpd
                    ldx       <BC
                    beq       @end
                    tst       <TMP0
                    beq       @end
                    bra       CPIR
@end                _FETCH




CBGROUP             _LOAD8
                    stx       <PC
                    cmpb      #$07
                    lbls      RLCR
                    cmpb      #$0F
                    lbls      RRCR
                    cmpb      #$17
                    lbls      RLR
                    cmpb      #$1F
                    lbls      RRR
                    cmpb      #$27
                    lbls      SLAR
                    cmpb      #$2F
                    lbls      SRAR
                    cmpb      #$38
                    lbcs      TRAP
                    cmpb      #$3F
                    lbls      SRLR
                    cmpb      #$7F
                    lbls      BITR
                    cmpb      #$BF
                    lbls      RESR
                    lbra      SETR





DDGROUP             leay      <IX,u
                    bra       @select
FDGROUP             leay      <IY,u
@select             _LOAD8
                    stx       <PC
                    cmpb      #$E5
                    lbeq      PUSHXX
                    cmpb      #$E1
                    lbeq      POPXX
                    cmpb      #$E9
                    lbeq      JPXX
                    cmpb      #$CB
                    lbeq      @cbgroup
                    cmpb      #$21
                    lbeq      LDXXIMM
                    cmpb      #$22
                    lbeq      _ldm_rr
                    cmpb      #$2A
                    lbeq      _ldrr_m
                    cmpb      #$A6
                    lbeq      AND_XX
                    cmpb      #$AE
                    lbeq      XOR_XX
                    cmpb      #$B6
                    lbeq      OR_XX
                    cmpb      #$BE
                    lbeq      CP_XX
                    cmpb      #$34
                    lbeq      INC_XX
                    cmpb      #$35
                    lbeq      DEC_XX
                    cmpb      #$23
                    lbeq      INCXX
                    cmpb      #$2B
                    lbeq      DECXX
                    cmpb      #$46
                    lbeq      LDB_XX
                    cmpb      #$4E
                    lbeq      LDC_XX
                    cmpb      #$56
                    lbeq      LDD_XX
                    cmpb      #$5E
                    lbeq      LDE_XX
                    cmpb      #$66
                    lbeq      LDH_XX
                    cmpb      #$6E
                    lbeq      LDL_XX
                    cmpb      #$7E
                    lbeq      LDA_XX
                    cmpb      #$70
                    lbeq      LD_XX_B
                    cmpb      #$71
                    lbeq      LD_XX_C
                    cmpb      #$72
                    lbeq      LD_XX_D
                    cmpb      #$73
                    lbeq      LD_XX_E
                    cmpb      #$74
                    lbeq      LD_XX_H
                    cmpb      #$75
                    lbeq      LD_XX_L
                    cmpb      #$36
                    lbeq      LD_XX_IMM
                    cmpb      #$77
                    lbeq      LD_XX_A
                    cmpb      #$F9
                    lbeq      LDSPXX
                    cmpb      #$E3
                    lbeq      EXSP_XX
                    cmpb      #$86
                    lbeq      ADDA_XX
                    cmpb      #$8E
                    lbeq      ADCA_XX
                    cmpb      #$96
                    lbeq      SUBA_XX
                    cmpb      #$9E
                    lbeq      SBCA_XX
                    cmpb      #$09
                    lbeq      ADDXXBC
                    cmpb      #$19
                    lbeq      ADDXXDE
                    cmpb      #$29
                    lbeq      ADDXXXX
                    cmpb      #$39
                    lbeq      ADDXXSP
                    lbra      TRAP
@cbgroup            ldy       ,y
                    _LOAD8
                    stx       <PC
                    leay      b,y
                    _LOAD8
                    stx       <PC
                    cmpb      #$26
                    lbeq      SLAXX
                    cmpb      #$2E
                    lbeq      SRAXX
                    cmpb      #$3E
                    lbeq      SRLXX
                    cmpb      #$7E
                    lbls      BITXX
                    cmpb      #$BE
                    lbls      RESXX
                    cmpb      #$FE
                    lbls      SETXX
                    cmpb      #$06
                    lbeq      _rcl
                    cmpb      #$16
                    lbeq      _rl
                    cmpb      #$0E
                    lbeq      _rrc
                    cmpb      #$1E
                    lbeq      _rr
                    lbra      TRAP

LDXXIMM             _LOAD16
                    stx       <PC
                    std       ,y
                    _FETCH
_ldr_xx             ldy       ,y
                    _LOAD8
                    stx       <PC
                    lda       b,y
                    rts
LDA_XX              bsr       _ldr_xx
                    sta       <A
                    _FETCH
LDB_XX              bsr       _ldr_xx
                    sta       <B
                    _FETCH
LDC_XX              bsr       _ldr_xx
                    sta       <C
                    _FETCH
LDD_XX              bsr       _ldr_xx
                    sta       <D
                    _FETCH
LDE_XX              bsr       _ldr_xx
                    sta       <E
                    _FETCH
LDH_XX              bsr       _ldr_xx
                    sta       <H
                    _FETCH
LDL_XX              bsr       _ldr_xx
                    sta       <L
                    _FETCH
_ld_xx_r            ldy       ,y
                    _LOAD8
                    stx       <PC
                    sta       b,y
                    _FETCH
LD_XX_B             lda       <B
                    bra       _ld_xx_r
LD_XX_C             lda       <C
                    bra       _ld_xx_r
LD_XX_D             lda       <D
                    bra       _ld_xx_r
LD_XX_E             lda       <E
                    bra       _ld_xx_r
LD_XX_H             lda       <H
                    bra       _ld_xx_r
LD_XX_L             lda       <L
                    bra       _ld_xx_r
LD_XX_A             lda       <A
                    bra       _ld_xx_r
LD_XX_IMM           ldy       ,y
                    _LOAD16
                    stx       <PC
                    sta       b,y
                    _FETCH
LDSPXX              ldd       ,y
                    std       <SP
                    _FETCH
EXSP_XX             ldx       <SP
                    _LOAD16
                    pshs      u
                    ldu       ,y
                    std       ,y
                    leax      -2,x
                    tfr       u,d
                    puls      u
                    _STORE16
                    _FETCH

_ld_xx              ldy       ,y
                    _LOAD8
                    stx       <PC
                    rts

_lda_xx             bsr       _ld_xx
                    lda       b,y
                    rts

ADDA_XX             bsr       _lda_xx
                    lbra      _add8

ADCA_XX             bsr       _lda_xx
                    lbra      _adc8

SUBA_XX             bsr       _ld_xx
                    lda       <A
                    suba      b,y
                    lbra      _sub8

SBCA_XX             ldd       <AF
                    andcc     #~M_CF
                    bitb      #1
                    beq       @CFc
                    orcc      #M_CF
@CFc                bsr       _ld_xx
                    sbca      b,y
                    lbra      _sbc8

_addxx              addd      ,y
                    std       ,y
                    tfr       cc,a
                    ldb       <F
                    andb      #~(HF|NF|CF)
                    bita      #%00100000
                    beq       @nHF
                    orb       #HF
@nHF                bita      #%00000001
                    beq       @nCF
                    orb       #CF
@nCF                stb       <F
                    _FETCH
_ADDXX              MACRO
                    ldd       \1
                    bra       _addxx
                    ENDM
ADDXXBC             _ADDXX    <BC
ADDXXDE             _ADDXX    <DE
ADDXXHL             _ADDXX    <HL
ADDXXSP             _ADDXX    <SP
ADDXXXX             ldd       ,y
                    bra       _addxx

INC_XX              lbsr      _ld_xx
                    inc       b,y
                    lbsr      _inc8
                    _FETCH

DEC_XX              lbsr      _ld_xx
                    inc       b,y
                    lbsr      _dec8
                    _FETCH

AND_XX              lbsr      _ld_xx
                    lda       <A
                    anda      b,y
                    lbra      _and

XOR_XX              lbsr      _ld_xx
                    lda       <A
                    eora      b,y
                    lbra      _xor

OR_XX               lbsr      _ld_xx
                    lda       b,y
                    lbra      _or

CP_XX               lbsr      _ld_xx
                    lda       <A
                    suba      b,y
                    lbra      _cp8

JPXX                ldd       ,y
                    std       <PC
                    _TRAPADDR

PUSHXX              ldd       ,y
                    _PUSH
                    _FETCH

POPXX               __POP
                    std       ,y
                    _FETCH


INCXX               ldd       ,y
                    addd      #1
                    std       ,y
                    _FETCH

DECXX               ldd       ,y
                    subd      #1
                    std       ,y
                    _FETCH


EXAF                ldd       <AF
                    ldx       <AF_
                    std       <AF_
                    stx       <AF
                    _FETCH

EXX                 ldd       <BC
                    ldx       <BC_
                    std       <BC_
                    stx       <BC
                    ldd       <DE
                    ldx       <DE_
                    std       <DE_
                    stx       <DE
                    ldd       <HL
                    ldx       <HL_
                    std       <HL_
                    stx       <HL
                    _FETCH

JR                  _LOAD8
                    leax      b,x
                    stx       <PC
                    _TRAPADDR


JRNZ                _LOAD8
                    lda       <F
                    bita      #ZF
                    bne       _nojr
_jr                 leax      b,x
                    stx       <PC
                    _TRAPADDR
_nojr               stx       <PC
                    _FETCH

JRZ                 _LOAD8
                    lda       <F
                    bita      #ZF
                    beq       _nojr
                    bra       _jr

JRNC                _LOAD8
                    lda       <F
                    bita      #CF
                    bne       _nojr
                    bra       _jr

JRC                 _LOAD8
                    lda       <F
                    bita      #CF
                    beq       _nojr
                    bra       _jr


_ldi                ldx       <HL
                    ldy       <DE
                    lda       ,x+
                    sta       ,y
                    stx       <HL
                    leay      1,y
                    sty       <DE
                    lda       <F
                    anda      #~(HF|NF)
                    ora       #PF
                    ldx       <BC
                    leax      -1,x
                    stx       <BC
                    bne       @notZero
                    anda      #~PF
@notZero            sta       <F
                    rts
LDI                 bsr       _ldi
                    _FETCH
LDIR                bsr       _ldi
                    ldx       <BC
                    bne       LDIR
                    _FETCH


_ldd                ldx       <HL
                    ldy       <DE
                    lda       ,x
                    sta       ,y
                    leax      -1,x
                    stx       <HL
                    leay      -1,y
                    sty       <DE
                    lda       <F
                    anda      #~(HF|NF)
                    ora       #PF
                    ldx       <BC
                    leax      -1,x
                    stx       <BC
                    bne       @notZero
                    anda      #~PF
@notZero            sta       <F
                    rts
LDD                 bsr       _ldd
                    _FETCH
LDDR                bsr       _ldd
                    ldx       <BC
                    bne       LDDR
                    _FETCH

RLCR                lbsr      _CBr
                    lbra      _rcl
RLR                 bsr       _CBr
                    lbra      _rl
RRCR                bsr       _CBr
                    lbra      _rrc
RRR                 bsr       _CBr
                    lbra      _rr



BITR
                    bsr       _CBr
BITXX               lbsr      _getBIT
                    bita      ,y
                    tfr       cc,b
                    lda       <F
                    anda      #~(ZF|NF)
                    ora       #HF
                    andb      #~(M_NF)
                    leay      FLAGTBL,pcr
                    ora       b,y
                    sta       <F
                    _FETCH


LDRR                ldb       ,-x
                    bsr       _CBr
                    lda       ,y
                    cmpb      #$48
                    bcc       @notB
                    sta       <B
                    _FETCH
@notB               cmpb      #$50
                    bcc       @notC
                    sta       <C
                    _FETCH
@notC               cmpb      #$58
                    bcc       @notD
                    sta       <D
                    _FETCH
@notD               cmpb      #$60
                    bcc       @notE
                    sta       <E
                    _FETCH
@notE               cmpb      #$68
                    bcc       @notH
                    sta       <H
                    _FETCH
@notH               cmpb      #$70
                    bcc       @notL
                    sta       <L
                    _FETCH
@notL               cmpb      #$78
                    bcc       @notHL
                    ldy       <HL
                    sta       ,y
                    _FETCH
@notHL              sta       <A
                    _FETCH




_CBr                tfr       b,a
                    anda      #7
                    cmpa      #0
                    bne       @notB
                    leay      <B,u
                    rts
@notB               cmpa      #1
                    bne       @notC
                    leay      <C,u
                    rts
@notC               cmpa      #2
                    bne       @notD
                    leay      <D,u
                    rts
@notD               cmpa      #3
                    bne       @notE
                    leay      <E,u
                    rts
@notE               cmpa      #4
                    bne       @notH
                    leay      <H,u
                    rts
@notH               cmpa      #5
                    bne       @notL
                    leay      <L,u
                    rts
@notL               cmpa      #6
                    bne       @notHL
                    ldy       <HL
                    rts
@notHL              leay      <A,u
                    rts


_getBIT             lda       #$01
                    andb      #$38
                    beq       @bitZero
                    lsrb
                    lsrb
                    lsrb
@loop               lsla
                    decb
                    bne       @loop
@bitZero            rts


RESR                bsr       _CBr
RESXX               bsr       _getBIT
                    coma
                    anda      ,y
                    sta       ,y
                    _FETCH

SETR                bsr       _CBr
SETXX               bsr       _getBIT
                    ora       ,y
                    sta       ,y
                    _FETCH


SLAR                bsr       _CBr
SLAXX               ldb       ,y
                    lslb
_SLAR               stb       ,y
                    tfr       cc,b
                    lda       <F
                    anda      #~(ZF|SF|NF|HF|PF|CF)
                    leay      FLAGTBL,pcr
                    ora       b,y
                    sta       <F
                    _FETCH


SRAR                lbsr      _CBr
SRAXX               ldb       ,y
                    asrb
                    bra       _SLAR


SRLR                lbsr      _CBr
SRLXX               ldb       ,y
                    lsrb
                    bra       _SLAR


IN                  ldx       <PC
                    _LOAD8
                    stb       <A
                    _FETCH

OUT                 ldx       <PC
                    _LOAD8
                    _FETCH
