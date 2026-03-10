*******************************************************
*
* DWRead
*    Receive a response from the DriveWire server.
*    Times out if serial port goes idle for more than 1.4 (0.7) seconds.
*    Serial data format:  1-8-N-1
*    4/12/2009 by Darren Atkinson
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
*

                  IFNE    MEGAMINIMPI
                    use       dwread/dwread_mmmpi.asm
                  ENDC

                  IFNE    wildbits
                  IFNE    DWIO_WIZFI
                    use       dwread_wildbits_wizfi.asm
                  ELSE
                    use       dwread_wildbits_serial.asm
                  ENDC
                  ENDC

                  IFNE    ARDUINO
                    use       dwread/dwread_arduino.asm
                  ENDC

                  IFNE    SY6551N
                    use       dwread/dwread_sy6551.asm
                  ENDC

                  IFNE    JMCPBCK
                    use       dwread/dwread_jmpcbck.asm
                  ENDC

                  IFNE    BECKER
                    use       dwread/dwread_becker.asm
                  ENDC

                  IFNE    BECKERTO
                    use       dwread/dwread_beckerto.asm
                  ENDC

                  IFNE    BAUD38400
                    use       dwread/dwread_bb38400.asm
                  ENDC

                  IFNE    picothing
                    use       dwread/dwread_picothing.asm
                  ENDC

                  IFEQ    BECKER+JMCPBCK+ARDUINO+BECKERTO+SY6551N+BAUD38400+wildbits+MEGAMINIMPI+picothing
                  IFEQ    H6309
                    use       dwread/dwread_bb6809.asm
                  ELSE
                    use       dwread/dwread_bb6309.asm
                  ENDC
                  ENDC

