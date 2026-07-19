********************************************************************
* dwinit_picothing.asm - DriveWire Init for Pico-Thing
*
* Initializes the auxiliary virtual MC6850 ACIA at $FFC6-$FFC7
* for DriveWire communication.
*
* The virtual ACIA has no physical baud rate — a master reset
* followed by 8N1 configuration is all that is needed.

DWInit
                    pshs      a
                    lda       #$03      master reset
                    sta       >Aux.Ctrl
                    lda       #$15      8N1, RTS low, no TX IRQ, no RX IRQ
                    sta       >Aux.Ctrl
                    puls      a,pc
