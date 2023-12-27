*******************************************************************
* REL - Relocation routine
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   5r5    2003/07/31  Boisy G. Pitre
* Back ported NitrOS-9 REL to OS-9 Level Two.
*
*          2004/11/09  P.Harvey-Smith
* Added code to flip Dragon Alpha into text mode on boot.
* EOU Beta 6
*          2020/09/01  Bill Nobel - GIME-X 2.86 Mhz mode enabled based on def
*          2020/09/01  L. Curtis Boyle - modified boot messages to reflect GIME-X
*                      or CPU type

                    nam       REL
                    ttl       Relocation routine

                    IFP1
                    use       defsfile
                    ENDC

XX.Size             equ       6                   number of bytes before REL actually starts
Offset              equ       Bt.Start+XX.Size
                    IFEQ      Level-1
ScStart             equ       $8000               screen start in memory
                    ELSE
ScStart             equ       $8008               screen start in memory
                    ENDC

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $06
edition             set       5

********************************************************************
* Any changes to the next 3 lines requires changes in XX.Size, above
                    fcc       /OS/       sync bytes
                    bra       (start+XX.Size+*-2) execution start
                    fdb       $1205               filler bytes

Begin               mod       eom,name,tylg,atrv,start,size

                    org       0
size                equ       .                   REL doesn't require any memory

name                fcs       /REL/
                    fcb       edition

                    IFNE      Level-1

*************************************************************************
** Start of Level2/Level3 code
**
** The boot-loader loads the "kernelfile" from track34 of the disk into
** memory at $26xx and then jumps into it at address $2602. The
** kernelfile is formed by concatenating the modules REL, BOOT, KRN.
** The entry point jumps via the REL module header to label "start".
**
** One function of REL is to copy the kernelfile from $26xx to high
** memory (specifically, to Bt.Start). $1200 bytes are copied.
**
** The size of each of these modules is controlled with filler bytes (eg,
** see label "Filler" below) so that (after relocation):
** REL  starts at $ED00 and is $130 bytes in size
** BOOT starts at $EE30 and is $1D0 bytes in size
** KRN  starts at $F000 and ends at $FEFF (but the 'emod' comes before
**      the end of krn -- refer to the source file for details)
**
** When REL starts, it has NO STACK
*************************************************************************

                    IFNE      mc09

*************************************************************************
** Start of Level2 code for mc09 ****************************************
*************************************************************************

crash               lda       #'*                 signal a crash error
                    jsr       <D.BtBug
                    tfr       b,a                 save error code
                    jsr       <D.BtBug            and dump this out, too
badbad              bra       badbad


* Entry point for REL. Code is currently running at $26xx. Arrive with
* MMU enabled (with 1-1 mapping), ROM disabled, TR=0, FRT=0.
*
* The MMU (which Coco calls Dynamic Address Translator, DAT) maps
* 8Kbyte blocks of physical memory into 8Kbyte regions of the CPU
* address space.
*
* There don't seem to be consistent names for stuff but I try to use:
* Page             - a 256Byte region of memory
* Block            - an 8Kbyte hunk of physical memory
* Map              - an 8Kbyte region of CPU address space. Map 0-7
*                    are addressed when TR=0, Map 8-15 are in use
*                    when TR=1.
* Mapping register - one of 16 registers (8 for TR=0, 8 for TR=1)
*                    that control which block appears in which map.
*
* There are 64 blocks ($00-$3F) on 512K system, 128 blocks ($00-7F)
* on 1MByte system. At the moment we assume 512K.
*
* In order to start krn, need to:
* - put block   0 in map 0 ($0000 in CPU address space)
* - put block   7 in map 7 ($E000 in CPU address space)
* - enable FRT (makes top 512 locations of block 7 permanently
*   mapped at CPU address $FE00 - $FFFF).
*
* Need to use block 7 for the top of memory because that is where
* the mc09 MMU hardware implements the special fixed-RAM-top (FRT)
* functionality that keeps a tiny piece of the NitrOS9 kernel
* permanently mapped into memory.
*
* This is different from the COCO, which uses block $3f. $3f also
* holds the I/O space on COCO whereas for mc09, the I/O space overlays
* and is not affected by the MMU at all.

