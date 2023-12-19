********************************************************************
* Clock - Clock for OS-9 Level Two/NitrOS-9
*
* Clock module for CoCo 3 and TC9 OS9 Level 2 and NitrOS-9
*
* Includes support for several different RTC chips, GIME Toggle
* IRQ fix, numerous minor changes.
*
* Based on Microware/Tandy Clock Module for CC3/L2
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

               nam       Clock
               ttl       Clock for OS-9 Level Two/NitrOS-9

TkPerTS        equ       2                   ticks per time slice
GI.Toggl       equ       %00000001           GIME CART* IRQ enable bit, for CC3

* TC9 needs to reset more interrupt sources
*GI.Toggl equ %00000111 GIME SERINT*, KEYINT*, CART* IRQ enable bits

               ifp1
               use       defsfile
               use       cocovtio.d
               endc

Edtn           equ       9
Vrsn           equ       5

*------------------------------------------------------------
*
* Start of module
*
               mod       len,name,Systm+Objct,ReEnt+Vrsn,Init,0

name           fcs       "Clock"
               fcb       Edtn

*
* Table to set up Service Calls:
*
NewSvc         fcb       F$Time
               fdb       F.Time-*-2
               fcb       F$VIRQ
               fdb       F.VIRQ-*-2
               fcb       F$Alarm
               fdb       F.ALARM-*-2
               fcb       F$STime
               fdb       F.STime-*-2
               fcb       $80                 end of service call installation table

*---------------------------------------------------------
* IRQ Handling starts here.
*
* Caveat: There may not be a stack at this point, so avoid using one.
*         Stack is set up by the kernel between here and SvcVIRQ.
*
SvcIRQ
               ifne      f256
               lda       INT_PENDING_0
               bita      #INT_VKY_SOF
               beq       NoClock
* clear interrupt
               lda       #INT_VKY_SOF
               sta       INT_PENDING_0       clear clock interrupt by writing bit back

               else

               lda       >IRQEnR             Get GIME IRQ Status and save it.
               ora       <D.IRQS
               sta       <D.IRQS
               bita      #$08                Check for clock interrupt
               beq       NoClock
               anda      #^$08               Drop clock interrupt
               sta       <D.IRQS
               endc
               ldx       <D.VIRQ             Set VIRQ routine to be executed
               clr       <D.QIRQ             ---x IS clock IRQ
               bra       ContIRQ

NoClock        leax      DoPoll,pcr          If not clock IRQ, just poll IRQ source
               ifne      H6309
               oim       #$FF,<D.QIRQ        ---x set flag to NOT clock IRQ
               else
               lda       #$FF
               sta       <D.QIRQ
               endc
ContIRQ        stx       <D.SvcIRQ
               jmp       [D.XIRQ]            Chain through Kernel to continue IRQ handling

*------------------------------------------------------------
*
* IRQ handling re-enters here on VSYNC IRQ.
*
* - Count down VIRQ timers, mark ones that are done
* - Call DoPoll/DoToggle to service VIRQs and IRQs and reset GIME
* - Call Keyboard scan
* - Update time variables
* - At end of minute, check alarm
*
SvcVIRQ        clra                          Flag if we find any VIRQs to service
               pshs      a
               ldy       <D.CLTb             Get address of VIRQ table
               bra       virqent

virqloop       equ       *
               ifgt      Level-2
               ldd       2,y                 Get Level 3 extended map type
               orcc      #IntMasks
               sta       >$0643
               stb       >$0645
               std       >DAT.Regs+1
               andcc     #^IntMasks
               endc

               ldd       Vi.Cnt,x            Decrement tick count
               ifne      H6309
               decd                          --- subd #1
               else
               subd      #$0001
               endc
               bne       notzero             Is this one done?
               lda       Vi.Stat,x           Should we reset?
               bmi       doreset
               lbsr      DelVIRQ             No, delete this entry
doreset        ora       #$01                Mark this VIRQ as triggered.
               sta       Vi.Stat,x
               lda       #$80                Add VIRQ as interrupt source
               sta       ,s
               ldd       Vi.Rst,x            Reset from Reset count.
