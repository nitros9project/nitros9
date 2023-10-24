* Disassembly by Dynamite+ of cc3disk
*

* ======================================================
*                  Layout of SC-II registers:
*
* $FF74   RW.Dat  --- R/W Buffer data #1
* $FF75       mirror of $FF74
* $FF76   RW.Ctrl --- Write  D0 = 0  FDC Write Op #2
*                               = 1  FDC Read Op  #2
*                            D1 = 0  Normal Mode
*                               = 1  Buffered I/O Mode
*                            D2 = 0  Normal NMI
*                               = 1  Masked NMI
*                            D3 = 0  No FIRQ (Masked)
*                               = 1  Enabled FIRQ
*                     Read   D7 = FDC INT Status (Inverted)
* $FF77       mirror of $FF76
*        #1: any write to $FF76-$FF77 clears Buffer counter
*        #2: in buffered mode only
* =========================================================

                    nam       CC3Disk.irq
                    ttl       Disto version: patched to remove F$IRQ on TERM

Level               equ       2

                    ifp1
                    use       defsfile
                    use       rbfdefs
                    endc

TyLan               equ       Drivr+Objct
AttRev              equ       ReEnt+3
Edition             set       163
ForcInt             equ       $d0
WrtSct              equ       $a0

                    mod       dlen,dnam,TyLan,AttRev,dexec,datsiz

RG.Ctrl             equ       $ff40
RG.Stat             equ       $ff48
RG.Trk              equ       $ff49
RG.Sect             equ       $ff4a
RG.Data             equ       $ff4b
*   I *THINK* Disto manual was backwards
*      This looks better in code
RW.Dat              equ       $ff74
RW.Ctrl             equ       $ff76
MPICtrl             equ       $ff7f
*IRQENR equ $ff92

* OS-9 data area definitions

                    org       DRVBEG+4*DRVMEM
tl                  equ       .
LstDrv              rmb       1
DrivMsk             rmb       1
ChgFlg              rmb       1
d00aa               rmb       1
d00ab               rmb       1
DskOfst             rmb       3
DisCode             rmb       2
VIRQPak             rmb       5
                    rmb       1
Lsn                 rmb       3
WtrkBuf             rmb       2
MPISlot             rmb       1
MPISav              rmb       1
datsiz              equ       .

                    fcb       $ff
dnam                fcs       "CC3Disk"
                    fcb       Edition

dexec               lbra      INIT
                    lbra      READ
                    lbra      WRITE
                    lbra      GETSTA
                    lbra      PUTSTA

TERM                ldx       #0
                    leau      LstDrv,u
                    leay      VIRQPak-tl,u
                    os9       F$VIRQ
                    leay      IRQSvc,pcr
                    os9       F$IRQ
                    leay      SC2vec,pcr
                    os9       F$IRQ
                    clrb
                    stb       RG.Ctrl
                    stb       D.MotOn
                    rts

* F$IRQ arrays: Flip byte, Mask byte, priority
videfs              fcb       0,Vi.IFlag,9
SC2stts             fcb       $80,$80,16

********************
* INIT:  entry:  U= Static Mem,  Y= Device Descr

INIT                clr       RW.Ctrl
                    clr       D.MotOn
                    ldx       #RG.Stat
                    lda       #ForcInt
                    sta       ,x                  Send cmd to FDC
                    lbsr      tdelay              Wait
                    lda       ,x                  Clear FDC register
                    lda       #$ff                Init "last drive accessed"
                    sta       LstDrv,u            to impossible #
                    ldb       #4
                    leax      DRVBEG,u
l0067               sta       ,x
                    sta       DD.BT,x
                    leax      DRVMEM,x
                    decb
                    bne       l0067
                    leax      NMIvec,pcr
                    stx       D.NMI
                    pshs      u
                    leau      LstDrv,u
                    leay      VIRQPak+VI.Stat-tl,u
                    tfr       y,d
                    leay      IRQSvc,pcr
                    leax      >videfs,pcr
                    os9       F$IRQ
                    puls      u
                    bcs       ret010
                    lda       MPICtrl
                    sta       MPISlot,u
                    ldd       #RW.Ctrl
                    leay      SC2vec,pcr
                    leax      >SC2stts,pcr
                    os9       F$IRQ
                    bcs       ret010
                    pshs      cc
                    orcc      #IntMasks
                    lda       $FF23
