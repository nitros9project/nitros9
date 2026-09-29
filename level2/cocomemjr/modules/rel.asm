********************************************************************
* REL - Relocation routine for the CoCo 1/2 with a CocoMEM Jr MMU
*
* Based on the CoCo 3 Level 2 REL (level1/coco1/modules/rel.asm). The
* CocoMEM Jr has the CoCo 3 MMU registers ($FF90/$FF91, $FFA0-$FFAF) but no
* GIME, so video comes from the VDG through the SAM, which can only display
* the 64K motherboard RAM (MMU blocks $38-$3F).
*
* Hardware notes:
* - $FF90 bit 6 enables the MMU and bit 3 (MC3) pins $FExx to block $3F.
*   Bit 7 is inverted compared with the GIME: 0 enables the alternate vectors
*   (CPU $FFE0-$FFFF read from MemJr RAM), 1 keeps the CoCo 1/2 ROM vectors.
* - The alternate vector RAM is written by mapping block $3F into any slot
*   other than 7 and writing the top of that slot ($xFF2-$xFFF).
* - Never touch $FFD9 (SAM fast mode): on a CoCo 1/2 it stops video and
*   DRAM refresh.
*
* Boot sequence: Disk BASIC's DOS command loads track 34 to $2600 and jumps
* to $2602 with the MMU off. REL sets up the MMU and the alternate vectors,
* clears a boot screen in Bt.Block, copies REL/BOOT/KRN to Bt.Start ($ED00)
* and starts krn at $F000. BtDebug maps the boot screen block into slot 0
* for each character, so D.BtBug output stays visible no matter what the
* kernel does to the system memory map. A crash leaves the screen alone, so
* the breadcrumbs before the '*' and error code stay visible.
*
* REL must be exactly $130 bytes: BOOT follows at Bt.Start+$130 and krn at
* $F000, and the boot track is full.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   5r7    2026/09/29  John Federico / Claude
* CocoMEM Jr version.

                    nam       REL
                    ttl       Relocation routine for CocoMEM Jr

                    IFP1
                    use       defsfile
                    ENDC

XX.Size             equ       6                   number of bytes before REL actually starts
Offset              equ       Bt.Start+XX.Size

* CocoMEM Jr registers
MJ.Init0            equ       $FF90               INIT0: MMU enable, MC3, alternate vectors
MJ.Init1            equ       $FF91               INIT1: task select
MJ.MMU              equ       %01000000           MMU enable
MJ.MC3              equ       %00001000           $FExx constant (block $3F)
MJ.NoAlt            equ       %10000000           1=ROM vectors, 0=alternate vectors
MJ.Boot             equ       MJ.MMU+MJ.MC3+MJ.NoAlt   MMU on, alternate vectors off
MJ.Run              equ       MJ.MMU+MJ.MC3       MMU on, alternate vectors on

* Boot screen in Bt.Block. The SAM display address must be a multiple of
* $200, so the screen starts $200 into the block; the block's first bytes
* hold the BtDebug cursor.
ScBlkAdr            equ       (Bt.Block-$38)*$2000   logical = motherboard address of Bt.Block
ScOff               equ       $0200               screen offset within the block
ScStart             equ       ScBlkAdr+ScOff      boot screen address while REL runs
ScSize              equ       32*16
VdgSpace            equ       $60                 VDG space, normal video

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $07
edition             set       5

********************************************************************
* Any changes to the next 3 lines requires changes in XX.Size, above
                    fcc       /OS/                sync bytes
                    bra       (start+XX.Size+*-2) execution start
                    fdb       $1205               filler bytes

Begin               mod       eom,name,tylg,atrv,start,size

                    org       0
size                equ       .                   REL doesn't require any memory

name                fcs       /REL/
                    fcb       edition

