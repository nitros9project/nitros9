********************************************************************
* sierra - Sierra setup module (Wildbits variant)
*
* Derived from objs_lsl/sierra.asm (CoCo 3 port by Chris Iden,
* disassembly/documentation by Paul Zibaila & Robert Gault).
*
* Wildbits differences from CoCo 3:
*   - Screen: TinyVicky bitmap allocated with SS.AScrn (Wildbits API)
*   - u0047: BM0 start block# (set here; read by scrn.asm for blits)
*   - Palette: Sierra AGI 16 colors loaded via SS.DfPal (BGRX format)
*   - No GIME: L01AF, L0388 stubbed; sub659 dispatcher de-GIMED
*   - SS.DScrn enables FX_BM+FX_GRF for graphics display
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   0      2025/xx/xx  Wildbits port

*Monitor defs
COMP                equ       0
RGB                 equ       1
MONO                equ       2

* I/O path definitions
StdIn               equ       0
StdOut              equ       1
StdErr              equ       2

                    nam       sierra
                    ttl       Sierra setup module

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

                    org       0
u0000               rmb       2
u0002               rmb       1
u0003               rmb       1
u0004               rmb       2
u0006               rmb       2
u0008               rmb       1
u0009               rmb       1
u000A               rmb       1
u000B               rmb       1
u000C               rmb       1
u000D               rmb       1
u000E               rmb       1
u000F               rmb       1
u0010               rmb       1
u0011               rmb       3
u0014               rmb       2
u0016               rmb       2
u0017               rmb       4
u001C               rmb       2
u001E               rmb       4
u0022               rmb       1
u0023               rmb       1
u0024               rmb       2
u0026               rmb       2
u0028               rmb       2
u002A               rmb       2
u002C               rmb       2
u002E               rmb       16
u003E               rmb       1
u003F               rmb       2
u0041               rmb       1
u0042               rmb       1
u0043               rmb       2
u0045               rmb       1
u0046               rmb       1                   Wildbits: unused
u0047               rmb       1                   Wildbits: BM0 start block#
u0048               rmb       2
u004A               rmb       5
u004F               rmb       4
u0053               rmb       2
u0055               rmb       10
u005F               rmb       163
u0102               rmb       112
mtf173              rmb       1
scr174              rmb       1
x01076              rmb       212
u0249               rmb       1
u024A               rmb       1
u024B               rmb       1
u024C               rmb       497
u043D               rmb       245
u0532               rmb       16
u0542               rmb       15
u0551               rmb       2
u0553               rmb       1
u0554               rmb       154
                    rmb       169
int5EE              rmb       1
                    rmb       106
sub659              rmb       1
                    rmb       116
u0xxx               rmb       6281
* Wildbits picture buffer: $40-byte header + 168 rows * 160 bytes = $6940 total.
* Starts at $2000 (immediately after u0xxx which ends at $1FFF).
wb_picbuf           rmb       $6940
* MMU helper buffers moved from module text to data segment (prevent write-to-module-text crash)
mmubuf              rmb       16
gprbuf              rmb       512
dbg_char            rmb       1               debug sentinel counter (remove before release)
size                equ       .

name                fcs       /sierra/
                    fcb       edition

start               equ       *
L0014               lbra      L007D
L0017               lbra      L00DB

L001A               fcb       $00

L001B               fcc       'AGI (c) copyright 1988 SIERRA On-Line'
                    fcc       'Wildbits version by Boisy Pitre'
                    fcb       $00
Infosz              equ       *-L001B

L005C               fcc       'Usage: Sierra -Rgb -Multitasking'
                    fcb       C$CR
Usgsz               equ       *-L005C

L007D               tfr       s,d
                    subd      #$04FF
                    std       <u0000
                    bsr       L009C

L0086               lbsr      L011A

L0089               ldd       <u0000
                    beq       L00DF
                    lda       #$00
                    sta       <u0011
                    lbsr      dbg_putc
                    ldx       <u0024
                    jsr       sub659
                    rts

