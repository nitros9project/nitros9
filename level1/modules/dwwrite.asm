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


                    ifne      MEGAMINIMPI
                    use dwwrite/dwwrite_mmmpi.asm
                    endc

                    ifne      f256
                    use dwwrite_f256.asm
                    endc

                    ifne      ARDUINO
                    use dwwrite/dwwrite_arduino.asm
                    endc

                    ifne      SY6551N
                    use dwwrite/dwwrite_sy6551.asm
                    endc

                    ifne      JMCPBCK
                    use dwwrite/dwwrite_jmcpbck.asm
                    endc

                    ifne      BECKER
                    use dwwrite/dwwrite_becker.asm
                    endc

                    ifne      BAUD38400
		    use dwwrite/dwwrite_bb38400.asm
                    endc

                    ifeq      BECKER+JMCPBCK+ARDUINO+BECKERTO+SY6551N+BAUD38400+f256+MEGAMINIMPI
                    ifeq      H6309
                    use dwwrite/dwwrite_bb6809.asm
                    else
                    use dwwrite/dwwrite_bb6309.asm
                    endc
                    endc
