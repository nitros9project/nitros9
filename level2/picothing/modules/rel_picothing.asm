********************************************************************
* REL - Hardware init and OS-9 boot loader for Pico-Thing
*
* Raw binary chunk (not an OS-9 module).  Loaded by Pico
* firmware at Chunk ($0130).  This is the first 6809 code
* to run after the Pico releases RESET.
*
* DrvWire byte at Chunk+2 selects boot device:
*   0 = PATA IDE (default)
*   1 = DriveWire (auxiliary ACIA)
*
* Boot sequence:
*   1. Disable interrupts, set DP=0
*   2. Set up DAT task 0 (identity map, KrnBlk in slot 7)
*   3. Set up stack at STKADDR ($2000)
*   4. Clear direct page
*   5. Enable 6309 native mode (HD63C09) [if H6309]
*   6. Install D.BtBug (serial debug output via console ACIA)
*   7. Install D.Crash handler
*   8. Initialize IDE or DriveWire (per DrvWire flag)
*   9. Print boot message with device type
*  10. Load OS9Kernel from disk directly to Bt.Start
*  11. Compute BRA stub addresses from krn and write hardware vectors
*  12. Find Krn module and jump to entry point
*
* The kernel finds boot_picothing (merged into OS9Kernel)
* and uses it via F$Boot to load OS9Boot from disk.
*
* On entry there is no stack; step 3 sets one up at STKADDR.
*
* Shared between Level 1 and Level 2 builds.  Level is set
* by the defsfile (Level equ 1 or 2).  At Level 1, D.BtBug
* and D.Crash DP offsets are defined locally since they do
* not exist in the Level 1 system direct page.  The kernel
* overwrites these locations after boot so there is no conflict.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*     1    2025       Initial version for Pico-Thing
*     2    2026/03/14 Unified L1/L2 with conditional assembly

                  IFP1
                    use       defsfile
                    use       ide_picothing.d
                  ENDC

* Level 1 does not define D.BtBug or D.Crash in os9.d.
* Define them locally at the same offsets as Level 2.
* REL owns the direct page at boot time; the kernel will
* reclaim these bytes later.
                  IFEQ    Level-1
D.BtBug             equ       $5E       boot debug vector (3 bytes)
D.Crash             equ       $6B       crash handler vector (6 bytes)
                  ENDC

Chunk               equ       $0130     rel load address
                    org       Chunk

*------------------------------------------------------------
* Entry point
*
* Arrived here with no stack, interrupts unknown, DAT state
* unknown (Pico firmware may have set task 0 identity map).
*
start               bra       start2
DrvWire             fcb       0         0=ide, 1=drivewire (Chunk+2)
RELVer              fcb       0,0,3     rel version major.minor.patch (Chunk+3)
start2              orcc      #IntMasks disable all interrupts
                    clra
                    tfr       a,dp      set direct page to $0000

* Set up DAT task 0: identity map for slots 0-6, KrnBlk for slot 7
* Task register is at DAT.Task ($FFC0), DAT RAM at $FE00
* Task 0 occupies $FE00-$FE07 (8 slots)
                    ldx       #DAT.Regs a=0 from above, first page
maploop@            sta       ,x+       slot N = physical page N
                    inca
                    cmpa      #DAT.BlCt-1 done slots 0-6?
                    blo       maploop@
                    lda       #KrnBlk   kernel page ($07)
                    sta       ,x        slot 7 = kernel block
                    clr       >DAT.Task select task 0

* Set up stack at top of block 0 (pre-decrements)
                    lds       #STKADDR

* Clear direct page ($0000-$00FF)
                    clra
                    clrb
                    tfr       d,x
clrdp@              sta       ,x+
                    incb
                    bne       clrdp@

* Install D.BtBug: JMP to our PicoBtBug routine
* D.BtBug is 3 bytes: opcode + 16-bit address
                    lda       #OpJMP
                    sta       <D.BtBug
                    leax      <PicoBtBug,pcr point to debug output routine
                    stx       <D.BtBug+1 store target address

* Install D.Crash handler
* D.Crash is 6 bytes, copied from R.Crash below
                    leax      R.Crash,pcr source
                    ldy       #D.Crash  destination
                    ldb       #CrashHdl-R.Crash size of crash vector
cpcrash@            lda       ,x+
                    sta       ,y+
                    decb
                    bne       cpcrash@

* Enable 6309 native mode if building for 6309
                  IFNE    H6309
                    ldmd      #3        native mode, FIRQ saves all regs
                    inc       <D.MDREG  set mode shadow register
                  ENDC

* Initialize storage device
                    tst       DrvWire,pcr
                    bne       dwinit@
                    lbsr      IDEInit
                    bra       initdn@
