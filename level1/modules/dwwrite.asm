*******************************************************
*
* DWWrite
*    Send a packet to the DriveWire server.
*    Serial data format:  1-8-N-1
*    4/12/2009 by Darren Atkinson
*
* Entry:
*    X  = starting address of data to send
*    Y  = number of bytes to send
*
* Exit:
*    X  = address of last byte sent + 1
*    Y  = 0
*    All others preserved
*


                  IFNE    MEGAMINIMPI
                    use       dwwrite/dwwrite_mmmpi.asm
                  ENDC

                  IFNE    wildbits
                  IFNE    DWIO_WIZFI
                    use       dwwrite_wildbits_wizfi.asm
                  ELSE
                    use       dwwrite_wildbits_serial.asm
                  ENDC
                  ENDC

                  IFNE    ARDUINO
                    use       dwwrite/dwwrite_arduino.asm
                  ENDC

                  IFNE    SY6551N
                    use       dwwrite/dwwrite_sy6551.asm
                  ENDC

                  IFNE    JMCPBCK
                    use       dwwrite/dwwrite_jmcpbck.asm
                  ENDC

                  IFNE    BECKER
                    use       dwwrite/dwwrite_becker.asm
                  ENDC

                  IFNE    BAUD38400
                    use       dwwrite/dwwrite_bb38400.asm
                  ENDC

                  IFNE    picothing
                    use       dwwrite/dwwrite_picothing.asm
                  ENDC

                  IFEQ    BECKER+JMCPBCK+ARDUINO+BECKERTO+SY6551N+BAUD38400+wildbits+MEGAMINIMPI+picothing
                  IFEQ    H6309
                    use       dwwrite/dwwrite_bb6809.asm
                  ELSE
                    use       dwwrite/dwwrite_bb6309.asm
                  ENDC
                  ENDC