* disable FIRQ from cart. set flag on falling edge of CART
                    anda      #$fc
                    sta       $FF23
                    lda       $FF22
                    lda       D.IRQER
                    ora       #1                  Enable CART IRQ
                    sta       D.IRQER             ..save in IRQENR shadow
                    sta       IRQENR              .. and actual register
                    puls      cc

***************
* GetSta : no op

GETSTA              clrb
ret010              rts

*******************
* READ   entry:  U= device Mem  Y= Path Descr
*                B,X= LSN

READ                lbsr      trkcmput
                    clr       d00aa-tl,u
                    ldd       Lsn-tl,u
                    bne       l0118
                    bsr       l0118
                    bcs       ret010
                    lda       PD.TYP,y
                    bita      #$40
                    lbne      t0set
                    ldx       PD.BUF,y
                    pshs      x,y
                    ldy       PD.DTB,y
                    ldb       #$14
l00e5               lda       b,x
                    sta       b,y
                    decb
                    bpl       l00e5
                    lda       DD.FMT,y
                    ldy       2,s
                    ldb       PD.DNS,y
                    bita      #2
                    beq       l00fd
                    bitb      #1
                    beq       badtyp
l00fd               bita      #4
                    beq       l0105
                    bitb      #2
                    beq       badtyp
l0105               bita      #1
                    beq       ret025
                    lda       PD.SID,y
                    suba      #2
                    bcs       badtyp
ret025              clrb
                    puls      x,y,pc
badtyp              comb
                    ldb       #E$BTyp
                    puls      x,y,pc
l0118               lbsr      l02d6
                    bcs       ret010
                    ldb       #$80
                    lda       #7
                    bsr       l019c
                    lbcs      E.Read
                    ldx       PD.BUF,y
                    ldb       #$80
                    tst       d00aa-tl,u
                    bne       l013c
                    pshs      b
*         Move data from SC2 buffer to RBF buffer
getdat              ldd       RW.Dat
                    std       ,x++
                    dec       ,s
                    bne       getdat
                    puls      b
l013c               andcc     #^Carry
                    rts

* ******************
* WRITE    entry: U= Device static Mem   Y= Path Descr
*                 B,X= LSN

WRITE               lbsr      trkcmput
l0142               bsr       l0151
                    bcs       ret040
                    tst       PD.VFY,y
                    bne       ret030
                    bsr       verify
                    bcs       l0142
ret030              clrb
ret040              rts
l0151               lbsr      l02d6
                    bcs       ret040
                    ldx       PD.BUF,y
                    lda       #4
                    sta       RW.Ctrl
                    ldb       #$80
                    pshs      b
putdat              ldd       ,x++
                    std       RW.Dat
                    dec       ,s
                    bne       putdat
                    puls      b
                    ldb       #WrtSct
                    lda       #6
                    bsr       l019c
                    lbra      l0243

verify              lda       d00ab-tl,u
                    pshs      a
                    clr       d00ab-tl,u
                    lda       #$ff
                    sta       d00aa-tl,u
                    bsr       l0118
                    bcs       l0197
                    pshs      b
l0185               ldd       RW.Dat
                    cmpd      ,x++
                    bne       l0193
                    dec       ,s
                    bne       l0185
                    bra       l0195
l0193               orcc      #Carry
l0195               puls      b
l0197               puls      a
                    sta       d00ab-tl,u
                    rts
l019c               std       DisCode-tl,u        Save both ctrlr cmds
l019e               ldd       DisCode-tl,u        Load both ctrlr cmds
                    bsr       sendcmd
                    lbsr      l0243
                    bcc       ret01ba
                    lda       RG.Stat
                    bita      #$40
                    bne       err01b9
                    lsr       d00ab-tl,u
                    beq       err01b9
                    bcc       l019e
                    lbsr      ssrset
                    bra       l019e
