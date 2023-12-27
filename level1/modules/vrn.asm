********************************************************************
* VRN - VIRQ/RAM/Nil device driver
*
* $Id$
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
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   ?      2003/02/08  Bruce Isted
* Created.
*   ?      2020/05/16  Added Alan Dekok's get/setstat labels, and new Signal names - LCB

                    nam       VRN
                    ttl       VIRQ/RAM/Nil device driver

                    ifp1
                    use       defsfile
                    endc

VTCount             equ       4                   maximum number of VIRQ tables. Changing this will
*                           change the number of RAM allocation block tables

* VIRQ Table Data Layout (14 bytes each entry)
                    org       0
FS2.ID              rmb       1                   Flight Simulator 2 (and FS2+) VIRQ process ID
FS2.Pth             rmb       1                   path number
FS2.Sgl             rmb       1                   signal code
FS2.Tmr             rmb       2                   countdown timer (send signal on zero)
FS2.Rst             rmb       2                   reset count (no reset if zero)
FS2.STot            rmb       1                   signal counter
FS2.VTot            rmb       4                   total VIRQ counter
KQ3.ID              rmb       1                   King's Quest III VIRQ process ID
KQ3.Pth             rmb       1                   path number
VTSize              equ       .                   VIRQ table size

* RAM Table Data Layout (5 bytes each entry)
                    org       0
RAM.ID              rmb       1                   RAM process ID
RAM.Pth             rmb       1                   path number
RAM.Bks             rmb       1                   number of RAM blocks
RAM.StB             rmb       2                   starting RAM block number
RTSize              equ       .                   RAM table size

* Shared VIRQ/RAM Table Data Layout
                    org       0
All.ID              rmb       1                   all tables' process ID
All.Pth             rmb       1                   all tables' path number

* Static device mem (in our 256 byte assigned memory).
* LCB:  May want to add these in defs files.
                    org       V.SCF
VIRQPckt            rmb       5                   VIRQ packet Counter(2),Reset(2),Status(1) bytes
PathNmbr            rmb       1                   current path number
ProcNmbr            rmb       1                   current process ID
VIRQTbls            rmb       VTCount*VTSize      space for VIRQ tables
RTCount             equ       ($0100-.)/RTSize    number of tables that fit in balance of page (32 default)
RAMTbls             rmb       RTCount*RTSize      space for RAM tables
VMem                equ       .

rev                 set       $00
edition             set       1

                    mod       VEnd,VName,Drivr+Objct,ReEnt+rev,VEntry,VMem

                    fcb       UPDAT.              driver access mode(s)

VName               fcs       "VRN"
                    fcb       edition             edition byte

* 6809/6309 - LCB: Move to closer to most often used branches (VSStt), so we can use BRA. At
* end of VGStt, just before VSStt, is probably best (might be able to BRA both get & set stat)
VEntry              lbra      VInit
                    lbra      VRead
                    lbra      VWrit
                    lbra      VGStt
                    lbra      VSStt
                    lbra      VTerm

                    IFGT      Level-1
IRQPckt             fcb       $00,$01,$0A         IRQ packet Flip(1),Mask(1),Priority(1) bytes
                    ENDC

* No real init on level 1 (which I presume just handles the /NIL device)
VInit               equ       *
                    IFGT      Level-1
* Note that all device memory except V.PAGE and
* V.PORT has already been cleared (zeroed).
                    leax      VIRQPckt+Vi.Stat,u  fake VIRQ status register
                    lda       #$80                VIRQ flag clear, repeated VIRQs
                    sta       ,x                  set it while we're here...
                    tfr       x,d                 copy fake VIRQ status register address
                    leax      IRQPckt,pc          IRQ polling packet
                    leay      IRQSvc,pc           IRQ service entry
                    os9       F$IRQ               Install our IRQ entry
                    bcs       InitExit            go report error...
                    ldd       #$0001              initial count
                    std       VIRQPckt+Vi.Rst,u   reset count
                    ldx       #$0001              code to install new VIRQ
                    leay      VIRQPckt,u          VIRQ software registers
                    os9       F$VIRQ
                    bcc       InitExit            no error, go exit...
                    pshs      cc,b                save error info
                    bsr       DumpIRQ             go remove from IRQ polling
                    puls      cc,b,pc             recover error info & exit...
                    ELSE
                    clrb
                    rts
                    ENDC

VRead               comb
                    ldb       #E$EOF              End of file error
InitExit            rts

* Level 1 just exits, since it only handles /NIL
VTerm               equ       *
                    IFGT      Level-1
                    ldx       #$0000              code to delete VIRQ entry
                    leay      VIRQPckt,u          VIRQ software registers
                    os9       F$VIRQ              remove from VIRQ polling
                    bcs       Term.Err            go report error...