L009C               lda       ,x+
                    cmpa      #C$CR
                    beq       L00DA
                    cmpa      #$2D
                    bne       L009C

                    lda       ,x+
                    ora       #$20
                    cmpa      #$72
                    beq       L00C2
                    cmpa      #$6D
                    beq       L00D2

                    lda       #StdOut
                    leax      >L005C,pcr
                    ldy       #Usgsz
                    os9       I$WritLn
                    clrb
                    bra       L00DF

L00C2               pshs      x
                    lda       #StdOut
                    ldb       #SS.Montr
                    ldx       #RGB
                    os9       I$SetStt
                    puls      x
                    bra       L009C

L00D2               lda       #$01
                    sta       >L001A,pcr
                    bra       L009C

L00DA               rts

agi_exit
L00DB               lbsr      L0133

L00DE               clrb
L00DF               os9       F$Exit

L00E2               fdb       $000C

* CoCo 3 palette bytes (unused on Wildbits; kept for reference)
L00E4               fcb       $02,$2E,$06,$09,$04,$20,$10,$1B
                    fcb       $11,$3D,$17,$29,$33,$3F,$00,$08
                    fcb       $14,$18,$20,$28,$22,$38,$07,$0B
                    fcb       $16,$1F,$27,$2D,$37,$3F

* Sierra AGI 16-color palette in Vicky CLUT BGRX format (4 bytes/entry)
* AGI color order: Black, Blue, Green, Cyan, Red, Magenta, Brown,
*   LtGray, DkGray, LtBlue, LtGreen, LtCyan, LtRed, LtMagenta,
*   Yellow, White
wb_agi_clut
                    fcb       $00,$00,$00,$00      0: Black
                    fcb       $AA,$00,$00,$00      1: Blue
                    fcb       $00,$AA,$00,$00      2: Green
                    fcb       $AA,$AA,$00,$00      3: Cyan
                    fcb       $00,$00,$AA,$00      4: Red
                    fcb       $AA,$00,$AA,$00      5: Magenta
                    fcb       $00,$55,$AA,$00      6: Brown
                    fcb       $AA,$AA,$AA,$00      7: LtGray
                    fcb       $55,$55,$55,$00      8: DkGray
                    fcb       $FF,$55,$55,$00      9: LtBlue
                    fcb       $55,$FF,$55,$00      10: LtGreen
                    fcb       $FF,$FF,$55,$00      11: LtCyan
                    fcb       $55,$55,$FF,$00      12: LtRed
                    fcb       $FF,$55,$FF,$00      13: LtMagenta
                    fcb       $55,$FF,$FF,$00      14: Yellow
                    fcb       $FF,$FF,$FF,$00      15: White
wb_agi_clut_sz      equ       *-wb_agi_clut        64 bytes

L0102               fdb       $0000
L0104               fdb       $0000

L0106               fcc       'Shdw'
                    fcb       C$CR

L010B               fcc       'Scrn'
                    fcb       C$CR

L0110               fcc       'MnLn'
                    fcb       C$CR

L0115               fcb       $00
L0116               fcb       $00
L0117               fcb       $00
L0118               fcb       $00
L0119               fcb       $00

L011A               lbsr      L0140
                    lda       #'A'
                    sta       >dbg_char
                    lbsr      dbg_putc
* mmuini1 reads system MMU block values - works on Wildbits via F$GPrDsc
                    lbsr      mmuini1
                    lbsr      dbg_putc
* L01AF: stubbed on Wildbits (no GIME twiddles needed)
                    lbsr      L01AF
                    lbsr      dbg_putc
L0120               lbsr      L01FA
                    lbsr      dbg_putc

                    lbsr      L0419
                    bcs       L0139
                    lbsr      dbg_putc

                    lbsr      L0229
                    bcs       L0136
                    lbsr      dbg_putc

                    lbsr      L026B
                    bcs       L0133
                    lbsr      dbg_putc
                    rts

