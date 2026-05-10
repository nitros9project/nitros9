*******************************************************
*
* DWInit
*    Initialize DriveWire for CoCo Bit Banger
    
                    ifne      MEGAMINIMPI
                    use dwinit/dwinit_mmmpi.asm
                    endc

                    ifne      wildbits
                    ifne      DWIO_WIZFI
                    use dwinit_wildbits_wizfi.asm
                    else
                    use dwinit_wildbits_serial.asm
                    endc
                    endc

                    ifne      ARDUINO
                    use dwinit/dwinit_arduino.asm
                    endc

                    ifne      BECKER
                    use dwinit/dwinit_none.asm
                    endc

                    ifne      JMCPBCK+atari
                    use dwinit/dwinit_none.asm
                    endc

                    ifne      BECKERTO
                    use dwinit/dwinit_none.asm
                    endc

                    ifne      SY6551N
                    use dwinit/dwinit_none.asm
                    endc

                    ifeq      BECKER+JMCPBCK+ARDUINO+BECKERTO+SY6551N+wildbits+MEGAMINIMPI+atari
                    use dwinit/dwinit_bb.asm
                    endc
