********************************************************************
* JoyDrv - Joystick Driver for 6551/Microsoft Mouse
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   6      1988/??/??
* L2 Upgrade distribution version.

                    nam       JoyDrv
                    ttl       Joystick Driver for 6551/Microsoft Mouse

* Disassembled 98/09/09 09:50:25 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    use       m51.defs
                    endc

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       6

MPISlot             set       $00

                    mod       eom,name,tylg,atrv,start,$FF68

name                fcs       /JoyDrv/
                    fcb       edition

SlotSlct            fcb       MPISlot

start               lbra      Init
                    lbra      Term
                    lbra      SSMsBtn
                    lbra      SSMsXY
                    lbra      SSJoyBtn

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
Pkt.Flip            fcb       Stat.Flp            D.Poll filp byte
Pkt.Mask            fcb       Stat.Msk            D.Poll mask byte
                    fcb       $01                 priority
*L0089    fcb   $00
*L008A    fcb   $0f,$01

***
* JoyDrv Initialization.
*
* INPUT:  U = JoyDrv data area address (8 bytes)
*
* OUTPUT:  IRQ service entry installed
*          D, X, and U registers may be altered
*
* ERROR OUTPUT:  CC = Carry set
*                B = error code
Init                ldd       #$0007
L008F               sta       b,u
                    decb
                    bpl       L008F
                    ldd       >M$Mem,pcr          get base hardware address
                    addd      #StatReg            status register address
                    leax      IRQPckt,pcr
                    leay      IRQSvc,pcr
                    os9       F$IRQ
                    bcs       TermExit            go report error...
                    ldx       >M$Mem,pcr          get base hardware address again
                    ldd       #(TIC.RTS!Cmd.DTR)*256+(DB.8!Ctl.RClk!BR.01200) [D]=command:control
                    pshs      cc
                    orcc      #IntMasks           disable IRQs while setting up hardware
                    sta       PRstReg,x           reset 6551
                    std       CmdReg,x            set command and control registers
                    lda       >PIA1Base+3         get PIA CART* input control register
                    anda      #$FC                clear PIA CART* control bits
                    sta       >PIA1Base+3         disable PIA CART* control bits
                    lda       >PIA1Base+2         clear possible pending PIA CART* FIRQ
                    lda       #$01                GIME CART* IRQ enable
                    ora       <D.IRQER            mask in current GIME IRQ enables
                    sta       <D.IRQER            save GIME CART* IRQ enable shadow register
                    sta       >IrqEnR             enable GIME CART* IRQs
                    ldb       DataReg,x           ensure old error,
                    ldb       StatReg,x           Rx data, and
                    ldb       DataReg,x           IRQ flags
                    ldb       StatReg,x           are clear
                    andb      Pkt.Mask,pcr        IRQ bits still set?
                    bne       InitErr             yes, go disable ACIA and return...
                    lda       SlotSlct,pcr        get MPI slot select value
                    bmi       InitExit            no MPI slot select, go exit...
                    sta       >MPI.Slct           recover original regs, return...
InitExit            puls      pc,cc

***
* JoyDrv Termination.
*
* INPUT:  U = JoyDrv data area address (8 bytes)
*
* OUTPUT:  IRQ service entry removed
*          D, X, and U registers may be altered
*
* ERROR OUTPUT:  CC = Carry set
*                B = error code
Term                pshs      cc                  save regs we alter
                    orcc      #IntMasks           mask IRQs while disabling ACIA
InitErr             ldx       M$Mem,pcr           get base address
                    lda       #TIC.RTS!Cmd.RxIE!Cmd.DTR disable all
                    sta       CmdReg,x            ACIA IRQs
                    puls      cc
                    leax      StatReg,x           point to status register
                    tfr       x,d                 copy status register address
                    ldx       #$0000              remove IRQ table entry
                    leay      IRQSvc,pcr
                    os9       F$IRQ
TermExit            rts

***
* Joystick button(s) status check.
*
* INPUT:  U = JoyDrv data area address (8 bytes)
*
* OUTPUT:  B = button or "clear" status
*              button(s)     = xxxxLRLR
*          A, X, and U registers may be altered
*
* ERROR OUTPUT:  none
SSJoyBtn            ldb       #$FF
                    ldx       #PIA0Base
                    stb       $02,x
                    ldb       ,x
                    comb
                    andb      #$0F
                    rts

***
* Mouse button(s) status check.
*
* INPUT:  U = JoyDrv data area address (8 bytes)
*
* OUTPUT:  B = button or "clear" status
*              button(s)     = xxxxLRLR
*              clear         = 10000000
*              shift-clear   = 11000000
*          A, X, and U registers may be altered
*
* ERROR OUTPUT:  none
SSMsBtn             lda       ,u                  get byte at ,U
                    clrb                          clear B
                    bita      #$20                A %00100000 bit clear?
                    beq       L010E               branch if so
                    orb       #$03                else set OR B with %00000011
