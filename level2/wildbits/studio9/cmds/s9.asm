********************************************************************
* s9 - Studio-9 main program (NitrOS-9 Level 2, Foenix WildBits K2/Jr2)
* Ported from UltiMusE III v10.11.4e by Mike Knudsen (CMDS/UMusE3 of the 2016 distribution disk):
* disassembled with os9dis.py, then changed by hand; it no longer matches the original module.
* Routine names come from Knudsen's C source (bmuse.c bt.c bin.c bfm.c bch.c bn.c bs.c bm.c bpl.c bgr.c
*   bcu.c bsys.c brm.c bms.c bti.c bv.c; klib for the library), matched through the vector table bin.c
*   fills ($0351-$03B5), string literals, call sequences and link order. Lxxxx labels and guessed names
*   mark code the v09 source lacks or that could not be tied down; "(was Lxxxx)" keeps the original
*   module offset and "[reading uncertain]" marks a reading the evidence did not settle.
* Local labels a<n>@, b<n>@ ...: the letter is the label, n the routine (lwasm has no per-routine scope).
*
* Structure: Microware-C code. The C startup copies the initialized data image (InitDataImage),
* relocates pointers, parses the parameter line and calls main. sysup forks the renderer s9gui with a
* /pipe on its stdin and makes that pipe path 1, so every printf/putc is a command stream to s9gui
* (one-byte command codes >= $80 through the DP format pointers, plus binary packets built at $0095
* and sent with nfwrite). The score is a list of 8-byte events (0 = part or 0 for markers, 1-2 =
* start ticks, 3-4 = duration code/shift, 5 = pitch or marker subtype) stored 928 per $1D00-byte
* page (i2p/plusplus/decdec, pswap, makepage). Globals: <nevents, <curind, <curevp, <nparts,
* <nstaves, <curcurse (edit mode), <rfr_scr (redraw), $0BEB score name, $0C19 staff table,
* $0425/$05C2 per-event screen x/y. The command loop (MainLoop, mainmen) handles keys, mouse clicks
* (mouce) and menus (menu3), and hands load/save/MIDI/print/etc. to the overlays s9b..s9y through
* soowee (links "s9x", calls its entry with a command letter, unlinks, relinks the previous one);
* the overlays share the vector table uinit fills ($0351-$03B5). The module tail is the C library:
* printf engine, stdio FILE code ($01B1 = _iob, 13 bytes each), string/memory helpers, 16/32-bit
* arithmetic and the OS-9 system-call wrappers (errno at $034F).
* Data addressing is left numeric (offsets into the data area, <$xx = direct page). fcb lines inside
* code carry the decoded mnemonic as a comment where lwasm cannot reproduce the original encoding.

                    nam       UMusE3
                    ttl       UMusE3 (disassembly)

                  IFP1
                    use       defsfile
                  ENDC

UME_SCOPE_UMUSE3                equ       1
                    use       equates.asm         definitions shared by every s9 module
tylg                set       $11
atrv                set       $81
size                equ       $1F60               do not grow: a larger data area gave E$MemFul (207)

* Direct-page names follow bdp.c's declaration order anchored on curevp = <$23 (10.11 has two bytes
* more than v09 between pitcarry and xyoff, so from xyoff on everything is +2; moldx/moldy stay
* numeric). Globals follow bglob.c anchored on kpind = $03D6; vectors follow fcnptrs.h from $0351,
* with 10.11's 'beep' entry before pflush. The printf formats for s9gui commands (pct2..pct7,
* pctn1..pctn6) are in equates.asm.


* ------------------------------------------------------------------------------------------------
* PAGE MAPPER. UltiMusE kept its score pages and event array in CoCo3 window get/put buffers
* ($1B $29 / $1B $2A escapes, SS.MpGPB); WildBits vtio has none of that, so makepage, killpage and
* MapGPBuffer are rebuilt on F$AllRAM (one 8K block per buffer), F$MapBlk, F$ClrBlk and F$DelRAM.
* One buffer is mapped at a time: the module and its data fill most of the eight DAT slots, so
* MapGPBuffer unmaps the current page before it maps the next. The block table GPTab is at $1000,
* above every static and below the stack.
* A page holds 928 events = $1D00 bytes (the original held 1020 = $1FE0): slot 7 hides its top
* three pages ($FD00-$FFFF), so a $1D00-byte page maps safely into any slot. The constant appears in
* i2p's divide, pswap's page end and the last-slot offsets in remove and makroom here, in every
* overlay's copy of the divide, and in s9d's file chunk size.

                    mod       eom,name,tylg,atrv,start,size
name                fcs       /s9/
                    fcb       $01
* CopyInitData (was L0014): copies X bytes from the init image (Y) into the data area (U); called twice by the C startup
CopyInitData        lda       ,y+
                    sta       ,u+
                    leax      -1,x
                    bne       CopyInitData
                    rts
start               equ       *
                    pshs      y
                    pshs      u
                    clra
                    clrb
a1@                 sta       ,u+
                    decb
                    bne       a1@
                    ldx       ,s
                    leau      ,x
                    leax      >$0CE0,x
                    pshs      x
                    leay      >InitDataImage,pcr
                    ldx       ,y++
                    beq       b1@
                    bsr       CopyInitData
                    ldu       2,s
b1@                 leau      >$00F7,u
                    ldx       ,y++
                    beq       c1@
                    bsr       CopyInitData
                    clra
c1@                 cmpu      ,s
                    beq       d1@
                    sta       ,u+
                    bra       c1@
d1@                 ldu       2,s
                    ldd       ,y++
                    beq       e1@
                    leax      >ModuleBase,pcr
                    lbsr      RelocPointers
e1@                 ldd       ,y++
                    beq       f1@
                    leax      ,u
                    lbsr      RelocPointers
f1@                 leas      4,s
                    puls      x
                    stx       >$0341,u
                    sty       >$0301,u
                    ldd       #$0001
                    std       >$033D,u
                    leay      >$0303,u
                    leax      ,s
                    lda       ,x+
g1@                 ldb       >$033E,u
                    cmpb      #$1D
                    beq       CallMain
h1@                 cmpa      #$0D
                    beq       CallMain
                    cmpa      #$20
                    beq       i1@
                    cmpa      #$2C
                    bne       j1@
i1@                 lda       ,x+
                    bra       h1@
j1@                 cmpa      #$22
                    beq       k1@
                    cmpa      #$27
                    bne       n1@
k1@                 stx       ,y++
                    inc       >$033E,u
                    pshs      a
l1@                 lda       ,x+
                    cmpa      #$0D
                    beq       m1@
                    cmpa      ,s
                    bne       l1@
m1@                 puls      b
                    clr       -1,x
                    cmpa      #$0D
                    beq       CallMain
                    lda       ,x+
                    bra       g1@
n1@                 leax      -1,x
                    stx       ,y++
                    leax      1,x
                    inc       >$033E,u
o1@                 cmpa      #$0D
                    beq       p1@
                    cmpa      #$20
                    beq       p1@
                    cmpa      #$2C
                    beq       p1@
                    lda       ,x+
                    bra       o1@
p1@                 clr       -1,x
                    bra       g1@
* CallMain (was L00E0): startup tail: pushes argc/argv, InitStackCheck, lbsr main, then exit(0) via ExitProg
CallMain            leax      >$0301,u
                    pshs      x
                    ldd       >$033D,u
                    pshs      a,b
                    leay      ,u
                    bsr       InitStackCheck
                    lbsr      main
                    clr       ,-s
                    clr       ,-s
                    lbsr      ExitProg
* InitStackCheck (was L00FA): sets heap top ($034B), stack base ($033F) and stack low-water mark ($034D) used by StackCheck
InitStackCheck      leax      >UmeStaticEnd,y      reserve port statics before the C heap
                    stx       >$034B,y
                    sts       >$033F,y
                    sts       >$034D,y
                    ldd       #$FF82
* StackCheck (was L010F): leax d,s and compares against the low-water/heap marks; falls into StackOverflow when the stack would hit the heap
StackCheck          leax      d,s
                    cmpx      >$034D,y
                    bhs       a2@
                    cmpx      >$034B,y
                    blo       StackOverflow
                    stx       >$034D,y
a2@                 rts
* msgStackOverflow (was L0122): 'STACK OVERFLOW' CR
msgStackOverflow    fcc       /STACK OVERFLOW/
                    fcb       $0D
* StackOverflow (was L013B): writes msgStackOverflow to path 2 and exits with status $00CF
StackOverflow       leax      <msgStackOverflow,pcr
                    ldb       #$CF
                    pshs      b
                    lda       #$02
                    ldy       #$0064
                    os9       I$WritLn
                    clr       ,-s
                    lbsr      ExitNow
                    ldd       >$033F,y
                    subd      >$034D,y
                    rts
                    fcb       $EC,$A9,$03,$4D,$A3,$A9,$03,$4B
                    fcb       $39
* RelocPointers (was L0162): walks a list of offsets from the init image adding the data/code base to each pointer (startup relocation)
RelocPointers       pshs      x
                    leax      d,y
                    leax      d,x
                    pshs      x
* RelocLoop (was L016A): loop head of RelocPointers
RelocLoop           ldd       ,y++
                    leax      d,u
                    ldd       ,x
                    addd      2,s
                    std       ,x
                    cmpy      ,s
                    bne       RelocLoop
                    leas      4,s
                    rts
L017C               equ       *
                    fcb       $54,$72,$65,$62,$6C,$65
                    fcb       $00
L0183               equ       *
                    fcb       $42,$61,$73,$73
                    fcb       $00
L0188               equ       *
                    fcb       $47,$75,$69,$54,$65,$6E,$6F,$72
                    fcb       $00
L0191               equ       *
                    fcb       $44,$62,$6C,$20,$42,$61,$73,$73
                    fcb       $00
L019A               equ       *
                    fcb       $50,$65,$72,$63,$75,$73,$73,$6E
                    fcb       $00
L01A3               equ       *
                    fcb       $41,$6C,$74,$6F
                    fcb       $00
L01A8               equ       *
                    fcb       $54,$65,$6E,$6F,$72
                    fcb       $00
L01AE               equ       *
                    fcb       $00
L01AF               equ       *
                    fcb       $70,$70,$70
                    fcb       $00
                    fcc       / pp/
                    fcb       $00
                    fcc       /  p/
                    fcb       $00
                    fcc       / mp/
                    fcb       $00
                    fcc       / mf/
                    fcb       $00
                    fcc       /  f/
                    fcb       $00
                    fcc       / ff/
                    fcb       $00
                    fcc       /fff/
                    fcb       $00
L01CF               equ       *
                    fcb       $4B,$69,$63,$6B,$20,$44,$72,$75,$6D
                    fcb       $00
L01D9               equ       *
                    fcb       $53,$69,$64,$65,$73,$74,$69,$63,$6B
                    fcb       $00
L01E3               equ       *
                    fcb       $53,$6E,$61,$72,$65
                    fcb       $00
L01E9               equ       *
                    fcb       $48,$69,$48,$61,$74,$20,$43,$6C,$73,$64
                    fcb       $00
L01F4               equ       *
                    fcb       $48,$69,$48,$61,$74,$20,$4F,$70,$65,$6E
                    fcb       $00
L01FF               equ       *
                    fcb       $4C,$6F,$77,$20,$20,$54,$6F,$6D
                    fcb       $00
L0208               equ       *
                    fcb       $4D,$69,$64,$20,$20,$54,$6F,$6D
                    fcb       $00
L0211               equ       *
                    fcb       $48,$69,$67,$68,$20,$54,$6F,$6D
                    fcb       $00
L021A               equ       *
                    fcb       $43,$6F,$77,$20,$42,$65,$6C,$6C
                    fcb       $00
L0223               equ       *
                    fcb       $43,$72,$61,$73,$68,$20,$31
                    fcb       $00
L022B               equ       *
                    fcb       $52,$69,$64,$65,$20,$31
                    fcb       $00
L0232               equ       *
                    fcb       $43,$68,$69,$6E,$61
                    fcb       $00
L0238               equ       *
                    fcb       $43,$72,$61,$73,$68,$20,$32
                    fcb       $00
L0240               equ       *
                    fcb       $52,$69,$64,$65,$20,$42,$65,$6C,$6C
                    fcb       $00
L024A               equ       *
                    fcb       $54,$61,$6D,$62,$6F,$75,$72,$69,$6E,$65
                    fcb       $00
L0255               equ       *
                    fcb       $4C,$6F,$20,$42,$6F,$6E,$67,$6F
                    fcb       $00
L025E               equ       *
                    fcb       $48,$69,$20,$42,$6F,$6E,$67,$6F
                    fcb       $00
                    use       Palette.asm         UmePalette, the sixteen CLUT 0 colors

* InitCodecAIN - enable all five WM8776 analog input lines.
* R21's AMX field is bits 4..0, one bit per AIN1..AIN5. $2A is register 21 with data bit 8 clear;
* $1F selects every input. The codec port is fixed I/O and needs no process-page mapping.
InitCodecAIN        ldx       #CODEC.Base
codecwait@          lda       CODECCtrl,x
                    lsra
                    bcs       codecwait@
                    lda       #$2A                WM8776 R21 command/register bits
                    sta       CODECCmdHi,x
                    lda       #$1F                AMX = AIN1|AIN2|AIN3|AIN4|AIN5
                    sta       CODECCmdLo,x
                    lda       #$01
                    sta       CODECCtrl,x          start the codec write
                    rts

* main (was L0267): releases the tail blocks, sets up the screen, installs breaker (F$Icpt), sysup, greeting, then MainInit/MainLoop
main            pshs      u
                    leas      <-$62,s
* The module is seven blocks: five of code, then UmeSymbols16 bank 1, the start-up data image and
* TailInit in block 6, and UmeSymbols16 bank 2 in block 7 (the tail of this file). F$Fork maps it
* all (data in slot 0, the module in 1-7, the map full), so the two tail blocks are released first:
* TailInit (in block 6, so it runs before the F$ClrBlk) puts their block numbers in FranParam for
* s9gui's fork, and s9gui copies the symbol banks out. They stay the module's memory until exit.
                    lbsr      TailInit
                    leau      >TailBlock6,pcr
                    ldb       #2
                    os9       F$ClrBlk
                    clra
                    clrb
* Zero the page mapper's bookkeeping: OS-9 does not clear the data area, and a stale GPMapped/GPAddr
* would make the first GPUnmap clear a live slot. makepage takes a zero GPTab entry as 'no block yet'.
                    std       >GPMapped           nothing mapped
                    std       >GPAddr
                    ldx       #GPTab
gpz1@               sta       ,x+
                    cmpx      #GPTab+GPTABSZ
                    bne       gpz1@
                    bsr      InitCodecAIN
* Screen set-up comes first so every launch takes the same top-of-RAM blocks: SS.AScrn wants ten
* free blocks in a row (F$AlHRAM). E$WADef means bitmap 0 survives from an earlier run and vtio has
* put its block in X; it is used again. The bitmap is never freed: s9gui may still be drawing when
* this process exits. Any other error skips the rest of the screen set-up (s9gui reports its own
* SS.AScrn failure).
* Y is the C static base; it is saved because the set-up calls below load Y.
                    pshs      y,u
                    lda       #$02                path 2 = /term
                    ldb       #SS.AScrn
                    ldx       #$0000              type 0: 320x240, ten blocks
                    ldy       #$0000              bitmap 0
                    os9       I$SetStt
                    bcc       bm1@
                    cmpb      #E$WADef            still allocated from an earlier run: X = its block
                    beq       bm1@
                    lbra      bm9@
bm1@                equ       *
                    lda       #$02
                    ldb       #SS.PScrn           layer 0 = bitmap 0
                    ldx       #$0000
                    ldy       #$0000
                    os9       I$SetStt
* Score paper RGB 233,234,231 (#E9EAE7). Bitmap nibble 0 is transparent in VICKY, so the paper
* color is the graphics backdrop, not CLUT entry 0.
                    ldd       #$E7EA              blue $E7, green $EA
                    std       >VKY.BackdropB
                    lda       #$E9                red $E9
                    sta       >VKY.BackdropR
* Hide layers 1 and 2 (no plane, source 7): a bitmap another program left there (shellbg uses bitmap
* 2 on layer 2) would show through every paper dot. The layers go through grfdrv256 SS.PScrn, which
* keeps them per terminal; the layer register is read once (the driver has no getter) so exit can
* restore it the same way.
                    ldd       >VKY_LAYER_CTRL_0   L0/L1 byte, L2 byte (read only)
                    std       >LayerSave
                    pshs      u
                    lda       #$02                layer 1 = no plane (source 7)
                    ldb       #SS.PScrn
                    ldx       #$0001
                    ldy       #$0007
                    os9       I$SetStt
                    lda       #$02                layer 2 = no plane
                    ldb       #SS.PScrn
                    ldx       #$0002
                    ldy       #$0007
                    os9       I$SetStt
bm1hidefail@        puls      u
* CLUT 0 entries 0-15 come from UmePalette through SS.ClutWrite (grfdrv keeps the CLUTs per
* terminal); entry 0 is transparent. HIRES4 is bitmap 0's own bit, set through SS.BmCfg; with
* palette group 0 it shows CLUT entries 0-15 only.
                    pshs      u
                    lda       #$02
                    ldb       #SS.ClutWrite
                    leax      >UmePalette,pcr     16 entries x 4 bytes
                    ldy       #$0000              CLUT 0, from entry 0
                    ldu       #16
                    os9       I$SetStt
                    lda       #$02                bitmap 0: on, CLUT 0; HIRES4 on, palette group 0
                    ldb       #SS.BmCfg
                    ldx       #$0100
                    ldy       #$0000
                    ldu       #$0100
                    os9       I$SetStt
                    puls      u
bm9@                puls      y,u
* mouce's tick source: entry 0 of the system process's DAT image maps the kernel's direct page,
* where D.Sec/D.Tick live.
                    pshs      y,u
                    leas      >-P$Size,s          room for the descriptor copy
                    clra
                    clrb
                    std       >MsSysDAT           no image until F$GPrDsc says so
                    clr       >MidiInPath
                    std       >MsPrevBtn          level 0, stamp 0
                    std       >MsStamp+1          (stamp low byte, MsLast)
                    std       >MsRightPrev        right button: level 0, nothing pending
                    std       >MsModeSave
                    ldd       #-1
                    std       >MenuBarHover
                    lda       #$01                the system process
                    leax      ,s
                    os9       F$GPrDsc
                    bcs       sd1@
                    ldd       P$DATImg,x          its block 0
                    std       >MsSysDAT
sd1@                leas      >P$Size,s
                    puls      y,u
                    clra
                    clrb
                    std       <$37,s
                    ldd       #$0001
                    std       <broke
                    leax      >breaker,pcr
                    pshs      x
                    lbsr      SetIntercept
                    leas      2,s
                    ldd       >UmeData_reserved_01C4
                    orb       #$80
                    std       >UmeData_reserved_01C4
                    lbsr      sysup
                    lbsr      greeting            the welcome box
                    bra       MainInit
* MainRestart (was L028E): the original restart re-entry (resets S, falls into MainInit); unreferenced
MainRestart         leas      <-$62,x
* MainInit (was L0291): initializes flags and the synth name 'gm', probes /N (DriveWire) into <$51, reads SYS/UM3.Init (prefio), sets colors
MainInit            lbsr      instinit
                    lbsr      MidiInitRoutes
                    lbsr      PianoHookInstall    every playback route must pass through the key highlighter
                    clra
                    clrb
                    stb       <$40,s
                    stb       >UmeData_reserved_0BEB
                    ldd       #$0001
                    stb       <readonly
* Default MIDI output: the SAM2695 synth through the MIDI UART (s9p's 'MIDI Pak' path, <midipak),
* not a DriveWire /MIDI device (<mididev).
                    stb       <midipak                hardware MIDI out by default
                    clr       <mididev                no /MIDI device path by default
                    stb       <clocken
                    stb       <midievts
                    stb       <instren
                    clra
                    ldb       #1
                    stb       <midiser            SAM2695 output on by default
                    clrb
                    stb       <rfr_tit
                    stb       <automon
                    ldd       #$000D
                    stb       <midinnmin
                    ldd       #$006C
                    stb       <midinnmax
                    ldd       #$000C
                    stb       <accentwt
                    ldd       #$FFFF
                    stb       <hires
                    stb       <left
                    ldb       #1
                    stb       <halfstaf           gray (alternate-dot) staff lines by default
                    clra
                    clrb
                    std       <forergb
                    ldd       #$003F
                    std       <backrgb
                    ldd       #$0001
                    stb       >UmeData_reserved_03C3
                    clra
                    clrb
                    stb       >UmeData_reserved_03B7
                    ldd       #$000B
                    pshs      a,b
                    ldx       #$03B8
                    pshs      x
                    lbsr      MemClear
                    leas      4,s
                    ldd       #$0002
                    pshs      a,b
                    leax      >strGm,pcr
                    pshs      x
                    ldx       #$03B8
                    pshs      x
                    lbsr      StrCopy
                    leas      6,s
* Probe the DriveWire network device /N once: <$51 = 1 when it opens, 0 when it does not (no N in
* the bootfile, or no DriveWire server). s9w's DW4 dialogs and s9u's update read it. OpenPath
* returns -1 on failure.
                    ldd       #$0003
                    pshs      a,b
                    leax      >pathDevN,pcr
                    pshs      x
                    lbsr      OpenPath
                    leas      4,s
                    clr       <UmeData_reserved_0051
                    cmpd      #-1
                    beq       b3@                 no /N: nothing DriveWire is offered
                    pshs      a,b
                    lbsr      ClosePath
                    leas      2,s
                    ldb       #1
                    stb       <UmeData_reserved_0051
b3@                 ldd       #$0072
                    pshs      a,b
                    lbsr      prefio
                    leas      2,s
                    ldd       <backrgb
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    lbsr      pal
                    leas      4,s
                    ldd       <forergb
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    lbsr      pal
                    leas      4,s
                    ldd       #$0001
                    bra      m3@
c3@                 ldd       <$13,s
                    aslb
                    rola
                    ldx       <$68,s
                    leax      d,x
                    ldd       ,x
                    std       <$3E,s
                    ldb       [<$3E,s]
                    cmpb      #$2D
                    bne       i3@
                    bra       h3@
d3@                 ldb       2,s
                    sex
                    tfr       d,x
                    bra       g3@
e3@                 clra
                    clrb
                    stb       <midiser
                    ldd       #$0001
                    stb       <midipak
                    bra       h3@
f3@                 ldd       #$0001
                    stb       <readonly
                    bra       h3@
g3@                 cmpx      #$0070
                    beq       e3@
                    cmpx      #$0072
                    beq       f3@
h3@                 ldx       <$3E,s
                    leax      1,x
                    stx       <$3E,s
                    ldb       ,x
                    stb       2,s
                    bne       d3@
                    bra       l3@
i3@                 ldb       >UmeData_reserved_0BEB
                    bne       j3@
                    ldd       <$3E,s
                    pshs      a,b
                    ldx       #$0BEB
                    bra       k3@
j3@                 ldd       <$3E,s
                    pshs      a,b
                    leax      <$42,s
k3@                 pshs      x
                    lbsr      StrCopy
                    leas      4,s
l3@                 ldd       <$13,s
                    addd      #$0001
m3@                 std       <$13,s
                    ldd       <$13,s
                    cmpd      <$66,s
                    blt      c3@
                    lbsr      uinit
* Overlay callbacks (especially pputchar) must exist before drive enumeration.
                    ldd       #'m
                    pshs      d
                    ldd       #'G
                    pshs      d
                    lbsr      soowee
                    leas      4,s
                    lbsr      MidiApplyMix        apply the initialized/restored SAM audio setting
                    clra
                    clrb
                    pshs      a,b
                    lbsr      newscore
                    leas      2,s
* The score named on the command line, or the sample s9g 'm' put in the name buffer, loads here,
* under the greeting box, before the prompt appears.
                    ldb       >UmeData_reserved_0BEB
                    beq       p3@
                    clra
                    clrb
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0075
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldx       #$0BEB
                    pshs      x
                    ldd       #$0064
                    pshs      a,b
                    ldd       #$0044
                    pshs      a,b
                    lbsr      soowee
                    leas      14,s
                    std       -2,s
                    beq       o3@
                    lbsr      reinit
                    ldb       <$40,s
                    beq       q3@
                    leax      <$40,s
                    pshs      x
                    ldx       #$0BEB
                    pshs      x
                    lbsr      StrCopy
                    leas      4,s
                    bra       q3@
o3@                 clra
                    clrb
                    stb       >UmeData_reserved_0BEB
* No startup menu: start-up goes straight to the score screen.
p3@                 equ       *
q3@                 equ       *
                    ldd       <curcurse
                    bne       n3@
                    lbsr      hitenter
n3@                 lbsr      wkill
                    ldd       #$00BF
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    lbsr      SendMark2Packet
                    leas      4,s
                    ldd       #$0001
                    pshs      a,b
                    lbsr      curset
                    leas      2,s
                    ldd       #$0016
                    pshs      a,b
                    lbsr      curset
                    leas      2,s
                    ldx       #brush
                    stx       ,s
                    ldx       #$0110
                    pshs      x
                    ldx       #brush
                    pshs      x
                    lbsr      CopyNoteAttrs
                    leas      4,s
                    ldd       #$0001
                    stb       <rfr_bar
                    stb       <rfr_men
                    stb       <rfr_scr
                    stb       <rfr_rep
                    clr       >toolson            the toolbox starts off; 't' shows it
                    ldd       #$FFFF
                    std       <undind
                    ldd       #16
                    std       >ToolX
                    ldd       >ToolX
                    addd      #44
                    std       <$1B,s
                    ldd       #$0008
                    std       <$19,s
                    std       >UmeData_reserved_03C8
* MainLoop (was L048E): top of the command loop: redraw when <rfr_scr ($7C), then mouse/key handling
MainLoop            lbsr      ClearMenuBarHover
                    ldb       #$01                redraw the menu bar after every command
                    stb       <rfr_bar
                    ldd       >MsModeSave         a right-click borrowed the X tool: put the tool back
                    beq       ml0@
                    pshs      a,b
                    lbsr      curset
                    leas      2,s
                    clra
                    clrb
                    std       >MsModeSave
ml0@                ldb       <rfr_scr
                    bne       FocusRedrawReady
                    tst       >FocusDirty
                    beq       a4@
                    clr       >FocusDirty
                    ldd       #'f
                    pshs      d
                    ldd       #'S
                    pshs      d
                    lbsr      soowee
                    leas      4,s
                    bra       a4@
FocusRedrawReady    clr       >FocusDirty
* rfr_scr = RfrScrKeep asks for the sheet draw without its cls (s9s 'n'); the rest of the refresh is
* unchanged. The job letter is soowee's second argument, pushed first.
                    ldb       <rfr_scr
                    cmpb      #RfrScrKeep
                    bne       fullredraw@
                    ldd       #SJobRedrawKeep     'n': draw the sheet over what is there (a dropped note)
                    bra       jobset@
fullredraw@         ldd       #SJobRedraw         's': clear the sheet, then draw it
jobset@             pshs      a,b
                    ldd       #$0001
                    stb       <rfr_rep
                    stb       <rfr_men
                    lbsr      wkill
                    ldd       <nstaves
                    addd      #$FFFF
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    lbsr      dfalstvs
                    leas      4,s
                    ldd       #'S
                    pshs      a,b
                    lbsr      soowee              s9s: the job letter is the word under 'S'
                    leas      4,s
                    lbsr      SendCmd98
                    lbsr      SendViewRange
a4@                 ldb       <rfr_tit
                    beq       b4@
                    lbsr      ShowTextLines
b4@                 ldb       <rfr_bar
                    beq       c4@
                    lbsr      SendCmd97
c4@                 ldb       <rfr_men
                    beq       h4@
                    ldb       >toolson
                    beq       h4@
                    ldx       ,s
                    ldb       1,x
                    cmpb      #$03
                    bne       d4@
                    ldd       #$0001
                    bra       e4@
d4@                 clra
                    clrb
e4@                 pshs      a,b
                    ldx       2,s
                    ldb       2,x
                    cmpb      #$20
                    bne       f4@
                    ldd       #$0001
                    bra       g4@
f4@                 clra
                    clrb
g4@                 pshs      a,b
                    lbsr      SendCmd99
                    leas      4,s
h4@                 equ       *
                    ldb       <rfr_rep
                    beq       i4@
                    ldb       >toolson
                    beq       i4@
                    ldd       <$19,s
                    pshs      a,b
                    ldd       <$1D,s
                    pshs      a,b
                    lbsr      SendModeInfo
                    leas      4,s
i4@                 ldd       <$37,s
                    beq       l4@
                    ldd       <curcurse
                    cmpd      #$0016
                    beq       j4@
                    ldd       <curcurse
                    cmpd      #$000F
                    beq       j4@
                    ldd       <curcurse
                    cmpd      #$0008
                    bne       k4@
j4@                 ldd       #$00A8
                    pshs      a,b
                    ldd       #$0002
                    pshs      a,b
                    ldd       15,s
                    addd      #$FFF5
                    pshs      a,b
                    lbsr      ClampRange
                    leas      6,s
                    pshs      a,b
                    ldd       <$19,s
                    addd      #$FFFF
                    pshs      a,b
                    lbsr      SendModeInfo
                    leas      4,s
                    ldd       <$37,s
                    pshs      a,b
                    lbsr      TSleep
                    leas      2,s
                    lbsr      SendCmd93
k4@                 clra
                    clrb
                    std       <$37,s
l4@                 clra
                    clrb
                    stb       <rfr_tit
                    stb       <rfr_bar
                    stb       <rfr_men
                    stb       <rfr_rep
                    stb       <rfr_scr
                    bra       n4@
m4@                 ldd       <dntime
                    cmpd      #$0032
                    bgt       p4@
n4@                 leax      11,s
                    pshs      x
                    leax      15,s
                    pshs      x
                    lbsr      mouce
                    leas      4,s
                    std       -2,s
                    bne       m4@
                    bra       p4@
o4@                 leas      <-$62,x
p4@                 ldd       11,s
                    pshs      a,b
                    ldd       15,s
                    pshs      a,b
                    lbsr      DrawPointer
                    leas      4,s
                    ldd       #$0001
                    pshs      a,b
                    lbsr      automouse
                    leas      2,s
                    clra
                    clrb
                    std       <$25,s
q4@                 ldd       <$25,s
                    std       <$23,s
                    lbsr      keysense
                    std       <$25,s
                    leax      3,s
                    pshs      x
                    leax      7,s
                    pshs      x
                    lbsr      mouce
                    leas      4,s
                    std       9,s
                    ldd       3,s                 canvas row
                    pshs      d
                    ldd       7,s                 pointer X
                    pshs      d
                    lbsr      TrackMenuBarHover
                    leas      4,s
                    ldd       9,s
* A right-button press (mouce: MsRightNew) with the left button up opens the note context menu
* (overlay s9c, menu 'n', at the pointer). Only its Delete row ('d') goes on, as an X-tool click
* (mode 6: the note becomes a rest) at the press position (CtxX/CtxY). The tool in use is kept in
* MsModeSave and restored at the top of MainLoop. The timers are set to 'just pressed after a long
* release' so the click path below sees a plain click, not a drag.
                    bne       rq1@                the left button is down: its business
                    tst       >MsRightNew
                    beq       rq1@                no right press pending
                    clr       >MsRightNew
* The menu opens only when find() reports a score item under the press (not the toolbox, the bars
* or bare sheet).
                    ldd       #$0001
                    pshs      d                   loose
                    clra
                    clrb
                    pshs      d                   keys: none
                    ldd       7,s                 my (3,s before the two pushes)
                    pshs      d
                    ldd       11,s                mx (5,s before the three pushes)
                    pshs      d
                    lbsr      find
                    leas      8,s
                    tsta
                    bmi       rq1@                nothing under the press: no menu
                    ldd       5,s                 pointer X (640 dots) and row at the press
                    std       <CtxX
                    ldd       3,s
                    std       <CtxY
                    ldd       #'n
                    pshs      d
                    ldd       #'C
                    pshs      d
                    lbsr      soowee              s9c: B = 'd' for Delete, else closed
                    leas      4,s
                    cmpb      #'d
                    bne       rq1@                closed: 9,s is still 0, no click
                    ldd       <curcurse                the tool in use (the frame still holds the press position)
                    std       >MsModeSave         (6 put back as 6 is harmless)
                    ldd       #$0006
                    pshs      a,b
                    lbsr      curset
                    leas      2,s
rq0@                clra
                    clrb
                    std       <dntime                just pressed
                    ldd       #254
                    std       <uptime                long after the last release
                    ldd       #$0001
                    std       9,s                 the click
rq1@                ldb       <snap
                    beq      u4@
                    leas      -2,s
                    ldd       #$0001
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       9,s
                    pshs      a,b
                    ldd       13,s
                    pshs      a,b
                    lbsr      find
                    leas      8,s
                    std       <$33,s
                    blt       t4@
                    ldd       <$33,s
                    subd      <xyoff
                    ldx       #grafxes
                    leax      d,x
                    ldb       ,x
                    sex
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    std       7,s
                    ldd       <$33,s
                    subd      <xyoff
                    ldx       #grafyes
                    leax      d,x
                    ldb       ,x
                    clra
                    std       ,s
                    beq       r4@
                    ldd       ,s
                    std       5,s
                    ldd       7,s
                    addd      #$0007
                    bra       s4@
r4@                 ldd       7,s
                    addd      #$0003
s4@                 std       7,s
t4@                 leas      2,s
u4@                 ldd       5,s
                    asra
                    rorb
                    asra
                    rorb
                    asra
                    rorb
                    std       <$17,s
                    ldd       5,s
                    cmpd      13,s
                    bne       v4@
                    ldd       3,s
                    cmpd      11,s
                    beq       w4@
v4@                 ldd       11,s
                    pshs      a,b
                    ldd       15,s
                    pshs      a,b
                    lbsr      DrawPointer
                    leas      4,s
                    ldd       3,s
                    pshs      a,b
                    ldd       7,s
                    pshs      a,b
                    lbsr      DrawPointer
                    leas      4,s
                    ldd       5,s
                    std       13,s
                    ldd       3,s
                    std       11,s
                    bra       y4@
w4@                 lbsr      inkey
                    stb       2,s
                    beq       x4@
                    lbsr      ClearMenuBarHover
                    ldd       11,s
                    pshs      a,b
                    ldd       15,s
                    pshs      a,b
                    lbsr      DrawPointer
                    leas      4,s
                    leax      <$62,s
                    lbra      bq4@
x4@                 ldd       #$0003
                    pshs      a,b
                    lbsr      TSleep
                    leas      2,s
y4@                 ldd       9,s
                    lbeq      q4@
* Keep the clicked menu title inverted until MainLoop resumes.
                    ldd       11,s
                    pshs      a,b
                    ldd       15,s
                    pshs      a,b
                    lbsr      DrawPointer
                    leas      4,s
                    ldb       >toolson
                    lbeq      ad4@
                    ldd       <$19,s
                    addd      #$0016
                    pshs      a,b
                    ldd       <$1D,s
                    addd      #$0003
                    pshs      a,b
                    ldd       <$1D,s
                    pshs      a,b
                    ldd       <$21,s
                    pshs      a,b
                    ldd       11,s
                    pshs      a,b
                    ldd       <$21,s
                    pshs      a,b
                    lbsr      inrect
                    leas      12,s
                    lbeq      ad4@
                    ldd       #$000E
                    pshs      a,b
                    lbsr      TSleep
                    leas      2,s
                    leax      7,s
                    pshs      x
                    leax      9,s
                    pshs      x
                    lbsr      mouce
                    leas      4,s
                    std       -2,s
                    lbeq      ab4@
                    leas      -4,s
                    ldd       7,s                 STACK OFFSET: drag frame, mouse Y
                    subd      >UmeData_reserved_03C8
                    std       ,s                  STACK OFFSET: drag frame, Y grab delta
                    ldd       9,s                 STACK OFFSET: drag frame, mouse pixel X
                    asra
                    rorb
                    asra
                    rorb
                    asra
                    rorb
                    subd      >ToolX
                    std       2,s                 STACK OFFSET: drag frame, X-column grab delta
                    ldb       #$80                capture the complete rendered toolbox once
                    lbsr      SendDraggedTools
                    bra       aa4@
z4@                 ldd       #164
                    pshs      d
                    ldd       #8
                    pshs      d
                    ldd       11,s                STACK OFFSET: drag frame plus limits, mouse Y
                    subd      4,s                 STACK OFFSET: drag frame plus limits, Y delta
                    pshs      d
                    lbsr      ClampRange
                    leas      6,s
                    std       >UmeData_reserved_03C8
                    std       <$1D,s              STACK OFFSET: drag frame, toolbox bottom Y
                    ldd       #32                 80 screen columns minus 48 toolbox columns
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    ldd       13,s                STACK OFFSET: drag frame plus limits, mouse pixel X
                    asra
                    rorb
                    asra
                    rorb
                    asra
                    rorb
                    subd      6,s                 STACK OFFSET: drag frame plus limits, X delta
                    pshs      d
                    lbsr      ClampRange
                    leas      6,s
                    std       >ToolX
                    addd      #44
                    std       <$1F,s              STACK OFFSET: drag frame, brush-box column
                    ldb       #$81                move the captured toolbox in both directions
                    lbsr      SendDraggedTools
aa4@                leax      7,s                 STACK OFFSET: drag frame, mouse Y
                    pshs      x
                    leax      11,s                STACK OFFSET: drag frame plus pointer, mouse X
                    pshs      x
                    lbsr      mouce
                    leas      4,s
                    std       -2,s
                    lbne      z4@
* The last DMA placement is complete; release needs no sheet redraw.
                    leas      4,s
                    bra       ac4@
ab4@                clra
                    clrb
                    stb       >toolson
                    ldd       #$0001
                    stb       <rfr_scr
                    stb       <rfr_bar
ac4@                lbra      MainLoop
ad4@                ldb       >toolson
                    lbeq      bd4@
                    ldd       >UmeData_reserved_03C8
                    addd      #$0016
                    pshs      a,b
                    ldd       >ToolX
                    addd      #44
                    pshs      a,b
                    ldd       >UmeData_reserved_03C8
                    pshs      a,b
                    ldd       >ToolX
                    pshs      a,b
                    ldd       11,s
                    pshs      a,b
                    ldd       <$21,s
                    pshs      a,b
                    lbsr      inrect
                    leas      12,s
                    lbeq      bd4@
                    ldd       <$17,s
                    subd      >ToolX
                    subd      #1
                    pshs      a,b
                    ldd       #$0002
                    lbsr      DivInt
                    std       <$13,s
                    cmpd      #$0015
                    lbge      be4@
* Consume this toolbox press once; mouce rearms after the physical release.
* The toolbox handle above keeps its separate held-button drag path.
                    ldd       #$0001
                    stb       <PressHeld
                    stb       <rfr_rep
                    ldd       <$13,s
                    cmpd      #$000E
                    lblt      am4@
                    ldd       <curcurse
                    cmpd      #$0010
                    beq       ae4@
                    ldd       <curcurse
                    cmpd      #$0015
                    bne       af4@
ae4@                ldd       #$0071
                    pshs      a,b
                    lbsr      partcopy
                    leas      2,s
af4@                ldd       <curcurse
                    std       <$15,s
                    cmpd      #$0008
                    bne       ag4@
                    ldd       #$0001
                    stb       <rfr_men
ag4@                ldd       >UmeData_reserved_03C8
                    addd      #$000B
                    cmpd      3,s
                    ble       aj4@
                    ldd       <$13,s
                    cmpd      #$0014
                    bgt       aj4@
                    ldd       <$13,s
                    pshs      a,b
                    lbsr      curset
                    leas      2,s
                    ldd       <curcurse
                    cmpd      #$0010
                    bne       ah4@
                    clra
                    clrb
                    stb       <rfr_scr
                    stb       <rfr_men
                    ldd       #$0069
                    pshs      a,b
                    lbsr      partcopy
                    leas      2,s
ah4@                ldd       <curcurse
                    cmpd      #$0014
                    bne       ai4@
                    ldd       <$15,s
                    pshs      a,b
                    lbsr      curset
                    leas      2,s
                    clra
                    clrb
                    stb       <rfr_men
                    lbsr      filtmen
ai4@                lbra      MainLoop
aj4@                ldd       <$13,s
                    addd      #$FFF5
                    pshs      a,b
                    lbsr      curset
                    leas      2,s
                    ldd       <curcurse
                    cmpd      #$0008
                    bne       al4@
                    ldd       #$0001
                    stb       <rfr_men
                    ldd       <$15,s
                    cmpd      #$0008
                    bne       al4@
                    ldd       #$0016
                    pshs      a,b
                    lbsr      curset
                    leas      2,s
                    bra       al4@
ak4@                leas      <-$62,x
al4@                ldd       <curcurse
                    cmpd      #$0009
                    lbne      ba4@
                    clra
                    clrb
                    ldx       ,s
                    stb       4,x
                    lbra      ba4@
am4@                ldd       <$13,s
                    cmpd      #$000D              item 13 = the note/rest toggle glyph
                    bne       ar4@
                    bra       NoteRestToggle
an4@                leas      <-$62,x
* NoteRestToggle: palette item 13, the glyph between the boxes. Flips the template note's byte 2
* between $20 (rest) and 1 (note), asks for the palette redraw (<rfr_men) and selects mode $16.
* MainLoop acts on the button level, so waitmouse ends the press here: one press, one flip.
NoteRestToggle      ldx       ,s
                    ldb       2,x
                    cmpb      #$20
                    bne       ap4@
                    ldd       #$0001
                    bra       aq4@
ap4@                ldd       #$0020
aq4@                ldx       ,s
                    stb       2,x
                    ldd       #$0001
                    stb       <rfr_men
                    ldd       #$0016
                    pshs      a,b
                    lbsr      curset
                    leas      2,s
                    lbsr      waitmouse        the press ends here, not on the next pass
                    lbra     ba4@
ar4@                ldd       <$13,s
                    cmpd      #$0009
                    blt       aw4@
                    ldd       >UmeData_reserved_03C8
                    addd      #$000B
                    cmpd      3,s
                    bge       au4@
                    bra       at4@
as4@                leas      <-$62,x
at4@                ldd       <$13,s
                    addd      #$FFF7
                    ldx       ,s
* Only triplet-mode transitions change the duration glyphs in the toolbox.
                    cmpb      1,x
                    beq       ToolboxModifierReady
                    cmpb      #$03
                    beq       ToolboxModifierRedraw
                    lda       1,x
                    cmpa      #$03
                    bne       ToolboxModifierStore
ToolboxModifierRedraw lda      #$01
                    sta       <rfr_men
ToolboxModifierStore stb       1,x
ToolboxModifierReady ldd       #$0016
                    bra       av4@
au4@                ldd       <$13,s
                    addd      #$FFF8
                    ldx       ,s
                    stb       4,x
                    ldx       ,s
                    ldb       4,x
                    sex
                    addd      #$0009
av4@                pshs      a,b
                    lbsr      curset
                    leas      2,s
                    bra       ba4@
aw4@                ldd       <$13,s
                    cmpd      #$0007
                    bgt       az4@
                    bra       ay4@
ax4@                leas      <-$62,x
ay4@                ldd       #$0016
                    pshs      a,b
                    lbsr      curset
                    leas      2,s
                    ldd       <$13,s
                    stb       [,s]
                    ldx       ,s
                    ldb       1,x
                    cmpb      #$03
                    beq       ba4@
                    clra
                    clrb
                    ldx       ,s
                    stb       1,x
                    bra       ba4@
az4@                lbra      MainLoop
ba4@                ldx       ,s
                    ldb       1,x
                    cmpb      #$03
                    lbeq      de4@
                    ldb       [,s]
                    beq       bb4@
                    ldb       [,s]
                    cmpb      #$07
                    bne       bc4@
bb4@                clra
                    clrb
                    ldx       ,s
                    stb       1,x
bc4@                ldb       [,s]
                    cmpb      #$06
                    lbne      de4@
                    ldx       ,s
                    ldb       1,x
                    clra
                    andb      #$01
                    stb       1,x
                    lbra      de4@
bd4@                ldd       3,s
                    cmpd      #MenuBarY1
                    blt       bf4@                MenuBarHit handles every column, including File at the left
                    ldd       5,s
                    cmpd      #$0280              all 640 dots
                    bge       bf4@
                    ldd       5,s
                    pshs      a,b
                    lbsr      barmice
                    leas      2,s
                    stb       2,s
                    beq       be4@
* The clicked title stays highlighted while its command runs: the bar is reprinted plain first
* (whatever the last command left on it), then the clicked title is inverted; MainLoop redraws the
* bar plain ($97) when the command returns.
                    pshs      d
                    lbsr      SendCmd97           the bar reprinted: every title unclicked, unhighlighted (MenuBarHover -1)
                    ldd       7,s                 x (5,s before the pshs)
                    ldx       #MenuBarY1
                    lbsr      MenuBarHit          D = the clicked title
                    std       >MenuBarHover
                    lbsr      InvertMenuBarHover  highlighted (it flushes, the reprint ahead of it)
                    ldd       #-1
                    std       >MenuBarHover
                    ldb       #$01
                    stb       <rfr_bar
                    puls      d
                    ldb       #$01                the press that chose the title may still be down:
                    stb       <PressHeld          mouce ignores the button until it is released
                    leax      <$62,s
                    lbra      bq4@
be4@                leax      <$62,s
                    lbra      o4@
bf4@                ldd       3,s
                    cmpd      #$0007
                    bge       bg4@
                    ldd       5,s
                    cmpd      #$0026
                    ble       bg4@
                    ldd       5,s
                    cmpd      #$0258
                    bge       bg4@
                    ldd       <nevents
                    lbsr      IntToLong
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldd       9,s
                    addd      #$FFDA
                    lbsr      IntToLong
                    lbsr      LongMul
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    bsr       ScrollBarDivRet
                    neg       <UmeData_reserved_0000
                    fcb       $02       inline long 562 = $00,$00,$02,$32 (the neg above is its first two bytes)
                    fcb       $32
* ScrollBarDivRet (was L0A1D): MainLoop top-scrollbar click: bsr skips the inline long 562, puls x = &divisor for LongDiv
ScrollBarDivRet     puls      x
                    lbsr      LongDiv
                    ldd       >UmeData_reserved_0345
                    std       <gind
                    ldd       #$0028
                    bra       bk4@
bg4@                ldd       3,s
                    cmpd      #$00B9
                    bgt       bh4@
                    ldd       3,s
                    cmpd      #$0007
* A click against the left or right screen edge does not scroll (the original's 'half:' zone, dj4@);
* it goes to the score-item hit test. The arrow keys still reach dj4@ through di4@.
                    lbge      dp4@
bh4@                ldd       5,s
                    cmpd      #$0026
                    bge       bl4@
                    bra       bj4@
bi4@                leas      <-$62,x
bj4@                ldd       <lftind
                    std       <gind
                    ldd       #$0050
bk4@                std       <xgoal
                    bra       bo4@
bl4@                ldd       5,s
                    cmpd      #$0258
                    ble       bp4@
                    bra       bn4@
bm4@                leas      <-$62,x
bn4@                ldd       <ritind
                    std       <gind
                    clra
                    clrb
                    std       <xgoal
                    ldd       <nevents
                    addd      #$FFFF
                    cmpd      <ritind
                    bgt       bo4@
                    lbsr      addbars
bo4@                ldd       #$0001
                    stb       <rfr_scr
                    lbra      MainLoop
bp4@                clra
                    clrb
                    stb       2,s
                    bra       br4@
bq4@                leas      <-$62,x
br4@                ldd       #$0001
                    stb       <rfr_rep
                    ldb       2,s
                    cmpb      #$5B
                    bne       bs4@
                    ldd       #$0003
                    bra      ca4@
bs4@                ldb       2,s
                    cmpb      #$5D
                    bne       bt4@
                    ldd       #$0004
                    bra       ca4@
bt4@                ldb       2,s
                    cmpb      #$5E
                    bne       bu4@
                    ldd       #$0005
                    bra       ca4@
bu4@                ldb       2,s
                    cmpb      #$78
                    bne       bv4@
                    ldd       #$0006
                    bra       ca4@
bv4@                ldb       2,s
                    cmpb      #$7C
                    bne       bw4@
                    ldd       #$000E
                    bra       ca4@
bw4@                ldb       2,s
                    cmpb      #$26
                    bne       bx4@
                    ldd       #$0007
                    bra       ca4@
bx4@                ldb       2,s
                    cmpb      #$40
                    bne       by4@
                    ldd       #$0012
                    bra       ca4@
by4@                ldb       2,s
                    cmpb      #$21
                    bne       bz4@
                    ldd       #$000F
                    bra       ca4@
bz4@                ldb       2,s
                    cmpb      #$25
                    bne       cb4@
                    ldd       #$0011
ca4@                pshs      a,b
                    lbsr      curset
                    leas      2,s
                    lbra      MainLoop
cb4@                ldb       2,s
                    cmpb      #$74
                    bne       cg4@
                    ldb       >toolson
                    bne       cc4@
                    ldd       #$0001
                    bra       cd4@
cc4@                clra
                    clrb
cd4@                stb       <rfr_rep
                    stb       <rfr_men
                    stb       >toolson
                    beq       ce4@
                    ldd       <$19,s
                    std       >UmeData_reserved_03C8
                    ldd       >ToolX
                    addd      #44
                    std       <$1B,s
                    bra       cf4@
ce4@                ldd       #$0001
                    stb       <rfr_scr
                    stb       <rfr_bar
cf4@                lbra      MainLoop
cg4@                ldb       2,s
                    cmpb      #$3E
                    bne       ch4@
                    leax      <$62,s
                    lbra      bm4@
ch4@                ldb       2,s
                    cmpb      #$3C
                    bne       ci4@
                    leax      <$62,s
                    lbra      bi4@
ci4@                ldd       #$0014
                    std       <$37,s
                    ldb       2,s
                    cmpb      #$08
                    beq       cj4@
                    ldb       2,s
                    cmpb      #$09
                    bne       cm4@
cj4@                ldb       2,s
                    cmpb      #$08
                    bne       ck4@
                    clra
                    clrb
                    bra       cl4@
ck4@                ldd       #$027F
cl4@                std       5,s
                    leax      <$62,s
                    lbra      di4@
cm4@                ldb       2,s
                    cmpb      #$0C
                    beq       cn4@
                    ldb       2,s
                    cmpb      #$0A
                    bne       cq4@
cn4@                ldb       2,s
                    cmpb      #$0C
                    bne       co4@
                    ldd       #$0001
                    bra       cp4@
co4@                ldd       #$FFFF
cp4@                pshs      a,b
                    ldx       2,s
                    ldb       1,x
                    sex
                    addd      ,s++
                    clra
                    andb      #$03
                    addd      #$0009
                    bra       cu4@
cq4@                ldb       2,s
                    cmpb      #$2E
                    beq       cr4@
                    ldb       2,s
                    cmpb      #$20
                    beq       cr4@
                    ldb       2,s
                    cmpb      #$33
                    bne       cv4@
cr4@                ldb       2,s
                    cmpb      #$2E
                    bne       cs4@
                    ldd       #$000A
                    bra       cu4@
cs4@                ldb       2,s
                    cmpb      #$33
                    bne       ct4@
                    ldd       #$000C
                    bra       cu4@
ct4@                ldd       #$0009
cu4@                std       <$13,s
                    leax      <$62,s
                    lbra      as4@
cv4@                ldb       2,s
                    cmpb      #$30
                    beq       cw4@
                    ldb       2,s
                    cmpb      #$0D
                    bne       cx4@
cw4@                leax      <$62,s
                    lbra      an4@
cx4@                ldb       2,s
                    cmpb      #$31
                    blt       cy4@
                    ldb       2,s
                    cmpb      #$38
                    bgt       cy4@
                    leax      >strDigitToDur,pcr
                    tfr       x,d
                    pshs      a,b
                    ldb       4,s
                    sex
                    addd      #$FFCF
                    addd      ,s++
                    tfr       d,x
                    ldb       ,x
                    sex
                    addd      #$FFD0
                    std       <$13,s
                    leax      <$62,s
                    lbra      ax4@
cy4@                ldb       2,s
                    cmpb      #$2B
                    beq       cz4@
                    ldb       2,s
                    cmpb      #$3D
                    bne       da4@
cz4@                ldd       <curcurse
                    cmpd      #$0008
                    beq       dc4@
                    ldd       #$0008
                    bra       dd4@
da4@                ldb       2,s
                    cmpb      #$5F
                    beq       db4@
                    ldb       2,s
                    cmpb      #$2D
                    bne       dg4@
db4@                ldd       <curcurse
                    cmpd      #$0009
                    bne       df4@
                    ldd       #$0002
                    ldx       ,s
                    stb       4,x
dc4@                ldd       #$0016
dd4@                pshs      a,b
                    lbsr      curset
                    leas      2,s
de4@                ldd       #$0001
                    stb       <rfr_rep
                    lbra      MainLoop
df4@                ldd       #$0009
                    pshs      a,b
                    lbsr      curset
                    leas      2,s
                    leax      <$62,s
                    lbra      ak4@
dg4@                clra
                    clrb
                    std       <$37,s
                    ldb       2,s
                    sex
                    pshs      a,b
                    lbsr      mainmen
                    std       ,s++
                    beq       dh4@
                    lbra      fz4@
dh4@                lbra      MainLoop
di4@                leas      <-$62,x
dj4@                ldd       <lftind
                    beq       dk4@
                    ldd       5,s
                    cmpd      #$0002
                    blt       dl4@
dk4@                ldd       5,s
                    cmpd      #$0275
                    blt       dp4@
dl4@                ldd       5,s
                    cmpd      #$0275
                    blt       dm4@
                    ldd       <ritind
                    bra       do4@
dm4@                ldd       <lftind
                    beq       dn4@
                    ldd       <lftind
                    addd      #$FFFF
                    std       <lftind
dn4@                ldd       <lftind
do4@                std       <gind
                    ldd       #$0028
                    std       <xgoal
                    ldd       #$0001
                    stb       <rfr_scr
                    ldd       11,s
                    pshs      a,b
                    ldd       15,s
                    pshs      a,b
                    lbsr      DrawPointer
                    leas      4,s
                    lbra      MainLoop
dp4@                ldb       <snap
                    bne       dq4@
                    ldd       #$0001
                    bra       dr4@
dq4@                clra
                    clrb
dr4@                pshs      a,b
                    ldd       <$25,s
                    ora       <$27,s
                    orb       <$28,s
                    pshs      a,b
                    ldd       7,s
                    pshs      a,b
                    ldd       11,s
                    pshs      a,b
                    lbsr      find
                    leas      8,s
                    std       <$33,s
                    lbge      eb4@
                    ldd       <$17,s
                    cmpd      #$0002
                    lblt      dv4@
                    ldd       <$17,s
                    cmpd      #$0004
                    lbge      dv4@
                    leas      -6,s
                    ldd       9,s
                    pshs      a,b
                    lbsr      findstaff
                    leas      2,s
                    std       4,s
                    cmpd      <nstaves
                    lbge      du4@
                    ldd       4,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      MulInt
                    ldx       #staves
                    leax      d,x
                    ldd       ,x
                    std       <$17,s
                    ldd       4,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      MulInt
                    ldx       #staves
                    leax      d,x
                    ldd       2,x
                    std       ,s
                    ldd       9,s
                    subd      <$17,s
                    std       2,s
                    ldd       <$17,s
                    addd      #$0014
                    pshs      a,b
                    ldd       #$004E
                    pshs      a,b
                    ldd       <$1B,s
                    addd      #$FFF9
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0002
                    pshs      a,b
                    lbsr      SendMarkPacket
                    leas      10,s
                    bra      dt4@
ds4@                ldd       <$17,s
                    addd      2,s
                    cmpd      9,s
                    beq       dt4@
                    ldd       <$17,s
                    addd      #$0014
                    pshs      a,b
                    ldd       #$004E
                    pshs      a,b
                    ldd       <$1B,s
                    addd      #$FFF9
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0002
                    pshs      a,b
                    lbsr      SendMarkPacket
                    leas      10,s
                    ldd       9,s
                    subd      2,s
                    std       <$17,s
                    ldd       #$00A7
                    pshs      a,b
                    ldd       #$0008
                    pshs      a,b
                    ldd       <$1B,s
                    pshs      a,b
                    lbsr      ClampRange
                    leas      6,s
                    std       <$17,s
                    ldd       ,s
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       <$1B,s
                    pshs      a,b
                    lbsr      SendCmd9C
                    leas      6,s
dt4@                leax      9,s
                    pshs      x
                    leax      13,s
                    pshs      x
                    lbsr      mouce
                    leas      4,s
                    std       -2,s
                    bne      ds4@
                    ldd       4,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      MulInt
                    ldx       #staves
                    leax      d,x
                    ldd       <$17,s
                    std       ,x
                    ldd       <$17,s
                    pshs      a,b
                    ldd       2,s
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    lbsr      SendStaffDef
                    leas      6,s
                    ldd       #$0001
                    stb       <rfr_bar
                    stb       <rfr_men
                    stb       <rfr_scr
                    leas      6,s
                    lbra      MainLoop
du4@                leas      6,s
dv4@                ldd       <dntime
                    cmpd      #$000D
                    bge       dw4@
                    ldd       #$000E
                    pshs      a,b
                    lbsr      TSleep
                    leas      2,s
                    leax      3,s
                    pshs      x
                    leax      7,s
                    pshs      x
                    lbsr      mouce
                    leas      4,s
                    std       -2,s
                    beq       dx4@
                    ldd       <uptime
                    cmpd      #$000A
                    ble       dx4@
dw4@                leax      <$62,s
                    lbra      o4@
dx4@                ldd       <uptime
                    addd      <dntime
                    cmpd      #$000D
                    blt       dz4@
                    ldd       <curcurse
                    cmpd      #$0016
                    beq       dy4@
                    ldd       <curcurse
                    cmpd      #$0008
                    beq       dy4@
                    ldd       <curcurse
                    cmpd      #$000F
                    bne       ea4@
dy4@                ldd       #$0012
                    std       <$37,s
                    bra       ea4@
dz4@                ldd       #$00A8
                    pshs      a,b
                    ldd       #$0008
                    pshs      a,b
                    ldd       15,s
                    addd      #$FFF5
                    pshs      a,b
                    lbsr      ClampRange
                    leas      6,s
                    std       >UmeData_reserved_03C8
                    std       <$19,s
                    ldb       >toolson
                    stb       <rfr_scr
                    ldd       #$0001
                    stb       <rfr_men
                    stb       <rfr_rep
                    stb       >toolson
                    ldd       >ToolX
                    addd      #44
                    std       <$1B,s
ea4@                lbra      MainLoop
eb4@                ldd       <$33,s
                    std       <gind
                    ldd       <$33,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    tfr       d,u
                    lbsr      FocusClickedNote
                    ldb       ,u
                    sex
                    std       <$2D,s
                    ldd       1,u
                    std       <$2F,s
                    ldd       <$33,s
                    subd      <xyoff
                    ldx       #grafxes
                    leax      d,x
                    ldb       ,x
                    sex
                    std       <xgoal
                    ldd       <curcurse
                    cmpd      #$0007
                    bne       ed4@
                    ldd       <$33,s
                    pshs      a,b
                    lbsr      exprmenu
                    leas      2,s
                    stb       <rfr_scr
                    lbeq      fi4@
ec4@                ldd       #$FFFF
                    std       <undind
                    lbra      fi4@
ed4@                ldd       <curcurse
                    cmpd      #$0009
                    lblt      eo4@
                    ldd       <curcurse
                    cmpd      #$000D
                    lbgt      eo4@
                    ldd       <$2D,s
                    beq       ee4@
                    ldb       5,u
                    sex
                    std       <$13,s
                    cmpd      #$0020
                    bne       ef4@
ee4@                lbsr      bell
                    lbra      MainLoop
ef4@                leax      <$21,s
                    pshs      x
                    leax      <$21,s
                    pshs      x
                    leax      <$15,s
                    pshs      x
                    ldd       <$33,s
                    pshs      a,b
                    lbsr      partstaff
                    leas      8,s
                    ldd       <$33,s
                    subd      <xyoff
                    ldx       #grafxes
                    leax      d,x
                    ldb       ,x
                    sex
                    std       <$17,s
                    ldd       <$33,s
                    subd      <xyoff
                    ldx       #grafyes
                    leax      d,x
                    ldb       ,x
                    clra
                    std       3,s
                    ldd       <$21,s
                    clra
                    andb      #$01
                    bne       ei4@
                    ldd       <$21,s
                    clra
                    andb      #$02
                    beq       eh4@
eg4@                ldd       #$0001
                    bra       ej4@
eh4@                ldd       <$13,s
                    cmpd      #$0004
                    bgt       eg4@
ei4@                clra
                    clrb
ej4@                pshs      a,b
                    ldd       5,s
                    cmpd      #$0017
                    ble       ek4@
                    ldd       #$0001
                    bra       el4@
ek4@                clra
                    clrb
el4@                anda      ,s+
                    andb      ,s+
                    stb       <$1E,s
                    sex
                    pshs      a,b
                    ldb       7,u
                    sex
                    pshs      a,b
                    ldd       7,s
                    pshs      a,b
                    ldd       <$1D,s
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    lbsr      SendNoteA9
                    leas      10,s
                    ldb       7,u
                    sex
                    pshs      a,b
                    ldx       2,s
                    ldb       4,x
                    sex
                    cmpd      ,s++
                    bne       em4@
                    ldd       #$0002
                    stb       7,u
                    lbra      fi4@
em4@                ldb       <$1E,s
                    sex
                    pshs      a,b
                    ldx       2,s
                    ldb       4,x
                    stb       7,u
                    sex
                    pshs      a,b
                    ldd       7,s
                    pshs      a,b
                    ldd       <$1D,s
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    lbsr      SendNoteA9
en4@                leas      10,s
                    lbra      fi4@
eo4@                ldd       <curcurse
                    cmpd      #$0006
                    lbne      ez4@
                    pshs      u
                    ldx       #$03EB
                    pshs      x
                    lbsr      CopyEvent
                    leas      4,s
                    ldd       #$0001
                    stb       <rfr_scr
                    ldd       <$33,s
                    std       <undind
                    ldd       <$2D,s
                    beq       ep4@
                    ldb       5,u
                    cmpb      #$20
                    bne       es4@                Delete turns any note into a rest, including clone parts
                    ldd       <$2D,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #parts
                    leax      d,x
                    ldd       2,x
                    clra
                    andb      #$04
                    bne       ep4@
                    ldb       5,u
                    cmpb      #$20
                    bne       es4@
                    leax      >msgDelFlagshipRest,pcr
                    pshs      x
                    lbsr      yesno
                    std       ,s++
                    beq       er4@
ep4@                ldd       <$33,s
                    pshs      a,b
                    lbsr      remove
eq4@                leas      2,s
                    lbra      fi4@
er4@                clra
                    clrb
                    stb       <rfr_scr
                    lbra      fi4@
es4@                ldd       #$0020
                    stb       5,u
                    ldd       #$0002
                    stb       7,u
                    bra       eu4@
et4@                ldd       1,u
                    cmpd      <$2F,s
                    bne       ev4@
                    lbsr      decdec
                    tfr       d,u
eu4@                ldd       <curind
                    bne       et4@
ev4@                ldd       <curind
                    addd      #$0001
                    std       <$31,s
                    ldd       <$33,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    bra       ex4@
ew4@                ldd       1,u
                    cmpd      <$2F,s
                    bne       ey4@
                    lbsr      plusplus
ex4@                tfr       d,u
                    ldd       <curind
                    cmpd      <nevents
                    blt       ew4@
ey4@                ldd       <curind
                    addd      #$FFFF
                    pshs      a,b
                    ldd       <$33,s
                    pshs      a,b
                    ldd       <$31,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #parts
                    leax      d,x
                    ldd       ,x
                    addd      #$0001
                    pshs      a,b
                    ldd       #$0073
                    pshs      a,b
                    ldd       #$0054
                    pshs      a,b
                    lbsr      soowee
                    lbra      en4@
ez4@                ldd       <curcurse
                    cmpd      #$0003
                    blt       fa4@
                    ldd       <curcurse
                    cmpd      #$0005
                    bgt       fa4@
                    ldd       <curcurse
                    addd      #$000A
                    pshs      a,b
                    ldd       <$35,s
                    pshs      a,b
                    lbsr      markin
                    leas      4,s
                    std       -2,s
                    lbne      ec4@
fa4@                ldd       <curcurse
                    cmpd      #$000F
                    bne       fb4@
                    ldd       <$33,s
                    pshs      a,b
                    lbsr      smash
                    lbra      eq4@
fb4@                ldd       <curcurse
                    cmpd      #$0013
                    bne       fc4@
                    ldd       #$0008
                    pshs      a,b
                    lbsr      TSleep
                    leas      2,s
                    leax      7,s
                    pshs      x
                    leax      9,s
                    pshs      x
                    lbsr      mouce
                    leas      4,s
                    std       -2,s
* A press released within the 8-tick wait auditions the clicked note; a held press drags it.
                    lbeq      AuditionClickedNote
                    ldd       <$33,s
                    pshs      a,b
                    lbsr      movenote
                    lbra      eq4@
fc4@                ldd       <curcurse
                    cmpd      #$0012
                    bne       fd4@
                    ldd       <$33,s
                    pshs      a,b
                    lbsr      squawk
                    lbra      eq4@
fd4@                ldd       <curcurse
                    cmpd      #$0011
                    bne       fe4@
                    ldd       <$33,s
                    pshs      a,b
                    lbsr      MergeNextNoteCmd
                    lbra      eq4@
fe4@                ldd       <curcurse
                    cmpd      #$0010
                    beq       ff4@
                    ldd       <curcurse
                    cmpd      #$0015
                    bne       fg4@
ff4@                ldd       <$33,s
                    pshs      a,b
                    ldd       #$0066
                    pshs      a,b
                    lbsr      partcopy
                    bra       fh4@
fg4@                ldd       <curcurse
                    cmpd      #$000E
                    bne       fi4@
                    clra
                    clrb
                    pshs      a,b
                    ldd       <$35,s
                    pshs      a,b
                    lbsr      markin
fh4@                leas      4,s
fi4@                ldd       <curcurse
                    cmpd      #$0016
                    beq       fj4@
                    ldd       <curcurse
                    cmpd      #$0008
                    beq       fj4@
                    lbra      MainLoop
fj4@                ldd       <$2D,s
                    bne       fm4@
                    pshs      u
                    lbsr      anybar
                    std       ,s++
                    beq       fk4@
                    ldd       <$33,s
                    pshs      a,b
                    ldd       #$0062
                    pshs      a,b
                    ldd       #$0045
                    pshs      a,b
                    lbsr      soowee
                    leas      6,s
                    bra       fl4@
fk4@                ldd       <$33,s
                    pshs      a,b
                    lbsr      exprmenu
                    leas      2,s
fl4@                stb       <rfr_scr
                    ldb       <rfr_scr
                    lbeq      fy4@
                    lbra      fx4@
fm4@                equ       *
* Note entry replaces rests only. Existing notes audition without editing the
* score or palette; the separate pitch-move tool retains drag behavior.
NoteEntryClick      ldb       5,u
                    cmpb      #$20
                    beq       NoteEntryRest
AuditionClickedNote ldd       <$33,s              STACK OFFSET: clicked event index in main's frame; also the pitch-move tool's single click
                    pshs      d
                    lbsr      AuditionPlacedNote    also waits for the initiating press to be released
                    leas      2,s
                    lbra      fy4@
* s9c 'k' answers 0 when the palette note fits in the rest(s) at the click; otherwise it has played
* the bonk and nothing is placed. It leaves the clicked event's page mapped, so U is still the event.
NoteEntryRest       ldd       <$33,s              STACK OFFSET: clicked event index in main's frame
                    pshs      d
                    ldd       #'k
                    pshs      d
                    ldd       #'C
                    pshs      d
                    lbsr      soowee
                    leas      6,s
                    std       -2,s
                    lbne      fy4@
                    ldd       #$0008
                    pshs      a,b
                    lbsr      TSleep
                    leas      2,s
                    ldd       <curcurse
                    cmpd      #$0008
                    bne       fn4@
                    ldb       5,u
                    cmpb      #$20
                    bne       fo4@
fn4@                leax      7,s
                    pshs      x
                    leax      9,s
                    pshs      x
                    lbsr      mouce
                    leas      4,s
                    std       -2,s
                    bne       fp4@                held: the original note entry (a slide picks the pitch)
* A plain click on a rest places the palette note on the line under the pointer (NoAbort keeps
* place() from aborting a placement without motion); it can be dragged afterwards. The pick into
* the palette (fo4@) is for notes only.
                    ldb       #$01
                    stb       <NoAbort
                    ldb       #$02
                    stb       <FakeDown           place: the first poll takes the coordinates, the second runs one lap of the slide
                    lbra      fp4@
fo4@                pshs      u
                    ldd       #$0003
                    addd      ,s++
                    pshs      a,b
                    ldx       #brush
                    pshs      x
                    lbsr      CopyNoteAttrs
                    leas      4,s
                    ldd       #$0001
                    stb       <rfr_rep
                    stb       <rfr_men
                    ldd       #$0002
                    ldx       ,s
                    stb       4,x
                    clra
                    clrb
                    ldx       ,s
                    stb       3,x
                    leax      7,s
                    pshs      x
                    leax      9,s
                    pshs      x
                    lbsr      mouce
                    leas      4,s
                    std       -2,s
                    bne       fp4@
                    ldd       #$0004
                    std       <$37,s
                    lbra      MainLoop
fp4@                ldd       <curcurse
                    cmpd      #$0008
                    bne       fr4@
                    ldb       5,u
                    cmpb      #$20
                    bne       fq4@
                    ldx       ,s
                    ldb       2,x
                    cmpb      #$20
                    bne       fr4@
fq4@                ldd       #$0001
                    bra       fs4@
fr4@                clra
                    clrb
fs4@                stb       <$1D,s
* bmuse.c hands place()/chip() the palette brush whatever the victim is. Here a note victim (brush
* cursor, no Plus) is copied into notemp and brp (,s) points there for this pass: place() drags
* the note's own attributes to the new pitch, chip() re-stamps it with its own duration, and the
* palette is untouched. A rest victim takes the palette item (note entry). brp goes back to #brush
* at fy4@.
                    tst       <$1D,s              Plus: the original path
                    bne       fs9@
                    ldb       5,u
                    cmpb      #$20
                    beq       fs9@                a rest: the palette item goes in
                    leax      3,u                 the victim's NOTE: dur, durmod, slot, pitmod, artic
                    pshs      x
                    leax      <$3B,s              notemp (<$39,s at the base depth)
                    pshs      x
                    lbsr      CopyNoteAttrs
                    leas      4,s
                    leax      <$39,s
                    stx       ,s                  brp -> the copy
* Imported Lyra, MIDI and Orchestra rests carry the notation-only marker $82 in byte 7. Bit 7 is
* cleared here so a note entered on such a rest gets articulation 2 (the player skips a marked
* note); native articulations 0-4 pass unchanged.
fs9@                ldb       7,u
                    andb      #$7F
                    ldx       ,s
                    stb       4,x
                    ldb       <$1D,s
                    sex
                    pshs      a,b
                    pshs      x                   brp (bmuse.c: &brush), still in X
                    pshs      u
                    ldd       <$39,s
                    pshs      a,b
                    lbsr      place
                    leas      8,s
                    std       -2,s
                    bne       ft4@
                    ldb       <aborted
                    stb       <rfr_scr
                    ldd       #$0002
                    ldx       ,s
                    stb       4,x
                    lbra      fy4@                brp back to the palette first
ft4@                ldb       <$1D,s
                    bne      fw4@
                    ldx       ,s
                    ldb       1,x
                    sex
                    pshs      a,b
                    ldb       [<$02,s]
                    sex
                    pshs      a,b
                    lbsr      cod2raw
                    leas      4,s
                    std       <$2B,s
                    ldb       4,u
                    sex
                    pshs      a,b
                    ldb       3,u
                    sex
                    pshs      a,b
                    lbsr      cod2raw
                    leas      4,s
                    cmpd      <$2B,s
                    beq       fu4@
                    ldd       #$0001
                    bra       fv4@
fu4@                clra
                    clrb
fv4@                stb       <rfr_scr
                    ldx       ,s                  brp (bmuse.c: &brush; notemp itself for a dragged note)
                    pshs      x
                    leax      <$3B,s
                    pshs      x
                    lbsr      CopyNoteAttrs
                    leas      4,s
                    ldd       <$2D,s
                    pshs      a,b
                    ldd       <$2D,s
                    pshs      a,b
                    leax      <$3D,s
                    pshs      x
                    ldd       <$39,s
                    pshs      a,b
                    lbsr      chip
                    leas      8,s
fw4@                ldd       <$33,s
                    pshs      d
                    lbsr      AuditionPlacedNote
                    leas      2,s
                    ldd       #$0002
                    ldx       ,s
                    stb       4,x
                    clra
                    clrb
                    ldx       ,s
                    stb       3,x
fx4@                ldd       #$FFFF
                    std       <undind
fy4@                clr       <NoAbort
                    ldx       #brush
                    stx       ,s                  brp back to the palette (a note drag pointed it at notemp)
                    lbra      MainLoop
fz4@                lbra      RestartChain        Misc > Restart: quit teardown, then a fresh s9
                    fcb       $32,$E8,$62,$35,$C0
* Menu-bar hover and click: the pointer is tested against the hit table at [pDriveMenu] (built by
* s9g): MenuBarItems rectangles x1,y1,x2,y2 of four bytes each, x in eight-dot columns (x2
* inclusive), y in canvas rows. Entries 0-9 are the menu titles, 10-15 the instant-drive shortcuts.
* The hover inversion is s9gui's menu-row inversion (mark packet kind 3) over that rectangle.
* TrackMenuBarHover(x,y) preserves all registers.
* MenuBarHit: D = pointer x (dots), X = its canvas row -> D = the entry (0-15) or -1 (N set).
* Keeps X, Y and U.
MenuBarHit          pshs      x,y,u
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb                          B = the column, x / 8
                    pshs      b
                    tfr       x,d                 B = the row
                    lda       ,s+                 A = the column
                    ldy       >pDriveMenu
                    beq       MenuBarHitEmpty
                    ldu       #0                  the index
MenuBarHitNext      cmpb      1,y                 y1
                    blo       MenuBarHitMiss
                    cmpb      3,y                 y2
                    bhi       MenuBarHitMiss
                    cmpa      ,y                  x1
                    blo       MenuBarHitMiss
                    cmpa      2,y                 x2
                    bls       MenuBarHitDone      inside
MenuBarHitMiss      leay      4,y
                    leau      1,u
                    cmpu      #MenuBarItems
                    blo       MenuBarHitNext
MenuBarHitEmpty     ldu       #-1
MenuBarHitDone      tfr       u,d
                    tsta                          N set = none
                    puls      x,y,u,pc
TrackMenuBarHover   pshs      d,x,y,u
                    ldd       10,s                x
                    ldx       12,s                y
                    lbsr      MenuBarHit          D = the title under the pointer, -1 = none
MenuBarHoverFound   cmpd      >MenuBarHover
                    beq       MenuBarHoverReturn
                    pshs      d
                    lbsr      ClearMenuBarHover
                    puls      d
                    std       >MenuBarHover
                    lbsr      InvertMenuBarHover
MenuBarHoverReturn  puls      d,x,y,u,pc
ClearMenuBarHover   pshs      d,x,y,u
                    lbsr      InvertMenuBarHover
                    ldd       #-1
                    std       >MenuBarHover
                    puls      d,x,y,u,pc
InvertMenuBarHover  pshs      d,x,y,u
                    ldd       >MenuBarHover
                    bmi       MenuBarInvertDone
                    lslb
                    rola
                    lslb
                    rola                          four bytes a rectangle
                    ldx       >pDriveMenu
                    leax      d,x                 the title's rectangle
                    clra
                    ldb       3,x                 y2
                    pshs      d
                    ldb       2,x                 x2, the last column
                    pshs      d
                    ldb       1,x                 y1
                    pshs      d
                    ldb       ,x                  x1
                    pshs      d
                    ldd       #$7303              kind 3 with $73 xor $B8 = $CB: four-pixel menu shift
                    pshs      d
                    lbsr      SendMarkPacket
                    leas      10,s
                    lbsr      flush
MenuBarInvertDone   puls      d,x,y,u,pc
* barmice (was L1306): maps a click x through MenuBarHit onto strMenuBarKeys ('floimt^Gbrp', then
* $10-$15 for the drive shortcuts). B = the key, 0 = nothing there. The caller has checked the row.
barmice             pshs      u
                    ldd       4,s                 x
                    ldx       #MenuBarY1
                    lbsr      MenuBarHit
                    bmi       MenuBarNoKey
                    leax      >strMenuBarKeys,pcr
                    ldb       b,x
                    puls      u,pc
MenuBarNoKey        clrb
                    puls      u,pc
* strGm (was L1325): 'gm' default synth name copied to $03B8
strGm               fcb       $67,$6D,$00
* pathDevN (was L1328): '/N' opened at start to detect DriveWire (<$51)
pathDevN            fcb       $2F,$4E,$00
* strDigitToDur (was L132B): '12636574' key digit to duration-code map used by the 1-8 keys in main
strDigitToDur       fcc       /12636574/
                    fcb       $00
* msgDelFlagshipRest (was L1334): 'Delete Flagship Rest?'
msgDelFlagshipRest  fcc       /Delete Flagship Rest?/
                    fcb       $00
* strMenuBarKeys: the menu keys, then the click codes $10-$15 of the S0/S1/X0-X3 drive shortcuts.
strMenuBarKeys      fcc       /floimt/
                    fcb       $07
                    fcc       /brp/
                    fcb       $10,$11,$12,$13,$14,$15
                    fcb       $00
* volspell (was L135E): returns a pointer into strDynamicsNames (4-byte entries, index n&7)
volspell        pshs      u
                    leax      >strDynamicsNames,pcr
                    tfr       x,d
                    pshs      a,b
                    ldd       6,s
                    clra
                    andb      #$07
                    aslb
                    rola
                    aslb
                    rola
                    bra       NameTableAddRet
* ArticName (was L1373): returns a pointer into strArticNames (9-byte entries, index n&7)
ArticName           pshs      u
                    leax      >strArticNames,pcr
                    tfr       x,d
                    pshs      a,b
                    ldd       6,s
                    clra
                    andb      #$07
                    pshs      a,b
                    ldd       #$0009
                    lbsr      MulInt
* NameTableAddRet (was L138A): shared tail of volspell/ArticName: adds the pushed table base to the index and returns
NameTableAddRet     addd      ,s++
                    puls      u,pc
* tranpart (was L138E): walks events of a part between two indexes adjusting byte 5 (pitch step) by an offset, wrapping by octaves of 7
tranpart       pshs      a,b,x,u
                    ldd       12,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    bra       g5@
a5@                 ldb       ,u
                    sex
                    cmpd      8,s
                    bne       f5@
                    ldb       5,u
                    sex
                    std       2,s
                    cmpd      #$0020
                    beq       f5@
                    ldd       2,s
                    addd      10,s
                    bra       c5@
b5@                 ldd       ,s
                    subd      #$0007
c5@                 std       ,s
                    ldd       ,s
                    cmpd      #$0014
                    bgt       b5@
                    bra       e5@
d5@                 ldd       ,s
                    addd      #$0007
                    std       ,s
e5@                 ldd       ,s
                    cmpd      #$FFF5
                    blt       d5@
                    ldd       ,s
                    stb       5,u
f5@                 lbsr      plusplus
g5@                 tfr       d,u
                    ldd       <curind
                    cmpd      14,s
                    ble       a5@
                    leas      4,s
                    puls      u,pc
* clonemid (was L13E8): vector $0397: copies per-part table bytes between parts sharing a staff (partstaff flags)
clonemid       pshs      u
                    leas      -12,s
                    ldd       <$12,s
                    cmpd      <nparts
                    ble       h5@
                    ldd       <nparts
                    std       <$12,s
h5@                 ldd       <$10,s
                    bgt       i5@
                    ldd       #$0001
                    std       <$10,s
i5@                 ldd       <$10,s
                    bra      o5@
j5@                 leax      10,s
                    pshs      x
                    leax      8,s
                    pshs      x
                    leax      10,s
                    pshs      x
                    ldd       8,s
                    pshs      a,b
                    lbsr      partstaff
                    leas      8,s
                    std       4,s
                    ldd       10,s
                    clra
                    andb      #$04
                    beq      n5@
                    ldd       #$0001
                    bra       m5@
k5@                 leax      8,s
                    pshs      x
                    leax      8,s
                    pshs      x
                    leax      10,s
                    pshs      x
                    ldd       6,s
                    pshs      a,b
                    lbsr      partstaff
                    leas      8,s
                    cmpd      4,s
                    bne       l5@
                    ldd       8,s
                    clra
                    andb      #$04
                    bne       l5@
                    ldd       8,s
                    eora      10,s
                    eorb      11,s
                    clra
                    andb      #$03
                    bne       l5@
                    ldx       <$14,s
                    ldd       2,s
                    leax      d,x
                    pshs      x
                    ldx       <$16,s
                    ldd       2,s
                    leax      d,x
                    ldb       ,x
                    stb       [,s++]
l5@                 ldd       ,s
                    addd      #$0001
m5@                 std       ,s
                    ldd       ,s
                    cmpd      <nparts
                    ble       k5@
n5@                 ldd       2,s
                    addd      #$0001
o5@                 std       2,s
                    ldd       2,s
                    cmpd      <$12,s
                    ble      j5@
                    leas      12,s
                    puls      u,pc
* squawk (was L1492): prints ' Part %d, Channel %d %s %s Instr ... Environment ... Index %d at %u Ticks' report (mode $12)
squawk       pshs      u
                    leas      <-$41,s
                    ldd       #$0002
                    std       12,s
                    std       14,s
                    ldd       #$0010
                    std       <$10,s
                    bra       b6@
a6@                 ldd       <$10,s
                    leax      <$20,s
                    leax      d,x
                    ldd       #$FFFF
                    stb       ,x
b6@                 ldd       <$10,s
                    addd      #$FFFF
                    std       <$10,s
                    bge       a6@
                    ldd       <nparts
                    bra       d6@
c6@                 ldd       8,s
                    leax      <$30,s
                    leax      d,x
                    pshs      x
                    ldd       10,s
                    ldx       #MidiChanTbl
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$0F
                    stb       [,s++]
                    ldd       8,s
                    addd      #$FFFF
d6@                 std       8,s
                    ldd       8,s
                    bgt       c6@
                    ldd       <$45,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    tfr       d,u
                    ldb       ,u
                    sex
                    std       8,s
                    ldb       5,u
                    sex
                    std       4,s
                    std       2,s
                    ldb       6,u
                    sex
                    std       6,s
                    ldd       #$0001
                    pshs      a,b
                    lbsr      dialogue
                    leas      2,s
                    ldd       8,s
                    beq       e6@
                    ldd       8,s
                    pshs      a,b
                    leax      >fmtPartHdr,pcr
                    pshs      x
                    lbsr      Printf
                    leas      4,s
e6@                 lbsr      flush
                    ldd       #$0078
                    std       10,s
                    ldd       #$0004
                    std       <$18,s
                    std       <$1A,s
                    clra
                    clrb
                    std       <$16,s
                    ldd       #$FFFF
                    std       <$1E,s
                    ldd       #$0004
                    std       <$14,s
                    std       <$12,s
                    clra
                    clrb
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    lbra      s6@
f6@                 ldb       ,u
                    sex
                    std       ,s
                    beq       h6@
                    ldd       ,s
                    cmpd      8,s
                    lbne      r6@
                    ldb       7,u
                    cmpb      #$02
                    beq       g6@
                    ldb       7,u
                    sex
                    std       12,s
                    lbeq      r6@
                    ldd       12,s
                    std       14,s
                    lbra      r6@
g6@                 ldd       14,s
                    std       12,s
                    lbra      r6@
h6@                 ldb       5,u
                    sex
                    std       4,s
                    tfr       d,x
                    bra       m6@
i6@                 ldb       7,u
                    sex
                    std       <$12,s
                    lbra      r6@
j6@                 ldb       3,u
                    sex
                    std       10,s
                    lbra      r6@
k6@                 ldb       6,u
                    sex
                    std       <$16,s
                    bra      r6@
l6@                 ldb       6,u
                    sex
                    std       <$1A,s
                    ldb       7,u
                    sex
                    std       <$18,s
                    bra      r6@
m6@                 cmpx      #$001A
                    beq       i6@
                    cmpx      #$0019
                    beq       j6@
                    cmpx      #$000B
                    beq       k6@
                    cmpx      #$000A
                    beq       l6@
                    ldd       8,s
                    beq      r6@
                    ldb       6,u
                    sex
                    std       ,s
                    ldx       4,s
                    bra       q6@
n6@                 ldd       ,s
                    leax      <$30,s
                    leax      d,x
                    ldb       ,x
                    sex
                    leax      <$20,s
                    leax      d,x
                    ldb       7,u
                    stb       ,x
                    ldd       ,s
                    cmpd      8,s
                    bne       r6@
                    ldb       7,u
                    sex
                    std       <$1E,s
                    bra       r6@
o6@                 ldd       ,s
                    leax      <$30,s
                    leax      d,x
                    ldb       7,u
                    stb       ,x
                    bra       r6@
p6@                 ldd       ,s
                    cmpd      8,s
                    bne       r6@
                    ldb       7,u
                    sex
                    std       <$14,s
                    bra       r6@
q6@                 cmpx      #$0017
                    beq       n6@
                    cmpx      #$0016
                    beq       o6@
                    cmpx      #$0018
                    beq       p6@
r6@                 lbsr      plusplus
s6@                 tfr       d,u
                    ldd       <curind
                    cmpd      <$45,s
                    lble      f6@
                    lbsr      decdec
                    tfr       d,u
                    ldd       8,s
                    lbeq      z6@
                    ldd       8,s
                    leax      <$30,s
                    leax      d,x
                    ldb       ,x
                    sex
                    std       <$10,s
                    ldd       12,s
                    pshs      a,b
                    lbsr      ArticName
                    std       ,s
                    ldd       <$16,s
                    pshs      a,b
                    lbsr      volspell
                    std       ,s
                    ldd       <$14,s
                    addd      #$0001
                    pshs      a,b
                    leax      >fmtChannelInfo,pcr
                    pshs      x
                    lbsr      Printf
                    leas      8,s
                    ldd       <$10,s
                    leax      <$20,s
                    leax      d,x
                    ldb       ,x
                    sex
                    std       <$1C,s
                    leax      >strInstrLabel,pcr
                    pshs      x
                    lbsr      Printf
                    leas      2,s
                    ldd       <$1E,s
                    cmpd      <$1C,s
                    beq       t6@
                    leax      >strSays,pcr
                    pshs      x
                    lbsr      Printf
                    leas      2,s
t6@                 ldd       <$1E,s
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #$07EB
                    leax      d,x
                    pshs      x
                    ldd       <$20,s
                    pshs      a,b
                    ldd       <$22,s
                    bge       u6@
                    leax      >strNone1,pcr
                    bra       v6@
u6@                 leax      >fmtNumEqStr1,pcr
v6@                 tfr       x,d
                    pshs      a,b
                    lbsr      Printf
                    leas      6,s
                    ldd       <$1E,s
                    cmpd      <$1C,s
                    beq       y6@
                    leax      >strButPlays,pcr
                    pshs      x
                    lbsr      Printf
                    leas      2,s
                    ldd       <$1C,s
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #$07EB
                    leax      d,x
                    pshs      x
                    ldd       <$1E,s
                    pshs      a,b
                    ldd       <$20,s
                    bge       w6@
                    leax      >strNone2,pcr
                    bra       x6@
w6@                 leax      >fmtNumEqStr2,pcr
x6@                 tfr       x,d
                    pshs      a,b
                    lbsr      Printf
                    leas      6,s
y6@                 ldx       #$01BE
                    pshs      x
                    ldd       #$000D
                    pshs      a,b
                    lbsr      FPutc
                    bra       aa6@
z6@                 ldd       2,s
                    pshs      a,b
                    lbsr      ispwexpr
                    std       ,s++
                    beq       ab6@
                    ldd       6,s
                    pshs      a,b
                    leax      >fmtAppliesToPart,pcr
                    pshs      x
                    lbsr      Printf
aa6@                leas      4,s
ab6@                leax      >strEnvironment,pcr
                    pshs      x
                    lbsr      Printf
                    leas      2,s
                    ldd       <$12,s
                    pshs      a,b
                    lbsr      volspell
                    std       ,s
                    ldd       12,s
                    clra
                    pshs      a,b
                    ldd       <$1C,s
                    pshs      a,b
                    ldd       <$20,s
                    pshs      a,b
                    leax      >fmtEnvValues,pcr
                    pshs      x
                    lbsr      Printf
                    leas      10,s
                    ldd       <$16,s
                    bge       ac6@
                    ldd       <$16,s
                    nega
                    negb
                    sbca      #$00
                    bra       ad6@
ac6@                ldd       <$16,s
ad6@                pshs      a,b
                    ldd       <$18,s
                    bge       ae6@
                    leax      >fmtFlats,pcr
                    bra       af6@
ae6@                leax      >fmtSharps,pcr
af6@                tfr       x,d
                    pshs      a,b
                    lbsr      Printf
                    leas      4,s
                    ldd       1,u
                    pshs      a,b
                    ldd       <$47,s
                    pshs      a,b
                    leax      >fmtIndexTicks,pcr
                    pshs      x
                    lbsr      Printf
                    leas      6,s
                    lbsr      hitenter
                    lbsr      wkill
                    leas      <$41,s
                    puls      u,pc
* partcopy (was L17AC): copy a [ ] block between parts: 'Click anything in Part to Copy FROM', 'Overwrites Source part!'
partcopy        pshs      u
                    leas      >-$0090,s
                    ldb       >$0095,s
                    cmpb      #$71
                    bne       a7@
                    ldd       #$0001
                    stb       <rfr_rep
                    stb       <rfr_men
                    lbra      u7@
a7@                 leax      <$28,s
                    pshs      x
                    leax      <$30,s
                    pshs      x
                    leax      <$34,s
                    pshs      x
                    lbsr      fmarks
                    leas      6,s
                    ldd       <$2E,s
                    ora       <$30,s
                    orb       <$31,s
                    std       -2,s
                    blt       b7@
                    ldd       <$2E,s
                    cmpd      <$30,s
                    bgt       c7@
b7@                 clra
                    clrb
                    pshs      a,b
                    leax      >msgMissingBrackets,pcr
                    lbra      m7@
c7@                 ldb       >$0095,s
                    cmpb      #$69
                    bne       d7@
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0002
                    pshs      a,b
                    lbsr      SendCmd99
                    leas      4,s
                    leax      >msgClickCopyFrom,pcr
                    bra      f7@
d7@                 ldd       >$0096,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    tfr       d,x
                    ldb       ,x
                    sex
                    std       ,s
                    bne       e7@
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgMustTargetNote,pcr
                    lbra      m7@
e7@                 ldd       <curcurse
                    cmpd      #$0010
                    bne       g7@
                    ldd       ,s
                    std       >UmeData_reserved_03C4
                    ldd       #$0015
                    pshs      a,b
                    lbsr      curset
                    leas      2,s
                    ldd       #$0001
                    stb       <rfr_rep
                    ldd       >UmeData_reserved_03C4
                    pshs      a,b
                    leax      >fmtReadyToCopy,pcr
                    pshs      x
                    leax      <$43,s
                    pshs      x
                    lbsr      SPrintf
                    leas      6,s
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0002
                    pshs      a,b
                    lbsr      SendCmd99
                    leas      4,s
                    leax      <$3F,s
f7@                 pshs      x
                    lbsr      Printf
                    leas      2,s
                    lbsr      wkill
                    lbra      u7@
g7@                 ldd       >UmeData_reserved_03C4
                    cmpd      ,s
                    bne       h7@
                    ldd       >$0096,s
                    cmpd      <$30,s
                    blt       h7@
                    ldd       >$0096,s
                    cmpd      <$2E,s
                    bgt       h7@
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgCantCopySamePart,pcr
                    lbra      m7@
h7@                 leas      -4,s
                    ldd       >UmeData_reserved_03C4
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #parts
                    leax      d,x
                    ldd       ,x
                    pshs      a,b
                    ldd       #$000A
                    lbsr      MulInt
                    ldx       #staves
                    leax      d,x
                    ldd       2,x
                    std       2,s
                    ldd       4,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #parts
                    leax      d,x
                    ldd       ,x
                    pshs      a,b
                    ldd       #$000A
                    lbsr      MulInt
                    ldx       #staves
                    leax      d,x
                    ldd       2,x
                    std       ,s
                    ldd       2,s
                    cmpd      #$0004
                    beq       i7@
                    ldd       ,s
                    cmpd      #$0004
                    bne       j7@
i7@                 clra
                    clrb
                    bra       k7@
j7@                 ldd       ,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #clefs
                    leax      d,x
                    ldd       2,x
                    pshs      a,b
                    ldd       4,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #clefs
                    leax      d,x
                    ldd       2,x
                    subd      ,s++
k7@                 std       <$20,s
                    leas      4,s
                    leax      14,s
                    pshs      x
                    ldd       <$32,s
                    pshs      a,b
                    lbsr      fulltime
                    leas      2,s
                    lbsr      LongStore
                    leax      <$12,s
                    pshs      x
                    ldd       <$30,s
                    pshs      a,b
                    lbsr      fulltime
                    leas      2,s
                    lbsr      LongStore
                    leax      <$16,s
                    pshs      x
                    leax      <$14,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    leax      <$14,s
                    lbsr      LongSub
                    lbsr      LongStore
                    leax      6,s
                    pshs      x
                    ldd       >$0098,s
                    pshs      a,b
                    lbsr      fulltime
                    leas      2,s
                    lbsr      LongStore
                    leax      6,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    leax      <$12,s
                    lbsr      LongCmp
                    bgt       l7@
                    leax      6,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    leax      <$1A,s
                    lbsr      LongAdd
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    leax      <$12,s
                    lbsr      LongCmp
                    ble       l7@
                    ldd       ,s
                    cmpd      >UmeData_reserved_03C4
                    bne       l7@
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgWouldOverwrite,pcr
                    bra       m7@
l7@                 leax      6,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    leax      <$1A,s
                    lbsr      LongAdd
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldx       #$0091
                    lbsr      LongCmp
                    ble       n7@
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgRunOffEnd,pcr
m7@                 pshs      x
                    lbsr      alert
                    leas      4,s
                    lbra      u7@
n7@                 lbsr      patience
                    ldd       #$0001
                    stb       <rfr_scr
                    ldd       >$0096,s
                    std       <$28,s
                    std       <$2A,s
                    leax      <$16,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    leax      <$3E,s
                    pshs      x
                    clra
                    clrb
                    pshs      a,b
                    ldd       >$009E,s
                    pshs      a,b
                    lbsr      bomb
                    leas      10,s
                    std       <$1A,s
                    beq       o7@
                    clra
                    clrb
                    pshs      a,b
                    leax      8,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    leax      <$1C,s
                    lbsr      LongAdd
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldd       <$20,s
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    leax      <$44,s
                    pshs      x
                    ldd       12,s
                    pshs      a,b
                    lbsr      ghola
                    leas      14,s
                    std       <$28,s
o7@                 leax      >$0096,s
                    pshs      x
                    leax      <$30,s
                    pshs      x
                    leax      <$34,s
                    pshs      x
                    lbsr      fmarks
                    leas      6,s
                    ldd       >UmeData_reserved_03C4
                    pshs      a,b
                    ldd       <$32,s
                    pshs      a,b
                    lbsr      pnext
                    leas      4,s
p7@                 std       <$24,s
                    ldd       <$24,s
                    lblt      s7@
                    leax      10,s
                    pshs      x
                    ldd       <$26,s
                    pshs      a,b
                    lbsr      fulltime
                    leas      2,s
                    lbsr      LongStore
                    leax      10,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    leax      <$16,s
                    lbsr      LongCmp
                    lbge      s7@
                    leax      2,s
                    pshs      x
                    leax      8,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    leax      <$10,s
                    lbsr      LongAdd
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    leax      <$14,s
                    lbsr      LongSub
                    lbsr      LongStore
                    ldd       <$24,s
                    pshs      a,b
                    lbsr      i2p
                    std       ,s
                    leax      <$34,s
                    pshs      x
                    lbsr      CopyEvent
                    leas      4,s
                    ldb       <$37,s
                    sex
                    pshs      a,b
                    ldd       2,s
                    pshs      a,b
                    leax      6,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    lbsr      enter
                    leas      8,s
                    std       <$22,s
                    blt       s7@
                    ldd       <$22,s
                    cmpd      <$24,s
                    bgt       q7@
                    ldd       <$24,s
                    addd      #$0001
                    std       <$24,s
q7@                 ldd       <$28,s
                    cmpd      <$22,s
                    bge       r7@
                    ldd       <$22,s
                    std       <$28,s
r7@                 ldd       <$22,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    tfr       d,u
                    leax      <$35,s
                    pshs      x
                    pshs      u
                    ldd       #$0003
                    addd      ,s++
                    pshs      a,b
                    lbsr      CopyNoteAttrs
                    leas      4,s
                    ldd       <$24,s
                    pshs      a,b
                    lbsr      next
                    leas      2,s
                    lbra      p7@
s7@                 clra
                    clrb
                    pshs      a,b
                    ldd       2,s
                    pshs      a,b
                    ldd       <$2C,s
                    pshs      a,b
                    ldd       <$30,s
                    pshs      a,b
                    lbsr      fixup
                    leas      8,s
                    ldd       <$1C,s
                    beq       t7@
                    ldd       <$28,s
                    pshs      a,b
                    ldd       <$2C,s
                    pshs      a,b
                    ldd       <$20,s
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    lbsr      tranpart
                    leas      8,s
t7@                 lbsr      wkill
                    ldd       #$0001
                    stb       <rfr_scr
u7@                 leas      >$0090,s
                    puls      u,pc
* Move only the clicked note. place() changes the temporary attributes while
* dragging; commit pitch/accidental only, preserving duration, time and part.
movenote            pshs      u
                    leas      -MoveNoteFrame,s
                    ldd       MoveNoteArg,s       STACK OFFSET: caller's event index
                    pshs      d
                    lbsr      i2p
                    leas      2,s
                    tfr       d,u
                    tst       ,u
                    beq       MoveNoteDone
                    ldb       5,u
                    cmpb      #$20
                    beq       MoveNoteDone
                    leax      3,u
                    pshs      x
                    leax      MoveNoteAttrs+2,s   STACK OFFSET: temporary attributes, one argument pushed
                    pshs      x
                    lbsr      CopyNoteAttrs
                    leas      4,s
                    clra
                    clrb
                    pshs      d                   STACK ARGUMENT: replace, not add
                    leax      MoveNoteAttrs+2,s   STACK OFFSET: temporary attributes, one argument pushed
                    pshs      x
                    pshs      u
                    ldd       MoveNoteArg+6,s     STACK OFFSET: event index, three arguments pushed
                    pshs      d
                    lbsr      place
                    leas      8,s
                    cmpd      #0
                    beq       MoveNoteDone
                    ldd       MoveNoteArg,s
                    pshs      d
                    lbsr      i2p                 restore the clicked event's page after the drag
                    leas      2,s
                    tfr       d,u
                    ldb       MoveNoteAttrs+2,s   STACK OFFSET: resulting pitch
                    stb       5,u
                    ldb       MoveNoteAttrs+3,s   STACK OFFSET: resulting accidental
                    stb       6,u
                    ldd       #-1
                    std       <undind
                    ldb       #1
                    stb       <rfr_scr
                    ldd       MoveNoteArg,s
                    pshs      d
                    lbsr      AuditionPlacedNote
                    leas      2,s
MoveNoteDone        leas      MoveNoteFrame,s
                    puls      u,pc
* smash (was L1C6B): mode $0F (key '!'): repeats the current note over the rest of the bar; else 'Nothing changed.'
smash     pshs      u
                    leas      -13,s
                    ldd       <$11,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    tfr       d,u
                    ldb       ,u
                    sex
                    std       ,s
                    lbeq      t8@
                    lbsr      patience
                    ldx       #brush
                    pshs      x
                    leax      10,s
                    pshs      x
                    lbsr      CopyNoteAttrs
                    leas      4,s
                    ldb       10,s
                    cmpb      #$20
                    beq       j8@
                    ldd       ,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #parts
                    leax      d,x
                    ldd       2,x
                    std       2,s
                    clra
                    andb      #$01
                    beq       g8@
                    ldd       #$0008
                    bra       i8@
g8@                 ldd       2,s
                    clra
                    andb      #$02
                    beq       h8@
                    ldd       #$FFF8
                    bra       i8@
h8@                 clra
                    clrb
i8@                 asra
                    rorb
                    addd      #$0004
                    stb       10,s
j8@                 ldd       1,u
                    std       6,s
                    bra       m8@
k8@                 pshs      u
                    lbsr      anybar
                    std       ,s++
                    bne       n8@
                    ldb       ,u
                    sex
                    cmpd      ,s
                    bne       l8@
                    ldb       5,u
                    cmpb      #$20
                    bne       n8@
l8@                 lbsr      plusplus
                    tfr       d,u
m8@                 ldd       <curind
                    cmpd      <nevents
                    blt       k8@
n8@                 ldd       <curind
                    cmpd      <nevents
                    bne       o8@
                    ldd       <UmeData_reserved_0093
                    bra       p8@
o8@                 ldd       1,u
p8@                 subd      6,s
                    std       6,s
                    ldb       9,s
                    sex
                    pshs      a,b
                    ldb       10,s
                    sex
                    pshs      a,b
                    lbsr      cod2raw
                    leas      4,s
                    std       4,s
                    bra       r8@
q8@                 ldd       ,s
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    leax      12,s
                    pshs      x
                    ldd       <$17,s
                    pshs      a,b
                    lbsr      qchip
                    leas      8,s
                    ldd       #$0001
                    stb       <rfr_scr
                    ldd       <$11,s
                    pshs      a,b
                    lbsr      next
                    leas      2,s
                    std       <$11,s
                    blt       s8@
r8@                 ldd       6,s
                    subd      4,s
                    std       6,s
                    bge       q8@
s8@                 lbsr      wkill
                    ldb       <rfr_scr
                    bne       t8@
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgNothingChanged,pcr
                    pshs      x
                    lbsr      alert
                    leas      4,s
t8@                 leas      13,s
                    puls      u,pc
* MergeNextNoteCmd (was L1D62): mode $11 (key '%'): merges the clicked note with the next abutting one (ghola, fixup)
MergeNextNoteCmd    pshs      u
                    leas      <-$17,s
                    ldd       <$1B,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    tfr       d,u
                    ldb       ,u
                    sex
                    std       6,s
                    beq       u8@
                    ldd       1,u
                    std       8,s
                    ldb       5,u
                    sex
                    std       4,s
                    ldb       4,u
                    sex
                    std       2,s
                    pshs      a,b
                    ldb       3,u
                    sex
                    pshs      a,b
                    lbsr      cod2raw
                    leas      4,s
                    std       12,s
                    ldd       <$1B,s
                    pshs      a,b
                    lbsr      next
                    leas      2,s
                    std       ,s
                    blt       u8@
                    ldd       ,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    tfr       d,u
                    ldd       8,s
                    addd      12,s
                    cmpd      1,u
                    beq       v8@
u8@                 clra
                    clrb
                    lbra      w8@
v8@                 ldb       4,u
                    sex
                    pshs      a,b
                    ldb       3,u
                    sex
                    pshs      a,b
                    lbsr      cod2raw
                    leas      4,s
                    std       10,s
                    leax      14,s
                    pshs      x
                    ldd       <$1D,s
                    pshs      a,b
                    lbsr      fulltime
                    leas      2,s
                    lbsr      LongStore
                    ldd       12,s
                    addd      10,s
                    lbsr      IntToLong
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    leax      <$16,s
                    pshs      x
                    clra
                    clrb
                    pshs      a,b
                    ldd       <$23,s
                    pshs      a,b
                    lbsr      bomb
                    leas      10,s
                    ldd       4,s
                    stb       <$14,s
                    ldd       #$0001
                    pshs      a,b
                    leax      <$10,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldd       <$12,s
                    addd      <$10,s
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    leax      <$1C,s
                    pshs      x
                    ldd       <$12,s
                    pshs      a,b
                    lbsr      ghola
                    leas      14,s
                    std       ,s
                    clra
                    clrb
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    ldd       4,s
                    pshs      a,b
                    ldd       <$21,s
                    pshs      a,b
                    lbsr      fixup
                    leas      8,s
                    ldd       #$0001
w8@                 leas      <$17,s
                    puls      u,pc
* strDynamicsNames (was L1E51): eight 3-character dynamics names, each NUL-terminated
strDynamicsNames    fcc       /ppp/
                    fcb       $00
                    fcc       /pp /
                    fcb       $00
                    fcc       /p  /
                    fcb       $00
                    fcc       /mp /
                    fcb       $00
                    fcc       /mf /
                    fcb       $00
                    fcc       /f  /
                    fcb       $00
                    fcc       /ff /
                    fcb       $00
                    fcc       /fff/
                    fcb       $00
* strArticNames (was L1E71): five 8-character articulation names, each NUL-terminated
strArticNames       fcc       /Tied    /
                    fcb       $00
                    fcc       /Legato  /
                    fcb       $00
                    fcc       /(legato)/
                    fcb       $00
                    fcc       /Marcato /
                    fcb       $00
                    fcc       /Staccato/
                    fcb       $00
* fmtPartHdr (was L1E9E): ' Part %d, '
fmtPartHdr          fcc       / Part %d, /
                    fcb       $00
* fmtChannelInfo (was L1EA9): 'Channel %d  %s  %s'
fmtChannelInfo      fcc       /Channel %d  %s  %s/
                    fcb       $0D,$00
* strInstrLabel (was L1EBD): ' Instr: '
strInstrLabel       fcc       / Instr: /
                    fcb       $00
* strSays (was L1EC6): 'says '
strSays             fcc       /says /
                    fcb       $00
* strNone1 (was L1ECC): 'none'
strNone1            fcc       /none/
                    fcb       $00
* fmtNumEqStr1 (was L1ED1): '%d=%s'
fmtNumEqStr1        fcc       /%d=%s/
                    fcb       $00
* strButPlays (was L1ED7): '; but plays '
strButPlays         fcc       /; but plays /
                    fcb       $00
* strNone2 (was L1EE4): 'none'
strNone2            fcc       /none/
                    fcb       $00
* fmtNumEqStr2 (was L1EE9): '%d=%s'
fmtNumEqStr2        fcc       /%d=%s/
                    fcb       $00
* fmtAppliesToPart (was L1EEF): 'Applies to Part %d.'
fmtAppliesToPart    fcc       /Applies to Part %d./
                    fcb       $0D,$00
* strEnvironment (was L1F04): 'Environment:  '
strEnvironment      fcc       /Environment:  /
                    fcb       $00
* fmtEnvValues (was L1F13): ' %d/%d at %d  %s  '
fmtEnvValues        fcc       / %d/
                    fcb       $2F
                    fcc       /%d at %d  %s  /
                    fcb       $00
* fmtFlats (was L1F26): '%d flats'
fmtFlats            fcc       /%d flats/
                    fcb       $0D,$00
* fmtSharps (was L1F30): '%d sharps'
fmtSharps           fcc       /%d sharps/
                    fcb       $0D,$00
* fmtIndexTicks (was L1F3B): '   Index %d at %u Ticks'
fmtIndexTicks       fcc       /   Index %d at %u Ticks/
                    fcb       $0D,$00
* msgMissingBrackets (was L1F54): 'Missing or reversed [ ]!'
msgMissingBrackets  fcc       /Missing or reversed [ ]!/
                    fcb       $00
* msgClickCopyFrom (was L1F76): 'Click anything in Part' CR '  to Copy FROM:'
msgClickCopyFrom    fcc       /Click anything in Part/
                    fcb       $0D
                    fcc       /  to Copy FROM:/
                    fcb       $00
* msgMustTargetNote (was L1F9D): ' Target a note or rest.'
msgMustTargetNote   fcc       / Target a note or rest./
                    fcb       $00
* fmtReadyToCopy (was L1FBA): ' Ready to Copy' CR '   from Part %d.'
fmtReadyToCopy      fcc       / Ready to Copy/
                    fcb       $0D
                    fcc       /   from Part %d./
                    fcb       $00
* msgCantCopySamePart (was L1FDA): ' Can't copy the Same Part' CR '  to Inside of Block.'
msgCantCopySamePart fcc       / Can't copy the Same Part/
                    fcb       $0D
                    fcc       /  to Inside of Block./
                    fcb       $00
* msgWouldOverwrite (was L200A): 'Overwrites Source part!'
msgWouldOverwrite   fcc       /Overwrites Source part!/
                    fcb       $00
* msgRunOffEnd (was L2027): 'Runs off the score's end!'
msgRunOffEnd        fcc       /Runs off the score's end!/
                    fcb       $00

* msgNothingChanged (was L2052): ' Nothing changed.'; the bytes after it are unreferenced leftovers
msgNothingChanged   fcc       / Nothing changed./
                    fcb       $00,$EC,$64,$E3
                    fcs       /f4F./
                    fcb       $68,$EE,$66,$20,$04,$E6,$80,$E7
                    fcb       $C0,$AC,$E4,$25,$F8,$35,$C6
* ShiftEventsUp (was L207A): moves 8-byte event records up one slot from the end down to base (opens a hole for makroom)
ShiftEventsUp       ldd       4,s
                    ldx       2,s
                    pshs      x
                    leax      d,x
                    bra       b9@
a9@                 ldd       -8,x
                    std       ,x
                    ldd       -6,x
                    std       2,x
                    ldd       -4,x
                    std       4,x
                    ldd       -2,x
                    std       6,x
                    leax      -8,x
b9@                 cmpx      ,s
                    bhi       a9@
                    puls      x,pc
* ShiftEventsDown (was L209C): moves 8-byte event records down one slot (closes the hole left by remove)
ShiftEventsDown     ldx       2,s
                    ldd       4,s
                    addd      2,s
                    pshs      a,b
                    bra       b10@
a10@                ldd       8,x
                    std       ,x
                    ldd       10,x
                    std       2,x
                    ldd       12,x
                    std       4,x
                    ldd       14,x
                    std       6,x
                    leax      8,x
b10@                cmpx      ,s
                    blo       a10@
                    puls      a,b,pc
* CopyNoteAttrs (was L20BE): copies 5 bytes src->dst; used with +3 offsets to copy an event's duration/pitch bytes 3-7
CopyNoteAttrs       pshs      u
                    ldu       6,s
                    ldx       4,s
                    ldd       ,u
                    std       ,x
                    ldd       2,u
                    std       2,x
                    ldb       4,u
                    stb       4,x
                    puls      u,pc
* CopyEvent (was L20D2): copies one 8-byte event record src->dst
CopyEvent           pshs      u
                    ldu       6,s
                    ldx       4,s
                    ldd       ,u
                    std       ,x
                    ldd       2,u
                    std       2,x
                    ldd       4,u
                    std       4,x
                    ldd       6,u
                    std       6,x
                    puls      u,pc
* OpenWindow (was L20EA): a no-op here (the CoCo3 original linked GrfDrv and opened /W); sysup still calls it
OpenWindow          rts
                    puls      u,pc
* sysup (was L2211): opens the console, forks s9gui with a /pipe as its stdin and a second one as its stdout
* (the reply pipe, kept as FranReply), makes the command pipe path 1, sets <group and the priority
sysup            pshs      a,b,x,y,u
                    bsr      OpenWindow
* The console is opened by name rather than duplicated from stdin: started from a script, path 0 is
* the spent script file and every read returns E$EOF.
                    ldd       #$0003              UPDAT. - read and write
                    pshs      a,b
                    leax      >pathTerm,pcr
                    pshs      x
                    lbsr      OpenConsole         path 2's terminal, /term only as the fallback
                    leas      4,s
                    std       2,s                 the console we will put back on path 0
                    clra
                    clrb
                    pshs      a,b
                    lbsr      ClosePath
                    leas      2,s
                    ldd       #$0003
                    pshs      a,b
                    leax      >pathPipe,pcr
                    pshs      x
                    lbsr      OpenPath
                    leas      4,s
                    std       ,s
* The second /pipe takes path 1 for the fork and becomes s9gui's stdout, its reply pipe (path 2 stays
* the console: s9gui allocates the bitmap through SS.AScrn on path 2). After the fork it moves to a
* path of our own (FranReply) and path 1 becomes the command pipe.
                    ldd       #$0001
                    pshs      a,b
                    lbsr      ClosePath
                    leas      2,s
                    ldd       #$0003
                    pshs      a,b
                    leax      >pathPipe,pcr
                    pshs      x
                    lbsr      OpenPath            the lowest free path: 1
                    leas      4,s
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldx       #FranParam          'ab' CR: the tail blocks s9gui copies the symbols from (TailInit)
                    pshs      x
                    ldd       #$0003              their length (os9fork(name, paramlen, params, type, lang, datasize))
                    pshs      a,b
                    leax      >strFran,pcr
                    lbsr      S9Qualify
                    pshs      x
                    lbsr      ForkProg
                    leas      12,s
                    std       4,s
                    bge       a12@
                    leax      >msgCantForkFran,pcr
                    pshs      x
                    lbsr      PutsStdout
                    leas      2,s
                    ldd       #$0002
                    pshs      a,b
                    lbsr      SleepSeconds
                    leas      2,s
                    ldd       #$0025
                    pshs      a,b
                    lbsr      ExitProg
                    leas      2,s
a12@                ldd       #$0001
                    pshs      a,b
                    lbsr      DupPath             the reply pipe on a path of our own
                    leas      2,s
                    stb       >FranReply
                    ldd       #$0001
                    pshs      a,b
                    lbsr      ClosePath           path 1 is free again for the command pipe below
                    leas      2,s
                    ldd       ,s
                    pshs      a,b
                    lbsr      DupPath
                    leas      2,s
                    clra
                    clrb
                    pshs      a,b
                    lbsr      ClosePath
                    leas      2,s
                    ldd       2,s
                    pshs      a,b
                    lbsr      DupPath
                    leas      2,s
                    ldd       2,s
                    pshs      a,b
                    lbsr      ClosePath
                    leas      2,s
                    lbsr      GetPid
                    std       <group
                    ldd       #$008C
                    pshs      a,b
                    ldd       <group
                    pshs      a,b
                    lbsr      SetPriority
                    leas      4,s
                    leas      6,s
                    puls      u,pc
* charput (was L22C8): putchar(c) through FPutc on stdout ($01BE = _iob[1]); vector $0383
charput               pshs      u
                    ldx       #$01BE
                    pshs      x
                    ldb       7,s
                    sex
                    pshs      a,b
                    lbsr      FPutc
                    lbra      L250C
* addbars (was L22DA): calls overlay s9e cmd 'B' to append bars; ' No new bars!' if nothing added
addbars          pshs      a,b,u
                    ldd       <nevents
                    addd      #$FFFF
                    std       <gind
                    ldd       #$0014
                    std       <xgoal
                    ldx       #$0091
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldd       #$0004
                    pshs      a,b
                    ldd       <UmeData_reserved_0003
                    lbsr      DivInt
                    addd      #$0003
                    pshs      a,b
                    ldd       <nbars
                    addd      #$0001
                    pshs      a,b
                    ldd       <nevents
                    addd      #$FFFF
                    pshs      a,b
                    ldd       #$0042
                    pshs      a,b
                    ldd       #$0045
                    pshs      a,b
                    lbsr      soowee
                    leas      14,s
                    std       ,s
                    bne       a13@
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgNoNewBars,pcr
                    pshs      x
                    lbsr      alert
                    leas      4,s
                    bra       b13@
a13@                ldd       #$0001
                    stb       <rfr_scr
b13@                ldd       ,s
                    leas      2,s
                    puls      u,pc
* uinit (was L233F): stores ~45 main-program routine addresses at $0351-$03B5 for the overlays, sets option defaults, setmouse, FreeAllBlocks, 'no synth named.'
uinit    pshs      u
                    clr       >FocusDirty
                    clr       >FocusOnly
                    ldd       #-1
                    std       >FocusedPart
                    std       >PaintedFocus


                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0004
                    pshs      a,b
                    lbsr      SetPathOption
                    leas      4,s
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0007
                    pshs      a,b
                    lbsr      SetPathOption
                    leas      4,s
* SetPathOption's get-modify-put of the option block leaves PD.EOR and PD.EOF wrong on WildBits,
* so both are set explicitly; a stray PD.EOF makes an ordinary key read back as E$EOF.
                    ldd       #$000D              PD.EOR: end of record = carriage return
                    pshs      a,b
                    ldd       #$000B              option offset 11
                    pshs      a,b
                    lbsr      SetPathOption
                    leas      4,s
                    ldd       #$0000              PD.EOF = none (SCF ignores a zero EOF character)
                    pshs      a,b
                    ldd       #$000C              option offset 12
                    pshs      a,b
                    lbsr      SetPathOption
                    leas      4,s
                    leax      newscore,pcr
                    stx       >pMidiNewScore
                    leax      styinit,pcr
                    stx       >pMidiStaffInit
                    leax      i2p,pcr
                    stx       >pMidiEventPtr
                    leax      >pipemenu,pcr
                    stx       >pPipeMenu
                    leax      >menu3,pcr
                    stx       >pMenu3
                    leax      >fixup,pcr
                    stx       >pfixup
                    leax      >charmaus,pcr
                    stx       >pcharmaus
                    leax      >fmarks,pcr
                    stx       >pfmarks
                    leax      >findts,pcr
                    stx       >pfindts
                    leax      >giveback,pcr
                    stx       >pgivebac
                    leax      >textmenu,pcr
                    stx       >ptextmen
                    leax      >charput,pcr
                    stx       >pputchar
                    leax      >bell,pcr
                    stx       >pbeep
                    leax      >mflush,pcr
                    stx       >pmflush
                    leax      >putmidi,pcr
                    stx       >pputmidi
                    leax      >smfwrit,pcr
                    stx       >psmfwrit
                    leax      >keymouse,pcr
                    stx       >pkeymaus
                    leax      >getempty,pcr
                    stx       >pgetempty
                    leax      >gets,pcr
                    stx       >pgets
                    leax      >inkey,pcr
                    stx       >pinkey
                    leax      >pswap,pcr
                    stx       >ppswap
                    leax      >ievtinit,pcr
                    stx       >pievtinit
                    leax      >swapevts,pcr
                    stx       >pswapevts
                    leax      >flush,pcr
                    stx       >pflush
                    leax      >Printf,pcr
                    stx       >pprintf
                    leax      >SPrintf,pcr
                    stx       >psprintf
                    leax      >owrite,pcr
                    stx       >powrite
                    leax      >nfwrite,pcr
                    stx       >pnfwrite
                    leax      >mouce,pcr
                    stx       >pmouce
                    leax      >yesno,pcr
                    stx       >pyesno
                    leax      >alert,pcr
                    stx       >palert
                    leax      >hitenter,pcr
                    stx       >phit
                    leax      >fixmarx,pcr
                    stx       >pfixmarx
                    leax      >parse,pcr
                    stx       >pparse
                    leax      >regen,pcr
                    stx       >pregen
                    leax      >enter,pcr
                    stx       >penter
                    leax      >remove,pcr
                    stx       >premove
                    leax      >gtsig,pcr
                    stx       >pgtsig
                    leax      >gksig,pcr
                    stx       >pgksig
                    leax      >fulltime,pcr
                    stx       >pfulltime
                    leax      >makroom,pcr
                    stx       >pmakroom
                    leax      >play,pcr
                    stx       >pplay
                    leax      >tranpart,pcr
                    stx       >ptranprt
                    leax      >clonemid,pcr
                    stx       >pclonmid
                    leax      >soowee,pcr
                    stx       >psoowee
                    leax      >addbars,pcr
                    stx       >paddbars
                    leax      >addclone,pcr
                    stx       >paddclone
                    leax      >drawnr,pcr
                    stx       >pdrawnr
                    leax      >pluspart,pcr
                    stx       >ppluspart
                    leax      >repart,pcr
                    stx       >prepart
                    leax      >chip,pcr
                    stx       >pchip
                    leax      >cod2raw,pcr
                    stx       >pcod2raw
                    leax      >exprmenu,pcr
                    stx       >pexprmenu
                    leax      >partline,pcr
                    stx       >ppartline
                    leax      >findstaff,pcr
                    stx       >pfindstaff
                    ldd       #$0001
                    stb       >UmeData_reserved_03D3
                    stb       >UmeData_reserved_03D2
                    stb       >UmeData_reserved_03D1
                    stb       >UmeData_reserved_03D0
                    stb       >UmeData_reserved_03CF
                    stb       >UmeData_reserved_03CE
                    stb       >UmeData_reserved_03CD
                    clra
                    clrb
                    stb       <pldebug
                    ldd       #$0001
                    stb       <compact
                    clra
                    clrb
                    std       <nevents
                    ldd       #$003C
                    std       <secmin
                    clra
                    clrb
                    std       <transp
                    std       <velo
                    lbsr      setmouse
                    lbsr      FreeAllBlocks
                    clra
                    clrb
                    std       <xgoal
                    std       <gind
                    leax      >msgNoSynthNamed,pcr
                    pshs      x
                    ldx       #$0CB4
                    pshs      x
                    lbsr      StrCopy
* L250C (original offset $250C): the 'leas 4,s / puls u,pc' epilogue that charput jumps to after
* its FPutc.
L250C               equ       *
                    leas      4,s
                    puls      u,pc
* newscore (was L2510): clears the event list (count 1), parts/staves, creates the events array, optionally runs staffinit and s9l 'm'
newscore            pshs      u
                    lbsr      MidiDefaults        all parts and channels on, every part to channel 1
                    ldd       #-1
                    std       >FocusedPart

                    ldd       #$0001
                    std       <nevents
                    clra
                    clrb
                    pshs      a,b
                    lbsr      i2p
                    std       ,s++
                    beq       a14@
                    ldx       #$0C11
                    pshs      x
                    ldd       <curevp
                    pshs      a,b
                    lbsr      CopyEvent
                    leas      4,s
a14@                ldd       #$0004
                    std       <UmeData_reserved_0005
                    std       <UmeData_reserved_0003
                    clra
                    clrb
                    std       <keysig
                    std       <nstaves
                    std       <nparts
                    ldd       #$003C
                    std       <secmin
                    clra
                    clrb
                    std       <transp
                    std       <velo
                    lbsr      giveback
                    ldd       #$0001
                    pshs      a,b
                    lbsr      SendCmd8B
                    leas      2,s
                    clra
                    clrb
                    pshs      a,b
                    lbsr      SendCmd89
                    leas      2,s
                    ldd       #$0FFE
                    pshs      a,b
                    lbsr      ievtinit
                    leas      2,s
                    lbsr      titleclr
                    ldb       5,s
                    bne       b14@
                    puls      u,pc
b14@                clra
                    clrb
                    stb       >UmeData_reserved_0BEB
                    tst       <WizForce           the editor's Wizard row: no question, straight to the prompts
                    beq       b14a@
                    clr       <WizForce
                    bra       b14w@
b14a@               leax      >msgLayoutPrompts,pcr
                    pshs      x
                    lbsr      yesno
                    std       ,s++
                    beq       c14@
b14w@               lbsr      staffinit
c14@                clra
                    clrb
                    pshs      a,b
                    ldd       #$006D
                    pshs      a,b
                    ldd       #$004C
                    pshs      a,b
                    lbsr      soowee
                    leas      6,s
                    lbsr      scorebars
                    puls      u,pc
* scorereset: the event list back to its first event, as newscore does it (count 1, the template event
* copied in, the pages above given back); signatures, staves and parts are left as they are.
scorereset          pshs      u
                    ldd       #$0001
                    std       <nevents
                    clra
                    clrb
                    pshs      a,b
                    lbsr      i2p
                    std       ,s++
                    beq       scr1@
                    ldx       #$0C11
                    pshs      x
                    ldd       <curevp
                    pshs      a,b
                    lbsr      CopyEvent
                    leas      4,s
scr1@               lbsr      giveback
                    puls      u,pc
* scorebars: the tail of newscore after the layout designer, also run by the Score menu's Setup and
* Layout: timesig, s9e 'B' AddBars (eight bars of rests for every part), then the time-signature
* and key-signature events.
scorebars           pshs      u
                    lbsr      timesig
                    clra
                    clrb
                    pshs      a,b
                    pshs      a,b
                    ldd       #$0008
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0042
                    pshs      a,b
                    ldd       #$0045
                    pshs      a,b
                    lbsr      soowee
                    leas      14,s
                    std       <nbars
                    ldd       #$0001
                    pshs      a,b
                    lbsr      makroom
                    leas      2,s
                    tfr       d,u
                    clra
                    clrb
                    std       1,u
                    clra
                    clrb
                    stb       ,u
                    ldd       #$000A
                    stb       5,u
                    ldd       <UmeData_reserved_0003
                    stb       6,u
                    ldd       <UmeData_reserved_0005
                    stb       7,u
                    ldd       <keysig
                    beq       d14@
                    ldd       #$0002
                    pshs      a,b
                    lbsr      makroom
                    leas      2,s
                    tfr       d,u
                    clra
                    clrb
                    std       1,u
                    clra
                    clrb
                    stb       ,u
                    ldd       #$000B
                    stb       5,u
                    ldd       <keysig
                    stb       6,u
d14@                puls      u,pc
* timesig (was L2607): maps the time-signature denominator <$05 (2,4,8,16) to a beat code in <dencodur and derives beat/bar tick values
timesig         pshs      u
                    ldx       <UmeData_reserved_0005
                    bra       g15@
a15@                ldd       #$0002
                    bra       e15@
b15@                ldd       #$0003
                    bra       e15@
c15@                ldd       #$0004
                    bra       e15@
d15@                ldd       #$0005
e15@                std       <dencodur
                    bra       h15@
f15@                clra
                    clrb
                    puls      u,pc
g15@                cmpx      #$0002
                    beq       a15@
                    cmpx      #$0004
                    beq       b15@
                    cmpx      #$0008
                    beq       c15@
                    cmpx      #$0010
                    beq       d15@
                    bra       f15@
h15@                ldd       #$00C0
                    pshs      a,b
                    ldd       <UmeData_reserved_0005
                    lbsr      DivInt
                    std       <dendur
                    ldd       <dencodur
                    cmpd      #$0004
                    blt       i15@
                    ldd       <UmeData_reserved_0003
                    cmpd      #$0006
                    blt       i15@
                    ldd       <UmeData_reserved_0003
                    pshs      a,b
                    ldd       #$0003
                    lbsr      ModInt
                    bne       i15@
                    ldd       #$0001
                    bra       j15@
i15@                clra
                    clrb
j15@                stb       <tripper
                    ldb       <tripper
                    beq       k15@
                    ldd       <dendur
                    pshs      a,b
                    ldd       #$0003
                    lbsr      MulInt
                    std       <zonedur
                    ldd       <UmeData_reserved_0003
                    pshs      a,b
                    ldd       #$0003
                    lbsr      DivInt
                    std       <nzones
                    bra       l15@
k15@                ldd       <UmeData_reserved_0003
                    std       <nzones
                    ldd       <dendur
                    std       <zonedur
l15@                ldd       #$0001
                    puls      u,pc
* gksig: key-signature dialog (paper 3D box), result in <keysig; vector $0367  [reading uncertain]
gksig               pshs      u
                    leas      <-$51,s
                    ldd       #WinStylePaper3D    the paper 3D box
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0004
                    pshs      a,b
                    ldd       #$0020
                    pshs      a,b
                    ldd       #$0078
                    pshs      a,b
                    ldd       #$0014
                    pshs      a,b
                    lbsr      wcreate
                    leas      12,s
                    leax      >L2C19,pcr
                    pshs      x
                    lbsr      Printf
                    leas      2,s
                    leax      >L2C39,pcr
                    pshs      x
                    lbsr      Printf
                    leas      2,s
                    leax      >L2C5A,pcr
                    pshs      x
                    lbsr      Printf
                    leas      2,s
                    leax      ,s
                    pshs      x
                    lbsr      gets
                    leas      2,s
                    leax      ,s
                    pshs      x
                    lbsr      AtoI
                    leas      2,s
                    std       <keysig
                    lbsr      wkill
                    lbsr      flush
                    ldd       <keysig
                    leas      <$51,s
                    puls      u,pc
gtsig               pshs      u
                    leas      <-$52,s
                    ldd       #WinStylePaper3D    the paper 3D box
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0005
                    pshs      a,b
                    ldd       #$0020
                    pshs      a,b
                    ldd       #$0078
                    pshs      a,b
                    ldd       #$0014
                    pshs      a,b
                    lbsr      wcreate
                    leas      12,s
                    leax      >L2C73,pcr
                    pshs      x
                    lbsr      Printf
                    leas      2,s
                    leax      >L2C8E,pcr
                    pshs      x
                    lbsr      Printf
                    leas      2,s
                    leax      >L2CAE,pcr
                    bra      gtsig_6
gtsig_1               leax      >L2CCB,pcr
                    pshs      x
                    lbsr      Printf
                    leas      2,s
                    leax      1,s
                    pshs      x
                    lbsr      gets
                    leas      2,s
                    ldb       1,s
                    beq       gtsig_5
                    leax      1,s
                    pshs      x
                    lbsr      AtoI
                    leas      2,s
                    std       <UmeData_reserved_0003
                    ldd       <UmeData_reserved_0003
                    bgt       gtsig_2
                    ldd       #$0001
                    std       <UmeData_reserved_0003
gtsig_2               ldd       <UmeData_reserved_0003
                    cmpd      #$001F
                    ble       gtsig_3
                    ldd       #$001F
                    std       <UmeData_reserved_0003
gtsig_3               ldd       #$002F
                    pshs      a,b
                    leax      3,s
                    pshs      x
                    lbsr      StrIndex
                    leas      4,s
                    tfr       d,u
                    stu       -2,s
                    bne       gtsig_4
                    bra       gtsig_1
gtsig_4               pshs      u
                    ldd       #$0001
                    addd      ,s++
                    pshs      a,b
                    lbsr      AtoI
                    leas      2,s
                    std       <UmeData_reserved_0005
gtsig_5               lbsr      timesig
                    std       -2,s
                    bne       gtsig_7
                    lbsr      bell
                    leax      >L2CE0,pcr
gtsig_6               pshs      x
                    lbsr      Printf
                    leas      2,s
                    bra      gtsig_1
gtsig_7               lbsr      wkill
                    lbsr      flush
                    leas      <$52,s
                    puls      u,pc
* dfalprts (was L27CA): for each part 1..n: partstaff then SendPartDef ($8A packet)
dfalprts        pshs      u
                    leas      -10,s
                    ldd       14,s
                    bra       b16@
a16@                leax      2,s
                    pshs      x
                    leax      2,s
                    pshs      x
                    leax      8,s
                    pshs      x
                    ldd       14,s
                    pshs      a,b
                    lbsr      partstaff
                    leas      8,s
                    std       6,s
                    clra
                    clrb
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    ldd       <$12,s
                    pshs      a,b
                    lbsr      SendPartDef
                    leas      12,s
                    ldd       8,s
                    addd      #$0001
b16@                std       8,s
                    ldd       8,s
                    cmpd      <$10,s
                    ble       a16@
                    leas      10,s
                    puls      u,pc
* dfalstvs (was L281A): for each staff in a range: reads the 10-byte $0C19 staff entry and SendStaffDef ($88)
dfalstvs       pshs      a,b,u
                    ldd       6,s
                    bra       b17@
a17@                ldd       ,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      MulInt
                    ldx       #staves
                    leax      d,x
                    ldd       ,x
                    pshs      a,b
                    ldd       2,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      MulInt
                    ldx       #staves
                    leax      d,x
                    ldd       2,x
                    pshs      a,b
                    ldd       4,s
                    pshs      a,b
                    lbsr      SendStaffDef
                    leas      6,s
                    ldd       ,s
                    addd      #$0001
b17@                std       ,s
                    ldd       ,s
                    cmpd      8,s
                    ble       a17@
                    leas      2,s
                    puls      u,pc
* staffinit (was L2861): score layout prompts: clef per staff, '1, 2, or 3 Parts on Staff #%d?', limits, table print, 'Is this setup OK?'
staffinit        pshs      u
                    leas      <-$5F,s
                    lbsr      text
                    bra       a18@
a18@                clra
                    clrb
                    std       <nparts
                    ldu       #staves
                    ldx       #$0C63
                    stx       12,s
                    ldd       #$0001
                    std       <nstaves
                    lbra      j18@
b18@                ldd       <nstaves
                    pshs      a,b
                    lbsr      askclef
                    leas      2,s
                    std       4,s
                    lblt      k18@
                    ldd       4,s
                    std       2,u
                    ldd       <nstaves
                    pshs      a,b
                    leax      >fmtPartsOnStaff,pcr
                    pshs      x
                    lbsr      Printf
                    leas      4,s
                    lbsr      onehex
                    clra
                    andb      #$03
                    std       10,s
                    bne       c18@
                    ldd       10,s
                    addd      #$0001
                    std       10,s
c18@                ldd       #$0001
                    std       ,s
                    bra       i18@
d18@                ldd       <nparts
                    addd      #$0001
                    std       <nparts
                    cmpd      #$0010
                    ble       e18@
                    leax      <$5F,s
                    lbra      m18@
e18@                ldd       <nstaves
                    addd      #$FFFF
                    std       [<$0C,s]
                    ldd       10,s
                    cmpd      #$0001
                    beq       g18@
                    ldd       ,s
                    cmpd      #$0001
                    bne       f18@
                    ldd       #$0001
                    bra       h18@
f18@                ldd       ,s
                    cmpd      10,s
                    bne       g18@
                    ldd       #$0002
                    bra       h18@
g18@                clra
                    clrb
h18@                ldx       12,s
                    std       2,x
                    ldd       ,s
                    addd      #$0001
                    std       ,s
                    subd      #$0001
                    ldd       12,s
                    addd      #$0004
                    std       12,s
                    subd      #$0004
i18@                ldd       ,s
                    cmpd      10,s
                    ble      d18@
                    ldd       <nstaves
                    addd      #$0001
                    std       <nstaves
                    subd      #$0001
                    tfr       u,d
                    leau      10,u
j18@                ldd       <nstaves
                    cmpd      #$0007
                    lble      b18@
k18@                ldd       <nstaves
                    cmpd      #$0007
                    ble       l18@
                    ldd       #$0007
                    pshs      a,b
                    leax      >fmtAllStavesUsed,pcr
                    pshs      x
                    lbsr      Printf
                    leas      4,s
l18@                ldd       <nstaves
                    addd      #$FFFF
                    std       <nstaves
                    bra       n18@
m18@                leas      <-$5F,x
n18@                ldd       <nparts
                    cmpd      #$0010
                    ble       o18@
                    ldd       #$0010
                    pshs      a,b
                    leax      >fmtOverPartLimit,pcr
                    pshs      x
                    lbsr      Printf
                    leas      4,s
                    ldd       <nparts
                    addd      #$FFFF
                    std       <nparts
o18@                lbsr      styinit
                    lbsr      showlay
                    leax      >msgSetupOK,pcr
                    pshs      x
                    lbsr      yesno
                    std       ,s++
                    lbeq      a18@
                    lbsr      wkill
                    leas      <$5F,s
                    puls      u,pc
* askclef (was L2990): lists clef names '%3d - %s' and asks 'Clef for Staff #%d: ' (onehex), '  Off list, try again;'
askclef          pshs      u
                    leas      -5,s
                    ldx       #$01BE
                    pshs      x
                    ldd       #$000C
                    pshs      a,b
                    lbsr      FPutc
                    leas      4,s
                    clra
                    clrb
                    std       3,s
a19@                ldd       3,s
                    addd      #$0001
                    std       3,s
                    subd      #$0001
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #clefs
                    leax      d,x
                    ldu       ,x
                    ldb       ,u
                    beq       b19@
                    pshs      u
                    ldd       5,s
                    pshs      a,b
                    leax      >fmtClefListItem,pcr
                    pshs      x
                    lbsr      Printf
                    leas      6,s
                    bra       a19@
b19@                bra       c19@
c19@                ldd       9,s
                    pshs      a,b
                    leax      >fmtClefForStaff,pcr
                    pshs      x
                    lbsr      Printf
                    leas      4,s
                    lbsr      onehex
                    std       1,s
                    ldx       #$01BE
                    pshs      x
                    ldd       #$000D
                    pshs      a,b
                    lbsr      FPutc
                    leas      4,s
                    ldd       1,s
                    cmpd      3,s
                    bgt       d19@
                    ldd       1,s
                    addd      #$FFFF
                    bra       e19@
d19@                leax      >msgOffList,pcr
                    pshs      x
                    lbsr      Printf
                    leas      2,s
                    bra       c19@
e19@                leas      5,s
                    puls      u,pc
* styinit (was L2A17): computes the vertical height of each staff entry from the staff count ((176-x)/n via DivInt)
styinit         pshs      a,b,x,u
                    ldd       <nstaves
                    cmpd      #$0004
                    bge       a20@
                    ldd       #$0014
                    bra       b20@
a20@                clra
                    clrb
b20@                pshs      a,b
                    ldd       #$00B0
                    subd      ,s++
                    pshs      a,b
                    ldd       <nstaves
                    addd      #$0001
                    lbsr      DivInt
                    std       ,s
                    clra
                    clrb
                    std       2,s
                    ldu       #staves
                    bra       d20@
c20@                ldd       2,s
                    addd      #$0001
                    pshs      a,b
                    ldd       2,s
                    lbsr      MulInt
                    pshs      a,b
                    ldd       #$00B0
                    subd      ,s++
                    leau      10,u
                    std       -10,u
                    ldd       2,s
                    addd      #$0001
                    std       2,s
d20@                ldd       2,s
                    cmpd      <nstaves
                    blt       c20@
                    leas      4,s
                    puls      u,pc
* showlay (was L2A6D): prints 'S Hgt  Clef    Parts up mid' table, one '%d %3d %-8s' row per staff with part letters
showlay     pshs      u
                    leas      -11,s
                    leax      >strStaffTableHdr,pcr
                    pshs      x
                    lbsr      Printf
                    leas      2,s
                    leax      >strStaffTableRule,pcr
                    pshs      x
                    lbsr      Printf
                    leas      2,s
                    clra
                    clrb
                    lbra      i21@
a21@                ldd       7,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      MulInt
                    ldx       #staves
                    leax      d,x
                    ldd       2,x
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #clefs
                    leax      d,x
                    ldd       ,x
                    pshs      a,b
                    ldd       9,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      MulInt
                    ldx       #staves
                    leax      d,x
                    ldd       ,x
                    pshs      a,b
                    ldd       11,s
                    addd      #$0001
                    pshs      a,b
                    leax      >fmtStaffTableRow,pcr
                    pshs      x
                    lbsr      Printf
                    leas      8,s
                    ldd       #$0001
                    bra      h21@
b21@                leax      5,s
                    pshs      x
                    leax      5,s
                    pshs      x
                    leax      5,s
                    pshs      x
                    ldd       15,s
                    pshs      a,b
                    lbsr      partstaff
                    leas      8,s
                    cmpd      7,s
                    bne       g21@
                    ldd       5,s
                    clra
                    andb      #$02
                    beq       c21@
                    ldd       #$004C
                    bra       e21@
c21@                ldd       5,s
                    clra
                    andb      #$01
                    beq       d21@
                    ldd       #$0055
                    bra       e21@
d21@                ldd       #$004D
e21@                stb       ,s
                    ldd       5,s
                    clra
                    andb      #$04
                    beq       f21@
                    ldb       ,s
                    sex
                    addd      #$0020
                    stb       ,s
f21@                ldb       ,s
                    sex
                    pshs      a,b
                    ldd       11,s
                    pshs      a,b
                    lbsr      i2hexc
                    std       ,s
                    leax      >fmtTwoChars,pcr
                    pshs      x
                    lbsr      Printf
                    leas      6,s
g21@                ldd       9,s
                    addd      #$0001
h21@                std       9,s
                    ldd       9,s
                    cmpd      <nparts
                    ble      b21@
                    ldx       #$01BE
                    pshs      x
                    ldd       #$000D
                    pshs      a,b
                    lbsr      FPutc
                    leas      4,s
                    ldd       7,s
                    addd      #$0001
i21@                std       7,s
                    ldd       7,s
                    cmpd      <nstaves
                    lblt      a21@
                    leas      11,s
                    puls      u,pc
* pathTerm: '/term', the console OpenConsole falls back to when path 2 has no terminal
pathTerm            fcb       $2F
                    fcc       /term/
                    fcb       $00
* pathPipe (was L2BA7): '/pipe', opened for s9gui's stdin and stdout
pathPipe            fcb       $2F
                    fcc       /pipe/
                    fcb       $00
* strFran (was L2BAD): 's9gui', the renderer forked by sysup
strFran             fcc       /s9gui/
                    fcb       $00
* strCRParam (was L2BB2): CR parameter string (unreferenced)
strCRParam          fcb       $0D,$00
* msgCantForkFran (was L2BB4): 'Can't fork Fran!'
msgCantForkFran     fcc       /Can't fork Fran!/
                    fcb       $00
* msgNoNewBars (was L2BC5): ' No new bars!'
msgNoNewBars        fcc       / No new bars!/
                    fcb       $0D,$00
* msgNoSynthNamed (was L2BD4): 'no synth named.' default synth description at $0CB4
msgNoSynthNamed     fcc       /no synth named./
                    fcb       $00
* msgLayoutPrompts (was L2BE4): 'Prompts to begin the' CR ' score layout?'
msgLayoutPrompts    fcc       /Prompts to begin the/
                    fcb       $0D
                    fcc       / score layout?/
                    fcb       $00
L2C19               equ       *
                    fcb       $54,$79,$70,$65,$20,$6E,$75,$6D,$62,$65,$72,$20,$6F,$66,$20,$53,$68,$61,$72,$70,$73,$20,$28,$31,$20,$74,$6F,$20,$37,$29
                    fcb       $0D,$00
L2C39               equ       *
                    fcb       $20,$20,$6F,$72,$20,$6E,$65,$67,$61,$74,$69,$76,$65,$20,$20,$46,$6C,$61,$74,$73,$20,$28,$2D,$31,$20,$74,$6F,$20,$2D,$37,$29
                    fcb       $0D,$00
L2C5A               equ       *
                    fcb       $20,$20,$6F,$72,$20,$45,$4E,$54,$45,$52,$20,$66,$6F,$72,$20,$6E,$65,$69,$74,$68,$65,$72,$3A,$20
                    fcb       $00
L2C73               equ       *
                    fcb       $54,$69,$6D,$65,$20,$53,$69,$67,$73,$20,$61,$72,$65,$20,$77,$72,$69,$74,$74,$65,$6E,$20,$4E
                    fcb       $2F,$53,$0D,$00
L2C8E               equ       *
                    fcb       $20,$20,$4E,$20,$69,$73,$20,$4E,$75,$6D,$62,$65,$72,$20,$6F,$66,$20,$62,$65,$61,$74,$73,$20,$70,$65,$72,$20,$62,$61,$72
                    fcb       $0D,$00
L2CAE               equ       *
                    fcb       $20,$20,$53,$20,$69,$73,$20,$6E,$6F,$74,$65,$5F,$53,$69,$7A,$65,$20,$6F,$66,$20,$61,$20,$62,$65,$61,$74,$2E
                    fcb       $0D,$00
L2CCB               equ       *
                    fcb       $0D
                    fcc       /Your Time Sig N/
                    fcb       $2F
                    fcc       /S: /
                    fcb       $00
L2CE0               equ       *
                    fcb       $53,$20,$6D,$75,$73,$74,$20,$62,$65,$20,$32,$2C,$20,$34,$2C,$20,$38,$20,$6F,$72,$20,$31,$36,$2E
                    fcb       $0D,$0D,$00
* fmtPartsOnStaff (was L2CFB): 'Parts on Staff #%d (1-3)? '
fmtPartsOnStaff     fcc       /Parts on Staff #%d (1-3)? /
                    fcb       $00
* fmtAllStavesUsed (was L2D1B): '(All %d Staves used.)'
fmtAllStavesUsed    fcb       $0D
                    fcc       /(All %d Staves used.)/
                    fcb       $0D,$00
* fmtOverPartLimit (was L2D33): '**Over the %d-Part Limit.'
fmtOverPartLimit    fcb       $0D
                    fcc       /**Over the %d-Part Limit./
                    fcb       $0D,$00
* msgSetupOK (was L2D4F): 'Is this setup OK? '
msgSetupOK          fcc       /Is this setup OK? /
                    fcb       $00
* fmtClefListItem (was L2D62): '%3d - %s'
fmtClefListItem     fcc       /%3d - %s/
                    fcb       $0D,$00
* fmtClefForStaff (was L2D6C): 'Clef for Staff #%d: '
fmtClefForStaff     fcb       $0D
                    fcc       /Clef for Staff #%d: /
                    fcb       $00
* msgOffList (was L2D82): '  Off list, try again;'
msgOffList          fcc       /  Off list, try again;/
                    fcb       $0D,$00
* strStaffTableHdr (was L2D9A): FF 'S Hgt  Clef    Parts up/mid/dn' CR
strStaffTableHdr    fcb       $0C
                    fcc       /S Hgt  Clef    Parts up/
                    fcb       $2F
                    fcc       /mid/
                    fcb       $2F,$64,$6E,$0D,$00
* strStaffTableRule (was L2DBB): '- --- ------   ---------------'
strStaffTableRule   fcc       /- --- ------   ---------------/
                    fcb       $0D,$00
* fmtStaffTableRow (was L2DDB): '%d %3d %-8s'
fmtStaffTableRow    fcc       /%d %3d %-8s/
                    fcb       $00
* fmtTwoChars (was L2DE7): ' %c%c'
fmtTwoChars         fcc       / %c%c/
                    fcb       $00
* reinit (was L2DED): stores EventEndTime of the last event into $0091, RenumberBars, resends parts/staves to s9gui
reinit      pshs      u
                    ldx       #$0091
                    pshs      x
                    ldd       <nevents
                    addd      #$FFFF
                    pshs      a,b
                    lbsr      EventEndTime
                    leas      2,s
                    lbsr      LongStore
                    clra
                    clrb
                    pshs      a,b
                    lbsr      RenumberBars
                    leas      2,s
                    ldd       <UmeData_reserved_0003
                    beq       a22@
                    ldd       <UmeData_reserved_0005
                    bne       b22@
a22@                ldd       #$0004
                    std       <UmeData_reserved_0005
                    std       <UmeData_reserved_0003
b22@                lbsr      timesig
                    ldd       <nparts
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    lbsr      dfalprts
                    leas      4,s
                    ldd       <nstaves
                    addd      #$FFFF
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    lbsr      dfalstvs
                    leas      4,s
* Parts and channels are not set here: MidiDefaults set them before the file was read, and what the
* file or importer set since stands.
* Score metadata scans leave the event mapper at the end; return it to zero.
ResetScoreCursor    clra
                    clrb
                    pshs      d
                    lbsr      i2p
                    leas      2,s
                    puls      u,pc
* trim (was L2E7B): scans a string and terminates it at the first space (file-name cleanup after gets)
trim        pshs      u
                    leas      -1,s
                    ldu       5,s
a23@                ldb       ,u+
                    stb       ,s
                    cmpb      #$20
                    beq       b23@
                    ldb       ,s
                    ldx       5,s
                    leax      1,x
                    stx       5,s
                    stb       -1,x
b23@                ldb       ,s
                    bne       a23@
                    leas      1,s
                    puls      u,pc
* fsubmen (was L2E9B): the file sub-menu (s9c menu 2; radio item 1-4 = i/p/m/l); 'r', 'w' and 'd' run soowee('D','d') on the chosen kind
fsubmen            pshs      a,b,x,y,u
                    ldd       #$0001
                    std       2,s
                    ldd       #$0069
                    stb       1,s
                    bra       c23@
c23@                ldd       <curcurse
                    std       4,s
                    ldd       #$0002
                    pshs      a,b
                    lbsr      curset
                    leas      2,s
                    ldd       2,s                 the radio digit 1-4, put in MenuStates for menu3
                    pshs      a,b
                    leax      >fmtInt1,pcr
                    pshs      x
                    ldx       #MenuStates
                    pshs      x
                    lbsr      SPrintf
                    leas      6,s
                    ldd       #$0002              s9c menu 2 = the file sub-menu
                    pshs      d
                    ldd       #'M
                    pshs      d
                    ldd       #'C
                    pshs      d
                    lbsr      soowee
                    leas      6,s
                    stb       ,s
                    lbsr      wkill
                    ldd       4,s
                    pshs      a,b
                    lbsr      curset
                    leas      2,s
                    clra
                    clrb
                    stb       [<$0A,s]
                    ldb       ,s
                    sex
                    tfr       d,x
                    bra      q23@
d23@                ldd       #$0001
                    std       2,s
                    ldd       #$0069
                    bra       h23@
e23@                ldd       #$0002
                    std       2,s
                    ldd       #$0070
                    bra       h23@
f23@                ldd       #$0003
                    std       2,s
                    ldd       #$006D
                    bra       h23@
g23@                ldd       #$0004
                    std       2,s
                    ldd       #$006C
h23@                stb       1,s
                    lbra      c23@
i23@                clra
                    clrb
                    pshs      a,b
                    clra
                    clrb
                    bra       l23@
j23@                clra
                    clrb
                    bra       n23@
k23@                clra
                    clrb
                    pshs      a,b
                    ldd       #$0001
l23@                pshs      a,b
                    ldb       5,s
                    sex
                    pshs      a,b
                    clra
                    clrb
                    bra       o23@
m23@                ldd       #$0001
n23@                pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldb       5,s
                    sex
                    pshs      a,b
                    ldd       #$0001
o23@                pshs      a,b
                    ldd       <$12,s
                    pshs      a,b
                    ldd       #$0064
                    pshs      a,b
                    ldd       #$0044
                    pshs      a,b
                    lbsr      soowee
                    leas      14,s
                    bra       s23@
p23@                lbsr      bell
                    lbra      c23@
q23@                cmpx      #$000D
                    beq       r23@
                    cmpx      #$0069
                    lbeq      d23@
                    cmpx      #$0070
                    beq      e23@
                    cmpx      #$006D
                    beq      f23@
                    cmpx      #$006C
                    beq      g23@
                    cmpx      #$0076
                    beq      g23@
                    cmpx      #$0072
                    beq      i23@
                    cmpx      #$0077
                    beq      j23@
                    cmpx      #$0064
                    beq      k23@
                    cmpx      #$006B
                    beq      m23@
                    bra       p23@
r23@                clra
                    clrb
s23@                leas      6,s
                    puls      u,pc
* iomen (was L2FCE): file menu 'nraswfoidphtkq': new, rename ('Old: %s'/'New: '), write ('Read_Only Mode...'), chd ('Now: ',' To: '), pwd, audit, etc.
iomen            pshs      u
                    leas      <-$2C,s
                    lbra      ac24@
* The bar is put back each time the File menu comes up (a dialog it ran may have covered it), with
* File highlighted.
a24@                lbsr      SendCmd97
                    clra
                    clrb
                    std       >MenuBarHover       File, the first title
                    lbsr      InvertMenuBarHover
                    ldd       #-1
                    std       >MenuBarHover
                    ldd       <curcurse
                    std       1,s
                    ldd       #$0002
                    pshs      a,b
                    lbsr      curset
                    leas      2,s
                    ldd       <nevents
                    cmpd      #$0001
                    ble       b24@
* FILES is a condensed text menu streamed from s9c's descFiles (menu3), with or without a score; the
* read-only state goes to MenuStates as text.
                    ldb       <readonly
                    clra
                    andb      #$01
                    pshs      a,b
                    leax      >fmtInt2,pcr
                    pshs      x
                    ldx       #MenuStates
                    pshs      x
                    lbsr      SPrintf
                    leas      6,s
                    ldd       #$0000              s9c menu 0 = FILES
                    bra       c24@
b24@                ldb       <readonly
                    clra
                    andb      #$01
                    pshs      a,b
                    leax      >fmtInt3,pcr
                    pshs      x
                    ldx       #MenuStates
                    pshs      x
                    lbsr      SPrintf
                    leas      6,s
                    ldd       #$0000              s9c menu 0 = FILES too (no score loaded)
c24@                pshs      d
                    ldd       #'M
                    pshs      d
                    ldd       #'C
                    pshs      d
                    lbsr      soowee              s9c streams the menu, s9gui draws it and answers: B = the key
                    leas      6,s
                    stb       ,s
* Quit ('q') and Instrs ('i') keep the File menu up under their own box: the key becomes upper case
* ('Q', 'I') and the File menu is closed after the answer.
                    cmpb      #'q
                    beq       fmq0@
                    cmpb      #'i                 Instrs, etc...: its sub-menu over the File menu
                    bne       fmq1@
fmq0@               subb      #'a-'A              upper case marks the File menu still up: 'Q', 'I'
                    stb       ,s
                    bra       fmq2@
fmq1@               lbsr      wkill
fmq2@               ldd       1,s
                    pshs      a,b
                    lbsr      curset
                    leas      2,s
                    clra
                    clrb
                    stb       3,s
                    ldb       ,s
                    sex
                    tfr       d,x
                    lbra      ab24@
d24@                ldd       #$0002
                    pshs      a,b
                    lbsr      breaker
                    leas      2,s
                    lbra      ac24@
fmqq@               ldd       #$0002              Quit! picked in the File menu: the Exit box over it
                    pshs      a,b
                    lbsr      breaker
                    leas      2,s
                    lbsr      wkill               NO: then the File menu closes
                    lbra      ac24@
e24@                ldb       <readonly
                    bne       f24@
                    ldd       #$0001
                    bra       g24@
f24@                clra
                    clrb
g24@                stb       <readonly
                    lbra      ac24@
h24@                lbsr      titlemen
                    lbra      z24@
i24@                ldd       <nevents
                    cmpd      #$0002
                    blt       j24@
                    leax      >msgWillClearScore,pcr
                    pshs      x
                    lbsr      yesno
                    std       ,s++
                    beq       k24@
j24@                ldd       #$0001
                    pshs      a,b
                    lbsr      newscore
                    leas      2,s
                    ldd       #$0001
                    stb       <rfr_scr
                    clra
                    clrb
                    std       <xgoal
                    std       <gind
                    lbra      ad24@
k24@                lbra      ac24@
l24@                clra
                    clrb
                    pshs      a,b
                    lbsr      dialogue
                    leas      2,s
                    ldx       #$0BEB
                    pshs      x
                    leax      >fmtOldName,pcr
                    pshs      x
                    lbsr      Printf
                    leas      4,s
                    leax      >strNewPrompt,pcr
                    pshs      x
                    lbsr      Printf
                    leas      2,s
                    leax      3,s
                    pshs      x
                    lbsr      gets
                    leas      2,s
                    lbsr      wkill
                    leax      3,s
                    pshs      x
                    lbsr      trim
                    leas      2,s
                    ldb       3,s
                    lbeq      ac24@
                    leax      3,s
                    pshs      x
                    ldx       #$0BEB
                    pshs      x
                    lbsr      StrCopy
                    leas      4,s
                    lbra      ac24@
m24@                ldb       >UmeData_reserved_0BEB
                    beq       o24@
                    ldb       <readonly
                    beq       n24@
                    leax      >msgReadOnlyWrite,pcr
                    pshs      x
                    lbsr      yesno
                    std       ,s++
                    lbeq      ad24@
n24@                lbsr      monologue
                    ldx       #$0BEB
                    pshs      x
                    leax      >fmtOkWriting,pcr
                    pshs      x
                    lbsr      Printf
                    leas      4,s
o24@                lbsr      flush
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0075
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldx       #$0BEB
                    pshs      x
                    ldd       #$0064
                    pshs      a,b
                    ldd       #$0044
                    pshs      a,b
                    lbsr      soowee
                    leas      14,s
                    std       -2,s
                    lbne      ad24@
                    lbra      z24@
p24@                ldd       #$0001
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0075
                    pshs      a,b
                    clra
                    clrb
                    lbra      u24@
q24@                equ       *                   (s9d sets the defaults once the file has opened)
                    clra
                    clrb
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0075
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    leax      11,s
                    pshs      x
                    ldd       #$0064
                    pshs      a,b
                    ldd       #$0044
                    pshs      a,b
                    lbsr      soowee
                    leas      14,s
                    std       -2,s
                    lbeq      ac24@
                    ldd       #$0001
                    stb       <rfr_scr
                    leax      3,s
                    pshs      x
                    ldx       #$0BEB
                    pshs      x
                    lbsr      StrCopy
                    leas      4,s
                    lbsr      reinit
                    bra       s24@
r24@                clra
                    clrb
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0061
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    leax      11,s
                    pshs      x
                    ldd       #$0064
                    pshs      a,b
                    ldd       #$0044
                    pshs      a,b
                    lbsr      soowee
                    leas      14,s
                    std       -2,s
                    lbeq      ac24@
                    ldd       #$0001
                    stb       <rfr_scr
                    ldx       #$0091
                    pshs      x
                    ldd       <nevents
                    addd      #$FFFF
                    pshs      a,b
                    lbsr      EventEndTime
                    leas      2,s
                    lbsr      LongStore
                    ldd       #$0001
                    pshs      a,b
                    lbsr      RenumberBars
                    leas      2,s
s24@                lbsr      AuditIndex
                    lbra      ad24@
t24@                ldd       #$0001
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0075
                    pshs      a,b
                    ldd       #$0001
u24@                pshs      a,b
                    leax      11,s
                    pshs      x
                    ldd       #$0064
                    pshs      a,b
                    ldd       #$0044
                    pshs      a,b
                    lbsr      soowee
                    leas      14,s
                    lbra      ac24@
v24@                clra
                    clrb
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0075
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    leax      11,s
                    pshs      x
                    ldd       #$0064
                    pshs      a,b
                    ldd       #$0044
                    pshs      a,b
                    lbsr      soowee
                    leas      14,s
                    std       -2,s
                    lbeq      ac24@
                    leax      >msgKeepNewName,pcr
                    pshs      x
                    lbsr      yesno
                    std       ,s++
                    lbeq      ac24@
                    leax      3,s
                    pshs      x
                    ldx       #$0BEB
                    pshs      x
                    lbsr      StrCopy
                    leas      4,s
                    lbra      ad24@
w24@                leax      3,s                 (the File menu is still up under the sub-menu)
                    pshs      x
                    lbsr      fsubmen
                    std       ,s                  the answer, kept over the close
                    lbsr      wkill               the File menu
                    ldd       ,s++
                    lbeq      ac24@
                    lbra      ad24@
x24@                ldd       #$0001
                    pshs      a,b
                    lbsr      dialogue
                    leas      2,s
                    ldb       ,s
                    cmpb      #$70
                    bne       y24@
                    leax      >strNowPrompt,pcr
                    pshs      x
                    lbsr      Printf
                    leas      2,s
                    ldx       #$01BE
                    pshs      x
                    lbsr      FFlush
                    leas      2,s
                    lbsr      PrintCurDir
y24@                leax      >strToPrompt,pcr
                    pshs      x
                    lbsr      Printf
                    leas      2,s
                    leax      3,s
                    pshs      x
                    lbsr      gets
                    leas      2,s
                    leax      3,s
                    pshs      x
                    lbsr      trim
                    leas      2,s
                    ldb       3,s
                    beq       z24@
                    leax      3,s
                    pshs      x
                    lbsr      ChangeDir
                    std       ,s++
                    beq       z24@
                    lbsr      bell
                    leax      >msgCantChd,pcr
                    pshs      x
                    lbsr      Printf
                    leas      2,s
                    bra       y24@
z24@                lbsr      wkill
                    lbra      ac24@
aa24@               lbsr      bell
                    bra       ac24@
ab24@               cmpx      #$000D
                    beq       ad24@
                    cmpx      #$0071
                    lbeq      d24@
                    cmpx      #'Q                 Quit! from the File menu, still up
                    lbeq      fmqq@
                    cmpx      #$006F
                    lbeq      e24@
                    cmpx      #$0074
                    lbeq      h24@
                    cmpx      #$006E
                    lbeq      i24@
                    cmpx      #$0066
                    lbeq      l24@
                    cmpx      #$0073
                    lbeq      m24@
                    cmpx      #$0064
                    lbeq      p24@
                    cmpx      #$0072
                    lbeq      q24@
                    cmpx      #$0061
                    lbeq      r24@
                    cmpx      #$006B
                    lbeq      t24@
                    cmpx      #$0077
                    lbeq      v24@
                    cmpx      #'I                 Instrs, etc...: the File menu still up under it
                    lbeq      w24@
                    cmpx      #$0063
                    lbeq      x24@
                    cmpx      #$0068
                    lbeq      x24@
                    cmpx      #$0070
                    lbeq      x24@
                    lbra      aa24@
ac24@               lbra      a24@
ad24@               leas      <$2C,s
                    puls      u,pc
* fmtInt1 (was L3394): '%d'
fmtInt1             fcb       $25,$64,$00
* strIpmlMenuKeys (was L3397): 'ipml rwdk' key letters of fsubmen
strIpmlMenuKeys     fcc       /ipml rwdk/
                    fcb       $0D,$00
* fmtInt2 (was L33A2): '%d'
fmtInt2             fcb       $25,$64,$00
* strFileMenuKeys (was L33A5): 'nraswfoidphtkq' file-menu key letters (score loaded)
strFileMenuKeys     fcc       /nraswfoidphtkq/
                    fcb       $0D,$00
* fmtInt3 (was L33B5): '%d'
fmtInt3             fcb       $25,$64,$00
* strFileMenuKeys2 (was L33B8): ' nroidph' CR 'q' CR, reduced file-menu keys when no score is loaded
strFileMenuKeys2    fcc       / nroidph/
                    fcb       $0D,$71,$0D,$00
* msgWillClearScore (was L33C4): ' Clears the score. Sure? '
msgWillClearScore   fcc       / Clears the score. Sure? /
                    fcb       $00
* fmtOldName (was L33E7): 'Old: %s'
fmtOldName          fcb       $0D
                    fcc       /Old: %s/
                    fcb       $0D,$00
* strNewPrompt (was L33F1): 'New: '
strNewPrompt        fcc       /New: /
                    fcb       $00
* msgReadOnlyWrite (was L33F7): 'Read_Only Mode is on.' CR '  Write anyway?'
msgReadOnlyWrite    fcc       /Read_Only Mode is on./
                    fcb       $0D
                    fcc       /  Write anyway?/
                    fcb       $00
* fmtOkWriting (was L341D): CR 'OK, Writing:' CR '  %s'
fmtOkWriting        fcb       $0D
                    fcc       /OK, Writing:/
                    fcb       $0D
                    fcc       /  %s/
                    fcb       $00
* msgKeepNewName (was L3430): 'Keep new file name? '
msgKeepNewName      fcc       /Keep new file name? /
                    fcb       $00
* strNowPrompt (was L3445): 'Now: ' (current directory shown by PrintCurDir)
strNowPrompt        fcb       $0D
                    fcc       /Now: /
                    fcb       $00
* strToPrompt (was L344C): ' To: ' (chd target prompt)
strToPrompt         fcb       $0D
                    fcc       / To: /
                    fcb       $00
* msgCantChd (was L3453): '***Can't CHD to that dir.'
msgCantChd          fcc       /***Can't CHD to that dir./
                    fcb       $0D,$00
* chip (was L346E): places the template note ($010B) at a clicked time: fulltime + offset vs score end $0091, then SetNoteAttrs/ghola and fixup; vector $03B1
chip       pshs      u
                    leas      -11,s
                    clra
                    clrb
                    pshs      a,b
                    lbsr      automouse
                    leas      2,s
                    leax      ,s
                    pshs      x
                    ldd       <$11,s
                    pshs      a,b
                    lbsr      fulltime
                    leas      2,s
                    lbsr      LongStore
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldd       <$17,s
                    lbsr      IntToLong
                    lbsr      LongAdd
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldx       #$0091
                    lbsr      LongCmp
                    bgt       a25@
                    ldd       <$15,s
                    pshs      a,b
                    ldd       <$15,s
                    pshs      a,b
                    ldd       <$15,s
                    pshs      a,b
                    ldd       <$15,s
                    pshs      a,b
                    lbsr      qchip
                    leas      8,s
                    bra      b25@
a25@                ldx       #$0091
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    leax      4,s
                    lbsr      LongSub
                    ldd       >UmeData_reserved_0345
                    std       <$13,s
                    lbsr      IntToLong
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    leax      10,s
                    pshs      x
                    clra
                    clrb
                    pshs      a,b
                    ldd       <$17,s
                    pshs      a,b
                    lbsr      bomb
                    leas      10,s
                    clra
                    clrb
                    pshs      a,b
                    leax      2,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldd       <$19,s
                    pshs      a,b
                    ldx       <$19,s
                    ldb       1,x
                    sex
                    pshs      a,b
                    ldd       <$1B,s
                    pshs      a,b
                    ldd       <$21,s
                    pshs      a,b
                    lbsr      ghola
                    leas      14,s
b25@                std       4,s
                    ldd       4,s
                    blt       c25@
                    clra
                    clrb
                    pshs      a,b
                    ldd       <$17,s
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    ldd       <$15,s
                    pshs      a,b
                    bsr       fixup
                    leas      8,s
c25@                ldd       4,s
                    leas      11,s
                    puls      u,pc
* nextbar (was L3548): returns the index of the next bar event (anybar) after idx, or count-1
nextbar         pshs      u
                    ldd       4,s
                    cmpd      <nevents
                    bge       d26@
                    ldd       4,s
                    addd      #$0001
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    bra       c26@
a26@                pshs      u
                    lbsr      anybar
                    std       ,s++
                    beq       b26@
                    ldd       <curind
                    puls      u,pc
b26@                lbsr      plusplus
c26@                tfr       d,u
                    ldd       <curind
                    cmpd      <nevents
                    blt       a26@
d26@                ldd       <nevents
                    addd      #$FFFF
                    puls      u,pc
* fixup (was L357F): vector $0387: re-times and redraws the bar around an event (attrs at $0115, prev/next bar scan)
fixup          pshs      u
                    leas      <-$1D,s
                    clra
                    clrb
                    pshs      a,b
                    lbsr      automouse
                    leas      2,s
                    ldb       <$28,s
                    bne       g26@
                    ldd       <$25,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #parts
                    leax      d,x
                    ldd       2,x
                    clra
                    andb      #$04
                    bne       e26@
                    ldd       #$0001
                    bra       f26@
e26@                clra
                    clrb
f26@                stb       <$28,s
g26@                ldx       #$0115
                    pshs      x
                    leax      <$1A,s
                    pshs      x
                    lbsr      CopyNoteAttrs
                    leas      4,s
                    ldd       <$23,s
                    cmpd      <$21,s
                    bge       h26@
                    ldd       <$21,s
                    std       <$23,s
h26@                ldd       <$21,s
                    ble       l26@
                    ldd       <$21,s
                    addd      #$FFFF
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    bra       j26@
i26@                pshs      u
                    lbsr      anybar
                    std       ,s++
                    bne       k26@
                    lbsr      decdec
j26@                tfr       d,u
                    ldd       <curind
                    bgt       i26@
k26@                ldd       <curind
                    std       <$21,s
l26@                ldd       <$23,s
                    pshs      a,b
                    lbsr      nextbar
                    leas      2,s
                    std       <$23,s
                    clra
                    clrb
                    std       6,s
                    ldd       #$FFFF
                    std       2,s
                    std       4,s
                    ldd       <nevents
                    subd      <$23,s
                    std       <$23,s
                    ldd       <$21,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    lbra      u26@
m26@                ldd       <nevents
                    subd      <curind
                    std       ,s
                    ldb       ,u
                    sex
                    cmpd      <$25,s
                    lbne      q26@
                    ldd       1,u
                    std       <$12,s
                    ldb       <$28,s
                    beq      p26@
                    ldd       2,s
                    blt       n26@
                    ldd       <$12,s
                    subd      <$10,s
                    subd      12,s
                    std       10,s
                    ble      p26@
                    clra
                    clrb
                    pshs      a,b
                    ldd       4,s
                    pshs      a,b
                    lbsr      fulltime
                    leas      2,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldd       <$12,s
                    lbsr      IntToLong
                    lbsr      LongAdd
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldd       <$10,s
                    pshs      a,b
                    ldd       <$10,s
                    bra       o26@
n26@                ldd       4,s
                    blt       p26@
                    ldd       <$12,s
                    subd      14,s
                    std       10,s
                    ble       p26@
                    clra
                    clrb
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    lbsr      fulltime
                    leas      2,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldd       <$10,s
                    pshs      a,b
                    clra
                    clrb
o26@                pshs      a,b
                    leax      <$22,s
                    pshs      x
                    ldd       <$31,s
                    pshs      a,b
                    lbsr      ghola
                    leas      14,s
p26@                ldd       <nevents
                    subd      ,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    tfr       d,u
                    ldd       #$FFFF
                    std       4,s
                    ldd       <curind
                    std       2,s
                    ldd       <$12,s
                    std       <$10,s
                    ldb       4,u
                    sex
                    std       8,s
                    pshs      a,b
                    ldb       3,u
                    sex
                    pshs      a,b
                    lbsr      cod2raw
                    leas      4,s
                    std       12,s
                    lbra      t26@
q26@                pshs      u
                    lbsr      anybar
                    std       ,s++
                    lbeq      t26@
                    ldd       1,u
                    std       14,s
                    ldd       4,s
                    lbge      s26@
                    ldd       2,s
                    lblt      s26@
                    ldd       14,s
                    subd      <$10,s
                    subd      12,s
                    std       10,s
                    ldb       <$28,s
                    beq      r26@
                    ldd       10,s
                    ble       r26@
                    clra
                    clrb
                    pshs      a,b
                    ldd       4,s
                    pshs      a,b
                    lbsr      fulltime
                    leas      2,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldd       <$12,s
                    lbsr      IntToLong
                    lbsr      LongAdd
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldd       <$10,s
                    pshs      a,b
                    ldd       <$10,s
                    pshs      a,b
                    leax      <$22,s
                    pshs      x
                    ldd       <$31,s
                    pshs      a,b
                    lbsr      ghola
                    leas      14,s
                    std       6,s
                    ldd       <nevents
                    subd      ,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    lbra      s26@
r26@                ldd       10,s
                    lbge      s26@
                    leax      <$14,s
                    pshs      x
                    ldd       <curind
                    pshs      a,b
                    lbsr      fulltime
                    leas      2,s
                    lbsr      LongStore
                    ldd       12,s
                    lbsr      IntToLong
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    leax      <$1C,s
                    pshs      x
                    clra
                    clrb
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    lbsr      bomb
                    leas      10,s
                    clra
                    clrb
                    stb       <$19,s
                    ldd       14,s
                    subd      <$10,s
                    std       12,s
                    clra
                    clrb
                    pshs      a,b
                    leax      <$16,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldd       <$12,s
                    lbsr      IntToLong
                    lbsr      LongSub
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldd       <$12,s
                    pshs      a,b
                    ldd       <$10,s
                    pshs      a,b
                    leax      <$22,s
                    pshs      x
                    ldd       <$31,s
                    pshs      a,b
                    lbsr      ghola
                    leas      14,s
                    std       2,s
                    lblt      v26@
                    ldd       2,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    tfr       d,x
                    clra
                    clrb
                    stb       7,x
                    ldd       <nevents
                    subd      ,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    ldd       <curind
                    std       4,s
                    ldd       8,s
                    stb       <$19,s
                    clra
                    clrb
                    pshs      a,b
                    leax      <$16,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldd       <$10,s
                    nega
                    negb
                    sbca      #$00
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    leax      <$22,s
                    pshs      x
                    ldd       <$31,s
                    pshs      a,b
                    lbsr      ghola
                    leas      14,s
                    std       6,s
                    ldd       4,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    ldx       #$0115
                    pshs      x
                    leax      <$1A,s
                    pshs      x
                    lbsr      CopyNoteAttrs
                    leas      4,s
s26@                ldd       <curind
                    std       4,s
                    ldd       #$FFFF
                    std       2,s
                    ldd       <nevents
                    subd      <$23,s
                    cmpd      6,s
                    bgt       t26@
                    ldd       6,s
                    pshs      a,b
                    lbsr      nextbar
                    std       ,s
                    ldd       <nevents
                    subd      ,s++
                    std       <$23,s
                    ldd       4,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
t26@                lbsr      plusplus
u26@                tfr       d,u
                    ldd       <nevents
                    subd      <$23,s
                    cmpd      <curind
                    lbge      m26@
v26@                leas      <$1D,s
                    puls      u,pc
* bomb (was L3899): clears a time span for a new note: deletes/retimes same-part events, returns the leftover ticks
bomb     pshs      u
                    leas      -14,s
                    leax      10,s
                    pshs      x
                    leax      4,s
                    pshs      x
                    ldd       <$16,s
                    pshs      a,b
                    lbsr      fulltime
                    leas      2,s
                    lbsr      LongStore
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    leax      <$1E,s
                    lbsr      LongAdd
                    lbsr      LongStore
                    ldd       <$12,s
                    std       ,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    tfr       d,u
                    pshs      u
                    ldd       #$0003
                    addd      ,s++
                    pshs      a,b
                    ldd       <$18,s
                    pshs      a,b
                    lbsr      CopyNoteAttrs
                    leas      4,s
                    ldd       <$14,s
                    beq       x26@
                    ldx       <$14,s
                    ldb       2,x
                    cmpb      #$20
                    bne       w26@
                    ldd       #$0002
                    ldx       <$14,s
                    stb       4,x
w26@                ldd       <$14,s
                    pshs      a,b
                    pshs      u
                    ldd       #$0003
                    addd      ,s++
                    pshs      a,b
                    lbsr      CopyNoteAttrs
                    leas      4,s
x26@                leax      6,s
                    pshs      x
                    leax      4,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldx       <$1C,s
                    ldb       1,x
                    sex
                    pshs      a,b
                    ldb       [<$1E,s]
                    sex
                    pshs      a,b
                    lbsr      cod2raw
                    leas      4,s
                    lbsr      IntToLong
                    lbsr      LongAdd
                    lbsr      LongStore
                    lbra      ab26@
y26@                ldd       ,s
                    pshs      a,b
                    lbsr      next
                    leas      2,s
                    std       <$12,s
                    ble       z26@
                    leax      2,s
                    pshs      x
                    ldd       <$14,s
                    pshs      a,b
                    lbsr      fulltime
                    leas      2,s
                    lbsr      LongStore
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    leax      14,s
                    lbsr      LongCmp
                    blt       aa26@
z26@                leax      6,s
                    pshs      x
                    leax      12,s
                    lbsr      LongStore
                    bra      ac26@
aa26@               ldd       <$12,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    addd      #$0003
                    pshs      a,b
                    ldd       <$18,s
                    pshs      a,b
                    lbsr      CopyNoteAttrs
                    leas      4,s
                    leax      6,s
                    pshs      x
                    leax      4,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldx       <$1C,s
                    ldb       1,x
                    sex
                    pshs      a,b
                    ldb       [<$1E,s]
                    sex
                    pshs      a,b
                    lbsr      cod2raw
                    leas      4,s
                    lbsr      IntToLong
                    lbsr      LongAdd
                    lbsr      LongStore
                    ldd       <$12,s
                    pshs      a,b
                    lbsr      remove
                    leas      2,s
ab26@               leax      10,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    leax      10,s
                    lbsr      LongCmp
                    lbgt      y26@
ac26@               ldd       <$14,s
                    bne       ad26@
                    ldd       ,s
                    pshs      a,b
                    lbsr      remove
                    leas      2,s
                    bra       ae26@
ad26@               leax      6,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    leax      14,s
                    lbsr      LongCmp
                    bne       ae26@
                    ldd       ,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    tfr       d,x
                    leax      7,x
                    pshs      x
                    ldx       <$18,s
                    ldb       4,x
                    stb       [,s++]
ae26@               leax      6,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    leax      14,s
                    lbsr      LongSub
                    ldd       >UmeData_reserved_0345
                    leas      14,s
                    puls      u,pc
* ghola (was L3A21): sets <$7C, computes piles (parse/regen) and enter for a new note/rest
ghola          pshs      u
                    leas      -8,s
                    ldd       #$0001
                    stb       <rfr_scr
                    ldx       14,s
                    ldb       2,x
                    cmpb      #$20
                    bne       a27@
                    ldd       #$0002
                    std       6,s
                    bra       b27@
a27@                ldx       14,s
                    ldb       4,x
                    sex
                    std       6,s
                    clra
                    clrb
b27@                ldx       14,s
                    stb       4,x
                    ldx       14,s
                    ldb       2,x
                    sex
                    std       <vslot
                    pshs      a,b
                    ldx       <$10,s
                    ldb       1,x
                    sex
                    pshs      a,b
                    ldd       <$14,s
                    pshs      a,b
                    ldd       <$18,s
                    pshs      a,b
                    lbsr      parse
                    leas      8,s
c27@                ldb       <$19,s
                    sex
                    pshs      a,b
                    ldd       <$10,s
                    addd      #$0001
                    pshs      a,b
                    ldd       <$12,s
                    pshs      a,b
                    lbsr      regen
                    leas      6,s
                    std       2,s
                    ldd       <$12,s
                    subd      2,s
                    std       4,s
                    ldx       14,s
                    ldb       2,x
                    sex
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    leax      <$18,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    lbsr      enter
                    leas      8,s
                    std       ,s
                    bge       d27@
                    ldd       #$FFFF
                    bra       e27@
d27@                ldd       ,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    tfr       d,u
                    ldd       14,s
                    pshs      a,b
                    pshs      u
                    ldd       #$0003
                    addd      ,s++
                    pshs      a,b
                    lbsr      CopyNoteAttrs
                    leas      4,s
                    leax      <$14,s
                    pshs      x
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldd       10,s
                    lbsr      IntToLong
                    lbsr      LongAdd
                    lbsr      LongStore
                    ldd       2,s
                    std       <$12,s
                    ldd       2,s
                    lbgt      c27@
                    ldd       6,s
                    stb       7,u
                    ldx       14,s
                    stb       4,x
                    ldd       ,s
e27@                leas      8,s
                    puls      u,pc
* qchip (was L3AF9): bomb then ghola at fulltime+offset; used by smash and note entry
qchip     pshs      u
                    leas      -13,s
                    ldx       <$13,s
                    ldb       1,x
                    sex
                    std       ,s
                    ldd       <$15,s
                    lbsr      IntToLong
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    leax      12,s
                    pshs      x
                    ldd       <$19,s
                    pshs      a,b
                    ldd       <$19,s
                    pshs      a,b
                    lbsr      bomb
                    leas      10,s
                    std       2,s
                    bne       f27@
                    ldd       <$11,s
                    bra       g27@
f27@                leax      4,s
                    pshs      x
                    ldd       <$13,s
                    pshs      a,b
                    lbsr      fulltime
                    leas      2,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldd       <$1B,s
                    lbsr      IntToLong
                    lbsr      LongAdd
                    lbsr      LongStore
                    clra
                    clrb
                    pshs      a,b
                    leax      6,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    leax      <$12,s
                    pshs      x
                    ldd       <$23,s
                    pshs      a,b
                    lbsr      ghola
                    leas      14,s
g27@                leas      13,s
                    puls      u,pc
* parse (was L3B7A): vector $039D: computes the chord 'pile' counters <vslot..<tripnow for a duration span
parse           pshs      u
                    leas      <-$18,s
                    ldd       <$1C,s
                    beq       h27@
                    ldd       <$1C,s
                    cmpd      #$0001
                    bne       i27@
h27@                clra
                    clrb
                    lbra      y27@
i27@                ldd       <$22,s
                    std       <vslot
                    ldd       <$1E,s
                    cmpd      #$0003
                    bne       j27@
                    ldd       #$0001
                    bra       k27@
j27@                clra
                    clrb
k27@                stb       <tripnow
                    ldd       <$1C,s
                    std       >UmeData_durleft
                    clra
                    clrb
                    std       <rshift
                    ldd       <$1E,s
                    cmpd      #$0003
                    bge       l27@
                    ldd       <$20,s
                    cmpd      #$0003
                    bge       l27@
                    ldd       <$1C,s
                    pshs      a,b
                    ldd       #$0003
                    lbsr      DivInt
                    std       <strleft
                    clra
                    clrb
                    std       <trileft
                    ldd       <strleft
                    pshs      a,b
                    ldd       #$0003
                    lbsr      MulInt
                    pshs      a,b
                    ldd       <$1E,s
                    subd      ,s++
                    lbeq      x27@
                    bra       m27@
l27@                ldd       <$1E,s
                    cmpd      #$0003
                    bne       m27@
                    ldd       <$20,s
                    cmpd      #$0003
                    bne       m27@
                    ldd       <$1C,s
                    clra
                    andb      #$01
                    bne       m27@
                    ldd       <$1C,s
                    asra
                    rorb
                    std       <trileft
                    clra
                    clrb
                    std       <strleft
                    lbra      x27@
m27@                ldd       #$0063
                    std       8,s
                    clra
                    clrb
                    std       4,s
                    std       6,s
                    clra
                    clrb
                    std       <$12,s
                    clra
                    clrb
                    lbra      w27@
n27@                ldd       <$1C,s
                    subd      <$16,s
                    std       <$14,s
                    clra
                    andb      #$01
                    lbne      v27@
                    ldd       <$14,s
                    asra
                    rorb
                    std       <$10,s
                    ldd       #$03E7
                    std       ,s
                    std       2,s
                    leax      2,s
                    pshs      x
                    clra
                    clrb
                    pshs      a,b
                    ldd       <$16,s
                    pshs      a,b
                    lbsr      nbods
                    leas      6,s
                    pshs      a,b
                    leax      2,s
                    pshs      x
                    ldd       #$0001
                    pshs      a,b
                    ldd       <$16,s
                    pshs      a,b
                    lbsr      nbods
                    leas      6,s
                    addd      ,s++
                    std       14,s
                    ldd       2,s
                    cmpd      ,s
                    bge       o27@
                    ldd       2,s
                    bra       p27@
o27@                ldd       ,s
p27@                std       12,s
                    ldd       2,s
                    cmpd      ,s
                    ble       q27@
                    ldd       2,s
                    bra       r27@
q27@                ldd       ,s
r27@                std       10,s
                    ldd       14,s
                    cmpd      8,s
                    bge       t27@
                    ldd       14,s
                    std       8,s
s27@                ldd       12,s
                    std       6,s
                    bra       u27@
t27@                ldd       14,s
                    cmpd      8,s
                    bne       v27@
                    ldd       12,s
                    cmpd      6,s
                    bgt       s27@
                    ldd       12,s
                    cmpd      6,s
                    bne       v27@
                    ldd       10,s
                    cmpd      4,s
                    ble       v27@
u27@                ldd       10,s
                    std       4,s
                    ldd       <$12,s
                    std       <strleft
v27@                ldd       <$12,s
                    addd      #$0001
                    std       <$12,s
                    ldd       <$16,s
                    addd      #$0003
w27@                std       <$16,s
                    ldd       <$16,s
                    cmpd      <$1C,s
                    lble      n27@
                    ldd       <strleft
                    pshs      a,b
                    ldd       #$0003
                    lbsr      MulInt
                    pshs      a,b
                    ldd       <$1E,s
                    subd      ,s++
                    asra
                    rorb
                    std       <trileft
x27@                ldd       #$0001
y27@                leas      <$18,s
                    puls      u,pc
* nbods (was L3D02): parse helper: shifts a tick count until odd, counts the pieces, keeps the max via the ptr arg
nbods     pshs      u
                    leas      -8,s
                    clra
                    clrb
                    std       6,s
                    ldd       #$0003
                    subd      14,s
                    std       4,s
                    bra      ad27@
z27@                ldd       12,s
                    pshs      a,b
                    ldd       #$0001
                    lbsr      ShiftRightLog
                    std       12,s
                    ldd       4,s
                    pshs      a,b
                    ldd       #$0001
                    lbsr      ShiftLeft
                    std       4,s
aa27@               ldd       12,s
                    clra
                    andb      #$01
                    beq       z27@
                    ldd       6,s
                    addd      #$0001
                    std       6,s
                    ldd       14,s
                    bne       ab27@
                    ldd       12,s
                    clra
                    andb      #$02
                    beq       ab27@
                    ldd       12,s
                    clra
                    andb      #$07
                    std       2,s
                    ldd       12,s
                    subd      2,s
                    std       12,s
                    ldd       4,s
                    pshs      a,b
                    ldd       4,s
                    lbsr      MulInt
                    bra       ac27@
ab27@               ldd       12,s
                    addd      #$FFFF
                    std       12,s
                    ldd       4,s
ac27@               std       ,s
                    ldd       ,s
                    cmpd      [<$10,s]
                    bge       ad27@
                    ldd       ,s
                    std       [<$10,s]
ad27@               ldd       12,s
                    bne       aa27@
                    ldd       6,s
                    leas      8,s
                    puls      u,pc
* regen (was L3D7F): regenerates pile/duration bookkeeping after an edit; error '***Regen: piles=0, DurLeft='; vector $03A9
regen          pshs      a,b,x,y,u
                    ldd       <trileft
                    bne       b28@
                    ldd       <strleft
                    bne       b28@
                    ldd       >UmeData_durleft
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    leax      >msgRegenPiles,pcr
                    pshs      x
                    lbsr      alert
                    leas      6,s
                    clra
                    clrb
                    lbra      o28@
a28@                leas      -6,x
b28@                ldb       <tripnow
                    beq       c28@
                    ldd       #$0002
                    std       4,s
                    ldx       #$00A3
                    bra       d28@
c28@                ldd       #$0003
                    std       4,s
                    ldx       #$00A1
d28@                stx       2,s
                    ldd       [<$02,s]
                    bne       h28@
                    clra
                    clrb
                    std       <rshift
                    ldb       <tripnow
                    bne       e28@
                    ldd       #$0001
                    bra       f28@
e28@                clra
                    clrb
f28@                stb       <tripnow
                    leax      6,s
                    bra       a28@
g28@                ldd       [<$02,s]
                    pshs      a,b
                    ldd       #$0001
                    lbsr      ShiftRightArith
                    std       [<$02,s]
                    ldd       <rshift
                    addd      #$0001
                    std       <rshift
h28@                ldd       [<$02,s]
                    clra
                    andb      #$01
                    beq       g28@
                    ldb       <tripnow
                    bne       l28@
                    ldb       15,s
                    bne       i28@
                    ldd       <vslot
                    cmpd      #$0020
                    beq       k28@
i28@                ldd       [<$02,s]
                    clra
                    andb      #$02
                    beq       k28@
                    ldd       [<$02,s]
                    clra
                    andb      #$04
                    beq       j28@
                    ldd       #$0002
                    stb       [<$0C,s]
                    ldd       #$0005
                    subd      <rshift
                    stb       [<$0A,s]
                    ldd       #$0007
                    bra       n28@
j28@                ldd       #$0001
                    stb       [<$0C,s]
                    ldd       #$0006
                    subd      <rshift
                    stb       [<$0A,s]
                    ldd       #$0003
                    bra       n28@
k28@                clra
                    clrb
                    bra       m28@
l28@                ldd       #$0003
m28@                stb       [<$0C,s]
                    ldd       #$0007
                    subd      <rshift
                    stb       [<$0A,s]
                    ldd       #$0001
n28@                std       ,s
                    ldd       [<$02,s]
                    subd      ,s
                    std       [<$02,s]
                    ldd       ,s
                    pshs      a,b
                    ldd       <rshift
                    lbsr      ShiftLeft
                    std       ,s
                    ldd       >UmeData_durleft
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    ldd       4,s
                    lbsr      MulInt
                    nega
                    negb
                    sbca      #$00
                    addd      ,s++
                    std       >UmeData_durleft
o28@                leas      6,s
                    puls      u,pc
* msgRegenPiles (was L3E81): '***Regen: piles=0, DurLeft='
msgRegenPiles       fcc       /Regen: piles=0 DurLeft=/
                    fcb       $00
* drawnr (was L3E9D): builds a $A0 (note) or $A1 (rest, event byte 2 == ' ') packet with x,y,pitch/accidental bits and nfwrite; vector $038B
drawnr        pshs      u
                    ldd       6,s
                    cmpd      #$0002
                    blt       b29@
                    ldd       6,s
                    cmpd      #$004E
                    bgt       b29@
                    ldd       8,s
                    cmpd      #$0005
                    blt       b29@
                    ldd       8,s
                    cmpd      #$00BA
                    bgt       b29@
                    ldb       13,s
                    beq       a29@
                    ldd       8,s
                    cmpd      #$000C
                    blt       b29@
a29@                ldb       13,s
                    bne       c29@
                    ldd       8,s
                    cmpd      #$00B3
                    ble       c29@
b29@                puls      u,pc
c29@                ldb       <$11,s
                    stb       <arg1
                    ldd       6,s
                    stb       <arg2
                    ldd       8,s
                    stb       <arg3
                    ldx       4,s
                    ldb       ,x
                    cmpb      #8
                    blo       nrshort@
                    lda       <arg1
                    ora       #Note128Bit
                    sta       <arg1
                    ldb       #7                  legacy duration field stays within three bits
nrshort@            aslb
                    aslb
                    orb       1,x
                    stb       <arg4
                    ldx       4,s
                    ldb       2,x
                    cmpb      #$20
                    bne       d29@
                    ldd       #$00A1
                    stb       <arg0
                    ldd       #$0005
                    bra      g29@
d29@                ldd       #$00A0
                    stb       <arg0
                    ldx       4,s
                    ldb       3,x
                    aslb
                    aslb
                    aslb
                    orb       <arg1
                    stb       <arg1
                    ldb       4,x
                    aslb
                    aslb
                    aslb
                    aslb
                    aslb
                    orb       <arg4
                    stb       <arg4
                    ldd       10,s
                    stb       <arg5
                    ldb       13,s
                    beq       e29@
                    ldb       <arg1
                    sex
                    orb       #$02
                    stb       <arg1
e29@                ldb       15,s
                    beq       f29@
                    ldb       <arg1
                    sex
                    orb       #$04
                    stb       <arg1
f29@                ldx       4,s
                    cmpx      #$2000              event pages, not the brush or menu templates
                    blo       NoFocusNote
                    ldb       -3,x                event part precedes the five note attributes
                    clra
                    cmpd      >FocusedPart
                    bne       NoFocusNote
                    lda       <arg1
                    ora       #FocusNoteBit
                    sta       <arg1
NoFocusNote         ldd       #$0006
g29@                pshs      a,b
                    lbsr      nfwrite
                    leas      2,s
                    puls      u,pc
* FocusClickedNote: a note click selects its part; the normal score redraw applies the color and order.
FocusClickedNote    pshs      d
                    ldb       ,u
                    beq       FocusClickDone
                    lda       5,u
                    cmpa      #$20
                    beq       FocusClickDone
                    clra
                    std       >FocusedPart
                    lda       #1
                    sta       >FocusDirty
FocusClickDone      puls      d,pc
* SendNoteA9 (was L3F67): builds the 6-byte $A9 packet (5 values) then flush; sent twice per note drag in MainLoop
SendNoteA9          pshs      u
                    ldd       8,s
                    bge       h29@
                    clra
                    clrb
                    std       8,s
h29@                ldd       #$00A9
                    stb       <arg0
                    ldd       4,s
                    stb       <arg1
                    ldd       6,s
                    stb       <arg2
                    ldd       8,s
                    stb       <arg3
                    ldd       10,s
                    stb       <arg4
                    ldb       13,s
                    stb       <arg5
                    ldd       #$0006
                    pshs      a,b
                    lbsr      nfwrite
                    leas      2,s
                    bra       i29@
* SendFlagB0 (was L3FB4): printf(<$0A,$B0,n)+flush; called with the <aborted drag flag and with 0 by place
SendFlagB0          pshs      u
                    ldb       5,s
                    sex
                    pshs      a,b
                    ldd       #$00B0
                    pshs      a,b
                    ldd       <UmeData_reserved_000A
                    pshs      a,b
                    lbsr      Printf
                    leas      6,s
i29@                lbsr      flush
                    puls      u,pc
* SendCmdAC (was L3FCE): printf(<$16,$AC) one-byte s9gui command sent by place, paired with SendCmdAD
SendCmdAC           pshs      u
                    ldd       #$00AC
                    bra       j29@
* SendCmdAD (was L3FD5): printf(<$16,$AD) one-byte s9gui command sent by place after pmodfix
SendCmdAD           pshs      u
                    ldd       #$00AD
j29@                pshs      a,b
                    ldd       <pctn1
                    pshs      a,b
                    lbsr      Printf
                    leas      4,s
                    puls      u,pc
* ispwexpr (was L3FE7): true for marker subtypes $16 channel, $17 instrument, $18 volume, $1E, $20 (per-part environment markers)
ispwexpr     pshs      u
                    ldd       4,s
                    cmpd      #$0017
                    beq       a30@
                    ldd       4,s
                    cmpd      #$0018
                    beq       a30@
                    ldd       4,s
                    cmpd      #$0016
                    beq       a30@
                    ldd       4,s
                    cmpd      #$001E
                    beq       a30@
                    ldd       4,s
                    cmpd      #$0020
                    bne       b30@
a30@                ldd       #$0001
                    bra       c30@
b30@                clra
                    clrb
c30@                puls      u,pc
* cod2raw (was L401A): duration in ticks: table at $015A indexed by value code, shifted right by the second arg; vector $03AB
cod2raw        pshs      u
                    ldd       6,s
                    aslb
                    rola
                    ldx       #$015A
                    leax      d,x
                    ldd       ,x
                    pshs      a,b
                    ldd       6,s
                    lbsr      ShiftRightArith
                    puls      u,pc
* pnext (was L4030): returns the index of the next event belonging to part p after idx, or -1
pnext     pshs      u
                    ldd       4,s
                    cmpd      <nevents
                    bge       d31@
                    ldd       4,s
                    addd      #$0001
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    bra       c31@
a31@                ldb       ,u
                    sex
                    cmpd      6,s
                    bne       b31@
                    ldd       <curind
                    puls      u,pc
b31@                lbsr      plusplus
c31@                tfr       d,u
                    ldd       <curind
                    cmpd      <nevents
                    blt       a31@
d31@                ldd       #$FFFF
                    puls      u,pc
* next (was L4064): pnext for the part of event idx
next     pshs      u
                    ldd       4,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    tfr       d,x
                    ldb       ,x
                    sex
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    bsr       pnext
                    bra       e32@
* findstaff (was L407E): vector $035B: returns the staff whose $0C19 band (y-2..y+18) holds the given y, else >= <nstaves
findstaff        pshs      a,b,x,u
                    clra
                    clrb
                    bra       c32@
a32@                ldd       2,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      MulInt
                    ldx       #staves
                    leax      d,x
                    ldd       ,x
                    std       ,s
                    addd      #$FFFE
                    cmpd      8,s
                    bgt       b32@
                    ldd       ,s
                    addd      #$0012
                    cmpd      8,s
                    bge       d32@
b32@                ldd       2,s
                    addd      #$0001
c32@                std       2,s
                    ldd       2,s
                    cmpd      <nstaves
                    blt       a32@
d32@                ldd       2,s
e32@                leas      4,s
                    puls      u,pc
* find (was L40BD): walks parts calling finder to find the event under the mouse; -1 if none
find    pshs      a,b,x,y,u
                    ldd       #$FFFF
                    std       ,s
                    ldd       <lftind
                    std       2,s
                    ldb       15,s
                    clra
                    andb      #$03
                    bra       b33@
a33@                ldb       <$11,s
                    sex
                    pshs      a,b
                    ldd       4,s
                    pshs      a,b
                    ldd       <$10,s
                    pshs      a,b
                    ldd       <$10,s
                    pshs      a,b
                    bsr       finder
                    leas      8,s
                    std       4,s
                    blt       ra33@               nothing: the wider window once
                    ldd       4,s
                    std       ,s
                    addd      #$0001
                    std       2,s
                    ldb       15,s
                    addd      #$FFFF
b33@                stb       15,s
                    ldb       15,s
                    bge       a33@
                    bra       c33@
ra33@               ldb       <$11,s              the loose argument
                    cmpb      #1
                    bne       c33@                exact, or the wide pass already ran
                    incb
                    stb       <$11,s              2 = +-4 rows
                    bra       a33@
c33@                ldd       ,s
                    cmpd      #$FFFF
                    beq       d33@
                    ldd       ,s
                    std       >lastclik
d33@                ldd       ,s
                    leas      6,s
                    puls      u,pc
* finder (was L4112): event of one part under the click: compares x/y with the $0425/$05C2 tables (find)
finder         pshs      u
                    leas      -16,s
                    clra
                    clrb
                    std       8,s
                    ldd       <$18,s
                    std       2,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    lbra      x33@
e33@                ldd       <curind
                    subd      <xyoff
                    ldx       #grafxes
                    leax      d,x
                    ldb       ,x
                    sex
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    subd      <$14,s
                    std       14,s
                    cmpd      #$FFF4
                    lble      w33@
                    ldd       14,s
                    cmpd      #$0004
                    lbge      y33@
                    ldb       5,u
                    sex
                    std       ,s
                    ldb       ,u
                    bne      h33@
                    ldd       ,s
                    pshs      a,b
                    lbsr      ispwexpr
                    leas      2,s
                    bne      h33@
                    ldd       ,s
                    cmpd      #$0019
                    beq       f33@
                    ldd       ,s
                    cmpd      #$001A
                    beq       f33@
                    ldd       ,s
                    cmpd      #$001B
                    beq       f33@
                    ldd       ,s
                    cmpd      #$001C
                    beq       f33@
                    ldd       ,s
                    cmpd      #$001D
                    beq       f33@
                    ldd       ,s
                    cmpd      #$0022
                    beq       f33@
                    ldd       ,s
                    cmpd      #$001F
                    beq       f33@
                    ldd       ,s
                    cmpd      #$0021
                    beq       f33@
                    ldd       ,s
                    cmpd      #$0007
                    bne       g33@
f33@                ldd       <$16,s
                    cmpd      #$00AF
                    lbge      v33@
                    lbra      w33@
g33@                ldd       <$16,s
                    pshs      a,b
                    lbsr      findstaff
                    leas      2,s
                    std       6,s
                    cmpd      <nstaves
                    lblt      v33@
                    lbra      w33@
h33@                ldd       <curind
                    subd      <xyoff
                    ldx       #grafyes
                    leax      d,x
                    ldb       ,x
                    clra
                    subd      <$16,s
                    std       12,s
                    ldb       <$1B,s
                    bne       i33@
                    clra
                    clrb
                    bra       l33@
i33@                ldb       ,u
                    beq       k33@
                    ldd       ,s
                    cmpd      #$0020
                    bne       k33@
                    ldb       3,u
                    cmpb      #$01
                    bne       j33@
                    ldd       #$0003
                    bra       l33@
j33@                ldd       #$0001
                    bra       l33@
k33@                ldb       ,u
                    bne       m33@
                    ldd       ,s
                    pshs      a,b
                    lbsr      ispwexpr
                    leas      2,s
                    beq       m33@
                    ldd       #$0002
l33@                std       8,s
m33@                ldd       12,s
                    addd      8,s
                    std       12,s
                    beq       n33@
                    ldb       <$1B,s              loose: 0 exact, 1 = the original +-2 rows, 2 = the wide pass
                    lbeq      w33@
* find() runs finder with the +-2-row window over every event first and +-4 rows only when nothing
* was hit, so a nearby rest of another part does not take a press meant for a note.
* Window: |dy| < 2*loose+1.
                    aslb
                    incb                          3 or 5
                    clra
                    std       10,s
                    ldd       12,s
                    cmpd      10,s
                    lbge      w33@
                    ldd       12,s
                    addd      10,s
                    lble      w33@                dy <= -limit
n33@                ldb       ,u
                    beq      v33@
                    ldb       ,u
                    sex
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #parts
                    leax      d,x
                    ldd       2,x
                    std       4,s
                    ldd       >UmeData_reserved_03CB
                    beq       o33@
                    ldb       ,u
                    sex
                    cmpd      >UmeData_reserved_03CB
                    bne      w33@
o33@                ldd       ,s
                    cmpd      #$0020
                    bne       p33@
                    ldb       >UmeData_reserved_03CD
                    bne       q33@
p33@                ldd       ,s
                    cmpd      #$0020
                    beq       w33@
                    ldb       >UmeData_reserved_03CE
                    beq       w33@
q33@                ldd       4,s
                    clra
                    andb      #$04
                    beq       r33@
                    ldb       >UmeData_reserved_03CF
                    bne       s33@
r33@                ldd       4,s
                    clra
                    andb      #$04
                    bne       w33@
                    ldb       >UmeData_reserved_03D0
                    beq       w33@
s33@                ldd       4,s
                    clra
                    andb      #$01
                    beq       t33@
                    ldb       >UmeData_reserved_03D1
                    bne       v33@
t33@                ldd       4,s
                    clra
                    andb      #$02
                    beq       u33@
                    ldb       >UmeData_reserved_03D2
                    bne       v33@
u33@                ldd       4,s
                    clra
                    andb      #$03
                    bne       w33@
                    ldb       >UmeData_reserved_03D3
                    beq       w33@
v33@                ldd       <curind
                    bra       z33@
w33@                lbsr      plusplus
x33@                tfr       d,u
                    ldd       <curind
                    cmpd      <ritind
                    lble      e33@
y33@                ldd       #$FFFF
z33@                leas      <$10,s
                    puls      u,pc
* remove (was L42D9): removes event idx: count-1, ShiftEventsDown across buffer blocks; vector $03AF
remove         pshs      u
                    leas      <-$18,s
                    ldd       <$1C,s
                    blt       a34@
                    ldd       <$1C,s
                    cmpd      <nevents
                    blt       b34@
a34@                ldd       #$FFFF
                    lbra      g34@
b34@                ldd       <nevents
                    addd      #$FFFF
                    std       <nevents
                    ldd       <$1C,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    tfr       d,u
                    ldd       <curpage
                    std       2,s
                    ldd       <nevents
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    std       6,s
                    ldd       <curpage
                    std       ,s
                    cmpd      2,s
                    bne       c34@
                    pshs      u
                    ldd       8,s
                    subd      ,s++
                    pshs      a,b
                    pshs      u
                    lbsr      ShiftEventsDown
                    leas      4,s
                    lbra      f34@
c34@                ldd       <database
                    pshs      a,b
                    leax      <$12,s
                    pshs      x
                    lbsr      CopyEvent
                    leas      4,s
                    ldd       6,s
                    subd      <database
                    pshs      a,b
                    ldd       <database
                    pshs      a,b
                    lbsr      ShiftEventsDown
                    leas      4,s
                    ldd       ,s
                    bra       e34@
d34@                ldd       4,s
                    pshs      a,b
                    lbsr      pswap
                    leas      2,s
                    leax      <$10,s
                    pshs      x
                    leax      10,s
                    pshs      x
                    lbsr      CopyEvent
                    leas      4,s
                    ldd       <database
                    pshs      a,b
                    leax      <$12,s
                    pshs      x
                    lbsr      CopyEvent
                    leas      4,s
                    ldd       #$1CF8              927 events: the last event slot of a 928-event page
                    pshs      a,b
                    ldd       <database
                    pshs      a,b
                    lbsr      ShiftEventsDown
                    leas      4,s
                    leax      8,s
                    pshs      x
                    ldd       <curptop
                    pshs      a,b
                    lbsr      CopyEvent
                    leas      4,s
                    ldd       4,s
e34@                addd      #$FFFF
                    std       4,s
                    ldd       4,s
                    cmpd      2,s
                    bgt       d34@
                    ldd       <$1C,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    tfr       d,u
                    pshs      u
                    ldd       <curptop
                    subd      ,s++
                    pshs      a,b
                    pshs      u
                    lbsr      ShiftEventsDown
                    leas      4,s
                    leax      <$10,s
                    pshs      x
                    ldd       <curptop
                    pshs      a,b
                    lbsr      CopyEvent
                    leas      4,s
                    lbsr      giveback
f34@                ldd       <$1C,s
g34@                leas      <$18,s
                    puls      u,pc
* makroom (was L43D1): opens a slot at idx (ShiftEventsUp, new block if needed), count+1, returns pointer; vector $03B5
makroom         pshs      u
                    leas      <-$1A,s
                    ldd       <$1E,s
                    bge       a35@
                    clra
                    clrb
                    std       <$1E,s
a35@                ldd       <$1E,s
                    cmpd      <nevents
                    ble       b35@
                    ldd       <nevents
                    std       <$1E,s
b35@                ldd       <nevents
                    cmpd      #$7FFF
                    bge       c35@
                    ldd       <nevents
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    std       8,s
                    bne       d35@
c35@                clra
                    clrb
                    lbra      j35@
d35@                ldd       <curpage
                    std       2,s
                    ldd       <$1E,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    tfr       d,u
                    ldd       <curpage
                    std       4,s
                    cmpd      2,s
                    bne       e35@
                    pshs      u
                    ldd       10,s
                    subd      ,s++
                    pshs      a,b
                    pshs      u
                    lbsr      ShiftEventsUp
                    lbra      h35@
e35@                ldd       <curptop
                    pshs      a,b
                    leax      12,s
                    pshs      x
                    lbsr      CopyEvent
                    leas      4,s
                    pshs      u
                    ldd       <curptop
                    subd      ,s++
                    pshs      a,b
                    pshs      u
                    lbsr      ShiftEventsUp
                    leas      4,s
                    ldd       4,s
                    bra       g35@
f35@                ldd       ,s
                    pshs      a,b
                    lbsr      pswap
                    leas      2,s
                    leax      10,s
                    pshs      x
                    leax      <$14,s
                    pshs      x
                    lbsr      CopyEvent
                    leas      4,s
                    ldd       <curptop
                    pshs      a,b
                    leax      12,s
                    pshs      x
                    lbsr      CopyEvent
                    leas      4,s
                    ldd       #$1CF8              927 events: the last event slot of a 928-event page
                    pshs      a,b
                    ldd       <database
                    pshs      a,b
                    lbsr      ShiftEventsUp
                    leas      4,s
                    leax      <$12,s
                    pshs      x
                    ldd       <database
                    pshs      a,b
                    lbsr      CopyEvent
                    leas      4,s
                    ldd       ,s
g35@                addd      #$0001
                    std       ,s
                    ldd       ,s
                    cmpd      2,s
                    blt       f35@
                    ldd       <nevents
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    std       8,s
                    subd      <database
                    pshs      a,b
                    ldd       <database
                    pshs      a,b
                    lbsr      ShiftEventsUp
                    leas      4,s
                    leax      10,s
                    pshs      x
                    ldd       <database
                    pshs      a,b
                    lbsr      CopyEvent
h35@                leas      4,s
                    ldd       <$1E,s
                    cmpd      <nevents
                    bne       i35@
                    ldd       <nevents
                    addd      #$FFFF
                    pshs      a,b
                    bsr      EventEndTime
                    leas      2,s
                    ldd       >UmeData_reserved_0345
                    std       6,s
                    ldd       <nevents
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    tfr       d,x
                    ldd       6,s
                    std       1,x
i35@                ldd       <nevents
                    addd      #$0001
                    std       <nevents
                    ldd       <$1E,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
j35@                leas      <$1A,s
                    puls      u,pc
* fulltime (was L4501): 32-bit start time of event idx: 16-bit field plus wrap count found by walking back; stores into caller's long; vector $03B3
fulltime       pshs      a,b,x,y,u
                    ldd       10,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    tfr       d,u
                    ldd       1,u
                    std       ,s
                    std       4,s
                    clra
                    clrb
                    std       2,s
                    bra       c36@
a36@                ldd       1,u
                    cmpd      ,s
                    bls       b36@
                    ldd       2,s
                    addd      #$0001
                    std       2,s
b36@                ldd       1,u
                    std       ,s
                    lbsr      decdec
                    tfr       d,u
c36@                ldd       <curind
                    bge       a36@
                    ldd       10,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    leax      2,s
                    ldu       #$0343
                    pshs      u
                    lbsr      LongStore
                    lbra      EventWalkCommonRet
* EventEndTime (was L454B): fulltime + cod2raw of the event (long)
EventEndTime        pshs      a,b,x,u
                    ldd       8,s
                    bge       a37@
                    bsr       EventEndZeroRet
                    neg       <UmeData_reserved_0000
                    neg       <UmeData_reserved_0000
* EventEndZeroRet (was L4557): EventEndTime idx<0 path: bsr skips the inline long 0, puls x = &zero returned as the end time
EventEndZeroRet     puls      x
                    bra       c37@
a37@                leax      ,s
                    pshs      x
                    ldd       10,s
                    pshs      a,b
                    bsr      fulltime
                    leas      2,s
                    lbsr      LongStore
                    ldd       8,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    tfr       d,u
                    ldb       ,u
                    beq       b37@
                    leax      ,s
                    pshs      x
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldb       4,u
                    sex
                    pshs      a,b
                    ldb       3,u
                    sex
                    pshs      a,b
                    lbsr      cod2raw
                    leas      4,s
                    lbsr      IntToLong
                    lbsr      LongAdd
                    lbsr      LongStore
b37@                leax      ,s
c37@                ldu       #$0343
                    pshs      u
                    lbsr      LongStore
                    leas      4,s
                    puls      u,pc
* enter (was L45AC): finds the first event with time > given long and makroom there with part/time/subtype; vector $03AD
enter   pshs      u
                    leas      -10,s
                    leax      4,s
                    pshs      x
                    bsr       InsEvtTimeZeroRet
                    neg       <UmeData_reserved_0000
                    neg       <UmeData_reserved_0000
* InsEvtTimeZeroRet (was L45BA): enter: bsr skips the inline long 0, puls x = &zero used to init the running time
InsEvtTimeZeroRet   puls      x
                    lbsr      LongStore
                    clra
                    clrb
                    std       2,s
                    clra
                    clrb
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    bra      d38@
a38@                ldd       1,u
                    std       ,s
                    cmpd      2,s
                    bhs       b38@
                    ldd       4,s
                    addd      #$0001
                    std       4,s
b38@                ldd       ,s
                    std       2,s
                    std       6,s
                    leax      14,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    leax      8,s
                    lbsr      LongCmp
                    bgt       c38@
                    leax      14,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    leax      8,s
                    lbsr      LongCmp
                    blt       e38@
                    ldb       ,u
                    sex
                    cmpd      <$12,s
                    bgt       e38@
                    ldb       ,u
                    sex
                    cmpd      <$12,s
                    bne       c38@
                    ldb       5,u
                    sex
                    cmpd      <$14,s
                    ble       c38@
                    ldb       5,u
                    cmpb      #$0D
                    beq       c38@
                    ldb       5,u
                    cmpb      #$0E
                    bne       e38@
c38@                lbsr      plusplus
d38@                tfr       d,u
                    ldd       <curind
                    cmpd      <nevents
                    blt      a38@
e38@                ldd       <curind
                    std       8,s
                    pshs      a,b
                    lbsr      makroom
                    leas      2,s
                    tfr       d,u
                    stu       -2,s
                    bne       f38@
                    ldd       #$FFFF
                    bra       g38@
f38@                ldd       <$12,s
                    stb       ,u
                    ldd       <$10,s
                    std       1,u
                    ldd       <$14,s
                    stb       5,u
                    ldd       8,s
g38@                leas      10,s
                    puls      u,pc
* AuditIndex (was L4667): checks event start times are monotonic: 'Audit: bad start after'
AuditIndex          pshs      a,b,x,y,u
                    clra
                    clrb
                    std       4,s
                    clra
                    clrb
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    bra       c39@
a39@                ldd       1,u
                    std       2,s
                    subd      4,s
                    std       ,s
                    bge       b39@
                    ldd       4,s
                    pshs      a,b
                    ldd       4,s
                    pshs      a,b
                    ldd       <curind
                    pshs      a,b
                    ldd       #$0003
                    pshs      a,b
                    leax      >msgAuditBadStart,pcr
                    pshs      x
                    lbsr      alert
                    leas      10,s
                    clra
                    clrb
                    lbra      EventWalkCommonRet
b39@                ldd       2,s
                    std       4,s
                    lbsr      plusplus
c39@                tfr       d,u
                    ldd       <curind
                    cmpd      <nevents
                    blt       a39@
                    ldd       #$0001
                    lbra      EventWalkCommonRet
* RenumberBars (was L46B9): walks bar events (findts) renumbering them into byte 3; last bar count into <nbars
RenumberBars        pshs      a,b,x,y,u
                    ldd       #$0001
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    bra       e39@
d39@                pshs      u
                    lbsr      anybar
                    std       ,s++
                    bne       f39@
                    lbsr      plusplus
e39@                tfr       d,u
                    ldd       <curind
                    cmpd      <nevents
                    blt       d39@
f39@                ldd       <curind
                    pshs      a,b
                    bsr      findts
                    leas      2,s
                    ldd       <UmeData_reserved_0003
                    pshs      a,b
                    ldd       <dendur
                    lbsr      MulInt
                    cmpd      1,u
                    bhi       g39@
                    ldd       #$0001
                    bra       h39@
g39@                clra
                    clrb
h39@                std       4,s
                    clra
                    clrb
                    std       2,s
                    clra
                    clrb
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    bra       n39@
i39@                pshs      u
                    lbsr      anybar
                    std       ,s++
                    beq       m39@
                    ldd       1,u
                    std       ,s
                    ldd       4,s
                    pshs      a,b
                    ldd       2,s
                    cmpd      4,s
                    beq       j39@
                    ldd       #$0001
                    bra       k39@
j39@                clra
                    clrb
k39@                addd      ,s++
                    std       4,s
                    ldb       11,s
                    beq       l39@
                    ldd       4,s
                    std       3,u
l39@                ldd       ,s
                    std       2,s
m39@                lbsr      plusplus
n39@                tfr       d,u
                    ldd       <curind
                    cmpd      <nevents
                    blt       i39@
                    ldd       4,s
                    addd      #$FFFF
                    std       <nbars
* EventWalkCommonRet (was L474D): shared 'leas 6,s; puls u,pc' exit of fulltime, AuditIndex and RenumberBars
EventWalkCommonRet  leas      6,s
                    puls      u,pc
* findts (was L4751): scans backwards from idx for a marker (part 0) with subtype $0A (time signature), then timesig; vector $0391
findts   pshs      u
                    ldd       4,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    bra       c40@
a40@                ldb       ,u
                    bne       b40@
                    ldb       5,u
                    cmpb      #$0A
                    bne       b40@
                    ldb       6,u
                    sex
                    std       <UmeData_reserved_0003
                    ldb       7,u
                    sex
                    std       <UmeData_reserved_0005
                    bra       d40@
b40@                lbsr      decdec
c40@                tfr       d,u
                    ldd       <curind
                    bge       a40@
d40@                lbsr      timesig
                    puls      u,pc
* partstaff (was L4782): looks up part p in the staff table: returns staff, position and flags ('Partstaff: Bad Part=')
partstaff       pshs      a,b,u
                    ldd       6,s
                    cmpd      #$0001
                    blt       a41@
                    ldd       6,s
                    cmpd      <nparts
                    ble       b41@
a41@                ldd       6,s
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    leax      >msgBadPart,pcr
                    pshs      x
                    lbsr      alert
                    leas      6,s
                    ldd       <nparts
                    std       6,s
b41@                ldd       6,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #parts
                    leax      d,x
                    ldd       ,x
                    std       ,s
                    ldd       6,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #parts
                    leax      d,x
                    ldd       2,x
                    std       [<$0C,s]
                    ldd       ,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      MulInt
                    ldx       #staves
                    leax      d,x
                    leau      ,x
                    ldd       ,u
                    std       [<$08,s]
                    ldd       2,u
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #clefs
                    leax      d,x
                    ldd       2,x
                    std       [<$0A,s]
                    ldd       ,s
                    leas      2,s
                    puls      u,pc
* msgAuditBadStart (was L47F6): 'Audit: bad start after' CR
msgAuditBadStart    fcc       /Audit: bad start after/
                    fcb       $0D,$00
* msgBadPart (was L481C): 'Partstaff: Bad Part='
msgBadPart          fcc       /Partstaff: Bad Part=/
                    fcb       $00
* markin (was L4831): inserts a barline/marker at the click, warning ' Barline will slice notes...' / ' Marker will slice...'
markin  pshs      u
                    leas      -13,s
                    ldd       <$13,s
                    std       4,s
                    bne       a42@
                    ldd       #$000F
                    std       <$13,s
                    bra      h42@
a42@                clra
                    clrb
                    std       2,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    bra       g42@
b42@                ldb       ,u
                    bne       f42@
                    ldb       5,u
                    sex
                    cmpd      <$13,s
                    bne       f42@
                    ldd       <curind
                    std       2,s
                    pshs      a,b
                    lbsr      remove
                    leas      2,s
                    ldd       2,s
                    cmpd      <$11,s
                    bge       c42@
                    ldd       <$11,s
                    addd      #$FFFF
                    std       <$11,s
c42@                ldb       <rfr_scr
                    sex
                    pshs      a,b
                    ldd       4,s
                    cmpd      <lftind
                    blt       d42@
                    ldd       4,s
                    cmpd      <ritind
                    bgt       d42@
                    ldd       #$0001
                    bra       e42@
d42@                clra
                    clrb
e42@                ora       ,s+
                    orb       ,s+
                    stb       <rfr_scr
                    bra       h42@
f42@                lbsr      plusplus
g42@                tfr       d,u
                    ldd       <curind
                    cmpd      <nevents
                    blt      b42@
h42@                ldd       <$11,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    tfr       d,u
                    ldb       ,u
                    bne       k42@
                    ldd       <$13,s
                    cmpd      #$000E
                    bne       i42@
                    ldd       #$0001
                    bra       j42@
i42@                clra
                    clrb
j42@                addd      <$11,s
                    std       ,s
                    lbra      af42@
k42@                ldd       1,u
                    std       10,s
                    ldd       <$13,s
                    cmpd      #$000D
                    beq       m42@
                    ldd       <$13,s
                    cmpd      #$000F
                    bne       p42@
                    bra       m42@
l42@                ldb       ,u
                    beq       n42@
                    ldd       1,u
                    subd      10,s
                    std       8,s
                    blt       n42@
                    lbsr      decdec
                    tfr       d,u
m42@                ldd       <curind
                    bge       l42@
n42@                ldd       <curind
                    addd      #$0001
                    std       ,s
                    bra       t42@
o42@                ldd       1,u
                    subd      10,s
                    std       8,s
                    bgt       q42@
                    lbsr      plusplus
                    tfr       d,u
p42@                ldd       <curind
                    cmpd      <nevents
                    blt       o42@
q42@                ldd       <curind
                    std       ,s
                    ldd       <curind
                    cmpd      <nevents
                    blt       r42@
                    ldd       <nevents
                    addd      #$FFFF
                    pshs      a,b
                    lbsr      EventEndTime
                    leas      2,s
                    ldd       >UmeData_reserved_0345
                    bra       s42@
r42@                ldd       1,u
s42@                std       10,s
t42@                clra
                    clrb
                    stb       12,s
                    ldd       #$0001
                    bra      ae42@
u42@                ldd       ,s
                    addd      #$FFFF
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    bra      ac42@
v42@                ldb       ,u
                    sex
                    cmpd      6,s
                    bne       ab42@
                    ldb       4,u
                    sex
                    pshs      a,b
                    ldb       3,u
                    sex
                    pshs      a,b
                    lbsr      cod2raw
                    leas      4,s
                    addd      1,u
                    pshs      a,b
                    ldd       12,s
                    subd      ,s++
                    std       8,s
                    bge       ad42@
                    ldb       12,s
                    bne       y42@
                    ldd       4,s
                    bne       w42@
                    leax      >msgBarlineSlice,pcr
                    bra       x42@
w42@                leax      >msgMarkerSlice,pcr
x42@                tfr       x,d
                    pshs      a,b
                    lbsr      yesno
                    std       ,s++
                    beq       z42@
y42@                ldd       #$0001
                    bra       aa42@
z42@                clra
                    clrb
aa42@               stb       12,s
                    bne       ab42@
                    bra       ag42@
ab42@               lbsr      decdec
ac42@               tfr       d,u
                    ldd       <curind
                    bge      v42@
ad42@               ldd       6,s
                    addd      #$0001
ae42@               std       6,s
                    ldd       6,s
                    cmpd      <nparts
                    ble      u42@
af42@               ldd       ,s
                    pshs      a,b
                    lbsr      makroom
                    leas      2,s
                    tfr       d,u
                    stu       -2,s
                    bne       ah42@
ag42@               clra
                    clrb
                    bra       al42@
ah42@               clra
                    clrb
                    stb       ,u
                    ldd       4,s
                    stb       5,u
                    ldd       4,s
                    bne       ak42@
                    clra
                    clrb
                    std       3,u
                    ldb       12,s
                    beq       ak42@
                    ldd       #$0001
                    bra       aj42@
ai42@               clra
                    clrb
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    ldd       4,s
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    lbsr      fixup
                    leas      8,s
                    ldd       6,s
                    addd      #$0001
aj42@               std       6,s
                    ldd       6,s
                    cmpd      <nparts
                    ble       ai42@
ak42@               ldd       #$0001
                    stb       <rfr_scr
al42@               leas      13,s
                    puls      u,pc
* msgBarlineSlice (was L4A18): ' Barline will slice notes' CR '   and/or rests; Insert anyway?'
msgBarlineSlice     fcc       / Barline will slice notes/
                    fcb       $0D
                    fcc       /   and/
                    fcb       $2F
                    fcc       /or rests; Insert anyway?/
                    fcb       $00
* msgMarkerSlice (was L4A52): ' Marker will slice' CR '   notes/rests!  Insert anyway?'
msgMarkerSlice      fcc       / Marker will slice/
                    fcb       $0D
                    fcc       /   notes/
                    fcb       $2F
                    fcc       /rests!  Insert anyway?/
                    fcb       $00
* pmodfix (was L4A8E): masks a value to 0-7 with 1->0 and 5->4 for the event duration byte 3 in place
pmodfix        pshs      u
                    ldd       4,s
                    clra
                    andb      #$07
                    std       4,s
                    cmpd      #$0001
                    bne       a43@
                    clra
                    clrb
                    puls      u,pc
a43@                ldd       4,s
                    cmpd      #$0005
                    bne       b43@
                    ldd       #$0004
                    puls      u,pc
b43@                ldd       4,s
                    puls      u,pc
* pluspart (was L4AB2): vector $036D: finds events at the same time in the other parts sharing the staff (partstaff)
pluspart      pshs      u
                    leas      <-$14,s
                    ldd       <$18,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    tfr       d,u
                    ldb       ,u
                    sex
                    std       <$12,s
                    ldd       1,u
                    std       2,s
                    ldb       4,u
                    sex
                    pshs      a,b
                    ldb       3,u
                    sex
                    pshs      a,b
                    lbsr      cod2raw
                    leas      4,s
                    std       ,s
                    leax      12,s
                    pshs      x
                    leax      <$10,s
                    pshs      x
                    leax      <$12,s
                    pshs      x
                    ldd       <$18,s
                    pshs      a,b
                    lbsr      partstaff
                    leas      8,s
                    std       <$10,s
                    ldd       #$0001
                    lbra      m43@
c43@                ldd       10,s
                    cmpd      <$12,s
                    lbeq      l43@
                    leax      6,s
                    pshs      x
                    leax      <$10,s
                    pshs      x
                    leax      <$12,s
                    pshs      x
                    ldd       <$10,s
                    pshs      a,b
                    lbsr      partstaff
                    leas      8,s
                    std       4,s
                    ldd       6,s
                    clra
                    andb      #$04
                    lbeq      l43@
                    ldd       4,s
                    cmpd      <$10,s
                    bne      l43@
                    ldd       6,s
                    eora      12,s
                    eorb      13,s
                    clra
                    andb      #$03
                    bne      l43@
                    ldd       <$18,s
                    addd      #$FFFF
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    bra       e43@
d43@                ldb       ,u
                    sex
                    cmpd      10,s
                    beq       f43@
                    lbsr      decdec
e43@                tfr       d,u
                    ldd       <curind
                    bgt       d43@
f43@                ldd       <curind
                    ble       g43@
                    ldb       4,u
                    sex
                    pshs      a,b
                    ldb       3,u
                    sex
                    pshs      a,b
                    lbsr      cod2raw
                    leas      4,s
                    addd      1,u
                    cmpd      2,s
                    bhi       l43@
g43@                ldd       <$18,s
                    addd      #$0001
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    bra       i43@
h43@                ldb       ,u
                    sex
                    cmpd      10,s
                    beq       j43@
                    lbsr      plusplus
i43@                tfr       d,u
                    ldd       <curind
                    cmpd      <nevents
                    blt       h43@
j43@                ldd       <curind
                    cmpd      <nevents
                    bge       k43@
                    ldd       2,s
                    addd      ,s
                    cmpd      1,u
                    bhi       l43@
k43@                ldd       10,s
                    bra       n43@
l43@                ldd       10,s
                    addd      #$0001
m43@                std       10,s
                    ldd       10,s
                    cmpd      <nparts
                    lble      c43@
                    clra
                    clrb
n43@                leas      <$14,s
                    puls      u,pc
* addclone (was L4BCB): 'Out of Clone parts; Add another?' / 'Sorry, out of Parts!' then adds a part; vector $036B
addclone        pshs      a,b,u
                    leax      >msgOutOfClones,pcr
                    pshs      x
                    lbsr      yesno
                    std       ,s++
                    beq       a44@
                    ldd       <nparts
                    cmpd      #$0010
                    blt       b44@
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgOutOfParts,pcr
                    pshs      x
                    lbsr      alert
                    leas      4,s
a44@                clra
                    clrb
                    lbra      m44@
b44@                ldd       <nparts
                    addd      #$0001
                    std       <nparts
                    std       ,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #parts
                    leax      d,x
                    ldd       6,s
                    std       ,x
                    ldd       ,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #parts
                    leax      d,x
                    leax      2,x
                    pshs      x
                    ldd       10,s
                    orb       #$04
                    std       [,s++]
                    ldd       ,s
                    ldx       #MidiPartOn
                    leax      d,x
                    ldd       #$0001
                    stb       ,x
                    ldx       #MidiChanTbl
                    pshs      x
                    ldd       2,s
                    pshs      a,b
                    ldd       4,s
                    pshs      a,b
                    lbsr      clonemid
                    leas      6,s
                    ldd       ,s
                    lbra      m44@
* repart (was L4C44): vector $0371: previous same-part note's pitch (space if none); accidental zeroed past a bar marker
repart      pshs      u
                    leas      -1,s
                    clra
                    clrb
                    stb       ,s
                    ldd       7,s
                    beq       i44@
                    ldd       5,s
                    addd      #$FFFF
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    bra       h44@
c44@                ldb       ,u
                    bne       d44@
                    ldb       5,u
                    cmpb      #$06
                    bgt       d44@
                    ldd       #$0001
                    stb       ,s
d44@                ldb       ,u
                    sex
                    cmpd      7,s
                    bne       g44@
                    ldb       5,u
                    cmpb      #$20
                    beq       g44@
                    ldb       ,s
                    beq       e44@
                    ldb       6,u
                    sex
                    bra       f44@
e44@                clra
                    clrb
f44@                std       [<$09,s]
                    ldb       5,u
                    sex
                    bra       j44@
g44@                lbsr      decdec
h44@                tfr       d,u
                    ldd       <curind
                    bge       c44@
i44@                clra
                    clrb
                    std       [<$09,s]
                    ldd       #$0020
j44@                leas      1,s
                    puls      u,pc
* abortest (was L4CA3): toggles <aborted when both drag offsets are < 6 and reports it with SendFlagB0; gates place
abortest      pshs      u
                    tst       <NoAbort
                    beq       abt0@
                    clr       <aborted            a plain click on a rest: the placement stands
                    puls      u,pc
abt0@               ldd       4,s
                    cmpd      #$0006
                    bge       k44@
                    ldd       6,s
                    cmpd      #$0006
                    bge       k44@
                    ldb       <aborted
                    bne       n44@
                    ldd       #$0001
                    bra       l44@
k44@                ldb       <aborted
                    beq       n44@
                    clra
                    clrb
l44@                stb       <aborted
                    sex
                    pshs      a,b
                    lbsr      SendFlagB0
m44@                leas      2,s
n44@                puls      u,pc
* place (was L4CD0): mouse note entry: copies the event, partstaff, computes pitch from y, may addclone ('Part added.  Now try it.')
place    pshs      u
                    leas      <-$33,s
                    clra
                    clrb
                    stb       <aborted
                    ldd       <$39,s
                    pshs      a,b
                    leax      <$2D,s
                    pshs      x
                    lbsr      CopyEvent
                    leas      4,s
                    ldx       <$39,s
                    ldb       5,x
                    sex
                    std       <$1A,s
                    ldd       <$37,s
                    subd      <xyoff
                    std       <$1C,s
                    ldx       #grafxes
                    leax      d,x
                    ldb       ,x
                    sex
                    std       <$26,s
                    ldd       <$1C,s
                    ldx       #grafyes
                    leax      d,x
                    ldb       ,x
                    clra
                    std       <$24,s
                    ldb       [<$39,s]
                    sex
                    std       10,s
                    leax      4,s
                    pshs      x
                    leax      8,s
                    pshs      x
                    leax      <$22,s
                    pshs      x
                    ldd       <$10,s
                    pshs      a,b
                    lbsr      partstaff
                    leas      8,s
                    std       <$28,s
                    ldd       4,s
                    clra
                    andb      #$01
                    bne       c45@
                    ldd       4,s
                    clra
                    andb      #$02
                    beq       b45@
a45@                ldd       #$0001
                    bra       d45@
b45@                ldd       <$1A,s
                    cmpd      #$0004
                    bgt       a45@
c45@                clra
                    clrb
d45@                stb       <$2A,s
                    clra
                    clrb
                    pshs      a,b
                    ldd       6,s
                    clra
                    andb      #$04
                    pshs      a,b
                    ldb       <$2E,s
                    sex
                    pshs      a,b
                    ldd       <$24,s
                    pshs      a,b
                    ldd       <$2C,s
                    pshs      a,b
                    ldd       <$30,s
                    pshs      a,b
                    ldd       <$45,s
                    addd      #$0003
                    pshs      a,b
                    lbsr      drawnr
                    leas      14,s
                    ldb       <$3E,s
                    lbeq      g45@
                    ldd       #$0001
                    pshs      a,b
                    ldd       6,s
                    clra
                    andb      #$04
                    pshs      a,b
                    ldb       <$2E,s
                    sex
                    pshs      a,b
                    ldd       <$24,s
                    pshs      a,b
                    ldd       <$2C,s
                    pshs      a,b
                    ldd       <$30,s
                    pshs      a,b
                    ldd       <$45,s
                    addd      #$0003
                    pshs      a,b
                    lbsr      drawnr
                    leas      14,s
                    ldd       <$37,s
                    pshs      a,b
                    lbsr      pluspart
                    leas      2,s
                    std       8,s
                    beq       e45@
                    ldd       8,s
                    std       10,s
                    ldd       4,s
                    orb       #$04
                    std       4,s
                    bra       f45@
e45@                clra
                    clrb
                    stb       <rfr_scr
                    ldd       4,s
                    pshs      a,b
                    ldd       <$2A,s
                    pshs      a,b
                    lbsr      addclone
                    leas      4,s
                    std       8,s
                    lbeq      ac45@
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgPartAdded,pcr
                    pshs      x
                    lbsr      alert
                    leas      4,s
                    lbra      ac45@
f45@                ldd       <$37,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    std       <$39,s
g45@                ldx       <$3B,s
                    ldb       2,x
                    cmpb      #$20
                    lbne      m45@
                    ldb       <$3E,s
                    lbne      ac45@
                    ldd       4,s
                    clra
                    andb      #$01
                    beq       h45@
                    ldd       #$0008
                    bra       j45@
h45@                ldd       4,s
                    clra
                    andb      #$02
                    beq       i45@
                    ldd       #$FFF8
                    bra       j45@
i45@                clra
                    clrb
j45@                addd      <$1E,s
                    addd      #$0008
                    std       <$24,s
                    ldd       #$0001
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       <$24,s
                    pshs      a,b
                    ldd       <$2C,s
                    pshs      a,b
                    ldd       <$30,s
                    pshs      a,b
                    ldd       <$47,s
                    pshs      a,b
                    lbsr      drawnr
                    leas      14,s
                    lbsr      flush
                    bra       l45@
k45@                ldd       ,s
                    pshs      a,b
                    ldd       4,s
                    pshs      a,b
                    lbsr      abortest
                    leas      4,s
l45@                leax      ,s
                    pshs      x
                    leax      4,s
                    pshs      x
                    lbsr      mouce
                    leas      4,s
                    std       -2,s
                    bne       k45@
                    ldb       <aborted
                    lbne      aa45@
                    lbra      ag45@
m45@                clra
                    clrb
                    std       <$20,s
                    std       <$10,s
                    leax      ,s
                    pshs      x
                    leax      4,s
                    pshs      x
                    lbsr      mouce
                    leas      4,s
                    ldd       2,s
                    asra
                    rorb
                    asra
                    rorb
                    asra
                    rorb
                    asra
                    rorb
                    std       <$12,s
                    ldx       <$39,s
                    ldb       6,x
                    sex
                    std       <$14,s
                    ldb       <$3E,s
                    bne       n45@
                    ldd       <$1A,s
                    cmpd      #$0020
                    bne      s45@
n45@                ldb       <pitcarry
                    beq       o45@
                    leax      <$14,s
                    pshs      x
                    ldd       12,s
                    pshs      a,b
                    ldd       <$3B,s
                    pshs      a,b
                    lbsr      repart
                    leas      6,s
                    std       <$1A,s
                    ldd       <$37,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    std       <$39,s
o45@                ldd       <$1A,s
                    cmpd      #$0020
                    bne       s45@
                    ldd       <$1A,s
                    pshs      a,b
                    ldd       6,s
                    clra
                    andb      #$01
                    beq       p45@
                    ldd       #$0008
                    bra       r45@
p45@                ldd       6,s
                    clra
                    andb      #$02
                    beq       q45@
                    ldd       #$FFF8
                    bra       r45@
q45@                clra
                    clrb
r45@                asra
                    rorb
                    addd      #$0004
                    addd      ,s++
                    std       <$1A,s
s45@                ldd       <$1A,s
                    addd      #$000B
                    std       <$22,s
                    ldd       ,s
                    asra
                    rorb
                    asra
                    rorb
                    pshs      a,b
                    ldd       <$24,s
                    subd      ,s++
                    clra
                    andb      #$1F
                    std       <$16,s
                    ldd       <$14,s
                    subd      <$12,s
                    clra
                    andb      #$07
                    std       14,s
                    lbsr      SendCmdAC
                    lbra      z45@
t45@                ldd       ,s
                    asra
                    rorb
                    asra
                    rorb
                    addd      <$16,s
                    clra
                    andb      #$1F
                    std       <$22,s
                    ldd       2,s
                    asra
                    rorb
                    asra
                    rorb
                    asra
                    rorb
                    asra
                    rorb
                    std       <$12,s
                    ldd       <$22,s
                    cmpd      <$20,s
                    bne       u45@
                    ldd       <$12,s
                    cmpd      <$10,s
                    lbeq      z45@
u45@                ldd       <$12,s
                    std       <$10,s
                    ldd       <$22,s
                    std       <$20,s
                    ldd       ,s
                    pshs      a,b
                    ldd       4,s
                    pshs      a,b
                    lbsr      abortest
                    leas      4,s
                    ldb       <aborted
                    lbne      z45@
                    ldd       14,s
                    addd      <$12,s
                    clra
                    andb      #$07
                    pshs      a,b
                    lbsr      pmodfix
                    leas      2,s
                    ldx       <$3B,s
                    stb       3,x
                    lbsr      SendCmdAD
                    ldd       <$22,s
                    addd      #$FFF5
                    std       <$18,s
                    ldd       4,s
                    clra
                    andb      #$01
                    bne       x45@
                    ldd       4,s
                    clra
                    andb      #$02
                    beq       w45@
v45@                ldd       #$0001
                    bra       y45@
w45@                ldd       <$18,s
                    cmpd      #$0004
                    bgt       v45@
x45@                clra
                    clrb
y45@                stb       <$2A,s
                    ldd       <$1E,s
                    addd      <$18,s
                    addd      <$18,s
                    std       <$24,s
                    ldd       #$0001
                    pshs      a,b
                    ldd       6,s
                    clra
                    andb      #$04
                    pshs      a,b
                    ldb       <$2E,s
                    sex
                    pshs      a,b
                    ldd       <$24,s
                    pshs      a,b
                    ldd       <$2C,s
                    pshs      a,b
                    ldd       <$30,s
                    pshs      a,b
                    ldd       <$47,s
                    pshs      a,b
                    lbsr      drawnr
                    leas      14,s
                    lbsr      flush
z45@                leax      ,s
                    pshs      x
                    leax      4,s
                    pshs      x
                    lbsr      mouce
                    leas      4,s
                    std       -2,s
                    lbne      t45@
                    ldb       <aborted
                    beq       ab45@
aa45@               clra
                    clrb
                    pshs      a,b
                    lbsr      SendFlagB0
                    leas      2,s
                    bra       ac45@
ab45@               ldd       <$22,s
                    addd      #$FFF5
                    ldx       <$3B,s
                    stb       2,x
                    ldd       #$0001
                    stb       <rfr_rep
                    ldb       <$3E,s
                    lbeq      ag45@
                    ldx       <$3B,s
                    ldb       2,x
                    sex
                    pshs      a,b
                    ldd       10,s
                    pshs      a,b
                    ldd       <$3B,s
                    pshs      a,b
                    lbsr      fulltime
                    leas      2,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    lbsr      enter
                    leas      8,s
                    std       <$37,s
                    bge       ad45@
ac45@               clra
                    clrb
                    lbra      ah45@
ad45@               ldd       <$3B,s
                    pshs      a,b
                    ldd       <$39,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    addd      #$0003
                    pshs      a,b
                    lbsr      CopyNoteAttrs
                    leas      4,s
                    ldd       <$37,s
                    subd      <xyoff
                    std       <$1C,s
                    ldd       <ritind
                    subd      <xyoff
                    bra       af45@
ae45@               ldd       <$16,s
                    addd      #$0001
                    ldx       #grafxes
                    leax      d,x
                    pshs      x
                    ldd       <$18,s
                    ldx       #grafxes
                    leax      d,x
                    ldb       ,x
                    stb       [,s++]
                    ldd       <$16,s
                    addd      #$0001
                    ldx       #grafyes
                    leax      d,x
                    pshs      x
                    ldd       <$18,s
                    ldx       #grafyes
                    leax      d,x
                    ldb       ,x
                    stb       [,s++]
                    ldd       <$16,s
                    addd      #$FFFF
af45@               std       <$16,s
                    ldd       <$16,s
                    cmpd      <$1C,s
                    bge       ae45@
                    ldd       <ritind
                    addd      #$0001
                    std       <ritind
                    ldd       <$1C,s
                    ldx       #grafxes
                    leax      d,x
                    ldd       <$26,s
                    stb       ,x
                    clra
                    clrb
                    stb       <rfr_scr
ag45@               ldd       <$1C,s
                    ldx       #grafyes
                    leax      d,x
                    ldd       <$24,s
                    stb       ,x
                    ldd       #$0001
ah45@               leas      <$33,s
                    puls      u,pc
* msgOutOfClones (was L5116): 'Out of Clone parts; Add another?'
msgOutOfClones      fcc       /No Clone parts left. Add one?/
                    fcb       $00
* msgOutOfParts (was L5137): 'Sorry, out of Parts!'
msgOutOfParts       fcc       /Sorry, out of Parts!/
                    fcb       $00
* msgPartAdded (was L514C): 'Part added.  Now try it.'
msgPartAdded        fcc       /Part added./
                    fcb       $00
* text (was L5165): printf(<$16,$83): sent by staffinit and before the 'Can't relink'/'Hit BREAK' text
text           pshs      u
                    ldd       #$0083
                    pshs      a,b
                    ldd       <pctn1
                    pshs      a,b
                    lbsr      Printf
                    lbra      SendMarkPacketRet
* pal (was L5182): printf(<$0C, $87, slot&$0F, rgb&$3F) + fflush: palette color command used by rgbmen
pal            pshs      u
                    ldb       7,s
                    clra
                    andb      #$3F
                    pshs      a,b
                    ldb       7,s
                    clra
                    andb      #$0F
                    pshs      a,b
                    ldd       #$0087
                    pshs      a,b
                    ldd       <UmeData_reserved_000C
                    pshs      a,b
                    lbsr      Printf
                    leas      8,s
                    ldx       #$01BE
                    pshs      x
                    lbsr      FFlush
                    bra      a46@
a46@                leas      2,s
                    puls      u,pc
* SendStaffDef (was L51FC): printf(<$0E, $88, a, b, c) per staff
SendStaffDef        pshs      u
                    ldd       8,s
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    ldd       #$0088
                    pshs      a,b
                    ldd       <UmeData_reserved_000E
                    pshs      a,b
                    lbsr      Printf
                    lbra      FranSend5Ret
* SendCmd89 (was L5219): printf(<$0A,$89,n): sent with 0 by newscore once the part/staff counters are cleared
SendCmd89           pshs      u
                    ldd       4,s
                    pshs      a,b
                    ldd       #$0089
                    bra       SendCmd8xTail
* SendPartDef (was L5224): printf(<$14, $8A, six values) per part from dfalprts
SendPartDef         pshs      u
                    ldd       14,s
                    pshs      a,b
                    ldb       15,s
                    sex
                    pshs      a,b
                    ldb       15,s
                    sex
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    ldd       #$008A
                    pshs      a,b
                    ldd       <pct7
                    pshs      a,b
                    lbsr      Printf
                    leas      <$10,s
                    puls      u,pc
* SendCmd8B (was L5251): printf(<$0A,$8B,n): sent with 1 by newscore just before SendCmd89
SendCmd8B           pshs      u
                    ldd       4,s
                    pshs      a,b
                    ldd       #$008B
* SendCmd8xTail (was L525A): shared tail of SendCmd89/SendCmd8B: pushes the <$0A format, Printf, leas 6,s, puls u,pc
SendCmd8xTail       pshs      a,b
                    ldd       <UmeData_reserved_000A
                    pshs      a,b
                    lbsr      Printf
                    leas      6,s
                    puls      u,pc
* SendMarkPacket(kind, a, b, c, d): kind 2/4 -> 6-byte $BC packet (last byte 0/1), kind 3 -> 5-byte $B8
* packet ($CB when A = $73: the menu hover); built at $0095, nfwrite then flush. Other kinds send nothing.
SendMarkPacket      pshs      a,b,x,u
                    ldd       #$0001
                    std       ,s
                    ldd       12,s
                    bge       a47@
                    clra
                    clrb
                    std       12,s
a47@                ldd       <$10,s
                    bge       b47@
                    clra
                    clrb
                    std       <$10,s
b47@                ldd       10,s
                    stb       <arg1
                    ldd       12,s
                    stb       <arg2
                    ldd       14,s
                    stb       <arg3
                    ldd       <$10,s
                    stb       <arg4
                    ldx       8,s
                    bra       g47@
c47@                clra
                    clrb
                    std       ,s
d47@                ldd       #$00BC
                    stb       <arg0
                    ldd       ,s
                    stb       <arg5
                    ldd       #$0006
                    bra       f47@
e47@                eora      #$B8                $00 -> $B8; hover's $73 -> $CB
                    tfr       a,b
                    stb       <arg0
                    ldd       #$0005
f47@                std       2,s
                    bra       h47@
g47@                tfr       x,d                 B is the kind; A is zero normally, $73 for menu hover
                    cmpb      #$0002
                    beq       c47@
                    cmpb      #$0004
                    beq       d47@
                    cmpb      #$0003
                    beq       e47@
                    bra       SendMarkPacketRet
h47@                ldd       2,s
                    pshs      a,b
                    lbsr      nfwrite
                    leas      2,s
                    lbsr      flush
* SendMarkPacketRet (was L52F3): shared 'leas 4,s; puls u,pc' exit of SendMarkPacket (bad-kind arm) and of text
SendMarkPacketRet   leas      4,s
                    puls      u,pc
* SendMark2Packet (was L52F7): Calls SendMarkPacket(2,0,x,$4F,y); lbsr'd once from MainInit with (0,$BF) after newscore
SendMark2Packet     pshs      u
                    ldd       6,s
                    pshs      a,b
                    ldd       #$004F
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0002
                    pshs      a,b
                    lbsr      SendMarkPacket
* FranSend5Ret (was L5312): Shared tail dropping the 5 pushed words: SendStaffDef lbra's here, SendMark2Packet falls in
FranSend5Ret        leas      10,s
                    puls      u,pc
* SendCmd9C (was L5316): Builds the 5-byte $9C packet (x,y,z,<halfstaf)+flush; lbsr'd from the MainLoop drag handler
SendCmd9C           pshs      u
                    ldd       4,s
                    bge       i47@
                    clra
                    clrb
                    std       4,s
i47@                ldd       #$009C
                    stb       <arg0
                    ldd       4,s
                    stb       <arg1
                    ldb       7,s
                    stb       <arg2
                    ldd       8,s
                    stb       <arg3
                    ldb       <halfstaf
                    stb       <arg4
                    ldd       #$0005
                    pshs      a,b
                    lbsr      nfwrite
                    leas      2,s
j47@                lbsr      flush
                    puls      u,pc
* dump (was L5344): 'Printer Ready?' then printset if <printype unset and printf('%c%c\r', $CE, port)
dump       pshs      u
                    leas      -1,s
                    leax      >msgPrinterReady,pcr
                    pshs      x
                    lbsr      yesno
                    std       ,s++
                    beq       b48@
                    ldb       <printype
                    bne       a48@
                    lbsr      printset
                    lbsr      wkill
                    ldb       <printype
                    beq       b48@
a48@                ldb       <printype
                    sex
                    pshs      a,b
                    ldd       #$00CE
                    pshs      a,b
                    leax      >fmtPrintToPort,pcr
                    pshs      x
                    lbsr      Printf
                    leas      6,s
b48@                leas      1,s
                    puls      u,pc
* msgPrinterReady (was L53A1): 'Printer Ready?'
msgPrinterReady     fcc       /Printer Ready?/
                    fcb       $00
* fmtPrintToPort (was L53B0): '%c%c\r' used with $CE and the printer port
fmtPrintToPort      fcc       /%c%c/
                    fcb       $0D,$00
                    fcc       /%c%c%c%c%s/
                    fcb       $0D,$00
* owrite (was L53C2): fwrite(buf,1,n,stdout) wrapper; vector $0361
owrite               pshs      u
                    ldx       #$01BE
                    pshs      x
                    ldd       8,s
                    pshs      a,b
                    ldd       #$0001
                    bra       smfwrit_1
* nfwrite (was L53D2): fwrite($0095, 1, n, stdout): sends the binary command packet built at <arg0.. to s9gui; vector $0365
nfwrite          pshs      u
                    ldx       #$01BE
                    pshs      x
                    ldd       6,s
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldx       #$0095
                    pshs      x
                    bra       CallFWriteRet
* putmidi (was L53E9): putc(c, <fmidi MIDI FILE*); vector $037F
putmidi               pshs      u
                    ldd       <fmidi
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    lbsr      FPutc
                    lbra      L5524
smfwrit               pshs      u
                    ldd       <fmidi
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       10,s
smfwrit_1               pshs      a,b
                    ldd       10,s
                    pshs      a,b
* CallFWriteRet (was L540C): Shared FWrite call + 8-byte arg drop; nfwrite branches here, smfwrit falls in
CallFWriteRet       lbsr      FWrite
                    leas      8,s
                    puls      u,pc
* mflush (was L5413): fflush(<fmidi); vector $0381
mflush               pshs      u
                    ldd       <fmidi
                    pshs      a,b
                    lbsr      FFlush
                    leas      2,s
                    puls      u,pc
* AuditionPlacedNote(idx): plays the placed note alone, after the press is released. s9c 'a' builds
* a temporary score holding the note (meter, tempo and key in force at its bar, a bar line, the note
* at time 0, a closing bar at its end) in a fresh event page and swaps it in as page 1 with its own
* event count; s9p plays it like PLAY (0..count-1); s9c 'z' puts the real score back.
AuditionPlacedNote  pshs      d,x,y,u
                    lbsr      waitmouse
                    ldd       10,s                the placed note's index
                    pshs      d
                    ldd       #'a
                    pshs      d
                    ldd       #'C
                    pshs      d
                    lbsr      soowee              s9c 'a': D = the temporary score's event count, 0 = nothing to play
                    leas      6,s
                    subd      #1                  last = count - 1
                    blt       apnDone@            a rest, an inclusion or no memory: the real score is untouched
                    pshs      d                   last
                    clra
                    clrb
                    pshs      d                   first = 0
                    ldd       #'a
                    pshs      d
                    ldd       #'P
                    pshs      d
                    lbsr      soowee              the score player: no SAM reset, speed keys ignored
                    leas      8,s
                    ldd       #'z
                    pshs      d
                    ldd       #'C
                    pshs      d
                    lbsr      soowee              s9c 'z': the real score is page 1 again, the temporary page freed
                    leas      4,s
* The sheet is then redrawn without its cls, unless a full redraw is already asked for (the placed
* duration changed the bar's spacing, or a key ended the audition and moved the view).
                    ldb       <rfr_scr
                    bne       apnDone@
                    ldb       #RfrScrKeep
                    stb       <rfr_scr            draw the sheet over what is there (s9s 'n')
apnDone@            puls      d,x,y,u,pc

* Interrupt-captured DIN service. No user-mode hardware RX polling. Never link an overlay from a mouse/key/player callback:
* the caller's overlay and its piano-queue vector must remain mapped.
* Forward only complete packets; running status is expanded on output.
MidiInputService        pshs      cc,d,x,y,u
                    lbsr      MidiReadIRQ
                    lbcs      MidiEchoDone
                    lda       <UmeData_smf
                    pshs      a
                    clr       <UmeData_smf
                    ldu       #64
                    bra       rxByte@
rxLoop@             lbsr      MidiReadIRQ
                    lbcs      rxDone@
rxByte@             equ       *
                    cmpb      #$F8
                    bhs       rxSingle@
                    cmpb      #$F7
                    beq       rxEndSys@
                    tstb
                    bpl       rxData@
                    stb       >MidiRxStatus
                    stb       >MidiRxBuffer
                    clr       >MidiRxDrop
                    lda       #1
                    sta       >MidiRxCount
                    lda       #3
                    cmpb      #$F0
                    blo       rxChannel@
                    beq       rxSysStart@
                    cmpb      #$F2
                    beq       rxSetNeed@
                    cmpb      #$F1
                    beq       rxTwo@
                    cmpb      #$F3
                    beq       rxTwo@
                    clr       >MidiRxStatus
                    cmpb      #$F6
                    bne       rxNext@
rxSingle@           lbsr      EchoByte
                    bra       rxNext@
rxChannel@          andb      #$E0
                    cmpb      #$C0
                    bne       rxSetNeed@
rxTwo@              lda       #2
                    bra       rxSetNeed@
rxSysStart@         clra
rxSetNeed@          sta       >MidiRxNeed
                    bra       rxNext@
rxEndSys@           lda       >MidiRxStatus
                    cmpa      #$F0
                    bne       rxNext@
                    bsr       EchoAppend
                    tst       >MidiRxDrop
                    bne       rxClear@
                    bsr       EchoPacket
rxClear@            clr       >MidiRxStatus
                    bra       rxNext@
rxData@             tst       >MidiRxStatus
                    beq       rxNext@
                    bsr       EchoAppend
                    tst       >MidiRxNeed
                    beq       rxNext@
                    lda       >MidiRxCount
                    cmpa      >MidiRxNeed
                    bne       rxNext@
                    bsr       EchoPacket
                    lda       #1
                    sta       >MidiRxCount
                    lda       >MidiRxStatus
                    cmpa      #$F0
                    bhs       rxClear@
rxNext@             leau      -1,u
                    cmpu      #0                  LEAU does not set Z: enforce the receive budget
                    lbne      rxLoop@
rxDone@             puls      a
                    sta       <UmeData_smf
MidiEchoDone        puls      cc,d,x,y,u,pc
* Read ONLY the IRQ driver's queue. Preserves the caller's X/Y/U and returns B, C.
MidiReadIRQ         pshs      a,x,y
                    lda       >MidiInPath
                    beq       mrnone@
                    deca
                    ldb       #SS.MidiRead
                    os9       I$GetStt
                    puls      a,x,y,pc
mrnone@             orcc      #Carry
                    puls      a,x,y,pc
EchoAppend          lda       >MidiRxCount
                    cmpa      #64
                    bhs       rxOverflow@
                    ldx       #MidiRxBuffer
                    stb       a,x                 A is bounded to 0..63; keep B as the MIDI byte
                    inc       >MidiRxCount
                    rts
rxOverflow@         inc       >MidiRxDrop
                    rts
EchoPacket          pshs      x,y,u
                    ldx       #MidiRxBuffer
                    ldb       >MidiRxCount
                    clra
                    tfr       d,y
rxSend@             ldb       ,x+
                    bsr       EchoByte
                    leay      -1,y
                    bne       rxSend@
                    tst       >MidiPlaying
                    beq       rxPacketDone@
                    clr       <UmeData_runstat
                    clr       <UmeData_reserved_00CE                  next player message needs its status again
rxPacketDone@       puls      x,y,u,pc
EchoByte            pshs      d                   STACK ARGUMENT: pMidiSend reads only the low byte
                    jsr       [>pMidiSend]
                    leas      2,s
                    rts


* MidiDefaults: parts 1-16 on, channels 1-16 on, every part to channel 1 (table value 0). newscore
* calls it; a load or an import gets the same reset in s9d (MidiDefaults9d) once the file has
* opened, so a cancelled pick changes nothing. Keeps every register.
MidiDefaults        pshs      d,x
                    ldx       #MidiPartOn+1
                    ldd       #$1001              A = 16 entries, B = on
mdf1@               stb       ,x+
                    deca
                    bne       mdf1@
                    ldx       #MidiChanOn
                    lda       #16
mdf2@               stb       ,x+
                    deca
                    bne       mdf2@
                    ldx       #MidiChanTbl+1
                    lda       #16
mdf3@               clr       ,x+
                    deca
                    bne       mdf3@
                    puls      d,x,pc
* Live MIDI fanout; device prompts and validation live in s9r.
MidiInitRoutes      pshs      d,x,y,u
                    leax      MidiSendSelected,pcr
                    stx       >pMidiSend
                    leax      MidiSynthSend,pcr   SAM2695, plus VS1053 when Vs1053Out
                    stx       >pSAMSend
                    leax      MidiInputService,pcr
                    stx       >pMidiEcho
                    ldd       #'i
                    pshs      d                   STACK ARGUMENT: initialize output routes
                    ldd       #'R
                    pshs      d                   STACK ARGUMENT: MIDI device overlay, startup only
                    lbsr      soowee
                    leas      4,s
                    puls      d,x,y,u,pc

* C word argument at 2,s. Every selected destination receives the same byte.
MidiSendSelected    pshs      d,x,y,u
                    tst       <smf
                    bne       mssDone@
                    ldu       #MidiRoutePaths
mssNext@            lda       ,u+
                    cmpa      #MidiUnusedPath
                    beq       mssAdvance@
                    cmpa      #MidiWildbitsPath
                    bne       mssPath@
                    ldb       11,s
                    lbsr      MidiSynthSend       SAM2695, plus VS1053 when Vs1053Out
                    bra       mssAdvance@
mssPath@            tst       >MidiSelected
                    beq       mssAdvance@
                    leax      11,s
                    ldy       #1
                    os9       I$Write
                    bcc       mssAdvance@
                    lda       -1,u
                    os9       I$Close
                    lda       #MidiUnusedPath
                    sta       -1,u
mssAdvance@         cmpu      #MidiRoutePaths+MidiRouteCount
                    blo       mssNext@
mssDone@            puls      d,x,y,u,pc

* B = MIDI byte. The physical MIDI OUT is always active; the SAM2695 checkbox
* controls whether that stream is audible through the onboard analog mix.
MidiSynthSend       bsr       MidiSAMSend
                    tst       >Vs1053Out
                    beq       msyDone@
                    bra       MidiVSSend
msyDone@            rts
* MidiVSSend: B = MIDI byte into the VS1053 bridge's SDI FIFO. VLSI's real-time MIDI synth reads SDI
* as zero-padded pairs: $00 then the MIDI byte. VS_* are offsets, so absolute operands must include
* VS1053.Base.
MidiVSSend          pshs      d
mvsWait1@           lda       >VS1053.Base+VS_FIFOSTAT
                    bita      #VS_FIFO_FULL
                    bne       mvsWait1@
                    clra
                    sta       >VS1053.Base+VS_FIFO            the pad byte
mvsWait2@           lda       >VS1053.Base+VS_FIFOSTAT
                    bita      #VS_FIFO_FULL
                    bne       mvsWait2@
                    stb       >VS1053.Base+VS_FIFO            the MIDI byte
                    puls      d,pc
* MidiSAMSend: B = MIDI byte, written through the /mi device (MIDrv Write -> the MIDI UART's TX FIFO:
* DIN MIDI OUT and the SAM2695); no /mi path open = nothing sent. Y is the C static base: saved.
MidiSAMSend         pshs      d,x,y
                    lda       >MidiInPath
                    beq       mssNone@
                    deca
                    leax      1,s                 the byte (B as pushed)
                    ldy       #1
                    os9       I$Write
mssNone@            puls      d,x,y,pc

* play (was L5420): 'New .MID file: ' or /MIDI device, fopen 'w', then overlay s9p 'p' writes the MIDI stream, FClose
play    pshs      u
                    clr       <mididev             live paths bypass the C file writer
                    leas      <-$22,s
                    clra
                    clrb
                    pshs      a,b
                    lbsr      automouse
                    leas      2,s
                    ldb       <mididev
                    bne       a49@
                    ldb       <smf
                    lbeq      f49@
a49@                ldb       <smf
                    bne       b49@
                    leax      >pathMidiDev,pcr
                    pshs      x
                    leax      2,s
                    pshs      x
                    lbsr      StrCopy
                    bra       c49@
b49@                clra
                    clrb
                    pshs      a,b
                    lbsr      dialogue
                    leas      2,s
                    leax      >msgNewMidFile,pcr
                    pshs      x
                    lbsr      Printf
                    leas      2,s
                    leax      ,s
                    pshs      x
                    lbsr      gets
                    leas      2,s
                    lbsr      wkill
                    ldb       ,s
                    lbeq      h49@
                    clra
                    clrb
                    stb       <$19,s
                    leax      >strMidExt,pcr
                    pshs      x
                    leax      2,s
                    pshs      x
                    lbsr      StrCat
c49@                leas      4,s
                    leax      >strModeWrite,pcr
                    pshs      x
                    leax      2,s
                    pshs      x
                    lbsr      FOpen
                    leas      4,s
                    std       <fmidi
                    beq       d49@
                    ldx       <fmidi
                    ldd       6,x
                    orb       #$80
                    std       6,x
                    bra       e49@
d49@                clra
                    clrb
                    pshs      a,b
                    leax      >msgCantOpenMidi,pcr
                    pshs      x
                    lbsr      alert
                    leas      4,s
                    ldb       <smf
                    bne      a49@
                    bra       h49@
e49@                lbsr      timesig
                    std       -2,s
                    bne       f49@
                    ldd       #$0004
                    std       <UmeData_reserved_0005
                    std       <UmeData_reserved_0003
                    lbsr      timesig
f49@                ldd       <$28,s
                    pshs      a,b
                    ldd       <$28,s
                    pshs      a,b
                    ldd       #$0070
                    pshs      a,b
                    ldd       #$0050
                    pshs      a,b
                    lbsr      soowee
                    leas      8,s
                    ldb       <mididev
                    bne       g49@
                    ldb       <smf
                    beq       h49@
g49@                ldd       <fmidi
                    pshs      a,b
                    lbsr      FClose
                    leas      2,s
h49@                leas      <$22,s
                    puls      u,pc
* bell (was L54F9): vector $0377. Silent: the original BeepTone toggled the CoCo DAC at $FF20 with
* interrupts masked, and on WildBits $FF20-$FF23 are the WizFi controller ($FF01/$FF03 the SD card
* controller), so the tone code is not assembled.
bell                rts                           nothing pushed yet, so a plain rts

* waitmouse (was L5505): loops mouce (sleep 4) until no button is pressed
waitmouse        pshs      a,b,x,u
                    bra       b51@
a51@                ldd       #$0004
                    pshs      a,b
                    lbsr      TSleep
                    leas      2,s
b51@                leax      ,s
                    pshs      x
                    leax      4,s
                    pshs      x
                    lbsr      mouce
                    leas      4,s
                    std       -2,s
                    bne       a51@
* L5524 (original offset $5524): waitmouse's 'leas 4,s / puls u,pc' epilogue, which putmidi jumps to
* after its FPutc.
L5524               equ       *
                    leas      4,s
                    puls      u,pc
* kmouse (was L5528): returns -1 on mouse button, the key if one is ready (testkey/ReadPath), else 0
kmouse      pshs      u
                    leas      -1,s
                    clra
                    clrb
                    stb       ,s
                    ldd       7,s
                    pshs      a,b
                    ldd       7,s
                    pshs      a,b
                    lbsr      mouce
                    leas      4,s
                    std       -2,s
                    beq       a52@
                    ldd       #$FFFF
                    bra       c52@
a52@                lbsr      testkey
                    std       -2,s
                    beq       b52@
                    ldd       #$0001
                    pshs      a,b
                    leax      2,s
                    pshs      x
                    clra
                    clrb
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
b52@                ldb       ,s
                    sex
c52@                leas      1,s
                    puls      u,pc
* keymouse (was L5566): waits for a key or click, tracking the pointer (DrawPointer) and returning key or 0 with x/y; vector $0355
keymouse      pshs      u
                    lbsr      flush         flush (it ends with a CR) before waiting for input
                    leas      -7,s
                    clra
                    clrb
                    std       3,s
                    std       5,s
                    bsr      waitmouse
                    ldd       3,s
                    pshs      a,b
                    ldd       7,s
                    pshs      a,b
                    lbsr      DrawPointer
                    leas      4,s
a53@                ldd       13,s
                    pshs      a,b
                    ldd       13,s
                    pshs      a,b
                    bsr      kmouse
                    leas      4,s
                    std       1,s
                    beq       d53@
                    ldd       1,s
                    bge       b53@
                    clra
                    clrb
                    bra       c53@
b53@                ldd       1,s
c53@                stb       ,s
                    bra       g53@
d53@                ldd       [<$0B,s]
                    cmpd      5,s
                    bne       e53@
                    ldd       [<$0D,s]
                    cmpd      3,s
                    beq       f53@
e53@                ldd       3,s
                    pshs      a,b
                    ldd       7,s
                    pshs      a,b
                    lbsr      DrawPointer
                    leas      4,s
                    ldd       [<$0D,s]
                    std       3,s
                    pshs      a,b
                    ldd       [<$0D,s]
                    std       7,s
                    pshs      a,b
                    lbsr      DrawPointer
                    leas      4,s
                    ldd       5,s                 the pointer's x (3,s is its row)
                    ldx       3,s
                    lbsr      LayHover            the score editor's menu: highlight the row under the pointer
                    bra       a53@
f53@                ldd       #$0002
                    pshs      a,b
                    lbsr      TSleep
                    leas      2,s
                    bra      a53@
g53@                lbsr      LayHoverOff         the highlighted row back to normal before the caller acts
                    ldd       3,s
                    pshs      a,b
                    ldd       7,s
                    pshs      a,b
                    lbsr      DrawPointer
                    leas      4,s
                    ldb       ,s
                    lbra      ErrorBoxRet
* LayHover: D = pointer x (dots), X = its canvas row. When s9l has <LayHov on ($FF or a row + 1), the
* score editor's menu row under the pointer (columns MenuBarLeft..MenuBarRight, MenuRows rows
* MenuRowPitch apart from MenuRowY0) is inverted through SendMarkPacket kind 3, as the menu-bar hover
* is, and the row inverted before is put back. Keeps every register.
LayHover            pshs      d,x,y,u
                    tst       <LayHov
                    beq       lh9@
                    ldy       #$00FF              none
                    cmpd      #MenuBarLeft*8      the bar's first dot
                    blo       lh2@
                    cmpd      #(MenuBarRight+1)*8 the first dot past the bar
                    bhs       lh2@
                    cmpx      #MenuRowY0-(MenuRows-1)*MenuRowPitch-2   the last row's bottom
                    blo       lh2@
                    cmpx      #MenuRowY0+5        past the first row's top
                    bhs       lh2@
                    ldd       #MenuRowY0+4
                    pshs      x
                    subd      ,s++                MenuRowY0+4 - y
                    ldy       #0
lh1@                subd      #7
                    bmi       lh1a@
                    leay      1,y
                    bra       lh1@
lh1a@               leay      1,y                 the row + 1
lh2@                tfr       y,d
                    cmpb      <LayHov
                    beq       lh9@                the same row as before
                    ldb       <LayHov
                    cmpb      #$FF
                    beq       lh3@
                    decb
                    bsr       LayInvertRow        the old row back
lh3@                tfr       y,d
                    stb       <LayHov
                    cmpb      #$FF
                    beq       lh9@
                    decb
                    bsr       LayInvertRow        the new row
lh9@                puls      d,x,y,u,pc
* LayHoverOff: the highlighted row back to normal, the hover left on with no row
LayHoverOff         pshs      d,x,y,u
                    ldb       <LayHov
                    beq       lho9@
                    cmpb      #$FF
                    beq       lho9@
                    decb
                    bsr       LayInvertRow
                    ldb       #$FF
                    stb       <LayHov
lho9@               puls      d,x,y,u,pc
* LayInvertRow: B = the row (0..13): SendMarkPacket(3, MenuBarLeft, y - 1, MenuBarRight, y + 5) with y = MenuRowY0 - 7 * row, then flush
LayInvertRow        pshs      d,x,y,u
                    clra
                    pshs      d
                    lda       #7
                    mul                           D = 7 * row
                    pshs      d
                    ldd       #MenuRowY0
                    subd      ,s++
                    leas      2,s                 D = y
                    pshs      d                   ,s y
                    addd      #5
                    pshs      d                   y + 5
                    ldd       #MenuBarRight
                    pshs      d
                    ldd       4,s
                    subd      #1
                    pshs      d                   y - 1
                    ldd       #MenuBarLeft
                    pshs      d
                    ldd       #3                  invert
                    pshs      d
                    lbsr      SendMarkPacket
                    leas      12,s
                    lbsr      flush
                    puls      d,x,y,u,pc
* yesno (was L55F0): prompt box ($C9) with 'y'/'n' keys or clicks in the yes/no areas; returns 1 for yes; vector $03A1
yesno               pshs      u
                    clra
                    clrb
                    pshs      a,b                 black: no (the paper box)
                    ldd       #$004B
                    pshs      a,b                 y
                    ldd       #$0015
                    pshs      a,b                 column
                    ldd       10,s                the message
                    pshs      a,b
                    lbsr      yesnoAt
                    leas      8,s                 (leas and puls keep yesnoAt's flags: callers test them)
                    puls      u,pc
* yesnoAt(message, column, y, black): yesno at a text column and y; black non-zero = the black 3D box
* (s9gui's $C9 gets the column | $80). yesno is this at column $15, y $4B, paper.
yesnoAt             pshs      u
                    leas      -14,s
                    clra
                    clrb
                    pshs      a,b
                    lbsr      automouse
                    leas      2,s
                    ldd       <$14,s              the column
                    std       4,s
                    ldd       <$16,s              y
                    std       2,s
                    ldd       <$12,s              the message
                    pshs      a,b
                    ldd       4,s
                    pshs      a,b
                    ldd       8,s
                    tst       <$1D,s              black?
                    beq       yna1@
                    orb       #$80                the black 3D box
yna1@               pshs      a,b
                    ldd       #$00C9
                    pshs      a,b
                    leax      >fmtPromptBox,pcr
                    pshs      x
                    lbsr      Printf
                    leas      10,s
                    ldd       4,s                 12,s: the NO areas' base (the column; the black box: further left)
                    std       12,s
                    tst       <$19,s              the black box: its YES and NO sit further left (s9gui)
                    beq       yna2@
                    ldd       4,s
                    subd      #YesNoBlackYesHitDX
                    std       4,s                 the YES area follows
                    ldd       12,s
                    subd      #YesNoBlackNoDX
                    std       12,s                and the NO area
yna2@               lbsr      flush
                    lbsr      bell
                    ldd       >curcurse
                    std       6,s
                    ldd       #$0002
                    pshs      a,b
                    lbsr      curset
                    leas      2,s
a54@                leax      8,s
                    pshs      x
                    leax      12,s
                    pshs      x
                    lbsr      keymouse
                    leas      4,s
                    stb       ,s
                    lbne      d54@
* The black Exit box: a click outside it is NO, as outside any menu.
                    tst       <$19,s
                    beq       yni@
                    ldd       10,s                pointer x (dots)
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb                          its column
                    cmpd      <$14,s
                    blt       yno@                left of the box
                    subd      #YesNoBlackW+1
                    cmpd      <$14,s
                    bgt       yno@                right of it and its shadow
                    ldd       8,s                 pointer y
                    subd      <$16,s
                    cmpd      #6
                    bgt       yno@                above it
                    cmpd      #-(4*TextLineH+8)
                    bge       yni@                not below it: test the YES and NO areas
yno@                ldd       #$006E
                    bra       c54@
yni@                ldd       2,s
                    addd      #$FFED
                    cmpd      8,s
                    blt       d54@
                    ldd       2,s
                    addd      #$FFE3
                    cmpd      8,s
                    bgt       d54@
                    ldd       10,s
                    pshs      a,b
                    ldd       #$0003
                    lbsr      ShiftRightArith
                    std       10,s
                    ldd       4,s
                    addd      #$0007
                    cmpd      10,s
                    bgt       b54@
                    ldd       4,s
                    addd      #$0010
                    cmpd      10,s
                    blt       b54@
                    ldd       #$0079
                    bra       c54@
b54@                ldd       12,s                the NO area's base
                    addd      #$0014
                    cmpd      10,s
                    bgt       d54@
                    ldd       12,s
                    addd      #$001D
                    cmpd      10,s
                    blt       d54@
                    ldd       #$006E
c54@                stb       ,s
d54@                ldb       ,s
                    cmpb      #$6E
                    bne       e54@
                    clra
                    clrb
                    bra       f54@
e54@                ldb       ,s
                    cmpb      #$79
                    bne       g54@
                    ldd       #$0001
f54@                stb       1,s
                    bra       h54@
g54@                ldb       ,s
                    cmpb      #$05
                    lbeq      a54@
                    lbsr      bell
                    lbra      a54@
h54@                lbsr      wkill
                    ldd       6,s
                    pshs      a,b
                    lbsr      curset
                    leas      2,s
                    lbsr      flush
                    lbsr      waitmouse
                    ldb       1,s
                    leas      14,s                the answer in B (its flags kept)
                    puls      u,pc
* alert (was L56D8): opens a text box, prints msg plus n extra ' %d'/' %u' values, hitenter; vector $037B
alert            pshs      u
                    leas      -7,s
                    ldd       #$0009
                    std       3,s
                    ldd       #$009B
                    std       1,s
                    ldd       #WinStylePaper3D    the paper 3D box
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0004
                    pshs      a,b
                    ldd       #$003C
                    pshs      a,b
                    ldd       9,s
                    pshs      a,b
                    ldd       13,s
                    pshs      a,b
                    lbsr      wcreate
                    leas      12,s
                    ldd       11,s
                    pshs      a,b
                    lbsr      Printf
                    leas      2,s
                    ldd       >curcurse
                    std       5,s
                    ldd       #$0002
                    pshs      a,b
                    lbsr      curset
                    leas      2,s
                    ldd       13,s
                    bge       a55@
                    ldd       #$0001
                    bra       b55@
a55@                clra
                    clrb
b55@                stb       ,s
                    beq       c55@
                    ldd       13,s
                    nega
                    negb
                    sbca      #$00
                    std       13,s
c55@                ldd       13,s
                    clra
                    andb      #$07
                    std       13,s
                    leau      15,s
                    bra       g55@
d55@                ldd       ,u++
                    pshs      a,b
                    ldb       2,s
                    beq       e55@
                    leax      >fmtSpaceInt,pcr
                    bra       f55@
e55@                leax      >fmtSpaceUns,pcr
f55@                tfr       x,d
                    pshs      a,b
                    lbsr      Printf
                    leas      4,s
                    ldd       13,s
                    addd      #$FFFF
                    std       13,s
g55@                ldd       13,s
                    bgt       d55@
                    ldx       #$01BE
                    pshs      x
                    ldd       #$000D
                    pshs      a,b
                    lbsr      FPutc
                    leas      4,s
                    bsr      hitenter
                    lbsr      wkill
                    ldd       5,s
                    pshs      a,b
                    lbsr      curset
                    leas      2,s
                    ldx       #$01BE
                    pshs      x
                    lbsr      FFlush
                    leas      2,s
* ErrorBoxRet (was L578F): alert epilogue (leas 7,s; puls u,pc); keymouse lbra's here with its own 7-byte frame
ErrorBoxRet         leas      7,s
                    puls      u,pc
* dialogue (was L5793): wcreate at fixed prompt coordinates (2 or 5 lines by flag)
dialogue       pshs      u
                    ldd       #$0002
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldb       9,s
                    beq       a56@
                    ldd       #$0005
                    bra       b56@
a56@                ldd       #$0002
b56@                pshs      a,b
                    ldd       #$0032
                    pshs      a,b
                    ldd       #$006E
                    pshs      a,b
                    ldd       #$000E
                    bra       CallOpenTextBox
* monologue (was L57BC): wcreate for the 'OK, Writing: %s' status line
monologue       pshs      u
                    ldd       #WinStylePaper3D    the paper 3D box
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0004
                    pshs      a,b
                    ldd       #$0022
                    pshs      a,b
                    ldd       #$008C
                    pshs      a,b
                    ldd       #$0026
* CallOpenTextBox (was L57DA): Shared tail: pushes the last arg, calls wcreate; used by dialogue and monologue
CallOpenTextBox     pshs      a,b
                    lbsr      wcreate
                    lbra      NoteTmplRet
* hitenter (was L57E2): ' ENTER or CLICK to go on:' then waits (kmouse); vector $037D
hitenter      pshs      u
                    leas      -5,s
                    clra
                    clrb
                    pshs      a,b
                    lbsr      automouse
                    leas      2,s
                    leax      >msgHitEnter,pcr
                    pshs      x
                    lbsr      Printf
                    leas      2,s
                    ldd       #$0001
                    pshs      a,b
                    bsr       alcurset
                    leas      2,s
                    lbsr      bell
                    bsr       flush
                    lbsr      waitmouse
a57@                leax      1,s
                    pshs      x
                    leax      5,s
                    pshs      x
                    lbsr      kmouse
                    leas      4,s
                    stb       ,s
                    cmpb      #$0D
                    lbeq      PressEnterRet
                    ldb       ,s
                    sex
                    cmpd      #$FFFF
                    bne       b57@
                    lbsr      waitmouse
                    lbra      PressEnterRet
* The poll loop busy-waits about two ticks between passes instead of calling TSleep.
b57@                ldx       #$1000              about 2 ticks
bw1@                leax      -1,x
                    bne       bw1@
                    bra       a57@
* alcurset (was L583B): printf(<$18,$CC,1) before every key read (hitenter, readone, charmaus, gets)
alcurset      pshs      u
                    ldb       5,s
                    sex
                    pshs      a,b
                    ldd       #$00CC
                    lbra      SendCmdOneArg
* PollMark: $CA + CR to s9gui, then fflush: the screen is complete and input is about to be read; s9gui
* shows its hidden page on this and nothing else. Sent by the input polls inkey, testkey and mouce;
* it shares flush's body.
PollMark            pshs      u
                    ldd       #$00CA              $CA ($CE is the printer-port command)
                    bra       flushc@
* flush (was L5848): printf(<$16, $CD) + fflush(stdout): sent after every message/prompt so s9gui updates; vector $0379
flush         pshs      u
                    ldd       #$00CD
flushc@             pshs      a,b
                    ldd       <pctn1
                    pshs      a,b
                    lbsr      Printf
                    leas      4,s
* A CR follows the refresh command: the pipe's ReadLn hands s9gui a line only at a CR (or a full
* count), and a prompt without one would sit in the pipe. s9gui's $CD handler swallows the CR.
                    ldx       #$01BE              stdout, the pipe to s9gui
                    pshs      x
                    ldd       #$000D
                    pshs      a,b
                    lbsr      FPutc
                    leas      4,s
                    lbra      FlushStdoutRet
* patience (was L585B): printf(<$16,$C3)+flush at the start of a bulk edit; called by partcopy and smash
patience           pshs      u
                    ldd       #$00C3
                    pshs      a,b
                    ldd       <pctn1
                    pshs      a,b
                    lbsr      Printf
                    leas      4,s
                    lbra      RefreshAndRet
* menu (was L586E): printf(<$18, $C4, menu#) + fflush: asks s9gui to display menu n
menu            pshs      u
                    ldd       4,s
                    pshs      a,b
                    ldd       #$00C4
                    pshs      a,b
                    ldd       <pctn2
                    pshs      a,b
                    lbsr      Printf
                    leas      6,s
                    bra      FlushStdoutRet
* wcreate (was L5885): printf(<$14, $C6, x, y, w, h, a, b): opens a text box on the s9gui display
wcreate         pshs      u
                    ldd       14,s
                    pshs      a,b
                    ldb       15,s
                    sex
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    ldd       #$00C6
                    pshs      a,b
                    ldd       <pct7
                    pshs      a,b
                    lbsr      Printf
                    leas      <$10,s
                    lbra      RefreshAndRet
* wkill (was L58B2): printf(<$16, $C7): closes the current text box
wkill        pshs      u
                    ldd       #$00C7
                    lbra      SendCmdNoArg
* curset (was L58BA): stores the edit mode in >curcurse and tells s9gui ($9A, mode)
curset         pshs      u
                    ldd       4,s
                    std       >curcurse
                    ldd       4,s
                    pshs      a,b
                    ldd       #$009A
* SendCmdOneArg (was L58C8): Shared tail sending cmd+value through the <pctn2 format; curset falls in, alcurset lbra's
SendCmdOneArg       pshs      a,b
                    ldd       <pctn2
                    pshs      a,b
                    lbsr      Printf
                    leas      6,s
                    puls      u,pc
* DrawPointer: a no-op (the pointer is the hardware mouse cursor), kept for its callers.
DrawPointer         rts
* Shared fflush(stdout)+return for flush and menu.
FlushStdoutRet      ldx       #$01BE
                    pshs      x
                    lbsr      FFlush
                    leas      2,s
                    puls      u,pc
* SendViewRange (was L590C): printf(<$14, $95, <ritind last, <lftind first, <nevents count) display range
SendViewRange       pshs      u
                    ldd       <ritind
                    pshs      a,b
                    ldb       <ritind
                    sex
                    pshs      a,b
                    ldd       <lftind
                    pshs      a,b
                    ldb       <lftind
                    sex
                    pshs      a,b
                    ldd       <nevents
                    pshs      a,b
                    ldb       <nevents
                    sex
                    pshs      a,b
                    ldd       #$0095
                    pshs      a,b
                    ldd       <pct7
                    pshs      a,b
                    lbsr      Printf
                    leas      <$10,s
                    puls      u,pc
* SendCmd97 (was L593A): putc($97) to s9gui; lbsr'd from MainLoop when the <rfr_bar flag is set
SendCmd97           pshs      u
                    ldd       #-1
                    std       >MenuBarHover       the bar is drawn afresh: no hover inversion on it
                    ldx       #$01BE
                    pshs      x
                    ldd       #$0097
                    bra       a59@
* SendCmd98 (was L596F): putc($98) to s9gui; lbsr'd from MainLoop after the <rfr_scr redraw resends all staves
SendCmd98           pshs      u
                    ldx       #$01BE
                    pshs      x
                    ldd       #$0098
a59@                pshs      a,b
                    lbsr      FPutc
                    lbra      e59@
* SendDraggedTools: B=$80 captures the rendered toolbox; B=$81 moves it by rectangle copies.
* $99 retains its three arguments: Y, drag phase in flag 1, left X column in flag 2.
SendDraggedTools    pshs      u
                    clra
                    pshs      d                   STACK OFFSET: helper frame, saved phase
                    ldd       >ToolX
                    pshs      d                   STACK OFFSET: helper frame, left X column
                    ldd       2,s                 STACK OFFSET: helper frame, saved phase
                    pshs      d                   STACK OFFSET: helper frame, flag 1
                    lbsr      SendCmd99
                    leas      6,s
                    lbsr      flush
                    puls      u,pc
* SendCmd99 (was L5981): printf(<$0E,$99,>$03C8,f1,f2) status update; lbsr'd from MainLoop when <rfr_men is set
SendCmd99           pshs      u
                    ldb       7,s
                    sex
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    ldd       >UmeData_reserved_03C8
                    pshs      a,b
                    ldd       #$0099
                    pshs      a,b
                    ldd       <UmeData_reserved_000E
                    pshs      a,b
                    lbsr      Printf
                    leas      10,s
                    puls      u,pc
* SendModeInfo (was L59A1): printf(<$0E,$92,<curcurse mode,a,b), SendNoteTemplate first in modes 8/$0F/$16; MainLoop <rfr_rep path
SendModeInfo        pshs      u
                    ldd       >curcurse
                    cmpd      #$0016
                    beq       b59@
                    ldd       >curcurse
                    cmpd      #$000F
                    beq       b59@
                    ldd       >curcurse
                    cmpd      #$0008
                    bne       c59@
b59@                ldx       #brush
                    pshs      x
                    bsr       SendNoteTemplate
                    leas      2,s
c59@                ldd       6,s
                    bge       d59@
                    clra
                    clrb
                    std       6,s
d59@                ldd       >curcurse
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    ldd       #$0092
                    pshs      a,b
                    ldd       <UmeData_reserved_000E
                    pshs      a,b
                    lbsr      Printf
                    leas      10,s
* RefreshAndRet (was L59EA): Shared flush-then-return; patience and wcreate lbra here, SendModeInfo falls in
RefreshAndRet       lbsr      flush
                    puls      u,pc
* SendNoteTemplate (was L59EF): bsr'd by SendModeInfo: printf(<$10,$94,...) built from the $010B note template
SendNoteTemplate    pshs      u
                    ldd       #$0002
                    pshs      a,b
                    ldx       6,s
                    ldb       1,x
                    sex
                    pshs      a,b
                    ldb       [<$08,s]
                    sex
                    pshs      a,b
                    ldx       10,s
                    ldb       2,x
                    sex
                    pshs      a,b
                    ldd       #$0094
                    pshs      a,b
                    ldd       <UmeData_reserved_0010
                    pshs      a,b
                    lbsr      Printf
* NoteTmplRet (was L5A16): Shared 12-byte drop + return: SendNoteTemplate falls in, yesno and CallOpenTextBox lbra here
NoteTmplRet         leas      12,s
                    puls      u,pc
* SendCmd93 (was L5A1A): printf(<$16,$93); lbsr'd from MainLoop after the <$37,s delay/animation step
SendCmd93           pshs      u
                    ldd       #$0093
* SendCmdNoArg (was L5A1F): Shared tail: sends a bare cmd byte via <pctn1; wkill lbra's here, SendCmd93 falls in
SendCmdNoArg        pshs      a,b
                    ldd       <pctn1
                    pshs      a,b
                    lbsr      Printf
e59@                leas      4,s
                    puls      u,pc
* PressEnterRet (was L5A5C): hitenter's exit (leas 5,s); its CR and click tests lbeq/lbra to it
PressEnterRet       leas      5,s
                    puls      u,pc
* breaker (was L5A60): F$Icpt handler: signal 3 -> dump; others -> ' Exit this app? ', 'Save Score' via s9d 'd', QuitUnlinkAll
breaker       pshs      u
                    leas      <-$51,s
                    ldd       >UmeData_broke
                    lbeq      SignalSetPending
                    ldd       <$55,s
                    cmpd      #$0003
                    bne       a60@
                    lbsr      dump
                    lbra      SignalHandlerRet
a60@                ldd       >UmeData_broke
                    cmpd      #$0063
                    lbeq      SignalHandlerRet
                    ldd       #$0063
                    std       >UmeData_broke
                    ldd       #1
                    pshs      a,b                 the black 3D box
                    ldd       #ExitBoxY
                    pshs      a,b
                    ldd       #ExitBoxCol
                    pshs      a,b
                    leax      >msgQuitUmuse,pcr
                    pshs      x
                    lbsr      yesnoAt
                    leas      8,s
                    bne       b60@
                    ldd       <$55,s
                    std       >UmeData_broke
                    lbra      SignalHandlerRet
b60@                ldb       <readonly           Read Only mode: no Save Score prompt at quit
                    lbne      QuitUnlinkAll
                    ldx       #$0BEB
                    pshs      x
                    leax      >fmtSaveScore,pcr
                    pshs      x
                    leax      4,s
                    pshs      x
                    lbsr      SPrintf
                    leas      6,s
                    ldd       <nevents
                    cmpd      #$0002
                    ble       QuitUnlinkAll
                    leax      ,s
                    pshs      x
                    lbsr      yesno
                    leas      2,s
                    beq       QuitUnlinkAll
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0075
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldx       #$0BEB
                    pshs      x
                    ldd       #$0064
                    pshs      a,b
                    ldd       #$0044
                    pshs      a,b
                    lbsr      soowee
                    leas      14,s
* QuitUnlinkAll (was L5AF0): QuitTeardown, then exit(0)
QuitUnlinkAll       lbsr      QuitTeardown
                    clra
                    clrb
                    pshs      a,b
                    lbsr      ExitProg
* RestartChain: Misc > Restart. MainInit cannot simply run again (the module tail - data image, symbol
* banks - is consumed once at start, and s9gui keeps its state), so this runs the quit teardown and
* chains to a fresh s9: s9gui reads EOF on the command pipe and exits, the console goes back on paths
* 0-2, and F$Chain starts s9 from the top.
RestartChain        bsr       QuitTeardown
                    lda       #$02                a copy of path 2, the console s9 runs on,
                    os9       I$Dup               to put back on paths 0-2 (not /term by name: a vt's keys go to it)
                    pshs      a
                    lbsr      CloseAllFiles       paths 0-2, the command pipe on path 1 among them
                    lda       >FranReply
                    os9       I$Close
                    ldx       #MidiRoutePaths     the open MIDI device paths ($FF empty, $FE Wildbits)
rcm@                lda       ,x+
                    cmpa      #$FE
                    bhs       rcn@
                    os9       I$Close
rcn@                cmpx      #MidiRoutePaths+4
                    blo       rcm@
rcw@                os9       F$Wait              until s9gui has exited
                    bcc       rcw@
                    ldb       #3
rco@                lda       ,s                  the copy (the counter is pushed after it)
                    pshs      b
                    os9       I$Dup               the lowest free path: 0, then 1, then 2
                    puls      b
                    decb
                    bne       rco@
                    puls      a                   the copy itself goes
                    os9       I$Close
                    leax      >strS9Self,pcr
                    leau      2,x                 the parameter line: the CR
                    ldy       #1
                    ldd       #(Prgrm+Objct)*256
                    os9       F$Chain
                    os9       F$Exit              (F$Chain returns only on an error, in B)
strS9Self           fcc       /s9/
                    fcb       $0D
* QuitTeardown: the quit's teardown up to the exit - configuration flushed, windows closed, MIDI closed, overlays
* unloaded, buffers freed, path options, text screen, bitmaps and layers back as found.
QuitTeardown        ldd       #'e
                    pshs      d                   STACK ARGUMENT: flush configuration on application exit
                    ldd       #'G
                    pshs      d                   STACK ARGUMENT: configuration overlay
                    lbsr      soowee
                    leas      4,s
                    lbsr      wkill
                    lbsr      wkill
                    lbsr      CleanupStub         close MIDI/restore mix before unloading overlays
                    leax      ExitOverlayNames,pcr
qunext@             lda       ,x
                    beq       qudone@
                    pshs      x                   STACK ARGUMENT: module name; preserve cursor across unload
                    lbsr      unload
                    puls      x
quscan@             lda       ,x+
                    bne       quscan@
                    bra       qunext@
qudone@             equ       *
                    clra
                    clrb
                    pshs      a,b
                    lbsr      killem
                    leas      2,s
                    ldd       #$0022
                    pshs      a,b
                    lbsr      killpage
                    leas      2,s
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0004
                    pshs      a,b
                    lbsr      SetPathOption
                    leas      4,s
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0007
                    pshs      a,b
                    lbsr      SetPathOption
                    leas      4,s
* Text screen back (s9gui also does this when it exits cleanly); the bitmap stays allocated, see main.
                    pshs      y                   Y = the C static base, keep it
                    lda       #$02
                    ldb       #SS.DScrn
                    ldx       #FX_TXT
                    ldy       #FT_OMIT
                    os9       I$SetStt
                    puls      y
* Bitmap 0's HIRES4 off and the layers as found, through grfdrv256 (SS.BmCfg, SS.PScrn).
                    pshs      y,u
                    lda       #$02                bitmap 0: HIRES4 off, the rest left alone
                    ldb       #SS.BmCfg
                    ldx       #$FFFF
                    ldy       #$0000
                    ldu       #$00FF
                    os9       I$SetStt
lyrrestore@         ldb       >LayerSave          layer 0's source (bits 2:0) as found
                    andb      #$07
                    clra
                    tfr       d,y
                    ldx       #$0000
                    lda       #$02
                    ldb       #SS.PScrn
                    os9       I$SetStt
                    ldb       >LayerSave          layer 1's (bits 6:4)
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    andb      #$07
                    clra
                    tfr       d,y
                    ldx       #$0001
                    lda       #$02
                    ldb       #SS.PScrn
                    os9       I$SetStt
                    ldb       >LayerSave+1        layer 2's (bits 2:0 of the second byte)
                    andb      #$07
                    clra
                    tfr       d,y
                    ldx       #$0002
                    lda       #$02
                    ldb       #SS.PScrn
                    os9       I$SetStt
                    puls      y,u
                    rts
* SignalSetPending (was L5BA9): breaker's >$0076==0 path: stores the signal code in >$0076, prints CR and returns
SignalSetPending    ldd       <$55,s
                    std       >UmeData_broke
                    leax      >strCR1,pcr
                    pshs      x
                    lbsr      Printf
                    leas      2,s
* SignalHandlerRet (was L5BBA): breaker epilogue (leas $51,s); every quit/ignore path inside it lbra's here
SignalHandlerRet    leas      <$51,s
                    puls      u,pc
* pathMidiDev (was L5BBF): '/MIDI' device name used when no file name is given
pathMidiDev         fcb       $2F
                    fcc       /MIDI/
                    fcb       $00
* msgNewMidFile (was L5BC5): 'New .MID file: '
msgNewMidFile       fcc       /New .MID file: /
                    fcb       $00
* strMidExt (was L5BD5): '.mid' appended to the file name
strMidExt           fcc       /.mid/
                    fcb       $00
* strModeWrite (was L5BDA): 'w' fopen mode
strModeWrite        fcb       $77,$00
* msgCantOpenMidi (was L5BDC): '***Can't open /MIDI or File, try again.'
msgCantOpenMidi     fcc       /***Can't open /
                    fcb       $2F
                    fcc       /MIDI or File, try again./
                    fcb       $00
* fmtPromptBox (was L5C04): '%c%c%c%s' yesno prompt ($C9 code, x, y, text)
fmtPromptBox        fcc       /%c%c%c%s/
                    fcb       $00
* fmtSpaceInt (was L5C0D): ' %d'
fmtSpaceInt         fcc       / %d/
                    fcb       $00
* fmtSpaceUns (was L5C11): ' %u'
fmtSpaceUns         fcc       / %u/
                    fcb       $00
* msgHitEnter (was L5C15): ' ENTER or CLICK to go on:'
msgHitEnter         fcc       / ENTER or CLICK to go on:/
                    fcb       $00
* msgQuitUmuse (was L5C34): ' Exit this app? '
msgQuitUmuse        fcc       / Exit this app? /
                    fcb       $00
* fmtSaveScore (was L5C4A): 'Save Score '%s' ?'
fmtSaveScore        fcc       /Save Score '%s' ?/
                    fcb       $00
ExitOverlayNames    fcc       /s9s/
                    fcb       0
                    fcc       /s9l/
                    fcb       0
                    fcc       /s9t/
                    fcb       0
                    fcc       /s9p/
                    fcb       0
                    fcc       /s9d/
                    fcb       0
                    fcc       /s9e/
                    fcb       0
                    fcc       /s9m/
                    fcb       0
                    fcc       /s9b/
                    fcb       0
                    fcc       /s9k/
                    fcb       0
                    fcc       /s9r/
                    fcb       0
                    fcc       /s9w/
                    fcb       0
                    fcc       /s9u/
                    fcb       0
                    fcc       /s9c/
                    fcb       0
                    fcc       /s9i/
                    fcb       0
                    fcc       /s9y/
                    fcb       0
                    fcc       /s9f/
                    fcb       0
                    fcc       /s9g/
                    fcb       0
                    fcc       /s9o/
                    fcb       0
                    fcb       0                   end of unload list
* strCR1 (was L5C93): CR string printed when a signal is deferred
strCR1              fcb       $0D,$00
* LinkOverlay (was L5C95): F$Link (type $11) the named module, else F$Load it from the S9 module directory (S9Qualify) and link again ('Er %d ldg %s'); stores module addr in >$0007, returns entry
LinkOverlay         pshs      u
                    leas      -10,s
                    ldd       #$0011
                    stb       1,s
                    ldd       14,s
                    std       4,s
                    leax      ,s
                    pshs      x
                    clra
                    clrb
                    pshs      a,b
                    lbsr      Os9Call
                    leas      4,s
                    std       -2,s
                    beq      b61@
                    ldx       14,s                STACK OFFSET: LinkOverlay C module-name argument
                    lbsr      S9Qualify
                    stx       4,s                 STACK OFFSET: OS-9 register frame X
                    leax      ,s
                    pshs      x
                    ldd       #$0022
                    pshs      a,b
                    lbsr      Os9Call
                    leas      4,s
                    std       -2,s
                    bne       a61@
                    ldd       14,s
                    std       4,s
                    leax      ,s
                    pshs      x
                    clra
                    clrb
                    pshs      a,b
                    lbsr      Os9Call
                    leas      4,s
                    std       -2,s
                    beq       b61@
a61@                ldd       #$0001
                    pshs      a,b
                    lbsr      dialogue
                    leas      2,s
                    ldd       14,s
                    pshs      a,b
                    ldb       4,s
                    clra
                    pshs      a,b
                    leax      >fmtErrLoading,pcr
                    pshs      x
                    lbsr      Printf
                    leas      6,s
                    lbsr      hitenter
                    lbsr      wkill
                    clra
                    clrb
                    lbra      Os9WrapperRet
b61@                ldd       8,s
                    std       >UmeData_reserved_0007
                    ldd       6,s
                    lbra      Os9WrapperRet
* S9Qualify: X = module name -> X = its absolute path (S9ModuleDir; the name is copied to S9ModuleLeaf). Keeps D, U and CC.
S9Qualify           pshs      d,u,cc
                    ldu       >S9ModuleLeaf
s9qcopy@            lda       ,x+
                    sta       ,u+
                    bne       s9qcopy@
                    ldx       #S9ModuleDir
                    puls      cc,d,u,pc
* delink (was L5D13): F$UnLink the module at >$0007 and clears it
delink    pshs      u
                    leas      -10,s
                    ldd       >UmeData_reserved_0007
                    lbeq      Os9WrapperRet
                    ldd       >UmeData_reserved_0007
                    std       8,s
                    leax      ,s
                    pshs      x
                    ldd       #$0002
                    pshs      a,b
                    lbsr      Os9Call
                    leas      4,s
                    clra
                    clrb
                    std       >UmeData_reserved_0007
                    lbra      Os9WrapperRet
* unload (was L5D39): F$UnLoad by name (used for every s9x at quit)
unload        pshs      u
                    leas      -10,s
                    ldd       #$0011
                    stb       1,s
                    ldd       14,s
                    std       4,s
                    leax      ,s
                    pshs      x
                    ldd       #$001D
                    pshs      a,b
                    lbsr      Os9Call
                    leas      4,s
                    lbra      Os9WrapperRet
* soowee (was L5D57): builds 's9'+letter, unlinks the current overlay, LinkOverlay, calls entry(cmd, args...), puts breaker back, then relinks the previous overlay ('Cn't rlk %s!'); vector $0363
soowee         pshs      u
                    leas      -11,s
                    ldb       >UmeData_reserved_0009
                    stb       4,s
                    ldd       >UmeData_reserved_0007
                    std       2,s
                    bsr       delink
                    leax      >strUm3x,pcr
                    pshs      x
                    leax      7,s
                    pshs      x
                    lbsr      StrCopy
                    leas      4,s
                    ldb       <$10,s
                    stb       7,s                 STACK OFFSET: overlay letter in name at 5,s
                    leax      5,s
                    pshs      x
                    lbsr      LinkOverlay
                    leas      2,s
                    tfr       d,u
                    stu       -2,s
                    bne       a62@
                    clra
                    clrb
                    bra      c62@
a62@                ldb       <$10,s
                    stb       >UmeData_reserved_0009
                    clra
                    clrb
                    pshs      a,b
                    lbsr      automouse
                    leas      2,s
                    ldd       <$1B,s
                    pshs      a,b
                    ldd       <$1B,s
                    pshs      a,b
                    ldd       <$1B,s
                    pshs      a,b
                    ldd       <$1B,s
                    pshs      a,b
                    ldd       <$1B,s
                    pshs      a,b
                    ldb       <$1C,s
                    sex
                    pshs      a,b
                    ldb       #$01                the press that chose the overlay may still be down:
                    stb       <PressHeld          mouce ignores the button until it is released
                    jsr       ,u
                    leas      12,s
                    std       ,s
* s9w and s9u install their own F$Icpt handler (inside the overlay) for their DriveWire exchanges; once
* the overlay is unlinked that address is stale, so every overlay returns with s9's breaker back in place.
                    leax      >breaker,pcr
                    pshs      x
                    lbsr      SetIntercept
                    leas      2,s
                    lbsr      delink
                    ldd       2,s
                    beq       b62@
                    ldb       4,s
                    stb       7,s                 STACK OFFSET: overlay letter in name at 5,s
                    leax      5,s
                    pshs      x
                    lbsr      LinkOverlay
                    std       ,s++
                    bne       b62@
                    lbsr      text
                    leax      5,s
                    pshs      x
                    leax      >fmtCantRelink,pcr
                    pshs      x
                    lbsr      Printf
                    leas      4,s
                    ldd       #$0026
                    pshs      a,b
                    lbsr      ExitProg
                    leas      2,s
b62@                ldb       4,s
                    stb       >UmeData_reserved_0009
                    ldd       ,s
c62@                leas      11,s
                    puls      u,pc
* keysense (was L5E00): I$GetStt SS.KySns ($27) on path 0: keyboard/shift sense byte
keysense            pshs      u
                    leas      -10,s
                    clra
                    clrb
                    stb       1,s
                    ldd       #$0027
                    stb       2,s
                    leax      ,s
                    pshs      x
                    ldd       #$008D
                    pshs      a,b
                    lbsr      Os9Call
                    leas      4,s
                    ldb       1,s
                    lbra      Os9WrapperRet
* readone (was L5E20): reads one byte from path 0, strips bit 7, echoes it unless ^E
readone         pshs      u
                    ldd       #$0001
                    pshs      a,b
                    lbsr      alcurset
                    leas      2,s
                    lbsr      flush
                    ldd       #$0001
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    ldb       [<$04,s]
                    clra
                    andb      #$7F
                    stb       [<$04,s]
                    cmpd      #$0005
                    beq       a63@
                    ldx       #$01BE
                    pshs      x
                    ldb       [<$06,s]
                    sex
                    pshs      a,b
                    lbsr      FPutc
                    leas      4,s
a63@                lbsr      flush
                    ldb       [<$04,s]
                    puls      u,pc
* charmaus (was L5E68): keymouse, CR on click, mask bit 7, echo (except ^E), stores into the caller's buffer; vector $0353
charmaus         pshs      u
                    leas      -5,s
                    ldd       #$0001
                    pshs      a,b
                    lbsr      alcurset
                    leas      2,s
                    lbsr      flush
                    leax      1,s
                    pshs      x
                    leax      5,s
                    pshs      x
                    lbsr      keymouse
                    leas      4,s
                    stb       ,s
                    bne       a64@
                    ldd       #$000D
                    stb       ,s
a64@                ldb       ,s
                    clra
                    andb      #$7F
                    stb       ,s
                    cmpb      #$05
                    beq       b64@
                    ldx       #$01BE
                    pshs      x
                    ldb       2,s
                    sex
                    pshs      a,b
                    lbsr      FPutc
                    leas      4,s
b64@                lbsr      flush
                    ldb       ,s
                    stb       [<$09,s]
                    leas      5,s
                    puls      u,pc
* onehex (was L5EB5): charmaus then hexc2i
onehex            pshs      u
                    leas      -1,s
                    leax      ,s
                    pshs      x
                    bsr      charmaus
                    leas      2,s
                    sex
                    pshs      a,b
                    lbsr      hexc2i
                    bra       DropArgThenRet
* inkey (was L5ECA): fflush, SS.Ready on path 0; readone if a key is waiting else 0; vector $0357
inkey             pshs      u
                    leas      -1,s
                    lbsr      PollMark            the screen is complete: s9gui may show it (PollMark does its own fflush)
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    lbsr      GetStatus
                    leas      4,s
                    std       -2,s
                    beq       a65@
                    clra
                    clrb
                    bra       b65@
a65@                leax      ,s
                    pshs      x
                    lbsr      readone
* DropArgThenRet (was L5EF5): Drops the pushed 2-byte arg then returns; inkey falls in, onehex bra's here after hexc2i
DropArgThenRet      leas      2,s
b65@                leas      1,s
                    puls      u,pc
* testkey (was L5EFB): fflush then SS.Ready on path 0; 1 when a key is waiting
testkey          pshs      u
                    lbsr      MidiInputService        service DIN while waiting for keyboard input too
                    lbsr      PollMark            the screen is complete: s9gui may show it (PollMark does its own fflush)
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    lbsr      GetStatus
                    leas      4,s
                    std       -2,s
                    bne       a66@
                    ldd       #$0001
                    bra       b66@
a66@                clra
                    clrb
b66@                puls      u,pc
* gets (was L5F22): line input with backspace, ^X line kill, echo, max $51 chars, CR terminates; vector $0359
gets            pshs      u
                    leas      -7,s
                    ldu       11,s
                    ldd       #$0001
                    pshs      a,b
                    lbsr      alcurset
                    leas      2,s
                    lbsr      flush
                    clra
                    clrb
                    std       5,s
a67@                leax      1,s
                    pshs      x
                    leax      5,s
                    pshs      x
                    lbsr      keymouse
                    leas      4,s
                    stb       ,s
                    bne       b67@
                    ldd       #$000D
                    stb       ,s
b67@                ldb       ,s
                    clra
                    andb      #$7F
                    stb       ,s
                    cmpb      #$08
                    bne       d67@
                    ldd       5,s
                    lbeq      j67@
                    leau      -1,u
                    ldd       5,s
                    addd      #$FFFF
                    std       5,s
                    ldx       #$01BE
                    pshs      x
                    ldd       #$0008
c67@                pshs      a,b
                    lbsr      FPutc
                    leas      4,s
                    bra      j67@
d67@                ldb       ,s
                    cmpb      #$18
                    bne       g67@
                    bra       f67@
e67@                ldx       #$01BE
                    pshs      x
                    ldd       #$0008
                    pshs      a,b
                    lbsr      FPutc
                    leas      4,s
f67@                ldd       5,s
                    addd      #$FFFF
                    std       5,s
                    subd      #$FFFF
                    bne       e67@
                    ldu       11,s
                    clra
                    clrb
                    std       5,s
                    bra       j67@
g67@                ldb       ,s
                    cmpb      #$0D
                    bne       h67@
                    ldx       #$01BE
                    pshs      x
                    ldd       #$000D
                    pshs      a,b
                    lbsr      FPutc
                    leas      4,s
                    lbsr      flush
                    clra
                    clrb
                    stb       ,u
                    bra       k67@
h67@                ldd       5,s
                    cmpd      #$0051
                    bge       i67@
                    ldb       ,s
                    stb       ,u+
                    ldd       5,s
                    addd      #$0001
                    std       5,s
                    ldx       #$01BE
                    pshs      x
                    ldb       2,s
                    sex
                    bra      c67@
i67@                lbsr      bell
j67@                lbsr      flush
                    lbra      a67@
k67@                ldd       11,s
                    leas      7,s
                    puls      u,pc
* setmouse (was L5FF1): I$SetStt SS.GIP ($94) with the mouse port/resolution word from <hires and <left
setmouse          pshs      u
                    leas      -10,s
                    clra
                    clrb
                    stb       1,s
                    ldd       #$0094
                    stb       2,s
                    ldd       #$FFFF
                    std       6,s
* The original asked 'Hi-Res Adapter?' and 'Left Joy Port?' (CoCo hardware) here; both answers are now
* forced to no. <hires and <left hold the answers (negative = not asked yet), so they are set to zero.
                    clrb
                    stb       <hires                no hi-res adapter
                    stb       <left                not the left joystick port
                    ldb       <hires
                    beq       c68@
                    ldd       #$0100
                    bra       d68@
c68@                clra
                    clrb
d68@                addd      #$0001
                    pshs      a,b
                    ldb       <left
                    sex
                    addd      ,s++
                    std       4,s
                    leax      ,s
                    pshs      x
                    ldd       #$008E
                    pshs      a,b
                    lbsr      Os9Call
                    leas      4,s
                    bra       Os9WrapperRet
* automouse (was L604C): a no-op. The original told the CoCo window system (SS.Mouse) whether the pointer
* follows the mouse; the WildBits pointer is a hardware cursor. Callers drop their own argument.
automouse      rts

* Os9WrapperRet (was L6089): shared 10-byte frame exit of the Os9Call wrappers (keysense, LinkOverlay, delink, unload, setmouse)
Os9WrapperRet       leas      10,s
                    puls      u,pc
* mouce (was L608D): the WildBits mouse through SS.Mouse on path 2; args X ptr, Y ptr; returns D = left button (0/1); vector $039F
* SS.Mouse (level1/wildbits/cmds/wild.asm 'MouseHR'): exit A = buttons (bit 0 left, bit 1 right, bit 2 middle,
* active high), X = 0..640, Y = 0..479. X goes back as it is (the canvas is 640 wide); Y is halved to canvas rows,
* clamped to 0..191 and flipped (UltiMusE counts rows from the bottom). A right-button press is reported as an
* edge through MsRightNew.
mouce           lbsr      MidiInputService
                    lbsr      PollMark            the screen is complete: about to read the mouse
                    pshs      y,u                 S+0..1 y, +2..3 u, +4..5 return, +6..7 X ptr, +8..9 Y ptr
* Path 2 (the console), not path 0, which can be a script file before sysup rewires the paths. Y is saved:
* SS.Mouse returns the row in Y and Y is the C static base.
                    lda       #$02                path 2 = /term, the console
                    ldb       #SS.Mouse           the wildbits mouse getstat
                    os9       I$GetStt            A = buttons, X = 0..640, Y = 0..479
                    lbcs      rm9@                no answer: report no button, leave the coords
                    pshs      a                   keep the buttons; the args are now at 7,s / 9,s
* The pointer registers (MS_MEN, MS_XH) belong to the driver; nothing here touches them.
                    tfr       x,d
                    std       [7,s]               X straight through to the caller
                    tfr       y,d
                    lsra
                    rorb                          0..479 -> 0..239 canvas rows
                    cmpd      #$00BF
                    bls       rm1@
                    ldd       #$00BF              clamp to the 0..191 the canvas uses
rm1@                pshs      a,b                 the args are now at 9,s / 11,s
                    ldd       #$00BF
                    subd      ,s++                191 - row: UltiMusE counts rows from the bottom; args back at 7,s / 9,s
                    std       [9,s]               Y to the caller
                    puls      b                   the button byte
                    pshs      b
                    andb      #$02                the right button
                    cmpb      >MsRightPrev
                    beq       rmr1@               unchanged
                    stb       >MsRightPrev
                    beq       rmr1@               it went up: nothing pending
                    ldb       #$01
                    stb       >MsRightNew         it went down: MainLoop opens the note context menu
rmr1@               puls      b
                    clra
                    andb      #$01                left button only, bit 0
* PressHeld: the press that chose a menu or overlay may still be down. The menu-bar dispatch sets it when
* a title click becomes a menu key, soowee on the way into every overlay, and s9p for its own SS.Mouse
* poll. While it is set the button reads as up, so nothing takes the starting press for a click of its
* own; the first reading with the button up clears it. Drags begin with a click seen after that.
                    tst       <PressHeld
                    beq       rm8@                no starting press to swallow
                    tstb
                    beq       rm7@                the button has been seen up: from now on it counts
                    clrb                          still the starting press: report it up
                    bra       rm8@
rm7@                clr       <PressHeld
* The original's click timers, from the level about to be returned (B) and the kernel tick: button down -
* <dntime = ticks held so far, <uptime = ticks the previous release lasted; button up - <dntime = ticks the
* last press lasted, <uptime = ticks since the release. Both 0..254. Without a tick (no DAT image yet, or
* F$CpyMem fails) the current state reads 254, long settled: not a fresh press.
rm8@                tst       <FakeDown
                    beq       rm8b@
                    dec       <FakeDown           a plain click on a rest: reported held for a poll or two
                    ldb       #$01
rm8b@               pshs      b                   the level
                    leas      -2,s                D.Sec, D.Tick
                    ldd       #254
                    std       ,s                  the fallback
                    ldd       >MsSysDAT
                    beq       rmt1@
                    pshs      y                   Y = the C static base; F$CpyMem wants the count in it
                    ldx       #D.Sec              D.Tick follows it
                    ldy       #$0002
                    leau      2,s                 the two bytes
                    os9       F$CpyMem            D = the DAT image, X = offset, Y = count, U = destination
                    puls      y
                    bcs       rmt1@
* D.Tick counts down (60..1), so 60 - tick counts up within the second.
                    ldb       #60
                    subb      1,s                 60 - tick: 0..59, counting up within the second
                    stb       1,s
                    lda       ,s                  seconds
                    ldb       #60
                    mul
                    addb      1,s                 + (60 - tick)
                    adca      #$00                now, 0..3599, monotonic
                    std       ,s
                    ldb       2,s                 the level
                    cmpb      >MsPrevBtn
                    beq       rmt0@               the same state: how long has it lasted?
                    stb       >MsPrevBtn          an edge: the state that ends becomes the last one
                    ldd       ,s
                    subd      >MsStamp
                    bpl       rme1@
                    addd      #3600               the minute wrapped
rme1@               cmpd      #254
                    bls       rme2@
                    ldd       #254
rme2@               stb       >MsLast
                    ldd       ,s
                    std       >MsStamp            the new state starts now
rmt0@               ldd       ,s
                    subd      >MsStamp            ticks in this state
                    bpl       rmt2@
                    addd      #3600
rmt2@               cmpd      #254
                    bls       rmt3@
                    ldd       #254
rmt3@               std       ,s                  (A is 0: it fits a byte)
rmt1@               ldb       >MsLast
                    clra
                    tst       2,s                 the level
                    beq       rmt4@
                    std       <uptime                down: the previous release's length
                    ldd       ,s
                    std       <dntime                and the ticks held so far
                    bra       rmt5@
rmt4@               std       <dntime                up: the last press's length
                    ldd       ,s
                    std       <uptime                and the ticks since the release
rmt5@               leas      2,s
                    puls      b
                    clra
                    puls      y,u,pc
rm9@                clra
                    clrb
                    puls      y,u,pc
* fmtErrLoading (was L61F5): 'Er %d ldg %s'
fmtErrLoading       fcb       $0D
                    fcc       /Er %d ldg %s/
                    fcb       $0D,$00
* strUm3x (was L6204): 's9x' template; the x is replaced by the overlay letter in soowee
strUm3x             fcc       /s9x/
                    fcb       $00
* fmtCantRelink (was L6209): 'Cn't rlk %s!'
fmtCantRelink       fcc       /Cn't rlk %s!/
                    fcb       $0D,$00
* partline (vector $038D, randmen 'R'): a no-op. The original drew lines between events with CoCo grfdrv
* escape codes on path 2, which only print stray characters on WildBits.
partline            rts
* PIANO KEYS. PianoHook is the live MIDI-OUT dispatcher (pMidiSend, installed after MidiInitRoutes): every
* byte any player sends (score player, imported .lyr or .mid, audition) goes to the synth first
* (MidiSendSelected), then through a running-status parser: a Note On lights the key, a Note Off (or
* velocity 0) restores it, in the sending process, in step with the sound; s9gui is not involved. All Sound
* Off / All Notes Off (CC 120 / 123; s9p's StopRawNotes sends CC 120 on every channel when play ends) puts
* every key up, once.
* Layout: PianoHookInstall paints all 88 keys up. White key i (0 = A0 .. 51 = C8) sits at x = 8 + 12i, a
* black key 8 dots right of the white key on its left, so every key starts on a byte. The images
* (tools/gen/make_piano_keys.py: white 12 x 23 in three cut-out variants, black 8 x 15) go on picture rows
* 205-227, in block 8 of both bitmaps below the $1D00 that slot 7 hides, byte by byte: a $00 image byte
* leaves the screen byte (the cut-outs under the black keys), any other byte is stored.
* Painting: the score page leaves slot 7, the tail block with the images (the symbol bank from $1B00: the
* keys at $28C4 - $1B00 = $DC4) comes in and the key is staged on the stack, then each bitmap's block 8
* takes the slot in turn; the page comes back at the same address, so the player's cached page pointers
* hold. Statics at $1044-$1047 (FranParam, free once sysup has forked s9gui): the two bitmaps' first
* blocks, the parser's status and PianoPend; PianoSym ($10B0) keeps the tail block's number, read off
* FranParam before it is overwritten (first install only: a restart finds PianoStat there, never a CR).
* PianoPend: $00-$7F a note byte waiting for its velocity; otherwise flags - bit 0 set = keys may be lit
* (clear = the keyboard is all up), bit 1 clear = a CC value comes next: $FF/$FE idle, $FD/$FC a CC
* value next.
PianoHookInstall    pshs      d,x,y,u
                    lda       >FranParam+2        TailInit's CR: the first install (a restart finds PianoStat here)
                    cmpa      #C$CR
                    bne       phi1@
* The first install waits for s9gui's ready byte on the reply pipe (its screens cleared, bitmap 1 made and
* copied) before painting, so that DMA clear and copy cannot wipe painted keys. The byte lands on the saved
* A; s9gui gone = end of file, no wait.
                    lda       >FranReply
                    leax      ,s
                    ldy       #1
                    os9       I$Read
                    lda       >FranParam+1        block 7 of the module + $40 (TailInit), read before PianoBM1 lands on it
                    suba      #$40
                    sta       >PianoSym
phi1@               clr       >PianoStat
                    lda       #$FF
                    sta       >PianoPend
                    ldy       #0
                    bsr       PianoScreen
                    sta       >PianoBM
                    ldy       #1
                    bsr       PianoScreen
                    sta       >PianoBM1
                    lbsr      PianoAllUp          the keyboard itself: all 88 keys, up
                    leax      PianoHook,pcr
                    stx       >pMidiSend          every live byte passes here now
                    puls      d,x,y,u,pc
* PianoScreen: Y = the bitmap number -> A = its first block (SS.AScrn type 0; E$WADef = it exists, X = its block), 0 on another error
PianoScreen         lda       #2
                    ldb       #SS.AScrn
                    ldx       #0
                    os9       I$SetStt
                    bcc       psc1@
                    cmpb      #E$WADef
                    beq       psc1@
                    clra
                    rts
psc1@               tfr       x,d
                    tfr       b,a
                    rts
* PianoHook: the MIDI-OUT dispatcher. The byte is the low half of the caller's word at 2,s (MidiHwSend).
PianoHook           pshs      d,x,y,u
                    ldd       10,s
                    pshs      d
                    lbsr      MidiSendSelected    the synth first: the sound is on time
                    puls      d
                    tstb
                    bpl       ph1@                a data byte
                    cmpb      #$F8
                    bhs       ph9@                real time: the running status stands
                    stb       >PianoStat          a channel or system status starts a message
                    lda       >PianoPend
                    bmi       ph0@
                    lda       #$FF                a note message cut short
ph0@                ora       #2                  idle, the keyboard flag kept
                    sta       >PianoPend
                    bra       ph9@
ph1@                lda       >PianoStat
                    anda      #$F0
                    cmpa      #$B0
                    beq       phc@                a control change
                    cmpa      #$80
                    beq       ph4@
                    cmpa      #$90
                    bne       ph9@                not a note message
ph4@                lda       >PianoPend
                    bpl       ph5@
                    stb       >PianoPend          the note; the velocity follows
                    bra       ph9@
ph5@                pshs      b                   ,s the velocity; A = the note
                    ldb       #$FF
                    stb       >PianoPend
                    ldb       >PianoStat
                    andb      #$F0
                    cmpb      #$90
                    puls      b
                    bne       ph6@                a note off
                    tstb
                    beq       ph6@                velocity 0: off
                    ldb       #1
                    bra       ph7@
ph6@                clrb
ph7@                bsr       PianoKey
ph9@                puls      d,x,y,u,pc
* a control change: the first data byte is the controller, the second its value
phc@                lda       >PianoPend
                    bita      #2
                    beq       phc2@               the value: back to idle
                    cmpb      #120                All Sound Off
                    beq       phc1@
                    cmpb      #123                All Notes Off
                    bne       phc3@
phc1@               bita      #1
                    beq       phc3@               the keyboard is all up already
                    bsr       PianoAllUp
                    lda       #$FE
phc3@               anda      #$FD                the value follows
                    bra       phc4@
phc2@               ora       #2
phc4@               sta       >PianoPend
                    bra       ph9@
* PianoKey: A = the note, B = 1 lit / 0 clean. Folds onto A0-C8 by octaves. Keeps every register.
PianoKey            pshs      d
pk1@                cmpa      #21
                    bhs       pk2@
                    adda      #12
                    bra       pk1@
pk2@                cmpa      #108
                    bls       pk3@
                    suba      #12
                    bra       pk2@
pk3@                suba      #21
                    bsr       PianoDraw
                    puls      d,pc
* PianoAllUp: all 88 keys painted up (the keyboard at start-up, and on All Sound Off / All Notes Off); PianoPend
* then says the keyboard is all up ($FE), so the same message on the other fifteen channels paints nothing.
* The white images leave the black keys' bytes alone, so the order does not matter. Keeps every register.
PianoAllUp          pshs      d
                    clra
pau1@               clrb
                    bsr       PianoDraw
                    inca
                    cmpa      #88
                    blo       pau1@
                    lda       #$FE
                    sta       >PianoPend
                    puls      d,pc
* PianoDraw: A = the key index 0..87, B = 1 lit / 0 up. Keeps every register. While s9p plays (MidiPlaying)
* the key only goes to s9p's PianoMark (PianoVec), which paints it once every note of that moment is out,
* so no note waits for a paint. The rts must follow the jsr: PianoMark keeps that return address and
* PianoPaint is the next byte.
PianoDraw           tst       >MidiPlaying
                    beq       PianoPaint
                    jsr       [>PianoVec]
                    rts
* PianoPaint: the painting. The frame (Y): 0 the row-0 destination offset within block 8, 2 rows to paint, 3 bytes
* a row, 5 PianoTab's entry, 6 the image's offset in the tail block, 10 the staged image (up to 138 bytes); the
* pushed A at 160, B at 161.
PianoPaint          pshs      d,x,y,u
                    leas      -160,s
                    leay      ,s
                    ldb       160,y
                    addb      #21                 the note
                    clra                          A = its octave
pdr1@               cmpb      #12
                    blo       pdr2@
                    subb      #12
                    inca
                    bra       pdr1@
pdr2@               leax      PianoTab,pcr
                    ldb       b,x                 bits 0-2 the white key in the octave, 4-5 the image, 7 black
                    tst       160,y
                    bne       pdr3@
                    andb      #$CF                A0: no black key on its left - the C/F image
pdr3@               stb       5,y
                    andb      #7
                    pshs      b
                    ldb       #7
                    mul                           D = 7 x octave
                    addb      ,s+
                    subb      #12                 B = i, the white key from A0 (0..51)
                    lda       #6
                    mul                           6i: white key i sits at x = 8 + 12i, x / 2 = 4 + 6i
                    addd      #$0040+4            row 205 is $40 into block 8 (205 x 320 - $10000)
                    tst       5,y
                    bpl       pdr5@
                    addd      #4                  a black key sits 8 dots right of the white one
pdr5@               std       ,y                  where row 0 of the key starts
                    lda       5,y
                    lsra
                    lsra
                    lsra
                    lsra
                    anda      #3                  the image: 0 CF, 1 DGA, 2 EB, 3 black
                    ldb       #150
                    mul
                    addd      #PianoImages
                    tst       161,y
                    beq       pdr6@
                    addd      #PianoPressed       lit: the pressed image
pdr6@               std       6,y
                    ldd       #23*256+6           a white key: 23 rows of 6 bytes (12 dots)
                    tst       5,y
                    bpl       pdr7@
                    ldd       #15*256+4           a black key: 15 rows of 4 bytes (8 dots)
pdr7@               std       2,y
* the score page out of slot 7, the images' block in and the key staged, then each bitmap's block 8 painted
                    ldu       >GPAddr
                    ldd       >GPMapped
                    beq       pdr8@
                    ldb       #GPBLKS
                    os9       F$ClrBlk
pdr8@               ldb       >PianoSym
                    clra
                    tfr       d,x
                    ldb       #1
                    os9       F$MapBlk            U = the tail block (slot 7)
                    bcs       pdr9@
                    ldd       6,y
                    leax      d,u                 the image
                    pshs      u                   the tail block, for F$ClrBlk
                    leau      10,y                the stage
                    lda       2,y
                    ldb       3,y
                    mul                           B = bytes to stage (138 or 60)
pdr8a@              lda       ,x+
                    sta       ,u+
                    decb
                    bne       pdr8a@
                    puls      u
                    ldb       #1
                    os9       F$ClrBlk
                    lda       >PianoBM
                    beq       pdr9@
                    bsr       PianoBitmap
                    lda       >PianoBM1
                    beq       pdr9@
                    bsr       PianoBitmap
pdr9@               ldd       >GPMapped
                    beq       pdr10@
                    ldx       >GPMapped
                    ldb       >GPTab,x
                    clra
                    tfr       d,x
                    ldb       #GPBLKS
                    os9       F$MapBlk            the score page back (slot 7 again: the same address)
                    stu       >GPAddr
pdr10@              leas      160,s
                    puls      d,x,y,u,pc
* PianoBitmap: A = a bitmap's first block, Y = the frame: its block 8 into slot 7, the staged rows written, out.
PianoBitmap         pshs      d,x,u
                    adda      #8
                    tfr       a,b
                    clra
                    tfr       d,x
                    ldb       #1
                    os9       F$MapBlk            U = block 8 (slot 7)
                    bcs       pbm9@
                    pshs      u                   the base, for F$ClrBlk
                    ldd       ,y
                    leau      d,u                 row 0's first byte
                    leax      10,y                the staged image
                    lda       2,y
                    pshs      a                   ,s rows to go
pbm1@               ldb       3,y
                    pshs      u
                    bsr       PianoRow            X on through the image
                    puls      u
                    leau      >320,u              the next row
                    dec       ,s
                    bne       pbm1@
                    leas      1,s
                    puls      u
                    ldb       #1
                    os9       F$ClrBlk
pbm9@               puls      d,x,u,pc
* PianoRow: B image bytes at X straight onto the screen bytes at U; a $00 byte leaves the screen byte. X and U
* advance.
PianoRow            lda       ,x+
                    beq       pro1@
                    sta       ,u
pro1@               leau      1,u
                    decb
                    bne       PianoRow
                    rts
* PianoTab: a pitch class -> bits 0-2 its white key in the octave (C 0 .. B 6, a black key its left neighbor's),
* bits 4-5 its image (0 CF, 1 DGA, 2 EB, 3 black), bit 7 black
PianoTab            fcb       $00,$B0,$11,$B1,$22,$03,$B3,$14,$B4,$15,$B5,$26

inrect              pshs      u
                    ldd       4,s
                    cmpd      8,s
                    blt       a73@
                    ldd       4,s
                    cmpd      12,s
                    bgt       a73@
                    ldd       6,s
                    cmpd      10,s
                    blt       a73@
                    ldd       6,s
                    cmpd      14,s
                    bgt       a73@
                    ldd       #$0001
                    bra       b73@
a73@                clra
                    clrb
b73@                puls      u,pc
* menu3(desc, states): a text menu streamed to s9gui from a descriptor the caller owns, drawn and picked
* by s9gui (pipemenu). Descriptor: fcb col, y, width, rows; the key letters (one a row, a space = title);
* then rows of kind + label + NUL, a zero kind ends it. Kinds ' ' plain, 'b' checkbox (a state byte,
* '0' = off), 'r' radio head (a state digit K, hex allowed), 'q' member, 'f' field (label, then the state
* text up to CR). Boxes: Chars16 $60 empty, $7F checked. B = the key picked, CR = closed. Vector pMenu3.
* Frame: 0,s states cursor  2,s keys cursor  4,s K (first: the row pointer)
* 5,s the member index  6,s the row's key  7,s the box
menu3               pshs      u
                    leas      -8,s
                    ldu       12,s                the descriptor
                    clra
                    clrb
                    pshs      d
                    lbsr      alcurset            no text cursor in the box
                    leas      2,s
                    ldd       14,s                the states
                    std       ,s
                    leax      4,u
                    stx       2,s                 the keys
                    ldb       3,u
                    abx
                    stx       4,s                 the first row, for after the header
                    ldb       2,u                 width
                    clra
                    pshs      d
                    ldb       3,u                 rows
                    clra
                    pshs      d
                    ldb       1,u                 y
                    clra
                    pshs      d
                    ldb       ,u                  col
                    clra
                    pshs      d
                    ldd       #$00B9
                    pshs      d
                    leax      >fmtMenuHdr,pcr
                    pshs      x
                    lbsr      Printf               printf: $B9 col y rows width
                    leas      12,s
                    ldu       4,s                 the first row
m3row@              lda       ,u+                 the kind
                    lbeq      m3end@
                    ldx       2,s
                    ldb       ,x+
                    stx       2,s
                    stb       6,s                 the key letter
                    cmpb      #MenuKeyOff         a disabled row: a space key (s9gui never answers or
                    bne       m3live@             inverts it) and the DIM marker before the label (s9gui dims it)
                    ldb       #C$SPAC
                    stb       6,s
                    pshs      a
                    ldd       #MenuDim
                    pshs      d
                    lbsr      charput
                    leas      2,s
                    puls      a
m3live@
                    cmpa      #'b
                    beq       m3box@
                    cmpa      #'r
                    beq       m3radio@
                    cmpa      #'q
                    beq       m3member@
                    cmpa      #'f
                    beq       m3field@
                    pshs      u                   plain: key, label, CR
                    ldb       8,s
                    clra
                    pshs      d
                    leax      >fmtRowPlain,pcr
                    pshs      x
                    lbsr      Printf   
                    leas      6,s
                    bra       m3next@
m3radio@            ldx       ,s
                    lda       ,x+
                    stx       ,s
                    suba      #'0
                    cmpa      #9
                    bls       m3rk@
                    suba      #'a-'0-10           a hex digit (the part picker's g = 16)
m3rk@               sta       4,s                 K
                    clr       5,s
m3member@           inc       5,s
                    lda       5,s
                    cmpa      4,s
                    beq       m3on@
                    bra       m3off@
m3box@              ldx       ,s
                    lda       ,x+
                    stx       ,s
                    cmpa      #'0
                    bne       m3on@
m3off@              lda       #$60                the empty box
                    bra       m3draw@
m3on@               lda       #$7F                the checked box (Chars16 $7F)
m3draw@             sta       7,s
                    pshs      u                   label
                    ldb       9,s
                    clra
                    pshs      d                   the box
                    ldb       10,s
                    clra
                    pshs      d                   the key
                    leax      >fmtRowBox,pcr
                    pshs      x
                    lbsr      Printf   
                    leas      8,s
                    bra       m3next@
m3field@            pshs      u
                    ldb       8,s
                    clra
                    pshs      d
                    leax      >fmtRowKeyLabel,pcr
                    pshs      x
                    lbsr      Printf               key, label; then the state text
                    leas      6,s
m3fch@              ldx       ,s
                    ldb       ,x+
                    stx       ,s
                    cmpb      #C$CR
                    beq       m3fcr@
                    tstb
                    beq       m3fcr@
                    clra
                    pshs      d
                    lbsr      charput              putchar
                    leas      2,s
                    bra       m3fch@
m3fcr@              ldd       #C$CR
                    pshs      d
                    lbsr      charput  
                    leas      2,s
m3next@             lda       ,u+                 past the label
                    bne       m3next@
                    lbra      m3row@
m3end@              lbsr      pipemenu             s9gui draws, hovers and answers: B
                    leas      8,s
                    puls      u,pc
fmtMenuHdr          fcc       /%c%c%c%c%c/
                    fcb       0
fmtRowPlain         fcc       /%c%s/
                    fcb       C$CR,0
fmtRowBox           fcc       /%c%c %s/
                    fcb       C$CR,0
fmtRowKeyLabel      fcc       /%c%s/
                    fcb       0
* pipemenu: the caller has streamed a menu to s9gui ($B9 col y rows width, then one CR-terminated row
* each: the key letter, then the label); s9gui draws it and runs the hover loop on the packets sent from
* here - x (word), canvas row, code (0 move, 1 a fresh press, 2 close, else the key typed) - and answers
* every packet with one byte on the reply pipe FranReply: 0 = nothing yet, else the key letter of the
* row clicked or typed, CR for a click off the menu (or a title row). B = that byte. No arguments.
* Frame: 0,s x  2,s y  4,s the packet  8,s the button level last time. Y untouched.
pipemenu            pshs      u
                    leas      -9,s
                    clr       8,s
                    ldx       #$01BE
                    pshs      x
                    lbsr      FFlush              the menu must reach s9gui before its first packet
                    leas      2,s
                    lbsr      waitmouse           the click that opened the menu is released first
pml@                leax      2,s
                    pshs      x
                    leax      2,s
                    pshs      x
                    lbsr      kmouse              -1 button down, >0 a key (read), 0 nothing; x,y filled in
                    leas      4,s
                    cmpd      #$FFFF
                    bne       pmk@
                    ldb       8,s                 down: was it down last time too?
                    bne       pmh@
                    inc       8,s
                    ldb       #$01                a fresh press
                    bra       pmc@
pmh@                clrb                          held: a move
                    bra       pmc@
pmk@                clr       8,s                 up; B = the key typed or 0
pmc@                stb       7,s
                    ldd       ,s
                    std       4,s                 x
                    ldb       3,s
                    stb       6,s                 the canvas row
                    ldd       #$0004
                    pshs      a,b
                    leax      6,s
                    pshs      x
                    ldd       #$0001
                    pshs      a,b                 path 1: the pipe to s9gui
                    lbsr      WritePath
                    leas      6,s
* Lock-step: s9gui answers every packet with one byte, 0 = nothing yet. The pipe's GetStt always says
* 'ready', so SS.Ready cannot poll it; the read below blocks until the answer.
                    ldd       #$0001
                    pshs      a,b
                    leax      6,s                 the packet's first byte takes the answer
                    pshs      x
                    ldb       >FranReply
                    clra
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    ldb       4,s                 the answer
                    bne       pmr@
                    ldd       #$0001
                    pshs      a,b
                    lbsr      TSleep              a tick between packets
                    leas      2,s
                    lbra      pml@
pmr@                clra
                    leas      9,s
                    puls      u,pc
* greeting: opens the welcome box (column 23, y 170, 31 by 16, background saved) and prints strGreeting
* into it. The click that ends the start-up (hitenter) and the wkill after it follow in MainInit.
greeting            pshs      u
                    ldd       #WinMenu            the black shadowed box, paper text
                    pshs      a,b
                    ldd       #$0001              save the background
                    pshs      a,b
                    ldd       #16                 height
                    pshs      a,b
                    ldd       #31                 width
                    pshs      a,b
                    ldd       #170                y
                    pshs      a,b
                    ldd       #23                 column
                    pshs      a,b
                    lbsr      wcreate
                    leas      12,s
                    leax      >strGreeting,pcr
                    pshs      x
                    lbsr      Printf
                    leas      2,s
                    puls      u,pc
* strGreeting: the greeting dialog's text, 20 lines at most.
* $0C clears the box; each CR is a line, two CRs a blank line. The box is 31 columns wide, 16 rows tall.
strGreeting         fcb       $0C,C$CR
                    fcc       /          Welcome to/
                    fcb       C$CR,C$CR
                    fcc       /        Studio-9 v0.9B/
                    fcb       C$CR,C$CR
                    fcc       /  Music authoring system for/
                    fcb       C$CR
                    fcc       /  the Wildbits K2 and Jr2 PC./
                    fcb       C$CR
                    fcc       /   (C) 2026 by Roger Taylor/
                    fcb       C$CR,C$CR
                    fcc       /     Complete rewrite of:/
                    fcb       C$CR
                    fcc       /         UltiMusE-III/
                    fcb       C$CR
                    fcc       /  the 'Ultimate Music Editor'/
                    fcb       C$CR
                    fcc       /     by Michael J. Knudsen/
                    fcb       C$CR,C$CR,0
* randmen (was L6379): menu 1 keys 'pksnufh9?drq': quit, 'Restart Studio-9?', filtmen, overlays, partline, OS9 shell, about, MIDI file, undo ('Too late!'), DriveWire upload
randmen             pshs      u
                    leas      <-$55,s
                    ldd       <curcurse
                    std       ,s
                    ldd       #$0002
                    pshs      a,b
                    lbsr      curset
                    leas      2,s
a75@                ldb       <$5A,s
                    bne       b75@
                    ldd       #$0003              s9c menu 3 = the command menu
                    pshs      d
                    ldd       #'M
                    pshs      d
                    ldd       #'C
                    pshs      d
                    lbsr      soowee
                    leas      6,s
                    stb       <$5A,s
                    lbsr      wkill
b75@                ldb       <$5A,s
                    sex
                    tfr       d,x
                    lbra      ah75@
c75@                ldd       #$0002
                    pshs      a,b
                    lbsr      breaker
                    lbra      ae75@
d75@                leax      >msgRestartUmuse,pcr
                    pshs      x
                    lbsr      yesno
                    leas      2,s
                    lbeq      ai75@
                    ldd       #$0001
                    lbra      aj75@
e75@                lbsr      filtmen
                    lbra      ai75@
f75@                ldd       #$0070
                    pshs      a,b
                    ldd       #$0053
                    bra       h75@
g75@                ldd       #$006B
                    pshs      a,b
                    ldd       #$004B
h75@                pshs      a,b
                    lbsr      soowee
                    lbra      ac75@
i75@                ldb       <$5A,s
                    cmpb      #$52
                    bne       j75@
                    ldd       #$0001
                    bra       k75@
j75@                clra
                    clrb
k75@                pshs      a,b
                    lbsr      partline
                    lbra      ae75@
l75@                ldd       #WinStylePaper3D    the paper 3D box
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0019
                    pshs      a,b
                    ldd       #$004E
                    pshs      a,b
                    ldd       #$00BE
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    lbsr      wcreate
                    leas      12,s
                    leax      >msgEnterBlankLine,pcr
                    pshs      x
                    lbsr      Printf
                    leas      2,s
m75@                leax      >strOs9Prompt,pcr
                    pshs      x
                    lbsr      Printf
                    leas      2,s
                    leax      4,s
                    pshs      x
                    lbsr      gets
                    leas      2,s
                    tfr       d,x
                    ldb       ,x
                    beq       n75@
                    leax      4,s
                    pshs      x
                    lbsr      SystemShell
                    leas      2,s
                    std       2,s
                    beq       m75@
                    ldd       2,s
                    clra
                    pshs      a,b
                    leax      >fmtErrorNum,pcr
                    pshs      x
                    lbsr      Printf
                    leas      4,s
                    bra      m75@
n75@                lbsr      wkill
                    ldd       #$0001
                    stb       <rfr_scr
                    stb       <rfr_bar
                    lbra      ai75@
o75@                lbsr      report
                    lbra      ai75@
p75@                ldb       <pldebug
                    beq       q75@
                    lbsr      text
                    leax      >msgHitBreak,pcr
                    pshs      x
                    lbsr      Printf
                    leas      2,s
q75@                ldd       <nevents
                    addd      #$FFFF
                    pshs      a,b
                    ldb       <$5C,s
                    cmpb      #$77
                    bne       r75@
                    ldd       <lftind
                    bra       s75@
r75@                clra
                    clrb
s75@                pshs      a,b
                    lbsr      play
                    leas      4,s
                    ldb       <rfr_scr
                    bne       t75@
                    ldb       <pldebug
                    lbeq      ai75@
                    ldx       #$01BE
                    pshs      x
                    ldd       #$000D
                    pshs      a,b
                    lbsr      FPutc
                    leas      4,s
                    lbsr      hitenter
t75@                lbsr      wkill
                    lbra      ai75@
u75@                ldd       <undind
                    blt       x75@
                    ldb       >UmeData_reserved_03EB
                    sex
                    std       2,s
                    beq       v75@
                    ldd       2,s
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #parts
                    leax      d,x
                    ldd       2,x
                    clra
                    andb      #$04
                    bne       v75@
                    ldd       <undind
                    pshs      a,b
                    lbsr      i2p
                    bra       w75@
v75@                ldd       <undind
                    pshs      a,b
                    lbsr      makroom
w75@                leas      2,s
                    tfr       d,u
                    ldx       #$03EB
                    pshs      x
                    pshs      u
                    lbsr      CopyEvent
                    leas      4,s
                    ldd       #$FFFF
                    std       <undind
                    ldd       #$0001
                    stb       <rfr_scr
                    lbra      ai75@
x75@                clra
                    clrb
                    pshs      a,b
                    leax      >msgTooLate,pcr
                    bra       ab75@
y75@                ldd       #$0001
                    stb       <rfr_bar
                    stb       <rfr_scr
                    lbra      ai75@
z75@                ldb       <UmeData_reserved_0051
                    beq       aa75@
                    ldd       #$0075
                    pshs      a,b
                    ldd       #$0055
                    pshs      a,b
                    lbsr      soowee              (soowee puts breaker back)
                    leas      4,s
                    ldd       <broke
                    cmpd      #$0002
                    lbne      ai75@
                    ldd       #$0002
                    pshs      a,b
                    lbsr      breaker
                    leas      2,s
                    lbra      ai75@
aa75@               clra
                    clrb
                    pshs      a,b
                    leax      >msgNeedDriveWire,pcr
ab75@               pshs      x
                    lbsr      alert
ac75@               leas      4,s
                    lbra      ai75@
ad75@               ldd       #$0001
                    stb       <rfr_scr
                    sex
                    pshs      a,b
                    lbsr      RenumberBars
ae75@               leas      2,s
                    lbra      ai75@
af75@               clra
                    clrb
                    pshs      a,b
                    leax      >msgNotYet,pcr
                    pshs      x
                    lbsr      alert
                    leas      4,s
ag75@               lbsr      bell
                    clra
                    clrb
                    stb       <$5A,s
                    lbra      ai75@
ah75@               cmpx      #$0071
                    lbeq      c75@
                    cmpx      #$0072
                    lbeq      d75@
                    cmpx      #$0066
                    lbeq      e75@
                    cmpx      #$0046
                    lbeq      e75@
                    cmpx      #$0023
                    lbeq      e75@
                    cmpx      #$0068
                    lbeq      f75@
                    cmpx      #$006B
                    lbeq      g75@
                    cmpx      #$004C
                    lbeq      i75@
                    cmpx      #$0052
                    lbeq      i75@
                    cmpx      #$0039
                    lbeq      l75@
                    cmpx      #$003A
                    lbeq      l75@
                    cmpx      #$003F
                    lbeq      o75@
                    cmpx      #$002F
                    lbeq      o75@
                    cmpx      #$0070
                    lbeq      p75@
                    cmpx      #$0077
                    lbeq      p75@
                    cmpx      #$0003
                    beq       ai75@
                    cmpx      #$0005
                    beq       ai75@
                    cmpx      #$0075
                    lbeq      u75@
                    cmpx      #$0073
                    lbeq      y75@
                    cmpx      #$0064
                    lbeq      z75@
                    cmpx      #$006E
                    lbeq      ad75@
                    cmpx      #$000D
                    beq       ai75@
                    cmpx      #$0076
                    lbeq      af75@
                    lbra      ag75@
ai75@               ldb       <$5A,s
                    lbeq      a75@
                    ldd       ,s
                    pshs      a,b
                    lbsr      curset
                    leas      2,s
                    clra
                    clrb
aj75@               leas      <$55,s
                    puls      u,pc
* filtmen (was L666D): menu $12 keys ' enraofc uml' toggling option bytes >$03CB-$03D3
filtmen           pshs      u
                    leas      <-$56,s
                    ldd       <curcurse
                    std       ,s
                    ldd       #$0002
                    pshs      a,b
                    lbsr      curset
                    leas      2,s
a76@                ldb       >UmeData_reserved_03D2
                    sex
                    pshs      a,b
                    ldb       >UmeData_reserved_03D3
                    sex
                    pshs      a,b
                    ldb       >UmeData_reserved_03D1
                    sex
                    pshs      a,b
                    ldb       >UmeData_reserved_03CF
                    sex
                    pshs      a,b
                    ldb       >UmeData_reserved_03D0
                    sex
                    pshs      a,b
                    ldd       >UmeData_reserved_03CB
                    beq       b76@
                    ldd       #$0001
                    bra       c76@
b76@                clra
                    clrb
c76@                addd      #$0001
                    pshs      a,b
                    ldb       >UmeData_reserved_03CD
                    sex
                    pshs      a,b
                    ldb       >UmeData_reserved_03CE
                    sex
                    pshs      a,b
                    leax      >fmtEightInts,pcr
                    pshs      x
                    ldx       #MenuStates
                    pshs      x
                    lbsr      SPrintf
                    leas      <$14,s
                    ldd       #$0007              s9c menu 7 = the finder filter
                    pshs      d
                    ldd       #'M
                    pshs      d
                    ldd       #'C
                    pshs      d
                    lbsr      soowee
                    leas      6,s
                    stb       4,s
                    lbsr      wkill
                    ldb       4,s
                    sex
                    tfr       d,x
                    lbra      ai76@
d76@                ldd       ,s
                    pshs      a,b
                    lbsr      curset
                    leas      2,s
                    lbra      aj76@
e76@                clra
                    clrb
                    std       >UmeData_reserved_03CB
                    ldd       #$0001
                    stb       >UmeData_reserved_03D2
                    stb       >UmeData_reserved_03D3
                    stb       >UmeData_reserved_03D1
                    stb       >UmeData_reserved_03CF
                    stb       >UmeData_reserved_03D0
                    stb       >UmeData_reserved_03CD
                    bra       h76@
f76@                ldb       >UmeData_reserved_03CE
                    beq       g76@
                    clra
                    clrb
                    stb       >UmeData_reserved_03CE
                    ldd       #$0001
                    stb       >UmeData_reserved_03CD
                    bra       i76@
g76@                ldd       #$0001
h76@                stb       >UmeData_reserved_03CE
i76@                lbra      a76@
j76@                ldb       >UmeData_reserved_03CD
                    beq       k76@
                    ldd       #$0001
                    stb       >UmeData_reserved_03CE
                    clra
                    clrb
                    bra       l76@
k76@                ldd       #$0001
l76@                stb       >UmeData_reserved_03CD
                    lbra      a76@
m76@                clra
                    clrb
                    std       >UmeData_reserved_03CB
                    lbra      a76@
n76@                lbsr      fltprtmen
                    lbra      a76@
o76@                ldb       >UmeData_reserved_03CF
                    sex
                    pshs      a,b
                    ldb       >UmeData_reserved_03D0
                    bne       p76@
                    ldd       #$0001
                    bra       q76@
p76@                clra
                    clrb
q76@                stb       >UmeData_reserved_03D0
                    bne       r76@
                    ldd       #$0001
                    bra       s76@
r76@                clra
                    clrb
s76@                ora       ,s+
                    orb       ,s+
                    stb       >UmeData_reserved_03CF
                    lbra      a76@
t76@                ldb       >UmeData_reserved_03D0
                    sex
                    pshs      a,b
                    ldb       >UmeData_reserved_03CF
                    bne       u76@
                    ldd       #$0001
                    bra       v76@
u76@                clra
                    clrb
v76@                stb       >UmeData_reserved_03CF
                    bne       w76@
                    ldd       #$0001
                    bra       x76@
w76@                clra
                    clrb
x76@                ora       ,s+
                    orb       ,s+
                    stb       >UmeData_reserved_03D0
                    lbra      a76@
y76@                ldb       >UmeData_reserved_03D1
                    bne       z76@
                    ldd       #$0001
                    bra       aa76@
z76@                clra
                    clrb
aa76@               stb       >UmeData_reserved_03D1
                    lbra      a76@
ab76@               ldb       >UmeData_reserved_03D3
                    bne       ac76@
                    ldd       #$0001
                    bra       ad76@
ac76@               clra
                    clrb
ad76@               stb       >UmeData_reserved_03D3
                    lbra      a76@
ae76@               ldb       >UmeData_reserved_03D2
                    bne       af76@
                    ldd       #$0001
                    bra       ag76@
af76@               clra
                    clrb
ag76@               stb       >UmeData_reserved_03D2
                    lbra      a76@
ah76@               lbsr      bell
                    lbra      a76@
ai76@               cmpx      #$000D
                    lbeq      d76@
                    cmpx      #$0065
                    lbeq      e76@
                    cmpx      #$006E
                    lbeq      f76@
                    cmpx      #$0072
                    lbeq      j76@
                    cmpx      #$0061
                    lbeq      m76@
                    cmpx      #$006F
                    lbeq      n76@
                    cmpx      #$0066
                    lbeq      o76@
                    cmpx      #$0070
                    lbeq      t76@
                    cmpx      #$0063
                    lbeq      t76@
                    cmpx      #$002B
                    lbeq      t76@
                    cmpx      #$003D
                    lbeq      t76@
                    cmpx      #$0075
                    lbeq      y76@
                    cmpx      #$006D
                    lbeq      ab76@
                    cmpx      #$006C
                    beq      ae76@
                    bra       ah76@
aj76@               leas      <$56,s
                    puls      u,pc
* fltprtmen (was L685B): menu with keys '123456789abcdefg' returning a MIDI channel via i2hexc
fltprtmen     pshs      u
                    leas      -5,s
                    ldd       <curcurse
                    std       1,s
                    ldd       #$0002
                    pshs      a,b
                    lbsr      curset
                    leas      2,s
                    ldd       >UmeData_reserved_03CB
                    pshs      a,b
                    lbsr      i2hexc
                    leas      2,s
                    stb       ,s
                    cmpb      #$41
                    blt       a77@
                    ldb       ,s
                    sex
                    addd      #$0020
                    stb       ,s
a77@                ldb       ,s                  the part as one hex character: the radio digit for s9c
                    stb       >MenuStates
                    clr       >MenuStates+1
                    ldd       #$0008              s9c menu 8 = the part picker
                    pshs      d
                    ldd       #'M
                    pshs      d
                    ldd       #'C
                    pshs      d
                    lbsr      soowee
                    leas      6,s
                    stb       ,s
                    lbsr      wkill
                    ldb       ,s
                    cmpb      #$0D
                    beq       b77@
                    ldb       ,s
                    sex
                    pshs      a,b
                    lbsr      hexc2i
                    leas      2,s
                    std       >UmeData_reserved_03CB
b77@                leas      5,s
                    puls      u,pc
* optmen (was L68D9): menu $0B keys 'naishcbtpdmlefr?' toggling <$4F,<$4D,<$4E,<pitcarry-<$4A,<$7A,<$78,<$43,<$3B, sound, rgbmen, printset, prefio
optmen         pshs      a,b,x,u
                    ldd       <curcurse
                    std       ,s
                    ldd       #$0002
                    pshs      a,b
                    lbsr      curset
                    leas      2,s
a78@                ldb       9,s
                    bne      b78@
                    ldb       >UmeData_reserved_03C3
                    sex
                    pshs      a,b
                    ldb       <left
                    sex
                    pshs      a,b
                    ldb       <hires
                    sex
                    pshs      a,b
                    ldb       <pldebug
                    sex
                    pshs      a,b
                    ldb       <thick
                    sex
                    pshs      a,b
                    ldb       <beam
                    sex
                    pshs      a,b
                    ldb       <compact
                    sex
                    pshs      a,b
                    ldb       <halfstaf
                    sex
                    pshs      a,b
                    ldb       <sticky
                    sex
                    pshs      a,b
                    ldb       <snap
                    sex
                    pshs      a,b
                    ldb       <pitcarry
                    sex
                    pshs      a,b
                    leax      >fmtElevenInts,pcr
                    pshs      x
                    ldx       #MenuStates
                    pshs      x
                    lbsr      SPrintf
                    leas      <$1A,s
                    ldd       #$0004              s9c menu 4 = options
                    pshs      d
                    ldd       #'M
                    pshs      d
                    ldd       #'C
                    pshs      d
                    lbsr      soowee
                    leas      6,s
                    stb       9,s
* Printer setup ('p') and Screen colors ('s') open over the Opts menu: the key becomes upper case ('P',
* 'S') and the Opts window is closed after the answer.
                    cmpb      #'p
                    beq       opk0@
                    cmpb      #'s                 Screen colors: over the Opts menu too
                    bne       opk@
opk0@               subb      #'a-'A              upper case marks the Opts menu still up: 'P', 'S'
                    stb       9,s
                    bra       b78@
opk@                lbsr      wkill
b78@                ldb       9,s
                    sex
                    tfr       d,x
                    lbra      at78@
c78@                ldb       <halfstaf
                    bne       d78@
                    ldd       #$0001
                    bra       e78@
d78@                clra
                    clrb
e78@                stb       <halfstaf
                    bra       l78@
f78@                ldb       <beam
                    beq       j78@
                    clra
                    clrb
                    bra       k78@
g78@                ldb       <thick
                    bne       h78@
                    ldd       #$0001
                    bra       i78@
h78@                clra
                    clrb
i78@                stb       <thick
                    beq       l78@
j78@                ldd       #$0001
k78@                stb       <beam
l78@                leax      4,s
                    bra      ab78@
m78@                ldb       <pitcarry
                    bne       n78@
                    ldd       #$0001
                    bra       o78@
n78@                clra
                    clrb
o78@                stb       <pitcarry
                    lbra      as78@
p78@                ldb       <snap
                    bne       q78@
                    ldd       #$0001
                    bra       r78@
q78@                clra
                    clrb
r78@                stb       <snap
                    lbra      as78@
s78@                ldb       <sticky
                    bne       t78@
                    ldd       #$0001
                    bra       u78@
t78@                clra
                    clrb
u78@                stb       <sticky
                    lbra      as78@
v78@                lbsr      printset
                    lbra      au78@
opp@                lbsr      printset            over the Opts menu
                    lbsr      wkill               then the Opts menu closes
                    lbra      au78@
w78@                lbsr      rgbmen              over the Opts menu
                    lbsr      wkill               then the Opts menu closes; the loop reopens it
                    bra      as78@
x78@                ldb       9,s
                    sex
                    pshs      a,b
                    lbsr      prefio
                    leas      2,s
                    lbsr      MidiApplyMix
                    lbra      au78@
y78@                ldb       <compact
                    bne       z78@
                    ldd       #$0001
                    bra       aa78@
z78@                clra
                    clrb
aa78@               stb       <compact
                    bra       ac78@
ab78@               leas      -4,x
ac78@               ldd       #$0001
                    stb       <rfr_scr
                    bra      as78@
ad78@               ldb       <pldebug
                    bne       ae78@
                    ldd       #$0001
                    bra       af78@
ae78@               clra
                    clrb
af78@               stb       <pldebug
                    bra       as78@
ag78@               ldb       <left
                    bne       ah78@
                    ldd       #$0001
                    bra       ai78@
ah78@               clra
                    clrb
ai78@               stb       <left
                    bra       am78@
aj78@               ldb       <hires
                    bne       ak78@
                    ldd       #$0001
                    bra       al78@
ak78@               clra
                    clrb
al78@               stb       <hires
am78@               lbsr      setmouse
                    bra       as78@
an78@               ldb       >UmeData_reserved_03C3
                    bne       ao78@
                    ldd       #$0001
                    bra       ap78@
ao78@               clra
                    clrb
ap78@               stb       >UmeData_reserved_03C3
                    bra       as78@
aq78@               lbsr      report
                    lbra      au78@
ar78@               lbsr      bell
as78@               clra
                    clrb
                    stb       9,s
                    lbra      au78@
at78@               cmpx      #$000D
                    lbeq      au78@
                    cmpx      #'h                 ditHered staff
                    lbeq      c78@
                    cmpx      #$0062
                    lbeq      f78@
                    cmpx      #$0074
                    lbeq      g78@
                    cmpx      #$006E
                    lbeq      m78@
                    cmpx      #$0061
                    lbeq      p78@
                    cmpx      #$0069
                    lbeq      s78@
                    cmpx      #$0070
                    lbeq      v78@
                    cmpx      #'P                 Printer setup chosen from the Opts menu (still up)
                    lbeq      opp@
                    cmpx      #'S                 Screen colors: the Opts menu still up under it
                    lbeq      w78@
                    cmpx      #$0066
                    lbeq      x78@
                    cmpx      #$0072
                    lbeq      x78@
                    cmpx      #$0063
                    lbeq      y78@
                    cmpx      #$0064
                    lbeq      ad78@
                    cmpx      #$006C
                    lbeq      ag78@
                    cmpx      #'m                 hi-res Mouse
                    lbeq      aj78@
                    cmpx      #$0065
                    lbeq      an78@
                    cmpx      #$003F
                    lbeq      aq78@
                    cmpx      #$002F
                    lbeq      aq78@
                    cmpx      #$006F
                    lbeq      as78@
                    lbra      ar78@
au78@               ldb       9,s
                    lbeq      a78@
                    ldd       ,s
                    pshs      a,b
                    lbsr      curset
                    leas      2,s
                    leas      4,s
                    puls      u,pc
* printset (was L6AE7): menu $0E keys '01234567ft' setting port number <doesff and f/t flag <automarg
printset      pshs      u
                    leas      -3,s
                    ldd       <curcurse
                    std       1,s
                    ldd       #$0002
                    pshs      a,b
                    lbsr      curset
                    leas      2,s
a79@                ldb       <automarg
                    sex
                    pshs      a,b
                    ldb       <doesff
                    sex
                    pshs      a,b
                    ldb       <printype
                    sex
                    addd      #$0031
                    pshs      a,b
                    leax      >fmtPortMenu,pcr
                    pshs      x
                    ldx       #MenuStates
                    pshs      x
                    lbsr      SPrintf
                    leas      10,s
                    ldd       #$0005              s9c menu 5 = printer setup
                    pshs      d
                    ldd       #'M
                    pshs      d
                    ldd       #'C
                    pshs      d
                    lbsr      soowee
                    leas      6,s
                    stb       ,s
                    lbsr      wkill
                    ldb       ,s
                    cmpb      #$30
                    blt       e79@
                    ldb       ,s
                    cmpb      #$37
                    bgt       e79@
                    ldb       ,s
                    sex
                    addd      #$FFD0
                    stb       <printype
                    ldb       <printype
                    cmpb      #$03
                    ble       b79@
                    ldb       <printype
                    cmpb      #$07
                    bne       c79@
b79@                clra
                    clrb
                    stb       <automarg
                    bra       d79@
c79@                ldd       #$0001
d79@                stb       <doesff
                    bra      a79@
e79@                ldb       ,s
                    cmpb      #$0D
                    beq       l79@
                    ldb       ,s
                    cmpb      #$66
                    bne       h79@
                    ldb       <doesff
                    bne       f79@
                    ldd       #$0001
                    bra       g79@
f79@                clra
                    clrb
g79@                stb       <doesff
                    lbra      a79@
h79@                ldb       ,s
                    cmpb      #$74
                    bne       k79@
                    ldb       <automarg
                    bne       i79@
                    ldd       #$0001
                    bra       j79@
i79@                clra
                    clrb
j79@                stb       <automarg
                    lbra      a79@
k79@                lbsr      bell
                    lbra      a79@
l79@                ldd       1,s
                    pshs      a,b
                    lbsr      curset
                    leas      2,s
                    leas      3,s
                    puls      u,pc
* prefio (was L6BB7): 'f' creates and writes SYS/UM3.Init (25 bytes at $0037 + 13 at $03B7), otherwise reads it; on read also sets colors, setmouse and s9w 's'
prefio          pshs      a,b,u
                    ldb       7,s
                    cmpb      #$66
                    bne       a80@
                    leau      >WritePath,pcr
                    ldd       #$000B
                    pshs      a,b
                    leax      >pathInitFile1,pcr
                    pshs      x
                    lbsr      CreateFile
                    leas      4,s
                    std       ,s
                    cmpd      #$0002
                    bge       b80@
                    leax      >msgCantCreateFile,pcr
                    pshs      x
                    lbsr      alert
                    lbra      d80@
a80@                leau      >ReadPath,pcr
                    ldd       #$0001
                    pshs      a,b
                    leax      >pathInitFile2,pcr
                    pshs      x
                    lbsr      OpenPath
                    leas      4,s
                    std       ,s
                    cmpd      #$0002
                    blt      e80@
b80@                ldd       #$0019
                    pshs      a,b
                    ldx       #$0037
                    pshs      x
                    ldd       4,s
                    pshs      a,b
                    jsr       ,u
                    leas      6,s
                    ldd       #$000D
                    pshs      a,b
                    ldx       #$03B7
                    pshs      x
                    ldd       4,s
                    pshs      a,b
                    jsr       ,u
                    leas      6,s
                    ldb       7,s
                    cmpb      #$72
                    bne       c80@
                    ldd       <forergb
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    lbsr      pal
                    leas      4,s
                    ldd       <backrgb
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    lbsr      pal
                    leas      4,s
                    lbsr      setmouse
                    ldb       <UmeData_reserved_0051
                    beq       c80@
                    ldb       >UmeData_reserved_03B8
                    beq       c80@
                    ldd       #$0073
                    pshs      a,b
                    ldd       #$0057
                    pshs      a,b
                    lbsr      soowee              (soowee puts breaker back)
                    leas      4,s
c80@                ldd       ,s
                    pshs      a,b
                    lbsr      ClosePath
d80@                leas      2,s
e80@                leas      2,s
                    puls      u,pc
* rgbmen (was L6C7D): menu $10 keys 'zofarRgGbB'/'bgrBGR' editing colors <forergb/<backrgb and sending pal
rgbmen           pshs      u
                    leas      -14,s
                    ldd       #$0001
                    stb       5,s
                    clra
                    clrb
                    stb       ,s
                    leax      >strColorKeys,pcr
                    stx       3,s
                    ldd       <curcurse
                    std       12,s
                    ldd       #$0002
                    pshs      a,b
                    lbsr      curset
                    leas      2,s
                    ldd       <forergb
                    std       10,s
                    ldd       <backrgb
                    std       8,s
a81@                ldb       5,s
                    beq       b81@
                    leau      10,s
                    leax      8,s
                    bra       c81@
b81@                leau      8,s
                    leax      10,s
c81@                stx       6,s
                    ldd       ,u
                    clra
                    andb      #$08
                    addd      #$0030
                    pshs      a,b
                    ldd       ,u
                    clra
                    andb      #$01
                    addd      #$0030
                    pshs      a,b
                    ldd       ,u
                    clra
                    andb      #$10
                    addd      #$0030
                    pshs      a,b
                    ldd       ,u
                    clra
                    andb      #$02
                    addd      #$0030
                    pshs      a,b
                    ldd       ,u
                    clra
                    andb      #$20
                    addd      #$0030
                    pshs      a,b
                    ldd       ,u
                    clra
                    andb      #$04
                    addd      #$0030
                    pshs      a,b
                    ldb       <$11,s
                    sex
                    pshs      a,b
                    ldd       #$0032
                    subd      ,s++
                    pshs      a,b
                    ldd       <pct7
                    pshs      a,b
                    ldx       #MenuStates
                    pshs      x
                    lbsr      SPrintf
                    leas      <$12,s
                    ldd       #$0006              s9c menu 6 = colors
                    pshs      d
                    ldd       #'M
                    pshs      d
                    ldd       #'C
                    pshs      d
                    lbsr      soowee
                    leas      6,s
                    stb       ,s
                    lbsr      wkill
                    ldb       ,s
                    sex
                    tfr       d,x
                    bra      m81@
d81@                ldd       10,s
                    std       <forergb
                    ldd       8,s
                    std       <backrgb
                    clra
                    clrb
                    stb       ,s
                    bra      n81@
e81@                clra
                    clrb
                    stb       ,s
                    ldd       <forergb
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    lbsr      pal
                    leas      4,s
                    ldd       <backrgb
                    pshs      a,b
                    clra
                    clrb
                    bra       l81@
f81@                ldd       #$0001
                    bra       h81@
g81@                clra
                    clrb
h81@                stb       5,s
                    bra      n81@
i81@                ldb       ,s
                    sex
                    pshs      a,b
                    ldd       5,s
                    pshs      a,b
                    lbsr      StrIndex
                    leas      4,s
                    std       1,s
                    beq       j81@
                    ldd       ,u
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       5,s
                    subd      7,s
                    lbsr      ShiftLeft
                    eora      ,s+
                    eorb      ,s+
                    std       ,u
                    bra       k81@
j81@                lbsr      bell
k81@                ldd       ,u
                    pshs      a,b
                    ldb       7,s
                    sex
l81@                pshs      a,b
                    lbsr      pal
                    leas      4,s
                    bra       n81@
m81@                cmpx      #$006B
                    beq      d81@
                    cmpx      #$006F
                    beq      d81@
                    cmpx      #$000D
                    beq      e81@
                    cmpx      #$0066
                    beq      f81@
                    cmpx      #$0061
                    beq      g81@
                    bra      i81@
n81@                ldb       ,s
                    lbne      a81@
                    ldd       12,s
                    pshs      a,b
                    lbsr      curset
                    leas      2,s
                    leas      14,s
                    puls      u,pc
* textmenu (was L6DEA): Vector $0375: scrolling list chooser used by the environment, instrument and volume prompts
textmenu        pshs      u
                    leas      <-$20,s
                    ldd       <curcurse
                    std       <$1E,s
                    ldd       <curcurse
                    cmpd      #$0006
                    beq       o81@
                    ldd       <curcurse
                    cmpd      #$0010
                    beq       o81@
                    ldd       <curcurse
                    cmpd      #$0015
                    beq       o81@
                    ldd       #$0001
                    pshs      a,b
                    lbsr      curset
                    leas      2,s
o81@                clra
                    clrb
                    std       6,s
                    std       12,s
                    lbsr      waitmouse
                    ldd       6,s
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    lbsr      DrawPointer
                    leas      4,s
                    ldd       <$26,s
                    pshs      a,b
                    ldd       <$2E,s
                    pshs      a,b
                    ldd       #$0007
                    lbsr      MulInt
                    addd      #$0004
                    nega
                    negb
                    sbca      #$00
                    addd      ,s++
                    std       <$26,s
                    ldd       <$2E,s
                    pshs      a,b
                    ldd       #$0007
                    lbsr      MulInt
                    pshs      a,b
                    ldd       <$28,s
                    subd      ,s++
                    addd      #$0002
                    std       10,s
                    ldd       <$2A,s
                    pshs      a,b
                    ldd       <$2A,s
                    lbsr      MulInt
                    addd      <$24,s
                    addd      #$FFFE
                    std       <$1A,s
                    ldd       #$FFFF
                    std       2,s
                    clra
                    clrb
                    std       <$16,s
p81@                leax      8,s
                    pshs      x
                    leax      <$10,s
                    pshs      x
                    lbsr      kmouse
                    leas      4,s
                    stb       1,s
                    ldd       14,s
                    asra
                    rorb
                    asra
                    rorb
                    asra
                    rorb
                    std       <$1C,s
                    ldd       <$26,s
                    pshs      a,b
                    ldd       <$1C,s
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    ldd       <$2A,s
                    pshs      a,b
                    ldd       <$10,s
                    pshs      a,b
                    ldd       <$26,s
                    pshs      a,b
                    lbsr      inrect
                    leas      12,s
                    stb       ,s
                    beq       q81@
                    ldd       <$26,s
                    subd      8,s
                    pshs      a,b
                    ldd       #$0007
                    lbsr      DivInt
                    std       <$18,s
                    pshs      a,b
                    ldd       #$0007
                    lbsr      MulInt
                    pshs      a,b
                    ldd       <$28,s
                    subd      ,s++
                    addd      #$FFFB
                    std       4,s
                    ldd       <$1C,s
                    subd      <$24,s
                    pshs      a,b
                    ldd       <$2A,s
                    lbsr      DivInt
                    std       <$10,s
                    pshs      a,b
                    ldd       <$2A,s
                    lbsr      MulInt
                    addd      <$24,s
                    std       <$14,s
q81@                ldb       1,s
                    beq       s81@
                    ldb       1,s
                    ble       r81@
                    ldb       1,s
                    sex
                    nega
                    negb
                    sbca      #$00
                    std       <$16,s
                    lbra      y81@
r81@                ldb       ,s
                    lbne      y81@
                    ldb       <$31,s
                    lbne      y81@
                    lbsr      waitmouse
                    lbra      p81@
s81@                ldd       14,s
                    cmpd      12,s
                    bne       t81@
                    ldd       8,s
                    cmpd      6,s
                    lbeq      p81@
t81@                ldd       6,s
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    lbsr      DrawPointer
                    leas      4,s
                    ldd       8,s
                    std       6,s
                    pshs      a,b
                    ldd       <$10,s
                    std       14,s
                    pshs      a,b
                    lbsr      DrawPointer
                    leas      4,s
                    ldb       ,s
                    bne       v81@
                    ldd       2,s
                    blt       u81@
                    ldd       2,s
                    addd      #$0005
                    pshs      a,b
                    ldd       <$14,s
                    addd      <$2A,s
                    addd      #$FFFE
                    pshs      a,b
                    ldd       6,s
                    addd      #$FFFF
                    pshs      a,b
                    ldd       <$18,s
                    pshs      a,b
                    ldd       #$0003
                    pshs      a,b
                    lbsr      SendMarkPacket
                    leas      10,s
                    ldd       #$FFFF
                    std       2,s
u81@                lbra      p81@
v81@                ldd       4,s
                    cmpd      2,s
                    bne       w81@
                    ldd       <$14,s
                    cmpd      <$12,s
                    lbeq      p81@
w81@                ldd       2,s
                    blt       x81@
                    ldd       2,s
                    addd      #$0005
                    pshs      a,b
                    ldd       <$14,s
                    addd      <$2A,s
                    addd      #$FFFE
                    pshs      a,b
                    ldd       6,s
                    addd      #$FFFF
                    pshs      a,b
                    ldd       <$18,s
                    pshs      a,b
                    ldd       #$0003
                    pshs      a,b
                    lbsr      SendMarkPacket
                    leas      10,s
x81@                ldd       4,s
                    addd      #$0005
                    pshs      a,b
                    ldd       <$16,s
                    addd      <$2A,s
                    addd      #$FFFE
                    pshs      a,b
                    ldd       8,s
                    addd      #$FFFF
                    pshs      a,b
                    ldd       <$1A,s
                    pshs      a,b
                    ldd       #$0003
                    pshs      a,b
                    lbsr      SendMarkPacket
                    leas      10,s
                    ldd       4,s
                    std       2,s
                    ldd       <$14,s
                    std       <$12,s
                    lbra      p81@
y81@                ldd       6,s
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    lbsr      DrawPointer
                    leas      4,s
                    ldd       <$1E,s
                    pshs      a,b
                    lbsr      curset
                    leas      2,s
                    ldb       ,s
                    beq       aa81@
                    ldd       2,s
                    blt       z81@
                    ldd       2,s
                    addd      #$0005
                    pshs      a,b
                    ldd       <$14,s
                    addd      <$2A,s
                    addd      #$FFFE
                    pshs      a,b
                    ldd       6,s
                    addd      #$FFFF
                    pshs      a,b
                    ldd       <$18,s
                    pshs      a,b
                    ldd       #$0003
                    pshs      a,b
                    lbsr      SendMarkPacket
                    leas      10,s
z81@                ldd       <$16,s
                    bne       aa81@
                    ldd       <$18,s
                    pshs      a,b
                    ldd       <$2C,s
                    lbsr      MulInt
                    addd      <$10,s
                    addd      #$0001
                    std       <$16,s
aa81@               ldd       <$16,s
                    leas      <$20,s
                    puls      u,pc
* strCmdMenuKeys (was L706B): 'pksnufh9?drq' randmen key letters
strCmdMenuKeys      fcc       /pksnufh9?drq/
                    fcb       $00
* msgRestartUmuse (was L7078): CR ' Restart Studio-9? '
msgRestartUmuse     fcb       $0D
                    fcc       / Restart Studio-9? /
                    fcb       $00
* msgEnterBlankLine (was L708A): CR '(a blank line leaves OS-9)'
msgEnterBlankLine   fcb       $0D
                    fcc       /(a blank line leaves OS-9)/
                    fcb       $0D,$0D,$00
* strOs9Prompt (was L70AE): 'OS9: ' shell command prompt
strOs9Prompt        fcc       /OS9: /
                    fcb       $00
* fmtErrorNum (was L70B4): 'ERROR %3d.'
fmtErrorNum         fcc       /ERROR %3d./
                    fcb       $0D,$00
* msgHitBreak (was L70C0): ' Hit BREAK to stop,  or ^C to stop and go there.'
msgHitBreak         fcb       $0C
                    fcc       / Hit BREAK to stop,/
                    fcb       $0D
                    fcc       / or ^C to stop and go there./
                    fcb       $0D,$00
* msgTooLate (was L70F3): 'Too late!' (undo no longer possible)
msgTooLate          fcb       $0D
                    fcc       /Too late!/
                    fcb       $0D,$00
* msgNeedDriveWire (was L70FF): 'Needs DriveWire4 + Internet'
msgNeedDriveWire    fcc       /Needs DriveWire4 + Internet/
                    fcb       $0D,$00
* msgNotYet (was L712F): 'Not yet.'
msgNotYet           fcc       /Not yet./
                    fcb       $0D,$00
* fmtEightInts (was L7139): '%d%d%d%d%d%d%d%d' option flags shown in filtmen
fmtEightInts        fcc       /%d%d%d%d%d%d%d%d/
                    fcb       $00
* strSetupMenuKeys (was L714A): ' enraofc uml' filtmen key letters
strSetupMenuKeys    fcc       / enraofc uml/
                    fcb       $00
* strChannelKeys (was L7157): '123456789abcdefg' MIDI channel keys
strChannelKeys      fcc       /123456789abcdefg/
                    fcb       $00
* fmtElevenInts (was L7168): '%d%d%d%d%d%d%d%d%d%d%d' option flags shown in optmen
fmtElevenInts       fcc       /%d%d%d%d%d%d%d%d%d%d%d/
                    fcb       $00
* strOptionMenuKeys (was L717F): 'naishcbtpdmlefr?' optmen key letters (h dithered staff, m hi-res mouse)
strOptionMenuKeys   fcc       /naishcbtpdmlefr?/
                    fcb       $0D,$00
* fmtPortMenu (was L7191): '%c%d%d' printset status
fmtPortMenu         fcc       /%c%d%d/
                    fcb       $00
* strPortMenuKeys (was L7198): '01234567ft' printset key letters
strPortMenuKeys     fcb       $0D
                    fcc       /01234567ft/
                    fcb       $0D,$00
* pathInitFile1 (was L71A5): '/dd/SYS/UM3.Init', the settings file (created for writing)
pathInitFile1       fcb       $2F
                    fcc       /dd/
                    fcb       $2F
                    fcc       /SYS/
                    fcb       $2F
                    fcc       /UM3.Init/
                    fcb       $00
* msgCantCreateFile (was L71B6): ' Can't create file!'
msgCantCreateFile   fcc       / Can't create file!/
                    fcb       $00
* pathInitFile2 (was L71CA): '/dd/SYS/UM3.Init', the settings file (opened for reading)
pathInitFile2       fcb       $2F
                    fcc       /dd/
                    fcb       $2F
                    fcc       /SYS/
                    fcb       $2F
                    fcc       /UM3.Init/
                    fcb       $00
* strColorKeys (was L71DB): 'bgrBGR' color component keys
strColorKeys        fcc       /bgrBGR/
                    fcb       $00
* strColorMenuKeys (was L71E2): 'zofarRgGbB' rgbmen key letters
strColorMenuKeys    fcc       /zofarRgGbB/
                    fcb       $0D,$00
* getempty (was L71EE): if the buffer is empty: prompt box, printf(fmt), gets into it; returns 1 when non-empty; vector $03A5
getempty       pshs      u
                    ldb       [<$04,s]
                    bne       a82@
                    ldb       9,s
                    sex
                    pshs      a,b
                    lbsr      dialogue
                    leas      2,s
                    ldd       6,s
                    pshs      a,b
                    lbsr      Printf
                    leas      2,s
                    ldd       4,s
                    pshs      a,b
                    lbsr      gets
                    leas      2,s
                    lbsr      wkill
a82@                ldb       [<$04,s]
                    lbeq      RetBoolFalse
                    ldd       #$0001
                    lbra      RetBoolDone
* prmenu (was L7221): menu(n), '  Choice: ' then charmaus into the buffer
prmenu          pshs      u
                    lbsr      flush         flush (it ends with a CR) before waiting for input
                    ldd       4,s
                    pshs      a,b
                    lbsr      menu
                    leas      2,s
                    lbsr      waitmouse
                    leax      >strChoicePrompt,pcr
                    pshs      x
                    lbsr      Printf
                    leas      2,s
                    ldd       #$0001
                    pshs      a,b
                    lbsr      alcurset
                    leas      2,s
                    ldd       6,s
                    lbeq      PulsUAndRet
                    ldd       6,s
                    pshs      a,b
                    lbsr      charmaus
                    lbra      PopWordThenRet
                    fcs       /4@2h/
                    fcb       $AF,$EC,$E8,$57,$34,$06,$EC,$E8
                    fcb       $57,$34,$06,$17,$1A,$03
                    fcs       /2d0d/
                    fcb       $34,$10,$17,$EC,$B3,$32,$62,$E6
                    fcb       $E4,$26,$06,$EC,$E8,$57,$16,$02
                    fcb       $F9,$30,$E4,$34,$10,$17,$1F,$A1
                    fcb       $16,$02,$71
* ClampRange (was L7285): returns v clamped to lo..hi
ClampRange          pshs      u
                    ldd       4,s
                    cmpd      6,s
                    bge       a83@
                    ldd       6,s
                    puls      u,pc
a83@                ldd       4,s
                    cmpd      8,s
                    ble       b83@
                    ldd       8,s
                    puls      u,pc
b83@                ldd       4,s
                    puls      u,pc
* hexc2i (was L72A1): '0'-'9' -> 0-9, 'a'-'g' -> 10-16, else 0
hexc2i         pshs      u
                    ldb       5,s
                    sex
                    subd      #$0030
                    stb       5,s
                    blt       a84@
                    ldb       5,s
                    cmpb      #$09
                    bgt       a84@
                    ldb       5,s
                    sex
                    puls      u,pc
a84@                ldb       5,s
                    sex
                    subd      #$0031
                    stb       5,s
                    lblt      RetBoolFalse
                    ldb       5,s
                    cmpb      #$06
                    lbgt      RetBoolFalse
                    ldb       5,s
                    sex
                    addd      #$000A
                    puls      u,pc
* i2hexc (was L72D4): n&$1F -> '0'-'9' or 'A'..
i2hexc         pshs      u
                    ldd       4,s
                    clra
                    andb      #$1F
                    std       4,s
                    cmpd      #$0009
                    bgt       a85@
                    ldd       4,s
                    addd      #$0030
                    puls      u,pc
a85@                ldd       4,s
                    addd      #$0037
                    puls      u,pc
* fmarks (was L7301): scans markers for subtypes $0D '[', $0E ']' and $0F, storing their indexes (-1 if absent); vector $0385
fmarks    pshs      a,b,u
                    ldd       #$FFFF
                    std       [<$08,s]
                    std       [<$0A,s]
                    std       [<$06,s]
                    clra
                    clrb
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    bra       g86@
a86@                ldb       ,u
                    bne       f86@
                    ldb       5,u
                    sex
                    std       ,s
                    tfr       d,x
                    bra       e86@
b86@                ldd       <curind
                    std       [<$06,s]
                    bra       f86@
c86@                ldd       <curind
                    std       [<$08,s]
                    bra       f86@
d86@                ldd       <curind
                    std       [<$0A,s]
                    bra       f86@
e86@                cmpx      #$000D
                    beq       b86@
                    cmpx      #$000E
                    beq       c86@
                    cmpx      #$000F
                    beq       d86@
f86@                lbsr      plusplus
g86@                tfr       d,u
                    ldd       <curind
                    cmpd      <nevents
                    blt       a86@
* PopWordThenRet (was L7357): fmarks' exit dropping its local word; prmenu lbra's here after charmaus
PopWordThenRet      leas      2,s
* PulsUAndRet (was L7359): Bare puls u,pc exit; prmenu lbeq's here when its buffer arg is 0, PopWordThenRet falls in
PulsUAndRet         puls      u,pc
* fixmarx (was L735B): fmarks then 'No [.  From start? ' / 'No ].  To end? '; vector $039B
fixmarx       pshs      u
                    ldd       8,s
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    bsr      fmarks
                    leas      6,s
                    ldd       [<$04,s]
                    bge       a87@
                    leax      >msgNoOpenBracket,pcr
                    pshs      x
                    lbsr      yesno
                    std       ,s++
                    beq       RetBoolFalse
                    clra
                    clrb
                    std       [<$04,s]
a87@                ldd       [<$06,s]
                    bge       b87@
                    leax      >msgNoCloseBracket,pcr
                    pshs      x
                    lbsr      yesno
                    std       ,s++
                    beq       RetBoolFalse
                    ldd       <nevents
                    addd      #$FFFF
                    std       [<$06,s]
b87@                ldd       #$0001
                    puls      u,pc
* anybar (was L73A4): true for a part-0 marker with subtype <= 6 (barline kinds)
anybar          pshs      u
                    ldb       [<$04,s]
                    bne       RetBoolFalse
                    ldx       4,s
                    ldb       5,x
                    cmpb      #$06
                    bgt       RetBoolFalse
                    ldd       #$0001
                    bra       RetBoolDone
* RetBoolFalse (was L73B8): Shared 'return 0' for getempty, fixmarx, anybar and hexc2i's range checks
RetBoolFalse        clra
                    clrb
* RetBoolDone (was L73BA): Shared return once D holds the result; getempty and anybar branch here with D=1
RetBoolDone         puls      u,pc
* instinit (was L73BC): fills 64 words at $075F with $80 and clears the first byte of 64 16-byte records at $07EB
instinit      pshs      u
                    ldu       #$0000
                    bra       b88@
a88@                tfr       u,d
                    aslb
                    rola
                    ldx       #$075F
                    leax      d,x
                    ldd       #$0080
                    std       ,x
                    tfr       u,d
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #$07EB
                    leax      d,x
                    clra
                    clrb
                    stb       ,x
                    leau      1,u
b88@                cmpu      #$0040
                    blt       a88@
                    puls      u,pc
* mainmen (was L73EE): top-level key switch. Menu-bar private codes $10-$15 select /s0, /s1 or
* /x0-/x3 and immediately open Read Score.
mainmen     pshs      u
                    leas      <-$51,s
                    ldb       <$56,s
                    lbeq      u89@
                    ldb       <$56,s
                    sex
                    tfr       d,x
                    lbra      s89@
a89@                clra
                    clrb
                    lbra      r89@
b89@                ldd       #$0069
                    pshs      a,b
                    ldd       #$004D
                    lbra      n89@
* The Score button (the bar's 'l') opens the score editor (s9l 'm'). Its menu says what happens on the
* way back (WizForce): 2 = Ready, nothing touched; 3 = Wizard, newscore with the layout prompts; 0 = New
* Score, the score built from the settings as they stand (time and key signature, staves, parts), asked
* first when the score already has music.
c89@                clra
                    clrb
                    pshs      a,b
                    ldd       #$006D
                    pshs      a,b
                    ldd       #$004C
                    pshs      a,b
                    lbsr      soowee              the score editor
                    leas      6,s
                    ldb       <WizForce
                    clr       <WizForce
                    cmpb      #$02
                    bne       c89w@
* Ready: the editor refilled the parts' rests on its way out (KeyExit); a score with no bars yet gets
* them here (scorebars, no reset); one with music is left as it is.
                    ldd       <nevents
                    cmpd      #$0001
                    lbgt      t89@
                    ldd       <nparts
                    lbeq      t89@
                    lbsr      scorebars
                    lbra      t89@
c89w@               equ       *
                    cmpb      #$03
                    bne       c89n@
                    ldb       #$01
                    stb       <WizForce           the wizard: the prompts run without the question
                    bra       d89@
c89n@               ldd       <nevents
                    cmpd      #$0001
                    ble       c89n1@
                    leax      >msgWillClearScore,pcr
                    pshs      x
                    lbsr      yesno
                    std       ,s++
                    lbeq      t89@
c89n1@              ldd       <nparts
                    lbeq      t89@                no part to hold rests
                    lbsr      scorereset          the events back to the first one
                    lbsr      scorebars           the bars and rests from the settings as they stand now
                    lbra      t89@
d89@                ldd       #$0001
                    pshs      a,b
                    lbsr      newscore
                    lbra      p89@
e89@                clra
                    clrb
                    pshs      a,b
                    lbsr      dialogue
                    leas      2,s
                    ldb       <$56,s
                    stb       ,s
                    ldb       <$56,s
                    sex
                    pshs      a,b
                    leax      >fmtChar,pcr
                    pshs      x
                    lbsr      Printf
                    leas      4,s
                    leax      <$51,s
                    bra       h89@
f89@                leas      <-$51,x
g89@                leax      ,s
                    pshs      x
                    ldd       #$0009
                    pshs      a,b
                    lbsr      prmenu
                    leas      4,s
                    ldb       ,s
                    cmpb      #$0D
                    bne       i89@
                    lbra      t89@
                    fcb       $20,$03
h89@                leas      <-$51,x
i89@                leax      1,s
                    pshs      x
                    lbsr      gets
                    leas      2,s
                    ldb       1,s
                    cmpb      #$3F
                    bne       j89@
                    lbsr      wkill
                    leax      <$51,s
                    bra       f89@
j89@                leax      ,s
                    pshs      x
                    ldd       #$0067
                    pshs      a,b
                    ldd       #$0054
                    pshs      a,b
                    lbsr      soowee
                    leas      6,s
                    lbra      t89@
k89@                lbsr      iomen
                    lbra      t89@
l89@                ldd       #$006D
                    pshs      a,b
                    ldd       #$004D
                    pshs      a,b
                    lbsr      soowee
                    leas      4,s
                    leax      >breaker,pcr
                    pshs      x
                    lbsr      SetIntercept
                    bra       p89@
m89@                ldd       #$0062
                    pshs      a,b
                    ldd       #$0054
n89@                pshs      a,b
                    lbsr      soowee
                    leas      4,s
                    lbra      t89@
o89@                ldb       <$56,s
                    sex
                    pshs      a,b
                    lbsr      optmen
p89@                leas      2,s
                    lbra      t89@
q89@                ldb       <$56,s
                    sex
r89@                pshs      a,b
                    lbsr      randmen
                    leas      2,s
                    lbra      v89@
s89@                cmpx      #$000D
                    lbeq      t89@
                    cmpx      #$0003
                    lbeq      t89@
                    cmpx      #$0005
                    lbeq      t89@
                    cmpx      #$0010
                    blo       mainNormalKey
                    cmpx      #$0015
                    lbls      MenuReadDrive
mainNormalKey       equ       *
                    cmpx      #$0072
                    lbeq      a89@
                    cmpx      #$0020
                    lbeq      a89@
                    cmpx      #$0069
                    lbeq      b89@
                    cmpx      #$006C
                    lbeq      c89@
                    cmpx      #$0047
                    lbeq      e89@
                    cmpx      #$0067
                    lbeq      e89@
                    cmpx      #$0007
                    lbeq      g89@
                    cmpx      #$0066
                    lbeq      k89@
                    cmpx      #$006D
                    lbeq      l89@
                    cmpx      #$0062
                    lbeq      m89@
                    cmpx      #$006F
                    lbeq      o89@
                    cmpx      #$0063
                    lbeq      o89@
                    cmpx      #$0064
                    lbeq      o89@
                    cmpx      #$0070
                    lbeq      q89@
                    lbra      q89@
MenuReadDrive       tfr       x,d                 private code $10-$15
                    pshs      a,b                 s9d receives this as a private command
                    ldd       #'D
                    pshs      a,b
                    lbsr      soowee
                    leas      4,s
* A score read through a drive shortcut gets what File > Read gives it: a redraw, reinit and the
* start-time check.
                    std       -2,s
                    beq       t89@                nothing was read
                    ldb       #1
                    stb       <rfr_scr
                    lbsr      reinit
                    lbsr      AuditIndex          and the start-time check File > Read runs
t89@                lbsr      wkill
u89@                clra
                    clrb
v89@                leas      <$51,s
                    puls      u,pc
* exprmenu (was L7579): environment marker editor 'ivme  tgc<a^le': key signature, tempo, MIDI channel, instrument, volume list, clock, beats; inserts the marker via enter; vector $03A3
exprmenu       pshs      u
                    leas      >-$00BE,s
                    ldd       #$FFFF
                    std       <$12,s
                    ldd       >$00C2,s
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    tfr       d,u
                    ldb       ,u
                    sex
                    std       10,s
                    ldb       5,u
                    sex
                    std       6,s
                    leax      ,s
                    pshs      x
                    ldd       >$00C4,s
                    pshs      a,b
                    lbsr      fulltime
                    leas      2,s
                    lbsr      LongStore
                    ldd       10,s
                    lbne      d90@
                    ldd       6,s
                    cmpd      #$000B
                    bne      d90@
                    leax      >msgChangeKeySig,pcr
                    pshs      x
                    lbsr      yesno
                    std       ,s++
                    beq      d90@
                    ldb       6,u
                    sex
                    std       <$10,s
                    bge       a90@
                    leax      >strFlat,pcr
                    bra       b90@
a90@                leax      >strSharp,pcr
b90@                tfr       x,d
                    pshs      a,b
                    ldd       <$12,s
                    pshs      a,b
                    leax      >fmtCurrentlyNew,pcr
                    pshs      x
                    leax      <$73,s
                    pshs      x
                    lbsr      SPrintf
                    leas      8,s
                    clra
                    clrb
                    stb       <$1C,s
                    clra
                    clrb
                    pshs      a,b
                    leax      <$6F,s
                    pshs      x
                    leax      <$20,s
                    pshs      x
                    lbsr      getempty
                    leas      6,s
                    lbeq      br90@
                    ldd       #$0007
                    pshs      a,b
                    ldd       #$FFF9
                    pshs      a,b
                    leax      <$20,s
                    pshs      x
                    lbsr      AtoI
                    std       ,s
                    lbsr      ClampRange
                    leas      6,s
                    stb       6,u
                    ldd       #$0001
                    lbra      bt90@
                    fcb       $20,$04
c90@                leas      >-$00BE,x
d90@                clra
                    clrb
                    pshs      a,b
                    ldd       #$0003
                    pshs      a,b
                    lbsr      prmenu
                    leas      4,s
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$000E
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0012
                    pshs      a,b
                    ldd       #$00A0
                    pshs      a,b
                    ldd       #$001F
                    pshs      a,b
                    lbsr      textmenu
                    leas      14,s
                    stb       13,s
                    bge       e90@
                    ldb       13,s
                    sex
                    nega
                    negb
                    sbca      #$00
                    stb       12,s
                    stb       <$1C,s
                    bra       f90@
e90@                leax      >strEnvMenuKeys,pcr
                    tfr       x,d
                    pshs      a,b
                    ldb       15,s
                    sex
                    addd      ,s++
                    tfr       d,x
                    ldb       ,x
                    stb       12,s
f90@                ldx       #$01BE
                    pshs      x
                    ldb       14,s
                    sex
                    pshs      a,b
                    lbsr      FPutc
                    leas      4,s
                    ldb       12,s
                    cmpb      #$0D
                    bne       g90@
                    lbsr      wkill
                    lbra      br90@
g90@                ldb       12,s
                    cmpb      #$65
                    bne       h90@
                    lbsr      wkill
                    ldd       >$00C2,s
                    pshs      a,b
                    ldd       #$0065
                    pshs      a,b
                    ldd       #$0045
                    pshs      a,b
                    lbsr      soowee
                    leas      6,s
                    lbra      bt90@
h90@                ldx       #$0C11
                    pshs      x
                    leax      <$16,s
                    pshs      x
                    lbsr      CopyEvent
                    leas      4,s
                    ldd       2,s
                    std       <$15,s
                    ldb       13,s
                    bge       i90@
                    leax      <$1D,s
                    pshs      x
                    lbsr      gets
                    leas      2,s
                    bra       j90@
i90@                clra
                    clrb
                    stb       <$1D,s
j90@                lbsr      wkill
                    ldb       12,s
                    sex
                    tfr       d,x
                    lbra      bo90@
k90@                ldd       #$0019
                    std       4,s
                    ldd       10,s
                    bne       l90@
                    ldd       6,s
                    cmpd      #$0019
                    bne       l90@
                    ldd       >$00C2,s
                    std       <$12,s
l90@                clra
                    clrb
                    pshs      a,b
                    leax      >msgNewTempo,pcr
                    pshs      x
                    leax      <$21,s
                    pshs      x
                    lbsr      getempty
                    leas      6,s
                    lbeq      br90@
                    ldd       #$00F0
                    pshs      a,b
                    ldd       #$001E
                    pshs      a,b
                    leax      <$21,s
                    pshs      x
                    lbsr      AtoI
                    std       ,s
                    lbsr      ClampRange
                    leas      6,s
                    stb       <$17,s
                    lbra      bp90@
m90@                ldd       #$0022
                    std       4,s
                    ldb       12,s
                    cmpb      #$5E
                    beq       n90@
                    ldb       12,s
                    cmpb      #$37
                    bne       o90@
n90@                ldd       #$000E
                    lbra      ae90@
o90@                ldd       #$FFF2
                    lbra      ae90@
p90@                ldd       10,s
                    bne       q90@
                    ldd       6,s
                    cmpd      #$001A
                    bne       q90@
                    ldd       >$00C2,s
                    std       <$12,s
q90@                ldd       #$001A
                    std       4,s
                    bra       v90@
r90@                ldd       10,s
                    bne       s90@
                    ldd       6,s
                    cmpd      #$001C
                    bne       s90@
                    ldd       >$00C2,s
                    std       <$12,s
s90@                ldd       #$001C
                    std       4,s
                    ldb       12,s
                    cmpb      #$3C
                    bne       t90@
                    ldd       #$0001
                    bra       u90@
t90@                clra
                    clrb
u90@                stb       <$17,s
v90@                leax      >$00BE,s
                    lbra      bc90@
w90@                ldd       10,s
                    bne       x90@
                    ldd       6,s
                    cmpd      #$001D
                    bne       x90@
                    ldd       >$00C2,s
                    std       <$12,s
x90@                ldd       #$001D
                    std       4,s
                    ldb       12,s
                    cmpb      #$72
                    bne       y90@
                    ldd       #$0001
                    bra       z90@
y90@                clra
                    clrb
z90@                addd      #$0002
                    stb       <$17,s
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgToTempo,pcr
                    pshs      x
                    leax      <$21,s
                    pshs      x
                    lbsr      getempty
                    leas      6,s
                    lbeq      br90@
                    ldd       #$00F0
                    pshs      a,b
                    ldd       #$001E
                    pshs      a,b
                    leax      <$21,s
                    pshs      x
                    lbsr      AtoI
                    std       ,s
                    lbsr      ClampRange
                    leas      6,s
                    stb       <$1B,s
                    leax      >$00BE,s
                    lbra      bk90@
aa90@               ldd       10,s
                    bne       ab90@
                    ldd       6,s
                    cmpd      #$001B
                    bne       ab90@
                    ldd       >$00C2,s
                    std       <$12,s
ab90@               ldd       #$001B
                    std       4,s
                    leax      >msgClockOn,pcr
                    pshs      x
                    lbsr      yesno
                    leas      2,s
                    bra       ae90@
ac90@               ldd       10,s
                    bne       ad90@
                    ldd       6,s
                    cmpd      #$0016
                    bne       ag90@
                    ldd       >$00C2,s
                    std       <$12,s
                    ldb       6,u
                    sex
                    std       10,s
ad90@               ldd       #$0016
                    std       4,s
                    ldd       10,s
                    stb       <$1A,s
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgMidiChannel,pcr
                    pshs      x
                    leax      <$21,s
                    pshs      x
                    lbsr      getempty
                    leas      6,s
                    lbeq      br90@
                    leax      <$1D,s
                    pshs      x
                    lbsr      AtoI
                    leas      2,s
                    addd      #$FFFF
                    clra
                    andb      #$0F
ae90@               stb       <$1B,s
                    lbra      bp90@
af90@               ldd       10,s
                    bne       ai90@
                    ldd       6,s
                    cmpd      #$0017
                    beq       ah90@
ag90@               leax      >$00BE,s
                    lbra      az90@
ah90@               ldd       >$00C2,s
                    std       <$12,s
                    ldb       6,u
                    sex
                    std       10,s
ai90@               ldd       #$0017
                    std       4,s
                    ldd       10,s
                    stb       <$1A,s
                    ldb       13,s
                    bge       aj90@
                    ldb       <$1D,s
                    beq       aj90@
                    leax      <$1D,s
                    pshs      x
                    lbsr      AtoI
                    leas      2,s
                    std       <$10,s
                    lbra      ax90@
aj90@               ldd       #WinStylePaper3D    the paper 3D box
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0010
                    pshs      a,b
                    ldd       #$0032
                    pshs      a,b
                    ldd       #$00AE
                    pshs      a,b
                    ldd       #$000F
                    pshs      a,b
                    lbsr      wcreate
                    leas      12,s
                    bra       al90@
ak90@               leas      >-$00BE,x
al90@               ldd       >UmeData_reserved_03C6
                    bge       am90@
                    clra
                    clrb
                    std       >UmeData_reserved_03C6
am90@               ldd       >UmeData_reserved_03C6
                    cmpd      #$0028
                    ble       an90@
                    ldd       #$0028
                    std       >UmeData_reserved_03C6
an90@               ldd       >UmeData_reserved_03C6
                    clra
                    andb      #$FE
                    std       >UmeData_reserved_03C6
                    ldd       #$0073
                    pshs      a,b
                    ldd       #$004D
                    pshs      a,b
                    lbsr      soowee
                    leas      4,s
                    leax      >strListNav,pcr
                    pshs      x
                    lbsr      Printf
                    leas      2,s
                    leax      >msgInstrNo,pcr
                    pshs      x
                    lbsr      Printf
                    leas      2,s
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$000D
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0002
                    pshs      a,b
                    ldd       #$0019
                    pshs      a,b
                    ldd       #$00AE
                    pshs      a,b
                    ldd       #$000F
                    pshs      a,b
                    lbsr      textmenu
                    leas      14,s
                    stb       13,s
                    beq       ao90@
                    ldb       13,s
                    sex
                    cmpd      #$FFF3
                    bne       ap90@
ao90@               lbsr      wkill
                    lbra      bn90@
ap90@               ldb       13,s
                    ble       ar90@
                    ldb       13,s
                    cmpb      #$18
                    ble       aq90@
                    ldb       13,s
                    clra
                    andb      #$01
                    beq      au90@
                    ldd       >UmeData_reserved_03C6
                    subd      #$0018
                    bra      av90@
aq90@               ldb       13,s
                    sex
                    addd      >UmeData_reserved_03C6
                    addd      #$FFFF
                    std       <$10,s
                    bra      ax90@
ar90@               ldb       13,s
                    sex
                    nega
                    negb
                    sbca      #$00
                    stb       12,s
                    cmpb      #$30
                    blt       as90@
                    ldb       12,s
                    cmpb      #$39
                    bgt       as90@
                    ldb       12,s
                    stb       <$1C,s
                    ldx       #$01BE
                    pshs      x
                    ldb       14,s
                    sex
                    pshs      a,b
                    lbsr      FPutc
                    leas      4,s
                    leax      <$1D,s
                    pshs      x
                    lbsr      gets
                    leas      2,s
                    leax      <$1C,s
                    pshs      x
                    lbsr      AtoI
                    leas      2,s
                    std       <$10,s
                    bra       ax90@
as90@               ldb       12,s
                    cmpb      #$62
                    bne       at90@
                    ldd       >UmeData_reserved_03C6
                    subd      #$0018
                    std       >UmeData_reserved_03C6
at90@               ldb       12,s
                    cmpb      #$66
                    bne       aw90@
au90@               ldd       >UmeData_reserved_03C6
                    addd      #$0018
av90@               std       >UmeData_reserved_03C6
aw90@               ldx       #$01BE
                    pshs      x
                    ldd       #$000C
                    pshs      a,b
                    lbsr      FPutc
                    leas      4,s
                    leax      >$00BE,s
                    lbra      ak90@
ax90@               ldd       <$10,s
                    clra
                    andb      #$3F
                    stb       <$1B,s
                    lbsr      wkill
                    lbra      bp90@
ay90@               ldd       10,s
                    bne       bb90@
                    ldd       6,s
                    cmpd      #$0018
                    bne       ba90@
                    ldd       >$00C2,s
                    std       <$12,s
                    ldb       6,u
                    sex
                    std       10,s
                    bra       bb90@
az90@               leas      >-$00BE,x
ba90@               clra
                    clrb
                    pshs      a,b
                    leax      >msgIVMOnNote,pcr
                    pshs      x
                    lbsr      alert
                    leas      4,s
                    lbsr      wkill
                    lbra      br90@
bb90@               ldd       #$0018
                    std       4,s
                    ldd       10,s
                    stb       <$1A,s
                    bra       bd90@
bc90@               leas      >-$00BE,x
bd90@               ldb       <$1D,s
                    lbne      bj90@
                    ldb       12,s
                    cmpb      #$76
                    bne       be90@
                    ldd       #$0007
                    bra       bf90@
be90@               ldd       #$0031
bf90@               pshs      a,b
                    ldd       #$00A0
                    subd      ,s++
                    std       14,s
                    ldd       4,s
                    cmpd      #$001C
                    bne       bg90@
                    ldd       14,s
                    subd      #$000E
                    std       14,s
bg90@               ldd       #WinStylePaper3D    the paper 3D box
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0004
                    pshs      a,b
                    ldd       #$001A
                    pshs      a,b
                    ldd       <$16,s
                    pshs      a,b
                    ldd       #$001B
                    pshs      a,b
                    lbsr      wcreate
                    leas      12,s
                    leax      >msgDynamicsList,pcr
                    pshs      x
                    lbsr      Printf
                    leas      2,s
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0002
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0004
                    pshs      a,b
                    ldd       #$0006
                    pshs      a,b
                    ldd       <$18,s
                    pshs      a,b
                    ldd       #$001C
                    pshs      a,b
                    lbsr      textmenu
                    leas      14,s
                    stb       13,s
                    lbsr      wkill
                    ldb       13,s
                    lbeq      br90@
                    ldb       13,s
                    bge       bh90@
                    ldb       13,s
                    sex
                    nega
                    negb
                    sbca      #$00
                    bra       bi90@
bh90@               ldb       13,s
                    sex
                    addd      #$002F
bi90@               stb       <$1D,s
                    clra
                    clrb
                    stb       <$1E,s
bj90@               leax      <$1D,s
                    pshs      x
                    lbsr      AtoI
                    leas      2,s
                    clra
                    andb      #$07
                    stb       <$1B,s
                    ldd       4,s
                    cmpd      #$001C
                    beq       bl90@
                    lbra      bp90@
bk90@               leas      >-$00BE,x
bl90@               clra
                    clrb
                    stb       <$1C,s
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgOverBeats,pcr
                    pshs      x
                    leax      <$20,s
                    pshs      x
                    lbsr      getempty
                    leas      6,s
                    lbeq      br90@
                    ldd       #$0063
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    leax      <$20,s
                    pshs      x
                    lbsr      AtoI
                    std       ,s
                    lbsr      ClampRange
                    leas      6,s
                    stb       <$1A,s
                    bra      bp90@
bm90@               lbsr      bell
bn90@               leax      >$00BE,s
                    lbra      c90@
bo90@               cmpx      #$0074
                    lbeq      k90@
                    cmpx      #$005E
                    lbeq      m90@
                    cmpx      #$0037
                    lbeq      m90@
                    cmpx      #$006C
                    lbeq      m90@
                    cmpx      #$002D
                    lbeq      m90@
                    cmpx      #$0067
                    lbeq      p90@
                    cmpx      #$003C
                    lbeq      r90@
                    cmpx      #$003E
                    lbeq      r90@
                    cmpx      #$0061
                    lbeq      w90@
                    cmpx      #$0072
                    lbeq      w90@
                    cmpx      #$0063
                    lbeq      aa90@
                    cmpx      #$0068
                    lbeq      ac90@
                    cmpx      #$006D
                    lbeq      ac90@
                    cmpx      #$0069
                    lbeq      af90@
                    cmpx      #$0076
                    lbeq      ay90@
                    cmpx      #$000D
                    beq       br90@
                    bra       bm90@
bp90@               ldd       4,s
                    stb       <$19,s
                    ldd       <$12,s
                    cmpd      #$FFFF
                    bne       bq90@
                    ldd       4,s
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    leax      4,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    lbsr      enter
                    leas      8,s
                    std       <$12,s
bq90@               ldd       <$12,s
                    bge       bs90@
br90@               clra
                    clrb
                    bra       bt90@
bs90@               leax      <$14,s
                    pshs      x
                    ldd       <$14,s
                    pshs      a,b
                    lbsr      i2p
                    std       ,s
                    lbsr      CopyEvent
                    leas      4,s
                    ldd       #$0001
bt90@               leas      >$00BE,s
                    puls      u,pc
* strChoicePrompt (was L7C3E): '  Choice: '
strChoicePrompt     fcc       /  Choice: /
                    fcb       $00
* msgNoOpenBracket (was L7C49): 'No [.  From start? '
msgNoOpenBracket    fcc       /No [.  From start? /
                    fcb       $00
* msgNoCloseBracket (was L7C61): 'No ].  To end? '
msgNoCloseBracket   fcc       /No ].  To end? /
                    fcb       $00
* fmtChar (was L7C71): '%c' echo of the g/G key
fmtChar             fcb       $25,$63,$00
* msgChangeKeySig (was L7C74): 'Change Key Sig?'
msgChangeKeySig     fcc       /Change Key Sig?/
                    fcb       $00
* fmtCurrentlyNew (was L7C8A): 'Currently %d %ss.' CR ' New Value: '
fmtCurrentlyNew     fcc       /Currently %d %ss./
                    fcb       $0D
                    fcc       / New Value: /
                    fcb       $00
* strFlat (was L7CA9): 'Flat'
strFlat             fcc       /Flat/
                    fcb       $00
* strSharp (was L7CAE): 'Sharp'
strSharp            fcc       /Sharp/
                    fcb       $00
* strEnvMenuKeys (was L7CB4): 'ivme  tgc<a^le' exprmenu key letters
strEnvMenuKeys      fcb       $0D
                    fcc       /ivme  tgc<a^le/
                    fcb       $00
* msgNewTempo (was L7CC4): ' New Tempo (30 - 240: '
msgNewTempo         fcc       / New Tempo (30 - 240: /
                    fcb       $00
* msgToTempo (was L7CDB): 'To Tempo: '
msgToTempo          fcc       /To Tempo: /
                    fcb       $00
* msgClockOn (was L7CE6): 'Turn Clock ON, not OFF?'
msgClockOn          fcc       /Turn Clock ON, not OFF?/
                    fcb       $00
* msgMidiChannel (was L7CFE): ' MIDI Chan (1 - 16): '
msgMidiChannel      fcc       / MIDI Chan (1 - 16): /
                    fcb       $00
* strListNav (was L7D17): ' (Back in list)          (Forward)'
strListNav          fcc       / (Back in list)          (Forward)/
                    fcb       $0D,$00
* msgInstrNo (was L7D3B): ' Instr. No. (0-63): '
msgInstrNo          fcb       $0D
                    fcc       / Instr. No. (0-63): /
                    fcb       $00
* msgIVMOnNote (was L7D51): ' I, V or M go on a Note or Rest.'
msgIVMOnNote        fcc       / I, V or M go on a Note or Rest./
                    fcb       $0D,$00
* msgDynamicsList (was L7D79): ' 0=ppp  1=pp ... 7=fff' on two lines, then 'No.: '
msgDynamicsList     fcb       $0D
                    fcc       / 0=ppp  1=pp  2=p   3=mp/
                    fcb       $0D
                    fcc       / 4=mf   5=f   6=ff  7=fff/
                    fcb       $0D,$0D
                    fcc       /No.: /
                    fcb       $00
* msgOverBeats (was L7DB4): 'Over how many Beats? '
msgOverBeats        fcc       /Over how many Beats? /
                    fcb       $00
* tlineclr (was L7DCA): clears text line n (52-byte records at events array + $1000)
tlineclr       pshs      u
                    ldd       >UmeData_reserved_03E5
                    addd      #$1000
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    ldd       #$0034
                    lbsr      MulInt
                    addd      ,s++
                    tfr       d,u
                    clra
                    clrb
                    stb       ,u
                    clra
                    clrb
                    stb       <$33,u
                    puls      u,pc
* titleclr (was L7DED): maps the events array and clears all 9 title/text lines
titleclr      pshs      a,b,u
                    ldd       #$0001
                    pshs      a,b
                    lbsr      swapevts
                    leas      2,s
                    ldd       #$0009
                    std       ,s
                    bra       b91@
a91@                ldd       ,s
                    pshs      a,b
                    bsr       tlineclr
                    leas      2,s
b91@                ldd       ,s
                    addd      #$FFFF
                    std       ,s
                    bge       a91@
                    clra
                    clrb
                    pshs      a,b
                    lbsr      swapevts
                    leas      2,s
                    lbra      TextLinesRet
* titlinsho (was L7E1D): prints the 9 text lines, optionally numbered '%d: '
titlinsho      pshs      a,b,x,u
                    ldd       #$0001
                    pshs      a,b
                    lbsr      swapevts
                    leas      2,s
                    ldd       >UmeData_reserved_03E5
                    addd      #$1000
                    std       ,s
                    clra
                    clrb
                    std       2,s
                    bra       c92@
a92@                ldb       9,s
                    beq       b92@
                    ldd       2,s
                    addd      #$0001
                    pshs      a,b
                    leax      >fmtLineNum,pcr
                    pshs      x
                    lbsr      Printf
                    leas      4,s
b92@                ldd       ,s
                    pshs      a,b
                    leax      >fmtStrCR,pcr
                    pshs      x
                    lbsr      Printf
                    leas      4,s
                    ldd       2,s
                    addd      #$0001
                    std       2,s
                    subd      #$0001
                    ldd       ,s
                    addd      #$0034
                    std       ,s
c92@                ldd       2,s
                    cmpd      #$0009
                    blt       a92@
                    clra
                    clrb
                    pshs      a,b
                    lbsr      swapevts
                    leas      2,s
                    ldx       #$01BE
                    pshs      x
                    ldd       #$000D
                    pshs      a,b
                    lbsr      FPutc
                    leas      4,s
                    leas      4,s
                    puls      u,pc
* ShowTextLines (was L7E91): text box, titlinsho, hitenter (when <rfr_tit is set)
ShowTextLines       pshs      a,b,u
                    ldd       #WinStylePaper3D    the paper 3D box
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$000C
                    pshs      a,b
                    ldd       #$0038
                    pshs      a,b
                    ldd       #$00AA
                    pshs      a,b
                    ldd       #$000F
                    pshs      a,b
                    lbsr      wcreate
                    leas      12,s
                    clra
                    clrb
                    pshs      a,b
                    lbsr      titlinsho
                    leas      2,s
                    lbsr      hitenter
                    lbsr      wkill
* TextLinesRet (was L7EC5): ShowTextLines' exit (leas 2,s); titleclr lbra's here after remapping the events array
TextLinesRet        leas      2,s
                    puls      u,pc
* LongToStr (was L7EC9): formats a 32-bit tick count as '%3u,%03d,%03d' into a buffer (LongDiv by 1000)
LongToStr           pshs      u
                    ldu       4,s
                    leas      -15,s
                    leax      <$15,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    bsr       LongToStrCmp0
                    neg       <UmeData_reserved_0000
                    neg       <UmeData_reserved_0000
* LongToStrCmp0 (was L7EE0): In LongToStr: bsr past the inline 0L constant, X=&0, LongCmp tests the tick count's sign
LongToStrCmp0       puls      x
                    lbsr      LongCmp
                    bge       a93@
                    leax      <$15,s
                    pshs      x
                    leax      <$17,s
                    lbsr      LongNegLoad
                    lbsr      LongStore
a93@                clra
                    clrb
                    stb       ,s
                    leax      3,s
                    pshs      x
                    bsr       LongToStrMillion
                    neg       <UmeData_reserved_000F
                    fcb       $42       inline long 1,000,000 = $00,$0F,$42,$40 (the neg above is its first two bytes)
                    fcb       $40
* LongToStrMillion (was L7F03): In LongToStr: bsr past the inline 1,000,000 constant; LongStore seeds the divisor with it
LongToStrMillion    puls      x
                    bra      f93@
b93@                leax      <$15,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    leax      7,s
                    lbsr      LongDiv
                    ldd       >UmeData_reserved_0345
                    std       1,s
                    beq       c93@
                    ldd       #$0001
                    stb       ,s
                    leax      <$15,s
                    pshs      x
                    leax      <$17,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldd       7,s
                    lbsr      IntToLong
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    leax      13,s
                    lbsr      LongMul
                    lbsr      LongSub
                    lbsr      LongStore
                    ldd       1,s
                    addd      #$0030
                    bra       d93@
c93@                ldb       ,s
                    beq       e93@
                    ldd       #$0030
d93@                stb       ,u+
e93@                leax      3,s
                    pshs      x
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    bsr       LongToStrDivTen
                    neg       <UmeData_reserved_0000
                    neg       <UmeData_reserved_000A
* LongToStrDivTen (was L7F6E): In LongToStr: bsr past the inline 10L constant; LongDiv divides the divisor by ten each pass
LongToStrDivTen     puls      x
                    lbsr      LongDiv
f93@                lbsr      LongStore
                    leax      3,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    bsr       megprint
                    neg       <UmeData_reserved_0000
                    com       <UmeData_reserved_00E8
* megprint (was L7F86): In LongToStr: bsr past the inline 1000L constant; LongCmp keeps the digit loop while >= 1000
megprint    puls      x
                    lbsr      LongCmp
                    lbge      b93@
                    ldd       <$17,s
                    pshs      a,b
                    ldb       2,s
                    beq       g93@
                    leax      >fmtComma3d,pcr
                    bra       h93@
g93@                leax      >fmtUns3,pcr
h93@                tfr       x,d
                    pshs      a,b
                    pshs      u
                    lbsr      SPrintf
                    leas      6,s
                    leas      15,s
                    puls      u,pc
* report (was L7FB1): fmtVersion ('Studio-9 v%d.%d.%d%c') plus ScoreInfo
report         pshs      u
                    leas      <-$12,s
                    ldd       #WinStylePaper3D    the paper 3D box
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0010
                    pshs      a,b
                    ldd       #$0036
                    pshs      a,b
                    ldd       #$00AA
                    pshs      a,b
                    ldd       #$000E
                    pshs      a,b
                    lbsr      wcreate
                    leas      12,s
                    clra
                    clrb
                    pshs      a,b
                    lbsr      titlinsho
                    leas      2,s
                    ldd       #$0045
                    pshs      a,b
                    ldd       #$0004
                    pshs      a,b
                    ldd       #$000B
                    pshs      a,b
                    ldd       #$000A
                    pshs      a,b
                    leax      >fmtVersion,pcr
                    pshs      x
                    lbsr      Printf
                    leas      10,s
                    ldb       <readonly
                    beq       a94@
                    leax      >strReadOnlyTag,pcr
                    bra       ScoreInfo
a94@                leax      >strEmpty2,pcr
* ScoreInfo (was L800F): prints score name, 'Score Level', parts/staves, bars/ticks, objects/pages/sectors, MIDI settings
ScoreInfo           tfr       x,d
                    pshs      a,b
                    ldx       #$0BEB
                    pshs      x
                    leax      >fmtNameQuoted,pcr
                    pshs      x
                    lbsr      Printf
                    leas      6,s
                    ldd       <scorelvl
                    pshs      a,b
                    leax      >fmtScoreLevel,pcr
                    pshs      x
                    lbsr      Printf
                    leas      4,s
                    ldd       <nstaves
                    pshs      a,b
                    ldd       <nparts
                    pshs      a,b
                    leax      >fmtPartsStaves,pcr
                    pshs      x
                    lbsr      Printf
                    leas      6,s
                    lbsr      flush
                    clra
                    clrb
                    pshs      a,b
                    lbsr      RenumberBars
                    leas      2,s
                    ldx       #$0091
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    leax      6,s
                    pshs      x
                    lbsr      LongToStr
                    leas      6,s
                    leax      2,s
                    pshs      x
                    ldd       <UmeData_reserved_0005
                    pshs      a,b
                    ldd       <UmeData_reserved_0003
                    pshs      a,b
                    ldd       <nbars
                    pshs      a,b
                    leax      >fmtBarsTicks,pcr
                    pshs      x
                    lbsr      Printf
                    leas      10,s
                    ldd       <nevents
                    pshs      a,b
                    ldd       #$0020
                    lbsr      DivInt
                    addd      #$0002
                    pshs      a,b
                    ldd       <nmpages
                    pshs      a,b
                    ldd       <nevents
                    pshs      a,b
                    ldd       #$7FFF
                    subd      <nevents
                    pshs      a,b
                    leax      >fmtObjectsUsed,pcr
                    pshs      x
                    lbsr      Printf
                    leas      10,s
                    ldb       <pldebug
                    sex
                    pshs      a,b
                    ldb       <compact
                    sex
                    pshs      a,b
                    ldb       <midiser
                    sex
                    pshs      a,b
                    ldb       <mididev
                    sex
                    pshs      a,b
                    ldb       <midipak
                    sex
                    pshs      a,b
                    leax      >fmtMidiSettings,pcr
                    pshs      x
                    lbsr      Printf
                    leas      12,s
                    lbsr      hitenter
                    lbsr      wkill
                    leas      <$12,s
                    puls      u,pc
* titlemen (was L80D8): opens the text box then EditTextLines
titlemen         pshs      u
                    leas      <-$54,s
                    ldd       #WinStylePaper3D    the paper 3D box
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$000C
                    pshs      a,b
                    ldd       #$0038
                    pshs      a,b
                    ldd       #$00AA
                    pshs      a,b
                    ldd       #$000D
                    pshs      a,b
                    lbsr      wcreate
                    leas      12,s
* EditTextLines (was L8100): ' Re-type line # (ENTER quits): ' then gets into the chosen 52-byte text line
EditTextLines       ldd       #$0001
                    pshs      a,b
                    lbsr      titlinsho
                    leas      2,s
                    leax      >msgLineToRetype,pcr
                    pshs      x
                    lbsr      Printf
                    leas      2,s
                    leax      2,s
                    pshs      x
                    lbsr      charmaus
                    leas      2,s
                    ldb       2,s
                    cmpb      #$0D
                    lbeq      d95@
                    ldb       2,s
                    sex
                    addd      #$FFCF
                    std       ,s
                    blt      c95@
                    ldd       ,s
                    cmpd      #$0009
                    bge      c95@
                    ldd       ,s
                    addd      #$0001
                    pshs      a,b
                    leax      >fmtLineNum2,pcr
                    pshs      x
                    lbsr      Printf
                    leas      4,s
                    leax      3,s
                    pshs      x
                    lbsr      gets
                    leas      2,s
                    ldb       3,s
                    beq      c95@
                    ldd       #$0001
                    pshs      a,b
                    lbsr      swapevts
                    leas      2,s
                    ldd       ,s
                    pshs      a,b
                    lbsr      tlineclr
                    leas      2,s
                    clra
                    clrb
                    stb       <$36,s
                    ldb       4,s
                    bne       a95@
                    ldb       3,s
                    cmpb      #$20
                    beq       b95@
a95@                ldd       #$0034
                    pshs      a,b
                    leax      5,s
                    pshs      x
                    ldd       >UmeData_reserved_03E5
                    addd      #$1000
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    ldd       #$0034
                    lbsr      MulInt
                    addd      ,s++
                    pshs      a,b
                    lbsr      StrNCopy
                    leas      6,s
b95@                clra
                    clrb
                    pshs      a,b
                    lbsr      swapevts
                    leas      2,s
c95@                leax      >strFormFeed,pcr
                    pshs      x
                    lbsr      Printf
                    leas      2,s
                    lbra      EditTextLines
d95@                lbsr      wkill
                    leas      <$54,s
                    puls      u,pc
* fmtLineNum (was L81C2): '%d: '
fmtLineNum          fcc       /%d: /
                    fcb       $00
* fmtStrCR (was L81C7): '%s\r'
fmtStrCR            fcb       $25,$73,$0D,$00
* fmtComma3d (was L81CB): ',%03d'
fmtComma3d          fcc       /,%03d/
                    fcb       $00
* fmtUns3 (was L81D1): '%3u'
fmtUns3             fcc       /%3u/
                    fcb       $00
* fmtVersion (was L81D5): 'Studio-9 v%d.%d.%d%c  '
fmtVersion          fcc       /Studio-9 v%d.%d.%d%c  /
                    fcb       $00
* fmtNameQuoted (was L81EB): ''%s'%s' score name plus read-only tag
fmtNameQuoted       fcc       /'%s'%s/
                    fcb       $0D,$00
* strReadOnlyTag (was L81F3): ' (R/O)' appended when read-only mode <readonly is on
strReadOnlyTag      fcc       / (R/
                    fcb       $2F,$4F,$29,$00
* strEmpty2 (was L81FA): empty string (no read-only tag)
strEmpty2           fcb       $00
* fmtScoreLevel (was L81FB): '   Score Level %d.'
fmtScoreLevel       fcc       /   Score Level %d./
                    fcb       $0D,$00
* fmtPartsStaves (was L820F): ' %d Parts on %d Staves; '
fmtPartsStaves      fcc       / %d Parts on %d Staves; /
                    fcb       $00
* fmtBarsTicks (was L8228): '%d bars of %d/%d; %s Ticks'
fmtBarsTicks        fcc       /%d bars of %d/
                    fcb       $2F
                    fcc       /%d; %s Ticks/
                    fcb       $0D,$00
* fmtObjectsUsed (was L8244): '%5d Objs left %5d used %2d pg %3d sect'
fmtObjectsUsed      fcc       /%5d Objs left %5d used %2d pg %3d sect/
                    fcb       $0D,$00
* fmtMidiSettings (was L8278): ' MIDI: Pak=%d, /dev=%d Ser=%d Cmp=%d Dbg=%d'
fmtMidiSettings     fcc       / MIDI: Pak=%d, /
                    fcb       $2F
                    fcc       /dev=%d Ser=%d Cmp=%d Dbg=%d/
                    fcb       $0D,$00
* msgLineToRetype (was L82B4): ' Re-type line # (ENTER quits): '
msgLineToRetype     fcc       / Re-type line # (ENTER quits): /
                    fcb       $00
* fmtLineNum2 (was L82D9): '%d: '
fmtLineNum2         fcb       $0D
                    fcc       /%d: /
                    fcb       $00
* strFormFeed (was L82DF): $0C clear-screen string
strFormFeed         fcb       $0C,$00
* The original BeepTone, PiaSoundOn and DelayLoop drove the CoCo DAC and PIAs ($FF20-$FF23, $FF01, $FF03),
* which on WildBits are the WizFi and SD card controllers; they are not assembled. The fcb bytes below are
* unreferenced leftovers of that code.
                    fcb       $8D,$DF,$86,$0A,$1F,$89,$5A,$26
                    fcb       $FD,$F6,$FF,$20,$C8,$F0,$F7,$FF
                    fcb       $20,$4C,$81,$4C,$25,$EE,$20,$BF
* SetPathOption (was L8344): I$GetStt SS.Opt on path 0, patches option byte [idx] to val, I$SetStt SS.Opt (echo = 4 and pause = 7 off at start, on at exit)
SetPathOption       pshs      u
                    leas      >-$008A,s
                    leax      10,s
                    stx       4,s
                    clra
                    clrb
                    stb       1,s
                    clra
                    clrb
                    stb       2,s
                    leax      ,s
                    pshs      x
                    ldd       #$008D
                    pshs      a,b
                    lbsr      Os9Call
                    leas      4,s
                    ldd       >$008E,s
                    leax      10,s
                    leax      d,x
                    ldd       >$0090,s
                    stb       ,x
                    leax      10,s
                    stx       4,s
                    clra
                    clrb
                    stb       1,s
                    clra
                    clrb
                    stb       2,s
                    leax      ,s
                    pshs      x
                    ldd       #$008E
                    pshs      a,b
                    lbsr      Os9Call
                    leas      4,s
                    leas      >$008A,s
                    puls      u,pc
* PrintCurDir (was L8392): pwd: opens '.', reads directory entries, climbs '..' matching LSNs, GetDevName at the root, prints '/%s' pieces ('File Structure Error!')
PrintCurDir         pshs      u
                    leas      >-$0164,s
                    clra
                    clrb
                    std       >$0162,s
                    ldd       #$0081
                    pshs      a,b
                    leax      >strDot,pcr
                    pshs      x
                    lbsr      OpenPath
                    leas      4,s
                    std       >$0160,s
                    cmpd      #$FFFF
                    bne       a98@
                    ldd       >UmeData_c_errno
                    pshs      a,b
                    lbsr      ExitProg
                    leas      2,s
a98@                ldd       #$0020
                    pshs      a,b
                    leax      <$12,s
                    pshs      x
                    ldd       >$0164,s
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    ldd       #$0001
                    pshs      a,b
                    leax      <$2F,s
                    pshs      x
                    leax      12,s
                    pshs      x
                    lbsr      Lsn24ToLong
                    leas      6,s
                    ldd       #$0020
                    pshs      a,b
                    leax      <$12,s
                    pshs      x
                    ldd       >$0164,s
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    ldd       #$0001
                    pshs      a,b
                    leax      <$2F,s
                    pshs      x
                    leax      4,s
                    pshs      x
                    lbsr      Lsn24ToLong
                    leas      6,s
                    leax      8,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    leax      4,s
                    lbsr      LongCmp
                    lbeq      h98@
b98@                leax      >strDotDot,pcr
                    pshs      x
                    lbsr      ChangeDir
                    leas      2,s
                    cmpd      #$FFFF
                    bne       c98@
                    ldd       >UmeData_c_errno
                    pshs      a,b
                    lbsr      ExitProg
                    leas      2,s
c98@                ldd       >$0160,s
                    pshs      a,b
                    lbsr      ClosePath
                    leas      2,s
                    ldd       #$0081
                    pshs      a,b
                    leax      >strDot2,pcr
                    pshs      x
                    lbsr      OpenPath
                    leas      4,s
                    std       >$0160,s
                    cmpd      #$FFFF
                    bne       d98@
                    ldd       >UmeData_c_errno
                    pshs      a,b
                    lbsr      ExitProg
                    leas      2,s
d98@                ldd       #$0020
                    pshs      a,b
                    leax      <$12,s
                    pshs      x
                    ldd       >$0164,s
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    ldd       #$0001
                    pshs      a,b
                    leax      <$2F,s
                    pshs      x
                    leax      12,s
                    pshs      x
                    lbsr      Lsn24ToLong
                    leas      6,s
                    ldd       #$0020
                    pshs      a,b
                    leax      <$12,s
                    pshs      x
                    ldd       >$0164,s
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    ldd       #$0001
                    pshs      a,b
                    leax      <$2F,s
                    pshs      x
                    leax      8,s
                    pshs      x
                    lbsr      Lsn24ToLong
                    leas      6,s
                    leax      12,s
                    pshs      x
                    leax      6,s
                    lbsr      LongStore
                    bra       g98@
e98@                ldd       #$0020
                    pshs      a,b
                    leax      <$12,s
                    pshs      x
                    ldd       >$0164,s
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    cmpd      #$0020
                    beq       f98@
                    leax      >msgFileStructErr,pcr
                    pshs      x
                    lbsr      Printf
                    leas      2,s
                    ldd       #$0001
                    pshs      a,b
                    lbsr      ExitProg
                    leas      2,s
                    bra       g98@
f98@                ldd       #$0001
                    pshs      a,b
                    leax      <$2F,s
                    pshs      x
                    leax      <$10,s
                    pshs      x
                    lbsr      Lsn24ToLong
                    leas      6,s
g98@                leax      ,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    leax      <$10,s
                    lbsr      LongCmp
                    bne       e98@
                    leax      <$10,s
                    pshs      x
                    ldd       >$0164,s
                    pshs      a,b
                    ldd       #$001E
                    lbsr      MulInt
                    leax      <$32,s
                    leax      d,x
                    pshs      x
                    lbsr      CopyHiBitName
                    leas      4,s
                    ldd       >$0162,s
                    addd      #$0001
                    std       >$0162,s
                    leax      4,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    leax      12,s
                    lbsr      LongCmp
                    beq       h98@
                    leax      ,s
                    pshs      x
                    leax      6,s
                    lbsr      LongStore
                    lbra      b98@
h98@                leax      >$0120,s
                    pshs      x
                    ldd       >$0162,s
                    pshs      a,b
                    lbsr      GetDevName
                    leas      4,s
                    cmpd      #$FFFF
                    bne       i98@
                    ldd       >UmeData_c_errno
                    pshs      a,b
                    lbsr      ExitProg
                    leas      2,s
i98@                leax      >$0120,s
                    pshs      x
                    leax      >$0142,s
                    pshs      x
                    lbsr      CopyHiBitName
                    leas      4,s
                    ldd       >$0160,s
                    pshs      a,b
                    lbsr      ClosePath
                    leas      2,s
                    leax      >$0140,s
                    pshs      x
                    leax      >fmtSlashName,pcr
                    bra       k98@
j98@                ldd       >$0162,s
                    pshs      a,b
                    ldd       #$001E
                    lbsr      MulInt
                    leax      <$30,s
                    leax      d,x
                    pshs      x
                    leax      >fmtSlashName2,pcr
k98@                pshs      x
                    lbsr      Printf
                    leas      4,s
                    ldx       #$01BE
                    pshs      x
                    lbsr      FFlush
                    leas      2,s
                    ldd       >$0162,s
                    addd      #$FFFF
                    std       >$0162,s
                    ldd       >$0162,s
                    bge       j98@
                    leax      >strCR3,pcr
                    pshs      x
                    lbsr      Printf
                    leas      2,s
                    leas      >$0164,s
                    puls      u,pc
* strDot (was L85FA): '.' current directory
strDot              fcb       $2E,$00
* strDotDot (was L85FC): '..' parent directory
strDotDot           fcb       $2E,$2E,$00
* strDot2 (was L85FF): '.' reopened after chd ..
strDot2             fcb       $2E,$00
* msgFileStructErr (was L8601): 'File Structure Error!'
msgFileStructErr    fcc       /File Structure Error!/
                    fcb       $0D,$00
* fmtSlashName (was L8618): '/%s' device name piece
fmtSlashName        fcb       $2F,$25,$73,$00
* fmtSlashName2 (was L861C): '/%s' directory name piece
fmtSlashName2       fcb       $2F,$25,$73,$00
* strCR3 (was L8620): CR ending the PrintCurDir line
strCR3              fcb       $0D,$00
* FreeAllBlocks (was L8622): killem(0) and clears block count <nmpages / current block <curpage
FreeAllBlocks       pshs      u
                    clra
                    clrb
                    pshs      a,b
                    lbsr      killem
                    leas      2,s
                    clra
                    clrb
                    std       <nmpages
                    std       <curpage
                    puls      u,pc
* pswap (was L8635): maps page n: unmaps the current one, defines missing pages up to n (makepage; ' Out of Memory Blocks!'), maps n: <database base, <curptop = base + 927 events; vector $0399
pswap       pshs      u
                    clra
                    clrb
                    pshs      a,b
                    ldd       <curpage
                    pshs      a,b
                    lbsr      MapGPBuffer
                    leas      4,s
                    ldd       4,s
                    std       <curpage
                    lbeq      EventBufFailRet
                    bra       b99@
a99@                ldd       <nmpages
                    addd      #$0001
                    std       <nmpages
                    pshs      a,b
                    lbsr      makepage
                    leas      2,s
                    bne       b99@
                    ldd       <nmpages
                    addd      #$FFFF
                    std       <nmpages
                    std       <curpage
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgOutOfBlocks,pcr
                    lbra      EventBufErrBox
b99@                ldd       <nmpages
                    cmpd      4,s
                    blt       a99@
                    ldd       #$0001
                    pshs      a,b
                    ldd       <curpage
                    pshs      a,b
                    lbsr      MapGPBuffer
                    leas      4,s
                    std       <database
                    ldd       <database
                    lbeq      EventBufFailRet
                    ldd       <database
                    addd      #$1CF8              page end = base + 927 events (928-event pages)
                    std       <curptop
                    ldd       #$0001
                    puls      u,pc
* i2p (was L869B): idx<0 -> current pointer <curevp; else page idx/928 via pswap, <curind=idx, <curevp = base + (idx%928)*8
i2p           pshs      a,b,u
                    ldd       6,s
                    bge       a100@
                    ldd       <curevp
                    lbra      EventBufPopRet
a100@               ldd       6,s
                    std       <curind
                    ldd       #$0001
                    bra       c100@
b100@               ldd       ,s
                    addd      #$0001
c100@               std       ,s
                    ldd       6,s
                    subd      #$03A0              928 events per page
                    std       6,s
                    bge       b100@
                    ldd       6,s
                    addd      #$03A0
                    std       6,s
                    ldd       ,s
                    cmpd      <curpage
                    beq       d100@
                    ldd       ,s
                    pshs      a,b
                    lbsr      pswap
                    leas      2,s
                    bne       d100@
                    clra
                    clrb
                    lbra      EventBufPopRet
d100@               ldd       6,s
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    addd      <database
                    std       <curevp
                    lbra      EventBufPopRet
* plusplus (was L86EC): advances <curind/<curevp by one event, mapping the next block when it runs off the end
plusplus           pshs      u
                    ldd       <curind
                    addd      #$0001
                    std       <curind
                    cmpd      <nevents
                    bge       EventStepRet
                    ldd       <curevp
                    addd      #$0008
                    std       <curevp
                    cmpd      <curptop
                    bls       EventStepRet
                    ldd       <curpage
                    addd      #$0001
                    pshs      a,b
                    lbsr      pswap
                    leas      2,s
                    ldd       <database
                    bra       EventStepSetPtr
* decdec (was L8716): steps <curind/<curevp back one event, mapping the previous block when needed
decdec           pshs      u
                    ldd       <curind
                    addd      #$FFFF
                    std       <curind
                    blt       EventStepRet
                    ldd       <curevp
                    addd      #$FFF8
                    std       <curevp
                    cmpd      <database
                    bhs       EventStepRet
                    ldd       <curpage
                    addd      #$FFFF
                    pshs      a,b
                    lbsr      pswap
                    leas      2,s
                    ldd       <curptop
* EventStepSetPtr (was L873B): plusplus/decdec tail: stores the new block base or end in <curevp before the shared return
EventStepSetPtr     std       <curevp
* EventStepRet (was L873D): Shared exit of plusplus and decdec: reloads <curevp and returns the current event pointer
EventStepRet        ldd       <curevp
                    puls      u,pc
* makepage (was L8741): buffer n (1..GPTABSZ-1) gets an 8K block from F$AllRAM unless it has one; D = 1, or 0 on failure
makepage      pshs      a,b,x,y,u
                    ldd       10,s                which buffer
                    lbeq      a101@               zero is not a buffer number
                    cmpd      #GPTABSZ
                    lbhs      a101@               outside the table
                    tfr       d,x
                    ldb       >GPTab,x            does it already have a block?
                    lbne      b101@               yes - nothing to do, report success
                    ldb       #GPBLKS
                    os9       F$AllRAM            claim one 8K block; D = its number
                    lbcs      a101@               out of memory: the caller frees a page and retries
                    ldx       10,s
                    stb       >GPTab,x            remember which block backs this buffer
                    bra      b101@
a101@               clra
                    clrb
                    bra       c101@
b101@               ldd       #$0001
c101@               leas      6,s
                    puls      u,pc
* killpage (was L87B1): gives buffer n's block back with F$DelRAM ('**Killing CurPage! ==' if n is the current page); D = 1
killpage        pshs      a,b,x,u
                    ldd       8,s
                    beq       a102@
                    ldd       8,s
                    cmpd      <curpage
                    bne       a102@
                    ldd       <curpage
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    leax      >msgKillingCurPage,pcr
                    pshs      x
                    lbsr      alert
                    leas      6,s
a102@               ldd       8,s                 which buffer
                    beq       b102@               zero: nothing to free
                    cmpd      #GPTABSZ
                    bhs       b102@
                    tfr       d,x                 X = buffer number
                    ldb       >GPTab,x            B = the block behind it
                    beq       b102@               it never had one
                    pshs      x                   keep the buffer number
                    clra
                    tfr       d,x                 X = the block number
                    ldb       #GPBLKS
                    os9       F$DelRAM            hand the block back to the system
                    puls      x
                    clr       >GPTab,x            this buffer has no block any more
                    bra       b102@
b102@               ldd       #$0001
c102@               leas      4,s
                    puls      u,pc
* killem (was L880B): kills every event buffer numbered above n and remaps n if needed
killem     pshs      u
                    ldd       <curpage
                    cmpd      4,s
                    ble       c103@
                    ldd       4,s
                    pshs      a,b
                    lbsr      pswap
                    bra       b103@
a103@               ldd       <nmpages
                    addd      #$FFFF
                    std       <nmpages
                    subd      #$FFFF
                    pshs      a,b
                    bsr      killpage
b103@               leas      2,s
c103@               ldd       <nmpages
                    cmpd      4,s
                    bgt       a103@
                    puls      u,pc
* giveback (was L8837): seeks the last event then frees buffers beyond its block; vector $038F
giveback    pshs      u
                    ldd       <nevents
                    addd      #$FFFF
                    pshs      a,b
                    lbsr      i2p
                    leas      2,s
                    ldd       <curpage
                    pshs      a,b
                    bsr       killem
                    lbra      EventBufPopRet
* GPUnmap - take the resident get/put buffer out of the process map, if there is one.
* Every register is preserved so it can be called from the middle of MapGPBuffer.
GPUnmap             pshs      d,x,u
                    ldd       >GPMapped
                    beq       g107@               nothing is mapped
                    ldu       >GPAddr
                    ldb       #GPBLKS
                    os9       F$ClrBlk            release the slot
                    clra
                    clrb
                    std       >GPMapped
g107@               puls      d,x,u,pc

* MapGPBuffer (was L884E): (n, flag): flag 1 maps buffer n's block (F$MapBlk), unmapping the resident one
* first, and returns its address (0 on failure); flag 0 unmaps the resident buffer and returns 1.
MapGPBuffer         pshs      u
                    leas      -10,s               args at 14,s and <$11,s
                    ldd       14,s                which buffer
                    lbeq      a104@               zero is not a buffer number
                    cmpd      #GPTABSZ
                    lbhs      a104@               outside the table
                    ldb       <$11,s              0 = take it out of the map, 1 = bring it in
                    beq       u104@
* Bring it in. Only one buffer fits, so whatever is resident goes out first.
                    ldd       >GPMapped
                    cmpd      14,s
                    bne       q104@               a different one (or none) is mapped
                    ldd       >GPAddr             this one is already in - hand back its address
                    bra      c104@
q104@               lbsr      GPUnmap             drop the resident page
                    ldx       14,s
                    ldb       >GPTab,x            the block behind the wanted buffer
                    lbeq      a104@               it was never defined
                    clra
                    tfr       d,x                 X = the block number
                    ldb       #GPBLKS
                    os9       F$MapBlk            U = the address it landed at
* One tick so a process switch loads the new map before anything is written through it: a user-mode
* F$MapBlk reaches the live MMU only at the next switch. Only a real remap pays it (an already-mapped
* buffer returns above).
                    pshs      cc,d,x,u            cc: the lbcs below must see F$MapBlk's carry, not F$Sleep's
                    ldx       #$0001
                    os9       F$Sleep
                    puls      cc,d,x,u
                    lbcs      a104@               no free slot in the process map
                    ldd       14,s
                    std       >GPMapped
                    tfr       u,d
                    std       >GPAddr
                    lbra      c104@               the caller wants the address in D
* Take it out of the map.
u104@               bsr      GPUnmap
                    ldd       #$0001              non-zero: the unmap itself succeeded
                    bra      c104@
a104@               clra
                    clrb
                    bra       c104@
c104@               leas      10,s
                    puls      u,pc
* ievtinit (was L8896): defines get/put buffer 34 ('Can't create Events buffer!') and maps it as >$03E5 ('***Can't allocate Events array!'); vector $0373
ievtinit   pshs      u
                    ldd       4,s
                    bgt       a105@
                    ldd       #$0001
                    std       4,s
a105@               ldd       >UmeData_reserved_03E5
                    bne       b105@
                    ldd       #$0022
                    pshs      a,b
                    lbsr      makepage
                    leas      2,s
                    bne       b105@
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgCantCreateEvents,pcr
* EventBufErrBox (was L88BA): alert(msg,0) tail shared by ievtinit and pswap's 'Out of Memory Blocks!'
EventBufErrBox      pshs      x
                    lbsr      alert
                    leas      4,s
                    bra       EventBufFailRet
b105@               ldd       #$0001
                    pshs      a,b
                    bsr      swapevts
                    leas      2,s
                    std       >UmeData_reserved_03E5
                    bne       c105@
                    ldd       #$1000
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    leax      >msgCantAllocEvents,pcr
                    pshs      x
                    lbsr      alert
                    leas      6,s
                    clra
                    clrb
                    pshs      a,b
                    bsr       swapevts
                    leas      2,s
* EventBufFailRet (was L88EF): Shared return 0: pswap's two lbeq failures and ievtinit after the error box
EventBufFailRet     clra
                    clrb
                    puls      u,pc
c105@               ldd       >UmeData_reserved_03E5
                    addd      #$0FFF
                    std       >UmeData_reserved_03E7
                    ldd       >UmeData_reserved_03E5
                    addd      #$0001
                    std       >UmeData_reserved_03E9
                    ldd       #$00EA
                    stb       [>$03E5,y]
                    clra
                    clrb
                    pshs      a,b
                    bsr       swapevts
                    leas      2,s
                    ldd       4,s
                    cmpd      #$0FFF
                    bge       d105@
                    ldd       4,s
                    bra       e105@
d105@               ldd       #$0FFF
e105@               puls      u,pc
* swapevts (was L8925): maps (flag=1) or unmaps buffer 34, remapping the current event block ('Can't map ImEvts!', 'EvtArray moved!'); vector $03A7
swapevts         pshs      a,b,u
                    ldb       7,s
                    beq      b106@
                    ldd       >UmeData_reserved_03E5
                    std       ,s
                    clra
                    clrb
                    pshs      a,b
                    ldd       <curpage
                    pshs      a,b
                    lbsr      MapGPBuffer
                    leas      4,s
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0022
                    pshs      a,b
                    lbsr      MapGPBuffer
                    leas      4,s
                    std       >UmeData_reserved_03E5
                    bne       a106@
                    clra
                    clrb
                    pshs      a,b
                    leax      >msgCantMapImEvts,pcr
                    pshs      x
                    lbsr      alert
                    leas      4,s
a106@               ldd       ,s
                    beq      c106@
                    ldd       >UmeData_reserved_03E5
                    cmpd      ,s
                    beq      c106@
                    ldd       >UmeData_reserved_03E5
                    pshs      a,b
                    ldd       2,s
                    pshs      a,b
                    ldd       #$0002
                    pshs      a,b
                    leax      >msgEvtArrayMoved,pcr
                    pshs      x
                    lbsr      alert
                    leas      8,s
                    ldd       >UmeData_reserved_03E9
                    pshs      a,b
                    ldd       >UmeData_reserved_03E5
                    subd      2,s
                    addd      ,s++
                    std       >UmeData_reserved_03E9
                    ldd       >UmeData_reserved_03E7
                    pshs      a,b
                    ldd       >UmeData_reserved_03E5
                    subd      2,s
                    addd      ,s++
                    std       >UmeData_reserved_03E7
                    bra       c106@
b106@               clra
                    clrb
                    pshs      a,b
                    ldd       #$0022
                    pshs      a,b
                    lbsr      MapGPBuffer
                    leas      4,s
                    ldd       #$0001
                    pshs      a,b
                    ldd       <curpage
                    pshs      a,b
                    lbsr      MapGPBuffer
                    leas      4,s
c106@               ldd       >UmeData_reserved_03E5
* EventBufPopRet (was L89CA): Shared 'leas 2,s; puls u,pc' exit of i2p, giveback and swapevts
EventBufPopRet      leas      2,s
                    puls      u,pc
* msgOutOfBlocks (was L89CE): ' Out of Memory Blocks!'
msgOutOfBlocks      fcc       /Out of Mem Blks!/
                    fcb       $00
* msgKillingCurPage (was L89E5): '**Killing CurPage! =='
msgKillingCurPage   fcc       /Killing CurPage!/
                    fcb       $00
* msgCantCreateEvents (was L89FB): 'Can't create Events buffer!'
msgCantCreateEvents fcc       /No Events buffer!/
                    fcb       $0D,$00
* msgCantAllocEvents (was L8A18): '***Can't allocate Events array!'
msgCantAllocEvents  fcc       /No room for Events!/
                    fcb       $0D,$00
* msgCantMapImEvts (was L8A39): 'Can't map ImEvts!'
msgCantMapImEvts    fcc       /Can't map ImEvts!/
                    fcb       $0D,$00
* msgEvtArrayMoved (was L8A4C): 'EvtArray moved!'
msgEvtArrayMoved    fcc       /EvtArray moved!/
                    fcb       $0D,$00
* FindFreeFile (was L8A5D): scans the 16 FILE slots at $01B1 (13 bytes each) for one with flags&3 == 0; errno $C8 if none
FindFreeFile        pshs      u
                    leau      >$01B1,y
a107@               ldd       6,u
                    clra
                    andb      #$03
                    beq      FileRetPtr
                    leau      13,u
                    pshs      u
                    leax      >$0281,y
                    cmpx      ,s++
                    bhi       a107@
                    ldd       #$00C8
                    std       >$034F,y
                    bra      FileRetNull
                    fcb       $35,$C0
* SetupFile (was L8A84): fills a FILE: path, read/write flags from the mode string ('r'/'d' = read, '+' = both), buffer pointers
SetupFile           pshs      u
                    ldu       8,s
                    bne       a108@
                    bsr       FindFreeFile
                    tfr       d,u
a108@               stu       -2,s
                    beq       FileRetNull
                    ldd       4,s
                    std       8,u
                    ldx       6,s
                    ldb       1,x
                    cmpb      #$2B
                    beq       b108@
                    ldx       6,s
                    ldb       2,x
                    cmpb      #$2B
                    bne       c108@
b108@               ldd       6,u
                    orb       #$03
                    bra       g108@
c108@               ldd       6,u
                    pshs      a,b
                    ldb       [<$08,s]
                    cmpb      #$72
                    beq       d108@
                    ldb       [<$08,s]
                    cmpb      #$64
                    bne       e108@
d108@               ldd       #$0001
                    bra       f108@
e108@               ldd       #$0002
f108@               ora       ,s+
                    orb       ,s+
g108@               std       6,u
                    ldd       2,u
                    addd      11,u
                    std       4,u
                    std       ,u
* FileRetPtr (was L8AD4): Returns U as the FILE pointer; FindFreeFile lbeq's here when a slot's flags&3 == 0
FileRetPtr          tfr       u,d
                    puls      u,pc
* FileRetNull (was L8AD8): Returns NULL: FindFreeFile after errno $C8 and SetupFile when no FILE slot was obtained
FileRetNull         clra
                    clrb
                    puls      u,pc
* OpenByMode (was L8ADC): parses fopen mode chars r/w/a/d/x/+ into OS-9 modes and calls OpenPath/CreateFile/SeekPath(end); errno $CB on bad mode
OpenByMode          pshs      u
                    ldu       4,s
                    leas      -4,s
                    clra
                    clrb
                    std       ,s
                    ldx       10,s
                    ldb       1,x
                    sex
                    tfr       d,x
                    bra       f109@
a109@               ldx       10,s
                    ldb       2,x
                    cmpb      #$2B
                    bne       b109@
                    ldd       #$0007
                    bra       d109@
b109@               ldd       #$0004
                    bra       d109@
c109@               ldd       #$0003
d109@               std       ,s
                    bra       g109@
e109@               leax      4,s
                    bra      n109@
f109@               stx       -2,s
                    beq       g109@
                    cmpx      #$0078
                    beq       a109@
                    cmpx      #$002B
                    beq       c109@
                    bra       e109@
g109@               ldb       [<$0A,s]
                    sex
                    tfr       d,x
                    bra      p109@
h109@               ldd       ,s
                    orb       #$01
                    bra       l109@
i109@               ldd       ,s
                    orb       #$02
                    pshs      a,b
                    pshs      u
                    lbsr      OpenPath
                    leas      4,s
                    std       2,s
                    cmpd      #$FFFF
                    beq       j109@
                    ldd       #$0002
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    lbsr      SeekPath
                    leas      8,s
                    bra       q109@
j109@               ldd       ,s
                    orb       #$02
                    pshs      a,b
                    pshs      u
                    lbsr      CreateFile
                    bra       m109@
k109@               ldd       ,s
                    orb       #$81
l109@               pshs      a,b
                    pshs      u
                    lbsr      OpenPath
m109@               leas      4,s
                    std       2,s
                    bra       q109@
n109@               leas      -4,x
o109@               ldd       #$00CB
                    std       >$034F,y
                    clra
                    clrb
                    bra       r109@
p109@               cmpx      #$0072
                    beq      h109@
                    cmpx      #$0061
                    beq      i109@
                    cmpx      #$0077
                    beq       j109@
                    cmpx      #$0064
                    beq       k109@
                    bra       o109@
q109@               ldd       2,s
r109@               leas      4,s
                    puls      u,pc
                    fcc       /4@O_4/
                    fcb       $06,$EC,$68,$34,$06,$EC,$68,$34
                    fcb       $06,$16,$00,$4B
* FOpen (was L8BB3): fopen(name, mode): OpenByMode then SetupFile
FOpen               pshs      u
                    ldd       6,s
                    pshs      a,b
                    ldd       6,s
                    pshs      a,b
                    lbsr      OpenByMode
                    leas      4,s
                    tfr       d,u
                    cmpu      #$FFFF
                    bne       a110@
                    clra
                    clrb
                    bra       c110@
a110@               clra
                    clrb
                    bra       b110@
                    fcb       $34,$40,$EC,$68,$34,$06,$17,$03
                    fcb       $9C,$32,$62,$EC,$66,$34,$06,$EC
                    fcb       $66,$34,$06,$17,$FE,$F4,$32,$64
                    fcb       $1F,$03,$EF,$7E,$2C,$04
                    fcc       /O_ /
                    fcb       $0F,$EC,$68
b110@               pshs      a,b
                    ldd       8,s
                    pshs      a,b
                    pshs      u
                    lbsr      SetupFile
                    leas      6,s
c110@               puls      u,pc
* PutsStdout (was L8C05): puts(s): FPutStr to stdout ($01BE) followed by CR
PutsStdout          pshs      u
                    leax      >$01BE,y
                    ldd       4,s
                    pshs      a,b,x
                    bsr       FPutStr
                    ldb       #$0D
                    stb       1,s
                    lbsr      FPutc
                    leas      4,s
                    puls      u,pc
* FPutStr (was L8C1C): fputs(s, fp) via FPutc
FPutStr             pshs      u
                    ldu       4,s
                    ldx       6,s
                    pshs      a,b,x
                    bra       b111@
a111@               stb       1,s
                    lbsr      FPutc
b111@               ldb       ,u+
                    bne       a111@
                    leas      4,s
                    puls      u,pc
* FWrite (was L8C33): fwrite(buf, size, count, fp) byte by byte through FPutc
FWrite              pshs      a,b,x,u
                    ldu       8,s
                    clra
                    clrb
                    bra       d112@
a112@               ldd       10,s
                    bra       c112@
b112@               ldx       14,s
                    ldb       ,u+
                    pshs      a,b,x
                    lbsr      FPutc
                    leas      4,s
                    cmpd      #$FFFF
                    beq       e112@
                    ldd       ,s
                    subd      #$0001
c112@               std       ,s
                    bne       b112@
                    ldd       2,s
                    addd      #$0001
d112@               std       2,s
                    cmpd      12,s
                    blt       a112@
e112@               leas      2,s
                    puls      a,b,u,pc
* Printf (was L8C69): printf: stores stdout in $0CCC and runs FormatEngine with PrintfPutc; vector $035D
Printf              pshs      u
                    leau      6,s
                    leax      >$01BE,y
                    ldd       4,s
                    bra       a113@
                    fcs       /4@3h./
                    fcb       $64,$EC,$66
a113@               stx       >$0CCC,y
                    leax      >PrintfPutc,pcr
                    bra       FmtDispatch
* SPrintf (was L8C87): sprintf: stores the buffer pointer in $0CCC and runs FormatEngine with SprintfPutc; vector $035F
SPrintf             pshs      u
                    ldd       4,s
                    std       >$0CCC,y
                    leau      8,s
                    ldd       6,s
                    leax      >SprintfPutc,pcr
* FmtDispatch (was L8C97): common tail of Printf/SPrintf: pushes args/format/output function and calls FormatEngine
FmtDispatch         pshs      a,b,u
                    pshs      x
                    bsr       FormatEngine
                    leas      6,s
                    puls      u,pc
* FmtEngineDone (was L8CA1): FormatEngine exit: FmtNextChar beq's here at the format NUL, drops the 8 local bytes and rts
FmtEngineDone       leas      8,s
                    rts
* FormatEngine (was L8CA4): _prtf: walks the format string handling %-, 0, width, .prec and c/d/u/x/X/o/s/l/f conversions
FormatEngine        ldu       4,s
                    leas      -8,s
                    bra       FmtNextChar
* FmtCharArm (was L8CAA): %c arm of FmtConvSwitch (cmpb #$63): fetches the next 2-byte arg, falls into FmtEmitChar
FmtCharArm          ldx       14,s
                    ldd       ,x++
                    stx       14,s
* FmtEmitChar (was L8CB0): Calls the output function [<$0A,s]; entered for literal chars and the unknown-letter default
FmtEmitChar         jsr       [<$0A,s]
* FmtNextChar (was L8CB3): loop head: fetch next format char, emit it unless '%'
FmtNextChar         ldb       ,u+
                    beq       FmtEngineDone
                    cmpb      #$25
                    bne       FmtEmitChar
                    clrb
                    lda       #$7D
                    std       ,s
                    stb       7,s
                    stb       2,s
                    ldb       ,u+
                    cmpb      #$2D
                    bne       a114@
                    stb       7,s
                    ldb       ,u+
a114@               cmpb      #$30
                    beq       b114@
                    ldb       #$20
b114@               stb       6,s
                    ldb       -1,u
                    lbsr      FmtParseNum
                    std       3,s
                    ldb       ,u+
                    cmpb      #$2E
                    bne       FmtConvSwitch
                    stb       2,s
                    ldb       ,u+
                    lbsr      FmtParseNum
                    std       ,s
                    ldb       ,u+
* FmtConvSwitch (was L8CEE): conversion-letter switch of FormatEngine
FmtConvSwitch       cmpb      #$63
                    beq       FmtCharArm
                    pshs      u
                    cmpb      #$66
                    beq       FmtFloat
                    cmpb      #$65
                    beq       FmtFloat
                    cmpb      #$67
                    beq       FmtFloat
                    cmpb      #$45
                    beq       FmtFloat
                    cmpb      #$47
                    beq       FmtFloat
                    cmpb      #$6C
                    beq       FmtLong
                    cmpb      #$73
                    beq       FmtString
                    cmpb      #$64
                    beq       FmtDecimal
                    cmpb      #$6F
                    lbeq      FmtOctal
                    cmpb      #$78
                    lbeq      FmtHex
                    cmpb      #$58
                    lbeq      FmtHex
                    cmpb      #$75
                    beq       FmtUnsigned
                    puls      u
                    bra       FmtEmitChar
* FmtFloat (was L8D2E): e/f/g/E/G conversions: calls the FmtFloatStub (floating point not linked)
FmtFloat            ldd       5,s
                    pshs      a,b
                    leax      <$12,s
                    ldd       4,s
                    tst       6,s
                    bne       a115@
                    ldd       #$0006
a115@               pshs      a,b,x
                    ldd       #$7D00
                    std       8,s
                    ldb       -1,u
                    clra
                    pshs      a,b
                    lbsr      FmtFloatStub
                    bra       FmtLongFloatOut
* FmtLong (was L8D4F): 'l' modifier: takes a 4-byte argument and adjusts the conversion via FmtLongSpec
FmtLong             pshs      u
                    ldx       <$12,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    leax      4,x
                    stx       <$16,s
                    ldb       ,u+
                    stu       6,s
                    pshs      a,b
                    lbsr      FmtLongSpec
* FmtLongFloatOut (was L8D6A): Tail of FmtFloat and FmtLong: drops the 8 pushed args, result string to U, then FmtPadEmit
FmtLongFloatOut     leas      8,s
                    tfr       d,u
                    lbra      FmtPadEmit
* FmtString (was L8D71): %s: StrLen, precision clip, FmtOutField
FmtString           bsr       FmtNextArg
                    tfr       d,u
                    pshs      u
                    lbsr      StrLen
                    leas      2,s
                    tst       4,s
                    beq       a116@
                    cmpd      2,s
                    bhi       a116@
                    std       2,s
a116@               lbsr      FmtOutField
                    lbra      FmtConvDone
* FmtDecimal (was L8D8D): %d: sign, then digits via the power-of-ten table at $01A6
FmtDecimal          bsr       FmtNumBuf
                    pshs      a,b,x,y,u
                    tsta
                    bpl       FmtDecDigits
                    nega
                    negb
                    sbca      #$00
                    std       ,s
                    ldb       #$2D
                    stb       ,u+
                    bra       FmtDecDigits
* FmtUnsigned (was L8DA0): %u conversion
FmtUnsigned         bsr       FmtNumBuf
                    pshs      a,b,x,y,u
* FmtDecDigits (was L8DA4): Shared digit loop of FmtDecimal (after sign) and FmtUnsigned, via the $01A6 power-of-ten table
FmtDecDigits        ldd       #$0005
                    std       2,s
                    sta       4,s
                    leax      >$01A6,y
                    puls      a,b
                    bra       e117@
a117@               inc       ,s
b117@               subd      ,x
                    bhs       a117@
                    addd      ,x++
                    pshs      b
                    ldb       1,s
                    tst       3,s
                    bne       c117@
                    tstb
                    beq       d117@
                    inc       3,s
c117@               addb      #$30
                    stb       ,u+
d117@               clr       1,s
                    puls      b
e117@               dec       1,s
                    bne       b117@
                    addb      #$30
                    stb       ,u+
                    clr       ,u
                    leas      4,s
                    bra       FmtNumPopBuf
* FmtNumBuf (was L8DDE): points U at the conversion buffer $0CCE and fetches the next argument
FmtNumBuf           leau      >$0CCE,y
* FmtNextArg (was L8DE2): loads the next 16-bit argument from the saved argument pointer
FmtNextArg          ldx       <$12,s
                    ldd       ,x++
                    stx       <$12,s
                    rts
* FmtHex (was L8DEB): %x/%X conversion (letter case from bit $20 of the conversion char)
FmtHex              andb      #$20
                    stb       7,s
                    bsr       FmtNumBuf
                    pshs      a,b,u
a118@               andb      #$0F
                    pshs      b
                    lda       #$30
                    cmpb      #$09
                    ble       b118@
                    lda       #$37
                    adda      12,s
b118@               adda      ,s+
                    sta       ,u+
                    ldd       ,s
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    std       ,s
                    bne       a118@
* FmtDigitsEnd (was L8E13): Terminates and reverses the digit buffer; entered from FmtHex fall-through and FmtOctal's bra
FmtDigitsEnd        clr       ,u
                    ldx       2,s
                    bsr       FmtReverse
                    leas      2,s
* FmtNumPopBuf (was L8E1B): Pops U = conversion buffer after the decimal loop, then falls into the pad-and-emit path
FmtNumPopBuf        puls      u
* FmtPadEmit (was L8E1D): bsr FmtPadString; entered from FmtLongFloatOut when U already holds the converted string
FmtPadEmit          bsr       FmtPadString
* FmtConvDone (was L8E1F): Restores the U pushed by FmtConvSwitch and resumes FmtNextChar; FmtString lbra's here
FmtConvDone         puls      u
                    lbra      FmtNextChar
* FmtRevSwap (was L8E24): Body of FmtReverse's loop: swaps the outer pair of digit-buffer bytes and steps inward
FmtRevSwap          ldb       ,x
                    lda       ,-u
                    sta       ,x+
                    stb       ,u
* FmtReverse (was L8E2C): reverses the digit buffer in place
FmtReverse          pshs      u
                    cmpx      ,s++
                    blo       FmtRevSwap
                    rts
* FmtOctal (was L8E33): %o conversion
FmtOctal            bsr       FmtNumBuf
                    pshs      a,b,u
a119@               andb      #$07
                    addb      #$30
                    stb       ,u+
                    ldd       ,s
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    std       ,s
                    bne       a119@
                    bra       FmtDigitsEnd
* FmtPadString (was L8E4B): StrLen of the converted buffer then FmtOutField
FmtPadString        pshs      u
                    lbsr      StrLen
                    leas      2,s
* FmtOutField (was L8E52): emits the field with left/right padding through the output function ([$0E,s])
FmtOutField         nega
                    negb
                    sbca      #$00
                    addd      7,s
                    std       7,s
                    tst       11,s
                    bne       b120@
                    bsr       FmtPadLoop
                    bra       b120@
a120@               ldb       ,u+
                    beq       c120@
                    jsr       [<$0E,s]
b120@               ldd       4,s
                    subd      #$0001
                    std       4,s
                    bpl       a120@
c120@               tst       11,s
                    beq       d120@
                    bsr       FmtPadLoop
d120@               rts
* FmtPadOneChar (was L8E79): Body of FmtPadLoop: loads the pad char at 12,s and calls the output function [<$10,s]
FmtPadOneChar       ldb       12,s
                    jsr       [<$10,s]
* FmtPadLoop (was L8E7E): emits pad characters while the width count is positive
FmtPadLoop          ldd       9,s
                    subd      #$0001
                    std       9,s
                    bpl       FmtPadOneChar
                    rts
* FmtParseNum (was L8E88): parses a decimal width/precision from the format using the ctype table at $0281 (digit bit $08)
FmtParseNum         clr       ,-s
                    clr       ,-s
                    leau      -1,u
                    leax      >$0281,y
                    bra       b121@
a121@               ldd       ,s
                    aslb
                    rola
                    std       ,s
                    aslb
                    rola
                    aslb
                    rola
                    addd      ,s
                    addb      ,u+
                    adca      #$00
                    subd      #$0030
                    std       ,s
                    ldb       ,u
b121@               lda       b,x
                    anda      #$08
                    bne       a121@
                    puls      a,b,pc
* PrintfPutc (was L8EB3): code left as data: ldx [$0CCC,y]; pshs x; lbsr FPutc - printf's character output
PrintfPutc          fcb       $AE,$A9,$0C,$CC,$34,$16,$17,$00
                    fcb       $10
                    fcc       /2d9/
* SprintfPutc (was L8EBF): code left as data: stores the char at [$0CCC,y]++ and terminates - sprintf's character output
SprintfPutc         fcb       $AE,$A9,$0C,$CC,$E7,$80,$AF,$A9
                    fcb       $0C,$CC,$6F,$84,$39
* FPutc (was L8ECC): putc(c, fp): buffers (InitFileBuf on first use), flushes on full buffer or CR in line mode, unbuffered write otherwise
FPutc               pshs      u
                    ldu       6,s
                    ldd       6,u
                    anda      #$80
                    andb      #$22
                    cmpb      #$02
                    bne       FileRetEof
                    cmpa      #$80
                    beq       a122@
                    pshs      u
                    lbsr      InitFileBuf
                    leas      2,s
a122@               ldd       6,u
                    andb      #$04
                    beq       d122@
                    ldd       #$0001
                    pshs      a,b
                    leax      7,s
                    ldd       8,u
                    pshs      a,b,x
                    ldb       7,u
                    andb      #$40
                    beq       b122@
                    lbsr      WriteLnPath
                    bra       c122@
b122@               lbsr      WritePath
c122@               leas      6,s
                    cmpd      #$FFFF
                    bne       g122@
                    ldb       7,u
                    orb       #$20
                    stb       7,u
* FileRetEof (was L8F12): Shared 'return -1' of FPutc, FClose and FFlush (null FILE, closed FILE, or write failure)
FileRetEof          ldd       #$FFFF
                    puls      u,pc
d122@               anda      #$01
                    bne       e122@
                    pshs      u
                    lbsr      FlushBuffer
                    std       ,s++
                    bne       FileRetEof
e122@               ldx       ,u
                    ldb       5,s
                    stb       ,x+
                    stx       ,u
                    cmpx      4,u
                    bhs       f122@
                    ldb       7,u
                    andb      #$40
                    beq       g122@
                    ldb       5,s
                    cmpb      #$0D
                    bne       g122@
f122@               pshs      u
                    lbsr      FlushBuffer
                    std       ,s++
                    bne       FileRetEof
g122@               ldd       4,s
                    puls      u,pc
                    fcb       $34,$40,$EE,$66,$E6
                    fcc       /d4F/
                    fcb       $17,$FF,$78,$E6,$69,$E7,$61,$17
                    fcb       $FF
                    fcs       /q2d5@/
* CloseAllFiles (was L8F5F): FClose on all 16 FILE slots (exit cleanup)
CloseAllFiles       pshs      u
                    leax      >$01B1,y
                    ldb       #$10
                    pshs      b
a123@               pshs      x
                    bsr       FClose
                    puls      x
                    leax      13,x
                    dec       ,s
                    bne       a123@
                    puls      b,u,pc
* FClose (was L8F77): fclose: FFlush if writable, ClosePath, clear flags
FClose              pshs      u
                    ldu       4,s
                    beq      FileRetEof
                    ldd       6,u
                    beq      FileRetEof
                    andb      #$02
                    beq       a124@
                    pshs      u
                    bsr       FFlush
                    leas      2,s
                    bra       b124@
a124@               clra
                    clrb
b124@               pshs      a,b
                    ldd       8,u
                    pshs      a,b
                    lbsr      ClosePath
                    leas      2,s
                    clra
                    clrb
                    std       6,u
                    puls      a,b,u,pc
* FFlush (was L8FA4): fflush(fp): InitFileBuf if needed then FlushBuffer
FFlush              pshs      u
                    ldu       4,s
                    lbeq      FileRetEof
                    ldd       6,u
                    andb      #$22
                    cmpb      #$02
                    lbne      FileRetEof
                    anda      #$80
                    bne       a125@
                    pshs      u
                    lbsr      InitFileBuf
                    leas      2,s
a125@               pshs      u
                    bsr       FlushBuffer
                    leas      2,s
                    puls      u,pc
* FlushBuffer (was L8FC9): writes the buffered bytes (WriteLnPath per line in line mode, WritePath otherwise) and resets the buffer; seeks first on read/write files
FlushBuffer         pshs      u
                    ldu       4,s
                    leas      -4,s
                    lda       6,u
                    anda      #$01
                    bne       a126@
                    ldd       ,u
                    cmpd      4,u
                    beq       a126@
                    clra
                    clrb
                    pshs      a,b
                    pshs      u
                    lbsr      ClearLongAcc
                    leas      2,s
                    ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    ldd       8,u
                    pshs      a,b
                    lbsr      SeekPath
                    leas      8,s
a126@               ldd       ,u
                    subd      2,u
                    std       2,s
                    beq      f126@
                    ldd       6,u
                    anda      #$01
                    beq      f126@
                    andb      #$40
                    beq       d126@
                    ldd       2,u
                    bra       c126@
b126@               pshs      a,b
                    ldd       ,u
                    pshs      a,b
                    ldd       8,u
                    pshs      a,b
                    lbsr      WriteLnPath
                    leas      6,s
                    std       ,s
                    cmpd      #$FFFF
                    beq       e126@
                    ldd       2,s
                    subd      ,s
                    std       2,s
                    ldd       ,u
                    addd      ,s
c126@               std       ,u
                    ldd       2,s
                    bne       b126@
                    bra       f126@
d126@               ldd       2,s
                    pshs      a,b
                    ldd       2,u
                    pshs      a,b
                    ldd       8,u
                    pshs      a,b
                    lbsr      WritePath
                    leas      6,s
                    cmpd      2,s
                    beq       f126@
e126@               ldb       7,u
                    orb       #$20
                    stb       7,u
                    ldd       4,u
                    std       ,u
                    ldd       #$FFFF
                    bra       g126@
f126@               lda       6,u
                    ora       #$01
                    sta       6,u
                    ldd       2,u
                    std       ,u
                    addd      11,u
                    std       4,u
                    clra
                    clrb
g126@               leas      4,s
                    puls      u,pc
* ClearLongAcc (was L9074): zeroes the 4-byte long accumulator at $0343
ClearLongAcc        leax      >$0343,y
                    clra
                    clrb
                    std       ,x
                    std       2,x
                    rts
* InitFileBuf (was L907F): first use of a FILE: GetStatus SS.Opt to pick line/block mode, SbrkAlloc a 256-byte buffer or fall back to the 1-byte slot
InitFileBuf         pshs      u
                    ldu       4,s
                    ldb       7,u
                    bitb      #$C0
                    bne       b127@
                    leas      <-$20,s
                    leax      ,s
                    ldd       8,u
                    pshs      a,b,x
                    clra
                    clrb
                    pshs      a,b
                    lbsr      GetStatus
                    ldb       #$40
                    lda       6,s
                    beq       a127@
                    ldb       #$80
a127@               leas      <$26,s
                    orb       7,u
                    stb       7,u
b127@               lda       6,u
                    ora       #$80
                    sta       6,u
                    andb      #$0C
                    bne       g127@
                    ldd       11,u
                    bne       c127@
                    ldd       #$0100
                    std       11,u
c127@               ldd       2,u
                    bne       d127@
                    ldd       11,u
                    pshs      a,b
                    lbsr      SbrkAlloc
                    leas      2,s
                    std       2,u
                    cmpd      #$FFFF
                    beq       e127@
d127@               ldb       #$08
                    bra       f127@
e127@               leax      10,u
                    stx       2,u
                    ldd       #$0001
                    std       11,u
                    ldb       #$04
f127@               orb       7,u
                    stb       7,u
                    ldd       2,u
                    addd      11,u
                    std       4,u
                    std       ,u
g127@               puls      u,pc
* FmtLongSpec (was L90ED): bsr'd by FmtLong: keeps the 4-byte path for d/o/x/X, else builds a 2-char spec at $01AE
FmtLongSpec         ldb       3,s
                    leax      >$01B0,y
                    cmpb      #$64
                    beq       h127@
                    cmpb      #$6F
                    beq       h127@
                    cmpb      #$78
                    beq       h127@
                    cmpb      #$58
                    beq       h127@
                    leax      -2,x
                    stb       1,x
h127@               tfr       x,d
                    rts
* FmtFloatStub (was L910A): returns the empty string for %e/%f/%g (no floating point library linked)
FmtFloatStub        leax      >strEmpty,pcr
                    tfr       x,d
                    rts
* strEmpty (was L9111): empty string returned by FmtFloatStub
strEmpty            fcb       $00
* SystemShell (was L9112): system(cmd): StackCheck, copies the command + CR, ForkProg 'shell', WaitChild until that pid exits
SystemShell         pshs      u
                    ldd       #$FF5A
                    lbsr      StackCheck
                    leas      <-$56,s
                    ldd       #$0051
                    ldu       <$5A,s
                    leax      ,s
                    pshs      a,b
                    pshs      x,u
                    lbsr      StrNCopy
                    leas      6,s
                    clr       <$50,s
                    leax      >strCR2,pcr
                    pshs      a,b,x
                    bsr      StrCat
                    leas      4,s
                    clra
                    clrb
                    pshs      a,b
                    incb
                    pshs      a,b
                    pshs      a,b
                    leax      6,s
                    pshs      x
                    pshs      x
                    bsr      StrLen
                    std       ,s
                    leax      >strShell,pcr
                    pshs      x
                    lbsr      ForkProg
                    leas      12,s
                    std       <$52,s
a128@               leax      <$54,s
                    pshs      x
                    lbsr      WaitChild
                    leas      2,s
                    cmpd      <$52,s
                    bne       a128@
                    leas      <$54,s
                    puls      a,b,u,pc
* strShell (was L9173): 'shell' forked by SystemShell
strShell            fcc       /shell/
* strCR2 (was L9178): CR appended to the shell command line
strCR2              fcb       $0D,$00
* StrCat (was L917A): strcat(dst, src) via StrEnd
StrCat              pshs      u
                    ldu       6,s
                    ldx       4,s
                    bsr       StrEnd
                    tfr       d,x
                    bra       StrCopyLoop
* StrCopy (was L9186): strcpy(dst, src)
StrCopy             pshs      u
                    ldu       6,s
                    ldx       4,s
* StrCopyLoop (was L918C): Byte copy loop entered by StrCopy fall-through and by StrCat's bra after StrEnd
StrCopyLoop         ldb       ,u+
                    stb       ,x+
                    bne       StrCopyLoop
                    ldd       4,s
                    puls      u,pc
                    fcb       $AE,$62
* StrEnd (was L9198): advances X to the terminating NUL (used by StrCat)
StrEnd              ldb       ,x+
                    bne       StrEnd
                    leax      -1,x
                    tfr       x,d
                    rts
* StrLen (was L91A1): strlen(s)
StrLen              pshs      u
                    ldu       4,s
a129@               ldb       ,u+
                    bne       a129@
                    leau      -1,u
                    tfr       u,d
                    subd      4,s
                    puls      u,pc
* StrNCopy (was L91B1): strncpy(dst, src, n) with NUL padding
StrNCopy            pshs      y,u
                    ldu       8,s
                    ldx       6,s
                    ldy       10,s
                    beq       c130@
a130@               ldb       ,u+
                    stb       ,x+
                    leay      -1,y
                    beq       c130@
                    tstb
                    bne       a130@
b130@               clr       ,x+
                    leay      -1,y
                    bne       b130@
c130@               ldd       6,s
                    puls      y,u,pc
* CopyHiBitName (was L91D1): copies an OS-9 name whose last char has bit 7 set into a C string (directory entries, device name)
CopyHiBitName       pshs      u
                    ldu       4,s
                    ldx       6,s
a131@               ldb       ,x+
                    stb       ,u+
                    bpl       a131@
                    andb      #$7F
                    stb       -1,u
                    clr       ,u
                    ldd       4,s
                    puls      u,pc
* StrIndex (was L91E7): index(s, c): pointer to the first c or 0
StrIndex            ldx       2,s
a132@               ldb       ,x+
                    beq       b132@
                    cmpb      5,s
                    bne       a132@
                    tfr       x,d
                    bra       c132@
b132@               clra
                    rts
                    fcb       $AE,$62,$CC,$00,$01,$34,$06,$20
                    fcb       $06,$E1,$67,$26,$02,$AF,$E4,$E6
                    fcb       $80,$26,$F6,$35,$06
c132@               subd      #$0001
                    rts
* MemClear (was L9210): zeroes n bytes at p
MemClear            pshs      u
                    ldu       4,s
                    clrb
                    ldx       6,s
                    beq       b133@
a133@               stb       ,u+
                    leax      -1,x
                    bne       a133@
b133@               ldd       4,s
                    puls      u,pc
* AtoI (was L9223): atoi: skips blanks/tabs, optional sign, decimal digits
AtoI                pshs      u
                    ldu       4,s
                    clra
                    clrb
                    pshs      a,b
                    pshs      b
a134@               ldb       ,u+
                    cmpb      #$20
                    beq       a134@
                    cmpb      #$09
                    beq       a134@
                    cmpb      #$2D
                    bne       b134@
                    stb       ,s
                    bra       d134@
b134@               cmpb      #$2B
                    bne       e134@
                    bra       d134@
c134@               ldd       1,s
                    aslb
                    rola
                    aslb
                    rola
                    addd      1,s
                    aslb
                    rola
                    pshs      a,b
                    ldb       -1,u
                    clra
                    subb      #$30
                    addd      ,s++
                    std       1,s
d134@               ldb       ,u+
e134@               cmpb      #$30
                    blo       f134@
                    cmpb      #$39
                    bls       c134@
f134@               tst       ,s+
                    puls      a,b
                    beq       g134@
                    nega
                    negb
                    sbca      #$00
g134@               puls      u,pc
* Lsn24ToLong (was L9270): expands n 3-byte LSNs into 4-byte longs (used on directory entries by PrintCurDir)
Lsn24ToLong         pshs      u
                    ldu       4,s
                    ldd       6,s
                    addd      #$0001
                    bra       b135@
a135@               clra
                    clrb
                    stb       ,u
                    ldx       6,s
                    ldb       -1,x
                    stb       1,u
                    ldd       [<$06,s]
                    std       2,u
                    leau      4,u
                    ldd       6,s
                    addd      #$0003
b135@               std       6,s
                    ldd       8,s
                    addd      #$FFFF
                    std       8,s
                    subd      #$FFFF
                    bgt       a135@
                    puls      u,pc
* SleepSeconds (was L92A1): sleep(n): n * F$TPS ticks (10 or 100 fallback) then TSleep; sleep(0) = TSleep(1)
SleepSeconds        ldd       2,s
                    beq       c136@
                    pshs      a,b
                    os9       F$TPS
                    bhs       b136@
                    clra
                    os9       F$ID
                    os9       F$SUser
                    bhs       a136@
                    ldd       #$000A
                    bra       b136@
a136@               ldd       #$0064
b136@               lbsr      MulInt
                    bra       d136@
c136@               ldd       #$0001
d136@               pshs      a,b
                    lbsr      TSleep
                    puls      x,pc
* LongMul (was L92CC): 32x32-bit multiply into the long accumulator $0343
LongMul             ldd       2,x
                    pshs      a,b
                    ldd       ,x
                    pshs      a,b
                    leax      >$0343,y
                    clr       ,x
                    clr       1,x
                    lda       9,s
                    ldb       3,s
                    mul
                    std       2,x
                    lda       9,s
                    ldb       2,s
                    mul
                    addd      1,x
                    std       1,x
                    bhs       a137@
                    inc       ,x
a137@               lda       8,s
                    ldb       3,s
                    mul
                    addd      1,x
                    std       1,x
                    bhs       b137@
                    inc       ,x
b137@               lda       9,s
                    ldb       1,s
                    mul
                    addd      ,x
                    std       ,x
                    lda       8,s
                    ldb       2,s
                    mul
                    addd      ,x
                    std       ,x
                    lda       7,s
                    ldb       3,s
                    mul
                    addd      ,x
                    std       ,x
                    lda       9,s
                    ldb       ,s
                    mul
                    addb      ,x
                    stb       ,x
                    lda       8,s
                    ldb       1,s
                    mul
                    addb      ,x
                    stb       ,x
                    lda       7,s
                    ldb       2,s
                    mul
                    addb      ,x
                    stb       ,x
                    lda       6,s
                    ldb       3,s
                    mul
                    addb      ,x
                    stb       ,x
                    leas      4,s
                    lbra      LongRetAcc
* LongDiv (was L9341): signed 32-bit divide: LongDivCore then negate the result if the signs differed
LongDiv             bsr       LongDivCore
                    lda       1,s
                    beq       a138@
                    lbsr      LongNegate
a138@               leas      8,s
                    lbra      LongRetAcc
                    fcb       $A6,$84,$AA,$01,$AA,$02,$AA,$03
                    fcb       $26,$11,$EC,$84,$ED,$A9,$03,$43
                    fcb       $EC,$02,$30,$A9,$03,$43,$ED,$02
                    fcb       $16,$01,$50,$A6,$62,$A7,$A9,$0C
                    fcb       $D8,$8D,$2D,$EC,$6A,$30,$A9,$03
                    fcb       $43,$ED,$84,$EC,$6C,$ED,$02,$6D
                    fcb       $A9,$0C,$D8,$2B,$C3,$32,$68,$16
                    fcb       $01,$31
* LongDivCore (was L9389): unsigned long shift-subtract divide; divisor 0 -> RaiseSignal($2D)
LongDivCore         lda       ,x
                    ora       1,x
                    ora       2,x
                    ora       3,x
                    bne       a139@
                    ldd       2,s
                    std       6,s
                    leas      6,s
                    ldd       #$002D
                    lbra      RaiseSignal
a139@               ldd       ,x
                    ldx       2,x
                    pshs      a,b,x
                    ldd       #$0000
                    pshs      a,b
                    std       >$0343,y
                    std       >$0345,y
                    tst       2,s
                    bpl       b139@
                    leax      2,s
                    lbsr      LongNegate
                    inc       1,s
b139@               tst       10,s
                    bpl       c139@
                    leax      10,s
                    lbsr      LongNegate
                    com       1,s
c139@               leax      >$0343,y
                    lda       #$01
d139@               inca
                    asl       5,s
                    rol       4,s
                    rol       3,s
                    rol       2,s
                    bpl       d139@
                    sta       ,s
e139@               ldd       12,s
                    subd      4,s
                    std       12,s
                    ldd       10,s
                    sbcb      3,s
                    sbca      2,s
                    std       10,s
                    bhs       f139@
                    ldd       12,s
                    addd      4,s
                    std       12,s
                    ldd       10,s
                    adcb      3,s
                    adca      2,s
                    std       10,s
                    andcc     #$FE
                    bra       g139@
f139@               orcc      #$01
g139@               rol       3,x
                    rol       2,x
                    rol       1,x
                    rol       ,x
                    lsr       2,s
                    ror       3,s
                    ror       4,s
                    ror       5,s
                    dec       ,s
                    bne       e139@
                    jmp       [<$06,s]
* LongAdd (was L9416): long at X += 4-byte argument, result in the accumulator
LongAdd             ldd       4,s
                    addd      2,x
                    std       >$0345,y
                    ldd       2,s
                    adcb      1,x
                    adca      ,x
                    std       >$0343,y
                    lbra      LongRetAcc
* LongSub (was L942B): long subtraction into the accumulator
LongSub             ldd       4,s
                    subd      2,x
                    std       >$0345,y
                    ldd       2,s
                    sbcb      1,x
                    sbca      ,x
                    std       >$0343,y
                    bra      LongRetAcc
* LongCmp (was L9440): compares the 4-byte argument with the long at X, sets N/Z/C for the caller's branch
LongCmp             ldd       2,s
                    cmpd      ,x
                    bne       b140@
                    ldd       4,s
                    cmpd      2,x
                    beq       b140@
                    blo       a140@
                    lda       #$01
                    andcc     #$FE
                    bra       b140@
a140@               clra
                    cmpa      #$01
b140@               pshs      cc
                    ldd       1,s
                    std       5,s
                    puls      cc
                    leas      4,s
                    rts
* LongNegLoad (was L9464): loads the long at X into the accumulator and negates it
LongNegLoad         bsr      LongLoadAcc
* LongNegate (was L9467): negates the long at X in place
LongNegate          ldd       #$0000
                    subd      2,x
                    std       2,x
                    ldd       #$0000
                    sbcb      1,x
                    sbca      ,x
                    std       ,x
                    rts
                    fcb       $EC,$84,$43,$53,$ED,$A9,$03,$43
                    fcb       $EC,$02
                    fcs       /CS0)/
                    fcb       $03,$43,$ED,$02,$39
* IntToLong (was L948B): sign-extends D into the long accumulator
IntToLong           leax      >$0343,y
                    std       2,x
                    tfr       a,b
                    sex
                    tfr       a,b
                    std       ,x
                    rts
                    fcb       $30,$A9,$03,$43,$ED,$02,$6F,$84
                    fcb       $6F,$01,$39
* LongStore (was L94A4): copies the long at X to the destination pointed to by the argument
LongStore           pshs      y
                    ldy       4,s
                    ldd       ,x
                    std       ,y
                    ldd       2,x
                    std       2,y
                    puls      x
                    exg       y,x
                    puls      a,b
                    std       ,s
                    rts
* LongRetAcc (was L94BA): common return leaving X pointing at the long accumulator $0343
LongRetAcc          tfr       cc,a
                    puls      x
                    stx       2,s
                    leas      2,s
                    leax      >$0343,y
                    tfr       a,cc
                    rts
* LongLoadAcc (was L94C9): copies the long at X into the accumulator
LongLoadAcc         ldd       ,x
                    std       >$0343,y
                    ldd       2,x
                    leax      >$0343,y
                    std       2,x
                    rts
* MulInt (was L94D8): 16x16 multiply (fast path when both high bytes are 0), low word in D, high in X
MulInt              tsta
                    bne       a141@
                    tst       2,s
                    bne       a141@
                    lda       3,s
                    mul
                    ldx       ,s
                    stx       2,s
                    ldx       #$0000
                    std       ,s
                    puls      a,b,pc
a141@               pshs      a,b
                    ldd       #$0000
                    pshs      a,b
                    pshs      a,b
                    lda       5,s
                    ldb       9,s
                    mul
                    std       2,s
                    lda       5,s
                    ldb       8,s
                    mul
                    addd      1,s
                    std       1,s
                    bhs       b141@
                    inc       ,s
b141@               lda       4,s
                    ldb       9,s
                    mul
                    addd      1,s
                    std       1,s
                    bhs       c141@
                    inc       ,s
c141@               lda       4,s
                    ldb       8,s
                    mul
                    addd      ,s
                    std       ,s
                    ldx       6,s
                    stx       8,s
                    ldx       ,s
                    ldd       2,s
                    leas      8,s
                    rts
                    fcb       $6F,$A9,$0C,$D9,$30,$8D,$00,$40
                    fcb       $AF,$A9,$0C,$DA,$20,$14
* ModInt (was L9539): signed 16-bit modulo: calls DivInt through $0CDA and returns the remainder with the dividend's sign
ModInt              leax      >DivInt,pcr
                    stx       >$0CDA,y
                    clr       >$0CD9,y
                    tst       2,s
                    bpl       a142@
                    inc       >$0CD9,y
a142@               subd      #$0000
                    bne       b142@
                    puls      x
                    ldd       ,s++
                    jmp       ,x
b142@               ldx       2,s
                    pshs      x
                    jsr       [>$0CDA,y]
                    ldd       ,s
                    std       2,s
                    tfr       x,d
                    tst       >$0CD9,y
                    beq       c142@
                    nega
                    negb
                    sbca      #$00
c142@               std       ,s++
                    rts
                    fcb       $83,$00,$00,$27,$0A,$34,$06
                    fcs       /2~od/
                    fcc       /oa ./
* DivZeroTrap (was L9582): divide by zero: RaiseSignal($2D)
DivZeroTrap         puls      a,b
                    std       ,s
                    ldd       #$002D
                    lbra      RaiseSignal
* DivInt (was L958C): signed 16-bit divide: quotient in D, remainder in X
DivInt              subd      #$0000
                    beq       DivZeroTrap
                    pshs      a,b
                    leas      -2,s
                    clr       ,s
                    clr       1,s
                    tsta
                    bpl       a143@
                    nega
                    negb
                    sbca      #$00
                    com       1,s
                    std       2,s
a143@               ldd       6,s
                    bpl       b143@
                    nega
                    negb
                    sbca      #$00
                    com       1,s
                    std       6,s
b143@               lda       #$01
c143@               inca
                    asl       3,s
                    rol       2,s
                    bpl       c143@
                    sta       ,s
                    ldd       6,s
                    clr       6,s
                    clr       7,s
d143@               subd      2,s
                    bhs       e143@
                    addd      2,s
                    andcc     #$FE
                    bra       f143@
e143@               orcc      #$01
f143@               rol       7,s
                    rol       6,s
                    lsr       2,s
                    ror       3,s
                    dec       ,s
                    bne       d143@
                    std       2,s
                    tst       1,s
                    beq       g143@
                    ldd       6,s
                    nega
                    negb
                    sbca      #$00
                    std       6,s
g143@               ldx       4,s
                    ldd       6,s
                    std       4,s
                    stx       6,s
                    ldx       2,s
                    ldd       4,s
                    leas      6,s
                    rts
* ShiftRightArith (was L95F6): arithmetic shift right of the 16-bit argument by B
ShiftRightArith     tstb
                    beq       ShiftDone
a144@               asr       2,s
                    ror       3,s
                    decb
                    bne       a144@
                    bra       ShiftDone
* ShiftRightLog (was L9602): logical shift right by B
ShiftRightLog       tstb
                    beq       ShiftDone
a145@               lsr       2,s
                    ror       3,s
                    decb
                    bne       a145@
* ShiftDone (was L960C): common exit of the shift helpers
ShiftDone           ldd       2,s
                    pshs      a,b
                    ldd       2,s
                    std       4,s
                    ldd       ,s
                    leas      4,s
                    rts
* ShiftLeft (was L9619): shift left by B
ShiftLeft           tstb
                    beq       ShiftDone
a146@               asl       3,s
                    rol       2,s
                    decb
                    bne       a146@
                    bra       ShiftDone
* RaiseSignal (was L9625): stores D in errno ($034F) and F$Send's signal B to its own process id
RaiseSignal         std       >$034F,y
                    pshs      b,y
                    os9       F$ID
                    puls      b,y
                    os9       F$Send
                    rts
                    fcb       $C6,$01,$A6,$63,$10,$3F,$8D,$10
                    fcb       $25,$04
                    fcs       / O9F/
                    fcb       $06,$20,$08,$C6,$00,$20,$02
* GetDevName (was L9649): I$GetStt SS.DevNm ($0E) into the buffer
GetDevName          ldb       #$0E
                    ldx       4,s
                    lda       3,s
                    os9       I$GetStt
                    bra       a147@
                    fcb       $34,$20,$C6,$0F,$A6,$65,$AE,$66
                    fcb       $10,$AE,$68,$10,$3F,$8D,$35,$20
a147@               lbra      RetChkCarry
* GetStatus (was L9667): _gs_* wrapper: I$GetStt with codes 0 Opt, 1 Ready, 2 Size, 5 Pos, 6 EOF, $0E, $0F; errno $D0 otherwise
GetStatus           pshs      y,u
                    lda       9,s
                    ldb       7,s
                    beq       e148@
                    cmpb      #$01
                    beq       f148@
                    cmpb      #$02
                    beq       a148@
                    cmpb      #$05
                    beq       a148@
                    cmpb      #$06
                    beq       f148@
                    cmpb      #$0E
                    beq       e148@
                    cmpb      #$0F
                    beq       d148@
                    ldb       #$D0
                    bra       b148@
a148@               os9       I$GetStt
                    bhs       c148@
b148@               puls      y,u
                    lbra      ErrReturn
c148@               stx       [<$0A,s]
                    ldx       10,s
                    stu       2,x
                    clra
                    clrb
                    puls      y,u,pc
d148@               ldy       12,s
e148@               ldx       10,s
f148@               os9       I$GetStt
                    puls      y,u
                    lbra      RetChkCarry
                    fcb       $34,$60,$A6,$69,$E6
                    fcs       /g'HA/
                    fcb       $02,$27,$42,$C1,$03,$27,$40,$C1
                    fcb       $04,$27,$37,$C1,$0A,$27,$48,$C1
                    fcb       $0B,$27,$34,$C1,$0C,$27,$40,$C1
                    fcb       $0D,$27,$30,$C1,$0F,$27,$28,$C1
                    fcb       $10,$27,$24,$C1,$11,$27,$1E,$C1
                    fcb       $14,$27,$17,$C1,$15,$27,$13,$C1
                    fcb       $19,$27,$0F,$C1,$1A,$27,$10,$C1
                    fcb       $1B,$27,$1C,$C6,$D0,$35,$60,$16
                    fcb       $03,$67,$10,$AE,$6E,$EE,$6C,$AE
                    fcb       $6A,$20,$0C,$1F,$89,$A6,$6B,$AE
                    fcb       $6C,$10,$AE,$6E,$EE,$E8,$10,$10
                    fcb       $3F,$8E,$35,$60,$16,$03,$53,$AE
                    fcb       $62,$A6,$65,$10,$3F,$84,$25,$03
                    fcb       $10,$3F,$8F,$16,$03,$44,$AE,$62
                    fcb       $E6,$65,$10,$3F,$85,$16,$03,$3A
                    fcb       $A6,$65,$20,$02,$86,$02,$AE,$62
                    fcb       $10,$3F,$90,$16,$03,$2C
* DupPath (was L973C): I$Dup wrapper
DupPath             lda       3,s
                    os9       I$Dup
                    lblo      ErrReturn
                    tfr       a,b
                    clra
                    rts
* CreateFile (was L9749): creat(): I$Create; on E$CEF reopens with I$Open and truncates via I$SetStt SS.Size 0
CreateFile          ldx       2,s
                    lda       5,s
                    tfr       a,b
                    andb      #$24
                    orb       #$0B
                    os9       I$Create
                    bhs       b149@
                    cmpb      #$DA
                    bne       a149@
                    lda       5,s
                    bita      #$80
                    bne       a149@
                    anda      #$07
                    ldx       2,s
                    os9       I$Open
                    blo       a149@
                    pshs      a,u
                    ldx       #$0000
                    leau      ,x
                    ldb       #$02
                    os9       I$SetStt
                    puls      a,u
                    bhs       b149@
                    pshs      b
                    os9       I$Close
                    puls      b
a149@               lbra      ErrReturn
                    fcb       $AE,$62,$A6,$65,$E6,$67,$10,$3F
                    fcb       $83,$25,$F2,$20,$14,$C1,$DA,$26
                    fcb       $EC,$10,$3F,$87,$25,$E7,$AE,$62
                    fcb       $A6,$65,$E6,$67,$10,$3F,$83,$25
                    fcb       $EC
b149@               tfr       a,b
                    clra
                    rts
* OpenPath (was L97AA): I$Open wrapper (returns path or -1 with errno)
OpenPath            ldx       2,s
                    lda       5,s
                    os9       I$Open
                    lblo      ErrReturn
                    tfr       a,b
                    clra
                    rts
* OpenConsole(name, mode): opens the terminal s9 was started on ('/' + path 2's device name, SS.DevNm)
* rather than the name passed (/term): under the multiterminal vtio a vt's keys go only to its own
* paths. The name passed is the fallback. Keeps Y.
OpenConsole         leas      -34,s
                    lda       #'/
                    sta       ,s
                    leax      1,s
                    lda       #$02
                    ldb       #SS.DevNm
                    os9       I$GetStt            the device name, high bit on its last character
                    leax      ,s
                    bcc       oc1@
                    ldx       36,s                no name: the one passed
oc1@                lda       39,s                the mode
                    os9       I$Open
                    leas      34,s                (LEAS keeps the carry)
                    lblo      ErrReturn
                    tfr       a,b
                    clra
                    rts
* ClosePath (was L97B9): I$Close wrapper
ClosePath           lda       3,s
                    os9       I$Close
                    lbra      RetChkCarry
* ReadPath (was L97C1): I$Read wrapper (E$EOF returns 0)
ReadPath            pshs      y
                    ldx       6,s
                    lda       5,s
                    ldy       8,s
                    pshs      y
                    os9       I$Read
                    bhs       b150@
                    cmpb      #$D3
                    bne       a150@
                    clra
                    clrb
                    puls      x,y,pc
a150@               puls      x,y
                    lbra      ErrReturn
b150@               tfr       y,d
                    puls      x,y,pc
                    fcb       $34,$20,$A6,$65,$AE,$66,$10,$AE
                    fcc       /h4 /
                    fcb       $10,$3F,$8B,$20,$DD
* WritePath (was L97F2): I$Write wrapper
WritePath           pshs      y
                    ldy       8,s
                    beq       WriteCountRet
                    lda       5,s
                    ldx       6,s
                    os9       I$Write
* WriteChkCarry (was L9800): Carry check shared by WritePath (fall-through) and WriteLnPath: error goes to ErrReturn
WriteChkCarry       bhs       WriteCountRet
                    puls      y
                    lbra      ErrReturn
* WriteCountRet (was L9807): Returns Y (bytes written) as D; also the count == 0 shortcut of WritePath and WriteLnPath
WriteCountRet       tfr       y,d
                    puls      y,pc
* WriteLnPath (was L980B): I$WritLn wrapper
WriteLnPath         pshs      y
                    ldy       8,s
                    beq       WriteCountRet
                    lda       5,s
                    ldx       6,s
                    os9       I$WritLn
                    bra       WriteChkCarry
* SeekPath (was L981B): lseek(path, long offset, whence 0/1/2) using SS.Pos/SS.Size then I$Seek
SeekPath            pshs      u
                    ldd       10,s
                    bne       a151@
                    ldu       #$0000
                    ldx       #$0000
                    bra       SeekApplyOfs
a151@               cmpd      #$0001
                    beq       SeekCurArm
                    cmpd      #$0002
                    beq       SeekEndArm
                    ldb       #$F7
* SeekError (was L9837): error exit of SeekPath: errno, returns -1L
SeekError           clra
                    std       >$034F,y
                    ldd       #$FFFF
                    leax      >$0343,y
                    std       ,x
                    std       2,x
                    puls      u,pc
* SeekEndArm (was L9849): whence == 2 arm of SeekPath: I$GetStt SS.Size ($02) gives the base for SeekApplyOfs
SeekEndArm          lda       5,s
                    ldb       #$02
                    os9       I$GetStt
                    blo       SeekError
                    bra       SeekApplyOfs
* SeekCurArm (was L9854): whence == 1 arm of SeekPath: I$GetStt SS.Pos ($05) gives the base, falls into SeekApplyOfs
SeekCurArm          lda       5,s
                    ldb       #$05
                    os9       I$GetStt
                    blo       SeekError
* SeekApplyOfs (was L985D): Common tail of the three SeekPath arms: adds the 32-bit offset to U:X and issues I$Seek
SeekApplyOfs        tfr       u,d
                    addd      8,s
                    std       >$0345,y
                    tfr       d,u
                    tfr       x,d
                    adcb      7,s
                    adca      6,s
                    bmi       SeekError
                    tfr       d,x
                    std       >$0343,y
                    lda       5,s
                    os9       I$Seek
                    blo       SeekError
                    leax      >$0343,y
                    puls      u,pc
                    fcb       $39,$8E,$00,$00,$5F,$10,$3F,$0A
                    fcb       $16,$01,$D2
                    fcs       /94`./
                    fcb       $66,$10,$AE,$68,$EE,$6A,$10,$3F
                    fcb       $17,$35,$E0,$A6,$63,$E6,$65,$10
                    fcb       $3F,$0F,$10,$25,$01,$B8,$39
* TSleep (was L98A8): F$Sleep wrapper (ticks in X)
TSleep              ldx       2,s
                    os9       F$Sleep
                    lblo      ErrReturn
                    tfr       x,d
                    rts
* ChangeDir (was L98B4): I$ChgDir (read mode) wrapper
ChangeDir           lda       #$01
                    ldx       2,s
                    os9       I$ChgDir
                    lbra      RetChkCarry
                    fcb       $86,$04,$20,$F4,$EC,$A9,$03,$41
                    fcb       $34,$06,$EC,$64,$10,$A3,$A9,$0C
                    fcb       $DC
                    fcc       /%&4 O_/
                    fcb       $10,$3F,$07,$E3,$66,$10,$3F,$07
                    fcb       $1F
                    fcc       / 5 $/
                    fcb       $06,$CC,$FF,$FF
                    fcs       /2b9m/
                    fcb       $A9,$03,$41,$E3,$A9,$0C,$DC,$A3
                    fcb       $E4,$ED,$A9,$0C,$DC,$32,$62,$EC
                    fcb       $A9,$0C,$DC,$34,$06,$A3,$64,$ED
                    fcb       $A9,$0C,$DC,$EC,$A9,$03,$41,$A3
                    fcb       $E1,$34,$06,$4F,$AE,$E4,$A7,$80
                    fcb       $AC,$A9,$03,$41,$25,$F8,$35,$86
* SbrkAlloc (was L991A): sbrk(n): grows the heap top $034B toward the stack mark $034D, zero-filling; -1 when full
SbrkAlloc           ldd       2,s
                    addd      >$034B,y
                    blo       SbrkFail
                    cmpd      >$034D,y
                    bhs       SbrkFail
                    pshs      a,b
                    ldx       >$034B,y
                    clra
a152@               cmpx      ,s
                    bhs       b152@
                    sta       ,x+
                    bra       a152@
b152@               ldd       >$034B,y
                    puls      x
                    stx       >$034B,y
                    rts
* SbrkFail (was L9943): returns -1 from SbrkAlloc
SbrkFail            ldd       #$FFFF
                    rts
                    fcb       $EC
                    fcc       /b4 /
                    fcb       $10,$3F,$07,$24,$05,$CC,$FF,$FF
                    fcb       $35,$A0,$1F
                    fcs       / 5 m/
                    fcb       $A9,$03
                    fcs       /AO_m/
                    fcb       $A9,$0C,$DC,$39,$A6,$63,$E6,$65
                    fcb       $10,$3F,$08,$16,$00,$FA
* WaitChild (was L996E): F$Wait wrapper returning the child pid and storing its status
WaitChild           clra
                    clrb
                    os9       F$Wait
                    lblo      ErrReturn
                    ldx       2,s
                    beq       a153@
                    stb       1,x
                    clr       ,x
a153@               tfr       a,b
                    clra
                    rts
* SetPriority (was L9983): F$SPrior wrapper
SetPriority         lda       3,s
                    ldb       5,s
                    os9       F$SPrior
                    lbra      RetChkCarry
                    fcb       $33,$E4,$32,$A9,$00,$FF,$AE,$42
                    fcb       $10,$AE,$44,$A6
                    fcs       /IHHHH*/
                    fcb       $4B,$E6,$4D,$EE,$46,$10,$3F,$05
                    fcb       $10,$3F,$06
* ForkProg (was L99AA): os9fork(name, params, paramlen, type, lang, datasize) F$Fork wrapper
ForkProg            pshs      y,u
                    ldx       6,s
                    ldy       8,s
                    ldu       10,s
                    lda       13,s
                    ora       15,s
                    ldb       <$11,s
                    os9       F$Fork
                    puls      y,u
                    lblo      ErrReturn
                    tfr       a,b
                    clra
                    rts
* GetPid (was L99C7): F$ID wrapper returning the process id
GetPid              pshs      y
                    os9       F$ID
                    puls      y
                    tfr       a,b
                    clra
                    rts
                    fcb       $34,$20,$10,$3F,$0C,$1F,$20,$35
                    fcb       $A0
                    fcc       /4  /
                    fcb       $0F,$34,$20,$8D,$EF,$ED,$7E,$27
                    fcb       $07,$C6,$D6,$35,$20,$16,$00,$71
                    fcb       $10,$AE,$64,$10,$3F,$1C,$24,$0C
                    fcb       $C1,$D0,$26,$EF,$1F,$20,$10,$BE
                    fcb       $00,$4B,$ED
                    fcs       /)O_5 /
* SetIntercept (was L9A06): F$Icpt with the IcptTrampoline; stores the C handler at $0CDE
SetIntercept        pshs      u
                    tfr       y,u
                    ldx       4,s
                    stx       >$0CDE,y
                    leax      >IcptTrampoline,pcr
                    os9       F$Icpt
                    puls      u
                    bra      RetChkCarry
* IcptTrampoline (was L9A1C): intercept stub code left as text: sets up regs, jsr [$0CDE,y] (the C handler), rti
IcptTrampoline      fcb       $1F
                    fcc       /2O4/
                    fcb       $06,$AD,$B9,$0C,$DE
                    fcc       /2b;/
* Os9Call (was L9A28): _os9(code, &regs): builds 'swi2 code; rts' on the stack, loads/stores the register struct, returns -1 on carry
Os9Call             pshs      y,u
                    lda       7,s
                    ldb       #$39
                    pshs      a,b
                    ldd       #$103F
                    pshs      a,b
                    ldu       12,s
                    ldd       1,u
                    ldx       4,u
                    ldy       6,u
                    ldu       8,u
                    jsr       ,s
                    pshs      cc,u
                    ldu       15,s
                    leau      8,u
                    pshu      a,b,dp,x,y
                    puls      a,x
                    sta       ,-u
                    stx       8,u
                    leas      4,s
                    puls      y,u
                    bita      #$01
                    beq       a154@
                    ldd       #$FFFF
                    rts
a154@               clra
                    clrb
                    rts
* ErrReturn (was L9A5F): stores the error code in errno $034F and returns -1
ErrReturn           clra
                    std       >$034F,y
                    ldd       #$FFFF
                    rts
* RetChkCarry (was L9A68): ErrReturn on carry, else returns 0
RetChkCarry         blo       ErrReturn
                    clra
                    clrb
                    rts
* ExitProg (was L9A6D): exit(n): CleanupStub, CloseAllFiles, waits for every child, then F$Exit
* Once the paths are closed s9gui sees EOF on its pipe and exits, freeing the bitmap, its symbol bank
* and its save arena; F$Wait until E$NoChld so the memory is back before the shell prompt returns.
ExitProg            bsr      CleanupStub
                    lbsr      CloseAllFiles
xw@                 os9       F$Wait              one child per call; carry + E$NoChld when none is left
                    bcc       xw@
* ExitNow (was L9A73): _exit(n): F$Exit directly
ExitNow             ldd       2,s
                    os9       F$Exit
* CleanupStub: closes the /mi path and, if SAM audio is off, turns it back on (MidiApplyMix: s9r 'c').
CleanupStub         lda       >MidiInPath
                    beq       cmsclose@
                    deca
                    os9       I$Close
                    clr       >MidiInPath
cmsclose@           tst       <midiser
                    bne       cms_done@
                    inc       <midiser
MidiApplyMix        ldd       #'c
                    pshs      d
                    ldd       #'R
                    pshs      d
                    lbsr      soowee
                    leas      4,s
cms_done@           rts
* ===================================================================================================
* THE TAIL. Everything above is the program and must end below $A000: five blocks, the most the process
* can keep mapped (data in slot 0, one event page and one overlay in the other two). Blocks 6 and 7 of
* the module hold what is needed once or by s9gui:
*   $A000  UmeSymbols16 bank 1 ($1B00 bytes of ../.mods/SYS/UmeSymbols16.img from 0) -> s9gui's symbol bank
*   $BB00  the start-up data image CStart copies into the data area, TailInit and module_dir.inc
*   $C000  UmeSymbols16 bank 2 (the rest of the image, from $1B00) -> s9gui, contiguous after bank 1
*          (part-type icons and piano-key images sit at its end - see UmeSymbols16.asm)
* Chars16 is embedded in s9gui. The module ends below $DD00 so its last block may sit in slot 7 under
* $FD00-$FFFF. main reads the two blocks' numbers (TailInit) and gives the slots back with F$ClrBlk.
                    fill      0,$A000-*           a negative count is an assembly error: the code has grown past five blocks
TailBlock6          equ       *
* Bank 1 comes straight from the raw image.
                    includebin ../.mods/SYS/UmeSymbols16.img,0,$1B00
* InitDataImage (was L9A79): initialized-data image (sizes, relocation lists, format pointers, tables)
* copied into the data area by CStart. Every module-relative pointer in it is an fdb of its label (26).
InitDataImage       fcb       $00,$22,$00,$00,$00,$00,$04,$00
                    fcb       $04,$00,$00,$00,$01,$47,$01,$45
                    fcb       $01,$43,$01,$41,$01,$3F,$01,$3D
                    fcb       $01,$56,$01,$54,$01,$52,$01,$50
                    fcb       $01,$4E,$01,$4C,$02,$0A,$01,$68
                    fcb       $34,$63,$00,$03,$00,$02,$00,$04
                    fcb       $00,$00,$01,$22,$4D,$57,$61,$6B     the 8 default MIDI volume levels 1,34,77,87,97,107,117,127
                    fcb       $75,$7F,$03,$00,$00,$00,$02,$03
                    fcb       $00,$00,$00,$02,$03,$00,$20,$00
                    fcb       $02,$02,$03,$02,$03,$04,$03,$03
                    fcb       $03,$03,$03,$03,$03,$00,$03,$03
                    fcb       $03,$03,$03,$03,$03,$03,$03,$00     data $0130 = type $16 (channel mark): width 0 - the markers of one time
                    fcb       $00,$03,$02,$02,$02,$04,$04,$02     share a column; s9s steps the next non-marker on by 3
                    fcb       $02,$03,$03,$01,$25,$63,$25,$63
                    fcb       $25,$63,$25,$63,$25,$63,$25,$63
                    fcb       $25,$63,$00,$25,$63,$25,$63,$25
                    fcb       $63,$25,$63,$25,$63,$25,$63,$0D
                    fcb       $00,$01,$80,$02,$40,$02,$A0,$01
                    fcb       $00
                    fdb       L017C
                    fcb       $00,$18
                    fdb       L0183
                    fcb       $00,$0C
                    fdb       L0188
                    fcb       $00,$11
                    fdb       L0191
                    fcb       $00,$05
                    fdb       L019A
                    fcb       $00,$00
                    fdb       L01A3
                    fcb       $00,$12
                    fdb       L01A8
                    fcb       $00,$10
                    fdb       L01AE
                    fcb       $00,$00
                    fdb       L01AF
                    fdb       L01CF
                    fdb       L01D9
                    fdb       L01E3
                    fdb       L01E9
                    fdb       L01F4
                    fdb       L01FF
                    fdb       L0208
                    fdb       L0211
                    fdb       L021A
                    fdb       L0223
                    fdb       L022B
                    fdb       L0232
                    fdb       L0238
                    fdb       L0240
                    fdb       L024A
                    fdb       L0255
                    fdb       L025E
                    fcb       $27,$10,$03,$E8,$00,$64,$00,$0A
                    fcb       $6C,$78,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$01,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$02
                    fcb       $00,$01,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$46,$00,$02,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$01,$01,$01,$01,$01
                    fcb       $01,$01,$01,$01,$11,$11,$11,$11
                    fcb       $11,$01,$01,$01,$01,$01,$01,$01
                    fcb       $01,$01,$01,$01,$01,$01,$01,$01
                    fcb       $01,$01,$01,$30,$20,$20,$20,$20
                    fcb       $20,$20,$20,$20,$20,$20,$20,$20
                    fcb       $20,$20,$20,$48,$48,$48,$48,$48
                    fcb       $48,$48,$48,$48,$48,$20,$20,$20
                    fcb       $20,$20,$20,$20,$42,$42,$42,$42
                    fcb       $42,$42,$02,$02,$02,$02,$02,$02
                    fcb       $02,$02,$02,$02,$02,$02,$02,$02
                    fcb       $02,$02,$02,$02,$02,$02,$20,$20
                    fcb       $20,$20,$20,$20,$44,$44,$44,$44
                    fcb       $44,$44,$04,$04,$04,$04,$04,$04
                    fcb       $04,$04,$04,$04,$04,$04,$04,$04
                    fcb       $04,$04,$04,$04,$04,$04,$20,$20
                    fcb       $20,$20,$01,$00,$1A,$01,$72,$01
                    fcb       $6E,$01,$6A,$01,$66,$01,$62,$01
                    fcb       $88,$01,$86,$01,$84,$01,$82,$01
                    fcb       $7E,$01,$7A,$01,$76,$01,$96,$01
                    fcb       $94,$01,$92,$01,$90,$01,$8E,$01
                    fcb       $8C,$01,$8A,$01,$A4,$01,$A2,$01
                    fcb       $A0,$01,$9E,$01,$9C,$01,$9A,$01
                    fcb       $98,$00,$0C,$00,$12,$00,$10,$00
                    fcb       $0E,$00,$0C,$00,$0A,$00,$20,$00
                    fcb       $1E,$00,$1C,$00,$1A,$00,$18,$00
                    fcb       $16,$00,$14,$55,$4D,$75,$73,$45
                    fcb       $33
                    fcb       $00

* TailInit: also sets up the module directory (S9InitDir; F$Exit if that fails). The numbers of blocks 6
* and 7 of this module -> FranParam as two characters (block + $40: never a space, a quote or a CR, so
* the parameter scanner passes them through) and a CR. Runs from block 6 itself, before main's
* F$ClrBlk. On a failure the parameters are a bare CR and s9gui gets no tail blocks.
TailInit            pshs      y,u
                    ldu       #S9ModuleDir
                    lbsr      S9InitDir
                    bcc       tidir@
                    os9       F$Exit              fail before opening pipes or allocating graphics
tidir@              stx       >S9ModuleLeaf
                    leas      >-P$Size,s
                    lda       #C$CR
                    sta       >FranParam
                    os9       F$ID                A = this process
                    leax      ,s
                    os9       F$GPrDsc            its descriptor, DAT image included
                    bcs       ti9@
                    leau      >TailBlock6,pcr     where block 6 sits in the map
                    tfr       u,d
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra                          A = the slot (address / $2000)
                    lsla                          two bytes an entry
                    leax      P$DATImg,x
                    leax      a,x                 block 6's entry
                    lda       1,x                 its block number (the low byte: wildbits has 128 blocks)
                    ldb       3,x                 block 7 is in the next slot
                    adda      #$40
                    addb      #$40
                    std       >FranParam
                    lda       #C$CR
                    sta       >FranParam+2
ti9@                leas      >P$Size,s
                    puls      y,u,pc
                    use       module_dir.inc      startup-only code, before this tail is unmapped
                    fill      0,$C000-*           (an error here: block 6 of the tail is over-full)
TailBlock7          equ       *
                    includebin ../.mods/SYS/UmeSymbols16.img,$1B00
* tools/check/check_module_size.py checks the module ends below $DD00 and the payloads sit where s9gui expects.

                    emod
eom                 equ       *
                    end