start               ldx       #MMUADR
                    lda       #(MMU_TR0|0)        Select mapping reg 0, with TR=0
                    ldb       #$0                 Select bottom block of physical memory
                    std       ,x                  Write A to MMUADR to set MAPSEL=0, then write B to MMUDAT
                    lda       #(MMU_TR0|7)        Select mapping reg 7, with TR=0
                    ldb       #$7                 Select block 7 of physical memory (512Kbyte system)
                    std       ,x                  Write A to MMUADR to set MAPSEL=7, then write B to MMUDAT
                    lda       #MMU_TR0FRT
                    sta       ,x                  Enable FixedRamTop
* The setup below has been reordered compared with the Coco code. This code does
* the copy/branch high before any of the page0 setup, reflecting an earlier code
* version where MMU setup was deferred (and so page0 was not yet mapped). Could restore
* the Coco ordering, if that allows more common code, or just leave it as-is.
* Copy kernelfile image from $26xx to Bt.Start ($ED00)
L00E2               tfr       pc,d                get the address at which we're executing
                    cmpa      #$26                the bootfile starts out at $2600
                    bne       L0101               if not at $26xx, already copied: continue with booting
                    ldu       #$2600              else move rel, Boot, krn over
                    ldx       #$1200              number of bytes to copy
                    ldy       #Bt.Start           where to put it

cpkrn               ldd       ,u++                from
                    std       ,y++                to
                    leax      -2,x                update count
                    bne       cpkrn
* Go to copy in high memory
                    jmp       >Offset+L0101

* Now executing at $EDxx
L0101               ldb       #$FF                negative - do complete boot
start1              orcc      #IntMasks           turn off IRQ's
* [NAC HACK 2016Dec05] todo: turn off timer interrupt in case this is a reboot
                    clra                          make A=0 for later
                    tfr       a,dp
                    clr       <D.CBStrt           cold boot start: don't re-boot on reset
                    lds       #$1FFF              set stack to the end of block 0
                    stb       ,-s                 save status of start, $00=cold, $01=warm $FF = startup: do complete boot
* This is done so I can tell what went on in the direct page if there's
* a crash. 0(crash) 1(reset) -1(startup)
*         beq   Cont        --don't clear out direct page if it's a crash
                    clrb                          clear out ALL of direct page
                    tfr       d,x                 here, too
L0072               sta       ,x+                 clear out the direct page
                    incb                          Boot won't be using any of it!
                    bne       L0072               BUT RAMMER/MD DOES!!!
* Use D.TINIT as a shadow of the MMU address register, so that we can
* do read/mod/write of TR bit later on
                    lda       #MMU_TR0
                    sta       <D.TINIT
**         tst   ,s         check status : 0(crash) 1(reset) -1(startup)
**         bmi   StoreQ     if NOT a crash or reset, start at the start...
**         bne   ClrLoop
MoveTxt             leau      <BootMsg,pcr        point to OS-9 Welcome Message
                    bsr       OutMsg
* 0  = crash
* 1  = reset
* -1 = startup
                    ldb       ,s+                 check state of boot
                    bne       L0101a              if OK, continue
* X pointing to FailMsg
                    bsr       OutMsg
L00E0               bra       L00E0               loop forever

* display null-terminated message at U to UART. U, A, CC updated.
OutMsg              lda       VDUSTA
                    bita      #2
                    beq       OutMsg
                    lda       ,u+
                    beq       MsgDone
                    sta       VDUDAT
                    bra       OutMsg

MsgDone             rts


BootMsg             fcc       /NITROS9 BOOT/
                    fcb       0
