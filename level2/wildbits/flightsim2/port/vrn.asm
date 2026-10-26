********************************************************************
* VRN - VIRQ/RAM/Nil device driver, the WildBits build (the frame timer behind FS's /FTDD)
*
* Copyright (C) 1989, 1990 Bruce Isted
*
* This program may be freely distributed as long as the copyright notice
* remains intact and the source, binary, and documentation files are
* distributed together.
*
* This program may not be sold for profit, individually or as part of a
* package without the prior written permission of the copyright holder.
*
* The WildBits Level 2 code of NitrOS-9's level1/modules/vrn.asm (Bruce Isted 2003; Alan Dekok's get/setstat
* names and the new signal names, LCB 2020) with its Level 1 branches taken out: assembled with the WildBits
* defs it was byte for byte the boot file's VRN (506 bytes, CRC $CD2A98, on the K2 and the Jr2 alike) until the
* speech feeder (edition 2, 2026-10-20: writes, SS.SpBy, Feed; edition 3 the silence guard, 4 whole frames, 2026-10-21).
*
* What it does: on the clock's virtual interrupt (F$VIRQ, every tick) it counts and, for each process that
* asked, counts a timer down and sends that process a signal when it reaches zero. Flight Simulator II opens
* /FTDD (ftdd.asm: this driver under SCF) and uses SS.FClr/SS.FSet to get a signal every few ticks (its frame
* pacing) and SS.VCtr to read how many ticks went by; King's Quest III's VIRQ and the RAM block calls are the
* other customers this driver was written for.

                    nam       VRN
                    ttl       VIRQ/RAM/Nil device driver

                    ifp1
                    use       defsfile
                    endc

* Constants: the values this module's instructions use, by name (fs_wb.d holds the addresses)
IrqRemove           equ       $0000               F$IRQ's X: 0, the polling table entry removed
RTCountSize         equ       RTCount*256+RTSize  A: the RAM tables (RTCount), B: a RAM table's bytes (RTSize)
SleepOneTick        equ       1                   F$Sleep's X: one tick
SpFrameLen          equ       15                  an SP0250 LPC frame's bytes (about 20 ms of speech; Feed's most a tick)
SpIdMask            equ       $FE                 the SP0250 status but Ready (bit 0): bit 7 set, bits 6-1 clear when the chip is there
SpLiveOn            equ       1                   SpLive 1: speech fed since the last silent frame (a silent frame owed)
SpNoBytes           equ       0                   the bytes waiting in the ring buffer: none
SpPresent           equ       $80                 the SP0250 status with Ready masked off when the chip is there: bit 7 set, bits 6-1 clear
SpReady             equ       $01                 the SP0250 status's Ready bit: room in its FIFO
SpStep              equ       1                   a ring buffer offset's step: the next byte
SpTwoFrames         equ       30                  two frames' bytes: the current frame's rest (less SpPos) and a whole silent frame
TermWaitTicks       equ       600                 VTerm's longest wait for the speech to end: 600 ticks (10 s)
VirqInstall         equ       $0001               F$VIRQ's X: not 0, the VIRQ installed
VirqRemove          equ       $0000               F$VIRQ's X: 0, the VIRQ removed
VirqRepeat          equ       $80                 Vi.Stat: bit 7 set, the VIRQ repeats (its count reloaded from Vi.Rst), Vi.IFlag clear
VirqTicks           equ       $0001               the VIRQ's count and reset count: every tick
VTCountSize         equ       VTCount*256+VTSize  A: the VIRQ tables (VTCount), B: a VIRQ table's bytes (VTSize)

VTCount             equ       4                   VIRQ tables (and so how many FS2 / KQ3 users at a time)