agi_shutdown
L0133               lbsr      L0336
L0136               lbsr      L0370
L0139               lbsr      L04BD
                    lbsr      L0388
                    rts

L0140               ldx       #$0002
                    ldd       #$0000
L0146               std       ,x++
                    cmpx      <u0000
                    bcs       L0146

                    lda       >L001A,pcr
                    sta       mtf173

                    ldd       #$0776
                    std       <u0053
                    std       <u0055

                    lda       #$5C
                    sta       >$0101

                    lda       #$17
                    sta       >$01D7

                    lda       #$0F
                    sta       >$023E

                    ldd       #$0000
                    std       <u004F

                    lda       #StdOut
                    ldb       #SS.Montr
                    os9       I$GetStt
                    tfr       x,d
                    stb       >L0119,pcr
                    andb      #$01
                    stb       >$0553

                    ldx       #RGB
                    lda       #StdOut
                    ldb       #SS.Montr
                    os9       I$SetStt

                    lda       #$32
                    sta       >$0245

* Wildbits: clear u0046/u0047; BM0 block# will be set in L026B by SS.AScrn
                    clr       <u0046
                    clr       <u0047

                    lda       #$15
                    sta       >$0247

                    lda       #$FF
                    sta       $05EE
                    ldb       #$10
                    ldx       #$0531

L01A3               sta       ,x+
                    decb
                    bne       L01A3
                    rts

*--------------------------------------------------------------------
* L01AF - stub: just initialize DBlk8K pointer.
* All CoCo3 GIME/MMU twiddles removed for Wildbits.
*--------------------------------------------------------------------
L01AF               orcc      #IntMasks
* Wildbits: init DBlk8K to scratch area (no GIME bank switching)
                    ldd       #u0xxx
                    std       <u0043
                    andcc     #^IntMasks
                    rts

L01FA               leax      L054F,pcr
                    pshs      x
                    leax      L04DA,pcr
                    ldu       #sub659
L0209               lda       ,x+
                    sta       ,u+
                    cmpx      ,s
                    blo       L0209

                    leax      >L04BD,pcr
                    stx       ,s
                    leax      >L0452,pcr
                    ldu       #int5EE
L021E               lda       ,x+
                    sta       ,u+
                    cmpx      ,s
                    blo       L021E
                    puls      x,pc

L0229               tfr       b,a
                    incb
                    std       <u001C

                    addd      #$0202
                    std       <u001E

                    addd      #$0202
                    sta       <u005F
                    std       <u000C
                    std       <u000E

* Wildbits: store sierra's own entry address so mnln can dispatch back into sierra
                    leax      start,pcr
                    stx       <u0022

                    ldu       #$001A
                    stu       <u0028
                    leax      >L0106,pcr
                    lbsr      L03D0
                    bcs       L026A
                    lbsr      dbg_putc

                    ldu       #$0012
                    stu       <u0026
                    leax      >L010B,pcr
                    lbsr      L03D0
                    bcs       L026A
                    lbsr      dbg_putc

                    ldu       #$000A
                    stu       <u0024
                    leax      >L0110,pcr
                    lbsr      L03D0
                    bcs       L026A

* Wildbits: u002E = mnln's actual entry address (stored at handle $000A by L03D0)
                    ldd       <u000A
                    std       <u002E
                    lbsr      dbg_putc
L026A               rts

*--------------------------------------------------------------------
* L026B - Wildbits screen setup.
*
* Allocates a 320x200 TinyVicky bitmap (8 blocks), assigns CLUT 0,
* puts it on layer 0, loads the Sierra AGI 16-color palette into
* CLUT 0, then switches the display into graphics mode.
*
* On success: u0047 holds BM0 start block# for scrn.asm.
*--------------------------------------------------------------------
L026B               leas      -$04,s              scratch on stack (2 words)

* SS.AScrn: allocate bitmap 0 (320x200 = type 1)
* Entry: Y=bitmap# (0), X=type (1=320x200), A=path
* Exit:  X=starting block# on success
                    ldy       #$0000              bitmap 0
                    ldx       #$0001              type: 320x200
                    lda       #StdOut
                    ldb       #SS.AScrn
                    os9       I$SetStt
                    bcs       L02E6               error: can't allocate bitmap

