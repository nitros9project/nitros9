********************************************************************
* mc09sdc - Multicomp09 SDCC Device Driver
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          2015/08/31  NAC
* Created from 1773 driver to support "virtual 720k disk" on SD card.
*

                    nam       mc09sdc
                    ttl       Multicomp09 SDCC Device Driver

                    use       defsfile

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       1

* Configuration Settings
N.Drives            equ       4                   number of drives to support

                    mod       eom,name,tylg,atrv,start,size

u0000               rmb       DRVBEG+(DRVMEM*N.Drives)

lsn0cp              rmb       1                   Loaded by LdSDAdrs - bytes to copy
size                equ       .

                    fcb       DIR.+SHARE.+PEXEC.+PWRIT.+PREAD.+EXEC.+UPDAT.

name                fcs       /mc09sd/
                    fcb       edition


* [NAC HACK 2015Sep04] probably ought to have timeouts on each of the
* wait loops.

* [NAC HACK 2015Sep04] based on tech ref and rb1773 we're supposed to
* get the base address from the device data structure and then access all
* the hw registers relative to that base address. rb1773 does it once and
* for all other access it uses a define. Tsk.
* Also, the device data structure doesn't seem to match what's in the
* tech ref.

*******************************************************************
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
* Multicomp09 SDCC does not require any initialisation
* [NAC HACK 2015Sep02] futures: new card detection and re-init when
* the hardware supports it.
* BUT the tech ref xplains the other stuff we need to do.
Init                equ       *

                    ldd       #$FF*256+N.Drives   'invalid' value & # of drives
                    leax      DRVBEG,u            point to start of drive tables
Init1               sta       ,x                  DD.TOT MSB to bogus value
                    sta       <V.TRAK,x           init current track # to bogus value
                    leax      <DRVMEM,x           point to next drive table
                    decb                          done all drives yet?
                    bne       Init1               no, init them all

* unlike rb1773 we do not need a sector buffer so we're done.

                    clrb                          clear carry
                    rts


*******************************************************************
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
* There are no get status calls.
* [NAC HACK 2015Sep02] futures: use it to retrieve SDcard offset of each
* drive.
GetStat             clrb                          no GetStt calls - return, no error, ignore
Return              rts


*******************************************************************
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
* There are no set status calls.
* [NAC HACK 2015Sep02] futures: use it to set SDcard offset of each
* drive, maybe mark drives as not available.
SetStat             clrb                          clear carry
                    rts


*******************************************************************
* Jump table for the public routines of this module. 3 bytes per
* entry, so any bra must be padded with a NOP. Save a few bytes by
* falling through to the last entry (Term).
*
start               bra       Init
                    nop
                    bra       Read
                    nop
                    bra       Write
                    nop
                    bra       GetStat
                    nop
                    bra       SetStat
                    nop

* FALL-THROUGH to the Term subroutine

*******************************************************************
* Term
*
* Entry:
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
* There is no memory allocated so nothing to do here, either. I
* almost feel bad..
*
Term                clrb
                    rts


*******************************************************************
* Read
*
* Entry:
*    B  = MSB of LSN
*    X  = LSB of LSN
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
* The SDcard base block for this disk is retrieved by LdSDAdrs.
*
Read                bsr       LdSDAdrs            set up address in controller
                    ldx       PD.BUF,y            Get physical sector buffer ptr

* If LSN0 is selected, will need to store the first few bytes
* both in the destination buffer and in the drive table.
* Calculate the drive table address in case we need it.
                    lda       PD.DRV,y
                    ldb       #DRVMEM
                    mul
                    leay      DRVBEG,u
                    leay      d,y

* wait for previous command (if any) to complete
RdBiz               lda       SDCTL
                    cmpa      #$80
                    bne       RdBiz

* issue the read command to the sdcard controller
                    clra
                    sta       SDCTL

* transfer 512 bytes, waiting for each in turn. only want 256
* of them - discard the rest

                    clrb                          zero is like 256
RdDBiz              lda       SDCTL
                    cmpa      #$e0
                    bne       RdDBiz              byte not ready
                    lda       SDDATA              get byte
                    sta       ,x+                 store in sector buffer

