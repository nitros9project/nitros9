********************************************************************
* Boot - CoCo SDC Boot module
* Provides HWInit, HWTerm, HWRead which are called by code in
* "use"d boot_common.asm
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          2014/12/22  Darren Atkinson
* Created.

                    nam       Boot
                    ttl       SDC Boot module

                    ifp1
                    use       defsfile
                    endc

* Default Boot is from drive 0
BootDr              set       0

* Alternate Boot is from drive 1
                    ifeq      DNum-1
BootDr              set       1
                    endc

* Common booter-required defines
LSN24BIT            equ       1
FLOPPY              equ       0

* DPort offsets
CONTROL             equ       0                   write-only
CMDREG              equ       8+0                 write-only
STATREG             equ       CMDREG              read-only
LSNREG              equ       8+1
DATAREG             equ       8+2

* NOTE: these are U-stack offsets, not DP
seglist             rmb       2                   pointer to segment list
blockloc            rmb       2                   pointer to memory requested
blockimg            rmb       2                   duplicate of the above
bootsize            rmb       2                   size in bytes
LSN0Ptr             rmb       2                   In memory LSN0 pointer
size                equ       .


tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

name                fcs       /Boot/
                    fcb       edition


*--------------------------------------------------------------------------
* HWInit - Initialize the device
*
*    Entry:
*       Y  = hardware address
*
*    Exit:
*       Carry Clear = OK, Set = Error
*       B  = error (Carry Set)
*
HWInit
                    ifne      mc09
                    clrb
                    rts
                    else
                    orcc      #$50                mask interrupts
                    lda       #$D0                stop any emulated FDC command
                    sta       CMDREG,y
                    pshs      d,x,y,u             delay
                    puls      d,x,y,u
                    lda       STATREG,y           clear INTRQ

                    ***       Fall                Thru ***
                    endc
*--------------------------------------------------------------------------
* HWTerm - Terminate the device
*
*    Entry:
*       Y  = hardware address
*
*    Exit:
*       Carry Clear = OK, Set = Error
*       B = error (Carry Set)
*
HWTerm              clrb                          no error
                    ifne      mc09
                    else
                    stb       CONTROL,y           disable command mode
                    endc
                    rts


***************************************************************************
                    use       boot_common.asm
***************************************************************************

*
* HWRead - Read a 256 byte sector from the device
*
*    Entry:
*       Y  = hardware address
*       B  = bits 23-16 of LSN
*       X  = bits 15-0  of LSN
*       blockloc,u = where to load the 256 byte sector
*
*    Exit:
*       X  = ptr to data (i.e. ptr in blockloc,u)
*       Carry Clear = OK, Set = Error
*
* multicomp09:
* for now, the image starts at SDcard block $02.8000
* so simply need to add that offset to the incoming
* LSN and load it into the hardware. Simples!
HWRead
                    ifne      mc09
                    bsr       LDSDADRS            set up address
* WAIT FOR PREVIOUS COMMAND (IF ANY) TO COMPLETE
RDBIZ               lda       SDCTL
                    cmpa      #$80
                    bne       RDBIZ

* ISSUE THE READ COMMAND TO THE SDCARD CONTROLLER
                    clra
                    sta       SDCTL

* TRANSFER 512 BYTES, WAITING FOR EACH IN TURN. ONLY WANT 256
* OF THEM - DISCARD THE REST

                    ldx       blockloc,u          get address of buffer to fill
                    pshs      x
                    clrb                          ZERO IS LIKE 256
SDRBIZ              lda       SDCTL
                    cmpa      #$E0
                    bne       SDRBIZ              BYTE NOT READY
                    lda       SDDATA              GET BYTE
                    sta       ,X+                 STORE IN SECTOR BUFFER
                    decb
                    bne       SDRBIZ              NEXT

SDRBIZ2             lda       SDCTL               B IS ALREADY ZERO (LIKE 256)
                    cmpa      #$E0
                    bne       SDRBIZ2             BYTE NOT READY
                    lda       SDDATA              GET BYTE (BUT DO NOTHING WITH IT)
                    decb
                    bne       SDRBIZ2             NEXT

                    puls      x
                    clra                          carry clear -> successful completion
                    rts

                    else
                    lda       #$43                start command mode
                    sta       CONTROL,y
                    stb       LSNREG,y            put LSN into registers
                    stx       LSNREG+1,y
                    clra                          A=0 for use at rdExit
                    bsr       waitSDC             wait for BUSY to be cleared
                    bcs       rdExit              exit on error or timeout
                    ldb       WhichDrv,pcr        get drive number
                    andb      #1                  limit to 0 or 1
                    orb       #$80                combine with Read Sector command
                    stb       CMDREG,y            send command to controller
                    bsr       waitSDC             wait for data READY
                    bcs       rdExit              exit on error or timeout
                    ldx       blockloc,u          get address of buffer to fill
                    pshs      u,x                 preserve U and X
                    ldb       #256/2              1/2 sector size
rdLoop              ldu       DATAREG,y           read word data from controller
                    stu       ,x++                store to buffer
                    decb                          decrement word counter
                    bne       rdLoop              loop until done
                    puls      x,u                 restore X and U
rdExit              sta       CONTROL,y           end command mode
                    rts
                    endc

                    ifne      mc09
*******************************************************************
* SET SDLBA2 SDLBA1 SDLBA0 FOR NEXT SD OPERATION
* add $02.8000 to {B,XH,XL} and load into the hardware
* registers.
* Can destroy A, B, X, CC
* Assumption: the lowest byte of the adder ($02.8000 here) will
* always be 0 and so never need fixup
LDSDADRS            pshs      b
                    tfr       x,d
                    stb       SDLBA0              ls byte is done.

                    ldb       #$02

                    adda      #$80
                    sta       SDLBA1              middle byte is done

                    adcb      #$00                add carry from middle byte
                    addb      ,s+                 add and drop stacked b
                    stb       SDLBA2
                    rts
                    else

*--------------------------------------------------------------------------
* Wait for controller status to indicate either "Not Busy" or "Ready".
* Will time out if neither condition satisfied within a suitable period.
*
* Exit:
*    CC.C set on error or time out
*
waitSDC             ldx       #0                  setup timeout counter
waitLp              bsr       waitRet             extra cycles for timeout
                    comb                          set carry for timeout/FAILED
                    leax      ,-x                 decrement timeout counter
                    beq       waitRet             return if timed out
                    ldb       STATREG,y           read status
                    bmi       waitRet             return if FAILED
                    lsrb                          BUSY --> Carry
                    bcc       waitRet             return if not busy
                    rolb                          clear carry
                    bitb      #2                  test READY
                    beq       waitLp              loop if not ready for transfer
waitRet             rts                           return
                    endc


*--------------------------------------------------------------------------

                    ifgt      Level-1
* L2 kernel file is composed of rel, boot, krn. The size of each of these
* is controlled with filler, so that (after relocation):
* rel  starts at $ED00 and is $130 bytes in size
* boot starts at $EE30 and is $1D0 bytes in size
* krn  starts at $F000 and ends at $FEFF (there is no 'emod' at the end
*      of krn and so there are no module-end boilerplate bytes)
*
* Filler to get to a total size of $1D0. 3, 2, 1 represent bytes after
* the filler: the end boilerplate for the module, fdb and fcb respectively.
Filler              fill      $39,$1D0-3-2-1-*
                    endc

Address             fdb       DPort
WhichDrv            fcb       BootDr

                    emod
eom                 equ       *
                    end
