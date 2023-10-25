********************************************************************
* wbug - WireBug for 6809/6309
*
* $Id$
*
* For Level 1, wbug must be run from the command line in order for
* the debugger to be properly setup.
*
* For Level 2, this module is called by the kernel at boot time.
*
* A process can invoke the debugger by executing an os9 F$Debug instruction.
* SWI can also invoke the debugger but should be reserved for breakpoints only.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2005/04/03  Boisy G. Pitre
* Started.
*
*   2      2008/02/07  Boisy G. Pitre
* Revamped to use F$Debug for debugger entry and SWI for breakpoints.
* Confirmed working under Level 1, but under Level 2, system calls
* currently crash the CoCo 3.

                    nam       KrnP3
                    ttl       WireBug for 6809/6309

                    ifp1
                    use       defsfile
                    use       drivewire.d
                    endc

                    ifeq      LEVEL-1
tylg                set       Prgrm+Objct
                    else
tylg                set       Systm+Objct
                    endc
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       2

cbsize              equ       24

* offsets into our on-stack storage
                    org       0
callregs            rmb       2
                    ifeq      LEVEL-1
l1exitvct           rmb       2
                    endc
combuff             rmb       cbsize
size                equ       .


L0000               mod       eom,name,tylg,atrv,start,size

SvcTbl              equ       *
                    fcb       F$Debug
                    fdb       dbgent-*-2
                    fcb       $80


name                equ       *
                    ifeq      LEVEL-1
                    fcs       /wbug/
                    else
                    fcs       /KrnP3/
                    fcb       edition

nextname            fcc       /KrnP4/             next module name to link to
                    fcb       C$CR
                    endc

subname             fcs       /dwio/

start
* attach to low level module
                    clra
                    leax      subname,pcr
                    os9       F$Link
                    bcs       ex@
                    ifgt      Level-1
                    sty       <D.DWSubAddr
                    else
                    sty       >D.DWSubAddr
                    endc
* install F$Debug system call
                    leay      SvcTbl,pcr
                    os9       F$SSvc
                    bcs       ex@
                    leax      brkent,pcr          get pointer to breakpoint entry
                    ifeq      LEVEL-1
                    stx       >D.SWI              store in D.SWI global
                    clrb                          clear carry
ex@                 os9       F$Exit              and exit
                    else
                    stx       <D.XSWI             store in D.XSWI global
* get next KrnP module going
gol2                lda       #tylg               get next module type (same as this one!)
                    leax      <nextname,pcr       get address of next module name
                    os9       F$Link              attempt to link to it
                    bcs       ex@                 no good...skip this
                    jsr       ,y                  else go execute it
ex@                 rts                           return
                    endc


* Breakpoint Entry
*
* We enter here when a process or the system executes an SWI instruction.
brkent
                    ifeq      LEVEL-1
* In Level 1, we get called right from the SWI vector, so we need to set U to point to the registers on the stack.
                    leau      ,s                  point X to regs on stack
                    leay      rtiexit,pc
                    endc
* This is a breakpoint; back up PC to point at SWI
                    ldd       R$PC,u
                    subd      #$01                length of SWI instruction
                    std       R$PC,u
                    ifeq      LEVEL-1
                    bra       cmn
                    endc

* Code common to both debugger and breakpoint entries
* Debugger Entry
*
* We enter here when a process or the system executes an os9 F$Debug instruction.
dbgent
                    ifeq      LEVEL-1
                    leay      rtsexit,pc
                    endc
cmn                 pshs      cc
                    orcc      #IntMasks
                    leas      -size,s             make room on stack for temp statics
                    leax      ,s                  point X to our temp statics
                    exg       x,u                 exchange X and U
                    stx       callregs,u          save pointer to caller regs
                    ifeq      LEVEL-1
                    sty       l1exitvct,u
                    endc
                    pshs      u
                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc
                    jsr       ,u                  initialize I/O
                    puls      u

                    lda       #OP_WIREBUG_MODE
                    ifeq      LEVEL-1
                    ldb       #$02                assume CoCo 2
                    else
                    ldb       #$03                assume CoCo 3
                    endc
                    std       combuff,u
                    ifne      H6309
                    lda       #$03                6309
                    else
                    lda       #$08                6809
                    endc
                    sta       combuff+2,u
                    lbsr      _sendtohost

* mainloop - processes requests from the server
mainloop
                    leax      combuff,u           point to comm buffer
                    pshs      u
                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc
l@
                    ldy       #24
                    ldd       #133
                    jsr       3,u                 get packet
                    cmpd      #$0000              no data?
                    beq       l@
                    puls      u
* bcs
                    tfr       y,d                 put checksum in D
                    subb      23,x
                    cmpb      combuff+23,u        does it match the checksum from the packet?
                    beq       processmsg          if not, send checksum error
                    bsr       _sendcsumerror
                    bra       mainloop

* Here we have a message with a valid checksum.
* Now we evaluate the command byte.
processmsg
                    lda       combuff,u           get command byte
                    cmpa      #OP_WIREBUG_READMEM Read Memory?
                    lbeq      _readmem            branch if so
                    cmpa      #OP_WIREBUG_READREGS Read Registers?
                    lbeq      _readregs           branch if so
                    cmpa      #OP_WIREBUG_WRITEMEM Write Memory?
                    lbeq      _writemem           branch if so
                    cmpa      #OP_WIREBUG_WRITEREGS Write Registers?
                    lbeq      _writeregs          branch if so
                    cmpa      #OP_WIREBUG_GO      Run Target?
                    bne       mainloop

_go
*               clr       combuff,u
*			   bsr       _sendtohost
                    leas      size,s              recover space on stack
                    ifeq      LEVEL-1
                    jmp       [l1exitvct,u]
                    endc