dwinit@             lbsr      DWInit
initdn@

* Print boot message on serial console
                    leax      <BootMsg,pcr
                    lbsr      PHDATA
                    tst       DrvWire,pcr
                    bne       dwmsg@
                    leax      <MsgIDE,pcr
                    bra       bootmsg@
dwmsg@              leax      <MsgDW,pcr
bootmsg@            lbsr      PHDATA
                    lbsr      PCRLF

* Check if device init failed
                    bcs       InitErr

* Load OS-9 from disk and jump to kernel
* LOADO9 does not return on success (calls JMPKER).
* On error it returns here, print message and halt.
                    lbsr      LOADO9
                    leax      <BootFail,pcr
                    bra       BtHalt
InitErr             leax      <InitFail,pcr
BtHalt              lbsr      PHDATA
                    lbsr      PCRLF
BtHang              bra       BtHang    halt on failure

*------------------------------------------------------------
* PicoBtBug - Boot debug character output via ACIA
*
* Polls TDRE (bit 1 of status register) then writes the
* character in A to the ACIA data register.
* Preserves all registers including CC.
*
* Entry: A = character to output
* Exit:  all registers preserved
*
PicoBtBug           pshs      cc,b      save flags and B
btbusy@             ldb       >ACIA.Ctrl read ACIA status
                    bitb      #Stat.TxE tx register empty?
                    beq       btbusy@   no, wait
                    sta       >ACIA.Data send character
                    puls      cc,b,pc   restore and return

*------------------------------------------------------------
* Boot message
*
                  IFEQ    Level-1
BootMsg             fcs       "NitrOS9 L1 Boot "
                  ELSE
BootMsg             fcs       "NitrOS9 Boot "
                  ENDC
MsgIDE              fcs       "(IDE)"
MsgDW               fcs       "(DriveWire)"
BootFail            fcs       "Boot failed"
InitFail            fcs       "Device init failed"
CrashMsg            fcs       "Crash error $"

*------------------------------------------------------------
* D.Crash handler (6 bytes, copied to direct page at D.Crash)
*
* On crash, jump back to our crash display routine.
* Format: JMP >target  (3 bytes) + 3 bytes for D.CBStrt area
*
R.Crash             jmp       >CrashHdl
                    fcb       $00,$00,$00 D.CBStrt placeholder

*------------------------------------------------------------
* Crash display - print error indicator and loop
*
CrashHdl            pshs      b         save error code
                    leax      CrashMsg,pcr
                    lbsr      PHDATA
                    puls      a         error code into A
                    lbsr      OUT2HX
                    lbsr      PCRLF
hang@               bra       hang@     loop forever

*------------------------------------------------------------
* OS-9 Disk Boot Routines
*
* Adapted from:
*         "ST-MON"
*    (c) 1984,1985 by David C. Wiens,
*         All rights reserved
* Modified MarkM 2018-04-29 LWASM on *IX and MacOS
*          MarkM 2019-06-15 Add 'krn' search for NitrOS-9
*          MarkM 2026-03-09 Adapted for Pico-Thing REL
*
* DriveWire 3 protocol equates
*
OP_READEX           equ       'R+128    read sector with checksum
OP_REREADEX         equ       'r+128    re-read after crc error
E_CRC               equ       $F3       crc error code

* Boot buffer addresses
*
OpJMP               equ       $7E       6809 JMP extended opcode
Stat.TxE            equ       %00000010 acia tx data register empty
STKADDR             equ       $2000     initial stack (pre-decrements)
KERADDR             equ       Bt.Start  kernel loaded here (Level-dependent)
* SWIStack ("REGISTER STACK" + $55) sits between the krn module's emod and
* the 6 BRA vector stubs; we skip it to find the stubs. The HD6309 kernel
* widens that text by two bytes ("REGISTER STACK63"), so the stub offset
* must grow to match or the hardware vectors land two bytes short.
                  IFNE    H6309
SWIStkSz            equ       17        "REGISTER STACK63" + $55
                  ELSE
SWIStkSz            equ       15        "REGISTER STACK" + $55
                  ENDC
VCT.Ct              equ       6         number of BRA stubs (SWI3..NMI)
VCT.Sz              equ       3         bytes per stub (BRA + offset + NOP)
SECBUF              equ       $B000     256 byte sector buffer
SEGBUF              equ       $B100     segment list buffer (240 bytes)
SEG_ENT             equ       5         bytes per segment entry

