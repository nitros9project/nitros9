*******************************************************
*
* DWInit
*    Initialize DriveWire for CoCo Bit Banger
    
                    ifne      MEGAMINIMPI
                    use dwinit/dwinit_mmmpi.asm
                    endc

                    ifne      f256
                    use dwinit_f256.asm
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

                    ifeq      BECKER+JMCPBCK+ARDUINO+BECKERTO+SY6551N+f256+MEGAMINIMPI+atari
                    use dwinit/dwinit_bb.asm
                    endc