err01b9             coma
ret01ba             rts

* sendcmd:  entry: A=No-halt buffer cmd mask
*                  B=WD ctrlr cmd code

sendcmd             pshs      a
                    lda       D.Proc
                    sta       V.WAKE-tl,u
                    puls      a
                    stb       RG.Stat
                    ora       #8
                    sta       RW.Ctrl
                    ldb       #$28
                    orb       DrivMsk-tl,u
                    stb       RG.Ctrl
                    pshs      x
                    bra       l01e8
l01d8               ldx       D.Proc
                    lda       P$State,x
                    ora       #Suspend
                    sta       P$State,x
                    andcc     #^IntMasks
                    ldx       #1
                    lbsr      l0424
l01e8               orcc      #IntMasks
                    lda       V.WAKE-tl,u
                    bne       l01d8
                    clrb
                    ldb       #4
                    stb       RW.Ctrl
                    andcc     #^IntMasks
                    puls      x,pc
SC2vec              lda       V.WAKE,u
                    beq       err0236
                    ldb       MPICtrl
                    stb       MPISav,u
                    ldb       MPISlot,u
                    stb       MPICtrl
                    ldb       #ForcInt
                    stb       RG.Stat
                    ldb       #4
                    stb       RW.Ctrl
*       The Bruce Isted patch.  Not needed???
                    ldb       D.IRQS
                    andb      #$fe
                    stb       D.IRQS
                    ldb       D.IRQER
                    andb      #$fe
                    stb       IRQENR
                    orb       #1
                    stb       IRQENR
*        End of Bruce Isted patch *
                    clrb
                    stb       V.WAKE,u
                    tfr       d,x                 A=V.WAKE??? B=0
                    lda       P$State,x
                    anda      #^Suspend
                    sta       P$State,x
                    clrb
                    bra       ret0237
err0236             comb
ret0237             lda       MPISav,u
                    sta       MPICtrl
                    rts

NMIvec              leas      R$Size,s            Pull RTI stack
                    puls      cc,y
l0243               ldb       RG.Stat             Get error status
                    clr       RW.Ctrl
                    andb      #$f8                mask off non-error bits
                    beq       done
                    pshs      x
                    leax      <errtbl-1,pcr
l0252               leax      1,x
                    rolb
                    bcc       l0252
                    ldb       ,x
                    puls      x,pc
done                clrb
                    rts

errtbl              fcb       E$NotRdy,E$WP,E$Write,E$Seek
                    fcb       E$CRC
E.Read              comb
                    ldb       #E$Read
                    rts

trkcmput            leau      LstDrv,u
                    clr       DskOfst+2-tl,u
                    lda       #$91
                    sta       d00ab-tl,u
                    tstb                          MMsb of sector
                    bne       E.Sect              always 0 for CoCo floppies
                    tfr       x,d
                    std       Lsn-tl,u            Save lsn
                    beq       l02a4
                    ldx       PD.DTB,y
                    cmpd      DD.TOT+1,x          Req'd lsn > max?
                    bcs       l0288               no, continue
E.Sect              comb
                    ldb       #E$Sect
                    leas      2,s
                    rts

l0288               clr       ,-s
                    bra       l028e
l028c               inc       ,s
l028e               subd      DD.SPT,x
                    bcc       l028c
                    addd      DD.SPT,x
                    lda       DD.FMT,x
                    lsra
                    bcc       l02a2
                    lsr       ,s
                    bcc       l02a2
                    inc       DskOfst+2-tl,u
l02a2               puls      a
l02a4               std       DskOfst-tl,u
                    clrb
                    rts
setdrv              clr       ChgFlg-tl,u
                    lda       PD.DRV,y
                    cmpa      #4
                    bcs       l02b5
                    comb
                    ldb       #E$Unit
                    rts
l02b5               pshs      a,b,x
                    cmpa      LstDrv-tl,u
                    beq       l02bd
                    com       ChgFlg-tl,u