*------------------------------------------------------------
* LOADO9 - load os9kernel from disk and jump to kernel
*
* reads lsn 0, finds os9kernel in root directory, loads
* it directly to KERADDR. os9kernel contains krn
* and boot_picothing merged together. the kernel uses
* boot_picothing via F$Boot to load os9boot from disk.
*
* entry: called from rel after hardware init
* exit:  no return if successful
*
LOADO9
* read lsn 0 and get pointers and format codes
                    clrb                lsn 23-16 = 0
                    ldx       #0        read lsn 0
                    ldy       #SECBUF
                    lbsr      READLS
                    lbcs      LExit
                    lbsr      PCRLF
                    leax      DForm,pcr "format: "
                    lbsr      PHDATA
                    lda       DD.FMT,y
                    lbsr      OUT2HX
                    lbsr      PCRLF
                    leax      DSPT,pcr  "sectors/track: "
                    lbsr      PHDATA
                    ldx       DD.SPT,y
                    lbsr      OUT4HX
                    lbsr      PCRLF
                    leax      DRoot,pcr "root dir: "
                    lbsr      PHDATA
                    ldx       DD.DIR+1,y
                    stx       RtDir,pcr
                    lbsr      OUT4HX
                    lbsr      PCRLF
* find and load os9kernel file
                    ldx       RtDir,pcr get root dir fd lsn
                    lbsr      FINDDT
                    lbcs      LExit
                    clrb                lsn 23-16 = 0
                    ldy       #SECBUF   read first dir sector
                    lbsr      READLS
                    lbcs      LExit
                    clr       FFSkip,pcr reset first-sector flag
                    leax      KerNam,pcr find os9kernel in directory
                    lbsr      FINDFL
                    bcc       gtkr1@
                    leax      O9KrErr,pcr "os9kernel file not found"
                    lbra      LError
gtkr1@              ldx       ModNam,pcr print file name and fd lsn
                    lbsr      PHDATA
                    lbsr      OUT1SP
                    ldx       ModLSN,pcr
                    lbsr      OUT4HX
                    lbsr      FINDDT    get segment list and size
                    lbcs      LExit
                    ldy       #KERADDR
                    lbsr      READCF    load os9kernel directly to KERADDR
                    lbcs      LExit
* verify that kernel module exists at KERADDR
                    leax      NKrn,pcr
                    ldy       #KERADDR
                    lbsr      FIND
                    lbcs      LExit
                  IFEQ    Level-1
* The Level 1 kernel keeps its secondary interrupt vectors in a
* $0100 (D.XSWI3) RAM jump table - the CoCo convention. Its cold-start
* copies VectCode there; on a CoCo the ROM points the 6809 hardware
* vectors at that table, but the Pico-Thing has no such ROM, so point
* $FFF2-$FFFC at the matching $0100 entries ourselves.
                    leax      L1Vects,pcr table of 6 vector addresses
                    ldy       #$FFF2    first hardware vector slot
l1vec@              ldd       ,x++      next $0100-table entry address
                    std       ,y++      write it to the hardware vector slot
                    cmpy      #$FFFE    stop before the reset vector at $FFFE
                    blo       l1vec@
                  ELSE
* set up hardware vectors from krn BRA stubs
* krn file layout after emod: [SWIStack 15 bytes] [6 x 3-byte BRA stubs]
* stubs: SWI3 SWI2 FIRQ IRQ SWI NMI (same order as $FFF2-$FFFC)
                    leax      ,y        use krn address returned by FIND
                    ldd       M$Size,x  get krn module size (through emod)
                    leax      d,x       point past emod
                    leax      SWIStkSz,x skip SWIStack
* x now points to first BRA stub (SWI3)
* write 6 vector addresses to $FFF2-$FFFD
                    ldy       #$FFF2
                    ldb       #VCT.Ct
veclp@              stx       ,y++      write stub address to vector slot
                    leax      VCT.Sz,x  advance to next stub
                    decb
                    bne       veclp@
                  ENDC
* jump to kernel (it will load os9boot via F$Boot)
                    lbsr      PCRLF
                    bra       JMPKER

                  IFEQ    Level-1
* Hardware-vector targets for Level 1, in $FFF2-$FFFC order
* (SWI3 SWI2 FIRQ IRQ SWI NMI), each pointing into the $0100 VectCode
* jump table (entry order SWI3 SWI2 SWI NMI IRQ FIRQ, 3 bytes apart).
L1Vects             fdb       D.XSWI3+0 SWI3 vector goes to $0100
                    fdb       D.XSWI3+3 SWI2 vector goes to $0103
                    fdb       D.XSWI3+15 FIRQ vector goes to $010F
                    fdb       D.XSWI3+12 IRQ vector goes to $010C
                    fdb       D.XSWI3+6 SWI vector goes to $0106
                    fdb       D.XSWI3+9 NMI vector goes to $0109
                  ENDC