L010E               bita      #$10                A %00010000 bit clear?
                    beq       L0114               branch if so
                    orb       #$0C                else set OR B with %11000000
L0114               tfr       b,a                 move B to A
                    anda      #$FA                AND A with %11111010
                    pshs      a                   save A
                    andb      #$05                AND B with %00000101
                    orb       7,u                 OR B with ????
                    leax      <L0134,pcr
                    lda       b,x
                    anda      #$0A
                    sta       7,u
                    ldb       b,x
                    andb      #$85
                    bpl       L0131
                    ldb       2,u
                    andb      #$C0
L0131               orb       ,s+
                    rts
L0134               fdb       $0003,$0003,$0806,$0206,$8002,$0002,$0806,$0a06

***
* Joystick/Mouse XY coordinate read.
*
* INPUT:  A = side flag (1 = right, 2 = left)
*         Y = resolution (0 = low, 1 = high)
*         U = JoyDrv data area address (8 bytes)
*
* OUTPUT:  X = horizontal coordinate (left edge = 0)
*              low resolution = 0 to 63
*              high resolution = 0 to HResMaxX
*          Y = vertical coordinate (top edge = 0)
*              low resolution = 0 to 63
*              high resolution = 0 to HResMaxY
*          D and U registers may be altered
*
* ERROR OUTPUT:  none
SSMsXY              pshs      cc
                    orcc      #IntMasks
                    ldx       3,u
                    ldd       5,u
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
                    bita      #Stat.Err           any error(s)?
                    beq       ChkRDRF             no, go check Rx data
                    ldb       DataReg,x           read Rx data register to clear error flags
L015C               lda       2,u                 get current button and Rx data counter
                    anda      #^%00000111         clear Rx data counter
L0160               sta       2,u                 reset Rx mouse data counter to wait for sync...
IRQExit             clrb                          clear carry to mark IRQ serviced
                    rts

ChkRDRF             bita      #Stat.RxF           Rx data?
                    beq       IRQExit             no, but this branch should never be taken...
                    ldb       DataReg,x           get Rx data
                    lda       2,u                 get button status and Rx counter
                    anda      #%00000111          waiting for sync with mouse data?
                    bne       L017A               branch if counter is not zero
                    bitb      #$40                OR Rx data with $40
                    beq       IRQExit             exit if 0
L0174               stb       a,u                 else save B at a,u
                    inc       2,u                 and increment counter
                    clrb
                    rts
L017A               bitb      #$40                OR Rx data with $40
                    bne       L015C               if set, reset data counter
                    cmpa      #$02                is this third byte?
                    bcs       L0174               branch if less than
                    ldx       #HResMaxY*2
                    pshs      x                   save on stack
                    lda       ,u                  get first byte of mouse packet
                    lsra                          shift right
                    lsra                          and again
                    leax      5,u                 point to X to CrntYPos,u
                    bsr       L01A9               process
                    ldd       ,u                  get first and second byte of mouse packet
                    ldx       #HResMaxX           get max X value
                    stx       ,s                  save on stack in place of earlier X
                    leax      3,u                 point X to CrntXPos,u
                    bsr       L01A9               process
                    leas      $02,s               restore stack
                    lda       #$80
                    ldx       3,u                 get CrntXPos,u
                    cmpx      #320
                    bcc       L0160               branch if equal
                    ora       #192
                    bra       L0160
L01A9               lslb
                    lslb
                    lsra
                    rorb
                    lsra
                    rorb
                    sex                           sign extend mouse packet's 2nd XY offset ([D] = -128 to +127)
                    pshs      d                   save it temporarily...
                    bpl       PosAdjst            go de-sensitize positive "ballistic" XY offset
                    orb       #%00000111          if -8<XYoffset<0, no "ballistic" response
                    addd      #$0001              "fix" negative offset "ballistic" response
                    bra       RShiftD             go calculate "ballistic" offset
PosAdjst            andb      #%11111000          if 0<XYoffset<8, no "ballistic" response
RShiftD             asra                          calculate 50% of XY offset
                    rorb                          for "ballistic" response.
                    addd      ,s++                add original XY offset total, clean up stack
                    addd      ,x                  add mouse's current XY position
                    bpl       CheckPos            zero or positive XY position, go check it...
                    clra                          set minimum XY position
                    clrb
CheckPos            cmpd      2,s                 past maximum XY position?
                    bls       SavePos             no, go save it...
                    ldd       $02,s               get maximum XY position
SavePos             std       ,x                  save new XY position
                    rts

                    emod
eom                 equ       *
                    end