FailMsg             fcc       / FAILED/
                    fcb       0

* Copy X bytes from U to Y
L00FD               lda       ,u+
                    sta       ,y+
                    leax      -1,x
                    bne       L00FD
                    rts

* Debug routine. Not executed here, but copied to D.Crash
* [NAC HACK 2017Jan21] the copy/space assigned is 16 bytes
* [NAC HACK 2017Jan21] so make sure it fits!! Ought to be a check..
* Come here with ASCII code in A. Clear bit 7 then
* display code on the VDU at the current cursor position.
* All registers except A are preserved. Vital to preserve CC
* because the caller needs it to detect that bit 7 was set -
* indicating the end of the string for some callers.
BtDebug             pshs      cc,d,x              save the registers
DebBsy              ldb       VDUSTA
                    bitb      #2
                    beq       DebBsy              wait until UART non-full
                    anda      #$7f                make valid ASCII
                    sta       VDUDAT              send character
                    puls      cc,d,x,pc           restore regs and exit

* [NAC HACK 2016Dec06] not sure there's any logic to what's done
* while we're at $2600 and what's done now we're at $EExx
* ..I think the distinction is what's done on a reboot-without-reload. Check.
* [NAC HACK 2016Dec06] At D.BtBug there are 3 bytes which
* default to RTS <16-bit address of debug routine>
* for debug, change the RTS ($39) to JMP ($7E)
* Come here in high memory: $EExx
L0101a              lda       #$7E                JMP opcode
                    sta       <D.BtBug
                    leax      <BtDebug,pc         point to debug routine
                    stx       <D.BtBug+1
                    leau      <R.Crash,pcr        point to D.Crash, D.CBStart
                    ldy       #D.Crash            move it over
                    ldx       #$10
                    bsr       L00FD
                    ldx       #$F000              we KNOW where krn module starts in memory
                    ldd       M$Exec,x            get execution start address of module
                    jmp       d,x                 jump to it

* D.Crash
R.Crash
*[NAC HACK 2017Jan21] since we're not planning to crash it's OK to comment this out, for now,
*[NAC HACK 2017Jan21] but I'm puzzled about why we'd set TR=0 (user mode??) on a crash
*[NAC HACK 2016Dec08] L003F    clr   >$FF91     go to map type 0 - called by CC3Go from map 1
                    jmp       >Offset+crash

                    fcb       $00                 warm start flag
                    fdb       $0074               go to $0074, next routine

* reset vector: map ROMs out and go to REL in the default DECB block map,
* which is still block $3F at the top of memory
                    nop       required            for the ROMs to believe it's a reset vector
                    clr       >$FFDF              go to all RAM mode
**[NAC HACK 2016Dec05]          jmp   >Offset+reset and re-start the boot

* Filler to get to a total size of $130. XX.Size is bytes at the start of
* this file - before the module header. 3 is bytes after this filler - the
* end boilerplate for the module.
*Filler   fill  $39,$130-XX.Size-3-*
                    fcb       $39,$39

                    ELSE      match               IFNE mc09

**************************************************************************
** Start of Level2/Level3 code for coco3 *********************************
**************************************************************************

* GIME setup data stored at $FF90-$FF9F and in direct page
L001F               fcb       $6C                 D.HINIT  MMU, IRQ, Vector page, SCS
                    fcb       $00                 D.TINIT  set MMU map type 0
                    fcb       $00                 D.IRQER  no FIRQ
                    fcb       $00                 D.FRQER  no IRQ
                    fdb       $0900               D.TIMxx  timer
                    fcb       $00                 D.RESV1  unused
                    fcb       $00                 D.RESV2  unused
                    IFEQ      TkPerSec-50
                    fcb       $0B                 D.VIDMD  50Hz refresh, alphanumeric display, 8 lines/char row
                    ELSE
                    fcb       $03                 D.VIDMD  60Hz refresh, alphanumeric display, 8 lines/char row
                    ENDC
                    IFEQ      Width-80
                    fcb       $34                 D.VIDRS  200 lines, 80 column mode, no attribute byte (monochrome)
                    fcb       $01                 D.BORDR  dark blue border