* do we also need to store it in the drive table?
                    pshs      b                   remember the count
                    ldb       lsn0cp,u
                    beq       nocp
                    sta       ,y+                 store in drive table
                    dec       lsn0cp,u

nocp                puls      b
                    decb
                    bne       RdDBiz              next

RdDBiz2             lda       SDCTL               b is already zero (like 256)
                    cmpa      #$e0
                    bne       RdDBiz2             byte not ready
                    lda       SDDATA              get byte (but do nothing with it)
                    decb
                    bne       RdDBiz2             next

                    clra                          carry clear => successful completion
                    rts


*******************************************************************
* Write
* Entry:
*    B  = MSB of LSN
*    X  = LSB of LSN
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
* The SDcard base block for this disk is retrieved by LdSDAdrs.
*
Write
                    bsr       LdSDAdrs            set up address in controller
                    ldx       PD.BUF,y            Get physical sector buffer ptr

* wait for previous command (if any) to complete
WrBiz               lda       SDCTL
                    cmpa      #$80
                    bne       WrBiz

* issue the write command to the sdcard controller
                    lda       #1
                    sta       SDCTL

* transfer 512 bytes, waiting for each in turn. Only have 256
* bytes so transfer them twice
                    pshs      x                   preserve data source
                    clrb                          zero is like 256
WrDBiz              lda       SDCTL
                    cmpa      #$a0
                    bne       WrDBiz              space not available
                    lda       ,x+                 get byte from buffer
                    sta       SDDATA              store to SD
                    decb
                    bne       WrDBiz              next

                    puls      x                   restore data source for 2nd copy
WrDBiz2             lda       SDCTL               b is zero (like 256)
                    cmpa      #$a0
                    bne       WrDBiz2             space not available
                    lda       ,x+                 get byte from buffer
                    sta       SDDATA              store to SD
                    decb
                    bne       WrDBiz2             next

                    clra                          clear carry => successful completion
                    rts


*******************************************************************
* SET SDLBA2 SDLBA1 SDLBA0 FOR NEXT SD OPERATION
* 1. The device descriptor holds a value that is the upper 16 bits
*    of the base block address of the disk image on the SDcard
* 2. If this value is QQQQ, add QQQQ00 to {B,XH,XL} to form the
*    value into the hardware registers.
* 3. Load lsn0cp with the number of bytes to be copied into the
*    LSN0 buffer - if {B,XH,XL} == 0, this DD.SIZ. Otherwise,
*    it is 0. Loaded for every operation, only *used* for Read.
*
* Entry:
*    B  = MSB of LSN
*    X  = LSB of LSN
*    Y  = address of path descriptor
*    U  = address of device memory area
* Can destroy A, B, X, CC
*
* It is a constraint that the disk image is aligned so that the
* low 8-bits of its offset are 0 (ie, it is on a 256*512 byte
* boundary). Therefore, the incoming XL value needs no manipulation
*
* [NAC HACK 2015Sep04] hack! the hardware addresses should be
* offsets from the base address stored in the device's data structure.
*
* PD.DEV,Y is the device table pointer. From this, get the
* descriptor pointer at V$DESC. From there, use the IT.xxx
* offsets to get to data in the device descriptor. This is
* long-winded because the value we need is outside of the area
* that gets copied into the path descriptor.
*
LdSDAdrs            pshs      y
                    ldy       PD.DEV,y            device table pointer
                    ldy       V$DESC,y            descriptor pointer

                    clr       lsn0cp,u            default: copy nothing
                    pshs      b

                    pshs      x                   copy of X to pull off byte by byte
                    addb      ,s+                 form b+xl
                    adcb      ,s+                 form b+xl+xh
                    bne       notlsn0             it is not LSN0. We're done.
                    ldb       #DD.SIZ
                    stb       lsn0cp,u            it is LSN0, need to copy this many bytes

notlsn0             tfr       x,d
                    stb       SDLBA0              ls byte is done.

                    ldb       IT.SOFF1,y          bits 23:16 of drive base

                    adda      IT.SOFF2,y          add bits 15:8 of drive base
                    sta       SDLBA1              middle byte is done

                    adcb      #$00                add carry from middle byte
                    addb      ,s+                 add and drop stacked b
                    stb       SDLBA2
                    puls      y,pc

                    emod
eom                 equ       *
                    end
