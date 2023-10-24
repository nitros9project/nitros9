********************************************************************
* Clock2 - Eliminator RTC Driver
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2004/08/18  Boisy G. Pitre
* Separated clock2 modules for source clarity.

                    nam       Clock2
                    ttl       Eliminator RTC Driver

                    ifp1
                    use       defsfile
                    endc

tylg                set       Sbrtn+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

RTC.Sped            equ       $20                 32.768 KHz, rate=0
RTC.Strt            equ       $06                 binary, 24 Hour, DST disabled
RTC.Stop            equ       $86                 bit 7 set stops clock to allow setting time
RTC.Base            equ       $FF72               I don't know base for this chip.

                    mod       eom,name,tylg,atrv,JmpTable,RTC.Base

name                fcs       "Clock2"
                    fcb       edition

JmpTable
                    lbra      Init
                    bra       GetTime
                    nop
                    lbra      SetTime


GetTime             ldx       M$Mem,pcr           get RTC base address from fake memory requirement
                    ldb       #$0A                UIP status register address
                    stb       ,x                  generate address strobe
                    lda       1,x                 get UIP status
                    bpl       NoUIP               Update In Progress, go shift next RTC read
                    lda       #TkPerSec/2         set up next RTC read attempt in 1/2 second
                    sta       <D.Tick             save tick
                    bra       UpdTExit            and return

NoUIP               decb                          year register address
                    stb       ,x                  generate address strobe
                    lda       1,x                 get year
                    sta       <D.Year
                    decb                          month register address
                    stb       ,x
                    lda       1,x
                    sta       <D.Month
                    decb                          day of month register address
                    stb       ,x
                    lda       1,x
                    sta       <D.Day
                    ldb       #4                  hour register address
                    stb       ,x
                    lda       1,x
                    sta       <D.Hour
                    ldb       #2                  minute register address
                    stb       ,x
                    lda       1,x
                    sta       <D.Min
                    clrb                          second register address
                    stb       ,x
                    lda       1,x
SaveSec             sta       <D.Sec
UpdTExit            rts