BOOTLINE            set       11                  80-col start line for BOOT/FAIL messages
                    ENDC
                    IFEQ      Width-40
                    fcb       $24                 D.VIDRS  200 lines, 40-col, no attribute byte
                    fcb       $01                 D.BORDR  dark blue border
BOOTLINE            set       13                  40-col start line for BOOT/FAIL messages
                    ENDC
                    IFEQ      Width-32
                    fcb       $20                 D.VIDRS  200 lines, 32-col, no attribute byte
                    fcb       $01                 D.BORDR  dark blue border
BOOTLINE            set       13                  32-col start line for BOOT/FAIL messages
                    ENDC
                    fcb       $00                 D.RESV3  (Distro 2Byte updates) display in lower 512k bank
                    fcb       $00                 D.VOFF2  vertical fine scroll set to 0
                    fcb       Bt.Block*4          D.VOFF1 display block where-ever
                    fcb       $01                 D.VOFF0  offset 8 bytes
                    fcb       $00                 D.HOFF0  no horizontal scroll
crash               lda       #'*                 signal a crash error
                    jsr       <D.BtBug
                    tfr       b,a                 save error code
                    jsr       <D.BtBug            and dump this out, too
                    clrb
                    fcb       $8C                 skip 2 bytes
*************************************************************************
* Entry point for level2/3
*************************************************************************
reset               equ       *                   later on, have reset different from start?
start               ldb       #$FF                negative - do complete boot
                    clr       >$FFDF              added for OS-9 ROM Kit boots +BGP+

start1              orcc      #IntMasks           turn off IRQ's
                    clr       >PIA0Base+3         turn off SAM IRQ's
                    clra                          make A=0 for later
                    IFNE      H6309
                    tfr       0,dp                set direct page to $0000
                    ldmd      #3                  native mode & FIRQ acts like IRQ (will need to change later for sound routine)
                    ELSE
                    tfr       a,dp
                    ENDC
                    clr       <D.CBStrt           cold boot start: don't re-boot on reset
* Coco3 enters this code with TR=1 and the MMU mappings set thus:
* TR=0: map 0-7: $??,$39,$3A,$3B,$3C,$3D,$3E,$3F
* TR-1: map 0-7: $38,$30,$31,$32,$33,$3D,$35,$3F
*
* Enter krn with TR=0. Only 2 (TR=0) mappings need to be set up:
* Physical RAM block $3F mapped to the top of memory (already by default)
* Physical RAM block $0  mapped to the bottom of memory.
*
* RAM block 0 about to get mapped. TR set to 0 by the GIME setup below.
                    clr       >DAT.Regs+0         map RAM block 0 to block 0 in DAT
                    lds       #$1FFF              set stack to the end of the block
                    stb       ,-s                 save status of start, $00=cold, $01=warm
* This is done so I can tell what went on in the direct page if there's
* a crash. 0(crash) 1(reset) -1(startup)
                    beq       Cont                --don't clear out direct page if it's a crash
* BGP 12/24/2009: clear out ALL of direct page (even $00-$1F). NOTE: IF USING
* RAMMER/MD (SEE BELOW) WHERE ONE CAN BOOT BACK UP TO NITROS9 FROM RAM DRIVE,
*   SWITCH BACK.
*         ldb   #$20         start out at $20
                    clrb
                    tfr       d,x                 here, too
L0072               sta       ,x+                 clear out the direct page
                    incb                          Boot won't be using any of it!
                    bne       L0072               BUT RAMMER/MD DOES!!!
                    inc       <D.Speed            0+1=1; high speed
