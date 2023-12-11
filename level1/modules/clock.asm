********************************************************************
* Clock - NitrOS-9 System Clock
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          ????/??/??
* NitrOS-9 2.00 distribution.
*
*   9r4    2003/01/01  Boisy G. Pitre
* Back-ported to OS-9 Level Two.
*
*   9r5    2003/08/18  Boisy G. Pitre
* Separated clock into Clock and Clock2 for modularity.
*
*   9r6    2003/09/04  Boisy G. Pitre
* Combined Level One and Level Two sources
*
*   9r7    2004/11/27  Phill Harvey-Smith
* Fixed bug in init routine that was causing DP and CC to
* be pulled off the stack and stored in D.Proc under Level 1
*
*   9r7    2005/01/17  Boisy G. Pitre
* Fixed incorrect value for PIA initialization.  Robert indicated
* that it should be $3434, not $3435.
*
*   9r7    2005/04/08  Phill Harvey-Smith
* Made the above level dependent as having PIAs inited with $3434
* will disable the IRQ from them, this is ok for Level 2/CoCo 3 as the
* IRQ is later enabled from the GIME, however the CoCo 1,2 and Dragon
* do not posses a GIME so anything dependent on the clock tick will
* hang. So changed to conditionaly compile based on level :-
*
*   9r8    2005/12/04  Boisy G. Pitre
* Minor code optimizations, fixed issue in Level 1 where clock ran slow
* due to improper initialization of certain system globals.

                    nam       Clock
                    ttl       NitrOS-9 System Clock

                    ifp1
                    use       defsfile
                    endc

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       8
edition             set       9

                    ifne      atari
USENMI              equ       0
                    endc

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
                    ldx       <D.Clock2           get entry point to Clock2
                    beq       around@             branch if it doesn't exist
                    clra                          clear carry
                    jmp       $06,x               and call SetTime entry point
around@             rts

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

Clock2              fcs       "Clock2"

init
                    pshs      dp,cc               save DP and CC
                    clra
                    tfr       a,dp                set DP to zero
                    leax      <Clock2,pcr
                    lda       #Sbrtn+Objct
                    os9       F$Link
                    bcc       LinkOk
                    ldy       #$0000              no Clock2, set vector to 0
LinkOk
                    puls      cc,dp               ; Restore saved dp and cc
                    sty       <D.Clock2           save entry point
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
                    ifne      USENMI
                    stx       <D.NMI
                    else
                    stx       <D.IRQ
                    endc

                    leay      NewSvc,pcr          insert syscalls
                    os9       F$SSvc

* Call Clock2 init routine
                    ldy       <D.Clock2           get entry point to Clock2
                    beq       around@             branch if it doesn't exist
                    jsr       ,y                  call init entry point of Clock2
around@

* Initialize clock hardware
                    ifne      f256
* Use the SOF to get a 1/60th or 1/70th interrupt
                    pshs      cc
                    orcc      #IntMasks
                    lda       #$FF
                    sta       INT_PENDING_0
                    sta       INT_PENDING_1
                    sta       INT_MASK_1
                    lda       INT_MASK_0
                    anda      #^INT_VKY_SOF
                    sta       INT_MASK_0
                    else
                    ifne      corsham
* Corsham SS-50 6809 board -- uses the Arduino as a clock source
* Timer values:
*    0 = disable timer interrupts
*    1 = 10 ms
*    2 = 20 ms
*    3 = 30 ms
*    4 = 40 ms
*    5 = 50 ms
*    6 = 100 ms
*    7 = 250 ms
*    8 = 500 ms
*    9 = 1000 ms

                    pshs      d,cc

* Check if subroutine module has already been linked
                    ifgt      LEVEL-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc
* The following code is commented because the pio subroutine module has already
* been linked and its entry point stored prior to us getting here.
*         bne   SetTimer
* Link to subroutine module
*         clra
*         leax  iosub,pcr
*         os9   F$Link
*         bcs   ClkEx
*         tfr   y,u
*         IFGT  LEVEL-1
*         stu   <D.DWSubAddr
*         ELSE
*         stu   >D.DWSubAddr
*         ENDC
* Initialize the low level device
*         jsr   ,u


SetTimer
                    orcc      #IntMasks
                    ldd       #CSETIMR*256+$02
                    std       1,s