notzero        std       Vi.Cnt,x
virqent        ldx       ,y++
               bne       virqloop

               ifgt      Level-2
               puls      d
               orcc      #Carry
               stb       >$0643
               stb       >DAT.Regs+1
               incb
               stb       >$0645
               stb       >DAT.Regs+1
               andcc     #^IntMasks
               else
               puls      a                   Get VIRQ status flag: high bit set if VIRQ
               endc

               ora       <D.IRQS             Check to see if other hardware IRQ pending.
               bita      #%10110111          Any V/IRQ interrupts pending?
               beq       toggle
               ifgt      Level-2
               lbsr      DoPoll              Yes, go service them.
               else
               bsr       DoPoll              Yes, go service them.
               endc
               bra       KbdCheck
toggle         equ       *
               ifgt      Level-2
               lbsr      DoToggle            No, toggle GIME anyway
               else
               bsr       DoToggle            No, toggle GIME anyway
               endc

KbdCheck       equ       *
               ifgt      Level-2
               lda       >$0643              grab current map type
               ldb       >$0645
               pshs      d                   save it
               orcc      #IntMasks           IRQs off
               lda       >$0660              SCF local memory ---x
               sta       >$0643              into DAT image ---x
               sta       >DAT.Regs+1         and into RAM ---x
               inca
               sta       >$0645
               sta       >DAT.Regs+2         map in SCF, CC3IO, WindInt, etc.
               endc

               jsr       [>D.AltIRQ]         go update mouse, gfx cursor, keyboard, etc.

               ifgt      Level-2
               puls      d                   restore original map type ---x
               orcc      #IntMasks
               sta       >$0643              into system DAT image ---x
               stb       >$0645
               std       >DAT.Regs+1         and into RAM ---x
               andcc     #$AF
               endc

               dec       <D.Tick             End of second?
               bne       VIRQend             No, skip time update and alarm check
               lda       #TkPerSec           Reset tick count
               sta       <D.Tick

* ATD: Modified to call real time clocks on every minute ONLY.
               inc       <D.Sec              go up one second
               lda       <D.Sec              grab current second
               cmpa      #60                 End of minute?
               blo       VIRQend             No, skip time update and alarm check
               clr       <D.Sec              Reset second count to zero

*
* Call GetTime entry point in Clock2
*
               ldx       <D.Clock2           get entry point to Clock2
               jsr       $03,x               call GetTime entry point

NoGet          ldd       >WGlobal+G.AlPID
               ble       VIRQend             Quit if no Alarm set
               ldd       >WGlobal+G.AlPckt+3 Does Hour/Minute agree?
               cmpd      <D.Hour
               bne       VIRQend
               ldd       >WGlobal+G.AlPckt+1 Does Month/Day agree?
               cmpd      <D.Month
               bne       VIRQend
               ldb       >WGlobal+G.AlPckt+0 Does Year agree?
               cmpb      <D.Year
               bne       VIRQend
               ldd       >WGlobal+G.AlPID
               cmpd      #1
               beq       checkbel
               os9       F$Send
               bra       endalarm
checkbel       ldb       <D.Sec              Sound bell for 15 seconds
               andb      #$F0
               beq       dobell
endalarm       ldd       #$FFFF
               std       >WGlobal+G.AlPID
               bra       VIRQend
dobell         ldx       >WGlobal+G.BelVec
               beq       VIRQend
               jsr       ,x
VIRQend        jmp       [>D.Clock]          Jump to kernel's timeslice routine

*------------------------------------------------------------
* Interrupt polling and GIME reset code
*

*
* Call [D.Poll] until all interrupts have been handled
*
Dopoll
               ifgt      Level-2
               lda       >$0643              Level 3: get map type
               ldb       >$0645
               pshs      d                   save for later
               endc
Dopoll.i
               jsr       [>D.Poll]           Call poll routine
               bcc       DoPoll.i            Until error (error -> no interrupt found)

               ifgt      Level-2
               puls      d
               orcc      #IntMasks
               sta       >$0643
               stb       >$0645
               std       >DAT.Regs+1
               andcc     #^IntMasks
               endc