Cont                clrb                          --make sure B=0
                    stb       >$FFD9              set to high speed
                    IFNE      GIMEX
                    ldb       #$5a                GimeX 2.86 mhz mode
                    stb       >$FFD9
* Should bump up D.Speed to 2 for 2.86 Mhz as well
                    ELSE
                    IFNE      MATCHBOX
                    ldb       #$9b                set Matchbox to RAM/CPU Throttle to 7mhz
                    stb       >$FF11
                    ENDC
                    ENDC
                    leay      <L001F,pcr          point to the video setup data
                    ldx       #$0090              set video mapping
                    deca                          now D=$FF00, versus STU >-$0100,x (saves 1 byte)
                    clrb
* Copy setup data to (1) the GIME at $FF90-$FFA0 and (2) shadow copy
* in the direct page at $0090 (D.HINIT etc).
L0084               ldu       ,y++                get the bytes
                    stu       d,x                 save in the hardware
                    stu       ,x++                and in the direct page
                    cmpx      #$00A0              end of video hardware yet?
                    blo       L0084
                    ldd       #$013f              color 0=$3F, 1=$01, i.e. white on dark blue
                    std       >$FFB0              set only the first two palettes, B=$00 already
                    lda       #Bt.Block
                    sta       >$FFA4              map in the block
                    ldx       #$8000              start of the block
                    IFNE      H6309
*         ldq   #(Bt.Flag*65536+8)
                    fcb       $cd
                    fdb       Bt.Flag
                    fdb       8
                    ELSE
                    ldd       #Bt.Flag
                    ENDC
                    tst       ,s                  check status : 0(crash) 1(reset) -1(startup)
                    bmi       StoreQ              if NOT a crash or reset, start at the start...
                    cmpd      ,x                  are they the same?
                    beq       MoveTxt             don't bother clearing the screen if it's there
StoreQ
                    IFNE      H6309
                    stq       ,x                  otherwise save the bytes on-screen
                    ELSE
                    std       ,x
                    ldd       #8
                    std       2,x
                    ENDC
                    leax      8,x                 point to the start of the screen in memory
                    IFNE      H6309
                    ldw       #$2000-8            clear out the entire block of memory
                    leau      <L00E0,pcr          point to $20, a space
                    tfm       u,x+                clear out the screen
                    ELSE
                    ldy       #$2000-8            clear out the entire block memory
                    ldb       #$20                Space character to clear with
ClrLoop             stb       ,x+
                    leay      -1,y
                    bne       ClrLoop
                    ENDC

MoveTxt             leau      <L0011,pcr          point to OS-9 Welcome Message
                    bsr       Move1               E=$00 already from TFM above...
* 0  = crash
* 1  = reset
* -1 = startup
                    ldb       ,s+                 check state of boot
                    bne       L00E2               if OK, continue
* U=<L0019 already from TFM above (call to L00FD)
                    bsr       Move1               move it on-screen, E=$00 already
                    clr       >$FF40              turn off disk drives
L00E0               bra       L00E0               loop forever

* Copy text to boot screen
* Entry: U=ptr to text block:
*          2 byte
Move1               ldy       ,u++                get where to put the text
                    IFNE      H6309
Move                ldf       ,u+                 get the size of the block to move into W
L00FD               tfm       u+,y+
                    ELSE
* If entered here:
*   U=src ptr
*   Y=dest ptr
*   X=size of copy
Move                clra                          D=size of block to copy
                    ldb       ,u+                 Get size of the block to move into U
                    tfr       d,x                 Move to counter
L00FD               lda       ,u+                 Copy X bytes from U to Y
                    sta       ,y+
                    leax      -1,x
                    bne       L00FD
                    ENDC
                    rts

L0011               fdb       (ScStart+(BOOTLINE*Width)+((Width-L1)/2))
                    fcb       L1                  length of the text below

