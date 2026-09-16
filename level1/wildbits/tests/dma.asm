********************************************************************
* dma - DMA engine probe (TinyVKY_DMA_Reg_Block, $FEC0-$FEDF)
*
* STRUCTURAL ONLY. This program never starts a transfer. It writes and
* reads the register file and nothing else, so it cannot scribble on
* memory and cannot wedge the machine. See the note at the end of this
* header for why the transfer test is deliberately absent.
*
* Each line stays under 70 columns.
*
* The interesting property of this block is that the READ decode does
* not return the register the WRITE decode filled. Writes are direct:
*     VDMA_REG[Bus_A_i[4:0]] <= Bus_D_i          (Reg_Block:67)
* but the read case statement (Reg_Block:73-100) hands back a different
* index for sixteen of the thirty-two addresses - the two address quads
* are reversed and the four size/stride pairs are swapped. The RTL's own
* comments there name $FEC4 "Source_Addy_H", so the read side was written
* for a byte order the write side never implemented.
*
* That gives a signature no other fault can imitate. Writing the low byte
* of each address into itself for $FEC4-$FED7 and reading it all back
* should return:
*     C7 C6 C5 C4  CB CA C9 C8  CD CC CF CE  D1 D0 D3 D2  D4 D5 D6 D7
* If every address returns its OWN value instead, the bitstream is newer
* than the RTL sources and the whole map has to be re-derived. All FF
* means the block is not decoding at all.
*
* Checks, all harmless:
*   1. $FEC0 read/write with an inert value (bit 0 clear, so nothing can
*      ever fire), then the control register is left at $00
*   2. $FEC1 - written and read are two different physical registers. A
*      write puts the 8-bit fill byte in; a read returns the status,
*      which at idle is exactly $00 (bit 7 progress, bits 6:0 hardwired)
*   3. the readback permutation signature above
*   4. $FED8-$FEDF - decoded but dead. The register array is only 24
*      entries, so writes there vanish and reads take the case default
*      and return $FF. All eight must read $FF
*   5. an address-bit-4 alias probe of the kind that IS present in the
*      neighbouring math block: $FED4 is written and $FEC7 must not move
*
* WHY THERE IS NO TRANSFER TEST HERE. Starting a transfer asks the engine
* to halt the CPU and wait for BA and BS to come back together
* (Controller:559 CPU_STOPPED_ST0). Nothing in that state has a timeout.
* If the handshake does not complete the state machine stops there for
* good, the status bit stays $80, and the CPU is re-halted every vertical
* blank for the rest of the session - unrecoverable without a reset.
* A transfer also needs a real PHYSICAL address, because the engine goes
* straight to the SRAM and not through the MMU. Both belong in a separate
* program run deliberately, not in a probe anyone might type by accident.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* ------------------------------------------------------------------
*   1      2026/09/09  Claude
* Created.

                    nam       dma
                    ttl       DMA engine probe

                    ifp1
                    use       defsfile
                    endc

* explicit absolute addresses: the defsfile carries the DMA map as an
* org 0 / rmb overlay, which gives offsets rather than addresses
DMACTL              equ       $FEC0               control (b0 enable, b7 start)
DMASTAT             equ       $FEC1               read status / write fill byte
DMAREGS             equ       $FEC4               first of the 20 probed bytes
DMAHOLE             equ       $FED8               decoded but dead, 8 bytes
NREGS               equ       20
NHOLE               equ       8
LBLEN               equ       14                  every label is 14 wide

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

                    org       0
got                 rmb       1
expv                rmb       1
cnt                 rmb       1
nff                 rmb       1                   FF count in the dead hole
rdbuf               rmb       NREGS               the 20 bytes as read back
line                rmb       80
stack               rmb       200
size                equ       .

name                fcs       /dma/
                    fcb       edition

hexch               fcc       /0123456789ABCDEF/

