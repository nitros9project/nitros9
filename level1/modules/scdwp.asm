********************************************************************
* scdwp.asm - CoCo DriveWire Printer Driver
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  1       2009/03/06  Boisy G. Pitre
* Started.

                    nam       scdwp
                    ttl       CoCo DriveWire Printer Driver

                    ifp1
                    use       defsfile
                    use       drivewire.d
                    endc

tylg                set       Drivr+Objct
atrv                set       ReEnt+Rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,Start,Size

                    fcb       READ.+WRITE.

name                fcs       /scdwp/
                    fcb       edition             one more revision level than the stock printer

* Device memory area: offset from U
                    org       V.SCF               V.SCF: free memory for driver to use
V.PAR               rmb       1                   1=space, 2=mark parity
V.BIT               rmb       1                   0=7, 1=8 bits
V.STP               rmb       1                   0=1 stop bit, 1=2 stop bits
V.COM               rmb       2                   Com Status baud/parity (=Y from SS.Comst Set/GetStt
V.COL               rmb       1                   columns
V.ROW               rmb       1                   rows
V.WAIT              rmb       2                   wait count for baud rate?
V.TRY               rmb       2                   number of re-tries if printer is busy
V.RTRY              rmb       1                   low nibble of parity=high byte of number of retries
V.BUFF              rmb       $80                 room for 128 blocked processes
size                equ       .

start               equ       *
                    lbra      Init
                    lbra      Read
                    lbra      Write
                    lbra      GetStt
                    lbra      SetStt

* Term
*
* Entry:
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Term                equ       *
                    clrb
                    rts

* Init
*
* Entry:
*    Y  = address of device descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Init
* Check if D.DWSubAddr already holds a valid subroutine module pointer
                    ifgt      Level-1
                    ldx       <D.DWSubAddr
                    else
                    ldx       >D.DWSubAddr
                    endc
                    bne       InitEx

* If here, D.DWSubAddr is 0, so we must link to subroutine module
                    ifgt      Level-1
                    ldx       <D.Proc
                    pshs      x
                    ldx       <D.SysPrc
                    stx       <D.Proc
                    endc
                    clra
                    leax      dwioname,pcr
                    os9       F$Link
                    ifgt      Level-1
                    puls      x
                    stx       <D.Proc
                    endc
                    bcs       InitEx
                    ifgt      Level-1
                    sty       <D.DWSubAddr
                    else
                    sty       >D.DWSubAddr
                    endc
                    jsr       ,y                  call init routine
InitEx              rts

dwioname            fcs       /dwio/

* Write
*
* Entry:
*    A  = character to write
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Write               equ       *
                    tfr       a,b
                    lda       #OP_PRINT
                    pshs      d
                    leax      ,s
                    ldy       #$0002
                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc
                    jsr       6,u
                    puls      d,pc


* GetStat
*
* Entry:
*    A  = function code
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
GetStt              cmpa      #SS.EOF             end of file?
                    bne       L0112
                    clrb                          if so, exit with no error
                    rts

L0112               ldx       PD.RGS,y
                    cmpa      #SS.ScSiz
                    beq       L0123
                    cmpa      #SS.ComSt
                    bne       L0173
                    clra
                    clrb
                    std       R$Y,x
                    clrb
                    rts

* get screen size GetStt
L0123               clra
                    ldb       #80
                    std       R$X,x
                    ldb       #24
                    std       R$Y,x
                    clrb
                    rts

* SetStat
*
* Entry:
*    A  = function code
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
SetStt
Close               cmpa      #SS.Close           close the device?
                    bne       L0173
                    lda       #OP_PRINTFLUSH      send PrintQueue Flush Packet
                    pshs      a
                    ldy       #$0001
                    leax      ,s
                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc
                    jsr       6,u
                    puls      a,pc

Read                comb
                    ldb       #E$BMode
                    rts

L0173               comb
                    ldb       #E$UnkSVc
                    rts

                    emod
eom                 equ       *
                    end