DumpIRQ             leax      VIRQPckt+Vi.Stat,u  fake VIRQ status register
                    tfr       x,d                 copy address...
                    ldx       #$0000              code to remove IRQ entry
                    leay      IRQSvc,pc           IRQ service routine
                    os9       F$IRQ
                    ELSE
                    clrb                          No error & return
                    ENDC
Term.Err            rts

* GetStat calls - NOTE: Only the Flight Sim II style calls have GetStats
VGStt               equ       *
                    IFGT      Level-1
* [A] = call code
* call $01:  SS.Ready (device never has data ready)
* call $80:  SS.VCtr  return FS2/FS2+ total VIRQ counter
* call $81:  SS.VSig  return FS2/FS2+ number of signals sent
* all others return E$UnkSvc error
                    bsr       GetInfo             process+path and caller's stack info
                    cmpa      #SS.Ready           SS.Ready?
                    bne       Chk.GS80            no, go check next...
                    comb                          Yes, Ready *always* returns Device Not Ready error
                    ldb       #E$NotRdy
                    rts

UnitErr             ldb       #E$Unit             Illegal Unit # error
                    rts

* get process+path info, [Y] --> caller's register stack
* do not alter [A] or [U]
GetInfo             ldb       PD.PD,y             path number
                    stb       PathNmbr,u          save it...
                    ldb       PD.CPR,y            current process ID (can't depend on V.BUSY)
                    stb       ProcNmbr,u          save it...
                    ldy       PD.RGS,y            caller's register stack address
                    rts

* SS.VCtr GetStat (FS2 call to return 32 bit count of VIRQ's, and reset counter to 0)
Chk.GS80            cmpa      #SS.VCtr            ($80) return total VIRQ count, and clear count to 0?
                    bne       Chk.GS81            no, go check next...
                    bsr       FPTFS2              find process+path entry
                    bcs       UnitErr             not in tables, go return Illegal Unit # error...
* LCB 6309 - ldq/stq
                    ldd       FS2.VTot,x          Return 32 bit total VIRQ counter in X:Y
                    std       R$X,y
                    ldd       FS2.VTot+2,x
                    std       R$Y,y
ClrVTot             clra
                    clrb                          no error...
                    std       FS2.VTot,x          Reset 32 bit VIRQ counter to 0
                    std       FS2.VTot+2,x
                    rts

* SS.VSig GetStat (FS2 call to return 8 bit count of number of Signals sent), and reset signal count to 0
Chk.GS81            cmpa      #SS.VSig            ($81) return & clear number of signals sent?
                    lbne      USvcErr             Whatever call they wanted is not supported, go report error...
                    bsr       FPTFS2              find process+path entry
                    bcs       UnitErr             not in tables, go return error...
                    lda       FS2.STot,x          Get number of signals sent
                    sta       R$A,y               return it to caller in A
                    clr       FS2.STot,x          and reset signal count to 0
                    ELSE
                    clrb                          Level 1 doesn't do VIRQ stuff, return w/o error
                    ENDC
                    rts

* VIRQ SetStat calls
VSStt               equ       *
                    IFGT      Level-1
* [A] = call code
* call $2A:  SS.Close (clear all process+path entries)
* call $81:  SS.FClr  (set process+path FS2 VIRQ, clear process+path FS2/FS2+ VIRQ)
* call $C7:  SS.FSet  (set process+path FS2+ VIRQ)
* call $C8:  SS.KSet  (set process+path KQ3 VIRQ)
* call $C9:  SS.KClr  (clear process+path KQ3 VIRQ)
* call $CA:  SS.ARAM  (allocate process+path RAM blocks)
* call $CB:  SS.DRAM  (de-allocate process+path RAM blocks)
* all others return E$UnkSvc error
                    bsr       GetInfo             process+path and caller's stack info
                    cmpa      #SS.Close           ($2A) SS.Close?
                    bne       Chk.SSC9            no, go check next...
                    bsr       FPTFS2              Yes, check for existing FS2/FS2+ VIRQ entry...
                    bcs       Chk.KV2A            none, go check for KQ3 VIRQ...
                    clr       All.ID,x            de-allocate FS2/FS2+ entry
Chk.KV2A            bsr       SS2A.KQ3            check/de-allocate KQ3 VIRQ...
                    bra       SS2A.RAM            go return RAM blocks, return from there...

Chk.SSC9            cmpa      #SS.KClr            ($C9) clear KQ3 VIRQ?
                    bne       Chk.SSCB            no, go check next...
SS2A.KQ3            bsr       FPTKQ3              existing KQ3 VIRQ is ours?
                    bcs       SS.OK               no, go exit clean...
                    clr       All.ID,x            de-allocate KQ3 VIRQ
                    rts

Chk.SSCB            cmpa      #SS.DRAM            ($CB) return process+path RAM blocks?
                    bne       Chk.SSC8            no, go check next...
SS2A.RAM            bsr       FPTRAM              go find RAM table entry
                    bcs       SS.OK               no entry, go exit clean...
                    clr       All.ID,x            de-allocate table entry
                    ldb       RAM.Bks,x           number of RAM blocks
                    beq       SS.OK               no RAM to return, go exit clean...
                    ldx       RAM.StB,x           first block number
                    os9       F$DelRAM            Deallocate the contiguous RAM blocks
                    rts

* Find Current Process+Path Table Entry
FPTRAM              leax      RAMTbls,u           first RAM table
                    ldd       #RTCount*256+RTSize [A]=loop count, [B]=table size
                    bra       FPT01

FPTKQ3              leax      VIRQTbls+KQ3.ID,u   first KQ3 VIRQ entry
                    bra       FPT00

FPTFS2              leax      VIRQTbls+FS2.ID,u   first FS2/FS2+ VIRQ entry
FPT00               ldd       #VTCount*256+VTSize [A]=loop count, [B]=table size
FPT01               pshs      a                   save loop count
FPTLoop             lda       ProcNmbr,u          current process ID
                    cmpa      All.ID,x            same?
                    bne       FPTNext             no, go check next...
                    lda       PathNmbr,u          current path number
                    cmpa      All.Pth,x           same?
                    bne       FPTNext             no, go check next...
                    clrb                          table found, clear Carry
                    puls      a,pc                clean up stack, return

FPTNext             abx                           next table
                    dec       ,s                  done yet?
                    bne       FPTLoop             no, go check next...
                    comb                          table not found, set Carry
                    puls      a,pc                clean up stack, return

Chk.SSC8            cmpa      #SS.KSet            ($C8) set KQ3 VIRQ?
                    bne       Chk.SSCA            no, go check next...
                    bsr       FPTKQ3              existing KQ3 VIRQ?
                    bcc       SS.OK               yes, go exit clean...
                    bsr       FETKQ3              KQ3 VIRQ available?
                    bcs       BusyErr             no, go report error...
SS.OK               clrb                          no error...
                    rts

Chk.SSCA            cmpa      #SS.ARAM            ($CA) allocate process+path RAM blocks?
                    bne       Chk.SS81            no, go check next...
                    bsr       FPTRAM              go check for existing process+path RAM table entry
                    bcc       BusyErr             found it, go report error...
                    bsr       FETRAM              go find empty RAM table entry...
                    bcs       BusyErr             tables full, go report error...
                    ldb       R$X+1,y             RAM blocks to allocate
                    stb       RAM.Bks,x           save it...
                    os9       F$AllRAM
                    bcs       SSCA.Err            go report error...
                    std       RAM.StB,x           save first block number
                    std       R$X,y               return it to caller, too
SS.Err              rts

SSCA.Err            pshs      cc,b                save error info
                    clr       All.ID,x            de-allocate table entry
                    puls      cc,b,pc             recover error info, return

GetFS2              bsr       FPTFS2              check for existing FS2/FS2+ entry...
                    bcc       GotFS2              found it...
                    bsr       FETFS2              check for empty FS2/FS2+ table...
                    bcs       BusyErr             none left, go report error...
                    lbsr      ClrVTot             go clear VIRQ total counter
GotFS2              ldd       R$X,y               FS2/FS2+ timer count
                    std       FS2.Tmr,x           save it...
                    std       FS2.Rst,x           FS2 reset count
                    clr       FS2.STot,x          no signals sent yet...
                    rts

* Find Empty Table Entry
FETRAM              leax      RAMTbls,u           first RAM table
                    ldd       #RTCount*256+RTSize [A]=loop count, [B]=table size
                    bra       FET01

FETKQ3              leax      VIRQTbls+KQ3.ID,u   first KQ3 VIRQ entry
                    bra       FET00

FETFS2              leax      VIRQTbls+FS2.ID,u   first FS2/FS2+ VIRQ entry
FET00               ldd       #VTCount*256+VTSize [A]=loop count, [B]=table size
FET01               pshs      a                   save loop count
FETLoop             lda       All.ID,x            table allocated?
                    bne       FETNext             yes, go check next...
                    lda       ProcNmbr,u          current process ID
                    sta       All.ID,x            allocate table
                    lda       PathNmbr,u          current path number
                    sta       All.Pth,x           set path number
                    clrb                          table found, clear Carry
                    puls      a,pc                clean up stack, return

FETNext             abx                           next table
                    dec       ,s                  done yet?
                    bne       FETLoop             no, go check next...
                    comb                          table not found, set Carry
                    puls      a,pc                clean up stack, return

BusyErr             comb                          Return a Device Busy error
                    ldb       #E$DevBsy
                    rts

* Standard FS2 signal (always sends signal code $80):
* Callers entry:
*   A = path
*   Y = LSB is clear/shut off signal (LSB=0) or set/turn on signal (LSB<>0)
*   X = Timer/reset count (# of 1/60th second ticks between signal sends)
Chk.SS81            cmpa      #SS.FClr            ($81) Set/clear FS2 VIRQ?
                    bne       Chk.SSC7            no, go check next...
                    bsr       GetFS2              go get FS2/FS2+ VIRQ entry
                    bcs       SS.Err              Couldn't get one, report error...
                    ldb       #S$FS2Sig           ($80) standard FS2 signal code
                    stb       FS2.Sgl,x           save it...
                    ldb       R$Y+1,y             FS2 VIRQ enable/disable flag
                    bne       SS.OK               set VIRQ flag, exit w/o error
ClrID               clr       All.ID,x            de-allocate entry by clearing process ID #
                    rts

* Enhanced FS2+ signal
* Callers entry:
*   A = path
*   X = Initial timer count (in 1/60th of second ticks)
*   Y = Reset count ($0000=one shot VIRQ, will not repeat),
*       else number of 1/60th sec ticks for each repeating VIRQ
*   U = MSB = $00 (reserved)
*       LSB = Signal code to send
Chk.SSC7            cmpa      #SS.FSet            ($C7) set FS2+ VIRQ?
                    bne       USvcErr             Unsupported SetStat call, report error...
                    bsr       GetFS2              go get FS2/FS2+ VIRQ entry
                    bcs       SS.Err              go report error...
                    ldd       R$Y,y               FS2+ reset count (one shot VIRQ if zero)
                    std       FS2.Rst,x           save it...
                    ldb       R$U+1,y             LSB = caller's signal code
                    stb       FS2.Sgl,x           save it...
                    rts

USvcErr             comb                          Return Unknown Service error
                    ldb       #E$UnkSvc
                    rts

* LCB 6309: AIM #^Vi.IFlag,VIRQPckt+ViStat,u
IRQSvc              lda       VIRQPckt+Vi.Stat,u  Get VIRQ status register
                    anda      #^Vi.IFlag          clear flag that VIRQ occured in VIRQ status register
                    sta       VIRQPckt+Vi.Stat,u  save it back
* LCB 6309: Changing some registers around here (use X for table entry ptr, B as VTSize, etc.)
* could speed this up a bit.
                    leau      VIRQTbls,u          VIRQ tables
                    ldy       #VTCount            loop count (normal default is 4 possible FS/KQ VIRQ's
IRQLoop             lda       KQ3.ID,u            KQ3 VIRQ process ID (only one allowed in system at at time?)
                    beq       NoKQ3Sgl            none, skip sending a KQ3 signal
                    ldb       #S$KQ3Sig           ($80) KQ3 signal code
                    os9       F$Send              send signal, ignore error (if any)
NoKQ3Sgl            lda       FS2.ID,u            process ID
                    beq       NoFS2Sgl            No FS2 set up for current entry, skip all counter updates...
                    inc       FS2.VTot+3,u        (7) Increment 32 bit total VIRQ counter
                    bne       DoneVTot
                    inc       FS2.VTot+2,u
                    bne       DoneVTot
                    inc       FS2.VTot+1,u
                    bne       DoneVTot
                    inc       FS2.VTot,u
DoneVTot            ldx       FS2.Tmr,u           dec # of VIRQ's before we send signal
                    leax      -1,x
                    stx       FS2.Tmr,u           done yet?
                    bne       NoFS2Sgl            no, we are done with current entry
                    inc       FS2.STot,u          Yes, bump up number of FS2(+) signals sent
                    ldx       FS2.Rst,u           reset # of VIRQ's before next FS2(+) signal send
                    stx       FS2.Tmr,u
                    bne       KeepID              There is a reset value, so we are done updating current entry
                    clr       FS2.ID,u            If reset value was 0, flag entry unused (one shot VIRQ)
KeepID              ldb       FS2.Sgl,u           Get signal code
                    os9       F$Send              send signal B to process A, ignore error (if any)
NoFS2Sgl            leau      VTSize,u            next table
* LCB 6309: Use E instead of Y?
                    leay      -1,y                done all tables?
                    bne       IRQLoop             no, go check next...
                    ENDC

VWrit               clrb                          no error...
                    rts

                    emod
VEnd                equ       *
                    end
