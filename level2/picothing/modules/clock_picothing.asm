********************************************************************
* clock_picothing - Clock module for Pico-Thing Level 2
*
* Uses the virtual MC6840 PTM at $FFC8-$FFCF (provided by Pico).
*
* The MC6840 timer 1 generates periodic IRQs for OS timeslicing.
*
* Important: the Pico firmware must route the MC6840 interrupt to
* the 6809 IRQ line (not FIRQ). NitrOS-9's timeslicing infrastructure
* is built around IRQ; FIRQ cannot drive the scheduler without
* significant kernel modifications.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*     1    2025       Initial version for Pico-Thing

                    nam       clock_picothing
                    ttl       Clock for Pico-Thing Level 2

TkPerTS             equ       2         ticks per time slice

                  IFP1
                    use       defsfile
                    use       cocovtio.d
                  ENDC

Edtn                equ       1
Vrsn                equ       0

*------------------------------------------------------------
*
* Start of module
*
                    mod       len,name,Systm+Objct,ReEnt+Vrsn,Init,0

name                fcs       "Clock"
                    fcb       Edtn

*
* Table to set up Service Calls
*
NewSvc              fcb       F$Time
                    fdb       F.Time-*-2
                    fcb       F$VIRQ
                    fdb       F.VIRQ-*-2
                    fcb       F$Alarm
                    fdb       F.ALARM-*-2
                    fcb       F$STime
                    fdb       F.STime-*-2
                    fcb       $80       end of service call table

*------------------------------------------------------------
*
* IRQ handler entry point
*
* Called by the kernel on every IRQ. We check whether the MC6840
* fired and route to either SvcVIRQ (clock tick) or DoPoll (other IRQ).
*
SvcIRQ
                    ldx       #PTMBase  point to MC6840
                    lda       PTM.CR,x  read status register
                    bita      #PTM.IRQFlag did MC6840 fire?
                    beq       NoClock   no, handle as generic IRQ

                    sta       PTM.CR,x  write back to acknowledge interrupt
                    ldx       <D.VIRQ   set VIRQ routine to be executed
                    clr       <D.QIRQ   flag as clock IRQ
                    bra       ContIRQ

NoClock             leax      DoPoll,pcr not clock IRQ, poll other sources
                    lda       #$FF
                    sta       <D.QIRQ   flag as non-clock IRQ
ContIRQ             stx       <D.SvcIRQ
                    jmp       [D.XIRQ]  chain to kernel timeslice handler

*------------------------------------------------------------
*
* IRQ handling re-enters here on clock tick.
*
* Counts down VIRQ timers, updates system time, checks alarm.
*
SvcVIRQ             clra                flag for VIRQ pending
                    pshs      a
                    ldy       <D.CLTb   get address of VIRQ table
                    bra       virqent

virqloop            equ       *
                    ldd       Vi.Cnt,x  decrement tick count
                    subd      #$0001
                    bne       notzero   is this one done?
                    lda       Vi.Stat,x should we reset?
                    bmi       doreset
                    lbsr      DelVIRQ   no, delete this entry
doreset             ora       #$01      mark VIRQ as triggered
                    sta       Vi.Stat,x
                    lda       #$80      add as interrupt source
                    sta       ,s
                    ldd       Vi.Rst,x  reset from reset count
notzero             std       Vi.Cnt,x
virqent             ldx       ,y++
                    bne       virqloop

                    puls      a         get VIRQ status
* Pico-Thing has no GIME — D.IRQS is never set by hardware.
* Always call DoPoll so that device IRQs (ACIA etc.) get serviced
* on every clock tick.
                    bsr       DoPoll    poll all registered devices

