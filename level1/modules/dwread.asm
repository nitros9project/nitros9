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

                    ifne      MEGAMINIMPI
                    use dwread/dwread_mmmpi.asm
                    endc

                    ifne      f256
                    use dwread_f256.asm
                    endc

                    ifne      ARDUINO
                    use dwread/dwread_arduino.asm
                    endc

                    ifne      SY6551N
                    use dwread/dwread_sy6551.asm
                    endc

                    ifne      JMCPBCK
                    use dwread/dwread_jmpcbck.asm
                    endc

                    ifne      BECKER
                    use dwread/dwread_becker.asm
                    endc

                    ifne      BECKERTO
                    use dwread/dwread_beckerto.asm
                    endc

                    ifne      BAUD38400
                    use dwread/dwread_bb38400.asm
                    endc

                    ifeq      BECKER+JMCPBCK+ARDUINO+BECKERTO+SY6551N+BAUD38400+f256+MEGAMINIMPI
                    ifeq      H6309
                    use dwread/dwread_bb6809.asm
                    else
                    use dwread/dwread_bb6309.asm
                    endc
                    endc