* what the read decode in TinyVKY_DMA_Reg_Block.v:73-100 returns when
* every address $FEC4-$FED7 has been given its own low byte
perm                fcb       $C7,$C6,$C5,$C4
                    fcb       $CB,$CA,$C9,$C8
                    fcb       $CD,$CC,$CF,$CE
                    fcb       $D1,$D0,$D3,$D2
                    fcb       $D4,$D5,$D6,$D7
* what an address that simply reads back what was written would give
iden                fcb       $C4,$C5,$C6,$C7
                    fcb       $C8,$C9,$CA,$CB
                    fcb       $CC,$CD,$CE,$CF
                    fcb       $D0,$D1,$D2,$D3
                    fcb       $D4,$D5,$D6,$D7

t0                  fcc       /dma ed.1: DMA register file at FEC0 - no transfer is run/
                    fcb       C$CR
t0l                 equ       *-t0
texp                fcc       / exp /
texpl               equ       *-texp
tok                 fcc       / OK/
                    fcb       C$CR
tokl                equ       *-tok
tbad                fcc       / BAD/
                    fcb       C$CR
tbadl               equ       *-tbad
r1                  fcc       /FEC4-FECD read: /
r1l                 equ       *-r1
r2                  fcc       /FECE-FED7 read: /
r2l                 equ       *-r2

lb0                 fcc       /FEC0 rw of 02 /
lb1                 fcc       /FEC1 idle stat/
lb2                 fcc       /FED8-FEDF FFs /
lb3                 fcc       /alias A4 FEC7 /

v0                  fcc       /read decode: the permutation in the RTL sources./
                    fcb       C$CR
v0l                 equ       *-v0
v0b                 fcc       /Reads do NOT return the register the write filled./
                    fcb       C$CR
v0bl                equ       *-v0b
v1                  fcc       /read decode: every address returns its own value./
                    fcb       C$CR
v1l                 equ       *-v1
v1b                 fcc       /This core is NEWER than the RTL - re-derive the map./
                    fcb       C$CR
v1bl                equ       *-v1b
v2                  fcc       /read decode: all FF - the block is not decoding./
                    fcb       C$CR
v2l                 equ       *-v2
v3                  fcc       /read decode: neither pattern - see the bytes above./
                    fcb       C$CR
v3l                 equ       *-v3
v4                  fcc       /alias: a write to FED4 also changed FEC7./
                    fcb       C$CR
v4l                 equ       *-v4
v5                  fcc       /real map: src FEC5-7, dst FEC9-B, Xsz FECC-D,/
                    fcb       C$CR
v5l                 equ       *-v5
v5b                 fcc       /Ysz FECE-F, strides FED0-3. 1D count is FECF:FECC:FECD./
                    fcb       C$CR
v5bl                equ       *-v5b

start               leax      t0,pcr
                    ldy       #t0l
                    lbsr      PutLine

* ---- 1. control register read/write. Bit 1 only: enable is clear so
* nothing can fire, and bit 7 never goes high.
                    lda       #$02
                    sta       >DMACTL
                    lda       >DMACTL
                    sta       <got
                    lda       #$02
                    sta       <expv
                    leax      lb0,pcr
                    lbsr      Rpt8
                    clra
                    sta       >DMACTL             leave it disarmed

* ---- 2. FEC1: written and read are different registers. The status at
* idle is exactly 00 - bit 7 progress, bits 6:0 hardwired zero.
                    lda       #$A5
                    sta       >DMASTAT            this is the fill byte
                    lda       >DMASTAT            this is the status
                    sta       <got
                    clra
                    sta       <expv
                    leax      lb1,pcr
                    lbsr      Rpt8

* ---- 3. the readback permutation. Give each address its own low byte.
                    ldx       #DMAREGS
                    lda       #$C4
Fill1               sta       ,x+
                    inca
                    cmpa      #$D8
                    bne       Fill1
                    ldx       #DMAREGS
                    ldy       #rdbuf
                    ldb       #NREGS