KbdCheck            jsr       [>D.AltIRQ] update keyboard/mouse/etc.

                    dec       <D.Tick   end of second?
                    bne       VIRQend   no, skip time update
                    lda       #TkPerSec reset tick count
                    sta       <D.Tick

                    inc       <D.Sec    increment second
                    lda       <D.Sec
                    cmpa      #60       end of minute?
                    blo       VIRQend   no, skip minute update
                    clr       <D.Sec    reset seconds

                    ldx       <D.Clock2 call Clock2 GetTime
                    jsr       $03,x

NoGet               ldd       >WGlobal+G.AlPID
                    ble       VIRQend   no alarm set
                    ldd       >WGlobal+G.AlPckt+3
                    cmpd      <D.Hour
                    bne       VIRQend
                    ldd       >WGlobal+G.AlPckt+1
                    cmpd      <D.Month
                    bne       VIRQend
                    ldb       >WGlobal+G.AlPckt+0
                    cmpb      <D.Year
                    bne       VIRQend
                    ldd       >WGlobal+G.AlPID
                    cmpd      #1
                    beq       checkbel
                    os9       F$Send
                    bra       endalarm
checkbel            ldb       <D.Sec
                    andb      #$F0
                    beq       dobell
endalarm            ldd       #$FFFF
                    std       >WGlobal+G.AlPID
                    bra       VIRQend
dobell              ldx       >WGlobal+G.BelVec
                    beq       VIRQend
                    jsr       ,x
VIRQend             jmp       [>D.Clock] jump to kernel timeslice routine

*------------------------------------------------------------
*
* Poll interrupt sources
*
DoPoll              pshs      b         save B
                    clrb                clear "serviced" flag
DoPollLp            jsr       [>D.Poll] call poll routine
                    bcs       DoPollDn  no device found, done polling
                    incb                at least one device was serviced
                    bra       DoPollLp  check for more
DoPollDn            tstb                any device serviced?
                    puls      b,pc      return; carry clear if serviced

*
* No hardware toggle needed (no GIME on Pico-Thing)
*
DoToggle            rts

*------------------------------------------------------------
*
* Handle F$VIRQ system call
*
F.VIRQ              pshs      cc
                    orcc      #IntMasks disable interrupts
                    ldy       <D.CLTb   address of VIRQ table
                    ldx       <D.Init   address of INIT
                    ldb       PollCnt,x number of polling table entries
                    ldx       R$X,u     zero means delete entry
                    beq       RemVIRQ
FindVIRQ            ldx       ,y++      is VIRQ entry null?
                    beq       AddVIRQ   if yes, add here
                    decb
                    bne       FindVIRQ
                    puls      cc
                    comb
                    ldb       #E$Poll
                    rts

AddVIRQ             leay      -2,y      point to first null VIRQ entry
                    ldx       R$Y,u
                    stx       ,y
                    ldy       R$D,u
                    sty       ,x
                    bra       virqexit

RemVIRQ             ldx       ,y++
                    beq       virqexit
                    cmpx      R$Y,u
                    bne       RemVIRQ
                    bsr       DelVIRQ
virqexit            puls      cc
                    clrb
                    rts

DelVIRQ             pshs      x,y
DelVLup             ldx       ,y++
                    stx       -4,y
                    bne       DelVLup
                    puls      x,y
                    leay      -2,y
                    rts

*------------------------------------------------------------
*
* Handle F$Alarm call
*
F.ALARM             ldx       #WGlobal+G.AlPckt
                    ldd       R$D,u
                    bne       DoAlarm
                    std       G.AlPID-G.AlPckt,x
                    rts

DoAlarm             tsta
                    bne       SetAlarm
                    cmpd      #1
                    bne       GetAlarm
SetAlarm            std       G.AlPID-G.AlPckt,x
                    ldy       <D.Proc
                    lda       P$Task,y
                    ldb       <D.SysTsk
                    ldx       R$X,u
                    ldu       #WGlobal+G.AlPckt
                    ldy       #5
                    bra       FMove