T1                  fcc       /NITRO/
                    IFNE      GIMEX
                    IFNE      H6309
                    fcc       /63 /
                    ELSE
                    fcc       /68 /
                    ENDC
                    fcc       /GIMEX/
                    ELSE
                    fcc       /S9 /
                    IFNE      H6309
                    fcc       /6309/
                    ELSE
                    fcc       /6809/
                    ENDC
                    ENDC
L1                  equ       *-T1
                    fdb       ScStart+((BOOTLINE+2)*Width)+((Width-LFail)/2)
                    fcb       LFail               length of the 'FAILED' string
TFail               fcc       /FAIL/
                    IFEQ      GIMEX
* Had to do this to make REL fit for GIMEX versions
                    fcc       /ED/
                    ENDC
LFail               equ       *-TFail

* saves 2 bytes over leax <L00E2,pc, cmpx #Bt.Start
L00E2               tfr       pc,d                get the address at which we're executing
                    cmpa      #$26                the bootfile starts out at $2600
                    bne       L0101               if not at $26xx, continue with booting
                    ldu       #$2600              else move rel, Boot, krn over
                    IFNE      H6309
                    ldw       #$1200              size of track 34 boot file
                    ELSE
                    ldx       #$1200              size of track 34 boot file
                    ENDC
                    ldy       #Bt.Start           where to put it
                    bsr       L00FD               1 byte smaller than tfm in place
                    jmp       >Offset+L0101

BtDebug             pshs      cc,d,x              save the register
                    orcc      #IntMasks           turn IRQ's off
                    ldb       #Bt.Block           block to map in
                    stb       >DAT.Regs+0         map the boot screen into block 0
                    ldx       >$0002              where to put the bytes
                    sta       ,x+                 put the character on-screen
                    stx       >$0002              save updated address
                    clr       >DAT.Regs+0         map block 0 in again
                    puls      cc,d,x,pc           restore X and exit