* error return
LError              lbsr      PCRLF
                    lbsr      PHDATA
LExit               rts

*------------------------------------------------------------
* JMPKER - find kernel entry point and jump
*
* entry: kernel already loaded at KERADDR
* exit:  no return
*
JMPKER              clra
                    tfr       a,dp
                    ldy       #KERADDR
                    leax      NKrn,pcr
                    bsr       FIND
                    ldd       M$Exec,y  get module execution offset
                    jmp       d,y       jump to os-9 kernel

*------------------------------------------------------------
* FIND - find an os-9 module by name
*
* entry: x = address of module name (fcs format)
*        y = address to begin search
* exit:  y = address of module (if found)
*        cc cs = not found
*
FIND                cmpy      #DAT.Regs still in valid range?
                    bhs       fnotf@
                    ldd       ,y        check header sync bytes
                    cmpa      #M$ID1
                    bne       fnxt@
                    cmpb      #M$ID2
                    bne       fnxt@
                    ldb       #M$IDSize check header parity
                    pshs      y
                    clra
fpar@               eora      ,y+
                    decb
                    bne       fpar@
                    puls      y
                    cmpa      #$FF
                    bne       fnxt@
                    pshs      x,y       compare name strings
                    ldd       M$Name,y
                    leay      d,y
fcmp@               lda       ,x+
                    anda      #$5F      strip fcs high bit and fold case
                    pshs      a
                    lda       ,y+
                    anda      #$5F
                    cmpa      ,s+
                    bne       fno@
                    tst       -1,x      last char? (hi bit set)
                    bpl       fcmp@
                    puls      x,y       match found
                    bra       ffnd@
fno@                puls      x,y
fnxt@               leay      1,y       try next location
                    bra       FIND
fnotf@              comb                not found
                    bra       fret@
ffnd@               clrb                found
fret@               rts

*------------------------------------------------------------
* FINDDT - read file descriptor and extract segment list
*
* reads the fd sector, copies the segment list to segbuf,
* and returns the file size and first segment lsn.
*
* entry: x = lsn of fd sector
* exit:  x = first segment lsn (low 16 bits)
*        u = file size in bytes (low 16 bits)
*        segment list copied to segbuf
*        cc cs on error
*
FINDDT              pshs      a,b,y
                    clrb                lsn 23-16 = 0
                    ldy       #SECBUF
                    lbsr      READLS
                    lbcs      fdt_done@
* extract file size
                    ldu       FD.SIZ+2,y low 16 bits of file size
* debug: print file size
                    pshs      x,u
                    leax      DSiz,pcr
                    lbsr      PHDATA
                    tfr       u,x
                    lbsr      OUT4HX
* copy segment list from secbuf to segbuf
                    leax      FD.SEG,y  source in secbuf
                    ldy       #SEGBUF   destination
                    ldb       #(256-FD.SEG) copy all segment data
cpyseg@             lda       ,x+
                    sta       ,y+
                    decb
                    bne       cpyseg@
* debug: print segment entries
                    ldx       #SEGBUF
                    clrb                segment counter
prtseg@             lda       ,x        check for end of list
                    ora       1,x
                    ora       2,x
                    ora       3,x
                    ora       4,x
                    beq       prtdn@    all zeros = end
                    incb
                    pshs      b,x
                    leax      DSeg,pcr  " seg "
                    lbsr      PHDATA
                    puls      b,x
                    pshs      b,x
                    lda       ,x        high byte of lsn
                    lbsr      OUT2HX
                    ldx       1,x       low 16 bits of lsn
                    lbsr      OUT4HX
                    lbsr      OUT1SP
                    puls      b,x
                    pshs      b,x
                    ldx       3,x       sector count
                    lbsr      OUT4HX
                    puls      b,x
                    leax      SEG_ENT,x advance to next entry
                    bra       prtseg@
prtdn@              lbsr      PCRLF
                    puls      x,u
* return first segment lsn (low 16 bits)
                    ldx       SEGBUF+1  low 16 bits of first lsn
                    clrb                success
fdt_done@           puls      a,b,y,pc