* Tell Arduino to generate timer interrupts
                    leax      1,s
                    ldy       #2
                    jsr       6,u
                    ldy       #1
                    jsr       3,u
                    lda       ,x
                    cmpa      #RACK
                    beq       SETIM1
                    ldy       #1
                    jsr       3,u                 read error code
                    bra       ClkEx

SETIM1

* Tell PIA to enable interrupts
                    ldx       #PIA0Base
                    lda       3,x
                    ora       #$01                *enable interrupts
                    sta       3,x
                    lda       2,x                 *clear pending ints

ClkEx
                    puls      cc,d,pc
*iosub	fcs	/pio/

                    else
                    ifne      atari
                    ifne      USENMI
                    lda       #$40
                    sta       NMIEN               enable VBlank NMI
                    rts
                    else
                    lda       #IRQST.TIMER1
                    pshs      cc
                    orcc      #IntMasks
                    ora       <D.IRQENShdw
                    sta       <D.IRQENShdw
                    sta       IRQEN
                    lda       #%00101001
                    sta       AUDCTL
                    clr       AUDC1
                    lda       #$FF
                    sta       AUDF1
                    sta       STIMER
                    endc
                    else
                    ldx       #PIA0Base           point to PIA0
                    clra                          no error for return...
                    pshs      cc                  save IRQ enable status (and Carry clear)
                    orcc      #IntMasks           stop interrupts

                    sta       1,x                 enable DDRA
                    sta       ,x                  set port A all inputs
                    sta       3,x                 enable DDRB
                    coma
                    sta       2,x                 set port B all outputs

;	ldd	#$343C		[A]=PIA0 CRA contents, [B]=PIA0 CRB contents

                    ldd       #$3435              IRQ needs to be left enabled for Level1, as no GIME generated IRQ

                    sta       1,x                 CA2 (MUX0) out low, port A, disable HBORD high-to-low IRQs
                    stb       3,x                 CB2 (MUX1) out low, port B, disable VBORD low-to-high IRQs

                    lda       2,x                 clear possible pending PIA0 VBORD IRQ
                    puls      cc,pc               recover IRQ enable status and return
                    endc
                    endc
                    endc
                    puls      cc,pc

*
* Clock IRQ Entry Point
*
* For CoCo 1/2, called once every 16.667 milliseconds
SvcIRQ
                    clra
                    tfr       a,dp                set direct page to zero
                    ifne      f256
                    lda       INT_PENDING_0
                    bita      #INT_VKY_SOF
                    bne       ClearInt            it's a clock interrupt -- clear it
                    jmp       [>D.SvcIRQ]         else service other possible IRQ
ClearInt
                    lda       #INT_VKY_SOF
                    sta       INT_PENDING_0       clear clock interrupt by writing bit back
                    else
                    ifne      corsham
                    tst       PIA0Base+3
                    bmi       ClearInt            it's a clock interrupt -- clear it
                    jmp       [>D.SvcIRQ]         else service other possible IRQ
ClearInt            tst       PIA0Base+2          clear clock interrupt by reading register
                    else
                    ifne      atari
                    ifne      USENMI
                    sta       NMIRES              clear NMI interrupt
                    else
                    lda       IRQST               get hw byte
                    bita      #IRQST.TIMER1
                    beq       L0032               branch if interrupt occurred
                    jmp       [>D.SvcIRQ]         else service other possible IRQ
L0032
                    lda       #$FF
                    sta       AUDF1
                    lda       <D.IRQENShdw
                    tfr       a,b                 A = clear interrupt, B = set interrupt
                    anda      #^IRQST.TIMER1
                    orb       #IRQST.TIMER1
                    sta       IRQEN
                    stb       IRQEN
                    stb       <D.IRQENShdw
                    sta       STIMER
                    endc
                    else
                    tst       PIA0Base+3          get hw byte
                    bmi       L0032               branch if sync flag on
                    jmp       [>D.SvcIRQ]         else service other possible IRQ
L0032               tst       PIA0Base+2          clear interrupt
                    endc
                    endc
                    endc
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
                    ldx       <D.Clock2           get entry point to Clock2
                    beq       L007B               branch if it doesn't exist
                    jsr       $03,x               call GetTime entry point
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