* Store BM0 start block# in u0047 (for scrn.asm L015A / L01D4)
                    tfr       x,d                 D = 0 : block#
                    stb       <u0047              BM0 start block#
                    stb       scr174              save for later free

* SS.Palet: assign CLUT 0 to bitmap 0
* Entry: X=CLUT# (0), Y=bitmap# (0), A=path
                    ldx       #$0000              CLUT 0
                    ldy       #$0000              bitmap 0
                    lda       #StdOut
                    ldb       #SS.Palet
                    os9       I$SetStt
                    bcs       L02E6

* SS.PScrn: assign bitmap 0 to layer 0
* Entry: X=layer# (0), Y=bitmap# (0), A=path
                    ldx       #$0000              layer 0
                    ldy       #$0000              bitmap 0
                    lda       #StdOut
                    ldb       #SS.PScrn
                    os9       I$SetStt
                    bcs       L02E6

* Build CLUT data on stack (1K = 256 x 4 bytes BGRX).
* Zero all 1K, then copy the 16 AGI palette entries.
                    leas      -$0400,s            allocate 1K CLUT buffer on stack
                    tfr       s,u                 U -> buffer start
                    ldy       #$0400              1K bytes to zero
L026B_zero          clr       ,u+
                    leay      -1,y
                    bne       L026B_zero
* Copy 64 bytes (16 entries) of AGI colors into buffer start
                    tfr       s,u                 U -> buffer start again
                    leax      >wb_agi_clut,pcr    X -> AGI color table
                    ldy       #wb_agi_clut_sz     Y = 64
L026B_copy          lda       ,x+
                    sta       ,u+
                    leay      -1,y
                    bne       L026B_copy

* SS.DfPal: load 1K CLUT buffer into CLUT 0
* Entry: X=CLUT# (0), Y=ptr to 1K data, A=path
                    tfr       s,y                 Y = CLUT buffer on stack
                    ldx       #$0000              CLUT 0
                    lda       #StdOut
                    ldb       #SS.DfPal
                    os9       I$SetStt
                    leas      $0400,s             free CLUT buffer
                    bcs       L02E6

* SS.DScrn: enable graphics mode (bitmaps + graphics)
* Entry: X=MCR low byte (FX_BM+FX_GRF), Y=MCR high byte (FT_OMIT)
                    ldx       #FX_BM+FX_GRF       enable bitmap + graphics
                    ldy       #FT_OMIT            don't change high byte
                    lda       #StdOut
                    ldb       #SS.DScrn
                    os9       I$SetStt
                    bcs       L02E6

                    clr       <u0045
                    lbsr      L02E9
L02E6               leas      $04,s
                    rts

* Kills echo, eof, int and quit signals (unchanged from CoCo 3)
L02E9               leas      <-$20,s
                    lda       #StdIn
                    ldb       #SS.OPT
                    leax      ,s
                    os9       I$GetStt
                    bcs       L0332

                    lda       >L0115,pcr
                    ldb       PD.EKO-PD.OPT,x
                    sta       PD.EKO-PD.OPT,x
                    stb       >L0115,pcr

                    lda       >L0116,pcr
                    ldb       PD.EOF-PD.OPT,x
                    sta       PD.EOF-PD.OPT,x
                    stb       >L0116,pcr

                    lda       >L0117,pcr
                    ldb       <PD.INT-PD.OPT,x
                    sta       <PD.INT-PD.OPT,x
                    stb       >L0117,pcr

                    lda       >L0118,pcr
                    ldb       <PD.QUT-PD.OPT,x
                    sta       <PD.QUT-PD.OPT,x
                    stb       >L0118,pcr

                    lda       #StdIn
                    ldb       #SS.OPT
                    os9       I$SetStt

L0332               leas      <$20,s
                    rts

