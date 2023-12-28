********************************************************************
* Clock - NitrOS-9 System Clock
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          2015/09/09  Neal Crook
* Created from clock.asm version 9r8. This version for 50Hz timer on
* multicomp09.


* [NAC HACK 2015Sep09] Inherited behaviour: this just stomps into
* D.IRQ so I assume that nothing could have been there before (ie
* because it's the "owner" of this vector). If there is an interrupt
* that is NOT a timer interrupt we jump through D.SvcIRQ, which is
* the list of other devices that might want to claim the interrupt.
* At the end of the timer interrupt service routine (ISR) we don't
* jump through D.SvcIRQ. The assumption is that there is only one
* interruptor. If that assumption tests false, the interrupt will
* still be asserted and we'll come straight back into this ISR.
* The timer ISR checks something and considers dispatching through
* AltIRQ. What's that all about?


                    nam       Clock
                    ttl       NitrOS-9 System Clock

                    use       defsfile

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       8
edition             set       9

*------------------------------------------------------------
* For a detailed hardware description of the Multicomp09
* timer, refer to mc09.d
*

*------------------------------------------------------------
*
* Start of module
*
                    mod       len,name,tylg,atrv,init,0

name                fcs       "Clock"
                    fcb       edition


TkPerTS             equ       TkPerSec/10         ticks per time slice

*
* Table to set up Service Calls
*
NewSvc              fcb       F$Time
                    fdb       FTime-*-2
                    fcb       F$VIRQ
                    fdb       FVIRQ-*-2
                    fcb       F$STime
                    fdb       FSTime-*-2
                    fcb       $80                 end of service call installation table


*------------------------------------------------------------
*
* Handle F$STime system call
*
* First, copy time packet from user address space to system time
* variables, then fall through to code to update RTC.
*
FSTime              equ       *
                    ldx       R$X,u
                    ldd       ,x
                    std       <D.Year
                    ldd       2,x
                    std       <D.Day
                    ldd       4,x
                    std       <D.Min
                    lda       #TkPerSec           reset to start of second
                    sta       <D.Tick
                    lbra      Clock2_SetTime

*--------------------------------------------------
*
* Clock Initialization
*
* This vector is called by the kernel to service the first F$STime
* call.  F$STime is usually called by SysGo (with a dummy argument)
* in order to initialize the clock.  F$STime is re-vectored to the
* service code above to handle future F$STime calls.
*
*

init
                    pshs      dp,cc               save DP and CC
                    clra
                    tfr       a,dp                set DP to zero
InitCont
* Do not need to explicitly read RTC during initialization
                    ldd       #59*256+$01         last second and last tick
                    std       <D.Sec              will prompt RTC read at next time slice
                    ldb       #TkPerSec
                    stb       <D.TSec             set ticks per second
                    ldb       #TkPerTS            get ticks per time slice
                    stb       <D.TSlice           set ticks per time slice
                    stb       <D.Slice            set first time slice

                    leax      SvcIRQ,pcr          set IRQ handler
                    stx       <D.IRQ

                    leay      NewSvc,pcr          insert syscalls
                    os9       F$SSvc

* Call Clock2 init routine

                    lbsr      Clock2_Init         call init entry point of Clock2

* Initialize clock hardware
                    lda       #2                  enable timer and its interrupt
                    sta       TIMER
                    rts


*
* Clock IRQ Entry Point
*
* For Multicomp09, called 50 times/s ie once every 20ms
SvcIRQ
                    clra
                    tfr       a,dp                set direct page to zero

* The increment sets N depending upon whether the timer interrupted
                    inc       TIMER
                    bmi       TimInt
                    jmp       [>D.SvcIRQ]         else service other possible IRQ
TimInt
                    dec       <D.Tick             decrement tick counter
                    bne       L007F               go around if not zero
                    ldb       <D.Sec              get minutes/seconds
* Seconds increment
                    incb                          increment seconds
                    cmpb      #60                 full minute?
                    bcs       L0079               nope...
*
* Call GetTime entry point in Clock2
*
                    lbsr      Clock_GetTime
                    fcb       $8C                 skip next 2 bytes
L0079               stb       <D.Sec              update sec
L007B               lda       <D.TSec             get ticks per second value
                    sta       <D.Tick             and repopulate tick decrement counter
L007F               clra                          clear A
                    pshs      a                   and save it on the stack
                    ldy       <D.CLTb             get pointer to VIRQ Polling Entries
                    bra       L009E               go to the processing portion of the loop
L0087               ldd       Vi.Cnt,x            get count down counter
                    subd      #$0001              subtract tick count
                    bne       L009C               branch if not at terminal count ($0000)
                    lda       #$01
                    sta       ,s                  set flag on stack to 1
                    lda       Vi.Stat,x           get status byte
                    beq       DelEntry            branch if zero (one shot, so delete)
L0096               ora       #Vi.IFlag           set interrupted flag
                    sta       Vi.Stat,x           save in packet
                    ldd       Vi.Rst,x            get reset count
L009C               std       Vi.Cnt,x            save tick count back
L009E               ldx       ,y++                get two bytes at Y
                    bne       L0087               if not zero, branch
                    lda       ,s+                 else get byte off stack
                    beq       GoAltIRQ            branch if zero
                    ldx       <D.Proc             else get pointer to current process descriptor
                    beq       L00AE               branch if none
                    tst       P$State,x           test process state
                    bpl       UsrPoll             branch if system state not set
L00AE               jsr       [>D.Poll]           poll ISRs
                    bcc       L00AE               keep polling until carry set
GoAltIRQ
                    jmp       [>D.AltIRQ]         jump into an alternate IRQ if available
DelEntry
                    bsr       DelVIRQ             delete the VIRQ entry
                    bra       L0096

UsrPoll             leay      >up@,pcr            point to routine to execute
                    jmp       [>D.URtoSs]         User to System
up@                 jsr       [>D.Poll]           call polling routine
                    bcc       up@                 keep polling until carry set
                    ldx       <D.Proc             get current process descriptor
                    ldb       P$State,x           and its state
                    andb      #^SysState          turn off sysstate bit
                    stb       P$State,x           save new state
                    ldd       <P$SWI2,x
                    std       <D.SWI2
                    ldd       <D.UsrIRQ
                    std       <D.SvcIRQ
                    bra       GoAltIRQ

DelVIRQ             pshs      y,x                 save off Y,X
dl@                 ldx       ,y++                get next entry
                    stx       -$04,y              move up
                    bne       dl@                 continue until all are moved
                    puls      y,x                 restore
                    leay      -2,y                move back 2 from Y (points to last entry)
                    rts                           return

* Install or Remove VIRQ Entry
FVIRQ               pshs      cc
                    orcc      #IntMasks           mask all interrupts
                    ldy       <D.CLTb             get pointer to VIRQ polling table
                    ldx       <D.Init             get pointer to init module
                    ldb       PollCnt,x           get poll count
                    ldx       R$X,u               get pointer to caller's X
                    beq       L0118               branch if removing
                    tst       ,y                  entry available?
                    beq       L010C
                    subb      #$02
                    lslb
                    leay      b,y
                    tst       ,y
                    bne       PTblFul             polling table full
L0106               tst       ,--y
                    beq       L0106
                    leay      $02,y
L010C               ldx       R$Y,u
                    stx       ,y
                    ldy       R$D,u
                    sty       ,x
                    bra       L0124
L0118               leax      R$Y,u               X = caller's Y
L011A               tst       ,y                  end of VIRQ table
                    beq       L0124               branch if so
                    cmpx      ,y++                else compare to current VIRQ entry and inc Y
                    bne       L011A               continue searching if not matched
                    bsr       DelVIRQ             else delete entry
L0124               puls      cc
                    clrb
                    rts
PTblFul             puls      cc
                    comb
                    ldb       #E$Poll
                    rts

* F$Time system call code
FTime               ldx       R$X,u
                    ldd       <D.Year
                    std       ,x
                    ldd       <D.Day
                    std       2,x
                    ldd       <D.Min
                    std       4,x
                    clrb
                    rts

                    emod
len                 equ       *
                    end
