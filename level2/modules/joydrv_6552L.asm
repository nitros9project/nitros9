*********************************************************************
* JoyDrv - Joystick Driver for 6552/Logitech Mouse
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   6      1988/??/??
* L2 Upgrade distribution version.

                    nam       JoyDrv
                    ttl       Joystick Driver for 6552/Logitech Mouse

* Disassembled 98/09/09 09:22:44 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    use       l52.defs
                    endc

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       6

MPISlot             set       $00

                    mod       eom,name,tylg,atrv,start,$FF64

name                fcs       /JoyDrv/
                    fcb       edition

start               lbra      Init
                    lbra      Term
                    lbra      SSMsBtn
                    lbra      SSMsXY
                    lbra      SSJoyBtn

SlotSlct            fcb       MPISlot

SSJoyXY             pshs      x,b,a
                    ldx       #PIA0Base
                    lda       <$23,x
                    ldb       <$20,x
                    pshs      b,a
                    anda      #$F7
                    sta       <$23,x
                    lda       $01,x
                    ldb       $03,x
                    pshs      b,a
                    andb      #$F7
                    lsr       $04,s
                    bcs       L0043
                    orb       #$08
L0043               stb       $03,x
                    lda       ,s
                    ora       #$08
                    bsr       L0065
                    std       $06,s
                    lda       ,s
                    anda      #$F7
                    bsr       L0065
                    std       $04,s
                    puls      b,a
                    sta       $01,x
                    stb       $03,x
                    puls      b,a
                    stb       <$20,x
                    sta       <$23,x
                    puls      pc,y,x
L0065               sta       $01,x
                    lda       #$7F
                    ldb       #$40
                    bra       L0078
L006D               lsrb
                    cmpb      #$01
                    bhi       L0078
                    lsra
                    lsra
                    tfr       a,b
                    clra
                    rts
L0078               pshs      b
                    sta       <$20,x
                    tst       ,x
                    bpl       L0085
                    adda      ,s+
                    bra       L006D
L0085               suba      ,s+
                    bra       L006D

IRQPckt             equ       *
Pkt.Flip            fcb       $00                 D.Poll flip byte
Pkt.Mask            fcb       $07                 D.Poll mask byte
                    fcb       $01                 priority

Init                clra
                    clrb
                    sta       Btn.Cntr,u          set up Rx data sync, no button(s) pressed
                    std       CrntXPos,u          set up X position at left screen edge
                    ldd       #HResMaxY*2
                    std       CrntYPos,u          set up Y position at top screen edge
                    ldd       M$Mem,pcr           get base hardware address
                    leax      IRQPckt,pcr
                    leay      IRQSvc,pcr
                    os9       F$IRQ
                    bcs       InitExit            go report error...
                    tfr       d,x
                    ldd       #$46E0
                    pshs      cc
                    orcc      #IntMasks           disable IRQs while setting up hardware
                    sta       1,x                 reset 6552
                    stb       1,x                 reset 6552
                    clr       2,x
                    lda       >PIA1Base+3         get PIA CART* input control register
                    anda      #$FC                clear PIA CART* control bits
                    sta       >PIA1Base+3         disable PIA CART* FIRQs
                    lda       >PIA1Base+2         clear possible pending PIA CART* FIRQ
                    ldd       #$0187              GIME CART* IRQ enable
                    ora       <D.IRQER            mask in current GIME IRQ enables
                    sta       <D.IRQER            save GIME CART* IRQ enable shadow register
                    sta       >IrqEnR             enable GIME CART* IRQs
                    stb       ,x
                    ldb       3,x                 *ensure old error,
                    ldb       ,x                  *Rx data, and
                    ldb       3,x                 *IRQ flags
                    ldb       ,x                  *are clear
                    andb      Pkt.Mask,pcr        IRQ bits still set?
                    bne       InitErr             yes, go disable ACIA and return...
                    lda       SlotSlct,pcr        get MPI slot select value
                    bmi       InitExit            no MPI slot select, go exit...
                    sta       >MPI.Slct           set MPI slot select register
                    puls      pc,cc               recover original regs, return...

Term                pshs      cc                  save regs we alter
                    orcc      #IntMasks           mask IRQs while disabling ACIA
InitErr             ldx       M$Mem,pcr           get base address
                    lda       #$7F                *disable all
                    sta       ,x                  *ACIA IRQs
                    puls      cc
                    tfr       x,d                 copy status register address
                    ldx       #$0000              remove IRQ table entry
                    leay      IRQSvc,pcr
                    os9       F$IRQ
InitExit            rts

SSJoyBtn            ldb       #$FF
                    ldx       #PIA0Base
                    stb       $02,x
                    ldb       ,x
                    comb
                    andb      #$0F
                    rts

SSMsBtn             pshs      cc
                    orcc      #IntMasks
                    lda       ,u
                    tfr       a,b
                    andb      #$C0
                    bne       L0120
                    bita      #$20
                    beq       L011A
                    orb       #$03