*--------------------------------------------------------------------
* L0336 - Wildbits screen teardown.
* Restores text mode, frees bitmap memory.
*--------------------------------------------------------------------
L0336               leas      -2,s
                    tst       scr174
                    beq       L036D

                    lbsr      L02E9
                    bcs       L036D

* SS.DScrn: return to text mode
                    ldx       #FX_TXT             text only
                    ldy       #FT_OMIT
                    lda       #StdOut
                    ldb       #SS.DScrn
                    os9       I$SetStt
                    bcs       L036D

* SS.FScrn: free bitmap 0
                    ldy       #$0000              bitmap 0
                    lda       #StdOut
                    ldb       #SS.FScrn
                    os9       I$SetStt

L036D               leas      2,s
                    rts

* Unload modules (unchanged)
L0370               leax      >L0106,pcr
                    lda       #Prgrm+Objct
                    lbsr      L040B
                    leax      >L010B,pcr
                    lbsr      L040B
                    leax      >L0110,pcr
                    lbsr      L040B
                    rts

*--------------------------------------------------------------------
* L0388 - Wildbits stub (CoCo 3 GIME restore not needed).
* Restore monitor type only; no GIME block manipulation.
*--------------------------------------------------------------------
L0388               clra
                    ldb       >L0119,pcr
                    andb      #$03
                    tfr       d,x
                    lda       #StdOut
                    ldb       #SS.Montr
                    os9       I$SetStt
                    rts

* Converts address into MMU values (unchanged from CoCo 3)
L03B6               tfr       x,d
                    ldb       #8
                    mul
                    pshs      u,a
                    leau      >mmubuf+8,u
                    lda       a,u
                    ldb       ,s
                    incb
                    andb      #$07
                    ldb       b,u
                    tfr       d,u
                    leas      3,s
                    rts

* Load named module (unchanged)
L03D0               leas      -$08,s
                    stu       ,s

                    stx       $02,s
                    lda       #Prgrm+Objct
                    os9       F$NMLoad
                    bcs       L0408

                    ldx       $02,s
                    os9       F$Link
                    bcs       L0408
                    stu       $06,s               save module header for F$UnLink
* Wildbits: store F$Link entry (Y) at handle[0:1] so dispatcher can find it
                    ldx       ,s                  X = handle address ($000A/$0012/$001A)
                    sty       ,x                  [handle] = module entry address
                    bra       L0403               skip CoCo3 MMU block loop

L0403               ldu       $06,s
                    os9       F$UnLink
L0408               leas      $08,s
                    rts

L040B               os9       F$UnLoad
                    bcc       L040B
                    clrb
                    rts

L0412               fcc       '/VI'
L0415               fcb       C$CR
L0416               fdb       $0000
L0418               fcb       $00

L0419               ldu       #$0000
                    ldx       #int5EE
                    os9       F$Icpt

                    lda       #$01
                    leax      >L0412+1,pcr
                    os9       I$Attach
                    bcs       L0451
                    stu       >L0416,pcr

                    leax      >L0412,pcr
                    os9       I$Open
                    bcs       L0451
                    sta       >L0418,pcr

                    ldb       #SS.ARAM
                    ldx       #$000D
                    os9       I$SetStt
                    bcs       L0451
                    pshs      x

                    ldb       #SS.KSet
                    os9       I$SetStt
                    puls      b,a
L0451               rts

* Signal intercept processing (unchanged)
L0452               cmpb      #$80
                    bne       L0464
                    tfr       u,d
                    tfr       a,dp
                    dec       <u004A
                    bne       L0464
                    bsr       L0465
                    lda       #$03
                    sta       <u004A
L0464               rti

L0465               inc       >u024C,u
                    bne       L047B
                    inc       >u024B,u
                    bne       L047B
                    inc       >u024A,u
                    bne       L047B
                    inc       >u0249,u
L047B               tst       >u0102,u
                    bne       L04BC

                    inc       <u003F
                    bne       L0487
                    inc       <u003E
