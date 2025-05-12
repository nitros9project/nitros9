*******************************************************************
* lldummy - Low-level dummy driver
*
* This driver exists purely for performance testing. It doesn't interface
* with any hardware.
*
* Date         System               Megaread 3 run average time
* -----------  -------------------  ---------------------------
* 12-Jul-2024  F256K                4.333 seconds
* 12-Jul-2024  6809 CoCo 3          19.666 seconds
* 12-Jul-2024  6309 CoCo 3          9.333 seconds
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*     1    2024/07/12  Boisy G. Pitre
* Created.

                    ifp1
                    use       defsfile
                    use       rbsuper.d
                    use       ide.d
                    endc

tylg                set       Sbrtn+Objct
atrv                set       ReEnt+rev
rev                 set       1

                    mod       eom,name,tylg,atrv,start,0

NumRetries          equ       8

* Low-level driver static memory area
                    org       V.LLMem
* Put any static storage for the driver here.
V.PhySct            rmb       3                   local copy of physical sector passed (V.PhySct)
V.SctCnt            rmb       1                   local copy of physical sector passed (V.SectCnt)

name                fcs       /lldummy/

start               bra       ll_init
                    nop
                    lbra      ll_read
                    lbra      ll_write
                    lbra      ll_getstat
                    lbra      ll_setstat

* ll_init - Low level init routine
*
* Entry:
*    Y  = address of device descriptor
*    U  = address of low level device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
* Note: This routine is called ONCE: for the first device
* IT IS NOT CALLED PER DEVICE!
*
ll_init
*         clrb
*         rts


* ll_term - Low level term routine
*
* Entry:
*    Y  = address of device descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
* Note: This routine is called ONCE: for the last device
* IT IS NOT CALLED PER DEVICE!
*
ll_term
                    clrb
                    rts

* ll_getstat - Low level GetStat routine
*
* Entry:
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
ll_getstat
                    ldx       PD.RGS,y
                    lda       R$B,x
                    cmpa      #SS.DSize
                    beq       SSDSize
                    ldb       #E$UnkSvc
                    coma
SSDSize
ex1                 rts

* ll_setstat - Low level SetStat routine
*
* Entry:
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
ll_setstat
                    ldx       PD.RGS,y
                    lda       R$B,x
                    cmpa      #SS.SQD
                    beq       StopUnit
                    ifne      0
                    cmpa      #SS.DCmd
                    bne       n@
                    pshs      x                   save pointer to caller registers
                    bsr       DCmd                call DCmd
                    puls      x                   get pointer to caller registers
                    sta       R$A,x               save status byte in A
                    endc
n@                  clrb
DCMd
StopUnit
ssex                rts


* ll_read - Low level read routine
*
* Entry:
*    Registers:
*      Y  = address of path descriptor
*      U  = address of device memory area
*    Static Variables of interest:
*      V.PhySct = starting physical sector to read from
*      V.SectCnt  = number of physical sectors to read
*      V.SectSize = physical sector size (0=256,1=512,2=1024,3=2048)
*      V.CchPSpot = address where physical sector(s) will go
*
* Exit:
*    All registers may be modified
*    Static variables may NOT be modified
ll_read
                    pshs      x                   make some space on the stack
* Copy V.PhySct and V.SectCnt to our local copy
* since we cannot modify them.
                    lda       V.PhysSect,u
                    ldy       V.PhysSect+1,u
                    sta       V.PhySct,u
                    sty       V.PhySct+1,u
                    lda       V.SectCnt,u
                    sta       V.SctCnt,u
* Increment physical sector
loop@
                    inc       V.PhySct+2,u
                    bcc       go@
                    inc       V.PhySct+1,u
                    bcc       go@
                    inc       V.PhySct,u
go@                 dec       V.SctCnt,u          decrement # of hw sectors to read
                    bne       loop@               if not zero, do it again
                    clrb
ex@                 puls      x,pc


* ll_write - Low level write routine
*
* Entry:
*    Registers:
*      Y  = address of path descriptor
*      U  = address of device memory area
*    Static Variables of interest:
*      V.PhySct = starting physical sector to write to
*      V.SectCnt  = number of physical sectors to write
*      V.SectSize = physical sector size (0=256,1=512,2=1024,3=2048)
*      V.CchPSpot = address of data to write to device
*
* Exit:
*    All registers may be modified
*    Static variables may NOT be modified
ll_write
                    pshs      x                   make some space on the stack
* Copy V.PhySct to our local copy
                    lda       V.PhysSect,u
                    ldy       V.PhysSect+1,u
                    sta       V.PhySct,u
                    sty       V.PhySct+1,u
                    lda       V.SectCnt,u
                    sta       V.SctCnt,u
loop@
                    ldy       V.CchPSpot,u        get pointer to spot in cache where physical sector is
* Increment physical sector
                    inc       V.PhySct+2,u
                    bcc       go@
                    inc       V.PhySct+1,u
                    bcc       go@
                    inc       V.PhySct,u
go@
                    dec       V.SctCnt,u          decrement # of hw sectors to read
                    bne       loop@               if not zero, do it again
                    clrb
ex@                 puls      x,pc

                    emod
eom                 equ       *
                    end