l02bd               sta       LstDrv-tl,u
                    leax      <drvmsks,pcr
                    ldb       a,x
                    stb       DrivMsk-tl,u
                    lbsr      mtron
                    puls      a,b,x,pc

drvmsks             fcb       $01,$02,$04,$40

l02cf               pshs      a
                    ldb       DD.BT,x
                    bra       l030c
l02d6               bsr       setdrv
                    bcs       l032f
                    ldd       DskOfst-tl,u
                    pshs      a
                    lda       DskOfst+2-tl,u
                    beq       l02e8
                    lda       DrivMsk-tl,u
                    ora       #$40
                    sta       DrivMsk-tl,u
l02e8               lda       PD.TYP,y
                    bita      #2
                    bne       l02f0
                    incb
l02f0               stb       RG.Sect
                    ldx       PD.DTB,y
                    ldb       DD.BT,x
                    lda       DD.FMT,x
                    lsra
                    eora      PD.DNS,y
                    anda      #2
                    pshs      a
                    lda       1,s
                    tst       ,s+
                    beq       l030c
                    asla
                    aslb
l030c               stb       RG.Trk
                    tst       ChgFlg-tl,u
                    bne       seek
                    ldb       ,s
                    cmpb      DD.BT,x
                    beq       l0326
seek                sta       RG.Data
                    ldb       PD.STP,y
                    andb      #3
                    eorb      #$1b
                    bsr       l0330
l0326               puls      a
                    sta       DD.BT,x
                    sta       RG.Trk
                    clrb
l032f               rts

l0330               lda       #4
                    lbsr      sendcmd
                    lda       RG.Stat
                    clr       RW.Ctrl
                    rts

tdelay              clr       18,u
                    inc       18,u
l0342               rol       18,u
                    bpl       l0342
                    rts

* Restore to LSN0
ssrset              pshs      b,x
                    lbsr      setdrv
                    bcs       l0370
                    ldx       PD.DTB,y
                    clr       DD.BT,x
                    lda       #4
stepIN              ldb       PD.STP,y
                    andb      #3
                    eorb      #$4b                Step In
                    pshs      a
                    bsr       l0330
                    puls      a
                    deca
                    bne       stepIN
                    ldb       PD.STP,y
                    andb      #3
                    eorb      #$0b                Restore
                    bsr       l0330
l0370               puls      b,x,pc

*********************
* PUTSTA   U= Device Static Mem  Y= Path Descr
*          A= Status Call

PUTSTA              leau      LstDrv,u
                    ldx       PD.RGS,y
                    ldb       R$B,x               SS.xx call
                    cmpb      #SS.WTrk
                    beq       wtrak
                    cmpb      #SS.Reset
                    beq       ssrset
                    comb
                    ldb       #E$UnkSvc
                    rts

* SS.WTRK call
wtrak               pshs      y,u
* request buffer memory
                    ldd       #$1a00
                    os9       F$SRqMem
                    bcs       ret080
                    ldx       2,s
                    stu       WtrkBuf-tl,x
                    ldx       D.Proc
                    lda       P$Task,x
                    ldb       D.SysTsk
                    ldy       ,s
                    ldx       PD.RGS,y
                    ldx       R$X,x
                    ldy       #$1a00
                    os9       F$Move
                    bcs       l03d3
                    puls      y,u
                    pshs      y,u
                    lbsr      setdrv
                    bcs       l03d3
                    ldx       PD.RGS,y
                    ldb       R$Y+1,x
                    bitb      #1
                    beq       l03c4
                    lda       DrivMsk-tl,u
                    ora       #$40
                    sta       DrivMsk-tl,u
                    sta       DskOfst+2-tl,u
l03c4               lda       R$U+1,x
                    ldx       PD.DTB,y
                    lbsr      l02cf
                    bcs       l03d3
                    ldx       WtrkBuf-tl,u
                    bsr       l03e4