L0487               ldd       <u0048
                    addd      #$0001
                    std       <u0048
                    cmpd      #$0014
                    bcs       L04BC
                    subd      #$0014
                    std       <u0048
                    ldd       #$003C
                    leax      >u043D,u
                    inc       ,x
                    cmpb      ,x
                    bhi       L04BC
                    sta       ,x+
                    inc       ,x
                    cmpb      ,x
                    bhi       L04BC
                    sta       ,x+
                    inc       ,x
                    ldb       #$18
                    cmpb      ,x
                    bhi       L04BC
                    sta       ,x+
                    inc       ,x
L04BC               rts

* /VI device cleanup (unchanged)
L04BD               lda       >L0418,pcr
                    beq       L04D0
                    ldb       #SS.KClr
                    os9       I$SetStt
                    ldb       #SS.DRAM
                    os9       I$SetStt
                    os9       I$Close
L04D0               ldu       >L0416,pcr
                    beq       L04D9
                    os9       I$Detach
L04D9               rts

*--------------------------------------------------------------------
* L04DA - Module dispatcher (sub659), copied into data area.
*
* Wildbits: removed GIME $FFA9/$FFAA/$FFAB/$FFAC/$FFAD/$FFAE/$FFAF
* writes. Module code is accessible at its link address; the OS
* keeps it mapped. Only the dispatch call and context save/restore
* remain.
*
* TODO: verify that modules remain mapped during dispatch on Wildbits
* Level 2. If not, F$MapBlk will be needed here.
*--------------------------------------------------------------------
L04DA               ldd       ,s++
                    std       <u002A
                    orcc      #IntMasks
                    ldu       <u0043
                    lda       $06,x
                    sta       u000C,u
                    lda       $05,x
                    sta       u000A,u
                    lda       $04,x
                    sta       u0008,u
                    lda       $03,x
                    sta       u0006,u
                    lda       $02,x
                    sta       u0004,u
                    andcc     #^IntMasks

                    lda       $07,x
                    ldu       <u002E
                    jsr       a,u

                    orcc      #IntMasks
                    ldu       <u0043
                    lda       <u0010
                    sta       u000C,u
                    lda       <u000F
                    sta       u000A,u
                    lda       <u000E
                    sta       u0008,u
                    lda       <u000D
                    sta       u0006,u
                    lda       <u000B
                    sta       u0002,u
                    lda       <u000A
                    sta       ,u
                    andcc     #^IntMasks

                    jmp       [>$002A]

L054F               fcb       $00,$00,$00,$00,$00,$00,$00,$00
L0557               fcb       $73,$69,$65,$72,$72,$61,$00

*--------------------------------------------------------------------
* dbg_putc - write current sentinel char to StdErr, then advance.
* Uses >dbg_char absolute addressing (safe even when U is corrupted).
* Preserves all registers. Remove before final release.
*--------------------------------------------------------------------
dbg_putc            pshs      d,x,y,cc
                    lda       >dbg_char
                    pshs      a
                    lda       #StdErr
                    ldy       #1
                    tfr       s,x
                    os9       I$Write
                    leas      1,s
                    inc       >dbg_char
                    puls      d,x,y,cc,pc

* MMU helper routines (use F$GPrDsc; work on Wildbits via NitrOS-9)
mmuini1             pshs      cc,x,y
                    orcc      #$50
                    lda       #1
                    leax      >gprbuf,u
                    os9       F$GPrDsc
                    leay      $41,x
                    leax      >mmubuf,u
                    ldb       #8
m2lup               lda       ,y++
                    sta       ,x+
                    decb
                    bne       m2lup
                    puls      cc,x,y,pc

mmuini2             pshs      cc,x,y
                    orcc      #$50
                    os9       F$ID
                    leax      >gprbuf,u
                    os9       F$GPrDsc
                    leay      $41,x
                    leax      >mmubuf+8,u
                    ldb       #8
mloop               lda       ,y++
                    sta       ,x+
                    decb
                    bne       mloop
                    puls      cc,x,y,pc

                    emod
eom                 equ       *
                    end