rtsexit             puls      cc
                    clrb
                    rts
rtiexit             puls      cc
                    rti


* Destroys A
_sendcsumerror
                    lda       #E$CRC
_senderror
                    sta       combuff,u
                    bra       _sendtohost

* Destroys A
_sendillnumerror
                    lda       #16
                    bra       _senderror

* This routine reads memory from the calling process' address space
* using F$Move.
_readmem
                    ldx       combuff+1,u         get source pointer
                    ldb       combuff+3,u         get count
                    cmpb      #1
                    bge       ok1@
bad1@               bsr       _sendillnumerror
                    bra       mainloop
ok1@                cmpb      #22
                    bgt       bad1@               if > 22, its illegal count

                    ifeq      LEVEL-1
* Level 1 copy
                    leay      combuff+1,u         point U to destination
l@                  lda       ,x+                 get byte at Y and inc
                    sta       ,y+                 save byte at X and inc
                    decb                          done?
                    bne       l@                  branch if not
                    else
* Level 2 copy
                    clra
                    tfr       d,y                 put count in Y
                    pshs      u,x                 save source pointer
                    leau      combuff+1,u         point U to destination
                    ldx       D.Proc              get current process pointer
                    lda       P$Task,x            get source task #
                    ldb       D.SysTsk            get destination task #
                    puls      x                   restore source pointer
                    os9       F$Move              move 'em out!
                    puls      u                   restore statics pointer
                    endc

                    bsr       _sendtohost
                    lbra      mainloop


* This routine writes memory from the host to the calling process'
* address space using F$Move.
_writemem
                    leax      combuff+4,u         point X to source
                    ifeq      LEVEL-1
* Level 1 copy
                    ldb       combuff+3,u         get count of packet
                    ldy       combuff+1,u         get destination pointer
l@                  lda       ,x+                 get byte at Y and inc
                    sta       ,y+                 save byte at X and inc
                    decb                          done?
                    bne       l@                  branch if not
                    else
* Level 2
                    clra
                    ldb       combuff+3,u         get count of packet
                    tfr       d,y                 put count in Y
                    pshs      u,x                 save on stack
                    ldu       combuff+1,u         get destination pointer
                    ldx       <D.Proc             get current process pointer
                    lda       <D.SysTsk           get source task #
                    ldb       P$Task,x            get destination task #
                    puls      x                   restore source pointer
                    os9       F$Move              move 'em out!
                    puls      u                   restore our static pointer
                    endc
                    ldd       #$0100              assume successful write
                    bsr       _sendtohost
                    lbra      mainloop


* This routine sends the contents of combuff,u to the communications
* hardware.
*
* Also, we compute the checksum as we send the bytes out so that
* we do not have to call a separate routine.
*
* Entry:
*    X = address of packet to send
_sendtohost
                    leax      combuff,u
                    ldb       #23                 B = count of packet - 1
                    clra                          A = checksum
l@                  adda      ,x+                 add up
                    decb                          until
                    bne       l@                  we've reached the end
                    sta       ,x                  save computed checksum
                    leax      -23,x
                    ldy       #24
                    pshs      u
                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc
                    jsr       6,u                 write it out
                    puls      u,pc


*  Target registers:  DO NOT CHANGE!
TASK_REGS
REG_STATE           rmb       1
REG_PAGE            rmb       1
REG_SP              rmb       2
REG_U               rmb       2
REG_Y               rmb       2
REG_X               rmb       2
REG_F               rmb       1                   F BEFORE E, SO W IS LEAST SIG. FIRST
REG_E               rmb       1
REG_B               rmb       1                   B BEFORE A, SO D IS LEAST SIG. FIRST
REG_A               rmb       1
REG_DP              rmb       1
REG_CC              rmb       1
REG_MD              rmb       1
REG_V               rmb       2
REG_PC              rmb       2
TASK_REG_SZ         equ       *-TASK_REGS


_readregs
                    ldy       callregs,u          get pointer to caller's regs
                    leax      combuff+1,u
                    ldb       R$DP,y
                    stb       ,x+                 DP
                    ldb       R$CC,y
                    stb       ,x+                 CC
                    ldd       R$D,y               D
                    std       ,x++
                    ifne      H6309
                    ldd       R$W,y               W
                    exg       a,b
                    std       ,x++
                    else
                    leax      2,x
                    endc
                    ldd       R$X,y               X
                    exg       a,b
                    std       ,x++
                    ldd       R$Y,y               Y
                    exg       a,b
                    std       ,x++
                    ldd       R$U,y               U
                    exg       a,b
                    std       ,x++

                    ifne      H6309
* construct MD from shadow register in NitrOS-9 globals
                    lda       >D.MDREG            MD
                    sta       ,x+
                    tfr       v,d
                    std       ,x++                V
                    else
                    leax      3,x
                    endc

                    ldd       R$PC,y
                    std       2,x                 PC
                    ldy       >D.Proc             get SP from proc desc
                    ldd       P$SP,y
                    std       ,x
                    bsr       _sendtohost
                    lbra      mainloop



_writeregs
                    ldy       callregs,u          get caller's reg ptr
                    ldd       combuff+1,u
                    std       R$DP,y
                    ldd       combuff+3,u
                    std       R$D,y
                    ifne      H6309
                    ldd       combuff+5,u
                    std       R$W,y
                    endc
                    ldd       combuff+7,u
                    std       R$X,y
                    ldd       combuff+9,u
                    std       R$Y,y
                    ldd       combuff+11,u
                    std       R$U,y

                    ldd       combuff+17,u
                    std       R$PC,y

                    ldy       >D.Proc
                    std       P$SP,y

                    lbra      mainloop

                    emod
eom                 equ       *
                    end
