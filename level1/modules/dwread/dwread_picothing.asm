********************************************************************
* dwread_picothing.asm - DriveWire Read for Pico-Thing
*
* Receive bytes from the auxiliary virtual MC6850 ACIA at $FFC6-$FFC7.
* Polls RDRF (bit 0 of status register) with a $7FFF countdown timeout.
*
* Entry:
*    X  = starting address where data is to be stored
*    Y  = number of bytes expected
*
* Exit:
*    CC = carry set on framing error, Z set if all bytes received
*    X  = starting address of data received
*    Y  = checksum
*    U is preserved.  All accumulators are clobbered

DWRead              pshs      d,x,u
                    pshs      cc
                    tfr       x,u       U now points to receive buffer
                    ldx       #$0000    initialize checksum
                  IFEQ    NOINTMASK
                    orcc      #IntMasks
                  ENDC
*
rx@                 ldd       #$7FFF    initialize timeout
                    pshs      d
poll@               ldb       >Aux.Ctrl read status register
                    andb      #%00000001 RDRF set?
                    bne       got@      yes, byte waiting
                    ldd       ,s        decrement timeout
                    subd      #1
                    std       ,s
                    bne       poll@     keep polling if not timed out
                    leas      2,s       discard timeout counter
                    bra       err@
*
got@                leas      2,s       discard timeout counter
                    ldb       >Aux.Data read received byte
                    stb       ,u+       store in buffer
                    abx                 accumulate checksum
                    leay      ,-y       decrement byte count
                    bne       rx@       next byte
                    bra       ok@
*
err@                puls      cc
                    andcc     #~(Zero+Carry) ~Z = not all bytes received, ~C = no framing error
                    bra       exit@
*
ok@                 puls      cc
                    orcc      #Zero     Z = all bytes received
                    andcc     #~Carry   ~C = no framing error
exit@               tfr       x,y       return checksum in Y
                    puls      d,x,u,pc