*------------------------------------------------------------
* FINDFL - find file name in directory
*
* searches all directory sectors using the segment list
* in segbuf (populated by a prior finddt call on the
* directory's fd). skips . and .. in first sector.
*
* entry: x = address of name string (fcs format)
*        y = address of directory sector buffer (first
*            sector already loaded)
* exit:  x = lsn of file fd sector
*        cc cs = not found
*
FINDFL              pshs      a,b,x,y,u
                    stx       FFName,pcr save name pointer
* first sector: skip . and .. entries, 6 remaining
                    leay      DIR.SZ*2,y skip . and ..
                    lda       #(256/DIR.SZ)-2
                    bsr       ffl_scan@
                    bcc       ffl_done@ found
* walk remaining directory sectors via segment list
                    ldu       #SEGBUF
ffl_seg@            lda       ,u        check for end of list
                    ora       1,u
                    ora       2,u
                    ora       3,u
                    ora       4,u
                    beq       ffl_nf@   end of segment list
* extract segment lsn and count
                    ldb       ,u        lsn 23-16
                    ldx       1,u       lsn 15-0
                    ldy       3,u       sector count
                    leau      SEG_ENT,u advance segment pointer
* skip first sector of first segment (already searched)
                    tst       FFSkip,pcr
                    bne       ffl_rd@
                    inc       FFSkip,pcr mark first sector skipped
                    leax      1,x       advance to second sector
                    bne       ffl_ns@
                    incb                carry into high byte
ffl_ns@             leay      -1,y      one fewer sector
                    beq       ffl_seg@  segment exhausted, next
ffl_rd@             pshs      b,x,y,u   save lsn and segment state
                    ldy       #SECBUF
                    lbsr      READLS
                    puls      b,x,y,u
                    bcs       ffl_nf@   read error, give up
* search all 8 entries in this sector
                    pshs      b,x,y,u
                    ldy       #SECBUF
                    lda       #(256/DIR.SZ)
                    bsr       ffl_scan@
                    puls      b,x,y,u
                    bcc       ffl_done@ found
* advance to next sector in segment
                    leax      1,x
                    bne       ffl_ns2@
                    incb                carry into high byte
ffl_ns2@            leay      -1,y
                    bne       ffl_rd@   more sectors in segment
                    bra       ffl_seg@  next segment
ffl_nf@             comb                not found
                    bra       ffl_exit@
ffl_done@           clrb                found (ModNam/ModLSN set)
ffl_exit@           puls      a,b,x,y,u,pc
*
* ffl_scan@ - scan A directory entries starting at Y
*
* entry: a = number of entries to check
*        y = pointer to first entry
*        FFName,pcr = name to find (fcs)
* exit:  cc cs = not found, cc cc = found
*        ModNam, ModLSN set on match
*
ffl_scan@           pshs      a,x,y
ffl_s1@             ldx       FFName,pcr reload name pointer
                    pshs      x,y
                    sty       ModNam,pcr stash dir entry pointer
ffl_s2@             lda       ,x+
                    anda      #$5F      strip fcs high bit and fold case
                    pshs      a
                    lda       ,y+
                    anda      #$5F
                    cmpa      ,s+
                    bne       ffl_s3@   no match
                    tst       -1,x      last char? (hi bit set)
                    bpl       ffl_s2@   no, next char
                    puls      x,y       match found
                    ldx       DIR.FD+1,y get fd lsn (low 16 bits)
                    stx       ModLSN,pcr
                    clra                clear carry
                    puls      a,x,y,pc
ffl_s3@             puls      x,y
                    leay      DIR.SZ,y  next directory entry
                    deca
                    bne       ffl_s1@
                    coma                not found
                    puls      a,x,y,pc
*
* findfl working variables
FFName              fdb       0         name string pointer
FFSkip              fcb       0         first-sector-skipped flag

*------------------------------------------------------------
* READCF - read file from disk using segment list
*
* walks the segment list in segbuf, reading each segment's
* consecutive sectors into the destination buffer.
* handles fragmented (non-contiguous) files.
*
* entry: u = file size in bytes
*        y = destination buffer address
*        segment list in segbuf (populated by finddt)
* exit:  all registers preserved on success
*        cc cs on error
*
READCF              pshs      a,b,x,y,u
                    sty       RCDest,pcr save destination pointer
                    ldx       #SEGBUF
                    stx       SegPtr,pcr init segment list pointer
* process next segment
nextseg@            ldx       SegPtr,pcr get current segment pointer
* check for end of segment list (5 zero bytes)
                    lda       ,x
                    ora       1,x
                    ora       2,x
                    ora       3,x
                    ora       4,x
                    lbeq      rcdone@   end of list
* check if file is fully read
                    cmpu      #0
                    lbeq      rcdone@
* extract 3-byte lsn and 2-byte sector count
                    lda       ,x
                    sta       CurLSN,pcr high byte of lsn
                    ldd       1,x
                    std       CurLSN+1,pcr low 16 bits of lsn
                    ldd       3,x
                    std       SegCnt,pcr sector count
* advance segment pointer past this entry
                    leax      SEG_ENT,x
                    stx       SegPtr,pcr
* debug: print segment being read
                    pshs      u
                    leax      DRdSg,pcr "rd "
                    lbsr      PHDATA
                    lda       CurLSN,pcr
                    lbsr      OUT2HX
                    ldx       CurLSN+1,pcr
                    lbsr      OUT4HX
                    lbsr      OUT1SP
                    ldx       SegCnt,pcr
                    lbsr      OUT4HX
                    lbsr      OUT1SP
                    puls      u
* read sectors in this segment
rdsec@              ldb       CurLSN,pcr lsn 23-16
                    ldy       #SECBUF   read one sector
                    ldx       CurLSN+1,pcr low 16 bits of lsn
                    lbsr      READLS
                    lbcs      rcerr@
* copy sector data to destination buffer
                    ldy       #SECBUF
                    ldx       RCDest,pcr
                    clrb                256 bytes per sector
cpbyte@             lda       ,y+
                    sta       ,x+
                    leau      -1,u      decrement remaining file size
                    cmpu      #0        file done?
                    beq       cpdn@
                    decb                sector done?
                    bne       cpbyte@
cpdn@               stx       RCDest,pcr update destination pointer
* progress dot
                    lda       #'.
                    jsr       <D.BtBug
* check if file fully read
                    cmpu      #0
                    beq       rcdone@
* increment lsn
                    ldx       CurLSN+1,pcr
                    leax      1,x
                    stx       CurLSN+1,pcr
                    bne       noc@
                    inc       CurLSN,pcr carry into high byte
* decrement segment sector count
noc@                ldx       SegCnt,pcr
                    leax      -1,x
                    stx       SegCnt,pcr
                    bne       rdsec@    more sectors in this segment
                    lbra      nextseg@  next segment
* error exit - carry is set from readls
rcerr@              puls      a,b,x,y,u,pc
* success
rcdone@             clrb                clear carry
                    puls      a,b,x,y,u,pc

*------------------------------------------------------------
* READLS - read logical sector from disk
*
* dispatches to drivewire or ide sector read.
*
* entry: b = lsn bits 23-16
*        x = lsn bits 15-0
*        y = sector buffer address
* exit:  y preserved, cc cs on error
*
READLS              tst       DrvWire,pcr drivewire?
                    lbne      DWSecRd   yes, read via drivewire
                    lbra      IDERead   read via pata ide

*------------------------------------------------------------
* DWInit - initialize auxiliary acia for drivewire
*
                    use       dwinit/dwinit_picothing.asm

*------------------------------------------------------------
* DWSecRd - read one sector via drivewire (OP_READEX)
*
* sends 5-byte command (opcode, drive, 3-byte lsn),
* receives 256 bytes, exchanges checksum, retries on
* crc error with OP_REREADEX.
*
* entry: b = lsn bits 23-16
*        x = lsn bits 15-0
*        y = sector buffer address
* exit:  y preserved, cc cs on error, cc cc on success
*
DWSecRd             pshs      b,x,y     save 24-bit lsn and buffer
* stack: [lsn23-16:0] [lsn15-8:1] [lsn7-0:2] [buf_hi:3] [buf_lo:4]
                    lda       #OP_READEX
dw_r2@              ldb       ,s        lsn[23:16]
                    ldx       1,s       lsn[15:0]
                    pshs      x         push lsn[15:0]
                    pshs      b         push lsn[23:16]
                    clrb                drive 0
                    pshs      d         push opcode + drive
* stack: [op:0] [drv:1] [lsn23-16:2] [lsn15-8:3] [lsn7-0:4] [saved:5-9]
                    leax      ,s
                    ldy       #5
                    lbsr      DWWrite   send 5-byte command
                    leas      5,s       clean command
* stack: [lsn23-16:0] [lsn15-8:1] [lsn7-0:2] [buf_hi:3] [buf_lo:4]
* receive 256 bytes of sector data
                    ldx       3,s       sector buffer (saved y)
                    ldy       #256
                    lbsr      DWRead    read sector from server
                    bcs       dw_err@   framing error
                    bne       dw_err@   timeout
* send 2-byte checksum returned by dwread in y
                    pshs      y         push checksum
                    leax      ,s
                    ldy       #2
                    lbsr      DWWrite   send checksum to server
* receive 1-byte error code
                    leax      ,s        reuse checksum area for response
                    ldy       #1
                    lbsr      DWRead    read error code
                    bcs       dw_ack@   framing error, accept data
                    bne       dw_ce@    timeout on error code
                    lda       ,s        get error code byte
                    leas      2,s       clean checksum area
* stack: [lsn23-16:0] [lsn15-8:1] [lsn7-0:2] [buf_hi:3] [buf_lo:4]
                    tsta
                    beq       dw_ok@    0 = success
                    cmpa      #E_CRC
                    bne       dw_err@   non-crc error
* crc error, retry with reread
                    lda       #OP_REREADEX
                    bra       dw_r2@
dw_ack@             leas      2,s       clean checksum area
dw_ok@              puls      b,x,y     restore registers
                    clrb                clear carry, success
                    rts
dw_ce@              leas      2,s       clean checksum area
dw_err@             puls      b,x,y     restore registers
                    comb                set carry, error
                    rts

*------------------------------------------------------------
* DWRead / DWWrite - drivewire byte transport via auxiliary acia
*
                    use       dwread/dwread_picothing.asm
                    use       dwwrite/dwwrite_picothing.asm

*------------------------------------------------------------
* IDEInit - initialize pata ide device
*
* selects master device, waits for bsy clear, sends identify
* device command, determines lba capability, discards geometry.
*
* exit: carry clear = ok, carry set = error
*
IDEInit             ldy       #PTIDEBase
                    lda       #%00000010 nIEN: disable ide interrupts
                    sta       AltStatus,y
                    lda       #%10100000 master, dev=0
                    sta       IDEMode,pcr save device select byte
                    clr       DevHead,y select master
* wait for bsy clear with timeout
                    ldx       #0        65536 polls
idi_bsy@            tst       Status,y  bsy clear?
                    bpl       idi_rdy@  yes
                    leax      -1,x
                    bne       idi_bsy@
                    bra       idi_fail@ timeout
idi_rdy@            lda       #S$IDENTIFY
                    sta       Command,y
* wait for bsy clear and drq with timeout
                    ldx       #0        65536 polls
idi_id@             lda       Status,y
                    bmi       idi_nxt@  bsy still set
                    anda      #DrqBit   drq set?
                    bne       idi_drq@  yes, data ready
idi_nxt@            leax      -1,x
                    bne       idi_id@
idi_fail@           comb                set carry, error
                    rts
* drq ready, read identify data
idi_drq@            ldx       #49       discard words 0-48
idi_sk1@            ldd       DataReg,y discard
                    leax      -1,x
                    bne       idi_sk1@
* word 49: lba support flag in bit 9 (bit 1 of high byte)
                    ldd       DataReg,y word 49
                    anda      #%00000010 lba supported?
                    beq       idi_nolba@
                    lda       IDEMode,pcr
                    ora       #%01000000 set lba flag
                    sta       IDEMode,pcr
idi_nolba@          ldx       #206      discard words 50-255
idi_sk2@            ldd       DataReg,y discard
                    leax      -1,x
                    bne       idi_sk2@
                    clrb                success
                    rts

*------------------------------------------------------------
* IDERead - read one 256-byte sector from pata ide
*
* physical sectors are 512 bytes. divides lsn by 2 to get
* physical sector, reads both halves, keeps only the one
* requested.
*
* entry: b = lsn bits 23-16
*        x = lsn bits 15-0
*        y = 256-byte sector buffer address
* exit:  carry clear = ok, carry set = error
*        y preserved (buffer pointer)
*
IDERead             pshs      y         save buffer pointer
                    pshs      x,b       push 24-bit lsn
* stack: [lsn23-16:0] [lsn15-8:1] [lsn7-0:2] [buf_hi:3] [buf_lo:4]
* compute half selector (bit 0 of lsn)
                    lda       2,s       lsn bits 7-0
                    anda      #$01      half = 0 or 1
                    pshs      a         save half
* stack: [half:0] [lsn23-16:1] [lsn15-8:2] [lsn7-0:3] [buf_hi:4] [buf_lo:5]
* shift 24-bit lsn right by 1 to get physical sector number
                    lsr       1,s       shift bits 23-16
                    ror       2,s       rotate into bits 15-8
                    ror       3,s       rotate into bits 7-0
                    ldy       #PTIDEBase
* wait for bsy clear and drdy
idr_bsy@            tst       Status,y
                    bmi       idr_bsy@
                    lda       IDEMode,pcr
                    sta       DevHead,y
idr_rdy@            ldb       Status,y
                    andb      #BusyBit+DrdyBit
                    cmpb      #DrdyBit
                    bne       idr_rdy@
                    ldb       #$01
                    stb       SectCnt,y one physical sector
* lba addressing from psn on stack
                    lda       1,s       psn 23-16
                    sta       CylHigh,y
                    lda       2,s       psn 15-8
                    sta       CylLow,y
                    lda       3,s       psn 7-0
                    sta       SectNum,y
                    lda       #S$READ
                    sta       Command,y
                    ldx       #0        timeout counter
idr_drq@            lda       Status,y
                    bita      #ErrBit   check for error
                    bne       idr_err@
                    bita      #DrqBit
                    bne       idr_ok@
                    leax      -1,x
                    bne       idr_drq@
                    bra       idr_err@  timeout
idr_ok@
* read 512-byte physical sector, keep wanted half
                    tst       ,s        which half?
                    bne       idr_h1@
* half=0: first 256 bytes -> buffer, discard second 256
                    ldx       4,s       sector buffer (saved y)
                    bsr       Rd256
                    bsr       Skip256
                    bra       idr_done@
* half=1: discard first 256, second -> buffer
idr_h1@             bsr       Skip256
                    ldx       4,s       sector buffer (saved y)
                    bsr       Rd256
idr_done@           lda       Status,y  read final status
                    leas      4,s       clean [half][psn]
                    puls      y         restore buffer pointer
                    clrb                clear carry
                    rts
idr_err@            lda       Status,y  read final status
                    leas      4,s       clean [half][psn]
                    puls      y         restore buffer pointer
                    comb                set carry (error)
                    rts

* Rd256 - read 256 bytes (128 words) from DataReg into X
Rd256               ldb       #128
                    pshs      b
rd256@              ldd       DataReg,y
                    std       ,x++
                    dec       ,s
                    bne       rd256@
                    leas      1,s
                    rts

* Skip256 - read and discard 256 bytes (128 words) from DataReg
Skip256             ldb       #128
                    pshs      b
skip@               ldd       DataReg,y
                    dec       ,s
                    bne       skip@
                    leas      1,s
                    rts

*------------------------------------------------------------
* Serial output routines
*
* adapted from st-mon for pico-thing. uses D.BtBug
* (acia polling output) instead of st-2900 duart.
*

* PHDATA - output fcs string (hi bit set on last char)
*
* entry: x = pointer to fcs string
* exit:  all registers preserved
*
PHDATA              pshs      a,cc,x
ph01@               lda       ,x+
                    pshs      a
                    anda      #$7F      strip hi bit for output
                    jsr       <D.BtBug
                    puls      a
                    tsta                hi bit set? (last char)
                    bpl       ph01@
                    puls      a,cc,x,pc

* PCRLF - output carriage return and line feed
*
* exit:  all registers preserved
*
PCRLF               pshs      a
                    lda       #C$CR
                    jsr       <D.BtBug
                    lda       #C$LF
                    jsr       <D.BtBug
                    puls      a,pc

* OUT4HX - output 4 hex digits
*
* entry: x = 16-bit value
* exit:  a undefined, all others preserved
*
OUT4HX              pshs      a
                    pshs      x
                    puls      a         high byte
                    bsr       OUT2HX
                    puls      a         low byte
                    bsr       OUT2HX
                    puls      a,pc

* OUT2HX - output 2 hex digits
*
* entry: a = 8-bit value
* exit:  all registers preserved
*
OUT2HX              pshs      a
                    lsra
                    lsra
                    lsra
                    lsra
                    bsr       OUT1HX
                    puls      a
                    bra       OUT1HX

* OUT1HX - output 1 hex digit
*
* entry: a = value (lower 4 bits)
* exit:  all registers preserved
*
OUT1HX              pshs      a,cc
                    anda      #$0F
                    adda      #'0
                    cmpa      #'9
                    ble       oh01@
                    adda      #$07      adjust for a-f
oh01@               jsr       <D.BtBug
                    puls      a,cc,pc

* OUT1SP - output one space
*
* exit:  all registers preserved
*
OUT1SP              pshs      a
                    lda       #C$SPAC
                    jsr       <D.BtBug
                    puls      a,pc

*------------------------------------------------------------
* Status/error message strings
*
DForm               fcs       "Format: "
DSPT                fcs       "Sectors/Track: "
DRoot               fcs       "Root dir: "
O9KrErr             fcs       "OS9Kernel file not found"
DSiz                fcs       " sz="
DSeg                fcs       " sg:"
DRdSg               fcs       "rd "

*------------------------------------------------------------
* Module name strings (fcs format, hi bit set on last char)
*
KerNam              fcs       /OS9Kernel/
NKrn                fcs       /Krn/

*------------------------------------------------------------
* Disk boot variables (pcr-relative)
*
RtDir               fdb       0         lsn of root directory
ModNam              fdb       0         pointer to file name
ModLSN              fdb       0         lsn of file fd
IDEMode             fcb       0         ide device select byte (lba flag)
* readcf working variables
SegPtr              fdb       0         current position in segbuf
CurLSN              fcb       0,0,0     current 3-byte lsn being read
SegCnt              fdb       0         remaining sectors in segment
RCDest              fdb       0         destination buffer pointer

                    end       Chunk
