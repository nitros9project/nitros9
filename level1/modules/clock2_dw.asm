********************************************************************
* Clock2 - DriveWire 3 RTC Driver
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2004/08/18  Boisy G. Pitre
* Separated clock2 modules for source clarity.
*
*   2      2010/01/02  Boisy G. Pitre
* Saved some bytes by optimizing

                    nam       Clock2
                    ttl       DriveWire 3 RTC Driver

                    ifp1
                    use       defsfile
                    use       drivewire.d
                    endc

tylg                set       Sbrtn+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       2


RTC.Base            equ       $0000

                    mod       eom,name,tylg,atrv,JmpTable,RTC.Base

name                fcs       "Clock2"
                    fcb       edition

subname             fcs       "dwio"

* Three Entry Points:
*   - Init
*   - GetTime
*   - SetTIme
JmpTable
                    bra       Init
                    nop
                    bra       GetTime             RTC Get Time
                    nop

SetTime
                    ifgt      Level-1
                    lda       <D.DWSrvID
                    else
                    lda       >D.DWSrvID
                    endc
                    cmpa      #128
                    bne       leave
                    pshs      u,y,x,d
                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc
                    beq       UpdLeave            in case we failed to link it, just exit
                    lda       #OP_SETTIME
                    pshs      a
                    ldy       #$0001
                    leax      ,s
                    jsr       DW$Write,u
                    puls      a
                    ldx       #D.Year
                    ldy       #$0006
                    jsr       DW$Write,u
                    bra       UpdLeave

GetTime
                    lda       #OP_TIME            Time packet
                    pshs      u,y,x,d
                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc
                    beq       UpdLeave            in case we failed to link it, just exit
                    leax      ,s
                    ldy       #$0001
                    jsr       DW$Write,u
                    ldx       #D.Year
                    ldy       #$0006
                    jsr       DW$Read,u
UpdLeave            puls      d,x,y,u,pc


Init
* Check if subroutine already linked
                    ifgt      Level-1
                    ldx       <D.DWSubAddr
                    else
                    ldx       >D.DWSubAddr
                    endc
                    bne       leave
                    ifgt      Level-1
                    ldx       <D.Proc
                    pshs      x
                    ldx       <D.SysPrc
                    stx       <D.Proc
                    endc
                    leax      subname,pcr
                    clra
                    os9       F$Link
                    ifgt      Level-1
                    puls      x
                    stx       <D.Proc
                    bcs       leave
                    sty       <D.DWSubAddr
                    else
                    bcs       leave
                    sty       >D.DWSubAddr
                    endc
                    jmp       ,y                  call initialization routine
leave               rts

                    emod
eom                 equ       *
                    end