Read1               lda       ,x+
                    sta       ,y+
                    decb
                    bne       Read1
                    leax      r1,pcr
                    ldb       #r1l
                    ldy       #rdbuf
                    lbsr      PutRow
                    leax      r2,pcr
                    ldb       #r2l
                    ldy       #rdbuf+10
                    lbsr      PutRow
                    leax      perm,pcr
                    lbsr      Same
                    bne       Dec1
                    leax      v0,pcr
                    ldy       #v0l
                    lbsr      PutLine
                    leax      v0b,pcr
                    ldy       #v0bl
                    bra       DecSay
Dec1                leax      iden,pcr
                    lbsr      Same
                    bne       Dec2
                    leax      v1,pcr
                    ldy       #v1l
                    lbsr      PutLine
                    leax      v1b,pcr
                    ldy       #v1bl
                    bra       DecSay
Dec2                ldx       #rdbuf              all FF?
                    ldb       #NREGS
Dec3                lda       ,x+
                    cmpa      #$FF
                    bne       Dec4
                    decb
                    bne       Dec3
                    leax      v2,pcr
                    ldy       #v2l
                    bra       DecSay
Dec4                leax      v3,pcr
                    ldy       #v3l
DecSay              lbsr      PutLine

* ---- 4. FED8-FEDF: writes vanish, reads take the case default
                    ldx       #DMAHOLE
                    lda       #$5A
                    ldb       #NHOLE
Hole1               sta       ,x+
                    decb
                    bne       Hole1
                    ldx       #DMAHOLE
                    ldb       #NHOLE
                    clr       <nff
Hole2               lda       ,x+
                    cmpa      #$FF
                    bne       Hole3
                    inc       <nff
Hole3               decb
                    bne       Hole2
                    lda       <nff
                    sta       <got
                    lda       #NHOLE
                    sta       <expv
                    leax      lb2,pcr
                    lbsr      Rpt8

* ---- 5. address bit 4 alias probe. In the math block a write ignores
* A[4]; here all five bits decode, so FEC7 must not follow FED4.
                    ldx       #DMAREGS
                    ldb       #NREGS
                    clra
Alias1              sta       ,x+
                    decb
                    bne       Alias1
                    lda       #$3C
                    sta       >DMAREGS+16         FED4
                    lda       >DMAREGS+3          FEC7, the mirrored address
                    sta       <got
                    clra
                    sta       <expv
                    leax      lb3,pcr
                    lbsr      Rpt8
                    lda       <got
                    beq       Map1
                    leax      v4,pcr
                    ldy       #v4l
                    lbsr      PutLine

* ---- the map the hardware actually consumes, for whoever reads this
Map1                leax      v5,pcr
                    ldy       #v5l
                    lbsr      PutLine
                    leax      v5b,pcr
                    ldy       #v5bl
                    lbsr      PutLine

                    clrb
                    os9       F$Exit

* ---- Same: X -> a 20-byte table; Z set when rdbuf matches it
Same                ldy       #rdbuf
                    ldb       #NREGS
Same1               lda       ,x+
                    cmpa      ,y+
                    bne       SameNo
                    decb
                    bne       Same1
                    rts                           Z set
SameNo              andcc     #$FB                Z clear
                    rts

* ---- PutRow: X -> label, B = its length, Y -> ten bytes to show
PutRow              pshs      y
                    ldy       #line
                    lbsr      Copy
                    puls      x
                    lda       #10
                    sta       <cnt
Row1                lda       ,x+
                    lbsr      Hex2
                    lda       #C$SPAC
                    sta       ,y+
                    dec       <cnt
                    bne       Row1
                    leay      -1,y                drop the trailing space
                    lda       #C$CR
                    sta       ,y+
                    tfr       y,d
                    subd      #line
                    tfr       d,y
                    ldx       #line
                    bra       PutLine

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
                    beq       VOK
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
