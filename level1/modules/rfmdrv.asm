********************************************************************
* rfmdrv - remote file manager driver
*

                    nam       rfmdrv
                    ttl       Remote file manager driver

                    ifp1
                    use       defsfile
                    use       rfm.d
                    use       drivewire.d
                    endc

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       $01

                    mod       eom,name,tylg,atrv,start,size


                    org       V.RFM
size                equ       .

                    fcb       DIR.+SHARE.+PEXEC.+PWRIT.+PREAD.+EXEC.+UPDAT.


name                fcs       /rfmdrv/
                    fcb       edition

start               lbra      Init
                    lbra      Read
                    lbra      Write
                    lbra      GetStat
                    lbra      SetStat
                    lbra      Term

* RFM must work as the first DriveWire client: no /X0 Attach prerequisite.
* D.DWSubAddr owns one shared module link, as for the RBF DriveWire driver.
Init                pshs      x,y,u
                    ifgt      Level-1
                    ldx       <D.DWSubAddr
                    else
                    ldx       >D.DWSubAddr
                    endc
                    bne       InitReady
                    ifgt      Level-1
* Link resident system modules in system-process context, then restore caller.
                    ldx       <D.Proc
                    pshs      x
                    ldx       <D.SysPrc
                    stx       <D.Proc
                    endc
                    leax      DWName,pcr
                    clra
                    os9       F$Link
                    ifgt      Level-1
                    puls      x
                    stx       <D.Proc
                    endc
                    bcs       InitReturn
                    tfr       y,x                 ; subroutine entry
                    ifgt      Level-1
                    stx       <D.DWSubAddr
                    else
                    stx       >D.DWSubAddr
                    endc
                    pshs      u                   ; linked header for failure cleanup
                    ldy       4,s                 ; original descriptor
                    ldu       6,s                 ; original device statics, not code
                    jsr       ,x
                    puls      u
                    bcs       InitFailed
                    lda       #OP_INIT
                    pshs      a
                    leax      ,s
                    ldy       #1
                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc
                    jsr       DW$Write,u
                    leas      1,s
InitReady           clrb
InitReturn          puls      x,y,u,pc
InitFailed          pshs      b,cc
                    ldd       #0
                    ifgt      Level-1
                    std       <D.DWSubAddr
                    else
                    std       >D.DWSubAddr
                    endc
                    os9       F$UnLink
                    puls      cc,b
                    bra       InitReturn
DWName              fcs       /dwio/

Read
Write
GetStat
SetStat
Term
                    nop
                    clrb
                    rts

                    emod
eom                 equ       *
                    end