L011A               bita      #$10
                    beq       L0120
                    orb       #$0C
L0120               anda      #$3F
                    sta       ,u
                    puls      pc,cc

SSMsXY              ldd       #$017E
                    pshs      cc
                    orcc      #IntMasks
                    ldx       CrntXPos,u
                    subd      CrntYPos,u
                    lsra
                    rorb
                    tfr       d,y
                    puls      pc,cc

***
* Mouse IRQ service routine.
*
* INPUT:  A = flipped and masked device status byte
*         U = mouse data area address
*
* OUTPUT:  updated serial mouse data
*          CC Carry clear
*          D, X, Y, and U registers may be altered
*
* ERROR OUTPUT:  none
IRQSvc              ldx       M$Mem,pcr
                    bita      #$06                any error(s)?
                    beq       ChkRDRF             no, go check Rx data
                    ldb       3,x                 read Rx data register to clear error flags
ClrRxCnt            lda       Btn.Cntr,u          get current button status and Rx data counter
                    anda      #^BC.RxCnt          clear Rx data counter
ButnExit            sta       Btn.Cntr,u          reset Rx mouse data counter to wait for sync...
IRQExit             clrb                          clear Carry to mark IRQ serviced
                    rts

ChkRDRF             bita      #$01                Rx data?
                    beq       IRQExit             no, but this branch should never be taken...
                    ldb       3,x                 get Rx data
                    lda       Btn.Cntr,u          get button status and Rx counter
                    anda      #BC.RxCnt           waiting for sync with mouse data?
                    bne       ChkOfst             no, go check Rx offset...
                    tfr       b,a                 copy Rx data
                    anda      #SyncMask           clear button status bits
                    cmpa      #SyncData           is it *PROBABLY* the initial (sync) byte?
                    bne       IRQExit             no, just ignore it...
                    comb                          invert button bits to match SS.Mouse format
                    lslb                          *move button
                    lslb                          *status into
                    lslb                          *bits 5-3
                    andb      #BC.Butns           clear everything but the button bits
                    incb                          set Rx counter to first XY position byte
                    pshs      b
                    lda       ,u
                    bita      #$08
                    beq       L017A
                    bitb      #$08
                    bne       L017A
                    lda       #$C0
                    ldx       CrntXPos,u
                    cmpx      #$0140
                    bcs       L017A
                    lsla
L017A               anda      #$C0
                    ora       ,s+
                    bra       ButnExit            go save new button status and Rx counter, exit...
ChkOfst             cmpa      #PcktSize-1         last byte in mouse packet?
                    bcs       SaveData            no, go save mouse data to Rx buffer...
                    ldx       #HResMaxY*2         get maximum Y position
                    pshs      x                   save it for CalcPos subroutine
                    leax      CrntYPos,u          point to current Y position
                    leay      Buffer+1,u          point to primary Y offset
                    bsr       CalcPos             go calculate & save mouse's new Y position
                    ldb       Buffer+2,u          get mouse packet's secondary X offset
                    ldx       #HResMaxX           get maximum X position
                    stx       ,s                  save it for CalcPos subroutine
                    leax      CrntXPos,u          point to current X position
                    leay      Buffer+0,u          point to primary X offset
                    bsr       CalcPos             go calculate & save mouse's new X position
                    leas      2,s                 clean up stack
                    bra       ClrRxCnt            go save button status and clear Rx counter, exit...
SaveData            stb       a,u                 save XY position byte to mouse data Rx buffer
                    inc       Btn.Cntr,u          point to next byte in Rx buffer
                    clrb                          clear Carry to mark IRQ serviced
                    rts

CalcPos             sex                           sign extend mouse packet's 2nd XY offset ([D] = -128 to +127)
                    pshs      d                   save it temporarily...
                    ldb       ,y                  get mouse packet's 1st XY offset
                    sex                           sign extend it ([D] = -128 to +127)
                    addd      ,s                  add mouse's 2nd XY offset
                    std       ,s                  save XY offset total temporarily...
                    bpl       PosAdjst            go de-sensitize positive "ballistic" XY offset...
                    orb       #%00000111          if -8<XYoffset<0, no "ballistic" response
                    addd      #1                  "fix" negative offset "ballistic" response
                    bra       RShiftD             go calculate "ballistic" offset...
PosAdjst            andb      #%11111000          if 0<XYoffset<8, no "ballistic" response
RShiftD             asra                          *calculate 50% of XY offset
                    rorb                          *for "ballistic" response
                    addd      ,s++                add original XY offset total, clean up stack
                    addd      ,x                  add mouse's current XY position
                    bpl       CheckPos            zero or positive XY position, go check it...
                    clra                          *set minimum
                    clrb                          *XY position
CheckPos            cmpd      2,s                 past maximum XY position?
                    bls       SavePos             no, go save it...
                    ldd       2,s                 get maximum XY position
SavePos             std       ,x                  save new XY position
                    rts

                    emod
eom                 equ       *
                    end