*
* Reset GIME to avoid missed IRQs
*
DoToggle
               ifne      coco3
               lda       #^GI.Toggl          Mask off CART* bit
               anda      <D.IRQS
               sta       <D.IRQS
               lda       <D.IRQER            Get current enable register status
               tfr       a,b
               anda      #^GI.Toggl          Mask off CART* bit
               orb       #GI.Toggl           --- ensure that 60Hz IRQ's are always enabled
               sta       >IRQEnR             Disable CART
               stb       >IRQEnR             Enable CART
               clrb
               endc
               rts


*------------------------------------------------------------
*
* Handle F$VIRQ system call
*
F.VIRQ         pshs      cc
               orcc      #IntMasks           Disable interrupts
               ldy       <D.CLTb             Address of VIRQ table
               ldx       <D.Init             Address of INIT
               ldb       PollCnt,x           Number of polling table entries from INIT
               ldx       R$X,u               Zero means delete entry
               beq       RemVIRQ
               ifgt      Level-2
               bra       FindVIRQ            ---x

v.loop         leay      4,y                 ---x
               endc
FindVIRQ       ldx       ,y++                Is VIRQ entry null?
               beq       AddVIRQ             If yes, add entry here
               decb
               bne       FindVIRQ
               puls      cc
               comb
               ldb       #E$Poll
               rts

AddVIRQ
               ifgt      Level-2
               ldx       R$Y,u
               stx       ,y
               lda       >$0643
               ldb       >$0645
               std       2,y
               else
               leay      -2,y                point to first null VIRQ entry
               ldx       R$Y,u
               stx       ,y
               endc
               ldy       R$D,u
               sty       ,x
               bra       virqexit

               ifgt      Level-2
v.chk          leay      4,y
RemVIRQ        ldx       ,y
               else
RemVIRQ        ldx       ,y++
               endc
               beq       virqexit
               cmpx      R$Y,u
               bne       RemVIRQ
               bsr       DelVIRQ
virqexit       puls      cc
               clrb
               rts

DelVIRQ        pshs      x,y
DelVLup
               ifgt      Level-2
               ldq       ,y++                move entries up in table
               leay      2,y
               stq       -8,y
               bne       DelVLup
               puls      x,y,pc
               else
               ldx       ,y++                move entries up in table
               stx       -4,y
               bne       DelVLup
               puls      x,y
               leay      -2,y
               rts
               endc

*------------------------------------------------------------
*
* Handle F$Alarm call
*
F.Alarm        ldx       #WGlobal+G.AlPckt
               ldd       R$D,u
               bne       DoAlarm
               std       G.AlPID-G.AlPckt,x  Erase F$Alarm PID, Signal.
               rts

DoAlarm        tsta                          If PID != 0, set alarm for this process
               bne       SetAlarm
               cmpd      #1                  1 -> Set system-wide alarm
               bne       GetAlarm
SetAlarm       std       G.AlPID-G.AlPckt,x
               ldy       <D.Proc
               lda       P$Task,y            Move from process task
               ldb       <D.SysTsk           To system task
               ldx       R$X,u               From address given in X
               ldu       #WGlobal+G.AlPckt
               ldy       #5                  Move 5 bytes
               bra       FMove

GetAlarm       cmpd      #2
               bne       AlarmErr
               ldd       G.AlPID-G.AlPckt,x
               std       R$D,u
               bra       RetTime
AlarmErr       comb
               ldb       #E$IllArg
               rts

*------------------------------------------------------------
*
* Handle F$Time System call
*
F.Time         equ       *
               ldx       #D.Time             Address of system time packet
RetTime        ldy       <D.Proc             Get pointer to current proc descriptor
               ldb       P$Task,y            Process Task number
               lda       <D.SysTsk           From System Task
               ldu       R$X,u
STime.Mv       ldy       #6                  Move 6 bytes
FMove          os9       F$Move
               rts

