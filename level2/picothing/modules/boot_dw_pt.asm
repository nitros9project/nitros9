********************************************************************
* boot_dw_pt - DriveWire Boot Module for Pico-Thing Level 2
*
* Provides HWInit, HWTerm, HWRead for boot_common.asm.
*
* Uses the auxiliary virtual MC6850 ACIA at $FFC6-$FFC7 for
* DriveWire 3 protocol communication with the DW server.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*     1    2026       Initial version for Pico-Thing

                    nam       Boot
                    ttl       DriveWire Boot Module for Pico-Thing Level 2

                  IFP1
                    use       defsfile
                    use       picothing.d
                    use       drivewire.d
                  ENDC

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

* on-stack static storage
                    org       0
seglist             rmb       2         pointer to segment list
blockloc            rmb       2         pointer to requested memory
blockimg            rmb       2         duplicate of above
bootloc             rmb       3         sector pointer
bootsize            rmb       2         size in bytes
LSN0Ptr             rmb       2         pointer to LSN0 buffer
size                equ       .

name                fcs       /Boot/
                    fcb       edition

* Common booter-required defines
LSN24BIT            equ       1
FLOPPY              equ       0

                    use       boot_common.asm

*------------------------------------------------------------
*
* HWInit - Initialize the auxiliary ACIA for DriveWire
*
* Entry: Y = hardware address (unused, DW uses fixed ACIA)
* Exit:  Carry clear = OK
*
HWInit
                    use       dwinit.asm

HWTerm              clrb
                    rts

*------------------------------------------------------------
*
* HWRead - Read one 256-byte sector via DriveWire 3 protocol
*
* Entry: Y = hardware address
*        B = bits 23-16 of LSN
*        X = bits 15-0  of LSN
*        blockloc,u = pointer to 256-byte sector buffer
* Exit:  X = pointer to data (= blockloc,u)
*        Carry clear = OK, Carry set = Error
*
HWRead
                    pshs      cc,d,x
* send op code and 3-byte LSN
                    lda       #OP_READEX load READ opcode
Read2               ldb       WhchDriv,pcr
                    std       ,s
                    leax      ,s
                    ldy       #5
                    lbsr      DWWrite   send command to server
* receive 256 bytes of sector data
                    ldx       blockloc,u
                    ldy       #256
                    bsr       DWRead    read bytes from server
                    bcs       ReadEr    framing error
                    bne       ReadEr2   timeout
* send two-byte checksum back to server
                    pshs      y
                    leax      ,s
                    ldy       #2
                    lbsr      DWWrite
                    ldy       #1
                    bsr       DWRead    read server response
                    leas      2,s
                    bcs       ReadEx    framing error on response
                    bne       ReadEr2   timeout on response
                    ldb       ,s        server error code
                    beq       ReadEx    zero = success
                    cmpb      #E_CRC
                    bne       ReadEr    non-CRC error
                    lda       #OP_REREADEX CRC error, retry
                    bra       Read2
ReadEx              leas      5,s       clean stack
                    ldx       blockloc,u
                    clrb
                    rts
ReadEr2             ldb       #E$Read
ReadEr              leas      5,s       clean stack
                    orcc      #Carry
                    rts

                    use       dwread.asm
                    use       dwwrite.asm

Address             fdb       $0000     hardware address (unused for DW)
WhchDriv            fcb       $00       DW drive number

                    emod
eom                 equ       *
                    end