l03d3               ldu       2,s                 Original U (Static storage)
                    pshs      cc,b
                    ldu       WtrkBuf-tl,u        Return WTrk buffer
                    ldd       #$1a00              ... to sys
                    os9       F$SRtMem
                    puls      cc,b
ret080              puls      y,u,pc

l03e4               pshs      cc,y
                    orcc      #IntMasks
                    ldb       #$f0
                    stb       RG.Stat
                    ldy       #$ffff
                    ldb       #$28
                    orb       DrivMsk-tl,u
                    stb       RG.Ctrl
                    orb       #$a8
                    lda       #2
                    lbsr      tdelay
l03ff               bita      RG.Stat
                    bne       sctwrt
                    leay      -1,y
                    bne       l03ff
                    lda       DrivMsk-tl,u
                    ora       #8
                    sta       RG.Ctrl
                    lda       #ForcInt
                    sta       RG.Stat
                    puls      cc,y
                    comb
                    ldb       #E$Write
                    rts
* NMI-type Block mode write
sctwrt              lda       ,x+
                    sta       RG.Data
                    stb       RG.Ctrl
                    bra       sctwrt              Loop till sector written

* Pause and timeout routines
l0424               pshs      a,b
                    ldd       D.Proc
                    cmpd      D.SysPrc
                    puls      a,b
                    beq       wait
                    os9       F$Sleep
                    rts
wait                ldx       #$a000
wait1               nop
                    nop
                    nop
                    leax      -1,x
                    bne       wait1
                    rts

mtron               pshs      a,b,x,y
                    ldd       #$00f0              Reset Drive timeout
                    std       VIRQPak-tl,u
                    lda       DrivMsk-tl,u
                    ora       #8                  Motor-on
                    sta       RG.Ctrl
                    ldx       #$0028
                    lda       D.MotOn             Result of last motoron attempt
                    bmi       svirq               If error previously
                    beq       l0469
                    tst       ChgFlg-tl,u         Different drive from last?
                    beq       ret090              No, no need to wait
                    lda       PD.TYP,y
                    bita      #$10                All motors not turned on?
                    beq       ret090              Yes, skip
                    bsr       l0424
                    ldd       #$00f0
                    std       VIRQPak-tl,u
                    bra       ret090

l0469               bsr       l0424
svirq               bsr       setVIRQ
ret090              clrb
                    puls      a,b,x,y,pc
setVIRQ             lda       #1
                    sta       D.MotOn
                    ldx       #1
                    leay      VIRQPak-tl,u
                    clr       Vi.Stat,y
                    ldd       #$00f0
                    os9       F$VIRQ
                    bcc       ret100
                    lda       #$80
                    sta       D.MotOn
ret100              clra
                    rts

*      IRQ service routine.  CC3Disk comes here on NMI
IRQSvc              pshs      a
                    lda       V.WAKE-tl,u
                    beq       l049f
                    ldb       #$0c
                    stb       RW.Ctrl
                    lda       #$d8
                    sta       RG.Stat
                    clr       d00ab-tl,u
                    bra       l04a3

l049f               lda       D.DMAReq
                    beq       l04a7
l04a3               bsr       setVIRQ
                    bra       ret110

l04a7               sta       RG.Ctrl
                    clr       VIRQPak+Vi.Stat-tl,u
                    clr       D.MotOn
ret110              puls      a,pc

t0set               ldx       PD.DTB,y
                    ldb       #$14
t0set1              clr       b,x
                    decb
                    bpl       t0set1
                    ldb       PD.CYL+1,y
                    lda       PD.SID,y
                    mul
                    subd      #1
                    lda       PD.SCT+1,y
                    sta       DD.TKS,x
                    sta       DD.SPT+1,x
                    mul
                    addd      PD.T0S,y
                    std       DD.TOT+1,x
                    lda       #7
                    sta       DD.ATT,x
                    lda       PD.DNS,y
                    asla
                    pshs      a
                    lda       PD.SID,y
                    deca
                    ora       ,s+
                    sta       DD.FMT,x
                    clrb
                    rts

                    emod

dlen                equ       *

                    end