*------------------------------------------------------------
*
* Handle F$STime system call
*
* First, copy time packet from user address space to system time
* variables, then fall through to code to update RTC.
*
F.STime        equ       *
               ldx       <D.Proc             Caller's process descriptor
               lda       P$Task,x            Source is in user map
               ldx       R$X,u               Address of caller's time packet
               ldu       #D.Time             Destination address
               ldb       <D.SysTsk           Destination is in system map
               bsr       STime.Mv            Get time packet (ignore errors)
               lda       #TkPerSec           Reset to start of second
               sta       <D.Tick

*
* Call SetTime entry point in Clock2
               ldx       <D.Clock2           get entry point to Clock2
               jsr       $06,x               else call GetTime entry point

NoSet          rts

Clock2         fcs       "Clock2"

*--------------------------------------------------
*
* Clock Initialization
*
* This vector is called by the kernel to service the first F$STime
* call.  F$STime is usually called by CC3Go (with a dummy argument)
* in order to initialize the clock.  F$STime is re-vectored to the
* service code above to handle future F$STime calls.
*
*
Init           ldx       <D.Proc             save user proc
               pshs      x
               ldx       <D.SysPrc           make sys for link
               stx       <D.Proc

               leax      <Clock2,pcr
               lda       #Sbrtn+Objct
               os9       F$Link

* And here, we restore the original D.Proc value
               puls      x
               stx       <D.Proc             restore user proc

               bcc       LinkOk
               lda       #E$MNF
               jmp       <D.Crash
LinkOk         sty       <D.Clock2           save entry point
InitCont
               ifne      coco3
               ldx       #PIA0Base           point to PIA0
               endc
               clra                          no error for return...
               pshs      cc                  save IRQ enable status (and Carry clear)
               orcc      #IntMasks           stop interrupts

* Initialize clock hardware
               ifne      f256
* Use the SOF to get a 1/60th or 1/70th interrupt
               orcc      #IntMasks
               lda       #$FF
               sta       INT_PENDING_0
               sta       INT_PENDING_1
               sta       INT_MASK_1
               lda       INT_MASK_0
               anda      #^INT_VKY_SOF
               sta       INT_MASK_0
               else
               
* Note: this code can go away once we have a rel_50hz
               ifeq      TkPerSec-50
               ldb       <D.VIDMD            get video mode register copy
               orb       #$08                set 50 Hz VSYNC bit
               stb       <D.VIDMD            save video mode register copy
               stb       >$FF98              set 50 Hz VSYNC
               endc

               sta       1,x                 enable DDRA
               sta       ,x                  set port A all inputs
               sta       3,x                 enable DDRB
               coma
               sta       2,x                 set port B all outputs
               ldd       #$343C              [A]=PIA0 CRA contents, [B]=PIA0 CRB contents
               sta       1,x                 CA2 (MUX0) out low, port A, disable HBORD high-to-low IRQs
               stb       3,x                 CB2 (MUX1) out low, port B, disable VBORD low-to-high IRQs
               sta       $23,x               disable CART +RG Mar 14, 2012
               lda       ,x                  clear possible pending PIA0 HBORD IRQ
               lda       2,x                 clear possible pending PIA0 VBORD IRQ
               endc
               
* Don't need to explicitly read RTC during initialization
               ldd       #59*256+TkPerTS     last second and time slice in minute
               std       <D.Sec              Will prompt RTC read at next time slice

               stb       <D.TSlice           set ticks per time slice
               stb       <D.Slice            set first time slice
               leax      SvcIRQ,pcr          set IRQ handler
               stx       <D.IRQ
               leax      SvcVIRQ,pcr         set VIRQ handler
               stx       <D.VIRQ
               leay      NewSvc,pcr          insert syscalls
               os9       F$SSvc
               
               ifne      f256
               else
* H6309 optimization opportunity here using oim
               lda       <D.IRQER            get shadow GIME IRQ enable register
               ora       #$08                set VBORD bit
               sta       <D.IRQER            save shadow register
               sta       >IRQEnR             enable GIME VBORD IRQs
               endc
               
* Call Clock2 init routine
               ldy       <D.Clock2           get entry point to Clock2
               jsr       ,y                  call init entry point of Clock2
InitRts        puls      cc,pc               recover IRQ enable status and return

               emod
len            equ       *
               end