GetAlarm            cmpd      #2
                    bne       AlarmErr
                    ldd       G.AlPID-G.AlPckt,x
                    std       R$D,u
                    bra       RetTime
AlarmErr            comb
                    ldb       #E$IllArg
                    rts

*------------------------------------------------------------
*
* Handle F$Time system call
*
F.Time              equ       *
                    ldx       #D.Time
RetTime             ldy       <D.Proc
                    ldb       P$Task,y
                    lda       <D.SysTsk
                    ldu       R$X,u
STime.Mv            ldy       #6
FMove               os9       F$Move
                    rts

*------------------------------------------------------------
*
* Handle F$STime system call
*
F.STime             equ       *
                    ldx       <D.Proc
                    lda       P$Task,x
                    ldx       R$X,u
                    ldu       #D.Time
                    ldb       <D.SysTsk
                    bsr       STime.Mv
                    lda       #TkPerSec
                    sta       <D.Tick

                    ldx       <D.Clock2 call Clock2 SetTime
                    jsr       $06,x

NoSet               rts

Clock2              fcs       "Clock2"

*------------------------------------------------------------
*
* Clock Initialization
*
* Called by the kernel to service the first F$STime call.
* Initializes the MC6840 PTM and installs IRQ handler.
*
Init                ldx       <D.Proc   save user proc
                    pshs      x
                    ldx       <D.SysPrc make sys for link
                    stx       <D.Proc

                    leax      <Clock2,pcr
                    lda       #Sbrtn+Objct
                    os9       F$Link

                    puls      x
                    stx       <D.Proc   restore user proc

                    bcc       LinkOk
                    lda       #E$MNF
                    jmp       <D.Crash
LinkOk              sty       <D.Clock2 save Clock2 entry point

                    clra
                    pshs      cc        save IRQ enable status
                    orcc      #IntMasks disable interrupts

* Initialize MC6840 PTM:
* - Reset the chip (write any value to CR with reset bit set)
* - Configure timer 1 for continuous mode, internal clock, interrupt enable
* - Load timer 1 with count value for desired tick rate
*
* Timer tick rate = input_clock / (count + 1)
* For 50Hz ticks with a 1MHz clock: count = 1000000/50 - 1 = 19999 = $4E1F
* For 60Hz ticks with a 1MHz clock: count = 1000000/60 - 1 = 16665 = $4119
* Update TkPerSec, PTClkCnt values to match your clock frequency.
*
                    ldx       #PTMBase  point to MC6840

                    lda       #$01      reset MC6840 (bit 0 of CR2 = reset)
                    sta       PTM.CR2,x

                    lda       #$00      clear reset bit
                    sta       PTM.CR2,x

                    lda       #$C3      timer 1: continuous, internal clock, 16-bit
                    sta       PTM.CR1,x write CR1

                  IFEQ    TkPerSec-50
                    ldd       #$4E1F    19999 = 50Hz with 1MHz clock
                  ELSE
                    ldd       #$4119    16665 = 60Hz with 1MHz clock
                  ENDC
                    sta       PTM.T1MSB,x write MSB first
                    stb       PTM.T1MSB+1,x write LSB (note: virtual 6840 may differ)

                    lda       #$C3      enable interrupt, start timer 1
                    sta       PTM.CR1,x

                    ldd       #59*256+TkPerTS trigger RTC read soon
                    std       <D.Sec    will prompt Clock2 read at next timeslice

                    stb       <D.TSlice set ticks per time slice
                    stb       <D.Slice  set first time slice
                    leax      SvcIRQ,pcr install IRQ handler
                    stx       <D.IRQ
                    leax      SvcVIRQ,pcr install VIRQ handler
                    stx       <D.VIRQ
                    leay      NewSvc,pcr insert service calls
                    os9       F$SSvc

                    ldy       <D.Clock2 call Clock2 init
                    jsr       ,y
                    puls      cc,pc     restore IRQ status and return

                    emod
len                 equ       *
                    end