SetTime             pshs      cc                  save interrupt status
                    orcc      #IntMasks           disable IRQs
                    ldx       M$Mem,pcr           get RTC base address from fake memory requirement
                    ldy       #D.Time             point [Y] to time variables in DP
                    ldd       #$0B*256+RTC.Stop
                    bsr       UpdatCk0            stop clock before setting it
                    ldb       #RTC.Sped
                    bsr       UpdatCk0            set crystal speed, output rate
                    bsr       UpdatClk            go set year
                    bsr       UpdatClk            go set month
                    bsr       UpdatClk            go set day of month
                    bsr       UpdatCk0            go set day of week (value doesn't matter)
                    bsr       UpdatCk0            go set hours alarm (value doesn't matter)
                    bsr       UpdatClk            go set hour
                    bsr       UpdatCk0            go set minutes alarm (value doesn't matter)
                    bsr       UpdatClk            go set minute
                    bsr       UpdatCk0            go set seconds alarm (value doesn't matter)
                    bsr       UpdatClk            go set second
                    ldd       #$0B*256+RTC.Strt
                    bsr       UpdatCk0            go start clock
                    puls      cc                  Recover IRQ status
                    clrb
                    rts

UpdatClk            ldb       ,y+                 get data from D.Time variables in DP
UpdatCk0            std       ,x                  generate address strobe, save data
                    deca                          set [A] to next register down
                    rts

                    ifgt      Level-1
* OS-9 Level Two code only (for now)
NewSvc              fcb       F$NVRAM             Eliminator adds one new service call
                    fdb       F.NVRAM-*-2
                    fcb       $80                 end of service call installation table

*------------------------------------------------------------
* read/write RTC Non Volatile RAM (NVRAM)
*
* INPUT:  [U] = pointer to caller's register stack
*         R$A = access mode (1 = read, 2 = write, other = error)
*         R$B = byte count (1 through 50 here, but in other implementations
*               may be 1 through 256 where 0 implies 256)
*         R$X = address of buffer in user map
*         R$Y = start address in NVRAM
*
* OUTPUT:  RTC NVRAM read/written
*
* ERROR OUTPUT:  [CC] = Carry set
*                [B] = error code
F.NVRAM             tfr       u,y                 copy caller's register stack pointer
                    ldd       #$0100              ask for one page
                    os9       F$SRqMem
                    bcs       NVR.Exit            go report error...
                    pshs      y,u                 save caller's stack and data buffer pointers
                    ldx       R$Y,y               get NVRAM start address
                    cmpx      #50                 too high?
                    bhs       Arg.Err             yes, go return error...
                    ldb       R$B,y               get NVRAM byte count
                    beq       Arg.Err
                    abx                           check end address
                    cmpx      #50                 too high?
                    bhi       Arg.Err             yes, go return error...
                    lda       R$A,y               get direction flag
                    cmpa      #WRITE.             put caller's data into NVRAM?
                    bne       ChkRead             no, go check if read...
                    clra                          [D]=byte count
                    pshs      d                   save it...
                    ldx       <D.Proc             get caller's process descriptor address
                    lda       P$Task,x            caller is source task
                    ldb       <D.SysTsk           system is destination task
                    ldx       R$X,y               get caller's source pointer
                    puls      y                   recover byte count
                    os9       F$Move              go MOVE data
                    bcs       NVR.Err
                    ldy       ,s                  get caller's register stack pointer from stack
                    lda       R$Y+1,y             get NVRAM start address
                    adda      #$0E                add offset to first RTC NVRAM address
                    ldb       R$B,y               get byte count
                    ldx       M$Mem,pcr           get clock base address from fake memory requirement
                    pshs      cc,b                save IRQ enable status and byte counter
                    orcc      #IntMasks           disable IRQs
WrNVR.Lp            ldb       ,u+                 get caller's data
                    std       ,x                  generate RTC address strobe and save data to NVRAM
                    inca                          next NVRAM address
                    dec       1,s                 done yet?
                    bne       WrNVR.Lp            no, go save another byte
                    puls      cc,b                recover IRQ enable status and clean up stack
NVR.RtM             puls      y,u                 recover register stack & data buffer pointers
                    ldd       #$0100              return one page
                    os9       F$SRtMem
NVR.Exit            rts

Arg.Err             ldb       #E$IllArg           Illegal Argument error
                    bra       NVR.Err

ChkRead             cmpa      #READ.              return NVRAM data to caller?
                    bne       Arg.Err             illegal access mode, go return error...
                    lda       R$Y+1,y             get NVRAM start address
                    adda      #$0E                add offset to first RTC NVRAM address
                    ldx       M$Mem,pcr           get clock base address from fake memory requirement
                    pshs      cc,b                save IRQ enable status and byte counter
                    orcc      #IntMasks           disable IRQs
RdNVR.Lp            sta       ,x                  generate RTC address strobe
                    ldb       1,x                 get NVRAM data
                    stb       ,u+                 save it to buffer
                    inca                          next NVRAM address
                    dec       1,s                 done yet?
                    bne       RdNVR.Lp            no, go get another byte
                    puls      cc,a                recover IRQ enable status, clean up stack ([A]=0)
                    ldb       R$B,y               [D]=byte count
                    pshs      d                   save it...
                    ldx       <D.Proc             get caller's process descriptor address
                    ldb       P$Task,x            caller is source task
                    lda       <D.SysTsk           system is destination task
                    ldu       R$X,y               get caller's source pointer
                    puls      y                   recover byte count
                    ldx       2,s                 get data buffer (source) pointer
                    os9       F$Move              go MOVE data
                    bcc       NVR.RtM
NVR.Err             puls      y,u                 recover caller's stack and data pointers
                    pshs      b                   save error code
                    ldd       #$0100              return one page
                    os9       F$SRtMem
                    comb                          set       Carry for error
                    puls      b,pc                recover error code, return...
                    endc


Init                equ       *
                    ifgt      Level-1
* Eliminator will install specific system calls
                    leay      NewSvc,pcr          insert syscalls
                    os9       F$SSvc
                    endc
                    rts

                    emod
eom                 equ       *
                    end

