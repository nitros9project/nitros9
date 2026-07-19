********************************************************************
* dwwrite_picothing.asm - DriveWire Write for Pico-Thing
*
* Send bytes via the auxiliary virtual MC6850 ACIA at $FFC6-$FFC7.
* Polls TDRE (bit 1 of status register) before each byte.
*
* Entry:
*    X  = starting address of data to send
*    Y  = number of bytes to send
*
* Exit:
*    X  = address of last byte sent + 1
*    Y  = 0
*    All others preserved

DWWrite             pshs      cc,a      preserve registers
                  IFEQ    NOINTMASK
                    orcc      #IntMasks mask interrupts
                  ENDC
tx@                 lda       >Aux.Ctrl read status register
                    anda      #%00000010 TDRE set?
                    beq       tx@       no, keep polling
                    lda       ,x+       load byte from buffer
                    sta       >Aux.Data write to transmit register
                    leay      -1,y      decrement byte counter
                    bne       tx@       loop if more to send
                    puls      cc,a,pc