L0101               lda       #$7E                JMP opcode
                    sta       <D.BtBug
                    leax      <BtDebug,pc         point to debug routine
                    stx       <D.BtBug+1
                    leau      <R.Crash,pcr        point to D.Crash, D.CBStart
                    ldy       #D.Crash            move it over
                    bsr       Move                E=$00 from call to L00FD above.
                    IFNE      H6309
                    ldmd      #$03                go to native mode, FIRQ saves all registers (NEED TO CHANGE WHEN SOUND DRIVER DONE)
                    inc       <D.MDREG            0+1=1; set MD shadow register (clr'd from above)
                    ENDC
                    ldx       #$F000              we KNOW where krn starts in memory
                    ldd       M$Exec,x            get execution start address
                    jmp       d,x                 jump to it

* D.Crash
R.Crash             fcb       $10                 size of the data to move over - 6 for D.Crash, $B for D.CBStrt
L003F               clr       >$FF91              go to map type 0 - called by CC3Go from map 1
                    jmp       >Offset+crash

                    fcb       $00                 warm start flag
                    fdb       $0074               go to $0074, next routine

* reset vector: map ROMs out and go to REL in the default DECB block map,
* which is still block $3F at the top of memory
                    nop       required            for the ROMs to believe it's a reset vector
                    clr       >$FFDF              go to all RAM mode
                    jmp       >Offset+reset       and re-start the boot

* Filler to get to a total size of $130. XX.Size is bytes at the start of
* this file - before the module header. 3 is bytes after this filler - the
* end boilerplate for the module.
*Filler   fill  $39,$130-XX.Size-3-*
                    IFNE      H6309
                    IFNE      GIMEX
* 6309+GIMEX
                    fcb       $39,$39
                    ELSE
* 6309 regular GIME
                    fcb       $39,$39,$39,$39,$39,$39
                    ENDC
                    ELSE
                    IFNE      GIMEX
* 6809+GIMEX
                    ELSE
                    IFNE      MATCHBOX
* 6809+MATCHBOX
                    ELSE
* 6809, regular GIME
                    fcb       $39,$39,$39,$39
                    ENDC
                    ENDC

                    ENDC
                    ENDC      match               IFNE mc09
                    ELSE      match               IFGT Level-1

*************************************************************************
** Start of Level1 code
**
** The boot-loader loads the "kernelfile" from track34 of the disk into
** memory at $26xx and then jumps into it at address $2602. The
** kernelfile is formed by concatenating modules REL, BOOT, KRN,
** KRNP2, INIT -- and maybe others, depending upon the hardware
** configuration.
** The entry point jumps via the REL module header to label "start".
**
** One function of REL is to copy the kernelfile from $26xx to high
** memory (specifically, to Bt.Start). Bt.Size ($1000-$1080) bytes are
** copied.
**
** Unlike the Level2/Level3 case, the size of each of the modules in the
** kernelfile is not padded.
**
** When REL starts, it has NO STACK
*************************************************************************

*************************************************************************
* Entry point for Level1 (all platforms) ********************************
*************************************************************************

Start
                    IFNE      mc09
                    leax      <BootMsg,pcr
outbsy              lda       VDUSTA
                    bita      #2
                    beq       outbsy
                    lda       ,x+
                    beq       done
                    sta       VDUDAT
                    bra       outbsy

done
                    ELSE      match               IFNE mc09

                    clr       PIA0Base+3

                    IFNE      (tano+d64+dalpha)
                    clr       PIA0Base+1          added for Dragon, works on CoCo
                    ENDC
                    IFNE      H6309
                    ldmd      #3                  native mode
                    ENDC

                    sta       $FFDF               turn off ROM
* locate Boot Text Screen at $8000
                    ldb       #$06
                    ldx       #$FFC6
L262B               sta       ,x++
                    decb
                    bne       L262B
                    sta       1,x

                    IFNE      dalpha
                    clr       $ffc0               Reset to text mode if Dragon Alpha
                    clr       $ffc2
                    clr       $ffc4

                    lda       $ff22
                    anda      #$07
                    sta       $ff22
                    ENDC

* Clear VDG screen
                    ldx       #ScStart
                    ldy       #512
                    lda       #$60
L263B               sta       ,x+
                    leay      -1,y
                    bne       L263B

* Copy "NITROS9 BOOT" to screen area
                    ldx       #ScStart+$10A
                    leay      <BootMsg,pcr
                    ldb       #BootMLen
L2649               lda       ,y+
                    sta       ,x+
                    decb
                    bne       L2649

                    IFNE      (tano+d64+dalpha)
                    tst       <$72
                    ELSE
                    ldd       #$1212
                    cmpd      <$0078
                    ENDC

                    beq       L266E

                    ENDC      match               IFNE mc09

* Copy boot track from $2600 to $EE00 - not quite all of it though. The whole boot
* track is $1200 bytes and would take us right up to $FFFF. We actually copy up to
* $FE80.
                    leau      >Begin-XX.Size,pcr
                    ldx       #Bt.Size
                    ldy       #Bt.Start
L2663               lda       ,u+
                    sta       ,y+
                    leax      -1,x
                    bne       L2663

* go to L266E but in high memory
                    jmp       >Offset+L266E

* now executing in high memory. Compute the absolute address of the entry
* point of the next module (which must be krn) and go there.
L266E               leax      <eom,pcr
                    ldd       M$Exec,x
                    jmp       d,x

BootMsg
                    IFNE      mc09
                    fcc       / Boot /
                    fcb       0
                    ELSE
                    IFEQ      dalpha              save some bytes on Dragon Alpha
                    fcc       /NITROSy/
                    fcb       $60
                    ENDC
                    fcc       /BOOT/
BootMLen            equ       *-BootMsg
                    ENDC      match               IFNE mc09

                    ENDC      match               IFGT Level-1

                    emod
eom                 equ       *
                    end