crash               lda       #'*                 signal a crash error
                    jsr       <D.BtBug
                    tfr       b,a                 and show the error code
                    jsr       <D.BtBug
                    clrb                          B=0: crash
                    fcb       $8C                 skip the LDB below (CMPX #)
start               ldb       #$FF                B=$FF: cold start
                    clr       >$FFDF              SAM all-RAM mode
                    orcc      #IntMasks           IRQs off
                    clr       >PIA0Base+3         turn off the VSYNC IRQ
                    clra
                    tfr       a,dp

* Task 0 and task 1: block 0 (MemJr RAM, system globals) in slot 0, and the
* motherboard RAM blocks $39-$3F in slots 1-7. We are running at $26xx, which
* is block $39 in slot 1, so the code keeps running when the MMU comes on.
                    ldx       #DAT.Regs
                    clr       ,x
                    clr       8,x
                    lda       #$39
DatLoop             sta       1,x
                    sta       9,x
                    leax      1,x
                    inca
                    cmpa      #$40
                    bne       DatLoop
                    clr       >MJ.Init1           task 0
                    lda       #MJ.Boot
                    sta       >MJ.Init0           MMU on, alternate vectors still off
* Slot 0 is now MemJr block 0: the ROM's stack is gone, so make a new one.
                    lds       #$1FFF
                    stb       ,-s                 save the boot status
                    beq       Vectors             crash: keep the direct page for post-mortem
                    ldx       #$0000
DpClr               clr       ,x+                 clear the direct page
                    cmpx      #$0100
                    bne       DpClr

* Alternate vectors: map block $3F into slot 6 and write $DFF2-$DFFD, which
* the CPU then sees at $FFF2-$FFFD. They point at the kernel's vector table
* at $FEEE-$FEFF (the same layout as the CoCo 3). RESET is not needed: a
* reset turns the MMU off, so the CPU gets the ROM's reset vector.
Vectors             lda       #$3F
                    sta       >DAT.Regs+6
                    ldx       #$FEEE              SWI3 is the first vector
                    ldu       #$DFF2
VecLoop             stx       ,u++
                    leax      3,x
                    cmpu      #$DFFE
                    blo       VecLoop
                    lda       #$3E
                    sta       >DAT.Regs+6         restore slot 6
                    lda       #MJ.Run
                    sta       >MJ.Init0           alternate vectors on
                    sta       <D.HINIT            shadow copies for the kernel
                    clr       <D.TINIT

* VDG text mode showing the boot screen at motherboard ScStart:
* SAM V0-V2=0 and F0-F6=ScStart/$200. Clearing a SAM bit is a write to the
* even address, setting it a write to the odd one.
                    lda       >PIA1Base+2
                    anda      #%00000111          text, CSS=0
                    sta       >PIA1Base+2
                    ldx       #$FFC0
                    ldb       #ScStart/$200
                    lda       #10                 3 V bits + 7 F bits
SamLoop             cmpa      #7
                    bhi       SamClr              V0-V2: clear
                    lsrb
                    bcc       SamClr
                    sta       1,x                 odd address sets the bit
                    fcb       $8C                 skip the STA below (CMPX #)
SamClr              sta       ,x                  even address clears it
                    leax      2,x
                    deca
                    bne       SamLoop

* Clear the boot screen, except after a crash
                    tst       ,s
                    beq       Reloc
                    ldd       #ScOff              BtDebug cursor (with the block in slot 0)
                    std       ScBlkAdr+2
                    ldx       #ScStart
                    lda       #VdgSpace
ClrLoop             sta       ,x+
                    cmpx      #ScStart+ScSize
                    bne       ClrLoop

* Move REL, BOOT and KRN from $2600 to Bt.Start, once
Reloc               ldb       ,s+                 check the boot status
                    beq       Failed              crash
                    tfr       pc,d
                    cmpa      #$26
                    bne       InHigh
                    ldu       #$2600
                    ldx       #$1200              size of the track 34 boot file
                    ldy       #Bt.Start
                    bsr       CopyLp
                    jmp       >Offset+InHigh

Failed              clr       >$FF40              turn off the disk drives
Hang                bra       Hang

* Copy X bytes from U to Y
Move                clra                          entry: U=ptr to length byte, data
                    ldb       ,u+
                    tfr       d,x
CopyLp              lda       ,u+
                    sta       ,y+
                    leax      -1,x
                    bne       CopyLp
                    rts

* Boot debug output: one character to the boot screen.
* Maps Bt.Block into slot 0, where its first bytes hold the cursor.
* Converts ASCII to VDG codes in normal video: lower case to upper case,
* then OR $40: $20-$3F (digits, punctuation) become $60-$7F.
BtDebug             pshs      cc,d,x
                    orcc      #IntMasks
                    ldb       #Bt.Block
                    stb       >DAT.Regs+0
                    ldx       >$0002              cursor
                    anda      #$7F
                    cmpa      #$60
                    blo       NotLow
                    suba      #$20                lower case to upper case
NotLow              ora       #$40                $20-$3F -> $60-$7F, $40-$5F unchanged
                    sta       ,x+
                    stx       >$0002
                    clr       >DAT.Regs+0         block 0 back in slot 0
                    puls      cc,d,x,pc

InHigh              lda       #$7E                JMP
                    sta       <D.BtBug
                    leax      <BtDebug,pcr
                    stx       <D.BtBug+1
                    leau      <R.Crash,pcr
                    ldy       #D.Crash
                    bsr       Move
                    ldx       #$F000              krn is at $F000
                    ldd       M$Exec,x
                    jmp       d,x

* Copied to D.Crash
R.Crash             fcb       6                   size of the code
                    clr       >MJ.Init1           task 0
                    jmp       >Offset+crash

* Pad REL to $130 bytes so BOOT starts at Bt.Start+$130
                    fill      $39,$130-XX.Size-3-*

                    emod
eom                 equ       *
                    end