* the speech feeder (WildBits, 2026-10-20): bytes written to the path are GI SP0250 LPC frames (15 bytes each, about
* 20 ms of speech), kept in a ring buffer and fed to the K2 rc26 core's chip at $FF9F on every tick (16.7 ms):
* while it reads Ready (room in its one-frame FIFO), up to a frame a tick. The chip is looked for once, at Init
* (bit 7 set, bits 6-1 clear, as diag's test); without it (the Jr2, older cores) the written bytes are dropped.
SpReg               equ       $FF9F               write: a frame byte; read: bit 7 present, bit 0 Ready
SpSize              equ       2048                the ring buffer, about 2.7 s of speech
SpMask              equ       (SpSize/256)-1      an offset's high byte wrapped
SpPoll              equ       16                  Ready polls per byte before the chip counts as full
SS.SpBy             equ       $82                 GetStat: the bytes still to speak, to the caller's X

* a VIRQ table (14 bytes): one FS2 entry and one KQ3 entry
                    org       0
FS2.ID              rmb       1                   FS2 (or FS2+) user: its process ID (0: free)
FS2.Pth             rmb       1                   its path number
FS2.Sgl             rmb       1                   the signal code it gets
FS2.Tmr             rmb       2                   ticks left until the next signal
FS2.Rst             rmb       2                   ticks between signals (0: one signal, then the entry frees)
FS2.STot            rmb       1                   signals sent since SS.VSig last read them
FS2.VTot            rmb       4                   ticks counted since SS.VCtr last read them (32 bits)
KQ3.ID              rmb       1                   KQ3 user: its process ID (0: free)
KQ3.Pth             rmb       1                   its path number
VTSize              equ       .                   a VIRQ table's size

* a RAM table (5 bytes): RAM blocks a process+path took through SS.ARAM
                    org       0
RAM.ID              rmb       1                   its process ID (0: free)
RAM.Pth             rmb       1                   its path number
RAM.Bks             rmb       1                   how many blocks
RAM.StB             rmb       2                   the first block's number
RTSize              equ       .                   a RAM table's size

* every table starts with the owner's process ID and path
                    org       0
All.ID              rmb       1                   the process ID
All.Pth             rmb       1                   the path number

* the device's static memory (one page)
                    org       V.SCF
VIRQPckt            rmb       5                   the VIRQ packet: counter (2), reset count (2), status (1)
PathNmbr            rmb       1                   the calling path's number
ProcNmbr            rmb       1                   the calling process's ID
SpBuf               rmb       2                   the speech ring buffer (system memory; 0: no SP0250, writes dropped)
SpHead              rmb       2                   the offset the next written byte goes to
SpTail              rmb       2                   the offset of the next byte for the chip
SpPos               rmb       1                   the bytes of the current frame the chip has (0-14)
SpLive              rmb       1                   1: speech fed since the last silent frame
SpSil               rmb       1                   silent-frame bytes still to send (Feed's guard)
VIRQTbls            rmb       VTCount*VTSize      the VIRQ tables
RTCount             equ       ($0100-.)/RTSize    RAM tables: as many as fit in the rest of the page
RAMTbls             rmb       RTCount*RTSize      the RAM tables
VMem                equ       .

rev                 set       $00
edition             set       4

                    mod       VEnd,VName,Drivr+Objct,ReEnt+rev,VEntry,VMem

                    fcb       UPDAT.              access modes: read and write

VName               fcs       "VRN"
                    fcb       edition

* the driver's entry table
VEntry              lbra      VInit               Init
                    lbra      VRead               Read
                    lbra      VWrit               Write
                    lbra      VGStt               GetStat
                    lbra      VSStt               SetStat
                    lbra      VTerm               Term

IRQPckt             fcb       $00,$01,$0A         F$IRQ packet: flip byte, mask, priority

* VInit: the fake VIRQ status register set up and polled through F$IRQ, then the VIRQ itself installed, every
* tick (the device memory but V.PAGE and V.PORT arrives cleared)
VInit               leax      VIRQPckt+Vi.Stat,u  X = the fake VIRQ status register
                    lda       #VirqRepeat         its flag clear, the VIRQ repeating
                    sta       ,x                  set
                    tfr       x,d                 D = its address, F$IRQ's "port"
                    leax      IRQPckt,pc          X = the polling packet
                    leay      IRQSvc,pc           Y = the service routine
                    os9       F$IRQ               onto the IRQ polling table
                    bcs       InitExit            refused: report it
                    ldd       #VirqTicks          every tick
                    std       VIRQPckt+Vi.Rst,u   the VIRQ's reset count
                    ldx       #VirqInstall        F$VIRQ: install
                    leay      VIRQPckt,u          Y = the VIRQ packet
                    os9       F$VIRQ              onto the clock's VIRQ list
                    bcc       SpInit              done: the speech buffer next
                    pshs      cc,b                refused: the error kept,
                    bsr       DumpIRQ             the IRQ entry taken back off,
                    puls      cc,b,pc             and the error returned

* SpInit: with an SP0250 at SpReg, the speech ring buffer taken from system memory (none: speech off, no error)
SpInit              lda       >SpReg
                    anda      #SpIdMask           all but Ready
                    cmpa      #SpPresent          present, bits 6-1 clear?
                    bne       SpNone              no chip
                    pshs      u
                    ldd       #SpSize
                    os9       F$SRqMem            U = the buffer
                    tfr       u,x
                    puls      u
                    bcs       SpNone              no memory: speech off
                    stx       SpBuf,u
SpNone              clrb
                    rts

* VRead: nothing to read, ever: end of file
VRead               comb                          carry set
                    ldb       #E$EOF              end of file
InitExit            rts

* VTerm: the speech still in the buffer spoken first (a tick's sleep at a time, 10 s at most: the device detaches
* when its last path closes, as after "copy phrase /ftdd"), then the VIRQ and the IRQ entry taken off and the
* speech buffer returned
VTerm               ldx       SpBuf,u
                    beq       VTerm1              no speech
                    ldy       #TermWaitTicks
VTerm0              ldd       SpHead,u
                    cmpd      SpTail,u            all fed, and the closing silent frame sent?
                    bne       VTerm2
                    lda       SpLive,u
                    ora       SpSil,u
                    beq       VTerm1
VTerm2              ldx       #SleepOneTick
                    os9       F$Sleep             a tick
                    leay      -1,y
                    bne       VTerm0
VTerm1              ldx       #VirqRemove         F$VIRQ: remove
                    leay      VIRQPckt,u          Y = the VIRQ packet
                    os9       F$VIRQ              off the clock's VIRQ list
                    bcs       Term.Err            refused: report it
                    bsr       DumpIRQ             the IRQ entry off
                    bcs       Term.Err
                    ldd       SpBuf,u             a speech buffer?
                    beq       Term.Err            none (carry clear)
                    pshs      u
                    tfr       d,u                 U = the buffer
                    ldd       #SpSize
                    os9       F$SRtMem            returned
                    puls      u,pc
DumpIRQ             leax      VIRQPckt+Vi.Stat,u  X = the fake VIRQ status register
                    tfr       x,d                 D = its address
                    ldx       #IrqRemove          F$IRQ: remove
                    leay      IRQSvc,pc           Y = the service routine
                    os9       F$IRQ               off the IRQ polling table
Term.Err            rts

* VGStt: A = the call. SS.Ready ($01): never ready; SS.VCtr ($80): the ticks counted, X:Y, and the count
* cleared; SS.VSig ($81): the signals sent, A, and that count cleared; SS.SpBy ($82): the speech bytes still to
* speak, X; anything else: unknown service
VGStt               bsr       GetInfo             the path, the process, the caller's registers
                    cmpa      #SS.Ready           SS.Ready?
                    bne       Chk.GS80            no: on
                    comb                          yes: never ready
                    ldb       #E$NotRdy           not ready
                    rts

UnitErr             ldb       #E$Unit             no table of this process+path: illegal unit
                    rts

* GetInfo: Y = the path descriptor: PathNmbr, ProcNmbr; Y = the caller's register stack. A and U kept.
GetInfo             ldb       PD.PD,y             the path number
                    stb       PathNmbr,u          kept
                    ldb       PD.CPR,y            the calling process (V.BUSY cannot be trusted here)
                    stb       ProcNmbr,u          kept
                    ldy       PD.RGS,y            Y = the caller's register stack
                    rts

* SS.VCtr: the 32-bit tick count to the caller's X:Y, then cleared
Chk.GS80            cmpa      #SS.VCtr            SS.VCtr ($80)?
                    bne       Chk.GS81            no: on
                    lbsr      FPTFS2              this process+path's FS2 table
                    bcs       UnitErr             none: illegal unit
                    ldd       FS2.VTot,x          the count's high word
                    std       R$X,y               to the caller's X
                    ldd       FS2.VTot+2,x        its low word
                    std       R$Y,y               to the caller's Y
ClrVTot             clra                          D = 0, carry clear
                    clrb
                    std       FS2.VTot,x          the count cleared
                    std       FS2.VTot+2,x
                    rts

* SS.VSig: the signals sent to the caller's A, then cleared
Chk.GS81            cmpa      #SS.VSig            SS.VSig ($81)?
                    bne       Chk.GS82            no: on
                    bsr       FPTFS2              this process+path's FS2 table
                    bcs       UnitErr             none: illegal unit
                    lda       FS2.STot,x          the signals sent
                    sta       R$A,y               to the caller's A
                    clr       FS2.STot,x          cleared
                    rts

* SS.SpBy: the speech bytes still in the buffer (head - tail, wrapped) to the caller's X; 0 when the phrase is
* out (the chip still sounds its last frame or two)
Chk.GS82            cmpa      #SS.SpBy            SS.SpBy ($82)?
                    lbne      USvcErr             no: unknown service
                    ldd       SpHead,u
                    subd      SpTail,u
                    anda      #SpMask
                    std       R$X,y
                    clrb
                    rts

* VSStt: A = the call. SS.SpBy ($82): the speech buffer emptied; SS.Close ($2A): every table of this process+path freed (its RAM blocks returned);
* SS.FClr ($81): FS2's VIRQ set or cleared; SS.FSet ($C7): FS2+'s VIRQ set; SS.KSet ($C8) / SS.KClr ($C9):
* KQ3's VIRQ set / cleared; SS.ARAM ($CA) / SS.DRAM ($CB): RAM blocks taken / returned; else unknown service
VSStt               bsr       GetInfo             the path, the process, the caller's registers
                    cmpa      #SS.SpBy            SS.SpBy ($82) as a SetStat: the speech buffer emptied (FS2's
                    bne       Chk.SS2A            tower after a crash); Feed's guard then silences the chip
                    pshs      cc
                    orcc      #IntMasks
                    ldd       SpHead,u
                    std       SpTail,u
                    tst       SpSil,u             the chip inside a frame: its rest silent first (Feed sends
                    bne       SS82a               SpSil before any new byte), so what is written next starts
                    lda       SpPos,u             a frame of its own
                    beq       SS82a
                    nega
                    adda      #SpFrameLen
                    sta       SpSil,u
SS82a               lda       #SpLiveOn           then a whole silent frame (the guard) unless speech follows
                    sta       SpLive,u
                    puls      cc
                    clrb
                    rts
Chk.SS2A            cmpa      #SS.Close           SS.Close ($2A)?
                    bne       Chk.SSC9            no: on
                    bsr       FPTFS2              an FS2 table of ours?
                    bcs       Chk.KV2A            none: on to KQ3
                    clr       All.ID,x            freed
Chk.KV2A            bsr       SS2A.KQ3            a KQ3 table of ours freed
                    bra       SS2A.RAM            and our RAM blocks returned (returns from there)

Chk.SSC9            cmpa      #SS.KClr            SS.KClr ($C9)?
                    bne       Chk.SSCB            no: on
SS2A.KQ3            bsr       FPTKQ3              a KQ3 table of ours?
                    bcs       SS.OK               none: done
                    clr       All.ID,x            freed
                    rts

Chk.SSCB            cmpa      #SS.DRAM            SS.DRAM ($CB)?
                    bne       Chk.SSC8            no: on
SS2A.RAM            bsr       FPTRAM              a RAM table of ours?
                    bcs       SS.OK               none: done
                    clr       All.ID,x            freed
                    ldb       RAM.Bks,x           B = its blocks
                    beq       SS.OK               none: done
                    ldx       RAM.StB,x           X = the first
                    os9       F$DelRAM            returned to the system
                    rts

* FPTRAM / FPTKQ3 / FPTFS2: X = this process+path's RAM / KQ3 / FS2 table; carry set when there is none
FPTRAM              leax      RAMTbls,u           X = the first RAM table
                    ldd       #RTCountSize        A = how many, B = their size
                    bra       FPT01

FPTKQ3              leax      VIRQTbls+KQ3.ID,u   X = the first KQ3 entry
                    bra       FPT00

FPTFS2              leax      VIRQTbls+FS2.ID,u   X = the first FS2 entry
FPT00               ldd       #VTCountSize        A = how many, B = their size
FPT01               pshs      a                   the count on the stack
FPTLoop             lda       ProcNmbr,u          this process
                    cmpa      All.ID,x            its?
                    bne       FPTNext             no: the next
                    lda       PathNmbr,u          this path
                    cmpa      All.Pth,x           its?
                    bne       FPTNext             no: the next
                    clrb                          found: carry clear
                    puls      a,pc

FPTNext             abx                           the next table
                    dec       ,s                  any left?
                    bne       FPTLoop             yes
                    comb                          none: carry set
                    puls      a,pc

Chk.SSC8            cmpa      #SS.KSet            SS.KSet ($C8)?
                    bne       Chk.SSCA            no: on
                    bsr       FPTKQ3              already ours?
                    bcc       SS.OK               yes: done
                    bsr       FETKQ3              a free KQ3 entry taken
                    bcs       BusyErr             none: busy
SS.OK               clrb                          no error
                    rts

Chk.SSCA            cmpa      #SS.ARAM            SS.ARAM ($CA)?
                    bne       Chk.SS81            no: on
                    bsr       FPTRAM              a RAM table of ours already?
                    bcc       BusyErr             yes: busy
                    bsr       FETRAM              a free one taken
                    bcs       BusyErr             all taken: busy
                    ldb       R$X+1,y             B = the blocks asked for (the caller's X)
                    stb       RAM.Bks,x           kept
                    os9       F$AllRAM            taken from the system
                    bcs       SSCA.Err            refused
                    std       RAM.StB,x           the first block kept
                    std       R$X,y               and to the caller's X
SS.Err              rts

SSCA.Err            pshs      cc,b                the error kept,
                    clr       All.ID,x            the table freed,
                    puls      cc,b,pc             the error returned

* GetFS2: X = this process+path's FS2 table, taken if it had none (its tick count cleared); its timer and reset
* count from the caller's X, no signals sent yet. Carry set: none free.
GetFS2              bsr       FPTFS2              ours already?
                    bcc       GotFS2              yes
                    bsr       FETFS2              a free one taken
                    bcs       BusyErr             none: busy
                    lbsr      ClrVTot             its tick count cleared
GotFS2              ldd       R$X,y               the caller's X: ticks per signal
                    std       FS2.Tmr,x           the timer
                    std       FS2.Rst,x           and its reset count
                    clr       FS2.STot,x          no signals sent yet
                    rts

* FETRAM / FETKQ3 / FETFS2: X = a free RAM / KQ3 / FS2 table, taken for this process+path; carry set when
* none is free
FETRAM              leax      RAMTbls,u           X = the first RAM table
                    ldd       #RTCountSize        A = how many, B = their size
                    bra       FET01

FETKQ3              leax      VIRQTbls+KQ3.ID,u   X = the first KQ3 entry
                    bra       FET00

FETFS2              leax      VIRQTbls+FS2.ID,u   X = the first FS2 entry
FET00               ldd       #VTCountSize        A = how many, B = their size
FET01               pshs      a                   the count on the stack
FETLoop             lda       All.ID,x            taken?
                    bne       FETNext             yes: the next
                    lda       ProcNmbr,u          this process
                    sta       All.ID,x            takes it
                    lda       PathNmbr,u          on this path
                    sta       All.Pth,x
                    clrb                          found: carry clear
                    puls      a,pc

FETNext             abx                           the next table
                    dec       ,s                  any left?
                    bne       FETLoop             yes
                    comb                          none: carry set
                    puls      a,pc

BusyErr             comb                          carry set
                    ldb       #E$DevBsy           device busy
                    rts

* SS.FClr: FS2's VIRQ, signal $80 every X ticks; the caller's Y low byte 0 clears it instead
Chk.SS81            cmpa      #SS.FClr            SS.FClr ($81)?
                    bne       Chk.SSC7            no: on
                    bsr       GetFS2              our FS2 table, its timer from X
                    bcs       SS.Err              none free
                    ldb       #S$FS2Sig           FS2's signal ($80)
                    stb       FS2.Sgl,x           kept
                    ldb       R$Y+1,y             the caller's Y low byte: set?
                    bne       SS.OK               yes: done
ClrID               clr       All.ID,x            no: the table freed
                    rts

* SS.FSet: FS2+'s VIRQ: the first signal after X ticks, then every Y ticks (0: once), with the signal code in
* the caller's U low byte
Chk.SSC7            cmpa      #SS.FSet            SS.FSet ($C7)?
                    bne       USvcErr             no: unknown service
                    bsr       GetFS2              our FS2 table, its timer from X
                    bcs       SS.Err              none free
                    ldd       R$Y,y               the caller's Y: ticks between signals (0: once)
                    std       FS2.Rst,x           the reset count
                    ldb       R$U+1,y             the caller's U low byte: the signal code
                    stb       FS2.Sgl,x           kept
                    rts

USvcErr             comb                          carry set
                    ldb       #E$UnkSvc           unknown service
                    rts

* IRQSvc: every tick (the clock's VIRQ): the VIRQ flag cleared; for each VIRQ table, KQ3's user signaled, and
* FS2's user's tick count raised and its timer counted down, signaled when it runs out (then reloaded, or freed
* when it has no reset count)
IRQSvc              lda       VIRQPckt+Vi.Stat,u  the fake VIRQ status register
                    anda      #^Vi.IFlag          its VIRQ flag cleared
                    sta       VIRQPckt+Vi.Stat,u
                    bsr       Feed                the speech chip fed
                    leau      VIRQTbls,u          U = the first VIRQ table
                    ldy       #VTCount            Y = how many
IRQLoop             lda       KQ3.ID,u            a KQ3 user?
                    beq       NoKQ3Sgl            no
                    ldb       #S$KQ3Sig           KQ3's signal ($80)
                    os9       F$Send              sent (an error is ignored)
NoKQ3Sgl            lda       FS2.ID,u            an FS2 user?
                    beq       NoFS2Sgl            no: the next table
                    inc       FS2.VTot+3,u        its 32-bit tick count raised
                    bne       DoneVTot
                    inc       FS2.VTot+2,u
                    bne       DoneVTot
                    inc       FS2.VTot+1,u
                    bne       DoneVTot
                    inc       FS2.VTot,u
DoneVTot            ldx       FS2.Tmr,u           its timer
                    leax      -1,x                one tick less
                    stx       FS2.Tmr,u           run out?
                    bne       NoFS2Sgl            no: the next table
                    inc       FS2.STot,u          yes: one more signal sent
                    ldx       FS2.Rst,u           the timer reloaded
                    stx       FS2.Tmr,u
                    bne       KeepID              repeating: the table stays
                    clr       FS2.ID,u            once only: the table freed
KeepID              ldb       FS2.Sgl,u           B = its signal code (A = its process)
                    os9       F$Send              sent (an error is ignored)
NoFS2Sgl            leau      VTSize,u            the next table
                    leay      -1,y                any left?
                    bne       IRQLoop             yes

* Feed (IRQSvc, every tick, U = the device memory): up to 15 bytes from the speech buffer to the chip, each when it
* reads Ready; Ready low for SpPoll polls: its FIFO is full (it takes the next frame as the current one ends).
* The guard (edition 3, 2026-10-21): the chip keeps running its last frame when no new one comes (its RTL resets
* only the repeat counters: an unvoiced frame goes on as static, a voiced one as a buzz), so speech that stops
* without its closing silent frame (a phrase cut short, the writer stopped by a crash, a menu or the exit) would
* sound on. Whole frames (edition 4, 2026-10-21): VWrit publishes each byte as it comes, so a tick can land inside
* a frame the writer is still writing; a frame starts only when all 15 of its bytes are in the buffer, and the
* buffer running short of one after speech is the end: a whole silent frame (SilFr) at the frame boundary, within
* a tick. The writer's bytes are never cut into frames out of step. Inside a frame its bytes are there; only
* SS.SpBy's purge ends one early (its rest silent: SpSil).
Feed                ldx       SpBuf,u
                    beq       FdDone              no chip
                    lda       #SpFrameLen         a frame at most
                    pshs      a
Fd1                 tst       SpSil,u             a silent frame being sent: it first
                    bne       Fd4
                    ldd       SpHead,u            D = the bytes waiting
                    subd      SpTail,u
                    anda      #SpMask
                    tst       SpPos,u
                    bne       Fd9                 inside a frame
                    cmpd      #SpFrameLen
                    bhs       Fd3                 a whole frame waiting: it starts
                    tst       SpLive,u            none whole: after speech, a silent frame
                    beq       Fd8
                    clr       SpLive,u
                    lda       #SpFrameLen
                    bra       Fd2
Fd9                 cmpd      #SpNoBytes
                    bne       Fd3                 the frame's next byte
                    clr       SpLive,u            (none: not reached, a frame starts whole) its rest silent,
                    lda       #SpTwoFrames        then a silent frame
                    suba      SpPos,u
Fd2                 sta       SpSil,u
Fd4                 bsr       FdRdy
                    bcs       Fd8                 full: the next tick
                    ldb       SpPos,u
                    leay      SilFr,pcr
                    lda       b,y
                    sta       >SpReg
                    dec       SpSil,u
                    bra       Fd5
Fd3                 bsr       FdRdy
                    bcs       Fd8
                    ldd       SpTail,u
                    lda       d,x                 the next byte
                    sta       >SpReg              to the chip
                    ldd       SpTail,u
                    addd      #SpStep
                    anda      #SpMask
                    std       SpTail,u
                    lda       #SpLiveOn
                    sta       SpLive,u
Fd5                 inc       SpPos,u             the frame's bytes
                    lda       SpPos,u
                    cmpa      #SpFrameLen
                    blo       Fd6
                    clr       SpPos,u
Fd6                 dec       ,s
                    bne       Fd1
Fd8                 leas      1,s
FdDone              rts
* FdRdy: carry clear when the chip reads Ready within SpPoll polls (room in its FIFO). Y clobbered.
FdRdy               ldy       #SpPoll
FdR1                lda       >SpReg
                    bita      #SpReady
                    bne       FdR2
                    leay      -1,y
                    bne       FdR1
                    orcc      #Carry
                    rts
FdR2                andcc     #^Carry
                    rts
* SilFr: a silent frame (amplitude 0), as speech2sp0250.py ends every phrase
SilFr               fcb       $80,$80,$00,$80,$80,$63,$80,$80,$01,$80,$80,$80,$80,$80,$80

* VWrit: A = a byte of speech: into the ring buffer (when it is full, a tick's sleep and again: the feeder makes
* room); dropped when there is no chip
VWrit               ldx       SpBuf,u
                    beq       WrOK                no chip: dropped
                    pshs      a                   the byte
Wr1                 ldd       SpHead,u
                    addd      #SpStep
                    anda      #SpMask
                    cmpd      SpTail,u            would the head meet the tail?
                    bne       Wr2                 no: room
                    ldx       #SleepOneTick
                    os9       F$Sleep             a tick
                    ldx       SpBuf,u
                    bra       Wr1
Wr2                 pshs      d                   the head after it
                    ldd       SpHead,u
                    leax      d,x
                    lda       2,s                 the byte
                    sta       ,x                  in
                    puls      d
                    std       SpHead,u            then the head on (the feeder reads it)
                    leas      1,s
WrOK                clrb                          no error
                    rts

                    emod
VEnd                equ       *
                    end
